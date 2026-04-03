# Running Tests in DataSpell

## From Console

### Run All Tests
```r
testthat::test_dir("tests/testthat")
```

### Run Specific Test File
```r
testthat::test_file("tests/testthat/test_db_helpers.R")
testthat::test_file("tests/testthat/test_cbratlas_integration.R")
```

### Run Tests Matching Pattern
```r
# All database tests
testthat::test_file("tests/testthat/test_db_helpers.R", filter = "database|db")

# All cbrATLAS integration tests
testthat::test_file("tests/testthat/test_cbratlas_integration.R", filter = "cjs.fn")
```

## From Runner Script

```r
# Load and execute all tests
source("tests/testthat.R")
```

## View Test Results

### Detailed output
```r
# Suppress summary, see full output
testthat::test_dir("tests/testthat", reporter = "verbose")
```

### With coverage
```r
library(covr)

# Coverage report
cov <- file_coverage("R/db_helpers.R", "tests/testthat/test_db_helpers.R")
print(cov)
```

## Debug a Failing Test

### Run test with traceback
```r
# Enables stepping through test
testthat::test_file("tests/testthat/test_db_helpers.R", reporter = "debug")
```

### Run single test manually
```r
# Copy test code from file and run interactively
# This lets you inspect intermediate values

temp_db <- tempfile(fileext = ".db")
source("R/db_helpers.R")
init_analysis_db.fn(temp_db)

# Now inspect temp_db manually
con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
DBI::dbListTables(con)  # See what tables exist
```

## Update Snapshots

After intentional changes to output structure:

```r
# Review proposed snapshot changes
testthat::snapshot_review("test_cbratlas_integration")

# Accept all changes
testthat::snapshot_accept("test_cbratlas_integration")
```

## Performance Tips

### Run tests faster
```r
# Skip expensive tests (e.g., bootstrap with high iterations)
testthat::test_dir("tests/testthat", 
                    filter = "!bootstrap")  # Skip bootstrap tests
```

### Parallel test execution
```r
# Use multiple cores (if supported by testthat version)
testthat::test_dir("tests/testthat", 
                    stop_on_failure = FALSE)
```

## DataSpell Test Runner Integration

If DataSpell has R testing support:

1. **Menu:** Tools → Run Tests (or similar)
2. **Select:** `tests/testthat` directory
3. **View:** Test results in IDE pane
4. **Click:** Test name to see output/error

(Exact menu may vary by DataSpell version)
