# FrankenPHP 学习计划

## 目的
提供一份可执行的学习路线，把仓库文档与代码阅读、动手验证和调试练习结合起来，帮助你系统掌握 FrankenPHP 的架构与实现细节。

## 学习方法（原则）
- 目标导向：每次聚焦一个小目标（理解一个组件、运行一个 demo、实现一个小改动）。
- 分阶段：文档阅读 → 环境验证与运行示例 → 源码逐层剖析 → 调试与改动验证 → 测试与复盘。
- 自上而下：先把高阶流程跑通，再深入关键实现文件（`frankenphp/frankenphp.go`、`frankenphp/worker.go`、`frankenphp/phpthread.go` 等）。
- 动手优先：读一处代码就跑一个 demo 或放个断点、添日志，迅速验证理解。
- 小步迭代：把大目标拆成多个可验证的小任务，完成一个就提交一个 checkpoint。

## 学习里程碑（建议顺序）
1. 环境与依赖（如果未完成）
   - 运行 `install-deps` 任务或执行 `./docs/scripts/install_deps.sh`。
2. 运行示例
   - 使用 `frankenphp/testdata/Caddyfile` 启动 Caddy 模式 demo。
   - 使用 `docs/demos/worker.Caddyfile` 测试 Worker 模式 demo。
3. 编译二进制
   - 在 `frankenphp/caddy/frankenphp` 目录下执行 `build-frankenphp` 任务（或运行任务里定义的 `go build`）。
4. VS Code 调试配置
   - 在 `frankenphp` 的入口处设置断点（例如 `frankenphp/frankenphp.go`、`frankenphp/worker.go`）。
5. 源码导读（分层次）
   - 阶段 A（框架与入口）: `frankenphp/frankenphp.go`、`frankenphp/cgi.go`、`frankenphp/caddy/`（Caddy 适配）
   - 阶段 B（Worker 引擎）: `frankenphp/worker.go`、`frankenphp/threadworker.go`、`frankenphp/phpthread.go`、`frankenphp/threadregular.go`
   - 阶段 C（CGO & C 绑定）: `frankenphp/cgo.go`、`frankenphp/frankenphp.c`、`frankenphp/types.go`、`frankenphp/types.c`
   - 阶段 D（辅助与扩展）: `frankenphp/hotreload.go`、`frankenphp/metrics.go`、`frankenphp/options.go`
6. 小练习（每个练习后提交 checkpoint）
   - 在 Worker demo 中增加一个自定义响应 header 并验证。
   - 添加简单日志或计数器并通过断点观察线程交互。
7. 测试与复盘
   - 运行 `go test` 覆盖相关包；阅读现有测试（`*_test.go`）学习测试关注点。
   - 总结学习笔记：架构图、线程模型、典型请求生命周期。

## 推荐命令（可复制执行）
```bash
# 安装依赖（可能耗时）
./docs/scripts/install_deps.sh

# 构建 frankenphp（在 workspace 根或指定目录运行任务）
# VS Code: Run Task -> build-frankenphp
(cd frankenphp/caddy/frankenphp && go build -tags watcher,brotli,nobadger,nomysql,nopgx -o frankenphp .)

# 在本地测试 Worker demo（Caddyfile 配置，请根据路径调整）
# 使用 Caddy 或在调试配置中启动相应 target，然后 curl 测试
curl http://127.0.0.1:80/
```

## 检查点（每完成一项请记录）
- 成功运行 `install-deps`。
- 成功构建 `frankenphp` 二进制并能响应 `phpinfo.php` 或 Worker 脚本。
- 在 `frankenphp/worker.go` 放断点并能在调试器里步进一次完整请求处理链。
- 完成至少一个小练习并把变更作为分支提交。

## 我将如何协助你
- 按上述里程碑逐步带你阅读代码：我会打开关键文件并解释每个函数的职责与交互。
- 我会帮助运行构建与 demo（如果你希望我在终端执行命令）。
- 我会在你做小改动时，帮你写补丁、运行测试并排查问题。

---
文件位置：`docs/LEARNING_PLAN.md`（已创建）。如果你同意，我现在就从 `frankenphp/frankenphp.go` 开始源码导读。 
