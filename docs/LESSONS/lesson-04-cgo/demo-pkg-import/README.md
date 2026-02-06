示例 `demo-pkg-import`：引用 `demo-pkg` 的例子（与以前的 `use_demo` 等价，已重命名）

运行：

```bash
cd docs/LESSONS/lesson-04-cgo/demo-pkg-import
go mod tidy
go run .
```

示例演示如何导入：

```go
import "github.com/flycoo/learning-frankenphp/docs/LESSONS/lesson-04-cgo/demo-pkg/lib"
```

运行补充说明

- `go run main` 报错的原因：`go run main` 会把 `main` 当作包的模式(package pattern)去查找一个名为 `main` 的包（在标准库或模块路径中），而不是当作文件名。因此如果没有匹配的包会出现类似的错误信息（例如："package main is not in std (/usr/local/go/src/main)"）。
- 正确的常用用法：
	- 运行当前目录下的 `package main`：
		```bash
		go run .
		```
	- 运行单个源文件：
		```bash
		go run main.go
		```
	- 运行多个源文件：
		```bash
		go run file1.go file2.go
		```

- 关于 `go.work`：当你在一个包含多个模块的工作区里开发，若某个模块不是 `go.work` 中列出的模块之一，运行会提示类似：

	"current directory outside modules listed in go.work or their selected dependencies"

	解决方法是将该模块加入工作区：
	```bash
	cd /path/to/repo
	go work use ./relative/path/to/module
	```

 之后就可以在工作区内直接用 `go run .` 或 `go run ./subdir` 运行该模块。

示例：
```bash
cd docs/LESSONS/lesson-04-cgo/demo-pkg-import
# 若报错提示未在 go.work 中，先运行：
go work use ../demo-pkg-import
go run .
```

短结论：通常推荐使用 `go run .`（运行当前目录的 `package main`），或用 `go run main.go` 明确指定文件，避免使用 `go run main` 这种容易被误解为包名的写法。
