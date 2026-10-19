/-
Occult/ZiWei/Position.lean

紫微斗数的**纯位置结构**（v0.2）。

* 位置用 `Fin 12` 表示（`Position`）；序号 0–11 只是位置标记。
* 这里**不出现**星曜、出生时间、四化、限运等任何需要历法或传统起例的内容。
* 命宫、财帛宫等**语义名称**单独放在 `Occult.ZiWei.Relations`，与位置本身分开。

所有定理都是有限阿贝尔群 `Fin 12` 上的组合事实。
-/

import Mathlib.Data.Finset.Basic
import Mathlib.Data.Fintype.Card
import Mathlib.Tactic

namespace Occult

namespace ZiWei

/-- 十二个抽象宫位位置，用 `Fin 12` 表示。 -/
abbrev Position := Fin 12

namespace Position

/-- 按自然数取位置（对 12 取模）。 -/
def ofNat (n : Nat) : Position := ⟨n % 12, Nat.mod_lt _ (by decide)⟩

/-- 位置的自然数序号（0–11）。 -/
def toNat (p : Position) : Nat := p.val

/-- 取模编码后的序号就是输入对 12 取模。 -/
@[simp]
theorem toNat_ofNat (n : Nat) : (ofNat n).toNat = n % 12 := rfl

/-- 先取序号再编码回到自身。 -/
@[simp]
theorem ofNat_toNat (p : Position) : ofNat p.toNat = p := by
  apply Fin.ext
  simp [ofNat, toNat, Nat.mod_eq_of_lt p.isLt]

/-- 位置上的整体旋转：把 `p` 平移 `k`。 -/
def rotate (k p : Position) : Position := k + p

/-- 旋转复合：先转 `l` 再转 `k`，等于一次转 `k + l`。 -/
theorem rotate_add (k l p : Position) : rotate (k + l) p = rotate k (rotate l p) := by
  simp [rotate, add_assoc]

/-- 旋转 0 是恒等。 -/
@[simp]
theorem rotate_zero (p : Position) : rotate 0 p = p := by
  simp [rotate]

/-- 旋转 `k` 的逆操作是旋转 `-k`。 -/
@[simp]
theorem rotate_neg (k p : Position) : rotate (-k) (rotate k p) = p := by
  simp [rotate]

/-- 每个旋转都是单射。 -/
theorem rotate_injective (k : Position) : Function.Injective (rotate k) := by
  intro a b h
  have h' := congrArg (rotate (-k)) h
  simpa [rotate] using h'

/-- 对宫：偏移 6。 -/
def opposite (p : Position) : Position := rotate 6 p

/-- 对宫的对宫是自身。 -/
theorem opposite_involutive (p : Position) : opposite (opposite p) = p := by
  apply Fin.ext
  simp [opposite, rotate, Fin.val_add]
  omega

/-- 对宫没有不动点。 -/
theorem opposite_ne_self (p : Position) : opposite p ≠ p := by
  intro h
  have h' := congrArg Fin.val h
  simp [opposite, rotate, Fin.val_add] at h'
  omega

/-- 三合的一个方向：偏移 4。 -/
def trineForward (p : Position) : Position := rotate 4 p

/-- 三合的另一个方向：偏移 8。 -/
def trineBackward (p : Position) : Position := rotate 8 p

/-- 连续偏移 4 三次回到原位。 -/
theorem trineForward_three (p : Position) :
    trineForward (trineForward (trineForward p)) = p := by
  apply Fin.ext
  simp [trineForward, rotate, Fin.val_add]
  omega

/-- 偏移 8 等于偏移 4 两次（两个三合方向互为逆向）。 -/
theorem trineBackward_eq_trineForward_twice (p : Position) :
    trineBackward p = trineForward (trineForward p) := by
  apply Fin.ext
  simp [trineBackward, trineForward, rotate, Fin.val_add]
  omega

/-- 三合正向偏移没有不动点。 -/
theorem trineForward_ne_self (p : Position) : trineForward p ≠ p := by
  intro h
  have h' := congrArg Fin.val h
  simp [trineForward, rotate, Fin.val_add] at h'
  omega

/-- 三合逆向偏移没有不动点。 -/
theorem trineBackward_ne_self (p : Position) : trineBackward p ≠ p := by
  intro h
  have h' := congrArg Fin.val h
  simp [trineBackward, rotate, Fin.val_add] at h'
  omega

/-- 三方四正：自身、两个三合、对宫组成的有限集 `{p, p+4, p+6, p+8}`。 -/
def triad (p : Position) : Finset Position :=
  {p, trineForward p, opposite p, trineBackward p}

/-- 三方四正恰有 4 个元素。 -/
theorem triad_card (p : Position) : (triad p).card = 4 := by
  have h : triad p = ({0, 4, 6, 8} : Finset Position).image (fun k => rotate k p) := by
    ext q
    simp [triad, trineForward, trineBackward, opposite, rotate]
  rw [h, Finset.card_image_of_injective _ (by intro a b hh; exact add_right_cancel hh)]
  decide

/-- 三方四正的显式成员刻画。 -/
theorem mem_triad_iff (p q : Position) :
    q ∈ triad p ↔ q = p ∨ q = trineForward p ∨ q = opposite p ∨ q = trineBackward p := by
  simp [triad]

end Position

end ZiWei

end Occult
