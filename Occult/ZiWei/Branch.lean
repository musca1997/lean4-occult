/-
Occult/ZiWei/Branch.lean

把十二地支（`Occult.DiZhi`）与紫微十二宫位置（`Occult.ZiWei.Position`）
对接起来。

* 这是一条**项目约定**：位置序号 = 地支序号，即
  子 ↦ 0、丑 ↦ 1、…、亥 ↦ 11。
* 本文件只建立双射与往返定理，不解释任何宫位含义，也不涉及出生排盘。
-/

import Occult.DiZhi
import Occult.ZiWei.Position

namespace Occult

namespace ZiWei

namespace Branch

/-- 地支到宫位位置：位置序号取地支序号（项目约定）。 -/
def ofDiZhi (b : DiZhi) : Position := ⟨b.toNat, b.toNat_lt⟩

/-- 宫位位置到地支：按序号对 12 取模后解码。 -/
def toDiZhi (p : Position) : DiZhi := DiZhi.ofNatMod p.val

/-- 先 `ofDiZhi` 再 `toDiZhi` 回到原地支。 -/
@[simp]
theorem toDiZhi_ofDiZhi (b : DiZhi) : toDiZhi (ofDiZhi b) = b := by
  simp [toDiZhi, ofDiZhi, DiZhi.ofNatMod_toNat]

/-- 先 `toDiZhi` 再 `ofDiZhi` 回到原位置。 -/
@[simp]
theorem ofDiZhi_toDiZhi (p : Position) : ofDiZhi (toDiZhi p) = p := by
  apply Fin.ext
  simp [ofDiZhi, toDiZhi, DiZhi.toNat_ofNatMod, Nat.mod_eq_of_lt p.isLt]

/-- 地支与位置的双射。 -/
def equiv : DiZhi ≃ Position where
  toFun := ofDiZhi
  invFun := toDiZhi
  left_inv := toDiZhi_ofDiZhi
  right_inv := ofDiZhi_toDiZhi

/-- `ofDiZhi` 是单射。 -/
theorem ofDiZhi_injective : Function.Injective ofDiZhi := equiv.injective

/-- `toDiZhi` 是单射。 -/
theorem toDiZhi_injective : Function.Injective toDiZhi := equiv.symm.injective

/-- `ofDiZhi` 是双射。 -/
theorem ofDiZhi_bijective : Function.Bijective ofDiZhi := equiv.bijective

/-- 位置序号就是其地支序号。 -/
@[simp]
theorem toNat_ofDiZhi (b : DiZhi) : (ofDiZhi b).val = b.toNat := rfl

/-- 显式表：子 0、丑 1、寅 2、卯 3、辰 4、巳 5、午 6、未 7、申 8、酉 9、戌 10、亥 11。 -/
theorem ofDiZhi_toNat (b : DiZhi) :
    (ofDiZhi b).val =
      match b with
      | DiZhi.zi => 0 | DiZhi.chou => 1 | DiZhi.yin => 2 | DiZhi.mao => 3
      | DiZhi.chen => 4 | DiZhi.si => 5 | DiZhi.wu => 6 | DiZhi.wei => 7
      | DiZhi.shen => 8 | DiZhi.you => 9 | DiZhi.xu => 10 | DiZhi.hai => 11 := by
  cases b <;> rfl

end Branch

end ZiWei

end Occult
