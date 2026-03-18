---
description: Research and plan before making code changes
---

## /plan — Pre-Implementation Planning

Use this workflow before starting any non-trivial task.

### 1. Understand the request
- Re-read the user's request carefully.
- Identify which files, models, views, or services are likely involved.

// turbo
### 2. Gather context
- Use `code_search` and `grep_search` to locate relevant code.
- Read key files to understand current state.
- Check `.windsurf/context/` for any prior notes on related work.

### 3. Create a plan
- Draft a concise step-by-step plan using the `todo_list` tool.
- Each step should be a single, testable action.
- Flag any ambiguities — ask the user before assuming.

### 4. Save context
- If the task spans multiple sessions or is complex, save key findings to `.windsurf/context/` using the `create_memory` tool or by writing a short markdown file.
- Include: affected files, key decisions, open questions.

### 5. Confirm with user
- Summarize the plan in chat.
- Wait for user approval before proceeding to implementation.

**Skip this workflow only for:** typo fixes, formatting-only changes, or single-line documentation edits.
