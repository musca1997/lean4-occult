# lean4-occult

用 Lean 4 形式化**阴阳、五行、十天干、十二地支、六十甲子**的有限组合结构，
并证明其基本性质（基数、编码往返、周期与最小正周期、同阴阳配对双射）；
v0.2 起还包括**紫微十二宫的纯位置结构**（旋转、对宫、三合、三方四正）；
v0.3 增加**来源明确的年干/年支系小安星**（禄存、擎羊、陀罗、天马）；
v0.4 增加**可追溯解释报告**（稳定规则编号、六组位置关系、文字与 JSON 输出）。

> 本项目只处理**可精确定义的有限结构**。它不声称、也不检验任何传统术数体系
> 的经验有效性；`docs/sources.md` 明确列出哪些内容属于项目约定、哪些尚未核查。

## 状态

v0.4，可构建、可运行。工具链固定为 `leanprover/lean4:v4.35.0`，
Mathlib 固定为 `v4.35.0`。

* v0.1：阴阳、五行、干支、六十甲子；补齐了天干五行映射、地支**本气**五行映射
  （明确不是藏干）、六十甲子后退 `prev` 及前后互逆、五行生克逆向 API，
  并把证明卫生（禁用关键字 / 自定义 `axiom`）做成 CI 强制检查。
* v0.2：紫微十二宫**纯位置结构**（`Fin 12`）：旋转与加法组合、逆操作、
  对宫偏移 6、三合偏移 4/8、三方四正基数 4，以及整体旋转保持这些结构；
  语义宫名与抽象位置分开，**不含星曜与出生排盘**。
* v0.3：来源明确的**年干/年支系小安星**：禄存（依年干）、擎羊/陀罗
  （随禄存前/后一位）、天马（依年支）。来源、版本、段落定位与短引文登记在
  `docs/sources.md` §5；地支与 `Position = Fin 12` 的对接（子 0、丑 1、…、
  亥 11）明确标为项目约定。**不含**出生排盘、历法、流年/大限或吉凶判断。
* v0.4：**可追溯解释报告**。`ziwei explain <天干> <地支> [--json]` 输出输入、
  四星位置、稳定规则编号、来源引用、推导节点与六组两两位置关系。结构化报告
  有实际健全性定理 `buildReport_correct`；JSON 用标准库 `Lean.Json` 转义，
  `schemaVersion = 0.4.0`。**不新增传统规则**，不做通用引擎、LLM、出生排盘或 UI。
  来源转录仍需人工核对；本版**没有**外部 JSON 证书检查器。
* v0.5 及以后见 `PLAN.md` 路线图（有限查询与完整性证明仅规划，未实现）。

## 快速开始

```bash
# 1. 安装用户级 elan（若尚未安装）
curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | sh -s -- -y --default-toolchain none
export PATH="$HOME/.elan/bin:$PATH"

# 2. 克隆项目并获取锁定版本依赖
git clone https://github.com/musca1997/lean4-occult.git
cd lean4-occult
lake exe cache get

# 3. 构建库、测试与 CLI
lake build

# 4. 运行 CLI
lake env lean4-occult cycle 0
lake env lean4-occult cycle 59
lake env lean4-occult pair 甲 子
lake env lean4-occult pair 甲 丑   # 退出码 1
lake env lean4-occult list
lake env lean4-occult ziwei relations 0
lake env lean4-occult ziwei anstar 甲 子
lake env lean4-occult ziwei explain 甲 子
lake env lean4-occult ziwei explain 甲 子 --json
```

`ziwei relations 0` 输出：

```
位置 0
自身 0
对宫 6
三合 4, 8
三方四正 0/4/6/8
```

`ziwei anstar 甲 子` 输出（按生年干/支安四颗小星）：

```
干支 甲子（索引 0）
禄存 寅 (2)
擎羊 卯 (3)
陀罗 丑 (1)
天马 寅 (2)
```

`ziwei explain 甲 子` 的核心输出（完整固定模板）：

