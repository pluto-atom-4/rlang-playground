# setup_tests.R – Install test dependencies and initialize test environment

# Install required packages for testing
install_test_deps <- function() {
  packages <- c(
    "testthat",      # Testing framework
    "DBI",           # Database interface
    "RSQLite",       # SQLite driver
    "withr",         # Temporary environment management
    "covr"           # Code coverage
  )
  
  missing <- setdiff(packages, rownames(installed.packages()))
  
  if (length(missing) > 0) {
    cat("Installing test dependencies:", paste(missing, collapse = ", "), "\n")
    install.packages(missing)
  } else {
    cat("✓ All test dependencies already installed\n")
  }
  
  invisible(missing)
}

# Verify cbrATLAS is installed
verify_cbratlas <- function() {
  if (!require("cbrATLAS", quietly = TRUE)) {
    stop(
      "cbrATLAS not installed. Run:\n",
      "  install.packages('devtools')\n",
      "  devtools::install_github('Columbia-Basin-Research-West/cbrATLAS')"
    )
  }
  
  cat("✓ cbrATLAS installed (version", 
      as.character(packageVersion("cbrATLAS")), ")\n")
  invisible(TRUE)
}

# Initialize test database
init_test_db <- function(db_path = "analysis_results.db") {
  if (!file.exists(db_path)) {
    source("R/db_helpers.R")
    init_analysis_db.fn(db_path)
    cat("✓ Test database initialized at", db_path, "\n")
  } else {
    cat("ℹ Test database already exists at", db_path, "\n")
  }
  invisible(db_path)
}

# Run all setup steps
setup_testing_environment <- function() {
  cat("Setting up testing environment...\n")
  cat("━" %+% strrep("━", 50) %+% "\n")
  
  install_test_deps()
  verify_cbratlas()
  init_test_db()
  
  cat("━" %+% strrep("━", 50) %+% "\n")
  cat("✓ Testing environment ready!\n")
  cat("\nNext steps:\n")
  cat("1. Run all tests: testthat::test_dir('tests/testthat')\n")
  cat("2. Run specific file: testthat::test_file('tests/testthat/test_db_helpers.R')\n")
  cat("3. See full guide: cat(readLines('tests/README.md'), sep = '\\n')\n")
}

# Execute setup if run directly
if (!interactive()) {
  setup_testing_environment()
} else {
  # If interactive, just define function and let user call it
  cat("Run: setup_testing_environment()\n")
}
