---
description: Save or update working context for session continuity
---

## /context — Save Working Context

Use this workflow to persist important task context across sessions.

### 1. Determine what to save
- Current task status and progress.
- Key decisions made during this session.
- Files changed and why.
- Open questions or known issues.
- Anything that would be lost between sessions.

### 2. Write context file
- Save to `.windsurf/context/` as a markdown file.
- Naming convention: `YYYY-MM-DD-<short-description>.md` (e.g., `2026-03-18-healthkit-history.md`).
- Keep it concise — bullet points, not paragraphs.
- Include: task description, files touched, current status, next steps.

### 3. Clean up stale context
- Check `.windsurf/context/` for old files that are no longer relevant.
- Delete or archive anything that's fully resolved.

### 4. Also use memories
- For preferences and patterns that apply across sessions, use the `create_memory` tool.
- Context files are for task-specific state; memories are for persistent knowledge.

### Template

```markdown
# <Task Title>
**Date:** YYYY-MM-DD
**Status:** in-progress | completed | blocked

## What was done
- ...

## Files changed
- `path/to/file.swift` — description

## Open questions
- ...

## Next steps
- ...
```
