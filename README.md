# 新しい Mac を買ったらやるやつ

## Homebrew のインストールと brew を使ったコマンド・アプリのインストール

1. ターミナルを開く
2. $HOME 配下に dev ディレクトリを切る
3. $HOME に移動
4. 以下のコマンドを叩く
   1. `bash -c "$(curl -L https://raw.githubusercontent.com/nabeliwo/dotfiles/main/install.sh)"`

## prezto のインストール

1. 以下のコマンドを叩く
   1. `zsh -c "$(curl -L https://raw.githubusercontent.com/nabeliwo/dotfiles/main/prezto.sh)"`
2. `tmp.zshrc` の内容を $HOME/.zshrc に追記する
3. 以下を参考にテーマを変更する
   1. https://qiita.com/gilly/items/5ff7bd7142e963cdbb9b

## iterm2 のテーマ変更

1. 以下のリポジトリから `getafe.itemcolors` をダウンロードして iterm2 の profile の color に設定する
   1. https://github.com/larssmit/iterm2-getafe
