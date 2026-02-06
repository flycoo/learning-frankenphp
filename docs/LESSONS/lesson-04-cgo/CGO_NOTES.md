# 判断二进制是否包含 cgo 依赖 / 如何构建静态二进制

检查二进制依赖（快速命令）：

```sh
ldd ./your-binary    # Linux
otool -L ./your-binary  # macOS
```

- 如果 `ldd` 列出 `.so`，说明二进制依赖共享库（运行时需要这些库）；若输出为 "not a dynamic executable" 则可能是静态链接。

如何构建静态二进制（要点与示例）：

- 静态链接要求所有依赖（包括 libc）都有静态版本（`.a`）。在 Linux 上常见做法是使用 musl 或在专门的静态构建环境中完成。

示例：尝试静态链接（仅在有静态库可用时有效）

```sh
CGO_ENABLED=1 go build -ldflags '-extldflags "-static"' -o app-static .
```

在 musl 环境或交叉构建链中的示例：

```sh
CGO_ENABLED=1 CC=x86_64-linux-musl-gcc go build -ldflags '-extldflags "-static"' -o app-musl .
```

- 如果不需要 cgo，可以禁用：

```sh
CGO_ENABLED=0 go build -o app-pure-go .
```

常见注意事项：

- cgo 会把工程内的 C 源编译并链接进可执行文件；对外部库而言，静态库会被包含进二进制，动态库仅在运行时需要存在。 
- 运行时动态加载（`dlopen`）不会在链接期打包库，需在运行环境中可用。 
- 使用 `go build -x` 或 `DEBUG_BUILD=1` 可查看底层链接器（gcc/ld）调用，帮助判断链接细节。

工具：
- `ldd ./binary`：查看 Linux 上的共享库依赖。
- `otool -L ./binary`：macOS 上查看依赖。
- `readelf -d ./binary`：查看 ELF 动态段（高级检查）。

简短结论：

- 是否“打包”取决于你如何链接：静态链接会把 C 代码/库包含进二进制，动态链接则依赖运行时共享库。完整静态可执行体通常需专门的构建环境与静态依赖。
