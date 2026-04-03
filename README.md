# R Analysis Playground: cbrATLAS Environment

A local development and analysis environment for exploring the **cbrATLAS** R package — tools for mark-recapture analysis with active-tag failure correction.

## What is This?

This repository provides:
- ✅ Documentation and guidance for working with the cbrATLAS R package
- ✅ A structured environment for creating analysis scripts and examples
- ✅ **Python 3.12.12 virtual environment** (uv + pyproject.toml) for data analysis and MCP servers
- ✅ **SQLite database** (SQLiteStudio/DataSpell) for tracking analysis runs and results
- ✅ Integration with Claude Code, GitHub Copilot, and JetBrains DataSpell
- ✅ MCP (Model Context Protocol) SQLite server for Claude Code database integration
- ✅ Best-practice setup for reproducible survival analysis workflows

**Note:** This is an *analysis environment*, not the package source. cbrATLAS is installed as an R package dependency.

---

## System Requirements

### Windows (Current Setup)
- **R 4.5.3** – Installed and in PATH (`C:/Program Files/R/R-4.5.3/bin`)
- **Python 3.12.12** – Virtual environment in `.venv/` (managed by uv)
- **JetBrains DataSpell** – IDE for R and Python development
- **uv** – Fast Python package manager (installed via pip)
- **git** – Version control
- **SQLite** – Database (included with Python)

### macOS/Linux
- **R >= 4.1.0** – Installed via Homebrew, apt, or from source
- **Python >= 3.10** – System or pyenv/conda
- **uv** – Install via `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **JetBrains DataSpell** – IDE

**Note:** Paths documented in this README are Windows-specific. Adjust for your OS accordingly.

---

## Quick Start

### 1. Clone This Repository

```bash
git clone https://github.com/YourUsername/rlang-playground.git
cd rlang-playground
```

### 2. Set Up Python Virtual Environment

```bash
# Activate Python virtual environment (Windows Bash/Git Bash)
source .venv/Scripts/activate

# Activate (Windows PowerShell)
.venv\Scripts\Activate.ps1

# Activate (macOS/Linux)
source .venv/bin/activate

# Verify installation
python --version  # Should be 3.12.12
```

### 3. Install R Package (cbrATLAS)

**From R console:**
```r
install.packages("devtools")
devtools::install_github("Columbia-Basin-Research-West/cbrATLAS")
```

**From command line (R 4.5.3 in PATH):**
```bash
Rscript -e "install.packages('devtools')"
Rscript -e "devtools::install_github('Columbia-Basin-Research-West/cbrATLAS')"
```

### 4. Verify Installations

```bash
# Check R version (Windows)
Rscript --version

# Check Python version (in virtual env)
python --version

# Load cbrATLAS in R
Rscript -e "library(cbrATLAS); packageVersion('cbrATLAS')"

