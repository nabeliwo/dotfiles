# OpenSSL 3 のプロバイダモジュール置き場（Homebrew openssl@3）を明示する。
# mise でビルドした Ruby が OpenSSL::Provider.load("legacy") 等を使う際、
# 既定の MODULESDIR を見つけられず失敗することがあるため。
# ディレクトリが存在する時だけ設定（WSL/Linux では no-op）。
if [ -d "/opt/homebrew/lib/ossl-modules" ]; then
  export OPENSSL_MODULES="/opt/homebrew/lib/ossl-modules"
fi
