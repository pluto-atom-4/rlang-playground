# Test Script Walkthrough

**File:** `analyses/example-01-simplified-test.R`

This script demonstrates the complete workflow: load libraries → create run ID → log to database → run analysis → save results → query results. Let's walk through each section.

---

## Section 1: Load Libraries & Helpers

```r
library(here)
source(here("R", "db_helpers.R"))
```

**What it does:**
- Loads `here` package for portable file paths
- Sources the database helper functions (9 functions defined in `R/db_helpers.R`)

**Why it matters:**
- All paths are relative to project root
- Database operations encapsulated in helper functions
- Same code works on any machine with project

**Output in console:**
```
here() starts at C:/Users/nobu/Documents/JetBrains/rlang-playground
✓ cbrATLAS analysis environment initialized
```

---

## Section 2: Create Unique Run ID

```r
run_id <- paste0("run-", format(Sys.time(), "%Y-%m-%d-%H%M%S"), "-simple-test-001")
```

**What it does:**
- Creates a timestamp-based run ID
- Format: `run-YYYY-MM-DD-HHMMSS-description`

**Example output:**
```
run-2026-04-03-134135-simple-test-001
```

**Why it matters:**
- Every analysis run has unique identifier
- Timestamp ensures chronological ordering
- Allows tracking multiple runs of same analysis
- Traceable in database queries

---

## Section 3: STEP 1 - Verify Portable Paths

```r
cat("\n[STEP 1] Verifying portable path setup...\n")
project_root <- here()
cat("  Project root:", project_root, "\n")
cat("  Analysis script:", here("analyses", "example-01-simplified-test.R"), "\n")
cat("  Database path:", here("results", "analysis_results.db"), "\n")
cat("  ✓ Portable paths working\n")
```

**What it does:**
- Prints project root directory
- Prints path to this script
- Prints path to database
- Verifies `here()` is working

**Example output:**
```
[STEP 1] Verifying portable path setup...
  Project root: C:/Users/nobu/Documents/JetBrains/rlang-playground 
  Analysis script: C:/Users/nobu/Documents/JetBrains/rlang-playground/analyses/example-01-simplified-test.R 
  Database path: C:/Users/nobu/Documents/JetBrains/rlang-playground/results/analysis_results.db 
  ✓ Portable paths working
```

**Why it matters:**
- Confirms paths resolve correctly
- Debugging aid if something goes wrong
- Shows portability is working

---

## Section 4: STEP 2 - Log Analysis Run

```r
log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "simplified_test",
  dataset_name = "synthetic_capture_data",
  script_path = here("analyses", "example-01-simplified-test.R"),
  notes = "Test workflow: database logging, path handling, result retrieval",
  random_seed = 12345,
  db_path = here("results", "analysis_results.db")
)
```

**What it does:**
- Calls database helper function `log_analysis_run.fn()`
- Creates entry in `analysis_runs` table
- Records metadata about this analysis execution

**What gets saved to database:**
```
run_id:          run-2026-04-03-134135-simple-test-001
created_at:      2026-04-03T13:41:35Z
analysis_type:   simplified_test
dataset_name:    synthetic_capture_data
script_path:     analyses/example-01-simplified-test.R
notes:           Test workflow: database logging, path handling, result retrieval
random_seed:     12345
status:          in_progress (updated to completed at end)
```

**Console output:**
```
✓ Logged run: run-2026-04-03-134135-simple-test-001
```

**Why it matters:**
- Establishes metadata for this run
- Can query "what analyses have I run?"
- Can query "when did I run this?"
- Basis for result tracking

---

## Section 5: STEP 3 - Create Synthetic Data

```r
set.seed(12345)
n_occasions <- 4

survival_estimates_df <- data.frame(
  individual_id_or_group = rep("cohort_A", n_occasions),
  occasion = 1:n_occasions,
  phi_estimate = c(0.87, 0.85, 0.82, 0.80),  # Declining survival
  phi_se = c(0.08, 0.08, 0.09, 0.10),
  capture_prob = c(0.75, 0.78, 0.76, 0.79),
  capture_prob_se = c(0.05, 0.05, 0.05, 0.06),
  convergence_status = rep("converged", n_occasions),
  stringsAsFactors = FALSE
)
```

**What it does:**
- Sets random seed for reproducibility
- Creates 4-occasion capture-recapture data
- Simulates declining survival (87% → 80%)
- Simulates capture probabilities (~75%)

**Data created:**
```
  individual_id_or_group occasion phi_estimate phi_se capture_prob capture_prob_se convergence_status
1               cohort_A        1         0.87   0.08         0.75            0.05          converged
2               cohort_A        2         0.85   0.08         0.78            0.05          converged
3               cohort_A        3         0.82   0.09         0.76            0.05          converged
4               cohort_A        4         0.80   0.10         0.79            0.06          converged
```