```
紫微小安星解释报告（schema 0.4.0）
干支 甲子（索引 0；甲阳；天干 0，地支 0）
规则：
  [ZW-LUCUN-STEM] 禄存按生年干落在固定地支宫位（……）（来源支持）
  ……
星曜位置：
  禄存 寅 (2)  规则 ZW-LUCUN-STEM
  擎羊 卯 (3)  规则 ZW-QINGYANG-AFTER-LUCUN
  陀罗 丑 (1)  规则 ZW-TUOLUO-BEFORE-LUCUN
  天马 寅 (2)  规则 ZW-TIANMA-BRANCH
两两关系（有限位置事实，不是吉凶解释）：
  禄存 / 擎羊：相邻（偏移 ±1）；位置 2 / 3
  禄存 / 天马：同宫；位置 2 / 2
  ……
保证范围：
  已验证结构化层：……见 buildReport_correct。
  人工信任边界：来源转录、短引文与读法需人工核对 docs/sources.md §5……
  外部证书：本版未实现从任意 JSON 重新验证的证书检查器……
```

JSON 模式只向 stdout 输出一个对象；字段、关系语义与信任边界见
`docs/report-schema.md`，完整示例见 `docs/examples/explain-jiazi.json`。

## CLI

```
lean4-occult cycle <n>          显示第 n 位（0–59）的甲子及下一步
lean4-occult pair <天干> <地支>  由干支查索引（要求同阴阳）
lean4-occult list               列出全部六十甲子
lean4-occult ziwei relations <位置>  显示位置（0–11）的自身、对宫、三合、三方四正
lean4-occult ziwei anstar <天干> <地支>
                                按生年干/支安禄存、擎羊、陀罗、天马
lean4-occult ziwei explain <天干> <地支> [--json]
                                可追溯四星位置与六组位置关系报告
lean4-occult --help             帮助
```

约定：索引 0 = 甲子，索引 59 = 癸亥；索引 `n` 的天干序号是 `n % 10`，
地支序号是 `n % 12`。详见 `docs/conventions.md`。

非法输入一律退出码 1，并在 stderr 说明原因：

* `cycle 60`、`cycle -1`、`cycle abc`：越界或非十进制
* `pair 甲 丑`、`pair 乙 子`：阴阳不同，不属于六十甲子
* `pair 甲`、`pair 甲 子 丑`：参数个数不对
* `pair 子 甲`、`pair 甲 X`：未知天干/地支
* `ziwei relations 12`、`ziwei relations -1`、`ziwei relations abc`：越界或非十进制
* `ziwei relations`、`ziwei relations 1 2`：缺参或多参
* `ziwei anstar 甲 丑`、`ziwei anstar 乙 子`：阴阳不同，不是六十甲子中的年份
* `ziwei anstar 子 甲`、`ziwei anstar 甲 X`：未知天干/地支
* `ziwei anstar 甲`、`ziwei anstar`、`ziwei anstar 甲 子 丑`：缺参或多参
* `ziwei explain 甲 丑`、`ziwei explain 乙 子`：阴阳不同，不是六十甲子中的年份
* `ziwei explain`、`ziwei explain 甲`、`ziwei explain 甲 子 丑`：缺参或多参
* `ziwei explain 甲 子 --yaml`、`ziwei explain --json 甲 子`：未知/位置错误的选项
* `ziwei explain 甲 子 --json --json`：重复 `--json`

## 库结构

| 文件 | 内容 |
| --- | --- |
| `Occult/YinYang.lean` | `YinYang`（阴/阳），对合 `neg`，奇偶解释 `ofParity` |
| `Occult/WuXing.lean` | `WuXing`（木火土金水），相生 `next`、相克 `overcomes`、逆向 `prev`/`overcomeBy` |
| `Occult/TianGan.lean` | `TianGan`（甲乙…癸），序号、阴阳、五行映射、汉字解析 |
| `Occult/DiZhi.lean` | `DiZhi`（子丑…亥），序号、阴阳、**本气**五行映射、汉字解析 |
| `Occult/JiaZi.lean` | `JiaZi`（同阴阳配对），`Fin 60` 等价，`next`/`prev` 与周期定理 |
| `Occult/Cli.lean` | CLI 输入解析 `parseNat?`（可在测试中直接检查） |
| `Occult/ZiWei/Position.lean` | `Position = Fin 12`，旋转、对宫、三合、三方四正 |
| `Occult/ZiWei/Relations.lean` | `Palace` 十二宫名、固定偏移 `offset`、`atPos` |
| `Occult/ZiWei/Properties.lean` | 旋转保持结构、任意参考位置下的命宫三方四正 |
| `Occult/ZiWei/Branch.lean` | 十二支与 `Position` 的编号对接（子 0、丑 1、…、亥 11） |
| `Occult/ZiWei/MinorStar.lean` | 禄存、擎羊、陀罗、天马；`place`/`placeJiaZi` 安星函数 |
| `Occult/ZiWei/Explain.lean` | 稳定规则编号、来源引用、报告语义 `Report.Correct`、关系分类、文字/JSON 输出 |
| `Tests.lean` | 关键结论的 `example` 回归检查 |
| `Main.lean` | CLI（含 `ziwei explain` 严格参数检查） |
| `docs/report-schema.md` | v0.4 报告字段、关系语义、信任边界与测试依赖 |
| `scripts/test_json.py` | 穷举 60 个输入的文本/JSON/计算一致性测试（Python 标准库） |

