# Lesson 04 — CGO 集成

目标
- 理解 FrankenPHP 中的 CGO 集成原理
- 通过一个最小的示例掌握 Go 与 C 的双向调用（Go 调用 C）

前置条件
- 已完成第 1-3 课的环境准备（包含 `go` 与本仓库的依赖）
- 本地已安装 Go 工具链（`go` 命令可用）

内容
- `demo/`：最小 CGO 示例，演示 Go 调用 C 并读取 C 返回的字符串。
- `run_demo.sh`：一键构建并运行 demo。可在容器或本地直接执行。
 - `demo/`：最小 CGO 示例，演示 C -> Go 批量注册回调以及扩展示例展示 Go <-> C 的字符串传递与内存所有权。
 - `run_demo.sh`：一键构建并运行 demo（包含扩展示例）。
 - `docs/CGO_INTEGRATION.md`：课程所依赖的项目级集成说明（建议先读该文档）。

运行步骤
1. 进入仓库根目录。
2. 运行脚本：

```bash
./docs/LESSONS/lesson-04-cgo/run_demo.sh
```

预期输出

- 初始示例输出：

	Demo: C -> Go bulk registration (kv array)
	[Go callback] REMOTE_ADDR = 127.0.0.1
	[Go callback] REQUEST_URI = /index.php
	[Go callback] HOST = example.local

- 扩展示例输出（内存所有权示例）：

	C allocated: allocated from C

这表示：
- C 端构建了一个 kv 数组并调用 Go 回调，Go 成功遍历并读取字符串。
- 扩展示例显示 C 分配内存后返回给 Go，Go 读取字符串后负责释放该内存（示例中通过 `C.free`）。

扩展阅读
- `docs/CGO_INTEGRATION.md`：项目级 CGO 集成说明。
- `frankenphp/cgo.go`、`frankenphp/frankenphp.c`：FrankenPHP 的实际集成代码示例。

内存与所有权注意事项

- 当 C 分配内存（`malloc` / 返回指针）并传回 Go 时，Go 需要调用 `C.free(unsafe.Pointer(ptr))` 以避免内存泄露。
- 使用 `C.GoString` 将 C 字符串复制为 Go 字符串；复制后的 Go 字符串独立于原始 C 内存，但原始 C 内存仍需按分配方释放。
- 对于批量数据（数组、结构体），在 C 中构建并通过指针传给 Go，可以减少 cgo 边界往返，但要确保生命周期在回调期间保持有效。

示例练习

1. 在 `docs/LESSONS/lesson-04-cgo/demo` 中运行：

```bash
./docs/LESSONS/lesson-04-cgo/run_demo.sh
```

2. 修改 `demo/main.go`，将批量数组长度扩展到 100 项并观察性能（注意：示例仅用于学习，非基准测试）。

3. 实现一个 C 回调函数，接收来自 Go 的函数指针并在 C 中调用（高级练习：注意 CGO 的回调约束）。
