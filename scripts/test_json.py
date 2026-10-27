#!/usr/bin/env python3
"""v0.4 JSON / report consistency tests.

This script checks the *rendered* CLI output against the v0.3 anstar output and
against an independent implementation of the finite relation classification.
It does not prove the Lean theorems; `lake build Tests` and
`scripts/check_hygiene.sh` do that. Here we exhaust all 60 sexagenary inputs.

Requires only Python 3.8+ (standard library). Usage:
    python3 scripts/test_json.py [path-to-lean4-occult]
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BIN = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, ".lake", "build", "bin", "lean4-occult")

STAR_NAMES = ["禄存", "擎羊", "陀罗", "天马"]
STAR_RULES = {
    "禄存": "ZW-LUCUN-STEM",
    "擎羊": "ZW-QINGYANG-AFTER-LUCUN",
    "陀罗": "ZW-TUOLUO-BEFORE-LUCUN",
    "天马": "ZW-TIANMA-BRANCH",
}
FACT_PAIRS = [
    ("禄存", "擎羊"),
    ("禄存", "陀罗"),
    ("禄存", "天马"),
    ("擎羊", "陀罗"),
    ("擎羊", "天马"),
    ("陀罗", "天马"),
]
RULE_CODES = [
    "ZW-LUCUN-STEM",
    "ZW-QINGYANG-AFTER-LUCUN",
    "ZW-TUOLUO-BEFORE-LUCUN",
    "ZW-TIANMA-BRANCH",
    "PRJ-BRANCH-POSITION",
    "PRJ-JIAZI-PARITY",
    "MATH-POSITION-CLASSIFY",
]
SOURCE_RULES = set(RULE_CODES[:4])
FACT_LABELS = {
    "same-palace": "同宫",
    "opposite-palace": "对宫（偏移 6）",
    "trine-palace": "三合（偏移 4/8）",
    "adjacent-palace": "相邻（偏移 ±1）",
    "different-palace": "不同宫",
}
SOURCE_A_URL = (
    "https://zh.wikisource.org/w/index.php?title="
    "%E7%B4%AB%E5%BE%AE%E6%96%97%E6%95%B8%E5%85%A8%E6%9B%B8/%E5%8D%B7%E4%BA%8C&oldid=1963110"
)
SOURCE_B_URL = "https://archive.org/details/20260506_20260506_1217/page/n75/mode/1up"


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run([BIN, *args], text=True, capture_output=True)


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def classify(p: int, q: int) -> str:
    if p == q:
        return "same-palace"
    if p == (q + 6) % 12:
        return "opposite-palace"
    if p in {(q + 4) % 12, (q + 8) % 12}:
        return "trine-palace"
    if p in {(q + 1) % 12, (q - 1) % 12}:
        return "adjacent-palace"
    return "different-palace"


def parse_anstar(text: str) -> dict[str, tuple[str, int]]:
    stars: dict[str, tuple[str, int]] = {}
    pattern = re.compile(r"^(禄存|擎羊|陀罗|天马) (\S+) \((\d+)\)$")
    for line in text.splitlines():
        match = pattern.match(line)
        if match:
            stars[match.group(1)] = (match.group(2), int(match.group(3)))
    if list(stars) != STAR_NAMES:
        fail(f"anstar output does not contain the four stars in order: {text!r}")
    return stars


def parse_input_name(index: int) -> str:
    result = run("cycle", str(index))
    if result.returncode != 0:
        fail(f"cycle {index} failed: {result.stderr}")
    match = re.search(r"索引 \d+：(\S{2})", result.stdout)
    if not match:
        fail(f"cannot parse cycle output: {result.stdout!r}")
    return match.group(1)


def check_report(index: int, name: str) -> None:
    stem, branch = name[0], name[1]
    anstar = run("ziwei", "anstar", stem, branch)
    if anstar.returncode != 0:
        fail(f"anstar {name} failed: {anstar.stderr}")
    expected_stars = parse_anstar(anstar.stdout)

    text = run("ziwei", "explain", stem, branch)
    if text.returncode != 0:
        fail(f"explain {name} failed: {text.stderr}")
    for star, (branch_name, position) in expected_stars.items():
        needle = f"{star} {branch_name} ({position})  规则 {STAR_RULES[star]}"
        if needle not in text.stdout:
            fail(f"{name}: text report missing {needle!r}")

    raw = run("ziwei", "explain", stem, branch, "--json")
    if raw.returncode != 0:
        fail(f"explain --json {name} failed: {raw.stderr}")
    if raw.stderr:
        fail(f"{name}: JSON mode wrote to stderr: {raw.stderr!r}")
    stripped = raw.stdout.strip()
    if not (stripped.startswith("{") and stripped.endswith("}")):
        fail(f"{name}: stdout is not a single JSON object: {stripped[:80]!r}")
    try:
        report = json.loads(stripped)
    except json.JSONDecodeError as exc:
        fail(f"{name}: invalid JSON: {exc}\n{stripped[:200]!r}")

    if set(report) != {
        "schemaVersion",
        "reportKind",
        "input",
        "rules",
        "stars",
        "derivations",
        "facts",
        "guarantees",
    }:
        fail(f"{name}: unexpected top-level keys {sorted(report)}")
    if report["schemaVersion"] != "0.4.0" or report["reportKind"] != "ziwei.explain":
        fail(f"{name}: bad version/kind")
    if report["input"] != {
        "jiazi": name,
        "index": index,
        "stem": stem,
        "branch": branch,
        "stemIndex": "甲乙丙丁戊己庚辛壬癸".index(stem),
        "branchIndex": "子丑寅卯辰巳午未申酉戌亥".index(branch),
        "polarity": "yang" if "甲乙丙丁戊己庚辛壬癸".index(stem) % 2 == 0 else "yin",
    }:
        fail(f"{name}: bad input object {report['input']!r}")

    rules = report["rules"]
    if [rule["id"] for rule in rules] != RULE_CODES:
        fail(f"{name}: rule ids/order mismatch: {[r['id'] for r in rules]}")
    for rule in rules:
        if rule["id"] in SOURCE_RULES:
            urls = [source["url"] for source in rule["sources"]]
            if urls != [SOURCE_A_URL, SOURCE_B_URL]:
                fail(f"{name}: source URLs mismatch for {rule['id']}: {urls}")
            if not all(source["quote"].strip() for source in rule["sources"]):
                fail(f"{name}: empty source quote for {rule['id']}")
        elif rule["sources"]:
            fail(f"{name}: non-source rule {rule['id']} has sources")

    stars = {entry["star"]: entry for entry in report["stars"]}
    if list(stars) != STAR_NAMES:
        fail(f"{name}: star entries/order mismatch: {list(stars)}")
    for star, (branch_name, position) in expected_stars.items():
        entry = stars[star]
        if entry["ruleId"] != STAR_RULES[star]:
            fail(f"{name}: wrong rule for {star}: {entry['ruleId']}")
        if entry["branch"] != branch_name or entry["position"] != position:
            fail(f"{name}: {star} JSON={entry} expected {(branch_name, position)}")

    derivations = {entry["star"]: entry for entry in report["derivations"]}
    if list(derivations) != STAR_NAMES:
        fail(f"{name}: derivation entries/order mismatch")
    lu_branch, lu_position = expected_stars["禄存"]
    for star, entry in derivations.items():
        stem_premise = f"生年干 {stem}（{report['input']['stemIndex']}）"
        if star == "天马":
            expected_premises = [f"生年支 {branch}（{report['input']['branchIndex']}）"]
        elif star in ("擎羊", "陀罗"):
            expected_premises = [stem_premise, f"中间事实：禄存位于 {lu_branch} ({lu_position})"]
        else:
            expected_premises = [stem_premise]
        if entry["premises"] != expected_premises:
            fail(f"{name}: bad premise for {star}: {entry['premises']!r} expected {expected_premises!r}")
        if entry["ruleId"] != STAR_RULES[star]:
            fail(f"{name}: bad derivation rule for {star}")
        if entry["conclusion"] != {"branch": expected_stars[star][0], "position": expected_stars[star][1]}:
            fail(f"{name}: bad derivation conclusion for {star}: {entry['conclusion']}")
        derived_line = f"  {'；'.join(expected_premises)} --[{STAR_RULES[star]}]--> {star} {expected_stars[star][0]} ({expected_stars[star][1]})"
        if derived_line not in text.stdout:
            fail(f"{name}: text report missing derivation {derived_line!r}")

    facts = report["facts"]
    if len(facts) != 6:
        fail(f"{name}: expected 6 facts, got {len(facts)}")
    for fact, pair in zip(facts, FACT_PAIRS):
        if (fact["left"], fact["right"]) != pair:
            fail(f"{name}: fact pair order mismatch: {(fact['left'], fact['right'])} vs {pair}")
        lp = stars[fact["left"]]["position"]
        rp = stars[fact["right"]]["position"]
        if fact["leftPosition"] != lp or fact["rightPosition"] != rp:
            fail(f"{name}: fact positions do not match star positions: {fact}")
        expected_kind = classify(lp, rp)
        if fact["kind"] != expected_kind or fact["label"] != FACT_LABELS[expected_kind]:
            fail(f"{name}: fact classification mismatch: {fact} expected {expected_kind}")
        fact_line = f"{fact['left']} / {fact['right']}：{fact['label']}；位置 {lp} / {rp}"
        if fact_line not in text.stdout:
            fail(f"{name}: text report missing fact {fact_line!r}")

    guarantees = report["guarantees"]
    if guarantees.get("externalCertificateChecker") is not False:
        fail(f"{name}: certificate checker must be explicitly false")
    if guarantees.get("soundnessTheorem") != "Occult.ZiWei.Explain.buildReport_correct":
        fail(f"{name}: bad soundness theorem reference")
    if "manual trust boundary" not in guarantees.get("sourceTranscription", ""):
        fail(f"{name}: missing source transcription trust boundary")
    for marker in ("已验证结构化层", "人工信任边界", "外部证书"):
        if marker not in text.stdout:
            fail(f"{name}: text report missing trust boundary marker {marker!r}")


def check_invalid() -> None:
    cases = [
        (["ziwei", "explain"], "缺少天干和地支参数"),
        (["ziwei", "explain", "甲"], "缺少地支参数"),
        (["ziwei", "explain", "甲", "丑", "--json"], "阴阳不同"),
        (["ziwei", "explain", "子", "甲"], "未知天干"),
        (["ziwei", "explain", "甲", "X"], "未知地支"),
        (["ziwei", "explain", "甲", "子", "--yaml"], "未知选项"),
        (["ziwei", "explain", "甲", "子", "--json", "--json"], "只能出现一次"),
        (["ziwei", "explain", "甲", "子", "丑"], "只接受两个干支参数"),
    ]
    for args, needle in cases:
        result = run(*args)
        if result.returncode == 0:
            fail(f"invalid command unexpectedly succeeded: {args}")
        if result.stdout:
            fail(f"invalid command wrote to stdout: {args}: {result.stdout!r}")
        if needle not in result.stderr:
            fail(f"invalid command stderr missing {needle!r}: {args}: {result.stderr!r}")


def main() -> None:
    if not os.access(BIN, os.X_OK):
        fail(f"binary not executable: {BIN} (run lake build first)")

    listing = run("list")
    if listing.returncode != 0:
        fail(f"list failed: {listing.stderr}")
    lines = [line for line in listing.stdout.splitlines() if line.strip()]
    if len(lines) != 60:
        fail(f"list returned {len(lines)} lines, expected 60")

    for index in range(60):
        name = parse_input_name(index)
        check_report(index, name)

    # Boundary names are also checked explicitly so a broken `list` cannot hide them.
    for index, name in ((0, "甲子"), (59, "癸亥")):
        if parse_input_name(index) != name:
            fail(f"cycle {index} is not {name}")
    check_invalid()
    print(f"ok: 60/60 inputs, text + JSON + anstar consistency, invalid-input rejection (binary {BIN})")


if __name__ == "__main__":
    main()
