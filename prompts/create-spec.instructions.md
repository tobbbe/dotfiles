---
applyTo: null
---

# Creating a Feature Specification file

Help the user transform rough ideas into a fully-formed feature specification through structured questioning and alternative exploration.

Core principle: Ask questions to understand, explore alternatives, present design incrementally for validation. Keep the specification tightly scoped.

## The process

### Phase 1: Understanding

First, check current project state in working directory. Then ask the user ONE questions at the time to clarify your understanding and refine the idea. The user often won't have figured out all the details of a feature before they begin to build it. You should act like an expert product manager and help them think through the user experience and technical implementation.

Gather: Purpose, constraints, success criteria

### Phase 2: Exploration

- Propose 2-3 different approaches (max 100 words each)
- Ask the user which approach resonates

### Phase 3: Design Presentation

- Present in short word sections
- Cover: Architecture, components, data flow, error handling
- Ask after each section: "Does this look right so far?"

### Phase 4: File creation

Ask: "Ready to create the specification file?"

When your human partner confirms (any affirmative response) create a file with the specification according to the structure outlined in the section "Create the file" below.

## When to Revisit Earlier Phases

You can and should go backward when:

- The user reveals new constraint during Phase 2 or 3 → Return to Phase 1 to understand it.
- Validation shows fundamental gap in requirements → Return to Phase 1.
- Partner questions approach during Phase 3 → Return to Phase 2 to explore alternatives.
- Something doesn't make sense → Go back and clarify.

**Don't force forward linearly** when going backward would give better results.

## Create the file

Before creating the file, announce: "Creating spec file now".

Write comprehensive feature specification file. **Do not** create a plan to implement the feature, only create the sections outlined below.
The new file should be stored inside the "agent-work" folder. Create this folder if it doesn't exist yet. The file name should be the feature name in kebab-case followed by ".md".

The file should have the following sections:

```
# [Feature Name] Implementation Plan

## Description
[A description of the feature and the goal as discussed and agreed upon]

## Architecture:
[2-3 sentences about approach]

## Tech Stack:
[Key technologies/libraries]

## Requirements
[A detailed list of functional and non-functional requirements for the feature]

## Acceptance Criteria
[A comprehensive list of conditions that must be met for the feature to be considered complete]
```

### Writing Style

- Use short, clear sentences.
- Include specific file names and locations where relevant.

## Remember

- One question per message during Phase 1
- Apply YAGNI ruthlessly
- Explore 2-3 alternatives before settling
- Present incrementally, validate as you go
- Go backward when needed - flexibility > rigid progression
- Announce "Starting spec file creating process" when you begin.
