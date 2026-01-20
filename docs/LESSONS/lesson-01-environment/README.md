# Lesson 01 — 环境验证与运行示例

目标
- 验证本地学习环境与依赖已安装。 
- 构建并运行 FrankenPHP 示例，确认服务可响应示例脚本。

前置条件
- 已克隆仓库并在 DevContainer 或本地准备好构建环境（见 `docs/README.md`）。
- 推荐至少 4GB 可用内存与已安装的系统依赖（C 编译器、Go、Docker 如需）。

步骤

1) 安装依赖（若已经安装可跳过）

```bash
./docs/scripts/install_deps.sh
```

2) 构建 FrankenPHP（二选一）

- 在 VS Code 中：打开 `Terminal -> Run Task -> build-frankenphp`。
- 或在终端中手动运行：

```bash
(cd frankenphp/caddy/frankenphp && go build -tags watcher,brotli,nobadger,nomysql,nopgx -o frankenphp .)
```

3) 启动 Caddy 模式示例

- 使用仓库内的 Caddyfile 示例（`frankenphp/testdata/Caddyfile`）启动构建后的二进制：

```bash
cd frankenphp/caddy/frankenphp
# 启动内置 caddy（frankenphp 二进制是内嵌 Caddy 的构建产物）
./frankenphp run --config ../../testdata/Caddyfile &
```

4) 验证服务响应

```bash
# 验证 phpinfo
curl -sS http://127.0.0.1:80/phpinfo.php | grep -i PHP

# 或访问根路径（Worker demo 可见计数输出）
curl -sS http://127.0.0.1:80/
```

5) 运行 Worker 模式示例（可选）

```bash
# 启动使用 worker Caddyfile 的示例（路径示意，按需调整）
./frankenphp run --config ../../docs/demos/worker.Caddyfile &
curl -sS http://127.0.0.1:80/
```

检查点（完成即通过）
- `install_deps` 已成功执行（或确认环境满足依赖）。
- 能够成功构建 `frankenphp` 二进制（在 `frankenphp/caddy/frankenphp/` 下）。
- `curl http://127.0.0.1:80/phpinfo.php` 返回包含 PHP 版本信息的页面。

常见问题与排查
- 构建失败：检查 `CGO_CFLAGS` / `CGO_LDFLAGS` 是否指向正确的 PHP 头文件与库。参见 `docs/README.md` 中的说明。
- 端口被占用：确认 80 端口是否已有服务，或修改 Caddyfile 中端口。
- 二进制无法启动或报错：查看启动日志，确认 `EmbeddedAppPath`、PHP 源路径和扩展均正确配置。

后续（第 2 课）
- 完成本课后，第 2 课将演示如何在 VS Code 中设置断点并用调试器单步运行 Worker 示例。
