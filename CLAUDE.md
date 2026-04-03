# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project: cbrATLAS R Package Analysis & Development Environment

This repository is a **local analysis and learning environment** for the **cbrATLAS** R package (Columbia Basin Research). It does not contain the package source code; instead, it uses cbrATLAS as an installed external dependency.

**What is cbrATLAS?**
An R package for mark-recapture analysis that adjusts survival estimates to account for active-tag failures using data-driven tag-life models.

---

## Architecture: cbrATLAS Analysis Pipeline

**Two-Step Correction Workflow:**

```
1. TAG-LIFE MODELING
   Input: Tag-life study data (failure times, covariates)
   Functions: cjs.taglife.corr + failCompare integration
   Output: Tag failure probability model

2. SURVIVAL ESTIMATION
   Input: Capture history data
   Functions: cjs.fn (single release) or cjs.paired.fn (paired release)
   Output: Raw CJS survival estimates

3. ADJUSTMENT & CORRECTION
   Functions: AdjSurv.fn, correct.fn
   Logic: Apply tag-failure probability to raw estimates
   Output: Corrected survival estimates (adjusted for tag failure)

4. INFERENCE
   Function: boot.L (bootstrap resampling)
   Output: Confidence intervals, uncertainty quantification
```

### Core Functions by Category

**CJS Capture-Recapture Models:**
- `cjs.fn` – Single release analysis (Cormack-Jolly-Seber)
- `cjs.lik` – CJS likelihood computation
- `cjs.paired.fn` – Paired release design (extended)
- `paired.cjs.lik` – Paired CJS likelihood

**Tag-Life & Correction:**
- `cjs.taglife.corr` – Integrate failCompare tag-life modeling
- `AdjSurv.fn` – Apply tag-failure correction to survival estimates
- `correct.fn` – Correction application utility

**Data Transformation:**
- `atlas2flat.fn` – Convert ATLAS format → R data frames
- `dayhr.fn` – Day/hour time utilities
- `harmonic.fn`, `harmonic_tt2site.fn`, `mean_tt2site.fn` – Time-to-site calculations
- `thist0` – Capture timing histogram utility

**Bootstrap & Inference:**
- `boot.L` – Bootstrap resampling for confidence intervals
- `vs2.fn` – Variance/survival utility

### Key Design Principles

1. **Vectorization:** Most functions operate on data.frame inputs; process multiple individuals/groups in one call
2. **List Returns:** Functions return structured lists with estimates, standard errors, convergence diagnostics, metadata
3. **Tag-Failure is Critical:** Entire correction pipeline depends on accurate tag-life modeling (failCompare integration)
4. **CJS Assumptions:** Assumes capture probability structure satisfies CJS identifiability; inputs must be validated

---

## Working with This Repository

### Project Structure

```
rlang-playground/
├── .claude/
│   └── settings.json              # Claude Code MCP + permissions config
├── .github/
│   └── copilot-instructions.md    # GitHub Copilot guidance
├── CLAUDE.md                      # This file - technical guidance
├── README.md                      # User guide, setup, overview
├── about-me.md                    # Collaboration preferences
├── .gitignore                     # Git exclusions (R project standard)
├── .Rprofile                      # Project R startup (here::here setup)
├── .Rbuildignore                  # R package build exclusions
├── docs/
│   └── start-from-here.md         # Session notes and onboarding
├── R/                             # R code (functions and analysis scripts)
│   ├── db_helpers.R               # Database helper functions
│   └── analyses/                  # Analysis scripts (main work)
│       ├── *.R                    # Individual analyses
│       └── notes/                 # Findings and documentation
├── data/                          # Clean/processed data for analysis
├── data-raw/                      # Raw input data (don't modify)
├── results/                       # Analysis outputs
│   ├── README.md                  # Database schema and usage
│   └── analysis_results.db        # SQLite database (auto-created)
└── tests/                         # Test scripts and validation
```

### Using cbrATLAS in This Environment

**Install:**

