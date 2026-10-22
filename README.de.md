<div align="center">

<img src="assets/AppIcon.png" width="128" alt="GlanceMD-Symbol">

# GlanceMD

**Markdown auf dem Mac, auf einen Blick.**

Eine `.md`-Datei im Finder auswählen, <kbd>Leertaste</kbd> drücken und gerendert lesen: Tabellen, Mermaid-Diagramme, Formeln, Code mit Syntaxhervorhebung, Fußnoten, Aufgabenlisten und die Bilder, die neben der Datei liegen.

![Finder, Leertaste, rohes Markdown wird zu einer gerenderten Seite in GlanceMD](docs/hero.gif)

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [Español](README.es.md) · [Português (BR)](README.pt-BR.md) · **Deutsch** · [Français](README.fr.md)

[![Neueste Version](https://img.shields.io/github/v/release/gksdud6330/glance-md?style=flat-square&labelColor=1d1d1f&color=636366)](https://github.com/gksdud6330/glance-md/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-636366?style=flat-square&labelColor=1d1d1f)](#installation)
[![Universal Binary](https://img.shields.io/badge/Apple%20silicon%20%26%20Intel-universal-636366?style=flat-square&labelColor=1d1d1f)](#installation)
[![MIT-Lizenz](https://img.shields.io/badge/license-MIT-636366?style=flat-square&labelColor=1d1d1f)](LICENSE)

[![GlanceMD für macOS herunterladen](https://img.shields.io/badge/Download-GlanceMD%20for%20macOS-1d1d1f?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/gksdud6330/glance-md/releases/latest)

Kostenlos und Open Source · funktioniert offline · macOS 13 oder neuer

</div>

## Vorher und nachher

Dieselbe Datei, dieselbe Leertaste. Links die Nur-Text-Vorschau, die macOS mitbringt. Rechts GlanceMD.

![Links Quick Look als Nur-Text, rechts dieselbe Datei von GlanceMD gerendert](docs/before-after.png)

## Was du bekommst

- **Ein Quick Look, das Markdown versteht.** Datei auswählen, Leertaste drücken, lesen. Lokale Bilder neben der Datei werden ebenfalls angezeigt. Ein Doppelklick auf ein Wort in der Vorschau markiert es, <kbd>⌘</kbd><kbd>C</kbd> kopiert es; die Datei wird dabei nicht geöffnet.
- **Korrektes Rendering.** CommonMark + GitHub Flavored Markdown über [markdown-it](https://github.com/markdown-it/markdown-it): verschachtelte Listen, ausgerichtete Tabellen mit leeren Zellen und maskierten Pipes, Fußnoten, Aufgabenlisten, Setext-Überschriften, `<details>`.
- **Diagramme und Formeln.** ` ```mermaid `-Blöcke werden zu Diagrammen; `$…$`, `$$…$$` und ` ```math ` rendert KaTeX.
- **Ein Viewer, wenn du einen brauchst.** Öffne eine `.md`-Datei mit GlanceMD (oder mach GlanceMD zur Standard-App für Markdown, dann reicht ein Doppelklick), und du siehst dasselbe Rendering in einem kleinen Fenster mit Tabs. Es rendert neu, sobald sich die Datei ändert (auch bei atomarem Speichern aus Editoren), und behält die Scrollposition.
- **Einstellungen.** Öffne GlanceMD (oder drücke <kbd>⌘</kbd><kbd>,</kbd>), um die Quick-Look-Vorschau ein- oder auszuschalten und markierten Text automatisch in die Zwischenablage zu kopieren (standardmäßig aus).
- **Fühlt sich nativ an.** Heller und dunkler Modus, Zoom (<kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>-</kbd> / Pinch), Kopieren, Links öffnen sich im Browser.
- **Sicher auch bei fremden Dateien.** Siehe [Sicherheit](#sicherheit).
- **Offline.** Alle Bibliotheken sind gebündelt. Nichts wird von einem CDN geladen.
- **Klein.** Ein paar hundert Zeilen Swift um eine WKWebView. Universal Binary (Apple Silicon + Intel), macOS 13 oder neuer.

<details>
<summary>Screenshots: das Viewer-Fenster und das Quick-Look-Panel</summary>

![GlanceMD-Viewer-Fenster](docs/app.png)

![Quick-Look-Vorschau derselben Datei](docs/quicklook.png)

</details>

## Installation

### Download

1. `GlanceMD-<version>.zip` unter [Releases](https://github.com/gksdud6330/glance-md/releases) herunterladen, entpacken und `GlanceMD.app` nach `/Applications` verschieben.
2. GlanceMD ist nicht notarisiert (ad hoc signiert, ohne kostenpflichtige Apple Developer ID), deshalb blockiert macOS den ersten Start. Einmal öffnen, die Warnung schließen, dann unter **Systemeinstellungen → Datenschutz & Sicherheit** auf **Trotzdem öffnen** klicken. Alternativ:
   ```bash
   xattr -dr com.apple.quarantine /Applications/GlanceMD.app
   ```
3. GlanceMD einmal starten, damit macOS die Quick-Look-Erweiterung registriert. Dann eine `.md`-Datei im Finder auswählen und die Leertaste drücken.

Zeigt die Leertaste weiterhin nur Text, `qlmanage -r` ausführen und prüfen, ob **GlanceMD Quick Look** unter **Systemeinstellungen → Allgemein → Anmeldeobjekte & Erweiterungen → Quick Look** aktiviert ist.

### Aus dem Quellcode bauen

Benötigt Xcode oder die Xcode Command Line Tools.

```bash
git clone https://github.com/gksdud6330/glance-md.git
cd glance-md
./install.sh        # baut build/GlanceMD.app und installiert es nach /Applications
```

`./build.sh` allein baut, ohne zu installieren.

### Als Standard-App für Markdown festlegen (optional)

Im Finder bei einer beliebigen `.md`-Datei **Informationen** → **Öffnen mit: GlanceMD** → **Alle ändern …**

## Sicherheit

Eine Markdown-Datei kann rohes HTML enthalten; ein Vorschauprogramm, das sie naiv rendert, führt also auch jedes Skript aus, das die Datei mitbringt. GlanceMD behandelt jedes Dokument als nicht vertrauenswürdig:

- Gerendertes HTML läuft durch [DOMPurify](https://github.com/cure53/DOMPurify): `<script>`, `on*`-Handler, `javascript:`-URLs, `<iframe>`, `<form>` und `<style>` werden entfernt.
- Die Seite läuft unter einer Content Security Policy, die nur die gebündelten Skripte erlaubt; selbst durchgerutschtes Markup kann nichts ausführen.
- Mermaid läuft mit `securityLevel: 'strict'`, KaTeX mit `trust: false`, sodass `\href{javascript:…}` nicht zu einem Link wird.
- Ein Klick auf einen Link zu einer lokalen Datei startet sie nie. `.md`-Links öffnen sich in GlanceMD, alles andere wird nur im Finder angezeigt.
- Die Quick-Look-Erweiterung läuft in einer Sandbox mit reinem Lesezugriff auf Dateien, den sie braucht, um Bilder neben dem Dokument anzuzeigen.

[`samples/stress-test.md`](samples/stress-test.md) prüft all das. Mit GlanceMD öffnen: Jede Zeile im letzten Abschnitt sollte `[안전]` („sicher" auf Koreanisch) anzeigen.

## So funktioniert es

```
src/app/          die Viewer-App (Fenster, Tabs, Live-Reload, Menüs)
src/quicklook/    die Quick-Look-Vorschauerweiterung (Sandbox)
src/shared/       MarkdownPage: lädt die Renderer-Seite und rendert eine Datei hinein
web/              die Renderer-Seite: markdown-it → DOMPurify → Mermaid/KaTeX/highlight.js
samples/          eine Funktionsdemo und ein Rendering-/Sicherheits-Stresstest
```

App und Erweiterung rendern über dieselbe `web/`-Seite, deshalb sehen eine Quick-Look-Vorschau und ein Viewer-Fenster immer identisch aus. Mermaid (etwa 5 MB) wird nur geladen, wenn ein Dokument ein Diagramm enthält.

## Einschränkungen

- Nicht notarisiert; siehe die Installationsschritte oben.
- Ein reiner Viewer: kein Bearbeiten, kein PDF-Export.
- Die erste Vorschau nach dem Anmelden kann ein, zwei Sekunden dauern, während WebKit startet.
- Getestet unter macOS 26 auf Apple Silicon.

## Danksagung

GlanceMD ist eine dünne Hülle um hervorragende Open-Source-Projekte: [markdown-it](https://github.com/markdown-it/markdown-it) mit den Plugins [footnote](https://github.com/markdown-it/markdown-it-footnote), [task list](https://github.com/revin/markdown-it-task-lists) und [texmath](https://github.com/goessner/markdown-it-texmath), [KaTeX](https://katex.org), [Mermaid](https://mermaid.js.org), [highlight.js](https://highlightjs.org) und [DOMPurify](https://github.com/cure53/DOMPurify). Ihre Lizenzen stehen in [`web/vendor/THIRD_PARTY_LICENSES.md`](web/vendor/THIRD_PARTY_LICENSES.md).

## Lizenz

[MIT](LICENSE)
