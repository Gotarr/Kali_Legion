#!/usr/bin/env bash
set -euo pipefail

# Initialisiert ein Git-Repo, macht den ersten Commit und pusht optional zu 'origin'.
# Nutzung:
#   bash init_repo.sh
#   bash init_repo.sh https://github.com/<ORG>/<REPO>.git

if ! command -v git >/dev/null 2>&1; then
  echo "[!] git ist nicht installiert."
  exit 1
fi

git init
git add .
git commit -m "Initial commit: Legion Kali Docs & Patches" || true
git branch -M main || true

if [[ "${1-}" != "" ]]; then
  git remote remove origin 2>/dev/null || true
  git remote add origin "$1"
  git push -u origin main
else
  echo "[i] Kein Remote angegeben. Du kannst spaeter hinzufügen mit:"
  echo "    git remote add origin <REMOTE_URL>"
  echo "    git push -u origin main"
fi
