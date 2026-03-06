#!/usr/bin/env python3

import json
import importlib.util
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
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


@dataclass
class AgentProcess:
    tool: str
    tty: str
    command: str


@dataclass
class TmuxPane:
    tty: str
    session_name: str
    window_name: str
    window_index: str
    pane_title: str
    pane_path: str


@dataclass
class KittyWindow:
    window_id: int
    tab_id: int
    os_window_id: int
    tab_title: str
    window_title: str
    ttys: set[str]


@dataclass
class SessionTarget:
    window_id: int
    session_path: Optional[str]
    tmux_client_tty: Optional[str]
    tmux_session_name: Optional[str]
    tmux_window_index: Optional[str]


def run_capture(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, text=True, capture_output=True, check=False)


def detect_agent_tool(command: str) -> Optional[str]:
    executable = command.strip().split(None, 1)
    if not executable:
        return None

    name = os.path.basename(executable[0]).lower()
    if name in {"opencode", "claude"}:
        return name
    return None


def process_sort_key(process: AgentProcess) -> tuple[int, int, str]:
    exact_match = process.command.strip() == process.tool
    spawns_child = " run " in f" {process.command} "
    return (0 if exact_match else 1, 1 if spawns_child else 0, process.command)


def normalize_session_name(value: str) -> str:
    return re.sub(r"[\s._]+", "-", value.strip().lower())


def list_session_paths_by_name() -> dict[str, str]:
    sessions_dir = Path(SCRIPT_DIR) / "sessions"
    session_paths: dict[str, str] = {}

    for session_path in sessions_dir.glob("*.kitty-session"):
        session_paths[normalize_session_name(session_path.stem)] = str(session_path)

        try:
            lines = session_path.read_text().splitlines()
        except OSError:
            continue

        for line in lines:
            match = re.search(r'launch\s+--title\s+"([^"]+)"', line)
            if not match:
                continue
            session_paths[normalize_session_name(match.group(1))] = str(session_path)

    return session_paths


def session_path_for_window(
    window: KittyWindow, session_paths_by_name: dict[str, str]
) -> Optional[str]:
    candidates = [window.window_title, window.tab_title]

    for title in list(candidates):
        if title.startswith("Tmux - "):
            candidates.append(title[7:])

    for candidate in candidates:
        normalized = normalize_session_name(candidate)
        if normalized in session_paths_by_name:
            return session_paths_by_name[normalized]

    return None


def list_agent_processes() -> list[AgentProcess]:
    result = run_capture(["ps", "-axo", "pid=,tty=,command="])
    if result.returncode != 0:
        return []

    processes_by_tty: dict[tuple[str, str], AgentProcess] = {}
    for raw_line in result.stdout.splitlines():
        line = raw_line.strip()
        if not line:
            continue

        parts = line.split(None, 2)
        if len(parts) < 3:
            continue

        _, tty, command = parts
        if tty == "??":
            continue

        lowered = command.lower()
        if "pick_agent_session.py" in lowered:
            continue

        tool = detect_agent_tool(command)
        if not tool:
            continue

        process = AgentProcess(tool=tool, tty=f"/dev/{tty}", command=command)
        key = (process.tty, process.tool)
        existing = processes_by_tty.get(key)
        if existing is None or process_sort_key(process) < process_sort_key(existing):
            processes_by_tty[key] = process

    return list(processes_by_tty.values())


def has_tmux() -> bool:
    return run_capture(["sh", "-lc", "command -v tmux >/dev/null 2>&1"]).returncode == 0


def list_tmux_panes() -> dict[str, TmuxPane]:
    if not has_tmux():
        return {}

    fmt = "#{pane_tty}\t#{session_name}\t#{window_name}\t#{window_index}\t#{pane_title}\t#{pane_current_path}"
    result = run_capture(["tmux", "list-panes", "-a", "-F", fmt])
    if result.returncode != 0:
        return {}

    panes: dict[str, TmuxPane] = {}
    for line in result.stdout.splitlines():
        tty, session_name, window_name, window_index, pane_title, pane_path = (
            line.split("\t") + ["", "", "", "", "", ""]
        )[:6]
        if not tty:
            continue
        panes[tty] = TmuxPane(
            tty=tty,
            session_name=session_name,
            window_name=window_name,
            window_index=window_index,
            pane_title=pane_title,
            pane_path=pane_path,
        )

    return panes


