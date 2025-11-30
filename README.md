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

## Cursor/VS Code Integration

### Keyboard Shortcut einrichten

1. Öffne die Command Palette: `Cmd+Shift+P` (macOS) oder `Ctrl+Shift+P` (Windows/Linux)
2. Wähle "Preferences: Open Keyboard Shortcuts (JSON)"
3. Füge folgenden Eintrag hinzu:

```json
{
  "key": "cmd+shift+m",
  "command": "workbench.action.terminal.sendSequence",
  "args": {
      "text": "~/.pandoc/md2pdf.sh \"${file}\"\u000D"
  },
  "when": "editorLangId == markdown && activeEditorGroupEmpty == false"
}
```

**Verwendung:**
- Öffne eine Markdown-Datei in Cursor/VS Code
- Drücke `Cmd+Shift+M`
- Das Terminal-Fenster öffnet sich automatisch und zeigt die Ausgabe der Konvertierung
- Das PDF wird automatisch im selben Verzeichnis wie die Markdown-Datei erstellt