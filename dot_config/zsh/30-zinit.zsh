ZINIT_HOME="$HOME/.local/share/zinit/zinit.git"
# 未インストールなら自動で clone（新規マシンのブートストラップ）
if [[ ! -f "$ZINIT_HOME/zinit.zsh" ]] && command -v git >/dev/null 2>&1; then
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
[[ -f "$ZINIT_HOME/zinit.zsh" ]] && source "$ZINIT_HOME/zinit.zsh"
