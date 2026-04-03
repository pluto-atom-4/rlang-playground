# Start From Here: cbrATLAS Analysis Environment Setup

**Date:** 2026-04-03  
**Project:** cbrATLAS R Package Analysis & Development Environment  
**Objective:** Establish a reproducible local learning/analysis environment for working with the cbrATLAS R package  
**Approach:** Use cbrATLAS as an installed package; develop local analyses, examples, and documentation in this playground

---

## Session Summary

### 1. Repository Analysis
- **cbrATLAS** (Columbia Basin Research): R package for mark-recapture analysis with active-tag failure correction
- **Version:** 0.2.0.0 | **License:** GPL-3 | **R Requirement:** >= 4.1.0
- **14 Exported Functions** organized in functional groups:
  - CJS Models: `cjs.fn`, `cjs.lik`, `cjs.paired.fn`, `paired.cjs.lik`
  - Tag-Life Adjustment: `cjs.taglife.corr`, `AdjSurv.fn`, `correct.fn`
  - Data Transformation: `atlas2flat.fn`, `dayhr.fn`, `harmonic.fn`, etc.
  - Utilities: `boot.L`, `thist0`, `vs2.fn`

### 2. Architecture Overview

**Analysis Pipeline:**
```
Tag-Life Study Data
      ↓
[cjs.taglife.corr + failCompare] → Tag Failure Probability Model
      ↓
Capture History Data
      ↓
[cjs.fn / cjs.paired.fn] → CJS Survival Estimates
      ↓
[AdjSurv.fn + correct.fn] → Adjusted for Tag Failure
      ↓
[boot.L] → Bootstrap CI & Uncertainty Quantification
```

**Key Design Principle:** Two-step adjustment — estimate raw survival, then correct using tag-failure probability from tag-life data.

### 3. Project Structure (This Playground)

```
rlang-playground/
├── CLAUDE.md                   # Technical guidance for Claude Code (NEW)
├── README.md                   # User guide and overview (NEW)
├── about-me.md                 # Collaboration preferences (NEW)
├── docs/
│   └── start-from-here.md      # This file
├── .claude/
│   └── settings.json           # Claude Code configuration (PLANNED)
└── analyses/                   # Your local work (to be created)
    ├── example-01-single-release.R
    ├── example-02-tag-life-modeling.R
    └── notes/
```

### 4. Design Decisions

#### Why This Structure?
- **Separation of Concerns:** CLAUDE.md (technical), README.md (guide), about-me.md (collaboration)
- **cbrATLAS as External Dependency:** Install via `devtools::install_github()` or `remotes::install_github()`
- **Local Analyses:** Create `.R` scripts in `analyses/` directory for your own work, examples, and extensions
- **Minimal Footprint:** No source code duplication; focus on learning and applied use

#### Why These Documentation Files?
- **CLAUDE.md:** Future Claude Code instances understand the package architecture and typical workflows
- **README.md:** Entry point; explains what this playground is, how to set up, how to use cbrATLAS
- **about-me.md:** Your voice and preferences; ensures Claude Code collaborates aligned with your values
- **start-from-here.md:** This file; session notes and next steps

#### Model & Tool Choices
- **Claude Haiku 4.5:** Efficient reasoning for analysis tasks; escalate to Opus 4.6 for complex methodology
- **JetBrains DataSpell:** Your R IDE of choice; Claude Code works seamlessly with it
- **GitHub Copilot + Claude Code:** Copilot for routine completions; Claude Code for strategic reasoning
- **Agent Teams:** Parallel task execution (data analysis, function testing, documentation)

---

## What's Ready Now

✅ **CLAUDE.md** – Detailed technical guidance, function architecture, development patterns  
✅ **about-me.md** – Your collaboration preferences and project philosophy  
✅ **README.md** – User guide, setup instructions, workflow overview  
⏳ **settings.json** – Optional; create if automating Claude Code workflows  

---

## Next Steps

### Immediate Setup (Before First Analysis)
```bash
# 1. Ensure R >= 4.1.0
R --version

# 2. Install cbrATLAS package
R
```

```r
# In R console:
install.packages("devtools")
devtools::install_github("Columbia-Basin-Research-West/cbrATLAS")

# Verify installation
library(cbrATLAS)
?cbrATLAS
vignette("cbrATLAS")  # Load the primary tutorial
```

### First Analysis Task
1. Review the cbrATLAS vignette in PDF or R console
2. Create `analyses/example-01-single-release.R` with a worked example
3. Document findings and questions
4. Identify which functions you'll focus on first

### For Claude Code Sessions
- Start with: `/init` to load context from CLAUDE.md, about-me.md
- Ask Claude to: explore specific functions, create analysis scripts, validate methodological choices
- Use: Agent teams for parallel data/function/test tasks

### If Extending/Contributing to cbrATLAS
- **For small enhancements:** Local R scripts in `analyses/` directory
- **For package modifications:** Clone cbrATLAS into separate directory, work on feature branch, submit PR
- **Always reference:** CLAUDE.md architecture, about-me.md collaboration preferences, this session log

---

## Key Insights

**Package Strengths:**
- Clear two-step pipeline: tag-life modeling → survival adjustment
- Robust integration with failCompare for model selection
- Well-established methodology (Townsend et al. 2006, Skalski et al. 1998)

**Learning Path:**
1. Load vignette, understand single release workflow
2. Explore data formats (input/output shapes)
3. Deep dive: CJS likelihood, tag-life modeling, correction application
4. Bootstrap diagnostics and inference
5. Optional: Extend to new study designs (paired releases, ViPRe, ViRDCt)

**Security & Quality:**
- Validate input data format before passing to functions
- Check convergence diagnostics in CJS models
- Use `set.seed()` for reproducible bootstrap results
- Document assumptions (CJS identifiability, tag failure distribution)

---

## Resources

**Official Documentation:**
- [cbrATLAS Vignette (PDF)](https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%20vignette.pdf) – Worked examples
- [Technical Manual (PDF)](https://www.cbr.washington.edu/sites/default/files/manuals/cbrATLAS%200.0.1.3.pdf) – Function reference
- [GitHub Repository](https://github.com/Columbia-Basin-Research-West/cbrATLAS) – Source, issues, discussion

**Foundational Papers:**
- Townsend et al. (2006) – Tag failure correction methodology
- Skalski et al. (1998) – CJS capture-recapture models

**Tools & Integration:**
- [Claude Code](https://claude.ai/code) – AI coding assistant
- [JetBrains DataSpell](https://www.jetbrains.com/dataspell/) – R IDE
- [GitHub Copilot](https://github.com/features/copilot) – Inline code completion

---

## Questions for Future Work

1. **Which cbrATLAS functions will you use most?** (Single release? Paired releases? Bootstrap-heavy?)
2. **Will you extend the package or create separate analysis scripts?** (CLAUDE.md and code structure assume the latter initially)
3. **Are there specific datasets or case studies** you want to work through?
4. **Performance concerns?** (Bootstrap iterations, dataset size, runtime expectations)
5. **Integration with other tools?** (Visualization, report generation, database integration)

Answer these in follow-up sessions to shape the project roadmap.

---

**Status:** ✅ Documentation files created; cbrATLAS ready to install  
**Ready for:** First analysis script, agent team coordination, methodological exploration  
**Last Updated:** 2026-04-03