# List Python packages
pip list | grep -E "(pytest|mcp-server|pandas)"
```

### 5. Open in DataSpell

- **File → Open** → select this directory
- Set Python interpreter to `.venv/`
- Set R interpreter to `C:/Program Files/R/R-4.5.3/bin/R.exe` (Windows)

---

## Project Structure

```
rlang-playground/
├── README.md                           # This file
├── CLAUDE.md                           # Technical architecture & development patterns
├── about-me.md                         # Collaboration preferences and philosophy
├── PYTHON_ENVIRONMENT.md               # Python venv setup with uv and dependency groups
├── pyproject.toml                      # Python dependencies (dev, mcp, analysis groups)
├── uv.lock                             # Deterministic Python dependency lock file
├── .venv/                              # Python 3.12.12 virtual environment (auto-created)
├── .claude/
│   └── settings.json                   # Claude Code MCP & permissions configuration
├── .github/
│   └── copilot-instructions.md         # GitHub Copilot guidance
├── .gitignore                          # Git exclusions (R, Python, IDE)
├── docs/
│   ├── INDEX.md                        # 📚 Documentation index (START HERE)
│   ├── start-from-here.md              # Session documentation and onboarding
│   ├── DATABASE_INSPECTION.md          # 🔍 SQLiteStudio & DataSpell guide (NEW)
│   ├── QUICK_REFERENCE.md              # One-page cheat sheet for analysis
│   ├── SETUP_COMPLETE.md               # Setup summary and verification
│   ├── COMPLETE_SETUP_DOCUMENTATION.md # Full reference manual (90+ sections)
│   ├── MANUAL_INSPECTION_CHECKLIST.md  # Step-by-step verification checklist
│   └── TEST_SCRIPT_WALKTHROUGH.md      # Code explanation and walkthrough
├── R/                                  # R code and analysis scripts
│   ├── db_helpers.R                    # Database helper functions (9 functions)
│   └── analyses/                       # Your analysis scripts (organized under R/)
│       ├── example-01-test-analysis.R
│       ├── example-02-cjs-workflow.R   # 📋 Recommended template for new analyses
│       ├── template-single-release-cjs.R
│       └── notes/                      # Analysis findings and documentation
├── results/
│   ├── README.md                       # Database schema and usage guide
│   ├── analysis_results.db             # SQLite database (auto-created)
│   ├── figures/                        # Analysis output plots
│   └── tables/                         # Analysis output tables
├── tests/
│   ├── test_db_helpers.R
│   ├── test_cbratlas_integration.R
│   ├── testthat.R
│   └── README.md                       # Testing guide
├── data-raw/                           # Raw input data (do not modify)
└── data/                               # Clean/processed data for analysis
```

**Key Files for New Users:**
- Start with: **`docs/INDEX.md`** – Complete documentation roadmap
- Quick reference: **`QUICK_REFERENCE.md`** – One-page cheat sheet
- Database inspection: **`DATABASE_INSPECTION.md`** – Query tools guide
- Example analysis: **`R/analyses/example-02-cjs-workflow.R`** – Working template

---

## Documentation Guide

### 🚀 Quick Navigation (Start Here!)

**New to the project?**
1. **[docs/INDEX.md](./docs/INDEX.md)** ← Read this first (complete roadmap)
2. **[QUICK_REFERENCE.md](./docs/QUICK_REFERENCE.md)** – One-page cheat sheet (copy-paste templates)
3. **[PYTHON_ENVIRONMENT.md](./PYTHON_ENVIRONMENT.md)** – Python setup and dependency management

### 📚 Core Project Documentation

| Document | Purpose | Best For |
|----------|---------|----------|
| **[docs/INDEX.md](./docs/INDEX.md)** | Complete documentation roadmap | First-time users, finding the right doc |
| **[CLAUDE.md](./CLAUDE.md)** | Technical architecture & patterns | Understanding cbrATLAS design & API |
| **[about-me.md](./about-me.md)** | Collaboration preferences | Understanding code style & communication |
| **[PYTHON_ENVIRONMENT.md](./PYTHON_ENVIRONMENT.md)** | Python venv setup with uv | Setting up Python dependencies |
| **[docs/DATABASE_INSPECTION.md](./docs/DATABASE_INSPECTION.md)** | SQLiteStudio & DataSpell guide | Inspecting analysis results in database |
| **[docs/QUICK_REFERENCE.md](./docs/QUICK_REFERENCE.md)** | One-page cheat sheet | Daily work, copy-paste templates |

### 📖 In-Depth Guides

| Document | Purpose | Sections |
|----------|---------|----------|
| **[docs/SETUP_COMPLETE.md](./docs/SETUP_COMPLETE.md)** | Setup summary | What was installed, facts, quick reference |
| **[docs/COMPLETE_SETUP_DOCUMENTATION.md](./docs/COMPLETE_SETUP_DOCUMENTATION.md)** | Full reference (28 KB, 90+ sections) | Detailed setup, configuration, troubleshooting |
| **[docs/MANUAL_INSPECTION_CHECKLIST.md](./docs/MANUAL_INSPECTION_CHECKLIST.md)** | Verification checklist | 150+ checks for manual testing |
| **[docs/TEST_SCRIPT_WALKTHROUGH.md](./docs/TEST_SCRIPT_WALKTHROUGH.md)** | Code explanation | Line-by-line analysis pattern tutorial |
| **[results/README.md](./results/README.md)** | Database schema | Tables, columns, helper functions |

### 🔗 Official cbrATLAS Resources

- **[Vignette (PDF)](https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%20vignette.pdf)** – Primary user guide with worked examples
- **[Technical Manual (PDF)](https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%200.0.1.3.pdf)** – Function reference and methodology
- **[GitHub Repository](https://github.com/Columbia-Basin-Research-West/cbrATLAS)** – Source code, issues, and discussions

---

## cbrATLAS Overview

**What Does It Do?**

cbrATLAS analyzes mark-recapture data from active-tag studies and adjusts survival estimates to account for tag failures (battery depletion, hardware failure). This prevents underestimation of true survival rates.

**Key Capabilities:**

1. **Tag-Life Modeling** – Estimate tag failure probability from tag-life study data using the failCompare package
2. **Survival Estimation** – Cormack-Jolly-Seber (CJS) capture-recapture models for single and paired releases
3. **Correction Application** – Adjust raw survival estimates for estimated tag failure
4. **Bootstrap Inference** – Confidence intervals and uncertainty quantification

**Analysis Pipeline:**

```
Tag-Life Data → Tag Failure Model
                       ↓
