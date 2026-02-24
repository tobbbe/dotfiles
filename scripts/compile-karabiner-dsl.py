#!/usr/bin/env python3

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple


MODIFIER_MAP = {
    "c": "left_control",
    "s": "left_shift",
    "a": "left_option",
    "cmd": "left_command",
}


class DslError(Exception):
    pass


@dataclass
class Action:
    kind: str
    argument: str


@dataclass
class Mapping:
    line_number: int
    trigger_parts: List[str]
    action: Action


@dataclass
class TrieNode:
    children: Dict[str, "TrieNode"] = field(default_factory=dict)
    mapping: Optional[Mapping] = None
    node_id: Optional[str] = None
    parent: Optional["TrieNode"] = None


def parse_line(line: str, line_number: int) -> Optional[Mapping]:
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        return None

    match = re.match(r"^map\s+(\S+)\s+(\S+)(?:\s+(.*))?$", stripped)
    if not match:
        raise DslError(f"Line {line_number}: invalid syntax")

    trigger = match.group(1)
    action_name = match.group(2)
    action_arg = (match.group(3) or "").strip()

    if not action_arg:
        raise DslError(
            f"Line {line_number}: missing argument for action '{action_name}'"
        )

    trigger_parts = trigger.split(">")
    if any(not part for part in trigger_parts):
        raise DslError(f"Line {line_number}: invalid trigger '{trigger}'")

    valid_actions = {"send_text", "open_url", "open", "script", "to_keys"}
    if action_name not in valid_actions:
        raise DslError(f"Line {line_number}: unknown action '{action_name}'")

    return Mapping(
        line_number=line_number,
        trigger_parts=trigger_parts,
        action=Action(kind=action_name, argument=action_arg),
    )


def parse_key_combo(token: str, line_number: int) -> Tuple[str, List[str]]:
    parts = token.split("-")
    if any(not part for part in parts):
        raise DslError(f"Line {line_number}: invalid key combo '{token}'")

    if len(parts) == 1:
        return parts[0], []

    key_code = parts[-1]
    modifier_tokens = parts[:-1]
    modifiers: List[str] = []
    seen = set()

    for modifier_token in modifier_tokens:
        if modifier_token not in MODIFIER_MAP:
            allowed = ", ".join(MODIFIER_MAP.keys())
            raise DslError(
                f"Line {line_number}: unknown modifier '{modifier_token}' in '{token}' (allowed: {allowed})"
            )
        mapped = MODIFIER_MAP[modifier_token]
        if mapped in seen:
            raise DslError(f"Line {line_number}: duplicate modifier in '{token}'")
        seen.add(mapped)
        modifiers.append(mapped)

    return key_code, modifiers


def parse_trigger_token(token: str, line_number: int) -> Dict[str, object]:
    key_code, modifiers = parse_key_combo(token, line_number)
    from_obj: Dict[str, object] = {"key_code": key_code}
    if modifiers:
        from_obj["modifiers"] = {"mandatory": modifiers}
    return from_obj


def build_action_to(action: Action, line_number: int) -> List[Dict[str, object]]:
    if action.kind == "send_text":
        return [{"insert_text": action.argument}]

    if action.kind == "open_url":
        url = action.argument
        command = f"open {json.dumps(url)}"
        return [{"shell_command": command}]

    if action.kind == "open":
        return [
            {
                "software_function": {
                    "open_application": {
                        "bundle_identifier": action.argument,
                    }
                }
            }
        ]

    if action.kind == "script":
        return [{"shell_command": action.argument}]

    if action.kind == "to_keys":
        key_code, modifiers = parse_key_combo(action.argument, line_number)
        to_obj: Dict[str, object] = {"key_code": key_code}
        if modifiers:
            to_obj["modifiers"] = modifiers
        return [to_obj]

    raise DslError(f"Line {line_number}: unsupported action '{action.kind}'")


