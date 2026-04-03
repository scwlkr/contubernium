# Refactor Review Handoff

Date: 2026-04-03

## Purpose

This note captures the repository review findings and a refactor plan for follow-up implementation work in another thread.

This is a scratchpad document, not a canonical doctrine file.

## Operator Decisions

These decisions were confirmed after the review and should be treated as accepted implementation direction:

1. Session approval bypass is acceptable as long as explicit operator consent is gained.
2. Specialists should be able to run tools/actions so they can return a better result back to `decanus`.

## Important Alignment Note

The two decisions above do not fully match the current constitutional docs as written.

That means the implementation thread should treat doctrine and contract alignment as part of the work:

- `AGENTS.md`
- `docs/doctrine.md`
- `docs/agent-contracts.md`
- `USER_MANUAL.md`
- `docs/RUNTIME_TOOL_CONTRACTS.md`

The runtime should not silently drift from those files any further.

## Current Verification Baseline

At review time:

- `zig build` passed
- `zig build test` passed
- `bun test` passed in `opentui/`

The core problem is not that the project fails to build. The problem is that several architectural and safety boundaries are under-specified or implemented in a way that will not scale cleanly.

## Findings

### 1. Specialist execution is allowed, but the execution model is still too implicit

The original review flagged specialist-side tool execution as a commander-first boundary problem.

Given the operator decision, the issue should be reframed:

- specialists may run runtime tools
- specialists should still remain subordinate tools under `decanus`
- specialist tool usage needs an explicit bounded sub-loop contract
- specialists must not become independent orchestrators
- specialists must not invoke other specialists directly
- control must return to `decanus` after the specialist result

What needs refactoring is not the existence of specialist tool use. What needs refactoring is the lack of a clearly codified subordinate execution model.

### 2. Workspace safety is lexical only and is vulnerable to symlink escape

Current path checks reject absolute paths and `..`, but they do not enforce a resolved workspace-root boundary.

Implications:

- `read_file`
- `write_file`
- `list_files`
- `search_text`

can be redirected outside the workspace through symlinks.

This should be treated as a real safety defect.

### 3. `search_text` has CLI flag injection risk

The runtime passes the search pattern directly into `rg` and `grep` without a `--` separator.

Implications:

- a pattern beginning with `-` can be interpreted as a flag instead of data
- tool behavior becomes inconsistent with the published tool contract
- pruning and bounded-search assumptions become less reliable

This is a correctness and safety issue, not just a robustness nit.

### 4. Session approval bypass needs explicit consent semantics and auditability

With the operator decision, session approval bypass is not inherently invalid.

The problem is that the current implementation and docs do not define it rigorously enough.

The follow-up thread should define:

- how consent is gained
- when consent expires
- whether it is per session, per run, or per tool class
- how the state and logs record that consent
- how the UI communicates bypass state clearly
- whether bypass can apply to all guarded actions or only specific categories

The current implementation is too close to a blanket override.

### 5. State, session, and run-log writes are not crash-safe

The runtime persists canonical data by truncating and rewriting files directly.

Implications:

- interrupted writes can corrupt canonical state
- session index and record corruption can break recall
- run log corruption undermines the audit trail

This affects:

- state
- config
- run logs
- session indexes
- session records

Atomic write discipline is needed.

### 6. Memory ownership is weak and hidden by `page_allocator`

The runtime uses `std.heap.page_allocator` in the main app and several hot paths allocate without corresponding frees.

Implications:

- long-lived UI/bridge sessions can grow memory indefinitely
- provider transport calls leak buffers
- config/state loading paths are not ownership-clean

This is survivable in short CLI runs but poor engineering for the actual intended runtime shape.

### 7. Logging and history updates are structurally expensive

Several hot paths repeatedly copy or reload full collections:

- history appends copy the full history slice
- intermediate result appends copy the full slice
- run log event appends reload and rewrite the full JSON log
- OpenTUI rereads the full log file on refresh intervals

Implications:

- longer missions will degrade disproportionately
- UI responsiveness will decay as logs grow
- persistence cost grows with mission duration

### 8. Prompt assembly is much heavier than the architecture needs

Each turn rebuilds a very large prompt from:

- base pattern
- tool policy
- soul
- contract
- skill
- selected action sections
- multiple memory layers
- routing guidance
- task summaries
- recent history

