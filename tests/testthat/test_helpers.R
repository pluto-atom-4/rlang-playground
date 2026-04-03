# tests/testthat/test_helpers.R – Test utility functions and fixtures

# Fixture: Sample capture history data for testing
create_sample_capture_data.fn <- function(n_individuals = 50, n_occasions = 10) {
  set.seed(42)  # Reproducible
  
  data.frame(
    id = rep(1:n_individuals, each = n_occasions),
    occasion = rep(1:n_occasions, n_individuals),
    capture = rbinom(n_individuals * n_occasions, 1, prob = 0.7),
    stringsAsFactors = FALSE
  )
}

# Fixture: Sample tag-life data for testing
create_sample_tag_life_data.fn <- function(n_tags = 100, max_days = 365) {
  set.seed(42)
  
  data.frame(
    tag_id = 1:n_tags,
    failure_time = rgamma(n_tags, shape = 2, rate = 0.01),  # Gamma-distributed lifetimes
    stringsAsFactors = FALSE
  )
}

# Assertion: Check that result has expected list structure
expect_cjs_result_structure.fn <- function(result) {
  expect_type(result, "list")
  expect_true("estimates" %in% names(result), label = "Result has 'estimates'")
  expect_true("se" %in% names(result), label = "Result has 'se'")
  if ("convergence" %in% names(result)) {
    expect_true("status" %in% names(result$convergence) || 
                "convergence" %in% tolower(names(result)))
  }
}

# Assertion: Check that all numeric columns are valid (no NaN, reasonable range)
expect_valid_estimates.fn <- function(estimates_df, col_names = NULL) {
  if (is.null(col_names)) {
    col_names <- grep("estimate|phi|prob", names(estimates_df), value = TRUE)
  }
  
  for (col in col_names) {
    if (col %in% names(estimates_df)) {
      expect_true(!any(is.na(estimates_df[[col]])), 
                  label = paste("No NAs in", col))
      expect_true(!any(is.nan(estimates_df[[col]])), 
                  label = paste("No NaNs in", col))
      expect_true(all(estimates_df[[col]] >= 0 & estimates_df[[col]] <= 1), 
                  label = paste(col, "in [0,1]"))
    }
  }
}

# Assertion: Check database operation succeeded
expect_db_operation.fn <- function(run_id, table_name, db_path = "analysis_results.db") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  
  result <- DBI::dbGetQuery(con, 
    paste("SELECT COUNT(*) as cnt FROM", table_name, "WHERE run_id = ?"),
    params = list(run_id)
  )
  
  DBI::dbDisconnect(con)
  
  expect_equal(result$cnt, 1, 
               label = paste("Record found in", table_name, "for run", run_id))
}

# Helper: Extract specific estimates from cbrATLAS result list
extract_estimates.fn <- function(result, occasion = NULL) {
  if ("estimates" %in% names(result)) {
    est <- result$estimates
  } else {
    est <- result
  }
  
  if (!is.null(occasion) && is.numeric(est)) {
    return(est[occasion])
  }
  
  return(est)
}

# Helper: Compare two analysis runs (for regression testing)
compare_estimates.fn <- function(run_1_results, run_2_results, tolerance = 1e-6) {
  est_1 <- extract_estimates.fn(run_1_results)
  est_2 <- extract_estimates.fn(run_2_results)
  
  if (is.data.frame(est_1) && is.data.frame(est_2)) {
    # Numeric columns only
    cols <- intersect(names(est_1), names(est_2))
    cols <- cols[sapply(est_1[, cols, drop = FALSE], is.numeric)]
    
    max_diff <- max(abs(est_1[, cols] - est_2[, cols]), na.rm = TRUE)
    return(list(
      max_difference = max_diff,
      within_tolerance = max_diff <= tolerance
    ))
  }
  
  return(list(
    max_difference = max(abs(est_1 - est_2), na.rm = TRUE),
    within_tolerance = max(abs(est_1 - est_2), na.rm = TRUE) <= tolerance
  ))
}
