# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100
SAVEHIST=1000
setopt HIST_IGNORE_DUPS
setopt nobeep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/daniel/.zshrc'
zstyle ':completion:*:desctiptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'
setopt correctall
# prompt -l lists promt themes

autoload -U compinit
compinit
# End of lines added by compinstall

bindkey ';5D'   emacs-backward-word
bindkey ';5C'   emacs-forward-word
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '\e[3~' delete-char

# alias
alias ls='ls --color=auto --human-readable --group-directories-first'
alias ll='ls --color=auto --almost-all --human-readable --group-directories-first -l'
alias l='ls --color=auto --human-readable --group-directories-first -l'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias cal='cal -m'

# PS1 escape sqeuences
# man zshmisc for a full list of parameters
export PS1="%F{magenta}%1d$%f "

# ex - archive extractor
# usage: ex <file>
ex ()
{
        if [ -f $1 ] ; then
                case $1 in
                        *.tar.xz)    tar xf $1          ;;
                        *.tar.bz2)   tar xjf $1         ;;
                        *.tar.gz)    tar xzf $1         ;;
                        *.bz2)       bunzip2 $1         ;;
                        *.rar)       unrar x $1         ;;
                        *.gz)        gunzip $1          ;;
                        *.tar)       tar xf $1          ;;
                        *.tbz2)      tar xjf $1         ;;
                        *.tgz)       tar xzf $1         ;;
                        *.zip)       unzip $1           ;;
                        *.Z)         uncompress $1      ;;
                        *.7z)        7z x $1            ;;
                        *)           echo "'$1' cannot be extracted via ex()" ;; 
                esac
        else
                echo "'$1' is not a valid file"
        fi
}
