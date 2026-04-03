# Testing Available Examples

This guide helps you test the 4 available example analysis scripts.

---

## Available Examples

| # | Script | Size | Purpose | Difficulty | Status |
|---|--------|------|---------|------------|--------|
| 1 | **example-01-simplified-test.R** | 8.7 KB | Database workflow test (no cbrATLAS) | Easy | ✅ |
| 2 | **example-01-test-analysis.R** | 6.8 KB | Basic test analysis | Easy | ✅ |
| 3 | **example-02-cjs-workflow.R** | 11 KB | Complete CJS workflow | Intermediate | ✅ |
| 4 | **template-single-release-cjs.R** | 13 KB | Full template with all steps | Advanced | 📋 |

**Location:** `R/analyses/`

---

## What Each Example Does

### Example 01: Simplified Test Workflow
**File:** `R/analyses/example-01-simplified-test.R` (8.7 KB)

**Purpose:**
- Tests the database logging workflow
- Tests portable path handling with `here::here()`
- Demonstrates saving and retrieving results
- **Does NOT require cbrATLAS**

**What it does:**
1. Creates synthetic survival estimates
2. Logs run to database
3. Saves raw and corrected estimates
4. Creates bootstrap results
5. Retrieves and displays results

**Expected output:** Database records created, displayed in console

**Dependencies:**
- ✅ `here` package (loads portable paths)
- ✅ `R/db_helpers.R` (database functions)

---

### Example 02: CJS Workflow (Recommended)
**File:** `R/analyses/example-02-cjs-workflow.R` (11 KB)

**Purpose:**
- Complete end-to-end CJS analysis workflow
- Demonstrates the standard analysis pattern
- Shows database integration throughout
- **Does NOT require cbrATLAS**

**What it does:**
1. Simulates capture history data
2. Creates synthetic CJS estimates
3. Logs to database with metadata
4. Applies tag-failure correction
5. Runs bootstrap resampling
6. Displays analysis summary

**Expected output:** 
- Console summary with statistics
- Database records (analysis_runs, estimates, bootstrap results)
- Confidence intervals

**Dependencies:**
- ✅ `here` package
- ✅ `R/db_helpers.R`

---

### Example 01: Test Analysis
**File:** `R/analyses/example-01-test-analysis.R` (6.8 KB)

**Purpose:**
- Simple test analysis script
- Demonstrates basic workflow
- **Does NOT require cbrATLAS**

**Dependencies:**
- ✅ `here` package
- ✅ `R/db_helpers.R`

---

### Template: Single Release CJS
**File:** `R/analyses/template-single-release-cjs.R` (13 KB)

**Purpose:**
- Complete template for your own analyses
- Can be copied and modified
- Includes all best practices

**Use this when:**
- You're ready to create your own analysis
- You want to replace synthetic data with real data
- You're ready to call actual cbrATLAS functions

---

## Prerequisites

Before running examples, verify:

```bash
# Check R is in PATH
Rscript --version
# Expected: R version 4.5.3

# Check required packages are installed
Rscript -e "library(here); library(DBI); library(RSQLite)"
# Should load without errors
```

---

## Running the Examples

### Option 1: Via Command Line (Fastest)

```bash
# Navigate to project root
cd C:/Users/nobu/Documents/JetBrains/rlang-playground

# Run example 1 (simplified test - ~30 seconds)
Rscript R/analyses/example-01-simplified-test.R

# Run example 2 (CJS workflow - ~1 minute)
Rscript R/analyses/example-02-cjs-workflow.R

# Run example 3 (test analysis - ~30 seconds)
Rscript R/analyses/example-01-test-analysis.R
```

### Option 2: Via DataSpell (Interactive)

1. **Open in DataSpell**
   - File → Open → `R/analyses/example-01-simplified-test.R`

2. **Run the script**
   - Click **Run** button (▶) in top right
   - Or press **Ctrl+Shift+F10**
   - Or **Run → Run...**

3. **View output**
   - Console shows all results
   - Can pause and inspect variables
   - Database updates shown in console

4. **Repeat for other examples**

### Option 3: Via R Console (Interactive)

```r
# In R console
setwd("C:/Users/nobu/Documents/JetBrains/rlang-playground")

# Run script
source("R/analyses/example-01-simplified-test.R")
```

---

## Testing Steps

### Step 1: Verify Prerequisites ✅

```bash
# 1a. Check R version
Rscript --version

# 1b. Check package availability
Rscript -e "library(here); library(DBI); library(RSQLite); cat('✓ All packages available\n')"

# 1c. Check database file exists
ls -lh results/analysis_results.db
```

### Step 2: Run Example 01 (Simplified Test) ✅

```bash
cd C:/Users/nobu/Documents/JetBrains/rlang-playground
Rscript R/analyses/example-01-simplified-test.R
```

**Expected output:**
- Run ID (e.g., `run-2026-04-03-161523-simple-test-001`)
- ✓ Portable paths working
- ✓ Run logged to database
- Data frame with 4 rows (survival estimates)
- ✓ Saved to survival_estimates table
- ✓ Saved corrected estimates
- Bootstrap results displayed
- ✓ Database retrieval successful

**Duration:** ~30 seconds

---

### Step 3: Run Example 02 (CJS Workflow) ✅

```bash
Rscript R/analyses/example-02-cjs-workflow.R
```

**Expected output:**
- Run configuration displayed
- ✓ Run logged
- ✓ Capture history created
- ✓ CJS estimates generated
- ✓ Corrected estimates applied
- ✓ Bootstrap CI calculated
- Analysis summary with:
  - Mean survival estimates
  - Confidence intervals
  - Statistics table

