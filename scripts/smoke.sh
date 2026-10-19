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

count="$("$BIN" list 2>/dev/null | wc -l)"
if [[ "$count" -ne 60 ]]; then
  echo "FAIL [list 行数] 期望 60，实际 $count"; fail=$((fail+1))
else
  pass=$((pass+1)); echo "ok   [list 行数 = 60]"
fi

echo
echo "通过 $pass 项，失败 $fail 项"
[[ $fail -eq 0 ]]
