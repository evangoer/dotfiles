export PATH=/opt/local/bin:~/.npm-global/bin:$PATH

alias vi=nvim
alias vim=nvim
alias :q=exit
alias ZZ=exit

# TODO clean out dotfiles for home, work (or at least home)
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

# TODO evaluate for zshrc
#
# FZF setup?
# eval "$(fzf --bash)"
#
# Git completion needed?
# if [ -f ~/.git-completion.bash ]; then 
#     . ~/.git-completion.bash
# fi
#
#
# How many of these do I need? 
# export EDITOR=nvim
# export CLICOLOR=true
# export GREP_OPTIONS='--color=auto'
#
# Do I still want this?
# set -o vi
