# tests/testthat/test_db_helpers.R – Unit & integration tests for database functions

test_that("init_analysis_db.fn creates database with correct schema", {
  # Create temp directory for test
  temp_db <- tempfile(fileext = ".db")
  
  # Initialize database
  source(here::here("R", "db_helpers.R"))
  init_analysis_db.fn(temp_db)
  
  # Verify file exists
  expect_true(file.exists(temp_db))
  
  # Connect and check tables
  con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
  tables <- DBI::dbListTables(con)
  
  expect_true("analysis_runs" %in% tables)
  expect_true("survival_estimates" %in% tables)
  expect_true("corrected_estimates" %in% tables)
  expect_true("bootstrap_results" %in% tables)
  
  # Check analysis_runs schema
  cols <- DBI::dbListFields(con, "analysis_runs")
  expect_true("run_id" %in% cols)
  expect_true("created_at" %in% cols)
  expect_true("analysis_type" %in% cols)
  expect_true("random_seed" %in% cols)
  expect_true("status" %in% cols)
  
  DBI::dbDisconnect(con)
  file.remove(temp_db)
})

test_that("log_analysis_run.fn inserts run metadata", {
  temp_db <- tempfile(fileext = ".db")
  source(here::here("R", "db_helpers.R"))
  init_analysis_db.fn(temp_db)
  
  run_id <- "test-run-001"
  log_analysis_run.fn(
    run_id = run_id,
    analysis_type = "single_release",
    dataset_name = "test_data",
    script_path = "tests/test_script.R",
    notes = "Unit test run",
    random_seed = 12345,
    db_path = temp_db
  )
  
  # Verify run was logged
  con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
  runs <- DBI::dbGetQuery(con, "SELECT * FROM analysis_runs WHERE run_id = ?", 
                          params = list(run_id))
  DBI::dbDisconnect(con)
  
  expect_equal(nrow(runs), 1)
  expect_equal(runs$run_id, run_id)
  expect_equal(runs$analysis_type, "single_release")
  expect_equal(runs$dataset_name, "test_data")
  expect_equal(runs$random_seed, 12345)
  expect_equal(runs$status, "in_progress")
  
  file.remove(temp_db)
})

test_that("save_survival_estimates.fn validates required columns", {
  temp_db <- tempfile(fileext = ".db")
  source(here::here("R", "db_helpers.R"))
  init_analysis_db.fn(temp_db)
  
  run_id <- "test-run-001"
  log_analysis_run.fn(run_id = run_id, analysis_type = "test", 
                      dataset_name = "test", db_path = temp_db)
  
  # Missing required columns
  bad_df <- data.frame(
    individual_id_or_group = "fish_1",
    occasion = 1
    # Missing: phi_estimate, phi_se
  )
  
  expect_error(save_survival_estimates.fn(run_id, bad_df, temp_db),
               "missing required columns")
  
  file.remove(temp_db)
})

test_that("save_survival_estimates.fn inserts estimates correctly", {
  temp_db <- tempfile(fileext = ".db")
  source(here::here("R", "db_helpers.R"))
  init_analysis_db.fn(temp_db)
  
  run_id <- "test-run-001"
  log_analysis_run.fn(run_id = run_id, analysis_type = "test", 
                      dataset_name = "test", db_path = temp_db)
  
  # Create sample estimates
  estimates <- data.frame(
    individual_id_or_group = c("fish_1", "fish_1", "fish_2", "fish_2"),
    occasion = c(1, 2, 1, 2),
    phi_estimate = c(0.95, 0.92, 0.96, 0.93),
    phi_se = c(0.05, 0.06, 0.04, 0.07),
    capture_prob = c(0.80, 0.82, 0.79, 0.81),
    capture_prob_se = c(0.10, 0.10, 0.11, 0.09),
    convergence_status = c("converged", "converged", "converged", "converged")
  )
  
  save_survival_estimates.fn(run_id, estimates, temp_db)
  
  # Verify data was saved
  con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
  saved <- DBI::dbGetQuery(con, 
                           "SELECT * FROM survival_estimates WHERE run_id = ?",
                           params = list(run_id))
  DBI::dbDisconnect(con)
  
  expect_equal(nrow(saved), 4)
  expect_equal(mean(saved$phi_estimate), mean(estimates$phi_estimate))
  
  file.remove(temp_db)
})

test_that("complete_analysis_run.fn updates status", {
  temp_db <- tempfile(fileext = ".db")
  source(here::here("R", "db_helpers.R"))
  init_analysis_db.fn(temp_db)
  
  run_id <- "test-run-001"
  log_analysis_run.fn(run_id = run_id, analysis_type = "test", 
                      dataset_name = "test", db_path = temp_db)
  
  # Verify initial status
  con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
  initial <- DBI::dbGetQuery(con, 
    "SELECT status FROM analysis_runs WHERE run_id = ?", 
    params = list(run_id))
  expect_equal(initial$status, "in_progress")
  DBI::dbDisconnect(con)
  
  # Complete the run
  complete_analysis_run.fn(run_id, temp_db)
  
  # Verify updated status
  con <- DBI::dbConnect(RSQLite::SQLite(), temp_db)
  updated <- DBI::dbGetQuery(con, 
    "SELECT status FROM analysis_runs WHERE run_id = ?", 
    params = list(run_id))
  expect_equal(updated$status, "completed")
  DBI::dbDisconnect(con)
  
  file.remove(temp_db)
})

test_that("get_all_runs.fn retrieves all runs ordered by timestamp", {
  temp_db <- tempfile(fileext = ".db")
  source(here::here("R", "db_helpers.R"))
  init_analysis_db.fn(temp_db)
  
  # Log multiple runs
  for (i in 1:3) {
    log_analysis_run.fn(
      run_id = paste0("test-run-", i),
      analysis_type = "test",
      dataset_name = "test",
      db_path = temp_db
    )
    Sys.sleep(0.1)  # Ensure different timestamps
  }
  
  runs <- get_all_runs.fn(temp_db)
  
  expect_equal(nrow(runs), 3)
  # Should be ordered by created_at DESC (most recent first)
  expect_equal(runs$run_id[1], "test-run-3")
  
  file.remove(temp_db)
})

test_that("get_run_estimates.fn returns correct estimate type", {
  temp_db <- tempfile(fileext = ".db")
  source(here::here("R", "db_helpers.R"))
  init_analysis_db.fn(temp_db)
  
  run_id <- "test-run-001"
  log_analysis_run.fn(run_id = run_id, analysis_type = "test", 
                      dataset_name = "test", db_path = temp_db)
  
  # Save estimates
  raw_est <- data.frame(
    individual_id_or_group = "fish_1",
    occasion = 1,
    phi_estimate = 0.95,
    phi_se = 0.05,
    capture_prob = 0.80,
    capture_prob_se = 0.10,
    convergence_status = "converged"
  )
  save_survival_estimates.fn(run_id, raw_est, temp_db)
  
  # Retrieve and verify
  retrieved <- get_run_estimates.fn(run_id, "raw", temp_db)
  expect_equal(nrow(retrieved), 1)
  expect_equal(retrieved$phi_estimate, 0.95)
  
  file.remove(temp_db)
})
