#!/usr/bin/env bash
set -euo pipefail
FILE="/root/legion/legion/app/importers/NmapImporter.py"
[[ -f "$FILE" ]] || { echo "[!] $FILE fehlt"; exit 1; }
cp -a "$FILE" "${FILE}.bak.$(date +%F_%H%M%S)"
python3 - <<'PY'
import re, pathlib, sys
p = pathlib.Path("/root/legion/legion/app/importers/NmapImporter.py")
s = p.read_text(encoding="utf-8")
pat = re.compile(r'^([ \t]*)db_script\s*\.\s*output\s*=\s*(?:getattr\(\s*scr\s*,\s*["\']output["\']\s*,\s*["\']["\']\s*\)|scr\s*\.\s*output)\s*$', re.M)
def repl(m):
    ind = m.group(1)
    return f'{ind}try:\n{ind}    db_script.output = getattr(scr, \"output\", \"\")\n{ind}except AttributeError:\n{ind}    continue'
s2, n = pat.subn(repl, s)
if n == 0:
    print('Pattern nicht gefunden – bitte manuell pruefen.')
    sys.exit(2)
p.write_text(s2, encoding='utf-8')
print(f'OK: Patch an {n} Stelle(n).')
PY
