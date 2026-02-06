示例模块：`demo-pkg`

模块路径（远程导入示例）:

```
github.com/flycoo/learning-frankenphp/docs/LESSONS/lesson-04-cgo/demo-pkg
```

包含：
- `lib`：可被导入的包，导出函数 `Hello(name string) string`。
- `example`：示例程序，演示如何导入并使用 `lib`。

本地运行示例：

```bash
cd docs/LESSONS/lesson-04-cgo/demo-pkg
go mod tidy
go run ./example
```

远程导入（其他项目）示例：

```go
import "github.com/flycoo/learning-frankenphp/docs/LESSONS/lesson-04-cgo/demo-pkg/lib"

fmt.Println(lib.Hello("Alice"))
```

如需我把该模块推到远程仓库并创建 tag，我可以继续帮你完成。

发布模块与包（概念与操作）

1) 概念要点
- **模块（module）**：由 `go.mod` 定义，表示一组包的集合；模块路径写在 `go.mod` 的 `module` 行中，例如 `github.com/youruser/yourrepo` 或子路径 `.../demo-pkg`。Go 通过模块路径 + 版本（git tag）来定位代码。
- **包（package）**：按目录组织；只有非 `main` 的包可以被其他程序 `import` 使用。`package main` 用于生成可执行文件，不能被 `import`。
- **发布（publish）**：通常是把代码推到远程 Git 仓库并创建 Git tag（语义化版本，如 `v0.1.0`），Go 工具会基于 tag 和模块路径下载指定版本。

2) 能否发布模块 vs 包？
- 你发布的是仓库/模块（包含多个包），不是单独“发布包”。当你打 tag 发布时，Go 会把该提交视为模块的一个版本；模块中包含的可导入包就能被其它项目通过 `import` 使用。

3) 简要操作步骤（示例）

- 在本地准备模块（以本目录为例）：
```bash
cd docs/LESSONS/lesson-04-cgo/demo-pkg
# 确保 go.mod 的 module 行为仓库可访问路径，例如：
# module github.com/youruser/yourrepo/docs/LESSONS/lesson-04-cgo/demo-pkg
go mod tidy
```

- 推送到远程并打 tag：
```bash
git add .
git commit -m "demo: publish demo-pkg"
git push origin main
git tag v0.1.0
git push origin v0.1.0
```

- 在其他项目中使用（按包路径导入）：
```go
import "github.com/youruser/yourrepo/docs/LESSONS/lesson-04-cgo/demo-pkg/lib"
```
然后运行：
```bash
go get github.com/youruser/yourrepo/docs/LESSONS/lesson-04-cgo/demo-pkg@v0.1.0
go mod tidy
```

4) 私有仓库与访问控制
- 对于私有仓库，设置 `GOPRIVATE`，并确保 CI/本地有正确的 Git 认证（SSH key 或 HTTPS token）：
```bash
export GOPRIVATE=github.com/youruser/*
```
如果使用私有代理或私有 registry，请按相应文档配置。

5) 版本与重大版本（v2+）注意事项
- 如果模块达到 v2 及以上，模块路径需要包含 `/v2`（例如 `github.com/youruser/repo/v2`），且标签也应是 `v2.x.x`。详见 Go Modules 版本语义规则。

6) 实务建议
- 若你想让仓库既包含示例可执行程序又提供可导入库，建议把可复用代码放在 `pkg/` 或 `lib/` 目录下（非 `main`），并在 `README` 中给出示例导入路径与版本号。
- 在发布前用 `go mod tidy`、`go test ./...`（如有测试）验证模块健康。

我可以替你把 `go.mod` 的模块路径改为最终的远程路径并创建 `v0.1.0` 标签，或者把 `lib` 移到 `pkg/` 并调整导入示例；你想要哪个选项？
