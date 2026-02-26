#!/usr/bin/env python3

import json
import os
import subprocess
import sys
from glob import glob
from typing import Optional


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in {"h", "l"}:
        raise SystemExit(0)

    direction = sys.argv[1]

    candidates: list[Optional[str]] = []
    env_socket = os.environ.get("KITTY_LISTEN_ON")
    if env_socket:
        candidates.append(env_socket)

    default_socket = "/tmp/kitty-socket"
    if os.path.exists(default_socket):
        candidates.append(f"unix:{default_socket}")

    sockets = sorted(glob("/tmp/kitty-socket-*"), key=os.path.getmtime, reverse=True)
    if sockets:
        candidates.append(f"unix:{sockets[0]}")
    candidates.append(None)

    deduped_candidates: list[Optional[str]] = []
    for candidate in candidates:
        if candidate not in deduped_candidates:
            deduped_candidates.append(candidate)

    to: Optional[str] = None

    def kitty_args(*args: str) -> list[str]:
        command = ["kitty", "@"]
        if to:
            command.extend(["--to", to])
        command.extend(args)
        return command

    def kitty_json(*args: str) -> str:
        nonlocal to
        for candidate in deduped_candidates:
            to = candidate
            command = kitty_args(*args)
            result = subprocess.run(
                command, text=True, capture_output=True, check=False
            )
            if result.returncode == 0:
                return result.stdout

        raise SystemExit(0)

    def kitty_call(*args: str) -> int:
        command = kitty_args(*args)
        result = subprocess.run(command, check=False)
        if result.returncode != 0 and to:
            fallback = subprocess.run(["kitty", "@", *args], check=False)
            return fallback.returncode
        return result.returncode

    data = kitty_json("ls")
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
        sequence = "\\eh" if direction == "h" else "\\el"
        kitty_call("send-text", "--match", f"id:{focused_window_id}", sequence)
        return

    action = "previous_tab" if direction == "h" else "next_tab"
    kitty_call("action", action)


if __name__ == "__main__":
    main()
