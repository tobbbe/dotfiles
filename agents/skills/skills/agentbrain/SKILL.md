---
name: agentbrain
description: Read and write persistant memory for you, the agent. Use it a lot.
---

# Agentbrain

This skill gives you a shared persistent memory store at `~/dev/agentbrain/`.

Use it to store information that would help future agents working on the same project or topic. This is especially useful for non-obvious project relationships, domain knowledge, user preferences, and traps or dead ends that future agents should avoid.

## When and how to use this skill

### Writing to memory

- Decide whether the learning belongs in project memory or a topic file.
- Prefer the canonical source when the information already lives in project docs or code comments.
- Create files as needed.
- Add durable, actionable notes.
- Update or remove stale entries when the current session proves they are wrong.
- Keep entries short and specific (preferably 1-3 sentences).

Write when:

- You discover non-obvious project relationship or domain detail that took real effort to discover.
- You hit a trap where the obvious approach fails, including why it fails.
- You learn a user preference that resolves a recurring ambiguous choice.
- You go down a dead end that future agents should avoid repeating.
- You discover an implicit dependency.

Do not write:

- Session summaries or journals.
- Duplicated information that already exists elsewhere in the repo.

### Reading from memory
- The current project memory file should be loaded automatically into the session context through `.claude.local.md` in the project root. That file should be a symlink to the canonical project memory file in `~/dev/agentbrain/projects/` and should start with `Agent brain project memory for current cwd`. If the header or symlink is missing, tell the user.
- Do not preemptively load all topic references. Read topic names first, then follow only the references that are relevant to the task.

## Storage structure and location

### Project memory
- Project-specific knowledge is stored in `~/dev/agentbrain/projects/<name>.md`. The project's root directory name (git repo root if available) is used for `<name>`. This is the canonical source.
- Each repo/project should have a `.claude.local.md` in the root that is symlink to the project-specific knowledge file. Let user know if its missing.
- When updating project memory, edit either the canonical file or `.claude.local.md` if it points to the same file. Prefer the canonical file when editing.

### Topic memory
- `~/dev/agentbrain/topics/<name>.md` for cross-project topic based knowledge.
