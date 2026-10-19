/-
Occult/WuXing.lean

五行（WuXing）：木火土金水。
定义两个循环结构：
* `next`：相生（木→火→土→金→水→木），周期 5；
* `overcomes`：相克（木克土、土克水、水克火、火克金、金克木），周期 5。

本文件只做有限组合结构，不对五行学说的经验内容作任何断言。
-/

import Mathlib.Data.Fintype.Card
import Mathlib.Tactic

namespace Occult

/-- 五行。 -/
inductive WuXing where
  /-- 木 -/
  | wood
  /-- 火 -/
  | fire
  /-- 土 -/
  | earth
  /-- 金 -/
  | metal
  /-- 水 -/
  | water
  deriving DecidableEq, Repr

namespace WuXing

/-- 序号编码：木 ↦ 0，火 ↦ 1，土 ↦ 2，金 ↦ 3，水 ↦ 4。 -/
def toFin : WuXing → Fin 5
  | wood => ⟨0, by decide⟩
  | fire => ⟨1, by decide⟩
  | earth => ⟨2, by decide⟩
  | metal => ⟨3, by decide⟩
  | water => ⟨4, by decide⟩

/-- 从序号解码。 -/
def ofFin : Fin 5 → WuXing
  | ⟨0, _⟩ => wood
  | ⟨1, _⟩ => fire
  | ⟨2, _⟩ => earth
  | ⟨3, _⟩ => metal
  | _ => water

theorem ofFin_toFin (x : WuXing) : ofFin (toFin x) = x := by
  cases x <;> rfl

theorem toFin_ofFin (n : Fin 5) : toFin (ofFin n) = n := by
  obtain ⟨k, hk⟩ := n
  interval_cases k <;> rfl

/-- 五行与 `Fin 5` 的显式等价。 -/
def equivFin : WuXing ≃ Fin 5 where
  toFun := toFin
  invFun := ofFin
  left_inv := ofFin_toFin
  right_inv := toFin_ofFin

instance : Fintype WuXing := Fintype.ofEquiv (Fin 5) equivFin.symm

/-- 五行恰有五个元素。 -/
theorem card_eq_five : Fintype.card WuXing = 5 := by
  rw [← Fintype.card_fin 5]
  exact Fintype.card_congr equivFin

/-- 相生次序：木生火、火生土、土生金、金生水、水生木。 -/
def next : WuXing → WuXing
  | wood => fire
  | fire => earth
  | earth => metal
  | metal => water
  | water => wood

/-- 相克次序：木克土、土克水、水克火、火克金、金克木。 -/
def overcomes : WuXing → WuXing
  | wood => earth
  | earth => water
  | water => fire
  | fire => metal
  | metal => wood

/-- 相生的逆向：谁生我（`prev x` 生 `x`）。 -/
def prev : WuXing → WuXing
  | wood => water
  | fire => wood
  | earth => fire
  | metal => earth
  | water => metal

/-- 相克的逆向：谁克我（`overcomeBy x` 克 `x`）。 -/
def overcomeBy : WuXing → WuXing
  | wood => metal
  | fire => water
  | earth => wood
  | metal => fire
  | water => earth

/-- 相生等价于序号加 1 再对 5 取模。 -/
theorem toFin_next (x : WuXing) : (next x).toFin.val = (x.toFin.val + 1) % 5 := by
  cases x <;> rfl

/-- 相克等价于序号加 2 再对 5 取模。 -/
theorem toFin_overcomes (x : WuXing) : (overcomes x).toFin.val = (x.toFin.val + 2) % 5 := by
  cases x <;> rfl

/-- 相生映射是单射。 -/
theorem next_injective : Function.Injective next := by
  intro a b h
  cases a <;> cases b <;> simp [next] at h ⊢

/-- 相生映射没有不动点。 -/
theorem next_ne_self (x : WuXing) : next x ≠ x := by
  cases x <;> decide

/-- 相生映射迭代五次回到原点。 -/
theorem next_five : next^[5] = id := by
  funext x
  cases x <;> rfl

/-- 相生迭代 `n` 次后的序号是序号加 `n` 再对 5 取模。 -/
theorem toFin_next_iterate (n : Nat) (x : WuXing) :
    (next^[n] x).toFin.val = (x.toFin.val + n) % 5 := by
  induction n generalizing x with
  | zero => simp [Nat.mod_eq_of_lt x.toFin.isLt]
  | succ k ih =>
    rw [Function.iterate_succ_apply', toFin_next, ih]
    omega

/-- 相生映射的周期恰为 5：迭代 `n` 次回到原点当且仅当 `5 ∣ n`。 -/
theorem next_period_iff (n : Nat) (x : WuXing) : next^[n] x = x ↔ 5 ∣ n := by
  constructor
  · intro h
    have h2 := congrArg Fin.val (congrArg WuXing.toFin h)
    rw [toFin_next_iterate] at h2
    omega
  · intro h
    obtain ⟨k, rfl⟩ := h
    rw [Function.iterate_mul, next_five, Function.iterate_id]
    rfl

/-- 相克映射迭代五次回到原点。 -/
theorem overcomes_five : overcomes^[5] = id := by
  funext x
  cases x <;> rfl

/-- 相克映射没有不动点。 -/
theorem overcomes_ne_self (x : WuXing) : overcomes x ≠ x := by
  cases x <;> decide

/-- 相生与相克是不同的关系。 -/
theorem overcomes_ne_next (x : WuXing) : overcomes x ≠ next x := by
  cases x <;> decide

/-- `prev` 是 `next` 的左逆。 -/
theorem prev_next (x : WuXing) : prev (next x) = x := by
  cases x <;> rfl

/-- `prev` 是 `next` 的右逆。 -/
theorem next_prev (x : WuXing) : next (prev x) = x := by
  cases x <;> rfl

/-- `prev` 也是单射（`next` 的逆映射）。 -/
theorem prev_injective : Function.Injective prev := by
  intro a b h
  cases a <;> cases b <;> simp [prev] at h ⊢

/-- 逆向映射 `prev` 没有不动点。 -/
theorem prev_ne_self (x : WuXing) : prev x ≠ x := by
  cases x <;> decide

/-- `prev` 迭代五次回到原点。 -/
theorem prev_five : prev^[5] = id := by
  funext x
  cases x <;> rfl

/-- 相生关系与逆向映射的等价刻画。 -/
theorem next_eq_iff_prev (x y : WuXing) : next x = y ↔ x = prev y := by
  constructor
  · intro h
    rw [← h, prev_next]
  · intro h
    rw [h, next_prev]

/-- `overcomeBy` 是 `overcomes` 的左逆。 -/
theorem overcomeBy_overcomes (x : WuXing) : overcomeBy (overcomes x) = x := by
  cases x <;> rfl

/-- `overcomeBy` 是 `overcomes` 的右逆。 -/
theorem overcomes_overcomeBy (x : WuXing) : overcomes (overcomeBy x) = x := by
  cases x <;> rfl

/-- `overcomeBy` 是单射。 -/
theorem overcomeBy_injective : Function.Injective overcomeBy := by
  intro a b h
  cases a <;> cases b <;> simp [overcomeBy] at h ⊢

/-- 逆向的相克映射没有不动点。 -/
theorem overcomeBy_ne_self (x : WuXing) : overcomeBy x ≠ x := by
  cases x <;> decide

/-- `overcomeBy` 迭代五次回到原点。 -/
theorem overcomeBy_five : overcomeBy^[5] = id := by
  funext x
  cases x <;> rfl

/-- 相克关系与逆向映射的等价刻画。 -/
theorem overcomes_eq_iff_overcomeBy (x y : WuXing) :
    overcomes x = y ↔ x = overcomeBy y := by
  constructor
  · intro h
    rw [← h, overcomeBy_overcomes]
  · intro h
    rw [h, overcomes_overcomeBy]

/-- 从木出发的相生轨道覆盖全部五行。 -/
theorem next_orbit_wood (y : WuXing) : ∃ n, n < 5 ∧ next^[n] wood = y := by
  cases y
  · exact ⟨0, by decide, rfl⟩
  · exact ⟨1, by decide, rfl⟩
  · exact ⟨2, by decide, rfl⟩
  · exact ⟨3, by decide, rfl⟩
  · exact ⟨4, by decide, rfl⟩

end WuXing

end Occult
