# lean4-occult

用 Lean 4 形式化**阴阳、五行、十天干、十二地支、六十甲子**的有限组合结构，
并证明其基本性质（基数、编码往返、周期与最小正周期、同阴阳配对双射）。

> 本项目只处理**可精确定义的有限结构**。它不声称、也不检验任何传统术数体系
> 的经验有效性；`docs/sources.md` 明确列出哪些内容属于项目约定、哪些尚未核查。

## 状态

v0.1，可构建、可运行。工具链固定为 `leanprover/lean4:v4.35.0`，
Mathlib 固定为 `v4.35.0`。

## 快速开始

```bash
# 1. 安装用户级 elan（若尚未安装）
curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | sh -s -- -y --default-toolchain none
export PATH="$HOME/.elan/bin:$PATH"

# 2. 克隆项目并获取锁定版本依赖
git clone https://github.com/musca1997/lean4-occult.git
cd lean4-occult
lake exe cache get

# 3. 构建库、测试与 CLI
lake build

# 4. 运行 CLI
lake env lean4-occult cycle 0
lake env lean4-occult cycle 59
lake env lean4-occult pair 甲 子
lake env lean4-occult pair 甲 丑   # 退出码 1
lake env lean4-occult list
```

## CLI

```
lean4-occult cycle <n>          显示第 n 位（0–59）的甲子及下一步
lean4-occult pair <天干> <地支>  由干支查索引（要求同阴阳）
lean4-occult list               列出全部六十甲子
lean4-occult --help             帮助
```

约定：索引 0 = 甲子，索引 59 = 癸亥；索引 `n` 的天干序号是 `n % 10`，
地支序号是 `n % 12`。详见 `docs/conventions.md`。

非法输入一律退出码 1，并在 stderr 说明原因：

* `cycle 60`、`cycle -1`、`cycle abc`：越界或非十进制
* `pair 甲 丑`、`pair 乙 子`：阴阳不同，不属于六十甲子
* `pair 甲`、`pair 甲 子 丑`：参数个数不对
* `pair 子 甲`、`pair 甲 X`：未知天干/地支

## 库结构

| 文件 | 内容 |
| --- | --- |
| `Occult/YinYang.lean` | `YinYang`（阴/阳），对合 `neg`，奇偶解释 `ofParity` |
| `Occult/WuXing.lean` | `WuXing`（木火土金水），相生 `next`、相克 `overcomes` |
| `Occult/TianGan.lean` | `TianGan`（甲乙…癸），序号、阴阳、汉字解析 |
| `Occult/DiZhi.lean` | `DiZhi`（子丑…亥），序号、阴阳、汉字解析 |
| `Occult/JiaZi.lean` | `JiaZi`（同阴阳配对），`Fin 60` 等价，`next` 与周期定理 |
| `Occult/Cli.lean` | CLI 输入解析 `parseNat?`（可在测试中直接检查） |
| `Tests.lean` | 关键结论的 `example` 回归检查 |
| `Main.lean` | CLI |

## 主要定理

* `JiaZi.card_eq_sixty`：六十甲子恰有 60 个元素。
* `JiaZi.next_sixty`：`next^[60] z = z`（60 是一个周期）。
* `JiaZi.next_period_iff`：`next^[n] z = z ↔ 60 ∣ n`（**最小**正周期是 60）。
* `JiaZi.next_min_period`：任何 `0 < k < 60` 都不能让甲子回到自身。
* `JiaZi.sameParityEquiv` + `card_sameParity_pairs`：同阴阳的（天干, 地支）配对
  与六十甲子一一对应，共 60 个。
* `JiaZi.existsUnique_index`：每个同阴阳组合有唯一索引 `n < 60`。
* `WuXing.next_period_iff`：五行相生的最小正周期是 5。
* `YinYang.ofParity_eq_iff`：阴阳编码由奇偶性完全决定。

完整清单（84 条 theorem/lemma）见 `docs/scope.md`。

## 验证记录（本地实测）

环境：NixOS 25.11，Lean 4.35.0，Mathlib v4.35.0（缓存）。

```
$ lake build
Build completed successfully (6277 jobs).

$ .lake/build/bin/lean4-occult cycle 0
索引 0：甲子（甲阳，天干 0，地支 0），下一步 乙丑（索引 1）

$ .lake/build/bin/lean4-occult cycle 59
索引 59：癸亥（癸阴，天干 9，地支 11），下一步 甲子（索引 0）

$ .lake/build/bin/lean4-occult pair 甲 子
索引 0：甲子（甲阳，天干 0，地支 0），下一步 乙丑（索引 1）

$ .lake/build/bin/lean4-occult pair 甲 丑 ; echo $?
错误：甲丑 阴阳不同（甲 序号 0，丑 序号 1），不在六十甲子中
1

$ .lake/build/bin/lean4-occult cycle 60 ; echo $?
错误：cycle 的索引必须在 0–59 之间，收到 60
...
1

$ .lake/build/bin/lean4-occult cycle -1 ; echo $?
错误：cycle 需要非负十进制整数，收到 "-1"
...
1

$ .lake/build/bin/lean4-occult cycle 1x ; echo $?
错误：cycle 需要非负十进制整数，收到 "1x"
...
1

$ .lake/build/bin/lean4-occult list | wc -l
60

$ ./scripts/smoke.sh
...
通过 19 项，失败 0 项
```

公理检查：

```
$ lake env lean /tmp/Ax.lean     # #print axioms 关键定理
'Occult.JiaZi.card_eq_sixty' depends on axioms: [propext, Classical.choice, Quot.sound]
'Occult.WuXing.next_period_iff' depends on axioms: [propext, Quot.sound]
'Occult.YinYang.neg_injective' depends on axioms: [propext]
```

没有项目自定义 `axiom`，没有 `sorry`/`admit`/`native_decide`。

### 关于构建警告

Mathlib 4.35 会打印形如
`imports ... which is designed for use with the module system` 的警告。
本项目尝试过在文件顶部加 `module`，但会改变定理可见性并导致下游文件
无法引用（实测报 `Unknown identifier`），因此保留默认的非 module 模式。
这些只是风格提示，不影响证明与构建结果。

## 仓库状态

* 公开仓库：https://github.com/musca1997/lean4-occult
* 采用 MIT License。
* `.lake/` 已加入 `.gitignore`（构建产物约 7.6 GB，主要是 Mathlib 缓存）。

## 不做的事

规则引擎、紫微斗数、占星、出生排盘、UI 均不在 v0.1 范围内，
原因见 `docs/scope.md`。传统文献的原文核对也未完成，见 `docs/sources.md`。

## 许可证

[MIT License](LICENSE)。
