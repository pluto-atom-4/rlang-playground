# Manual Inspection Checklist

**Use this checklist to manually verify each component of the setup.**

Date: _______________    Inspector: _______________

---

## ✅ SECTION 1: Environment & Installation

### 1.1 Python & Package Manager
```
[ ] Python installed: python --version
    Expected: Python 3.14+
    Actual: _________________________________

[ ] pip installed: pip --version
    Expected: pip 25.0+
    Actual: _________________________________

[ ] uv installed: uv --version
    Expected: uv 0.9.26 or later
    Actual: _________________________________
```

### 1.2 R Installation
```
[ ] R installed at: C:\Program Files\R\R-4.5.3
    Verify: dir "C:\Program Files\R\R-4.5.3\bin"
    Should show: Rscript.exe, R.exe, Rcmd.exe

[ ] R version: "C:/Program Files/R/R-4.5.3/bin/Rscript.exe" --version
    Expected: R version 4.5.3 or later
    Actual: _________________________________
```

### 1.3 R Packages (run in R console)
```
[ ] DBI installed
    Command: library(DBI); packageVersion("DBI")
    Status: [ ] Yes [ ] No

[ ] RSQLite installed
    Command: library(RSQLite); packageVersion("RSQLite")
    Status: [ ] Yes [ ] No

[ ] here installed
    Command: library(here); packageVersion("here")
    Status: [ ] Yes [ ] No

[ ] cbrATLAS installed
    Command: library(cbrATLAS); packageVersion("cbrATLAS")
    Version expected: 0.2.0.0
    Status: [ ] Yes [ ] No

[ ] failCompare installed
    Command: library(failCompare); packageVersion("failCompare")
    Status: [ ] Yes [ ] No

[ ] devtools installed
    Command: library(devtools); packageVersion("devtools")
    Status: [ ] Yes [ ] No

[ ] remotes installed
    Command: library(remotes); packageVersion("remotes")
    Status: [ ] Yes [ ] No
```

---

## ✅ SECTION 2: Project Structure

### 2.1 Directory Structure
```
C:/Users/nobu/Documents/JetBrains/rlang-playground/

[ ] .claude/ directory exists
    [ ] .claude/settings.json exists (see Section 3)

[ ] .github/ directory exists
    [ ] .github/copilot-instructions.md exists

[ ] R/analyses/ directory exists
    [ ] R/analyses/.gitkeep exists
    [ ] R/analyses/notes/ directory exists
    [ ] R/analyses/example-01-simplified-test.R exists
    [ ] R/analyses/example-02-cjs-workflow.R exists
    [ ] R/analyses/template-single-release-cjs.R exists

[ ] data/ directory exists

[ ] data-raw/ directory exists

[ ] docs/ directory exists
    [ ] docs/COMPLETE_SETUP_DOCUMENTATION.md exists
    [ ] docs/MANUAL_INSPECTION_CHECKLIST.md exists (this file)
    [ ] docs/SETUP_COMPLETE.md exists
    [ ] docs/TEST_SCRIPT_WALKTHROUGH.md exists
    [ ] docs/start-from-here.md exists

[ ] R/ directory exists
    [ ] R/db_helpers.R exists

[ ] results/ directory exists
    [ ] results/README.md exists
    [ ] results/analysis_results.db exists

[ ] tests/ directory exists

[ ] .gitignore file exists

[ ] .Rprofile file exists

[ ] .Rbuildignore file exists

[ ] about-me.md file exists

[ ] CLAUDE.md file exists

[ ] QUICK_REFERENCE.md file exists

[ ] README.md file exists

[ ] SQL_MCP_SETUP.md file exists
```

---

## ✅ SECTION 3: Configuration Files

### 3.1 .claude/settings.json
```
File path: .claude/settings.json

[ ] File exists
    Command: type .claude/settings.json

[ ] File is valid JSON (no syntax errors)
    Copy content to: https://jsonlint.com/
    Status: [ ] Valid [ ] Invalid

[ ] Contains "model": "claude-haiku-4-5-20251001"
    [ ] Yes [ ] No

[ ] Contains MCP server configuration
    [ ] "mcpServers" section exists
    [ ] "sqlite" subsection exists
    [ ] "command": "uvx"
    [ ] "--db-path" points to "results/analysis_results.db"

[ ] Contains "permissions" section
    [ ] "allow" array contains Bash(Rscript*), git commands
    [ ] "deny" array excludes destructive commands
```

