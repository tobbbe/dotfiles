# run with `sh setup.s`

# This may overwrite existing files in your home directory
rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "update.sh" \
		--exclude "README.md" \
		-avh --no-perms . ~;