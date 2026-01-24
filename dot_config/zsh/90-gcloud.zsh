# Google Cloud SDK (gcloud)
# Installed under ~/google-cloud-sdk by the official installer

GCLOUD_SDK_DIR="$HOME/google-cloud-sdk"

# PATH
if [[ -f "${GCLOUD_SDK_DIR}/path.zsh.inc" ]]; then
  source "${GCLOUD_SDK_DIR}/path.zsh.inc"
fi

# Completion (interactive only)
if [[ -o interactive ]] && [[ -f "${GCLOUD_SDK_DIR}/completion.zsh.inc" ]]; then
  source "${GCLOUD_SDK_DIR}/completion.zsh.inc"
fi
