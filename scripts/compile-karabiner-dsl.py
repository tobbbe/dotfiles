#!/usr/bin/env python3
#
# DSL syntax: see compile-karabiner-dsl.spec
#
# Triggers:
#   key combo: [modifier-]...<key>[?]  e.g. cmd-s, c-s-a, caps_lock?
#   sequence:  <combo>><combo>...      e.g. cmd-s>g  (trie-based, timeout via --timeout-ms)
#
# Modifiers: c (left_control), s (left_shift), a (left_option), cmd (left_command)
#             rc (right_control), rs (right_shift), ra (right_option), rcmd (right_command)
#
# Actions (inside to/to_if_alone/to_if_held_down/to_if_invoked/to_if_canceled):
#   key_code: <key> [(options)]        send key (options: halt=true, repeat=false,
#   consumer_key_code: <key>                      hold_down_milliseconds=N, modifiers=any)
#   apple_vendor_key_code: <key>       → apple_vendor_keyboard_key_code
#   shell: <command>                   → shell_command
#   set_variable: <name>=<value>       → set_variable {name, expression}
#   open: <bundle-id>                  → software_function.open_application
#
# Lines starting with # and blank lines are ignored.

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Modifier maps
# ---------------------------------------------------------------------------

MODIFIER_MAP = {
    "ctrl":    "control",
    "ctrl_l":  "left_control",
    "ctrl_r":  "right_control",
    "cmd":     "command",
    "cmd_l":   "left_command",
    "cmd_r":   "right_command",
    "shift":   "shift",
    "shift_l": "left_shift",
    "shift_r": "right_shift",
    "opt":     "option",
    "opt_l":   "left_option",
    "opt_r":   "right_option",
}


class DslError(Exception):
    pass


# ---------------------------------------------------------------------------
# Lexer / line model
# ---------------------------------------------------------------------------

@dataclass
class Line:
    number: int
    indent: int
    text: str  # stripped


def lex(source: str) -> List[Line]:
    result = []
    for i, raw in enumerate(source.splitlines(), start=1):
        stripped = raw.strip()
        if not stripped or stripped.startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        result.append(Line(i, indent, stripped))
    return result


# ---------------------------------------------------------------------------
# Key / modifier parsing helpers
# ---------------------------------------------------------------------------

def parse_key_combo(token: str, ln: int) -> Tuple[str, List[str]]:
    """Parse mod-mod-key into (key_code, [modifiers])."""
    parts = token.split("-")
    if len(parts) == 1:
        return parts[0], []
    key = parts[-1]
    mods: List[str] = []
    seen: set = set()
    for m in parts[:-1]:
        if m not in MODIFIER_MAP:
            raise DslError(f"Line {ln}: unknown modifier '{m}' in '{token}'")
        mapped = MODIFIER_MAP[m]
        if mapped in seen:
            raise DslError(f"Line {ln}: duplicate modifier in '{token}'")
        seen.add(mapped)
        mods.append(mapped)
    return key, mods


def parse_from(token: str, ln: int) -> Dict[str, Any]:
    """Parse trigger token (with optional ? suffix) into karabiner from object."""
    optional_any = token.endswith("?")
    if optional_any:
        token = token[:-1]
    key, mods = parse_key_combo(token, ln)
    obj: Dict[str, Any] = {"key_code": key}
    modifiers: Dict[str, Any] = {}
    if mods:
        modifiers["mandatory"] = sorted(mods)
    if optional_any:
        modifiers["optional"] = ["any"]
    if modifiers:
        obj["modifiers"] = modifiers
    return obj


def parse_remap_key(token: str) -> Dict[str, Any]:
    """Parse a simple-modification key (with optional type prefix)."""
    if token.startswith("consumer:"):
        return {"consumer_key_code": token[len("consumer:"):]}
    if token.startswith("top_case:"):
        return {"apple_vendor_top_case_key_code": token[len("top_case:"):]}
    return {"key_code": token}


# ---------------------------------------------------------------------------
# Action parsing
# ---------------------------------------------------------------------------

