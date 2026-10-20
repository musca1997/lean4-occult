# 范围与定理清单（scope）

本文件覆盖 v0.1–v0.3：v0.1 是阴阳、五行、干支、六十甲子的有限组合结构；
v0.2 是紫微十二宫的**纯位置结构**；v0.3 是来源明确的**年干/年支系小安星**
（禄存、擎羊、陀罗、天马），以及与 `Fin 12` 抽象宫位的地支对接。
本文件是 `PLAN.md` 的细化，列出全部 theorem/lemma，便于审阅覆盖面。

## 1. 范围内

### 数据类型

| 类型 | 文件 | 元素数 | 等价于 |
| --- | --- | --- | --- |
| `YinYang` | `Occult/YinYang.lean` | 2 | `Fin 2` |
| `WuXing` | `Occult/WuXing.lean` | 5 | `Fin 5` |
| `TianGan` | `Occult/TianGan.lean` | 10 | `Fin 10` |
| `DiZhi` | `Occult/DiZhi.lean` | 12 | `Fin 12` |
| `JiaZi` | `Occult/JiaZi.lean` | 60 | `Fin 60` |
| `ZiWei.Position` | `Occult/ZiWei/Position.lean` | 12 | `Fin 12`（同义） |
| `ZiWei.Palace` | `Occult/ZiWei/Relations.lean` | 12 | `Fin 12`（经 `offset` 双射） |
| `ZiWei.Branch` 的映射 | `Occult/ZiWei/Branch.lean` | — | `DiZhi ≃ Position` |
| `ZiWei.MinorStar.Star` | `Occult/ZiWei/MinorStar.lean` | 4 | 有限枚举（禄存/擎羊/陀罗/天马） |
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
| 宫位旋转 | `ZiWei.Position.rotate` | `rotate_add`、`rotate_neg`、`rotate_injective` |
| 对宫 | `ZiWei.Position.opposite` | `opposite_involutive`、`opposite_ne_self` |
| 三合 | `ZiWei.Position.trineForward`/`trineBackward` | `trineForward_three`、`trineBackward_eq_trineForward_twice` |
| 三方四正 | `ZiWei.Position.triad` | `triad_card`、`mem_triad_iff`、`rotate_triad`、`mem_triad_rotate_iff` |
| 语义宫名 | `ZiWei.Palace.offset`/`atPos` | `offset_injective`、`opposite_ming`、`triad_ming`、`atPos_triad_ming` |
| 地支/位置对接 | `ZiWei.Branch.ofDiZhi`/`toDiZhi` | `toDiZhi_ofDiZhi`、`ofDiZhi_toDiZhi`、`ofDiZhi_injective`、`ofDiZhi_bijective` |
| 禄存 | `ZiWei.MinorStar.luCun` | `luCun_toDiZhi`、`luCun_eq_iff`、`luCun_image`、`luCun_image_card` |
| 擎羊/陀罗 | `qingYang`/`tuoLuo` | `qingYang_eq_rotate_one`、`tuoLuo_eq_rotate_neg_one`、`qingYang_ne_luCun`、`qingYang_image_card` |
| 天马 | `tianMa` | `tianMa_toDiZhi`、`tianMa_image`、`tianMa_image_card`、`tianMa_not_injective` |
| 综合安星 | `place`/`placeJiaZi` | `place_*`、`placeJiaZi_*`、`placeJiaZi_jiaZi` |

## 2. 全部 theorem / lemma（共 196 条）

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

### `Occult/ZiWei/Position.lean`（14 条）

`toNat_ofNat`, `ofNat_toNat`, `rotate_add`, `rotate_zero`, `rotate_neg`, `rotate_injective`, `opposite_involutive`, `opposite_ne_self`, `trineForward_three`, `trineBackward_eq_trineForward_twice`, `trineForward_ne_self`, `trineBackward_ne_self`, `triad_card`, `mem_triad_iff`

### `Occult/ZiWei/Relations.lean`（15 条）

`offset_ofOffset`, `ofOffset_offset`, `card_eq_twelve`, `offset_injective`, `atPos_ming`, `atPos_rotate`, `opposite_ming`, `opposite_xiongDi`, `opposite_fuQi`, `opposite_ziNv`, `opposite_caiBo`, `opposite_jiE`, `trineForward_ming`, `trineBackward_ming`, `triad_ming`

