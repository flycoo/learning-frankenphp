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
