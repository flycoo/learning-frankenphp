# Lesson 03 — `Init` 总-分说明与源码内联注释

目标：先给出 `Init` 的高层（总）说明，然后在函数源码中按功能块（分）插入简洁注释，便于在调试器中逐步跟踪。

参考文件：`frankenphp/frankenphp.go` 中的 `Init` 实现

---

## 调用链（启动流程）

从调试器捕获的完整调用路径：

```
main.main (frankenphp/main.go:15)
  ↓
cmd.Main (cmd/main.go:72)
  ↓
cmd.cmdRun (commandfuncs.go:240)
  └─ Cobra 命令行框架处理 `run` 命令
  ↓
v2.Load (caddy.go:137)
  └─ 加载 Caddy 配置文件
  ↓
v2.changeConfig (caddy.go:238)
  └─ 变更 Caddy 运行配置
  ↓
v2.unsyncedDecodeAndRun (caddy.go:347)
  └─ 解析配置并启动适配器
  ↓
v2.run (caddy.go:454)
  └─ 执行 Caddy 运行时
  ↓
caddy.(*FrankenPHPApp).Start (app.go:168)
  └─ 启动 FrankenPHP Caddy 适配器应用
  ↓
frankenphp.Init (frankenphp.go:240) ← 第一个 Go 线程在此断点
  └─ 初始化 FrankenPHP 运行时系统
```

**关键点**：
- `Init` 是 Caddy 启动 FrankenPHP 时调用的**入口函数**
- 流程路径：Caddy CLI `run` 命令 → 加载配置 → 启动 FrankenPHPApp → 调用 Init
- Init 在单独的 Go 线程 #652400 中执行（不是主线程）
- Init 返回前，FrankenPHP 运行时已完全初始化，包括所有 PHP 线程池

---

## 总览（高层说明）

Init 的主要职责（总）：

- 初始化全局运行状态与信号处理
- 注册扩展并解析 `Option` 配置
- 计算并创建 PHP 线程池（主线程、regular、worker）
- 初始化 watchers、自动扩缩容与 worker 启动回调

### 详细职责分解

- **防护与信号**：防止重复初始化，忽略 SIGPIPE 信号
- **扩展与配置**：注册 PHP 扩展，解析并应用 Option 回调
- **线程池计算**：计算 worker 和 regular 线程数，校验 num_threads/max_threads 约束
- **PHP 初始化**：验证 PHP 版本（≥8.2），初始化主线程及其内部线程池
- **请求处理**：创建 regular 请求通道与 worker 线程池
- **热重载与监控**：启动 watchers（热重载）、自动扩缩容（autoscaling）
- **生命周期回调**：注册 worker 的：onServerStartup、onServerShutdown 钩子

下面按功能块在源码中插入注释（保留原始格式，仅在关键处加注释）。

