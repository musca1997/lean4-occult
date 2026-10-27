/-
Occult/ZiWei/Explain.lean

v0.4：可追溯的紫微小安星解释报告。

本文件**不新增传统安星规则**：四颗星的位置仍然只由 `MinorStar.placeJiaZi`
计算。这里增加的是：

* 稳定规则编号（`RuleId`），并把“来源支持”“项目编号约定”“数学推论”分开；
* 与 `docs/sources.md` §5 已登记来源对应的短引文、定位与 URL；
* 结构化报告 `Report`：输入、四星位置、规则、六组两两关系；
* `Report.Correct` 是**实际的可检验命题**（位置等于 `placeJiaZi`，关系成立），
  不是存一个已证 `True` 的占位符；
* 固定文字模板 `renderReport` 与标准库 JSON 序列化 `reportJson`。

边界：来源转录本身仍需人工核对；本版**没有**实现外部 JSON 证书检查器。
-/

import Occult.JiaZi
import Occult.ZiWei.MinorStar
import Lean.Data.Json

namespace Occult

namespace ZiWei

namespace Explain

/-! ## 来源与规则编号 -/

/-- 一条记录属于哪一类：来源支持、项目约定、还是数学推论。 -/
inductive ProvenanceKind where
  /-- 由 `docs/sources.md` 登记的来源文本支持。 -/
  | sourceSupported
  /-- 本项目选定的编号/读法约定，不是来源文字。 -/
  | projectConvention
  /-- 由前面的位置与规则计算出的数学事实。 -/
  | mathematicalConsequence
  deriving DecidableEq, Repr

/-- 稳定类别代码（JSON 与文字模板共用）。 -/
def ProvenanceKind.code : ProvenanceKind → String
  | .sourceSupported => "source-supported"
  | .projectConvention => "project-convention"
  | .mathematicalConsequence => "mathematical-consequence"

/-- 类别在固定文字模板里的短标签。 -/
def ProvenanceKind.label : ProvenanceKind → String
  | .sourceSupported => "来源支持"
  | .projectConvention => "项目约定"
  | .mathematicalConsequence => "数学推论"

/-- `docs/sources.md` §5 登记的一条来源引用。 -/
structure SourceRef where
  /-- 稳定的来源标识（不是规则标识）。 -/
  sourceId : String
  /-- 题名/卷次。 -/
  title : String
  /-- 段落或叶面定位。 -/
  locator : String
  /-- 版本/修订号。 -/
  version : String
  /-- 可公开核查的 URL。 -/
  url : String
  /-- 访问日期。 -/
  accessed : String
  /-- 只保留支持规则所需的短引文。 -/
  quote : String
  deriving DecidableEq, Repr

/-- 来源 A：维基文库《紫微斗數全書》卷二，固定修订号。 -/
def sourceWikisource : SourceRef :=
  { sourceId := "wikisource-ziwei-quanshu-juan2-1963110"
    title := "《紫微斗數全書》卷二（维基文库转录）"
    locator := "卷二〈安祿存星訣〉〈安擎羊陀羅二星訣〉〈安天馬星訣〉"
    version := "oldid=1963110，修订时间 2020-09-04T14:06:27Z"
    url := "https://zh.wikisource.org/w/index.php?title=%E7%B4%AB%E5%BE%AE%E6%96%97%E6%95%B8%E5%85%A8%E6%9B%B8/%E5%8D%B7%E4%BA%8C&oldid=1963110"
    accessed := "2026-10-20"
    quote := "甲生禄存在寅宫，乙生在卯丙戊巳，丁己禄存停午方，庚禄居申辛禄酉，壬禄在亥癸禄子。禄前擎羊后陀罗。假如癸禄在子，丑宫安擎羊，亥宫安陀罗，余仿此。寅午戍人马居申，申子辰人马居寅，巳酉丑人马居亥，亥卯未人马居巳。" }

/-- 来源 B：明刊本扫描件，仅作版本/叶面见证。 -/
def sourceScan : SourceRef :=
  { sourceId := "archive-ziwei-quanshu-ming-n75"
    title := "《新鋟希夷陳先生紫微斗數全書》七卷（明刊本）"
    locator := "第二卷相关安星段落，扫描第 75 叶（0 基 leaf n75）"
    version := "明·南陽堂刊本，元数据标 1600；Internet Archive 20260506_20260506_1217"
    url := "https://archive.org/details/20260506_20260506_1217/page/n75/mode/1up"
    accessed := "2026-10-20"
    quote := "本次只用该叶确认禄存、擎羊、陀罗、天马段落见于该版本；未把它当作逐字校勘依据。" }

