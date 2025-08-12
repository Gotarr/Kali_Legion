# Legion auf Kali Linux – Repo

Dieses Repository enthaelt die Installations- & Betriebsdokumentation fuer **Legion** auf **Kali Linux** (Root + venv), inkl. Einbindung der Passwortliste **rockyou** sowie **Troubleshooting/Parser-Fixes**.

**Stand:** 2025-08-12

## Struktur
```
.
├─ README.md
├─ LICENSE
├─ .gitignore
├─ docs/
│  └─ Legion_Kali_Dokumentation.pdf
└─ scripts/
   ├─ legion-venv
   ├─ patch_legion_vulners_v2.sh
   └─ patch_legion_nmapimporter_try_except_v2.sh
```

## Inhalte
- **docs/Legion_Kali_Dokumentation.pdf** – Leitfaden (Deckblatt + Inhaltsverzeichnis), inkl.:
  - Installation (Root + venv)
  - Start/Komfortstarter
  - rockyou-Einbindung (Hydra & Nmap-NSE)
  - stabile Nmap-Templates
  - Troubleshooting & Patches (vulners/CPE, NmapImporter)
- **scripts/** – Hilfsskripte:
  - `legion-venv`: Komfortstarter fuer Legion
  - `patch_legion_all.sh`: Kombiniert beide Patches (vulners + NmapImporter) in EINEM Lauf
  - (optional) Einzelpatches: `patch_legion_vulners_v2.sh`, `patch_legion_nmapimporter_try_except_v2.sh`

## Hinweis
Bitte nur in autorisierten Umgebungen einsetzen. Root + Netz-Scanning erfordern besondere Sorgfalt.

## Konfiguration
Optionale Pfad-Variable:
```bash
export LEGION_ROOT=/opt/legion
```

### Scripts
- `scripts/patch_legion_all.sh` – FULL-ROBUST (empfohlen)
- `scripts/patch_legion_vulners_fullrobust.sh` – nur CPE-Parser robust
- `scripts/patch_legion_nmapimporter_fullrobust.sh` – nur Guard-Zuweisung
