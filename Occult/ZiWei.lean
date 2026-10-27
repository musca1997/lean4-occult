/-
Occult/ZiWei.lean

紫微斗数 v0.2–v0.3 的聚合模块。

* v0.2：十二宫**纯位置结构**（抽象位置、旋转、三方四正、语义宫名偏移）。
* v0.3：来源明确的年干/年支小安星（禄存、擎羊、陀罗、天马），
  以及地支与位置的显式对接。

仍然不包含出生排盘、历法、四化、限运或吉凶判断。
-/

import Occult.ZiWei.Position
import Occult.ZiWei.Relations
import Occult.ZiWei.Properties
import Occult.ZiWei.Branch
import Occult.ZiWei.MinorStar
import Occult.ZiWei.Explain
