# Lesson 03 — `calculateMaxThreads` 注释与源码说明

目的：解释 `calculateMaxThreads` 的行为、约束检查和常见配置陷阱。优先级高，因为该函数经常导致初始化配置错误。

参考位置：`frankenphp/frankenphp.go` 中 `calculateMaxThreads` 实现

总览（高层）

- 计算总的 worker 数量并基于 `opt.numThreads`/`opt.maxThreads`/`opt.workers` 确定最终 `num_threads` 和 `max_threads` 的值。
- 校验约束：例如 `num_threads > num_workers`，`max_threads >= num_threads`（除非自动模式）等。
- 支持自动模式：当 `opt.maxThreads < 0` 时启用自动扩展策略。

下面为源码（保留原始格式）并在关键处插入中文注释：

```go
func calculateMaxThreads(opt *opt) (numWorkers int, _ error) {
    maxProcs := runtime.GOMAXPROCS(0) * 2
    maxThreadsFromWorkers := 0

    // 先统计每个 worker 配置，填充默认值并累计 worker 总数
    for i, w := range opt.workers {
        if w.num <= 0 {
            // 如果 worker.num 未显式设置，使用 GOMAXPROCS*2 作为默认值
            // 这是一个经验值，避免 worker 未配置时导致较低并发
            opt.workers[i].num = maxProcs
        }
        metrics.TotalWorkers(w.name, w.num)

        numWorkers += opt.workers[i].num

        // 如果 worker 配置了 maxThreads, 用来累加用于扩展的额外线程数
        if w.maxThreads > 0 {
            if w.maxThreads < w.num {
                return 0, fmt.Errorf("worker max_threads (%d) must be greater or equal to worker num (%d) (%q)", w.maxThreads, w.num, w.fileName)
            }

            if w.maxThreads > opt.maxThreads && opt.maxThreads > 0 {
                return 0, fmt.Errorf("worker max_threads (%d) cannot be greater than total max_threads (%d) (%q)", w.maxThreads, opt.maxThreads, w.fileName)
            }

            // 记录 worker 单独定义的 max_threads 所能提供的额外线程数
            maxThreadsFromWorkers += w.maxThreads - w.num
        }
    }

    // 标志位：用户是否显式设置了 numThreads / maxThreads
    numThreadsIsSet := opt.numThreads > 0
    maxThreadsIsSet := opt.maxThreads != 0
    // 约定：opt.maxThreads < 0 表示自动模式（auto mode）
    maxThreadsIsAuto := opt.maxThreads < 0

    // 如果 max_threads 没有在顶层设置，但某些 worker 定义了 maxThreads，合并这些信息到顶层 maxThreads
    if !maxThreadsIsSet && maxThreadsFromWorkers > 0 {
        maxThreadsIsSet = true
        if numThreadsIsSet {
            opt.maxThreads = opt.numThreads + maxThreadsFromWorkers
        } else {
            // 如果 numThreads 也未设置，基于 worker 总数 + 1（留一条空闲线程）
            opt.maxThreads = numWorkers + 1 + maxThreadsFromWorkers
        }
    }

    // 情形：用户只设置了 num_threads，但未设置 max_threads
    if numThreadsIsSet && !maxThreadsIsSet {
        opt.maxThreads = opt.numThreads
        if opt.numThreads <= numWorkers {
            // num_threads 必须大于 worker 数量（每个 worker 占用至少一个线程）
            return 0, fmt.Errorf("num_threads (%d) must be greater than the number of worker threads (%d)", opt.numThreads, numWorkers)
        }

        return numWorkers, nil
    }

    // 情形：用户只设置了 max_threads，但未设置 num_threads
    if maxThreadsIsSet && !numThreadsIsSet {
        // 默认把 num_threads 设为 worker 总数 + 1
        opt.numThreads = numWorkers + 1
        if !maxThreadsIsAuto && opt.numThreads > opt.maxThreads {
            // 如果不是自动模式，num_threads 不能超过 max_threads
            return 0, fmt.Errorf("max_threads (%d) must be greater than the number of worker threads (%d)", opt.maxThreads, numWorkers)
        }

        return numWorkers, nil
    }

    // 情形：用户既未设置 num_threads 也未设置 max_threads
    if !maxThreadsIsSet && !numThreadsIsSet {
        if numWorkers >= maxProcs {
            // 如果 worker 数 >= maxProcs，至少启动和 worker 数相等的线程，并留一个空闲线程
            opt.numThreads = numWorkers + 1
        } else {
            // 否则使用 maxProcs 作为线程数
            opt.numThreads = maxProcs
        }
        opt.maxThreads = opt.numThreads

        return numWorkers, nil
    }

    // 情形：用户同时设置了 num_threads 和 max_threads
    if opt.numThreads <= numWorkers {
        return 0, fmt.Errorf("num_threads (%d) must be greater than the number of worker threads (%d)", opt.numThreads, numWorkers)
    }

    if !maxThreadsIsAuto && opt.maxThreads < opt.numThreads {
        return 0, fmt.Errorf("max_threads (%d) must be greater than or equal to num_threads (%d)", opt.maxThreads, opt.numThreads)
    }

    return numWorkers, nil
}
```

要点总结

- 如果遇到 `num_threads` / `max_threads` 错误，首先检查是否为未满足约束（如 num_threads 必须大于 worker 总数）。
- 自动模式：`opt.maxThreads < 0` 表示允许 auto 扩展，此时不会严格要求 `max_threads >= num_threads`。
- 默认行为会把未设置的 worker.num 替换为 `GOMAXPROCS * 2`，这可能在 CI/容器中产生意外较高并发，请在配置中显式设置 worker.num 以获得可预测行为。

调试建议

- 在初始化失败时打印 `opt.numThreads`、`opt.maxThreads` 与 `opt.workers`，通常能迅速定位配置不一致。
- 在调试器中设置断点到 `calculateMaxThreads` 的返回点，检查 `numWorkers` 与 `maxThreadsFromWorkers` 的中间值。

文件：`docs/LESSONS/lesson-03-sourcewalkthrough/calculate_max_threads.md`