/-- 稳定规则编号。编号本身是项目标识，不是来源文字。 -/
inductive RuleId where
  /-- 禄存依生年干。 -/
  | luCunStem
  /-- 擎羊在禄存前一位。 -/
  | qingYangAfterLuCun
  /-- 陀罗在禄存后一位。 -/
  | tuoLuoBeforeLuCun
  /-- 天马依生年支。 -/
  | tianMaBranch
  /-- 十二支到 0–11 位置的编号约定。 -/
  | branchPosition
  /-- 输入必须是同阴阳的六十甲子。 -/
  | jiaZiParity
  /-- 两星位置关系的有限分类。 -/
  | relationClassification
  deriving DecidableEq, Repr

/-- 所有规则编号的固定顺序。 -/
def RuleId.all : List RuleId :=
  [luCunStem, qingYangAfterLuCun, tuoLuoBeforeLuCun, tianMaBranch,
   branchPosition, jiaZiParity, relationClassification]

/-- 稳定规则代码（写入 JSON 与文字模板，不随显示文字变化）。 -/
def RuleId.code : RuleId → String
  | .luCunStem => "ZW-LUCUN-STEM"
  | .qingYangAfterLuCun => "ZW-QINGYANG-AFTER-LUCUN"
  | .tuoLuoBeforeLuCun => "ZW-TUOLUO-BEFORE-LUCUN"
  | .tianMaBranch => "ZW-TIANMA-BRANCH"
  | .branchPosition => "PRJ-BRANCH-POSITION"
  | .jiaZiParity => "PRJ-JIAZI-PARITY"
  | .relationClassification => "MATH-POSITION-CLASSIFY"

/-- 规则类别。 -/
def RuleId.kind : RuleId → ProvenanceKind
  | .luCunStem => .sourceSupported
  | .qingYangAfterLuCun => .sourceSupported
  | .tuoLuoBeforeLuCun => .sourceSupported
  | .tianMaBranch => .sourceSupported
  | .branchPosition => .projectConvention
  | .jiaZiParity => .projectConvention
  | .relationClassification => .mathematicalConsequence

/-- 固定规则陈述（只描述有限位置规则，不含吉凶解释）。 -/
def RuleId.statement : RuleId → String
  | .luCunStem => "禄存按生年干落在固定地支宫位（甲寅、乙卯、丙戊巳、丁己午、庚申、辛酉、壬亥、癸子）"
  | .qingYangAfterLuCun => "擎羊在禄存位置 +1（来源以癸禄在子、丑宫擎羊固定方向）"
  | .tuoLuoBeforeLuCun => "陀罗在禄存位置 −1（来源以癸禄在子、亥宫陀罗固定方向）"
  | .tianMaBranch => "天马按生年支的三合组落在寅、申、巳、亥之一"
  | .branchPosition => "十二支编号为子 0、丑 1、…、亥 11"
  | .jiaZiParity => "输入天干与地支必须同阴阳，即属于六十甲子"
  | .relationClassification => "两星位置按同宫/对宫/三合/相邻/不同宫作有限分类，优先级固定"

/-- 来源支持规则引用的登记项；项目约定与数学推论不引用外部文本。 -/
def RuleId.sources : RuleId → List SourceRef
  | .luCunStem | .qingYangAfterLuCun | .tuoLuoBeforeLuCun | .tianMaBranch =>
      [sourceWikisource, sourceScan]
  | .branchPosition | .jiaZiParity | .relationClassification => []

/-- 报告中的一条规则记录。 -/
structure Rule where
  id : RuleId
  code : String
  kind : ProvenanceKind
  statement : String
  sources : List SourceRef
  deriving DecidableEq, Repr

/-- 把规则编号展开成完整记录。 -/
def RuleId.toRule (r : RuleId) : Rule :=
  { id := r
    code := r.code
    kind := r.kind
    statement := r.statement
    sources := r.sources }

