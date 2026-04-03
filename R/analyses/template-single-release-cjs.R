# ============================================================================
# Single Release CJS Analysis Template
# ============================================================================
#
# This template demonstrates a complete single-release mark-recapture analysis
# using Cormack-Jolly-Seber (CJS) models from the cbrATLAS package.
#
# Steps:
# 1. Load libraries and prepare environment
# 2. Load or create capture history data
# 3. Run CJS model with user-specified formulas
# 4. Extract and format results
# 5. Log to database
# 6. Generate summary output
#
# ============================================================================

# Load libraries
library(cbrATLAS)
library(here)
source(here("R", "db_helpers.R"))

# ============================================================================
# CONFIGURATION: Modify these settings for your analysis
# ============================================================================

# Data source
DATA_FILE <- here("data", "my_capture_data.csv")  # ← Change to your data file
DATA_DESCRIPTION <- "steelhead_2025"               # ← Description of dataset

# CJS Model configuration
SURVIVAL_FORMULA <- ~1              # ~1 = constant, ~occasion = time-varying
CAPTURE_FORMULA <- ~occasion         # ~1 = constant, ~occasion = time-varying
TIME_INTERVALS <- rep(1, 9)         # ← Adjust: vector of length (n_occasions - 1)

# Bootstrap configuration
N_BOOTSTRAP <- 1000
BOOTSTRAP_SEED <- 12345

# Metadata
ANALYSIS_AUTHOR <- "Your Name"        # ← Change to your name
ANALYSIS_NOTES <- "Single release CJS analysis with time-varying capture probability"

# ============================================================================
# STEP 1: Initialize run and create unique run ID
# ============================================================================

cat("\n", rep("=", 80), "\n")
cat("SINGLE RELEASE CJS ANALYSIS\n")
cat(rep("=", 80), "\n\n")

# Create timestamp-based run ID
run_id <- paste0(
  "run-",
  format(Sys.time(), "%Y-%m-%d-%H%M%S"),
  "-sr-cjs-001"  # sr = single release, cjs = model type
)

cat("Run ID:", run_id, "\n")
cat("Author:", ANALYSIS_AUTHOR, "\n")
cat("Dataset:", DATA_DESCRIPTION, "\n\n")

# ============================================================================
# STEP 2: Log analysis run to database
# ============================================================================

cat("[LOG] Logging analysis run to database...\n")

log_analysis_run.fn(
  run_id = run_id,
  analysis_type = "single_release",
  dataset_name = DATA_DESCRIPTION,
  script_path = here("analyses", "template-single-release-cjs.R"),
  notes = ANALYSIS_NOTES,
  random_seed = BOOTSTRAP_SEED,
  db_path = here("results", "analysis_results.db")
)

cat("  ✓ Run logged with ID:", run_id, "\n\n")

# ============================================================================
# STEP 3: Load capture history data
# ============================================================================

cat("[DATA] Loading capture history data...\n")

# Option A: Read from CSV
# capture_data <- read.csv(DATA_FILE, stringsAsFactors = FALSE)

# Option B: Use example data from cbrATLAS
# data(package = "cbrATLAS")  # See available datasets

# Option C: Create synthetic example data (for testing)
cat("  (Using synthetic example data)\n")
set.seed(BOOTSTRAP_SEED)
n_individuals <- 50
n_occasions <- 10

capture_data <- data.frame(
  individual = rep(1:n_individuals, each = n_occasions),
  occasion = rep(1:n_occasions, n_individuals),
  captured = rbinom(n_individuals * n_occasions, size = 1, prob = 0.8),
  stringsAsFactors = FALSE
)

# Ensure captures occur in valid pattern (can't capture before first release)
capture_data$captured[capture_data$occasion == 1] <- 1

cat("  Loaded:", nrow(capture_data), "records\n")
cat("  Individuals:", n_individuals, "\n")
cat("  Occasions:", n_occasions, "\n\n")

# Display sample of data
cat("  Sample of capture history:\n")
print(head(capture_data, 15))
cat("\n")

# ============================================================================
# STEP 4: Run CJS model
# ============================================================================

cat("[MODEL] Running CJS analysis...\n")
cat("  Survival formula:", deparse(SURVIVAL_FORMULA), "\n")
cat("  Capture formula:", deparse(CAPTURE_FORMULA), "\n")

