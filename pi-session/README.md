# pi-session (dotfiles source of truth)

This directory contains the source for:

- `pi-session` (bash CLI)
- `pi-session.lua` (Neovim plugin file)

## Setup

Create a symlink from your Neovim plugin path to this file:

```bash
ln -sf /Users/tobbe/dev/dotfiles/pi-session/pi-session.lua /Users/tobbe/.config/nvim/lua/plugins/pi-session.lua
```

This keeps all pi-session code in one place (dotfiles).

## Notes

- Do not create a separate editable copy in `~/.config/nvim/lua/plugins/`.
- Edit `pi-session.lua` here in dotfiles.
- `pi-session.lua` expects the bash script at:
  `/Users/tobbe/dev/dotfiles/pi-session/pi-session`
