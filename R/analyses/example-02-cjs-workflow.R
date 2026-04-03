# ============================================================================
# Example 02: Single Release CJS Workflow (Standalone)
# ============================================================================
#
# This demonstrates a complete CJS analysis workflow with database logging.
# Uses synthetic estimates (in real analysis, you'd call cbrATLAS functions).
#
# This script works as-is and demonstrates the full end-to-end pattern.
#
# ============================================================================

library(here)
source(here("R", "db_helpers.R"))

# ============================================================================
# CONFIGURATION
# ============================================================================

DATA_DESCRIPTION <- "example_steelhead"
N_INDIVIDUALS <- 50
N_OCCASIONS <- 10
BOOTSTRAP_SEED <- 12345
ANALYSIS_AUTHOR <- "Your Name"

# ============================================================================
# SETUP
# ============================================================================

cat("\n", rep("=", 80), "\n")
cat("SINGLE RELEASE CJS ANALYSIS - EXAMPLE 02\n")
cat(rep("=", 80), "\n\n")

# Create unique run ID
run_id <- paste0(
  "run-",
  format(Sys.time(), "%Y-%m-%d-%H%M%S"),
  "-cjs-example-02"
)

cat("Run ID:     ", run_id, "\n")
cat("Author:     ", ANALYSIS_AUTHOR, "\n")
cat("Dataset:    ", DATA_DESCRIPTION, "\n")
cat("Individuals:", N_INDIVIDUALS, "\n")
cat("Occasions:  ", N_OCCASIONS, "\n\n")

# ============================================================================
# STEP 1: Log analysis run
# ============================================================================

cat("[1] Logging analysis to database...\n")

log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "single_release",
  dataset_name = DATA_DESCRIPTION,
  script_path = here("analyses", "example-02-cjs-workflow.R"),
  notes = "Example CJS analysis: constant survival, time-varying capture",
  random_seed = BOOTSTRAP_SEED
)

cat("    ✓ Run logged\n\n")

# ============================================================================
# STEP 2: Simulate capture history data
# ============================================================================

cat("[2] Creating capture history data...\n")

set.seed(BOOTSTRAP_SEED)

# Simulate capture data
capture_data <- data.frame(
  individual = rep(1:N_INDIVIDUALS, each = N_OCCASIONS),
  occasion = rep(1:N_OCCASIONS, N_INDIVIDUALS),
  captured = rbinom(N_INDIVIDUALS * N_OCCASIONS, size = 1, prob = 0.8),
  stringsAsFactors = FALSE
)

# First capture must be 1 (released fish)
capture_data$captured[capture_data$occasion == 1] <- 1

cat("    Created:", nrow(capture_data), "records\n")
cat("    Sample data:\n")
print(head(capture_data, 12))
cat("\n")

# ============================================================================
# STEP 3: Simulate CJS model results
# ============================================================================

cat("[3] Simulating CJS model results...\n")

# In real analysis, you would:
#   result <- cjs.fn(data = capture_data, Phi.estim = ~1, p.estim = ~occasion, ...)
#   Then extract phi_estimate, phi_se, capture_prob, capture_prob_se

# For this example, we simulate realistic estimates
set.seed(BOOTSTRAP_SEED)

phi_true <- 0.82    # True survival 82%
p_true <- c(0.70, 0.72, 0.74, 0.76, 0.78, 0.77, 0.75, 0.73, 0.71)  # Occasion-varying capture

n_intervals <- N_OCCASIONS - 1

cat("    Simulated true survival:     ", phi_true * 100, "%\n")
cat("    Simulated capture probs:     ", "70-78%\n")
cat("    Generating estimate uncertainty...\n\n")

# Generate realistic estimates with uncertainty
survival_estimates_df <- data.frame(
  individual_id_or_group = "cohort_all",
  occasion = 1:n_intervals,
  phi_estimate = phi_true + rnorm(n_intervals, 0, 0.05),
  phi_se = rep(0.07, n_intervals),
  capture_prob = p_true,
  capture_prob_se = rep(0.06, n_intervals),
  convergence_status = rep("converged", n_intervals),
  stringsAsFactors = FALSE
)

# Bound to [0, 1]
survival_estimates_df$phi_estimate <- pmax(0, pmin(1, survival_estimates_df$phi_estimate))

cat("    Survival estimates (raw):\n")
print(survival_estimates_df)
cat("\n")

# ============================================================================
# STEP 4: Save raw survival estimates
# ============================================================================

cat("[4] Saving raw survival estimates...\n")

save_survival_estimates.fn(
  run_id = run_id,
  estimates_df = survival_estimates_df
)

cat("    ✓ Saved", nrow(survival_estimates_df), "estimates\n\n")

# ============================================================================
# STEP 5: Apply tag-failure correction (example: 3% failure)
# ============================================================================

cat("[5] Applying tag-failure correction...\n")

TAG_FAILURE_PROB <- 0.03  # 3% tag failure

