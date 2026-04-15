# agentbrain setup

- Canonical project memory lives in `~/dev/agentbrain/projects/<project>.md`.
- Each project should have `.claude.local.md` in its root as a symlink to that file.
- `CLAUDE.md` is for shared project instructions. `.claude.local.md` is for the agent's local project memory.
- `.claude.local.md` is loaded differently in each agent:
  - Claude Code reads `.claude.local.md` as project context, and `~/.claude/hooks/load-agentbrain.sh` adds the startup missing-link warning.
  - opencode loads `.claude.local.md` via `~/.config/opencode/opencode.json` `instructions`, and also shows a startup warning through `plugin/agentbrain-warning.js`.
  - Pi loads `.claude.local.md` through `~/.pi/agent/extensions/project-local-memory.ts`, which warns on session start and injects the file into the system prompt in `before_agent_start`.
- If `.claude.local.md` is missing, create it manually with:
  - `ln -s ~/dev/agentbrain/projects/<project>.md .claude.local.md`
- agentbrain has an agent skill, it's in `agents/skills/skills/agentbrain/`
