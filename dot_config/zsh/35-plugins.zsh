# 補完拡張
zinit light zsh-users/zsh-completions

# 入力補助
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

# 補完初期化（必ず最後）
autoload -Uz compinit
compinit
