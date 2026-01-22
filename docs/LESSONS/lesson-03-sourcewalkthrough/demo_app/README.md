# FrankenPHP Lesson 03 — Demos

This folder contains two demos demonstrating the `Option` pattern:

- `demo_app` (demo1): a self-contained demo package that mimics the `Option`/`WorkerOption` API and runs without depending on the repository's `frankenphp` C/CGO code.
- `demo2`: a demo that imports the repository's `frankenphp` module (`github.com/dunglas/frankenphp`) and calls `Init` directly. Building `demo2` uses the workspace `go.work` to pick the local `./frankenphp` module; building may require native PHP headers and CGO setup.

Run demo1 (standalone):

```bash
cd docs/LESSONS/lesson-03-sourcewalkthrough/demo_app
GOWORK=off go run .
```

Run demo2 (uses local `frankenphp` workspace module):

```bash
cd docs/LESSONS/lesson-03-sourcewalkthrough/demo_app/demo2
# Use the helper to detect PHP headers and export CGO flags, then run demo2.
# Example: detect and print flags
../setup_env.sh

# Or detect and run the demo in one step
../setup_env.sh ./run_demo2.sh
```

Notes:
- If `go run` for `demo2` fails, it's likely because `frankenphp` requires CGO and PHP development headers. Run `./docs/scripts/install_deps.sh` first and ensure your environment satisfies `frankenphp` build requirements.
