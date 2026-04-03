# Example Analysis 01: Test Workflow
# Purpose: Verify that the complete analysis pipeline works
# - Load cbrATLAS
# - Create sample data
# - Run basic analysis
# - Log results to database

library(cbrATLAS)
library(here)

# Source database helpers
source(here("R", "db_helpers.R"))

# Create a unique run ID for this analysis
run_id <- paste0("run-", format(Sys.time(), "%Y-%m-%d-%H%M%S"), "-test-001")

cat("Starting test analysis with run_id:", run_id, "\n")

# ============================================================================
# STEP 1: Log the analysis run to database
# ============================================================================

log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "test_analysis",
  dataset_name = "synthetic_data",
  script_path = here("analyses", "example-01-test-analysis.R"),
  notes = "Test workflow: synthetic capture history, basic CJS analysis",
  random_seed = 12345,
  db_path = here("results", "analysis_results.db")
)

# ============================================================================
# STEP 2: Create synthetic capture history data (simple test case)
# ============================================================================

# Simple capture history: 10 individuals, 5 capture occasions
n_individuals <- 10
n_occasions <- 5

# Create capture history data frame (long format)
capture_data <- data.frame(
  individual = rep(1:n_individuals, each = n_occasions),
  occasion = rep(1:n_occasions, n_individuals),
  # Simulate captures (90% present, 80% capture probability)
  captured = sample(c(0, 1), size = n_individuals * n_occasions,
                   prob = c(0.2, 0.8), replace = TRUE),
  stringsAsFactors = FALSE
)

cat("\nCapture history created:\n")
cat("  Individuals:", n_individuals, "\n")
cat("  Occasions:", n_occasions, "\n")
cat("  Total records:", nrow(capture_data), "\n")

# ============================================================================
# STEP 3: Run basic CJS analysis
# ============================================================================

cat("\nRunning CJS analysis...\n")

# Simple CJS model: constant survival, occasion-varying capture
try({
  cjs_result <- cjs.fn(
    data = capture_data,
    Phi.estim = ~1,              # Constant survival
    p.estim = ~occasion,          # Occasion-varying capture probability
    time.interval = rep(1, n_occasions - 1)
  )

  cat("CJS analysis completed.\n")
  print(str(cjs_result, max.level = 2))
})

# ============================================================================
# STEP 4: Create results data frame for database
# ============================================================================

# Prepare survival estimates for logging
survival_estimates_df <- data.frame(
  individual_id_or_group = "test_group_1",
  occasion = 1:(n_occasions - 1),
  phi_estimate = 0.85 + rnorm(n_occasions - 1, 0, 0.05),  # Simulated estimates
  phi_se = 0.10,
  capture_prob = NA_real_,
  capture_prob_se = NA_real_,
  convergence_status = "converged",
  stringsAsFactors = FALSE
)

# Ensure estimates are in valid range [0, 1]
survival_estimates_df$phi_estimate <- pmax(0, pmin(1, survival_estimates_df$phi_estimate))

cat("\nSurvival estimates prepared:\n")
print(head(survival_estimates_df))

# ============================================================================
# STEP 5: Save results to database
# ============================================================================

cat("\nSaving results to database...\n")

save_survival_estimates.fn(
  run_id = run_id,
  estimates_df = survival_estimates_df,
  db_path = here("results", "analysis_results.db")
)

# ============================================================================
# STEP 6: Create corrected estimates (simulated)
# ============================================================================

corrected_estimates_df <- data.frame(
  individual_id_or_group = "test_group_1",
  occasion = 1:(n_occasions - 1),
  raw_phi = survival_estimates_df$phi_estimate,
  tag_failure_prob = 0.05,  # Assume 5% tag failure
  corrected_phi = survival_estimates_df$phi_estimate / (1 - 0.05),  # Simple correction
  corrected_phi_se = 0.12,
  correction_method = "AdjSurv.fn",
  stringsAsFactors = FALSE
)

# Ensure corrected estimates are in valid range [0, 1]
corrected_estimates_df$corrected_phi <- pmax(0, pmin(1, corrected_estimates_df$corrected_phi))

cat("\nCorrected estimates prepared:\n")
print(head(corrected_estimates_df))

save_corrected_estimates.fn(
  run_id = run_id,
  corrected_df = corrected_estimates_df,
  db_path = here("results", "analysis_results.db")
)

# ============================================================================
# STEP 7: Create bootstrap results (simulated)
# ============================================================================

set.seed(12345)
bootstrap_results_df <- data.frame(
  individual_id_or_group = rep("test_group_1", n_occasions - 1),
  occasion = 1:(n_occasions - 1),
  estimate_type = "corrected",
  n_bootstrap = 1000,
  estimate = corrected_estimates_df$corrected_phi,
  ci_lower = corrected_estimates_df$corrected_phi - 0.10,
  ci_upper = corrected_estimates_df$corrected_phi + 0.10,
  ci_level = 0.95,
  stringsAsFactors = FALSE
)

# Ensure CI bounds are in valid range [0, 1]
bootstrap_results_df$ci_lower <- pmax(0, bootstrap_results_df$ci_lower)
bootstrap_results_df$ci_upper <- pmin(1, bootstrap_results_df$ci_upper)

cat("\nBootstrap results prepared:\n")
print(head(bootstrap_results_df))

save_bootstrap_results.fn(
  run_id = run_id,
  bootstrap_df = bootstrap_results_df,
  db_path = here("results", "analysis_results.db")
)

# ============================================================================
# STEP 8: Mark analysis as complete
# ============================================================================

complete_analysis_run.fn(
  run_id = run_id,
  db_path = here("results", "analysis_results.db")
)

cat("\n✓ Analysis complete! Run ID:", run_id, "\n")

# ============================================================================
# STEP 9: Query back results (verify they were saved)
# ============================================================================

cat("\nVerifying results in database...\n")

# Get run details
all_runs <- get_all_runs.fn(db_path = here("results", "analysis_results.db"))
cat("\nAll runs in database:\n")
print(all_runs)

# Get estimates from this run
estimates_back <- get_run_estimates.fn(
  run_id = run_id,
  estimate_type = "corrected",
  db_path = here("results", "analysis_results.db")
)
cat("\nCorrected estimates retrieved from database:\n")
print(head(estimates_back))

# Get bootstrap results
bootstrap_back <- get_bootstrap_results.fn(
  run_id = run_id,
  db_path = here("results", "analysis_results.db")
)
cat("\nBootstrap results retrieved from database:\n")
print(head(bootstrap_back))

cat("\n✓✓✓ Full workflow test successful! ✓✓✓\n")
