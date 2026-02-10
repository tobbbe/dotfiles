# 🚨 MAKE SURE dotfiles is at ~/dev/dotfiles
# run with `sh reload.sh` OR use `reload` in terminal

# This may overwrite existing files in your home directory
# But will NOT remove files that doesnt exist in dotfiles-repo
rsync --exclude ".git/" \
  --exclude ".DS_Store" \
  --exclude ".osx" \
  --exclude "reload.sh" \
  --exclude "functions.sh" \
  --exclude "aliases.sh" \
  --exclude "README.md" \
  --exclude "Library/LaunchAgents/readme.md" \
  --exclude "iterm-settings/" \
  --exclude "scripts/" \
  --exclude "prompts/" \
  --exclude "AGENTS.md" \
  --exclude "agent-skills/" \
  --exclude "agent-commands/" \
  --exclude ".config/sublime-text" \
  --exclude "firefoxUserContent.css" \
  -ah --itemize-changes --no-perms ~/dev/dotfiles/ ~/ 2>&1 |
  awk '/^[<>cdf]/ {if ($2 != "./") print "\033[32m" $2 "\033[0m"} /[Ee]rror|[Ww]arning/ {print "\033[31m" $0 "\033[0m"}'
# -ahv for verbose

# lazygit config (macOS uses Application Support not .config)
LAZYGIT_DIR=~/Library/Application\ Support/lazygit
cp ~/dev/dotfiles/Library/Application\ Support/lazygit/config.yml "$LAZYGIT_DIR/config.yml"
echo '↠ Lazygit config reloaded'

# vscode prompts
VSCODE_DIR=~/Library/Application\ Support/Code/User
rsync -ah ~/dev/dotfiles/prompts/ "$VSCODE_DIR/prompts/"
echo '↠ VSCode Prompts reloaded'

# vscode agents
cp ~/dev/dotfiles/AGENTS.md "$VSCODE_DIR/prompts/AGENTS.md" && sed -i '' '1i\
---\
applyTo: "**"\
---\

' "$VSCODE_DIR/prompts/AGENTS.md"
echo '↠ VSCode AGENTS.md reloaded'

# opencode
cp ~/dev/dotfiles/AGENTS.md ~/.config/opencode/AGENTS.md
echo '↠ Opencode AGENTS.md reloaded'

# claude
cp ~/dev/dotfiles/AGENTS.md ~/.claude/CLAUDE.md
echo '↠ Claude AGENTS.md reloaded'

# agent skills → ~/.claude/skills/ (opencode also reads from there)
for skill_dir in ~/dev/dotfiles/agent-skills/*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  mkdir -p ~/.claude/skills/"$name"
  cp "$skill_dir"SKILL.md ~/.claude/skills/"$name"/SKILL.md
done
echo '↠ Agent skills reloaded'

# agent commands → ~/.claude/skills/ (slash commands) + ~/.config/opencode/commands/
mkdir -p ~/.config/opencode/commands
for cmd_dir in ~/dev/dotfiles/agent-commands/*/; do
  [ -d "$cmd_dir" ] || continue
  name=$(basename "$cmd_dir")
  mkdir -p ~/.claude/skills/"$name"
  cp "$cmd_dir"SKILL.md ~/.claude/skills/"$name"/SKILL.md
  cp "$cmd_dir"SKILL.md ~/.config/opencode/commands/"$name".md
done
echo '↠ Agent commands reloaded'

# merge npmrc secrets
# '-' tells cat to read from stdin (which in this case is a newline)
# test -f ~/.npmrc-secrets && echo "\n" | cat - ~/.npmrc-secrets >> ~/.npmrc

tmux source-file ~/.tmux.conf
echo '↠ Tmux reloaded'

if pgrep -x "AeroSpace" >/dev/null; then
  aerospace reload-config
  echo '↠ Aerospace reloaded'
else
  echo '↠ Aerospace is not running'
fi

sketchybar --reload
echo '↠ SketchyBar reloaded'

# Reload Kitty config
KITTY_SOCKET=$(ls -t /tmp/kitty-socket-* 2>/dev/null | head -1)
if [ -n "$KITTY_SOCKET" ] && /Applications/kitty.app/Contents/MacOS/kitty @ --to "unix:$KITTY_SOCKET" load-config 2>/tmp/kitty-reload-error.log; then
  echo '↠ Kitty reloaded'
else
  echo '↠ Kitty reload failed (see /tmp/kitty-reload-error.log)'
fi

# Reload Ghostty config via AppleScript
# osascript -e 'tell application "System Events" to tell process "Ghostty" to click menu item "Reload Configuration" of menu "Ghostty" of menu bar item "Ghostty" of menu bar 1' 2>&1 | grep -v "^menu item" >&2
# echo '↠ Ghostty reloaded'

# Reload Hammerspoon
hs -c "hs.reload()" 2>/dev/null
echo '↠ Hammerspoon reloaded'

exec ${SHELL} -l