### `Occult/ZiWei/Properties.lean`（14 条）

`rotate_opposite`, `rotate_trineForward`, `rotate_trineBackward`, `rotate_triad`, `rotate_triad_card`, `mem_triad_rotate_iff`, `opposite_mem_triad`, `trineForward_mem_triad`, `trineBackward_mem_triad`, `self_mem_triad`, `trineForward_atPos_ming`, `opposite_atPos_ming`, `trineBackward_atPos_ming`, `atPos_triad_ming`

### `Occult/ZiWei/Branch.lean`（7 条）

`toDiZhi_ofDiZhi`, `ofDiZhi_toDiZhi`, `ofDiZhi_injective`, `toDiZhi_injective`, `ofDiZhi_bijective`, `toNat_ofDiZhi`, `ofDiZhi_toNat`

### `Occult/ZiWei/MinorStar.lean`（38 条）

`star_all_length`, `star_card_eq_four`, `luCun_toDiZhi`, `luCun_bing_eq_wu`, `luCun_ding_eq_ji`, `luCun_eq_iff`, `luCun_image`, `luCun_image_card`, `qingYang_eq_rotate_one`, `tuoLuo_eq_rotate_neg_one`, `qingYang_toDiZhi`, `tuoLuo_toDiZhi`, `qingYang_gui`, `tuoLuo_gui`, `qingYang_ne_luCun`, `tuoLuo_ne_luCun`, `qingYang_ne_tuoLuo`, `qingYang_image_card`, `tuoLuo_image_card`, `qingYang_image`, `tuoLuo_image`, `tianMa_toDiZhi`, `tianMa_yin_wu_xu`, `tianMa_shen_zi_chen`, `tianMa_si_you_chou`, `tianMa_hai_mao_wei`, `tianMa_image`, `tianMa_image_card`, `tianMa_not_injective`, `place_luCun`, `place_qingYang`, `place_tuoLuo`, `place_tianMa`, `placeJiaZi_luCun`, `placeJiaZi_qingYang`, `placeJiaZi_tuoLuo`, `placeJiaZi_tianMa`, `placeJiaZi_jiaZi`

## 3. 范围外

| 项目 | 原因 |
| --- | --- |
| 主星（紫微/天府等）安星 | 需要出生时间与历法/起例，且传统版本差异未核查 |
| 天魁/天钺 | 来源歌诀有异文，且未说明组内魁/钺归属；见 `docs/sources.md` §5.4 |
| 红鸾/天喜 | 本版本次未登记其来源与规则 |
| 流禄/流羊/流陀/流年天马/月马 | 需要流年输入，且与生年规则不同；本库只做生年四星 |
| 出生排盘 | 需要历法、时区、真太阳时与天文计算，属于经验建模 |
| 四化、限运、大限流年 | 依赖更多未核查传统说法与历法模型 |
| 规则引擎（刑冲合害、藏干、十神、旺衰） | 依赖大量未核查的传统说法，且不是有限组合结构 |
| 西方占星 | 需要另一套完整模型与文献核对 |
| UI / Web / 数据库 | 与数学核心无关 |
| 文献引文（v0.1/v0.2 部分） | v0.3 只登记了三条安星规则；其余传统说法仍未完成原文核对，见 `docs/sources.md` |

## 4. 证明卫生

* 不使用 `axiom`、`constant`、`sorry`、`admit`、`native_decide`、`implemented_by`、`extern`。
* `scripts/check_hygiene.sh` 是强制检查：既扫描上述禁用关键字与 `axiom`/`constant`
  声明，也对全部 theorem/lemma 运行 `#print axioms`，只允许 Lean 标准公理
  `propext`、`Classical.choice`、`Quot.sound`；CI 直接调用该脚本并以其退出码为准。
* 周期与最小周期分开陈述（见 `docs/conventions.md` 第 4 节）。
* 紫微 v0.2 部分只证明“位置 + 偏移”的组合事实，不把任何传统宫位含义写成定理。
* 紫微 v0.3 部分只编码来源登记的三条安星规则；`#print axioms` 对全部
  196 条 theorem/lemma 运行，白名单不变。
