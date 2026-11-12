# Research Slides

日本語の研究発表向け Typst テーマです。16:9 の表紙、章ナビゲーション、本編と付録のページ番号、カード、数式注釈、グラフをまとめています。

## プロジェクトにコピーして使う

このフォルダを新しいプロジェクトにコピーし、`example.typ` をプロジェクト直下の `main.typ` にコピーします。先頭の `"lib.typ"` を `"research-slides/lib.typ"` に変更して、発表情報と本文を書き換えます。

```sh
typst compile main.typ main.pdf
```

サンプルの確認だけなら、親ディレクトリから `typst compile research-slides/example.typ example.pdf` でビルドできます。

## 複数のプロジェクトで共通利用する

`typst info` の **Package path** に `local/research-slides/0.1.0` を作り、このフォルダの中身を配置します。macOS の既定パスにインストールする場合は、このリポジトリのルートで実行します。[Typst のローカルパッケージ仕様](https://github.com/typst/packages#local-packages)

```sh
package_dir="$HOME/Library/Application Support/typst/packages/local/research-slides/0.1.0"
mkdir -p "$package_dir"
cp -R research-slides/. "$package_dir/"
```

新しいプロジェクトでは、サンプル先頭のインポート先を `"@local/research-slides:0.1.0"` に変更します。

## 書き方と設定

| 設定・部品 | 用途 |
| --- | --- |
| `config-info(title: …, subtitle: …, author: …, institution: …)` | 表紙の情報 |
| `conference-theme.with(…, footer: [発表名])` | テーマを適用。フッタは省略可。既定の言語は `lang: "ja"`、付録ラベルは `appendix-label: [付録]` |
| `#title-slide(event: [イベント名])` | 表紙を挿入。表紙とイベント名は省略可 |
| `= 章名` と `== スライド見出し` | 章ナビゲーションと各スライド。章を設けない場合は `==` から始める |
| `#show: appendix` | 以降の `==` を付録として扱う。付録の番号は A1 から始まり、本編の総枚数には含まれない |
| `lead`、`card`、`keybox`、`takeaway` | 冒頭の要点、比較、強調枠、末尾の結論 |
| `note`、`caption`、`tag`、`hl`、`warning` | 補足、図の説明、ラベル、強調、注意 |
| `eqsize`、`pri`、`acc`、`markp`、`marka`、`markm`、`annot` | 数式のサイズ、着色、ハイライトと注釈 |
| `node`、`fplot`、`sample` | ブロック図の箱、グラフ描画、関数のサンプリング |

配色・文字サイズ・フォントは `theme.typ` の `colors`・`sizes`・`fonts` で管理します。`size-scale` で絶対指定の文字サイズをまとめて調整できます。プロジェクトごとに見た目を変える場合は、コピーしたテーマを編集します。

Typst 0.15.1、Touying 0.7.4、mannot 0.4.0 を使います。初回のビルド時に Typst が依存パッケージを取得します。和文の第一候補は Noto Sans CJK JP、数式は New Computer Modern Math です。