## 主要定理

* `JiaZi.card_eq_sixty`：六十甲子恰有 60 个元素。
* `JiaZi.next_sixty`：`next^[60] z = z`（60 是一个周期）。
* `JiaZi.next_period_iff`：`next^[n] z = z ↔ 60 ∣ n`（**最小**正周期是 60）。
* `JiaZi.next_min_period`：任何 `0 < k < 60` 都不能让甲子回到自身。
* `JiaZi.sameParityEquiv` + `card_sameParity_pairs`：同阴阳的（天干, 地支）配对
  与六十甲子一一对应，共 60 个。
* `JiaZi.existsUnique_index`：每个同阴阳组合有唯一索引 `n < 60`。
* `WuXing.next_period_iff`：五行相生的最小正周期是 5。
* `WuXing.next_eq_iff_prev` / `overcomes_eq_iff_overcomeBy`：生克的逆向关系与
  逆向映射 `prev` / `overcomeBy` 等价；`prev_next`、`next_prev` 证明互逆。
* `TianGan.wuXing_toFin`：天干五行序号 = 天干序号 `/ 2`（甲乙木…壬癸水）。
* `DiZhi.wuXing_toFin`：地支本气五行逐项展开（子水…亥水；**不是藏干**）。
* `JiaZi.prev_next` / `next_prev`：六十甲子前进与后退互逆；
  `JiaZi.prev_period_iff`：后退的最小正周期同样是 60。
* `YinYang.ofParity_eq_iff`：阴阳编码由奇偶性完全决定。
* `ZiWei.Position.opposite_involutive` / `opposite_ne_self`：对宫的对宫是自身，
  且对宫没有不动点。
* `ZiWei.Position.trineForward_three`：连续偏移 4 三次回到原位；
  `trineBackward_eq_trineForward_twice`：偏移 8 等于偏移 4 两次。
* `ZiWei.Position.triad_card`：三方四正 `{p, p+4, p+6, p+8}` 恰有 4 个元素。
* `ZiWei.Position.rotate_triad` / `mem_triad_rotate_iff`：整体旋转保持三方四正。
* `ZiWei.Palace.offset_injective` / `card_eq_twelve`：十二宫名与 `Fin 12` 一一对应。
* `ZiWei.Position.atPos_triad_ming`：任意参考位置下，命、财帛、迁移、官禄
  构成命宫的三方四正。
* `ZiWei.Branch.ofDiZhi_toDiZhi` / `toDiZhi_ofDiZhi`：地支与 `Position` 的
  编号映射互逆；`ofDiZhi_bijective` 给出双射。
* `ZiWei.MinorStar.luCun_toDiZhi`：禄存（依年干）的完整地支表；
  `luCun_image_card`：10 个天干因丙戊、丁己同宫而只落到 8 个位置。
* `ZiWei.MinorStar.qingYang_eq_rotate_one` / `tuoLuo_eq_rotate_neg_one`：
  擎羊、陀罗分别是禄存位置 +1 / −1；`qingYang_gui`、`tuoLuo_gui` 是来源
  “癸禄在子 → 丑擎羊、亥陀罗”的例子。
* `ZiWei.MinorStar.tianMa_toDiZhi`：天马（依年支）的完整地支表；
  `tianMa_image_card`：四个三合组只共用四个马位（像的基数为 4）。
* `ZiWei.MinorStar.placeJiaZi_jiaZi`：甲子年安星样例（禄存寅、擎羊卯、
  陀罗丑、天马寅）。
* `ZiWei.Explain.buildReport_correct`：任意六十甲子输入生成的报告都满足
  `Report.Correct`：每个星位等于 `placeJiaZi`、每条关系类别成立、覆盖四星与
  全部稳定规则编号。它不是“报告里存一个已证 `True`”。
