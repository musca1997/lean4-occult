/-
Occult/JiaZi.lean

六十甲子：由天干与地支按“同阴阳”配对而成的有限类型。

关键结构事实（均在本文件中完整证明，未使用占位符或自定义公理）：

* `JiaZi` 与 `Fin 60` 显式等价（`JiaZi.equivFin`），因此恰有 60 个元素；
* 六十甲子上的 `next`（天干、地支各前进一位）迭代 60 次回到原点；
* `next` 的**最小正周期**是 60：`next^[n] z = z ↔ 60 ∣ n`；
* 对任意同阴阳的天干、地支组合，存在唯一索引 `0 ≤ i < 60` 与之对应
  （`JiaZi.existsUnique_index`），即同阴阳配对与六十甲子一一对应。

约定：索引 0 记为甲子，索引 `n` 的天干序号为 `n % 10`、地支序号为 `n % 12`。
-/

import Mathlib.Data.Fintype.Card
import Mathlib.Tactic
import Occult.TianGan
import Occult.DiZhi

namespace Occult

/-- 六十甲子：天干与地支的同阴阳配对。 -/
structure JiaZi where
  /-- 天干 -/
  stem : TianGan
  /-- 地支 -/
  branch : DiZhi
  /-- 同阴阳条件（本项目约定：天干、地支序号同奇偶） -/
  parity : stem.toNat % 2 = branch.toNat % 2
  deriving DecidableEq, Repr

namespace JiaZi

/-- 中国剩余定理形式的索引计算：给定同奇偶的 `a < 10`、`b < 12`，
返回唯一的 `n < 60` 使 `n % 10 = a` 且 `n % 12 = b`。 -/
def crt (a b : Nat) : Nat := (a + 10 * ((5 * ((b + 12 - a) / 2)) % 6)) % 60

/-- `crt` 的正确性：结果落在 `[0, 60)` 且两个投影都还原。 -/
theorem crt_spec (a b : Nat) (ha : a < 10) (hb : b < 12) (hp : a % 2 = b % 2) :
    crt a b < 60 ∧ crt a b % 10 = a ∧ crt a b % 12 = b := by
  unfold crt
  interval_cases a <;> interval_cases b <;> omega

/-- 同阴阳条件下，索引在 `[0, 60)` 内由两个投影唯一确定。 -/
theorem index_unique {i j : Nat} (hi : i < 60) (hj : j < 60)
    (h1 : i % 10 = j % 10) (h2 : i % 12 = j % 12) : i = j := by
  omega

/-- 索引 `n` 对应的六十甲子（`n` 自动对 60 取模）。 -/
def ofIndex (n : Fin 60) : JiaZi where
  stem := TianGan.ofNatMod n.val
  branch := DiZhi.ofNatMod n.val
  parity := by
    simp only [TianGan.toNat_ofNatMod, DiZhi.toNat_ofNatMod]
    omega

/-- 六十甲子对应的索引（`crt` 形式）。 -/
def toIndex (z : JiaZi) : Fin 60 :=
  ⟨crt z.stem.toNat z.branch.toNat,
    (crt_spec _ _ z.stem.toNat_lt z.branch.toNat_lt z.parity).1⟩

/-- 先 `ofIndex` 再 `toIndex` 得到原索引。 -/
theorem toIndex_ofIndex (n : Fin 60) : toIndex (ofIndex n) = n := by
  apply Fin.ext
  simp only [toIndex, ofIndex, TianGan.toNat_ofNatMod, DiZhi.toNat_ofNatMod]
  have h := (crt_spec (n.val % 10) (n.val % 12)
    (Nat.mod_lt _ (by decide)) (Nat.mod_lt _ (by decide)) (by omega))
  omega

/-- 先 `toIndex` 再 `ofIndex` 得到原甲子。 -/
theorem ofIndex_toIndex (z : JiaZi) : ofIndex (toIndex z) = z := by
  obtain ⟨s, b, h⟩ := z
  have hs : crt s.toNat b.toNat % 10 = s.toNat :=
    (crt_spec _ _ s.toNat_lt b.toNat_lt h).2.1
  have hb : crt s.toNat b.toNat % 12 = b.toNat :=
    (crt_spec _ _ s.toNat_lt b.toNat_lt h).2.2
  have hstem : TianGan.ofNatMod (crt s.toNat b.toNat) = s := by
    conv_rhs => rw [← TianGan.ofNatMod_toNat s]
    rw [TianGan.ofNatMod_eq_iff]
    omega
  have hbranch : DiZhi.ofNatMod (crt s.toNat b.toNat) = b := by
    conv_rhs => rw [← DiZhi.ofNatMod_toNat b]
    rw [DiZhi.ofNatMod_eq_iff]
    omega
  rw [JiaZi.mk.injEq]
  exact ⟨hstem, hbranch⟩

