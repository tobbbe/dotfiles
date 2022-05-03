#!/bin/bash

## https://juripakaste.fi/jq-alfred-script-filter/

extraPaths="/Users/tobbbe/.dotfiles" # just add new line inside string here to add more items

(find ~/dev ~/devp -mindepth 1 -maxdepth 1 -type d && echo $extraPaths) | /usr/local/bin/jq -nR \
'{
    "items": [
        # things here is jq-things! split() etc
        inputs |
        select(length>0) |                                          # remove empty lines
        inputs as $path |
        ($path | split("/")[-1] | sub("^\\."; "")) as $title |      # take dir name and remove leading dot
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