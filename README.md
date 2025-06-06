# dotfiles
Update with `sh update.sh`
Make sure your user is named "tobbe"

# Install
- homebrew
	- git
	- tmux
	- jq
	- z
	- bat
	- tmuxinator
	- ripgrep
	- fzf
	- pnpm
	- bat
	- fastlane
	- gh
	- httpie
- atuin (shell history)
- volta (node)
	- install node with volta https://volta.sh
	- install global npm packages with `volta install <package>`
	- list global packages with `volta list`
	- packages to install:
		- @antfu/ni
		- vercel
- firefox
	- see settings below
- notion
- dotfiles
- alfred
	- alfred-settings
- sf mono
- iterm2
- https://shottr.cc/

# git
1. Create two ssh keys: work and personal (see github docs)
2. Create ~/.gitconfig-personal with:
```
[user]
    email = personal-email@gmail.com
[core]
    sshCommand = "ssh -i  ~/.ssh/personal"
```
and ~/.gitconfig-work with:
```
[user]
    email = name@company.com
[core]
    sshCommand = "ssh -i  ~/.ssh/work"
```
3. upload ssh .pub files to github etc
4. update .gitconfig with folders to use with each ssh-key/account

# Mac
- Require password after screen saver begins or display turned off (includes afk=lock screen) to **immediatly**
- keyboard > keyboard shortcuts > "Move focus to next window" set to `cmd+<`
- keyboard > Delay until repeat = short(est)

# VSCode

## VSCode settings
- Typescript Tsdk: `./node_modules/typescript/lib`

## Extensions:
- Eslint [https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
    - Prettier is NOT needed if Eslint and settings in vscode is setup correctly
- Github Copilot
- Tailwind CSS IntelliSence
- Quick and Simple Text Selection

## eslint+prettier
### alt 1 (eslint handles all)
- disable prettier plugin
- Default formatter: `ESLint`
- Search settings for “format:enable”. Disable ALL except ESLint. ESLint should handle it.
- requires:
	- npm pack: eslint-plugin-prettier
	- npm pack: prettier
	- eslintConfig extend: plugin:prettier/recommended
### alt 2 (prettier vscode plugin handles prettier)
- enable prettier plugin
- Default formatter: `prettier`
- setting: prettier require config
- Search settings for “format:enable”. Disable ALL. Prettier plugin will handle it.
- DOES NOT require:
	- npm pack: eslint-plugin-prettier
	- npm pack: prettier
	- eslintConfig extend: plugin:prettier/recommended => REPLACE with 'prettier' from eslint-config-prettier

# Firefox
- Strict privacy
- Delete cookies and data when firefox is closed
	- exceptions: excalidraw.com, stackoverflow.com, github.com
- in about:config
	- closeWindowWithLastTab false
	- browser.urlbar.filter.javascript false (to be able to search booklets, "form fill" for example. Then use "ff" in address bar (configured shortcut on the bookmark))
	- cookiebanners.service.mode (and for private browsing) = 1 (reject all)
	- cookiebanners.bannerClicking.enabled TRUE

## Addons
- vimium
    - ändra chars used for hints
    - lägg till tema-css: https://github.com/philc/vimium/wiki/Theme
		- my own https://gist.github.com/tobbbe/b95cc29a85ce3fa239cf68ce76aeb42e
    - exclude urls:
		- https?://photopea.com/*
		- https?://excalidraw.com/*
    
    ```bash
    # Insert your preferred key mappings here.
    unmap <m-A>
    map <m-A> Vomnibar.activateTabSelection
    map <m-p> Vomnibar.activate

	unmap h
	map h goBack

	unmap l
	map l goForward

	unmap /
	unmap p
	unmap t
    ``` 
- bitwarden
- Firefox Multi-Account Containers
- ublock origin
    - Remove google consent: [https://daniel-lange.com/archives/164-Getting-rid-of-the-Google-cookie-consent-popup.html](https://daniel-lange.com/archives/164-Getting-rid-of-the-Google-cookie-consent-popup.html)
    - trusted sites: localhost

# iterm keybindings
- Backup iterm Settings to com.googlecode.iterm2.plist (in dotfiles dir). Setup in General-tab => Preferences.
- Backup iterm Profile to iterm-default-profile.json (in dotfiles dir). Must save manually after changes.
Set Presets.. to "Natural text editing" under Profile=>Keys
AND set these of these in pref=>keys (selection ex):
`⇧+⌥+← | move start of sel back by word | select to the left by word`  
`⇧+⌥+→ | move end of sel forward by word | select to the right by word``

# todo
- scheduled tasks. Ex: move todo to repo and auto-push https://bitbucket.org/tobbbbe/todo/src
	- launchd
	https://blog.jan-ahrens.eu/2017/01/13/cron-is-dead-long-live-launchd.html
	http://www.launchd.info/
	https://superuser.com/questions/126907/how-can-i-get-a-script-to-run-every-day-on-mac-os-x
	https://medium.com/@chetcorcos/a-simple-launchd-tutorial-9fecfcf2dbb3

# install node with nvm
NOPE, use if you update node with nvm, migrate global packages: https://github.com/creationix/nvm#migrating-global-packages-while-installing

# set shells (logout+login after change)
zsh (default on mac): `chsh -s $(which zsh)` or if thats not working: `chsh -s /bin/zsh`
fish: `chsh -s /usr/local/bin/fish`

# temporary swich shell
in terminal, type:
`zsh`
`fish`

# good stuff
https://github.com/mathiasbynens/dotfiles
https://evanhahn.com/a-decade-of-dotfiles/

# Osascript
`open -a 'Firefox.app' 'https://tobb.be/dashboard' && osascript -e 'delay 0.08' -e 'tell application \"System Events\"' -e 'keystroke \"l\" using {command down}' -e 'end tell'`

```
{
	"description": "show terminal",
	"manipulators": [
		{
			"from": {
				"key_code": "non_us_backslash",
				"modifiers": {
					"mandatory": ["left_command"]
				}
			},
			"to": [
				{
					"halt": true,
					"key_code": "t",
					"modifiers": [
						"left_shift",
						"left_control",
						"left_command",
						"left_option"
					]
				}
			],
			"type": "basic"
		}
	]
},
```