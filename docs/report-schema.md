# v0.4 解释报告 schema（`ziwei.explain`）

本文件描述 `lean4-occult ziwei explain <天干> <地支> [--json]` 的输出。
JSON 只是**输出格式**，不是可独立复核的证书；本版没有实现外部 JSON 证书
检查器（`guarantees.externalCertificateChecker = false`）。

* 文字模板：`ZiWei.Explain.renderReport`
* JSON 构造：`ZiWei.Explain.reportJson` / `renderJson`
* 结构化健全性：`ZiWei.Explain.buildReport_correct`
* 示例：`docs/examples/explain-jiazi.json`、`docs/examples/explain-jiazi.txt`
* 穷举一致性测试：`scripts/test_json.py`（标准库 Python 3，不依赖第三方包）

## 1. 调用与退出行为

```
lean4-occult ziwei explain <天干> <地支>
lean4-occult ziwei explain <天干> <地支> --json
```

* 只接受两个干支参数；`--json` 可选，且**只能出现一次、只能放在最后**。
* 拒绝未知 flag、重复 `--json`、缺参和多参，退出码 1，错误写 stderr。
* 天干/地支必须是六十甲子中的同阴阳组合；否则退出码 1。
* 文本模式在 stdout 输出固定模板。
* JSON 模式在 stdout 输出**单个** JSON 对象（无前缀、无日志）；错误仍只写 stderr。

## 2. 顶层字段

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `schemaVersion` | string | 固定为 `"0.4.0"` |
| `reportKind` | string | 固定为 `"ziwei.explain"` |
| `input` | object | 已校验的六十甲子输入 |
| `rules` | array | 规则编号、类别、陈述与来源引用 |
| `stars` | array | 四颗星的支名 + 0–11 位置 |
| `derivations` | array | 每颗星的输入前提、规则、结论 |
| `facts` | array | 六组两两位置关系 |
| `guarantees` | object | 已验证范围、人工信任边界、证书状态 |

## 3. `input`

```json
{
  "jiazi": "甲子",
  "index": 0,
  "stem": "甲",
  "branch": "子",
  "stemIndex": 0,
  "branchIndex": 0,
  "polarity": "yang"
}
```

* `index` 是六十甲子索引（0–59）。
* `stemIndex` / `branchIndex` 是 `docs/conventions.md` 的编号。
* `polarity` 是 `yang` / `yin`；输入已通过同阴阳校验。

## 4. `rules`

每条规则：

```json
{
  "id": "ZW-LUCUN-STEM",
  "kind": "source-supported",
  "statement": "……",
  "sources": []
}
```

* `id` 是稳定代码，不随显示文字变化。完整清单见 `docs/sources.md` §6。
* `kind` 三选一：
  * `source-supported`：来源支持（必须带非空 `sources`）；
  * `project-convention`：项目编号/输入约定；
  * `mathematical-consequence`：由位置与规则推出的数学分类。
* `sources` 每项字段：`sourceId`、`title`、`locator`、`version`、`url`、
  `accessed`、`quote`。来源只支持“该版本这样写”，不支持吉凶或经验有效性。

## 5. `stars` 与 `derivations`

```json
{"star": "禄存", "ruleId": "ZW-LUCUN-STEM", "branch": "寅", "position": 2}
```

```json
{
  "star": "擎羊",
  "ruleId": "ZW-QINGYANG-AFTER-LUCUN",
  "premises": ["生年干 甲（0）", "中间事实：禄存位于 寅 (2)"],
  "conclusion": {"branch": "卯", "position": 3}
}
```

* 禄存前提是生年干；擎羊/陀罗前提额外包含“禄存位置”这一中间事实；
  天马前提是生年支。
* 四颗星固定顺序：禄存、擎羊、陀罗、天马。
* `position` 是 0–11；`branch` 是同一位置的十二支名（子 0、…、亥 11）。
* 这些值直接来自既有函数 `ZiWei.MinorStar.placeJiaZi`，不在报告层重写规则。
* 证明：`buildReport_star_positions` 说明每个 `stars` 位置等于计算函数结果。

## 6. `facts` 与关系语义

六组无序星对固定为：

1. 禄存 / 擎羊
2. 禄存 / 陀罗
3. 禄存 / 天马
4. 擎羊 / 陀罗
5. 擎羊 / 天马
6. 陀罗 / 天马

每条：

```json
{
  "left": "禄存",
  "right": "擎羊",
  "kind": "adjacent-palace",
  "label": "相邻（偏移 ±1）",
  "leftPosition": 2,
  "rightPosition": 3
}
```

`kind` 是**有限位置事实**，按固定优先级分类（不是吉凶解释）：

| 优先级 | `kind` | 实际命题 |
| --- | --- | --- |
| 1 | `same-palace` | `p = q` |
| 2 | `opposite-palace` | `p = q + 6 (mod 12)` |
| 3 | `trine-palace` | `p = q + 4` 或 `p = q + 8 (mod 12)` |
| 4 | `adjacent-palace` | `p = q + 1` 或 `p = q - 1 (mod 12)` |
| 5 | `different-palace` | 其余 `p ≠ q` |

分类函数 `ZiWei.Explain.classify`；健全性 `classify_sound` 证明分类结果
对应的位置命题成立。证明只说明“按这些位置会得到什么”，不说明传统吉凶含义。

## 7. `guarantees`

| 字段 | 含义 |
| --- | --- |
| `verifiedStructuredLayer` | 已验证的字段范围：输入、四星位置、六组关系、规则/来源引用 |
| `soundnessTheorem` | `Occult.ZiWei.Explain.buildReport_correct` |
| `scope` | 仅有限位置事实，不含吉凶/传统解释 |
| `sourceTranscription` | 来源转录与短引文的人工信任边界 |
| `versionCollation` | 本库不声称完成版本校勘 |
| `externalCertificateChecker` | 固定 `false` |
| `certificateNote` | JSON 是输出，不是可独立复核的证书 |

## 8. 已验证层与人工信任边界

**Lean 已验证（结构化层）**

* 报告输入就是 CLI 解析出的 `JiaZi`。
* 四颗星位置等于 `MinorStar.placeJiaZi` 的结果。
* 六组关系类别满足 `RelationKind.holds`。
* 报告覆盖全部四星与全部稳定规则编号，规则记录等于稳定编号展开结果
  （来源字段未被替换）。

这些由 `buildReport_correct` 统一陈述；`Tests.lean` 还检查具体样例与
JSON 转义边界。

**人工仍需核对（来源层）**

* 来源转录是否忠实于所标版本、短引文是否抄录正确、异体/讹字读法是否合理。
* 本版没有实现从任意 JSON 重新验证的证书检查器；不要把它当作独立证书。
* `scripts/test_json.py` 做的是 60 种输入的 CLI/JSON 结构与计算一致性测试；
  它**不是** Lean 证明，也不替代来源核对。

## 9. 测试依赖

* `lake build`：Lean 类型检查与 `Tests.lean` 回归。
* `./scripts/smoke.sh`：CLI 正负例（含 `explain`）。
* `python3 scripts/test_json.py`：仅用 Python 标准库，穷举 60 个输入，
  比较文本、JSON、`ziwei anstar` 结果与独立关系分类。
* `./scripts/check_hygiene.sh`：禁用关键字、自定义公理与 `#print axioms` 白名单。
