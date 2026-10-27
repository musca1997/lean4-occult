# PLAN — lean4-occult（v0.1–v0.4 已完成）

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

### v0.2 紫微十二宫纯位置结构 `[x]`

* [x] `Occult/ZiWei/Position.lean`：`Position = Fin 12`；抽象位置与语义名称分开。
* [x] 旋转与加法组合、逆操作：`rotate_add`、`rotate_zero`、`rotate_neg`、
      `rotate_injective`。
* [x] 对宫偏移 6：`opposite_involutive`、`opposite_ne_self`。
* [x] 三合偏移 4/8：`trineForward_three`、
      `trineBackward_eq_trineForward_twice`，两个方向都无不动点。
* [x] 三方四正 `{p, p+4, p+6, p+8}` 基数 4：`triad_card`、`mem_triad_iff`。
* [x] 整体旋转保持对宫/三合/三方四正：`rotate_opposite`、
      `rotate_trineForward`、`rotate_trineBackward`、`rotate_triad`、
      `rotate_triad_card`、`mem_triad_rotate_iff`。
* [x] 语义层 `Occult/ZiWei/Relations.lean`：`Palace` 十二宫名、`offset`、`atPos`
      与任意 `anchor` 下的语义对宫/命宫三方四正；`offset_injective`、
      `card_eq_twelve`。
* [x] `Occult/ZiWei/Properties.lean`：整体性质与 `atPos_triad_ming`。
* [x] CLI `lean4-occult ziwei relations <p>`，严格校验 `0..11`，
      非法/缺参/多参退出码 1；smoke 测试覆盖。
* [x] Tests 回归与文档（conventions/scope/sources/README）同步。
* [x] **不做**星曜、出生排盘、四化、限运等依赖历法或未核查传统说法的内容。

### v0.3 来源明确的小安星子系统 `[x]`

* [x] 选定子系统：年干/年支系小安星——禄存（依年干）、擎羊/陀罗（随禄存
      前/后一位）、天马（依年支）。
* [x] 来源登记到 `docs/sources.md` §5：维基文库《紫微斗數全書》卷二
      （修订号 1963110，永久 URL，访问日期 2026-10-20）的〈安祿存星訣〉
      〈安擎羊陀羅二星訣〉〈安天馬星訣〉；并以明刊本
      《新鋟希夷陳先生紫微斗數全書》七卷（Internet Archive
      `20260506_20260506_1217`，扫描叶 75）作版本/叶面见证。
* [x] 逐条给出短引文、卷次/段落/叶面定位、URL、访问日期；标明哪些是
      来源支持、哪些是文本读法解释、哪些是项目约定。
* [x] 分析来源可靠性、版本/派别范围与同名不同规则：只覆盖《全書》系统；
      只做生年禄存/羊陀/天马，不做流禄、流羊、流陀、流年天马、月马；
      天魁/天钺因歌诀异文且未说明组内魁/钺归属而**不实现**；红鸾/天喜
      本版本次不实现。
* [x] `Occult/ZiWei/Branch.lean`：十二支与 `Position = Fin 12` 的编号对接
      （子 0、丑 1、…、亥 11，明确为项目约定），双射与往返定理；
      与现有抽象宫位/地支映射的对接在 `docs/conventions.md` §7 说明。
* [x] `Occult/ZiWei/MinorStar.lean`：四颗命名星曜类型 `Star`、四张安星表、
      `place`/`placeJiaZi` 安星函数、范围/基数/同宫/非单射/互不同位等
      关系定理（45 条新 theorem/lemma）。
* [x] CLI `lean4-occult ziwei anstar <天干> <地支>`：严格校验 2 个参数、
      天干/地支是否可解析、是否同阴阳（属于六十甲子）；非法/缺参/多参
      退出码 1。smoke 覆盖正例与负例。
* [x] Tests 增加地支映射、四张表、来源例子（癸禄在子）、像的基数、
      综合安星样例（甲子/癸亥）等回归检查。
* [x] 文档同步：README、`docs/sources.md`、`docs/conventions.md`、
      `docs/scope.md`；来源短引文注明版权与定位，不复制整节。
* [x] `scripts/check_hygiene.sh` 覆盖当时新定理（v0.3 时共 196 条；当前 v0.4 共 215 条），仍只允许
      `propext`、`Classical.choice`、`Quot.sound`。
