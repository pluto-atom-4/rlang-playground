# Quick Reference Card: cbrATLAS Analysis Environment

**Print this or bookmark it for daily use**

---

## 🚀 Start Your Analysis (In DataSpell)

```r
# 1. Load libraries
library(cbrATLAS)
library(here)
source(here("R", "db_helpers.R"))

# 2. Create run ID
run_id <- paste0("run-", format(Sys.time(), "%Y-%m-%d"), "-myanalysis")

# 3. Log to database
log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "single_release",
  dataset_name = "your_data",
  script_path = here("analyses", "my_analysis.R"),
  notes = "My analysis notes",
  random_seed = 12345
)

# 4. Do your analysis
result <- cjs.fn(data = my_capture_data, Phi.estim = ~1, p.estim = ~t)

# 5. Save results
save_survival_estimates.fn(run_id, survival_df)
save_corrected_estimates.fn(run_id, corrected_df)
save_bootstrap_results.fn(run_id, bootstrap_df)
complete_analysis_run.fn(run_id)

# 6. Verify results
estimates <- get_run_estimates.fn(run_id, estimate_type = "corrected")
print(estimates)
```

---

## 📁 File Paths (Always Use `here::here()`)

```r
library(here)

# DATA
data_file <- here("data", "myfile.csv")
raw_file <- here("data-raw", "raw_input.csv")

# RESULTS
results_file <- here("results", "output.csv")
db_path <- here("results", "analysis_results.db")

# ANALYSES
source(here("analyses", "my_script.R"))

# DOCS
notes_file <- here("docs", "findings.md")
```

**❌ NEVER:**
```r
# BAD - Don't do this
"C:/Users/nobu/Documents/.../file.csv"
setwd("C:/Users/nobu/...")
```

---

## 🗄️ Database Operations

### Initialize (One-time)
```r
source(here("R", "db_helpers.R"))
init_analysis_db.fn()  # Creates analysis_results.db
```

### Log a Run
```r
log_analysis_run.fn(
  run_id = "run-2026-04-03-analysis-001",
  analysis_type = "single_release",    # or "tag_life", "paired_release"
  dataset_name = "steelhead_2025",
  script_path = here("analyses", "my_script.R"),
  notes = "Initial analysis, n=50 fish",
  random_seed = 12345
)
```

### Save Results (After Running Analysis)
```r
save_survival_estimates.fn(run_id, estimates_df)
save_corrected_estimates.fn(run_id, corrected_df)
save_bootstrap_results.fn(run_id, bootstrap_df)
complete_analysis_run.fn(run_id)
```

### Query Results
```r
# All runs
all_runs <- get_all_runs.fn()

# Raw estimates from specific run
raw <- get_run_estimates.fn(run_id, estimate_type = "raw")

# Corrected estimates
corrected <- get_run_estimates.fn(run_id, estimate_type = "corrected")

# Bootstrap results
bootstrap <- get_bootstrap_results.fn(run_id)
```

---

## 🤖 Claude Code MCP Queries (No R code needed!)

Open Claude Code and type:

```
Show me all analysis runs in the database
↓
Claude uses MCP to query directly (no R code)

Show results from run-2026-04-03-001
↓
Returns all estimates from that run

Compare corrected estimates between two runs
↓
Claude queries both and shows comparison

What's the most recent analysis?
↓
Claude finds latest run_id and shows metadata
```

---

## ✅ Required Data Formats

### Capture History (Long Format)
```r
data.frame(
  individual = c(1, 1, 1, 2, 2, 2),     # Individual ID
  occasion = c(1, 2, 3, 1, 2, 3),       # Capture session
  captured = c(1, 0, 1, 1, 1, 0)        # 0/1 indicator
)
```

### Survival Estimates (For Database)
```r
data.frame(
  individual_id_or_group = "cohort_A",
  occasion = 1:5,
  phi_estimate = c(0.85, 0.83, 0.80, 0.78, 0.75),
  phi_se = c(0.08, 0.08, 0.09, 0.09, 0.10),
  capture_prob = 0.75,
  capture_prob_se = 0.05,
  convergence_status = "converged"
)
```

### Corrected Estimates (For Database)
```r
data.frame(
  individual_id_or_group = "cohort_A",
  occasion = 1:5,
  raw_phi = survival_est$phi_estimate,
  tag_failure_prob = 0.05,  # 5% failure
  corrected_phi = survival_est$phi_estimate / (1 - 0.05),
  corrected_phi_se = survival_est$phi_se / (1 - 0.05),
  correction_method = "AdjSurv.fn"
)
```

