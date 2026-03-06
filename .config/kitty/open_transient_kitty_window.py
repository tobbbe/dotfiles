#!/usr/bin/env python3

import argparse
import importlib.util
import os
import subprocess
import sys
from typing import Optional

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


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--title")
    parser.add_argument("--cwd")
    parser.add_argument("command", nargs="+")
    return parser.parse_args()


def run_via_remote(
    command: list[str], title: Optional[str], cwd: Optional[str]
) -> Optional[int]:
    remote = KittyRemote()

    launch_args = ["launch", "--type=window", "--copy-env", "--wait-for-child-to-exit"]
    if title:
        launch_args.extend(["--os-window-title", title, "--title", title])
    if cwd:
        launch_args.extend(["--cwd", cwd])

    result = remote.capture(*launch_args, *command)
    if result is None:
        return None

    exit_code = result.stdout.strip()
    if not exit_code:
        return 0

    try:
        return int(exit_code)
    except ValueError:
        return 1


def run_via_kitty(command: list[str], title: Optional[str], cwd: Optional[str]) -> int:
    kitty_command = [
        "kitty",
        "--session",
        "none",
        "--single-instance",
        "--wait-for-single-instance-window-close",
    ]

    if title:
        kitty_command.extend(["--title", title])
    if cwd:
        kitty_command.extend(["--directory", cwd])

    kitty_command.extend(command)
    return subprocess.run(kitty_command, check=False).returncode


def main() -> None:
    args = parse_args()
    exit_code = run_via_remote(args.command, args.title, args.cwd)
    if exit_code is None:
        exit_code = run_via_kitty(args.command, args.title, args.cwd)
    raise SystemExit(exit_code)


if __name__ == "__main__":
    main()
