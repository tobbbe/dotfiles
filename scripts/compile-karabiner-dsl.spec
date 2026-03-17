# Karabiner Elements DSL — Specification
# Compiled by compile-karabiner-dsl.py
# Output JSON uses sort_keys=True + indent=2.

## Usage

  python3 scripts/compile-karabiner-dsl.py <input.dsl.config> <output.json>
  python3 scripts/compile-karabiner-dsl.py <input> <output> [--timeout-ms N]

  On error: prints "Line N: <message>" to stderr and exits non-zero.
  The output file is only written on success.

## File format
Line-based. Significant indentation: 2 spaces per level.
# starts a comment. Blank lines ignored.

## Top-level declarations (order in file = order in output)

  profile name="<name>"

  global
    <key>: <value>

  virtual_hid_keyboard
    <key>: <value>

  complex_parameters
    basic.simultaneous_threshold_milliseconds: <n>
    basic.to_delayed_action_delay_milliseconds: <n>
    basic.to_if_alone_timeout_milliseconds: <n>
    basic.to_if_held_down_threshold_milliseconds: <n>

  var <NAME> <token> [<token>...]        (see Variables below)

  remap <from> -> <to>                   (profile-level simple modification)

  device vendor=<id> product=<id> ...    (see Device blocks below)

  rule "<title>"                         (see Rules below)
  rule description="<text>"

## Variables
  var <NAME> <token> [<token>...]

  Expanded with $NAME anywhere on a map line, before condition parsing.
  Useful for repeated bundle ID lists:

    var TERMINALS com.mitchellh.ghostty net.kovidgoyal.kitty org.alacritty
    map x if_app $TERMINALS to key_code: escape

## Simple modifications
  remap <from> -> <to>

  Key type prefixes (default = key_code):
    consumer:<key>    consumer_key_code
    top_case:<key>    apple_vendor_top_case_key_code

## Device blocks
  device vendor=<id> product=<id>
         [is_pointing_device=<bool>]
         [ignore=<bool>]
         [manipulate_caps_lock_led=<bool>]
         [disable_built_in_keyboard_if_exists=<bool>]
         [simple_modifications=empty]    (emit "simple_modifications": [] even with no remaps)
    remap <from> -> <to>

  Pointing devices (is_pointing_device=true) omit fn_function_keys,
  manipulate_caps_lock_led, and disable_built_in_keyboard_if_exists.

## Rules and maps
  rule "<title>"              (emits "title" key)
  rule description="<text>"  (emits "description" key)
    map ...

  Inline map — single to action on one line:
    map <trigger>[?] [conditions] to <action>

  Block map — multiple actions or additional blocks:
    map <trigger>[?] [conditions]
      to
        <action>
        [<action> ...]
      to_if_alone
        <action>
        [<action> ...]
      to_if_held_down
        <action>
      to_delayed_action
        to_if_invoked
          <action>
        to_if_canceled
          <action>
      parameters
        <key>: <value>

  ? suffix on trigger → modifiers: { optional: ["any"] } on the from side

## Trigger syntax
  <key>              plain key_code
  <mod>-<mod>-<key>  one or more modifiers + key (mandatory)
  <trigger>?         with optional: ["any"]

  Modifiers (unqualified = either side):
    ctrl  / ctrl_l  / ctrl_r    either / left / right control
    shift / shift_l / shift_r   either / left / right shift
    opt   / opt_l   / opt_r     either / left / right option
    cmd   / cmd_l   / cmd_r     either / left / right command

  Modifier order does not matter — output is always sorted alphabetically.

## Sequences (trie / leader key)
  Trigger tokens joined with >:
    map cmd-s>g to open: com.sublimemerge

  Intermediate nodes set a trie state variable; leaf nodes clear it.
  Timeout controlled by --timeout-ms flag (default: 800ms).

## Conditions (space-separated on map line, after trigger)
  if_app <id> [<id>...]          frontmost_application_if  (multiple ids = OR)
  unless_app <id> [<id>...]      frontmost_application_unless
  if_expr="<expr>"               expression_if
  if_input_source="<lang>"       input_source_if (language field)

  Quoted ids supported: if_app "bundle id with spaces"
  Repeating a keyword = separate AND condition:
    if_app disabled if_app org.mozilla.firefox  →  two conditions

## Actions
  key_code: <key> [(options)]
  consumer_key_code: <key>               → consumer_key_code
  apple_vendor_key_code: <key>           → apple_vendor_keyboard_key_code
  shell: <command>                       → shell_command (rest of line, unquoted)
  set_variable: <name>=<value>           → set_variable {name, expression}
  open: <bundle-id>                      → software_function.open_application

  Output modifiers use the same <mod>-<key> syntax:
    key_code: cmd_r-opt_r-b  →  {key_code: "b", modifiers: ["right_command", "right_option"]}

  Options (in parentheses after key, space-separated):
    halt=true
    repeat=false
    hold_down_milliseconds=<n>
    modifiers=any                        → modifiers: ["any"] (passthrough)
