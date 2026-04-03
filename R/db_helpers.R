# Database Helpers for cbrATLAS Analysis Results Tracking
# 
# Helper functions to initialize and manage the analysis results database.
# Use these functions in analysis scripts to log results reproducibly.

library(DBI)
library(RSQLite)

# Initialize the analysis results database with schema
init_analysis_db.fn <- function(db_path = "analysis_results.db") {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  # Create analysis_runs table
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS analysis_runs (
      run_id TEXT PRIMARY KEY,
      created_at TEXT,
      analysis_type TEXT,
      dataset_name TEXT,
      script_path TEXT,
      notes TEXT,
      random_seed INTEGER,
      status TEXT DEFAULT 'completed'
    )
  ")
  
  # Create survival_estimates table
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS survival_estimates (
      run_id TEXT,
      individual_id_or_group TEXT,
      occasion INTEGER,
      phi_estimate REAL,
      phi_se REAL,
      capture_prob REAL,
      capture_prob_se REAL,
      convergence_status TEXT,
      PRIMARY KEY (run_id, individual_id_or_group, occasion),
      FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
    )
  ")
  
  # Create corrected_estimates table
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS corrected_estimates (
      run_id TEXT,
      individual_id_or_group TEXT,
      occasion INTEGER,
      raw_phi REAL,
      tag_failure_prob REAL,
      corrected_phi REAL,
      corrected_phi_se REAL,
      correction_method TEXT,
      PRIMARY KEY (run_id, individual_id_or_group, occasion),
      FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
    )
  ")
  
  # Create bootstrap_results table
  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS bootstrap_results (
      run_id TEXT,
      individual_id_or_group TEXT,
      occasion INTEGER,
      estimate_type TEXT,
      n_bootstrap INTEGER,
      estimate REAL,
      ci_lower REAL,
      ci_upper REAL,
      ci_level REAL,
      PRIMARY KEY (run_id, individual_id_or_group, occasion, estimate_type),
      FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
    )
  ")
  
  dbDisconnect(con)
  cat("✓ Database initialized at:", db_path, "\n")
  invisible(db_path)
}

# Log an analysis run to the database
log_analysis_run.fn <- function(
  run_id,
  analysis_type,
  dataset_name,
  script_path = NA_character_,
  notes = NA_character_,
  random_seed = NA_integer_,
  db_path = "analysis_results.db"
) {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  run_data <- data.frame(
    run_id = run_id,
    created_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ"),
    analysis_type = analysis_type,
    dataset_name = dataset_name,
    script_path = script_path,
    notes = notes,
    random_seed = random_seed,
    status = "in_progress",
    stringsAsFactors = FALSE
  )
  
  dbAppendTable(con, "analysis_runs", run_data)
  dbDisconnect(con)
  
  cat("✓ Logged run:", run_id, "\n")
  invisible(run_id)
}

