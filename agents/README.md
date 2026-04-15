# Agents

Shared agent configuration and content for Claude Code, opencode, pi, and VS Code.

## Structure
- `AGENT-TEMPLATE.md` shared instructions copied into supported tools by `reload.sh`
- `commands/` user-invoked slash commands
- `skills/` auto-triggered skills
- `prompts/` VS Code prompts
- `agent-brain/` agentbrain docs and helper scripts

## Reloading
Run `sh reload.sh` after changing anything in `agents/`.