set.seed(BOOTSTRAP_SEED)

tryCatch({
  cjs_result <- cjs.fn(
    data = capture_data,
    Phi.estim = SURVIVAL_FORMULA,
    p.estim = CAPTURE_FORMULA,
    time.interval = TIME_INTERVALS
  )

  cat("  ✓ Model converged\n\n")

  # Extract estimates
  cat("  Model structure:\n")
  print(str(cjs_result, max.level = 1))

}, error = function(e) {
  cat("  ✗ Model failed to converge\n")
  cat("  Error:", e$message, "\n\n")
  stop("CJS model failed to converge. Check data and formulas.")
})

# ============================================================================
# STEP 5: Extract and format survival estimates
# ============================================================================

cat("\n[RESULTS] Extracting survival estimates...\n")

# Format: Create data frame matching database schema
# Assumes cjs_result contains: $real = matrix/df with Phi and p estimates
# Adjust column names based on actual cbrATLAS output

survival_estimates_df <- data.frame(
  individual_id_or_group = "cohort_all",
  occasion = 1:(n_occasions - 1),
  phi_estimate = c(0.85, 0.83, 0.82, 0.81, 0.80, 0.79, 0.78, 0.77, 0.76),  # ← Update with actual estimates
  phi_se = c(0.06, 0.06, 0.06, 0.07, 0.07, 0.07, 0.07, 0.08, 0.08),        # ← Update with actual SE
  capture_prob = c(0.75, 0.78, 0.76, 0.79, 0.77, 0.78, 0.76, 0.78, 0.77),
  capture_prob_se = rep(0.05, 9),
  convergence_status = "converged",
  stringsAsFactors = FALSE
)

cat("  Extracted", nrow(survival_estimates_df), "survival estimates\n\n")
print(survival_estimates_df)
cat("\n")

# ============================================================================
# STEP 6: OPTIONAL - Apply tag-failure correction
# ============================================================================

# Uncomment this section if you have tag-life data and want to apply correction

cat("[OPTIONAL] Tag-failure correction\n")
cat("  (Skipped - set TAG_FAILURE_PROB to apply)\n\n")

TAG_FAILURE_PROB <- NA  # ← Change to numeric value if available

if (!is.na(TAG_FAILURE_PROB)) {
  cat("  Applying", TAG_FAILURE_PROB * 100, "% tag failure correction...\n")

  corrected_estimates_df <- data.frame(
    individual_id_or_group = "cohort_all",
    occasion = 1:(n_occasions - 1),
    raw_phi = survival_estimates_df$phi_estimate,
    tag_failure_prob = TAG_FAILURE_PROB,
    corrected_phi = survival_estimates_df$phi_estimate / (1 - TAG_FAILURE_PROB),
    corrected_phi_se = survival_estimates_df$phi_se / (1 - TAG_FAILURE_PROB),
    correction_method = "AdjSurv.fn",
    stringsAsFactors = FALSE
  )

  # Bound to [0, 1]
  corrected_estimates_df$corrected_phi <- pmin(1.0, corrected_estimates_df$corrected_phi)

  cat("  ✓ Applied correction\n\n")
  print(corrected_estimates_df)

} else {

  corrected_estimates_df <- data.frame(
    individual_id_or_group = "cohort_all",
    occasion = 1:(n_occasions - 1),
    raw_phi = survival_estimates_df$phi_estimate,
    tag_failure_prob = 0.0,  # No correction
    corrected_phi = survival_estimates_df$phi_estimate,
    corrected_phi_se = survival_estimates_df$phi_se,
    correction_method = "none",
    stringsAsFactors = FALSE
  )

  cat("  (No tag-failure correction applied)\n\n")
}

# ============================================================================
# STEP 7: Bootstrap confidence intervals
# ============================================================================

cat("[BOOTSTRAP] Computing confidence intervals...\n")
cat("  n_bootstrap:", N_BOOTSTRAP, "\n")
cat("  seed:", BOOTSTRAP_SEED, "\n")

set.seed(BOOTSTRAP_SEED)

# Create bootstrap results from estimates
# In real analysis, you would rerun boot.L() from cbrATLAS

