#!/bin/bash

## link to this in alfred "script filter" like this: `~/.dotfiles/scripts/devpaths.sh $@`
## For some reason the first line is excluded by jq, thats why I prepend "argh"
## https://juripakaste.fi/jq-alfred-script-filter/

extraPaths="/Users/tobbbe/.dotfiles" # just add new line inside string here to add more items

(echo "argh" && find ~/dev ~/devp -mindepth 1 -maxdepth 1 -type d && echo $extraPaths) | /usr/local/bin/jq -nR \
'{
    # things here is jq-things! split() etc NOT bash.
    # Wrap in '' to use args. ex see contains below
    "items": [
        inputs |
        select(length>0) |                                          # remove empty lines
        inputs as $path |
        $path | split("/")[-1] as $title |                          # take dir name. `($path | split("/")[-1] | sub("^\\."; "")) as $title |` to remove leading dot
        select($title | contains("'$1'") and contains("'$2'") and contains("'$3'")) |
        {
            "uid": $path,
            "type": "public.folder",
            "title": $title,
            "subtitle": $path,
            "arg": $path,
            icon: { type: "filetype", path: "public.folder" }
        }
    ]
}'

# >&2 echo "Arg: $@" # log to terminal. doesnt work to alfred debug though :/