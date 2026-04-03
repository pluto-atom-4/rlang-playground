# tests/testthat.R – Run all tests via testthat
library(testthat)

# Load local helper functions
source(here::here("R", "db_helpers.R"))

# Run all tests in tests/testthat/
test_dir(here::here("tests", "testthat"))
