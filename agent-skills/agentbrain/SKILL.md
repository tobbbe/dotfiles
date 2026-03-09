---
name: agentbrain
description: Read and write persistent memory shared across all agents and sessions. Write when you discover non-obvious project details, hit a trap, learn a user preference, or reach a dead end. Read topic files when they are relevant to the current task.
---

# Agentbrain

This skill gives you a shared persistent memory store at `~/dev/agentbrain/`. This is shared across all AI agents and sessions.

The purpose of this skill is to prevent future agents from wasting time and have a persistent memory that adds non-obvious and unknown information to the context.

## When and how to use this skill

### Writing to memory

- Decide whether the learning belongs in project memory or a topic file.
- Prefer the canonical source when the information already lives in project docs or code comments.
- Create files as needed.
- Add only durable, actionable notes that save future agents real time.
- Update or remove stale entries when the current session proves they are wrong.
- Keep entries short and specific (preferably 1-3 sentences) and place them under the correct heading: `context`, `traps`, `preferences`, or `dead ends`.

Write when:

- You discover non-obvious project relationship or domain detail that took real effort to discover.
- You hit a trap where the obvious approach fails, including why it fails.
- You learn a user preference that resolves a recurring ambiguous choice.
- You go down a dead end that future agents should avoid repeating.
- You discover an implicit dependency.

Do not write:

- Session summaries or journals.
- Facts an agent can easily rediscover.
- Duplicated information that already exists elsewhere in the repo.

### Reading from memory
- The current project memory file is loaded automatically into the session context through `claude.local.md` and should start with `Agent brain project memory for current cwd`. If that header is missing, tell the user.
- Do not preemptively load all topic references. Read topic names first, then follow only the references that are relevant to the task.

## Storage structure and location

### Project memory
- `~/dev/agentbrain/projects/<name>.md` for project-specific knowledge. Use the project's directory name.

### Topic memory
- `~/dev/agentbrain/topics/<name>.md` for cross-project topic based knowledge.

### Entry format

```md
## context
non-obvious project relationships and domain knowledge that would take real effort to discover from code alone

## traps
things that look like they should work but don't, and why

## preferences
User's choices on ambiguous decisions (where multiple valid approaches exist)

## dead ends
approaches that were tried and failed, and why — so the next agent doesn't repeat them
```
