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
		--exclude ".config/sublime-text" \
		--exclude "firefoxUserContent.css" \
		-ah --itemize-changes --no-perms ~/dev/dotfiles/ ~/ 2>&1 | \
		awk '/^[<>cdf]/ {if ($2 != "./") print "\033[32m" $2 "\033[0m"} /[Ee]rror|[Ww]arning/ {print "\033[31m" $0 "\033[0m"}'
		# -ahv for verbose

# merge npmrc secrets
# '-' tells cat to read from stdin (which in this case is a newline)
# test -f ~/.npmrc-secrets && echo "\n" | cat - ~/.npmrc-secrets >> ~/.npmrc

tmux source-file ~/.tmux.conf
echo '↠ Tmux reloaded'

if pgrep -x "AeroSpace" > /dev/null; then
    aerospace reload-config
    echo '↠ Aerospace reloaded'
else
    echo '↠ Aerospace is not running'
fi

sketchybar --reload
echo '↠ SketchyBar reloaded'

exec ${SHELL} -l