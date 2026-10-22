<div align="center">

<img src="assets/AppIcon.png" width="128" alt="GlanceMD icon">

# GlanceMD

**Markdown on macOS, at a glance.**

Select a `.md` file in Finder, press <kbd>Space</kbd>, and read it rendered: tables, Mermaid diagrams, math, highlighted code, footnotes, task lists and the images next to it.

![Finder, Space, raw Markdown turning into a rendered page in GlanceMD](docs/hero.gif)

**English** · [한국어](README.ko.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [Español](README.es.md) · [Português (BR)](README.pt-BR.md) · [Deutsch](README.de.md) · [Français](README.fr.md)

[![Latest release](https://img.shields.io/github/v/release/gksdud6330/glance-md?style=flat-square&labelColor=1d1d1f&color=636366)](https://github.com/gksdud6330/glance-md/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-636366?style=flat-square&labelColor=1d1d1f)](#install)
[![Universal binary](https://img.shields.io/badge/Apple%20silicon%20%26%20Intel-universal-636366?style=flat-square&labelColor=1d1d1f)](#install)
[![MIT license](https://img.shields.io/badge/license-MIT-636366?style=flat-square&labelColor=1d1d1f)](LICENSE)

[![Download GlanceMD for macOS](https://img.shields.io/badge/Download-GlanceMD%20for%20macOS-1d1d1f?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/gksdud6330/glance-md/releases/latest)

Free and open source · works offline · macOS 13 or later

</div>

## Before and after

Same file, same Space bar. Left: the plain-text preview macOS ships with. Right: GlanceMD.

![Plain-text Quick Look on the left, GlanceMD rendering of the same file on the right](docs/before-after.png)

## What you get

- **Quick Look that understands Markdown.** Select a file, press Space, read. Local images next to the file show up too. Double-click a word in the preview to select it and <kbd>⌘</kbd><kbd>C</kbd> to copy it; it does not open the file.
- **Correct rendering.** CommonMark + GitHub Flavored Markdown via [markdown-it](https://github.com/markdown-it/markdown-it): nested lists, aligned tables with empty cells and escaped pipes, footnotes, task lists, setext headings, `<details>`.
- **Diagrams and math.** ` ```mermaid ` blocks become diagrams; `$…$`, `$$…$$` and ` ```math ` render with KaTeX.
- **A viewer when you need one.** Open a `.md` file with GlanceMD (or make it your default Markdown app, then a double-click does it) to get the same rendering in a small window with tabs. It re-renders when the file changes (atomic saves from editors included) and keeps your scroll position.
- **Settings.** Open GlanceMD (or press <kbd>⌘</kbd><kbd>,</kbd>) to turn the Quick Look preview on or off, and to have selected text copied to the clipboard automatically (off by default).
- **Native feel.** Light and dark mode, zoom (<kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>-</kbd> / pinch), copy, links open in your browser.
- **Safe to open files you didn't write.** See [Security](#security).
- **Offline.** Every library is bundled. Nothing is fetched from a CDN.
- **Small.** A few hundred lines of Swift around WKWebView. Universal binary (Apple silicon + Intel), macOS 13 or later.

<details>
<summary>Screenshots: the viewer window and the Quick Look panel</summary>

![GlanceMD viewer window](docs/app.png)

![Quick Look preview of the same file](docs/quicklook.png)

</details>

## Install

### Download

1. Download `GlanceMD-<version>.zip` from [Releases](https://github.com/gksdud6330/glance-md/releases), unzip it and move `GlanceMD.app` to `/Applications`.
2. GlanceMD is not notarized (it is signed ad hoc, without a paid Apple Developer ID), so macOS blocks the first launch. Open it once, close the warning, then go to **System Settings → Privacy & Security** and click **Open Anyway**. Alternatively:
   ```bash
   xattr -dr com.apple.quarantine /Applications/GlanceMD.app
   ```
3. Launch GlanceMD once so macOS registers its Quick Look extension. Then select a `.md` file in Finder and press Space.

If Space still shows plain text, run `qlmanage -r` and make sure **GlanceMD Quick Look** is enabled in **System Settings → General → Login Items & Extensions → Quick Look**.

### Build from source

Requires Xcode or the Xcode Command Line Tools.

```bash
git clone https://github.com/gksdud6330/glance-md.git
cd glance-md
./install.sh        # builds build/GlanceMD.app and installs it to /Applications
```

`./build.sh` alone builds without installing.

### Make it the default app for Markdown (optional)

In Finder, **Get Info** on any `.md` file → **Open with: GlanceMD** → **Change All…**

## Security

A Markdown file can contain raw HTML, so a previewer that renders it naively will also run whatever script the file carries. GlanceMD treats every document as untrusted:

- Rendered HTML goes through [DOMPurify](https://github.com/cure53/DOMPurify): `<script>`, `on*` handlers, `javascript:` URLs, `<iframe>`, `<form>` and `<style>` are removed.
- The page runs under a Content Security Policy that only allows the bundled scripts, so even markup that slips through cannot execute.
- Mermaid runs with `securityLevel: 'strict'`; KaTeX runs with `trust: false`, so `\href{javascript:…}` is not turned into a link.
- Clicking a link to a local file never launches it. `.md` links open in GlanceMD, anything else is only revealed in Finder.
- The Quick Look extension is sandboxed with read-only file access, which it needs to show images next to the document.

[`samples/stress-test.md`](samples/stress-test.md) exercises all of this. Open it with GlanceMD: every line in the last section should read `[안전]` ("safe").

## How it works

```
src/app/          the viewer app (windows, tabs, live reload, menus)
src/quicklook/    the Quick Look preview extension (sandboxed)
src/shared/       MarkdownPage: loads the renderer page and renders a file into it
web/              the renderer page: markdown-it → DOMPurify → Mermaid/KaTeX/highlight.js
samples/          a feature demo and a rendering/security stress test
```

The app and the extension render through the same `web/` page, so a Quick Look preview and a viewer window always look identical. Mermaid (about 5 MB) is loaded only when a document contains a diagram.

## Limitations

- Not notarized; see the install steps above.
- A read-only viewer: no editing, no PDF export.
- The first preview after login can take a second or two while WebKit starts.
- Tested on macOS 26 on Apple silicon.

## Credits

GlanceMD is a thin shell around excellent open-source projects: [markdown-it](https://github.com/markdown-it/markdown-it) with [footnote](https://github.com/markdown-it/markdown-it-footnote), [task list](https://github.com/revin/markdown-it-task-lists) and [texmath](https://github.com/goessner/markdown-it-texmath) plugins, [KaTeX](https://katex.org), [Mermaid](https://mermaid.js.org), [highlight.js](https://highlightjs.org) and [DOMPurify](https://github.com/cure53/DOMPurify). Their licenses are in [`web/vendor/THIRD_PARTY_LICENSES.md`](web/vendor/THIRD_PARTY_LICENSES.md).

## License

[MIT](LICENSE)