def parse_options(opts_str: str, ln: int) -> Dict[str, Any]:
    """Parse '(halt=true repeat=false hold_down_milliseconds=200)' into a dict."""
    result: Dict[str, Any] = {}
    for part in opts_str.split():
        if "=" not in part:
            raise DslError(f"Line {ln}: invalid option '{part}'")
        k, v = part.split("=", 1)
        if v == "true":
            result[k] = True
        elif v == "false":
            result[k] = False
        elif v == "any":
            result[k] = v
        else:
            try:
                result[k] = int(v)
            except ValueError:
                result[k] = v
    return result


def parse_action_line(text: str, ln: int) -> Dict[str, Any]:
    """Parse a single action line into a karabiner to-entry dict."""

    # key_code: <key> [(options)]
    m = re.match(r"^key_code:\s+(\S+)(?:\s+\(([^)]*)\))?$", text)
    if m:
        raw_key, opts_str = m.group(1), m.group(2)
        key, mods = parse_key_combo(raw_key, ln)
        entry: Dict[str, Any] = {"key_code": key}
        if mods:
            entry["modifiers"] = sorted(mods)
        if opts_str:
            opts = parse_options(opts_str, ln)
            if "modifiers" in opts and opts["modifiers"] == "any":
                entry["modifiers"] = ["any"]
                del opts["modifiers"]
            for k, v in opts.items():
                entry[k] = v
        return entry

    # consumer_key_code: <key>
    m = re.match(r"^consumer_key_code:\s+(\S+)$", text)
    if m:
        return {"consumer_key_code": m.group(1)}

    # apple_vendor_key_code: <key>  →  apple_vendor_keyboard_key_code
    m = re.match(r"^apple_vendor_key_code:\s+(\S+)$", text)
    if m:
        return {"apple_vendor_keyboard_key_code": m.group(1)}

    # shell: <rest of line>
    m = re.match(r"^shell:\s+(.+)$", text)
    if m:
        return {"shell_command": m.group(1)}

    # set_variable: name=value
    m = re.match(r"^set_variable:\s+(\S+?)=(.+)$", text)
    if m:
        return {"set_variable": {"expression": m.group(2), "name": m.group(1)}}

    # open: <bundle-id>
    m = re.match(r"^open:\s+(\S+)$", text)
    if m:
        return {"software_function": {"open_application": {"bundle_identifier": m.group(1)}}}

    raise DslError(f"Line {ln}: unrecognised action '{text}'")


# ---------------------------------------------------------------------------
# Condition parsing
# ---------------------------------------------------------------------------

def parse_conditions(tokens: List[str], ln: int) -> List[Dict[str, Any]]:
    """
    Parse condition tokens from a map line into karabiner condition objects.
    Tokens: if_app id id ..., unless_app id ..., if_expr="...", if_input_source="..."
    Repeating a keyword creates a separate condition (AND).
    """
    conditions: List[Dict[str, Any]] = []
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        if tok in ("if_app", "unless_app"):
            kind = "frontmost_application_if" if tok == "if_app" else "frontmost_application_unless"
            ids: List[str] = []
            i += 1
            while i < len(tokens) and not (
                tokens[i] in ("if_app", "unless_app")
                or tokens[i].startswith("if_expr=")
                or tokens[i].startswith("if_input_source=")
            ):
                # next token might be a condition keyword at start (quoted)
                tok_val = tokens[i]
                if tok_val.startswith('"') and tok_val.endswith('"'):
                    tok_val = tok_val[1:-1]
                ids.append(tok_val)
                i += 1
            conditions.append({"bundle_identifiers": ids, "type": kind})
        elif tok.startswith("if_expr="):
            expr = tok[len("if_expr="):]
            if expr.startswith('"') and expr.endswith('"'):
                expr = expr[1:-1]
            conditions.append({"expression": expr, "type": "expression_if"})
            i += 1
        elif tok.startswith("if_input_source="):
            lang = tok[len("if_input_source="):]
            if lang.startswith('"') and lang.endswith('"'):
                lang = lang[1:-1]
            conditions.append({"input_sources": [{"language": lang}], "type": "input_source_if"})
            i += 1
        else:
            raise DslError(f"Line {ln}: unknown condition token '{tok}'")
    return conditions


