# Aliases

# --- ls shortcuts (macOS/BSD-friendly) ---
alias ll='ls -lGh'
alias la='ls -laGh'

# --- git ---
alias g='git'
alias lg='lazygit'

# --- ruby/bundler ---
alias be='bundle exec'

# --- ghq + zoxide + fzf (repo selection) ---
repo() {
  local root repo
  root="$(ghq root)" || return

  repo="$(ghq list | fzf \
    --prompt='ghq> ' \
    --height=40% --reverse \
    --preview="ls -1 '${root}/{}' 2>/dev/null | sed -n '1,200p'")" || return

  cd "${root}/${repo}" || return

  # zoxide に「よく使うrepo」を学習させる
  zoxide add "${root}/${repo}" >/dev/null 2>&1 || true
}
