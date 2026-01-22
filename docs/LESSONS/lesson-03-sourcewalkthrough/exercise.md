# Exercise — `Init` 源码练习

任务说明：阅读 `init_walkthrough.md`，回答下列问题并完成动手任务。

快速参考文件：
- [init_walkthrough.md](docs/LESSONS/lesson-03-sourcewalkthrough/init_walkthrough.md)
- 源码入口：frankenphp/frankenphp.go

问题（简短回答）：
1. 在 `Init` 中为何要忽略 `SIGPIPE`？
2. 当 PHP 不是 ZTS 构建时，`Init` 如何调整线程数？为什么？
3. `calculateMaxThreads` 的返回值 `workerThreadCount` 用来决定什么？把你的理解写成一两句。

动手任务：
- 在 `docs/LESSONS/lesson-03-sourcewalkthrough/init_walkthrough.md` 中为 `calculateMaxThreads` 返回处添加一段 1-2 行的解释（中文）。
- 或者，在源码 `frankenphp/frankenphp.go` 的相应位置添加一处同等说明性的注释（仅注释，不修改逻辑）。

验证步骤：
- 构建 `frankenphp`（参照 README 中的命令）。
- 启动并观察日志，确认包含 "FrankenPHP started" 行与 PHP 版本、线程信息。

提交：在本目录下添加 `my_answers.md`（可选）并把你的注释补丁作为一个 commit（或把补丁发送给我让我帮你应用）。
