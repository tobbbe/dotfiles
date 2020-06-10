# dotfiles
Update with `sh update.sh`

# todo
- scheduled tasks. Ex: move todo to repo and auto-push https://bitbucket.org/tobbbbe/todo/src
	- launchd
	https://blog.jan-ahrens.eu/2017/01/13/cron-is-dead-long-live-launchd.html
	http://www.launchd.info/
	https://superuser.com/questions/126907/how-can-i-get-a-script-to-run-every-day-on-mac-os-x
	https://medium.com/@chetcorcos/a-simple-launchd-tutorial-9fecfcf2dbb3

# install node with nvm
if you update node with nvm, migrate global packages: https://github.com/creationix/nvm#migrating-global-packages-while-installing

# good stuff
https://github.com/mathiasbynens/dotfiles


# set shells (logout+login after change)
zsh (default on mac): `chsh -s $(which zsh)` or if thats not working: `chsh -s /bin/zsh`
fish: `chsh -s /usr/local/bin/fish`

# temporary swich shell
in terminal, type:
`zsh`
`fish`

# iterm keybindings
set Presets.. to "Natural text editing" under Profile=>Keys
AND set SOME of these in pref=>keys (selection ex):

## Move curser forward/backward one word
⌥+← — — Send Escape Sequence: b
⌥+→ — — Send Escape Sequence: f
## Move cursor to the start/end of the line
⌘+← — — Send Hex Codes: 0x01
⌘+→ — — Send Hex Codes: 0x05
## Delete last/next word
⌥+Backspace — — Send Hex Codes: 0x17
⌥+Del — — Send Escape Sequence: d
## Delete to start of line
⌘+Backspace — — Send Hex Codes: 0x15
## selection
⇧+⌥+← | move start of sel back by word | select to the left by word
⇧+⌥+→ | move end of sel forward by word | select to the right by word