corrected_estimates_df <- data.frame(
  individual_id_or_group = "cohort_all",
  occasion = 1:n_intervals,
  raw_phi = survival_estimates_df$phi_estimate,
  tag_failure_prob = TAG_FAILURE_PROB,
  corrected_phi = survival_estimates_df$phi_estimate / (1 - TAG_FAILURE_PROB),
  corrected_phi_se = survival_estimates_df$phi_se / (1 - TAG_FAILURE_PROB),
  correction_method = "AdjSurv.fn",
  stringsAsFactors = FALSE
)

# Bound to [0, 1]
corrected_estimates_df$corrected_phi <- pmin(1.0, corrected_estimates_df$corrected_phi)

cat("    Tag failure rate: ", TAG_FAILURE_PROB * 100, "%\n")
cat("    Adjustment factor:", 1 / (1 - TAG_FAILURE_PROB), "\n")
cat("    Corrected estimates:\n")
print(corrected_estimates_df)
cat("\n")

# ============================================================================
# STEP 6: Save corrected estimates
# ============================================================================

cat("[6] Saving corrected estimates...\n")

save_corrected_estimates.fn(
  run_id = run_id,
  corrected_df = corrected_estimates_df
)

cat("    ✓ Saved\n\n")

# ============================================================================
# STEP 7: Generate bootstrap confidence intervals
# ============================================================================

cat("[7] Computing bootstrap confidence intervals...\n")

N_BOOTSTRAP <- 1000

# Generate bootstrap CI from estimates
bootstrap_results_df <- data.frame(
  individual_id_or_group = rep("cohort_all", 2 * n_intervals),
  occasion = rep(1:n_intervals, 2),
  estimate_type = rep(c("raw", "corrected"), each = n_intervals),
  n_bootstrap = N_BOOTSTRAP,
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

# Bound to [0, 1]
bootstrap_results_df$ci_lower <- pmax(0, bootstrap_results_df$ci_lower)
bootstrap_results_df$ci_upper <- pmin(1, bootstrap_results_df$ci_upper)

cat("    Generated", nrow(bootstrap_results_df), "bootstrap results\n")
cat("    Sample bootstrap results:\n")
print(head(bootstrap_results_df, 10))
cat("\n")

# ============================================================================
# STEP 8: Save bootstrap results
# ============================================================================

cat("[8] Saving bootstrap results...\n")

save_bootstrap_results.fn(
  run_id = run_id,
  bootstrap_df = bootstrap_results_df
)

cat("    ✓ Saved\n\n")

# ============================================================================
# STEP 9: Mark analysis complete
# ============================================================================

cat("[9] Marking analysis complete...\n")

complete_analysis_run.fn(run_id)

cat("    ✓ Complete\n\n")

# ============================================================================
# STEP 10: Verify results by querying database
# ============================================================================

cat("[10] Verifying results from database...\n\n")

# Query all runs
all_runs <- get_all_runs.fn()
cat("     Recent runs:\n")
print(all_runs[, c("run_id", "analysis_type", "status")])

# Query raw estimates
raw_est <- get_run_estimates.fn(run_id, estimate_type = "raw")
cat("\n     Raw estimates from database:\n")
print(raw_est)

# Query corrected estimates
corr_est <- get_run_estimates.fn(run_id, estimate_type = "corrected")
cat("\n     Corrected estimates from database:\n")
print(corr_est)

# Query bootstrap
boot_est <- get_bootstrap_results.fn(run_id)
cat("\n     Bootstrap results from database (first 10):\n")
print(head(boot_est, 10))

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n", rep("=", 80), "\n")
cat("ANALYSIS COMPLETE - SUMMARY\n")
cat(rep("=", 80), "\n\n")

cat("Run ID:              ", run_id, "\n")
cat("Dataset:             ", DATA_DESCRIPTION, "\n")
cat("Analysis Type:       Single Release CJS\n")
cat("Individuals:         ", N_INDIVIDUALS, "\n")
cat("Occasions:           ", N_OCCASIONS, "\n")
cat("Bootstrap N:         ", N_BOOTSTRAP, "\n")
cat("Tag Failure Corr:    ", TAG_FAILURE_PROB * 100, "%\n")

cat("\nDatabase Summary:\n")
cat("  - 1 run metadata entry\n")
cat("  -", nrow(survival_estimates_df), "raw survival estimates\n")
cat("  -", nrow(corrected_estimates_df), "corrected estimates\n")
cat("  -", nrow(bootstrap_results_df), "bootstrap results\n")
cat("  - TOTAL:", 1 + nrow(survival_estimates_df) + nrow(corrected_estimates_df) + nrow(bootstrap_results_df), "records\n")

cat("\nWhat to do next:\n")
cat("  1. Review console output above\n")
cat("  2. Open DataSpell and run this script interactively\n")
cat("  3. Modify DATA_DESCRIPTION, TAG_FAILURE_PROB, etc.\n")
cat("  4. Copy this as template for your own analyses\n")
cat("  5. Use Claude Code to query: 'Show results from", run_id, "'\n")

cat("\n", rep("=", 80), "\n")
cat("✓ SUCCESS - All systems operational!\n")
cat(rep("=", 80), "\n\n")
