# run with `sh update.sh` OR use `reload` in terminal

# This may overwrite existing files in your home directory
# But will NOT remove files that doesnt exist in dotfiles-repo
rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "update.sh" \
		--exclude ".functions" \
		--exclude ".aliases" \
		--exclude "README.md" \
		--exclude "Library/LaunchAgents/readme.md" \
		--exclude "iterm-settings/" \
		--exclude "scripts/" \
		--exclude ".config/sublime-text" \
		-avh --no-perms ~/dotfiles/ ~; # MAKE SURE dotfiles is at ~/dotfiles, else use . and execute this in this folder