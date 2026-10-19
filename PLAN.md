# PLAN — lean4-occult v0.1

状态标记：`[x]` 已完成并经过本地验证，`[ ]` 未开始，`[~]` 有意排除在 v0.1 之外。

## 目标

一个**只做有限组合结构与可证明性质**的 Lean 4 库：阴阳、五行、十天干、十二地支、
六十甲子。所有数学陈述都用 Lean 证明，不引入 `axiom`、不使用 `sorry`/`admit`/
`native_decide` 之类的证明捷径。传统来源与项目约定严格分开记录。

## 里程碑

### M0 工具链与骨架 `[x]`

- [x] 用户级安装 elan（`~/.elan`，未使用 sudo，未改系统配置）
- [x] 固定工具链 `leanprover/lean4:v4.35.0`（`lean-toolchain`）
- [x] Lake 包 `lean4_occult`，根库 `Occult`，根命名空间 `Occult`
- [x] Mathlib 依赖固定到 `v4.35.0`（`lakefile.toml` 的 `rev`）
- [x] 使用 Mathlib 预编译缓存（`lake update` 下载 9031 个文件），未完整构建 Mathlib
- [x] `git init`
- [x] 发布采用 MIT License
- [x] 提交并推送到公开仓库 `musca1997/lean4-occult`

### M1 有限结构 `[x]`

- [x] `Occult/YinYang.lean`：`YinYang`（`yin`/`yang`），对合 `neg`，`Fintype`，`Fin 2` 等价
- [x] `Occult/WuXing.lean`：`WuXing`（木火土金水），相生 `next`、相克 `overcomes`，`Fin 5` 等价
- [x] `Occult/TianGan.lean`：`TianGan`（甲乙丙丁戊己庚辛壬癸），`Fin 10` 等价，汉字解析
- [x] `Occult/DiZhi.lean`：`DiZhi`（子丑寅卯辰巳午未申酉戌亥），`Fin 12` 等价，汉字解析
- [x] `Occult/JiaZi.lean`：`JiaZi` 结构（同阴阳约束），`Fin 60` 等价，`next`，解析/打印

### M2 定理 `[x]`

- [x] 编码往返：`ofFin_toFin` / `toFin_ofFin`（四个类型各一组）
- [x] 基数：`card_eq_two` / `card_eq_five` / `card_eq_ten` / `card_eq_twelve` / `card_eq_sixty`
- [x] 阴阳映射：`YinYang.ofParity_eq_iff`、`ofParity_succ`、`ofParity_mod`
- [x] 五行周期：`next_five`、`next_period_iff`（`5 ∣ n`，即最小正周期 5）、`overcomes_five`
- [x] 六十甲子 60 周期：`next_sixty`（上界）
- [x] 六十甲子**最小**正周期：`next_period_iff`（`60 ∣ n`）、`next_min_period`
- [x] 同阴阳配对双射：`sameParityEquiv`、`card_sameParity_pairs`、`existsUnique_index`
- [x] 相位投影：`stem_toNat_eq` / `branch_toNat_eq` / `ofIndex_coords`
- [x] 天干五行映射：`TianGan.wuXing`（甲乙木…壬癸水），`wuXing_toFin`、`wuXing_eq_iff`、
      `wuXing_ofNatMod_add_two`
- [x] 地支**本气**五行映射：`DiZhi.wuXing`（明确**不是藏干**），`wuXing_toFin`、
      `wuXing_ofNatMod_toNat`
- [x] 六十甲子后退 `JiaZi.prev` 及前后互逆：`prev_next`、`next_prev`、`prev_injective`、
      `prev_sixty`、`prev_period_iff`
- [x] 五行生克逆向 API：`WuXing.prev`、`WuXing.overcomeBy` 与
      `next_eq_iff_prev`、`overcomes_eq_iff_overcomeBy`、各自互逆与周期/无不动点定理