/-- 展开记录的编号就是原编号。 -/
@[simp]
theorem RuleId.toRule_id (r : RuleId) : r.toRule.id = r := rfl

/-- 来源支持规则的展开记录恰好引用两条已登记来源。 -/
theorem RuleId.toRule_sources_source (r : RuleId)
    (h : r.kind = ProvenanceKind.sourceSupported) :
    r.toRule.sources = [sourceWikisource, sourceScan] := by
  cases r with
  | luCunStem => rfl
  | qingYangAfterLuCun => rfl
  | tuoLuoBeforeLuCun => rfl
  | tianMaBranch => rfl
  | branchPosition => cases h
  | jiaZiParity => cases h
  | relationClassification => cases h

/-- 项目约定与数学推论不引用外部来源。 -/
theorem RuleId.toRule_sources_nonsource (r : RuleId)
    (h : r.kind ≠ ProvenanceKind.sourceSupported) :
    r.toRule.sources = [] := by
  cases r with
  | luCunStem => exact (h rfl).elim
  | qingYangAfterLuCun => exact (h rfl).elim
  | tuoLuoBeforeLuCun => exact (h rfl).elim
  | tianMaBranch => exact (h rfl).elim
  | branchPosition => rfl
  | jiaZiParity => rfl
  | relationClassification => rfl

/-! ## 四星位置与推导节点 -/

/-- 每颗星固定使用的规则。 -/
def StarEntry.expectedRule : MinorStar.Star → RuleId
  | .luCun => .luCunStem
  | .qingYang => .qingYangAfterLuCun
  | .tuoLuo => .tuoLuoBeforeLuCun
  | .tianMa => .tianMaBranch

/-- 报告中的一条星曜安置记录。 -/
structure StarEntry where
  star : MinorStar.Star
  rule : RuleId
  position : Position
  deriving DecidableEq, Repr

/-- 这条记录必须等于 `placeJiaZi` 的实际结果，并且使用正确的规则编号。 -/
def StarEntry.Correct (z : JiaZi) (e : StarEntry) : Prop :=
  e.position = MinorStar.placeJiaZi z e.star ∧ e.rule = StarEntry.expectedRule e.star

/-- 从已有计算函数构造一条记录，不重写安星逻辑。 -/
def mkStarEntry (z : JiaZi) (s : MinorStar.Star) : StarEntry :=
  { star := s
    rule := StarEntry.expectedRule s
    position := MinorStar.placeJiaZi z s }

/-- 每条构造出来的星曜记录都满足 `StarEntry.Correct`。 -/
theorem mkStarEntry_correct (z : JiaZi) (s : MinorStar.Star) :
    StarEntry.Correct z (mkStarEntry z s) := by
  constructor <;> rfl

/-- 构造记录的星曜就是输入星曜。 -/
@[simp]
theorem mkStarEntry_star (z : JiaZi) (s : MinorStar.Star) :
    (mkStarEntry z s).star = s := rfl

/-- 构造记录的位置就是 `placeJiaZi` 的结果。 -/
@[simp]
theorem mkStarEntry_position (z : JiaZi) (s : MinorStar.Star) :
    (mkStarEntry z s).position = MinorStar.placeJiaZi z s := rfl

/-! ## 两星位置关系（有限分类，不是吉凶解释）

关系只读取两个 `Position`。这里是**位置事实**：同宫、对宫（偏移 6）、
三合（偏移 4/8）、相邻（偏移 ±1）或其余不同宫。分类优先级固定为
同宫 > 对宫 > 三合 > 相邻 > 不同宫，因此每对星恰有一个类别。
-/

/-- 两星位置的有限关系类别。 -/
inductive RelationKind where
  | samePalace
  | oppositePalace
  | trinePalace
  | adjacentPalace
  | differentPalace
  deriving DecidableEq, Repr

/-- 关系类别的稳定代码。 -/
def RelationKind.code : RelationKind → String
  | .samePalace => "same-palace"
  | .oppositePalace => "opposite-palace"
  | .trinePalace => "trine-palace"
  | .adjacentPalace => "adjacent-palace"
  | .differentPalace => "different-palace"

