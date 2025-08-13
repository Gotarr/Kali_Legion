#!/usr/bin/env bash
set -euo pipefail

FILE="/opt/legion/legion/parsers/Script.py"

echo "[*] Prüfe Datei: $FILE"
if [[ ! -f "$FILE" ]]; then
  echo "[!] Datei nicht gefunden: $FILE"
  exit 1
fi

TS="$(date +%F_%H%M%S)"
BAK="${FILE}.bak.${TS}"
echo "[*] Erstelle Backup: $BAK"
cp -a "$FILE" "$BAK"

# Temp-Kopie zum späteren Vergleich
TMP_BEFORE="$(mktemp)"
cp -a "$FILE" "$TMP_BEFORE"

echo "[*] Patche Zeile mit unsicherem Indexzugriff..."
# Ersetzt: resultCpeDetails['version'] = resultCpeData[4]
# Durch:   resultCpeDetails['version'] = (resultCpeData[4] if len(resultCpeData) > 4 and resultCpeData[4] not in ("*", "-") else "")
perl -0777 -pe 's/resultCpeDetails\[\x27version\x27\]\s*=\s*resultCpeData\[4\]/resultCpeDetails[\x27version\x27] = (resultCpeData[4] if len(resultCpeData) > 4 and resultCpeData[4] not in ("*", "-") else "")/g' -i "$FILE"

if cmp -s "$FILE" "$TMP_BEFORE"; then
  echo "[!] Pattern nicht gefunden – keine Änderung durchgeführt."
  echo "    Bitte prüfe manuell die betroffene Stelle in: $FILE"
  echo "    Backup bleibt bestehen: $BAK"
  exit 2
fi

echo "[+] Patch angewendet."
echo "[*] Geänderte Zeile(n):"
grep -n "resultCpeDetails\['version'\]" "$FILE" || true

echo
echo "[i] Falls etwas schiefgeht, kannst du zurückrollen mit:"
echo "    cp -a \"$BAK\" \"$FILE\""


