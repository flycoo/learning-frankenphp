# Demo — 使用 `Option` 配置 `Init`

目的：给出一个最小示例，展示如何通过 `Option`/`WorkerOption` 配置并调用 `Init` 启动 FrankenPHP（仅示例，可能需在工作区模式下调整导入路径）。

快速说明：读取并参考 [frankenphp/options.go](frankenphp/options.go#L1-L400) 中的选项工厂函数。下面示例演示常见组合：上下文、线程数、worker、超时。

示例代码片段（非完整生产代码，只作示范）：

```go
package main

import (
    "context"
    "log"
    "time"

    "slog"

    "frankenphp"
)

func main() {
    // 示例：构建 Option 列表
    opts := []frankenphp.Option{
        frankenphp.WithContext(context.Background()),
        frankenphp.WithNumThreads(4),
        frankenphp.WithMaxThreads(8),
        frankenphp.WithMaxWaitTime(5 * time.Second),
        frankenphp.WithWorkers("worker-echo", "scripts/worker.php", 1, frankenphp.WithWorkerMaxThreads(2)),
        // 可选：传入自定义 logger（需创建 *slog.Logger）
        // frankenphp.WithLogger(myLogger),
    }

    if err := frankenphp.Init(opts...); err != nil {
        log.Fatalf("Init failed: %v", err)
    }
    defer frankenphp.Shutdown()

    // 真实程序此处会启动 HTTP 服务器或阻塞等待
    select {}
}
```

运行/验证：
- 将示例放在仓库内（例如 `docs/LESSONS/lesson-03-sourcewalkthrough/demo_main.go`），在支持 `go.work` 的环境下 `go run`。
- 构建或运行时可能需要先执行 `./docs/scripts/install_deps.sh` 以准备 PHP 头文件/依赖。

备注：此示例展示 `WithNumThreads`、`WithMaxThreads`、`WithWorkers` 等常见选项的用法；要在你的环境可运行，可能需要调整导入路径或使用项目的 `go.work` 配置。
