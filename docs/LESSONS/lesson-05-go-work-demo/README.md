# Lesson 05 — 演示 `go.work` 的本地模块解析

目的：通过两个简单的 demo 演示 Go 在有/无 `go.work` 时如何解析同一个依赖（本地模块 vs 远程模块）。

目录结构：
- `localdep/`：本地模块，模块路径为 `example.com/localdep`，导出 `Hello()`。
- `consumer/`：消费模块，依赖 `example.com/localdep` 并调用 `Hello()`。
- `go.work`：用于演示“有 `go.work`”的场景（会把 `./localdep` 作为 workspace 模块）。
- `run-without-work.sh`：演示在禁用 `go.work`（`GOWORK=off`）情况下的行为。
- `run-with-work.sh`：演示启用本目录 `go.work` 后的行为。

如何运行：

1. 无 `go.work`（等同于没有把本地模块加入 workspace）：

```bash
cd docs/LESSONS/lesson-05-go-work-demo
GOWORK=off go run ./consumer
```

预期：`go` 会尝试从远程（模块代理或仓库）获取 `example.com/localdep`，如果该模块未发布则会报错（无法找到）。

2. 有 `go.work`（把 `./localdep` 列入 workspace）：

```bash
cd docs/LESSONS/lesson-05-go-work-demo
go run ./consumer
```

预期：构建成功，输出 `Hello from localdep (local)` —— 因为 `go.work` 指定使用本地模块替代网络获取。

小结：这个 lesson 演示 `go.work` 可以把本地模块作为依赖来源，使得在未发布模块的情况下也能本地开发与构建。
