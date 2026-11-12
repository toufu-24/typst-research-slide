#import "@preview/touying:0.7.4": (
  config-colors,
  config-common,
  config-page,
  touying-slide,
  touying-slide-wrapper,
  touying-slides,
  utils,
)

// ---- 配色 ---------------------------------------------------------------
#let colors = (
  // 背景・本文・主題・強調の 4 色を軸に，補足や区切りには灰色を使う。
  background: rgb("F8F7F3"),
  text: rgb("25282C"),       // 本文：墨色
  primary: rgb("#294b88"),   // 主題（紺）
  primary-light: rgb("E7EDF4"),
  accent: rgb("A64D19"),     // 強調（橙）
  accent-light: rgb("F5E7DB"),
  muted: rgb("505861"),
  rule: rgb("D4D7DA"),
  panel: rgb("F3F3F3"),
)

// ---- 文字サイズ ------------------------------------------------------------
// 全体を一括で拡大・縮小する倍率（1 = 現在の大きさ）
#let size-scale = 1

#let sizes = (
  // 全体の基準
  body: 24pt,              // 本文
  math-block: 30pt,        // 別行立ての数式
  math-inline: 1.1em,      // 文中の数式（和文に対する相対倍率．欧文数式は同じptだと小さく見える）
  annot: 24pt,             // 数式の注釈（mannot）
  // ヘッダ・フッタ
  heading: 30pt,           // スライドの見出し
  nav: 17pt,             // 上端の章の表示
  page: 30pt,              // 右上のページ番号
  page-total: 18pt,        // 総枚数
  page-appendix: 22pt,     // 付録スライドの番号（A1 など）
  footer: 15pt,          // 左下の発表名
  // 表紙
  cover-event: 15pt,
  cover-title: 36pt,
  cover-subtitle: 25pt,
  cover-author: 30pt,
  cover-institution: 20pt,
  // 部品（components.typ）
  lead: 25pt,              // スライド冒頭の一文
  card: 24pt,              // カードの見出しと本文，定理枠の見出し
  note: 20pt,              // 補足
  caption: 20pt,           // 図の説明・脚注
  tag: 18pt,               // 「事前知識：…」などのラベル
  plot-tick: 16pt,         // グラフの目盛り
  plot-label: 20pt,        // グラフの軸ラベル
  plot-annotation: 18pt,   // グラフ中の注記
  // スライド内で個別に使う大きさ
  display: 38pt,           // 特に大きく見せる式
  symbol-large: 34pt,      // 大きく見せる関係記号
  symbol: 30pt,            // 通常の関係記号
  emphasis: 28pt,          // 強調したい一文
  math-block-small: 27pt,  // 少し小さめの別行数式
  list: 26pt,              // まとめの箇条書き
  table: 22pt,             // 表
  appendix-body: 21pt,     // 付録スライドの本文
  diagram: 22pt,           // ブロック図の箱の中
  compact: 20pt,           // 詰めて書く説明文
  compact-small: 19pt,     // 応用例カードの本文
)
#let sizes = sizes.pairs().map(((k, v)) => (k, if type(v) == length { v * size-scale } else { v })).to-dict()

#let fonts = (
  sans: ("Noto Sans CJK JP", "Hiragino Sans", "Arial"),
  math: "New Computer Modern Math",
)

// ---- ヘッダ：章の進行表示＋見出し ------------------------------------------
// 章（= 見出し）を上端に並べ，現在の章だけ色を塗る
#let section-nav(self, appendix-label) = context {
  set text(size: sizes.nav)
  if self.appendix {
    block(width: 100%, inset: (y: 5pt), stroke: (bottom: .8pt + colors.rule),
      text(weight: "bold", fill: colors.muted, appendix-label))
    return
  }
  let sections = query(heading.where(level: 1))
  if sections.len() == 0 { return }
  let current = utils.current-heading(level: 1)
  grid(
    columns: (1fr,) * sections.len(),
    ..sections.map(h => {
      let active = current != none and h.location() == current.location()
      block(
        width: 100%,
        inset: (y: 5pt),
        fill: if active { colors.primary-light } else { none },
        stroke: (bottom: 1.2pt + if active { colors.primary } else { colors.rule }),
        align(center, text(
          weight: if active { "bold" } else { "regular" },
          fill: if active { colors.primary } else { colors.muted },
          h.body,
        )),
      )
    }),
  )
}

