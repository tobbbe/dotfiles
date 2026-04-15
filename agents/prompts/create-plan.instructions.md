---
applyTo: null
---

# Extend specification file with Implementation Plan section

Extend the linked specification file with an comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, docs they might need to check. Give them the whole plan as bite-sized tasks. DRY. YAGNI.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain.

Read the specification file carefully and make sure you fully understand it.

Do not change anything in the existing specification file, only add the new section named "Implementation Plan" at the end.

Think hard to create the best possible plan.

Announce at start: "Extending the specification file with an implementation plan".

## Bite-Sized Task Granularity

Each task should edit at most 1-3 files. If a task requires touching more than 3 files, break it down further.

## Task Structure

```
### Task N
**Files:**
- Create: `exact/path/to/file.ts`
- Modify: `exact/path/to/existing.ts`

[Detailed description of the task, including specific implementation details, code snippets, and any relevant context. Be explicit about what needs to be done, why, and how. Include documentation updates if applicable.]
```

## Remember

- Exact file paths always
- Complete description in task (not "add validation")
- Use short, clear sentences.
- Include specific file names and locations where relevant.
- DRY
- YAGNI
