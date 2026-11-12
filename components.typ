#import "theme.typ": colors, sizes, fonts
#import "@preview/mannot:0.4.0": markhl, annot as mannot-annot

// ---- 文字の強さ -------------------------------------------------------------
#let note(body) = text(size: sizes.note, fill: colors.muted, body)
#let caption(body) = text(size: sizes.caption, fill: colors.muted, body)
#let warning(body) = text(fill: colors.accent, weight: "bold", body)
#let hl(body) = text(fill: colors.primary, weight: "bold", body)

// 別行立ての数式の大きさを個別に変える：#eqsize(sizes.display)[$ ... $]
// （text(size:) では別行数式の既定サイズに上書きされるため）
#let eqsize(size, body) = {
  show math.equation.where(block: true): set text(size: size)
  body
}

// ---- 数式への印と注釈（mannot）------------------------------------------------
// 印：$markp(x, #<x>)$ のように数式内で使う（タグは後の注釈用）
//   markp：主役（紺）／ marka：強調・注意（橙）／ markm：補助（灰）
#let _mark-fill(c) = c.transparentize(86%)
#let markp = markhl.with(color: colors.primary, fill: _mark-fill(colors.primary), radius: 3pt)
#let marka = markhl.with(color: colors.accent, fill: _mark-fill(colors.accent), radius: 3pt)
#let markm = markhl.with(color: colors.muted, fill: _mark-fill(colors.muted), radius: 3pt)
// 注釈：印を付けたのと同じ数式ブロックの中で #annot(<x>)[説明] と書く
// 注釈は数式のレイアウトに影響しないので，前後の余白は #v() で確保する
#let annot = mannot-annot.with(
  annot-text-props: (font: fonts.sans, size: sizes.annot, weight: "medium"),
  annot-par-props: (leading: .35em),
  leader-stroke: .05em,
)

// 数式の中で一部に色を付ける（入れ子の数式を作らないので大きさが変わらない）
// 例：$x + acc(y)$
#let acc(body) = text(fill: colors.accent, body)
#let pri(body) = text(fill: colors.primary, body)

// スライド冒頭の一文（このスライドで言いたいこと）
#let lead(body) = block(below: 14pt, text(size: sizes.lead, weight: "medium", body))

// 小さなラベル（「事前知識：…」など）。装飾なしの色文字
#let tag(body, fill: colors.primary) = text(size: sizes.tag, weight: "bold", fill: fill, body)

// ---- 枠 ------------------------------------------------------------------
// 情報のまとまり。背景色や角丸は使わず，見出しの上の罫線だけで区切る。
// tone: "primary" | "accent" | "plain"（罫線と見出しの色）
// rule: false で見出し上の罫線を消す
#let card(title: none, tone: "plain", height: auto, rule: true, body) = {
  let color = if tone == "primary" { colors.primary } else if tone == "accent" { colors.accent } else { colors.text }
  block(
    width: 100%,
    height: height,
    stroke: if rule { (top: 1.4pt + color) } else { none },
    inset: (top: 8pt, bottom: 2pt),
    {
      if title != none {
        block(below: 10pt, text(size: sizes.card, weight: "bold", fill: color, title))
      }
      set text(size: sizes.card)
      show math.equation.where(block: true): set text(size: sizes.math-block-small)
      body
    },
  )
}

// 定理・問いなど，一番目立たせたい枠。細い罫線の囲みと太字の見出しだけ
#let keybox(title: none, body) = block(
  width: 100%,
  stroke: 1pt + colors.primary,
  inset: (x: 18pt, y: 12pt),
  {
    if title != none {
      block(below: 12pt, text(size: sizes.card, weight: "bold", fill: colors.primary, title))
    }
    body
  },
)

// スライド末尾の結論。太字の一文を細い罫線の下に置く
#let takeaway(body) = block(
  width: 100%,
  stroke: (top: .8pt + colors.rule),
  inset: (top: 10pt),
  text(weight: "bold", body),
)

