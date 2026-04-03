# Testing Infrastructure Complete

## ✅ What Was Created

### Testing Structure
```
tests/
├── README.md                          # Complete testing guide (8.9 KB)
├── DATASPELL_GUIDE.md                 # IDE-specific test execution tips
├── setup_tests.R                      # Test dependency installer
├── testthat.R                         # Test runner script
└── testthat/
    ├── test_helpers.R                 # Fixtures, assertions, utilities
    ├── test_db_helpers.R              # Unit tests for database functions
    ├── test_cbratlas_integration.R    # Integration tests for analysis pipeline
    └── _snaps/                        # Auto-generated snapshot outputs (after first run)
```

### Test Files Created

| File | Tests | Purpose |
|------|-------|---------|
| **test_helpers.R** | Fixtures | Reproducible sample data, custom assertions |
| **test_db_helpers.R** | 8 unit tests | Database initialization, insert, query, update |
| **test_cbratlas_integration.R** | 10 integration tests | Full cbrATLAS workflow, snapshots, pipeline validation |

---

## 📋 What Gets Tested

### Unit Tests (Database Layer)
✅ Schema creation with correct tables and columns  
✅ Run metadata insertion and retrieval  
✅ Column validation (catches malformed input)  
✅ Survival estimate storage and retrieval  
✅ Corrected estimate storage and retrieval  
✅ Bootstrap result storage and retrieval  
✅ Status updates (in_progress → completed)  
✅ Query ordering and filtering  

### Integration Tests (Analysis Pipeline)
✅ Sample data fixtures are reproducible and valid  
✅ cbrATLAS functions load and are callable  
✅ `cjs.fn()` returns expected structure  
✅ Survival estimates are valid (in [0,1] range)  
✅ Bootstrap resampling produces valid CI structures  
✅ Correction pipeline interfaces correctly  
✅ Full workflow: data → raw estimates → database storage  
✅ Output snapshots capture and validate structure  
✅ Reproducibility: fixed seeds produce consistent results  

---

## 🚀 Quick Start

### Install Test Dependencies
```r
source("tests/setup_tests.R")
setup_testing_environment()

# Or manually:
install.packages(c("testthat", "DBI", "RSQLite", "withr", "covr"))
```

### Run All Tests
```r
testthat::test_dir("tests/testthat")
```

### Run Specific Test File
```r
testthat::test_file("tests/testthat/test_db_helpers.R")
testthat::test_file("tests/testthat/test_cbratlas_integration.R")
```

### Run Single Test
```r
testthat::test_that("Database initialization works", {
  # test code runs here
})
```

### Generate Coverage Report
```r
library(covr)
cov <- file_coverage("R/db_helpers.R", "tests/testthat/test_db_helpers.R")
print(cov)
```

---

## 🧩 Custom Test Helpers

All in `tests/testthat/test_helpers.R`:

### Fixtures (Reproducible Test Data)
```r
# Sample capture history (50 individuals, 10 occasions by default)
capture_data <- create_sample_capture_data.fn(n_individuals = 50, n_occasions = 10)

# Sample tag-life data (100 tags, gamma-distributed failure times)
tag_life_data <- create_sample_tag_life_data.fn(n_tags = 100, max_days = 365)
```

### Custom Assertions
```r
# Validate CJS result has proper structure (estimates, SE, convergence)
expect_cjs_result_structure.fn(result)

# Check estimates are valid: no NAs/NaNs, all in [0,1]
expect_valid_estimates.fn(estimates_df, col_names = c("phi_estimate", "corrected_phi"))

# Verify database operation succeeded
expect_db_operation.fn(run_id = "run-001", table_name = "survival_estimates")
```

### Helper Functions
```r
# Extract estimates from result list
est <- extract_estimates.fn(result, occasion = 1)

# Compare two analysis runs (for regression testing)
comparison <- compare_estimates.fn(run_1_results, run_2_results, tolerance = 1e-6)
```

---

## 📚 Testing Philosophy

Per `about-me.md`:
- ✅ **Integration tests over mocks** – Use real cbrATLAS functions with actual data
- ✅ **Validate against benchmarks** – Check survival estimates in [0,1], convergence
- ✅ **Reproducibility** – Fixed seeds, documented fixtures, snapshot tracking
- ✅ **Evidence-based** – Test actual output, not just "did it run"

**NO mocking cbrATLAS functions.** Tests use real package functions with sample data.

---

