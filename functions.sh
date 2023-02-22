
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

# ex `getProcessByPort 8081`, then `kill (PID == processId)` ---> https://stackoverflow.com/questions/24387451/how-can-i-kill-whatever-process-is-using-port-8080-so-that-i-can-vagrant-up
function getProcessByPort() {
	lsof -n -i4TCP:$@
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

	local dir_names_sorted=$(echo $dir_names | awk '{ print length($0) " " $0; }' $file | sort -n | cut -d ' ' -f 2-)

	echo $dir_names_sorted | while read line ; do
		local git_output=$(cd $line && git status -s)
		local git_output_length=${#git_output}

		if [ "$do_git_fetch" = true ]; then
			echo "git fetching ${line}"
			local do_git_fetch_output=$(cd $line && git fetch --quiet)
		fi

		if [[ ${#git_output_length} -gt 1 ]]; then
			((qty_has_changes++))
			echo -e "\e[31m${underline}$line\e[0m"
			(cd $line && git status -s)
		elif [ "$show_no_changes" = true ]; then
				echo -e "\e[32m$line\e[0m"
		fi
	done

	if [ "$qty_has_changes" = "0" ]; then
		printf "\n"
		echo -e "\e[32m🎉 Everything is up to date!\e[0m"
	fi

	printf "\n"
}

function rnyolo() {
	rm -rf node_modules;
	rm package-lock.json;
	rm -rf ios/build;
	rm -rf ios/Pods;
	rm ios/Podfile.lock;
	npm i $@;
	cd ios;
	pod install;
	cd -;
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

function resizeJpgsMaxWidth() {mkdir $1x; for f in *.jpg; do sips --resampleWidth "$1" "$f" --out "$1x//${f/.jpg/_$1.jpg}"; done }

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