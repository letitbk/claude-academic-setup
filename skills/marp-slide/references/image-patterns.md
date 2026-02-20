# Marp 画像記法リファレンス

Marpit公式の画像記法に基づく、画像の配置とスタイリング方法。

公式ドキュメント: https://marpit.marp.app/image-syntax

## 基本的な画像挿入

### 通常の画像

```markdown
![](image.png)
![代替テキスト](image.png)
```

画像はコンテンツとして表示されます。

### サイズ指定

Marpでは画像にサイズキーワードを追加可能：

```markdown
![width:600px](image.png)
![height:400px](image.png)
![w:600px h:400px](image.png)
```

**サポートされる単位**:
- `px` - ピクセル
- `%` - パーセント
- `em`, `rem`, `cm`, `mm`, `in`, `pt`, `pc`

**省略形**:
- `w:` = `width:`
- `h:` = `height:`

## 背景画像 (`bg`キーワード)

### 基本的な背景画像

```markdown
![bg](image.png)
```

画像をスライドの背景として配置します。テキストコンテンツと重ならず、背景に配置されます。

### 背景サイズキーワード

```markdown
![bg fit](image.png)
![bg cover](image.png)
![bg contain](image.png)
![bg auto](image.png)
```

| キーワード | 動作 | CSS相当 |
|----------|------|--------|
| `fit` | アスペクト比を保ちスライド内に収める | `background-size: contain` |
| `cover` | アスペクト比を保ちスライド全体を覆う | `background-size: cover` |
| `contain` | `fit`と同じ | `background-size: contain` |
| `auto` | 元のサイズ | `background-size: auto` |

### 背景サイズ（数値指定）

```markdown
![bg 80%](image.png)
![bg 1280px](image.png)
![bg 50% 80%](image.png)
```

CSSの`background-size`プロパティと同じ構文をサポート。

## 分割背景（Split Backgrounds）

複数の背景画像を使って画面を分割できます。

### 基本的な分割

```markdown
![bg](image1.png)
![bg](image2.png)
```

2つの画像が左右に分割表示されます。

### 3分割以上

```markdown
![bg](image1.png)
![bg](image2.png)
![bg](image3.png)
```

3つ以上の画像は等分に分割されます。

### 分割方向の指定

デフォルトは水平分割（horizontal）ですが、垂直分割も可能：

```markdown
![bg vertical](image1.png)
![bg](image2.png)
```

`vertical`キーワードで垂直分割に変更。

### 左右の配置指定

```markdown
![bg left](image.png)
```

画像を左側に配置し、右側にテキストスペースを確保。

```markdown
![bg right](image.png)
```

画像を右側に配置し、左側にテキストスペースを確保。

### サイズ比率の指定

```markdown
![bg left:33%](image.png)
```

左側33%に画像、右側67%にテキストスペース。

```markdown
![bg right:60%](image.png)
```

右側60%に画像、左側40%にテキストスペース。

## フィルター効果

### 明度調整

```markdown
![brightness:0.5](image.png)
![brightness:1.5](image.png)
```

値の範囲: 0（真っ黒）〜 1（通常）〜 2以上（明るく）

### コントラスト

```markdown
![contrast:0.8](image.png)
![contrast:1.5](image.png)
```

### ぼかし

```markdown
![blur:10px](image.png)
```

### グレースケール

```markdown
![grayscale](image.png)
![grayscale:1](image.png)
```

値の範囲: 0（カラー）〜 1（完全なグレースケール）

### セピア

```markdown
![sepia](image.png)
![sepia:0.8](image.png)
```

### 色相回転

```markdown
![hue-rotate:180deg](image.png)
```

### 反転

```markdown
![invert](image.png)
![invert:0.8](image.png)
```

### 透明度

```markdown
![opacity:0.5](image.png)
```

### 彩度

```markdown
![saturate:2](image.png)
```

### 複数のフィルター

```markdown
![brightness:1.2 contrast:1.1 saturate:1.3](image.png)
```

## 実用的なパターン例

### パターン1: 左にテキスト、右に画像

```markdown
## プロダクト紹介

![bg right:40%](product.png)

- 特徴1
- 特徴2
- 特徴3
```

### パターン2: 背景画像 + オーバーレイテキスト

```markdown
![bg brightness:0.5](hero.png)

# キャッチコピー

サブテキスト
```

暗くした背景の上に白いテキストを配置。

### パターン3: 複数画像の比較

```markdown
![bg left:50%](before.png)
![bg right:50%](after.png)
```

Before/Afterを左右に並べる。

### パターン4: 縦並び比較

```markdown
![bg vertical](image1.png)
![bg](image2.png)
```

上下に画像を配置。

### パターン5: サイズ指定した通常画像

```markdown
## 図解

![w:600px](diagram.png)

上記の図は...
```

### パターン6: 3分割レイアウト

```markdown
![bg](image1.png)
![bg](image2.png)
![bg](image3.png)
```

### パターン7: フィルター効果を使った背景

```markdown
![bg blur:5px brightness:0.7](background.png)

# 見やすいテキスト

ぼかしと暗さで背景を控えめに
```

## 注意事項

1. **背景画像とテキスト**: `![bg]`画像は背景レイヤーに配置され、テキストと重なりません
2. **複数背景の順序**: 記述順に左から右（または上から下）に配置されます
3. **フィルター対応**: すべてのフィルターがすべての環境で動作するとは限りません
4. **相対パス**: 画像パスはMarkdownファイルからの相対パスで指定

## 公式リファレンス

詳細は公式ドキュメントを参照：
- **Image syntax**: https://marpit.marp.app/image-syntax
