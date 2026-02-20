# Marp テーマCSS作成ガイド

Marpit公式のテーマCSS仕様に基づく、カスタムテーマの作成方法。

公式ドキュメント: https://marpit.marp.app/theme-css

## テーマの基本構造

### @themeメタデータ（必須）

テーマCSSには`@theme`メタデータが必要：

```css
/* @theme theme-name */
```

このメタデータがないと、テーマとして認識されません。

### 基本的なテーマCSS例

```css
/* @theme my-theme */

section {
  background-color: #fff;
  color: #333;
  font-size: 24px;
  padding: 60px;
}

h1 {
  color: #1e40af;
  font-size: 48px;
}

h2 {
  color: #3b82f6;
  font-size: 36px;
}
```

## HTML構造

Marpが生成するHTML構造：

```html
<section>
  <h1>スライドタイトル</h1>
  <p>コンテンツ</p>
</section>
```

各スライドは`<section>`要素として生成されます。

## スライドサイズ

### デフォルトサイズ

```css
section {
  width: 1280px;
  height: 720px;
}
```

16:9比率（1280x720）がデフォルト。

### カスタムサイズの定義

```css
/* @theme my-theme */
/* @size 4:3 960px 720px */

section {
  width: 960px;
  height: 720px;
}
```

`@size`メタデータでカスタムサイズを定義できます。

## ページネーション

ページ番号のスタイリング：

```css
section::after {
  content: attr(data-marpit-pagination) ' / ' attr(data-marpit-pagination-total);
  position: absolute;
  right: 30px;
  bottom: 20px;
  font-size: 16px;
  color: #666;
}
```

**利用可能な属性**:
- `data-marpit-pagination` - 現在のページ番号
- `data-marpit-pagination-total` - 総ページ数

## ヘッダーとフッター

### ヘッダー

```css
header {
  position: absolute;
  top: 30px;
  left: 60px;
  right: 60px;
  font-size: 18px;
  color: #666;
}
```

### フッター

```css
footer {
  position: absolute;
  bottom: 30px;
  left: 60px;
  right: 60px;
  font-size: 18px;
  color: #666;
}
```

## テーマの拡張と継承

### @importでの読み込み

```css
/* @theme my-extended-theme */

@import 'default';

section {
  background-color: #f0f0f0;
}
```

既存のテーマを拡張できます。

### @import-themeで名前付きテーマを継承

```css
/* @theme my-theme */

@import-theme 'default';

h1 {
  color: red;
}
```

`@import-theme`を使用すると、テーマ名で読み込めます。

## クラスベースのバリエーション

### leadクラス（タイトルスライド）

```css
section.lead {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
}

section.lead h1 {
  font-size: 64px;
}
```

### invertクラス（反転配色）

```css
section.invert {
  background-color: #000;
  color: #fff;
}

section.invert h1,
section.invert h2 {
  color: #fff;
}
```

## Scoped Style（スライド固有のスタイル）

Markdown内で`<style scoped>`を使用：

```markdown
<style scoped>
section {
  background-color: #e3f2fd;
}
</style>

# このスライドだけ青い背景
```

## 背景画像のスタイリング

背景画像は自動的に処理されますが、CSSで調整可能：

```css
section[data-marpit-background-image] {
  background-size: cover;
  background-position: center;
}
```

## 数式のスタイリング（Marp Core）

```css
.katex {
  font-size: 1.2em;
}

.katex-display {
  margin: 1em 0;
}
```

## リストのスタイリング

```css
ul, ol {
  margin: 0.5em 0;
  padding-left: 1.5em;
}

li {
  margin: 0.3em 0;
}

li::marker {
  color: #3b82f6;
}
```

## テーブルのスタイリング

```css
table {
  border-collapse: collapse;
  width: 100%;
  margin: 1em 0;
}

th, td {
  border: 1px solid #ddd;
  padding: 0.5em 1em;
  text-align: left;
}

th {
  background-color: #f0f0f0;
  font-weight: bold;
}
```

## コードブロックのスタイリング

```css
pre {
  background-color: #f5f5f5;
  border-radius: 4px;
  padding: 1em;
  overflow-x: auto;
}

code {
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
}

pre code {
  background-color: transparent;
  padding: 0;
}
```

## レスポンシブ対応

```css
@media screen and (max-width: 1280px) {
  section {
    font-size: 20px;
  }
  
  h1 {
    font-size: 40px;
  }
}
```

## 実践的なテーマ例

### ミニマルテーマ

```css
/* @theme minimal */

section {
  background-color: #ffffff;
  color: #333333;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  font-size: 24px;
  padding: 80px;
}

h1, h2, h3 {
  font-weight: 300;
  color: #000000;
}

h1 {
  font-size: 60px;
  margin-bottom: 0.5em;
}

h2 {
  font-size: 40px;
  margin-bottom: 0.5em;
}
```

### ダークテーマ

```css
/* @theme dark */

section {
  background-color: #1a1a1a;
  color: #e0e0e0;
  font-size: 22px;
  padding: 60px;
}

h1, h2, h3 {
  color: #61dafb;
}

a {
  color: #61dafb;
}

code {
  background-color: #2d2d2d;
  color: #61dafb;
}
```

## Markdown内でのスタイル埋め込み

```markdown
---
marp: true
---

<style>
section {
  background-color: #f8f8f4;
  font-family: 'Noto Sans JP', sans-serif;
}

h1 {
  color: #4f86c6;
}
</style>

# スライド
```

この方法でテーマを使わずにカスタムスタイルを適用できます。

## ベストプラクティス

1. **コントラストを確保**: 背景とテキストの色のコントラスト比を4.5:1以上に
2. **適切なフォントサイズ**: 本文22-24px、タイトル40-60px程度
3. **余白を十分に**: パディング60px以上推奨
4. **フォールバックフォント**: Web Fontが読み込めない場合のシステムフォントを指定
5. **印刷対応**: `@media print`で印刷用スタイルも定義

## 公式リファレンス

詳細は公式ドキュメントを参照：
- **Theme CSS**: https://marpit.marp.app/theme-css
- **Marpit API**: https://marpit-api.marp.app/
- **公式テーマ実装**: https://github.com/marp-team/marp-core/tree/main/themes