// ページ番号（見出しの右に大きめに表示）。表紙は数えない
#let page-number(self) = context {
  let number = utils.slide-counter.get().first()
  let total = utils.last-slide-counter.final().first()
  if self.appendix {
    text(size: sizes.page-appendix, weight: "bold", fill: colors.muted)[A#(number - total)]
  } else [
    #text(size: sizes.page, weight: "bold", fill: colors.text)[#number]#text(size: sizes.page-total, fill: colors.muted)[~/~#total]
  ]
}

#let slide-heading(self, appendix-label) = {
  section-nav(self, appendix-label)
  v(10pt)
  grid(
    columns: (1fr, auto),
    column-gutter: 16pt,
    align: (left + bottom, right + bottom),
    text(size: sizes.heading, weight: "bold", utils.display-current-heading(level: 2)),
    page-number(self),
  )
  v(6pt)
  line(length: 100%, stroke: .8pt + colors.rule)
  v(12pt)
}

// ---- 表紙 ----------------------------------------------------------------
#let title-slide(event: none) = touying-slide-wrapper(self => {
  touying-slide(
    self: self,
    config: utils.merge-dicts(
      config-page(footer: none, margin: 0pt),
      config-common(subslide-preamble: none, freeze-slide-counter: true),
    ),
  )[
    #pad(x: 72pt)[
      #v(1fr)
      #if event != none and event != [] {
        text(size: sizes.cover-event, fill: colors.muted, event)
        v(14pt)
      }
      #text(size: sizes.cover-title, weight: "bold", fill: colors.primary, self.info.title)
      #if self.info.subtitle != none [
        #v(18pt)
        #text(size: sizes.cover-subtitle, fill: colors.muted, self.info.subtitle)
      ]
      #v(1.2fr)
      #text(size: sizes.cover-author, self.info.author)
      #if self.info.institution != none [
        #v(10pt)
        #text(size: sizes.cover-institution, fill: colors.muted, self.info.institution)
      ]
      #v(1fr)
    ]
  ]
})

// ---- 全体設定 ---------------------------------------------------------------
#let conference-theme(footer: none, lang: "ja", appendix-label: [付録], ..config, body) = {
  set text(font: fonts.sans, size: sizes.body, fill: colors.text, lang: lang)
  set par(leading: .7em, spacing: 16pt)
  set list(spacing: 18pt, marker: text(fill: colors.primary)[▸])
  set enum(spacing: 20pt)
  set math.equation(numbering: none)
  // 周囲の太字にかかわらず，数式内の通常文字と太字を区別する
  show math.equation: it => {
    set text(weight: "regular")
    it
  }
  show math.equation: set text(font: fonts.math)
  show math.equation.where(block: false): set text(size: sizes.math-inline)
  show math.equation.where(block: true): set text(size: sizes.math-block)
  show math.equation.where(block: true): set block(above: 10pt, below: 10pt)
  show strong: set text(fill: colors.primary)

  show: touying-slides.with(
    config-page(
      width: 960pt,
      height: 540pt,
      margin: (x: 44pt, top: 22pt, bottom: 38pt),
      fill: colors.background,
      footer: if footer != none { text(size: sizes.footer, fill: colors.muted, footer) },
      footer-descent: 14pt,
    ),
    config-common(
      subslide-preamble: self => slide-heading(self, appendix-label),
      zero-margin-footer: false,
      show-strong-with-alert: false,
      new-section-slide-fn: none,
    ),
    config-colors(
      primary: colors.primary,
      neutral-darkest: colors.text,
      neutral-lightest: colors.background,
    ),
    ..config,
  )
  body
}