* `ZiWei.Explain.classify_sound`：关系分类（同宫/对宫/三合/相邻/不同宫）
  的结果确实满足对应位置命题；`pairFacts_correct` 把它逐对应用到实际位置。
* `ZiWei.Explain.RuleId.toRule_id` 等：稳定规则编号与报告规则记录一致。

完整清单（**215** 条 theorem/lemma）见 `docs/scope.md`。

### v0.1 陈述复核

* 「周期」与「最小正周期」分开陈述：`next_sixty` 只声称 60 是周期，
  真正的周期刻画是 `next_period_iff`（`↔ 60 ∣ n`），并由 `next_min_period`
  给出更小正步数不闭合的显式陈述；五行同理。
* 「六十甲子构成单一 60 元循环」由 `next_injective` 与
  `next_iterate_injective`（前 60 步两两不同）共同支撑，而不是靠枚举断言。
* 同阴阳配对「恰有 60 个」由 `card_sameParity_pairs` 给出，并与
  `existsUnique_index` 的双射一致。
* 新增映射都被明确标注为**项目约定**（`TianGan.wuXing`、`DiZhi.wuXing`），
  其中 `DiZhi.wuXing` 是单一**本气**，不是藏干；`docs/sources.md` 同步说明
  这些对应关系尚未做文献核对。

### v0.3 陈述复核与来源边界

* 本版只编码《紫微斗數全書》卷二〈安祿存星訣〉〈安擎羊陀羅二星訣〉
  〈安天馬星訣〉三条有限规则；来源、修订号、扫描叶面、URL、访问日期与短引文
  见 `docs/sources.md` §5。
* `docs/sources.md` §5.3 明确记录三处文本读法：`丙戊巳` 读作丙、戊均在巳；
  `丁己…午` 读作丁、己均在午；原文“寅午戍”读作“寅午戌”。这些是**解释**，
  不是把转录文本当成校勘本。
* “前 = +1、后 = −1”不是项目另选的方向，而是由来源例子
  “癸禄在子，丑宫安擎羊，亥宫安陀罗”固定（`qingYang_gui`、`tuoLuo_gui`）。
* 12 支到 0–11 的编号是**项目约定**（`docs/conventions.md` §7），来源只说
  “子宫/丑宫…”。因此库里同时提供地支表定理（`luCun_toDiZhi` 等），
  避免只依赖数字。
* 天魁/天钺、红鸾/天喜、流禄/流羊/流陀/流年天马、月马均**未实现**；
  天魁/天钺的排除理由（歌诀异文且未说明组内魁/钺归属）见 `docs/sources.md`
  §5.4。没有把“未实现”写成“已核查”。
* 证明所得的性质（像的基数、同宫对、非单射等）与来源表格本身分开：
  它们只说明“按这张表计算会得到什么”，不说明传统体系“有效”。

### v0.4 陈述复核与信任边界

* 报告只由已有计算函数构造：`buildReport` 中四星位置来自
  `MinorStar.placeJiaZi`；关系来自同一位置的 `classify`。没有在报告层重写
  安星表，也没有新增传统规则。
* `Report.Correct` 是实际命题，不是 `True`：`buildReport_correct` 证明四星位置
  等于计算函数、六组关系类别成立、星曜覆盖 `Star.all`、规则覆盖 `RuleId.all`。
* 关系只是有限位置事实：同宫、对宫（偏移 6）、三合（偏移 4/8）、相邻
  （偏移 ±1）或其余不同宫；优先级固定。`classify_sound` 证明分类结果满足
  对应位置命题。没有任何吉凶、格局或传统解释被写成定理。
* 稳定规则编号 `ZW-*` / `PRJ-*` / `MATH-*` 在 `docs/sources.md` §6 登记；
  四条来源规则引用 §5 的来源 A/B，三条项目/数学规则不伪造外部来源。
* 文字模板只渲染可检验字段，并明确写出“已验证结构化层 / 来源转录人工信任
  边界 / 本版无外部证书检查器”。JSON 是输出而非证书；本版**不**实现从任意
  JSON 重新验证的 checker。
* `scripts/test_json.py` 穷举 60 个输入，检查文本、JSON、`anstar` 与独立关系
  分类一致；这是测试，不是证明。结构化健全性由 Lean 定理保证。

### v0.2 陈述复核

