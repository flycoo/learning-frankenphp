# CGO & Go 快速备忘（Cheatsheet）

常用命令

- 构建并运行当前目录程序：

```sh
go build -o app .
./app
```

- 运行包含 cgo 的程序（需要系统安装 C 编译器）：

```sh
go run .
```

- 禁用 cgo（纯 Go 构建）：

```sh
CGO_ENABLED=0 go build -o app-pure-go .
```

- 查看二进制的共享库依赖（Linux/macOS）：

```sh
ldd ./your-binary    # Linux
otool -L ./your-binary  # macOS
```

常见 cgo 注意点

- cgo 注释块必须在 `import "C"` 之前：

```go
/*
#cgo CFLAGS: -I.
#include "c_code.h"
*/
import "C"
```

- 把 cgo 指令放在单独文件（例如 `cgo_flags.go`）可以让其它 Go 文件不需要 `import "C"` 就调用包装好的函数，但 `//export` 的导出函数必须与 `import "C"` 在同一文件中。

- 内存与所有权：
  - 如果 C 分配了内存（`malloc`），Go 收到指针后需要调用 `C.free(unsafe.Pointer(p))`；使用 `C.GoString` 会复制字符串。  
  - 优先在 C 端构建复杂数据结构并一次性传给 Go 以减少 cgo 边界次数。

- cgo 指令：
  - `#cgo CFLAGS: -I/path`  # 头文件搜索路径
  - `#cgo LDFLAGS: -L/path -lmylib`  # 链接器选项

构建静态二进制（提示）

- 若要尽可能静态链接，需静态版本的所有依赖（`.a`），并传给链接器 `-static`：

```sh
CGO_ENABLED=1 go build -ldflags '-extldflags "-static"' -o app-static .
```

- 推荐使用 musl 静态工具链（例如 `CC=x86_64-linux-musl-gcc`），因为对 glibc 完全静态链接兼容性较差。

调试与分析速查

- 打开 cgo 的构建细节：

```sh
DEBUG_BUILD=1 go build -x .
```

- 使用 race detector：

```sh
CGO_ENABLED=1 go test -race ./...
```

- 使用 pprof：查看 `docs/LESSONS/lesson-04-cgo/scripts/pprof_instructions.sh`。

简短建议

- 把复杂 C 逻辑封装在 C 文件里，Go 侧写薄薄的 wrapper；把 `import "C"` 与 `//export` 放在一起。  
- 把常用构建/运行命令写成脚本，降低复现门槛，便于频繁练习。
