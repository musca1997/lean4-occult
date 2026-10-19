/-
Occult/DiZhi.lean

十二地支：子丑寅卯辰巳午未申酉戌亥。
同样给出到 `Fin 12` 的编码与阴阳归属（偶数位为阳，奇数位为阴）。
-/

import Mathlib.Data.Fintype.Card
import Mathlib.Tactic
import Occult.YinYang
import Occult.WuXing

namespace Occult

/-- 十二地支。 -/
inductive DiZhi where
  /-- 子 -/
  | zi
  /-- 丑 -/
  | chou
  /-- 寅 -/
  | yin
  /-- 卯 -/
  | mao
  /-- 辰 -/
  | chen
  /-- 巳 -/
  | si
  /-- 午 -/
  | wu
  /-- 未 -/
  | wei
  /-- 申 -/
  | shen
  /-- 酉 -/
  | you
  /-- 戌 -/
  | xu
  /-- 亥 -/
  | hai
  deriving DecidableEq, Repr

namespace DiZhi

/-- 序号编码：子 ↦ 0，…，亥 ↦ 11。 -/
def toFin : DiZhi → Fin 12
  | zi => ⟨0, by decide⟩
  | chou => ⟨1, by decide⟩
  | yin => ⟨2, by decide⟩
  | mao => ⟨3, by decide⟩
  | chen => ⟨4, by decide⟩
  | si => ⟨5, by decide⟩
  | wu => ⟨6, by decide⟩
  | wei => ⟨7, by decide⟩
  | shen => ⟨8, by decide⟩
  | you => ⟨9, by decide⟩
  | xu => ⟨10, by decide⟩
  | hai => ⟨11, by decide⟩

/-- 从序号解码。 -/
def ofFin : Fin 12 → DiZhi
  | ⟨0, _⟩ => zi
  | ⟨1, _⟩ => chou
  | ⟨2, _⟩ => yin
  | ⟨3, _⟩ => mao
  | ⟨4, _⟩ => chen
  | ⟨5, _⟩ => si
  | ⟨6, _⟩ => wu
  | ⟨7, _⟩ => wei
  | ⟨8, _⟩ => shen
  | ⟨9, _⟩ => you
  | ⟨10, _⟩ => xu
  | _ => hai

theorem ofFin_toFin (b : DiZhi) : ofFin (toFin b) = b := by
  cases b <;> rfl

theorem toFin_ofFin (n : Fin 12) : toFin (ofFin n) = n := by
  obtain ⟨k, hk⟩ := n
  interval_cases k <;> rfl

/-- 地支与 `Fin 12` 的显式等价。 -/
def equivFin : DiZhi ≃ Fin 12 where
  toFun := toFin
  invFun := ofFin
  left_inv := ofFin_toFin
  right_inv := toFin_ofFin

instance : Fintype DiZhi := Fintype.ofEquiv (Fin 12) equivFin.symm

/-- 地支恰有十二个。 -/
theorem card_eq_twelve : Fintype.card DiZhi = 12 := by
  rw [← Fintype.card_fin 12]
  exact Fintype.card_congr equivFin

/-- 地支的自然数序号（0–11）。 -/
def toNat (b : DiZhi) : Nat := (toFin b).val

/-- 按自然数序号取地支（对 12 取模）。 -/
def ofNatMod (n : Nat) : DiZhi := ofFin ⟨n % 12, Nat.mod_lt _ (by decide)⟩

/-- `toNat` 始终小于 12。 -/
theorem toNat_lt (b : DiZhi) : b.toNat < 12 := (toFin b).isLt

/-- 先编码再解码回到自身。 -/
@[simp]
theorem ofNatMod_toNat (b : DiZhi) : ofNatMod b.toNat = b := by
  conv_rhs => rw [← ofFin_toFin b]
  unfold ofNatMod toNat
  congr 1
  apply Fin.ext
  simp [Nat.mod_eq_of_lt (toFin b).isLt]

/-- 解码后的序号就是输入对 12 取模。 -/
@[simp]
theorem toNat_ofNatMod (n : Nat) : (ofNatMod n).toNat = n % 12 := by
  rw [toNat, ofNatMod, toFin_ofFin]

