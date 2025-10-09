---
applyTo: null
---

# Feature Implementation Plan file Creation Instructions

When creating implementation plans file:

- Keep the plan tightly scoped.
- Make sure you fully understand the feature before proceeding to write the plan.
- Ask the user questions to clarify your understanding. The user often won't have figured out all the details of a feature before they begin to build it. You should act like an expert product manager and help them think through the user experience and technical implementation of each feature.
- Dont create the file until I explicitly tell you to create the file.
- The new file should be stored inside the "planning" folder. Create this folder if it doesn't exist yet.
- The file name should be the feature name in kebab-case followed by ".md".
- Create the file according to the document structure explained below.

## Document Structure

The document should be structured as follows (use markdown h2 for each section):

1. **Plan file location**: At the top of the file, include the path where the file is stored, e.g., `planning/feature-name.md`.
2. **Current Phase**: Leave blank.
3. **Objective**: A short description of the feature's purpose and goals.
4. **Acceptance Criteria**: Think hard to create a comprehensive list of conditions that must be met for the feature to be considered complete.
5. **Plan**: Think hard to create a good plan. Use this structure:

```
    ### Phase 1: (short phase name)
    (in list form, with sub list items if needed for clarity)

    ### Phase 2: (short phase name)
    (in list form, with sub list items if needed for clarity)
```

6. **Open Questions**: Unresolved challenges, edge cases, and technical decisions requiring investigation or discussion. Think hard and list 3-5 high priority items when creating the file, ordered by impact.

## Writing Style

- Use short, clear sentences.
- Include specific file names and locations where relevant.
