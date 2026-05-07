# bcx

**Terminal calculator for floating-point expressions with interactive REPL**

A Bash wrapper around `bc` that fixes its poor terminal UX by providing readline history, proper Ctrl-C handling, and a clean REPL interface.

**GitHub**: [Open-Technology-Foundation/bcx](https://github.com/Open-Technology-Foundation/bcx)

## Features

- **Interactive REPL** with readline history (arrow keys, Ctrl-R search)
- **Single-expression mode** for quick calculations
- **Persistent command history** (`~/.bcx_history`)
- **x → * conversion** in terminal mode (e.g., `3x4` becomes `3*4`)
- **Clean error handling** with clear feedback
- **Math library** support (sqrt, sin, cos, etc.)

## Installation

```bash
# Copy to system path
sudo cp bcx /usr/local/bin/
sudo chmod +x /usr/local/bin/bcx

# Optional: Install bash completion
sudo cp .bash_completion /etc/bash_completion.d/bcx

# Optional: Create alias for quick access
echo "alias ?='bcx'" >> ~/.bashrc
```

## Usage

```
bcx [-h|--help] [-V|--version] [--] [expression...]
```

| Flag | Action |
|------|--------|
| `-h`, `--help` | Print help (adapts to invocation name) and exit `0` |
| `-V`, `--version` | Print `<name> <version>` and exit `0` |
| `--` | End-of-options marker; everything after is expression |

Multiple args are joined and spaces stripped before evaluation, so
`bcx 23 x 42`, `bcx 23x42`, and `bcx "23 * 42"` are equivalent in
terminal mode.

Expressions starting with `-` (negative numbers, etc.) must be preceded
by `--` so the parser does not mistake them for unknown options:

```bash
bcx -- -3+5      # → 2
bcx -3+5         # ✗ Invalid option '-3+5' (exit 22)
```

Help and version output reflect the actual invocation name. Run via the
`?` alias (or any symlink) and the synopsis updates accordingly:

```text
$ ? -h
? 1.0.0 - terminal calculator for floating point expressions
...
Usage: ? [-h|--help] [-V|--version] [--] [expression...]
```

### Mode behaviour

| Stdout    | Args | Behaviour                                              |
|-----------|------|--------------------------------------------------------|
| Terminal  | yes  | Echo `> expr` to stderr, evaluate, **enter REPL**      |
| Terminal  | no   | Enter REPL immediately                                 |
| Pipe/file | yes  | Evaluate once, print result, exit (`22` on bc error)   |
| Pipe/file | no   | Print help to stderr, exit `2`                         |

The `x → *` substitution applies only in terminal mode at the command line —
not inside the REPL, where `*` is required.

**Terminal — REPL after one-shot eval:**
```bash
$ bcx "3.14 * 2"
> 3.14*2
6.28
> sqrt(144)
12
>                             # empty line or Ctrl-D exits
```

**Terminal — interactive REPL only:**
```bash
$ bcx
> 2 + 2
4
> sqrt(16)
4.00000000000000000000
>
```

**Pipe / capture (one-shot, no REPL):**
```bash
result=$(bcx "42 * 72 / 3.14")
echo "Result: $result"

bcx "sqrt(144)" | tee result.txt
```

**As command alias:**
```bash
? 23x42                     # quick calculation (terminal: x → *)
? "scale=4; 22/7"           # pi approximation
```

### REPL Controls

| Key | Action |
|-----|--------|
| Ctrl-D or empty line | Exit (code 0) |
| Ctrl-C | Exit (code 130) |
| ↑/↓ | History navigation |
| Ctrl-R | Reverse history search |

### Exit Codes

Canonical [BCS exit codes](https://github.com/Open-Technology-Foundation/bash-coding-standard) are used.

| Code | Symbol       | Meaning                                                          |
|------|--------------|------------------------------------------------------------------|
| 0    | SUCCESS      | Normal exit (REPL via Ctrl-D / empty line, or successful eval)   |
| 2    | ERR_USAGE    | No args supplied to a pipe (help printed to stderr)              |
| 5    | ERR_IO       | Could not create temporary error-capture file                    |
| 18   | ERR_NODEP    | `bc` binary not found on PATH                                    |
| 22   | ERR_INVAL    | bc emitted a parse / runtime diagnostic in one-shot mode         |
| 130  | (signal)     | REPL interrupted with Ctrl-C                                     |

REPL evaluation errors are reported but do **not** affect the exit code —
exit status reflects how the session ended, not what happened during it.

## Requirements

- Bash 4.4+ — uses `shopt -s inherit_errexit` and `${var@Q}` quoting
- `bc` calculator (invoked with `--mathlib` for sqrt/sin/cos/etc.)
- POSIX `mktemp` (for the per-run error-capture file)

History is persisted to `~/.bcx_history` (`HISTSIZE=1000`).

## BCS Compliance

This script follows the [Bash Coding Standard](https://github.com/Open-Technology-Foundation/bash-coding-standard) with proper error handling, readonly constants, and structured organization.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

GNU General Public License v3.0 - see [LICENSE](LICENSE).

## Author

Gary Dean | [garydean.id](https://garydean.id)