- [x] 共 108 条 theorem/lemma（含 CLI 解析，见 `docs/scope.md` 清单）

### M3 CLI `[x]`

- [x] `lean4-occult cycle <n>`：0–59 校验，输出甲子与下一步
- [x] `lean4-occult pair <天干> <地支>`：逐字解析 + 同阴阳校验
- [x] `lean4-occult list`：列出全部 60 位
- [x] 非法输入（越界、负号、混字母、空串、未知字、阴阳不同、参数不足/过多）退出码 1，stderr 说明
- [x] `Occult/Cli.lean`：可测试的 `parseNat?`，不使用会 panic 的 `String.toNat!`
- [x] 实测：`cycle 0` / `cycle 59` / `pair 甲 子` / `pair 甲 丑` 等（见 README 的验证记录）

### M4 文档与 CI `[x]`

- [x] `README.md`（中文）
- [x] `docs/conventions.md`：索引、阴阳、方向等全部约定
- [x] `docs/sources.md`：来源与**未核查**内容，不编造引文
- [x] `docs/scope.md`：v0.1 范围与定理清单
- [x] `PLAN.md`（本文件）
- [x] `.github/workflows/ci.yml`：固定工具链 + `lake exe cache get` + `lake build` + CLI 冒烟测试
- [x] `scripts/smoke.sh`：本地 CLI 有效/非法输入回归

### M5 证明卫生自动拦截 `[x]`

- [x] `scripts/check_hygiene.sh`：扫描禁用关键字与自定义 `axiom`/`constant` 声明
- [x] 对库内全部 theorem/lemma 运行 `#print axioms`，白名单仅
      `propext`、`Classical.choice`、`Quot.sound`；出现其他公理即失败
- [x] CI 调用该脚本，而不是只“打印”公理

### M5.5 明确不在 v0.1 `[~]`

- [~] 规则引擎（刑冲合害、藏干、十神、旺衰）
- [~] 紫微斗数、西方占星
- [~] 出生时间排盘（需要历法/时区/真太阳时，属于经验建模而非本库的数学核心）
- [~] UI / Web / 数据库
- [~] 对传统文献的引文核对（见 `docs/sources.md` 的“未核查”一节）

## 路线图（v0.2 及以后）

以下只是方向，**未完成的条目不写成已完成**；每个版本仍需构建、测试与公理检查通过。

### v0.2 紫微十二宫纯位置结构 `[ ]`

* `Fin 12` 表示宫位；**抽象位置**与命宫/财帛宫等**语义名称**分开。
* 旋转与加法组合、逆操作；对宫偏移 6（对宫对宫为自身、无不动点）。
* 三合偏移 4/8（三次偏移 4 回原位）；三方四正有限集 `{p, p+4, p+6, p+8}` 基数为 4。
* 整体旋转保持对宫、三合、三方四正。
* CLI `lean4-occult ziwei relations <p>`，严格校验 `0..11`，非法/缺参/多参报错。
* **不做**星曜、出生排盘、四化、限运等依赖历法或未核查传统说法的内容。

### v0.3 来源明确的小安星子系统 `[ ]`

* 仅当能给出可核查来源（版本、卷次、页码）并逐条登记到 `docs/sources.md` 时才开始。
* 在此之前，不对小安星的具体起例作任何断言。

### 之后：规则引擎 / AI `[ ]`

* 在有限结构与来源登记稳定之后，再考虑刑冲合害等规则引擎与机器学习辅助；
* 这些都不属于“可证明的有限组合结构”，需要单独的范围文件与免责声明。

## 验收标准（v0.1）

1. `lake build` 通过，无 `sorry`/`axiom`/`native_decide`。
2. `#print axioms` 只出现 Lean 标准公理（`propext`、`Classical.choice`、`Quot.sound`）。
3. CLI 的四类调用（`cycle` 合法/非法、`pair` 合法/非法）行为符合 README。
4. 文档明确区分「数学事实」「项目约定」「未核查的传统说法」。