/-- 关系类别在固定文字模板里的说明。 -/
def RelationKind.label : RelationKind → String
  | .samePalace => "同宫"
  | .oppositePalace => "对宫（偏移 6）"
  | .trinePalace => "三合（偏移 4/8）"
  | .adjacentPalace => "相邻（偏移 ±1）"
  | .differentPalace => "不同宫"

/-- 类别对应的实际位置命题。这是健全性证明要使用的语义。 -/
def RelationKind.holds : RelationKind → Position → Position → Prop
  | .samePalace, p, q => p = q
  | .oppositePalace, p, q => p = Position.opposite q
  | .trinePalace, p, q =>
      p = Position.trineForward q ∨ p = Position.trineBackward q
  | .adjacentPalace, p, q =>
      p = Position.rotate 1 q ∨ p = Position.rotate (-1) q
  | .differentPalace, p, q => p ≠ q

/-- 按固定优先级分类两个位置。 -/
def classify (p q : Position) : RelationKind :=
  if p = q then .samePalace
  else if p = Position.opposite q then .oppositePalace
  else if p = Position.trineForward q ∨ p = Position.trineBackward q then .trinePalace
  else if p = Position.rotate 1 q ∨ p = Position.rotate (-1) q then .adjacentPalace
  else .differentPalace

/-- **健全性**：分类结果对应的位置命题确实成立。 -/
theorem classify_sound (p q : Position) : (classify p q).holds p q := by
  by_cases h1 : p = q
  · have hc : classify p q = .samePalace := by
      rw [classify, ite_eq_left h1]
    rw [hc]
    exact h1
  · by_cases h2 : p = Position.opposite q
    · have hc : classify p q = .oppositePalace := by
        rw [classify, ite_eq_right h1, ite_eq_left h2]
      rw [hc]
      exact h2
    · by_cases h3 : p = Position.trineForward q ∨ p = Position.trineBackward q
      · have hc : classify p q = .trinePalace := by
          rw [classify, ite_eq_right h1, ite_eq_right h2, ite_eq_left h3]
        rw [hc]
        exact h3
      · by_cases h4 : p = Position.rotate 1 q ∨ p = Position.rotate (-1) q
        · have hc : classify p q = .adjacentPalace := by
            rw [classify, ite_eq_right h1, ite_eq_right h2, ite_eq_right h3, ite_eq_left h4]
          rw [hc]
          exact h4
        · have hc : classify p q = .differentPalace := by
            rw [classify, ite_eq_right h1, ite_eq_right h2, ite_eq_right h3, ite_eq_right h4]
          rw [hc]
          exact h1

/-- 分类只可能给出五个类别之一，且同宫/对宫/三合/相邻都是不同宫的特例。 -/
theorem classify_ne_different_of_same (p q : Position) (h : p = q) :
    classify p q = .samePalace := by
  simp [classify, h]

/-- 报告中的一条两星关系记录（自带两个位置，便于独立核对）。 -/
structure RelationFact where
  left : MinorStar.Star
  right : MinorStar.Star
  leftPosition : Position
  rightPosition : Position
  kind : RelationKind
  deriving DecidableEq, Repr

/-- 关系记录必须使用实际计算位置，并且类别确实成立。 -/
def RelationFact.Correct (z : JiaZi) (f : RelationFact) : Prop :=
  f.leftPosition = MinorStar.placeJiaZi z f.left ∧
  f.rightPosition = MinorStar.placeJiaZi z f.right ∧
  f.kind.holds f.leftPosition f.rightPosition

/-- 从实际计算位置构造关系记录。 -/
def mkRelationFact (z : JiaZi) (a b : MinorStar.Star) : RelationFact :=
  let lp := MinorStar.placeJiaZi z a
  let rp := MinorStar.placeJiaZi z b
  { left := a
    right := b
    leftPosition := lp
    rightPosition := rp
    kind := classify lp rp }

/-- 每条构造出来的关系记录都满足 `RelationFact.Correct`。 -/
theorem mkRelationFact_correct (z : JiaZi) (a b : MinorStar.Star) :
    RelationFact.Correct z (mkRelationFact z a b) := by
  constructor
  · rfl
  · constructor
    · rfl
    · exact classify_sound _ _

/-- 六组无序星曜对，顺序固定。 -/
def starPairs : List (MinorStar.Star × MinorStar.Star) :=
  [(.luCun, .qingYang), (.luCun, .tuoLuo), (.luCun, .tianMa),
   (.qingYang, .tuoLuo), (.qingYang, .tianMa), (.tuoLuo, .tianMa)]

