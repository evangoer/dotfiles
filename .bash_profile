#!/bin/bash

# Add any local (not in git) bash config
[ -f ~/.bashrc ] && source ~/.bashrc

# Base paths
PATH=$PATH:/usr/bin:/usr/sbin
[ -d /sbin ] && PATH=/sbin:$PATH
[ -d /bin ] && PATH=/bin:$PATH
[ -d /usr/local ] && PATH=/usr/local/bin:/usr/local/sbin:$PATH
[ -d /usr/texbin ] && PATH=/usr/texbin:$PATH
[ -d ~/dev/sprox/bin ] && PATH=~/dev/sprox/bin:$PATH

# Paths for various package managers
if [ -d /opt/local ]; then 
    PATH=/opt/local/bin:/opt/local/sbin:/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin:$PATH
    [ -d /opt/local/lib/mysql55/bin ] && PATH=/opt/local/lib/mysql55/bin:$PATH
    [ -d /opt/local/apache2/bin ] && PATH=/opt/local/apache2/bin:$PATH
    export MANPATH=/opt/local/man:/opt/local/share/man:$MANPATH
fi
[ -d $HOME/.rvm/bin ] && PATH=$HOME/.rvm/bin:$PATH

export PATH

# local::lib (CPAN)
[ $SHLVL -eq 1 ] && eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"

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

# Indicate whether we're in a chroot, virtualenv, rvm, etc.
function virtual() {
  RVM_PROMPT=`rvm-prompt v g 2>/dev/null`
  [[ $RVM_PROMPT != '' ]] && echo "[$RVM_PROMPT]"
}

PS1='\t ${ALT_USER}\h$(virtual):\w $(branch)\$ '

export EDITOR=vim
export CLICOLOR=true
export GREP_OPTIONS='--color=auto'

alias vi=vim
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
