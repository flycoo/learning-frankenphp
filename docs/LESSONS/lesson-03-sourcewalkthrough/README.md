# Lesson 03 — `Init` Practice

目标：基于 `init_walkthrough.md` 做一次动手练习，理解 `Init` 的启动序列与关键决策点，并能在代码或文档中添加简洁注释以辅助调试器步进。

先决条件：已克隆仓库并在 dev 环境中（Linux）。推荐先运行依赖安装与构建任务。

快速开始命令：

```bash
./docs/scripts/install_deps.sh
(cd frankenphp/caddy/frankenphp && go build -tags watcher,brotli,nobadger,nomysql,nopgx -o frankenphp .)
```

练习步骤：
- 阅读：[init_walkthrough.md](docs/LESSONS/lesson-03-sourcewalkthrough/init_walkthrough.md)
- 完成练习：参见 `exercise.md` 并把你的答案写在本目录下的 `my_answers.md`（可选）
- 可选动手：在源码或文档中添加一处小注释并构建验证（参考 `frankenphp/frankenphp.go`）

预期结果：
- 能用简短句子回答 `Init` 中的关键步骤（见 `exercise.md`）
- 能在仓库中提交一个小补丁（或仅在本地）来增强注释
- 能本地构建 `frankenphp` 并观察启动日志包含 PHP 版本与线程信息

下一步：打开 `exercise.md` 开始练习。
# Lesson 03 — 源码逐层导读（主流程与线程模型）

目标
- 系统化理解请求从 HTTP 到 PHP 执行的主流程（入口 → 线程分配 → PHP 回调 → 响应）。
- 理解线程模型、Worker vs Regular 线程、扩缩容触发点与 hooks。

建议阅读顺序（按课时进度）
1. `frankenphp/frankenphp.go`：`Init`（初始化/线程分配/扩缩容/钩子）、`ServeHTTP`（请求入口）、CGO 导出回调（`go_ub_write`、`go_write_headers`、`go_read_post`）。
2. `frankenphp/phpmainthread.go` / `frankenphp/phpthread.go`：主线程与线程的创建、状态机与上下文存取方法。
3. `frankenphp/worker.go`：`initWorkers`、`worker.handleRequest`、队列与扩缩容交互（`scaleChan`）。
4. `frankenphp/cgo.go` 与 `frankenphp/frankenphp.c`：CGO 桥接点，了解 C ↔ Go 的交互边界和内存管理注意点。
5. `frankenphp/hotreload.go`、`frankenphp/options.go`：辅助功能与配置读取如何影响运行时行为。

重点函数与断点建议
- `Init`（`frankenphp/frankenphp.go`）: 检查 `opt`、`calculateMaxThreads`、`initPHPThreads`、`initWorkers` 执行顺序。
- `ServeHTTP`: 从 `http.Request` 构建 `contextHolder` 并选择 worker 或 regular thread 路径。
- `go_ub_write` / `go_write_headers`: PHP 输出与 header 写入如何回到 `http.ResponseWriter`。
- `worker.handleRequest`: 排队、直接分发、触发 `scaleChan` 的逻辑与超时处理。

小练习（每项后提交为 checkpoint）
1. 在 `ServeHTTP` 放断点，发起一个请求，追踪到 `worker.handleRequest` 或 `handleRequestWithRegularPHPThreads`，记录线程 id。验证：请求结束后 `done` channel 被触发。
2. 在 `go_write_headers` 放断点，观察 PHP 设置响应状态与 headers 的流程；修改代码以在响应中加入自定义 header（小改动并运行验证）。
3. 在 `worker.handleRequest` 中模拟高并发（`ab -n 50 -c 10` 或 `wrk`），观察 `queuedRequests`、扩缩容事件与日志。

常用命令
```bash
# 打开文件（示例）
code frankenphp/frankenphp.go

# 跟踪函数出现位置
rg "func Init\(|go_ub_write|worker.handleRequest" -n frankenphp

# 并发测试（示例）
ab -n 200 -c 20 http://127.0.0.1:80/worker.php
```

检查点
- 能在调试器中从 `ServeHTTP` 逐步步进到 `go_ub_write`（或 `worker.handleRequest`）。
- 能在 `worker.handleRequest` 触发扩缩容并观察新线程加入（日志/metrics）。
- 完成至少一个小练习并把修改提交到分支。

下一步建议
- 我可以带你逐行讲解 `Init`（如果你愿意，我们现在开始并在关键处放断点）。
