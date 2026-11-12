#import "lib.typ": (
  appendix, card, colors, conference-theme, config-info, fplot, keybox,
  lead, sample, takeaway, title-slide,
)

#show: conference-theme.with(
  config-info(
    title: [観測データから信号を推定する],
    subtitle: [Estimating a Signal from Observations],
    author: [発表者名],
    institution: [所属],
  ),
  footer: [研究発表],
)

#title-slide(event: [研究室セミナー])

= 背景

== 観測には雑音が含まれる

#lead[観測から，雑音のない信号を推定する．]

#grid(
  columns: (1fr, 1fr),
  column-gutter: 32pt,
  card(title: [観測], tone: "accent")[
    信号 $x$ と雑音 $epsilon$ の和を測定する．
  ],
  card(title: [推定], tone: "primary")[
    観測 $y$ を使って信号 $x$ を求める．
  ],
)

#v(1fr)
#takeaway[信号と雑音の違いを利用すると，推定に役立つ．]

= 方法

== 推定値を参照値と比較する

#grid(
  columns: (1fr, 1fr),
  column-gutter: 32pt,
  align: horizon,
  keybox(title: [観測モデル])[
    $ y = x + epsilon $
  ],
  align(center, fplot(
    width: 245pt,
    height: 180pt,
    xticks: (0, .5, 1),
    yticks: (0, .5, 1),
    xlabel: $t$,
    series: (
      (pts: sample(t => t, 0, 1), stroke: (paint: colors.muted, dash: "dashed", thickness: 2pt)),
      (pts: sample(t => t * t, 0, 1), stroke: 2.6pt + colors.primary),
    ),
    labels: (
      (x: .23, y: .39, body: [参照値]),
      (x: .72, y: .34, body: [推定値], fill: colors.primary),
    ),
  )),
)

#show: appendix

== 観測モデルの記号

- $x$ は推定したい信号
- $y$ は観測した値
- $epsilon$ は観測に加わる雑音
