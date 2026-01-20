# FrankenPHP Worker Mode 架构与调用流程

在 FrankenPHP Worker 模式下，HTTP 请求的处理流程是一个 **Go (Web Server) 与 C (PHP Engine) 协同工作** 的过程。

整个流程可以分为四个阶段：**启动阶段**、**请求接收阶段**、**PHP 执行阶段**、**结束响应阶段**。

## 1. 启动阶段 (预热)

在处理任何 HTTP 请求之前，FrankenPHP 会先启动 Worker 脚本，使其进入“等待”状态。

*   **Go**: `frankenphp.Init()` -> `initWorkers()` (位于 `worker.go`)
    *   Go 启动多个 OS 线程，每个线程运行一个 PHP 解析器实例。
*   **C**: `php_thread` (位于 `frankenphp.c`)
    *   调用 `frankenphp_execute_script` 执行配置的 `worker.php`。
*   **PHP**: `worker.php` (用户代码)
    *   脚本开始运行，进入 `while` 循环。
    *   执行 `frankenphp_handle_request($callback)`。
*   **C**: `PHP_FUNCTION(frankenphp_handle_request)` (位于 `frankenphp.c`)
    *   PHP 扩展内部调用 `go_frankenphp_worker_handle_request_start`。
*   **Go**: `go_frankenphp_worker_handle_request_start` (位于 `threadworker.go`)
    *   **此处阻塞**：该函数内部调用 `waitForWorkerRequest()`，等待 Go 主协程派发请求。

## 2. 请求接收阶段 (Go -> C)

当一个 HTTP 请求到达端口时（例如 80 端口）：

*   **Go (Caddy)**: `caddy/module.go` -> `ServeHTTP()`
    *   这是 Caddy 的入口，它构建 `frankenphp.Request` 对象，设置 `WorkerName`。
    *   调用 `frankenphp.ServeHTTP(w, req)`。
*   **Go (Core)**: `frankenphp.go` -> `ServeHTTP()`
    *   检测到 `req.workerRequest` 为真，调用 `handleWorkerRequest`。
    *   调用 `worker.handleRequest` (位于 `worker.go`)。
*   **Go (Worker)**: `worker.handleRequest()` (位于 `worker.go`)
    *   从空闲线程池中找一个处于阻塞状态的线程。
    *   **派发请求**：将 HTTP 请求上下文 (Context) 发送给该线程的通道。
*   **Go (Thread)**: `threadworker.go` -> `waitForWorkerRequest()`
    *   收到请求信号，**解除阻塞**。
    *   返回 `true` 给 C 语言层。

## 3. PHP 执行阶段 (C -> PHP CallBack)

此时控制权回到了之前阻塞的 C 代码栈中：

*   **Go**: `go_frankenphp_worker_handle_request_start` 返回。
*   **C**: `PHP_FUNCTION(frankenphp_handle_request)` (位于 `frankenphp.c`)
    *   继续执行。
    *   **更新超全局变量**：调用 `frankenphp_worker_request_startup`，将新的 `$_GET`, `$_POST`, `$_SERVER` 数据注入到 PHP 内存中。
    *   **执行回调**: 调用用户传入的匿名函数 `function() { ... }`。
*   **PHP**: 用户代码
    *   执行业务逻辑（如 `echo "Hello"`）。
    *   输出内容实际上是写入到了 Go 自定义的 `Writer` 中，该 Writer 映射回 HTTP 响应。

## 4. 结束响应阶段

当 PHP 回调函数执行完毕：

*   **C**: `PHP_FUNCTION(frankenphp_handle_request)`
    *   PHP 函数执行结束。
    *   调用 `frankenphp_worker_request_shutdown` 清理请求级变量。
    *   调用 `go_frankenphp_finish_worker_request` 通知 Go。
*   **Go**: `go_frankenphp_finish_worker_request` (位于 `threadworker.go`)
    *   标记该线程已完成工作，将其放回空闲池。
    *   通知 HTTP 响应流结束。
*   **Go (Caddy)**: `ServeHTTP` 返回，请求处理完成，连接关闭。
*   **PHP**: `worker.php`
    *   `frankenphp_handle_request` 返回 `true`。
    *   `do...while` 循环继续，再次调用 `frankenphp_handle_request`，回到 **步骤 1** 的阻塞状态，等待下一个请求。

## 总结图示

```mermaid
graph TD
    User[用户] --> Caddy[Caddy (Go)]
    subgraph "Go Runtime"
        Caddy --> Module[ServeHTTP (module.go)]
        Module --> Dispatcher[handleWorkerRequest (frankenphp.go)]
        Dispatcher -- Channel --> GoThread[Worker Thread (waiting)]
    end
    
    subgraph "C & PHP Runtime"
        PHP[worker.php] -- 1. 调用 --> C_Ext[frankenphp_handle_request (C)]
        C_Ext -- 2. 阻塞等待 --> GoThread
        GoThread -- 3. 唤醒并注入数据 --> C_Ext
        C_Ext -- 4. 执行回调 --> PHP_Callback[PHP 业务逻辑]
        PHP_Callback -- 5. 返回 --> C_Ext
        C_Ext -- 6. 循环 --> PHP
    end
```
