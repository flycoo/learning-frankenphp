# FrankenPHP Source Study Guide

This environment is configured to study, compile, and debug FrankenPHP using VS Code.

## 1. Prerequisites / Dependencies

Before running or compiling, you must install the necessary dependencies (C compiler, PHP source, etc.).
A script is provided to automate this.

**Action:** Run the VS Code Task: `install-deps` (Terminal > Run Task > install-deps).
*Note: This process compiles PHP from source and may take 10-20 minutes.*

## 2. Compilation

FrankenPHP is a Caddy module. You can build it using Go.

**Action:** Run the VS Code Task: `build-frankenphp` (Terminal > Run Task > build-frankenphp).
This will produce a `frankenphp` binary in `frankenphp/caddy/frankenphp/`.

## 3. Debugging (Breakpoints)

You can debug the Go code and the Caddy integration directly in VS Code.
Open the Debug view (Ctrl+Shift+D) and select one of the configurations:

### A. Launch FrankenPHP (Caddy)
*   **Description**: Runs FrankenPHP in standard mode acting as a web server.
*   **Context**: Uses `frankenphp/testdata/Caddyfile`.
*   **How to verify**: 
    1. Set a breakpoint in `frankenphp.go` or any relevant file.
    2. Start debugging.
    3. Open a terminal and `curl http://127.0.0.1:80/phpinfo.php` (or open in browser if port forwarded).

### B. Launch FrankenPHP (Worker Mode)
*   **Description**: Runs FrankenPHP in worker mode (high performance).
*   **Context**: Uses `docs/demos/worker.Caddyfile` which points to `frankenphp/testdata/worker.php`.
*   **Demo Logic**: The Caddyfile rewrites all requests to `/worker.php` so that the worker (which is configured for that file) picks them up.
*   **How to verify**:
    1. Set a breakpoint in `worker.go` or `frankenphp/testdata/worker.php`.
    2. Start debugging.
    3. `curl http://127.0.0.1:80/` -> Should see "Requests handled: ..." output.

### C. Launch Test Server
*   **Description**: Runs a minimal Go server embedding FrankenPHP, without Caddy.
*   **Context**: Code in `internal/testserver`.
*   **Port**: 8080.

## 4. Source Code Structure

*   `/frankenphp`: Core Go library and C bindings.
*   `/frankenphp/caddy`: Caddy module adapter.
*   `/frankenphp/internal`: Internal utilities.
*   `/frankenphp/testdata`: PHP scripts for testing.

## 5. Architecture & Flow

*   [Worker Mode Engine Flow (Chinese)](architecture_worker.md): Detailed explanation of the Go <-> C <-> PHP lifecycle in worker mode.

## 6. Demos

*   **Standard Mode**: See `frankenphp/testdata/Caddyfile`
*   **Worker Mode**: See `docs/demos/worker.Caddyfile` and `frankenphp/testdata/worker.php`

## Tips

*   The `install_deps.sh` script compiles PHP with `--enable-debug`, allowing you to inspect C structures if you step deep enough (requires GDB/C knowledge and proper VS Code C++ setup, but this setup focuses on Go debugging).
*   `CGO_CFLAGS` and `CGO_LDFLAGS` are configured in `launch.json` to point to the correct PHP include paths and library paths in `/usr/local`.

## 7. Troubleshooting

See [docs/troubleshooting.md](troubleshooting.md) for common build issues.