**Duration:** ~1 minute

---

### Step 4: Verify Database Results ✅

```bash
# After running examples, query database
Rscript -e "
library(here)
library(DBI)
library(RSQLite)
conn <- dbConnect(RSQLite::SQLite(), here('results', 'analysis_results.db'))
cat('\\n=== ANALYSIS RUNS ===\\n')
print(dbReadTable(conn, 'analysis_runs'))
cat('\\n=== RECORD COUNTS ===\\n')
cat('Survival estimates:', nrow(dbReadTable(conn, 'survival_estimates')), '\\n')
cat('Corrected estimates:', nrow(dbReadTable(conn, 'corrected_estimates')), '\\n')
cat('Bootstrap results:', nrow(dbReadTable(conn, 'bootstrap_results')), '\\n')
dbDisconnect(conn)
"
```

---

## Verifying Success

### ✅ All Examples Pass If:

1. **No errors** in console output
2. **Run IDs created** (visible in output)
3. **Database records** saved (can query them)
4. **Estimates displayed** (numbers shown in console)
5. **Confidence intervals** calculated

### ⚠️ Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| `Error: could not find function "here"` | Package not installed | Run: `install.packages("here")` |
| `Error: cannot open file` | Wrong path | Check you're in project root: `pwd` |
| `Error in log_analysis_run.fn()` | db_helpers not found | Check file exists: `ls R/db_helpers.R` |
| `Error: database locked` | Another process using DB | Close other R sessions |
| Slow execution | First run compiles code | Subsequent runs are faster |

---

## Next Steps

### After Examples Pass ✅

1. **Review results in database:**
   ```bash
   # Use DataSpell to inspect results/analysis_results.db
   # Or use SQLiteStudio
   ```

2. **Examine example 2 in detail:**
   - Read `R/analyses/example-02-cjs-workflow.R`
   - Understand each step
   - Try modifying parameters

3. **Create your own analysis:**
   - Copy template: `template-single-release-cjs.R`
   - Replace synthetic data with your data
   - Add your analysis steps
   - Run and save results

4. **Read documentation:**
   - `docs/QUICK_REFERENCE.md` – Common operations
   - `docs/TEST_SCRIPT_WALKTHROUGH.md` – Detailed code explanation
   - `CLAUDE.md` – cbrATLAS architecture

---

## Expected Test Results

### Execution Times
| Example | Time | Notes |
|---------|------|-------|
| Example 01 (simplified) | ~30 sec | Fast, synthetic data only |
| Example 02 (CJS workflow) | ~1 min | Includes bootstrap simulation |
| Example 03 (test) | ~30 sec | Basic workflow |
| All examples | ~3 min | Total time to run all |

### Database Artifacts
After running both Example 01 and 02:
- ✓ 2+ analysis_runs records
- ✓ 8+ survival_estimates records
- ✓ 8+ corrected_estimates records
- ✓ 100+ bootstrap_results records

### Console Output Example

```
================================================================================
SIMPLIFIED TEST ANALYSIS: Database Workflow
================================================================================

Run ID: run-2026-04-03-161523-simple-test-001

[STEP 1] Verifying portable path setup...
  Project root: C:/Users/nobu/Documents/JetBrains/rlang-playground
  Analysis script: C:/Users/nobu/Documents/JetBrains/rlang-playground/R/analyses/example-01-simplified-test.R
  Database path: C:/Users/nobu/Documents/JetBrains/rlang-playground/results/analysis_results.db
  ✓ Portable paths working

[STEP 2] Logging analysis run to database...
  ✓ Run logged to database

[STEP 3] Creating synthetic survival estimates...
  Created 4 raw survival estimates
  individual_id_or_group occasion phi_estimate phi_se capture_prob capture_prob_se convergence_status
1              cohort_A        1        0.87   0.08        0.75           0.05          converged
2              cohort_A        2        0.85   0.08        0.78           0.05          converged
3              cohort_A        3        0.82   0.09        0.76           0.05          converged
4              cohort_A        4        0.80   0.10        0.79           0.06          converged

[STEP 4] Saving survival estimates to database...
  ✓ Saved to survival_estimates table

[✓] Analysis completed successfully!
```

---

## Test Checklist

Use this checklist to verify all examples work:

- [ ] **Prerequisites verified**
  - [ ] R 4.5.3 in PATH
  - [ ] `here` package installed
  - [ ] `DBI`, `RSQLite` packages installed
  - [ ] Database file exists

- [ ] **Example 01 (Simplified Test)**
  - [ ] Runs without errors
  - [ ] Creates unique run ID
  - [ ] Logs analysis to database
  - [ ] Saves estimates
  - [ ] Completes in ~30 seconds

- [ ] **Example 02 (CJS Workflow)**
  - [ ] Runs without errors
  - [ ] Creates capture history data
  - [ ] Generates CJS estimates
  - [ ] Applies corrections
  - [ ] Calculates bootstrap CI
  - [ ] Completes in ~1 minute

- [ ] **Example 03 (Test Analysis)**
  - [ ] Runs without errors
  - [ ] Completes successfully

- [ ] **Database Verification**
  - [ ] Can query analysis_runs
  - [ ] Can query survival_estimates
  - [ ] Can query corrected_estimates
  - [ ] Can query bootstrap_results

- [ ] **Ready for Production**
  - [ ] All examples pass
  - [ ] Database working correctly
  - [ ] Understand workflow
  - [ ] Ready to create custom analysis

---

**Status:** Ready to test  
**Created:** 2026-04-03  
**Examples:** 4 (all ready)  
**Estimated total test time:** 5-10 minutes
