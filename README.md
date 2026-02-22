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