// 横に並ぶ処理の流れ（ブロック図）
#let node(body, fill: colors.background, stroke: colors.text, width: auto) = box(
  width: width,
  inset: (x: 8pt, y: 8pt),
  fill: fill,
  stroke: 1pt + stroke,
  align(center, body),
)
// ---- グラフ（Typstで直接描画） ---------------------------------------------
// series: ((pts: ((x, y), ...), stroke: ...), ...)
// dots:   ((x: , y: , fill: , stroke: ), ...)
// labels: ((x: , y: , body: , anchor: ), ...)
// areas:  ((pts: ((x, y), ...), fill: ...), ...)  塗りつぶす多角形（軸より先に描く）
#let fplot(
  width: 300pt,
  height: 180pt,
  xlim: (0, 1),
  ylim: (0, 1),
  xticks: (),
  yticks: (),
  series: (),
  dots: (),
  labels: (),
  areas: (),
  xlabel: none,
  ylabel: none,
  axes-at-zero: true,
) = {
  let px(x) = (x - xlim.at(0)) / (xlim.at(1) - xlim.at(0)) * width
  let py(y) = height - (y - ylim.at(0)) / (ylim.at(1) - ylim.at(0)) * height
  let ax = if axes-at-zero { calc.clamp(0, xlim.at(0), xlim.at(1)) } else { xlim.at(0) }
  let ay = if axes-at-zero { calc.clamp(0, ylim.at(0), ylim.at(1)) } else { ylim.at(0) }
  set text(size: sizes.plot-tick, fill: colors.muted)
  box(width: width, height: height, inset: 0pt, {
    // 塗り
    for a in areas {
      let pts = a.pts.map(((x, y)) => (px(x), py(y)))
      place(curve(
        fill: a.fill,
        stroke: none,
        curve.move(pts.first()),
        ..pts.slice(1).map(p => curve.line(p)),
        curve.close(),
      ))
    }
    // 補助線
    for x in xticks {
      place(line(start: (px(x), 0pt), end: (px(x), height), stroke: .5pt + colors.rule))
      place(dx: px(x) - 20pt, dy: height + 4pt, box(width: 40pt, align(center, $#x$)))
    }
    for y in yticks {
      place(line(start: (0pt, py(y)), end: (width, py(y)), stroke: .5pt + colors.rule))
      place(dx: -44pt, dy: py(y) - 8pt, box(width: 38pt, align(right, $#y$)))
    }
    // 軸
    place(line(start: (0pt, py(ay)), end: (width, py(ay)), stroke: 1pt + colors.muted))
    place(line(start: (px(ax), 0pt), end: (px(ax), height), stroke: 1pt + colors.muted))
    if xlabel != none {
      place(dx: width + 4pt, dy: py(ay) - 10pt, text(size: sizes.plot-label, fill: colors.text, xlabel))
    }
    if ylabel != none {
      place(dx: px(ax) + 6pt, dy: -6pt, text(size: sizes.plot-label, fill: colors.text, ylabel))
    }
    // 曲線
    for s in series {
      let pts = s.pts.map(((x, y)) => (px(x), py(y)))
      place(curve(
        stroke: s.at("stroke", default: 2.6pt + colors.primary),
        curve.move(pts.first()),
        ..pts.slice(1).map(p => curve.line(p)),
      ))
    }
    for d in dots {
      let r = d.at("r", default: 4.5pt)
      place(dx: px(d.x) - r, dy: py(d.y) - r, circle(
        radius: r,
        fill: d.at("fill", default: colors.primary),
        stroke: d.at("stroke", default: none),
      ))
    }
    for l in labels {
      let w = 200pt
      let anchor = l.at("anchor", default: "left")
      let dx = if anchor == "left" { px(l.x) } else if anchor == "right" { px(l.x) - w } else { px(l.x) - w / 2 }
      let al = if anchor == "left" { left } else if anchor == "right" { right } else { center }
      place(dx: dx, dy: py(l.y) - 10pt, box(width: w, align(al, text(size: sizes.plot-annotation, fill: l.at("fill", default: colors.text), l.body))))
    }
  })
}

#let sample(f, a, b, n: 200) = range(n + 1).map(i => {
  let x = a + (b - a) * i / n
  (x, f(x))
})
