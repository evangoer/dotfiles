#!/bin/bash

# Base paths
PATH=/usr/bin:/usr/sbin
[ -d /sbin ] && PATH=/sbin:$PATH
[ -d /bin ] && PATH=/bin:$PATH
[ -d /usr/local ] && PATH=/usr/local/bin:/usr/local/sbin:$PATH
[ -d /usr/texbin ] && PATH=/usr/texbin:$PATH

# Paths for various package managers
if [ -d /opt/local ]; then 
    PATH=/opt/local/bin:/opt/local/sbin:/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH
    export MANPATH=/opt/local/man:/opt/local/share/man:$MANPATH
fi
[ -d /home/y ] && PATH=/home/y/bin:$PATH
export PATH

function branch() {
    BRANCH=`git branch 2>/dev/null | grep '\*' | awk '{print $2}'`
    [[ $BRANCH != '' ]] && echo "on $BRANCH "
}

PS1='\t \u@\h:\w $(branch)\$ '

export EDITOR=vim
export CLICOLOR=true
export GREP_OPTIONS='--color=auto'

alias vi=vim
alias :q=exit 
alias ZZ=exit 

# Scheme for managing dotfiles via git without making ~ a git repo.
# When updating dotfiles, use 'dotfiles <gitcmd>', not 'git <gitcmd>'.
# When adding a NEW dotfile, use the -f option (force) since by default, all files are ignored.
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
