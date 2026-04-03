# tests/README.md – Testing Strategy & Usage Guide

## Testing Philosophy

This repository uses **testthat** for comprehensive testing covering:

1. **Unit Tests** – Individual database helper functions work correctly in isolation
2. **Integration Tests** – Full analysis pipeline (data → cJS model → corrections → results) works end-to-end
3. **Snapshot Tests** – Output structures are captured and validate against unexpected changes
4. **Validation Tests** – Results check against known properties (e.g., survival estimates in [0,1])

**Focus:** Per `about-me.md`, we prefer **integration tests over mocks** and validate against **biological benchmarks** (cbrATLAS published vignette examples).

---

## Test Structure

```
tests/
├── README.md                          # This file
├── testthat.R                         # Runner script (sources and executes all tests)
└── testthat/
    ├── test_helpers.R                 # Test utilities, fixtures, custom assertions
    ├── test_db_helpers.R              # Unit & integration tests for database functions
    ├── test_cbratlas_integration.R    # Integration tests for cbrATLAS analysis pipeline
    └── _snaps/                        # Snapshot test outputs (auto-generated)
        └── test_cbratlas_integration_ # Snapshots by test variant
```

---

## Running Tests

### Run All Tests
```r
# Option 1: From project root
testthat::test_dir("tests/testthat")

# Option 2: Using runner script
source("tests/testthat.R")

# Option 3: In DataSpell/RStudio
# Use Test menu → Run All Tests (if configured)
```

### Run Specific Test File
```r
testthat::test_file("tests/testthat/test_db_helpers.R")
```

### Run Single Test
```r
testthat::test_that("init_analysis_db.fn creates database with correct schema", {
  # Test code...
})
```

### Run with Coverage Report
```r
library(covr)
coverage <- code_coverage(
  source_file = "R/db_helpers.R",
  test_files = "tests/testthat/test_db_helpers.R"
)
print(coverage)
```

---

## Test Categories

### 1. Unit Tests: Database Functions (test_db_helpers.R)

**What's tested:**
- `init_analysis_db.fn()` – Schema creation, all tables exist with correct columns
- `log_analysis_run.fn()` – Run metadata insertion, timestamp format
- `save_survival_estimates.fn()` – Column validation, data insertion, foreign key constraints
- `save_corrected_estimates.fn()` – Corrected estimate insertion
- `save_bootstrap_results.fn()` – Bootstrap result insertion
- `complete_analysis_run.fn()` – Status update from in_progress → completed
- `get_all_runs.fn()` – Query ordering by timestamp DESC
- `get_run_estimates.fn()` – Filtering by run_id and estimate_type

**Example:**
```r
test_that("log_analysis_run.fn inserts run metadata", {
  temp_db <- tempfile(fileext = ".db")
  init_analysis_db.fn(temp_db)
  
  log_analysis_run.fn(
    run_id = "test-001",
    analysis_type = "single_release",
    dataset_name = "test",
    db_path = temp_db
  )
  
  # Verify insert
  con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
  runs <- DBI::dbGetQuery(con, "SELECT * FROM analysis_runs WHERE run_id = 'test-001'")
  DBI::dbDisconnect(con)
  
  expect_equal(nrow(runs), 1)
  expect_equal(runs$analysis_type, "single_release")
})
```

### 2. Integration Tests: cbrATLAS Analysis (test_cbratlas_integration.R)

**What's tested:**
- Sample data fixtures generate reproducible, valid capture histories
- `cbrATLAS::cjs.fn()` returns expected structure (estimates, SE, convergence)
- Survival estimates are valid (in [0,1] range)
- Bootstrap resampling produces valid CI structures
- Tag-life correction pipeline interfaces correctly
- Full workflow: data → raw estimates → corrected estimates → database storage

**Example:**
```r
test_that("cjs.fn returns expected structure", {
  capture_data <- create_sample_capture_data.fn(n_individuals = 30, n_occasions = 8)
  
  result <- cjs.fn(
    data = capture_data,
    Phi.estim = ~1,
    p.estim = ~t,
    time.interval = rep(1, 7)
  )
  
  expect_cjs_result_structure.fn(result)
  expect_true(all(result$estimates >= 0 & result$estimates <= 1))
})
```

### 3. Snapshot Tests

**What's tested:**
- Analysis outputs (survival estimates, correction results) match previously captured snapshots
- Detects unintended changes in output structure or values
- Variants by cbrATLAS version for compatibility tracking

