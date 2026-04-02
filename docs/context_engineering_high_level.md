# Context Engineering

Context engineering is the practice of giving an AI system the right information at the right time so it can do useful work without being overloaded.

A model only sees what is inside its context window during a given step. That means performance depends not just on the model itself, but on how well its context is prepared, filtered, structured, and refreshed.

## What context engineering lets you do

### 1. Give the model the right instructions
You can provide the rules, goals, examples, and behavioral guidance that define how the system should act.

Examples:
- system prompts
- agent instructions
- few-shot examples
- tool descriptions
- style or formatting rules

### 2. Give the model the right knowledge
You can supply facts, documents, memories, and reference material that help it answer correctly.

Examples:
- retrieval from documents
- project notes
- user preferences
- prior decisions
- structured data from files or databases

### 3. Preserve important information outside the context window
Not everything should stay in the live prompt. Context engineering lets you save useful information elsewhere and bring it back when needed.

Examples:
- scratchpads
- task state
- memory files
- summaries of past work
- saved intermediate outputs

### 4. Pull in only what matters for the current step
Instead of dumping everything into the prompt, you can select the most relevant information for the exact task being performed.

Examples:
- retrieve only relevant documents
- load only the rules for the current tool
- include only the last useful messages
- inject only the memory tied to the active task

### 5. Compress long histories into smaller usable forms
As work grows, raw history becomes too large. Context engineering lets you reduce it while keeping what matters.

Examples:
- summaries
- trimmed conversation history
- extracted decisions and action items
- compressed notes for handoff to another step or agent

### 6. Split work into separate contexts
Different tasks often work better when isolated. Rather than one giant context, you can create separate contexts for separate jobs.

Examples:
- one agent for research
- one agent for coding
- one agent for planning
- isolated workspaces for tools, subtasks, or environments

### 7. Reduce confusion and failure
Poor context causes many agent problems. Good context engineering lowers the chance of the model getting distracted, contradictory, or stuck.

It helps reduce:
- irrelevant information
- conflicting instructions
- hallucinated details that get carried forward
- overloaded prompts
- tool misuse caused by bad or missing context

## Four core moves

Most context engineering can be understood through four actions:

### Write
Save useful context outside the live prompt.

### Select
Choose what to bring into the prompt for the current step.

### Compress
Reduce large context into smaller, still-useful forms.

### Isolate
Separate tasks so each one gets its own cleaner context.

## Why it matters for agents

This matters even more for agents than for simple chat because agents:
- run longer
- call tools
- generate intermediate outputs
- revisit old decisions
- accumulate more and more context over time

Without context engineering, an agent tends to get slower, less accurate, and more confused as a task grows.

## Simple mental model

A useful way to think about it:

- the model is the reasoning engine
- the context window is its working memory
- context engineering is the discipline of managing that working memory well

The goal is not to give the model more information.
The goal is to give it the right information.
