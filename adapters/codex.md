# Codex Adapter

Assemble prompts in this order:

1. `shared/patterns/RUNTIME_BASE.md`
2. `shared/patterns/TOOL_POLICY.md`
3. agent `SOUL.md`
4. agent `CONTRACT.md`
5. agent `SKILL.md`
6. selected action files
7. project context files
8. live state

Return JSON only. Preserve the `decanus` commander model and never allow project-local agent overrides.
