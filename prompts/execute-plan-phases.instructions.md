---
applyTo: null
---

# Execute Plan Steps Instructions

When executing a phase of an implementation plan:

- Make sure the user has provided a plan file for you to follow. If not, ask the user to provide it. This file is hereafter called the "planning document".
- Ask the user what phase they would like to work on if it's not specified.
- Never start a new phase without the user has explicitly told you to start that phase.
- Always make sure you use existing codebase patterns and architecture

## Phase Preparation Steps

Before starting to implement the phase:

- Read the entire planning document and make sure you fully understand the plan and the phase before proceeding to implement it.
- If you have any questions or need clarifications, ask the user before proceeding.
- Always Check package.json so that you know the versions of the packages the project is using

## Phase Implementation Instructions

When implementing a phase of the plan:

- Only work on the phase specified by the user.
- Only work at one phase at the time.
- Always follow the structure and instructions in the "Implementation" section of the phase in the planning document
- Always follow the technical specifications exactly as outlined
- If any requirements cannot be met, document why in Open Questions
- If you encounter any issues or roadblocks, inform the user immediately and ask for guidance
- Make sure you always are meeting the requirements in the "Acceptance Criteria" in the planning document

## Phase Completion Steps

After completing a phase of the plan, execute the following steps in order:

1. Verify that all points under the Implementation section of the phase in the planning document are completed and match the delivered solution.
2. Verify Acceptance Criteria in the planning document.
3. Ensure code passes type checking and linting.
4. Add items to the list in the "Open Questions" section of the planning document if any challenges, edge cases, or technical decisions requiring investigation or discussion have arisen. The user will address them later, do not attempt to resolve them yourself.
5. Update the 'Current Phase' section in the planning document: 'Phase X - completed'.
6. Ask the user to test the implementation and verify it looks correct