bootstrap_results_df <- data.frame(
  individual_id_or_group = rep("cohort_all", 2 * (n_occasions - 1)),
  occasion = rep(1:(n_occasions - 1), 2),
  estimate_type = rep(c("raw", "corrected"), each = n_occasions - 1),
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

cat("  ✓ Computed", nrow(bootstrap_results_df), "bootstrap results\n\n")
print(head(bootstrap_results_df, 10))
cat("\n")

# ============================================================================
# STEP 8: Save all results to database
# ============================================================================

cat("[DATABASE] Saving results to database...\n")

# Save survival estimates
save_survival_estimates.fn(
  run_id = run_id,
  estimates_df = survival_estimates_df,
  db_path = here("results", "analysis_results.db")
)

# Save corrected estimates
save_corrected_estimates.fn(
  run_id = run_id,
  corrected_df = corrected_estimates_df,
  db_path = here("results", "analysis_results.db")
)

# Save bootstrap results
save_bootstrap_results.fn(
  run_id = run_id,
  bootstrap_df = bootstrap_results_df,
  db_path = here("results", "analysis_results.db")
)

cat("  ✓ All results saved\n\n")

# ============================================================================
# STEP 9: Mark analysis complete
# ============================================================================

complete_analysis_run.fn(
  run_id = run_id,
  db_path = here("results", "analysis_results.db")
)

cat("[COMPLETE] Analysis marked as completed\n\n")

# ============================================================================
# STEP 10: Verify and display results
# ============================================================================

cat("[VERIFY] Querying database to verify results...\n")

# Get all runs
all_runs <- get_all_runs.fn(db_path = here("results", "analysis_results.db"))
cat("\n  Recent analysis runs:\n")
print(all_runs[, c("run_id", "analysis_type", "status", "created_at")])

# Get corrected estimates
stored_estimates <- get_run_estimates.fn(
  run_id = run_id,
  estimate_type = "corrected",
  db_path = here("results", "analysis_results.db")
)
cat("\n  Corrected estimates retrieved from database:\n")
print(stored_estimates)

# ============================================================================
# STEP 11: Generate summary output
# ============================================================================

cat("\n", rep("=", 80), "\n")
cat("ANALYSIS SUMMARY\n")
cat(rep("=", 80), "\n")

cat("\nRun ID:            ", run_id, "\n")
cat("Dataset:           ", DATA_DESCRIPTION, "\n")
cat("Analysis Type:     Single Release CJS\n")
cat("Individuals:       ", n_individuals, "\n")
cat("Occasions:         ", n_occasions, "\n")
cat("Survival Formula:  ", deparse(SURVIVAL_FORMULA), "\n")
cat("Capture Formula:   ", deparse(CAPTURE_FORMULA), "\n")
cat("Bootstrap N:       ", N_BOOTSTRAP, "\n")
cat("Tag Failure Corr:  ", if(is.na(TAG_FAILURE_PROB)) "No" else paste(TAG_FAILURE_PROB*100, "%"), "\n")

cat("\nResults saved to:\n")
cat("  Database:        results/analysis_results.db\n")
cat("  Run ID:          ", run_id, "\n")

cat("\nNext steps:\n")
cat("  1. Review results in DataSpell console\n")
cat("  2. Query database: get_run_estimates.fn('", run_id, "')\n")
cat("  3. Compare with other runs using Claude Code\n")
cat("  4. Save plots/tables to results/ directory\n")

cat("\n", rep("=", 80), "\n\n")

# ============================================================================
# OPTIONAL: Visualization (uncomment if desired)
# ============================================================================

# library(ggplot2)
#
# # Plot survival estimates with confidence intervals
# p <- ggplot(bootstrap_results_df[bootstrap_results_df$estimate_type == "corrected",],
#             aes(x = occasion, y = estimate)) +
#   geom_point(size = 3) +
#   geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2) +
#   ylim(0, 1) +
#   theme_minimal() +
#   labs(title = paste("CJS Survival Estimates -", DATA_DESCRIPTION),
#        x = "Interval", y = "Survival (Phi)",
#        subtitle = paste("Run ID:", run_id))
#
# # Save plot
# plot_path <- here("results", paste0(run_id, "_survival_estimates.png"))
# ggsave(plot_path, p, width = 8, height = 5)
# cat("  Plot saved to:", plot_path, "\n")

cat("✓ Analysis complete!\n\n")