* 紫微部分只断言**位置**事实：`Fin 12` 上的旋转、对宫、三合、三方四正，
  以及宫名相对固定参考位置的偏移；不出现星曜、四化、限运、出生时间。
* 「三方四正恰有 4 个元素」由 `triad_card` 证明，且集合按偏移显式写出
  `{p, p+4, p+6, p+8}`，不使用枚举 12 个位置的方式。
* 「旋转保持三方四正」既有集合像形式（`rotate_triad`），也有成员形式
  （`mem_triad_rotate_iff`），并给出基数不变（`rotate_triad_card`）。
* 语义宫名与偏移表在 `docs/conventions.md` 第 6 节标为**项目约定**，
  `anchor` 由使用者提供，本库不计算命宫。

## v0.3/v0.4 来源（可公开核查）

* 可读文本：维基文库《紫微斗數全書》卷二，修订号 **1963110**
  （2020-09-04），〈安祿存星訣〉〈安擎羊陀羅二星訣〉〈安天馬星訣〉，
  访问日期 2026-10-20。永久链接：
  <https://zh.wikisource.org/w/index.php?title=%E7%B4%AB%E5%BE%AE%E6%96%97%E6%95%B8%E5%85%A8%E6%9B%B8/%E5%8D%B7%E4%BA%8C&oldid=1963110>
* 版本/叶面见证：明刊本《新鋟希夷陳先生紫微斗數全書》七卷
  （宋·陳摶撰，明·潘希尹補，南陽堂刊本，元数据标 1600），
  Internet Archive 扫描件第 75 叶（0 基 `n75`）：
  <https://archive.org/details/20260506_20260506_1217/page/n75/mode/1up>
* 逐条短引文、读法解释、可靠性/派别/同名规则分析与版权说明见
  `docs/sources.md` §5；v0.4 稳定规则编号映射见 §6。来源只支持
  “该版本这样写”，不支持任何吉凶或经验有效性主张。

## 验证记录（本地实测）

环境：NixOS 25.11，Lean 4.35.0，Mathlib v4.35.0（缓存）。

```
$ lake build
Build completed successfully (6291 jobs).

$ .lake/build/bin/lean4-occult cycle 0
索引 0：甲子（甲阳，天干 0，地支 0），下一步 乙丑（索引 1）

$ .lake/build/bin/lean4-occult cycle 59
索引 59：癸亥（癸阴，天干 9，地支 11），下一步 甲子（索引 0）

$ .lake/build/bin/lean4-occult pair 甲 子
索引 0：甲子（甲阳，天干 0，地支 0），下一步 乙丑（索引 1）

$ .lake/build/bin/lean4-occult pair 甲 丑 ; echo $?
错误：甲丑 阴阳不同（甲 序号 0，丑 序号 1），不在六十甲子中
1

$ .lake/build/bin/lean4-occult cycle 60 ; echo $?
错误：cycle 的索引必须在 0–59 之间，收到 60
...
1

$ .lake/build/bin/lean4-occult cycle -1 ; echo $?
错误：cycle 需要非负十进制整数，收到 "-1"
...
1

$ .lake/build/bin/lean4-occult cycle 1x ; echo $?
错误：cycle 需要非负十进制整数，收到 "1x"
...
1

$ .lake/build/bin/lean4-occult list | wc -l
60

$ .lake/build/bin/lean4-occult ziwei relations 0
位置 0
自身 0
对宫 6
三合 4, 8
三方四正 0/4/6/8

$ .lake/build/bin/lean4-occult ziwei relations 12 ; echo $?
错误：ziwei relations 的位置必须在 0–11 之间，收到 12
...
1

$ .lake/build/bin/lean4-occult ziwei relations ; echo $?
错误：ziwei relations 缺少位置参数（0–11）
...
1

$ .lake/build/bin/lean4-occult ziwei anstar 甲 子
干支 甲子（索引 0）
禄存 寅 (2)
擎羊 卯 (3)
陀罗 丑 (1)
天马 寅 (2)

$ .lake/build/bin/lean4-occult ziwei anstar 癸 亥
干支 癸亥（索引 59）
禄存 子 (0)
擎羊 丑 (1)
陀罗 亥 (11)
天马 巳 (5)

$ .lake/build/bin/lean4-occult ziwei anstar 甲 丑 ; echo $?
错误：甲丑 阴阳不同（甲 序号 0，丑 序号 1），不是六十甲子中的年份
...
1

$ .lake/build/bin/lean4-occult ziwei explain 甲 子
紫微小安星解释报告（schema 0.4.0）
干支 甲子（索引 0；甲阳；天干 0，地支 0）
规则：
  [ZW-LUCUN-STEM] ……（来源支持）
  ……
星曜位置：
  禄存 寅 (2)  规则 ZW-LUCUN-STEM
  ……
两两关系（有限位置事实，不是吉凶解释）：
  禄存 / 天马：同宫；位置 2 / 2
  ……
保证范围：
  已验证结构化层：……见 buildReport_correct。
  人工信任边界：……
  外部证书：本版未实现从任意 JSON 重新验证的证书检查器……

$ .lake/build/bin/lean4-occult ziwei explain 甲 子 --json | python3 -m json.tool | head
{
    "derivations": [ ... ],
    "facts": [ ... ],
    "guarantees": { "externalCertificateChecker": false, ... },
    "input": { "jiazi": "甲子", "index": 0, ... },
    "reportKind": "ziwei.explain",
    "rules": [ ... ],
    "schemaVersion": "0.4.0",
    "stars": [ ... ]
}

$ .lake/build/bin/lean4-occult ziwei explain 甲 子 --yaml ; echo $?
错误：ziwei explain 含未知选项 "--yaml"；只支持可选的 --json，且必须放在最后
...
1

$ .lake/build/bin/lean4-occult ziwei explain 甲 子 --json --json ; echo $?
错误：ziwei explain 的 --json 只能出现一次
...
1

$ ./scripts/smoke.sh
...
通过 61 项，失败 0 项

$ python3 scripts/test_json.py
ok: 60/60 inputs, text + JSON + anstar consistency, invalid-input rejection (...)
```

