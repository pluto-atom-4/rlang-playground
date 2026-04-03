# SQLite Database Inspection Guide

This guide covers inspecting the `results/analysis_results.db` SQLite database using **SQLiteStudio** (standalone tool) and **DataSpell** (JetBrains IDE).

---

## Database Location

**Path:** `C:\Users\nobu\Documents\JetBrains\rlang-playground\results\analysis_results.db`

⚠️ **Windows-specific path** – Adjust for macOS/Linux as needed.

---

## Option 1: SQLiteStudio (Standalone)

SQLiteStudio is a lightweight, independent SQLite GUI tool. **Recommended for quick inspection and one-off queries.**

### Installation

**Windows:**
1. Download from https://sqlitestudio.pl/
2. Choose portable version (no installation needed) or installer
3. Extract and run `sqlitestudio.exe`

**macOS:**
```bash
brew install sqlitestudio
sqlitestudio
```

**Linux:**
```bash
sudo apt-get install sqlitestudio
sqlitestudio
```

### Opening the Database

1. **Launch SQLiteStudio**
2. **File → Add Database**
3. **Select:** `results/analysis_results.db`
4. Click **OK**

The database appears in the left panel under "Databases".

### Inspecting Tables

**View Table Structure:**
- Expand the database in left panel
- Right-click table name → **View structure**
- Shows column names, types, constraints, primary keys

**View All Rows:**
- Double-click table name → **Data** tab opens
- Displays all rows in grid format

**Common Inspection Tasks:**

| Task | Steps |
|------|-------|
| **Show all analysis runs** | Double-click `analysis_runs` table |
| **Check recent runs** | Tools → SQL Editor → Write query (see below) |
| **View estimates for a run** | Query with `WHERE run_id = 'run-id-here'` |
| **Count records per table** | `SELECT COUNT(*) FROM table_name` |

### Running Queries in SQLiteStudio

**SQL Editor:**
1. **Tools → SQL Editor** (or press Ctrl+E)
2. Write SQL query
3. Click **Execute** (or Ctrl+Enter)

**Example Queries:**

```sql
-- Show all runs with creation time and status
SELECT run_id, created_at, analysis_type, status 
FROM analysis_runs 
ORDER BY created_at DESC;

-- Count records per table
SELECT COUNT(*) as count FROM survival_estimates;
SELECT COUNT(*) as count FROM corrected_estimates;

-- Get estimates for a specific run
SELECT individual_id_or_group, occasion, phi_estimate, phi_se 
FROM survival_estimates 
WHERE run_id = 'run-2026-04-03-single-release-001'
ORDER BY individual_id_or_group, occasion;

-- Get corrected estimates
SELECT individual_id_or_group, occasion, raw_phi, corrected_phi, corrected_phi_se
FROM corrected_estimates
WHERE run_id = 'run-2026-04-03-single-release-001';

-- Get bootstrap confidence intervals
SELECT * FROM bootstrap_results 
WHERE run_id = 'run-2026-04-03-single-release-001'
LIMIT 10;
```

---

## Option 2: DataSpell (JetBrains IDE)

**Recommended for integrated workflow** – Use database directly within your IDE.

### Setup Database Connection in DataSpell

**Step 1: Open DataSpell**
- Launch JetBrains DataSpell from your system

**Step 2: Add Database Connection**

1. **View → Tool Windows → Database** (or right side panel)
2. Click **+** icon → **Data Source → SQLite**
3. **Name:** `rlang-playground` (or preferred name)
4. **File path:** `/home/nobu/Documents/JetBrains/rlang-playground/results/analysis_results.db`
   - ⚠️ **Windows path:** `C:\Users\nobu\Documents\JetBrains\rlang-playground\results\analysis_results.db`
   - Use forward slashes or adjust for your OS
5. Click **Test Connection** → Should show "Success"
6. Click **OK**

**Step 3: Verify Connection**

In the Database tool window (right panel):
```
rlang-playground
├── analysis_runs
├── survival_estimates
├── corrected_estimates
├── bootstrap_results
└── (other tables)
```

### Inspecting Tables in DataSpell

**View Table Data:**
1. Right-click table name in Database panel
2. Select **Open** or **View Data**
3. Grid view with all rows, sortable by column

**View Table Structure:**
1. Right-click table name
2. Select **View Structure**
3. Shows columns, types, constraints, indexes

**Filter & Sort:**
- Click column header to sort ascending/descending
- Use filter icon (funnel) to filter rows by value

### Running Queries in DataSpell

**Method 1: Database Console (Quick Queries)**

1. **View → Tool Windows → Database**
2. Right-click database → **New → Query Console**
3. Write SQL, select all (Ctrl+A), run (Ctrl+Enter)