**Why it matters:**
- Demonstrates correct data format
- Shows estimates structure
- Provides realistic example values
- Can copy this pattern for your data

---

## Section 6: STEP 4 - Save to Database

```r
save_survival_estimates.fn(
  run_id = run_id,
  estimates_df = survival_estimates_df,
  db_path = here("results", "analysis_results.db")
)
```

**What it does:**
- Calls database helper function
- Appends estimates to `survival_estimates` table
- Links to run via run_id

**Console output:**
```
✓ Saved 4 survival estimates for run: run-2026-04-03-134135-simple-test-001
```

**Why it matters:**
- Persists raw estimates to database
- Can compare estimates across multiple runs
- Historical record of all analyses

---

## Section 7: STEP 5 - Create Corrected Estimates

```r
tag_failure_prob <- 0.05

corrected_estimates_df <- data.frame(
  individual_id_or_group = rep("cohort_A", n_occasions),
  occasion = 1:n_occasions,
  raw_phi = survival_estimates_df$phi_estimate,
  tag_failure_prob = tag_failure_prob,
  corrected_phi = survival_estimates_df$phi_estimate / (1 - tag_failure_prob),
  corrected_phi_se = survival_estimates_df$phi_se / (1 - tag_failure_prob),
  correction_method = "AdjSurv.fn",
  stringsAsFactors = FALSE
)
```

**What it does:**
- Assumes 5% tag failure rate
- Applies correction formula: `phi_corrected = phi_raw / (1 - tag_failure_prob)`
- Corrected SE: `se_corrected = se_raw / (1 - tag_failure_prob)`

**Example calculation:**
```
Raw phi:        0.87
Tag failure:    0.05
Corrected phi:  0.87 / (1 - 0.05) = 0.87 / 0.95 = 0.9157895
Correction:     0.87 → 0.92 (increased by ~5.7%)
```

**Data created:**
```
  raw_phi tag_failure_prob corrected_phi corrected_phi_se correction_method
1    0.87             0.05     0.9157895       0.08421053        AdjSurv.fn
2    0.85             0.05     0.8947368       0.08421053        AdjSurv.fn
3    0.82             0.05     0.8631579       0.09473684        AdjSurv.fn
4    0.80             0.05     0.8421053       0.10526316        AdjSurv.fn
```

**Why it matters:**
- Demonstrates tag-failure correction
- Shows before/after estimates
- Documents correction method used
- Basis for comparing raw vs. corrected

---

## Section 8: STEP 6 - Save Corrected Estimates

```r
save_corrected_estimates.fn(
  run_id = run_id,
  corrected_df = corrected_estimates_df,
  db_path = here("results", "analysis_results.db")
)
```

**What it does:**
- Saves corrected estimates to database
- Records method used (AdjSurv.fn)
- Preserves raw estimates for comparison

---

## Section 9: STEP 7 - Create Bootstrap Results

```r
bootstrap_results_df <- data.frame(
  individual_id_or_group = rep("cohort_A", 2 * n_occasions),
  occasion = rep(1:n_occasions, 2),
  estimate_type = rep(c("raw", "corrected"), each = n_occasions),
  n_bootstrap = n_bootstrap,
  estimate = c(survival_estimates_df$phi_estimate, corrected_estimates_df$corrected_phi),
  ci_lower = c(...),
  ci_upper = c(...),
  ci_level = 0.95
)
```

**What it does:**
- Creates confidence intervals for estimates
- 8 rows: 4 occasions × 2 types (raw + corrected)
- 95% confidence level

**Example data:**
```
  occasion estimate_type n_bootstrap estimate ci_lower ci_upper ci_level
1        1           raw        1000     0.87  0.7132 1.0000     0.95
2        1     corrected        1000     0.92  0.7507 1.0000     0.95
3        2           raw        1000     0.85  0.6932 1.0000     0.95
4        2     corrected        1000     0.89  0.7297 1.0000     0.95
...
```

**Why it matters:**
- Provides uncertainty quantification
- Shows CI for raw and corrected estimates
- Documents bootstrap parameters
- Basis for reporting results

---

## Section 10: STEP 8 - Save Bootstrap Results

```r
save_bootstrap_results.fn(
  run_id = run_id,
  bootstrap_df = bootstrap_results_df,
  db_path = here("results", "analysis_results.db")
)
```

**Console output:**
```
✓ Saved 8 bootstrap results for run: run-2026-04-03-134135-simple-test-001
```

---

