# Google Cloud SDK (gcloud)
# インストール場所の両対応:
#   - 公式インストーラ: ~/google-cloud-sdk
#   - Homebrew cask (gcloud-cli): /opt/homebrew/share/google-cloud-sdk
# 最初に見つかった方を読み込む。
for GCLOUD_SDK_DIR in "$HOME/google-cloud-sdk" "/opt/homebrew/share/google-cloud-sdk"; do
  if [[ -f "${GCLOUD_SDK_DIR}/path.zsh.inc" ]]; then
    source "${GCLOUD_SDK_DIR}/path.zsh.inc"
    if [[ -o interactive ]] && [[ -f "${GCLOUD_SDK_DIR}/completion.zsh.inc" ]]; then
      source "${GCLOUD_SDK_DIR}/completion.zsh.inc"
    fi
    break
  fi
done
unset GCLOUD_SDK_DIR
