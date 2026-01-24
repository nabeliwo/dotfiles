# Environment variables

# less (ページャーの設定)
export LESS='-g -i -M -R -S -w -X -z-4'

# zoxide (z でディレクトリを移動)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# fzf key bindings & completion (Homebrew)
# ctrl + r: ヒストリー検索
# ctrl + t: 今いるディレクトリ以下のファイル検索
# option + c: 今いる場所からディレクトリ移動
if [[ -x /opt/homebrew/bin/brew ]]; then
  local fzf_base
  fzf_base="$(/opt/homebrew/bin/brew --prefix fzf 2>/dev/null)"

  if [[ -n "$fzf_base" ]]; then
    [[ -r "$fzf_base/shell/key-bindings.zsh" ]] && source "$fzf_base/shell/key-bindings.zsh"
    [[ -r "$fzf_base/shell/completion.zsh"   ]] && source "$fzf_base/shell/completion.zsh"
  fi
fi

# starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
# starship config
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

# Rails console でエラーが出る問題の対応
# https://github.com/rails/rails/issues/38560
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# local secrets (not managed by chezmoi)
if [[ -r "$HOME/.config/zsh/80-secrets.zsh" ]]; then
  source "$HOME/.config/zsh/80-secrets.zsh"
fi
