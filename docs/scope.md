# 范围与定理清单（scope）

v0.1 只做有限组合结构与可证明性质。本文件是 `PLAN.md` 的细化，列出全部
theorem/lemma，便于审阅覆盖面。

## 1. 范围内

### 数据类型

| 类型 | 文件 | 元素数 | 等价于 |
| --- | --- | --- | --- |
| `YinYang` | `Occult/YinYang.lean` | 2 | `Fin 2` |
| `WuXing` | `Occult/WuXing.lean` | 5 | `Fin 5` |
| `TianGan` | `Occult/TianGan.lean` | 10 | `Fin 10` |
| `DiZhi` | `Occult/DiZhi.lean` | 12 | `Fin 12` |
| `JiaZi` | `Occult/JiaZi.lean` | 60 | `Fin 60` |
| `parseNat?` | `Occult/Cli.lean` | — | 非空 ASCII 十进制解析 |

### 结构映射

| 映射 | 定义 | 关键定理 |
| --- | --- | --- |
| 阴阳取反 | `YinYang.neg` | `neg_neg`、`neg_injective`、`neg_ne_self` |
| 奇偶编码 | `YinYang.ofParity` | `ofParity_eq_iff`、`ofParity_succ`、`ofParity_mod` |
| 五行相生 | `WuXing.next` | `next_five`、`next_period_iff`、`toFin_next` |
| 五行相克 | `WuXing.overcomes` | `overcomes_five`、`overcomes_ne_next`、`toFin_overcomes` |
| 五行相生逆向 | `WuXing.prev` | `prev_next`、`next_prev`、`prev_five`、`next_eq_iff_prev` |
| 五行相克逆向 | `WuXing.overcomeBy` | `overcomeBy_overcomes`、`overcomes_overcomeBy`、`overcomeBy_five`、`overcomes_eq_iff_overcomeBy` |
| 天干五行 | `TianGan.wuXing` | `wuXing_toFin`、`wuXing_eq_iff`、`wuXing_ofNatMod_add_two` |
| 地支本气五行 | `DiZhi.wuXing` | `wuXing_toFin`、`wuXing_ofNatMod_toNat` |
| 干支编码 | `toFin`/`ofFin`/`ofNatMod` | `ofFin_toFin`、`toFin_ofFin`、`ofNatMod_eq_iff` |
| 干支阴阳 | `TianGan.yinYang`/`DiZhi.yinYang` | `yinYang_eq_iff` |
| 甲子索引 | `JiaZi.crt`/`ofIndex`/`toIndex` | `crt_spec`、`toIndex_ofIndex`、`ofIndex_toIndex` |
| 甲子推进 | `JiaZi.next` | `next_sixty`、`next_period_iff`、`next_min_period` |
| 甲子后退 | `JiaZi.prev` | `prev_next`、`next_prev`、`prev_sixty`、`prev_period_iff` |
| 同阴阳配对 | `JiaZi.sameParityEquiv` | `card_sameParity_pairs`、`existsUnique_index` |
| 解析/打印 | `toChar`/`ofChar`/`parse?`/`name` | `ofChar_toChar`、`parse?_name`、`name_injective` |

## 2. 全部 theorem / lemma（共 108 条）

下表由源文件按 `theorem`/`lemma` 声明自动核对；`scripts/check_hygiene.sh`
会对其中每一条运行 `#print axioms`，并在出现非标准公理时使 CI 失败。

### `Occult/YinYang.lean`（11 条）

`neg_neg`, `neg_ne_self`, `neg_injective`, `eq_yin_or_yang`, `ofParity_eq_iff`, `ofParity_mod`, `ofParity_succ`, `ofFin_toFin`, `toFin_ofFin`, `card_eq_two`, `forall_iff`

### `Occult/WuXing.lean`（26 条）

