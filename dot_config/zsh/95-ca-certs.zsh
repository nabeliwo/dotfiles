# Cloudflare WARP の Gateway CA を OpenSSL 系ツールに信頼させる。
# ~/cloudflare.pem（machine-local。WARP/キーチェーンから取得）がある時だけ有効化。
# システムCA + Gateway CA を1つに結合したバンドルを作り、標準の CA 環境変数で各ツールへ渡す。
# 対象: Ruby / Python(requests) / curl / AWS CLI / gcloud など OpenSSL 系。
# ※ Node は NODE_EXTRA_CA_CERTS（別ファイル）、docker は colima VM 内で対応済み。
if [ -f "$HOME/cloudflare.pem" ]; then
  _ca_base="/opt/homebrew/etc/ca-certificates/cert.pem"   # Homebrew ca-certificates（Mozilla バンドル）
  _ca_bundle="$HOME/.config/certs/ca-bundle.pem"          # 生成物（machine-local・git 管理外）
  if [ -f "$_ca_base" ]; then
    # ベース or cloudflare.pem が更新されたら結合バンドルを作り直す（brew upgrade 追従）
    if [ ! -f "$_ca_bundle" ] || [ "$_ca_base" -nt "$_ca_bundle" ] || [ "$HOME/cloudflare.pem" -nt "$_ca_bundle" ]; then
      mkdir -p "$(dirname "$_ca_bundle")"
      cat "$_ca_base" "$HOME/cloudflare.pem" > "$_ca_bundle"
    fi
  fi
  if [ -f "$_ca_bundle" ]; then
    export SSL_CERT_FILE="$_ca_bundle"
    export AWS_CA_BUNDLE="$_ca_bundle"
    export REQUESTS_CA_BUNDLE="$_ca_bundle"
    export CLOUDSDK_CORE_CUSTOM_CA_CERTS_FILE="$_ca_bundle"   # gcloud も同じバンドルに寄せる
  fi
  unset _ca_base _ca_bundle
fi
