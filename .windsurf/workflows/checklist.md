---
description: Mandatory workflow checklist before making any code changes
---

## /checklist — Mandatory Workflow Checklist

Complete this checklist before making ANY code changes. If any box is unchecked and it's not an emergency override, **stop and follow the workflow**.

### Phase 1: Planning ✋
- [ ] Understood the user's request fully (re-read it).
- [ ] Searched the codebase for relevant files and context.
- [ ] Created a step-by-step plan using `todo_list`.
- [ ] Checked `.windsurf/context/` for prior notes on related work.

### Phase 2: Documentation 📝
- [ ] Key findings from code search are noted.
- [ ] All files that need changes are identified.
- [ ] Approach is clear — no guessing.

### Phase 3: Implementation 🔧
- [ ] Implementing exactly what was planned.
- [ ] Minimal changes outside plan scope.
- [ ] Updating context files as needed.
- [ ] Each edit is tested (build check after significant changes).

### Phase 4: Review ✅
- [ ] Build succeeds with no errors.
- [ ] All planned changes are complete.
- [ ] Context files updated with results.
- [ ] User given a clear summary.

### Emergency Override ⚠️
Only skip the full workflow for:
- Typo fixes (1-2 characters)
- Missing punctuation
- Formatting-only changes
- Documentation-only updates

### Workflow Violation Recovery
If you catch yourself violating the workflow:
1. **STOP** immediately.
2. Save current progress to `.windsurf/context/`.
3. Create a proper plan with `todo_list`.
4. Resume with proper workflow.
