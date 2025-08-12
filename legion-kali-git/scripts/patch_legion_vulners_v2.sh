#!/usr/bin/env bash
set -euo pipefail
FILE="/root/legion/legion/parsers/Script.py"
[[ -f "$FILE" ]] || { echo "[!] $FILE fehlt"; exit 1; }
cp -a "$FILE" "${FILE}.bak.$(date +%F_%H%M%S)"
python3 - <<'PY'
import re, pathlib
p = pathlib.Path("/root/legion/legion/parsers/Script.py")
s = p.read_text(encoding="utf-8")
s_new = re.sub(
    r"resultCpeDetails\['version'\]\s*=\s*resultCpeData\[4\]",
    "resultCpeDetails['version'] = (resultCpeData[4] if len(resultCpeData) > 4 and resultCpeData[4] not in ('*','-') else '')",
    s
)
if s_new == s:
    print('Pattern nicht gefunden – bitte Stelle pruefen.')
else:
    p.write_text(s_new, encoding="utf-8")
    print('OK: Patch angewendet.')
PY
