/-
Main.lean

`lean4-occult` 命令行入口。

用法：
  lean4-occult cycle <n>        显示第 n 位（0–59）的甲子及其下一步
  lean4-occult pair <天干> <地支>  由干支查索引，校验同阴阳
  lean4-occult list             列出全部六十甲子
  lean4-occult --help

所有输入都做显式校验，非法输入以退出码 1 结束并在 stderr 给出说明。
-/

import Occult

open Occult

/-- 打印一位甲子的完整信息。 -/
def describe (z : JiaZi) : String :=
  let i := z.toIndex.val
  let yy := match z.stem.yinYang with
    | .yin => "阴"
    | .yang => "阳"
  let nxt := JiaZi.next z
  s!"索引 {i}：{JiaZi.name z}（{z.stem.name}{yy}，天干 {z.stem.toNat}，地支 {z.branch.toNat}），" ++
    s!"下一步 {JiaZi.name nxt}（索引 {nxt.toIndex.val}）"

def usage : String :=
  "用法：\n" ++
  "  lean4-occult cycle <n>          显示第 n 位（0–59）的甲子\n" ++
  "  lean4-occult pair <天干> <地支>  由干支查索引（要求同阴阳）\n" ++
  "  lean4-occult list               列出全部六十甲子\n" ++
  "  lean4-occult --help             显示本帮助\n" ++
  "\n示例：lean4-occult cycle 0 / lean4-occult pair 甲 子"

def fail (msg : String) : IO UInt32 := do
  IO.eprintln s!"错误：{msg}"
  IO.eprintln ""
  IO.eprintln usage
  return 1

def main (args : List String) : IO UInt32 := do
  match args with
  | [] => fail "缺少子命令"
  | ["--help"] | ["-h"] | ["help"] =>
    IO.println usage
    return 0
  | ["list"] =>
    for n in List.finRange 60 do
      IO.println (describe (JiaZi.ofIndex n))
    return 0
  | ["cycle", s] =>
    match parseNat? s with
    | none => fail s!"cycle 需要非负十进制整数，收到 {repr s}"
    | some n =>
      if h : n < 60 then
        IO.println (describe (JiaZi.ofIndex ⟨n, h⟩))
        return 0
      else
        fail s!"cycle 的索引必须在 0–59 之间，收到 {n}"
  | ["pair", g, b] =>
    match TianGan.parse g, DiZhi.parse b with
    | none, _ => fail s!"未知天干 {repr g}（应为 甲 乙 丙 丁 戊 己 庚 辛 壬 癸 之一）"
    | _, none => fail s!"未知地支 {repr b}（应为 子 丑 寅 卯 辰 巳 午 未 申 酉 戌 亥 之一）"
    | some g, some b =>
      if h : g.toNat % 2 = b.toNat % 2 then
        let z : JiaZi := ⟨g, b, h⟩
        IO.println (describe z)
        return 0
      else
        IO.eprintln s!"错误：{g.name}{b.name} 阴阳不同（{g.name} 序号 {g.toNat}，{b.name} 序号 {b.toNat}），不在六十甲子中"
        return 1
  | _ => fail s!"无法识别的参数：{args}"
