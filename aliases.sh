alias andemu="emulator -avd" #https://developer.android.com/studio/run/emulator-commandline
alias andemulist="emulator -list-avds"
alias andrem="scrcpy" #https://github.com/Genymobile/scrcpy
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias dev="cd ~/dev"
alias wdev="cd /Volumes/\[C\]\ Windows\ 11.hidden/dev"
alias week='date +%V'
alias ip="publicip && localip"
alias publicip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias openports="lsof -PiTCP -sTCP:LISTEN"
alias copyclip="tr -d '\n' | pbcopy" #ex: ip | copyclip (your ip will be added to clipboard)
alias reload="sh ~/dev/dotfiles/update.sh && exec ${SHELL} -l"
alias path='echo -e ${PATH//:/\\n}' # Print each PATH entry on a separate line
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
alias susp="prlctl suspend 'Windows 11'"
alias shareport="ngrok http --domain=careful-driven-spaniel.ngrok-free.app --region eu "  # ex: `shareport 3000`
alias caliases="cat ~/dev/dotfiles/aliases.sh --paging=never"
alias cfns="cat ~/dev/dotfiles/functions.sh --paging=never"
alias ncu="npx npm-check-updates"
alias f="cd"
alias ls="ls --color -1"
# git
## gg and gam is in functions
alias gs="git status -s"
alias gp="git pull"
alias ga="git add -A"
alias gc="git commit -m"
alias sneak="git add . && git commit --amend --no-edit"
alias gl="git log --graph --date=relative --decorate --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset'"
alias gl+="git log --oneline --decorate --graph --stat --date=relative --pretty=format:'%C(yellow)%h%Creset%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset'"

# tmux
alias ta='tmux attach -t'		            # attach named session
alias tp='tmux a'           		        # attach previous session
alias tt='tmux a && tmux choose-session'	# show tmux choose-session
alias tl='tmux list-sessions'
# alias tn='tmux new-session -s'	      is in functions.sh       # create new named session
# alias tk='tmux kill-session -t'         is in functions.sh          # kill named session
alias tx='tmuxinator'			            # example `tx tob` (start session, or attach if already running)

# nmap requires sudo to find all devices
# -i=case INsensitive -v=invert
alias scannetwork="sudo nmap -sn 192.168.1.0/24 | sed -e 's|Nmap scan report|\nNmap scan report|'"
alias scannetworkMore="sudo nmap 192.168.1.0/24"

# react-native
alias rnPodsReInstall="rm -rf ios/build ios/Pods ios/Podfile.lock; cd ios; pod install; cd -" # remove build+pods and reinstall them
# rni in functions
alias prodrni="npx react-native run-ios --simulator=\"iPhone 14\" --configuration Release"
alias rna="npx react-native run-android"
alias rnar="cd android && ./gradlew --no-daemon bundleRelease && open ./app/build/outputs/bundle/release/ && cd .."
alias xcodederiveddata="open /Users/tobbe/Library/Developer/Xcode/DerivedData/"
alias openinxcode='open $(find ios -name "*.xcworkspace" -print -quit)'
alias sendRNDevMenuKey="adb shell input keyevent 82"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias å="exit"

# which code => returns where code command in terminal is installed! if node or global node module, make sure to run command first. ex: `node -v` then `which node`
# someoutput grep cool => returns lines where "cool" exist in someoutput. works with pipes |
# rg --no-ignore --hidden --files | rg contentOfFileName (ex: keystore)
# rg --files --no-ignore -. | rg -F 'bdo.md' # -F = treat string as fixed (not regex), ie auto escape stuff
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
# curl -L --silent https://site.com | grep -o -E ".{0,3}someword.{0,4}"
# if file contains it
# grep -o -E ".{0,3}someword.{0,4}" file.txt

# check info of process
# ps aux | grep {pid}
