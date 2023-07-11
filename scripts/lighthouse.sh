#!/bin/bash -l

# Dependency: requires lighthouse (https://developers.google.com/web/tools/lighthouse#cli)
# Install via npm: `npm install -g lighthouse`

# @raycast.title Lighthouse
# @raycast.description Open a [Lighthouse](https://developers.google.com/web/tools/lighthouse/) report of URL.

# @raycast.currentDirectoryPath ~/Desktop
# @raycast.icon images/google-lighthouse-logo.png
# @raycast.mode silent
# @raycast.packageName Google
# @raycast.schemaVersion 1

# @raycast.argument1 { "type": "text", "placeholder": "URL" }
# @raycast.argument2 { "type": "text", "placeholder": "d|m(default)", "optional": true  }

if ! command -v lighthouse &> /dev/null; then
	echo "lighthouse is required (https://developers.google.com/web/tools/lighthouse#cli).";
	exit 1;
fi

regex='(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'

if [[ $1 =~ $regex ]]; then
    # https://www.npmjs.com/package/lighthouse#cli-options
	if [[ $2 == "d" ]]; then
        lighthouse --quiet --view --preset=desktop "$1"
    else
        lighthouse --quiet --view "$1"
    fi
else
    echo "Input is not a valid URL."
    exit 1
fi