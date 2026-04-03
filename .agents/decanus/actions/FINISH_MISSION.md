# FINISH_MISSION

## Purpose

Close the loop only when the mission is complete or irreducibly blocked and further safe execution would add no control value.

`FINISH_MISSION` exists to prevent fake closure.

## Strategic Goal

End the mission in a way that is:

- truthful
- evidenced
- legible
- resumable when blocked

## When To Use

Use `FINISH_MISSION` when:

- all required work is done
- the requested deliverable has been produced
- the operator explicitly wants a stopping-point response now
- the operator explicitly asked for a read-only exploratory response and the current evidence supports a useful synthesis now
- the system needs operator input or approval and no safe progress remains
- a final blocked condition has been made explicit and cannot be reduced further inside the loop

Do not use it merely because substantial work has happened.

## Required Inputs

- final known state
- relevant tool or specialist results
- blockers if any
- verification evidence
- residual risk if any
- operator constraints about stopping point or completeness

## Governing Constraints

`FINISH_MISSION` must:

- not claim completion without evidence
- keep the summary tied to actual outcomes
- distinguish clearly between complete, blocked, and partial outcomes
- avoid optimistic wording that hides missing verification
- make resumption conditions clear when the outcome is blocked

## Completion Checklist

Before choosing `finish`, `decanus` should be able to answer yes to the relevant questions:

### If Completing Successfully

- Was the mission objective actually satisfied?
- Is there evidence for the completed work?
- Are remaining issues either out of scope or explicitly disclosed?
- Is there any unresolved blocker that should keep the loop open instead?

### If Ending As Blocked

- Is the blocker explicit rather than vague?
- Is there no safe autonomous step left?
- Is it clear what condition must change?
- Is it clear whether the operator, policy, or environment must change it?

If these answers are weak, do not finish yet.

## Process

### Step 1: Classify The End State

Determine whether the mission is:

- complete
- blocked on operator action
- blocked on runtime or policy constraints
- ending at the operator's requested stopping point

### Step 2: Verify The Ground Truth

Check the actual evidence:

- changed files
- tool output
- validation results
- explicit operator instruction
- explicit blocker evidence

Do not rely on momentum, memory drift, or likely assumptions.

### Step 3: Summarize Reality

State:

- what was accomplished
- what was not accomplished if relevant
- why the loop is ending now
- what remains next if the mission is blocked or intentionally paused

### Step 4: Return The Correct Decanus Outcome

- `action: "finish"` with `final_response` when the mission should end successfully
- `action: "blocked"` with `blocked_reason` when the mission must stop without safe progress

## Final Response Quality

A strong final response should:

- match the actual work performed
- stay proportionate to the mission
- disclose meaningful residual risk or lack of verification
- avoid pretending certainty where certainty does not exist

The final response is not a victory speech.
It is the operator-facing truth of the mission state.

## Blocked Response Quality

A strong blocked response should state:

- the exact blocking condition
- why `decanus` cannot safely continue
- what input, approval, or environment change is needed

Blocked should feel actionable, not dramatic.

## Success Criteria

`FINISH_MISSION` is successful when:

- the loop ends for the correct reason
- the operator can understand the actual outcome immediately
- the outcome is consistent with evidence
- no hidden unresolved condition was concealed by the wording

## Failure Modes

- Missing verification: keep the loop open
- Unresolved blocker: do not mark complete
- Partial progress presented as completion: continue the loop or return explicit blocked state
- Vague blocked wording: replace it with a condition that makes resumption clear
- Final response drift: remove claims unsupported by evidence

## Example End States

### Complete

- required code was changed
- relevant validation was run or its absence disclosed
- the requested result was produced

### Blocked

- policy prevents the required command
- operator approval is required and unavailable
- a key requirement is ambiguous and cannot be safely inferred

## Example

`decanus::FINISH_MISSION` after the requested implementation and validation are complete, or after the loop has reached a precise operator- or policy-blocked stopping point with no safe further move.
