# Dokumentation: Installation von Legion auf Kali Linux (mit virtueller Umgebung)

## 1. Überblick

Legion ist ein GUI-basiertes Penetration-Testing-Tool, das auf Python3 basiert und zahlreiche Recon- und Exploit-Module integriert.  
Um Systemkonflikte zu vermeiden, wird Legion in dieser Anleitung in einer Python Virtual Environment (venv) betrieben.

## 2. Voraussetzungen

| Komponente         | Anforderung                        |
|--------------------|------------------------------------|
| Betriebssystem     | Kali Linux (Rolling / 2023.x oder neuer empfohlen) |
| Benutzerrechte     | Root- oder sudo-Berechtigung        |
| Internetverbindung | Für Paketinstallation & Git-Clone   |
| Speicherplatz      | ca. 300 MB frei                     |

## 3. Paketabhängigkeiten

Legion benötigt u. a.:

- Python 3.x
- python3-pip
- python3-venv
- git
- Bibliotheken wie python3-pyqt5, python3-sqlalchemy, nmap, hydra, nikto usw.

## 4. Installationsschritte

### 4.1 System aktualisieren

```bash
sudo apt update && sudo apt full-upgrade -y
```

### 4.2 Abhängigkeiten installieren

```bash
sudo apt install -y git python3 python3-pip python3-venv python3-pyqt5 \
    python3-sqlalchemy python3-lxml \
    nmap hydra nikto whatweb \
    seclists dirb
```

### 4.3 Legion herunterladen

```bash
cd /opt
sudo git clone https://github.com/GoVanguard/legion.git
################################## nmap "patch"
cd /opt
sudo git clone https://github.com/Gotarr/Kali_Legion
```

### 4.4 Virtuelle Umgebung erstellen

```bash
cd /opt/legion
python3 -m venv venv
```

### 4.5 Virtuelle Umgebung aktivieren

```bash
source venv/bin/activate
```

💡 Hinweis: Nach Aktivierung zeigt die Shell `(venv)` vor der Eingabezeile an.

### 4.6 Python-Module in venv installieren

```bash
pip install --upgrade pip
pip install -r requirements.txt
# Alles auf ein kompatibles Set bringen
pip install --upgrade pip setuptools wheel
pip install "requests>=2.32.0,<3" "urllib3>=2.2,<3" "idna>=3" "certifi>=2024.2.2" "charset-normalizer>=3"

```

### 4.7 Startskript ausführbar machen

```bash
chmod +x legion.py
```

### 4.8 patchscripte für den nmap import error

```bash
cd /opt
bash Kali_Legion/scripts/patch_legion_nmapimporter_scr_none.sh
bash Kali_Legion/scripts/patch_legion_nmapimporter_try_except.sh
bash Kali_Legion/scripts/patch_legion_vulners.sh
```
## 5. Start von Legion (in venv)

### 5.1 venv aktivieren

```bash
cd /opt/legion
source venv/bin/activate
```

### 5.2 Legion starten

```bash
python3 legion.py
```

⚠ Wichtig: Auch im venv muss `sudo` verwendet werden, da Legion Root-Rechte für Scans benötigt.

## 6. Beenden der virtuellen Umgebung

```bash
deactivate
```

## 7. Optional: Start-Skript für venv

Damit nicht jedes Mal der komplette Befehl getippt werden muss:

```bash
echo -e '#!/bin/bash\ncd /opt/legion\nsource venv/bin/activate\npython3 legion.py' | sudo tee /usr/local/bin/legion-venv
sudo chmod +x /usr/local/bin/legion-venv
```

Start dann mit:

```bash
legion-venv
```

## 8. Sicherheitshinweis

⚠ Legion nur in autorisierten Netzwerken einsetzen – unbefugtes Scannen kann strafbar sein!  
Vor Einsatz in Unternehmensumgebungen schriftliche Genehmigung einholen.

## 9. Referenzen

- Offizielles GitHub-Repo: https://github.com/GoVanguard/legion
- GitHub-Repo: https://github.com/hackman238/legion (neuer, andere Bestimmungen und Install)
- Python Virtual Environment Doku: https://docs.python.org/3/library/venv.html
- Kali Linux Dokumentation: https://www.kali.org/docs/

## 10. Deinstallation

> **Achtung:** Die folgenden Schritte entfernen Legion vollständig aus deinem System.  
> Die optionalen Schritte zum Entfernen von Abhängigkeiten (Tools wie `nmap`, `hydra`, `nikto` usw.) solltest du **nur** nutzen, wenn du sie nicht für andere Zwecke verwendest.

### 10.1 Vorbereitung (Legion beenden / venv deaktivieren)
Falls eine virtuelle Umgebung aktiv ist oder Legion läuft:
```bash
deactivate 2>/dev/null || true
```

### 10.2 Optional: Startskript entfernen
Wenn du das optionale Startskript erstellt hast:
```bash
sudo rm -f /usr/local/bin/legion-venv
```

### 10.3 Legion-Verzeichnis löschen
```bash
sudo rm -rf /opt/legion
```

### 10.4 Optional: Abhängigkeiten entfernen
Nur ausführen, wenn die Pakete **ausschließlich** für Legion installiert wurden:
```bash
sudo apt remove --purge -y \
  python3-pyqt5 python3-sqlalchemy python3-lxml \
  nmap hydra nikto whatweb seclists dirb
```

Anschließend Paketreste und Cache säubern:
```bash
sudo apt autoremove --purge -y
sudo apt clean
```

### 10.5 (Optional) Python-/Pip-Cache aufräumen
```bash
rm -rf ~/.cache/pip
```

### 10.6 Prüfung
Die folgenden Befehle sollten **keine** Treffer mehr liefern:
```bash
which legion-venv || echo "OK: kein Startskript gefunden"
ls -ld /opt/legion || echo "OK: /opt/legion wurde entfernt"
```