**Method 2: SQL Editor File**

1. **File → New → SQL File**
2. Name it (e.g., `inspect_runs.sql`)
3. Select database at top: `rlang-playground`
4. Write queries, execute with Ctrl+Enter
5. Results appear in bottom panel

**Example SQL File for DataSpell:**

```sql
-- View recent runs
SELECT run_id, created_at, analysis_type, status 
FROM analysis_runs 
ORDER BY created_at DESC
LIMIT 10;

-- Count records per table
SELECT 'analysis_runs' as table_name, COUNT(*) as count FROM analysis_runs
UNION ALL
SELECT 'survival_estimates', COUNT(*) FROM survival_estimates
UNION ALL
SELECT 'corrected_estimates', COUNT(*) FROM corrected_estimates
UNION ALL
SELECT 'bootstrap_results', COUNT(*) FROM bootstrap_results;

-- Get all data for the latest run
SELECT * FROM analysis_runs 
WHERE run_id = (
  SELECT run_id FROM analysis_runs 
  ORDER BY created_at DESC LIMIT 1
);
```

**Run Individual Query:**
- Highlight query text
- Press Ctrl+Enter
- Results in bottom panel

---

## Database Schema Reference

### Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| **analysis_runs** | Metadata for each analysis | `run_id`, `created_at`, `status` |
| **survival_estimates** | Raw CJS estimates | `run_id`, `individual_id_or_group`, `occasion` |
| **corrected_estimates** | Tag-failure adjusted estimates | `run_id`, `individual_id_or_group`, `occasion` |
| **bootstrap_results** | Bootstrap confidence intervals | `run_id`, `estimate_type`, `ci_level` |

### Detailed Schema

**analysis_runs**
```sql
CREATE TABLE analysis_runs (
  run_id TEXT PRIMARY KEY,
  created_at TEXT,           -- ISO 8601 timestamp
  analysis_type TEXT,        -- 'tag_life', 'single_release', 'paired_release'
  dataset_name TEXT,
  script_path TEXT,
  notes TEXT,
  random_seed INTEGER,
  status TEXT                -- 'in_progress', 'completed', 'failed'
);
```

**survival_estimates**
```sql
CREATE TABLE survival_estimates (
  run_id TEXT,
  individual_id_or_group TEXT,
  occasion INTEGER,
  phi_estimate REAL,         -- Survival probability
  phi_se REAL,               -- Standard error
  capture_prob REAL,
  capture_prob_se REAL,
  convergence_status TEXT,   -- 'converged', 'warning', 'failed'
  PRIMARY KEY (run_id, individual_id_or_group, occasion),
  FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
);
```

**corrected_estimates**
```sql
CREATE TABLE corrected_estimates (
  run_id TEXT,
  individual_id_or_group TEXT,
  occasion INTEGER,
  raw_phi REAL,              -- Before correction
  tag_failure_prob REAL,     -- Tag failure probability applied
  corrected_phi REAL,        -- After correction
  corrected_phi_se REAL,     -- Standard error after correction
  correction_method TEXT,    -- Method used
  PRIMARY KEY (run_id, individual_id_or_group, occasion),
  FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
);
```

**bootstrap_results**
```sql
CREATE TABLE bootstrap_results (
  run_id TEXT,
  individual_id_or_group TEXT,
  occasion INTEGER,
  estimate_type TEXT,        -- 'raw' or 'corrected'
  n_bootstrap INTEGER,       -- Number of resamples
  estimate REAL,             -- Point estimate
  ci_lower REAL,             -- CI lower bound
  ci_upper REAL,             -- CI upper bound
  ci_level REAL,             -- Confidence level (0.95, 0.90, etc.)
  PRIMARY KEY (run_id, individual_id_or_group, occasion, estimate_type, ci_level),
  FOREIGN KEY (run_id) REFERENCES analysis_runs(run_id)
);
```

---

## Common Inspection Queries

### Show All Runs

```sql
SELECT run_id, created_at, analysis_type, status 
FROM analysis_runs 
ORDER BY created_at DESC;
```

### Get Latest Run Details

```sql
SELECT * FROM analysis_runs 
WHERE created_at = (SELECT MAX(created_at) FROM analysis_runs);
```

### Count Records in Each Table

```sql
SELECT 
  'analysis_runs' as table_name, COUNT(*) as record_count 
  FROM analysis_runs
UNION ALL SELECT 
  'survival_estimates', COUNT(*) 
  FROM survival_estimates
UNION ALL SELECT 
  'corrected_estimates', COUNT(*) 
  FROM corrected_estimates
UNION ALL SELECT 
  'bootstrap_results', COUNT(*) 
  FROM bootstrap_results;
```

### Get All Estimates for a Specific Run