**Example:**
```r
test_that("Analysis pipeline snapshot: raw estimates are reproducible", {
  capture_data <- create_sample_capture_data.fn(n_individuals = 25, n_occasions = 7)
  result <- cjs.fn(data = capture_data, ...)
  
  expect_snapshot(result$estimates)
})
```

**Update snapshots after intentional changes:**
```r
testthat::snapshot_accept("test_cbratlas_integration")
```

---

## Custom Test Assertions

Defined in `test_helpers.R`:

| Assertion | Purpose |
|-----------|---------|
| `expect_cjs_result_structure.fn()` | Validates result has estimates, SE, convergence |
| `expect_valid_estimates.fn()` | Checks no NAs/NaNs, all values in [0,1] |
| `expect_db_operation.fn()` | Verifies database insert/update succeeded |

**Example usage:**
```r
expect_cjs_result_structure.fn(result)
expect_valid_estimates.fn(estimates_df, col_names = c("phi_estimate", "corrected_phi"))
expect_db_operation.fn("run-001", "survival_estimates")
```

---

## Test Fixtures

Defined in `test_helpers.R`:

| Fixture | Purpose | Default |
|---------|---------|---------|
| `create_sample_capture_data.fn()` | Reproducible capture history | 50 individuals, 10 occasions |
| `create_sample_tag_life_data.fn()` | Reproducible tag-life data | 100 tags, gamma distribution |

**Example:**
```r
capture_data <- create_sample_capture_data.fn(n_individuals = 50, n_occasions = 10)
tag_life_data <- create_sample_tag_life_data.fn(n_tags = 100, max_days = 365)
```

---

## Extending Tests

### Add Unit Test for New Helper Function

1. Create `test_<function_name>.R` in `tests/testthat/`
2. Use `test_that()` for each behavior
3. Use temp files for database tests: `tempfile(fileext = ".db")`

### Add Integration Test for New Analysis

1. Add to `test_cbratlas_integration.R` or create `test_<analysis_type>.R`
2. Use sample data fixtures
3. Run full pipeline and validate outputs
4. Log results to database and verify storage

### Add Snapshot Test

```r
test_that("New analysis output matches snapshot", {
  result <- my_new_function(data)
  expect_snapshot(result$output)
})
```

Then run `testthat::snapshot_accept()` to record snapshots.

---

## CI/CD Integration (Optional)

### GitHub Actions Example

Create `.github/workflows/test.yml`:
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        r-version: ['4.1', '4.2', '4.3']
    steps:
      - uses: actions/checkout@v2
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: ${{ matrix.r-version }}
      - run: Rscript -e 'install.packages("testthat")'
      - run: Rscript tests/testthat.R
```

---

## Troubleshooting

### "cbrATLAS not installed"
```r
# Install from GitHub
install.packages("devtools")
devtools::install_github("Columbia-Basin-Research-West/cbrATLAS")
```

### Snapshot mismatch
```r
# Review snapshot changes
testthat::snapshot_review("test_cbratlas_integration")

# Accept changes (after verifying intentional)
testthat::snapshot_accept("test_cbratlas_integration")
```

### Test timeout
If bootstrap tests timeout, reduce `n.bootstrap`:
```r
boot_result <- boot.L(..., n.bootstrap = 50)  # Fast for tests
```

---

## Dependencies

**Required for running tests:**
- `testthat` (>= 3.0) – Testing framework
- `DBI`, `RSQLite` – Database testing
- `cbrATLAS` – For integration tests

**Optional:**
- `withr` – Temporary environment management
- `covr` – Code coverage reporting
- `mockery` – Mocking (rarely used per about-me.md)

**Install:**
```r
install.packages(c("testthat", "DBI", "RSQLite", "withr", "covr"))
```

---

## Best Practices

✅ **DO:**
- Use meaningful test names: `test_that("function does X when given Y", ...)`
- Use fixtures for reproducible data
- Test both happy path and error cases
- Validate outputs against known properties
- Update snapshots when intentional changes occur
- Run tests before committing changes

❌ **DON'T:**
- Use `set.seed()` randomly; document why if used
- Write overly narrow tests (brittle to refactoring)
- Mock cbrATLAS functions; prefer integration tests with real data
- Ignore test failures; understand why before proceeding
- Commit snapshot files without review

---

**Last Updated:** 2026-04-03  
**Test Framework:** testthat (>= 3.0)  
**Tested Packages:** cbrATLAS (0.2.0.0+)
