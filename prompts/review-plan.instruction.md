# Review Planning Document Instructions

When reviewing an implementation plan document:

- Ask the user to provide the planning document if not already specified.
- Read the entire planning document thoroughly before providing feedback.

## Review Checklist

Evaluate the planning document against these criteria:

### Objective Clarity
- Is the feature's purpose clearly defined?
- Are the goals specific and measurable?

### Acceptance Criteria Completeness
- Are all criteria testable and unambiguous?
- Do they cover both happy paths and edge cases?
- Are they prioritized (must-have vs nice-to-have)?
- Is it clear when the feature is "done"?

### Plan Structure and Detail
- Are phases logically ordered and scoped?
- Does each phase have clear, actionable implementation steps?
- Are file paths and technical specifications included where needed?
- Are sub-instructions used effectively to break down complex steps?
- Would another developer understand what to build from these instructions?

### Technical Feasibility
- Are there any technical impossibilities or conflicts?
- Does the plan account for existing codebase patterns and architecture?

### Open Questions Quality
- Are there obvious questions missing?

### Missing Elements
- Are there critical phases or steps not covered?
- Should any phase be split into more phases?
- Does the plan address error handling and edge cases?

## Review Output Format

Structure your review as follows:

1. **Critical Issues**: Any blocking problems that must be addressed
2. **Suggestions**: Specific improvements organized by section
3. **Additional Questions**: Questions to ask the user to improve the plan

## Review Guidelines

- Be specific: reference exact sections and suggest concrete changes
- Prioritize: distinguish between critical issues and nice-to-haves
- Be constructive: explain *why* something should change
- Ask questions: if context is missing, ask rather than assume
