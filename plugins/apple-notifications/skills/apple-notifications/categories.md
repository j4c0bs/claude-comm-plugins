# Notification Categories

Detailed reference for choosing and formatting notification categories.

## Category Selection

Choose the appropriate category based on the event type:

| Category | Use When | Default Sound |
|----------|----------|---------------|
| **Completion** | Long-running task finished | Glass |
| **Discovery** | Important finding, bug, or issue detected | Funk |
| **Milestone** | Progress update in multi-step process | none |
| **Attention** | User input needed, blocked on decision | Purr |
| **Error** | Critical failure or error occurred | Basso |

## 1. Completion

**Use for**: Long-running operations finishing (builds, test suites, deployments, large refactors)

**Title patterns**:
- "Build Complete"
- "Tests Complete"
- "Deployment Complete"
- "Task Complete"

**Message patterns**:
- Include duration and results
- "Built 247 files in 2m 34s"
- "All 142 tests passed successfully"
- "Deployment successful in 3m 12s"

**Sound**: Glass (success chime) or none

**Example**:
```bash
osascript -e 'display notification "All 142 tests passed successfully" with title "Tests Complete" sound name "Glass"'
```

## 2. Discovery

**Use for**: Important findings, bugs, security issues, insights discovered

**Title patterns**:
- "Important Finding"
- "Security Issue"
- "Bug Detected"
- "Issue Found"

**Message patterns**:
- Describe what was found
- Include location/context
- "Found security vulnerability in auth module"
- "Memory leak detected in background worker"
- "Deprecated API usage in 12 components"

**Sound**: Funk (attention) or none

**Example**:
```bash
osascript -e 'display notification "Found security vulnerability in auth module" with title "Security Issue" sound name "Funk"'
```

## 3. Milestone

**Use for**: Progress updates in multi-step processes (migrations, batch operations, refactoring)

**Title patterns**:
- "Progress Update"
- "Migration Progress"
- "Refactor Progress"

**Message patterns**:
- Show completed/total
- "Completed 5 of 12 database migrations"
- "Refactored 23 of 47 components"
- "Processed 1,847 of 3,200 records"

**Sound**: none (silent to avoid notification fatigue)

**Example**:
```bash
osascript -e 'display notification "Completed 5 of 12 database migrations" with title "Migration Progress"'
```

## 4. Attention

**Use for**: User input needed, blocked on decision, approval required

**Title patterns**:
- "Attention Needed"
- "Input Required"
- "Decision Required"
- "Approval Needed"

**Message patterns**:
- Explain what's needed
- "Cannot proceed without schema approval"
- "Multiple merge conflict strategies available"
- "Choose authentication method to continue"

**Sound**: Purr (gentle but noticeable) or none

**Example**:
```bash
osascript -e 'display notification "Cannot proceed without schema approval" with title "Input Required" sound name "Purr"'
```

## 5. Error

**Use for**: Critical failures, test failures, build errors

**Title patterns**:
- "Error Detected"
- "Tests Failed"
- "Build Failed"
- "Critical Error"

**Message patterns**:
- Summarize the error
- Include count if multiple
- "Test suite failed: 14 errors found"
- "Build failed: compilation errors in auth module"
- "Database connection failed after 3 retries"

**Sound**: Basso (serious tone) or none

**Example**:
```bash
osascript -e 'display notification "Test suite failed: 14 errors found" with title "Tests Failed" sound name "Basso"'
```

## Content Formatting

**Title** (required, ~40 char limit):
- Identify the event type clearly
- Keep concise and scannable
- Examples: "Build Complete", "Security Issue", "Tests Failed"

**Message** (required, ~200 char limit):
- Core information user needs
- Include quantifiable details when relevant
- Keep scannable and actionable
- Examples: "All 142 tests passed successfully", "Found vulnerability in auth module"

**Subtitle** (optional, ~30 char limit):
- Secondary context if needed
- Repository name, task name, or categorization
- Examples: "backend-api repository", "Authentication refactor"

**Sound** (optional):
- Use category defaults or omit for silent notification
- Available sounds: Glass, Funk, Purr, Basso, Sosumi
- Consider urgency and time of day