## Section 11: STEP 9 - Mark Complete

```r
complete_analysis_run.fn(
  run_id = run_id,
  db_path = here("results", "analysis_results.db")
)
```

**What it does:**
- Updates `status` in `analysis_runs` from "in_progress" to "completed"
- Marks run as finished

**Why it matters:**
- Can distinguish completed vs. failed runs
- Query to find incomplete analyses
- Checkpoint for workflow

---

## Section 12: STEP 10 - Query & Verify

```r
all_runs <- get_all_runs.fn(db_path = here("results", "analysis_results.db"))
cat("\n  Recent runs in database:\n")
print(all_runs[, c("run_id", "analysis_type", "status", "created_at")])
```

**What it does:**
- Queries all runs
- Prints recent runs with key metadata

**Console output:**
```
  Recent runs in database:
                                 run_id   analysis_type    status           created_at
1 run-2026-04-03-134135-simple-test-001 simplified_test completed 2026-04-03T13:41:35Z
```

**Why it matters:**
- Verifies data was saved
- Shows workflow logging works end-to-end
- Demonstrates query functionality

---

## Section 13: Query Results by Type

```r
raw_estimates <- get_run_estimates.fn(
  run_id = run_id,
  estimate_type = "raw",
  db_path = here("results", "analysis_results.db")
)
print(raw_estimates)
```

**What it does:**
- Retrieves raw (uncorrected) estimates
- Shows all columns from `survival_estimates` table

**Console output:**
```
  run_id individual_id_or_group occasion phi_estimate phi_se ... convergence_status
1 ...    cohort_A                1         0.87       0.08      converged
2 ...    cohort_A                2         0.85       0.08      converged
...
```

---

## Section 14: Summary

```r
cat("\n", rep("=", 70), "\n")
cat("✓✓✓ TEST COMPLETE - ALL SYSTEMS OPERATIONAL ✓✓✓\n")
cat("\nSummary:\n")
cat("  Run ID:              ", run_id, "\n")
cat("  Database path:       ", here("results", "analysis_results.db"), "\n")
cat("  Tables used:         ", "analysis_runs, survival_estimates, corrected_estimates, bootstrap_results\n")
cat("  Records saved:       ", nrow(survival_estimates_df) + nrow(corrected_estimates_df) + nrow(bootstrap_results_df), "\n")
cat("  Records retrieved:   ", nrow(raw_estimates) + nrow(corrected_est) + nrow(bootstrap_est), "\n")
```

**What it does:**
- Prints success banner
- Shows final statistics

**Console output:**
```
======================================================================
✓✓✓ TEST COMPLETE - ALL SYSTEMS OPERATIONAL ✓✓✓
======================================================================

Summary:
  Run ID:               run-2026-04-03-134135-simple-test-001 
  Database path:        C:/Users/nobu/Documents/JetBrains/rlang-playground/results/analysis_results.db 
  Tables used:          analysis_runs, survival_estimates, corrected_estimates, bootstrap_results
  Records saved:        16 
  Records retrieved:    16 
```

---

## Flow Diagram

```
Load Libraries
    ↓
Create Run ID (timestamp-based)
    ↓
[LOG RUN METADATA] → analysis_runs table
    ↓
Create synthetic estimates data
    ↓
[SAVE RAW ESTIMATES] → survival_estimates table
    ↓
Apply tag-failure correction (÷ 0.95)
    ↓
[SAVE CORRECTED ESTIMATES] → corrected_estimates table
    ↓
Create bootstrap confidence intervals
    ↓
[SAVE BOOTSTRAP RESULTS] → bootstrap_results table
    ↓
[MARK RUN COMPLETE] → Update status in analysis_runs
    ↓
Query back all results to verify
    ↓
✓ SUCCESS: 16 records saved and retrieved
```

---

## Key Takeaways

1. **Reproducible:** Set seed before random operations (`set.seed(12345)`)
2. **Traceable:** Every run has unique ID tied to metadata
3. **Persistent:** All results saved to database
4. **Verifiable:** Query back results to confirm persistence
5. **Portable:** Uses `here::here()` for all paths
6. **Modular:** Database operations encapsulated in helpers
7. **Complete workflow:** From analysis to storage to retrieval

---

## How to Adapt for Your Analysis

1. Replace synthetic data with your actual capture history
2. Replace `cjs.fn()` call with your actual analysis
3. Replace estimate creation with actual output from your model
4. Change `analysis_type` to match your workflow (e.g., "single_release", "tag_life")
5. Change `dataset_name` to your actual dataset
6. Keep all the database logging code the same

---

That's the complete walkthrough! Every line serves a purpose in the end-to-end workflow.
