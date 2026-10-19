# 约定（conventions）

本文件记录 lean4-occult **自己选定**的编码约定。它们是实现选择，不是对传统
文献的引用。任何一处约定被改动，都必须同步修改对应的定理。

## 1. 索引与顺序

### 天干

| 索引 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 天干 | 甲 | 乙 | 丙 | 丁 | 戊 | 己 | 庚 | 辛 | 壬 | 癸 |

### 地支

| 索引 | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 地支 | 子 | 丑 | 寅 | 卯 | 辰 | 巳 | 午 | 未 | 申 | 酉 | 戌 | 亥 |

两个顺序都取常见的通行排列；本库只依赖“这是一个固定顺序”，
不依赖任何文献出处。

### 五行

| 索引 | 0 | 1 | 2 | 3 | 4 |
| --- | --- | --- | --- | --- | --- |
| 五行 | 木 | 火 | 土 | 金 | 水 |

`WuXing.next` = 索引 `+1 (mod 5)`（相生），
`WuXing.overcomes` = 索引 `+2 (mod 5)`（相克）。
这两个方向是**定义**，不是定理；若要改成相反方向，只需替换定义并重跑证明。

逆向映射同样是定义：

* `WuXing.prev` = 索引 `−1 (mod 5)`，即“谁生我”；`prev x` 生 `x`。
* `WuXing.overcomeBy` = 索引 `−2 (mod 5)`，即“谁克我”；`overcomeBy x` 克 `x`。
* 等价关系式：`next x = y ↔ x = prev y`（`next_eq_iff_prev`）、
  `overcomes x = y ↔ x = overcomeBy y`（`overcomes_eq_iff_overcomeBy`）。
* `prev` 与 `overcomeBy` 都是无不动点的 5 阶置换（`prev_five`、`overcomeBy_five`）。

### 天干与五行（项目约定）

| 天干 | 甲 | 乙 | 丙 | 丁 | 戊 | 己 | 庚 | 辛 | 壬 | 癸 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 五行 | 木 | 木 | 火 | 火 | 土 | 土 | 金 | 金 | 水 | 水 |

即 `TianGan.wuXing` 的序号是 `toNat / 2`（`wuXing_toFin`）。这是**编码约定**，
不是文献引文（见 `docs/sources.md`）。

### 地支本气与五行（项目约定，**不是藏干**）

| 地支 | 子 | 丑 | 寅 | 卯 | 辰 | 巳 | 午 | 未 | 申 | 酉 | 戌 | 亥 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 本气五行 | 水 | 土 | 木 | 木 | 土 | 火 | 火 | 土 | 金 | 金 | 土 | 水 |

* `DiZhi.wuXing` 只给出**单一本气**，逐项展开见 `DiZhi.wuXing_toFin`。
* **藏干**（含中气、余气）——即一个地支对应多个天干——**不在本库范围内**，
  本库也不对它作任何断言。见 `docs/sources.md` 第 2 节。

## 2. 阴阳

* `YinYang.yin` / `YinYang.yang` 两个构造子。
* `YinYang.neg` 是对合（`neg_neg`），无不动点（`neg_ne_self`）。
* `YinYang.ofParity n`：`n % 2 = 0` 记为**阳**，否则记为**阴**。
  这是一条纯编码约定（见 `ofParity_eq_iff`），本库不对“奇偶=阴阳”作任何
  经验主张。
* 天干、地支的 `yinYang` 一律由 `ofParity ∘ toNat` 定义，因此
  “同阴阳” ⇔ “序号同奇偶”（`TianGan.yinYang_eq_iff`、`DiZhi.yinYang_eq_iff`）。

由此得到的配对表（由约定推出，不是引文）：

* 阳干：甲(0)、丙(2)、戊(4)、庚(6)、壬(8)
* 阴干：乙(1)、丁(3)、己(5)、辛(7)、癸(9)
* 阳支：子(0)、寅(2)、辰(4)、午(6)、申(8)、戌(10)
* 阴支：丑(1)、卯(3)、巳(5)、未(7)、酉(9)、亥(11)

## 3. 六十甲子

`JiaZi` 定义为结构体：

```lean
structure JiaZi where
  stem : TianGan
  branch : DiZhi
  parity : stem.toNat % 2 = branch.toNat % 2
```

即只接受**同阴阳**的干支组合，共 10 × 12 / 2 = 60 种
（`card_sameParity_pairs`）。

* 索引 0 = 甲子（`JiaZi.jiaZi`），索引 59 = 癸亥（`JiaZi.guiHai`）。
* 索引 `n` 的天干序号 = `n % 10`，地支序号 = `n % 12`
  （`stem_toNat_ofIndex`、`branch_toNat_ofIndex`）。
* 索引由 `JiaZi.crt` 计算：

  ```lean
  crt a b = (a + 10 * ((5 * ((b + 12 - a) / 2)) % 6)) % 60
  ```

  其正确性由 `crt_spec` 给出：对同奇偶的 `a < 10`、`b < 12`，
  `crt a b < 60` 且 `crt a b % 10 = a`、`crt a b % 12 = b`。
  唯一性由 `index_unique` 给出。
* `JiaZi.next` = 索引 `+1 (mod 60)`，对应“天干、地支各前进一位”。
* `JiaZi.prev` = 索引 `−1 (mod 60)`，对应“天干、地支各后退一位”；
  `prev_next` 与 `next_prev` 证明二者互逆，`prev_period_iff` 给出其最小正周期也是 60。

## 4. 周期 vs 最小周期

这两个概念在本库中严格区分：

| 概念 | 陈述 | 定理 |
| --- | --- | --- |
| 60 是周期 | `next^[60] z = z` | `JiaZi.next_sixty` |
| 最小正周期是 60 | `next^[n] z = z ↔ 60 ∣ n` | `JiaZi.next_period_iff` |
| 没有更小的正周期 | `0 < k < 60 → next^[k] 甲子 ≠ 甲子` | `JiaZi.next_min_period` |

五行同理：`next_five` 是周期，`next_period_iff`（`5 ∣ n`）才是最小正周期。

另一个等价刻画：`JiaZi.next_injective`（`next` 是单射）与
`JiaZi.next_iterate_injective`（从甲子出发的前 60 步两两不同），
合起来说明六十甲子确实构成一个长度为 60 的单一循环，而不是若干短循环的并。

`next_period_iff` 的证明走索引：`next^[n]` 在 `Fin 60` 上是加 `n` 再取模，
因此回到原点当且仅当 `60 ∣ n`；对五行同理（模 5）。没有使用任何枚举式的
“检查所有 60 个元素”来代替一般性论证。

## 5. 字符串与 CLI

* `TianGan.toChar` / `DiZhi.toChar` 给出单个汉字字符，
  `ofChar` 是其逆（`ofChar_toChar`）。
* `name` 只由 `toChar` 拼接，`parse` 只接受**单个**字符；
  `JiaZi.parse?` 只接受**两个**字符，且要求同阴阳，否则返回 `none`。
* CLI 的 `cycle` 只接受 ASCII 十进制、且 `0 ≤ n < 60`。
* 输出中的“阴/阳”由 `YinYang` 直接映射，不做额外解释。