* [x] **不做**出生排盘、历法、时区、真太阳时、四化、限运、吉凶预测；
      `place` 的输入是**已给定**的年干/年支，不从日期推算。

### v0.4 可追溯解释报告与 JSON `[x]`

* [x] `Occult/ZiWei/Explain.lean`：稳定规则编号 `RuleId`（7 项），严格区分
      `source-supported` / `project-convention` / `mathematical-consequence`。
* [x] 四条来源规则接到 `docs/sources.md` §5/§6 已登记的来源 A/B：固定修订号、
      段落/叶面定位、永久 URL、访问日期、短引文；不伪造来源。
* [x] `Report` 包含输入、四星位置（支名 + 0–11）、规则、推导节点、六组两两关系；
      位置全部调用 v0.3 的 `placeJiaZi`，不在报告层重写规则。
* [x] `Report.Correct` 是实际命题（位置等于计算函数、关系成立、覆盖四星与全部
      规则）；`buildReport_correct` 对任意 `JiaZi` 证明。
* [x] 关系分类只读取 `Position`：同宫/对宫/三合/相邻/不同宫，固定优先级；
      `classify_sound` 证明分类结果满足相应位置命题；明确不是吉凶解释。
* [x] 固定文字模板 `renderReport` 只渲染可检验字段；明确标注已验证结构化层、
      来源转录人工信任边界，以及本版**没有**外部 JSON certificate checker。
* [x] JSON 用标准库 `Lean.Json` 构造与转义，`schemaVersion = 0.4.0`；
      stdout 纯 JSON，错误 stderr + 非 0；文档 `docs/report-schema.md` 与
      `docs/examples/explain-jiazi.{json,txt}`。
* [x] CLI `lean4-occult ziwei explain <天干> <地支> [--json]`，保留已有 CLI；
      严格校验 `--json` 位置、重复/未知 flag、缺参/多参和同阴阳。
* [x] `Tests.lean` 增加 v0.4 回归与 JSON 转义 `#guard`；
      `scripts/test_json.py` 穷举 60 个输入，检查文本、JSON、`anstar` 与独立
      关系分类一致；`scripts/smoke.sh` 覆盖正负例。
* [x] `scripts/check_hygiene.sh` 支持带点定理名；215 条 theorem/lemma 全部
      通过公理白名单。
* [x] 同步 README / `docs/sources.md` / `docs/conventions.md` / `docs/scope.md`。
* [x] **不做**新传统规则、通用规则引擎、LLM、出生排盘、UI；不声称来源校勘
      或吉凶有效性。

### v0.5 有限查询与完整性证明（仅规划，未实现） `[ ]`

* [ ] 有限查询 API（例如按规则编号/星曜/关系筛选报告字段），仍只做位置事实。
* [ ] 完整性/唯一性证明：明确“这六组关系覆盖全部无序星对”“分类在给定优先级下
      唯一”等陈述，并为查询结果建立相应健全性/完整性定理。
* [ ] 若引入外部证书，需单独实现并测试从 JSON 重新验证的 checker；本版没有。
* [ ] 不把自然语言模板全文形式化；继续区分结构化证明与来源转录信任边界。

### 之后：规则引擎 / AI `[ ]`

* 在有限结构与来源登记稳定之后，再考虑刑冲合害等规则引擎与机器学习辅助；
* 这些都不属于“可证明的有限组合结构”，需要单独的范围文件与免责声明。

## 验收标准（v0.1–v0.4）

1. `lake build` 通过，无 `sorry`/`axiom`/`native_decide`。
2. `#print axioms` 只出现 Lean 标准公理（`propext`、`Classical.choice`、`Quot.sound`）。
3. CLI 的合法/非法调用（`cycle`、`pair`、`ziwei relations`、`ziwei anstar`、
   `ziwei explain`）行为符合 README；smoke 覆盖正负例。
4. 文档明确区分「数学事实」「项目约定」「来源支持的有限规则」「未核查的传统说法」。
5. v0.3/v0.4 的每条编码规则都能追溯到 `docs/sources.md` 登记的版本、段落/叶面、
   URL、访问日期与短引文；不能追溯的内容不实现。
6. 证明性质只陈述“按来源表格计算会得到什么”，不声称传统体系有效。
7. v0.4 报告的每个星位/关系都由实际输入与规则推出（`buildReport_correct`），
   JSON 是输出而非外部证书；未实现的外部 checker 明确标注。