# Mark a run as completed
complete_analysis_run.fn <- function(run_id, db_path = "analysis_results.db") {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  dbExecute(con, "
    UPDATE analysis_runs 
    SET status = 'completed' 
    WHERE run_id = ?
  ", params = list(run_id))
  
  dbDisconnect(con)
  cat("✓ Marked run as completed:", run_id, "\n")
  invisible(run_id)
}

# Save survival estimates to database
save_survival_estimates.fn <- function(
  run_id,
  estimates_df,
  db_path = "analysis_results.db"
) {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  # Ensure required columns exist
  required_cols <- c("individual_id_or_group", "occasion", "phi_estimate", "phi_se")
  if (!all(required_cols %in% names(estimates_df))) {
    stop("estimates_df missing required columns:", 
         paste(setdiff(required_cols, names(estimates_df)), collapse = ", "))
  }
  
  # Add run_id
  estimates_df$run_id <- run_id
  
  dbAppendTable(con, "survival_estimates", estimates_df)
  dbDisconnect(con)
  
  cat("✓ Saved", nrow(estimates_df), "survival estimates for run:", run_id, "\n")
  invisible(estimates_df)
}

# Save corrected estimates to database
save_corrected_estimates.fn <- function(
  run_id,
  corrected_df,
  db_path = "analysis_results.db"
) {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  # Ensure required columns exist
  required_cols <- c("individual_id_or_group", "occasion", "raw_phi", 
                     "corrected_phi", "corrected_phi_se")
  if (!all(required_cols %in% names(corrected_df))) {
    stop("corrected_df missing required columns:", 
         paste(setdiff(required_cols, names(corrected_df)), collapse = ", "))
  }
  
  # Add run_id
  corrected_df$run_id <- run_id
  
  dbAppendTable(con, "corrected_estimates", corrected_df)
  dbDisconnect(con)
  
  cat("✓ Saved", nrow(corrected_df), "corrected estimates for run:", run_id, "\n")
  invisible(corrected_df)
}

# Save bootstrap results to database
save_bootstrap_results.fn <- function(
  run_id,
  bootstrap_df,
  db_path = "analysis_results.db"
) {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  # Ensure required columns exist
  required_cols <- c("individual_id_or_group", "occasion", "estimate_type",
                     "n_bootstrap", "estimate", "ci_lower", "ci_upper")
  if (!all(required_cols %in% names(bootstrap_df))) {
    stop("bootstrap_df missing required columns:", 
         paste(setdiff(required_cols, names(bootstrap_df)), collapse = ", "))
  }
  
  # Add run_id
  bootstrap_df$run_id <- run_id
  
  dbAppendTable(con, "bootstrap_results", bootstrap_df)
  dbDisconnect(con)
  
  cat("✓ Saved", nrow(bootstrap_df), "bootstrap results for run:", run_id, "\n")
  invisible(bootstrap_df)
}

# Query all runs in database
get_all_runs.fn <- function(db_path = "analysis_results.db") {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  runs <- dbGetQuery(con, "
    SELECT * FROM analysis_runs 
    ORDER BY created_at DESC
  ")
  
  dbDisconnect(con)
  return(runs)
}

# Query estimates for a specific run
get_run_estimates.fn <- function(
  run_id,
  estimate_type = "raw",  # 'raw' or 'corrected'
  db_path = "analysis_results.db"
) {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  if (estimate_type == "raw") {
    results <- dbGetQuery(con, "
      SELECT * FROM survival_estimates 
      WHERE run_id = ?
      ORDER BY individual_id_or_group, occasion
    ", params = list(run_id))
  } else if (estimate_type == "corrected") {
    results <- dbGetQuery(con, "
      SELECT * FROM corrected_estimates 
      WHERE run_id = ?
      ORDER BY individual_id_or_group, occasion
    ", params = list(run_id))
  } else {
    stop("estimate_type must be 'raw' or 'corrected'")
  }
  
  dbDisconnect(con)
  return(results)
}

# Query bootstrap results for a specific run
get_bootstrap_results.fn <- function(
  run_id,
  db_path = "analysis_results.db"
) {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  
  results <- dbGetQuery(con, "
    SELECT * FROM bootstrap_results 
    WHERE run_id = ?
    ORDER BY individual_id_or_group, occasion, estimate_type
  ", params = list(run_id))
  
  dbDisconnect(con)
  return(results)
}

# Example usage (comment out or remove after testing):
#
# # Initialize database (run once)
# init_analysis_db.fn()
#
# # Log a new analysis run
# log_analysis_run.fn(
#   run_id = "run-2026-04-03-single-release-001",
#   analysis_type = "single_release",
#   dataset_name = "steelhead_2025",
#   script_path = "analyses/example-01-single-release.R",
#   notes = "Initial single-release analysis with 100 fish",
#   random_seed = 12345
# )
#
# # After running analysis, save results
# # save_survival_estimates.fn(run_id, survival_results_df)
# # save_corrected_estimates.fn(run_id, corrected_results_df)
# # save_bootstrap_results.fn(run_id, bootstrap_results_df)
#
# # Mark run complete
# # complete_analysis_run.fn(run_id)
#
# # Query results
# # get_run_estimates.fn(run_id, estimate_type = "corrected")
