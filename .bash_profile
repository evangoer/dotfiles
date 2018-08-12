#!/bin/bash

# Add any local (not in git) bash config
[ -f ~/.bashrc ] && source ~/.bashrc

# Base paths
PATH=$PATH:/usr/bin:/usr/sbin
[ -d /sbin ] && PATH=/sbin:$PATH
[ -d /bin ] && PATH=/bin:$PATH
[ -d /usr/local ] && PATH=/usr/local/bin:/usr/local/sbin:$PATH
[ -d /usr/texbin ] && PATH=/usr/texbin:$PATH
[ -d /Library/Developer/Toolchains/swift-latest.xctoolchain ] && PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH

# Paths for various package managers
if [ -d /opt/local ]; then 
    PATH=/opt/local/bin:/opt/local/sbin:/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH
    [ -d /opt/local/lib/mysql55/bin ] && PATH=/opt/local/lib/mysql55/bin:$PATH
    [ -d /opt/local/apache2/bin ] && PATH=/opt/local/apache2/bin:$PATH
    export MANPATH=/opt/local/man:/opt/local/share/man:$MANPATH
fi

export PATH

export OS_TENANT_NAME=csi-tenant-egoer
export OS_AUTH_URL=https://mr-keystone.isg.apple.com:5000/v2.0/
export OS_USERNAME=$USER

set -o vi

if [ -f ~/.git-completion.bash ]; then 
    . ~/.git-completion.bash
fi

function branch() {
    BRANCH=`git branch 2>/dev/null | grep '\*' | awk '{print $2}'`
    [[ $BRANCH != '' ]] && echo "on $BRANCH "
}

# If I'm not 'evan' or 'goer', display user@ in the prompt
ALT_USER=''; [[ `whoami` != 'evan' && `whoami` != 'egoer' ]] && ALT_USER=`whoami`@

function salads_required() {
    if [ ! -f ~/.salad ]; then
        return 0
    fi

    declare -i WEEK_START SALAD SALAD_COUNT
    local WEEK_START=`date +%s`-60*60*24*7
    local SALAD_COUNT=3
    local SALAD_DB=~/.salad
    local SALAD=0

    while read SALAD; do
        declare -i SALAD
        if [ $WEEK_START -lt $SALAD ]; then
            SALAD_COUNT=$SALAD_COUNT-1
        fi
        if [ $SALAD_COUNT -lt 1 ]; then
            break
        fi
    done < $SALAD_DB

    for ((i=0; i<SALAD_COUNT; i++)); do
        SALAD_STR=${SALAD_STR}🌿
    done

    [[ -n $SALAD_STR ]] && echo " $SALAD_STR"
}

PS1='\t$(salads_required) ${ALT_USER}\h:\w $(branch)\$ '

export EDITOR=nvim
export CLICOLOR=true
export GREP_OPTIONS='--color=auto'

alias vi=nvim
alias vim=nvim
alias :q=exit 
alias ZZ=exit 

# Scheme for managing dotfiles via git without making ~ a git repo.
# When updating dotfiles, use 'dotfiles <gitcmd>', not 'git <gitcmd>'.
# When adding a NEW dotfile, use the -f option (force) since by default, all files are ignored.
#
# 1. git clone git@github.com:evangoer/dotfiles.git
# 2. mv dotfiles/.git ~/.dotfiles.git
# 3. [optional] avoid clobbering old dotfiles (copy or rename as necessary)
# 4. cp -R dotfiles/.* ~
#
# Derived from http://silas.sewell.org/blog/2009/03/08/profile-management-with-git-and-github/
# and http://necoro.wordpress.com/2009/10/08/managing-your-configuration-files-with-git-and-stgit/
alias dotfiles='git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME'

# Convenience aliases for MacPorts packages
if [ -f /opt/local/bin/mysqladmin5 ]; then
    alias mysqlstart='sudo /opt/local/bin/mysqld_safe5 &'
    alias mysqlstop='/opt/local/bin/mysqladmin5 -u root -p shutdown'
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
