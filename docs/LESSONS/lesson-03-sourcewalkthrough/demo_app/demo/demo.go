package demo

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"time"
)

// Option configures the demo server.
type Option func(o *opt) error

// WorkerOption configures a worker.
type WorkerOption func(w *workerOpt) error

type opt struct {
	ctx         context.Context
	numThreads  int
	maxThreads  int
	workers     []workerOpt
	maxWaitTime time.Duration
}

type workerOpt struct {
	name    string
	num     int
	onStart func()
	onStop  func()
}

// WithContext injects a context used to cancel the demo.
func WithContext(ctx context.Context) Option {
	return func(o *opt) error {
		o.ctx = ctx
		return nil
	}
}

// WithNumThreads sets the number of threads (simulated).
func WithNumThreads(n int) Option {
	return func(o *opt) error {
		o.numThreads = n
		return nil
	}
}

// WithMaxThreads sets the maximum allowed threads.
func WithMaxThreads(n int) Option {
	return func(o *opt) error {
		o.maxThreads = n
		return nil
	}
}

// WithMaxWaitTime sets the maximum wait time for acquiring a thread.
func WithMaxWaitTime(d time.Duration) Option {
	return func(o *opt) error {
		o.maxWaitTime = d
		return nil
	}
}

// WithWorkers registers a worker set.
func WithWorkers(name string, num int, options ...WorkerOption) Option {
	return func(o *opt) error {
		w := workerOpt{name: name, num: num}
		for _, optfn := range options {
			if err := optfn(&w); err != nil {
				return err
			}
		}
		o.workers = append(o.workers, w)
		return nil
	}
}

// WithWorkerOnStart registers a callback when a worker starts.
func WithWorkerOnStart(f func()) WorkerOption {
	return func(w *workerOpt) error {
		w.onStart = f
		return nil
	}
}

// WithWorkerOnStop registers a callback when a worker stops.
func WithWorkerOnStop(f func()) WorkerOption {
	return func(w *workerOpt) error {
		w.onStop = f
		return nil
	}
}

// Server is the running demo server.
type Server struct {
	opt    opt
	wg     sync.WaitGroup
	cancel context.CancelFunc
}

// Init applies options and starts simulated workers. It returns a Server handle.
func Init(options ...Option) (*Server, error) {
	cfg := opt{
		ctx:         context.Background(),
		numThreads:  1,
		maxThreads:  1,
		maxWaitTime: 5 * time.Second,
	}

	for _, fn := range options {
		if err := fn(&cfg); err != nil {
			return nil, err
		}
	}

	if cfg.numThreads <= 0 {
		return nil, errors.New("numThreads must be > 0")
	}
	if cfg.maxThreads < cfg.numThreads {
		return nil, fmt.Errorf("maxThreads (%d) < numThreads (%d)", cfg.maxThreads, cfg.numThreads)
	}

	// create cancellable context
	ctx := cfg.ctx
	var cancel context.CancelFunc
	if ctx == nil {
		ctx, cancel = context.WithCancel(context.Background())
	} else {
		ctx, cancel = context.WithCancel(ctx)
	}

	s := &Server{opt: cfg, cancel: cancel}

	// start workers
	for _, w := range cfg.workers {
		for i := 0; i < w.num; i++ {
			s.wg.Add(1)
			go func(name string, onStart, onStop func()) {
				defer s.wg.Done()
				if onStart != nil {
					onStart()
				}
				// simulate work loop until context canceled
				<-ctx.Done()
				if onStop != nil {
					onStop()
				}
			}(w.name, w.onStart, w.onStop)
		}
	}

	// log startup summary
	fmt.Printf("Demo Init: numThreads=%d maxThreads=%d workers=%d maxWait=%s\n", cfg.numThreads, cfg.maxThreads, len(cfg.workers), cfg.maxWaitTime)

	return s, nil
}

// Shutdown cancels the server and waits for workers to stop.
func (s *Server) Shutdown() {
	if s == nil {
		return
	}
	s.cancel()
	s.wg.Wait()
}
