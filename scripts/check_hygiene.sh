#!/usr/bin/env bash
# scripts/check_hygiene.sh — 证明卫生检查
#
# 1. 源文件中不得出现 sorry / admit / native_decide / implemented_by / extern；
# 2. 源文件中不得声明自定义 axiom 或 constant；
# 3. 对库内每一条 theorem / lemma 运行 `#print axioms`，
#    只允许 Lean 标准公理 propext、Classical.choice、Quot.sound。
#
# 任一检查失败都会以非零退出码结束。
set -euo pipefail

cd "$(dirname "$0")/.."

# 库内需要检查的源文件（不含 .lake）。
mapfile -t FILES < <(find Occult -name '*.lean' | sort)
FILES+=(Occult.lean Main.lean Tests.lean)

echo "==> 禁止关键字检查（sorry / admit / native_decide / implemented_by / extern）"
if grep -rnE '\b(sorry|admit|native_decide|implemented_by|extern)\b' "${FILES[@]}"; then
  echo "错误：源文件中出现禁用关键字" >&2
  exit 1
fi

echo "==> 自定义 axiom / constant 声明检查"
if grep -rnE '^[[:space:]]*(private[[:space:]]+|protected[[:space:]]+)*(axiom|constant)[[:space:]]' "${FILES[@]}"; then
  echo "错误：源文件中出现 axiom 或 constant 声明" >&2
  exit 1
fi

echo "==> 收集库内 theorem / lemma"
names_file=$(mktemp)
lean_file=$(mktemp --suffix=.lean)
log_file=$(mktemp)
cleanup() { rm -f "$names_file" "$lean_file" "$log_file"; }
trap cleanup EXIT

for f in $(find Occult -name '*.lean' | sort); do
  base="$(basename "$f" .lean)"
  case "$f" in
    Occult/Cli.lean) ns="Occult" ;;
    Occult/ZiWei/Position.lean|Occult/ZiWei/Properties.lean) ns="Occult.ZiWei.Position" ;;
    Occult/ZiWei/Relations.lean) ns="Occult.ZiWei.Palace" ;;
    Occult/ZiWei/*)  ns="Occult.ZiWei.$base" ;;
    *)               ns="Occult.$base" ;;
  esac
  { grep -hoE '^[[:space:]]*(@\[[^]]*\][[:space:]]*)?(private[[:space:]]+|protected[[:space:]]+)?(theorem|lemma)[[:space:]]+[A-Za-z_][A-Za-z0-9_?!'"'"']*' "$f" || true; } \
    | sed -E 's/^[[:space:]]*(@\[[^]]*\][[:space:]]*)?(private[[:space:]]+|protected[[:space:]]+)?(theorem|lemma)[[:space:]]+//' \
    | while IFS= read -r name; do printf '%s.%s\n' "$ns" "$name"; done
done | sort -u > "$names_file"

count="$(wc -l < "$names_file")"
echo "共 $count 条待检查"

{
  echo "import Occult"
  echo
  while IFS= read -r name; do
    echo "#print axioms $name"
  done < "$names_file"
} > "$lean_file"

if ! lake env lean "$lean_file" > "$log_file" 2>&1; then
  echo "错误：#print axioms 执行失败（可能有定理名不存在）" >&2
  cat "$log_file" >&2
  exit 1
fi

echo "==> 公理白名单检查"
violations="$(grep -oE 'depends on axioms: \[[^]]*\]' "$log_file" \
  | sed 's/.*\[//; s/\]//' \
  | tr ',' '\n' \
  | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
  | grep -vE '^(propext|Classical\.choice|Quot\.sound)$' || true)"

if [[ -n "$violations" ]]; then
  echo "错误：发现白名单之外的公理：" >&2
  echo "$violations" >&2
  exit 1
fi

echo "==> 公理检查通过：只出现 propext、Classical.choice、Quot.sound"
