# While Loop Performance Benchmark Results

**Benchmark Date:** 2025-10-20
**Purpose:** Establish BCS guideline for loop construct selection
**System:** 13th Gen Intel Core i9-13900HX, Bash 5.2.21(1)-release, Linux 6.8.0-85

## Executive Summary

Statistical analysis of 30 runs across 4 test scenarios demonstrates that **`while ((1)); do` is consistently 10-14% faster than `while :; do`** in Bash 5.2.21.

This performance advantage:
- ◉ Is statistically significant across all iteration counts
- ◉ Persists even when loops contain actual work
- ◉ Shows low variance (highly reliable results)
- ◉ Exceeds the 5% threshold for performance recommendations

## Test Results

### Test 1: Empty Loop - 100K Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| `while ((1))` | 0.088s | 0.088s | 0.003s | **Baseline** |
| `while :` | 0.098s | 0.097s | 0.004s | +11% slower |

**Finding:** `while ((1))` is **11% faster**

---

### Test 2: Empty Loop - 1M Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| `while ((1))` | 0.828s | 0.826s | 0.010s | **Baseline** |
| `while :` | 0.937s | 0.935s | 0.014s | +13% slower |

**Finding:** `while ((1))` is **13% faster**

---

### Test 3: Empty Loop - 10M Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| `while ((1))` | 8.384s | 8.217s | 0.317s | **Baseline** |
| `while :` | 9.579s | 9.507s | 0.331s | +14% slower |

**Finding:** `while ((1))` is **14% faster**

---

### Test 4: Loop with Arithmetic Work - 1M Iterations

| Construct | Mean | Median | StdDev | Relative Performance |
|-----------|------|--------|--------|----------------------|
| `while ((1))` | 1.531s | 1.525s | 0.043s | **Baseline** |
| `while :` | 1.694s | 1.690s | 0.044s | +10% slower |

**Finding:** `while ((1))` is **10% faster**

Loop body: `((sum += i))` - representative of real-world arithmetic operations.

---

## Analysis

### Why is `while ((1))` Faster?

1. **Constant Evaluation Optimization**
   - `((1))` is a constant arithmetic expression that Bash can optimize
   - May be evaluated once at parse time rather than per iteration
   - No builtin function call overhead

2. **Builtin Overhead**
   - `:` is a builtin command that requires execution stack setup
   - Even though `:` does nothing, it still has call overhead
   - Function call occurs millions of times in tight loops

3. **Consistency Across Scenarios**
   - Performance advantage holds at all scales (100K to 10M iterations)
   - Advantage persists even with work inside loop body
   - This indicates the overhead is in loop condition evaluation, not elsewhere

### Statistical Significance

All results show:
- **Low standard deviations** (< 4% of mean values)
- **Consistent mean/median alignment** (< 2% difference)
- **Reproducible across 30 runs** per test
- **Clear performance gap** (10-14%, well above noise threshold)

### Practical Impact

For a loop that runs **1 million iterations**:
- `while ((1))`: 0.828 seconds
- `while :`: 0.937 seconds
- **Savings: 0.109 seconds (109 milliseconds)**

This difference compounds in:
- Performance-critical scripts
- Long-running processes
- Loops executed frequently
- Systems where CPU time is costly

---

## BCS Guideline Recommendations

### Primary Recommendation

**Use `while ((1)); do` for infinite loops in performance-conscious code.**

```bash
# Recommended for BCS-compliant scripts
while ((1)); do
    # loop body
    some_condition && break
done
```

### Secondary Considerations

**When to use `while :`:**
1. **POSIX compliance required** - `((1))` is Bash-specific
2. **Code readability priority** - `:` is more traditional and recognizable
3. **Non-performance-critical scripts** - Difference is negligible for short loops
4. **Team style guidelines** - Existing codebase uses `:` consistently

**When to use `while ((1))`:**
1. **Performance-critical code** - Loops with >10K iterations
2. **Bash-specific scripts** - Already using Bash features
3. **Tight loops** - Minimal work per iteration amplifies the difference
4. **BCS-compliant projects** - Following modern Bash best practices

### Recommended BCS Standard

```bash
# BCS-GUIDELINE: Loop Constructs
#
# For infinite loops, prefer while ((1)) over while : for performance.
# Performance gain: 10-14% across various iteration counts.
#
# Use while ((1)) when:
#   - Script uses other Bash-specific features (already non-POSIX)
#   - Loop will execute many iterations (>10,000)
#   - Performance matters for the use case
#
# Use while : when:
#   - POSIX compliance is required
#   - Script must work with /bin/sh
#   - Readability/tradition is prioritized over performance
#   - Loop iterations are minimal (<1,000)

# Recommended (modern Bash):
while ((1)); do
    process_item || break
done

# Acceptable (POSIX/traditional):
while :; do
    process_item || break
done

# Note: Both constructs are valid. Choose based on project requirements.
```

---

## Test Methodology

### Benchmark Design

- **Runs per test:** 30 (for statistical significance)
- **Iteration counts:** 100K, 1M, 10M
- **Timing method:** Nanosecond precision using `date +%s%N`
- **Statistics calculated:** Mean, Median, Standard Deviation
- **Test isolation:** Each run executes in separate function scope

### Test Environment

```
Date: 2025-10-20T10:44:21+08:00
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

Results are saved to timestamped files:
- `benchmark-results-TIMESTAMP.txt` - Detailed results

---

## Conclusion

Based on rigorous statistical analysis across 120 test runs (4 scenarios × 30 runs each), **`while ((1)); do` is demonstrably faster than `while :; do`** with a consistent 10-14% performance advantage.

For Bash Coding Standard (BCS) compliance, we recommend:
- **Default to `while ((1))`** for modern Bash scripts
- **Document the choice** in coding standards
- **Allow `while :`** for POSIX compatibility requirements
- **Prioritize consistency** within each project

The performance gain is significant enough to warrant a standard recommendation while still allowing flexibility for specific use cases requiring POSIX compliance.

---

## References

- Benchmark script: `/ai/scripts/bcx/benchmark-while-loops.sh`
- Raw results: `/ai/scripts/bcx/benchmark-results-20251020-104421.txt`
- Bash Coding Standard: `/ai/scripts/Okusi/bash-coding-standard/`

---

*Generated: 2025-10-20*
*Author: Gary Dean*
*For: Bash Coding Standard (BCS) Guidelines*
