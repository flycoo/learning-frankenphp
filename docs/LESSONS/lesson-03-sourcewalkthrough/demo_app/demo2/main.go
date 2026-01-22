package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/dunglas/frankenphp"
)

func main() {
	// Minimal use of the real frankenphp Init API
	// 这里演示使用带超时的 Context：基于 `context.Background()` 创建一个 5 秒的可取消 Context，
	// 超时到达或调用 `cancel()` 时，派生的 goroutine 可收到取消信号并做清理。
	// 这种模式适合需要在一段时间内自动回收或防止长期阻塞的场景。
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// 将 `ctx` 传入 frankenphp，frankenphp 可以基于这个 Context 管理内部 goroutine/线程的生命周期。
	// 由于这里使用了超时 Context，若 5 秒后还未完成，Context 会被取消，frankenphp 及其子任务应响应取消并退出。
	if err := frankenphp.Init(
		frankenphp.WithContext(ctx),
		frankenphp.WithNumThreads(1),
		frankenphp.WithMaxThreads(1),
		frankenphp.WithMaxWaitTime(2*time.Second),
	); err != nil {
		fmt.Fprintf(os.Stderr, "frankenphp Init failed: %v\n", err)
		os.Exit(2)
	}
	defer frankenphp.Shutdown()

	fmt.Println("demo2: frankenphp.Init succeeded (if build completed). Press Ctrl+C to exit")

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	<-sig
	fmt.Println("demo2: exiting")
}
