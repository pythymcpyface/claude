### Rust
- Follow Rust API guidelines
- Use `Result` for recoverable errors, `panic!` only for bugs
- Prefer `&str` over `String` in function parameters
- Use `clippy` warnings as errors
- Document public APIs with `///` comments

### Commands
```bash
cargo run            # Run project
cargo build --release # Production build
cargo test           # Run tests
cargo clippy         # Lint
cargo fmt            # Format
```
