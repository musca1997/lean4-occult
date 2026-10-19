/-
Occult/Cli.lean

CLI 共用的输入解析。放在库里（而不是 `Main.lean`）是为了让解析行为
可以被 `Tests.lean` 直接检查，也避免在可执行文件中重复实现。

`parseNat?` 只接受非空 ASCII 十进制串；负号、空格、全角数字、空串一律
返回 `none`。它不使用 `String.toNat!`（后者在非法输入上会 panic）。
-/
import Mathlib.Tactic

namespace Occult

/-- 把字符当作十进制数字的值；非数字字符返回 `none`。 -/
def digitVal? (c : Char) : Option Nat :=
  if c ≥ '0' && c ≤ '9' then some (c.toNat - '0'.toNat) else none

/-- 解析非空 ASCII 十进制自然数。 -/
def parseNat? (s : String) : Option Nat :=
  s.toList.foldl (fun acc c =>
    match acc, digitVal? c with
    | some n, some d => some (n * 10 + d)
    | _, _ => none) (if s.isEmpty then none else some 0)

/-- 空串不是自然数。 -/
@[simp]
theorem parseNat?_empty : parseNat? "" = none := rfl

/-- 单字符 `0` 解析为 0。 -/
@[simp]
theorem parseNat?_zero : parseNat? "0" = some 0 := rfl

/-- 具体用例（CLI 冒烟测试依赖）。 -/
@[simp] theorem parseNat?_007 : parseNat? "007" = some 7 := rfl
@[simp] theorem parseNat?_59 : parseNat? "59" = some 59 := rfl
@[simp] theorem parseNat?_60 : parseNat? "60" = some 60 := rfl
@[simp] theorem parseNat?_neg : parseNat? "-1" = none := rfl
@[simp] theorem parseNat?_mixed : parseNat? "1x" = none := rfl
@[simp] theorem parseNat?_space : parseNat? " 1" = none := rfl

end Occult
