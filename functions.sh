
# Start an HTTP server from a directory, optionally specifying the port
# why use -c and -p flags: https://stackoverflow.com/a/38295516/1320551
function server() {
	local port="${@:-8022}";
	echo 'https://www.npmjs.com/package/http-server'
	# sleep 2 && open "http://localhost:${port}/" &
	npx http-server -c-1 -p $port
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

function re() {
	code $(f $@ -e)
}

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

function gg() {
	local message="${@:-no message}";
	git add -A && git commit -m "${message}" && git push
}
function gam() {
	local message="${@:-no message}";
	git add -A && git commit -m "${message}"
}

# ex `getProcessByPort 8081`
function portGetProcessId() {
	lsof -n -i4TCP:$@
	printYellow "Kill with: kill (PID == processId)\n" # https://stackoverflow.com/questions/24387451/how-can-i-kill-whatever-process-is-using-port-8080-so-that-i-can-vagrant-up
}

nf() {
	cd "/Users/tobbe/Google Drive/Work/todo"
	v -c 'startinsert'
	cd -
}

function goo() {
	local message="${@:-}";
	open 'https://www.google.com/search?q='${message}
}

# ex: curlPostRe :80/post
# edit with curlEditPostData
# must use quotes around property-names in json!
function curlPostBodyFromFileRe() {
	curl -H "Content-Type: application/json" -X POST --data-binary @/Users/tobbe/Downloads/body.json $@ | jq
}

# ex: curlPost :80/post
function curlPostBodyFromFile() {
	curlEditPostData && curlPostRe $@ | jq
}

# ex: curlPostForm "param1=value1&param2=value2" :80/post
function curlPostForm() {
	curl -X POST --data-urlencode $@
}

function sumlines() {
	awk '{s+=$1} END {print s}' $@
}

function gitStatusRecursive() {
    local underline=$(tput smul)
    local qty_has_changes=0

    local show_no_changes=true
    if [[ $1 == *"-q"* ]]; then
        show_no_changes=false
    fi

    local do_git_fetch=false
    if [[ $1 == *"-f"* ]]; then
        do_git_fetch=true
    fi

    # find all .git directories
    local git_dirs=$(find . -type d -name .git -maxdepth 3)

    # remove ".git" from lines
    local dir_names=$(echo $git_dirs | sed -e "s/\.git//")

    # Create arrays to store repos with and without changes
    local no_changes_repos=()
    local has_changes_repos=()

    echo $dir_names | tr ' ' '\n' | while read line ; do
        if [ -z "$line" ]; then
            continue
        fi

        if [ "$do_git_fetch" = true ]; then
            echo "git fetching ${line}"
            (cd $line && git fetch --quiet)
        fi

        local git_output=$(cd $line && git status -s)
        local git_output_length=${#git_output}

        if [[ ${#git_output_length} -gt 1 ]]; then
            has_changes_repos+=("$line")
            ((qty_has_changes++))
        elif [ "$show_no_changes" = true ]; then
            no_changes_repos+=("$line")
        fi
    done

    # Sort the arrays alphabetically, ignoring case
	IFS=$'\n' no_changes_repos=($(sort -f <<<"${no_changes_repos[*]}"))
	IFS=$'\n' has_changes_repos=($(sort -f <<<"${has_changes_repos[*]}"))

    # Display repos without changes first
    for repo in "${no_changes_repos[@]}"; do
        echo -e "\e[32m$repo\e[0m"
    done

    # Display repos with changes last
    for repo in "${has_changes_repos[@]}"; do
        echo -e "\e[31m${underline}$repo\e[0m$(printRed " - has changes")"
        # (cd $repo && git status -s)
    done

    if [ "$qty_has_changes" = "0" ]; then
        printf "\n"
        echo -e "\e[32m🎉 Everything is up to date!\e[0m"
    fi

    printf "\n"
}


function rnclearcache() {
	printRed "⚠️ Clear all the caches...\n";

	echo "🧹🧹🧹 Removing ios/build...";
    rm -rf ios/build;

	echo "🧹🧹🧹 Deleting all DerivedData folders...";
	rm -rf ~/Library/Developer/Xcode/DerivedData/*

	echo "🧹🧹🧹 Running xcode clean...";
	cd ios
	xcodebuild clean
	cd -

	echo "🧹🧹🧹 Removing watchman watches...";
	watchman watch-del-all;
	watchman shutdown-server

	# Using node_modules so must run after npm i
	echo "🧹🧹🧹 Cleaning android gradlew...";
	cd android && ./gradlew --no-daemon clean && cd -;
}


function rnyolo() {
    echo "🧹🧹🧹 Removing node_modules...";
    rm -rf node_modules;

    echo "🧹🧹🧹 Removing package-lock.json...";
    rm package-lock.json;

	## echo "🧹🧹🧹 Deintegrate CocoaPods from your project...";
	## DANGER, removes build phases in xcode etc:  cd ios && pod deintegrate && cd -

    echo "🧹🧹🧹 Removing ios/Pods...";
    rm -rf ios/Pods;

    echo "🧹🧹🧹 Removing ios/Podfile.lock...";
    rm ios/Podfile.lock;

    echo "🤠🤠🤠 Running npm install...";
    npm i;

	rnclearcache;

    echo "🤠🤠🤠 Running pod install...";
    cd ios && pod install && cd -;

	printYellow "\nDone! 🎉\n";
	printRed "🚨 Also try restart bundler with \`react-native start --reset-cache\`\n"
}


# go to finderpath: `cd $(finderpath)`
function finderpath() {
	osascript -e 'tell application "Finder" to get the POSIX path of (target of front window as alias)'
}

function gfgo() {
	if [[ $@ = *" "* ]]; then
  		echo "Release name cant contain spaces"
		return 1;
  	fi

	if [ $# -eq 0 ]; then
		echo 'Please name release'
		return 1;
	else
		git flow release start $@
		GIT_MERGE_AUTOEDIT=no git flow release finish -m '$@' -n $@
		echo 'Dont forget to push!'
	fi;
}

function countLetters() {
	local str="${@:-}";
	echo ${#str}
}

function minifyVideo() {
	ffmpeg -i $1 -c:v libx265 -preset fast -crf 28 -tag:v hvc1 -c:a eac3 -b:a 224k $2.mp4
}

timer() {
    start="$(( $(date '+%s') + $1))"
	spin='-\|/'
	echo "Timer: $1s"
    while [ $start -ge $(date +%s) ]; do
        # time="$(( $start - $(date +%s) ))"
        # echo -ne "."
		i=$(( (i+1) %4 ))
		printf "\r${spin:$i:1}"
        sleep 0.1
    done
	osascript -e 'display notification "🚨" with title "Timer"'
	say 'Timer finished!'
	osascript -e 'display notification "⏰" with title "Timer"'
	sleep 0.6
	osascript -e 'display notification "🚨" with title "Timer"'
	sleep 0.6
	osascript -e 'display notification "⏰" with title "Timer"'
	sleep 0.6
	osascript -e 'display notification "🚨" with title "Timer"'
}

function startDocker () {
	printf "Starting Docker";
	open -a Docker;

	while [[ -z "$(! docker stats --no-stream 2> /dev/null)" ]];
	do printf ".";
	sleep 1
	done

	echo "";
}

function ff () {
	local dirr=$*
	local hasnav=false
	if [[ -n $dirr ]]; then
		if [[ -d $dirr ]]; then
			# if subdir exist, go there
			hasnav=true
			cd $dirr
		elif [[ ! -z $(f -e $dirr) ]]; then
			# if z find something, go there
			f "$dirr"
			hasnav=true
		fi;
	fi;
	
	local fpath=$(fzf --bind 'f2:execute-silent(code {})' --preview 'bat --style=numbers --color=always --line-range :500 {}')
	[ -z $fpath ] || code $fpath
	# [[ $hasnav ]] && cd - > /dev/null
}

# find in files
fif() {
	local dirr=$*
	local hasnav=false
	if [[ -n $dirr ]]; then
		if [[ -d $dirr ]]; then
			# if subdir exist, go there
			hasnav=true
			cd $dirr
		elif [[ ! -z $(f -e $dirr) ]]; then
			# if z find something, go there
			f "$dirr"
			hasnav=true
		fi;
	fi;
	
	selected=$(
	fzf \
	-m \
	-e \
	--ansi \
	--disabled \
	--reverse \
	--bind "ctrl-a:select-all" \
	--bind "f2:execute-silent(code {})" \
	--bind "change:reload:rg -i -l --hidden {q} || true" \
	--preview "rg -i --pretty --context 2 {q} {}" | cut -d":" -f1,2
	)

	[[ -n $selected ]] && code $selected # open multiple files in editor
	# [[ $hasnav ]] && cd - > /dev/null
}

function da() {
  local cid
  cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')

  [ -n "$cid" ] && docker attach "$cid"
}

function sshproxy() {
	# create with `mkcert "*.https.localhost"`
	# CANNOT be "*.localhost". Must have subdomain before wildcard
	local-ssl-proxy --source ${2:-3010} --target ${1:-3000} --cert ~/_wildcard.https.localhost.pem --key ~/_wildcard.https.localhost-key.pem
}

function jsontocsv() {
	if [ -z "$1" ]; then
		echo "\033[0;31mNo file selected"
		return -1
	fi;

	filename="$(basename -- $1)"
	outputName="${filename/json/csv}"   

	jq -r '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols, $rows[] | @csv' $1 > $outputName
}

function testIfYouHaveAccessToFns() {
	osascript -e 'display dialog ("HI!")'
}

# example: replaceInConfig API2_ORIGIN "http:\/\/"$(localip) .env.development.local
replaceInConfig() {
    local file=$3
    sed -E -i '' "/^$1=/{s/=.+/=$2/;}" "$file"
	printRed "\nDont forget to restart build job!\n\n"
}

printRed() {
	local RED='\033[1;31m'
	local NC='\033[0m' # No Color
	printf "${RED}$1${NC}" # printf doesnt send end-of-line. So add \n after your input to skip "%"
}
printYellow() {
	local YELLOW='\033[0;33m'
	local NC='\033[0m' # No Color
	printf "${YELLOW}$1${NC}" # printf doesnt send end-of-line. So add \n after your input to skip "%"
}

generate_random_string() {
  local length=$1
  local random_string=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1)
  echo "$random_string"
}

function setgituser {
  if [ "$#" -eq 0 ]; then
    printRed "Error: You have to pass an email address!\n"
    return 1
  else
	git config user.email "$@"
  	git config user.name "Tobias Ekman"

	echo "✅ Git config set to:"
	echo "Name: $(git config user.name)"
	echo "Email: $(git config user.email)"
  fi
}

function rni() {
	if [ -z "$1" ]; then
		simulator_name="iPhone 15 Pro";
	else
		simulator_name="$1";
	fi

	if ! xcrun simctl list | grep -Fq "Booted"; then
		xcrun simctl boot "$simulator_name"
	else
		echo "🆗 "$simulator_name" simulator already booted"
	fi

	open -a Simulator

	npm start;

	sleep 2
	osascript -e 'tell application "System Events" to key code 34'
}

function pi() {
  if [[ "$PWD" != */ios ]]; then
    cd ios
  fi

  pod install
  cd ..
}

foreachline() {
  # usage: doforlines <file> <command>
  local file="$1"
  shift
  while IFS= read -r line || [ -n "$line" ]; do
    "$@" "$line"
  done < "$file"
}

# usage: getwithenvvar CRON_SECRET https://url --extra-httpie-params(optional)
# example: getwithenvvar CRON_SECRET https://url -v (verbose) --follow (follow redirects)
function getwithenvvar() {
    local variable_name=$1
    local url=$2
    local current_dir=$(pwd)
    local env_file="${current_dir}/.env.local"
    local secret_value
    # Read in the target variable from the environment file
    if [ -f "$env_file" ]; then
        secret_value=$(grep -m 1 "^${variable_name}=" "$env_file" | cut -d '=' -f2-)
        # Remove surrounding double quotes only if both are present
        if [[ $secret_value == \"*\" && $secret_value == *\" ]]; then
            secret_value="${secret_value%\"}"
            secret_value="${secret_value#\"}"
        fi
    fi
    # Ensure the variable was actually found and is not empty
    if [ -z "$secret_value" ]; then
        echo "The variable '${variable_name}' was not set or is empty."
        return 1
    fi

    http $3 $4 $5 $6 -A bearer -a "$secret_value" "$url"
}

function mitm_on() {
    networksetup -setsecurewebproxystate wi-fi on
    networksetup -setwebproxystate wi-fi on
    
    networksetup -setwebproxy wi-fi localhost 8080
    networksetup -setsecurewebproxy wi-fi localhost 8080
}

function mitm_off() {
    networksetup -setsecurewebproxystate wi-fi off
    networksetup -setwebproxystate wi-fi off
}

function code() {
	# open current directory in vscode
	if [ $# -eq 0 ]; then
		open -a "Visual Studio Code" .
	else
		open -a "Visual Studio Code" $@
	fi
}

function tn() {
  if [ -z "$1" ]; then
    echo "Error: Session name required"
    return 1
  fi
  tmux new-session -d -s "$1" 2>/dev/null # handle if session already exists
  if [ -n "$TMUX" ]; then
     tmux switch-client -t "$1"
  else
    tmux attach -t "$1"
  fi
}

function tk() {
    if [ -z "$1" ]; then
       tmux kill-session
    else
        tmux kill-session -t "$1"
    fi
}

function v() {
  if [ $# -eq 0 ]; then
    nvim
  else
    nvim $@
  fi
}

function resizeAndConvertImagesInFolder() {
    # Default values
    width=2000
    quality=90
    
    # Parse command line arguments
    while getopts "w:q:" opt; do
        case $opt in
            w) width=$OPTARG ;;
            q) quality=$OPTARG ;;
            *) ;;
        esac
    done
    
    rm -rf resized_images
    mkdir -p resized_images

    # Find all image files and process them
    find . -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | while read img; do
        # Get filename without extension
        filename=$(basename -- "$img")
        name="${filename%.*}"
        
        # Resize and convert to jpg with specified quality
        sips --resampleWidth $width --setProperty format jpeg --setProperty formatOptions $quality "$img" --out "resized_images/${name}.jpg"
    done

    echo "All images have been resized to width $width with quality $quality and saved to the resized_images directory"
}