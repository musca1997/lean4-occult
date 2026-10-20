/-
Occult/ZiWei/MinorStar.lean

v0.3：来源明确的年干/年支系小安星。

范围仅限于《紫微斗數全書》卷二所载的三条有限安星规则：

* 禄存（依生年干）；
* 擎羊、陀罗（随禄存，前一位/后一位）；
* 天马（依生年支）。

来源、版本、段落定位与短引文见 `docs/sources.md`。本文件只编码
“给定年干/年支后，星曜落在十二支宫位中的哪一位”，**不**实现出生排盘、
历法、流年/大限，也不对吉凶作任何断言。

十二支宫位通过 `Occult.ZiWei.Branch` 与 `Position = Fin 12` 对接：
子 ↦ 0、丑 ↦ 1、…、亥 ↦ 11（项目约定）。
-/

import Occult.JiaZi
import Occult.ZiWei.Branch

namespace Occult

namespace ZiWei

namespace MinorStar

/-- 本子系统涉及的四颗小星。 -/
inductive Star where
  /-- 禄存 -/
  | luCun
  /-- 擎羊 -/
  | qingYang
  /-- 陀罗 -/
  | tuoLuo
  /-- 天马 -/
  | tianMa
  deriving DecidableEq, Repr

/-- 星曜的汉字名（用于 CLI 输出）。 -/
def Star.name : Star → String
  | luCun => "禄存"
  | qingYang => "擎羊"
  | tuoLuo => "陀罗"
  | tianMa => "天马"

/-- 按固定顺序列出四颗星（用于 CLI 输出）。 -/
def Star.all : List Star := [luCun, qingYang, tuoLuo, tianMa]

instance : Fintype Star := Fintype.ofList Star.all (by
  intro x
  cases x <;> simp [Star.all])

/-- 列表 `Star.all` 的长度为 4。 -/
theorem star_all_length : Star.all.length = 4 := rfl

/-- 四颗星恰有四个元素。 -/
theorem star_card_eq_four : Fintype.card Star = 4 := by
  have h : (Finset.univ : Finset Star) = {Star.luCun, Star.qingYang, Star.tuoLuo, Star.tianMa} := by
    ext x
    cases x <;> simp
  calc
    Fintype.card Star = (Finset.univ : Finset Star).card := Finset.card_univ.symm
    _ = ({Star.luCun, Star.qingYang, Star.tuoLuo, Star.tianMa} : Finset Star).card := by rw [h]
    _ = 4 := by decide

/-! ## 禄存（依生年干）

来源：〈安祿存星訣〉“甲生祿存在寅宮，乙生在卯丙戊巳，丁己祿存停午方，
庚祿居申辛祿酉，壬祿在亥癸祿子。”

“丙戊巳”按句意读作“丙、戊在巳”；“丁己…午”读作“丁、己在午”。
这两处是来源文本的紧凑写法，具体读法见 `docs/sources.md`。
-/

/-- 禄存：甲寅、乙卯、丙戊巳、丁己午、庚申、辛酉、壬亥、癸子。 -/
def luCun : TianGan → Position
  | .jia => 2
  | .yi => 3
  | .bing => 5
  | .ding => 6
  | .wu => 5
  | .ji => 6
  | .geng => 8
  | .xin => 9
  | .ren => 11
  | .gui => 0

/-- 禄存的地支表（逐项展开，便于与原文核对）。 -/
theorem luCun_toDiZhi (g : TianGan) :
    Branch.toDiZhi (luCun g) =
      match g with
      | .jia => DiZhi.yin | .yi => DiZhi.mao | .bing => DiZhi.si | .ding => DiZhi.wu
      | .wu => DiZhi.si | .ji => DiZhi.wu | .geng => DiZhi.shen | .xin => DiZhi.you
      | .ren => DiZhi.hai | .gui => DiZhi.zi := by
  cases g <;> rfl

/-- 丙、戊同禄（同在巳宫）。 -/
theorem luCun_bing_eq_wu : luCun TianGan.bing = luCun TianGan.wu := rfl

