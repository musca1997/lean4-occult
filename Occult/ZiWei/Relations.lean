/-
Occult/ZiWei/Relations.lean

把抽象位置（`Occult.ZiWei.Position`）与**语义名称**分开的层级。

* `Palace` 只是十二个名称（命宫、兄弟宫、…、父母宫）。
* `Palace.offset` 给出各名称相对参考位置 `anchor` 的固定偏移；
  这是一条**项目约定**，不是从出生时间算出的命盘，也不涉及任何星曜。
* `Palace.atPos anchor p` = `anchor + offset p`；`anchor` 是任意选定的参考位置，
  本库**不**从出生时间计算它。
-/

import Occult.ZiWei.Position

namespace Occult

namespace ZiWei

/-- 十二个语义宫名（纯标签，不含星曜与出生排盘）。 -/
inductive Palace where
  /-- 命宫 -/
  | ming
  /-- 兄弟宫 -/
  | xiongDi
  /-- 夫妻宫 -/
  | fuQi
  /-- 子女宫 -/
  | ziNv
  /-- 财帛宫 -/
  | caiBo
  /-- 疾厄宫 -/
  | jiE
  /-- 迁移宫 -/
  | qianYi
  /-- 仆役宫 -/
  | puYi
  /-- 官禄宫 -/
  | guanLu
  /-- 田宅宫 -/
  | tianZhai
  /-- 福德宫 -/
  | fuDe
  /-- 父母宫 -/
  | fuMu
  deriving DecidableEq, Repr

namespace Palace

/-- 十二宫的固定偏移（项目约定）：命 0、兄弟 1、…、父母 11。 -/
def offset : Palace → Position
  | ming => 0
  | xiongDi => 1
  | fuQi => 2
  | ziNv => 3
  | caiBo => 4
  | jiE => 5
  | qianYi => 6
  | puYi => 7
  | guanLu => 8
  | tianZhai => 9
  | fuDe => 10
  | fuMu => 11

/-- 偏移的逆映射（用于给出 `Palace` 的 `Fintype` 实例）。 -/
def ofOffset : Fin 12 → Palace
  | ⟨0, _⟩ => ming
  | ⟨1, _⟩ => xiongDi
  | ⟨2, _⟩ => fuQi
  | ⟨3, _⟩ => ziNv
  | ⟨4, _⟩ => caiBo
  | ⟨5, _⟩ => jiE
  | ⟨6, _⟩ => qianYi
  | ⟨7, _⟩ => puYi
  | ⟨8, _⟩ => guanLu
  | ⟨9, _⟩ => tianZhai
  | ⟨10, _⟩ => fuDe
  | _ => fuMu

/-- 先 `ofOffset` 再 `offset` 回到原索引。 -/
theorem offset_ofOffset (n : Fin 12) : offset (ofOffset n) = n := by
  fin_cases n <;> rfl

/-- 先 `offset` 再 `ofOffset` 回到原宫名。 -/
theorem ofOffset_offset (p : Palace) : ofOffset (offset p) = p := by
  cases p <;> rfl

/-- 宫名与 `Fin 12` 的显式等价（偏移是双射）。 -/
def equivFin : Palace ≃ Fin 12 where
  toFun := offset
  invFun := ofOffset
  left_inv := ofOffset_offset
  right_inv := offset_ofOffset

instance : Fintype Palace := Fintype.ofEquiv (Fin 12) equivFin.symm

/-- 宫名恰有十二个。 -/
theorem card_eq_twelve : Fintype.card Palace = 12 := by
  rw [← Fintype.card_fin 12]
  exact Fintype.card_congr equivFin

/-- 偏移是单射：不同宫名有不同偏移。 -/
theorem offset_injective : Function.Injective offset := equivFin.injective

/-- 参考位置 `anchor` 下的宫位：`anchor + offset p`。 -/
def atPos (anchor : Position) (palace : Palace) : Position := anchor + offset palace

/-- 命宫就是参考位置本身。 -/
theorem atPos_ming (anchor : Position) : atPos anchor ming = anchor := by
  simp [atPos, offset]

/-- 语义层与整体旋转可交换。 -/
theorem atPos_rotate (k anchor : Position) (palace : Palace) :
    atPos (Position.rotate k anchor) palace = Position.rotate k (atPos anchor palace) := by
  simp [atPos, Position.rotate, add_assoc]

/-! ### 语义对宫（项目约定）

以下六对是“偏移相差 6”，即 `Position.opposite` 在语义层的体现。
它们只是固定偏移的计算结果，不是对传统宫位关系的文献断言。
-/

theorem opposite_ming : Position.opposite (offset ming) = offset qianYi := by decide

theorem opposite_xiongDi : Position.opposite (offset xiongDi) = offset puYi := by decide

theorem opposite_fuQi : Position.opposite (offset fuQi) = offset guanLu := by decide

theorem opposite_ziNv : Position.opposite (offset ziNv) = offset tianZhai := by decide

theorem opposite_caiBo : Position.opposite (offset caiBo) = offset fuDe := by decide

theorem opposite_jiE : Position.opposite (offset jiE) = offset fuMu := by decide

/-! ### 命宫的三方四正（项目约定）

偏移 0、4、8 是命、财帛、官禄（两个三合方向）；偏移 6 是迁移（对宫）。
-/

theorem trineForward_ming : Position.trineForward (offset ming) = offset caiBo := by decide

theorem trineBackward_ming : Position.trineBackward (offset ming) = offset guanLu := by decide

/-- 命宫、财帛宫、迁移宫、官禄宫构成命宫的三方四正。 -/
theorem triad_ming :
    Position.triad (offset ming) = {offset ming, offset caiBo, offset qianYi, offset guanLu} := by
  rw [Position.triad, trineForward_ming, opposite_ming, trineBackward_ming]

end Palace

end ZiWei

end Occult
