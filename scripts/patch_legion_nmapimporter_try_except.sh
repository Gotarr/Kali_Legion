#!/usr/bin/env bash
set -euo pipefail

FILE="/opt/legion/app/importers/NmapImporter.py"

echo "[*] Prüfe Datei: $FILE"
[[ -f "$FILE" ]] || { echo "[!] Datei nicht gefunden: $FILE"; exit 1; }

TS="$(date +%F_%H%M%S)"
BAK="${FILE}.bak.${TS}"
echo "[*] Erstelle Backup: $BAK"
cp -a "$FILE" "$BAK"

echo "[*] Patche defensive Zuweisung für db_script.output mittels Python-Regex ..."
python3 - <<'PY'
import re, pathlib, sys
p = pathlib.Path("/opt/legion/app/importers/NmapImporter.py")
s = p.read_text(encoding="utf-8")

# Erfasst:
#   db_script.output = scr.output
#   db_script.output = getattr(scr, "output", "")
pat = re.compile(
    r'^([ \t]*)db_script\s*\.\s*output\s*=\s*'
    r'(?:getattr\(\s*scr\s*,\s*["\']output["\']\s*,\s*["\']["\']\s*\)|scr\s*\.\s*output)\s*$',
    re.M
)

def repl(m):
    indent = m.group(1)
    return (
        f'{indent}try:\n'
        f'{indent}    db_script.output = getattr(scr, "output", "")\n'
        f'{indent}except AttributeError:\n'
        f'{indent}    continue'
    )

new_s, n = pat.subn(repl, s)
if n == 0:
    print("NO_CHANGE")
    sys.exit(2)

p.write_text(new_s, encoding="utf-8")
print(f"PATCHED {n} place(s)")
PY

rc=$?
if [[ $rc -eq 2 ]]; then
  echo "[!] Pattern nicht gefunden – keine Änderung durchgeführt."
  echo "    Zeige Kontextzeilen:"
  nl -ba "$FILE" | sed -n '1,200p' | grep -n "db_script\.output" || true
  echo "    Backup bleibt bestehen: $BAK"
  exit 2
fi

echo "[+] Patch angewendet."
echo "[*] Geänderte Umgebung (±3 Zeilen):"
nl -ba "$FILE" | awk '
  /db_script\.output/ { for(i=NR-3;i<=NR+3;i++) if (i>0) lines[i]=1 }
  { buf[NR]=$0 }
  END { for(i in lines) print buf[i] }
' | sort -n

echo
echo "[i] Rollback bei Bedarf:"
echo "    cp -a \"$BAK\" \"$FILE\""