### 3.2 .Rprofile
```
File path: .Rprofile

[ ] File exists
    Command: type .Rprofile

[ ] Contains here::i_am() initialization
    [ ] Yes [ ] No

[ ] Contains CRAN mirror setting
    [ ] Yes [ ] No

[ ] Test in R console:
    here::here()
    Expected: C:/Users/nobu/Documents/JetBrains/rlang-playground
    Actual: _________________________________
```

### 3.3 .gitignore
```
File path: .gitignore

[ ] File exists

[ ] Contains R-specific exclusions
    [ ] .Rhistory
    [ ] .RData
    [ ] .Rproj.user

[ ] Excludes database file
    [ ] results/analysis_results.db in exclusions

[ ] Excludes IDE files
    [ ] .idea/ in exclusions
```

---

## ✅ SECTION 4: Database

### 4.1 Database File
```
File path: results/analysis_results.db

[ ] File exists
    Command: ls -lh results/analysis_results.db
    Expected size: 30+ KB
    Actual: _________________________________

[ ] File type is SQLite
    Command: file results/analysis_results.db
    Should contain: "SQLite 3.x database"

[ ] Database is accessible from R
    Command in R:
        con <- dbConnect(RSQLite::SQLite(), here("results", "analysis_results.db"))
        dbListTables(con)
    Expected tables: analysis_runs, survival_estimates, corrected_estimates, bootstrap_results
    Status: [ ] Success [ ] Failed
```

### 4.2 Database Tables
```
In R console:
library(DBI)
library(RSQLite)
con <- dbConnect(RSQLite::SQLite(), here("results", "analysis_results.db"))

For each table, run:
dbGetQuery(con, "SELECT COUNT(*) as count FROM [TABLE_NAME]")

[ ] analysis_runs table
    Record count: _______ (expected: 2+)
    Primary key: run_id
    Status: [ ] OK [ ] ERROR

[ ] survival_estimates table
    Record count: _______ (expected: 18+)
    Primary key: (run_id, individual_id_or_group, occasion)
    Status: [ ] OK [ ] ERROR

[ ] corrected_estimates table
    Record count: _______ (expected: 18+)
    Primary key: (run_id, individual_id_or_group, occasion)
    Status: [ ] OK [ ] ERROR

[ ] bootstrap_results table
    Record count: _______ (expected: 36+)
    Primary key: (run_id, individual_id_or_group, occasion, estimate_type)
    Status: [ ] OK [ ] ERROR

dbDisconnect(con)
```

### 4.3 Database Helper Functions
```
In R console:
source(here("R", "db_helpers.R"))

[ ] init_analysis_db.fn() defined
    Status: [ ] Yes [ ] No

[ ] log_analysis_run.fn() defined
    Status: [ ] Yes [ ] No

[ ] complete_analysis_run.fn() defined
    Status: [ ] Yes [ ] No

[ ] save_survival_estimates.fn() defined
    Status: [ ] Yes [ ] No

[ ] save_corrected_estimates.fn() defined
    Status: [ ] Yes [ ] No

[ ] save_bootstrap_results.fn() defined
    Status: [ ] Yes [ ] No

[ ] get_all_runs.fn() defined
    Status: [ ] Yes [ ] No

[ ] get_run_estimates.fn() defined
    Status: [ ] Yes [ ] No

[ ] get_bootstrap_results.fn() defined
    Status: [ ] Yes [ ] No

Total functions: [ ] 9 found [ ] < 9 (ERROR)
```

---

## ✅ SECTION 5: Analysis Scripts

