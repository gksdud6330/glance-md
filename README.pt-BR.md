<div align="center">

<img src="assets/AppIcon.png" width="128" alt="Ícone do GlanceMD">

# GlanceMD

**Markdown no macOS, num piscar de olhos.**

Selecione um arquivo `.md` no Finder, pressione <kbd>Espaço</kbd> e leia-o renderizado: tabelas, diagramas Mermaid, fórmulas, código com destaque de sintaxe, notas de rodapé, listas de tarefas e as imagens que estão ao lado do arquivo.

![Finder, Espaço, o Markdown bruto vira uma página renderizada no GlanceMD](docs/hero.gif)

[English](README.md) · [한국어](README.ko.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [Español](README.es.md) · **Português (BR)** · [Deutsch](README.de.md) · [Français](README.fr.md)

[![Última versão](https://img.shields.io/github/v/release/gksdud6330/glance-md?style=flat-square&labelColor=1d1d1f&color=636366)](https://github.com/gksdud6330/glance-md/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-636366?style=flat-square&labelColor=1d1d1f)](#instalação)
[![Binário universal](https://img.shields.io/badge/Apple%20silicon%20%26%20Intel-universal-636366?style=flat-square&labelColor=1d1d1f)](#instalação)
[![Licença MIT](https://img.shields.io/badge/license-MIT-636366?style=flat-square&labelColor=1d1d1f)](LICENSE)

[![Baixar o GlanceMD para macOS](https://img.shields.io/badge/Download-GlanceMD%20for%20macOS-1d1d1f?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/gksdud6330/glance-md/releases/latest)

Gratuito e de código aberto · funciona offline · macOS 13 ou mais recente

</div>

## Antes e depois

O mesmo arquivo, a mesma barra de espaço. À esquerda, a pré-visualização em texto puro que vem com o macOS. À direita, o GlanceMD.

![Quick Look em texto puro à esquerda, o mesmo arquivo renderizado pelo GlanceMD à direita](docs/before-after.png)

## O que você ganha

- **Um Quick Look que entende Markdown.** Selecione um arquivo, pressione Espaço e leia. As imagens locais ao lado do arquivo também aparecem. Dê um clique duplo numa palavra da pré-visualização para selecioná-la e <kbd>⌘</kbd><kbd>C</kbd> para copiar; o arquivo não é aberto.
- **Renderização correta.** CommonMark + GitHub Flavored Markdown via [markdown-it](https://github.com/markdown-it/markdown-it): listas aninhadas, tabelas alinhadas com células vazias e barras verticais escapadas, notas de rodapé, listas de tarefas, títulos setext, `<details>`.
- **Diagramas e fórmulas.** Blocos ` ```mermaid ` viram diagramas; `$…$`, `$$…$$` e ` ```math ` são renderizados com KaTeX.
- **Um visualizador quando você precisar.** Abra um arquivo `.md` com o GlanceMD (ou defina-o como app padrão para Markdown, e basta um clique duplo) para ver a mesma renderização numa janela pequena com abas. Ela renderiza de novo quando o arquivo muda (inclusive salvamentos atômicos de editores) e mantém a posição de rolagem.
- **Ajustes.** Abra o GlanceMD (ou pressione <kbd>⌘</kbd><kbd>,</kbd>) para ligar ou desligar a pré-visualização do Quick Look e para copiar o texto para a área de transferência assim que você o seleciona (desligado por padrão).
- **Cara de macOS.** Modo claro e escuro, zoom (<kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>-</kbd> / pinça), copiar, links abrem no seu navegador.
- **Seguro para abrir arquivos que não foram escritos por você.** Veja [Segurança](#segurança).
- **Offline.** Todas as bibliotecas vêm embutidas. Nada é baixado de um CDN.
- **Pequeno.** Algumas centenas de linhas de Swift em volta de um WKWebView. Binário universal (Apple silicon + Intel), macOS 13 ou mais recente.

<details>
<summary>Capturas de tela: a janela do visualizador e o painel do Quick Look</summary>

![Janela do visualizador do GlanceMD](docs/app.png)

![Pré-visualização Quick Look do mesmo arquivo](docs/quicklook.png)

</details>

## Instalação

### Download

1. Baixe `GlanceMD-<version>.zip` em [Releases](https://github.com/gksdud6330/glance-md/releases), descompacte e mova `GlanceMD.app` para `/Applications`.
2. O GlanceMD não é notarizado (é assinado ad hoc, sem um Apple Developer ID pago), então o macOS bloqueia a primeira abertura. Abra uma vez, feche o aviso e vá em **Ajustes do Sistema → Privacidade e Segurança** e clique em **Abrir Mesmo Assim**. Ou então:
   ```bash
   xattr -dr com.apple.quarantine /Applications/GlanceMD.app
   ```
3. Abra o GlanceMD uma vez para que o macOS registre a extensão de Quick Look. Depois selecione um arquivo `.md` no Finder e pressione Espaço.

Se Espaço ainda mostrar texto puro, rode `qlmanage -r` e confira se **GlanceMD Quick Look** está ativado em **Ajustes do Sistema → Geral → Itens de Início e Extensões → Quick Look**.

### Compilar a partir do código-fonte

Requer o Xcode ou as Xcode Command Line Tools.

```bash
git clone https://github.com/gksdud6330/glance-md.git
cd glance-md
./install.sh        # compila build/GlanceMD.app e instala em /Applications
```

`./build.sh` sozinho só compila, sem instalar.

### Tornar o app padrão para Markdown (opcional)

No Finder, **Obter Informações** em qualquer arquivo `.md` → **Abrir com: GlanceMD** → **Alterar Tudo…**

## Segurança

Um arquivo Markdown pode conter HTML bruto, então um visualizador que o renderize ingenuamente também executa qualquer script que o arquivo carregue. O GlanceMD trata todo documento como não confiável:

- O HTML renderizado passa pelo [DOMPurify](https://github.com/cure53/DOMPurify): `<script>`, handlers `on*`, URLs `javascript:`, `<iframe>`, `<form>` e `<style>` são removidos.
- A página roda sob uma Content Security Policy que só permite os scripts embutidos, então mesmo uma marcação que escape não consegue executar.
- O Mermaid roda com `securityLevel: 'strict'`; o KaTeX roda com `trust: false`, então `\href{javascript:…}` não vira link.
- Clicar num link para um arquivo local nunca o executa. Links `.md` abrem no GlanceMD; qualquer outro é apenas mostrado no Finder.
- A extensão de Quick Look roda em sandbox com acesso somente leitura a arquivos, necessário para mostrar as imagens ao lado do documento.

[`samples/stress-test.md`](samples/stress-test.md) exercita tudo isso. Abra-o com o GlanceMD: cada linha da última seção deve mostrar `[안전]` ("seguro", em coreano).

## Como funciona

```
src/app/          o app visualizador (janelas, abas, live reload, menus)
src/quicklook/    a extensão de pré-visualização do Quick Look (em sandbox)
src/shared/       MarkdownPage: carrega a página de renderização e renderiza um arquivo nela
web/              a página de renderização: markdown-it → DOMPurify → Mermaid/KaTeX/highlight.js
samples/          uma demo de recursos e um teste de estresse de renderização/segurança
```

O app e a extensão renderizam pela mesma página `web/`, então uma pré-visualização do Quick Look e uma janela do visualizador sempre ficam idênticas. O Mermaid (cerca de 5 MB) só é carregado quando o documento contém um diagrama.

## Limitações

- Não é notarizado; veja os passos de instalação acima.
- É um visualizador somente leitura: sem edição, sem exportar para PDF.
- A primeira pré-visualização depois do login pode levar um ou dois segundos enquanto o WebKit inicia.
- Testado no macOS 26 em Apple silicon.

## Créditos

O GlanceMD é uma casca fina em volta de excelentes projetos de código aberto: [markdown-it](https://github.com/markdown-it/markdown-it) com os plugins [footnote](https://github.com/markdown-it/markdown-it-footnote), [task list](https://github.com/revin/markdown-it-task-lists) e [texmath](https://github.com/goessner/markdown-it-texmath), [KaTeX](https://katex.org), [Mermaid](https://mermaid.js.org), [highlight.js](https://highlightjs.org) e [DOMPurify](https://github.com/cure53/DOMPurify). As licenças deles estão em [`web/vendor/THIRD_PARTY_LICENSES.md`](web/vendor/THIRD_PARTY_LICENSES.md).

## Licença

[MIT](LICENSE)