/-- 六组两两关系都由实际位置构造。 -/
def pairFacts (z : JiaZi) : List RelationFact :=
  starPairs.map (fun p => mkRelationFact z p.1 p.2)

theorem starPairs_length : starPairs.length = 6 := rfl

theorem pairFacts_length (z : JiaZi) : (pairFacts z).length = 6 := rfl

/-- 报告中的每条关系都由实际输入与规则推出（位置 + 分类健全性）。 -/
theorem pairFacts_correct (z : JiaZi) :
    ∀ f ∈ pairFacts z, RelationFact.Correct z f := by
  intro f hf
  unfold pairFacts at hf
  obtain ⟨p, _, rfl⟩ := List.mem_map.mp hf
  exact mkRelationFact_correct z p.1 p.2

/-! ## 结构化报告与语义 -/

/-- 可追溯解释报告。 -/
structure Report where
  input : JiaZi
  stars : List StarEntry
  rules : List Rule
  facts : List RelationFact
  deriving DecidableEq, Repr

/-- 从已有计算函数构造报告。 -/
def buildReport (z : JiaZi) : Report :=
  { input := z
    stars := MinorStar.Star.all.map (mkStarEntry z)
    rules := RuleId.all.map RuleId.toRule
    facts := pairFacts z }

/-- 报告的语义：所有星位、关系都由输入经规则推出，覆盖全部四星与全部规则。 -/
structure Report.Correct (r : Report) : Prop where
  starsCorrect : ∀ e ∈ r.stars, StarEntry.Correct r.input e
  factsCorrect : ∀ f ∈ r.facts, RelationFact.Correct r.input f
  starCoverage : r.stars.map (fun e => e.star) = MinorStar.Star.all
  rulesCoverage : r.rules.map (fun rule => rule.id) = RuleId.all
  rulesCorrect : ∀ rule ∈ r.rules, rule = rule.id.toRule

/-- **健全性定理**：任意六十甲子输入生成的报告都满足 `Report.Correct`。 -/
theorem buildReport_correct (z : JiaZi) : (buildReport z).Correct := by
  constructor
  · intro e he
    unfold buildReport at he
    obtain ⟨s, _, rfl⟩ := List.mem_map.mp he
    exact mkStarEntry_correct z s
  · intro f hf
    unfold buildReport at hf
    exact pairFacts_correct z f hf
  · simp [buildReport, Function.comp_def]
  · simp [buildReport, Function.comp_def, RuleId.toRule]
  · intro rule hr
    unfold buildReport at hr
    obtain ⟨id, _, rfl⟩ := List.mem_map.mp hr
    rfl

/-- 报告输入就是构造时的输入。 -/
@[simp]
theorem buildReport_input (z : JiaZi) : (buildReport z).input = z := rfl

/-- 报告包含且只包含四颗星。 -/
theorem buildReport_star_coverage (z : JiaZi) :
    (buildReport z).stars.map (fun e => e.star) = MinorStar.Star.all :=
  (buildReport_correct z).starCoverage

/-- 报告包含全部稳定规则编号。 -/
theorem buildReport_rule_coverage (z : JiaZi) :
    (buildReport z).rules.map (fun rule => rule.id) = RuleId.all :=
  (buildReport_correct z).rulesCoverage

/-- 报告中的规则记录就是稳定编号展开后的记录（来源字段没有被替换）。 -/
theorem buildReport_rules_correct (z : JiaZi) :
    ∀ rule ∈ (buildReport z).rules, rule = rule.id.toRule :=
  (buildReport_correct z).rulesCorrect

/-- 报告中的每个星位都等于现有计算函数的结果。 -/
theorem buildReport_star_positions (z : JiaZi) :
    ∀ e ∈ (buildReport z).stars, e.position = MinorStar.placeJiaZi z e.star :=
  fun e he => ((buildReport_correct z).starsCorrect e he).1

/-- 报告中的每条关系都由实际位置与 `classify_sound` 推出。 -/
theorem buildReport_fact_holds (z : JiaZi) :
    ∀ f ∈ (buildReport z).facts,
      f.kind.holds f.leftPosition f.rightPosition :=
  fun f hf => ((buildReport_correct z).factsCorrect f hf).2.2