```go
func Init(options ...Option) error {
	// 防止重复初始化：若已运行则返回错误
	if isRunning {
		return ErrAlreadyStarted
	}
	isRunning = true

	// 忽略 SIGPIPE，避免写 socket 时进程被系统信号终止（systemd/docker 常见）
	signal.Ignore(syscall.SIGPIPE)

	// 在启动前注册任何需要的扩展
	registerExtensions()

	// 解析并应用传入的 Option 回调，Option 用于定制 ctx/logger/threads/metrics
	opt := &opt{}
	for _, o := range options {
		if err := o(opt); err != nil {
			// Option 应用失败时回滚并返回错误
			Shutdown()
			return err
		}
	}

	// 安全地将 Option 中的 ctx/logger 迁移到包级全局变量
	globalMu.Lock()

	if opt.ctx != nil {
		globalCtx = opt.ctx
		opt.ctx = nil
	}

	if opt.logger != nil {
		globalLogger = opt.logger
		opt.logger = nil
	}

	globalMu.Unlock()

	// 注入 metrics（可用于测试/监控替换）
	if opt.metrics != nil {
		metrics = opt.metrics
	}

	// 请求处理相关的最大等待时间（用于超时控制）
	maxWaitTime = opt.maxWaitTime

	// 计算 worker/线程配额（会校验 num_threads 与 max_threads 等约束）
	workerThreadCount, err := calculateMaxThreads(opt)
	if err != nil {
		Shutdown()
		return err
	}

	// 上报最终线程数到 metrics
	metrics.TotalThreads(opt.numThreads)

	// 从 C 层读取 PHP 构建信息（版本、ZTS 等）
	config := Config()

	// 要求 PHP >= 8.2
	if config.Version.MajorVersion < 8 || (config.Version.MajorVersion == 8 && config.Version.MinorVersion < 2) {
		Shutdown()
		return ErrInvalidPHPVersion
	}

	// 根据 PHP 是否启用 ZTS 调整行为
	if config.ZTS {
		// 在 Linux 上，如果未启用 Zend Max Execution Timers，记录警告
		if !config.ZendMaxExecutionTimers && runtime.GOOS == "linux" {
			if globalLogger.Enabled(globalCtx, slog.LevelWarn) {
				globalLogger.LogAttrs(globalCtx, slog.LevelWarn, `Zend Max Execution Timers are not enabled, timeouts (e.g. "max_execution_time") are disabled, recompile PHP with the "--enable-zend-max-execution-timers" configuration option to fix this issue`)
			}
		}
	} else {
		// 非 ZTS 构建无法并发执行 PHP，强制只使用 1 个线程
		opt.numThreads = 1
		if globalLogger.Enabled(globalCtx, slog.LevelWarn) {
			globalLogger.LogAttrs(globalCtx, slog.LevelWarn, `ZTS is not enabled, only 1 thread will be available, recompile PHP using the "--enable-zts" configuration option or performance will be degraded`)
		}
	}

	// 初始化主线程及其内部线程池结构（涉及 CGO/PHP 初始化）
	mainThread, err := initPHPThreads(opt.numThreads, opt.maxThreads, opt.phpIni)
	if err != nil {
		Shutdown()
		return err
	}

	// 准备 regular 请求通道与常规线程池
	regularRequestChan = make(chan contextHolder)
	regularThreads = make([]*phpThread, 0, opt.numThreads-workerThreadCount)
	for i := 0; i < opt.numThreads-workerThreadCount; i++ {
		convertToRegularThread(getInactivePHPThread())
	}

	// 初始化 worker（配置的长驻 worker 脚本）
	if err := initWorkers(opt.workers); err != nil {
		Shutdown()

		return err
	}

	// 启动 watchers（例如热重载），出错则回滚
	if err := initWatchers(opt); err != nil {
		Shutdown()
		return err
	}

	// 初始化自动扩缩容（依赖于 mainThread 和监控数据）
	initAutoScaling(mainThread)

	// 启动成功日志（包含版本与线程信息）
	if globalLogger.Enabled(globalCtx, slog.LevelInfo) {
		globalLogger.LogAttrs(globalCtx, slog.LevelInfo, "FrankenPHP started 🐘", slog.String("php_version", Version().Version), slog.Int("num_threads", mainThread.numThreads), slog.Int("max_threads", mainThread.maxThreads))

		if EmbeddedAppPath != "" {
			globalLogger.LogAttrs(globalCtx, slog.LevelInfo, "embedded PHP app 📦", slog.String("path", EmbeddedAppPath))
		}
	}

	// 注册 worker 的启动/关闭回调，Shutdown() 会调用 onServerShutdown 列表
	onServerShutdown = nil
	for _, w := range opt.workers {
		if w.onServerStartup != nil {
			w.onServerStartup()
		}
		if w.onServerShutdown != nil {
			onServerShutdown = append(onServerShutdown, w.onServerShutdown)
		}
	}

	return nil
}
```

---

## 下一步深入阅读

可按同样风格继续深入以下函数：

- **initPHPThreads** — PHP 线程池初始化（核心 CGO 操作）
- **calculateMaxThreads** — 线程数计算与约束校验
- **initWorkers** — Worker 脚本启动与生命周期
- **initWatchers** — 热重载/监听器初始化
- **initAutoScaling** — 自动扩缩容机制启动

---

文件位置：`docs/LESSONS/lesson-03-sourcewalkthrough/init_walkthrough.md`
