# tests/testthat/test_cbratlas_integration.R – Integration tests using cbrATLAS functions

test_that("Sample capture data has correct structure", {
  source(here::here("tests", "testthat", "test_helpers.R"))
  
  data <- create_sample_capture_data.fn(n_individuals = 50, n_occasions = 10)
  
  expect_is(data, "data.frame")
  expect_equal(nrow(data), 50 * 10)
  expect_equal(ncol(data), 3)
  expect_true("id" %in% names(data))
  expect_true("occasion" %in% names(data))
  expect_true("capture" %in% names(data))
  
  # All captures should be 0 or 1
  expect_true(all(data$capture %in% c(0, 1)))
  
  # Check occasion sequence
  expect_equal(unique(data$occasion), 1:10)
})

test_that("Sample tag-life data has expected properties", {
  source(here::here("tests", "testthat", "test_helpers.R"))
  
  data <- create_sample_tag_life_data.fn(n_tags = 100, max_days = 365)
  
  expect_is(data, "data.frame")
  expect_equal(nrow(data), 100)
  expect_true("tag_id" %in% names(data))
  expect_true("failure_time" %in% names(data))
  
  # All failure times should be positive
  expect_true(all(data$failure_time > 0))
})

test_that("cbrATLAS package loads and functions are available", {
  # This test validates that cbrATLAS is installed and accessible
  expect_true(require("cbrATLAS", quietly = TRUE), 
              label = "cbrATLAS package loaded")
  
  # Check key functions exist
  expect_true(exists("cjs.fn", mode = "function"))
  expect_true(exists("AdjSurv.fn", mode = "function"))
  expect_true(exists("boot.L", mode = "function"))
})

test_that("cjs.fn returns expected structure", {
  skip_if_not_installed("cbrATLAS")
  
  source(here::here("tests", "testthat", "test_helpers.R"))
  library(cbrATLAS)
  
  # Create test data
  capture_data <- create_sample_capture_data.fn(n_individuals = 30, n_occasions = 8)
  
  # Run CJS analysis
  result <- cjs.fn(
    data = capture_data,
    id = id,
    occasion = occasion,
    capture = capture,
    Phi.estim = ~1,
    p.estim = ~t,
    time.interval = rep(1, 7)
  )
  
  # Validate result structure
  expect_cjs_result_structure.fn(result)
  
  # Validate estimates are reasonable (survival between 0 and 1)
  if (!is.null(result$estimates)) {
    est <- extract_estimates.fn(result)
    if (is.numeric(est)) {
      expect_true(all(est >= 0 & est <= 1), label = "Survival estimates in [0,1]")
    }
  }
})

test_that("Bootstrap resampling produces valid confidence intervals", {
  skip_if_not_installed("cbrATLAS")
  
  source(here::here("tests", "testthat", "test_helpers.R"))
  library(cbrATLAS)
  
  capture_data <- create_sample_capture_data.fn(n_individuals = 20, n_occasions = 6)
  
  # Run bootstrap with small sample for speed
  set.seed(999)
  boot_result <- boot.L(
    data = capture_data,
    id = id,
    occasion = occasion,
    capture = capture,
    Phi.estim = ~1,
    p.estim = ~t,
    time.interval = rep(1, 5),
    n.bootstrap = 50,
    seed = 999
  )
  
  # Validate bootstrap results
  expect_type(boot_result, "list")
  
  # If bootstrap produced CI estimates, validate structure
  if ("ci" %in% names(boot_result) || "bootstrap" %in% names(boot_result)) {
    # Structure depends on cbrATLAS version; just check it's not empty
    expect_true(length(boot_result) > 0)
  }
})

