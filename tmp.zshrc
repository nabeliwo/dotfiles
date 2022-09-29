#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


#
# path
#
export PATH=/usr/local/bin/git:$PATH
eval "$(fasd --init posix-alias zsh-hook)"
. /usr/local/opt/asdf/libexec/asdf.sh


#
# alias
#
alias g='git'
alias be='bundle exec'
alias cdg='cd $(ghq root)/$(ghq list | peco)'


#
# コマンド履歴検索
#
function peco-history-selection() {
  BUFFER=`history -n 1 | tac  | awk '!a[$0]++' | peco`
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection
