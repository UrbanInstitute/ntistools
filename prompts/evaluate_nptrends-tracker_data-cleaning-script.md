Analyze `inst/examples/nptrends_tracker_data_extraction.R` and identify patterns suitable for package-level refactoring.

## Steps

1. Read the script thoroughly before doing anything else
2. Audit existing package functions (check R/ directory and NAMESPACE) to inventory what already exists
3. Identify refactoring candidates in the script — repeated logic, hardcoded patterns, reusable transformations
4. For each candidate, check against existing functions:
   - If similar: evaluate extend vs. new (prefer extension unless it would bloat the interface)
   - If novel: propose as a new function with a clear justification
5. Draft a written refactoring plan and stop — do not write any code until the plan is approved

## Plan format

For each proposed change, include:
- **Function name** (following package naming conventions)
- **What it replaces** (line references in the script)
- **Signature** (arguments and return value)
- **Extend or new** — and why
- **Risk / notes**

## Constraints
- No code changes until plan is explicitly approved
- Prefer extending existing functions over proliferating new ones
- Flag any cases where the right call is genuinely ambiguous