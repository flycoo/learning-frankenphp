文件位置：`docs/LESSONS/lesson-02-debugging/README.md`（已创建）。

Lesson-specific Caddyfile

 - Path: `docs/LESSONS/lesson-02-debugging/Caddyfile` (this Caddyfile sets the document root to the lesson directory so PHP scripts placed there will be served).

Running this lesson

 - Run FrankenPHP (normal):

```bash
# from workspace root
./frankenphp/caddy/frankenphp/frankenphp run --config docs/LESSONS/lesson-02-debugging/Caddyfile &
```

 - Run FrankenPHP under Delve (headless) for debugging:

```bash
dlv exec ./frankenphp/caddy/frankenphp/frankenphp --headless --listen=:2345 --api-version=2 -- run --config docs/LESSONS/lesson-02-debugging/Caddyfile &
# Then attach from VS Code using the "Attach to frankenphp (Delve)" launch configuration.
```

Place PHP scripts for the lesson in the lesson directory. Example:

```bash
cp frankenphp/testdata/phpinfo.php docs/LESSONS/lesson-02-debugging/phpinfo.php
cp frankenphp/testdata/_executor.php docs/LESSONS/lesson-02-debugging/_executor.php
curl -sS http://127.0.0.1:80/phpinfo.php | head -n 20
```

Notes

 - Because the Caddyfile `root` is the lesson directory, any PHP file you add under `docs/LESSONS/lesson-02-debugging/` will be served directly by this lesson configuration.
 - Use the provided VS Code attach configuration to connect to Delve on port `2345`.
# Lesson 02 — 调试 FrankenPHP（VS Code + Delve）

目标
- 在本地使用 VS Code + Delve 调试 FrankenPHP 的 Go 代码（例如 `Init`、worker 调度、线程切换）。

前置条件
- 已完成第1课（环境与示例），能本地启动 `frankenphp`（参见 `docs/LESSONS/lesson-01-environment/README.md`）。
- 已安装 `dlv`（Delve）并能从命令行执行。Go 開發环境配置完成。

快速步骤（推荐）
1. 在 `frankenphp` 目录构建可调试的二进制（或使用 `dlv debug` 直接运行）：

```bash
# 使用已配置的 task（或手动）
(cd frankenphp/caddy/frankenphp && go build -tags watcher,brotli,nobadger,nomysql,nopgx -o frankenphp .)

# 启动可被调试器附加的进程（示例：在 2345 端口上以 headless 模式启动 Delve）
cd frankenphp/testdata
"$(pwd -P)/../caddy/frankenphp/frankenphp" # optional: run directly if not using dlv

# 或使用 dlv exec（在项目根运行）
dlv exec ./frankenphp/caddy/frankenphp/frankenphp --headless --listen=:2345 --api-version=2 -- run --config frankenphp/testdata/Caddyfile
```

2. 在 VS Code 中添加或使用已有的 launch 配置（位于 `.vscode/launch.json`），示例：

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Attach to frankenphp (Delve)",
      "type": "go",
      "request": "attach",
      "mode": "remote",
      "remotePath": "",
      "port": 2345,
      "host": "127.0.0.1"
    }
  ]
}
```

3. 常用断点位置（建议先在这些位置放断点）
- `frankenphp/frankenphp.go`: `Init`、`ServeHTTP`、CGO 导出的回调（如 `go_ub_write`、`go_write_headers`）。
- `frankenphp/worker.go`: `initWorkers`、`worker.handleRequest`、`drainWorkerThreads`。
- `frankenphp/phpthread.go` / `frankenphp/threadworker.go`：线程生命周期与状态转换处。

调试提示与注意事项
- 如果你使用 `dlv exec` 或 `dlv debug`，Delve 会在启动时构建或执行二进制；确保 `CGO_CFLAGS`/`CGO_LDFLAGS` 环境变量可访问到 PHP 头文件和库（如果需要手工设置）。
- 当调试涉及 CGO 与 PHP 内部（C 代码）时，Go 层断点仍然有效，但要理解线程切换发生在 Go 管理的 `phpThread` 上。可在 `frankenphp` 的 `go_ub_write` 等回调处观察 PHP 层输出。
- 在高并发场景下，线程会频繁切换；为简化调试，先将 `opt.numThreads` 设置为较小值（例如 2）以减小并发噪声。

示例：一键启动并附加（命令行）

```bash
# 启动 frankenphp via dlv (headless)
dlv exec ./frankenphp/caddy/frankenphp/frankenphp --headless --listen=:2345 --api-version=2 -- run --config frankenphp/testdata/Caddyfile &

# 在 VS Code 使用上面的 Attach 配置连接到 :2345
```

调试练习（课程任务示例）
- 在 `Init` 内部设置断点，启动并观察 worker/thread 数量、日志与 hooks 执行顺序。
- 在 `worker.handleRequest` 中设置断点，发起并发请求（并使用 `scaleChan` 触发扩缩容），观察请求被分配到线程的过程。

文件位置：`docs/LESSONS/lesson-02-debugging/README.md`（已创建）。



# 快速运行演示（普通模式）
cd /workspaces/gophp/docs/LESSONS/lesson-02-debugging
./run_demo.sh

# 或者单独使用调试模式
./stop_frankenphp.sh
./start_frankenphp_debug.sh  # 然后从 VS Code 附加调试器