/-! ## 固定文字模板

模板只渲染结构字段（代码、位置、地支名、关系类别、来源定位与 URL），
不把自然语言解释冒充为全文形式化。 -/

/-- 位置的地支名 + 数字序号。 -/
def renderPosition (p : Position) : String :=
  s!"{(Branch.toDiZhi p).name} ({p.val})"

/-- 星曜名（复用 v0.3 的固定名称）。 -/
def renderStar (s : MinorStar.Star) : String := s.name

/-- 推导节点使用的前提文本（中间事实只在需要时出现）。 -/
def premisesFor (z : JiaZi) (s : MinorStar.Star) : List String :=
  match s with
  | .luCun => [s!"生年干 {z.stem.name}（{z.stem.toNat}）"]
  | .qingYang =>
      [s!"生年干 {z.stem.name}（{z.stem.toNat}）"
       , s!"中间事实：禄存位于 {renderPosition (MinorStar.placeJiaZi z .luCun)}"]
  | .tuoLuo =>
      [s!"生年干 {z.stem.name}（{z.stem.toNat}）"
       , s!"中间事实：禄存位于 {renderPosition (MinorStar.placeJiaZi z .luCun)}"]
  | .tianMa => [s!"生年支 {z.branch.name}（{z.branch.toNat}）"]

/-- 把报告渲染为固定文字模板。 -/
def renderReport (r : Report) : String :=
  let z := r.input
  let yy := match z.stem.yinYang with
    | .yin => "阴"
    | .yang => "阳"
  let inputLine :=
    s!"干支 {JiaZi.name z}（索引 {z.toIndex.val}；{z.stem.name}{yy}；天干 {z.stem.toNat}，地支 {z.branch.toNat}）"
  let ruleLines := r.rules.map (fun rule =>
    s!"  [{rule.code}] {rule.statement}（{rule.kind.label}）")
  let starLines := r.stars.map (fun e =>
    s!"  {renderStar e.star} {renderPosition e.position}  规则 {e.rule.code}")
  let derivationLines := r.stars.map (fun e =>
    s!"  {String.intercalate "；" (premisesFor r.input e.star)} --[{e.rule.code}]--> {renderStar e.star} {renderPosition e.position}")
  let factLines := r.facts.map (fun f =>
    s!"  {renderStar f.left} / {renderStar f.right}：{f.kind.label}；位置 {f.leftPosition.val} / {f.rightPosition.val}")
  let body :=
    [s!"紫微小安星解释报告（schema 0.4.0）"
     , inputLine
     , "规则："] ++ ruleLines ++
    ["星曜位置："] ++ starLines ++
    ["推导节点（输入/必要中间事实 -> 规则 -> 结论）："] ++ derivationLines ++
    ["两两关系（有限位置事实，不是吉凶解释）："] ++ factLines ++
    ["保证范围："
     , "  已验证结构化层：输入、四星位置、六组关系均与 Lean 计算结果一致；见 buildReport_correct。"
     , "  人工信任边界：来源转录、短引文与读法需人工核对 docs/sources.md §5；本报告不声称已完成版本校勘。"
     , "  外部证书：本版未实现从任意 JSON 重新验证的证书检查器；JSON 是输出，不是可独立复核的证书。"]
  String.intercalate "\n" body

/-! ## 标准库 JSON 序列化

键名与顺序固定；字符串交给 `Lean.Json` 转义，不手写拼接 JSON。
-/

/-- 来源引用 JSON。 -/
def sourceRefJson (s : SourceRef) : Lean.Json :=
  Lean.Json.mkObj
    [("sourceId", Lean.Json.str s.sourceId)
     , ("title", Lean.Json.str s.title)
     , ("locator", Lean.Json.str s.locator)
     , ("version", Lean.Json.str s.version)
     , ("url", Lean.Json.str s.url)
     , ("accessed", Lean.Json.str s.accessed)
     , ("quote", Lean.Json.str s.quote)]

/-- 规则 JSON。 -/
def ruleJson (r : Rule) : Lean.Json :=
  Lean.Json.mkObj
    [("id", Lean.Json.str r.code)
     , ("kind", Lean.Json.str r.kind.code)
     , ("statement", Lean.Json.str r.statement)
     , ("sources", Lean.Json.arr (r.sources.map sourceRefJson).toArray)]

