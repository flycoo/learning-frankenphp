#!/bin/sh
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)

cat <<'EOF'
pprof 使用说明（示例步骤）

1) 构建 demo 可执行文件（例如 demo_move_flags_split）：

  cd docs/LESSONS/lesson-04-cgo/demo_move_flags_split
  sh build.sh

2) 如果要收集 CPU profile，建议在程序中使用 `net/http/pprof` 或 `runtime/pprof` 输出 profile 文件，示例代码：

  import _ "net/http/pprof"
  go func() { log.Println(http.ListenAndServe(":6060", nil)) }()

 然后在运行中的进程上使用 `go tool pprof`：

  go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

3) 另一个方式是让程序在运行时写出 profile 文件：

  import "runtime/pprof"
  f, _ := os.Create("cpu.prof")
  pprof.StartCPUProfile(f)
  defer pprof.StopCPUProfile()

  运行结束后用：
  go tool pprof -http=:8080 ./your-binary cpu.prof

4) 本脚本仅提供步骤说明；若要我为某个 demo 自动集成 pprof 支持并生成示例 profile 文件，我可以帮你修改 demo 代码并添加收集脚本。
EOF
