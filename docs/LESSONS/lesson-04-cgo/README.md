# Lesson 04 — CGO 集成

目标

学习任务清单

下面的清单按学习顺序组织，配套脚本位于 `docs/LESSONS/lesson-04-cgo/scripts/`，可直接运行练习：

1. 运行并理解 demo（输出、内存所有权、回调）：

```sh
./docs/LESSONS/lesson-04-cgo/scripts/run_all_demos.sh
```

2. 为某个小模块添加单元测试并运行测试（练习 `go test`）：

```sh
./docs/LESSONS/lesson-04-cgo/scripts/run_tests.sh
```

3. 使用 race detector 运行测试，检测并发问题：

```sh
./docs/LESSONS/lesson-04-cgo/scripts/run_race.sh
```

4. 使用 pprof 做性能分析（说明脚本会展示推荐步骤）：

```sh
./docs/LESSONS/lesson-04-cgo/scripts/pprof_instructions.sh
```

说明：这些脚本都在课程目录下，目的是让你能一步运行练习并观察结果。脚本会在各自子目录执行已存在的 `build.sh`（构建并运行示例），或运行 `go test`。如果你想我把某个练习做成 CI 步骤或添加示例测试用例，我也可以帮忙。

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
 - `demo_cfile/`：将 C 代码放在单独 `.c/.h` 文件中的示例（`c_code.c` + `c_code.h`）。
 - `demo_move_flags/`：将 cgo 注释放在 `cgo_flags.go` 的示例（`import "C"` 与 `//export` 在同一文件）。
 - `demo_move_flags_split/`：将 cgo 注释放在 `cgo_flags.go`，并把 `main()` 保留在单独 `main.go` 的示例（通过包装函数暴露 C 功能给主程序）。
 - 每个示例目录下包含 `build.sh`：运行该脚本可在该示例目录构建可执行文件。
 - `docs/CGO_INTEGRATION.md`：课程所依赖的项目级集成说明（建议先读该文档）。

运行步骤
1. 进入仓库根目录。
2. 运行脚本：

```bash
./docs/LESSONS/lesson-04-cgo/run_demo.sh
```

单独示例构建

- 使用各示例目录下的构建脚本：

```bash
./docs/LESSONS/lesson-04-cgo/demo/build.sh
./docs/LESSONS/lesson-04-cgo/demo_cfile/build.sh
./docs/LESSONS/lesson-04-cgo/demo_move_flags/build.sh
./docs/LESSONS/lesson-04-cgo/demo_move_flags_split/build.sh
```

构建脚本会在对应目录输出一个同名二进制（例如 `demo_move_flags_split/demo_move_flags_split`），然后可直接运行该二进制。

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

调试 CGO 构建（可选）

- 为了查看 cgo 在后台如何编译和链接 C 代码，`run_demo.sh` 提供了两种辅助模式：
	- `debug` 或环境变量 `DEBUG_BUILD=1`：使用 `go run -x`，打印底层 gcc/ld 调用。示例：

	```bash
	./docs/LESSONS/lesson-04-cgo/run_demo.sh debug
	# 或
	DEBUG_BUILD=1 ./docs/LESSONS/lesson-04-cgo/run_demo.sh
	```

	- `WORK=1`：先运行 `go build -work`，Go 会输出临时工作目录路径，目录中包含 cgo 生成的 C 源与对象文件，方便进一步检查：

	```bash
	WORK=1 ./docs/LESSONS/lesson-04-cgo/run_demo.sh
	```

	- 组合使用：

	```bash
	DEBUG_BUILD=1 WORK=1 ./docs/LESSONS/lesson-04-cgo/run_demo.sh
	```

- 说明：
	- `go run`/`go build` 会自动触发 cgo：生成 `_cgo_*` 文件、调用系统 C 编译器（`gcc`/`clang`）来编译这些 C 片段，最后由 Go 链接器将产物链接为可执行文件。
	- 如果需要传递额外的 CFLAGS 或链接选项，可以通过 `// #cgo` 指令、或环境变量 `CGO_CFLAGS` / `CGO_LDFLAGS` 来设置。
	- 确保系统安装了 C 编译器（`gcc` 或 `clang`），并且 `CGO_ENABLED` 为 `1`（通常本地构建默认启用）。

示例调试输出（部分）将包含 `gcc` 或 `ld` 被调用的行、以及 `WORK=/tmp/go-build...` 提示，指示临时构建目录位置。


练习与保持记忆的低成本做法

下面几条是低成本、易坚持的练习方法，适合长期保持对 Go / cgo 知识的记忆：

- **每天短练（10–15 分钟）**：运行一个 demo、读一小段代码或改一个小参数，保持连续性比一次学大量内容更有效。
- **写速查表/备忘（Cheatsheet）**：把常用命令、cgo 注意点和内存管理要点放到 `CHEATSHEET.md`，遇到问题先查表。
- **周任务（每周一件）**：每周给 demo 增加一点功能（加测试、加 pprof、改接口），用小目标保持进步。
- **自动化脚本降低门槛**：把常用命令写成脚本（已提供 `scripts/`），让运行示例变得简单，鼓励你频繁复现。
- **写笔记或教别人**：用一句话总结你学到的知识或写短文，这能显著加深记忆。
- **使用闪卡/间隔重复（Anki）**：把容易忘的细节做成卡片，利用间隔重复长期记忆。
- **准备样板/模板**：把常用的 cgo 模板、构建脚本和测试样例存起来，下次直接复用节省记忆成本。

所有这些资源和脚本都在课程目录下：查看 `CHEATSHEET.md` 和 `scripts/`，把 `scripts/practice.sh` 加入你的日常练习计划能快速提高保持率.
