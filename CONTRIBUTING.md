# Contributing To Contubernium

Contubernium feature work follows the constitutional development process in `AGENTS.md`, `docs/doctrine.md`, `docs/agent-contracts.md`, and `docs/CONTUBERNIUM_CONSTITUTION.md`.

## Read First

Before changing runtime behavior, read:

- `AGENTS.md`
- `docs/doctrine.md`
- `docs/agent-contracts.md`
- `USER_MANUAL.md`

## Required Build Order

For every feature change:

1. add or update the test for the intended outcome first
2. implement the behavior
3. update `USER_MANUAL.md` with the shipped behavior and the verifying test reference

## USER_MANUAL Requirements

When behavior changes:

- update the relevant operator-facing section if setup, commands, approvals, memory behavior, or runtime behavior changed
- add or update the matching row in the `Feature And Test Ledger`
- record the verifying test in the `Current verification` column using the test file path and test name
- treat missing manual updates as incomplete work

The `Feature And Test Ledger` in `USER_MANUAL.md` is the canonical location for feature-to-test references.

## Verification Expectations

Before opening or approving a feature change, run the relevant automated coverage.
For runtime and CLI work, start with:

```bash
zig build test
```

Add narrower or broader verification commands when the changed surface requires them.

## Review Checklist

Until CI enforces this automatically, reviewers should reject feature work unless all of the following are true:

- the intended behavior has an automated test or an updated automated test
- `USER_MANUAL.md` describes the shipped behavior
- `USER_MANUAL.md` updates the `Feature And Test Ledger` row for that feature
- the `Current verification` column names the test file and test name that verify the change
