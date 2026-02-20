# Marp 基本構文リファレンス

公式ドキュメントに基づくMarpの基本的な書き方。

## フロントマター（Directives）

### 基本構造

```markdown
---
marp: true
theme: default
paginate: true
---
```

### 主要なグローバルディレクティブ

| ディレクティブ | 説明 | 値の例 |
|------------|------|-------|
| `marp` | Marp機能の有効化 | `true` |
| `theme` | テーマの指定 | `default`, `gaia`, `uncover` |
| `size` | スライドサイズ（Marp Core拡張） | `16:9`, `4:3`, `A4` |
| `paginate` | ページ番号の表示 | `true`, `false` |
| `header` | 全スライドのヘッダー | 任意のテキスト |
| `footer` | 全スライドのフッター | 任意のテキスト |
| `backgroundColor` | 背景色 | `#fff`, `white` |
| `backgroundImage` | 背景画像 | `url('image.png')` |
| `color` | テキスト色 | `#000`, `black` |
| `class` | CSSクラスの適用 | `lead`, `invert` |

### サイズディレクティブ（Marp Core）

```markdown
---
size: 16:9
---
```

利用可能なサイズ：
- `16:9` (1280x720, デフォルト)
- `4:3` (960x720)
- `A4` (210mm x 297mm)

### ページ固有のディレクティブ

スライドごとに設定を変更する場合、`<!-- ディレクティブ名: 値 -->`形式で記述：

```markdown
<!-- _class: lead -->
<!-- _backgroundColor: black -->
<!-- _color: white -->

# このスライドだけ適用
```

**アンダースコア `_` の意味**：
- `_`なし：以降の全スライドに適用
- `_`あり：現在のスライドのみ適用

## スライドの区切り

```markdown
---

# 最初のスライド

---

# 次のスライド

---
```

`---`（水平線）で新しいスライドに切り替わります。

## ヘッダーとフッター

### グローバル設定

```markdown
---
header: '講義名'
footer: '2024年10月'
---
```

### スライドごとの設定

```markdown
<!-- header: 'セクション1' -->
<!-- footer: 'ページ番号表示' -->
```

### 無効化

```markdown
<!-- header: '' -->
<!-- footer: '' -->
```

## ページネーション（ページ番号）

```markdown
---
paginate: true
---
```

テーマによって表示位置やスタイルが異なります。

特定のスライドで非表示：
```markdown
<!-- paginate: false -->
```

または：
```markdown
<!-- _paginate: false -->
```

## インラインスタイル

### Markdown内でのスタイル指定

```markdown
---
marp: true
---

<style>
section {
  background-color: #f0f0f0;
}

h1 {
  color: #333;
}
</style>

# スライド
```

### Scoped Style

特定のスライドのみにスタイルを適用：

```markdown
<style scoped>
h1 {
  color: red;
}
</style>

# このスライドだけ赤い見出し
```

## 数式（Marp Core拡張）

Pandoc形式の数式をサポート：

### インライン数式

```markdown
$E = mc^2$
```

### ブロック数式

```markdown
$$
\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}
$$
```

## 絵文字（Marp Core拡張）

```markdown
:smile: :+1: :sparkles:
```

GitHub Emoji記法をサポート。

## コメント

HTMLコメントはレンダリングされません：

```markdown
<!-- これはコメントです -->
```

ディレクティブもコメント形式で記述：

```markdown
<!-- _class: lead -->
```

## 公式リファレンスリンク

詳細は公式ドキュメントを参照：

- **Directives一覧**: https://marpit.marp.app/directives
- **Marp Core機能**: https://github.com/marp-team/marp-core
- **Theme CSS仕様**: https://marpit.marp.app/theme-css
- **公式サイト**: https://marp.app/

## よくある設定例

### 基本設定

```markdown
---
marp: true
theme: default
size: 16:9
paginate: true
---
```

### タイトルスライド

```markdown
---
marp: true
theme: default
---

<!-- _class: lead -->
<!-- _paginate: false -->

# プレゼンテーションタイトル

発表者名
```

### セクション区切り

```markdown
<!-- _class: lead -->

# 第2章

新しいセクション

---

## 通常のスライド
```

### カスタム背景色

```markdown
<!-- _backgroundColor: #e3f2fd -->

# 明るい青背景のスライド
```
