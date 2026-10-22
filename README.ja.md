<div align="center">

<img src="assets/AppIcon.png" width="128" alt="GlanceMD アイコン">

# GlanceMD

**macOS の Markdown を、ひと目で。**

Finder で `.md` ファイルを選んで <kbd>Space</kbd> を押すだけで、表、Mermaid 図、数式、シンタックスハイライト付きコード、脚注、タスクリスト、同じフォルダの画像までレンダリングされた状態で読めます。

![Finder で Space を押すと、生の Markdown が GlanceMD のレンダリングに変わる](docs/hero.gif)

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-CN.md) · **日本語** · [Español](README.es.md) · [Português (BR)](README.pt-BR.md) · [Deutsch](README.de.md) · [Français](README.fr.md)

[![最新リリース](https://img.shields.io/github/v/release/gksdud6330/glance-md?style=flat-square&labelColor=1d1d1f&color=636366)](https://github.com/gksdud6330/glance-md/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-636366?style=flat-square&labelColor=1d1d1f)](#インストール)
[![ユニバーサルバイナリ](https://img.shields.io/badge/Apple%20silicon%20%26%20Intel-universal-636366?style=flat-square&labelColor=1d1d1f)](#インストール)
[![MIT ライセンス](https://img.shields.io/badge/license-MIT-636366?style=flat-square&labelColor=1d1d1f)](LICENSE)

[![macOS 版 GlanceMD をダウンロード](https://img.shields.io/badge/Download-GlanceMD%20for%20macOS-1d1d1f?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/gksdud6330/glance-md/releases/latest)

無料・オープンソース · オフラインで動作 · macOS 13 以降

</div>

## 導入前と導入後

同じファイル、同じスペースキー。左が macOS 標準のプレーンテキストプレビュー、右が GlanceMD です。

![左はプレーンテキストの Quick Look、右は同じファイルを GlanceMD でレンダリングしたもの](docs/before-after.png)

## できること

- **Markdown がわかる Quick Look。** ファイルを選んで Space を押せば、すぐ読めます。同じフォルダにある画像も表示されます。プレビュー内で単語をダブルクリックすると選択され、<kbd>⌘</kbd><kbd>C</kbd> でコピーできます。ファイルは開きません。
- **正確なレンダリング。** [markdown-it](https://github.com/markdown-it/markdown-it) で CommonMark と GitHub Flavored Markdown を処理します。ネストしたリスト、空セルやエスケープしたパイプを含む整列済みの表、脚注、タスクリスト、setext 見出し、`<details>` にも対応。
- **図と数式。** ` ```mermaid ` ブロックは図になり、`$…$`、`$$…$$`、` ```math ` は KaTeX でレンダリングされます。
- **必要なときはビューアで。** `.md` ファイルを GlanceMD で開くと（デフォルトのアプリにしておけばダブルクリックで）、同じレンダリングをタブ付きの小さなウインドウで表示します。ファイルが変更されるたび（エディタのアトミック保存も含む）に再レンダリングし、スクロール位置はそのまま保ちます。
- **設定。** GlanceMD を起動すると（または <kbd>⌘</kbd><kbd>,</kbd>）設定ウインドウが開きます。Quick Look プレビューのオン／オフと、テキストを選択しただけでクリップボードにコピーする機能（初期設定はオフ）を切り替えられます。
- **macOS らしい使い心地。** ライト/ダークモード、ズーム（<kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>-</kbd> / ピンチ）、コピー、リンクはブラウザで開きます。
- **他人が書いたファイルも安全に開ける。** [セキュリティ](#セキュリティ)を参照。
- **オフライン。** すべてのライブラリを同梱。CDN から取得するものはありません。
- **小さい。** WKWebView を包む数百行の Swift。ユニバーサルバイナリ（Apple シリコン + Intel）、macOS 13 以降。

<details>
<summary>スクリーンショット：ビューアウインドウと Quick Look パネル</summary>

![GlanceMD のビューアウインドウ](docs/app.png)

![同じファイルの Quick Look プレビュー](docs/quicklook.png)

</details>

## インストール

### ダウンロード

1. [Releases](https://github.com/gksdud6330/glance-md/releases) から `GlanceMD-<version>.zip` をダウンロードして展開し、`GlanceMD.app` を `/Applications` に移動します。
2. GlanceMD は公証（notarization）されていない（有料の Apple Developer ID なしの ad hoc 署名）ため、macOS が初回起動をブロックします。一度開いて警告を閉じたあと、**システム設定 → プライバシーとセキュリティ** で **このまま開く** をクリックしてください。またはターミナルで：
   ```bash
   xattr -dr com.apple.quarantine /Applications/GlanceMD.app
   ```
3. GlanceMD を一度起動すると、macOS が Quick Look 機能拡張を登録します。あとは Finder で `.md` ファイルを選んで Space を押すだけです。

Space を押してもプレーンテキストのままなら、`qlmanage -r` を実行し、**システム設定 → 一般 → ログイン項目と機能拡張 → Quick Look** で **GlanceMD Quick Look** が有効になっているか確認してください。

### ソースからビルド

Xcode または Xcode Command Line Tools が必要です。

```bash
git clone https://github.com/gksdud6330/glance-md.git
cd glance-md
./install.sh        # build/GlanceMD.app をビルドして /Applications にインストール
```

`./build.sh` だけならインストールせずにビルドのみ行います。

### Markdown のデフォルトアプリにする（任意）

Finder で任意の `.md` ファイルを **情報を見る** → **このアプリケーションで開く: GlanceMD** → **すべてを変更…**

## セキュリティ

Markdown ファイルには生の HTML を書けるため、素朴にレンダリングするプレビューアはファイルに仕込まれたスクリプトまで実行してしまいます。GlanceMD はすべてのドキュメントを信頼できないものとして扱います。

- レンダリングした HTML は [DOMPurify](https://github.com/cure53/DOMPurify) を通します。`<script>`、`on*` ハンドラ、`javascript:` URL、`<iframe>`、`<form>`、`<style>` は取り除かれます。
- ページは同梱スクリプトだけを許可する Content Security Policy の下で動くので、すり抜けたマークアップがあっても実行されません。
- Mermaid は `securityLevel: 'strict'`、KaTeX は `trust: false` で動作し、`\href{javascript:…}` がリンクになることはありません。
- ローカルファイルへのリンクをクリックしても、決して起動しません。`.md` へのリンクは GlanceMD で開き、それ以外は Finder で表示するだけです。
- Quick Look 機能拡張は読み取り専用のファイルアクセスだけを持つサンドボックス内で動きます。ドキュメントの隣にある画像を表示するために必要な権限です。

[`samples/stress-test.md`](samples/stress-test.md) がこれらすべてを検証します。GlanceMD で開くと、最後のセクションのすべての行が `[안전]`（韓国語で「安全」）と表示されるはずです。

## 仕組み

```
src/app/          ビューアアプリ（ウインドウ、タブ、ライブリロード、メニュー）
src/quicklook/    Quick Look プレビュー機能拡張（サンドボックス）
src/shared/       MarkdownPage：レンダラーページを読み込み、ファイルをレンダリングする
web/              レンダラーページ：markdown-it → DOMPurify → Mermaid/KaTeX/highlight.js
samples/          機能デモと、レンダリング/セキュリティのストレステスト
```

アプリと機能拡張は同じ `web/` ページでレンダリングするので、Quick Look のプレビューとビューアのウインドウは常に同じ見た目になります。Mermaid（約 5 MB）はドキュメントに図が含まれるときだけ読み込まれます。

## 制限事項

- 公証されていません。上記のインストール手順を参照してください。
- 読み取り専用のビューアです。編集や PDF 書き出しはできません。
- ログイン後の最初のプレビューは、WebKit の起動に 1〜2 秒かかることがあります。
- Apple シリコンの macOS 26 でテストしています。

## クレジット

GlanceMD は優れたオープンソースプロジェクトを薄く包んだだけのものです：[markdown-it](https://github.com/markdown-it/markdown-it) と [footnote](https://github.com/markdown-it/markdown-it-footnote)、[task list](https://github.com/revin/markdown-it-task-lists)、[texmath](https://github.com/goessner/markdown-it-texmath) の各プラグイン、[KaTeX](https://katex.org)、[Mermaid](https://mermaid.js.org)、[highlight.js](https://highlightjs.org)、[DOMPurify](https://github.com/cure53/DOMPurify)。それぞれのライセンスは [`web/vendor/THIRD_PARTY_LICENSES.md`](web/vendor/THIRD_PARTY_LICENSES.md) にあります。

## ライセンス

[MIT](LICENSE)
