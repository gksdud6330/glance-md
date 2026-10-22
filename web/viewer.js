(() => {
  'use strict';

  const md = window.markdownit({
    html: true,        // allow <details>, <kbd>, ... ; DOMPurify strips anything executable
    linkify: true,
    highlight(code, lang) {
      if (lang && hljs.getLanguage(lang)) {
        try {
          return hljs.highlight(code, { language: lang, ignoreIllegals: true }).value;
        } catch (err) {
          console.warn(`glancemd: highlight failed for "${lang}"`, err);
        }
      }
      return ''; // markdown-it escapes the code itself
    },
  })
    .use(window.markdownitFootnote)
    .use(window.markdownitTaskLists, { label: true })
    .use(window.texmath, { engine: window.katex, delimiters: ['gitlab', 'dollars'] });

  const renderFence = md.renderer.rules.fence;
  md.renderer.rules.fence = (tokens, idx, options, env, self) => {
    const token = tokens[idx];
    if (token.info.trim().split(/\s+/)[0].toLowerCase() === 'mermaid') {
      return `<pre class="mermaid-source">${md.utils.escapeHtml(token.content)}</pre>\n`;
    }
    return renderFence(tokens, idx, options, env, self);
  };

  const purifyConfig = {
    RETURN_DOM_FRAGMENT: true,
    ADD_TAGS: ['eq', 'eqn'],
    FORBID_TAGS: ['style', 'form', 'iframe', 'object', 'embed'],
  };

  const hasScheme = (v) => /^[a-z][a-z0-9+.-]*:/i.test(v);

  function resolveRelativeToDocument(root, baseURL) {
    for (const el of root.querySelectorAll('img[src], source[src], video[src], audio[src], a[href]')) {
      const attr = el.tagName === 'A' ? 'href' : 'src';
      const value = el.getAttribute(attr);
      if (!value || value.startsWith('#') || hasScheme(value)) continue;
      el.setAttribute(attr, new URL(value, baseURL).href);
    }
  }

  function slug(text) {
    return text.trim().toLowerCase().replace(/[^\p{L}\p{N}\s-]/gu, '').replace(/\s+/g, '-');
  }

  function addHeadingIds(root) {
    const seen = new Map();
    for (const h of root.querySelectorAll('h1, h2, h3, h4, h5, h6')) {
      if (h.id) continue;
      const base = slug(h.textContent) || 'section';
      const n = seen.get(base) ?? 0;
      seen.set(base, n + 1);
      h.id = n === 0 ? base : `${base}-${n}`;
    }
  }

  const darkScheme = window.matchMedia('(prefers-color-scheme: dark)');
  let mermaidLoading = null;
  let diagramCount = 0;

  function loadMermaid() {
    mermaidLoading ??= new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = 'vendor/mermaid.min.js';
      script.onload = () => resolve(window.mermaid);
      script.onerror = () => {
        mermaidLoading = null;
        reject(new Error('vendor/mermaid.min.js를 불러오지 못했습니다'));
      };
      document.head.append(script);
    });
    return mermaidLoading;
  }

  async function renderDiagrams(root) {
    const sources = [...root.querySelectorAll('pre.mermaid-source')];
    if (sources.length === 0) return;
    const mermaid = await loadMermaid();
    mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'strict',
      suppressErrorRendering: true,
      theme: darkScheme.matches ? 'dark' : 'default',
    });
    for (const pre of sources) {
      const diagram = document.createElement('div');
      try {
        const { svg } = await mermaid.render(`glancemd-mermaid-${++diagramCount}`, pre.textContent);
        diagram.className = 'mermaid-diagram';
        diagram.innerHTML = svg;
      } catch (err) {
        diagram.className = 'diagram-error';
        diagram.textContent = `Mermaid 오류: ${err?.message ?? err}\n\n${pre.textContent}`;
      }
      pre.replaceWith(diagram);
    }
  }

  let copyOnSelect = false;
  let copiedToastTimer = 0;

  function showCopiedToast() {
    let toast = document.getElementById('copied-toast');
    if (!toast) {
      toast = document.createElement('div');
      toast.id = 'copied-toast';
      toast.setAttribute('role', 'status');
      toast.textContent = 'Copied';
      document.body.append(toast);
    }
    toast.classList.add('visible');
    clearTimeout(copiedToastTimer);
    copiedToastTimer = setTimeout(() => toast.classList.remove('visible'), 1200);
  }

  document.addEventListener('mouseup', () => {
    if (!copyOnSelect) return;
    const text = window.getSelection()?.toString() ?? '';
    if (!text.trim()) return;
    window.webkit.messageHandlers.copySelection.postMessage(text);
    showCopiedToast();
  });

  let renderGeneration = 0;
  let lastRequest = null;

  window.glancemd = {
    setCopyOnSelect(enabled) {
      copyOnSelect = enabled;
    },

    async render(markdown, baseURL) {
      const generation = ++renderGeneration;
      lastRequest = { markdown, baseURL };
      const fragment = DOMPurify.sanitize(md.render(markdown), purifyConfig);
      resolveRelativeToDocument(fragment, baseURL);
      addHeadingIds(fragment);
      await renderDiagrams(fragment);
      if (generation !== renderGeneration) return 'superseded';
      const readingPosition = window.scrollY;
      document.getElementById('content').replaceChildren(fragment);
      window.scrollTo(0, readingPosition);
      return 'rendered';
    },
  };

  darkScheme.addEventListener('change', () => {
    if (!lastRequest) return;
    window.glancemd.render(lastRequest.markdown, lastRequest.baseURL)
      .catch((err) => console.error('glancemd: re-render after theme change failed', err));
  });
})();
