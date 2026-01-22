# Solution / Hints

问题答案（简短）：
1. 忽略 `SIGPIPE` 是为了避免向已关闭的 socket 写入时进程被系统信号终止，服务在网络异常下应自己处理错误而不是被 kill。
2. 如果 PHP 不是 ZTS（非线程安全），`Init` 强制将 `numThreads` 设为 1；因为非 ZTS 构建不能并发执行 PHP，多个线程会导致未定义行为或崩溃。
3. `workerThreadCount` 表示为长驻 worker 保留的线程数，它影响 regular 请求池的大小（即总线程数中有多少用于 worker）。

动手提示：
- 只添加注释，不要更改逻辑或 API。
- 构建失败时，先检查 CGO 环境变量与 `php-src` 的头文件是否就绪（仓库有安装脚本 `./docs/scripts/install_deps.sh`）。

如果你愿意，我可以替你把注释补丁应用到 `init_walkthrough.md` 或直接在 `frankenphp/frankenphp.go` 加注释并运行一次本地构建验证。
