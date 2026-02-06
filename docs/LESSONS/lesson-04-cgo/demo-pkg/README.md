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
