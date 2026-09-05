# libpq（PostgreSQL クライアント: psql / pg_dump / pg_restore 等）は keg-only なので
# PATH に手動追加する。DB サーバ本体は Docker/colima 側で動かすため libpq のみ。
# ディレクトリが存在する時だけ（WSL/Linux では no-op）。
if [ -d "/opt/homebrew/opt/libpq/bin" ]; then
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
fi