# ---------------------------------------------------------------------------
# Block reader
# ---------------------------------------------------------------------------

class BlockReader:
    def __init__(self, lines: List[Line]):
        self.lines = lines
        self.pos = 0

    def peek(self) -> Optional[Line]:
        if self.pos < len(self.lines):
            return self.lines[self.pos]
        return None

    def consume(self) -> Line:
        line = self.lines[self.pos]
        self.pos += 1
        return line

    def consume_children(self, parent_indent: int) -> List[Line]:
        """Consume all lines indented more than parent_indent."""
        children = []
        while self.peek() and self.peek().indent > parent_indent:
            children.append(self.consume())
        return children

    def at_end(self) -> bool:
        return self.pos >= len(self.lines)


# ---------------------------------------------------------------------------
# Parse action block (to / to_if_alone / etc.)
# ---------------------------------------------------------------------------

def parse_action_block(children: List[Line]) -> List[Dict[str, Any]]:
    """Parse a flat list of action lines into a list of karabiner to-entries."""
    actions = []
    for line in children:
        actions.append(parse_action_line(line.text, line.number))
    return actions


# ---------------------------------------------------------------------------
# Parse to_delayed_action block
# ---------------------------------------------------------------------------

def parse_to_delayed_action(children: List[Line]) -> Dict[str, Any]:
    """
    Children of to_delayed_action: to_if_invoked and to_if_canceled blocks.
    """
    result: Dict[str, Any] = {}
    reader = BlockReader(children)
    while not reader.at_end():
        line = reader.consume()
        sub = reader.consume_children(line.indent)
        if line.text == "to_if_canceled":
            result["to_if_canceled"] = parse_action_block(sub)
        elif line.text == "to_if_invoked":
            result["to_if_invoked"] = parse_action_block(sub)
        else:
            raise DslError(f"Line {line.number}: unexpected in to_delayed_action: '{line.text}'")
    return result


# ---------------------------------------------------------------------------
# Parse map block
# ---------------------------------------------------------------------------

def parse_map_body(header_line: Line, children: List[Line]) -> Dict[str, Any]:
    """
    Parse the body of a map block (to, to_if_alone, to_if_held_down,
    to_delayed_action, parameters) and return a partial manipulator dict.
    """
    manip: Dict[str, Any] = {}
    reader = BlockReader(children)
    while not reader.at_end():
        line = reader.consume()
        sub = reader.consume_children(line.indent)
        if line.text == "to":
            manip["to"] = parse_action_block(sub)
        elif line.text == "to_if_alone":
            manip["to_if_alone"] = parse_action_block(sub)
        elif line.text == "to_if_held_down":
            manip["to_if_held_down"] = parse_action_block(sub)
        elif line.text == "to_delayed_action":
            manip["to_delayed_action"] = parse_to_delayed_action(sub)
        elif line.text == "parameters":
            params: Dict[str, Any] = {}
            for p in sub:
                k, _, v = p.text.partition(": ")
                try:
                    params[k.strip()] = int(v.strip())
                except ValueError:
                    params[k.strip()] = v.strip()
            manip["parameters"] = params
        else:
            raise DslError(f"Line {line.number}: unexpected in map body: '{line.text}'")
    return manip


# ---------------------------------------------------------------------------
# Trie for sequences
# ---------------------------------------------------------------------------

@dataclass
class TrieNode:
    children: Dict[str, "TrieNode"] = field(default_factory=dict)
    mapping: Optional[Dict[str, Any]] = None  # partial manipulator body
    node_id: Optional[str] = None
    parent: Optional["TrieNode"] = None