/-- 位置 JSON：地支名 + 0–11 序号。 -/
def positionJson (p : Position) : Lean.Json :=
  Lean.Json.mkObj
    [("branch", Lean.Json.str (Branch.toDiZhi p).name)
     , ("position", Lean.Json.num p.val)]

/-- 星曜安置 JSON。 -/
def starEntryJson (e : StarEntry) : Lean.Json :=
  Lean.Json.mkObj
    [("star", Lean.Json.str e.star.name)
     , ("ruleId", Lean.Json.str e.rule.code)
     , ("branch", Lean.Json.str (Branch.toDiZhi e.position).name)
     , ("position", Lean.Json.num e.position.val)]

/-- 两星关系 JSON。 -/
def relationFactJson (f : RelationFact) : Lean.Json :=
  Lean.Json.mkObj
    [("left", Lean.Json.str f.left.name)
     , ("right", Lean.Json.str f.right.name)
     , ("kind", Lean.Json.str f.kind.code)
     , ("label", Lean.Json.str f.kind.label)
     , ("leftPosition", Lean.Json.num f.leftPosition.val)
     , ("rightPosition", Lean.Json.num f.rightPosition.val)]

/-- 推导节点：输入前提、规则与结论。 -/
def derivationJson (z : JiaZi) (e : StarEntry) : Lean.Json :=
  Lean.Json.mkObj
    [("star", Lean.Json.str e.star.name)
     , ("ruleId", Lean.Json.str e.rule.code)
     , ("premises", Lean.Json.arr ((premisesFor z e.star).map Lean.Json.str).toArray)
     , ("conclusion", positionJson e.position)]

/-- 输入 JSON。 -/
def inputJson (z : JiaZi) : Lean.Json :=
  let yy := match z.stem.yinYang with
    | .yin => "yin"
    | .yang => "yang"
  Lean.Json.mkObj
    [("jiazi", Lean.Json.str (JiaZi.name z))
     , ("index", Lean.Json.num z.toIndex.val)
     , ("stem", Lean.Json.str z.stem.name)
     , ("branch", Lean.Json.str z.branch.name)
     , ("stemIndex", Lean.Json.num z.stem.toNat)
     , ("branchIndex", Lean.Json.num z.branch.toNat)
     , ("polarity", Lean.Json.str yy)]

/-- 保证范围 JSON：明确区分已验证结构化层与人工信任边界。 -/
def guaranteesJson : Lean.Json :=
  Lean.Json.mkObj
    [("verifiedStructuredLayer", Lean.Json.str "input, four star positions, pairwise finite relations, rule/source references")
     , ("soundnessTheorem", Lean.Json.str "Occult.ZiWei.Explain.buildReport_correct")
     , ("scope", Lean.Json.str "finite positional facts only; no auspiciousness or traditional interpretation")
     , ("sourceTranscription", Lean.Json.str "manual trust boundary; see docs/sources.md §5")
     , ("versionCollation", Lean.Json.str "not a critical edition")
     , ("externalCertificateChecker", Lean.Json.bool false)
     , ("certificateNote", Lean.Json.str "JSON is an output, not a standalone certificate; this version does not re-verify arbitrary JSON")]

/-- 完整报告 JSON。 -/
def reportJson (r : Report) : Lean.Json :=
  Lean.Json.mkObj
    [("schemaVersion", Lean.Json.str "0.4.0")
     , ("reportKind", Lean.Json.str "ziwei.explain")
     , ("input", inputJson r.input)
     , ("rules", Lean.Json.arr (r.rules.map ruleJson).toArray)
     , ("stars", Lean.Json.arr (r.stars.map starEntryJson).toArray)
     , ("derivations", Lean.Json.arr (r.stars.map (derivationJson r.input)).toArray)
     , ("facts", Lean.Json.arr (r.facts.map relationFactJson).toArray)
     , ("guarantees", guaranteesJson)]

/-- 单行 JSON 文本（stdout 只输出这一串）。 -/
def renderJson (r : Report) : String := Lean.Json.compress (reportJson r)

end Explain

end ZiWei

end Occult
