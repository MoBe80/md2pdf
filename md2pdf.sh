#!/bin/bash

################################################################################
# md2pdf.sh - Markdown zu PDF Converter
#
# Konvertiert Markdown-Dateien zu PDFs mit Pandoc und WeasyPrint.
# 
# Verwendung:
#   ./md2pdf.sh <markdown-file> [-s stylesheet-name]
#
# Parameter:
#   <markdown-file>    Pfad zur Markdown-Datei (erforderlich)
#   -s <name>          Optional: Stylesheet-Name (ohne .css)
#                      Standard: style.css
#                      Beispiel: -s myStyle → verwendet ~/.pandoc/myStyle.css
#
# Features:
#   - Automatische Datums-Präfix-Verwaltung (YYYYMMDD)
#   - Ersetzt bestehendes Datum oder fügt neues hinzu
#   - Prüft Abhängigkeiten (pandoc, weasyprint)
#   - Bietet interaktive Installation via Homebrew
#   - Output-Datei liegt im selben Verzeichnis wie Input-Datei
#
# Beispiel:
#   ./md2pdf.sh Docs/Dokument.md
#   → Erstellt: Docs/20251128_Dokument.pdf
#
#   ./md2pdf.sh Docs/20251015_Dokument.md -s myStyle
#   → Erstellt: Docs/20251128_Dokument.pdf (Datum aktualisiert)
################################################################################

set -euo pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktion: Fehler ausgeben und beenden
error_exit() {
    echo -e "${RED}Fehler:${NC} $1" >&2
    exit 1
}

# Funktion: Info ausgeben
info() {
    echo -e "${GREEN}Info:${NC} $1"
}

# Funktion: Warnung ausgeben
warn() {
    echo -e "${YELLOW}Warnung:${NC} $1"
}

# Funktion: Prüft ob ein Kommando verfügbar ist
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Funktion: Installiert Abhängigkeit via Homebrew
install_dependency() {
    local dep=$1
    local brew_package=$2
    
    warn "$dep ist nicht installiert."
    read -p "Möchten Sie $dep via Homebrew installieren? (j/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[JjYy]$ ]]; then
        info "Installiere $dep via Homebrew..."
        if ! command_exists brew; then
            error_exit "Homebrew ist nicht installiert. Bitte installieren Sie Homebrew zuerst: https://brew.sh"
        fi
        if brew install "$brew_package"; then
            info "$dep wurde erfolgreich installiert."
        else
            error_exit "Installation von $dep fehlgeschlagen."
        fi
    else
        error_exit "$dep ist erforderlich, um fortzufahren."
    fi
}

# Funktion: Prüft und installiert Abhängigkeiten
check_dependencies() {
    if ! command_exists pandoc; then
        install_dependency "pandoc" "pandoc"
    fi
    
    if ! command_exists weasyprint; then
        install_dependency "weasyprint" "weasyprint"
    fi
}

# Funktion: Extrahiert Dateiname ohne Pfad und Extension
get_basename() {
    local filepath=$1
    basename "$filepath" .md
}

# Funktion: Extrahiert Verzeichnis aus Dateipfad
get_directory() {
    local filepath=$1
    dirname "$filepath"
}

# Funktion: Entfernt Datums-Präfix aus Dateinamen (falls vorhanden)
remove_date_prefix() {
    local filename=$1
    # Entfernt YYYYMMDD_ am Anfang des Dateinamens
    echo "$filename" | sed -E 's/^[0-9]{8}_//'
}

# Funktion: Erstellt Output-Dateinamen mit aktuellem Datum
create_output_filename() {
    local input_file=$1
    local dir=$(get_directory "$input_file")
    local basename=$(get_basename "$input_file")
    local basename_no_date=$(remove_date_prefix "$basename")
    local current_date=$(date +%Y%m%d)
    
    echo "${dir}/${current_date}_${basename_no_date}.pdf"
}

# Funktion: Prüft ob Stylesheet existiert
check_stylesheet() {
    local stylesheet_path=$1
    if [[ ! -f "$stylesheet_path" ]]; then
        error_exit "Stylesheet nicht gefunden: $stylesheet_path"
    fi
}

# Hauptlogik
main() {
    local markdown_file=""
    local stylesheet_name="style"
    
    # Parameter parsen
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--stylesheet)
                if [[ -z "${2:-}" ]]; then
                    error_exit "Option -s erfordert einen Stylesheet-Namen."
                fi
                stylesheet_name="$2"
                shift 2
                ;;
            -*)
                error_exit "Unbekannte Option: $1"
                ;;
            *)
                if [[ -z "$markdown_file" ]]; then
                    markdown_file="$1"
                else
                    error_exit "Zu viele Parameter. Bitte geben Sie nur eine Markdown-Datei an."
                fi
                shift
                ;;
        esac
    done
    
    # Prüfe ob Markdown-Datei angegeben wurde
    if [[ -z "$markdown_file" ]]; then
        error_exit "Keine Markdown-Datei angegeben. Verwendung: $0 <markdown-file> [-s stylesheet-name]"
    fi
    
    # Prüfe ob Markdown-Datei existiert
    if [[ ! -f "$markdown_file" ]]; then
        error_exit "Markdown-Datei nicht gefunden: $markdown_file"
    fi
    
    # Prüfe ob Datei eine .md Extension hat
    if [[ ! "$markdown_file" =~ \.(md|markdown)$ ]]; then
        warn "Datei hat keine .md oder .markdown Extension. Konvertiere trotzdem..."
    fi
    
    # Prüfe Abhängigkeiten
    check_dependencies
    
    # Erstelle Stylesheet-Pfad
    local stylesheet_path="$HOME/.pandoc/${stylesheet_name}.css"
    
    # Prüfe ob Stylesheet existiert
    check_stylesheet "$stylesheet_path"
    
    # Erstelle Output-Dateinamen
    local output_file=$(create_output_filename "$markdown_file")
    
    info "Konvertiere: $markdown_file"
    info "→ Output: $output_file"
    info "→ Stylesheet: $stylesheet_path"
    
    # Konvertiere mit Pandoc
    if pandoc "$markdown_file" -o "$output_file" \
        --pdf-engine=weasyprint \
        --css="$stylesheet_path"; then
        info "PDF erfolgreich erstellt: $output_file"
    else
        error_exit "PDF-Konvertierung fehlgeschlagen."
    fi
}

# Script ausführen
main "$@"

