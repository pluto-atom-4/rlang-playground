# Python Virtual Environment Setup

This project uses **uv** for fast, deterministic Python package management with a **pyproject.toml**-based configuration.

## Quick Start

### Activate Virtual Environment

**Windows (Bash/Git Bash):**
```bash
source .venv/Scripts/activate
```

**Windows (PowerShell):**
```powershell
.venv\Scripts\Activate.ps1
```

**macOS/Linux:**
```bash
source .venv/bin/activate
```

### Verify Installation

```bash
python --version  # Should be 3.12.12
pip list | head   # List installed packages
```

### Deactivate Virtual Environment

```bash
deactivate
```

---

## Dependency Management

### Configuration Files

- **`pyproject.toml`** – Project metadata and dependency groups
- **`uv.lock`** – Deterministic lock file (commit to git)
- **`.venv/`** – Virtual environment directory (added to `.gitignore`)

### Dependency Groups

Organized for different use cases:

| Group | Purpose | Install |
|-------|---------|---------|
| `dev` | Testing, linting, type checking | `uv sync --group dev` |
| `mcp` | MCP server for Claude Code | `uv sync --group mcp` |
| `analysis` | Data analysis & visualization | `uv sync --group analysis` |

**Install all groups:**
```bash
uv sync --all-groups
```

**Install specific group:**
```bash
uv sync --group mcp
```

---

## Updating Dependencies

### Sync Latest from pyproject.toml

```bash
uv sync --all-groups
```

This:
- Resolves all dependencies
- Updates `.venv` with new packages
- Updates `uv.lock` (deterministic)

### Add a New Package

Edit `pyproject.toml` under the appropriate `[dependency-groups]` section:

```toml
[dependency-groups]
dev = [
    "pytest>=7.0",
    "new-package>=1.0",  # Add here
]
```

Then sync:
```bash
uv sync --all-groups
```

### Remove a Package

Remove from `pyproject.toml` and run:
```bash
uv sync --all-groups
```

---

## Current Dependency Groups

### `dev` – Development Tools

```
pytest>=7.0           # Testing framework
pytest-cov>=4.0       # Coverage reporting
ruff>=0.1.0           # Fast linter
black>=23.0           # Code formatter
mypy>=1.0             # Static type checker
```

### `mcp` – MCP Server Integration

```
mcp-server-sqlite>=0.2.0  # SQLite MCP server for Claude Code
```

### `analysis` – Data Analysis & Visualization

```
pandas>=2.0           # Data manipulation
numpy>=1.24           # Numerical computing
matplotlib>=3.7       # Plotting
seaborn>=0.12         # Statistical visualization
```

---

## Using with Claude Code

The MCP server enables database queries in Claude Code sessions:

```bash
# Activate environment
source .venv/Scripts/activate

# MCP server is configured in .claude/settings.json
# Claude Code can now query: query [SQL] and execute [SQL]
```

**Example in Claude Code session:**
```
→ list_tables
  Tables: analysis_runs, survival_estimates, bootstrap_results

→ query "SELECT * FROM analysis_runs LIMIT 5"
```

---

## Platform Notes

⚠️ **Windows-Specific:**
- Virtual environment path: `.venv\Scripts\activate.ps1` (PowerShell)
- Virtual environment path: `.venv/Scripts/activate` (Bash/Git Bash)
- Activation differs from macOS/Linux

---

## Troubleshooting

### Virtual environment not activating

**Windows (PowerShell):**
```powershell
# If execution policy blocks scripts:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.venv\Scripts\Activate.ps1
```

### Package conflicts

Clear and reinstall:
```bash
rm -rf .venv uv.lock
uv sync --all-groups
```

### uv not found

Install uv:
```bash
pip install uv
# or (Windows):
winget install astral-sh.uv
```

Verify:
```bash
uv --version
```

---

## Git Configuration

The `.gitignore` already includes:
```
.venv/
__pycache__/
*.pyc
.pytest_cache/
.coverage
```

Commit `pyproject.toml` and `uv.lock` to git for reproducibility. Do NOT commit `.venv/`.

---

## Further Reading

- [uv Documentation](https://docs.astral.sh/uv/)
- [PEP 735 – Dependency Groups](https://peps.python.org/pep-0735/)
- [pyproject.toml Specification](https://packaging.python.org/en/latest/specifications/pyproject-toml/)

---

**Last Updated:** 2026-04-03  
**Python Version:** 3.12.12  
**uv Version:** Latest (check with `uv --version`)