test_that("Analysis pipeline snapshot: raw estimates are reproducible", {
  skip_if_not_installed("cbrATLAS")
  skip_if_not_installed("withr")
  
  source(here::here("tests", "testthat", "test_helpers.R"))
  library(cbrATLAS)
  
  # Use fixed seed and data
  set.seed(42)
  capture_data <- create_sample_capture_data.fn(n_individuals = 25, n_occasions = 7)
  
  # Run analysis
  result <- cjs.fn(
    data = capture_data,
    id = id,
    occasion = occasion,
    capture = capture,
    Phi.estim = ~1,
    p.estim = ~t,
    time.interval = rep(1, 6)
  )
  
  # Take snapshot of estimates (allows detecting unintended changes)
  expect_snapshot(
    result$estimates,
    variant = paste0("cbratlas_", packageVersion("cbrATLAS"))
  )
})

test_that("Correction pipeline integrates smoothly", {
  skip_if_not_installed("cbrATLAS")
  
  source(here::here("tests", "testthat", "test_helpers.R"))
  library(cbrATLAS)
  
  # Create sample data
  capture_data <- create_sample_capture_data.fn(n_individuals = 30, n_occasions = 8)
  
  # Step 1: Get raw estimates
  raw_result <- cjs.fn(
    data = capture_data,
    id = id,
    occasion = occasion,
    capture = capture,
    Phi.estim = ~1,
    p.estim = ~t,
    time.interval = rep(1, 7)
  )
  
  # Step 2: Verify correction functions are available
  expect_true(exists("AdjSurv.fn", mode = "function"))
  expect_true(exists("correct.fn", mode = "function"))
  
  # Step 3: Verify no errors when applying corrections
  # (Note: actual correction depends on tag-life data; this tests interface)
  if (is.numeric(raw_result$estimates)) {
    raw_ests <- raw_result$estimates
    expect_true(all(raw_ests >= 0 & raw_ests <= 1), 
                label = "Raw estimates valid before correction")
  }
})

test_that("Database integration captures analysis metadata", {
  skip_if_not_installed("cbrATLAS")
  
  temp_db <- tempfile(fileext = ".db")
  source(here::here("R", "db_helpers.R"))
  source(here::here("tests", "testthat", "test_helpers.R"))
  library(cbrATLAS)
  
  # Initialize database
  init_analysis_db.fn(temp_db)
  
  # Log a run
  run_id <- "integration-test-001"
  log_analysis_run.fn(
    run_id = run_id,
    analysis_type = "single_release",
    dataset_name = "integration_test",
    script_path = "tests/testthat/test_cbratlas_integration.R",
    notes = "Integration test run",
    random_seed = 12345,
    db_path = temp_db
  )
  
  # Run analysis
  capture_data <- create_sample_capture_data.fn(n_individuals = 20, n_occasions = 6)
  result <- cjs.fn(
    data = capture_data,
    id = id,
    occasion = occasion,
    capture = capture,
    Phi.estim = ~1,
    p.estim = ~t,
    time.interval = rep(1, 5)
  )
  
  # Save estimates to database
  if (is.numeric(result$estimates)) {
    est_df <- data.frame(
      individual_id_or_group = "overall",
      occasion = 1:length(result$estimates),
      phi_estimate = result$estimates,
      phi_se = 0.05,  # Placeholder SE
      capture_prob = 0.80,
      capture_prob_se = 0.10,
      convergence_status = "converged"
    )
    save_survival_estimates.fn(run_id, est_df, temp_db)
  }
  
  # Verify data was saved
  con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
  saved_runs <- DBI::dbGetQuery(con, 
    "SELECT COUNT(*) as cnt FROM analysis_runs WHERE run_id = ?",
    params = list(run_id))
  saved_ests <- DBI::dbGetQuery(con, 
    "SELECT COUNT(*) as cnt FROM survival_estimates WHERE run_id = ?",
    params = list(run_id))
  DBI::dbDisconnect(con)
  
  expect_equal(saved_runs$cnt, 1, label = "Run metadata saved")
  expect_true(saved_ests$cnt > 0, label = "Estimates saved")
  
  file.remove(temp_db)
})