The runtime already includes context-pressure handling, but the prompting system is one of the main causes of that pressure.

This should be simplified and made more targeted.

### 9. Module boundaries are too broad

The Zig code is concentrated in a handful of very large files:

- `src/runtime_core.zig`
- `src/runtime_assets.zig`
- `src/runtime_loop.zig`
- `src/runtime_ui.zig`
- `src/runtime_app.zig`

This makes changes slower and weakens ownership boundaries between:

- protocol/types
- state management
- persistence
- tool execution
- provider transport
- commander loop
- specialist loop
- CLI/UI bridge

### 10. Tests are numerous but overly concentrated

There is a decent number of tests, but they are packed heavily into `src/runtime_app.zig`.

Implications:

- test intent is harder to navigate
- ownership is unclear
- module-level regression coverage is harder to maintain as code is split

The project needs the test suite redistributed along module lines as the refactor proceeds.

## Recommended Refactor Plan

### Phase 1: Policy and doctrine alignment

Update the repo’s governing and shipped-behavior docs so the implementation thread is working against explicit truth.

Define:

- session approval bypass as an operator-consented mode
- specialist tool usage as a bounded subordinate execution model
- the exact commander-first boundary that still remains in force

### Phase 2: Formalize the specialist subordinate execution model

Refactor the loop so specialist tool execution is explicit and constrained.

Target properties:

- `decanus` remains mission owner
- specialists can use runtime tools
- specialists cannot invoke other specialists
- specialist execution returns a structured result to `decanus`
- logs and state make specialist sub-execution visible

### Phase 3: Harden safety boundaries

Replace lexical path checks with resolved workspace-root enforcement.

Also:

- block symlink escape for guarded workspace tools
- add `--` separators for `rg` and `grep`
- review command blocking so it is not only substring-based

### Phase 4: Replace persistence primitives

Introduce a shared persistence layer with:

- write-to-temp
- flush
- atomic rename
- consistent serialization helpers

Then migrate:

- state persistence
- session records
- session indexes
- global session index
- run logs

### Phase 5: Fix memory ownership

Move away from relying on `page_allocator` to hide leaks.

Refactor toward:

- explicit ownership
- request-scoped arenas where appropriate
- deinit paths for provider responses and file loads
- allocator discipline at module boundaries

### Phase 6: Split the runtime into real modules

Suggested target slices:

- `protocol` / core types
- `state_manager`
- `persistence`
- `provider_transport`
- `tool_runner`
- `prompt_builder`
- `commander_loop`
- `specialist_loop`
- `cli`
- `ui_bridge`

This should be done incrementally, not as a single rewrite.

### Phase 7: Reduce prompt weight

Refactor prompt assembly to use:

- cached static prompt fragments
- smaller per-turn deltas
- targeted memory excerpts instead of repeated full dumps
- lane-specific evidence selection

The goal is to lower prompt pressure without weakening determinism.

### Phase 8: Rebalance logging and UI data flow

Refactor logs and UI around incremental updates instead of full-file rereads.

Potential directions:

- append-friendly log format
- indexed summaries
- incremental bridge snapshots
- reduced OpenTUI polling

### Phase 9: Reorganize the test suite around module ownership

As code moves, move the tests with it.

Add high-priority regression tests for:

- symlink escape prevention
- `search_text` patterns that begin with `-`
- specialist subordinate tool execution semantics
- approval bypass consent and persistence behavior
- atomic-write recovery behavior
- long-run log and history growth behavior

## Suggested Execution Order For The Next Thread

1. Align doctrine and shipped-behavior docs with the accepted operator decisions.
2. Refactor the execution model for specialist subordinate tool use.
3. Harden workspace and command safety boundaries.
4. Introduce atomic persistence helpers and migrate canonical writes.
5. Split the runtime into smaller modules while moving tests with them.
6. Simplify prompt assembly and improve log/UI scaling.

## Bottom Line

Contubernium already has a clear doctrine and a working build/test baseline.

The next implementation thread should avoid broad rewriting and instead do disciplined structural work:

- codify the accepted policy decisions
- make specialist execution explicit and bounded
- harden the safety model
- fix persistence and memory ownership
- split the runtime by domain

That sequence will improve correctness and maintainability without losing the commander-first architecture.
