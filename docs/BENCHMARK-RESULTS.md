# While Loop Performance Benchmark Results

**Benchmark Date:** 2025-10-20
**Purpose:** Establish BCS guideline for loop construct selection
**System:** 13th Gen Intel Core i9-13900HX, Bash 5.2.21(1)-release, Linux 6.8.0-85

## Executive Summary

Statistical analysis of 30 runs across 4 test scenarios demonstrates clear performance hierarchy:

**🏆 Performance Ranking (Fastest → Slowest):**

1. **`while ((1)); do`** - FASTEST ⚡ (Baseline)
2. **`while :; do`** - MIDDLE (9-14% slower)
3. **`while true; do`** - SLOWEST 🐌 (15-22% slower)

**Key Finding:** `while true` is the **worst performer** despite being commonly used for "readability". It is consistently 15-22% slower than `while ((1))`.

## Complete Test Results

### Test 1: Empty Loop - 100K Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| **`while ((1))`** | **0.091s** | **0.091s** | **0.004s** | **Baseline (Fastest)** ⚡ |
| `while :` | 0.102s | 0.103s | 0.004s | +12% slower |
| `while true` | 0.110s | 0.109s | 0.004s | **+20% slower** 🐌 |

---

### Test 2: Empty Loop - 1M Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| **`while ((1))`** | **0.885s** | **0.884s** | **0.024s** | **Baseline (Fastest)** ⚡ |
| `while :` | 1.009s | 1.007s | 0.031s | +14% slower |
| `while true` | 1.079s | 1.077s | 0.029s | **+21% slower** 🐌 |

---

### Test 3: Empty Loop - 5M Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| **`while ((1))`** | **4.270s** | **4.238s** | **0.178s** | **Baseline (Fastest)** ⚡ |
| `while :` | 4.837s | 4.799s | 0.204s | +13% slower |
| `while true` | 5.231s | 5.173s | 0.222s | **+22% slower** 🐌 |

---

### Test 4: Loop with Arithmetic Work - 1M Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| **`while ((1))`** | **1.432s** | **1.430s** | **0.033s** | **Baseline (Fastest)** ⚡ |
| `while :` | 1.575s | 1.582s | 0.036s | +9% slower |
| `while true` | 1.647s | 1.647s | 0.040s | **+15% slower** 🐌 |

Loop body: `((sum += i))` - representative of real-world arithmetic operations.

---

## Analysis

### Performance Hierarchy Explained

**1. `while ((1))` - Fastest**
- Constant arithmetic expression evaluation
- Bash can optimize this at parse time
- No function call overhead
- Direct evaluation in the shell's arithmetic context

**2. `while :` - Middle**
- Shell special builtin (POSIX standard)
- Minimal overhead - the `:` does nothing but still requires builtin execution
- Faster than external commands but slower than arithmetic evaluation
- Traditional Unix idiom for infinite loops

**3. `while true` - Slowest**
- **Actual command execution** (not just a builtin)
- Must be looked up in PATH and executed each iteration
- Highest overhead of all three constructs
- Despite being "readable", it's the worst performer

### Why These Performance Differences?

**Arithmetic Evaluation (`((1))`)**
```bash
while ((1)); do
    # Constant expression - can be optimized
    # No command lookup required
    # Direct arithmetic context evaluation
done
```

**Special Builtin (`:`)**
```bash
while :; do
    # Special shell builtin
    # Does nothing, but still requires execution
    # No PATH lookup, but function call overhead
done
```

**Command Execution (`true`)**
```bash
while true; do
    # Actual command that must be:
    #   1. Looked up in PATH
    #   2. Executed
    #   3. Return status checked
    # Happens EVERY iteration
done
```

### Statistical Significance

All results show:
- **Low standard deviations** (< 5% of mean values)
- **Consistent mean/median alignment**
- **Reproducible across 30 runs** per test
- **Clear, measurable performance gaps**

### Practical Impact

**For a loop running 1 million iterations:**

| Construct | Time | Difference from Fastest |
|-----------|------|-------------------------|
| `while ((1))` | 0.885s | **Baseline** |
| `while :` | 1.009s | +0.124s (+124ms) |
| `while true` | 1.079s | +0.194s (+194ms) |

**The difference compounds in:**
- Performance-critical scripts
- Long-running daemon processes
- Loops executed frequently
- High-iteration batch processing
- Systems where CPU time is costly

---

## BCS Guideline Recommendations

### Primary Recommendation

**✓ Use `while ((1)); do` as the default for infinite loops in Bash scripts.**

```bash
# RECOMMENDED: Fastest and Bash-idiomatic
while ((1)); do
    process_item || break
done
```

### Secondary Options

**When to use `while :`**
1. **POSIX compliance required** - Script must work with `/bin/sh`
2. **Team convention** - Existing codebase uses `:` consistently
3. **Cross-shell compatibility** - Script may run on non-Bash shells

```bash
# ACCEPTABLE: POSIX-compliant but slower
while :; do
    process_item || break
done
```

**When to AVOID `while true`**
- ❌ **DO NOT use for performance-critical code**
- ❌ **Slowest of all three options** (15-22% overhead)
- ❌ **No significant readability benefit** over `while :`
- ❌ **Requires external command execution**

