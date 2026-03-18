---
description: Post-implementation review and verification
---

## /review — Post-Implementation Review

Run this workflow after completing any implementation to verify quality.

// turbo
### 1. Build check
- Run: `xcodebuild -project BaseStat.xcodeproj -scheme BaseStat -destination 'generic/platform=iOS Simulator' 2>&1 | grep -E "error:|warning:|BUILD"`
- Fix any errors before proceeding. Warnings are acceptable if cosmetic (e.g., SwiftLint line length).

// turbo
### 2. Lint check
- Scan build output for SwiftLint warnings.
- Fix any non-cosmetic warnings (e.g., force unwraps, unused variables).
- Cosmetic warnings (file length, line length) can be noted but skipped.

### 3. Diff summary
- Summarize all files changed, with a one-line description per file.
- Note any files that were created vs modified.

### 4. Test the change
- If the change is UI-related, note what the user should visually verify.
- If the change is logic-related, describe how to trigger and verify the behavior.
- Suggest any edge cases the user should test.

### 5. Update context
- Update `.windsurf/context/` if this task produced knowledge useful for future sessions.
- Mark completed items in `todo_list`.

### 6. Report to user
- Provide a concise summary: what was done, what to verify, any known limitations.
