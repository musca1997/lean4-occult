/-
Occult/TianGan.lean

十天干：甲乙丙丁戊己庚辛壬癸。
天干只有有限十个元素；本文件给出命名构造子、到 `Fin 10` 的编码、
阴阳归属（按序号奇偶：偶数位为阳，奇数位为阴），以及从字符串解析。

关于阴阳归属的约定见 `docs/conventions.md`：这是本项目采用的编码约定，
不是对传统文献的引用。
-/

import Mathlib.Data.Fintype.Card
import Mathlib.Tactic
import Occult.YinYang

namespace Occult

/-- 十天干。 -/
inductive TianGan where
  /-- 甲 -/
  | jia
  /-- 乙 -/
  | yi
  /-- 丙 -/
  | bing
  /-- 丁 -/
  | ding
  /-- 戊 -/
  | wu
  /-- 己 -/
  | ji
  /-- 庚 -/
  | geng
  /-- 辛 -/
  | xin
  /-- 壬 -/
  | ren
  /-- 癸 -/
  | gui
  deriving DecidableEq, Repr

namespace TianGan

/-- 序号编码：甲 ↦ 0，…，癸 ↦ 9。 -/
def toFin : TianGan → Fin 10
  | jia => ⟨0, by decide⟩
  | yi => ⟨1, by decide⟩
  | bing => ⟨2, by decide⟩
  | ding => ⟨3, by decide⟩
  | wu => ⟨4, by decide⟩
  | ji => ⟨5, by decide⟩
  | geng => ⟨6, by decide⟩
  | xin => ⟨7, by decide⟩
  | ren => ⟨8, by decide⟩
  | gui => ⟨9, by decide⟩

/-- 从序号解码。 -/
def ofFin : Fin 10 → TianGan
  | ⟨0, _⟩ => jia
  | ⟨1, _⟩ => yi
  | ⟨2, _⟩ => bing
  | ⟨3, _⟩ => ding
  | ⟨4, _⟩ => wu
  | ⟨5, _⟩ => ji
  | ⟨6, _⟩ => geng
  | ⟨7, _⟩ => xin
  | ⟨8, _⟩ => ren
  | _ => gui

theorem ofFin_toFin (g : TianGan) : ofFin (toFin g) = g := by
  cases g <;> rfl

theorem toFin_ofFin (n : Fin 10) : toFin (ofFin n) = n := by
  obtain ⟨k, hk⟩ := n
  interval_cases k <;> rfl

/-- 天干与 `Fin 10` 的显式等价。 -/
def equivFin : TianGan ≃ Fin 10 where
  toFun := toFin
  invFun := ofFin
  left_inv := ofFin_toFin
  right_inv := toFin_ofFin

instance : Fintype TianGan := Fintype.ofEquiv (Fin 10) equivFin.symm

/-- 天干恰有十个。 -/
theorem card_eq_ten : Fintype.card TianGan = 10 := by
  rw [← Fintype.card_fin 10]
  exact Fintype.card_congr equivFin

/-- 天干的自然数序号（0–9）。 -/
def toNat (g : TianGan) : Nat := (toFin g).val

/-- 按自然数序号取天干（对 10 取模）。 -/
def ofNatMod (n : Nat) : TianGan := ofFin ⟨n % 10, Nat.mod_lt _ (by decide)⟩

/-- `toNat` 始终小于 10。 -/
theorem toNat_lt (g : TianGan) : g.toNat < 10 := (toFin g).isLt

/-- 先编码再解码回到自身。 -/
@[simp]
theorem ofNatMod_toNat (g : TianGan) : ofNatMod g.toNat = g := by
  conv_rhs => rw [← ofFin_toFin g]
  unfold ofNatMod toNat
  congr 1
  apply Fin.ext
  simp [Nat.mod_eq_of_lt (toFin g).isLt]

/-- 解码后的序号就是输入对 10 取模。 -/
@[simp]
theorem toNat_ofNatMod (n : Nat) : (ofNatMod n).toNat = n % 10 := by
  rw [toNat, ofNatMod, toFin_ofFin]

/-- 按序号取天干相同，当且仅当序号同余 10。 -/
theorem ofNatMod_eq_iff (a b : Nat) : ofNatMod a = ofNatMod b ↔ a % 10 = b % 10 := by
  constructor
  · intro h
    have := congrArg toNat h
    simpa using this
  · intro h
    unfold ofNatMod
    congr 1
    apply Fin.ext
    simpa using h

/-- 天干的阴阳：偶数序号为阳，奇数序号为阴。 -/
def yinYang (g : TianGan) : YinYang := YinYang.ofParity g.toNat

/-- 阴阳相同当且仅当序号同奇偶。 -/
theorem yinYang_eq_iff (g h : TianGan) : g.yinYang = h.yinYang ↔ g.toNat % 2 = h.toNat % 2 :=
  YinYang.ofParity_eq_iff _ _

/-- TianGan的单字符表示。 -/
def toChar : TianGan → Char
  | jia => '甲'
  | yi => '乙'
  | bing => '丙'
  | ding => '丁'
  | wu => '戊'
  | ji => '己'
  | geng => '庚'
  | xin => '辛'
  | ren => '壬'
  | gui => '癸'

/-- 从单字符解析。 -/
def ofChar : Char → Option TianGan
  | '甲' => some jia
  | '乙' => some yi
  | '丙' => some bing
  | '丁' => some ding
  | '戊' => some wu
  | '己' => some ji
  | '庚' => some geng
  | '辛' => some xin
  | '壬' => some ren
  | '癸' => some gui
  | _ => none

/-- 单字符解析与打印互逆。 -/
@[simp]
theorem ofChar_toChar (x : TianGan) : ofChar x.toChar = some x := by
  cases x <;> rfl

/-- 天干的汉字写法（单字字符串）。 -/
def name (x : TianGan) : String := String.singleton x.toChar

/-- 从单字字符串解析天干；非法输入返回 `none`。 -/
def parse (s : String) : Option TianGan :=
  match s.toList with
  | [c] => ofChar c
  | _ => none

/-- 解析与打印互逆。 -/
@[simp]
theorem parse_name (g : TianGan) : parse g.name = some g := by
  cases g <;> rfl

/-- 打印是单射。 -/
theorem name_injective : Function.Injective name := by
  intro a b h
  have h' : a.toChar = b.toChar := by
    simpa [name] using h
  cases a <;> cases b <;> simp [toChar] at h' ⊢

end TianGan

end Occult