Capture History Data → CJS Survival Estimates → Corrected Survival → Bootstrap CI
```

**Current Scope:**
- Single release designs with and without censoring
- Optional tag-failure correction
- Bootstrap-based inference

**Planned Extensions:**
- Paired release designs
- Virtual-Paired Release (ViPRe)
- Virtual Release Dead Fish Correction (ViRDCt)

---

## Getting Started with Analysis

### Step 1: Load and Explore

```r
library(cbrATLAS)

# View all available functions
help(package = "cbrATLAS")

# Run the vignette tutorial
vignette("cbrATLAS")
```

### Step 2: Create Your First Analysis Script

Create `R/analyses/example-01-single-release.R`:

```r
# Load library
library(cbrATLAS)

# Example: Single release analysis
# (See vignette for detailed workflow)

# Load data, run analysis, document findings
# Keep scripts focused and reproducible
```

### Step 3: Use with Claude Code

```bash
# Start Claude Code in this directory
claude code

# In Claude Code, you can:
# - Ask about cbrATLAS function usage
# - Design analysis workflows
# - Create or validate R scripts
# - Understand statistical methodology
```

---

## Integration: Tools & Workflows

### 🛠️ Development Stack

| Tool | Purpose | How to Use |
|------|---------|-----------|
| **JetBrains DataSpell** | R & Python IDE | Main development environment |
| **Claude Code** | AI coding assistant | `/init`, `/plan`, `/commit` commands |
| **GitHub Copilot** | Code completion | Inline suggestions in DataSpell |
| **SQLiteStudio** | SQLite GUI (standalone) | Quick database queries & exploration |
| **uv** | Python package manager | `uv sync --all-groups` to manage dependencies |

### 📊 Database Integration

**SQLite database** (`results/analysis_results.db`) tracks all analysis runs:

- **Via DataSpell:** Right-click database in IDE → "Open" or "View Data"
- **Via SQLiteStudio:** Download from https://sqlitestudio.pl/, then File → Add Database
- **Via Claude Code (MCP):** Query directly in Claude Code sessions using MCP SQLite server

See **[DATABASE_INSPECTION.md](./docs/DATABASE_INSPECTION.md)** for detailed guides.

### 🤖 AI Assistant Workflow

**Division of Labor:**
- **GitHub Copilot** → Routine code completions, syntax suggestions
- **Claude Code** → Complex reasoning, architecture decisions, design, documentation
- **DataSpell** → Interactive development, data exploration, visualization

**Recommended Workflow:**
1. Use **Copilot** for quick function generation and syntax
2. Use **Claude Code** (`/init`, `/plan`, `/commit`) for strategic decisions
3. Use **DataSpell** console for interactive debugging and data exploration
4. Use **SQLiteStudio/DataSpell** to inspect database results
5. Document findings in analysis scripts and markdown notes

---

## Python Environment Setup

This project includes a **Python 3.12.12 virtual environment** managed by **uv** for:
- Testing and validation tools
- MCP server integration with Claude Code
- Data analysis and visualization (pandas, numpy, matplotlib, seaborn)

### Quick Setup

```bash
# Activate virtual environment
source .venv/Scripts/activate  # Windows Bash
.venv\Scripts\Activate.ps1     # Windows PowerShell
source .venv/bin/activate      # macOS/Linux

# Verify
python --version  # Should be 3.12.12
pip list | head   # List installed packages

# Sync dependencies (if pyproject.toml changes)
uv sync --all-groups

