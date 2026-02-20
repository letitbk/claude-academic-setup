# Marp 高度な機能リファレンス

Marp CoreとMarpitの高度な機能。

## Fragmented List（段階的表示）

リストアイテムを段階的に表示する機能（アニメーション効果）。

公式ドキュメント: https://github.com/marp-team/marpit/tree/main/docs/fragmented-list

### 基本的な使い方

```markdown
* Item 1
* Item 2
* Item 3
```

通常、すべてのアイテムが一度に表示されます。

### アスタリスク（*）の使用

```markdown
* Item 1
* Item 2
* Item 3
```

Marp CLIで`--html`オプション使用時、各アイテムが順次表示されます。

### 注意事項

- **HTML出力時のみ有効**: PDF/PPTX/画像では効果なし
- **プレゼンテーションモード**: ブラウザでのプレゼンテーション時に機能
- **Marp for VS Code**: プレビューでは動作しない場合あり

## 数式記法（Marp Core拡張）

Pandoc形式の数式をサポート。KaTeXを使用してレンダリング。

公式: https://github.com/marp-team/marp-core#math-typesetting

### インライン数式

```markdown
文中に $E = mc^2$ を挿入
```

### ブロック数式

```markdown
$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
```

### 複数行の数式

```markdown
$$
\begin{aligned}
  f(x) &= x^2 + 2x + 1 \\
  &= (x + 1)^2
\end{aligned}
$$
```

### 数式の例

```markdown
## 二次方程式の解

$$
x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$

## オイラーの等式

$$
e^{i\pi} + 1 = 0
$$
```

### 注意事項

- **KaTeX記法**: LaTeX構文のサブセット
- **サポート外の記法**: 一部のLaTeX機能は非対応
- **KaTeX公式**: https://katex.org/docs/supported.html

## 絵文字（Marp Core拡張）

GitHub Emoji記法をサポート。

公式: https://github.com/marp-team/marp-core#emoji

### 使用方法

```markdown
:smile: :heart: :+1: :sparkles:
```

レンダリング結果: 😄 ❤️ 👍 ✨

### よく使う絵文字

```markdown
:arrow_right: →
:check: ✓
:x: ✗
:bulb: 💡
:warning: ⚠️
:rocket: 🚀
:tada: 🎉
```

### 絵文字リスト

完全なリスト: https://github.com/ikatyang/emoji-cheat-sheet

## Auto-scaling（自動スケーリング）

テキストが多い場合、自動的にフォントサイズを調整。

### 無効化

```markdown
---
marp: true
---

<!-- _class: no-scaling -->

# 自動スケーリングなし
```

カスタムCSSで制御：

```css
section.no-scaling {
  --marpit-auto-scaling: off;
}
```

## HTMLタグの使用

Markdown内で直接HTMLを記述可能。

### 配置制御

```markdown
<div style="text-align: center;">
中央配置のテキスト
</div>
```

### 2カラムレイアウト

```markdown
<div style="display: flex;">
<div style="flex: 1;">

## 左側

- ポイント1
- ポイント2

</div>
<div style="flex: 1;">

## 右側

- ポイント3
- ポイント4

</div>
</div>
```

### スタイル付きボックス

```markdown
<div style="background-color: #e3f2fd; padding: 20px; border-radius: 8px;">

**重要なポイント**

ここに重要な内容を記述

</div>
```

## Marp CLI 詳細オプション

公式: https://github.com/marp-team/marp-cli

### 基本的なコマンド

```bash
# HTMLに変換
marp slide.md

# PDFに変換
marp slide.md --pdf

# PowerPointに変換
marp slide.md --pptx

# 画像に変換
marp slide.md --images png
```

### 監視モード

```bash
# ファイルを監視して自動変換
marp -w slide.md

# サーバーモードで監視
marp -s -w slide.md
```

### テーマ指定

```bash
# カスタムテーマを使用
marp slide.md --theme custom-theme.css

# テーマディレクトリを指定
marp slide.md --theme-set themes/
```

### 複数ファイルの一括変換

```bash
# ディレクトリ内のすべてのMarkdownを変換
marp slides/*.md

# 出力ディレクトリを指定
marp slides/*.md -o output/
```

### HTML出力オプション

```bash
# HTML出力（単一ファイル）
marp slide.md -o output.html

# スタンドアロンHTML（CDN使用）
marp slide.md --html
```

### PDF出力オプション

```bash
# PDF出力
marp slide.md --pdf --allow-local-files

# ページ番号なしでPDF
marp slide.md --pdf --pdf-notes
```

### 画像出力

```bash
# PNG画像として出力
marp slide.md --images png

# JPEG画像として出力
marp slide.md --images jpeg

# 解像度指定
marp slide.md --images png --image-scale 2
```

## Marp for VS Code

公式: https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode

### 有効化

Markdownファイルのフロントマターに記述：

```markdown
---
marp: true
---
```

### プレビュー

- `Ctrl+Shift+V` (Win/Linux)
- `Cmd+Shift+V` (Mac)

### エクスポート

1. コマンドパレット (`Ctrl+Shift+P`)
2. "Marp: Export slide deck..."を選択
3. 形式を選択（HTML/PDF/PPTX/PNG/JPEG）

### 設定

VS Codeの設定でカスタマイズ可能：

```json
{
  "markdown.marp.themes": [
    "./themes/custom-theme.css"
  ],
  "markdown.marp.enableHtml": true
}
```

## GitHub Actions での自動ビルド

公式: https://github.com/marketplace/actions/marp-action

### 基本的なワークフロー

```yaml
name: Marp Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Marp Build
        uses: docker://marpteam/marp-cli:latest
        with:
          args: slides.md --pdf --allow-local-files
          
      - name: Upload PDF
        uses: actions/upload-artifact@v3
        with:
          name: slides
          path: slides.pdf
```

### GitHub Pagesへの公開

```yaml
- name: Marp to Pages
  uses: docker://marpteam/marp-cli:latest
  with:
    args: slides.md -o index.html

- name: Deploy to Pages
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./
```

## Tips & Tricks

### 1. スライド番号のカスタマイズ

```css
section::after {
  content: 'Page ' attr(data-marpit-pagination);
}
```

### 2. 背景のグラデーション

```markdown
---
backgroundImage: linear-gradient(135deg, #667eea 0%, #764ba2 100%)
color: white
---
```

### 3. 2段組レイアウト

```markdown
<div class="columns">
<div>

左側のコンテンツ

</div>
<div>

右側のコンテンツ

</div>
</div>

<style>
.columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2rem;
}
</style>
```

### 4. プログレスバー

```css
section::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: calc(var(--paginate) / var(--paginate-total) * 100%);
  height: 5px;
  background-color: #3b82f6;
}
```

## トラブルシューティング

### PDFが生成されない

- ChromeまたはEdgeがインストールされているか確認
- `--allow-local-files`オプションを追加

### フォントが表示されない

- Google Fontsなどは`@import`で読み込む
- ローカルフォントは絶対パスで指定

### 画像が表示されない

- 画像の相対パスを確認
- `--allow-local-files`が必要な場合あり

## 公式リファレンス集

- **Marp公式サイト**: https://marp.app/
- **Marpit Directives**: https://marpit.marp.app/directives
- **Image Syntax**: https://marpit.marp.app/image-syntax
- **Theme CSS**: https://marpit.marp.app/theme-css
- **Marp Core**: https://github.com/marp-team/marp-core
- **Marp CLI**: https://github.com/marp-team/marp-cli
- **VS Code Extension**: https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode