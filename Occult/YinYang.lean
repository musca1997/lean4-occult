/-
Occult/YinYang.lean

阴阳（YinYang）有限结构：两个元素，带一个对合（取反）。
这是整个库最底层的类型，供天干、地支共享。
-/

import Mathlib.Data.Fintype.Card
import Mathlib.Tactic

namespace Occult

/-- 阴阳：仅有两个构造子。 -/
inductive YinYang where
  /-- 阴 -/
  | yin
  /-- 阳 -/
  | yang
  deriving DecidableEq, Repr

namespace YinYang

/-- 取反：阴变阳，阳变阴。 -/
def neg : YinYang → YinYang
  | yin => yang
  | yang => yin

/-- 取反是对合（两次取反回到自身）。 -/
@[simp]
theorem neg_neg (x : YinYang) : neg (neg x) = x := by
  cases x <;> rfl

/-- 取反没有不动点。 -/
theorem neg_ne_self (x : YinYang) : neg x ≠ x := by
  cases x <;> decide

/-- 取反是单射。 -/
theorem neg_injective : Function.Injective neg := by
  intro a b h
  cases a <;> cases b <;> simp [neg] at h ⊢

/-- 穷举：任何阴阳要么是阴，要么是阳。 -/
theorem eq_yin_or_yang (x : YinYang) : x = yin ∨ x = yang := by
  cases x <;> simp

/-- 按自然数奇偶解释阴阳：偶数记为阳，奇数记为阴。 -/
def ofParity (n : Nat) : YinYang :=
  if n % 2 = 0 then yang else yin

/-- 奇偶解释与相等一致。 -/
theorem ofParity_eq_iff (a b : Nat) : ofParity a = ofParity b ↔ a % 2 = b % 2 := by
  unfold ofParity
  by_cases ha : a % 2 = 0 <;> by_cases hb : b % 2 = 0 <;>
    simp [ha, hb] <;> omega

/-- 奇偶解释在模偶数下不变。 -/
theorem ofParity_mod (n k : Nat) (he : k % 2 = 0) :
    ofParity (n % k) = ofParity n := by
  rw [ofParity_eq_iff, Nat.mod_mod_of_dvd n (Nat.dvd_of_mod_eq_zero he)]

/-- 奇偶解释的后继会翻转阴阳。 -/
theorem ofParity_succ (n : Nat) : ofParity (n + 1) = neg (ofParity n) := by
  unfold ofParity neg
  by_cases h : n % 2 = 0 <;> simp [h] <;> omega

/-- 到 `Fin 2` 的编码：阴 ↦ 0，阳 ↦ 1。 -/
def toFin : YinYang → Fin 2
  | yin => ⟨0, by decide⟩
  | yang => ⟨1, by decide⟩

/-- 从 `Fin 2` 解码。 -/
def ofFin : Fin 2 → YinYang
  | ⟨0, _⟩ => yin
  | _ => yang

theorem ofFin_toFin (x : YinYang) : ofFin (toFin x) = x := by
  cases x <;> rfl

theorem toFin_ofFin (n : Fin 2) : toFin (ofFin n) = n := by
  obtain ⟨k, hk⟩ := n
  interval_cases k <;> rfl

/-- 阴阳与 `Fin 2` 的显式等价。 -/
def equivFin : YinYang ≃ Fin 2 where
  toFun := toFin
  invFun := ofFin
  left_inv := ofFin_toFin
  right_inv := toFin_ofFin

instance : Fintype YinYang := Fintype.ofEquiv (Fin 2) equivFin.symm

/-- 阴阳恰有两个元素。 -/
theorem card_eq_two : Fintype.card YinYang = 2 := by
  rw [← Fintype.card_fin 2]
  exact Fintype.card_congr equivFin

/-- 对任意阴阳都成立的命题，只需分别验证阴与阳。 -/
theorem forall_iff (p : YinYang → Prop) : (∀ x, p x) ↔ p yin ∧ p yang := by
  constructor
  · intro h
    exact ⟨h _, h _⟩
  · intro h x
    cases x
    · exact h.1
    · exact h.2

end YinYang

end Occult
