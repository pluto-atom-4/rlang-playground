# Project-level R startup script for reproducible analysis environment
# This file is sourced automatically when R starts in this project directory

# Initialize here::here() if available (marks project root for portable paths)
if (requireNamespace("here", quietly = TRUE)) {
  here::i_am("README.md")  # Mark project root for here::here() functions
}

# Set CRAN mirror for reproducible package installation
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Optional: Set width for readable console output
options(width = 100)

# Optional: Disable scientific notation for cleaner output
options(scipen = 10)

# Message indicating project initialization
if (!exists(".project_initialized")) {
  cat("✓ cbrATLAS analysis environment initialized\n")
  cat("  Use here::here() for portable file paths\n")
  .project_initialized <- TRUE
}
