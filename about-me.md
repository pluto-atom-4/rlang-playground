# About Me: Project Philosophy & Collaboration Style

## Who I Am

I am a researcher/developer working with R on quantitative ecology and mark-recapture survival analysis problems. I value **precision, reproducibility, and clarity** in both code and communication.

## My Preferences

### Technical Stack
- **Primary Language**: R 4.5.3 (installed, in PATH at `C:/Program Files/R/R-4.5.3/bin`)
  - ⚠️ **Note:** PATH configuration is **Windows-specific**. On macOS/Linux, R is typically in `/usr/local/bin` or managed via Homebrew/apt.
- **IDE**: JetBrains DataSpell (not RStudio)
- **AI Assistant Models**: Claude Haiku 4.5 (efficient, sufficient for most tasks)
- **Tools**: GitHub for version control, renv for dependency management when possible
- **Testing Philosophy**: Integration tests over unit mocks; validate against known biological benchmarks

### Code Style & Quality

I prefer:
- **Clarity over cleverness** – Code should be self-documenting; comments explain *why*, not *what*
- **Functional programming patterns** – Minimize side effects; favor piping (magrittr or base R pipes) for readability
- **Vectorized operations** – R is powerful when you work *with* the language, not against it
- **Explicit naming** – Variable and function names should convey intent (e.g., `survival_estimate`, not `surv_est`)
- **Conservative assumptions** – Validate inputs, handle edge cases, fail fast with clear error messages

### Documentation Standards

I expect:
- **roxygen comments** for all exported functions (including `@param`, `@return`, `@examples`)
- **README and vignettes** that show real workflows, not theoretical use cases
- **Inline comments only for non-obvious logic** (e.g., likelihood computation tricks, numerical stability workarounds)
- **Git commit messages** that explain *why* a change was made, not just *what* changed

### Analysis & Methodology

When working on survival analysis:
- Always cite foundational papers (Townsend et al. 2006, Skalski et al. 1998)
- Validate against published benchmarks when extending models
- Document assumptions clearly (CJS identifiability, tag failure distributions, capture probability structures)
- Bootstrap confidence intervals should always include diagnostics (convergence, n_resamples, seed)

## Collaboration Preferences

### How I Like to Work with Claude Code

1. **Ask clarifying questions early** – If requirements are ambiguous, ask before coding
2. **Show your reasoning** – Explain *why* you're choosing one approach over another
3. **Validate assumptions** – Check if the codebase already has patterns I should follow
4. **Provide diffs, not rewrites** – Small, focused changes are easier to review than large rewrites
5. **Test first, document second** – A passing test is more convincing than a well-written comment

### When to Escalate to Me

- **Architectural decisions** – Any change affecting the analysis pipeline (input validation, likelihood computation, correction application)
- **Methodological questions** – If you're unsure whether a statistical choice is valid, ask
- **Performance trade-offs** – Speed vs. readability; caching vs. simplicity
- **Integration with external tools** – Changes involving failCompare, data format conversions, or external dependencies

### When You Can Proceed Independently

- Routine function additions within established patterns
- Documentation updates, example code, vignette improvements
- Bug fixes with clear root causes
- Test coverage expansion
- Refactoring that doesn't change behavior

## Tools & Automation

I embrace:
- **Agent teams** – Parallel exploration, analysis, and documentation tasks
- **Claude Code automation** – Remote triggers for routine tasks (testing, documentation builds, validation checks)
- **GitHub integration** – Use actions for CI/CD when beneficial; keep PRs focused and reviewable
- **Copilot + Claude Code complementarity** – Copilot for routine completions; Claude Code for strategy and reasoning

I avoid:
- Over-engineering for hypothetical future features
- Premature abstractions (three similar functions is OK; wait for clear patterns before abstracting)
- Magic numbers or unexplained defaults
- Heavy mocking in tests (prefer integration tests with real data when possible)

## Communication Style

I prefer:
- **Direct and concise** – Get to the point; avoid preamble
- **Questions over assumptions** – If unsure, ask rather than guess
- **Evidence-based discussions** – "Let's check the data" beats "I think..."
- **Async-friendly** – Clear written notes are better than meetings

I do NOT prefer:
- Flowery explanations or excessive detail
- Passive voice or hedging ("might consider potentially exploring")
- Summaries of what was just done (I can read the diff)

## Current Focus

Working to establish:
1. A reproducible local environment for cbrATLAS development and analysis
2. Clear documentation and onboarding for future work
3. A structured approach to extending the package (new study designs, additional models)
4. Integration of Claude Code as a trusted development partner for complex statistical reasoning

## Project Philosophy

**cbrATLAS exists to solve a real problem**: Active tags improve capture probability but introduce tag failure uncertainty. This package should:
- Make correct biological inference (survival) tractable
- Be transparent about assumptions and uncertainty
- Serve researchers, not showcase statistical sophistication for its own sake

Code should be **maintainable by others** – future researchers should be able to understand the analysis pipeline, validate the mathematics, and extend it with confidence.

---

**Last Updated:** 2026-04-03

*This document is your guide to how I think and work. Refer back to it when making decisions about code style, documentation, testing, and collaboration.*
