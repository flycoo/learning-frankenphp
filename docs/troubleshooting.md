
## 6. Troubleshooting

### Compilation Errors

If you see errors like:
*   `php_variables.h: No such file or directory`
*   `undefined reference to tsrm_get_ls_cache`

This is because the build process needs to know where the custom PHP headers and libraries are installed.

*   **Solution**: The `.vscode/launch.json` and `.vscode/tasks.json` have been configured to automatically include `CGO_CFLAGS` and `CGO_LDFLAGS` pointing to `/usr/local/include/php...` and `/usr/local/lib`.
*   If you build manually in the terminal, you must export these variables:

```bash
export CGO_CFLAGS=$(php-config --includes)
export CGO_LDFLAGS="-L/usr/local/lib"
go build ...
```

### Module Errors

If you see `main module ... does not contain package ...`:
*   Ensure that both `frankenphp` and `frankenphp/caddy` are in your `go.work`.
*   This environment has initialized `go.work` to include both.
