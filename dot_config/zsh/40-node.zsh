# Node.js / pnpm
export PNPM_HOME="$HOME/Library/pnpm"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Cloudflare WARP の証明書を Node.js アプリケーションが使用するための設定
export NODE_EXTRA_CA_CERTS="$HOME/cloudflare.pem"
