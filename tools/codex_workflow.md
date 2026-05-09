# Codex Workflow Helper

This repository-local helper records prompts, Codex response summaries, and
eventual git commits in human-readable markdown files. It does not inspect,
wrap, or restart an interactive Codex session.

Run commands from anywhere inside the repo; the script writes files in the
repo root.

## Files

- `PROMPT_latest.md`: the most recently recorded prompt.
- `RESPONSE_latest.md`: the most recently recorded response summary.
- `PROMPTS_used.md`: append-style history of prompts, response summaries, and
  commit metadata.

These files are intentionally plain markdown so they can be edited by hand.

## Typical Two-Terminal Workflow

After sending a prompt to Codex, save the same prompt from your shell:

```sh
pbpaste | python3 tools/codex_workflow.py prompt
```

You can also pipe text from a file:

```sh
python3 tools/codex_workflow.py prompt --file my_prompt.md
```

After Codex finishes, save your summary of the response:

```sh
pbpaste | python3 tools/codex_workflow.py response
```

or:

```sh
python3 tools/codex_workflow.py response --file response_summary.md
```

After committing, record the latest commit hash and subject:

```sh
python3 tools/codex_workflow.py commit
```

Run the `prompt`, `response`, and `commit` commands sequentially for one entry.
They update the same markdown log and do not implement file locking.

By default, `response` and `commit` update the entry identified by
`PROMPT_latest.md`. To update an older entry, pass its entry id:

```sh
python3 tools/codex_workflow.py response --entry 20260425T183012Z --file response.md
python3 tools/codex_workflow.py commit --entry 20260425T183012Z
```

If needed, commit metadata can be supplied manually:

```sh
python3 tools/codex_workflow.py commit \
  --hash 0123456789abcdef0123456789abcdef01234567 \
  --subject "Document panel plotting workflow"
```

## Expected Log Entry Format

```md
## 2026-04-25T18:30:12+00:00 — `20260425T183012Z`

<!-- codex-workflow-entry: 20260425T183012Z -->

### Prompt

User prompt text goes here.

### Response Summary

<!-- codex-workflow-response-start: 20260425T183012Z -->
Codex response summary goes here.
<!-- codex-workflow-response-end: 20260425T183012Z -->

### Commit

<!-- codex-workflow-commit-start: 20260425T183012Z -->
- Recorded: `2026-04-25T18:45:00+00:00`
- Hash: `0123456789abcdef0123456789abcdef01234567`
- Subject: Document panel plotting workflow
<!-- codex-workflow-commit-end: 20260425T183012Z -->
```

The HTML comments are stable markers used by the script when updating the
matching response and commit sections.