## 📖 Test Coverage Overview

### Database Helper Functions (test_db_helpers.R)
```
init_analysis_db.fn
├─ Creates database ✓
├─ Creates all 4 tables ✓
├─ Correct schema ✓

log_analysis_run.fn
├─ Inserts run metadata ✓
├─ Validates required fields ✓

save_survival_estimates.fn
├─ Validates columns ✓
├─ Inserts estimates ✓
├─ Foreign key constraints ✓

save_corrected_estimates.fn
├─ Inserts corrected estimates ✓

save_bootstrap_results.fn
├─ Inserts bootstrap results ✓

complete_analysis_run.fn
├─ Updates status ✓

get_all_runs.fn
├─ Retrieves all runs ✓
├─ Orders by timestamp DESC ✓

get_run_estimates.fn
├─ Filters by run_id ✓
├─ Filters by estimate_type ✓
```

### cbrATLAS Analysis Pipeline (test_cbratlas_integration.R)
```
Sample Data
├─ Capture history fixture ✓
├─ Tag-life fixture ✓

cbrATLAS Functions
├─ Package loads ✓
├─ Functions callable ✓

Analysis
├─ CJS analysis runs ✓
├─ Results have proper structure ✓
├─ Estimates are valid ✓
├─ Snapshots capture output ✓

Bootstrap
├─ Bootstrap produces CI ✓

Corrections
├─ Correction pipeline ready ✓

Database Integration
├─ Results log to database ✓
├─ Metadata captures properly ✓
```

---

## 🔄 Snapshot Testing

Snapshots capture output structure and values, detecting unintended changes:

```r
# First run: Snapshot is created
expect_snapshot(result$estimates)

# Subsequent runs: Result compared to snapshot
# If different, test fails with visual diff

# After intentional changes, update:
testthat::snapshot_accept("test_cbratlas_integration")
```

Snapshots stored in `tests/testthat/_snaps/` (auto-generated).

---

## 🛠️ Extending Tests

### Add Unit Test for New Database Function
```r
# In test_db_helpers.R:
test_that("new_db_function.fn works correctly", {
  temp_db <- tempfile(fileext = ".db")
  init_analysis_db.fn(temp_db)
  
  # Test code...
  
  file.remove(temp_db)
})
```

### Add Integration Test for New Analysis
```r
# In test_cbratlas_integration.R:
test_that("new analysis workflow produces valid output", {
  capture_data <- create_sample_capture_data.fn(n_individuals = 30, n_occasions = 8)
  result <- my_analysis.fn(capture_data)
  
  expect_cjs_result_structure.fn(result)
  expect_valid_estimates.fn(result$estimates)
})
```

### Add Snapshot for Output Validation
```r
test_that("new analysis snapshot", {
  result <- my_analysis.fn(data)
  expect_snapshot(result)
})
```

---

## 📋 Dependencies

**Required:**
- `testthat` (>= 3.0) – Testing framework
- `DBI`, `RSQLite` – Database operations
- `cbrATLAS` (>= 0.2.0.0) – Analysis package

**Optional:**
- `withr` – Temporary environment management
- `covr` – Code coverage reporting

**Install all:**
```r
install.packages(c("testthat", "DBI", "RSQLite", "withr", "covr"))
devtools::install_github("Columbia-Basin-Research-West/cbrATLAS")
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `tests/README.md` | Complete testing guide with philosophy, structure, examples |
| `tests/DATASPELL_GUIDE.md` | IDE-specific tips for running tests in DataSpell |
| `tests/setup_tests.R` | Automated setup for test environment |
| `.github/copilot-instructions.md` | Updated with testing strategy section |

---

## ✅ Next Steps

1. **Install test dependencies:**
   ```r
   source("tests/setup_tests.R")
   setup_testing_environment()
   ```

2. **Run all tests:**
   ```r
   testthat::test_dir("tests/testthat")
   ```

3. **Review test results** – All tests should pass ✓

4. **Explore tests/README.md** – Full testing guide with examples

5. **Write tests for analysis scripts** – Add to `tests/testthat/` as you create analyses

6. **Update snapshots when intentional** – `testthat::snapshot_accept()`

---

**Status:** ✅ Comprehensive testing infrastructure with testthat  
**Coverage:** Database operations, integration tests, snapshots, custom assertions  
**Ready for:** Test-driven development, validation against benchmarks, reproducibility  
**Last Updated:** 2026-04-03
