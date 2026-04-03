# SQL MCP Setup Complete: cbrATLAS Analysis Environment

## ✅ What Was Created

### 1. **Directory Structure (Standard R Project Layout)**
```
R/                          # Helper functions & utilities
├── db_helpers.R            # Database init, logging, and query functions
data/                       # Clean data for analyses
data-raw/                   # Raw input data (don't modify)
results/                    # Analysis outputs
├── README.md               # Database schema and usage guide
├── analysis_results.db     # SQLite database (auto-created on init)
R/analyses/                   # Main analysis scripts
tests/                      # Validation scripts
```

### 2. **Database Schema (SQLite)**
Four tables for results tracking:

| Table | Purpose |
|-------|---------|
| **analysis_runs** | Metadata: run_id, timestamp, analysis_type, dataset, random_seed, status |
| **survival_estimates** | Raw CJS estimates: run_id, individual, occasion, phi, SE, convergence |
| **corrected_estimates** | Tag-failure adjusted: run_id, individual, occasion, raw/corrected phi, method |
| **bootstrap_results** | Bootstrap CI: run_id, individual, occasion, n_bootstrap, estimate, ci_lower/upper |

### 3. **Database Helper Functions** (R/db_helpers.R)
- `init_analysis_db.fn()` – Initialize database
- `log_analysis_run.fn()` – Start a new analysis run
- `save_survival_estimates.fn()` – Log raw survival estimates
- `save_corrected_estimates.fn()` – Log corrected estimates
- `save_bootstrap_results.fn()` – Log bootstrap results
- `complete_analysis_run.fn()` – Mark run as finished
- `get_all_runs.fn()` – Query all previous runs
- `get_run_estimates.fn()` – Query estimates from a run
- `get_bootstrap_results.fn()` – Query bootstrap results from a run

### 4. **Copilot Instructions** (.github/copilot-instructions.md)
Updated to include:
- SQL MCP server section with schema details
- Database integration examples
- Directory structure guidelines
- Database usage patterns for analysis scripts

### 5. **.Rbuildignore**
Standard R project exclusions (results/, data-raw/, tests/, .github/, etc.)

---

## 🚀 Quick Start: Using the Database

### Initialize (Run Once)
```r
source("R/db_helpers.R")
init_analysis_db.fn()
# Creates: results/analysis_results.db
```

### Log Results from Analysis Script
```r
source("R/db_helpers.R")

# 1. Start a run
run_id <- "run-2026-04-03-single-release-001"
log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "single_release",
  dataset_name = "steelhead_2025",
  script_path = "R/analyses/example-01-single-release.R",
  notes = "Initial analysis with 100 fish",
  random_seed = 12345
)

# 2. Run your analysis
result <- cjs.fn(data = capture_data, Phi.estim = ~1, p.estim = ~t)

# 3. Save results
save_survival_estimates.fn(run_id, survival_results_df)
save_corrected_estimates.fn(run_id, corrected_results_df)
save_bootstrap_results.fn(run_id, bootstrap_results_df)

# 4. Mark complete
complete_analysis_run.fn(run_id)
```

### Query Previous Results
```r
# All runs
all_runs <- get_all_runs.fn()

# Estimates from specific run
estimates <- get_run_estimates.fn("run-2026-04-03-single-release-001", 
                                   estimate_type = "corrected")

# Bootstrap CI
bootstrap <- get_bootstrap_results.fn("run-2026-04-03-single-release-001")
```

---

## 📋 Files Created/Modified

| File | Status | Purpose |
|------|--------|---------|
| `.claude/settings.json` | ✅ Created | MCP server + Claude Code permissions config |
| `.github/copilot-instructions.md` | ✅ Enhanced | Added path conventions, anti-patterns, MCP details |
| `.gitignore` | ✅ Created | Standard R project git exclusions |
| `.Rprofile` | ✅ Created | Project R startup (`here::here()` setup) |
| `CLAUDE.md` | ✅ Enhanced | Added MCP configuration section + updated structure |
| `R/db_helpers.R` | ✅ Created | Database functions & helpers |
| `results/README.md` | ✅ Created | Database schema & usage guide |
| `.Rbuildignore` | ✅ Created | Standard R project exclusions |
| `R/` | ✅ Created | Helper functions directory |
| `R/analyses/` | ✅ Created | Analysis scripts directory (with .gitkeep) |
| `R/analyses/notes/` | ✅ Created | Analysis notes subdirectory |
| `data/` | ✅ Created | Clean data for analyses |
| `data-raw/` | ✅ Created | Raw input data |
| `results/` | ✅ Created | Analysis outputs |
| `tests/` | ✅ Created | Validation/test scripts |

---

## 🔗 Integration with Claude Code & Copilot Sessions

### Claude Code (MCP-Enabled)

Claude Code sessions will:
1. Load `.claude/settings.json` for MCP server configuration
2. Access SQLite database directly via MCP tools: `list_tables`, `query`, `execute`
3. Query previous analysis runs without writing R code
4. Use Haiku 4.5 model for efficient analysis reasoning

**Required setup:**
```bash
# Install uv (Python package manager for MCP server)
pip install uv
```

**Query example:**
```
Claude Code can directly: "Get the most recent 5 analysis runs from the database"
→ Uses MCP tool: query "SELECT * FROM analysis_runs ORDER BY created_at DESC LIMIT 5"
```

### GitHub Copilot Sessions

Future Copilot sessions will:
1. Read `.github/copilot-instructions.md` for repository context
2. Understand the two-step cbrATLAS correction pipeline
3. Know about the SQL database for results tracking
4. Use `R/db_helpers.R` functions to log analysis results
5. Follow path conventions with `here::here()` (configured in `.Rprofile`)
6. Avoid anti-patterns: `attach()`, `setwd()`, hardcoded paths
7. Query previous runs for comparison and reproducibility

---

## 🚀 Claude Code + MCP Quick Start

### 1. Install Prerequisites

```bash
# Install uv (required for MCP server)
pip install uv

# Verify installation
uv --version
```

### 2. Initialize Database (One-Time)

```r
# In R console from project directory:
source("R/db_helpers.R")
init_analysis_db.fn()
# Creates: results/analysis_results.db
```

### 3. Start Claude Code

```bash
# From project directory:
claude code
# OR: /init (in Claude Code to load project context)
```

### 4. Query Database from Claude Code

In Claude Code session:
```
Query the database: "Show me all analysis runs"
→ Claude Code uses MCP sqlite tool directly, no R needed
```

---

## 📝 Next Steps

1. **Install `uv`**: Required for MCP server (`pip install uv`)
2. **Create first analysis script** in `R/analyses/` 
3. **Initialize database**: `source("R/db_helpers.R"); init_analysis_db.fn()`
4. **Log results** from your analysis using the helper functions
5. **Query across runs** to compare analyses
6. **Use Claude Code MCP** for direct database queries (no code required)

---

**Status:** ✅ SQL MCP + Claude Code configured with standard R project structure  
**Ready for:** Analysis scripts, database logging, Claude Code queries, reproducible research workflow  
**Prerequisites:** `uv` must be installed for MCP server  
**Last Updated:** 2026-04-03
