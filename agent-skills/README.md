# Agent Skills

Auto-triggered skills for Claude Code and opencode. The agent picks these up based on context.

Copied to `~/.claude/skills/` by `reload`. opencode reads from there too, so one copy serves both.

For user-invoked slash commands (`/something`), use `agent-commands/` instead.

## Adding a skill

1. Create `agent-skills/<name>/SKILL.md`
2. Run `reload`