### 5.1 Test Scripts Exist
```
[ ] R/analyses/example-01-simplified-test.R exists
    File size: _______ bytes
    Lines: _______ (expected: 400+)

[ ] R/analyses/example-02-cjs-workflow.R exists
    File size: _______ bytes
    Lines: _______ (expected: 350+)

[ ] R/analyses/template-single-release-cjs.R exists
    File size: _______ bytes
    Lines: _______ (expected: 500+)
```

### 5.2 Run Test Scripts
```
In DataSpell R Console:

[ ] example-01 execution
    Command: source(here("analyses", "example-01-simplified-test.R"))
    Status: [ ] SUCCESS [ ] FAILED
    Database records created: _______ (expected: 16)
    Records retrieved: _______ (expected: 16)

[ ] example-02 execution
    Command: source(here("analyses", "example-02-cjs-workflow.R"))
    Status: [ ] SUCCESS [ ] FAILED
    Database records created: _______ (expected: 37)
    Records retrieved: _______ (expected: 37)
```

---

## ✅ SECTION 6: Claude Code Integration

### 6.1 MCP Server
```
[ ] uv is installed and working
    Command: uv --version
    Status: [ ] OK [ ] FAILED

[ ] .claude/settings.json points to correct database
    Path in file: results/analysis_results.db
    Database exists: [ ] Yes [ ] No

[ ] Claude Code can start
    Command (in terminal): claude code
    Status: [ ] Starts [ ] Fails
    Duration to startup: _______ seconds
```

### 6.2 MCP Query Test
```
In Claude Code session:

[ ] List tables in database
    Query: "List all tables in the database"
    Response should include: analysis_runs, survival_estimates, corrected_estimates, bootstrap_results
    Status: [ ] Works [ ] Fails

[ ] Show recent runs
    Query: "Show me recent analysis runs"
    Response should show: Run ID, analysis_type, status, created_at
    Status: [ ] Works [ ] Fails

[ ] Query specific results
    Query: "Show results from [RUN_ID]"
    Response should show: Estimates with confidence intervals
    Status: [ ] Works [ ] Fails
```

---

## ✅ SECTION 7: Documentation

### 7.1 Documentation Files Exist
```
[ ] CLAUDE.md exists (lines: 250+)
[ ] README.md exists (lines: 350+)
[ ] about-me.md exists (lines: 100+)
[ ] QUICK_REFERENCE.md exists (lines: 250+)
[ ] docs/SETUP_COMPLETE.md exists
[ ] docs/START_FROM_HERE.md exists
[ ] docs/TEST_SCRIPT_WALKTHROUGH.md exists
[ ] docs/COMPLETE_SETUP_DOCUMENTATION.md exists (this doc)
[ ] results/README.md exists (schema documentation)
[ ] SQL_MCP_SETUP.md exists
```

### 7.2 Documentation Content Check
```
[ ] CLAUDE.md contains:
    [ ] Architecture overview
    [ ] Function list (14+ functions)
    [ ] MCP configuration section
    [ ] CJS model explanation

[ ] QUICK_REFERENCE.md contains:
    [ ] Copy-paste analysis template
    [ ] Common commands table
    [ ] Anti-patterns section
    [ ] Database operations guide

[ ] results/README.md contains:
    [ ] Database schema (4 tables)
    [ ] R code examples
    [ ] MCP query examples
```

---

## ✅ SECTION 8: Portable Paths

### 8.1 Test here::here() Function
```
In R console:
library(here)

[ ] here() returns correct path
    Command: here()
    Expected: C:/Users/nobu/Documents/JetBrains/rlang-playground
    Actual: _________________________________

[ ] here("data") resolves correctly
    Command: here("data")
    Expected: C:/Users/nobu/Documents/JetBrains/rlang-playground/data
    Actual: _________________________________

[ ] here("results", "analysis_results.db") resolves
    Command: here("results", "analysis_results.db")
    Should end with: .../results/analysis_results.db
    Actual: _________________________________

[ ] file.exists(here("results", "analysis_results.db")) returns TRUE
    Status: [ ] TRUE [ ] FALSE
```

---

## ✅ SECTION 9: Data Integrity

