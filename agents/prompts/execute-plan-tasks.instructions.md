---
applyTo: null
---

# Execute Plan Tasks

## Overview

Load plan, review critically, execute tasks in batches, report for review between batches.

Core principle: Batch execution with checkpoints for architect review. Execute task at a time, report progress, ask for confirmation before next task.

Announce at start: "I'm using the Executing Plans skill to implement this plan."

## Task implementation

When executing a task of an implementation plan:

- Ask the user what task they would like to work on if it's not specified. Always assume all previous tasks are completed.
- Never start a new task without the user has given permission.
- Always make sure you use existing codebase patterns and architecture.
- Make sure the implementation always are meeting the Requirements and Acceptance Criteria.
- If you have any questions, need clarifications or hit road blocks, ask the user for guidance before proceeding.
- Always Check package.json when using a package so that you know what versions of the package is used.

## Task Completion

After completing a task; ask the user to test and verify the implementation.
