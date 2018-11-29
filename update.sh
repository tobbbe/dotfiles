# run with `sh setup.s` OR use `reload` in terminal

# This may overwrite existing files in your home directory
rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "update.sh" \
		--exclude "README.md" \
		-avh --no-perms ~/dotfiles/ ~; # MAKE SURE dotfiles is at ~/dotfiles, else use . and execute this in this folder