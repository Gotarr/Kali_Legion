#!/usr/bin/env bash
set -euo pipefail
LEGION_ROOT="${LEGION_ROOT:-/root/legion}"
SCRIPT_PY="${LEGION_ROOT}/legion/parsers/Script.py"
IMPORTER_PY="${LEGION_ROOT}/legion/app/importers/NmapImporter.py"

backup() {
  local f="$1"
  if [[ -f "$f" ]]; then
    local ts; ts="$(date +%F_%H%M%S)"
    cp -a "$f" "${f}.bak.${ts}"
    echo "[*] Backup erstellt: ${f}.bak.${ts}"
  else
    echo "[!] Datei nicht gefunden: $f"
  fi
}

echo "==> Patch 1/2: FULL-ROBUST CPE-Parsing in: $SCRIPT_PY"
if [[ -f "$SCRIPT_PY" ]]; then
  backup "$SCRIPT_PY"
  python3 - <<'PY'
import re, pathlib
p = pathlib.Path("{SCRIPT_PY}")
s = p.read_text(encoding="utf-8")

# Helper einfuegen
if "_parse_cpe(" not in s:
    m = re.search(r'(\n(?:from|import)[^\n]*\n(?:[^\n]*\n)*)', s, re.M)
    insert = '\ndef _parse_cpe(cpe_str: str):\n    """\n    Unterstuetzt CPE 2.2 (cpe:/a:vendor:product:version) und CPE 2.3 (cpe:2.3:a:vendor:product:version:...).\n    Gibt dict mit vendor, product, version zurueck (leere Strings, wenn nicht vorhanden).\n    """\n    vendor = product = version = ""\n    if not cpe_str:\n        return {"vendor": vendor, "product": product, "version": version}\n    parts = cpe_str.split(":")\n    try:\n        if cpe_str.startswith("cpe:2.3:"):\n            vendor = parts[3] if len(parts) > 3 else ""\n            product = parts[4] if len(parts) > 4 else ""\n            raw_ver = parts[5] if len(parts) > 5 else ""\n            version = "" if raw_ver in ("*", "-") else raw_ver\n        elif cpe_str.startswith("cpe:/"):\n            vendor = parts[2] if len(parts) > 2 else ""\n            product = parts[3] if len(parts) > 3 else ""\n            version = parts[4] if len(parts) > 4 else ""\n        else:\n            if len(parts) >= 3:\n                vendor = parts[-3]\n                product = parts[-2]\n                version = parts[-1]\n    except Exception:\n        pass\n    return {"vendor": vendor, "product": product, "version": version}\n'
    if m:
        s = s[:m.end()] + insert + s[m.end():]
    else:
        s = insert + s

# Robuste Belegung von vendor/product/version
if "parsed = _parse_cpe(resultCpe)" not in s:
    pattern = re.compile(r'^([ \t]*)resultCpeDetails\[\s*[\'"]version[\'"]\s*\]\s*=\s*resultCpeData\[4\]\s*$', re.M)
    def repl(m):
        ind = m.group(1)
        return (f"{ind}parsed = _parse_cpe(resultCpe)\n"
                f"{ind}resultCpeDetails['vendor']  = parsed.get('vendor', '')\n"
                f"{ind}resultCpeDetails['product'] = parsed.get('product', '')\n"
                f"{ind}resultCpeDetails['version'] = parsed.get('version', '')")
    s, n = pattern.subn(repl, s)

p.write_text(s, encoding="utf-8")
print("[+] Script.py FULL-ROBUST fertig.")
PY
else
  echo "[!] Uebersprungen – Datei fehlt."
fi

echo
echo "==> Patch 2/2: Guard-Zuweisung in: $IMPORTER_PY"
if [[ -f "$IMPORTER_PY" ]]; then
  backup "$IMPORTER_PY"
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
else
  echo "[!] Uebersprungen – Datei fehlt."
fi

echo
echo "[OK] Full-robust Patch fertig."
