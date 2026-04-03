# Copilot Instructions for rlang-playground

This repository is a local **analysis and learning environment** for the **cbrATLAS** R package—mark-recapture analysis with active-tag failure correction. This is not the package source; cbrATLAS is installed as an external dependency.

## Quick Context

- **Primary Language:** R (>= 4.1.0)
- **IDE:** JetBrains DataSpell
- **Package:** cbrATLAS (Columbia Basin Research) — installed via `devtools::install_github("Columbia-Basin-Research-West/cbrATLAS")`
- **Purpose:** Create reproducible analysis scripts, examples, and documentation for working with cbrATLAS functions

---

## Architecture: Two-Step Survival Correction Pipeline

```
1. TAG-LIFE MODELING
   Input: Tag failure study data
   Process: cjs.taglife.corr (with failCompare integration)
   Output: Tag failure probability model

2. SURVIVAL ESTIMATION  
   Input: Capture history data
   Process: cjs.fn (single release) or cjs.paired.fn (paired releases)
   Output: Raw CJS survival estimates

3. ADJUSTMENT & CORRECTION
   Process: AdjSurv.fn + correct.fn
   Output: Corrected survival estimates (adjusted for tag failure)

4. INFERENCE
   Process: boot.L (bootstrap resampling)
   Output: Confidence intervals & uncertainty quantification
```

**Key Design Principle:** All cbrATLAS functions operate on data.frame inputs (long format), return structured lists with estimates/SE/diagnostics/metadata, and follow `.fn` naming convention.

---

## Core Function Categories

**CJS Capture-Recapture:**
- `cjs.fn` – Single release analysis (Cormack-Jolly-Seber model)
- `cjs.paired.fn` – Paired release design
- `cjs.lik`, `paired.cjs.lik` – Likelihood computation (internal)

**Tag-Life & Correction:**
- `cjs.taglife.corr` – Estimate tag failure probability via failCompare
- `AdjSurv.fn` – Apply tag-failure correction
- `correct.fn` – Correction utility

**Data Transformation:**
- `atlas2flat.fn` – Convert ATLAS format → data frames
- `dayhr.fn` – Day/hour time utilities
- `harmonic.fn`, `harmonic_tt2site.fn`, `mean_tt2site.fn` – Time-to-site calculations

**Bootstrap & Inference:**
- `boot.L` – Bootstrap resampling (always use `set.seed()` before for reproducibility)
- `vs2.fn` – Variance/survival utility

---

## Project Structure & Conventions

```
rlang-playground/
├── .claude/                           # Claude Code configuration
│   └── settings.json                  # MCP server & permissions config
├── .github/
│   └── copilot-instructions.md        # This file - GitHub Copilot guidance
├── .idea/                             # DataSpell IDE config
├── .venv/                             # Python virtual environment (optional)
│
├── 📋 CORE DOCUMENTATION
├── README.md                          # Main guide & quick start
├── CLAUDE.md                          # Detailed technical guidance (read this first)
├── about-me.md                        # Collaboration preferences & code philosophy
├── INDEX.md                           # Navigation guide for all documentation
├── QUICK_REFERENCE.md                 # Common tasks & syntax cheat sheet
├── 00_READ_ME_FIRST.md                # Entry point for new users
├── START-FROM-HERE.md                 # Session notes & onboarding
│
├── 📚 PROJECT SETUP & REFERENCE
├── TESTING_SETUP.md                   # Setup summary & test configuration
├── TESTING_SETUP.md                   # Testing framework reference
├── SQL_MCP_SETUP.md                   # SQLite MCP server configuration
├── PYTHON_ENVIRONMENT.md              # Python deps & environment setup
├── DIRECTORY_REORGANIZATION.md        # Project structure notes
├── DATASPELL_GUIDE.md                 # IDE-specific guidance
├── COMPLETE_SETUP_DOCUMENTATION.md    # Full setup walkthrough
│
├── 📊 REFERENCE & INSPECTION
├── DATABASE_INSPECTION.md             # How to inspect database contents
├── MANUAL_INSPECTION_CHECKLIST.md     # Validation checklist
├── TEST_EXAMPLES.md                   # Example test patterns
├── TEST_RESULTS.md                    # Recent test execution results
├── TEST_SCRIPT_WALKTHROUGH.md         # Detailed test script guide
│
├── 🔧 CONFIG FILES
├── .Rprofile                          # R startup (here::here config)
├── .Rbuildignore                      # R build exclusions
├── .gitignore                         # Git exclusions
├── pyproject.toml                     # Python project config
├── uv.lock                            # UV package lock file
│
├── 📁 MAIN PROJECT DIRECTORIES
├── analyses/                          # Analysis scripts (main work)
│   ├── *.R                            # Individual focused analyses
│   └── notes/                         # Analysis findings & documentation
│
├── R/                                 # Helper functions & utilities
│   ├── db_helpers.R                   # Database initialization & query functions
│   └── *.R                            # Other utility functions
│
├── data/                              # Clean/processed data (analysis-ready)
├── data-raw/                          # Raw input data (do not modify)
├── docs/                              # Documentation & session notes
├── results/                           # Analysis outputs (plots, tables, summaries)
│   ├── analysis_results.db            # SQLite database (results tracking)
│   └── README.md                      # Database schema & usage guide
│
├── tests/                             # Test scripts & validation
│   ├── testthat/                      # testthat framework tests
│   │   ├── test_db_helpers.R
│   │   ├── test_cbratlas_integration.R
│   │   ├── test_helpers.R
│   │   └── _snaps/                    # Snapshot tests
│   ├── README.md                      # Complete testing guide
│   └── DATASPELL_GUIDE.md             # IDE test execution guide
│
├── identifier.sqlite                  # ID mapping database
└── analysis_results.db                # Results database (tracked)
```

