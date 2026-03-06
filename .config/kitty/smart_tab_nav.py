#!/usr/bin/env python3

import json
import importlib.util
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
if SCRIPT_DIR not in sys.path:
    sys.path.insert(0, SCRIPT_DIR)

KITTY_REMOTE_SPEC = importlib.util.spec_from_file_location(
    "kitty_remote", os.path.join(SCRIPT_DIR, "kitty_remote.py")
)
if KITTY_REMOTE_SPEC is None or KITTY_REMOTE_SPEC.loader is None:
    raise SystemExit(1)
kitty_remote = importlib.util.module_from_spec(KITTY_REMOTE_SPEC)
KITTY_REMOTE_SPEC.loader.exec_module(kitty_remote)
KittyRemote = kitty_remote.KittyRemote


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in {"h", "l", "t"}:
        raise SystemExit(0)

    direction = sys.argv[1]

    remote = KittyRemote()
    data = remote.json("ls")
    if not data:
        raise SystemExit(0)
    tree = json.loads(data)

    focused_tab = None
    focused_window_id = None

    for os_window in tree:
        for tab in os_window.get("tabs", []):
            if not tab.get("is_focused"):
                continue
            focused_tab = tab
            for window in tab.get("windows", []):
                if window.get("is_focused"):
                    focused_window_id = window.get("id")
                    break
            break
        if focused_tab is not None:
            break

    if focused_tab is None:
        raise SystemExit(0)

    tab_title = str(focused_tab.get("title") or "")
    tab_name = str(focused_tab.get("name") or "")
    tab_label = f"{tab_title} {tab_name}".lower()
    if "tmux" in tab_label and focused_window_id is not None:
        if direction == "h":
            sequence = "\\eh"
        elif direction == "l":
            sequence = "\\el"
        else:
            sequence = "\\et"
        remote.call("send-text", "--match", f"id:{focused_window_id}", sequence)
        return

    if direction == "h":
        action = "previous_tab"
    elif direction == "l":
        action = "next_tab"
    else:
        action = "new_tab_with_cwd"
    remote.call("action", action)


if __name__ == "__main__":
    main()
