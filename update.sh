# run with `sh update.sh` OR use `reload` in terminal

# This may overwrite existing files in your home directory
# But will NOT remove files that doesnt exist in dotfiles-repo
rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "update.sh" \
		--exclude "functions.sh" \
		--exclude "aliases.sh" \
		--exclude "README.md" \
		--exclude "Library/LaunchAgents/readme.md" \
		--exclude "iterm-settings/" \
		--exclude "scripts/" \
		--exclude ".config/sublime-text" \
		--exclude "firefoxUserContent.css" \
		-avh --no-perms ~/dev/dotfiles/ ~; # MAKE SURE dotfiles is at ~/dev/dotfiles

# merge npmrc secrets
# '-' tells cat to read from stdin (which in this case is a newline)
test -f ~/.npmrc-secrets && echo "\n" | cat - ~/.npmrc-secrets >> ~/.npmrc