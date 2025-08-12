#!/usr/bin/env bash
set -euo pipefail

FILE="/root/legion/legion/app/importers/NmapImporter.py"

echo "[*] Prüfe Datei: $FILE"
[[ -f "$FILE" ]] || { echo "[!] Datei nicht gefunden: $FILE"; exit 1; }

TS="$(date +%F_%H%M%S)"
BAK="${FILE}.bak.${TS}"
echo "[*] Erstelle Backup: $BAK"
cp -a "$FILE" "$BAK"

TMP_BEFORE="$(mktemp)"
cp -a "$FILE" "$TMP_BEFORE"

echo "[*] Patche defensive Zuweisung für scr.output ..."
# Ersetzt jede direkte Zuweisung an scr.output durch getattr(..., '', '')
perl -0777 -pe 's/(\bdb_script\s*\.\s*output\s*=\s*)scr\s*\.\s*output\b/\1getattr(scr, "output", "")/g' -i "$FILE"

if cmp -s "$FILE" "$TMP_BEFORE"; then
  echo "[!] Pattern nicht gefunden – keine Änderung durchgeführt."
  echo "    Bitte prüfe die betroffene Stelle in: $FILE"
  echo "    Backup bleibt bestehen: $BAK"
  exit 2
fi

echo "[+] Patch angewendet."
echo "[*] Geänderte Zeile(n) rund um db_script.output:"
nl -ba "$FILE" | grep -n "db_script\.output" || true

echo
echo "[i] Rollback bei Bedarf:"
echo "    cp -a \"$BAK\" \"$FILE\""