/-- 按序号取地支相同，当且仅当序号同余 12。 -/
theorem ofNatMod_eq_iff (a b : Nat) : ofNatMod a = ofNatMod b ↔ a % 12 = b % 12 := by
  constructor
  · intro h
    have := congrArg toNat h
    simpa using this
  · intro h
    unfold ofNatMod
    congr 1
    apply Fin.ext
    simpa using h

/-- 地支的**本气**五行（项目约定，**不是藏干**）：
子水、丑土、寅木、卯木、辰土、巳火、午火、未土、申金、酉金、戌土、亥水。
藏干（含中气、余气）不在本库范围内；见 `docs/conventions.md` 与 `docs/sources.md`。 -/
def wuXing : DiZhi → WuXing
  | zi => WuXing.water
  | chou => WuXing.earth
  | yin => WuXing.wood
  | mao => WuXing.wood
  | chen => WuXing.earth
  | si => WuXing.fire
  | wu => WuXing.fire
  | wei => WuXing.earth
  | shen => WuXing.metal
  | you => WuXing.metal
  | xu => WuXing.earth
  | hai => WuXing.water

/-- 地支本气五行的具体编码（逐项展开，便于审阅）。 -/
theorem wuXing_toFin (b : DiZhi) : b.wuXing.toFin.val =
    match b with
    | zi => 4 | chou => 2 | yin => 0 | mao => 0 | chen => 2 | si => 1
    | wu => 1 | wei => 2 | shen => 3 | you => 3 | xu => 2 | hai => 4 := by
  cases b <;> rfl

/-- 按序号取地支不改变本气五行（编码往返的直接推论）。 -/
@[simp]
theorem wuXing_ofNatMod_toNat (b : DiZhi) : (ofNatMod b.toNat).wuXing = b.wuXing := by
  rw [ofNatMod_toNat]

/-- 地支的阴阳：偶数序号为阳，奇数序号为阴。 -/
def yinYang (b : DiZhi) : YinYang := YinYang.ofParity b.toNat

/-- 阴阳相同当且仅当序号同奇偶。 -/
theorem yinYang_eq_iff (a b : DiZhi) : a.yinYang = b.yinYang ↔ a.toNat % 2 = b.toNat % 2 :=
  YinYang.ofParity_eq_iff _ _

/-- DiZhi的单字符表示。 -/
def toChar : DiZhi → Char
  | zi => '子'
  | chou => '丑'
  | yin => '寅'
  | mao => '卯'
  | chen => '辰'
  | si => '巳'
  | wu => '午'
  | wei => '未'
  | shen => '申'
  | you => '酉'
  | xu => '戌'
  | hai => '亥'

/-- 从单字符解析。 -/
def ofChar : Char → Option DiZhi
  | '子' => some zi
  | '丑' => some chou
  | '寅' => some yin
  | '卯' => some mao
  | '辰' => some chen
  | '巳' => some si
  | '午' => some wu
  | '未' => some wei
  | '申' => some shen
  | '酉' => some you
  | '戌' => some xu
  | '亥' => some hai
  | _ => none

/-- 单字符解析与打印互逆。 -/
@[simp]
theorem ofChar_toChar (x : DiZhi) : ofChar x.toChar = some x := by
  cases x <;> rfl

/-- 地支的汉字写法（单字字符串）。 -/
def name (x : DiZhi) : String := String.singleton x.toChar

/-- 从单字字符串解析地支；非法输入返回 `none`。 -/
def parse (s : String) : Option DiZhi :=
  match s.toList with
  | [c] => ofChar c
  | _ => none

/-- 解析与打印互逆。 -/
@[simp]
theorem parse_name (b : DiZhi) : parse b.name = some b := by
  cases b <;> rfl

/-- 打印是单射。 -/
theorem name_injective : Function.Injective name := by
  intro a b h
  have h' : a.toChar = b.toChar := by
    simpa [name] using h
  cases a <;> cases b <;> simp [toChar] at h' ⊢

end DiZhi

end Occult
