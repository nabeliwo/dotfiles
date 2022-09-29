#!/bin/bash

set -eu

# 実行場所のディレクトリを取得
THIS_DIR=$HOME/dev/dotfiles

if [ ! -d "$THIS_DIR" ]; then
    git clone https://github.com/nabeliwo/dotfiles.git "$THIS_DIR"
else
    echo "$THIS_DIR already downloaded. Updating..."
    cd "$THIS_DIR"
    git stash
    git checkout main
    git pull origin main
    echo
fi

cd $THIS_DIR

echo "start setup..."

for f in .??*
do
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".aws" ]] && continue
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".ssh" ]] && continue

    ln -snfv "$THIS_DIR/$f" ~/
done

# install homebrew
if ! command -v brew > /dev/null 2>&1; then
    # Install homebrew: https://brew.sh/
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo
fi
brew bundle
echo

cat << END
**************************************************
DOTFILES SETUP FINISHED! bye.
**************************************************
END
