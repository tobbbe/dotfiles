#!/usr/bin/env python3

import os
import subprocess
import sys
from glob import glob
from typing import Optional


KITTY_BIN = "/Applications/kitty.app/Contents/MacOS/kitty"


def resolve_kitty_targets() -> list[Optional[str]]:
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

    deduped: list[Optional[str]] = []
    for candidate in candidates:
        if candidate not in deduped:
            deduped.append(candidate)
    return deduped


class KittyRemote:
    def __init__(self) -> None:
        self.targets = resolve_kitty_targets()
        self.target: Optional[str] = None

    def _kitty_command(self, target: Optional[str], *args: str) -> list[str]:
        command = [KITTY_BIN, "@"]
        if target:
            command.extend(["--to", target])
        command.extend(args)
        return command

    def capture(self, *args: str) -> Optional[subprocess.CompletedProcess[str]]:
        for target in self.targets:
            self.target = target
            result = subprocess.run(
                self._kitty_command(target, *args),
                text=True,
                capture_output=True,
                check=False,
            )
            if result.returncode == 0:
                return result
        return None

    def json(self, *args: str) -> Optional[str]:
        result = self.capture(*args)
        if result is None:
            return None
        return result.stdout

    def call(self, *args: str) -> int:
        exit_code = 1
        for target in self.targets:
            self.target = target
            result = subprocess.run(self._kitty_command(target, *args), check=False)
            exit_code = result.returncode
            if exit_code == 0:
                return 0
        return exit_code


def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: kitty_remote.py <kitty @ args...>", file=sys.stderr)
        return 2

    remote = KittyRemote()
    return remote.call(*sys.argv[1:])


if __name__ == "__main__":
    raise SystemExit(main())