def insert_sequence(root: TrieNode, tokens: List[str], body: Dict[str, Any],
                    ln: int) -> None:
    node = root
    for tok in tokens:
        if tok not in node.children:
            child = TrieNode(parent=node)
            node.children[tok] = child
        node = node.children[tok]
    if node.mapping is not None:
        raise DslError(f"Line {ln}: duplicate sequence trigger")
    node.mapping = body


def assign_trie_ids(root: TrieNode) -> None:
    counter = 0

    def walk(node: TrieNode) -> None:
        nonlocal counter
        for child in node.children.values():
            counter += 1
            child.node_id = f"dsl_state_{counter}"
            walk(child)

    walk(root)


def build_trie_manipulators(root: TrieNode, conditions: List[Dict[str, Any]],
                             timeout_ms: int) -> List[Dict[str, Any]]:
    manipulators: List[Dict[str, Any]] = []

    def walk(node: TrieNode, path: List[str]) -> None:
        for token, child in node.children.items():
            ln = 0
            from_obj = parse_from(token, ln)

            conds = list(conditions)
            if node.node_id is not None:
                conds.append({
                    "expression": f"{node.node_id} > system.now.milliseconds",
                    "type": "expression_if",
                })

            if child.mapping is None:
                to_entries = [{
                    "set_variable": {
                        "expression": f"system.now.milliseconds + {timeout_ms}",
                        "name": child.node_id,
                    }
                }]
            else:
                body = child.mapping
                to_entries = list(body.get("to", []))
                # clear all ancestor trie nodes
                walker: Optional[TrieNode] = child
                while walker is not None and walker.node_id is not None:
                    to_entries.append({
                        "set_variable": {"expression": "0", "name": walker.node_id}
                    })
                    walker = walker.parent

            manip: Dict[str, Any] = {"from": from_obj, "to": to_entries, "type": "basic"}
            if conds:
                manip["conditions"] = conds
            manipulators.append(manip)
            walk(child, [*path, token])

    walk(root, [])
    return manipulators


# ---------------------------------------------------------------------------
# Top-level parser
# ---------------------------------------------------------------------------

@dataclass
class ParsedDsl:
    profile_name: str = "Default"
    global_settings: Dict[str, Any] = field(default_factory=dict)
    virtual_hid_keyboard: Dict[str, Any] = field(default_factory=dict)
    complex_parameters: Dict[str, Any] = field(default_factory=dict)
    simple_modifications: List[Dict[str, Any]] = field(default_factory=list)
    devices: List[Dict[str, Any]] = field(default_factory=list)
    rules: List[Dict[str, Any]] = field(default_factory=list)  # [{title/description, manipulators}]
    variables: Dict[str, List[str]] = field(default_factory=dict)


def expand_vars(tokens: List[str], variables: Dict[str, List[str]], ln: int) -> List[str]:
    result = []
    for tok in tokens:
        if tok.startswith("$"):
            name = tok[1:]
            if name not in variables:
                raise DslError(f"Line {ln}: unknown variable '${name}'")
            result.extend(variables[name])
        else:
            result.append(tok)
    return result


def coerce_value(v: str) -> Any:
    if v == "true":
        return True
    if v == "false":
        return False
    try:
        return int(v)
    except ValueError:
        return v


def tokenize_map_line(text: str) -> List[str]:
    """Split a map line into tokens, keeping quoted strings together."""
    tokens = []
    current = []
    in_quote = False
    for ch in text:
        if ch == '"':
            in_quote = not in_quote
            current.append(ch)
        elif ch == " " and not in_quote:
            if current:
                tokens.append("".join(current))
                current = []
        else:
            current.append(ch)
    if current:
        tokens.append("".join(current))
    return tokens


