<div align="center">

<img src="assets/AppIcon.png" width="128" alt="Icône de GlanceMD">

# GlanceMD

**Le Markdown sur macOS, en un coup d'œil.**

Sélectionnez un fichier `.md` dans le Finder, appuyez sur <kbd>Espace</kbd> et lisez-le rendu : tableaux, diagrammes Mermaid, formules, code avec coloration syntaxique, notes de bas de page, listes de tâches et les images placées à côté du fichier.

![Finder, Espace, le Markdown brut devient une page rendue dans GlanceMD](docs/hero.gif)

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [Español](README.es.md) · [Português (BR)](README.pt-BR.md) · [Deutsch](README.de.md) · **Français**

[![Dernière version](https://img.shields.io/github/v/release/gksdud6330/glance-md?style=flat-square&labelColor=1d1d1f&color=636366)](https://github.com/gksdud6330/glance-md/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-636366?style=flat-square&labelColor=1d1d1f)](#installation)
[![Binaire universel](https://img.shields.io/badge/Apple%20silicon%20%26%20Intel-universal-636366?style=flat-square&labelColor=1d1d1f)](#installation)
[![Licence MIT](https://img.shields.io/badge/license-MIT-636366?style=flat-square&labelColor=1d1d1f)](LICENSE)

[![Télécharger GlanceMD pour macOS](https://img.shields.io/badge/Download-GlanceMD%20for%20macOS-1d1d1f?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/gksdud6330/glance-md/releases/latest)

Gratuit et open source · fonctionne hors ligne · macOS 13 ou plus récent

</div>

## Avant et après

Le même fichier, la même barre d'espace. À gauche, l'aperçu en texte brut fourni par macOS. À droite, GlanceMD.

![Quick Look en texte brut à gauche, le même fichier rendu par GlanceMD à droite](docs/before-after.png)

## Ce que vous obtenez

- **Un Quick Look qui comprend le Markdown.** Sélectionnez un fichier, appuyez sur Espace, lisez. Les images locales à côté du fichier s'affichent aussi. Double-cliquez sur un mot dans l'aperçu pour le sélectionner et <kbd>⌘</kbd><kbd>C</kbd> pour le copier ; le fichier n'est pas ouvert.
- **Un rendu correct.** CommonMark + GitHub Flavored Markdown via [markdown-it](https://github.com/markdown-it/markdown-it) : listes imbriquées, tableaux alignés avec cellules vides et barres verticales échappées, notes de bas de page, listes de tâches, titres setext, `<details>`.
- **Diagrammes et formules.** Les blocs ` ```mermaid ` deviennent des diagrammes ; `$…$`, `$$…$$` et ` ```math ` sont rendus avec KaTeX.
- **Une visionneuse quand il en faut une.** Ouvrez un fichier `.md` avec GlanceMD (ou faites-en votre app par défaut pour le Markdown, et un double-clic suffit) pour afficher le même rendu dans une petite fenêtre à onglets. Elle se met à jour dès que le fichier change (y compris lors des enregistrements atomiques des éditeurs) et conserve la position de défilement.
- **Réglages.** Ouvrez GlanceMD (ou appuyez sur <kbd>⌘</kbd><kbd>,</kbd>) pour activer ou désactiver l'aperçu Quick Look et copier automatiquement le texte sélectionné dans le presse-papiers (désactivé par défaut).
- **Une sensation native.** Mode clair et sombre, zoom (<kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>-</kbd> / pincement), copie, les liens s'ouvrent dans votre navigateur.
- **Sûr pour ouvrir des fichiers que vous n'avez pas écrits.** Voir [Sécurité](#sécurité).
- **Hors ligne.** Toutes les bibliothèques sont embarquées. Rien n'est récupéré depuis un CDN.
- **Léger.** Quelques centaines de lignes de Swift autour d'une WKWebView. Binaire universel (Apple silicon + Intel), macOS 13 ou plus récent.

<details>
<summary>Captures d'écran : la fenêtre de la visionneuse et le panneau Quick Look</summary>

![Fenêtre de la visionneuse GlanceMD](docs/app.png)

![Aperçu Quick Look du même fichier](docs/quicklook.png)

</details>

## Installation

### Téléchargement

1. Téléchargez `GlanceMD-<version>.zip` depuis [Releases](https://github.com/gksdud6330/glance-md/releases), décompressez-le et déplacez `GlanceMD.app` dans `/Applications`.
2. GlanceMD n'est pas notarisé (il est signé ad hoc, sans Apple Developer ID payant), donc macOS bloque le premier lancement. Ouvrez-le une fois, fermez l'avertissement, puis allez dans **Réglages Système → Confidentialité et sécurité** et cliquez sur **Ouvrir quand même**. Ou bien :
   ```bash
   xattr -dr com.apple.quarantine /Applications/GlanceMD.app
   ```
3. Lancez GlanceMD une fois pour que macOS enregistre son extension Quick Look. Sélectionnez ensuite un fichier `.md` dans le Finder et appuyez sur Espace.

Si Espace affiche toujours du texte brut, exécutez `qlmanage -r` et vérifiez que **GlanceMD Quick Look** est activé dans **Réglages Système → Général → Éléments de connexion et extensions → Quick Look**.

### Compiler depuis les sources

Nécessite Xcode ou les Xcode Command Line Tools.

```bash
git clone https://github.com/gksdud6330/glance-md.git
cd glance-md
./install.sh        # compile build/GlanceMD.app et l'installe dans /Applications
```

`./build.sh` seul compile sans installer.

### En faire l'app par défaut pour le Markdown (facultatif)

Dans le Finder, **Lire les informations** sur n'importe quel fichier `.md` → **Ouvrir avec : GlanceMD** → **Tout modifier…**

## Sécurité

Un fichier Markdown peut contenir du HTML brut ; un outil d'aperçu qui le rend naïvement exécute donc aussi tout script que le fichier transporte. GlanceMD traite chaque document comme non fiable :

- Le HTML rendu passe par [DOMPurify](https://github.com/cure53/DOMPurify) : `<script>`, les gestionnaires `on*`, les URL `javascript:`, `<iframe>`, `<form>` et `<style>` sont supprimés.
- La page s'exécute sous une Content Security Policy qui n'autorise que les scripts embarqués ; même un balisage qui passerait entre les mailles ne peut pas s'exécuter.
- Mermaid tourne avec `securityLevel: 'strict'` ; KaTeX avec `trust: false`, donc `\href{javascript:…}` ne devient pas un lien.
- Cliquer sur un lien vers un fichier local ne le lance jamais. Les liens `.md` s'ouvrent dans GlanceMD, tout le reste est seulement affiché dans le Finder.
- L'extension Quick Look est isolée dans un bac à sable avec un accès aux fichiers en lecture seule, nécessaire pour afficher les images à côté du document.

[`samples/stress-test.md`](samples/stress-test.md) met tout cela à l'épreuve. Ouvrez-le avec GlanceMD : chaque ligne de la dernière section doit afficher `[안전]` (« sûr » en coréen).

## Fonctionnement

```
src/app/          l'app visionneuse (fenêtres, onglets, rechargement à chaud, menus)
src/quicklook/    l'extension d'aperçu Quick Look (bac à sable)
src/shared/       MarkdownPage : charge la page de rendu et y rend un fichier
web/              la page de rendu : markdown-it → DOMPurify → Mermaid/KaTeX/highlight.js
samples/          une démo des fonctionnalités et un test de robustesse rendu/sécurité
```

L'app et l'extension rendent via la même page `web/`, si bien qu'un aperçu Quick Look et une fenêtre de la visionneuse sont toujours identiques. Mermaid (environ 5 Mo) n'est chargé que si le document contient un diagramme.

## Limites

- Non notarisé ; voir les étapes d'installation ci-dessus.
- Une visionneuse en lecture seule : pas d'édition, pas d'export PDF.
- Le premier aperçu après l'ouverture de session peut prendre une ou deux secondes, le temps que WebKit démarre.
- Testé sur macOS 26 avec Apple silicon.

## Remerciements

GlanceMD n'est qu'une fine enveloppe autour d'excellents projets open source : [markdown-it](https://github.com/markdown-it/markdown-it) avec les plugins [footnote](https://github.com/markdown-it/markdown-it-footnote), [task list](https://github.com/revin/markdown-it-task-lists) et [texmath](https://github.com/goessner/markdown-it-texmath), [KaTeX](https://katex.org), [Mermaid](https://mermaid.js.org), [highlight.js](https://highlightjs.org) et [DOMPurify](https://github.com/cure53/DOMPurify). Leurs licences se trouvent dans [`web/vendor/THIRD_PARTY_LICENSES.md`](web/vendor/THIRD_PARTY_LICENSES.md).

## Licence

[MIT](LICENSE)