`ofFin_toFin`, `toFin_ofFin`, `card_eq_five`, `toFin_next`, `toFin_overcomes`, `next_injective`, `next_ne_self`, `next_five`, `toFin_next_iterate`, `next_period_iff`, `overcomes_five`, `overcomes_ne_self`, `overcomes_ne_next`, `prev_next`, `next_prev`, `prev_injective`, `prev_ne_self`, `prev_five`, `next_eq_iff_prev`, `overcomeBy_overcomes`, `overcomes_overcomeBy`, `overcomeBy_injective`, `overcomeBy_ne_self`, `overcomeBy_five`, `overcomes_eq_iff_overcomeBy`, `next_orbit_wood`

### `Occult/TianGan.lean`（14 条）

`ofFin_toFin`, `toFin_ofFin`, `card_eq_ten`, `toNat_lt`, `ofNatMod_toNat`, `toNat_ofNatMod`, `ofNatMod_eq_iff`, `wuXing_toFin`, `wuXing_eq_iff`, `wuXing_ofNatMod_add_two`, `yinYang_eq_iff`, `ofChar_toChar`, `parse_name`, `name_injective`

### `Occult/DiZhi.lean`（13 条）

`ofFin_toFin`, `toFin_ofFin`, `card_eq_twelve`, `toNat_lt`, `ofNatMod_toNat`, `toNat_ofNatMod`, `ofNatMod_eq_iff`, `wuXing_toFin`, `wuXing_ofNatMod_toNat`, `yinYang_eq_iff`, `ofChar_toChar`, `parse_name`, `name_injective`

### `Occult/JiaZi.lean`（36 条）

`crt_spec`, `index_unique`, `toIndex_ofIndex`, `ofIndex_toIndex`, `card_eq_sixty`, `toIndex_next`, `toIndex_prev`, `toIndex_iterate`, `toIndex_prev_iterate`, `next_sixty`, `next_period_iff`, `prev_next`, `next_prev`, `prev_injective`, `prev_sixty`, `prev_period_iff`, `stem_toNat_ofIndex`, `branch_toNat_ofIndex`, `stem_toNat_eq`, `branch_toNat_eq`, `stem_next`, `branch_next`, `stem_ofIndex`, `branch_ofIndex`, `parity_yinYang`, `existsUnique_index`, `next_iterate_jiaZi`, `ofIndex_eq_next_iterate`, `next_min_period`, `card_sameParity_pairs`, `yinYang_toIndex`, `ofIndex_coords`, `ofIndex_injective`, `next_injective`, `next_iterate_injective`, `parse?_name`

### `Occult/Cli.lean`（8 条）

`parseNat?_empty`, `parseNat?_zero`, `parseNat?_007`, `parseNat?_59`, `parseNat?_60`, `parseNat?_neg`, `parseNat?_mixed`, `parseNat?_space`
## 3. 范围外（v0.1 不做）

| 项目 | 原因 |
| --- | --- |
| 规则引擎（刑冲合害、藏干、十神、旺衰） | 依赖大量未核查的传统说法，且不是有限组合结构 |
| 紫微斗数、西方占星 | 需要另一套完整模型与文献核对，超出 v0.1 |
| 出生排盘 | 需要历法、时区、真太阳时与天文计算，属于经验建模 |
| UI / Web / 数据库 | 与数学核心无关 |
| 文献引文 | 未完成原文核对，见 `docs/sources.md` |

## 4. 证明卫生

* 不使用 `axiom`、`constant`、`sorry`、`admit`、`native_decide`、`implemented_by`、`extern`。
* `scripts/check_hygiene.sh` 是强制检查：既扫描上述禁用关键字与 `axiom`/`constant`
  声明，也对全部 theorem/lemma 运行 `#print axioms`，只允许 Lean 标准公理
  `propext`、`Classical.choice`、`Quot.sound`；CI 直接调用该脚本并以其退出码为准。
* 周期与最小周期分开陈述（见 `docs/conventions.md` 第 4 节）。