### 9.1 Verify Test Data
```
In R console:
source(here("R", "db_helpers.R"))
all_runs <- get_all_runs.fn()

[ ] Get_all_runs returns data frame
    Command: nrow(all_runs)
    Expected: 2+ rows (from test runs)
    Actual: _______ rows

[ ] Run IDs are unique
    Command: length(unique(all_runs$run_id)) == nrow(all_runs)
    Status: [ ] TRUE [ ] FALSE

[ ] Status column contains "completed"
    Command: table(all_runs$status)
    Expected: All "completed"
    Actual: _________________________________

[ ] Timestamps are valid
    Command: all_runs$created_at
    Should show ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ)
    Status: [ ] Valid [ ] Invalid
```

### 9.2 Verify Analysis Results
```
In R console:
run_id <- all_runs$run_id[1]  # Get first run

[ ] get_run_estimates.fn() works
    Command: raw <- get_run_estimates.fn(run_id, "raw")
    Records returned: _______ (expected: 4+)

[ ] Estimates are in valid range [0, 1]
    Command: all(raw$phi_estimate >= 0 & raw$phi_estimate <= 1)
    Status: [ ] TRUE [ ] FALSE

[ ] Standard errors are positive
    Command: all(raw$phi_se > 0)
    Status: [ ] TRUE [ ] FALSE

[ ] get_bootstrap_results.fn() works
    Command: boot <- get_bootstrap_results.fn(run_id)
    Records returned: _______ (expected: 8+)

[ ] Confidence intervals are ordered
    Command: all(boot$ci_lower <= boot$estimate & boot$estimate <= boot$ci_upper)
    Status: [ ] TRUE [ ] FALSE
```

---

## ✅ SECTION 10: Permissions & Security

### 10.1 Git Ignore Rules
```
[ ] results/analysis_results.db is in .gitignore
    Command: grep "analysis_results.db" .gitignore
    Status: [ ] Found [ ] NOT found

[ ] .Rhistory is in .gitignore
    Status: [ ] Found [ ] NOT found

[ ] .idea/ is in .gitignore
    Status: [ ] Found [ ] NOT found
```

### 10.2 Claude Code Permissions
```
[ ] Destructive commands are in "deny" list
    [ ] git push --force*
    [ ] git reset --hard*
    [ ] rm -rf*

[ ] Safe commands are in "allow" list
    [ ] Bash(Rscript*)
    [ ] Bash(git status)
    [ ] Bash(git add*)
    [ ] Bash(git commit*)
```

---

## ✅ SECTION 11: System Readiness

### 11.1 DataSpell Setup
```
[ ] DataSpell can open project
    File → Open → C:/Users/nobu/Documents/JetBrains/rlang-playground
    Status: [ ] Opens [ ] Error

[ ] R console available in DataSpell
    Tools → Terminal (or View → Tool Windows)
    Status: [ ] Available [ ] Not available

[ ] Can run R scripts in DataSpell
    Status: [ ] Yes [ ] No
```

### 11.2 Final System Check
```
[ ] All packages load without errors
[ ] Database is accessible
[ ] Paths resolve correctly
[ ] Analysis scripts run to completion
[ ] Claude Code can query database
[ ] Documentation is complete

OVERALL SYSTEM STATUS:
[ ] ✅ READY FOR PRODUCTION
[ ] ⚠️ WARNINGS (list below)
[ ] ❌ FAILURES (list below)

Warnings:
_________________________________________________________________
_________________________________________________________________

Failures:
_________________________________________________________________
_________________________________________________________________
```

---

## Summary

**Total checks:** 150+

**Passed:** _______

**Failed:** _______

**Completion percentage:** _______%

---

## Inspector Sign-Off

| Item | Value |
|------|-------|
| Inspector name | _________________________ |
| Inspection date | _________________________ |
| Inspection time | _________________________ |
| Overall status | [ ] PASS [ ] FAIL [ ] CONDITIONAL |
| Notes | _________________________ |

---

**Next step:** If all checks pass, system is ready for analysis work!

If any checks failed, see `docs/COMPLETE_SETUP_DOCUMENTATION.md` → **Troubleshooting** section.

---

**Document version:** 1.0  
**Created:** 2026-04-03
