<div align="center">

<img src="assets/AppIcon.png" width="128" alt="GlanceMD 图标">

# GlanceMD

**macOS 上的 Markdown，一眼看清。**

在 Finder 中选中一个 `.md` 文件，按下 <kbd>Space</kbd>，直接阅读渲染后的文档：表格、Mermaid 图表、数学公式、代码高亮、脚注、任务列表，以及同目录下的图片。

![在 Finder 中按下 Space，原始 Markdown 变成 GlanceMD 渲染后的页面](docs/hero.gif)

[English](README.md) · [한국어](README.ko.md) · **简体中文** · [日本語](README.ja.md) · [Español](README.es.md) · [Português (BR)](README.pt-BR.md) · [Deutsch](README.de.md) · [Français](README.fr.md)

[![最新版本](https://img.shields.io/github/v/release/gksdud6330/glance-md?style=flat-square&labelColor=1d1d1f&color=636366)](https://github.com/gksdud6330/glance-md/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-636366?style=flat-square&labelColor=1d1d1f)](#安装)
[![通用二进制](https://img.shields.io/badge/Apple%20silicon%20%26%20Intel-universal-636366?style=flat-square&labelColor=1d1d1f)](#安装)
[![MIT 许可证](https://img.shields.io/badge/license-MIT-636366?style=flat-square&labelColor=1d1d1f)](LICENSE)

[![下载 macOS 版 GlanceMD](https://img.shields.io/badge/Download-GlanceMD%20for%20macOS-1d1d1f?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/gksdud6330/glance-md/releases/latest)

免费开源 · 离线可用 · macOS 13 或更高版本

</div>

## 使用前后对比

同一个文件，同一个空格键。左边是 macOS 自带的纯文本预览，右边是 GlanceMD。

![左边是纯文本 Quick Look，右边是 GlanceMD 渲染的同一个文件](docs/before-after.png)

## 你能得到什么

- **看得懂 Markdown 的 Quick Look。** 选中文件，按 Space，开始阅读。同目录下的本地图片也会显示。在预览中双击一个单词即可选中，<kbd>⌘</kbd><kbd>C</kbd> 复制；不会打开文件。
- **正确的渲染。** 通过 [markdown-it](https://github.com/markdown-it/markdown-it) 处理 CommonMark 和 GitHub Flavored Markdown：嵌套列表、带空单元格和转义竖线的对齐表格、脚注、任务列表、setext 标题、`<details>`。
- **图表和公式。** ` ```mermaid ` 代码块会渲染成图表；`$…$`、`$$…$$` 和 ` ```math ` 由 KaTeX 渲染。
- **需要时有查看器。** 用 GlanceMD 打开 `.md` 文件（设为默认应用后双击即可），在一个带标签页的小窗口中查看同样的渲染结果。文件变化时自动重新渲染（包括编辑器的原子保存），并保持滚动位置。
- **设置。** 打开 GlanceMD（或按 <kbd>⌘</kbd><kbd>,</kbd>）进入设置窗口：可以开关 Quick Look 预览，也可以让选中的文本自动复制到剪贴板（默认关闭）。
- **原生体验。** 浅色/深色模式、缩放（<kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>-</kbd> / 双指捏合）、复制，链接在浏览器中打开。
- **放心打开别人发来的文件。** 见[安全](#安全)。
- **离线。** 所有库都已打包进应用，不从 CDN 获取任何内容。
- **小巧。** 包裹 WKWebView 的几百行 Swift。通用二进制（Apple silicon + Intel），macOS 13 或更高版本。

<details>
<summary>截图：查看器窗口和 Quick Look 面板</summary>

![GlanceMD 查看器窗口](docs/app.png)

![同一个文件的 Quick Look 预览](docs/quicklook.png)

</details>

## 安装

### 下载

1. 从 [Releases](https://github.com/gksdud6330/glance-md/releases) 下载 `GlanceMD-<version>.zip`，解压后把 `GlanceMD.app` 移到 `/Applications`。
2. GlanceMD 未经公证（没有付费的 Apple Developer ID，采用 ad hoc 签名），所以 macOS 会拦截首次启动。先打开一次，关闭警告，然后前往 **系统设置 → 隐私与安全性**，点击 **仍要打开**。或者在终端执行：
   ```bash
   xattr -dr com.apple.quarantine /Applications/GlanceMD.app
   ```
3. 启动一次 GlanceMD，让 macOS 注册它的 Quick Look 扩展。然后在 Finder 中选中一个 `.md` 文件并按 Space。

如果按 Space 仍然显示纯文本，运行 `qlmanage -r`，并确认 **系统设置 → 通用 → 登录项与扩展 → Quick Look** 中已启用 **GlanceMD Quick Look**。

### 从源码构建

需要 Xcode 或 Xcode Command Line Tools。

```bash
git clone https://github.com/gksdud6330/glance-md.git
cd glance-md
./install.sh        # 构建 build/GlanceMD.app 并安装到 /Applications
```

只运行 `./build.sh` 则只构建不安装。

### 设为 Markdown 的默认应用（可选）

在 Finder 中对任意 `.md` 文件 **显示简介** → **打开方式：GlanceMD** → **全部更改…**

## 安全

Markdown 文件可以包含原始 HTML，一个天真地直接渲染的预览器也会顺带执行文件里携带的脚本。GlanceMD 把每一份文档都当作不可信内容：

- 渲染出的 HTML 会经过 [DOMPurify](https://github.com/cure53/DOMPurify)：`<script>`、`on*` 事件处理器、`javascript:` URL、`<iframe>`、`<form>` 和 `<style>` 都会被移除。
- 页面运行在只允许内置脚本的 Content Security Policy 之下，即使有标记漏网也无法执行。
- Mermaid 以 `securityLevel: 'strict'` 运行；KaTeX 以 `trust: false` 运行，所以 `\href{javascript:…}` 不会变成链接。
- 点击指向本地文件的链接绝不会启动它。`.md` 链接在 GlanceMD 中打开，其他文件只会在 Finder 中显示。
- Quick Look 扩展运行在沙盒中，只有只读文件权限，这是显示文档旁图片所必需的。

[`samples/stress-test.md`](samples/stress-test.md) 覆盖了以上全部内容。用 GlanceMD 打开它：最后一节的每一行都应显示为 `[안전]`（韩语"安全"）。

## 工作原理

```
src/app/          查看器应用（窗口、标签页、实时重载、菜单）
src/quicklook/    Quick Look 预览扩展（沙盒）
src/shared/       MarkdownPage：加载渲染页面并把文件渲染进去
web/              渲染页面：markdown-it → DOMPurify → Mermaid/KaTeX/highlight.js
samples/          功能演示和渲染/安全压力测试
```

应用和扩展通过同一个 `web/` 页面渲染，所以 Quick Look 预览和查看器窗口永远长得一样。Mermaid（约 5 MB）只在文档包含图表时才加载。

## 限制

- 未经公证；见上面的安装步骤。
- 只读查看器：不能编辑，不能导出 PDF。
- 登录后的第一次预览可能需要一两秒等待 WebKit 启动。
- 在 Apple silicon 的 macOS 26 上测试。

## 致谢

GlanceMD 只是一层薄薄的外壳，功劳属于这些优秀的开源项目：[markdown-it](https://github.com/markdown-it/markdown-it) 及其 [footnote](https://github.com/markdown-it/markdown-it-footnote)、[task list](https://github.com/revin/markdown-it-task-lists)、[texmath](https://github.com/goessner/markdown-it-texmath) 插件，[KaTeX](https://katex.org)、[Mermaid](https://mermaid.js.org)、[highlight.js](https://highlightjs.org) 和 [DOMPurify](https://github.com/cure53/DOMPurify)。它们的许可证见 [`web/vendor/THIRD_PARTY_LICENSES.md`](web/vendor/THIRD_PARTY_LICENSES.md)。

## 许可证

[MIT](LICENSE)
