# Constitution Decisions

## Purpose

This document records owner decisions that resolve constitutional ambiguities and unblock implementation work.

It does not amend the Constitution. It clarifies how the project should implement it.

## Decision 001: Core Agent Count

Decision:

- The constitutional "eight (8) core agents" count includes `decanus`.

Implementation consequence:

- Contubernium should have exactly 8 core agents total:
  - `decanus`
  - 7 non-helper core specialists
- Any additional agents beyond those 8 should be classified as helper agents.

Current impact:

- The current roster is oversized for the new constitution and will need reclassification or consolidation during alignment work.

## Decision 002: OpenRouter Integration Pattern

Decision:

- OpenRouter should be a first-class supported backend.
- It should use the industry-standard OpenAI-compatible transport pattern rather than a separate custom transport stack.

Rationale:

- This is the standard way modern developer tools integrate OpenRouter.
- It preserves compatibility with existing OpenAI-compatible runtime logic.
- It avoids unnecessary provider-specific complexity while still honoring the Constitution's explicit OpenRouter requirement.

Implementation consequence:

- The runtime should expose OpenRouter clearly in config, docs, and provider selection.
- Internally, it may reuse the existing `openai-compatible` request/response transport shape.

## Decision 003: Approval Bypass Scope

Decision:

- Explicit consent to proceed without approval is scoped per session.
- The operator must be able to toggle it back off during the same session.

Implementation consequence:

- Approval bypass should not be a permanent global mode.
- Approval bypass should not implicitly carry across unrelated future sessions.
- The active session state should record whether bypass is currently enabled.

## Effective Context

These decisions apply to the current constitution alignment effort and should be treated as the default interpretation unless replaced by a future amendment or newer owner decision record.
