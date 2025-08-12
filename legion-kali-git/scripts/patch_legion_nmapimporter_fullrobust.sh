#!/usr/bin/env bash
set -euo pipefail
LEGION_ROOT="${LEGION_ROOT:-/root/legion}"
IMPORTER_PY="${LEGION_ROOT}/legion/app/importers/NmapImporter.py"

if [[ ! -f "$IMPORTER_PY" ]]; then
  echo "[!] Datei fehlt: $IMPORTER_PY"; exit 1
fi
cp -a "$IMPORTER_PY" "${IMPORTER_PY}.bak.$(date +%F_%H%M%S)"

python3 - <<'PY'
import re, pathlib
p = pathlib.Path("{IMPORTER_PY}")
s = p.read_text(encoding="utf-8")

if "if db_script is not None and scr is not None:" not in s:
    pat = re.compile(r'^([ \t]*)db_script\s*\.\s*output\s*=\s*(?:getattr\(\s*scr\s*,\s*[\"\']output[\"\']\s*,\s*[\"\'][\"\']\s*\)|scr\s*\.\s*output)\s*$', re.M)
    def repl(m):
        ind = m.group(1)
        return f"{ind}if db_script is not None and scr is not None:\n{ind}    db_script.output = getattr(scr, \"output\", \"\")"
    s2, n = pat.subn(repl, s)
    if n > 0:
        s = s2

p.write_text(s, encoding="utf-8")
print("[+] NmapImporter.py Guard fertig.")
PY
