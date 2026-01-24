# History

HISTFILE=~/.zsh_history
HISTSIZE=20000
SAVEHIST=20000

setopt hist_ignore_dups        # 連続重複を保存しない
setopt hist_ignore_space       # 先頭スペースのコマンドは保存しない
setopt hist_reduce_blanks      # 余計な空白を詰める
setopt inc_append_history      # 実行したらすぐ履歴へ追加
setopt share_history           # 複数シェルで履歴共有
setopt extended_history        # タイムスタンプ等も保持
