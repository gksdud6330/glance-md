<div align="center">

<img src="assets/AppIcon.png" width="128" alt="GlanceMD 아이콘">

# GlanceMD

**macOS에서 마크다운을, 스페이스바 한 번에.**

Finder에서 `.md` 파일을 고르고 <kbd>Space</kbd>를 누르면 표, Mermaid 다이어그램, 수식, 코드 하이라이트, 각주, 체크리스트, 같은 폴더의 이미지까지 제대로 렌더링해서 보여 줍니다.

![Finder에서 Space를 누르자 날것의 마크다운이 GlanceMD 렌더링으로 바뀌는 장면](docs/hero.gif)

[English](README.md) · **한국어** · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [Español](README.es.md) · [Português (BR)](README.pt-BR.md) · [Deutsch](README.de.md) · [Français](README.fr.md)

[![최신 릴리스](https://img.shields.io/github/v/release/gksdud6330/glance-md?style=flat-square&labelColor=1d1d1f&color=636366)](https://github.com/gksdud6330/glance-md/releases/latest)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-636366?style=flat-square&labelColor=1d1d1f)](#설치)
[![유니버설 바이너리](https://img.shields.io/badge/Apple%20silicon%20%26%20Intel-universal-636366?style=flat-square&labelColor=1d1d1f)](#설치)
[![MIT 라이선스](https://img.shields.io/badge/license-MIT-636366?style=flat-square&labelColor=1d1d1f)](LICENSE)

[![macOS용 GlanceMD 다운로드](https://img.shields.io/badge/Download-GlanceMD%20for%20macOS-1d1d1f?style=for-the-badge&logo=apple&logoColor=white)](https://github.com/gksdud6330/glance-md/releases/latest)

무료 오픈소스 · 인터넷 없이 동작 · macOS 13 이상

</div>

## 설치 전과 후

같은 파일, 같은 스페이스바. 왼쪽은 macOS가 기본으로 보여 주는 일반 텍스트 미리보기, 오른쪽은 GlanceMD입니다.

![왼쪽은 일반 텍스트 Quick Look, 오른쪽은 같은 파일을 GlanceMD로 렌더링한 모습](docs/before-after.png)

## 이런 것들이 됩니다

- **마크다운을 아는 Quick Look.** 파일을 고르고 Space를 누르면 바로 읽을 수 있습니다. 같은 폴더의 이미지도 함께 뜹니다. 미리보기 안에서 단어를 더블클릭하면 선택되고 <kbd>⌘</kbd><kbd>C</kbd>로 복사됩니다. 파일이 열리지는 않습니다.
- **정확한 렌더링.** [markdown-it](https://github.com/markdown-it/markdown-it)으로 CommonMark와 GitHub Flavored Markdown을 처리합니다. 중첩 목록, 빈 셀과 이스케이프된 파이프가 있는 정렬 표, 각주, 체크리스트, setext 제목, `<details>`까지.
- **다이어그램과 수식.** ` ```mermaid ` 블록은 다이어그램이 되고, `$…$`, `$$…$$`, ` ```math `는 KaTeX로 렌더링됩니다.
- **필요할 땐 뷰어로.** `.md` 파일을 GlanceMD로 열면(기본 앱으로 지정해 두면 더블클릭으로) 같은 렌더링을 탭이 있는 작은 창으로 볼 수 있습니다. 파일을 저장할 때마다(에디터의 원자적 저장 포함) 다시 렌더링하고, 읽던 위치는 그대로 유지합니다.
- **설정.** GlanceMD를 실행하면(또는 <kbd>⌘</kbd><kbd>,</kbd>) 설정 창이 열립니다. Quick Look 미리보기를 켜고 끌 수 있고, 텍스트를 선택하면 바로 클립보드에 복사되게 할 수도 있습니다(기본은 꺼짐).
- **macOS답게.** 라이트/다크 모드, 확대·축소(<kbd>⌘</kbd><kbd>+</kbd> / <kbd>⌘</kbd><kbd>-</kbd> / 핀치), 복사, 링크는 브라우저에서 열립니다.
- **남이 보낸 파일을 열어도 안전.** [보안](#보안) 참고.
- **오프라인.** 모든 라이브러리가 앱에 들어 있습니다. CDN에서 받아오는 것은 없습니다.
- **작습니다.** WKWebView를 감싼 수백 줄의 Swift. 유니버설 바이너리(Apple 실리콘 + Intel), macOS 13 이상.

<details>
<summary>스크린샷: 뷰어 창과 Quick Look 패널</summary>

![GlanceMD 뷰어 창](docs/app.png)

![같은 파일의 Quick Look 미리보기](docs/quicklook.png)

</details>

## 설치

### 다운로드

1. [Releases](https://github.com/gksdud6330/glance-md/releases)에서 `GlanceMD-<version>.zip`을 받아 압축을 풀고 `GlanceMD.app`을 `/Applications`로 옮깁니다.
2. GlanceMD는 공증(notarize)되지 않은 앱이라(유료 Apple Developer ID 없이 ad hoc 서명) macOS가 첫 실행을 막습니다. 한 번 실행해서 경고를 닫은 뒤 **시스템 설정 → 개인정보 보호 및 보안**에서 **그래도 열기**를 누르세요. 또는 터미널에서:
   ```bash
   xattr -dr com.apple.quarantine /Applications/GlanceMD.app
   ```
3. GlanceMD를 한 번 실행하면 macOS가 Quick Look 확장 프로그램을 등록합니다. 이제 Finder에서 `.md` 파일을 고르고 Space를 누르세요.

Space를 눌러도 여전히 일반 텍스트가 보이면 `qlmanage -r`을 실행하고, **시스템 설정 → 일반 → 로그인 항목 및 확장 프로그램 → Quick Look(훑어보기)**에서 **GlanceMD Quick Look**이 켜져 있는지 확인하세요.

### 소스에서 빌드

Xcode 또는 Xcode Command Line Tools가 필요합니다.

```bash
git clone https://github.com/gksdud6330/glance-md.git
cd glance-md
./install.sh        # build/GlanceMD.app을 빌드해서 /Applications에 설치
```

`./build.sh`만 실행하면 설치 없이 빌드만 합니다.

### 마크다운 기본 앱으로 지정 (선택)

Finder에서 아무 `.md` 파일이나 **정보 가져오기** → **다음으로 열기: GlanceMD** → **모두 변경…**

## 보안

마크다운 파일에는 HTML을 그대로 쓸 수 있기 때문에, 순진하게 렌더링하는 미리보기 도구는 파일에 들어 있는 스크립트까지 실행해 버립니다. GlanceMD는 모든 문서를 신뢰하지 않는 것으로 취급합니다.

- 렌더링된 HTML은 [DOMPurify](https://github.com/cure53/DOMPurify)를 거칩니다. `<script>`, `on*` 핸들러, `javascript:` URL, `<iframe>`, `<form>`, `<style>`은 제거됩니다.
- 페이지는 번들된 스크립트만 허용하는 Content Security Policy 아래에서 동작하므로, 빠져나간 마크업이 있어도 실행되지 않습니다.
- Mermaid는 `securityLevel: 'strict'`, KaTeX는 `trust: false`로 동작해서 `\href{javascript:…}`가 링크가 되지 않습니다.
- 로컬 파일 링크를 클릭해도 절대 실행하지 않습니다. `.md` 링크는 GlanceMD에서 열리고, 그 외에는 Finder에서 보여 주기만 합니다.
- Quick Look 확장 프로그램은 읽기 전용 파일 접근 권한만 가진 샌드박스 안에서 동작합니다. 문서 옆의 이미지를 보여 주려면 이 권한이 필요합니다.

[`samples/stress-test.md`](samples/stress-test.md)가 이 모든 것을 검증합니다. GlanceMD로 열어 보면 마지막 섹션의 모든 줄이 `[안전]`으로 보여야 합니다.

## 구조

```
src/app/          뷰어 앱 (창, 탭, 라이브 리로드, 메뉴)
src/quicklook/    Quick Look 미리보기 확장 프로그램 (샌드박스)
src/shared/       MarkdownPage: 렌더러 페이지를 불러와 파일을 렌더링
web/              렌더러 페이지: markdown-it → DOMPurify → Mermaid/KaTeX/highlight.js
samples/          기능 데모와 렌더링/보안 스트레스 테스트
```

앱과 확장 프로그램이 같은 `web/` 페이지로 렌더링하기 때문에 Quick Look 미리보기와 뷰어 창은 항상 똑같이 보입니다. Mermaid(약 5 MB)는 문서에 다이어그램이 있을 때만 불러옵니다.

## 한계

- 공증되지 않았습니다. 위의 설치 단계를 참고하세요.
- 읽기 전용 뷰어입니다. 편집이나 PDF 내보내기는 없습니다.
- 로그인 후 첫 미리보기는 WebKit이 뜨는 동안 1~2초 걸릴 수 있습니다.
- Apple 실리콘의 macOS 26에서 테스트했습니다.

## 크레딧

GlanceMD는 훌륭한 오픈소스 프로젝트들을 얇게 감싼 껍데기입니다: [markdown-it](https://github.com/markdown-it/markdown-it)과 [footnote](https://github.com/markdown-it/markdown-it-footnote), [task list](https://github.com/revin/markdown-it-task-lists), [texmath](https://github.com/goessner/markdown-it-texmath) 플러그인, [KaTeX](https://katex.org), [Mermaid](https://mermaid.js.org), [highlight.js](https://highlightjs.org), [DOMPurify](https://github.com/cure53/DOMPurify). 각 라이선스는 [`web/vendor/THIRD_PARTY_LICENSES.md`](web/vendor/THIRD_PARTY_LICENSES.md)에 있습니다.

## 라이선스

[MIT](LICENSE)
