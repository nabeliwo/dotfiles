# dotfiles

nabeliwo's dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Platform Support

This dotfiles repository supports:
- **macOS** (Apple Silicon and Intel)
- **WSL2 Ubuntu**
- **Linux** (with Homebrew)

Platform-specific configurations are automatically applied using chezmoi templates.

## Get started

### macOS

#### 1. Install chezmoi

```bash
brew install chezmoi
```

#### 2. Clone dotfiles

```bash
chezmoi init https://github.com/nabeliwo/dotfiles.git
```

<!-- #### 3. Login to 1password cli

```
# On bash
eval $(op my.1password.com メールアドレス)

# On fish with fish-replay
replay 'eval $(op my.1password.com メールアドレス)'
``` -->

#### 3. Apply dotfiles

```bash
chezmoi apply
```

### WSL2 Ubuntu

#### 1. Install Linux Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (follow the instructions shown after installation)
```

#### 2. Install wsl-open (for browser integration)

```bash
sudo apt update
sudo apt install wsl-open
```

#### 3. Install chezmoi

```bash
brew install chezmoi
```

#### 4. Clone dotfiles

```bash
chezmoi init https://github.com/nabeliwo/dotfiles.git
```

#### 5. Apply dotfiles

```bash
chezmoi apply
```

#### 6. Font setup (Windows side)

Install these fonts on Windows for proper terminal display:
- [Hack Nerd Font](https://www.nerdfonts.com/)
- Noto Sans CJK JP

Configure Windows Terminal to use these fonts in its settings.

## Required Tools

### 1. Install zinit (zsh plugin manager)

```bash
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
```

After installation, restart your shell or run `exec zsh` to reload.

### 2. Install other tools via Homebrew

```bash
# Essential tools
brew install fzf       # Fuzzy finder for command history and file search
brew install starship  # Shell prompt
brew install zoxide    # Smart directory navigation
brew install mise      # Runtime version manager
brew install ghq       # Repository management
brew install lazygit   # Git TUI

# Optional: Node.js and package managers
brew install node
npm install -g pnpm
```

**Note**: The dotfiles are designed to work even if some tools are not installed. Missing tools will simply be skipped without causing errors. However, for the best experience, install all the tools listed above.

## Platform-specific notes

### Differences handled automatically

The following settings are automatically adjusted based on your platform:

- **Homebrew path**: `/opt/homebrew` (Apple Silicon), `/usr/local` (Intel Mac), `/home/linuxbrew/.linuxbrew` (Linux)
- **pnpm home**: `~/Library/pnpm` (macOS), `~/.local/share/pnpm` (Linux)
- **Browser command**: `open` (macOS), `wslview` (WSL2), `xdg-open` (Linux)
- **ls color flags**: `-G` (macOS/BSD), `--color=auto` (Linux/GNU)
- **macOS-specific settings**: Rails fork safety, Cloudflare WARP certificates (macOS only)

### Verification

After applying dotfiles, verify the setup:

```bash
# Check shell loads without errors
zsh -l -c 'echo "Shell loads: $SHELL"'

# Check installed tools
which brew fzf starship mise

# Check environment variables
echo $PNPM_HOME
echo $BROWSER

# Check aliases
ll
la
```
