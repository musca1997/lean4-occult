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
| 干支编码 | `toFin`/`ofFin`/`ofNatMod` | `ofFin_toFin`、`toFin_ofFin`、`ofNatMod_eq_iff` |
| 干支阴阳 | `TianGan.yinYang`/`DiZhi.yinYang` | `yinYang_eq_iff` |
| 甲子索引 | `JiaZi.crt`/`ofIndex`/`toIndex` | `crt_spec`、`toIndex_ofIndex`、`ofIndex_toIndex` |
| 甲子推进 | `JiaZi.next` | `next_sixty`、`next_period_iff`、`next_min_period` |
| 同阴阳配对 | `JiaZi.sameParityEquiv` | `card_sameParity_pairs`、`existsUnique_index` |
| 解析/打印 | `toChar`/`ofChar`/`parse?`/`name` | `ofChar_toChar`、`parse?_name`、`name_injective` |

## 2. 全部 theorem / lemma（共 84 条）

| # | 文件 | 名称 | 说明 |
| --- | --- | --- | --- |
| 1 | `Cli.lean` | `parseNat?_empty` | 空串不是自然数。 |
| 2 | `Cli.lean` | `parseNat?_zero` | 单字符 `0` 解析为 0。 |
| 3 | `Cli.lean` | `parseNat?_007` | 具体用例（CLI 冒烟测试依赖）。 |
| 4 | `Cli.lean` | `parseNat?_59` | 具体用例（CLI 冒烟测试依赖）。 |
| 5 | `Cli.lean` | `parseNat?_60` | 具体用例（CLI 冒烟测试依赖）。 |
| 6 | `Cli.lean` | `parseNat?_neg` | 具体用例（CLI 冒烟测试依赖）。 |
| 7 | `Cli.lean` | `parseNat?_mixed` | 具体用例（CLI 冒烟测试依赖）。 |
| 8 | `Cli.lean` | `parseNat?_space` | 具体用例（CLI 冒烟测试依赖）。 |
| 9 | `DiZhi.lean` | `ofFin_toFin` |  |
| 10 | `DiZhi.lean` | `toFin_ofFin` |  |
| 11 | `DiZhi.lean` | `card_eq_twelve` | 地支恰有十二个。 |
| 12 | `DiZhi.lean` | `toNat_lt` | `toNat` 始终小于 12。 |
| 13 | `DiZhi.lean` | `ofNatMod_toNat` | 先编码再解码回到自身。 |
| 14 | `DiZhi.lean` | `toNat_ofNatMod` | 解码后的序号就是输入对 12 取模。 |
| 15 | `DiZhi.lean` | `ofNatMod_eq_iff` | 按序号取地支相同，当且仅当序号同余 12。 |
| 16 | `DiZhi.lean` | `yinYang_eq_iff` | 阴阳相同当且仅当序号同奇偶。 |
| 17 | `DiZhi.lean` | `ofChar_toChar` | 单字符解析与打印互逆。 |
| 18 | `DiZhi.lean` | `parse_name` | 解析与打印互逆。 |
| 19 | `DiZhi.lean` | `name_injective` | 打印是单射。 |
| 20 | `JiaZi.lean` | `crt_spec` | `crt` 的正确性：结果落在 `[0, 60)` 且两个投影都还原。 |
| 21 | `JiaZi.lean` | `index_unique` | 同阴阳条件下，索引在 `[0, 60)` 内由两个投影唯一确定。 |
| 22 | `JiaZi.lean` | `toIndex_ofIndex` | 先 `ofIndex` 再 `toIndex` 得到原索引。 |
| 23 | `JiaZi.lean` | `ofIndex_toIndex` | 先 `toIndex` 再 `ofIndex` 得到原甲子。 |
| 24 | `JiaZi.lean` | `card_eq_sixty` | 六十甲子恰有六十个元素。 |
| 25 | `JiaZi.lean` | `toIndex_next` | `next` 在索引上就是加一取模。 |
| 26 | `JiaZi.lean` | `toIndex_iterate` | 迭代 `next` 与索引加法一致。 |
| 27 | `JiaZi.lean` | `next_sixty` | 六十甲子的周期上界：迭代 60 次回到自身。 |
| 28 | `JiaZi.lean` | `next_period_iff` | 六十甲子的**最小正周期**是 60：迭代 `n` 次回到自身当且仅当 `60 ∣ n`。 |
| 29 | `JiaZi.lean` | `stem_toNat_ofIndex` | 第 `n` 位的天干序号是 `n % 10`。 |
| 30 | `JiaZi.lean` | `branch_toNat_ofIndex` | 第 `n` 位的地支序号是 `n % 12`。 |
| 31 | `JiaZi.lean` | `stem_toNat_eq` | 任意甲子的天干序号等于其索引对 10 取模。 |
| 32 | `JiaZi.lean` | `branch_toNat_eq` | 任意甲子的地支序号等于其索引对 12 取模。 |
| 33 | `JiaZi.lean` | `stem_next` | 天干前进一位。 |
| 34 | `JiaZi.lean` | `branch_next` | 地支前进一位。 |
| 35 | `JiaZi.lean` | `stem_ofIndex` | 第 `n` 位的天干是 `n % 10`。 |
| 36 | `JiaZi.lean` | `branch_ofIndex` | 第 `n` 位的地支是 `n % 12`。 |
| 37 | `JiaZi.lean` | `parity_yinYang` | 六十甲子中天干与地支的阴阳一致。 |
| 38 | `JiaZi.lean` | `existsUnique_index` | 任意同阴阳的天干、地支组合都恰好对应一个六十甲子。 |
| 39 | `JiaZi.lean` | `next_iterate_jiaZi` | 六十甲子枚举就是 `next` 从甲子出发的轨道。 |
| 40 | `JiaZi.lean` | `ofIndex_eq_next_iterate` | 索引 `n` 的甲子等于从甲子出发迭代 `n` 步。 |
| 41 | `JiaZi.lean` | `next_min_period` | 60 是**最小**正周期：任何更小的正步数都不能使甲子回到自身。 |
| 42 | `JiaZi.lean` | `card_sameParity_pairs` | 同阴阳配对的数目是 60。 |
| 43 | `JiaZi.lean` | `yinYang_toIndex` | 六十甲子的索引与阴阳一致：索引的奇偶就是干支的阴阳。 |
| 44 | `JiaZi.lean` | `ofIndex_coords` | 第 `n` 位甲子的天干序号是 `n % 10`，地支序号是 `n % 12`。 |
| 45 | `JiaZi.lean` | `ofIndex_injective` | `ofIndex` 是单射：不同的索引给出不同的甲子。 |
| 46 | `JiaZi.lean` | `next_injective` | `next` 是单射（等价地，六十甲子构成一个 60 元循环）。 |
| 47 | `JiaZi.lean` | `next_iterate_injective` | 从甲子出发迭代 `n < 60` 步得到的甲子两两不同（轨道没有提前闭合）。 |
| 48 | `JiaZi.lean` | `parse?_name` | `parse?` 与 `name` 互逆。 |
| 49 | `TianGan.lean` | `ofFin_toFin` |  |
| 50 | `TianGan.lean` | `toFin_ofFin` |  |
| 51 | `TianGan.lean` | `card_eq_ten` | 天干恰有十个。 |
| 52 | `TianGan.lean` | `toNat_lt` | `toNat` 始终小于 10。 |
| 53 | `TianGan.lean` | `ofNatMod_toNat` | 先编码再解码回到自身。 |
| 54 | `TianGan.lean` | `toNat_ofNatMod` | 解码后的序号就是输入对 10 取模。 |
| 55 | `TianGan.lean` | `ofNatMod_eq_iff` | 按序号取天干相同，当且仅当序号同余 10。 |
| 56 | `TianGan.lean` | `yinYang_eq_iff` | 阴阳相同当且仅当序号同奇偶。 |
| 57 | `TianGan.lean` | `ofChar_toChar` | 单字符解析与打印互逆。 |
| 58 | `TianGan.lean` | `parse_name` | 解析与打印互逆。 |
| 59 | `TianGan.lean` | `name_injective` | 打印是单射。 |
| 60 | `WuXing.lean` | `ofFin_toFin` |  |
| 61 | `WuXing.lean` | `toFin_ofFin` |  |
| 62 | `WuXing.lean` | `card_eq_five` | 五行恰有五个元素。 |
| 63 | `WuXing.lean` | `toFin_next` | 相生等价于序号加 1 再对 5 取模。 |
| 64 | `WuXing.lean` | `toFin_overcomes` | 相克等价于序号加 2 再对 5 取模。 |
| 65 | `WuXing.lean` | `next_injective` | 相生映射是单射。 |
| 66 | `WuXing.lean` | `next_ne_self` | 相生映射没有不动点。 |
| 67 | `WuXing.lean` | `next_five` | 相生映射迭代五次回到原点。 |
| 68 | `WuXing.lean` | `toFin_next_iterate` | 相生迭代 `n` 次后的序号是序号加 `n` 再对 5 取模。 |
| 69 | `WuXing.lean` | `next_period_iff` | 相生映射的周期恰为 5：迭代 `n` 次回到原点当且仅当 `5 ∣ n`。 |
| 70 | `WuXing.lean` | `overcomes_five` | 相克映射迭代五次回到原点。 |
| 71 | `WuXing.lean` | `overcomes_ne_self` | 相克映射没有不动点。 |
| 72 | `WuXing.lean` | `overcomes_ne_next` | 相生与相克是不同的关系。 |
| 73 | `WuXing.lean` | `next_orbit_wood` | 从木出发的相生轨道覆盖全部五行。 |
| 74 | `YinYang.lean` | `neg_neg` | 取反是对合（两次取反回到自身）。 |
| 75 | `YinYang.lean` | `neg_ne_self` | 取反没有不动点。 |
| 76 | `YinYang.lean` | `neg_injective` | 取反是单射。 |
| 77 | `YinYang.lean` | `eq_yin_or_yang` | 穷举：任何阴阳要么是阴，要么是阳。 |
| 78 | `YinYang.lean` | `ofParity_eq_iff` | 奇偶解释与相等一致。 |
| 79 | `YinYang.lean` | `ofParity_mod` | 奇偶解释在模偶数下不变。 |
| 80 | `YinYang.lean` | `ofParity_succ` | 奇偶解释的后继会翻转阴阳。 |
| 81 | `YinYang.lean` | `ofFin_toFin` | 从 `Fin 2` 解码。 |
| 82 | `YinYang.lean` | `toFin_ofFin` |  |
| 83 | `YinYang.lean` | `card_eq_two` | 阴阳恰有两个元素。 |
| 84 | `YinYang.lean` | `forall_iff` | 对任意阴阳都成立的命题，只需分别验证阴与阳。 |

## 3. 范围外（v0.1 不做）

| 项目 | 原因 |
| --- | --- |
| 规则引擎（刑冲合害、藏干、十神、旺衰） | 依赖大量未核查的传统说法，且不是有限组合结构 |
| 紫微斗数、西方占星 | 需要另一套完整模型与文献核对，超出 v0.1 |
| 出生排盘 | 需要历法、时区、真太阳时与天文计算，属于经验建模 |
| UI / Web / 数据库 | 与数学核心无关 |
| 文献引文 | 未完成原文核对，见 `docs/sources.md` |

## 4. 证明卫生

* 不使用 `axiom`、`sorry`、`admit`、`native_decide`、`implemented_by`、`extern`。
* `#print axioms` 只出现 Lean 标准公理：`propext`、`Classical.choice`、`Quot.sound`。
* 周期与最小周期分开陈述（见 `docs/conventions.md` 第 4 节）。
