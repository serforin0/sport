#!/usr/bin/env bash
# E2E HubSport — prioriza celular real conectado
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

API_BASE_URL="${API_BASE_URL:-https://yordy.shop/api/v1}"

echo "==> flutter pub get"
flutter pub get

if [[ -n "${E2E_DEVICE:-}" ]]; then
  DEVICE="$E2E_DEVICE"
else
  DEVICE="$(flutter devices --machine 2>/dev/null | python3 -c '
import json,sys
data=json.load(sys.stdin)
# 1) Android/iOS físico
for d in data:
    t=d.get("targetPlatform") or ""
    if (t.startswith("android") or t.startswith("ios")) and not d.get("emulator", False):
        print(d["id"]); raise SystemExit
# 2) Cualquier móvil
for d in data:
    t=d.get("targetPlatform") or ""
    if t.startswith("android") or t.startswith("ios"):
        print(d["id"]); raise SystemExit
print("macos")
')"
fi

echo "==> E2E device=$DEVICE api=$API_BASE_URL"
flutter test integration_test/hubsport_e2e_suite_test.dart \
  -d "$DEVICE" \
  --dart-define=ENABLE_DEMO_LOGIN=true \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --reporter expanded