def parse_dsl(lines: List[Line], timeout_ms: int) -> ParsedDsl:
    result = ParsedDsl()
    reader = BlockReader(lines)
    # pending rule context
    current_rule_title: Optional[str] = None
    current_rule_key: str = "title"
    current_manipulators: List[Dict[str, Any]] = []

    def flush_rule() -> None:
        nonlocal current_rule_title, current_manipulators
        if current_manipulators:
            rule: Dict[str, Any] = {current_rule_key: current_rule_title,
                                    "manipulators": current_manipulators}
            result.rules.append(rule)
        current_rule_title = None
        current_manipulators = []

    def add_manipulator(m: Dict[str, Any]) -> None:
        if current_rule_title is None:
            raise DslError("map outside of a rule block")
        current_manipulators.append(m)

    while not reader.at_end():
        line = reader.consume()

        # --- var ---
        m = re.match(r"^var\s+(\w+)\s+(.+)$", line.text)
        if m:
            name, rest = m.group(1), m.group(2)
            result.variables[name] = rest.split()
            continue

        # --- profile ---
        m = re.match(r'^profile\s+name="(.+)"$', line.text)
        if m:
            result.profile_name = m.group(1)
            continue

        # --- global ---
        if line.text == "global":
            children = reader.consume_children(line.indent)
            for child in children:
                k, _, v = child.text.partition(": ")
                result.global_settings[k.strip()] = coerce_value(v.strip())
            continue

        # --- virtual_hid_keyboard ---
        if line.text == "virtual_hid_keyboard":
            children = reader.consume_children(line.indent)
            for child in children:
                k, _, v = child.text.partition(": ")
                result.virtual_hid_keyboard[k.strip()] = coerce_value(v.strip())
            continue

        # --- complex_parameters ---
        if line.text == "complex_parameters":
            children = reader.consume_children(line.indent)
            for child in children:
                k, _, v = child.text.partition(": ")
                result.complex_parameters[k.strip()] = coerce_value(v.strip())
            continue

        # --- remap (profile-level simple modification) ---
        m = re.match(r"^remap\s+(\S+)\s+->\s+(\S+)$", line.text)
        if m:
            frm = parse_remap_key(m.group(1))
            to = parse_remap_key(m.group(2))
            result.simple_modifications.append({"from": frm, "to": [to]})
            continue

        # --- device ---
        m = re.match(r"^device\s+(.+)$", line.text)
        if m:
            flush_rule()
            attrs_str = m.group(1)
            attrs: Dict[str, Any] = {}
            for part in attrs_str.split():
                k, _, v = part.partition("=")
                attrs[k] = coerce_value(v)
            children = reader.consume_children(line.indent)
            # parse device simple_modifications
            dev_remaps: List[Dict[str, Any]] = []
            for child in children:
                rm = re.match(r"^remap\s+(\S+)\s+->\s+(\S+)$", child.text)
                if rm:
                    frm = parse_remap_key(rm.group(1))
                    to = parse_remap_key(rm.group(2))
                    dev_remaps.append({"from": frm, "to": [to]})
                else:
                    raise DslError(f"Line {child.number}: unexpected in device block: '{child.text}'")
            device = build_device(attrs, dev_remaps)
            result.devices.append(device)
            continue

        # --- rule ---
        m = re.match(r'^rule\s+description="(.+)"$', line.text)
        if m:
            flush_rule()
            current_rule_key = "description"
            current_rule_title = m.group(1)
            current_manipulators = []
            continue

        m = re.match(r'^rule\s+"(.+)"$', line.text)
        if m:
            flush_rule()
            current_rule_key = "title"
            current_rule_title = m.group(1)
            current_manipulators = []
            continue

        # --- map ---
        if line.text.startswith("map "):
            rest = line.text[4:]
            tokens = tokenize_map_line(rest)
            trigger_token = tokens[0]
            remaining = expand_vars(tokens[1:], result.variables, line.number)

            # Inline form: map <trigger> [conditions] to <action>
            if "to" in remaining:
                to_idx = remaining.index("to")
                cond_tokens = remaining[:to_idx]
                action_text = " ".join(remaining[to_idx + 1:])
                body = {"to": [parse_action_line(action_text, line.number)]}
                children = []
            else:
                cond_tokens = remaining
                children = reader.consume_children(line.indent)
                body = parse_map_body(line, children)

            conditions = parse_conditions(cond_tokens, line.number) if cond_tokens else []

            # Sequence?
            if ">" in trigger_token:
                seq_tokens = trigger_token.split(">")
                trie = TrieNode()
                insert_sequence(trie, seq_tokens, body, line.number)
                assign_trie_ids(trie)
                manips = build_trie_manipulators(trie, conditions, timeout_ms)
                for manip in manips:
                    add_manipulator(manip)
            else:
                from_obj = parse_from(trigger_token, line.number)
                manip: Dict[str, Any] = {"from": from_obj, "type": "basic"}
                if conditions:
                    manip["conditions"] = conditions
                manip.update({k: v for k, v in body.items()})
                add_manipulator(manip)
            continue

        raise DslError(f"Line {line.number}: unexpected top-level statement: '{line.text}'")

    flush_rule()
    return result