**Important:** Do not modify these files without explicit discussion—they are curated for consistency and collaboration:
- `CLAUDE.md` – Technical architecture and guidance
- `README.md` – User guide and quick start
- `about-me.md` – Collaboration preferences and values

**Directory Guidelines:**

| Directory | Purpose | What to Put Here | Guidelines |
|-----------|---------|------------------|-----------|
| **R/** | Helper functions | Utility functions, database helpers | Use `.fn` naming; roxygen comments; minimal side effects |
| **analyses/** | Main analysis work | One-focused-analysis-per-script R files | Reproducible; use `here::here()`; document assumptions |
| **data/** | Clean data | Analysis-ready datasets (CSV, RDS, etc.) | Generated from data-raw via analyses; validated before use |
| **data-raw/** | Raw inputs | Original data (do not modify) | Reference-only; never changed after checked in |
| **results/** | Analysis outputs | Plots, tables, summaries, database | Keep git-ignored if large; analysis_results.db tracks findings |
| **tests/** | Validation scripts | Unit/integration tests, fixtures, snapshots | Use testthat framework; reproduce edge cases & benchmarks |
| **docs/** | Documentation | Session notes, architecture diagrams, findings | Reference material; session-specific notes allowed |
| **.claude/** | Claude config | MCP settings, permissions | Do not modify without discussion |
| **.github/** | GitHub config | Copilot instructions, workflows | This guidance file; keep updated with project changes |

---

## Documentation Files Guide

This project includes comprehensive documentation files to support reproducibility and collaboration:

### Entry Points for New Users
- **00_READ_ME_FIRST.md** – Quick orientation for first-time users
- **START-FROM-HERE.md** – Session-specific notes and onboarding steps
- **INDEX.md** – Navigation guide across all documentation

### Core Technical Guidance
- **CLAUDE.md** – Comprehensive technical reference (cbrATLAS pipeline, conventions, architecture)
- **README.md** – Main user guide with quick start and setup
- **about-me.md** – Collaboration preferences and code philosophy
- **QUICK_REFERENCE.md** – Common tasks and syntax cheat sheet

### Setup & Configuration
- **TESTING_SETUP.md** – Test framework setup and quick reference
- **SQL_MCP_SETUP.md** – SQLite MCP server configuration and database setup
- **PYTHON_ENVIRONMENT.md** – Python virtual environment and dependencies
- **DATASPELL_GUIDE.md** – IDE-specific guidance for DataSpell/PyCharm
- **COMPLETE_SETUP_DOCUMENTATION.md** – Full step-by-step setup walkthrough

### Testing & Validation
- **tests/README.md** – Comprehensive testing guide (unit, integration, snapshots)
- **tests/DATASPELL_GUIDE.md** – Running tests from IDE
- **TEST_EXAMPLES.md** – Example test patterns and best practices
- **TEST_RESULTS.md** – Recent test execution results
- **TEST_SCRIPT_WALKTHROUGH.md** – Detailed walkthrough of test scripts

### Project Reference
- **DATABASE_INSPECTION.md** – How to inspect analysis_results.db contents
- **DIRECTORY_REORGANIZATION.md** – Notes on project structure evolution
- **MANUAL_INSPECTION_CHECKLIST.md** – Validation and verification checklist

---

### Data Input Format
- Capture histories: long-format data.frame with columns for individual ID, capture occasion, capture indicator (0/1)
- Always validate: no NA/NaN in critical columns; occasion sequence correct; capture probability structure satisfies CJS identifiability
- See cbrATLAS vignette (PDF) for exact schema

### Function Return Structure
All major functions return **named lists** with:
- `estimates` – Point estimates (survival, capture probability)
- `se` – Standard errors
- `convergence` – Convergence diagnostics
- Metadata (sample size, formula, time intervals, etc.)

**Always document list structure** when creating analysis outputs.

### Function Naming & Extensions
- Use `.fn` suffix for all new custom functions (e.g., `my_analysis.fn`)
- Follow functional programming patterns (minimize side effects, vectorize operations)
- Use explicit naming: `survival_estimate`, not `surv_est`

### Random Seed for Reproducibility
```r
set.seed(12345)  # Always before bootstrap operations
boot_result <- boot.L(data, formula, n.bootstrap = 1000, seed = 12345)
```

### CJS Identifiability Constraints
- First capture occasion cannot have Phi (survival) estimation
- Capture probability structure must satisfy CJS assumptions
- Validate before fitting: check formula and occasion structure

---

## Testing Strategy

**Framework:** testthat (>= 3.0) with integration tests, snapshots, and custom assertions.

### Test Coverage

| Category | Location | Purpose |
|----------|----------|---------|
| **Unit Tests** | `tests/testthat/test_db_helpers.R` | Database functions (init, insert, query, update) |
| **Integration Tests** | `tests/testthat/test_cbratlas_integration.R` | Full pipeline (data → analysis → correction → results) |
| **Snapshots** | `tests/testthat/_snaps/` | Validate output structure & detect unintended changes |
| **Fixtures** | `tests/testthat/test_helpers.R` | Reproducible sample data (capture histories, tag-life data) |
| **Custom Assertions** | `tests/testthat/test_helpers.R` | Validate CJS results, valid estimates, DB operations |

### Run Tests

```r
# All tests
testthat::test_dir("tests/testthat")

# Specific file
testthat::test_file("tests/testthat/test_db_helpers.R")

# With coverage
library(covr)
code_coverage(source_file = "R/db_helpers.R", 
              test_files = "tests/testthat/test_db_helpers.R")
```

### Philosophy

Per `about-me.md`, tests emphasize:
- **Integration tests over mocks** – Use real cbrATLAS functions and data
- **Validation against benchmarks** – Survival estimates in [0,1], convergence checks
- **Reproducibility** – Fixed seeds, documented fixtures, snapshot tracking

### Custom Test Helpers

```r
# Fixtures
capture_data <- create_sample_capture_data.fn(n_individuals = 50, n_occasions = 10)
tag_life_data <- create_sample_tag_life_data.fn(n_tags = 100)

# Assertions
expect_cjs_result_structure.fn(result)
expect_valid_estimates.fn(estimates_df, col_names = c("phi_estimate", "phi_se"))
expect_db_operation.fn(run_id, "survival_estimates")
```

### Writing New Tests

1. **For database functions:** Add to `test_db_helpers.R`
2. **For analysis workflows:** Add to `test_cbratlas_integration.R` 
3. **For outputs:** Use snapshots with `expect_snapshot()`
4. **For validation:** Use `expect_valid_estimates.fn()` or custom assertions

See `tests/README.md` for complete testing guide.

---

## Quick Start Resources

### First Time in This Project?
1. **Start here:** `00_READ_ME_FIRST.md` (5 min overview)
2. **Then read:** `README.md` (setup & quick start)
3. **Reference:** `QUICK_REFERENCE.md` (common tasks)

### Setting Up Your Environment?
1. **Full walkthrough:** `COMPLETE_SETUP_DOCUMENTATION.md`
2. **Python setup:** `PYTHON_ENVIRONMENT.md`
3. **Testing setup:** `TESTING_SETUP.md`
4. **Database setup:** `SQL_MCP_SETUP.md`

### Writing Your First Analysis?
1. **Check:** `QUICK_REFERENCE.md` for examples
2. **Reference:** `CLAUDE.md` sections on cbrATLAS functions and data format
3. **Test:** Follow patterns in `TEST_EXAMPLES.md`
4. **Document:** Add findings to `analyses/notes/` or `results/`

### Running Tests?
1. **Overview:** `tests/README.md`
2. **IDE setup:** `tests/DATASPELL_GUIDE.md` (if using DataSpell)
3. **Examples:** `TEST_EXAMPLES.md`
4. **Walkthrough:** `TEST_SCRIPT_WALKTHROUGH.md`

### Understanding the Database?
1. **Schema:** `SQL_MCP_SETUP.md`
2. **Inspection:** `DATABASE_INSPECTION.md`
3. **cbrATLAS integration:** See "SQL MCP Server" section below

---

### Load & Verify Package
```r
library(cbrATLAS)
packageVersion("cbrATLAS")  # Should be 0.2.0.0+
help(package = "cbrATLAS")
vignette("cbrATLAS")  # Primary tutorial
```

### Run Single Release Analysis
```r
result <- cjs.fn(
  data = capture_history_df,
  Phi.estim = ~1,          # Survival formula
  p.estim = ~t,            # Capture probability formula
  time.interval = intervals
)
```

### Apply Tag-Failure Correction
```r
# 1. Estimate tag-life model
tag_life <- cjs.taglife.corr(tag_failure_data)

# 2. Adjust survival
corrected <- AdjSurv.fn(
  raw_survival = result$estimates,
  tag_failure_prob = tag_life$failure_prob
)
```

### Bootstrap for Confidence Intervals
```r
set.seed(12345)
boot_result <- boot.L(
  data = capture_history_df,
  formula = ~1,
  n.bootstrap = 1000,
  seed = 12345
)
```

---

## Critical Dependencies & Numerical Stability

- **failCompare:** Used by `cjs.taglife.corr` for tag-life model fitting; enables multiple model-fitting approaches and goodness-of-fit assessment
- **CJS Likelihood:** Ill-conditioned; cbrATLAS uses log-space computation internally. Do NOT modify likelihood calculations without rigorous testing against published benchmarks.
- **Bootstrap Diagnostics:** Always check: convergence status, number of resamples, random seed in outputs

---

## Code Style & Quality Standards

Based on about-me.md preferences:

- **Clarity over cleverness** – Code should be self-documenting
- **Comments for *why*, not *what*** – Explain non-obvious logic (likelihood tricks, numerical workarounds)
- **Functional programming** – Minimize side effects; use piping (magrittr or `|>`)
- **Vectorized operations** – Work *with* R, not against it
- **Input validation** – Check data format, range, completeness; fail fast with clear errors
- **Documentation** – roxygen comments for functions (`@param`, `@return`, `@examples`); clear git commits explaining rationale

---

## Path Conventions & File Management

### Use `here::here()` for All File Paths

All file paths in analysis scripts must use `here::here()` for portability:

```r
# ✅ CORRECT: Portable across machines and project locations
library(here)
data_path <- here("data", "processed_data.csv")
results_path <- here("results", "my_analysis")

# ❌ WRONG: Absolute paths break on other machines
data_path <- "C:/Users/nobu/Documents/JetBrains/rlang-playground/data/processed_data.csv"

# ❌ WRONG: setwd() breaks reproducibility
setwd("C:/Users/nobu/Documents/JetBrains/rlang-playground")
```

The `.Rprofile` file marks the project root with `here::i_am("README.md")` so `here::here()` works everywhere.

### Read-Only & Protected Files

**Do NOT modify without explicit discussion:**
- `CLAUDE.md` – Technical architecture; core reference
- `README.md` – User guide and quick start
- `about-me.md` – Collaboration preferences and philosophy
- `.github/copilot-instructions.md` – This file; keeps GitHub guidance current
- `.claude/settings.json` – MCP server config and permissions
- `.Rprofile` – Project root marker for `here::here()`
- `.Rbuildignore` – R package build metadata
- `pyproject.toml` – Python project configuration

**Editable/Extensible files for analysis work:**
- `analyses/*.R` – Analysis scripts (main work; add new analyses freely)
- `R/*.R` – Helper functions (add utilities as needed)
- `results/` – Analysis outputs and subdirectories (create new folders for each analysis)
- `docs/` – Notes and findings (session-specific notes allowed)
- `tests/testthat/*.R` – Test files (add tests for new functionality)

**Auto-Generated/External (do not commit large files):**
- `analysis_results.db`, `identifier.sqlite` – SQLite databases
- `.venv/`, `Lib/`, `Scripts/` – Virtual environment directories
- `results/plots/`, `results/tables/` – Large output files (consider .gitignore)

---

## Anti-Patterns to Avoid

**These patterns break reproducibility and portability:**

❌ **Do NOT use `attach()`**
```r
# BAD
attach(data)
mean(phi_estimate)  # Implicit; unclear where it comes from
```
→ Use explicit `data$column` or vectorized operations instead

❌ **Do NOT use `setwd()`**
```r
# BAD
setwd("C:/my/path")
df <- read.csv("data.csv")
```
→ Use `here::here()` for all paths

❌ **Do NOT call `install.packages()` in scripts**
```r
# BAD (in analysis script)
install.packages("tidyverse")
library(tidyverse)
```
→ Users should manage dependencies separately; only use `library()` or `require()`

❌ **Do NOT hardcode absolute paths**
```r
# BAD
db_path <- "C:/Users/nobu/Documents/rlang-playground/results/analysis_results.db"
```
→ Use `here::here("results", "analysis_results.db")`

❌ **Do NOT use global assignment `<<-`**
```r
# BAD
my_function <- function() {
  global_var <<- 123  # Creates global side effect
}
```
→ Use functional patterns; pass/return values explicitly

---

## When to Check about-me.md

Refer to `about-me.md` for:
- **Escalation criteria:** When to ask before proceeding (architecture changes, methodological questions, external tool integration)
- **Independent work criteria:** When you can proceed without asking (routine function additions, documentation, bug fixes, refactoring)
- **Testing philosophy:** Integration tests over mocks; validate against biological benchmarks
- **Communication style:** Direct and concise; questions over assumptions; evidence-based

---

## References

**Official cbrATLAS Resources:**
- [Vignette (PDF)](https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%20vignette.pdf) – Worked examples and workflow
- [Technical Manual (PDF)](https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%200.0.1.3.pdf) – Complete function reference
- [GitHub Repository](https://github.com/Columbia-Basin-Research-West/cbrATLAS) – Source code and issues

**Foundational Methodology:**
- Townsend, R.L., et al. (2006) – Tag-failure correction for survival analysis
- Skalski, J.R., et al. (1998) – Cormack-Jolly-Seber capture-recapture models

**Testing Resources:**
- `tests/README.md` – Comprehensive testing guide
- `tests/DATASPELL_GUIDE.md` – IDE-specific test execution
- `TESTING_SETUP.md` – Setup summary and quick reference
- [testthat documentation](https://testthat.r-lib.org/) – Official reference

---

## SQL MCP Server for Results Tracking

A SQLite database is configured to track **analysis results** (survival estimates, corrections, bootstrap CI) for reproducibility and querying across multiple analyses.

### Database Schema

**analysis_runs** – Metadata for each analysis execution
```sql
CREATE TABLE analysis_runs (
  run_id TEXT PRIMARY KEY,              -- Unique identifier (e.g., "run-2026-04-03-tag-life-001")
  created_at TEXT,                      -- ISO 8601 timestamp
  analysis_type TEXT,                   -- 'tag_life' | 'single_release' | 'paired_release'
  dataset_name TEXT,                    -- Source data identifier
  script_path TEXT,                     -- Path to analysis script
  notes TEXT,                           -- Analysis notes/comments
  random_seed INTEGER,                  -- For reproducibility (especially bootstrap)
  status TEXT DEFAULT 'completed'       -- 'in_progress' | 'completed' | 'failed'
);
```

**survival_estimates** – Raw CJS estimates (before correction)
```sql
CREATE TABLE survival_estimates (
  run_id TEXT,                          -- Foreign key to analysis_runs
  individual_id_or_group TEXT,          -- Individual ID or group name
  occasion INTEGER,                     -- Survival interval number
  phi_estimate REAL,                    -- Survival probability estimate
  phi_se REAL,                          -- Standard error
  capture_prob REAL,                    -- Capture probability (if relevant)
  capture_prob_se REAL,
  convergence_status TEXT,              -- 'converged' | 'warning' | 'failed'
  PRIMARY KEY (run_id, individual_id_or_group, occasion),
  FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
);
```

**corrected_estimates** – Tag-failure adjusted estimates
```sql
CREATE TABLE corrected_estimates (
  run_id TEXT,                          -- Foreign key to analysis_runs
  individual_id_or_group TEXT,          -- Individual ID or group name
  occasion INTEGER,                     -- Survival interval number
  raw_phi REAL,                         -- Before correction
  tag_failure_prob REAL,                -- Tag failure probability applied
  corrected_phi REAL,                   -- After correction
  corrected_phi_se REAL,                -- Standard error post-correction
  correction_method TEXT,               -- 'AdjSurv.fn' | other method
  PRIMARY KEY (run_id, individual_id_or_group, occasion),
  FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
);
```

**bootstrap_results** – Bootstrap confidence intervals
```sql
CREATE TABLE bootstrap_results (
  run_id TEXT,                          -- Foreign key to analysis_runs
  individual_id_or_group TEXT,          -- Individual ID or group name
  occasion INTEGER,                     -- Survival interval number
  estimate_type TEXT,                   -- 'raw' | 'corrected'
  n_bootstrap INTEGER,                  -- Number of bootstrap resamples
  estimate REAL,                        -- Point estimate
  ci_lower REAL,                        -- Lower confidence limit (e.g., 2.5%)
  ci_upper REAL,                        -- Upper confidence limit (e.g., 97.5%)
  ci_level REAL,                        -- Confidence level (0.95, 0.90, etc.)
  PRIMARY KEY (run_id, individual_id_or_group, occasion, estimate_type),
  FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
);
```

### How to Use from R

```r
# Write results to database after analysis
library(DBI)
library(RSQLite)

con <- dbConnect(RSQLite::SQLite(), "analysis_results.db")

# Save run metadata
dbAppendTable(con, "analysis_runs", data.frame(
  run_id = "run-2026-04-03-single-release-001",
  created_at = Sys.time(),
  analysis_type = "single_release",
  dataset_name = "steelhead_2025",
  script_path = "analyses/example-01-single-release.R",
  random_seed = 12345,
  status = "completed"
))

# Save survival estimates
dbAppendTable(con, "survival_estimates", data.frame(
  run_id = "run-2026-04-03-single-release-001",
  individual_id_or_group = "fish_cohort_1",
  occasion = 1:10,
  phi_estimate = c(...),
  phi_se = c(...)
  # ... other columns
))

dbDisconnect(con)
```

### Querying Results

**Via R** (in analysis scripts):
```r
# Query corrected estimates for a specific run
con <- dbConnect(RSQLite::SQLite(), here("results", "analysis_results.db"))
results <- dbGetQuery(con, "
  SELECT * FROM corrected_estimates 
  WHERE run_id = 'run-2026-04-03-single-release-001'
  ORDER BY occasion
")
dbDisconnect(con)
```

**Via Claude Code MCP** (in claude.ai/code sessions):
When Claude Code has database access (via `.claude/settings.json` MCP configuration), you can query directly:
```
Claude Code MCP Tools:
- list_tables            → Show available tables in analysis_results.db
- query [SQL]            → Execute SELECT queries
- execute [SQL]          → Execute INSERT/UPDATE/DELETE statements
- describe_table [name]  → Show schema for a table
```
Example:
```
Claude: Use the sqlite tool to list tables
→ Returns: analysis_runs, survival_estimates, corrected_estimates, bootstrap_results

Claude: Query "SELECT run_id, created_at FROM analysis_runs ORDER BY created_at DESC LIMIT 5"
→ Returns: Recent 5 analysis runs with metadata
```

### MCP Server Setup

The project uses **SQLite MCP Server** for Claude Code integration. Configuration is in `.claude/settings.json`:
- **Transport:** `uvx` (from `uv` Python package manager)
- **Database:** `results/analysis_results.db` (relative path)
- **Tools available:** `list_tables`, `query`, `execute`, `describe_table`

**Prerequisite:** Install `uv` if using Claude Code:
```bash
pip install uv
# or: winget install astral-sh.uv (Windows)
```

---

## Getting Started as a New AI Assistant

1. **Read core documentation:**
   - CLAUDE.md (technical architecture)
   - about-me.md (collaboration style & code philosophy)

2. **Understand the analysis pipeline:**
   - Tag-life modeling → Survival estimation → Correction → Bootstrap inference
   - All functions use long-format data.frame inputs and return named lists

3. **When writing code:**
   - Use `.fn` naming convention
   - Validate input data (format, NA/NaN, CJS constraints)
   - Always set `set.seed()` before bootstrap
   - Document list return structures

4. **Database integration (optional):**
   - For analysis scripts that generate results, consider logging to the SQL database
   - Use `run_id` to track results from a single analysis execution
   - Query across runs for comparative analysis

5. **When in doubt:**
   - Check about-me.md escalation criteria
   - Reference the vignette for data format examples
   - Test against published benchmarks before extending models

---

**Last Updated:** 2026-04-03  
**cbrATLAS Target Version:** 0.2.0.0+  
**R Requirement:** >= 4.1.0  
**Database:** SQLite with MCP server for results tracking
