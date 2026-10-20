/-
Tests.lean

可执行回归检查：用 `example` 固化关键结论，`lake build Tests` 即运行类型检查。
另外用 `#guard_msgs` 校验 CLI 相关的字符串行为。
-/

import Occult

open Occult

namespace Tests

/-! ## 阴阳 -/

example : Fintype.card YinYang = 2 := YinYang.card_eq_two
example : YinYang.neg YinYang.yin = YinYang.yang := rfl
example : YinYang.ofParity 7 = YinYang.yin := rfl
example : YinYang.ofParity 8 = YinYang.yang := rfl
example (n : Nat) : YinYang.ofParity (n + 60) = YinYang.ofParity n := by
  rw [YinYang.ofParity_eq_iff]; omega

/-! ## 五行 -/

example : Fintype.card WuXing = 5 := WuXing.card_eq_five
example : WuXing.next WuXing.water = WuXing.wood := rfl
example : WuXing.overcomes WuXing.metal = WuXing.wood := rfl
example (n : Nat) (x : WuXing) : WuXing.next^[n] x = x ↔ 5 ∣ n :=
  WuXing.next_period_iff n x
example : WuXing.next^[5] = id := WuXing.next_five
example : WuXing.prev (WuXing.next WuXing.wood) = WuXing.wood := WuXing.prev_next _
example : WuXing.next (WuXing.prev WuXing.wood) = WuXing.wood := WuXing.next_prev _
example (x : WuXing) : WuXing.prev (WuXing.next x) = x := WuXing.prev_next x
example (x : WuXing) : WuXing.next (WuXing.prev x) = x := WuXing.next_prev x
example (x : WuXing) : WuXing.overcomeBy (WuXing.overcomes x) = x :=
  WuXing.overcomeBy_overcomes x
example (x : WuXing) : WuXing.overcomes (WuXing.overcomeBy x) = x :=
  WuXing.overcomes_overcomeBy x
example (x y : WuXing) : WuXing.next x = y ↔ x = WuXing.prev y :=
  WuXing.next_eq_iff_prev x y
example (x y : WuXing) : WuXing.overcomes x = y ↔ x = WuXing.overcomeBy y :=
  WuXing.overcomes_eq_iff_overcomeBy x y
example : WuXing.prev^[5] = id := WuXing.prev_five
example : WuXing.overcomeBy^[5] = id := WuXing.overcomeBy_five

/-! ## 天干 / 地支 -/

example : Fintype.card TianGan = 10 := TianGan.card_eq_ten
example : Fintype.card DiZhi = 12 := DiZhi.card_eq_twelve
example : TianGan.jia.toNat = 0 := rfl
example : TianGan.gui.toNat = 9 := rfl
example : DiZhi.zi.toNat = 0 := rfl
example : DiZhi.hai.toNat = 11 := rfl
example : TianGan.parse "甲" = some TianGan.jia := rfl
example : TianGan.parse "x" = none := rfl
example : DiZhi.parse "亥" = some DiZhi.hai := rfl
example : DiZhi.parse "" = none := rfl
example : TianGan.jia.wuXing = WuXing.wood := rfl
example : TianGan.gui.wuXing = WuXing.water := rfl
example : TianGan.bing.wuXing = WuXing.fire := rfl
example : TianGan.geng.wuXing = WuXing.metal := rfl
example : TianGan.ji.wuXing = WuXing.earth := rfl
example (g : TianGan) : g.wuXing.toFin.val = g.toNat / 2 := TianGan.wuXing_toFin g
example (g h : TianGan) : g.wuXing = h.wuXing ↔ g.toNat / 2 = h.toNat / 2 :=
  TianGan.wuXing_eq_iff g h
example (n : Nat) :
    (TianGan.ofNatMod (n + 2)).wuXing = WuXing.next (TianGan.ofNatMod n).wuXing :=
  TianGan.wuXing_ofNatMod_add_two n
example : DiZhi.zi.wuXing = WuXing.water := rfl
example : DiZhi.chou.wuXing = WuXing.earth := rfl
example : DiZhi.yin.wuXing = WuXing.wood := rfl
example : DiZhi.si.wuXing = WuXing.fire := rfl
example : DiZhi.shen.wuXing = WuXing.metal := rfl
example : DiZhi.hai.wuXing = WuXing.water := rfl
example (b : DiZhi) : (DiZhi.ofNatMod b.toNat).wuXing = b.wuXing :=
  DiZhi.wuXing_ofNatMod_toNat b

/-! ## 六十甲子 -/