# ---------------------------------------------------------------------------
# Device builder
# ---------------------------------------------------------------------------

DEVICE_BOOL_FIELDS = [
    "disable_built_in_keyboard_if_exists",
    "ignore",
    "manipulate_caps_lock_led",
]


def build_device(attrs: Dict[str, Any], remaps: List[Dict[str, Any]]) -> Dict[str, Any]:
    vendor_id = attrs["vendor"]
    product_id = attrs["product"]
    is_pointing = attrs.get("is_pointing_device", False)
    empty_simple_mods = attrs.get("simple_modifications") == "empty"

    device: Dict[str, Any] = {}

    if not is_pointing:
        if "disable_built_in_keyboard_if_exists" in attrs:
            device["disable_built_in_keyboard_if_exists"] = attrs["disable_built_in_keyboard_if_exists"]

    if "ignore" in attrs:
        device["ignore"] = attrs["ignore"]

    if not is_pointing and "manipulate_caps_lock_led" in attrs:
        device["manipulate_caps_lock_led"] = attrs["manipulate_caps_lock_led"]

    identifiers: Dict[str, Any] = {
        "is_keyboard": True,
        "is_pointing_device": is_pointing,
        "product_id": product_id,
        "vendor_id": vendor_id,
    }
    device["identifiers"] = identifiers

    if not is_pointing:
        device["fn_function_keys"] = []

    if remaps:
        device["simple_modifications"] = remaps
    elif empty_simple_mods:
        device["simple_modifications"] = []

    return device


# ---------------------------------------------------------------------------
# Output builder
# ---------------------------------------------------------------------------

def build_output(parsed: ParsedDsl) -> Dict[str, Any]:
    rules_out = []
    for rule in parsed.rules:
        key = "description" if "description" in rule else "title"
        rules_out.append({key: rule[key], "manipulators": rule["manipulators"]})

    complex_mods: Dict[str, Any] = {}
    if parsed.complex_parameters:
        complex_mods["parameters"] = parsed.complex_parameters
    complex_mods["rules"] = rules_out

    profile: Dict[str, Any] = {
        "complex_modifications": complex_mods,
        "devices": parsed.devices,
        "name": parsed.profile_name,
        "selected": True,
        "simple_modifications": parsed.simple_modifications,
        "virtual_hid_keyboard": parsed.virtual_hid_keyboard,
    }

    return {
        "global": parsed.global_settings,
        "profiles": [profile],
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def compile_dsl(input_path: Path, output_path: Path, timeout_ms: int) -> None:
    source = input_path.read_text(encoding="utf-8")
    lines = lex(source)
    parsed = parse_dsl(lines, timeout_ms)
    output = build_output(parsed)
    output_path.write_text(
        json.dumps(output, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Compile keymap DSL to Karabiner JSON")
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--timeout-ms", type=int, default=800)
    args = parser.parse_args()

    if args.timeout_ms <= 0:
        print("--timeout-ms must be > 0", file=sys.stderr)
        return 1

    try:
        compile_dsl(args.input, args.output, args.timeout_ms)
    except FileNotFoundError as e:
        print(str(e), file=sys.stderr)
        return 1
    except DslError as e:
        print(str(e), file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
