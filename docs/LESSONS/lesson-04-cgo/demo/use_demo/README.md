示例 `use_demo`：引用 `demo-pkg` 的例子

运行：

```bash
cd docs/LESSONS/lesson-04-cgo/demo/use_demo
go mod tidy
go run .
```

该示例演示如何在本仓库内或远程项目中导入：

```go
import "github.com/flycoo/learning-frankenphp/docs/LESSONS/lesson-04-cgo/demo-pkg/lib"
```
