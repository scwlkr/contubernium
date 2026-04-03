# Runtime Tool Contracts

This document is the canonical published registry for Contubernium runtime tools.

All runtime tools share the same failure envelope:

```json
{
  "code": "MACHINE_READABLE_CODE",
  "cause": "operator-facing explanation",
  "context": {
    "actor": "",
    "lane": "",
    "tool": "",
    "target": "",
    "command": "",
    "detail": "",
    "provider": "",
    "model": "",
    "turn_id": "",
    "iteration": 0
  }
}
```

Shared rules:

- `Permission class` is one of `Read`, `Write`, `Execute`.
- Runtime tools may be requested by `decanus` or by the currently active specialist invocation.
- When a specialist requests a runtime tool, the result returns to that same specialist until the invocation completes or blocks.
- `Approval behavior` is derived from the tool's published metadata and session policy.
- `session-bypass` is an operator-consented approval mode for guarded runtime tools: it is active-session-only, off by default, reversible, and surfaced in session state and durable logs.
- `Timeout behavior` is either `None` or `Policy default` (`policy.tool_timeout_ms`).
- Success responses return human-readable `summary` text to the active turn.

## list_files

### Contract
- Permission class: `Read`
- Approval behavior: Policy-guarded through the read-tool policy toggle. If the active session is in `session-bypass`, the per-request confirmation step is skipped for this guarded tool.
- Timeout behavior: `None`

### Input Schema
- `path` (optional, string): Workspace-relative directory path. Defaults to `.`.
- `description` (optional, string): Optional rationale for the listing request.

### Output Schema
- `summary` (text): Directory listing text, including exit status and any truncation notice.

### Failure Response
- Shape: `code`, `cause`, `context`
- Common codes: `UNKNOWN_TOOL_REQUEST`, `TOOL_PATH_UNSAFE`, `TOOL_ACCESS_DENIED`

## read_file

### Contract
- Permission class: `Read`
- Approval behavior: Policy-guarded through the read-tool policy toggle. If the active session is in `session-bypass`, the per-request confirmation step is skipped for this guarded tool.
- Timeout behavior: `None`

### Input Schema
- `path` (required, string): Workspace-relative file path to read.
- `description` (optional, string): Optional rationale for the read request.

### Output Schema
- `summary` (text): File-read summary containing the path and truncated file contents.

### Failure Response
- Shape: `code`, `cause`, `context`
- Common codes: `MISSING_PATH`, `TOOL_PATH_UNSAFE`, `FILE_NOT_FOUND`, `TOOL_TARGET_INVALID`, `TOOL_ACCESS_DENIED`

## search_text

### Contract
- Permission class: `Read`
- Approval behavior: Policy-guarded through the read-tool policy toggle. If the active session is in `session-bypass`, the per-request confirmation step is skipped for this guarded tool.
- Timeout behavior: `Policy default`

### Input Schema
- `pattern` (required, string): Literal or regex search pattern.
- `path` (optional, string): Workspace-relative path to search. Defaults to `.`.
- `description` (optional, string): Optional rationale for the search request.

### Output Schema
- `summary` (text): Search summary containing the pattern, path, and matched lines.

### Failure Response
- Shape: `code`, `cause`, `context`
- Common codes: `MISSING_PATTERN`, `TOOL_PATH_UNSAFE`, `TOOL_TIMEOUT`, `FILE_NOT_FOUND`, `TOOL_ACCESS_DENIED`, `TOOL_EXECUTION_FAILED`

## run_command

### Contract
- Permission class: `Execute`
- Approval behavior: Policy-guarded through the shell-execution policy toggle. If the active session is in `session-bypass`, the per-request confirmation step is skipped for this guarded tool.
- Timeout behavior: `Policy default`

### Input Schema
- `command` (required, string): Shell command executed through `sh -lc`.
- `description` (optional, string): Optional approval rationale shown to the operator.

### Output Schema
- `summary` (text): Command summary containing exit status, stdout, and stderr.

### Failure Response
- Shape: `code`, `cause`, `context`
- Common codes: `MISSING_COMMAND`, `TOOL_POLICY_BLOCKED`, `TOOL_DENIED`, `TOOL_TIMEOUT`, `TOOL_EXECUTION_FAILED`

## write_file

### Contract
- Permission class: `Write`
- Approval behavior: Policy-guarded through the workspace-write policy toggle. If the active session is in `session-bypass`, the per-request confirmation step is skipped for this guarded tool.
- Timeout behavior: `None`

### Input Schema
- `path` (required, string): Workspace-relative file path to create or replace.
- `content` (required, text): Full file contents written to the target path.
- `description` (optional, string): Optional approval rationale shown to the operator.

### Output Schema
- `summary` (text): Write summary containing the target path and byte count.

### Failure Response
- Shape: `code`, `cause`, `context`
- Common codes: `MISSING_PATH`, `TOOL_PATH_UNSAFE`, `TOOL_DENIED`, `TOOL_ACCESS_DENIED`, `TOOL_EXECUTION_FAILED`

## ask_user

### Contract
- Permission class: `Execute`
- Approval behavior: No approval prompt. The tool blocks and returns operator input as the next required step.
- Timeout behavior: `None`

### Input Schema
- `description` (required, text): Question or clarification that must be shown to the operator.

### Output Schema
- `summary` (text): Question summary returned to the active turn.

### Failure Response
- Shape: `code`, `cause`, `context`
- Common codes: `USER_INPUT_REQUIRED`
