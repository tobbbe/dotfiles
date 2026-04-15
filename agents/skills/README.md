# Agent Skills

Auto-triggered skills for Claude Code, opencode, and pi. The agent picks these up based on context.
These live under `agents/skills/`.

Important: `name` field must be lowercase and match the directory name.

Copied to `~/.claude/skills/` by `reload`. opencode reads from there too, so one copy serves both. pi reads from `~/.pi/agent/settings.json` and points to this repo's `agents/skills/skills` directory.

For user-invoked slash commands (`/something`), use `agents/commands/` instead.

## Adding a skill

1. Create `agents/skills/skills/<name>/SKILL.md`
2. Run `reload`

`agents/skills/README.md` is intentionally kept at the root.
