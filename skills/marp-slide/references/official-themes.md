# Marp 公式テーマリファレンス

Marp Coreに含まれる3つの公式テーマの解説。

公式実装: https://github.com/marp-team/marp-core/tree/main/themes

## 公式テーマ一覧

1. **default** - シンプルで汎用的なテーマ
2. **gaia** - モダンでカラフルなテーマ
3. **uncover** - ミニマルでエレガントなテーマ

## Default テーマ

### 特徴

- **配色**: 白背景、黒テキスト、青アクセント
- **フォント**: シンプルなサンセリフ
- **用途**: 汎用的なプレゼンテーション
- **スタイル**: 清潔、読みやすい

### 使用方法

```markdown
---
marp: true
theme: default
---

# タイトル

コンテンツ
```

### 利用可能なクラス

#### lead（タイトルスライド）

```markdown
<!-- _class: lead -->

# プレゼンテーション

副題や説明
```

中央寄せ、大きなテキスト。

#### invert（反転配色）

```markdown
<!-- _class: invert -->

# 黒背景・白文字
```

背景が黒、テキストが白に反転。

#### 組み合わせ

```markdown
<!-- _class: lead invert -->

# 反転タイトルスライド
```

複数のクラスを同時に適用可能。

### カスタマイズ例

```markdown
---
theme: default
---

<style>
section {
  background-color: #f5f5f5;
}

h1 {
  color: #1e40af;
}
</style>
```

## Gaia テーマ

### 特徴

- **配色**: カラフル、鮮やかなアクセントカラー
- **フォント**: モダンなサンセリフ
- **用途**: クリエイティブなプレゼン、デザイン発表
- **スタイル**: 活気的、視覚的に魅力的

### 使用方法

```markdown
---
marp: true
theme: gaia
---

# タイトル
```

### カラーバリエーション

Gaiaテーマは複数の配色を持ちます：

```markdown
<!-- _class: lead -->
# デフォルト配色

---

<!-- _class: lead invert -->
# 反転配色

---

<!-- _class: lead gaia -->
# Gaia配色
```

### 特徴的なスタイル

- **グラデーション背景**: タイトルスライドで使用
- **カラフルなアクセント**: 見出しやリンク
- **大きなタイポグラフィ**: インパクトのある見出し

### カスタマイズ例

```markdown
---
theme: gaia
---

<style>
section {
  --color-background: #fff;
  --color-foreground: #333;
  --color-highlight: #e91e63;
}
</style>
```

## Uncover テーマ

### 特徴

- **配色**: ミニマル、白または黒ベース
- **フォント**: エレガントなセリフフォント
- **用途**: フォーマルなプレゼン、学術発表
- **スタイル**: 洗練、シンプル、エレガント

### 使用方法

```markdown
---
marp: true
theme: uncover
---

# タイトル
```

### 利用可能なクラス

#### lead（タイトルスライド）

```markdown
<!-- _class: lead -->

# プレゼンテーション
```

中央寄せ、大きなセリフフォント。

#### invert（反転配色）

```markdown
<!-- _class: invert -->

# 黒背景のスライド
```

黒背景、白文字。

### 特徴的なスタイル

- **セリフフォント**: 見出しに使用
- **広い余白**: ミニマルなレイアウト
- **中央寄せ**: コンテンツが中央に配置される傾向

### カスタマイズ例

```markdown
---
theme: uncover
---

<style>
section {
  font-family: 'Georgia', serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}
</style>
```

## テーマ比較表

| 特徴 | default | gaia | uncover |
|------|---------|------|---------|
| **背景色** | 白 | カラフル | 白/黒 |
| **フォント** | サンセリフ | サンセリフ | セリフ |
| **配色** | シンプル | 鮮やか | ミニマル |
| **用途** | 汎用 | クリエイティブ | フォーマル |
| **スタイル** | 清潔 | 活気的 | エレガント |

## クラスの共通仕様

すべての公式テーマで使用可能：

### lead

```markdown
<!-- _class: lead -->
```

- タイトルスライド用
- 中央寄せ
- 大きなテキスト
- フッター/ページ番号を非表示

### invert

```markdown
<!-- _class: invert -->
```

- 配色を反転
- 背景とテキストの色を入れ替え
- ダークモード風

## テーマ選択のガイドライン

### defaultを選ぶべき場合

- 汎用的なプレゼンテーション
- ビジネス用途
- シンプルで読みやすいデザインが必要
- カスタマイズの基盤として使用

### gaiaを選ぶべき場合

- クリエイティブなプレゼン
- デザイン関連の発表
- 若い世代向け
- 視覚的なインパクトが必要

### uncoverを選ぶべき場合

- フォーマルなプレゼン
- 学術発表
- ミニマルなデザイン志向
- エレガントな印象を与えたい

## カスタムテーマとの組み合わせ

### 公式テーマを拡張

```css
/* @theme my-custom-default */

@import-theme 'default';

section {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

h1 {
  color: #1e3a8a;
}
```

### 複数テーマの切り替え

```markdown
---
marp: true
theme: default
---

# セクション1（defaultテーマ）

---

<!-- theme: gaia -->

# セクション2（gaiaテーマ）

---

<!-- theme: uncover -->

# セクション3（uncoverテーマ）
```

注：同一ファイル内でのテーマ切り替えは限定的なサポート。

## 実践例

### defaultテーマの活用

```markdown
---
marp: true
theme: default
paginate: true
---

<!-- _class: lead -->

# プロジェクト報告

2024年10月

---

## アジェンダ

1. 進捗状況
2. 課題と対策
3. 今後の予定

---

## 進捗状況

- タスクA: 完了
- タスクB: 進行中
- タスクC: 予定通り
```

### gaiaテーマの活用

```markdown
---
marp: true
theme: gaia
---

<!-- _class: lead -->

# 新製品発表

革新的なデザイン

---

## コンセプト

**3つの柱**

1. 🎨 美しさ
2. 🚀 速さ
3. 💡 使いやすさ
```

### uncoverテーマの活用

```markdown
---
marp: true
theme: uncover
---

<!-- _class: lead -->

# 研究発表

深層学習の応用

---

## 研究背景

近年の技術発展により...

---

<!-- _class: invert -->

## 実験結果

精度: 95.3%
```

## 公式リファレンス

- **公式テーマ実装**: https://github.com/marp-team/marp-core/tree/main/themes
- **Marp Core README**: https://github.com/marp-team/marp-core
- **テーマCSS仕様**: https://marpit.marp.app/theme-css