### Bootstrap Results (For Database)
```r
data.frame(
  individual_id_or_group = "cohort_A",
  occasion = 1:5,
  estimate_type = "corrected",  # or "raw"
  n_bootstrap = 1000,
  estimate = 0.88,
  ci_lower = 0.75,
  ci_upper = 0.96,
  ci_level = 0.95
)
```

---

## ⚙️ Essential Commands

| Task | Command |
|------|---------|
| **Start R** | Open DataSpell → R Console |
| **Load project** | `source(here("R", "db_helpers.R"))` |
| **Check database** | `file.exists(here("results", "analysis_results.db"))` |
| **View results** | `head(get_run_estimates.fn("run-XXX"))` |
| **Bootstrap** | `set.seed(12345); boot.L(data, formula, n.bootstrap=1000)` |
| **Create new analysis** | Copy `example-01-simplified-test.R`; modify |
| **Query via Claude** | Start: `claude code` → ask Claude |

---

## 📝 Write a New Analysis Script

**Template:**
```r
# ============================================================================
# Analysis: [Your Title]
# Author: [Your name]
# Date: [Date]
# ============================================================================

library(cbrATLAS)
library(here)
source(here("R", "db_helpers.R"))

# Unique run ID
run_id <- paste0("run-", format(Sys.time(), "%Y-%m-%d-%H%M%S"), "-yourname-001")

# Log run
log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "single_release",
  dataset_name = "your_dataset",
  script_path = here("analyses", "your_script.R"),
  notes = "Description of what you're doing",
  random_seed = 12345
)

# Your analysis code here
# ...

# Save results
save_survival_estimates.fn(run_id, your_estimates_df)
save_corrected_estimates.fn(run_id, your_corrected_df)
save_bootstrap_results.fn(run_id, your_bootstrap_df)
complete_analysis_run.fn(run_id)

# Verify
print(get_run_estimates.fn(run_id, estimate_type = "corrected"))
```

---

## 🎯 CJS Analysis Quick Reference

```r
library(cbrATLAS)

# Single release
result <- cjs.fn(
  data = capture_history,           # Long-format data frame
  Phi.estim = ~1,                   # Survival: ~1 (constant) or ~time (time-varying)
  p.estim = ~t,                     # Capture: ~t (time-varying) or ~1 (constant)
  time.interval = rep(1, n_occ-1)   # Time between occasions
)

# Tag-life correction
set.seed(12345)
tag_life <- cjs.taglife.corr(tag_failure_data)
corrected_phi <- result$phi / (1 - tag_life$failure_prob)

# Bootstrap CI
set.seed(12345)
boot_result <- boot.L(
  data = capture_history,
  formula = ~1,
  n.bootstrap = 1000
)
```

---

## ❌ Anti-Patterns (DON'T DO)

```r
# ❌ DON'T - Attach data
attach(mydata)
mean(survival)  # Where does this come from?

# ✅ DO - Use explicit naming
mean(mydata$survival)

# ❌ DON'T - Hard-code paths
file <- "C:/Users/nobu/Documents/JetBrains/rlang-playground/data/file.csv"

# ✅ DO - Use here::here()
file <- here("data", "file.csv")

# ❌ DON'T - Use setwd()
setwd("C:/some/path")
df <- read.csv("file.csv")

# ✅ DO - Use here::here() in paths
df <- read.csv(here("data", "file.csv"))

# ❌ DON'T - Call install.packages in scripts
install.packages("ggplot2")

# ✅ DO - Assume packages are installed, just load
library(ggplot2)

# ❌ DON'T - Global assignment
my_func <- function() {
  result <<- some_calc()  # Side effect!
}

# ✅ DO - Return values
my_func <- function() {
  result <- some_calc()
  return(result)
}
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| **`here()` not found** | `install.packages("here")`; `library(here)` |
| **Database error** | Delete `results/analysis_results.db`; run `init_analysis_db.fn()` |
| **cbrATLAS won't load** | Restart DataSpell; try `remotes::install_github("Columbia-Basin-Research-West/cbrATLAS")` |
| **Path errors** | Use `here::here()` everywhere; never hardcode paths |
| **Claude Code MCP down** | Restart Claude Code; ensure `uv --version` works |
| **Forgot run_id?** | `get_all_runs.fn()` shows all IDs; copy from output |

---

## 📚 Learn More

- **Architecture:** Read `CLAUDE.md`
- **Setup details:** Read `docs/SETUP_COMPLETE.md`
- **Collaboration style:** Read `about-me.md`
- **Database schema:** Read `results/README.md`
- **cbrATLAS vignette:** `vignette("cbrATLAS")`

---

**Print this page • Bookmark it • Reference it daily**

Last updated: 2026-04-03
