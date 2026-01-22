# FrankenPHP 源码学习指南

本项目环境已配置好 VS Code，用于学习、编译和调试 FrankenPHP。

## 1. 环境准备 / 依赖 (Prerequisites)

在运行或编译之前，您必须安装必要的依赖项（C 编译器、PHP 源码等）。
即使您已经进入 DevContainer，我们建议通过以下任务确保 PHP 源码已准备就绪。
（*注：本项目包含一个 `setup_phpsrc.sh` 脚本和 git submodule 配置，通常会自动处理 PHP 源码*）

**操作：** 运行 VS Code 任务：`install-deps` (Terminal > Run Task > install-deps)。
*注意：此过程会从源码编译 PHP，可能需要 10-20 分钟。*

## 2. 编译 (Compilation)

FrankenPHP 本质上是一个 Caddy 模块。我们可以使用 Go 来构建它。

**操作：** 运行 VS Code 任务：`build-frankenphp` (Terminal > Run Task > build-frankenphp)。
这将在 `frankenphp/caddy/frankenphp/` 目录下生成一个 `frankenphp` 二进制文件。

## 3. 调试 (Debugging)

您可以直接在 VS Code 中调试 Go 代码以及 Caddy 集成部分。
打开调试视图 (Ctrl+Shift+D) 并选择以下配置之一：

### A. Launch FrankenPHP (Caddy模式)
*   **描述**：以标准模式运行 FrankenPHP，充当 Web 服务器。
*   **上下文**：使用 `frankenphp/testdata/Caddyfile` 配置文件。
*   **如何验证**：
    1. 在 `frankenphp.go` 或任何相关文件中设置断点。
    2. 启动调试。
    3. 打开终端并执行 `curl http://127.0.0.1:80/phpinfo.php`（或在浏览器中打开）。

### B. Launch FrankenPHP (Worker模式)
*   **描述**：以 Worker 模式运行 FrankenPHP（高性能模式）。
*   **上下文**：使用 `docs/demos/worker.Caddyfile`，该配置指向 `frankenphp/testdata/worker.php`。
*   **演示逻辑**：Caddyfile 将所有请求重写为 `/worker.php`，以便通过 Worker 脚本处理。
*   **如何验证**：
    1. 在 `worker.go` 或 `frankenphp/testdata/worker.php` 中设置断点。
    2. 启动调试。
    3. 执行 `curl http://127.0.0.1:80/` -> 应该看到 "Requests handled: ..." 输出。

### C. Launch Test Server (纯Go服务器)
*   **描述**：运行一个最小化的 Go 服务器来嵌入 FrankenPHP，不使用 Caddy。
*   **上下文**：`internal/testserver` 中的代码。
*   **端口**：8080。

## 4. 仓库结构与版本控制 (Repository Structure)

本学习环境由三个部分组成，通过 Git Submodule 管理：

1.  **根仓库 (`learning-frankenphp`)**
    *   **作用**：管理学习笔记、文档 (`docs/`)、VS Code 配置 (`.vscode/`) 以及辅助脚本。
    *   **脚本**：
        *   `setup_git_gh.sh`: 初始化环境脚本。
        *   `commit_changes.sh`: **日常使用**。自动提交根仓库和子模块的变更，并推送到您的 Fork。
2.  **FrankenPHP 子模块 (`frankenphp/`)**
    *   **源地址**：指向您的 Fork (`flycoo/frankenphp`)。
    *   **上游**：指向官方 (`php/frankenphp`)。
    *   **分支**：通常在 `study/logging-trace` 等自定义分支上工作。
3.  **PHP 源码子模块 (`php-src/`)**
    *   **源地址**：指向您的 Fork (`flycoo/php-src`)。
    *   **用途**：用于 CGO 编译链接以及跟踪底层 PHP 实现。

## 5. 源码结构 (Code Overview)

*   `/frankenphp`: 核心 Go 库和 C 语言绑定 (C Bindings)。
*   `/frankenphp/caddy`: Caddy 模块适配器。
*   `/frankenphp/internal`: 内部工具包。
*   `/frankenphp/testdata`: 用于测试的 PHP 脚本。

## 6. 架构与流程 (Architecture)

*   [Worker 模式引擎流程 (中文)](architecture_worker.md): 详细解释了 Worker 模式下 Go <-> C <-> PHP 的生命周期交互。

## 7. 演示 (Demos)

*   **标准模式**: 配置文件见 `frankenphp/testdata/Caddyfile`
*   **Worker 模式**: 配置文件见 `docs/demos/worker.Caddyfile`，脚本见 `frankenphp/testdata/worker.php`

## 8. 课程目录 (Lessons)

- Lesson 01 — 环境验证与运行示例: [docs/LESSONS/lesson-01-environment/README.md](docs/LESSONS/lesson-01-environment/README.md) （已完成)
- Lesson 02 — 调试与断点: [docs/LESSONS/lesson-02-debugging/README.md](docs/LESSONS/lesson-02-debugging/README.md) （已完成)


## 小贴士 (Tips)

*   `install_deps.sh` 脚本在编译 PHP 时使用了 `--enable-debug`，只要步进得足够深，您可以检查 C 结构体（这需要 GDB/C 知识和适当的 C++ 插件配置，但本环境主要侧重于 Go 调试）。
*   `CGO_CFLAGS` and `CGO_LDFLAGS` 已经在 `launch.json` 中配置好，指向了 `/usr/local` 下正确的 PHP 头文件和库路径。
*   使用 `./commit_changes.sh` 脚本来一键提交所有更改。

## 8. 故障排除 (Troubleshooting)

参见 [docs/troubleshooting.md](troubleshooting.md) 了解常见的构建问题。
