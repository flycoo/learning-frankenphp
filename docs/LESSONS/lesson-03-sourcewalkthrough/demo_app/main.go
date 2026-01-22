package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	demo "lesson03/frankenphp-demo/demo"
)

func main() {
	// build options
	ctx := context.Background()

	s, err := demo.Init(
		demo.WithContext(ctx),
		demo.WithNumThreads(2),
		demo.WithMaxThreads(4),
		demo.WithMaxWaitTime(3*time.Second),
		demo.WithWorkers("echo", 2,
			demo.WithWorkerOnStart(func() { fmt.Println("worker echo started") }),
			demo.WithWorkerOnStop(func() { fmt.Println("worker echo stopped") }),
		),
	)
	if err != nil {
		fmt.Fprintf(os.Stderr, "init failed: %v\n", err)
		os.Exit(2)
	}

	// graceful shutdown on SIGINT/SIGTERM
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	fmt.Println("Demo running — press Ctrl+C to stop")
	<-sig

	fmt.Println("Shutting down...")
	s.Shutdown()
	fmt.Println("Shutdown complete")
}
