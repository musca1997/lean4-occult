# 工具链与构建记录（toolchain）

## 安装方式（用户级，无 sudo）

```bash
curl -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -o /tmp/elan-init.sh
sh /tmp/elan-init.sh -y --default-toolchain none
export PATH="$HOME/.elan/bin:$PATH"
elan default leanprover/lean4:v4.35.0
```

结果：

```
elan 4.2.4 (227caca13 2026-08-25)
Lean (version 4.35.0, x86_64-unknown-linux-gnu, commit eb6cafb7290e8bd5f2937522d8d804f58f02bafc, Release)
```

未修改 `/etc`、未使用 `sudo`、未改动系统 Nix 配置。所有文件位于
`~/.elan` 与项目目录。

## 依赖固定

* `lean-toolchain`：`leanprover/lean4:v4.35.0`
* `lakefile.toml`：`mathlib` `rev = "v4.35.0"`
* `lake-manifest.json` 由 `lake update` 生成，锁定所有传递依赖的 commit。

Mathlib 版本选择依据：`v4.35.0` 是上游**已存在的 tag**，其
`lean-toolchain` 内容正是 `leanprover/lean4:v4.35.0`，二者匹配。

## 缓存

```
$ lake update
...
Attempting to download 9031 file(s) from leanprover-community/mathlib4 cache
Downloaded: 9031 file(s) [attempted 9031/9031 = 100%]
Decompressed 9031 file(s)
```

未从源码完整编译 Mathlib（那将需要数小时）。

## 实际构建结果

```
$ lake build
Build completed successfully (6285 jobs).

$ ./scripts/smoke.sh
通过 29 项，失败 0 项

$ ./scripts/check_hygiene.sh
共 151 条待检查
==> 公理检查通过：只出现 propext、Classical.choice、Quot.sound
```

仅剩 Mathlib 的 module-system 风格警告（见 README 说明），无 error。

## 已知阻塞 / 未完成

* 无网络或工具链阻塞：elan、Lean、Mathlib 缓存均成功获取。
* 实现阶段只初始化 git；后续按用户授权提交并发布到公开 GitHub 仓库。
* CLI 的十进制解析使用自写的 `parseNat?`（只接受 ASCII 数字，不使用会 panic
  的 `String.toNat!`），已用 `cycle -1`、`cycle 1x`、`cycle ""` 实测拒绝。
* 发布采用 MIT License，见根目录 `LICENSE`。
* 传统文献引文核对未做，见 `docs/sources.md`。
