# FrankenPHP CGO 集成专题

本文档总结并说明了 FrankenPHP 项目中如何通过 CGO 将 Go 与 PHP（Zend 引擎）集成的实现细节。

**摘要**
- FrankenPHP 使用 CGO 在 Go 与嵌入式 PHP（SAPI embed）之间建立双向调用桥接。Go 负责 HTTP 请求接收与调度，C 层（包含 PHP SAPI）负责执行 PHP 脚本并通过回调把结果传回 Go。文档和实现分散在若干源码文件中，核心文件：[frankenphp/cgo.go](frankenphp/cgo.go)、[frankenphp/frankenphp.c](frankenphp/frankenphp.c)、[frankenphp/frankenphp.h](frankenphp/frankenphp.h)、以及 Go 层的若干实现（如 [frankenphp/frankenphp.go](frankenphp/frankenphp.go)、[frankenphp/worker.go](frankenphp/worker.go)）。

## 1. CGO 编译配置
- 在 `frankenphp/cgo.go` 中通过 `// #cgo` 指令设置平台相关的 `CFLAGS` 与 `LDFLAGS`，例如链接 `-lphp`、`-ldl`、`-lresolv` 等系统库，并对 macOS/linux 进行区分。这保证 Go 编译时能正确找到 PHP 头文件与运行时库并与之链接。

## 2. Go ⇄ C 数据结构与头文件
- `frankenphp/frankenphp.h` 定义了跨语言使用的结构体（例如 `go_string`、`ht_key_value_pair`）和导出的 C 接口原型，供 Go 通过 `import "C"` 调用。
- 这些结构体用于在 C 与 Go 之间传递字符串、键值对、zval 等数据，以减少不必要的内存拷贝与转换次数。

## 3. 双向函数调用机制
- C 调用 Go：
  - C 代码包含 `_cgo_export.h`（由 cgo 生成），并调用一系列 `go_*` 前缀的函数，例如 `go_update_request_info()`、`go_frankenphp_worker_handle_request_start()`、`go_putenv()`、`go_getenv()`、`go_ub_write()`、`go_write_headers()` 等。这些函数在 Go 侧实现，用于完成请求调度、环境变量管理、写响应、日志等操作（见 `frankenphp.c` 中对 `go_...` 的调用）。
- Go 调用 C：
  - 在 Go 源（例如 `frankenphp/frankenphp.go`、`phpmainthread.go` 等）中通过 `C.frankenphp_*` 系列函数启动主线程、创建/启动 PHP 线程、执行脚本、查询版本与配置等，例如 `C.frankenphp_new_main_thread()`、`C.frankenphp_new_php_thread()`、`C.frankenphp_execute_script()`、`C.frankenphp_get_version()` 等。

## 4. Worker 模式下的请求处理流程（概览）
参见补充架构文档：[docs/architecture_worker.md](./architecture_worker.md)。主要步骤：
- 启动阶段：Go 调用 `frankenphp_new_main_thread`/`frankenphp_new_php_thread` 创建 PHP 主线程与工作线程（C 层启动 Zend SAPI 并进入脚本执行循环）。
- 请求接收：Caddy（Go）将 HTTP 请求转换为内部 `frankenphp.Request`，调用 `ServeHTTP()` -> `frankenphp.ServeHTTP()` -> `worker.handleRequest()`，从空闲线程池取出阻塞的 PHP 线程并将请求通过通道派发。
- C 层唤醒：在 PHP 代码中调用 `frankenphp_handle_request()`（C 的 PHP 扩展函数），该函数内部会调用 `go_frankenphp_worker_handle_request_start(thread_index)` 阻塞等待 Go 派发请求；一旦返回，C 端设置请求上下文并执行用户回调。
- PHP 执行：用户回调在 Zend 引擎中执行，输出通过 C 层调用 `go_ub_write()` 回写到 Go 的响应流。
- 完成通知：C 层在请求结束后调用 `go_frankenphp_finish_worker_request()` 通知 Go 线程完成并回收至空闲池。

在源码中，关键实现点在 `frankenphp/frankenphp.c` 的 `PHP_FUNCTION(frankenphp_handle_request)`、`frankenphp_worker_request_startup()`、`frankenphp_worker_request_shutdown()`，以及 Go 侧的 `threadworker.go` / `worker.go` 的通道与线程管理逻辑。

## 5. 超全局变量与批量注册优化
- 为了减少大量的 CGO 调用开销，C 层提供了批量注册接口 `frankenphp_register_bulk()`，一次性把多个已知的 `$_SERVER` 变量写入 PHP 的超全局数组，避免逐项调用 Go-侧函数。
- 在非 worker 模式下，C 层会直接通过 `get_full_env()`（最终调用 Go 的 `go_getfullenv`）导入环境变量；在 worker 模式下，项目会缓存 `os_environment`，以避免重复读取并保证线程安全。

## 6. PHP 线程生命周期（C 实现要点）
- `php_main`：初始化 SAPI、读取并覆盖 `php.ini`（通过 `go_get_custom_php_ini()`），启动 SAPI 并准备就绪，然后进入主循环，最终调用 `go_frankenphp_shutdown_main_thread()` 完成清理。
- `php_thread`：每个 PHP 工作线程循环调用 `go_frankenphp_before_script_execution(thread_index)` 获取要执行的脚本名，运行脚本（`frankenphp_execute_script`）并在结束后调用 `go_frankenphp_after_script_execution(thread_index, status)`。当 Go 端关闭通道后，线程退出并调用 `go_frankenphp_on_thread_shutdown(thread_index)` 通知 Go。

## 7. 编译与环境要点
- PHP 必须以嵌入式 SAPI 支持构建（`--enable-embed`），并建议启用线程安全（`--enable-zts`）以支持多线程 Worker。
- 项目 `docs/scripts/install_deps.sh` 演示了推荐的依赖、配置与构建选项（包括 `--enable-debug` 以便调试符号），并安装本项目期望的本地库。
- 编译时需确保 `CGO_CFLAGS` / `CGO_LDFLAGS` 指向 PHP 安装的头文件和库路径，以便 cgo 能正确生成绑定。

## 8. 集成要点总结
- 双向桥接：通过 `_cgo_export.h` 生成的接口实现 C 调用 Go；通过 `import "C"` 调用导出自 C 的函数。
- 最小化开销：使用批量注册与结构体（如 `go_string`、`ht_key_value_pair`）来减少 cgo 边界往返与拷贝。
- 线程安全：使用 PHP 的 ZTS（线程安全）构建与适当的 TSRM 管理（`tsrm`）以支持多线程。
- 清晰分层：Go 负责网络与调度，C 负责 SAPI 与 PHP 生命周期，PHP 负责业务逻辑。

## 9. 参考源码文件
- [frankenphp/cgo.go](frankenphp/cgo.go)
- [frankenphp/frankenphp.h](frankenphp/frankenphp.h)
- [frankenphp/frankenphp.c](frankenphp/frankenphp.c)
- [frankenphp/frankenphp.go](frankenphp/frankenphp.go)
- [frankenphp/worker.go](frankenphp/worker.go)
- [docs/architecture_worker.md](docs/architecture_worker.md)
- [docs/scripts/install_deps.sh](docs/scripts/install_deps.sh)

---
*该文档基于仓库源码摘录与项目文档整理而成，若需将其合并到项目其他文档或做扩展（如添加示意图、代码链接到具体行号或示例片段），我可以继续完善。*