```sql
SELECT 
  'raw' as estimate_type,
  individual_id_or_group, 
  occasion, 
  phi_estimate as estimate,
  phi_se as se
FROM survival_estimates 
WHERE run_id = 'run-2026-04-03-single-release-001'
UNION ALL
SELECT 
  'corrected',
  individual_id_or_group, 
  occasion, 
  corrected_phi,
  corrected_phi_se
FROM corrected_estimates 
WHERE run_id = 'run-2026-04-03-single-release-001'
ORDER BY individual_id_or_group, occasion;
```

### Get Bootstrap Confidence Intervals for a Run

```sql
SELECT 
  individual_id_or_group,
  occasion,
  estimate_type,
  estimate,
  ci_lower,
  ci_upper,
  ci_level
FROM bootstrap_results
WHERE run_id = 'run-2026-04-03-single-release-001'
  AND ci_level = 0.95
ORDER BY individual_id_or_group, occasion, estimate_type;
```

### Find Runs by Analysis Type

```sql
SELECT run_id, created_at, dataset_name, status
FROM analysis_runs
WHERE analysis_type = 'single_release'
ORDER BY created_at DESC;
```

### Check for Failed Analyses

```sql
SELECT run_id, created_at, notes, status
FROM analysis_runs
WHERE status = 'failed'
ORDER BY created_at DESC;
```

---

## Comparison: SQLiteStudio vs DataSpell

| Feature | SQLiteStudio | DataSpell |
|---------|--------------|-----------|
| **Setup** | Lightweight install/portable | Already your IDE |
| **Interface** | Standalone window | Integrated panel |
| **Query Editor** | Simple SQL editor | Full IDE support, syntax highlighting |
| **Quick Inspection** | ✅ Fast, intuitive | ✅ Fast via tool window |
| **Integration** | No (separate tool) | ✅ Open within DataSpell |
| **Data Visualization** | Grid view | Grid view + IDE features |
| **Export** | Limited | ✅ Copy/paste to R scripts |
| **Ideal For** | One-off queries, quick checks | Workflow integration, analysis |

**Recommendation:**
- **SQLiteStudio** – For standalone inspection, testing new queries
- **DataSpell** – For integrated workflow, linking queries to analysis scripts

---

## Troubleshooting

### Database File Not Found

**Windows:**
- Check path in connection: `C:\Users\nobu\Documents\JetBrains\rlang-playground\results\analysis_results.db`
- Use backslashes or forward slashes (both work)
- Database must exist (created by `init_analysis_db.fn()` in R)

**macOS/Linux:**
- Adjust to actual user path: `/home/username/...` or `~/...`

### Connection Fails in DataSpell

1. **Verify file exists:** Check `results/analysis_results.db` in file explorer
2. **Check permissions:** File should be readable
3. **Reconnect:** Right-click database → **Properties → Test Connection**
4. **Restart DataSpell** if still failing

### No Data in Tables

- Database may not be initialized yet
- Run `source("R/db_helpers.R")` and `init_analysis_db.fn()` in R console
- Run at least one analysis script to populate with data

### Query Returns No Results

- Verify `run_id` spelling (case-sensitive)
- Check date filters match actual timestamps
- Query `SELECT * FROM analysis_runs` first to see available run IDs

---

## Best Practices

1. **Always query first** – Check `analysis_runs` to see available run IDs before filtering other tables
2. **Use run_id as anchor** – All tables link to `run_id`; filter by this first
3. **Check status before using data** – Only use `status = 'completed'` runs
4. **Save useful queries** – Keep `.sql` files in project for repeated inspections
5. **Document findings** – When you discover patterns or issues, add notes to `analysis_runs.notes`

---

## Integration with Claude Code

Claude Code can query the database directly via the **MCP SQLite server** without opening these tools:

```
User: "Show me the last 5 analysis runs"

Claude Code → MCP server → SQLite queries:
list_tables → Shows available tables
query "SELECT run_id, created_at, analysis_type FROM analysis_runs 
       ORDER BY created_at DESC LIMIT 5"
```

This is faster for analysis-as-you-go workflows. Use SQLiteStudio/DataSpell for detailed exploration.

---

## Further Reading

- [SQLiteStudio Documentation](https://sqlitestudio.pl/index.rvt)
- [DataSpell Database Tools](https://www.jetbrains.com/help/dataspell/db-tutorial.html)
- [SQLite Query Language](https://www.sqlite.org/lang.html)
- [Project Database Schema](../results/README.md)

---

**Last Updated:** 2026-04-03  
**Database Location (Windows):** `C:\Users\nobu\Documents\JetBrains\rlang-playground\results\analysis_results.db`  
**Platform Note:** Path configuration is Windows-specific; adjust for macOS/Linux