/-- 丁、己同禄（同在午宫）。 -/
theorem luCun_ding_eq_ji : luCun TianGan.ding = luCun TianGan.ji := rfl

/-- 禄存相同当且仅当两个天干相同，或落在“丙戊”“丁己”这两组同宫对上。 -/
theorem luCun_eq_iff (g h : TianGan) :
    luCun g = luCun h ↔
      g = h ∨
        (g = TianGan.bing ∧ h = TianGan.wu) ∨
        (g = TianGan.wu ∧ h = TianGan.bing) ∨
        (g = TianGan.ding ∧ h = TianGan.ji) ∨
        (g = TianGan.ji ∧ h = TianGan.ding) := by
  cases g <;> cases h <;> decide

/-- 禄存的像：十二支中缺丑、辰、未、戌，恰有八个位置。 -/
theorem luCun_image :
    (Finset.univ.image luCun) = ({0, 2, 3, 5, 6, 8, 9, 11} : Finset Position) := by
  decide

/-- 禄存的像恰有 8 个位置（10 个天干中有两组同宫）。 -/
theorem luCun_image_card : (Finset.univ.image luCun).card = 8 := by
  rw [luCun_image]
  decide

/-! ## 擎羊、陀罗（随禄存前/后一位）

来源：〈安擎羊陀羅二星訣〉“祿前擎羊後陀羅”；
“此二星隨祿存安之，前安擎羊祿後安陀羅。假如癸祿在子，丑宮安擎羊，
亥宮安陀羅，餘倣此。”

因此“前”= 位置 +1，“后”= 位置 −1；方向以来源自己的癸禄例子为准，
不是本项目另行选择的方向。
-/

/-- 擎羊：禄存前一位（位置 +1）。 -/
def qingYang : TianGan → Position
  | .jia => 3
  | .yi => 4
  | .bing => 6
  | .ding => 7
  | .wu => 6
  | .ji => 7
  | .geng => 9
  | .xin => 10
  | .ren => 0
  | .gui => 1

/-- 陀罗：禄存后一位（位置 −1）。 -/
def tuoLuo : TianGan → Position
  | .jia => 1
  | .yi => 2
  | .bing => 4
  | .ding => 5
  | .wu => 4
  | .ji => 5
  | .geng => 7
  | .xin => 8
  | .ren => 10
  | .gui => 11

/-- 擎羊就是禄存位置 +1。 -/
theorem qingYang_eq_rotate_one (g : TianGan) :
    qingYang g = Position.rotate 1 (luCun g) := by
  cases g <;> rfl

/-- 陀罗就是禄存位置 −1。 -/
theorem tuoLuo_eq_rotate_neg_one (g : TianGan) :
    tuoLuo g = Position.rotate (-1) (luCun g) := by
  cases g <;> rfl

/-- 擎羊的地支表。 -/
theorem qingYang_toDiZhi (g : TianGan) :
    Branch.toDiZhi (qingYang g) =
      match g with
      | .jia => DiZhi.mao | .yi => DiZhi.chen | .bing => DiZhi.wu | .ding => DiZhi.wei
      | .wu => DiZhi.wu | .ji => DiZhi.wei | .geng => DiZhi.you | .xin => DiZhi.xu
      | .ren => DiZhi.zi | .gui => DiZhi.chou := by
  cases g <;> rfl

/-- 陀罗的地支表。 -/
theorem tuoLuo_toDiZhi (g : TianGan) :
    Branch.toDiZhi (tuoLuo g) =
      match g with
      | .jia => DiZhi.chou | .yi => DiZhi.yin | .bing => DiZhi.chen | .ding => DiZhi.si
      | .wu => DiZhi.chen | .ji => DiZhi.si | .geng => DiZhi.wei | .xin => DiZhi.shen
      | .ren => DiZhi.xu | .gui => DiZhi.hai := by
  cases g <;> rfl

