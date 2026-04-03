# Implement Broad-Request Autonomy in Contubernium

You are working on Contubernium’s orchestration behavior.

## Context

The current system becomes too rigid when the operator gives a broad but actionable request. Instead of choosing a reasonable scope and proceeding, the orchestrator repeatedly asks narrowing questions until the interaction stalls.

This is not primarily a capability problem. It is a control-policy problem.

In mature agent systems, this is usually solved by shifting from **certainty-first routing** to **best-effort execution with explicit assumptions**. The common pattern is:

- treat broad requests as actionable by default,
- distinguish true blockage from ordinary uncertainty,
- limit clarification loops,
- let the orchestrator choose a sensible review framework,
- and only interrupt the operator when execution is genuinely blocked.

The result should feel less bureaucratic and more competent, while still preserving safety and system discipline.

## Objective

Refine the existing behavior so that broad operator requests lead to useful work instead of repeated clarification.

Do this in a way that fits the current architecture and philosophy of Contubernium rather than replacing it with a completely different system.

## The Failure Pattern

Current pattern:

1. operator gives a broad request,
2. orchestrator asks for scope,
3. operator answers broadly,
4. orchestrator asks for narrower scope again,
5. this repeats instead of progressing into execution.

Desired pattern:

1. operator gives a broad request,
2. orchestrator determines whether it is actually blocked,
3. if not blocked, it states brief assumptions,
4. it proceeds with a reasonable default review or execution framework,
5. it returns findings, priorities, or next actions.

## Design Direction

Use established agent-design principles that have worked well in practice:

### 1. Ambiguity should not automatically trigger clarification
Many production-grade systems treat ambiguity as something to manage, not something that stops motion. If the system can make a reasonable assumption without causing major waste or risk, it should proceed.

### 2. Clarification should be budgeted
A common fix is to limit how often the orchestrator may ask follow-up scope questions before it must act. This prevents local models from getting trapped in conservative loops.

### 3. Broad directives should map to default frameworks
When users say things like “review the whole project,” strong systems do not demand a category selection. They apply a default review lens internally and begin.

### 4. Operator intent should override procedural friction
When the operator explicitly says to stop asking questions and proceed, the system should treat that as a strong signal to continue autonomously unless blocked by a real dependency.

### 5. Assumptions are often better than questions
A common design approach is to let the orchestrator briefly state what it is assuming, then continue. This gives the operator a chance to correct course without forcing an unnecessary pause.

### 6. Best-effort output is better than no output
Useful partial work is usually preferable to repeated requests for perfect scope definition.

## Constraints

- Preserve Contubernium’s existing structure and command philosophy.
- Avoid introducing changes that would destabilize the current system unnecessarily.
- Do not overfit the solution to one transcript; solve the broader orchestration issue.
- Keep the implementation aligned with local-model realities, especially the tendency of smaller models to over-repeat safe decision patterns.
- Favor minimal, robust changes over sprawling redesign.

## What to Improve

Address the orchestration behavior wherever it currently causes unnecessary clarification loops. This may involve prompt logic, contracts, routing rules, decision criteria, state transitions, schemas, or other supporting mechanisms.

Rather than hardcoding a brittle rule for one scenario, improve the system so it behaves better across requests such as:

- review the project,
- find gaps,
- improve this,
- look at the whole thing,
- tell me what’s missing,
- inspect the system and prioritize issues.

## Expected Outcome

After your changes, the system should generally behave like this:

- recognize that a broad request is still actionable,
- determine whether it is truly blocked,
- proceed when reasonable assumptions are available,
- avoid repeated scope interrogation,
- surface assumptions briefly when helpful,
- and return ranked, practical results.

The operator experience should feel more decisive, more useful, and less rigid.

## Implementation Standard

Make the changes in the spirit of how strong orchestrators are usually improved:

- give the system room to infer,
- make clarification the exception rather than the default,
- preserve user control without forcing constant user specification,
- and prefer mechanisms that generalize.

## Deliverable

Implement the improvement directly in the codebase and any supporting prompt or policy files needed.

Where appropriate, include a concise explanation of:

- what was changed,
- why that change addresses the failure mode,
- and how the updated behavior now handles broad operator requests more effectively.