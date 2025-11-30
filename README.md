Markdown zu PDF Converter

Konvertiert Markdown-Dateien zu PDFs mit Pandoc und WeasyPrint.

Verwendung:
  ./md2pdf.sh <markdown-file> [-s stylesheet-name]

Parameter:
  <markdown-file>    Pfad zur Markdown-Datei (erforderlich)
  -s <name>          Optional: Stylesheet-Name (ohne .css)
                     Standard: verwendet DEFAULT_CSS Variable
                     Beispiel: -s myStyle → verwendet ~/.pandoc/myStyle.css

Features:
  - Automatische Datums-Präfix-Verwaltung (YYYYMMDD)
  - Ersetzt bestehendes Datum oder fügt neues hinzu
  - Prüft Abhängigkeiten (pandoc, weasyprint)
  - Bietet interaktive Installation via Homebrew
  - Output-Datei liegt im selben Verzeichnis wie Input-Datei

Beispiel:
  ./md2pdf.sh Docs/Dokument.md
  → Erstellt: Docs/20251128_Dokument.pdf

  ./md2pdf.sh Docs/20251015_Dokument.md -s myStyle
  → Erstellt: Docs/20251128_Dokument.pdf (Datum aktualisiert)