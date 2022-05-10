#!/bin/bash

## link to this in alfred "script filter" like this: `~/dotfiles/scripts/devpaths.sh $@`
## everytime 'inputs' is called it pops from the list https://stackoverflow.com/questions/72110455/why-is-the-first-line-is-skipped/72110653#72110653<
## https://juripakaste.fi/jq-alfred-script-filter/
## https://www.alfredapp.com/help/workflows/inputs/script-filter/json/

extraPaths=$(cat <<EOF
/Users/tobbbe/dotfiles
/Users/tobbbe/devp/tobb.be/www
EOF
)

(find ~/dev ~/devp -mindepth 1 -maxdepth 1 -type d && echo -e "$extraPaths") | /usr/local/bin/jq -nR \
'{
    # things here is jq-things! split() etc NOT bash.
    # Wrap in '' to use args. ex see contains below
    "items": [
        inputs as $path |
        $path |
        split("/")[-1] as $title |
        select($path | split("/tobbbe/")[-1] | contains("'$1'") and contains("'$2'") and contains("'$3'")) |
        {
            "uid": $path,
            "title": $title,
            "subtitle": $path,
            "arg": $path,
            "type": "file:skipcheck",
            # icon: { type: "filetype", path: "public.folder" }
        }
    ]
}'

# >&2 echo "Arg: $@" # log to terminal. doesnt work to alfred debug though :/