def insert_mapping(root: TrieNode, mapping: Mapping) -> None:
    node = root
    for token in mapping.trigger_parts:
        if token not in node.children:
            child = TrieNode(parent=node)
            node.children[token] = child
        node = node.children[token]

    if node.mapping is not None:
        old = node.mapping
        trigger = ">".join(mapping.trigger_parts)
        raise DslError(
            f"Line {mapping.line_number}: trigger collision for '{trigger}' (already defined on line {old.line_number})"
        )
    node.mapping = mapping


def validate_prefix_collisions(node: TrieNode, path: List[str]) -> None:
    if node.mapping is not None and node.children:
        trigger = ">".join(path)
        raise DslError(
            f"Line {node.mapping.line_number}: trigger '{trigger}' is both a complete mapping and a prefix of another mapping"
        )

    for token, child in node.children.items():
        validate_prefix_collisions(child, [*path, token])


def assign_node_ids(root: TrieNode) -> None:
    counter = 0

    def walk(node: TrieNode) -> None:
        nonlocal counter
        for _token, child in node.children.items():
            counter += 1
            child.node_id = f"dsl_state_{counter}"
            walk(child)

    walk(root)


def build_manipulators(root: TrieNode, timeout_ms: int) -> List[Dict[str, object]]:
    manipulators: List[Dict[str, object]] = []

    def walk(node: TrieNode, path: List[str]) -> None:
        for token, child in node.children.items():
            source_mapping = child.mapping
            line_number = (
                source_mapping.line_number if source_mapping is not None else 0
            )
            from_obj = parse_trigger_token(token, line_number)

            conditions = []
            if node.node_id is not None:
                conditions.append(
                    {
                        "type": "expression_if",
                        "expression": f"{node.node_id} > system.now.milliseconds",
                    }
                )

            if child.mapping is None:
                to_entries = [
                    {
                        "set_variable": {
                            "name": child.node_id,
                            "expression": f"system.now.milliseconds + {timeout_ms}",
                        }
                    }
                ]
            else:
                mapping = child.mapping
                to_entries = build_action_to(mapping.action, mapping.line_number)
                clear_list = []
                walker: Optional[TrieNode] = child
                while walker is not None and walker.node_id is not None:
                    clear_list.append(
                        {
                            "set_variable": {
                                "name": walker.node_id,
                                "expression": "0",
                            }
                        }
                    )
                    walker = walker.parent
                to_entries.extend(clear_list)

            manipulator: Dict[str, object] = {
                "type": "basic",
                "from": from_obj,
                "to": to_entries,
            }
            if conditions:
                manipulator["conditions"] = conditions

            manipulator["description"] = f"dsl:{'>'.join(path + [token])}"
            manipulators.append(manipulator)

            walk(child, [*path, token])

    walk(root, [])
    return manipulators


def compile_dsl(input_path: Path, output_path: Path, timeout_ms: int) -> None:
    lines = input_path.read_text(encoding="utf-8").splitlines()

    root = TrieNode()
    for index, line in enumerate(lines, start=1):
        mapping = parse_line(line, index)
        if mapping is None:
            continue
        insert_mapping(root, mapping)

    validate_prefix_collisions(root, [])
    assign_node_ids(root)
    manipulators = build_manipulators(root, timeout_ms)

    output_data = {
        "rules": [
            {
                "description": f"Generated from {input_path.name}",
                "manipulators": manipulators,
            }
        ]
    }

    output_path.write_text(json.dumps(output_data, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Compile simple keymap DSL to Karabiner rules"
    )
    parser.add_argument("input", type=Path, help="Input DSL file")
    parser.add_argument("output", type=Path, help="Output JSON file")
    parser.add_argument(
        "--timeout-ms",
        type=int,
        default=800,
        help="Maximum delay between sequence keys in milliseconds (default: 800)",
    )
    args = parser.parse_args()

    if args.timeout_ms <= 0:
        raise DslError("--timeout-ms must be greater than 0")

    try:
        compile_dsl(args.input, args.output, args.timeout_ms)
    except FileNotFoundError as error:
        print(str(error), file=sys.stderr)
        return 1
    except DslError as error:
        print(str(error), file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