/-- 来源的例子：癸禄在子，丑宫安擎羊。 -/
theorem qingYang_gui : qingYang TianGan.gui = Branch.ofDiZhi DiZhi.chou := rfl

/-- 来源的例子：癸禄在子，亥宫安陀罗。 -/
theorem tuoLuo_gui : tuoLuo TianGan.gui = Branch.ofDiZhi DiZhi.hai := rfl

/-- 擎羊与禄存不同位。 -/
theorem qingYang_ne_luCun (g : TianGan) : qingYang g ≠ luCun g := by
  intro h
  rw [qingYang_eq_rotate_one] at h
  have h' := congrArg Fin.val h
  simp [Position.rotate, Fin.val_add] at h'
  omega

/-- 陀罗与禄存不同位。 -/
theorem tuoLuo_ne_luCun (g : TianGan) : tuoLuo g ≠ luCun g := by
  intro h
  rw [tuoLuo_eq_rotate_neg_one] at h
  have h' := congrArg Fin.val h
  simp [Position.rotate, Fin.val_add] at h'
  omega

/-- 擎羊与陀罗不同位。 -/
theorem qingYang_ne_tuoLuo (g : TianGan) : qingYang g ≠ tuoLuo g := by
  intro h
  rw [qingYang_eq_rotate_one, tuoLuo_eq_rotate_neg_one] at h
  have h' := congrArg Fin.val h
  simp [Position.rotate, Fin.val_add] at h'
  omega

/-- 擎羊的像恰有 8 个位置。 -/
theorem qingYang_image_card : (Finset.univ.image qingYang).card = 8 := by
  decide

/-- 陀罗的像恰有 8 个位置。 -/
theorem tuoLuo_image_card : (Finset.univ.image tuoLuo).card = 8 := by
  decide

/-- 擎羊的显式像。 -/
theorem qingYang_image :
    (Finset.univ.image qingYang) = ({0, 1, 3, 4, 6, 7, 9, 10} : Finset Position) := by
  decide

/-- 陀罗的显式像。 -/
theorem tuoLuo_image :
    (Finset.univ.image tuoLuo) = ({1, 2, 4, 5, 7, 8, 10, 11} : Finset Position) := by
  decide

/-! ## 天马（依生年支）

来源：〈安天馬星訣〉“寅午戍人馬居申，申子辰人馬居寅，
巳酉丑人馬居亥，亥卯未人馬居巳。”

原文“戍”按上下文读作“戌”（寅午戌三合火局）。本库只实现**生年支**
天马，不实现流年天马。
-/

/-- 天马：寅午戌→申、申子辰→寅、巳酉丑→亥、亥卯未→巳。 -/
def tianMa : DiZhi → Position
  | .yin | .wu | .xu => 8
  | .shen | .zi | .chen => 2
  | .si | .you | .chou => 11
  | .hai | .mao | .wei => 5

/-- 天马的地支表（逐项展开，便于与原文核对）。 -/
theorem tianMa_toDiZhi (b : DiZhi) :
    Branch.toDiZhi (tianMa b) =
      match b with
      | .yin | .wu | .xu => DiZhi.shen
      | .shen | .zi | .chen => DiZhi.yin
      | .si | .you | .chou => DiZhi.hai
      | .hai | .mao | .wei => DiZhi.si := by
  cases b <;> rfl

/-- 寅午戌三支的天马同在申。 -/
theorem tianMa_yin_wu_xu :
    tianMa DiZhi.yin = 8 ∧ tianMa DiZhi.wu = 8 ∧ tianMa DiZhi.xu = 8 := by
  decide

/-- 申子辰三支的天马同在寅。 -/
theorem tianMa_shen_zi_chen :
    tianMa DiZhi.shen = 2 ∧ tianMa DiZhi.zi = 2 ∧ tianMa DiZhi.chen = 2 := by
  decide

/-- 巳酉丑三支的天马同在亥。 -/
theorem tianMa_si_you_chou :
    tianMa DiZhi.si = 11 ∧ tianMa DiZhi.you = 11 ∧ tianMa DiZhi.chou = 11 := by
  decide