**Windows** (R 4.5.3 in PATH at `C:/Program Files/R/R-4.5.3/bin`):
```bash
# From command line:
Rscript -e "install.packages('devtools')"
Rscript -e "devtools::install_github('Columbia-Basin-Research-West/cbrATLAS')"
```

**macOS/Linux** (adjust PATH as needed for your system):
```bash
# If R is in /usr/local/bin or via Homebrew:
Rscript -e "install.packages('devtools')"
Rscript -e "devtools::install_github('Columbia-Basin-Research-West/cbrATLAS')"
```

Or in R console (platform-agnostic):
```r
install.packages("devtools")
devtools::install_github("Columbia-Basin-Research-West/cbrATLAS")
```

**Load & Explore:**
```r
library(cbrATLAS)
?cbrATLAS                    # Package overview
help(package = "cbrATLAS")   # All functions
vignette("cbrATLAS")         # Primary tutorial
```

**Create Local Analysis Scripts:**
```r
# R/analyses/example-01-single-release.R
library(cbrATLAS)

# Load data, run analysis, document findings
# Keep scripts focused and reproducible
```

### Development Patterns

1. **Write analysis scripts** in `R/analyses/` directory
2. **Use cbrATLAS functions** as installed package (don't modify source)
3. **Document assumptions:** Capture probability structure, identifiability, tag-failure distribution
4. **Validate inputs:** Ensure data formats match expectations before passing to functions
5. **Check diagnostics:** Review convergence, n_bootstrap, random seed in bootstrap operations
6. **Test with vignette examples:** Reproduce published examples before extending to new data

---

## Common Tasks

### Verify R Installation & Load Package
```r
# Check R version (4.5.3 installed and in PATH)
R.version$version.string

# Load and verify cbrATLAS
library(cbrATLAS)
packageVersion("cbrATLAS")   # Should be 0.2.0.0 or later
```

### Run Single Release Analysis
```r
# See vignette for detailed workflow
result <- cjs.fn(
  data = capture_history_df,
  Phi.estim = ~1,          # Survival estimation formula
  p.estim = ~t,            # Capture probability formula
  time.interval = time_intervals
)
```

### Apply Tag-Failure Correction
```r
# 1. Estimate tag-life model
tag_life <- cjs.taglife.corr(tag_failure_data)

# 2. Adjust survival estimates
corrected <- AdjSurv.fn(
  raw_survival = result$estimates,
  tag_failure_prob = tag_life$failure_prob
)
```

### Bootstrap for Confidence Intervals
```r
boot_result <- boot.L(
  data = capture_history_df,
  formula = ~1,
  n.bootstrap = 1000,
  seed = 12345
)
```

---

## Critical Dependencies

- **failCompare:** Provides multiple model-fitting approaches for tag-life data; enables goodness-of-fit assessment and model comparison
- **R 4.5.3:** Currently installed and available in PATH (Windows: `C:/Program Files/R/R-4.5.3/bin`; adjust for macOS/Linux)
- **devtools/remotes:** Only needed for installation from GitHub

---

## Important Patterns & Conventions

1. **Function Naming:** `.fn` suffix is standard across the package (e.g., `cjs.fn`, `AdjSurv.fn`, `atlas2flat.fn`). Maintain this when extending.
2. **Data Input Format:** Capture histories are long-format data.frames. See vignette for exact schema (columns: individual ID, occasion, capture indicator).
3. **Return Structure:** All major functions return lists with named components for estimates, SE, diagnostics, metadata. Always document list structure.
4. **Random Seed:** Always set `set.seed()` before bootstrap operations for reproducibility.
5. **CJS Identifiability:** Capture probability parameters must satisfy CJS constraints (e.g., first occasion cannot have Phi estimation). Validate before analysis.

---

## Known Limitations & Roadmap

**Current Scope:**
- Single release data with and without censoring
- Optional tag-failure correction
- Bootstrap inference

**Planned Extensions (not yet implemented):**
- Paired release study designs
- Virtual-Paired Release (ViPRe)
- Virtual Release Dead Fish Correction (ViRDCt)

---

## Security & Best Practices

1. **Input Validation:** Always check data format, range, and completeness before passing to functions. Ensure no NA/NaN in critical columns.
2. **Numerical Stability:** CJS likelihood can be ill-conditioned (use log-space computation). Do not modify likelihood calculations without extensive testing against published benchmarks.
3. **Reproducibility:** Document random seed for all stochastic operations (bootstrap). Include session info in analysis outputs.
4. **Assumption Checking:** Validate CJS identifiability, tag-failure distribution fit, and capture probability structure before interpreting results.
5. **External Data Integration:** If using external datasets, validate schema against vignette examples. Ensure time intervals, release dates, and observation windows are correctly specified.

---

## Claude Code Configuration & MCP Server

### .claude/settings.json (Configured)

The project includes a `.claude/settings.json` file that configures:

**Model Selection:**
- Default: `claude-haiku-4-5-20251001` (efficient for routine analysis tasks)
- Escalate to Opus 4.6 for complex methodological decisions

**MCP Server Integration:**
SQLite MCP server provides direct database access from Claude Code sessions:
```json
{
  "mcpServers": {
    "sqlite": {
      "command": "uvx",
      "args": ["mcp-server-sqlite", "--db-path", "results/analysis_results.db"]
    }
  }
}
```

**MCP Tools Available** (in Claude Code sessions):
- `list_tables` – Show all tables in the database
- `query [SQL]` – Execute SELECT queries and retrieve results
- `execute [SQL]` – Execute INSERT/UPDATE/DELETE statements
- `describe_table [name]` – Show schema for a specific table

**Permissions:**
- **Allow:** `Rscript*`, `git status`, `git diff*`, `git log*`, `git add*`, `git commit*`
- **Deny:** Network commands (`curl`, `wget`), destructive git (`--force`), `rm -rf`

**Prerequisite:** Users must have `uv` installed for MCP server:
```bash
pip install uv
# or: winget install astral-sh.uv (Windows)
```

### Example: Query Database in Claude Code Session

```
User: "Query the database to show recent analysis runs"

Claude Code (with MCP):
→ list_tables
   Tables: analysis_runs, survival_estimates, corrected_estimates, bootstrap_results

→ query "SELECT run_id, created_at, analysis_type FROM analysis_runs ORDER BY created_at DESC LIMIT 5"
   run_id                       created_at                analysis_type
   run-2026-04-03-tag-life-001  2026-04-03T10:23:45Z     tag_life
   run-2026-04-02-release-001   2026-04-02T15:10:22Z     single_release
   ...
```

---

## For Claude Agents: Coordination Guidelines

### Agent Team Structure (Recommended)

1. **Data Explorer Agent:** Validate input formats, explore cbrATLAS sample data, check column names and ranges
2. **Function Analyst Agent:** Deep dive into function logic, CJS mathematics, tag-life modeling, bootstrap mechanics
3. **Analysis & Documentation Agent:** Create analysis scripts, document findings, write new vignettes or examples

### Communication Pattern

- **Use Agent tool for parallel work:** Each agent handles independent tasks simultaneously
- **Escalate to human:** Methodological decisions, validation against published literature, scope trade-offs
- **Reference CLAUDE.md:** All agents should understand the architecture and conventions
- **Check about-me.md:** Ensure collaboration approach aligns with user preferences

---

## References & Further Reading

**Official Documentation:**
- Vignette: https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%20vignette.pdf
- Technical Manual: https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%200.0.1.3.pdf
- GitHub: https://github.com/Columbia-Basin-Research-West/cbrATLAS

**Foundational Methodology:**
- Townsend, R.L., et al. (2006) – Tag-failure correction methodology
- Skalski, J.R., et al. (1998) – CJS capture-recapture theory

**Tools & Integration:**
- JetBrains DataSpell: R IDE for this environment
- Claude Code: https://claude.ai/code
- GitHub Copilot: Inline code completion (pair with Claude Code for complex logic)

---

**Last Updated:** 2026-04-03  
**cbrATLAS Target Version:** 0.2.0.0+  
**R Version:** 4.5.3  
**Note on PATH:** Windows-specific installation documented; macOS/Linux setups may differ
