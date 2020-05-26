
# Load the shell dotfiles:
for file in ~/.{aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;


## NVM (node version manager. Install with brew)
load_nvm () {
	export NVM_DIR=~/.nvm
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
}

# default setup
# load_nvm

# lazy setup (http://broken-by.me/lazy-load-nvm/)
declare -a NODE_GLOBALS=(`find ~/.nvm/versions/node -maxdepth 3 -type l -wholename '*/bin/*' | xargs -n1 basename | sort | uniq`)
NODE_GLOBALS+=("node")
NODE_GLOBALS+=("nvm")
for cmd in "${NODE_GLOBALS[@]}"; do
    eval "${cmd}(){ unset -f ${NODE_GLOBALS}; load_nvm; ${cmd} \$@ }"
done
# end lazy setup nvm

## end NVM


# python env version manager
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi


# there is 3 ways to add programs to be executable:
# (not recommended) add lines to /etc/paths
# `export PATH=$PATH:path/to/program` in .bash_profile will add paths at the end of your $PATH
# `ln -s /path/to/some/program /usr/local/bin/program` will create a symlink to /usr/local/bin/ which is already in /etc/paths

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator # make sure this is BEFORE /tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/build-tools/28.0.3
export LANG=en_US.UTF-8
export PATH=$PATH:"/Applications/Sublime Merge.app/Contents/SharedSupport/bin"
export PATH=$PATH:"/Applications/Sublime Text.app/Contents/SharedSupport/bin"
export PYTHONDONTWRITEBYTECODE=1