example : Fintype.card JiaZi = 60 := JiaZi.card_eq_sixty
example : JiaZi.jiaZi.stem = TianGan.jia := rfl
example : JiaZi.jiaZi.branch = DiZhi.zi := rfl
example : JiaZi.guiHai.stem = TianGan.gui := rfl
example : JiaZi.guiHai.branch = DiZhi.hai := rfl
example : JiaZi.next JiaZi.jiaZi = JiaZi.ofIndex 1 := rfl
example : JiaZi.ofIndex 1 = ⟨TianGan.yi, DiZhi.chou, rfl⟩ := rfl
example (z : JiaZi) : JiaZi.next^[60] z = z := JiaZi.next_sixty z
example (n : Nat) (z : JiaZi) : JiaZi.next^[n] z = z ↔ 60 ∣ n :=
  JiaZi.next_period_iff n z
example (k : Nat) (hk : 0 < k) (hk60 : k < 60) : JiaZi.next^[k] JiaZi.jiaZi ≠ JiaZi.jiaZi :=
  JiaZi.next_min_period k hk hk60
example (g : TianGan) (b : DiZhi) (h : g.toNat % 2 = b.toNat % 2) :
    ∃! n : Fin 60, (JiaZi.ofIndex n).stem = g ∧ (JiaZi.ofIndex n).branch = b :=
  JiaZi.existsUnique_index g b h
