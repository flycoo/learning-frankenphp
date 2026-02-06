本目录包含两个独立的 CGO 示例二进制：

- `bulk`：演示 C -> Go 的批量回调（kv 数组）。
- `ext`：演示 C 分配内存并返回给 Go（由 Go 释放）。

运行方法：

在仓库中运行单个示例（无需先编译）：
```bash
cd docs/LESSONS/lesson-04-cgo/demo
go run ./bulk
go run ./ext
```

使用构建脚本（构建并运行两个二进制）：
```bash
cd docs/LESSONS/lesson-04-cgo/demo
./build.sh
```

关于 `module demo` 与 `package main` 的说明（简洁）

- **为什么不需要改 `module demo`：** 模块名（`module demo`）只是模块路径/标识符，用于本地开发与依赖解析；只要不需要发布到远程仓库（或作为可被其它模块导入的公共路径），本地使用任意合理名称是可以的。仓库通过 `go.work` 将多个模块/目录组合在一起进行开发，模块名不会在本地产生冲突。
- **为什么同一模块下有两个 `package main` 不冲突：** Go 的“包”和“可执行程序”是按目录组织的。每个目录可以是一个独立的包；当目录内使用 `package main` 时，编译该目录会生成一个独立的可执行文件。模块内可以包含多个目录（每个目录可以是 `package main`），它们会生成不同的二进制文件，因此互不冲突。

如果你希望把模块名改为更具语义或包含仓库地址（例如 `github.com/your/repo/demo`），我可以帮你改并更新 `go.work`，但本地学习/演示场景下不是必须的。

发布与远程导入（详细步骤）

- 核心概念：
	- `module` 行应设置为可被访问的仓库路径，例如 `github.com/youruser/gophp-demo`。
	- 只有非 `main` 的包可以被其他模块 `import`。将复用逻辑放在普通包（例如 `pkg/`）下。
	- 使用 Git tag（语义化版本，如 `v0.1.0`）发布版本。

- 示例操作流程：
	1. 选择模块路径并修改 `go.mod`：

```bash
cd docs/LESSONS/lesson-04-cgo/demo
# 编辑 go.mod，将 module demo 改为你的远程路径，例如：
# module github.com/youruser/gophp-demo
sed -i 's|module demo|module github.com/youruser/gophp-demo|g' go.mod
go mod tidy
git add go.mod go.sum
git commit -m "set module path to github.com/youruser/gophp-demo"
```

	2. 在远程创建仓库并推送：

```bash
git remote add origin git@github.com:youruser/gophp-demo.git
git push -u origin main
```

	3. 打 tag 发布版本并推送 tag：

```bash
git tag v0.1.0
git push origin v0.1.0
```

	4. 在其它项目中导入使用（假设你把复用代码放在 `pkg/mylib`）：

```go
import "github.com/youruser/gophp-demo/pkg/mylib"
```

然后在命令行：

```bash
go get github.com/youruser/gophp-demo@v0.1.0
go mod tidy
```

- 私有仓库提示：
	- 设置 `GOPRIVATE` 环境变量，例如：
		```bash
		export GOPRIVATE=github.com/youruser/*
		```
	- 确保本地/CI 有权限访问私有仓库（SSH key 或 HTTPS token）。

- 关于 v2+ 模块：
	- 若发布 `v2` 或更高版本，模块路径需包含 `/v2`，例如 `github.com/youruser/gophp-demo/v2`，并用 `v2.x.x` 标签。

如需我替你把模块名改为远程路径并把可复用代码抽到 `pkg/`，我可以完成并测试推送步骤。
