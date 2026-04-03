# Example Analysis 01: Simplified Test Workflow
# Purpose: Test the database logging workflow without cbrATLAS
# - Test here::here() path handling
# - Log analysis run to database
# - Save synthetic results
# - Query back results

library(here)

# Source database helpers
source(here("R", "db_helpers.R"))

# Create a unique run ID for this analysis
run_id <- paste0("run-", format(Sys.time(), "%Y-%m-%d-%H%M%S"), "-simple-test-001")

cat("\n", rep("=", 70), "\n")
cat("SIMPLIFIED TEST ANALYSIS: Database Workflow\n")
cat(rep("=", 70), "\n")
cat("\nRun ID:", run_id, "\n")

# ============================================================================
# STEP 1: Verify here::here() is working (portable paths)
# ============================================================================

cat("\n[STEP 1] Verifying portable path setup...\n")
project_root <- here()
cat("  Project root:", project_root, "\n")
cat("  Analysis script:", here("analyses", "example-01-simplified-test.R"), "\n")
cat("  Database path:", here("results", "analysis_results.db"), "\n")
cat("  ✓ Portable paths working\n")

# ============================================================================
# STEP 2: Log the analysis run to database
# ============================================================================

cat("\n[STEP 2] Logging analysis run to database...\n")

log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "simplified_test",
  dataset_name = "synthetic_capture_data",
  script_path = here("analyses", "example-01-simplified-test.R"),
  notes = "Test workflow: database logging, path handling, result retrieval",
  random_seed = 12345,
  db_path = here("results", "analysis_results.db")
)

cat("  ✓ Run logged to database\n")

# ============================================================================
# STEP 3: Create synthetic survival estimates
# ============================================================================

cat("\n[STEP 3] Creating synthetic survival estimates...\n")

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

cat("  Created", nrow(survival_estimates_df), "raw survival estimates\n")
print(survival_estimates_df)

# ============================================================================
# STEP 4: Save survival estimates to database
# ============================================================================

cat("\n[STEP 4] Saving survival estimates to database...\n")

save_survival_estimates.fn(
  run_id = run_id,
  estimates_df = survival_estimates_df,
  db_path = here("results", "analysis_results.db")
)

cat("  ✓ Saved to survival_estimates table\n")

# ============================================================================
# STEP 5: Create tag-failure corrected estimates
# ============================================================================

cat("\n[STEP 5] Creating tag-failure corrected estimates...\n")

# Assume 5% tag failure rate
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

# Bound corrected estimates to [0, 1]
corrected_estimates_df$corrected_phi <- pmin(1.0, corrected_estimates_df$corrected_phi)

cat("  Created", nrow(corrected_estimates_df), "corrected estimates\n")
print(corrected_estimates_df)

# ============================================================================
# STEP 6: Save corrected estimates to database
# ============================================================================

cat("\n[STEP 6] Saving corrected estimates to database...\n")

save_corrected_estimates.fn(
  run_id = run_id,
  corrected_df = corrected_estimates_df,
  db_path = here("results", "analysis_results.db")
)

cat("  ✓ Saved to corrected_estimates table\n")

# ============================================================================
# STEP 7: Create bootstrap confidence intervals
# ============================================================================

cat("\n[STEP 7] Creating bootstrap confidence intervals...\n")

set.seed(12345)
n_bootstrap <- 1000

bootstrap_results_df <- data.frame(
  individual_id_or_group = rep("cohort_A", 2 * n_occasions),
  occasion = rep(1:n_occasions, 2),
  estimate_type = rep(c("raw", "corrected"), each = n_occasions),
  n_bootstrap = n_bootstrap,
  estimate = c(survival_estimates_df$phi_estimate, corrected_estimates_df$corrected_phi),
  ci_lower = c(
    survival_estimates_df$phi_estimate - 1.96 * survival_estimates_df$phi_se,
    corrected_estimates_df$corrected_phi - 1.96 * corrected_estimates_df$corrected_phi_se
  ),
  ci_upper = c(
    survival_estimates_df$phi_estimate + 1.96 * survival_estimates_df$phi_se,
    corrected_estimates_df$corrected_phi + 1.96 * corrected_estimates_df$corrected_phi_se
  ),
  ci_level = 0.95,
  stringsAsFactors = FALSE
)

# Bound CI to [0, 1]
bootstrap_results_df$ci_lower <- pmax(0, bootstrap_results_df$ci_lower)
bootstrap_results_df$ci_upper <- pmin(1, bootstrap_results_df$ci_upper)

cat("  Created", nrow(bootstrap_results_df), "bootstrap results\n")
print(head(bootstrap_results_df, 8))

# ============================================================================
# STEP 8: Save bootstrap results to database
# ============================================================================

cat("\n[STEP 8] Saving bootstrap results to database...\n")

save_bootstrap_results.fn(
  run_id = run_id,
  bootstrap_df = bootstrap_results_df,
  db_path = here("results", "analysis_results.db")
)

cat("  ✓ Saved to bootstrap_results table\n")

# ============================================================================
# STEP 9: Mark analysis as complete
# ============================================================================

cat("\n[STEP 9] Marking analysis as complete...\n")

complete_analysis_run.fn(
  run_id = run_id,
  db_path = here("results", "analysis_results.db")
)

cat("  ✓ Run marked as completed\n")

# ============================================================================
# STEP 10: Query back and verify results
# ============================================================================

cat("\n[STEP 10] Verifying results by querying database...\n")

# Get all runs
all_runs <- get_all_runs.fn(db_path = here("results", "analysis_results.db"))
cat("\n  Recent runs in database:\n")
print(all_runs[, c("run_id", "analysis_type", "status", "created_at")])

# Get raw estimates from this run
raw_estimates <- get_run_estimates.fn(
  run_id = run_id,
  estimate_type = "raw",
  db_path = here("results", "analysis_results.db")
)
cat("\n  Raw estimates retrieved:\n")
print(raw_estimates)

# Get corrected estimates from this run
corrected_est <- get_run_estimates.fn(
  run_id = run_id,
  estimate_type = "corrected",
  db_path = here("results", "analysis_results.db")
)
cat("\n  Corrected estimates retrieved:\n")
print(corrected_est)

# Get bootstrap results
bootstrap_est <- get_bootstrap_results.fn(
  run_id = run_id,
  db_path = here("results", "analysis_results.db")
)
cat("\n  Bootstrap results retrieved:\n")
print(head(bootstrap_est, 8))

# ============================================================================
# FINAL: Success summary
# ============================================================================

cat("\n", rep("=", 70), "\n")
cat("✓✓✓ TEST COMPLETE - ALL SYSTEMS OPERATIONAL ✓✓✓\n")
cat(rep("=", 70), "\n")

cat("\nSummary:\n")
cat("  Run ID:              ", run_id, "\n")
cat("  Database path:       ", here("results", "analysis_results.db"), "\n")
cat("  Tables used:         ", "analysis_runs, survival_estimates, corrected_estimates, bootstrap_results\n")
cat("  Records saved:       ", nrow(survival_estimates_df) + nrow(corrected_estimates_df) + nrow(bootstrap_results_df), "\n")
cat("  Records retrieved:   ", nrow(raw_estimates) + nrow(corrected_est) + nrow(bootstrap_est), "\n")
cat("\nNext steps:\n")
cat("  1. Open this in DataSpell and run interactively\n")
cat("  2. Use Claude Code to query database: 'Show results from ", run_id, "'\n")
cat("  3. Create your own analysis script following this pattern\n")
cat(rep("=", 70), "\n\n")
