/-
Occult/ZiWei/Properties.lean

十二宫纯位置结构的整体性质。

* 整体旋转保持对宫、三合与三方四正（`rotate_opposite`、
  `rotate_trineForward`、`rotate_trineBackward`、`rotate_triad`）。
* 三方四正恰有 4 个元素，并在旋转下保持基数（`rotate_triad_card`）。
* 语义层（`Palace.atPos`）在任意参考位置下也满足同样的三方四正关系
  （`atPos_triad_ming`）。这里仍然**不涉及星曜或出生排盘**。
-/

import Occult.ZiWei.Relations

namespace Occult

namespace ZiWei

namespace Position

/-! ## 旋转保持结构 -/

/-- 整体旋转保持对宫。 -/
theorem rotate_opposite (k p : Position) : opposite (rotate k p) = rotate k (opposite p) := by
  apply Fin.ext
  simp [opposite, rotate, Fin.val_add]
  omega

/-- 整体旋转保持正向三合。 -/
theorem rotate_trineForward (k p : Position) :
    trineForward (rotate k p) = rotate k (trineForward p) := by
  apply Fin.ext
  simp [trineForward, rotate, Fin.val_add]
  omega

/-- 整体旋转保持逆向三合。 -/
theorem rotate_trineBackward (k p : Position) :
    trineBackward (rotate k p) = rotate k (trineBackward p) := by
  apply Fin.ext
  simp [trineBackward, rotate, Fin.val_add]
  omega

/-- 整体旋转把三方四正映到三方四正的像。 -/
theorem rotate_triad (k p : Position) : triad (rotate k p) = (triad p).image (rotate k) := by
  ext q
  simp [triad, trineForward, trineBackward, opposite, rotate, add_assoc, add_comm]

/-- 整体旋转保持三方四正的基数。 -/
theorem rotate_triad_card (k p : Position) : (triad (rotate k p)).card = 4 := by
  rw [rotate_triad, Finset.card_image_of_injective _ (rotate_injective k)]
  exact triad_card p

/-- 旋转下的三方四正成员等价刻画。 -/
theorem mem_triad_rotate_iff (k p q : Position) :
    q ∈ triad (rotate k p) ↔ rotate (-k) q ∈ triad p := by
  rw [rotate_triad, Finset.mem_image]
  constructor
  · rintro ⟨x, hx, hxq⟩
    have hx' : x = rotate (-k) q := by
      rw [← hxq]
      simp [rotate]
    simpa [hx'] using hx
  · intro hq
    refine ⟨rotate (-k) q, hq, ?_⟩
    simp [rotate]

/-! ## 成员关系 -/

/-- 对宫属于三方四正。 -/
theorem opposite_mem_triad (p : Position) : opposite p ∈ triad p := by
  simp [triad]

/-- 正向三合属于三方四正。 -/
theorem trineForward_mem_triad (p : Position) : trineForward p ∈ triad p := by
  simp [triad]

/-- 逆向三合属于三方四正。 -/
theorem trineBackward_mem_triad (p : Position) : trineBackward p ∈ triad p := by
  simp [triad]

/-- 自身属于三方四正。 -/
theorem self_mem_triad (p : Position) : p ∈ triad p := by
  simp [triad]

/-! ## 语义层：任意参考位置下的命宫三方四正 -/

/-- 命宫的正向三合是财帛宫。 -/
theorem trineForward_atPos_ming (anchor : Position) :
    trineForward (Palace.atPos anchor Palace.ming) = Palace.atPos anchor Palace.caiBo := by
  apply Fin.ext
  simp [Palace.atPos, Palace.offset, trineForward, rotate, Fin.val_add]
  omega

/-- 命宫的对宫是迁移宫。 -/
theorem opposite_atPos_ming (anchor : Position) :
    opposite (Palace.atPos anchor Palace.ming) = Palace.atPos anchor Palace.qianYi := by
  apply Fin.ext
  simp [Palace.atPos, Palace.offset, opposite, rotate, Fin.val_add]
  omega

/-- 命宫的逆向三合是官禄宫。 -/
theorem trineBackward_atPos_ming (anchor : Position) :
    trineBackward (Palace.atPos anchor Palace.ming) = Palace.atPos anchor Palace.guanLu := by
  apply Fin.ext
  simp [Palace.atPos, Palace.offset, trineBackward, rotate, Fin.val_add]
  omega

/-- 任意参考位置下，命宫、财帛宫、迁移宫、官禄宫构成命宫的三方四正。 -/
theorem atPos_triad_ming (anchor : Position) :
    triad (Palace.atPos anchor Palace.ming) =
      {Palace.atPos anchor Palace.ming, Palace.atPos anchor Palace.caiBo,
       Palace.atPos anchor Palace.qianYi, Palace.atPos anchor Palace.guanLu} := by
  rw [triad, trineForward_atPos_ming, opposite_atPos_ming, trineBackward_atPos_ming]

end Position

end ZiWei

end Occult