example : Fintype.card {p : TianGan × DiZhi // p.1.toNat % 2 = p.2.toNat % 2} = 60 :=
  JiaZi.card_sameParity_pairs
example : JiaZi.parse? "甲子" = some JiaZi.jiaZi := rfl
example : JiaZi.parse? "甲丑" = none := rfl
example : JiaZi.parse? "甲" = none := rfl
example (z : JiaZi) : JiaZi.parse? (JiaZi.name z) = some z := JiaZi.parse?_name z
example : Function.Injective JiaZi.ofIndex := JiaZi.ofIndex_injective
example : Function.Injective JiaZi.next := JiaZi.next_injective
example {m n : Nat} (hm : m < 60) (hn : n < 60)
    (h : JiaZi.next^[m] JiaZi.jiaZi = JiaZi.next^[n] JiaZi.jiaZi) : m = n :=
  JiaZi.next_iterate_injective hm hn h
example : JiaZi.name (JiaZi.ofIndex 59) = "癸亥" := rfl
example : JiaZi.prev JiaZi.jiaZi = JiaZi.ofIndex 59 := rfl
example : JiaZi.prev (JiaZi.next JiaZi.jiaZi) = JiaZi.jiaZi := JiaZi.prev_next _
example (z : JiaZi) : JiaZi.prev (JiaZi.next z) = z := JiaZi.prev_next z
example (z : JiaZi) : JiaZi.next (JiaZi.prev z) = z := JiaZi.next_prev z
example : Function.Injective JiaZi.prev := JiaZi.prev_injective
example (z : JiaZi) : JiaZi.prev^[60] z = z := JiaZi.prev_sixty z
example (n : Nat) (z : JiaZi) : JiaZi.prev^[n] z = z ↔ 60 ∣ n :=
  JiaZi.prev_period_iff n z

/-! ## CLI 输入解析 -/

example : Occult.parseNat? "0" = some 0 := rfl
example : Occult.parseNat? "007" = some 7 := rfl
example : Occult.parseNat? "59" = some 59 := rfl
example : Occult.parseNat? "60" = some 60 := rfl
example : Occult.parseNat? "-1" = none := rfl
example : Occult.parseNat? "1x" = none := rfl
example : Occult.parseNat? "" = none := rfl
example : Occult.parseNat? " 1" = none := rfl
example : Occult.parseNat? "999999999999999999999999" = some 999999999999999999999999 := rfl

/-! ## CLI 用到的索引往返 -/

-- `Main.parseNat?` 依赖 `String.toNat!`，这里用等价性质检查 CLI 依赖的核心行为。
example : (JiaZi.ofIndex ⟨59, by decide⟩).toIndex.val = 59 := rfl
example (n : Fin 60) : (JiaZi.ofIndex n).toIndex = n := JiaZi.toIndex_ofIndex n
example (z : JiaZi) : JiaZi.ofIndex z.toIndex = z := JiaZi.ofIndex_toIndex z

/-! ## 紫微十二宫位置（v0.2） -/

example : ZiWei.Position.opposite (0 : ZiWei.Position) = 6 := rfl
example : ZiWei.Position.trineForward (0 : ZiWei.Position) = 4 := rfl
example : ZiWei.Position.trineBackward (0 : ZiWei.Position) = 8 := rfl
example (p : ZiWei.Position) : ZiWei.Position.opposite (ZiWei.Position.opposite p) = p :=
  ZiWei.Position.opposite_involutive p
example (p : ZiWei.Position) : ZiWei.Position.opposite p ≠ p :=
  ZiWei.Position.opposite_ne_self p
example (p : ZiWei.Position) :
    ZiWei.Position.trineForward (ZiWei.Position.trineForward (ZiWei.Position.trineForward p)) = p :=
  ZiWei.Position.trineForward_three p
example (p : ZiWei.Position) :
    ZiWei.Position.trineBackward p =
      ZiWei.Position.trineForward (ZiWei.Position.trineForward p) :=
  ZiWei.Position.trineBackward_eq_trineForward_twice p
example (p : ZiWei.Position) : (ZiWei.Position.triad p).card = 4 :=
  ZiWei.Position.triad_card p
example (k p q : ZiWei.Position) :
    q ∈ ZiWei.Position.triad (ZiWei.Position.rotate k p) ↔
      ZiWei.Position.rotate (-k) q ∈ ZiWei.Position.triad p :=
  ZiWei.Position.mem_triad_rotate_iff k p q
example (k p : ZiWei.Position) :
    ZiWei.Position.opposite (ZiWei.Position.rotate k p) =
      ZiWei.Position.rotate k (ZiWei.Position.opposite p) :=
  ZiWei.Position.rotate_opposite k p
example (k p : ZiWei.Position) :
    ZiWei.Position.triad (ZiWei.Position.rotate k p) =
      (ZiWei.Position.triad p).image (ZiWei.Position.rotate k) :=
  ZiWei.Position.rotate_triad k p
example : Fintype.card ZiWei.Palace = 12 := ZiWei.Palace.card_eq_twelve
example : Function.Injective ZiWei.Palace.offset := ZiWei.Palace.offset_injective
example : ZiWei.Palace.atPos (0 : ZiWei.Position) ZiWei.Palace.ming = 0 :=
  ZiWei.Palace.atPos_ming 0
example : ZiWei.Palace.offset ZiWei.Palace.qianYi = 6 := rfl
example : ZiWei.Position.opposite (ZiWei.Palace.offset ZiWei.Palace.ming) =
    ZiWei.Palace.offset ZiWei.Palace.qianYi := ZiWei.Palace.opposite_ming
example (anchor : ZiWei.Position) :
    ZiWei.Position.triad (ZiWei.Palace.atPos anchor ZiWei.Palace.ming) =
      {ZiWei.Palace.atPos anchor ZiWei.Palace.ming,
       ZiWei.Palace.atPos anchor ZiWei.Palace.caiBo,
       ZiWei.Palace.atPos anchor ZiWei.Palace.qianYi,
       ZiWei.Palace.atPos anchor ZiWei.Palace.guanLu} :=
  ZiWei.Position.atPos_triad_ming anchor

/-! ## 紫微小安星（v0.3） -/

-- 地支与位置的约定映射：子 0、丑 1、…、亥 11。
example : ZiWei.Branch.ofDiZhi DiZhi.zi = (0 : ZiWei.Position) := rfl
example : ZiWei.Branch.ofDiZhi DiZhi.hai = (11 : ZiWei.Position) := rfl
example : ZiWei.Branch.toDiZhi (0 : ZiWei.Position) = DiZhi.zi := rfl
example (b : DiZhi) : ZiWei.Branch.toDiZhi (ZiWei.Branch.ofDiZhi b) = b :=
  ZiWei.Branch.toDiZhi_ofDiZhi b
example (p : ZiWei.Position) : ZiWei.Branch.ofDiZhi (ZiWei.Branch.toDiZhi p) = p :=
  ZiWei.Branch.ofDiZhi_toDiZhi p
example : Function.Injective ZiWei.Branch.ofDiZhi := ZiWei.Branch.ofDiZhi_injective

-- 禄存表：甲寅、乙卯、丙戊巳、丁己午、庚申、辛酉、壬亥、癸子。
example : ZiWei.MinorStar.luCun TianGan.jia = (2 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.luCun TianGan.bing = (5 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.luCun TianGan.wu = (5 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.luCun TianGan.ding = (6 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.luCun TianGan.ji = (6 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.luCun TianGan.gui = (0 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.luCun TianGan.bing = ZiWei.MinorStar.luCun TianGan.wu :=
  ZiWei.MinorStar.luCun_bing_eq_wu
example : ZiWei.MinorStar.luCun TianGan.ding = ZiWei.MinorStar.luCun TianGan.ji :=
  ZiWei.MinorStar.luCun_ding_eq_ji
example (g h : TianGan) : ZiWei.MinorStar.luCun g = ZiWei.MinorStar.luCun h ↔
    g = h ∨
      (g = TianGan.bing ∧ h = TianGan.wu) ∨
      (g = TianGan.wu ∧ h = TianGan.bing) ∨
      (g = TianGan.ding ∧ h = TianGan.ji) ∨
      (g = TianGan.ji ∧ h = TianGan.ding) :=
  ZiWei.MinorStar.luCun_eq_iff g h
example : (Finset.univ.image ZiWei.MinorStar.luCun).card = 8 :=
  ZiWei.MinorStar.luCun_image_card

-- 擎羊/陀罗：来源例子“癸禄在子，丑宫擎羊，亥宫陀罗”。
example : ZiWei.MinorStar.qingYang TianGan.gui = (1 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tuoLuo TianGan.gui = (11 : ZiWei.Position) := rfl
example (g : TianGan) : ZiWei.MinorStar.qingYang g =
    ZiWei.Position.rotate 1 (ZiWei.MinorStar.luCun g) :=
  ZiWei.MinorStar.qingYang_eq_rotate_one g
example (g : TianGan) : ZiWei.MinorStar.tuoLuo g =
    ZiWei.Position.rotate (-1) (ZiWei.MinorStar.luCun g) :=
  ZiWei.MinorStar.tuoLuo_eq_rotate_neg_one g
example (g : TianGan) : ZiWei.MinorStar.qingYang g ≠ ZiWei.MinorStar.luCun g :=
  ZiWei.MinorStar.qingYang_ne_luCun g
example (g : TianGan) : ZiWei.MinorStar.tuoLuo g ≠ ZiWei.MinorStar.luCun g :=
  ZiWei.MinorStar.tuoLuo_ne_luCun g
example (g : TianGan) : ZiWei.MinorStar.qingYang g ≠ ZiWei.MinorStar.tuoLuo g :=
  ZiWei.MinorStar.qingYang_ne_tuoLuo g
example : (Finset.univ.image ZiWei.MinorStar.qingYang).card = 8 :=
  ZiWei.MinorStar.qingYang_image_card
example : (Finset.univ.image ZiWei.MinorStar.tuoLuo).card = 8 :=
  ZiWei.MinorStar.tuoLuo_image_card

-- 天马表：寅午戌→申、申子辰→寅、巳酉丑→亥、亥卯未→巳。
example : ZiWei.MinorStar.tianMa DiZhi.yin = (8 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.wu = (8 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.xu = (8 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.shen = (2 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.zi = (2 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.chen = (2 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.si = (11 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.you = (11 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.chou = (11 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.hai = (5 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.mao = (5 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.tianMa DiZhi.wei = (5 : ZiWei.Position) := rfl
example : (Finset.univ.image ZiWei.MinorStar.tianMa).card = 4 :=
  ZiWei.MinorStar.tianMa_image_card
example : ¬ Function.Injective ZiWei.MinorStar.tianMa :=
  ZiWei.MinorStar.tianMa_not_injective

-- 综合安星函数与六十甲子版本。
example : ZiWei.MinorStar.Star.all.length = 4 := ZiWei.MinorStar.star_all_length
example : Fintype.card ZiWei.MinorStar.Star = 4 := ZiWei.MinorStar.star_card_eq_four
example (g : TianGan) (b : DiZhi) : ZiWei.MinorStar.place g b ZiWei.MinorStar.Star.luCun =
    ZiWei.MinorStar.luCun g := rfl
example (g : TianGan) (b : DiZhi) : ZiWei.MinorStar.place g b ZiWei.MinorStar.Star.tianMa =
    ZiWei.MinorStar.tianMa b := rfl
example : ZiWei.MinorStar.placeJiaZi JiaZi.jiaZi ZiWei.MinorStar.Star.luCun =
    (2 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.placeJiaZi JiaZi.jiaZi ZiWei.MinorStar.Star.qingYang =
    (3 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.placeJiaZi JiaZi.jiaZi ZiWei.MinorStar.Star.tuoLuo =
    (1 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.placeJiaZi JiaZi.jiaZi ZiWei.MinorStar.Star.tianMa =
    (2 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.placeJiaZi JiaZi.guiHai ZiWei.MinorStar.Star.luCun =
    (0 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.placeJiaZi JiaZi.guiHai ZiWei.MinorStar.Star.qingYang =
    (1 : ZiWei.Position) := rfl
example : ZiWei.MinorStar.placeJiaZi JiaZi.guiHai ZiWei.MinorStar.Star.tuoLuo =
    (11 : ZiWei.Position) := rfl

end Tests
