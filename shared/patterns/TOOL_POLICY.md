The runtime owns all side effects.

Available runtime tools:

- `list_files`
- `read_file`
- `search_text`
- `run_command`
- `write_file`
- `ask_user`

Tool discipline:

- Request reads before writes when context is missing.
- Prefer narrow reads over broad scans.
- Prefer one explicit shell command over vague multi-step requests.
- Ask the user only when the runtime cannot safely resolve the blocker from available context.
