#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
if [[ -e android/key.properties || -e android/signing/quran-kareem-release.p12 ]]; then
  echo 'Existing signing material found. Reuse it; do not replace an update key.' >&2
  exit 1
fi
umask 077
mkdir -p android/signing
export QURAN_SIGN_PASS
QURAN_SIGN_PASS="$(python3 -c 'import secrets; print(secrets.token_hex(24))')"
keytool -genkeypair -noprompt -storetype PKCS12 \
  -keystore android/signing/quran-kareem-release.p12 \
  -alias quran-kareem -keyalg RSA -keysize 3072 -validity 10000 \
  -storepass:env QURAN_SIGN_PASS -keypass:env QURAN_SIGN_PASS \
  -dname 'CN=Quran Kareem, OU=Android, O=Quran Kareem, C=EG'
python3 - <<'PY'
import os
from pathlib import Path
password = os.environ['QURAN_SIGN_PASS']
Path('android/key.properties').write_text(
    f'storePassword={password}\nkeyPassword={password}\n'
    'keyAlias=quran-kareem\nstoreFile=signing/quran-kareem-release.p12\n'
)
PY
unset QURAN_SIGN_PASS
echo 'Private release key created. Back up android/key.properties and android/signing together.'
