### Go
- Follow Effective Go guidelines
- Use `error` return values, not panics
- Keep interfaces small (1-3 methods)
- Use `context.Context` for cancellation
- Table-driven tests

### Commands
```bash
go run .             # Run project
go build             # Build
go test ./...        # Run tests
go vet ./...         # Static analysis
golangci-lint run    # Lint
```
