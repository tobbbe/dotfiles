---
name: feature-spec
description: A skill for creating and updating feature spec documents.
---

# Feature Spec

This skill helps you create and update feature specification documents that serve as validation criteria during implementation.

Before beginning work on a feature, both in a new and running session, ask the user if they want to create a new spec document, keep working on an existing one, or not use any spec document at all.

## When to use this skill

Use this skill when you or the user:

- Is about to start working on a new feature.
- Is changing, finding, adding or removing new Acceptance Criteria, Requirements, Constraints, Assumptions, Out of scope or Related Files & Services for the feature.
- Before committing work on a feature.
- When reviewing changes to a feature.

## Workflow
- The point of the document is "Here's what done looks like. Check your work against it."
- Create the document in the repo root at `./features/<feature-name>.md` if it doesn't exist, with all headers and empty sections.
- Update the relevant sections of the document based on the user's input. If the user is adding new information, append it to the relevant section. If the user is changing existing information, update the relevant section accordingly.
- All content under the sections should be in a plain list format. Each item should be short and specific, ideally 1-3 sentences.
- If there are any contradictions or missing information, ask the user for clarification.
- Before finishing implementation or update of a feature, walk through every item in the spec and verify it's satisfied.
- If an item isn't met, either fix it or flag it to the user.

## Document structure

```
# [Name of the feature]
[Short description of the feature]

## Constraints

## Assumptions

## Out of scope

## Requirements & Acceptance Criteria

## Related Files & Services
```

## Example document

```
# Password Reset

Allow users to reset their password via email without contacting support.

## Constraints

- Must use existing email infrastructure (SendGrid)
- Must comply with SOC 2 requirements
- Rate-limited to 5 reset requests per hour per user

## Assumptions

- Users have access to their registered email
- Majority of reset attempts happen on mobile

## Out of scope

- SMS-based password reset
- Admin-initiated password resets

## Requirements & Acceptance Criteria

- User can request a password reset from the login page
  - Given a valid email, they receive a reset link within 30 seconds
  - Given an unregistered email, they see the same confirmation message
- Reset link expires after 24 hours
  - Given an expired token, user sees an error with a retry option
- New password must be at least 12 characters
  - Given a password under 12 characters, user sees a validation error

## Related Files & Services

- Auth endpoints: `src/api/auth/reset.ts`
- Email templates: `src/templates/password-reset.html`
- SendGrid integration: `src/services/email.ts`
```
