# Analysis Results Directory

This directory stores outputs from cbrATLAS analysis scripts.

## Structure

- **analysis_results.db** – SQLite database tracking all analysis runs and results
- **Run folders** (optional) – e.g., `run-2026-04-03-single-release-001/` for organizing outputs per analysis

## Using the Database

### Initialize (run once)

```r
source("R/db_helpers.R")
init_analysis_db.fn()
```

### Log Results from Analysis Script

```r
source("R/db_helpers.R")

# Start a run
log_analysis_run.fn(
  run_id = "run-2026-04-03-single-release-001",
  analysis_type = "single_release",
  dataset_name = "steelhead_2025",
  script_path = "analyses/example-01-single-release.R",
  notes = "Initial analysis with 100 fish",
  random_seed = 12345
)

# After analysis completes, save results
save_survival_estimates.fn("run-2026-04-03-single-release-001", survival_df)
save_corrected_estimates.fn("run-2026-04-03-single-release-001", corrected_df)
save_bootstrap_results.fn("run-2026-04-03-single-release-001", bootstrap_df)

# Mark complete
complete_analysis_run.fn("run-2026-04-03-single-release-001")
```

### Query Results

**Via R** (in analysis scripts):
```r
# Get all previous runs
all_runs <- get_all_runs.fn()

# Get estimates from a specific run
estimates <- get_run_estimates.fn("run-2026-04-03-single-release-001", 
                                   estimate_type = "corrected")

# Get bootstrap results
bootstrap <- get_bootstrap_results.fn("run-2026-04-03-single-release-001")
```

**Via Claude Code MCP** (in claude.ai/code sessions):
Claude Code can query the database directly without writing R:
```
Claude Code user: "Show me the last 5 analysis runs"
→ Claude uses MCP sqlite tool:
   list_tables → [analysis_runs, survival_estimates, ...]
   query "SELECT run_id, created_at, analysis_type FROM analysis_runs 
          ORDER BY created_at DESC LIMIT 5"
   → Results: recent runs with timestamps and types

Claude Code user: "Get corrected estimates for run-2026-04-03-single-release-001"
→ query "SELECT individual_id_or_group, occasion, corrected_phi, corrected_phi_se 
         FROM corrected_estimates WHERE run_id = 'run-2026-04-03-single-release-001'
         ORDER BY individual_id_or_group, occasion"
   → Results: table of corrected survival estimates
```

## Data Schema

### analysis_runs
- **run_id** – Unique identifier (e.g., "run-2026-04-03-single-release-001")
- **created_at** – ISO 8601 timestamp
- **analysis_type** – 'tag_life' | 'single_release' | 'paired_release'
- **dataset_name** – Source data identifier
- **script_path** – Path to analysis script
- **notes** – Analysis notes/comments
- **random_seed** – For reproducibility
- **status** – 'in_progress' | 'completed' | 'failed'

### survival_estimates
Raw CJS estimates before correction
- **run_id, individual_id_or_group, occasion** (primary key)
- **phi_estimate, phi_se** – Survival probability & SE
- **capture_prob, capture_prob_se** – Capture probability (if applicable)
- **convergence_status** – 'converged' | 'warning' | 'failed'

### corrected_estimates
Tag-failure adjusted estimates
- **run_id, individual_id_or_group, occasion** (primary key)
- **raw_phi** – Before correction
- **tag_failure_prob** – Tag failure probability applied
- **corrected_phi, corrected_phi_se** – After correction & SE
- **correction_method** – 'AdjSurv.fn' | other

### bootstrap_results
Bootstrap confidence intervals
- **run_id, individual_id_or_group, occasion, estimate_type** (primary key)
- **estimate_type** – 'raw' | 'corrected'
- **n_bootstrap** – Number of resamples
- **estimate, ci_lower, ci_upper** – Point estimate and CI bounds
- **ci_level** – Confidence level (0.95, 0.90, etc.)

---

**Last Updated:** 2026-04-03