/-- 六十甲子与 `Fin 60` 的显式等价。 -/
def equivFin : JiaZi ≃ Fin 60 where
  toFun := toIndex
  invFun := ofIndex
  left_inv := ofIndex_toIndex
  right_inv := toIndex_ofIndex

instance : Fintype JiaZi := Fintype.ofEquiv (Fin 60) equivFin.symm

/-- 六十甲子恰有六十个元素。 -/
theorem card_eq_sixty : Fintype.card JiaZi = 60 := by
  rw [← Fintype.card_fin 60]
  exact Fintype.card_congr equivFin

/-- 第 0 位：甲子。 -/
def jiaZi : JiaZi := ofIndex 0

/-- 第 59 位：癸亥。 -/
def guiHai : JiaZi := ofIndex 59

/-- 六十甲子的下一步：天干、地支各前进一位。 -/
def next (z : JiaZi) : JiaZi :=
  ofIndex ⟨(z.toIndex.val + 1) % 60, Nat.mod_lt _ (by decide)⟩

/-- `next` 在索引上就是加一取模。 -/
theorem toIndex_next (z : JiaZi) : (next z).toIndex.val = (z.toIndex.val + 1) % 60 := by
  simp [next, toIndex_ofIndex]

/-- 迭代 `next` 与索引加法一致。 -/
theorem toIndex_iterate (n : Nat) (z : JiaZi) :
    ((next^[n] z).toIndex).val = (z.toIndex.val + n) % 60 := by
  induction n generalizing z with
  | zero => simp [Nat.mod_eq_of_lt z.toIndex.isLt]
  | succ k ih =>
    rw [Function.iterate_succ_apply', toIndex_next, ih]
    omega

/-- 六十甲子的周期上界：迭代 60 次回到自身。 -/
theorem next_sixty (z : JiaZi) : next^[60] z = z := by
  apply equivFin.injective
  apply Fin.ext
  show ((next^[60] z).toIndex).val = z.toIndex.val
  rw [toIndex_iterate]
  simp

/-- 六十甲子的**最小正周期**是 60：迭代 `n` 次回到自身当且仅当 `60 ∣ n`。 -/
theorem next_period_iff (n : Nat) (z : JiaZi) : next^[n] z = z ↔ 60 ∣ n := by
  constructor
  · intro h
    have h1 : (next^[n] z).toIndex = z.toIndex := by rw [h]
    have h2 := congrArg Fin.val h1
    rw [toIndex_iterate] at h2
    have h3 : (z.toIndex.val + n) % 60 = z.toIndex.val % 60 := by
      rw [h2]; exact (Nat.mod_eq_of_lt z.toIndex.isLt).symm
    have h4 : (z.toIndex.val + n) % 60 = z.toIndex.val := by
      rw [h3, Nat.mod_eq_of_lt z.toIndex.isLt]
    omega
  · intro h
    obtain ⟨k, rfl⟩ := h
    apply equivFin.injective
    apply Fin.ext
    show ((next^[60 * k] z).toIndex).val = z.toIndex.val
    rw [toIndex_iterate]
    simp

/-- 第 `n` 位的天干序号是 `n % 10`。 -/
@[simp]
theorem stem_toNat_ofIndex (n : Fin 60) : (ofIndex n).stem.toNat = n.val % 10 := by
  simp [ofIndex]

/-- 第 `n` 位的地支序号是 `n % 12`。 -/
@[simp]
theorem branch_toNat_ofIndex (n : Fin 60) : (ofIndex n).branch.toNat = n.val % 12 := by
  simp [ofIndex]

/-- 任意甲子的天干序号等于其索引对 10 取模。 -/
theorem stem_toNat_eq (z : JiaZi) : z.stem.toNat = z.toIndex.val % 10 := by
  conv_lhs => rw [← ofIndex_toIndex z]
  exact stem_toNat_ofIndex _

/-- 任意甲子的地支序号等于其索引对 12 取模。 -/
theorem branch_toNat_eq (z : JiaZi) : z.branch.toNat = z.toIndex.val % 12 := by
  conv_lhs => rw [← ofIndex_toIndex z]
  exact branch_toNat_ofIndex _

/-- 天干前进一位。 -/
theorem stem_next (z : JiaZi) : (next z).stem = TianGan.ofNatMod (z.stem.toNat + 1) := by
  rw [← TianGan.ofNatMod_toNat ((next z).stem), TianGan.ofNatMod_eq_iff]
  rw [stem_toNat_eq (next z), stem_toNat_eq z, toIndex_next]
  omega

/-- 地支前进一位。 -/
theorem branch_next (z : JiaZi) : (next z).branch = DiZhi.ofNatMod (z.branch.toNat + 1) := by
  rw [← DiZhi.ofNatMod_toNat ((next z).branch), DiZhi.ofNatMod_eq_iff]
  rw [branch_toNat_eq (next z), branch_toNat_eq z, toIndex_next]
  omega

/-- 第 `n` 位的天干是 `n % 10`。 -/
theorem stem_ofIndex (n : Fin 60) : (ofIndex n).stem = TianGan.ofNatMod n.val := rfl

/-- 第 `n` 位的地支是 `n % 12`。 -/
theorem branch_ofIndex (n : Fin 60) : (ofIndex n).branch = DiZhi.ofNatMod n.val := rfl

/-- 六十甲子中天干与地支的阴阳一致。 -/
theorem parity_yinYang (z : JiaZi) : z.stem.yinYang = z.branch.yinYang := by
  show YinYang.ofParity z.stem.toNat = YinYang.ofParity z.branch.toNat
  rw [YinYang.ofParity_eq_iff]
  exact z.parity

/-- 任意同阴阳的天干、地支组合都恰好对应一个六十甲子。 -/
theorem existsUnique_index (g : TianGan) (b : DiZhi) (h : g.toNat % 2 = b.toNat % 2) :
    ∃! n : Fin 60, (ofIndex n).stem = g ∧ (ofIndex n).branch = b := by
  have hspec := crt_spec g.toNat b.toNat g.toNat_lt b.toNat_lt h
  refine ⟨⟨crt g.toNat b.toNat, hspec.1⟩, ?_, ?_⟩
  · constructor
    · show TianGan.ofNatMod (crt g.toNat b.toNat) = g
      conv_rhs => rw [← TianGan.ofNatMod_toNat g]
      rw [TianGan.ofNatMod_eq_iff]
      omega
    · show DiZhi.ofNatMod (crt g.toNat b.toNat) = b
      conv_rhs => rw [← DiZhi.ofNatMod_toNat b]
      rw [DiZhi.ofNatMod_eq_iff]
      omega
  · intro n hn
    obtain ⟨hstem, hbranch⟩ := hn
    apply Fin.ext
    have hn1 : n.val % 10 = g.toNat := by
      rw [← stem_toNat_ofIndex n, hstem]
    have hn2 : n.val % 12 = b.toNat := by
      rw [← branch_toNat_ofIndex n, hbranch]
    have hn1' : n.val % 10 = crt g.toNat b.toNat % 10 := by omega
    have hn2' : n.val % 12 = crt g.toNat b.toNat % 12 := by omega
    exact index_unique n.isLt hspec.1 hn1' hn2'

/-- 六十甲子枚举就是 `next` 从甲子出发的轨道。 -/
theorem next_iterate_jiaZi (n : Nat) :
    next^[n] jiaZi = ofIndex ⟨n % 60, Nat.mod_lt _ (by decide)⟩ := by
  apply equivFin.injective
  apply Fin.ext
  show ((next^[n] jiaZi).toIndex).val = (ofIndex ⟨n % 60, Nat.mod_lt _ (by decide)⟩).toIndex.val
  rw [toIndex_iterate]
  simp [jiaZi, toIndex_ofIndex]

/-- 索引 `n` 的甲子等于从甲子出发迭代 `n` 步。 -/
theorem ofIndex_eq_next_iterate (n : Fin 60) : ofIndex n = next^[n.val] jiaZi := by
  rw [next_iterate_jiaZi]
  congr 1
  apply Fin.ext
  simp [Nat.mod_eq_of_lt n.isLt]

/-- 60 是**最小**正周期：任何更小的正步数都不能使甲子回到自身。 -/
theorem next_min_period (k : Nat) (hk : 0 < k) (hk60 : k < 60) : next^[k] jiaZi ≠ jiaZi := by
  intro h
  have hdvd := (next_period_iff k jiaZi).1 h
  have : 60 ≤ k := Nat.le_of_dvd hk hdvd
  omega

/-- 同阴阳的（天干, 地支）组合恰有 60 个，与六十甲子一一对应。 -/
def sameParityEquiv : {p : TianGan × DiZhi // p.1.toNat % 2 = p.2.toNat % 2} ≃ JiaZi where
  toFun p := ⟨p.1.1, p.1.2, p.2⟩
  invFun z := ⟨(z.stem, z.branch), z.parity⟩
  left_inv p := by
    obtain ⟨⟨g, b⟩, h⟩ := p
    rfl
  right_inv z := by
    obtain ⟨s, b, h⟩ := z
    rfl

/-- 同阴阳配对的数目是 60。 -/
theorem card_sameParity_pairs :
    Fintype.card {p : TianGan × DiZhi // p.1.toNat % 2 = p.2.toNat % 2} = 60 := by
  rw [← card_eq_sixty]
  exact Fintype.card_congr sameParityEquiv

/-- 六十甲子的索引与阴阳一致：索引的奇偶就是干支的阴阳。 -/
theorem yinYang_toIndex (z : JiaZi) : YinYang.ofParity z.toIndex.val = z.stem.yinYang := by
  rw [TianGan.yinYang, stem_toNat_eq, YinYang.ofParity_mod _ 10 (by decide)]

/-- 第 `n` 位甲子的天干序号是 `n % 10`，地支序号是 `n % 12`。 -/
theorem ofIndex_coords (n : Fin 60) :
    (ofIndex n).stem.toNat = n.val % 10 ∧ (ofIndex n).branch.toNat = n.val % 12 :=
  ⟨stem_toNat_ofIndex n, branch_toNat_ofIndex n⟩

/-- `ofIndex` 是单射：不同的索引给出不同的甲子。 -/
theorem ofIndex_injective : Function.Injective ofIndex :=
  equivFin.symm.injective

/-- `next` 是单射（等价地，六十甲子构成一个 60 元循环）。 -/
theorem next_injective : Function.Injective next := by
  intro a b h
  have h' := congrArg Fin.val (congrArg toIndex h)
  rw [toIndex_next, toIndex_next] at h'
  have hmod : (a.toIndex.val + 1) ≡ (b.toIndex.val + 1) [MOD 60] := h'
  have h2 : a.toIndex.val ≡ b.toIndex.val [MOD 60] := Nat.ModEq.add_right_cancel' 1 hmod
  have := Nat.ModEq.eq_of_lt_of_lt h2 a.toIndex.isLt b.toIndex.isLt
  apply equivFin.injective
  apply Fin.ext
  exact this

/-- 从甲子出发迭代 `n < 60` 步得到的甲子两两不同（轨道没有提前闭合）。 -/
theorem next_iterate_injective {m n : Nat} (hm : m < 60) (hn : n < 60)
    (h : next^[m] jiaZi = next^[n] jiaZi) : m = n := by
  have h' := congrArg Fin.val (congrArg toIndex h)
  rw [toIndex_iterate, toIndex_iterate] at h'
  simp only [jiaZi, toIndex_ofIndex] at h'
  omega

/-- 六十甲子的汉字写法，例如 `甲子`。 -/
def name (z : JiaZi) : String := String.ofList [z.stem.toChar, z.branch.toChar]

/-- 从“天干+地支”两字字符串解析甲子；不满足同阴阳条件时返回 `none`。 -/
def parse? (s : String) : Option JiaZi :=
  match s.toList with
  | [g, b] =>
    match TianGan.ofChar g, DiZhi.ofChar b with
    | some g, some b =>
      if h : g.toNat % 2 = b.toNat % 2 then some ⟨g, b, h⟩ else none
    | _, _ => none
  | _ => none

/-- `parse?` 与 `name` 互逆。 -/
@[simp]
theorem parse?_name (z : JiaZi) : parse? z.name = some z := by
  obtain ⟨s, b, h⟩ := z
  have hlist : (name ⟨s, b, h⟩).toList = [s.toChar, b.toChar] := by
    simp [name]
  rw [parse?, hlist]
  simp only [TianGan.ofChar_toChar, DiZhi.ofChar_toChar, dite_eq_left h]

end JiaZi

end Occult
