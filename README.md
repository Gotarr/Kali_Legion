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

## Schnellstart (als Git-Repo initialisieren)
Variante A – mit Script:
```bash
cd legion-kali-git
bash init_repo.sh
# optional gleich auf ein Remote pushen:
bash init_repo.sh https://github.com/<ORG>/<REPO>.git
```

Variante B – manuell:
```bash
git init
git add .
git commit -m "Initial commit: Legion Kali Docs & Patches"
git branch -M main
git remote add origin <REMOTE_URL>
git push -u origin main
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