def list_tmux_clients() -> dict[str, str]:
    if not has_tmux():
        return {}

    result = run_capture(
        ["tmux", "list-clients", "-F", "#{client_tty}\t#{session_name}"]
    )
    if result.returncode != 0:
        return {}

    clients: dict[str, str] = {}
    for line in result.stdout.splitlines():
        tty, session_name = (line.split("\t") + ["", ""])[:2]
        if tty:
            clients[tty] = session_name
    return clients


def tty_by_pid(pids: set[int]) -> dict[int, str]:
    if not pids:
        return {}

    pid_csv = ",".join(str(pid) for pid in sorted(pids))
    result = run_capture(["ps", "-o", "pid=,tty=", "-p", pid_csv])
    if result.returncode != 0:
        return {}

    mapping: dict[int, str] = {}
    for line in result.stdout.splitlines():
        parts = line.split()
        if len(parts) != 2:
            continue

        pid_raw, tty = parts
        if tty == "??":
            continue

        try:
            pid = int(pid_raw)
        except ValueError:
            continue

        mapping[pid] = f"/dev/{tty}"

    return mapping


def list_kitty_windows(remote: KittyRemote) -> list[KittyWindow]:
    raw = remote.json("ls")
    if not raw:
        return []

    try:
        tree = json.loads(raw)
    except json.JSONDecodeError:
        return []

    pid_by_window: dict[int, set[int]] = {}
    skeleton: dict[int, tuple[int, int, int, str, str]] = {}
    all_pids: set[int] = set()

    for os_window in tree:
        os_window_id = int(os_window.get("id") or 0)
        for tab in os_window.get("tabs", []):
            tab_id = int(tab.get("id") or 0)
            tab_title = str(tab.get("title") or tab.get("name") or "")
            for window in tab.get("windows", []):
                window_id = int(window.get("id") or 0)
                window_title = str(window.get("title") or "")
                pids: set[int] = set()

                pid = window.get("pid")
                if isinstance(pid, int):
                    pids.add(pid)

                for process in window.get("foreground_processes", []):
                    process_pid = process.get("pid")
                    if isinstance(process_pid, int):
                        pids.add(process_pid)

                if pids:
                    pid_by_window[window_id] = pids
                    all_pids.update(pids)

                skeleton[window_id] = (
                    window_id,
                    tab_id,
                    os_window_id,
                    tab_title,
                    window_title,
                )

    pid_tty = tty_by_pid(all_pids)

    windows: list[KittyWindow] = []
    for window_id, (
        wid,
        tab_id,
        os_window_id,
        tab_title,
        window_title,
    ) in skeleton.items():
        ttys = {
            pid_tty[pid]
            for pid in pid_by_window.get(window_id, set())
            if pid in pid_tty
        }
        windows.append(
            KittyWindow(
                window_id=wid,
                tab_id=tab_id,
                os_window_id=os_window_id,
                tab_title=tab_title,
                window_title=window_title,
                ttys=ttys,
            )
        )

    return windows


def pick_line(lines: list[str]) -> Optional[str]:
    if not lines:
        return None

    result = subprocess.run(
        [
            "fzf",
            "--prompt",
            "Agent session > ",
            "--with-nth",
            "2..",
            "--delimiter",
            "\t",
            "--height",
            "40%",
            "--layout",
            "reverse",
            "--border",
        ],
        input="\n".join(lines),
        text=True,
        capture_output=True,
        check=False,
    )

    if result.returncode != 0:
        return None

    selected = result.stdout.strip()
    return selected or None