公理检查：

```
$ lake env lean /tmp/Ax.lean     # #print axioms 关键定理
'Occult.JiaZi.card_eq_sixty' depends on axioms: [propext, Classical.choice, Quot.sound]
'Occult.WuXing.next_period_iff' depends on axioms: [propext, Quot.sound]
'Occult.YinYang.neg_injective' depends on axioms: [propext]
```

没有项目自定义 `axiom`，没有 `sorry`/`admit`/`native_decide`。

`scripts/check_hygiene.sh` 把上述检查自动化并强制化：

```
$ ./scripts/check_hygiene.sh
==> 禁止关键字检查（sorry / admit / native_decide / implemented_by / extern）
==> 自定义 axiom / constant 声明检查
==> 收集库内 theorem / lemma
共 215 条待检查
==> 公理白名单检查
==> 公理检查通过：只出现 propext、Classical.choice、Quot.sound
```

若某条定理引用了白名单之外的公理，脚本会列出并返回非零退出码，CI 随之失败。

### 关于构建警告

Mathlib 4.35 会打印形如
`imports ... which is designed for use with the module system` 的警告。
本项目尝试过在文件顶部加 `module`，但会改变定理可见性并导致下游文件
无法引用（实测报 `Unknown identifier`），因此保留默认的非 module 模式。
这些只是风格提示，不影响证明与构建结果。

## 仓库状态

* 公开仓库：https://github.com/musca1997/lean4-occult
* 采用 MIT License。
* `.lake/` 已加入 `.gitignore`（构建产物约 7.6 GB，主要是 Mathlib 缓存）。

## 不做的事

规则引擎、占星、出生排盘、UI 均不在本库范围内，原因见 `docs/scope.md`。
v0.2 只包含紫微斗数的**纯位置结构**；v0.3 只增加来源登记过的四颗小星
（禄存、擎羊、陀罗、天马）；v0.4 只增加可追溯报告、稳定规则编号与关系输出，
不新增传统规则，也不实现通用规则引擎/LLM。四化、限运、大限流年、出生排盘、
吉凶判断均不包含；`Palace.atPos` 的 `anchor` 由使用者提供，本库不计算命宫。
地支藏干明确不属于本库：`DiZhi.wuXing` 只是单一本气。
v0.4 没有实现外部 JSON 证书检查器；JSON 是输出，不是独立证书。
v0.5 的有限查询与完整性证明只在 `PLAN.md` 中规划，尚未实现。
除 `docs/sources.md` §5 登记的三条安星规则外，其余传统说法的原文核对
仍未完成；未登记的内容不作断言。

## 许可证

[MIT License](LICENSE)。