/-- 亥卯未三支的天马同在巳。 -/
theorem tianMa_hai_mao_wei :
    tianMa DiZhi.hai = 5 ∧ tianMa DiZhi.mao = 5 ∧ tianMa DiZhi.wei = 5 := by
  decide

/-- 天马的像只有四个位置：寅、巳、申、亥（四马地）。 -/
theorem tianMa_image :
    (Finset.univ.image tianMa) = ({2, 5, 8, 11} : Finset Position) := by
  decide

/-- 天马的像恰有 4 个位置（每个三合组共用一个马位）。 -/
theorem tianMa_image_card : (Finset.univ.image tianMa).card = 4 := by
  rw [tianMa_image]
  decide

/-- 天马不是单射：例如寅、午同马。 -/
theorem tianMa_not_injective : ¬ Function.Injective tianMa := by
  intro h
  have hh : tianMa DiZhi.yin = tianMa DiZhi.wu := rfl
  have : DiZhi.yin = DiZhi.wu := h hh
  exact DiZhi.noConfusion this

/-! ## 综合安星函数

`place` 的输入是**已经给定**的生年干与生年支；它不推算年份，也不处理历法。
`placeJiaZi` 是同一函数在六十甲子上的版本（保证干支同阴阳）。
-/

/-- 给定年干、年支，安四颗小星。 -/
def place (g : TianGan) (b : DiZhi) : Star → Position
  | .luCun => luCun g
  | .qingYang => qingYang g
  | .tuoLuo => tuoLuo g
  | .tianMa => tianMa b

/-- 六十甲子版本的安星函数。 -/
def placeJiaZi (z : JiaZi) : Star → Position := place z.stem z.branch

/-- `place` 对禄存的定义。 -/
@[simp]
theorem place_luCun (g : TianGan) (b : DiZhi) : place g b .luCun = luCun g := rfl

/-- `place` 对擎羊的定义。 -/
@[simp]
theorem place_qingYang (g : TianGan) (b : DiZhi) : place g b .qingYang = qingYang g := rfl

/-- `place` 对陀罗的定义。 -/
@[simp]
theorem place_tuoLuo (g : TianGan) (b : DiZhi) : place g b .tuoLuo = tuoLuo g := rfl

/-- `place` 对天马的定义。 -/
@[simp]
theorem place_tianMa (g : TianGan) (b : DiZhi) : place g b .tianMa = tianMa b := rfl

/-- 六十甲子版本的禄存。 -/
@[simp]
theorem placeJiaZi_luCun (z : JiaZi) : placeJiaZi z .luCun = luCun z.stem := rfl

/-- 六十甲子版本的擎羊。 -/
@[simp]
theorem placeJiaZi_qingYang (z : JiaZi) : placeJiaZi z .qingYang = qingYang z.stem := rfl

/-- 六十甲子版本的陀罗。 -/
@[simp]
theorem placeJiaZi_tuoLuo (z : JiaZi) : placeJiaZi z .tuoLuo = tuoLuo z.stem := rfl

/-- 六十甲子版本的天马。 -/
@[simp]
theorem placeJiaZi_tianMa (z : JiaZi) : placeJiaZi z .tianMa = tianMa z.branch := rfl

/-- 甲子年的安星样例：禄存寅、擎羊卯、陀罗丑、天马寅。 -/
theorem placeJiaZi_jiaZi :
    placeJiaZi JiaZi.jiaZi .luCun = Branch.ofDiZhi DiZhi.yin ∧
    placeJiaZi JiaZi.jiaZi .qingYang = Branch.ofDiZhi DiZhi.mao ∧
    placeJiaZi JiaZi.jiaZi .tuoLuo = Branch.ofDiZhi DiZhi.chou ∧
    placeJiaZi JiaZi.jiaZi .tianMa = Branch.ofDiZhi DiZhi.yin := by
  decide

end MinorStar

end ZiWei

end Occult