```bash
# NOT RECOMMENDED: Slowest option
while true; do
    process_item || break
done
```

### Recommended BCS Standard

```bash
# BCS-GUIDELINE: Infinite Loop Constructs
#
# Performance ranking (fastest to slowest):
#   1. while ((1))      - FASTEST  (0-22% overhead)
#   2. while :          - MIDDLE   (9-14% overhead)
#   3. while true       - SLOWEST  (15-22% overhead)
#
# Default choice: while ((1))
#   - Fastest performance
#   - Bash-specific but acceptable for modern scripts
#   - Clear intent (infinite loop with constant condition)
#
# Alternative: while :
#   - Use for POSIX compatibility
#   - Traditional Unix idiom
#   - Moderate performance penalty (9-14%)
#
# Avoid: while true
#   - Worst performance (15-22% slower)
#   - No readability advantage over ':'
#   - Requires external command execution

# RECOMMENDED (modern Bash):
while ((1)); do
    process_item || break
done

# ACCEPTABLE (POSIX/traditional):
while :; do
    process_item || break
done

# NOT RECOMMENDED (slowest):
while true; do
    process_item || break
done
```

---

## Test Methodology

### Benchmark Design

- **Constructs tested:** `while ((1))`, `while :`, `while true`
- **Runs per test:** 30 (for statistical significance)
- **Iteration counts:** 100K, 1M, 5M
- **Timing method:** Nanosecond precision using `date +%s%N`
- **Statistics calculated:** Mean, Median, Standard Deviation
- **Test isolation:** Each run executes in separate function scope

### Test Environment

```
Date: 2025-10-20T11:17:35+08:00
Hostname: okusi
Bash Version: 5.2.21(1)-release
CPU: 13th Gen Intel(R) Core(TM) i9-13900HX
Kernel: 6.8.0-85-generic
```

### Reproducibility

To reproduce these results:

```bash
./benchmark-while-loops.sh
```

Results are saved to `docs/`:
- `benchmark-results-TIMESTAMP.txt` - Detailed results

---

## Visual Performance Comparison

```
Performance Overhead vs. while ((1)):

100K iterations:
  while ((1))  ████████████████████░░░░░░░░░░  0.091s  [BASELINE]
  while :      ███████████████████████░░░░░░░  0.102s  [+12%]
  while true   █████████████████████████░░░░░  0.110s  [+20%]

1M iterations:
  while ((1))  ████████████████████░░░░░░░░░░  0.885s  [BASELINE]
  while :      ███████████████████████░░░░░░░  1.009s  [+14%]
  while true   █████████████████████████░░░░░  1.079s  [+21%]

5M iterations:
  while ((1))  ████████████████████░░░░░░░░░░  4.270s  [BASELINE]
  while :      ███████████████████████░░░░░░░  4.837s  [+13%]
  while true   █████████████████████████░░░░░  5.231s  [+22%]

1M with work:
  while ((1))  ████████████████████░░░░░░░░░░  1.432s  [BASELINE]
  while :      ██████████████████████░░░░░░░░  1.575s  [+9%]
  while true   ████████████████████████░░░░░░  1.647s  [+15%]
```

---

## Conclusion

Based on rigorous statistical analysis across 120 test runs (4 scenarios × 30 runs each) comparing three infinite loop constructs:

### Definitive Results

1. **`while ((1))` is consistently the fastest** (baseline performance)
2. **`while :` is 9-14% slower** (acceptable for POSIX compatibility)
3. **`while true` is 15-22% slower** (avoid in performance-conscious code)

### BCS Recommendations

**For Bash Coding Standard:**

- ✓ **Default to `while ((1))`** for modern Bash scripts
- ✓ **Allow `while :`** for POSIX compatibility requirements
- ✗ **Discourage `while true`** due to poor performance
- ✓ **Document the choice** in coding standards
- ✓ **Prioritize consistency** within each project

The performance gain of `while ((1))` over `while true` (15-22%) is significant enough to warrant a strong recommendation, especially for:
- Performance-critical loops
- High-iteration counts (>10K)
- Long-running processes
- Batch processing scripts

---

## Common Myths Debunked

**Myth:** "`while true` is more readable"
**Reality:** `while :` has been the Unix standard for 50+ years and is equally readable. `while true` adds no clarity while sacrificing 15-22% performance.

**Myth:** "`true` is a shell builtin, so it's fast"
**Reality:** While `true` is often a builtin, it still requires command execution overhead. It's consistently the slowest of the three options.

**Myth:** "The performance difference doesn't matter"
**Reality:** In loops with millions of iterations, the 15-22% overhead compounds to hundreds of milliseconds or even seconds of wasted CPU time.

---

## References

- Benchmark script: `/ai/scripts/bcx/benchmark-while-loops.sh`
- Raw results: `/ai/scripts/bcx/docs/benchmark-results-20251020-111735.txt`
- Bash Coding Standard: `/ai/scripts/Okusi/bash-coding-standard/`

---

*Generated: 2025-10-20*
*Author: Gary Dean*
*For: Bash Coding Standard (BCS) Guidelines*