def entry_session_name(process: AgentProcess, pane: Optional[TmuxPane]) -> str:
    if pane and pane.pane_path:
        return os.path.basename(pane.pane_path.rstrip("/")) or pane.pane_path
    if pane and pane.session_name:
        return pane.session_name
    return process.tty


def tmux_client_tty_for_window(
    window: KittyWindow, clients_by_tty: dict[str, str]
) -> Optional[str]:
    for tty in window.ttys:
        if tty in clients_by_tty:
            return tty
    return None


def build_entries(
    processes: list[AgentProcess],
    panes_by_tty: dict[str, TmuxPane],
    clients_by_tty: dict[str, str],
    kitty_windows: list[KittyWindow],
    session_paths_by_name: dict[str, str],
) -> dict[str, SessionTarget]:
    entries: dict[str, SessionTarget] = {}
    entry_count = 0

    for process in processes:
        pane = panes_by_tty.get(process.tty)

        direct_windows = [
            window for window in kitty_windows if process.tty in window.ttys
        ]
        windows = direct_windows

        if not windows and pane:
            windows = [
                window
                for window in kitty_windows
                if any(
                    clients_by_tty.get(tty) == pane.session_name for tty in window.ttys
                )
            ]

        if not windows:
            continue

        for window in windows:
            entry_count += 1
            key = str(entry_count)
            session_name = entry_session_name(process, pane)
            tab_name = window.tab_title or window.window_title or "-"

            display = f"{key}\t{session_name:<24} {tab_name:<24} {process.tool}"
            entries[display] = SessionTarget(
                window_id=window.window_id,
                session_path=session_path_for_window(window, session_paths_by_name),
                tmux_client_tty=tmux_client_tty_for_window(window, clients_by_tty),
                tmux_session_name=pane.session_name if pane else None,
                tmux_window_index=pane.window_index if pane else None,
            )

    return entries


def focus_selected_window(
    remote: KittyRemote,
    window_id: int,
    session_path: Optional[str],
    tmux_client_tty: Optional[str],
    tmux_session_name: Optional[str],
    tmux_window_index: Optional[str],
) -> int:
    if session_path:
        remote.call(
            "action", "--match", f"id:{window_id}", "goto_session", session_path
        )

    if tmux_client_tty and tmux_session_name:
        run_capture(
            [
                "tmux",
                "switch-client",
                "-c",
                tmux_client_tty,
                "-t",
                tmux_session_name,
            ]
        )
        if tmux_window_index:
            run_capture(
                [
                    "tmux",
                    "select-window",
                    "-t",
                    f"{tmux_session_name}:{tmux_window_index}",
                ]
            )

    exit_code = remote.call("focus-tab", "--match", f"window_id:{window_id}")
    if exit_code != 0:
        return exit_code

    return remote.call("focus-window", "--match", f"id:{window_id}")


def main() -> None:
    if run_capture(["sh", "-lc", "command -v fzf >/dev/null 2>&1"]).returncode != 0:
        print("fzf is required")
        raise SystemExit(1)

    remote = KittyRemote()

    processes = list_agent_processes()
    if not processes:
        print("No running opencode or claude sessions found")
        raise SystemExit(0)

    panes_by_tty = list_tmux_panes()
    clients_by_tty = list_tmux_clients()
    kitty_windows = list_kitty_windows(remote)
    session_paths_by_name = list_session_paths_by_name()

    entries = build_entries(
        processes,
        panes_by_tty,
        clients_by_tty,
        kitty_windows,
        session_paths_by_name,
    )
    selected = pick_line(list(entries.keys()))
    if not selected:
        raise SystemExit(0)

    target = entries[selected]
    if target.window_id == -1:
        print("Selected session is not attached to a kitty window")
        raise SystemExit(1)

    exit_code = focus_selected_window(
        remote,
        target.window_id,
        target.session_path,
        target.tmux_client_tty,
        target.tmux_session_name,
        target.tmux_window_index,
    )
    raise SystemExit(exit_code)


if __name__ == "__main__":
    main()
