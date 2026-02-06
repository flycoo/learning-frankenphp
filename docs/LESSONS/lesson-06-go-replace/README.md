# Lesson 06 — 演示 `go.mod` 中的 `replace` 指令

### 什么是 `replace`？
`replace` 是 `go.mod` 文件中的一条指令，用于将一个模块路径（及其版本）替换为另一个路径（通常是本地路径或另一个代码仓库）。

### 与 `go.work` 的区别
- **`go.work`**：用于**本地开发环境**。它不会改变 `go.mod`，适合同时在多个本地仓库穿梭开发。它通常不会被提交到 Git。
- **`replace`**：定义在 **`go.mod`** 中。它是项目配置的一部分，**必须提交到 Git**。它会强制所有构建该项目的人使用指定的替换路径。

### 场景示例：修复依赖库的 Bug
假设你依赖一个库 `example.com/localdep`，但它有个 Bug。在等待作者修复并发布新版本之前，你可以在本地克隆它，修复后通过 `replace` 强制你的项目使用修复后的本地版本。

### Demo 结构
- `localdep-patch/`：修复了 Bug 的本地版本。
- `consumer/`：通过 `replace` 引用本地修复版本的项目。

### 验证步骤
1. 进入目录：`cd docs/LESSONS/lesson-06-go-replace/consumer`
2. 运行程序：`go run .`
3. 观察输出：应该看到 `Hello from PATCHED localdep!`。

### 关键代码 (consumer/go.mod)
```go
module example.com/consumer

go 1.25

require example.com/localdep v1.0.0

replace example.com/localdep v1.0.0 => ../localdep-patch
```