# Deactivate when done
deactivate
```

### Dependency Groups

Organized for different use cases:

```toml
[dependency-groups]
dev = [pytest, pytest-cov, ruff, black, mypy]           # Testing & linting
mcp = [mcp-server-sqlite]                              # Claude Code integration
analysis = [pandas, numpy, matplotlib, seaborn]        # Data analysis
```

**Install specific group:**
```bash
uv sync --group mcp        # Just MCP server
uv sync --all-groups       # Everything
```

See **[PYTHON_ENVIRONMENT.md](./PYTHON_ENVIRONMENT.md)** for complete documentation.

---

## Database & Results Management

This project uses **SQLite** to track all analysis runs and results:

### Database Structure

```
results/analysis_results.db
├── analysis_runs           # Metadata for each analysis
├── survival_estimates      # Raw CJS estimates
├── corrected_estimates     # Tag-failure adjusted estimates
└── bootstrap_results       # Bootstrap confidence intervals
```

### Inspect Database

**Option 1: DataSpell (Integrated)**
1. View → Tool Windows → Database
2. Click + → SQLite → `results/analysis_results.db`
3. Browse tables, run SQL queries, view data

**Option 2: SQLiteStudio (Standalone)**
1. Download from https://sqlitestudio.pl/
2. File → Add Database → `results/analysis_results.db`
3. Use SQL Editor for queries

**Option 3: Claude Code (MCP)**
```
In Claude Code session:
→ list_tables
→ query "SELECT * FROM analysis_runs LIMIT 5"
```

See **[DATABASE_INSPECTION.md](./docs/DATABASE_INSPECTION.md)** for detailed tutorials and example queries.

---

## Working with Data

### Input Format

cbrATLAS expects capture history data in long format:

```r
# Example structure (see vignette for details):
# Columns: individual_id, occasion, capture (0/1)
capture_history <- data.frame(
  id = rep(1:100, each = 10),
  occasion = rep(1:10, 100),
  capture = c(...),  # 0/1 indicator
  ...
)
```

### Validation

Always validate input data:
- Check for NA/NaN in critical columns
- Verify occasion sequence is correct
- Confirm capture probability structure meets CJS assumptions

---

## Using Claude Code Effectively

### Before Starting Analysis

Read these files in order:
1. **CLAUDE.md** – Understand cbrATLAS architecture
2. **about-me.md** – Align with collaboration preferences
3. **docs/start-from-here.md** – Session context

### When Working on Tasks

```bash
# Initialize Claude Code with context
claude code
# Type: /init

# Design a new task
# Type: /plan (enter plan mode for strategic decisions)

