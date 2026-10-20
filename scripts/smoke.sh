#!/usr/bin/env bash
# scripts/smoke.sh — CLI 冒烟测试：有效与非法输入都必须符合预期。
# 用法：scripts/smoke.sh [binary]
set -uo pipefail

BIN="${1:-.lake/build/bin/lean4-occult}"
if [[ ! -x "$BIN" ]]; then
  echo "找不到可执行文件：$BIN（先运行 lake build）" >&2
  exit 2
fi

fail=0
pass=0

# expect_ok <描述> <期望子串> <参数...>
expect_ok() {
  local desc="$1"; shift
  local needle="$1"; shift
  local out rc
  out="$("$BIN" "$@" 2>&1)"; rc=$?
  if [[ $rc -ne 0 ]]; then
    echo "FAIL [$desc] 退出码 $rc，期望 0"; echo "$out"; fail=$((fail+1)); return
  fi
  if [[ "$out" != *"$needle"* ]]; then
    echo "FAIL [$desc] 输出缺少 \"$needle\""; echo "$out"; fail=$((fail+1)); return
  fi
  pass=$((pass+1)); echo "ok   [$desc]"
}

# expect_fail <描述> <期望子串> <参数...>
expect_fail() {
  local desc="$1"; shift
  local needle="$1"; shift
  local out rc
  out="$("$BIN" "$@" 2>&1)"; rc=$?
  if [[ $rc -eq 0 ]]; then
    echo "FAIL [$desc] 退出码 0，期望非 0"; echo "$out"; fail=$((fail+1)); return
  fi
  if [[ "$out" != *"$needle"* ]]; then
    echo "FAIL [$desc] 输出缺少 \"$needle\""; echo "$out"; fail=$((fail+1)); return
  fi
  pass=$((pass+1)); echo "ok   [$desc]"
}

expect_ok   "cycle 0 = 甲子"        "甲子"            cycle 0
expect_ok   "cycle 59 = 癸亥"       "癸亥"            cycle 59
expect_ok   "cycle 59 下一步甲子"   "下一步 甲子"     cycle 59
expect_ok   "pair 甲 子"            "甲子"            pair 甲 子
expect_ok   "pair 癸 亥"            "癸亥"            pair 癸 亥
expect_ok   "help"                  "用法"            --help

expect_fail "cycle 60 越界"         "0–59"            cycle 60
expect_fail "cycle -1 非数字"       "十进制"          cycle -1
expect_fail "cycle abc 非数字"      "十进制"          cycle abc
expect_fail "pair 甲 丑 阴阳不同"   "阴阳不同"        pair 甲 丑
expect_fail "pair 乙 子 阴阳不同"   "阴阳不同"        pair 乙 子
expect_fail "pair 子 甲 未知天干"   "未知天干"        pair 子 甲
expect_fail "pair 甲 X 未知地支"    "未知地支"        pair 甲 X
expect_fail "pair 缺参"             "无法识别"        pair 甲
expect_fail "未知子命令"            "无法识别"        frobnicate
expect_fail "pair 多参"             "无法识别"        pair 甲 子 丑
expect_fail "cycle 超大数"          "0–59"            cycle 999999999999999999999999
expect_ok   "cycle 007 前导零"      "辛未"            cycle 007

expect_ok   "ziwei relations 0 自身"    "自身 0"                ziwei relations 0
expect_ok   "ziwei 0 对宫"              "对宫 6"                ziwei relations 0
expect_ok   "ziwei 0 三合"              "三合 4, 8"             ziwei relations 0
expect_ok   "ziwei 0 三方四正"          "三方四正 0/4/6/8"      ziwei relations 0
expect_ok   "ziwei relations 11"        "位置 11"               ziwei relations 11
expect_fail "ziwei relations 12 越界"   "0–11"                  ziwei relations 12
expect_fail "ziwei relations -1"        "十进制"                ziwei relations -1
expect_fail "ziwei relations abc"       "十进制"                ziwei relations abc
expect_fail "ziwei relations 缺参"      "缺少位置参数"          ziwei relations
expect_fail "ziwei relations 多参"      "只接受一个位置参数"    ziwei relations 1 2

# v0.3 小安星：禄存、擎羊、陀罗、天马
expect_ok   "anstar 甲子 禄存寅"        "禄存 寅 (2)"           ziwei anstar 甲 子
expect_ok   "anstar 甲子 擎羊卯"        "擎羊 卯 (3)"           ziwei anstar 甲 子
expect_ok   "anstar 甲子 陀罗丑"        "陀罗 丑 (1)"           ziwei anstar 甲 子
expect_ok   "anstar 甲子 天马寅"        "天马 寅 (2)"           ziwei anstar 甲 子
expect_ok   "anstar 癸亥 禄存子"        "禄存 子 (0)"           ziwei anstar 癸 亥
expect_ok   "anstar 癸亥 擎羊丑"        "擎羊 丑 (1)"           ziwei anstar 癸 亥
expect_ok   "anstar 癸亥 陀罗亥"        "陀罗 亥 (11)"          ziwei anstar 癸 亥
expect_ok   "anstar 癸亥 天马巳"        "天马 巳 (5)"           ziwei anstar 癸 亥
expect_ok   "anstar 丙寅 禄存巳"        "禄存 巳 (5)"           ziwei anstar 丙 寅
expect_ok   "anstar 丙寅 天马申"        "天马 申 (8)"           ziwei anstar 丙 寅
expect_fail "anstar 甲丑 阴阳不同"      "不是六十甲子"          ziwei anstar 甲 丑
expect_fail "anstar 乙子 阴阳不同"      "不是六十甲子"          ziwei anstar 乙 子
expect_fail "anstar 子甲 未知天干"      "未知天干"              ziwei anstar 子 甲
expect_fail "anstar 甲X 未知地支"       "未知地支"              ziwei anstar 甲 X
expect_fail "anstar 缺地支"             "缺少地支参数"          ziwei anstar 甲
expect_fail "anstar 缺两参"             "缺少天干和地支参数"    ziwei anstar
expect_fail "anstar 多参"               "只接受两个参数"        ziwei anstar 甲 子 丑

count="$("$BIN" list 2>/dev/null | wc -l)"
if [[ "$count" -ne 60 ]]; then
  echo "FAIL [list 行数] 期望 60，实际 $count"; fail=$((fail+1))
else
  pass=$((pass+1)); echo "ok   [list 行数 = 60]"
fi

echo
echo "通过 $pass 项，失败 $fail 项"
[[ $fail -eq 0 ]]
