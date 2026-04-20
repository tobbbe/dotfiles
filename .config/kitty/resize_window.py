#!/usr/bin/env python3
"""Resize the focused kitty window to 80% of the available space in the current layout."""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from kitty_remote import KittyRemote

DEFAULT_RATIO = 0.8


def main() -> int:
    ratio = float(sys.argv[1]) / 100 if len(sys.argv) > 1 else DEFAULT_RATIO

    remote = KittyRemote()

    ls_output = remote.json("ls")
    if ls_output is None:
        print("Failed to get kitty window list", file=sys.stderr)
        return 1

    data = json.loads(ls_output)

    focused_tab = None
    focused_window = None

    for os_window in data:
        if not os_window.get("is_focused"):
            continue
        for tab in os_window.get("tabs", []):
            if not tab.get("is_focused"):
                continue
            focused_tab = tab
            for window in tab.get("windows", []):
                if window.get("is_focused"):
                    focused_window = window
            break
        break

    if focused_tab is None or focused_window is None:
        print("Could not find focused window", file=sys.stderr)
        return 1

    layout = focused_tab.get("layout", "")
    windows = focused_tab.get("windows", [])

    if len(windows) <= 1:
        return 0

    if layout == "vertical":
        axis = "vertical"
        current_size = focused_window["lines"]
        total_size = sum(w["lines"] for w in windows)
    elif layout == "horizontal":
        axis = "horizontal"
        current_size = focused_window["columns"]
        total_size = sum(w["columns"] for w in windows)
    else:
        # stack or unknown layout — nothing meaningful to do
        return 0

    target_size = int(total_size * ratio)
    increment = target_size - current_size

    if increment == 0:
        return 0

    return remote.call(
        "resize-window",
        "--increment", str(increment),
        "--axis", axis,
    )


if __name__ == "__main__":
    raise SystemExit(main())