# Commit your work with context
# Type: /commit (document why, not just what)
```

### Agent Team Coordination

For complex tasks, use agent teams:
- **Data Explorer Agent** – Explore input formats and sample data
- **Function Analyst Agent** – Understand CJS models and correction logic
- **Documentation Agent** – Create examples and write vignettes

---

## Best Practices

### Reproducibility
- Always set `set.seed()` before bootstrap operations
- Document R version, package versions, and key parameters
- Include session info in analysis outputs

### Numerical Stability
- CJS likelihood is ill-conditioned; use log-space computation (built into cbrATLAS)
- Validate convergence diagnostics from CJS models
- Test against published benchmarks

### Documentation
- Write roxygen comments for any custom functions (`@param`, `@return`, `@examples`)
- Document assumptions about data (identifiability, tag failure distribution)
- Use meaningful variable names (not `x`, `y`, `z`)

### Security
- Validate all external input before analysis
- Ensure sensitive data (if any) is not committed to version control
- Use git hooks to prevent accidental commits of sensitive files

---

## Common Tasks

### Load Package
```r
library(cbrATLAS)
```

### Check Available Data
```r
data(package = "cbrATLAS")
```

### Run Single Release Analysis
```r
result <- cjs.fn(
  data = capture_data,
  Phi.estim = ~1,
  p.estim = ~t,
  time.interval = intervals
)
```

### Apply Tag-Failure Correction
```r
corrected <- AdjSurv.fn(
  raw_survival = result$estimates,
  tag_failure_prob = tag_life_prob
)
```

### Bootstrap Confidence Intervals
```r
boot_ci <- boot.L(
  data = capture_data,
  formula = ~1,
  n.bootstrap = 1000,
  seed = 12345
)
```

---

## Troubleshooting

### Installation Issues

```r
# If devtools installation fails, try:
install.packages("remotes")
remotes::install_github("Columbia-Basin-Research-West/cbrATLAS")
```

### Package Not Found

```r
# Verify installation:
library(cbrATLAS)  # Should load without error
packageVersion("cbrATLAS")  # Should show 0.2.0.0 or later
```

### Questions About Methods

- See the vignette for worked examples
- Check the technical manual for function signatures
- Reference Townsend et al. (2006) for tag-failure methodology
- Reference Skalski et al. (1998) for CJS theory

---

## Key References

**cbrATLAS Methodology:**
- Townsend, R.L., et al. (2006) – Tag-failure correction for survival analysis
- Skalski, J.R., et al. (1998) – Cormack-Jolly-Seber capture-recapture models

**Tools & Integration:**
- [Claude Code](https://claude.ai/code) – AI coding assistant
- [JetBrains DataSpell](https://www.jetbrains.com/dataspell/) – R IDE
- [GitHub Copilot](https://github.com/features/copilot) – Code completion
- [cbrATLAS GitHub](https://github.com/Columbia-Basin-Research-West/cbrATLAS) – Package repository

---

## Contributing & Extending

### Creating New Analysis Scripts

1. Create file in `R/analyses/` directory
2. Document assumptions and methodology
3. Include reproducible examples
4. Test against cbrATLAS vignette examples

### Contributing Back to cbrATLAS

If you discover improvements or extensions:
1. Create a feature branch in a clone of the cbrATLAS repository
2. Reference this environment's documentation and approach
3. Submit a pull request with clear methodology documentation
4. Include tests and updated vignettes

---

## Support

- **Claude Code Questions:** Type `/help` in Claude Code or visit [claude.ai/code](https://claude.ai/code)
- **cbrATLAS Issues:** File on [GitHub Issues](https://github.com/Columbia-Basin-Research-West/cbrATLAS/issues)
- **R Questions:** [Stack Overflow](https://stackoverflow.com/questions/tagged/r) or [RStudio Community](https://community.rstudio.com/)

---

## Getting Started Checklist

- [ ] **Read documentation:**
  - [ ] Start: [`docs/INDEX.md`](./docs/INDEX.md) (complete roadmap)
  - [ ] Quick ref: [`QUICK_REFERENCE.md`](./docs/QUICK_REFERENCE.md) (cheat sheet)
  - [ ] Tech details: [`CLAUDE.md`](./CLAUDE.md) (architecture)

- [ ] **Set up environment:**
  - [ ] Activate Python venv: `source .venv/Scripts/activate`
  - [ ] Verify R 4.5.3: `Rscript --version`
  - [ ] Install cbrATLAS: `Rscript -e "devtools::install_github('Columbia-Basin-Research-West/cbrATLAS')"`
  - [ ] Open in DataSpell

- [ ] **Test installations:**
  - [ ] Run: `Rscript -e "library(cbrATLAS); ?cbrATLAS"`
  - [ ] Run: `python --version` (in venv)
  - [ ] Check database: **[DATABASE_INSPECTION.md](./docs/DATABASE_INSPECTION.md)**

- [ ] **Try your first analysis:**
  - [ ] Review: [`R/analyses/example-02-cjs-workflow.R`](./R/analyses/example-02-cjs-workflow.R)
  - [ ] Copy to `R/analyses/my-first-analysis.R`
  - [ ] Modify with your data
  - [ ] Run in DataSpell or via `Rscript`

- [ ] **Use Claude Code for design:**
  - [ ] Open Claude Code: `claude code`
  - [ ] Type `/plan` for architecture decisions
  - [ ] Type `/commit` to document work

---

## Platform-Specific Notes

⚠️ **Windows (Current Setup):**
- R path: `C:/Program Files/R/R-4.5.3/bin`
- Python venv: `.venv/Scripts/activate` (Bash) or `.venv\Scripts\Activate.ps1` (PowerShell)
- All paths documented use Windows format

**macOS/Linux:**
- Adjust R installation path for your system
- Python venv: `source .venv/bin/activate`
- SQLite paths follow Unix conventions

See individual documentation files for platform-specific guidance.

---

## Project Status

✅ **Fully configured and tested:**
- R 4.5.3 environment (in PATH)
- Python 3.12.12 virtual environment (via uv)
- SQLite database with 4-table schema
- MCP SQLite server (Claude Code integration)
- Comprehensive documentation (13 docs, 50+ pages)
- Example analysis scripts with working templates
- Testing framework (9 R helper functions)

**Ready for:** Immediate analysis work and development

---

## Support & Resources

### Questions?
- **Documentation:** See [`docs/INDEX.md`](./docs/INDEX.md) for complete roadmap
- **Quick reference:** See [`QUICK_REFERENCE.md`](./docs/QUICK_REFERENCE.md)
- **Troubleshooting:** See [`COMPLETE_SETUP_DOCUMENTATION.md`](./docs/COMPLETE_SETUP_DOCUMENTATION.md)

### External Help
- **Claude Code:** Type `/help` or visit [claude.ai/code](https://claude.ai/code)
- **cbrATLAS:** File issues on [GitHub Issues](https://github.com/Columbia-Basin-Research-West/cbrATLAS/issues)
- **R Questions:** [Stack Overflow](https://stackoverflow.com/questions/tagged/r) or [R Community](https://community.rstudio.com/)
- **Python Questions:** [Stack Overflow](https://stackoverflow.com/questions/tagged/python) or [Python Discourse](https://discuss.python.org/)

---

**Last Updated:** 2026-04-03  
**cbrATLAS Version Target:** 0.2.0.0+  
**R Version:** 4.5.3 (Windows) | >= 4.1.0 (macOS/Linux)  
**Python Version:** 3.12.12 (virtual environment)  
**IDE:** JetBrains DataSpell (with GitHub Copilot + Claude Code integration)
