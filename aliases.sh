alias dev="cd ~/Dev && clear"
alias please="npm"
alias andemu="emulator -avd pixel4android11" #https://developer.android.com/studio/run/emulator-commandline
alias andrem="scrcpy" #https://github.com/Genymobile/scrcpy
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias week='date +%V'
alias ip="publicip && localip"
alias publicip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias openports="lsof -PiTCP -sTCP:LISTEN"
alias copyclip="tr -d '\n' | pbcopy" #ex: ip | copyclip (your ip will be added to clipboard)
alias afk="osascript -e 'tell application \"System Events\" to keystroke \"q\" using {command down,control down}'" #"/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend" # Lock the screen
alias reload="sh ~/dotfiles/update.sh && exec ${SHELL} -l"
alias path='echo -e ${PATH//:/\\n}' # Print each PATH entry on a separate line
alias v="nvim"
alias cpwd="pwd | copyclip && echo '$PWD copied to clipboard'"
alias fb="fb-messenger-cli"
alias listglobalnodepkgs="npm ls -g --depth=0"
alias hosts="sudo vim /etc/hosts"
alias networkname="echo '$(scutil --get LocalHostName).local'"
alias flushdns="sudo killall -HUP mDNSResponder; sleep 2; echo done!"
alias curlEditPostData="/bin/bash -c 'read -p '$'\'\e[31mMust use quotes around property-names in json!\e[0m ENTER to continue'\''' && v ~/Downloads/body.json"
alias listsizes="du -sh * | sort -h"
alias cat=bat
alias sm="smerge ."
alias susp="prlctl suspend windows"
alias tob="$EDITOR ~/devp/tobb.be/www/"
alias shareport="ngrok http -region eu " # ex: `shareport 3000`

# git
## gg and gam is in functions
alias gs="git status -s"
alias ga="git add -A"
alias gc="git commit -m"
alias sneak="git add . && git commit --amend --no-edit"
alias gitlog="git log --oneline --decorate --graph"
alias gitlogall="git log --oneline --decorate --graph --all"
alias gitlogs="git log --oneline --decorate --graph --stat"
alias gitlogt="git log --graph --decorate --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset'"

# tmux
alias ta='tmux attach -t'		# attach named session
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'	# create new named session
alias tk='tmux kill-session -t' # kill named session
alias tx='tmuxinator'			# example `tx tob` (start session, or attach if already running)

# nmap requires sudo to find all devices
# -i=case INsensitive -v=invert
alias scannetwork="sudo nmap -sn 192.168.1.0/24 | sed -e 's|Nmap scan report|\nNmap scan report|'"
alias scannetworkMore="sudo nmap 192.168.1.0/24"

alias rnPodsReInstall="rm -rf ios/build ios/Pods ios/Podfile.lock; cd ios; pod install; cd -" # remove build+pods and reinstall them
alias rni="npx react-native run-ios --simulator=\"iPhone 11\""
alias prodrni="npx react-native run-ios --simulator=\"iPhone 11\" --configuration Release"
alias rna="npx react-native run-android"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# which code => returns where code command in terminal is installed! if node or global node module, make sure to run command first. ex: `node -v` then `which node`
# someoutput grep cool => returns lines where "cool" exist in someoutput. works with pipes |
# rg --no-ignore --files | rg contentOfFileName (ex: keystore)
# list of devices on network => arp -a
# DNS lookup => dig +noall +answer example.com

# minify/resize img.
# -Z 640 = Resample image so height and width aren't greater than specified size(640).
# formatOptions = 1-100 / low|normal|high
## examples:
# sips -Z 640 someImage.jpg --out someImage-640.jpg
# sips -s format jpeg input.png --out output.jpg
## format to max 640px, png to jpg and 90% quality
# sips -Z 640 -s format jpeg -s formatOptions 90 original.png --out converted.jpg
## set maxWidth, keep aspect ratio
# sips --resampleWidth 1400 original.jpg --out converted.jpg <----- BEST ONE

# check if page contains word and include text before after
# -i = ignore case
# -m 1 = only first match
# -o = print only matching
# -E =  extend
#       grep -E '(this|or_this)'
# -A 1 = print 1 line after
# -B 1 = print 1 line before
# -C 1 = print 1 line before and after
# curl --silent https://site.com | grep -o -E ".{0,3}someword.{0,4}"
# if file contains it
# grep -o -E ".{0,3}someword.{0,4}" file.txt

# check info of process
# ps aux | grep {pid}