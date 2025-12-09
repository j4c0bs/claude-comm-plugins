---
name: apple-notifications
description: Send macOS desktop notifications to inform users of important events, milestones, or status updates without interrupting workflow
---

# Apple Notifications

Send macOS desktop notifications to inform users of important events without interrupting their workflow. Use this skill to surface critical information, completion status, or findings that warrant user awareness but don't require immediate interaction. Notifications appear in the macOS Notification Center and can optionally include sound cues.

## When to Activate

ONLY send notifications for notable moments:

✅ **DO use notifications for**:
- Long-running operations completing (builds, tests, deployments taking >2 minutes)
- Critical errors or important findings discovered during execution
- Significant milestones reached in multi-step tasks
- Important discoveries that warrant user awareness
- User is away or might be multitasking and needs awareness of completion

❌ **DO NOT use notifications for**:
- Routine operations or trivial updates
- Reading files, searching code, or exploratory tasks
- Tasks completing in under 30 seconds
- User is actively engaged in conversation with immediate responses
- Every step of a process (only key milestones)
- Information already visible in conversation output

## Workflow

### Step 1: Determine If Notification Is Warranted

Before sending a notification, evaluate:
1. **Duration**: Has the task been running for >2 minutes, or will results appear much later?
2. **Significance**: Is this information important enough to warrant notification?
3. **User context**: Is the user likely away or multitasking?
4. **Redundancy**: Is this information not already visible in immediate conversation output?

If ALL criteria suggest a notification would add value, proceed to Step 2.

### Step 2: Select Notification Category

Choose the appropriate category based on the event type:

| Category | Use When | Default Sound |
|----------|----------|---------------|
| **Completion** | Long-running task finished | Glass |
| **Discovery** | Important finding, bug, or issue detected | Funk |
| **Milestone** | Progress update in multi-step process | none |
| **Attention** | User input needed, blocked on decision | Purr |
| **Error** | Critical failure or error occurred | Basso |

### Step 3: Format Notification Content

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

### Step 4: Execute Notification Command

**Platform check first**:
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS detected, proceed with notification
else
  # Not macOS, skip gracefully
fi
```

**Execute notification** (see Implementation Methods section below for recommended approach)

## Implementation Methods

There are two approaches for sending notifications. Use terminal-notifier if available, otherwise fall back to osascript.

### Method 1: terminal-notifier (Recommended)

**Pros:**
- More reliable across all terminal clients (Terminal.app, iTerm2, VS Code)
- Shows custom app name instead of "Script Editor"
- No permission configuration needed
- Better notification management

**Cons:**
- Requires installation via Homebrew: `brew install terminal-notifier`
- Not built into macOS

**Basic syntax:**
```bash
terminal-notifier -title "TITLE" -message "MESSAGE"
```

**With sound:**
```bash
terminal-notifier -title "TITLE" -message "MESSAGE" -sound default
```

**With subtitle:**
```bash
terminal-notifier -title "TITLE" -subtitle "SUBTITLE" -message "MESSAGE"
```

### Method 2: osascript (Built-in Fallback)

**Pros:**
- Built into macOS, no installation needed
- Works on all macOS versions

**Cons:**
- Shows as "Script Editor" in notifications
- Requires Script Editor to have notification permissions enabled
- User must enable: System Settings → Notifications → Script Editor → set to "Banners" or "Alerts"

**Basic syntax:**
```bash
osascript -e 'display notification "MESSAGE" with title "TITLE"'
```

### Recommended Implementation Pattern

Use this fallback approach for maximum compatibility:

```bash
send_notification() {
    local title="$1"
    local message="$2"
    local sound="${3:-}"  # Optional sound parameter

    # Check for macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        return 0  # Skip gracefully on non-macOS
    fi

    # Try terminal-notifier first (if available)
    if command -v terminal-notifier &> /dev/null; then
        if [ -n "$sound" ]; then
            terminal-notifier -title "$title" -message "$message" -sound "$sound" 2>/dev/null
        else
            terminal-notifier -title "$title" -message "$message" 2>/dev/null
        fi
        return $?
    fi

    # Fallback to osascript (built-in)
    if [ -n "$sound" ]; then
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null || true
    else
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    fi
}

# Usage examples:
send_notification "Build Complete" "All 142 tests passed successfully" "Glass"
send_notification "Progress Update" "Completed 5 of 12 migrations"
```

## Notification Categories

### 1. Completion

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

### 2. Discovery

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

### 3. Milestone

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

### 4. Attention

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

### 5. Error

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

## Command Syntax

### Basic Notification (Title + Message)
```bash
osascript -e 'display notification "MESSAGE" with title "TITLE"'
```

### With Subtitle
```bash
osascript -e 'display notification "MESSAGE" with title "TITLE" subtitle "SUBTITLE"'
```

### With Sound
```bash
osascript -e 'display notification "MESSAGE" with title "TITLE" sound name "SOUND_NAME"'
```

### Full Featured (All Parameters)
```bash
osascript -e 'display notification "MESSAGE" with title "TITLE" subtitle "SUBTITLE" sound name "SOUND_NAME"'
```

### Available Sounds

**Recommended**:
- `Glass` - Success, completion (pleasant chime)
- `Funk` - Discovery, attention needed (distinctive)
- `Purr` - Gentle attention (soft, non-intrusive)
- `Basso` - Error, warning (deeper, serious tone)
- `Sosumi` - General notification (classic Mac sound)

**Available but use sparingly**: Blow, Bottle, Frog, Hero, Morse, Ping, Pop, Submarine, Tink

## Error Handling

### Platform Detection

Always check for macOS before attempting notification:

```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "MESSAGE" with title "TITLE"' 2>/dev/null || true
fi
```

### Graceful Degradation

Suppress errors to prevent notification failures from breaking workflow:

```bash
osascript -e 'display notification "MESSAGE" with title "TITLE"' 2>/dev/null || true
```

The `2>/dev/null` redirects errors, and `|| true` ensures the command always returns success.

### Character Escaping

Single quotes in messages require special escaping for AppleScript:

**Problem**: Messages containing apostrophes break the command
```bash
# This BREAKS:
osascript -e 'display notification "User's authentication failed" with title "Error"'
```

**Solution 1**: Escape apostrophes with `'"'"'`
```bash
osascript -e 'display notification "User'"'"'s authentication failed" with title "Error"'
```

**Solution 2**: Use double quotes for the outer command (preferred)
```bash
osascript -e "display notification \"User's authentication failed\" with title \"Error\""
```

### Message Length Limits

macOS imposes practical limits on notification text:
- **Title**: ~40 characters (truncated with "..." if longer)
- **Message**: ~200 characters (truncated if longer)
- **Subtitle**: ~30 characters (truncated if longer)

Keep messages concise and front-load important information.

## Best Practices

### Frequency Guidelines

**Long tasks (>2 minutes)**:
- Send notification at start (optional)
- Send at major milestones (1-2 minute intervals)
- Always send at completion

**Short tasks (<2 minutes)**:
- Only send at completion if significant
- Skip notifications for routine operations

**Interactive tasks**:
- Send when blocked on user input
- Send when critical error requires attention

### Content Guidelines

**Do**:
- Lead with outcome or finding
- Include quantifiable details when available
- Keep scannable (user sees for ~3 seconds)
- Use clear, non-technical language when possible
- Front-load important information

**Don't**:
- Include code snippets or file paths
- Use technical jargon unnecessarily
- Send duplicate notifications for same event
- Include sensitive information (passwords, tokens, keys)
- Create notification spam with frequent updates

### Integration with Other Communication

**Complement, don't duplicate**:
- Don't send notification AND voice update for same event
- Choose based on user preference and context
- Notifications for background awareness
- Voice for active communication when explicitly requested

**Check for voice-updates skill**:
- If user requested voice updates, use voice instead of notifications
- If user is actively engaged, skip notification (they'll see output)

## Examples

### Example 1: Test Suite Completion

**Scenario**: Running comprehensive test suite that takes 4 minutes

```bash
# After tests complete
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "All 247 tests passed in 4m 12s" with title "Tests Complete" sound name "Glass"' 2>/dev/null || true
fi
```

### Example 2: Security Vulnerability Found

**Scenario**: Analyzing codebase and discovering security issue

```bash
# After finding vulnerability
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "SQL injection risk in user input handler" with title "Security Issue" subtitle "High Priority" sound name "Funk"' 2>/dev/null || true
fi
```

### Example 3: Migration Progress

**Scenario**: Running 15 database migrations, notify at milestones

```bash
# After completing 5 of 15 migrations
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "Completed 5 of 15 database migrations" with title "Migration Progress"' 2>/dev/null || true
fi
```

### Example 4: Build Failure

**Scenario**: Build fails with compilation errors

```bash
# After build fails
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "23 TypeScript compilation errors found" with title "Build Failed" sound name "Basso"' 2>/dev/null || true
fi
```

### Example 5: User Input Required

**Scenario**: Multiple valid approaches, need user to decide

```bash
# When blocked on user decision
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "Choose authentication strategy to continue" with title "Input Required" sound name "Purr"' 2>/dev/null || true
fi
```

### Example 6: Character Escaping

**Scenario**: Message contains apostrophes

```bash
# Handle apostrophes properly
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e "display notification \"User's session token expired\" with title \"Authentication Error\"" 2>/dev/null || true
fi
```

### Example 7: Long-Running Deployment

**Scenario**: Deployment taking 8 minutes, notify at milestones

```bash
# Milestone 1: Build phase complete (2 minutes)
osascript -e 'display notification "Build phase complete, starting deployment" with title "Deployment Progress"' 2>/dev/null || true

# Milestone 2: Database migrations complete (5 minutes)
osascript -e 'display notification "Database migrations complete" with title "Deployment Progress"' 2>/dev/null || true

# Final: Deployment complete (8 minutes)
osascript -e 'display notification "Deployment successful in 8m 24s" with title "Deployment Complete" sound name "Glass"' 2>/dev/null || true
```

## Platform Requirements

### Option 1: terminal-notifier (Recommended)
- **Operating System**: macOS (Darwin kernel)
- **Installation**: `brew install terminal-notifier`
- **Permissions**: No additional configuration needed

### Option 2: osascript (Built-in Fallback)
- **Operating System**: macOS (Darwin kernel)
- **Command**: `osascript` (built into macOS, no installation needed)
- **Permissions**: Script Editor must have notification permissions enabled

**Non-macOS platforms**: Commands will fail gracefully when wrapped with platform detection and error suppression.

## User Control & Troubleshooting

### For terminal-notifier
No configuration needed - notifications work out of the box.

### For osascript (Important for macOS)

**If Script Editor doesn't appear in System Settings → Notifications:**

You need to trigger the notification permission prompt first:
1. Open **Script Editor** app (in Applications/Utilities)
2. Create a new script with this line:
   ```applescript
   display notification "Test notification"
   ```
3. Click the **Run** button (▶️)
4. macOS will prompt you to allow notifications
5. Click **"Allow"**

**Now enable Script Editor notifications:**
1. Open System Settings → Notifications
2. Scroll down and find **"Script Editor"** in the app list
3. Change notification style from "None" to **"Banners"** or **"Alerts"**
4. Ensure "Allow Notifications" is enabled

**Why this is needed:**
- `osascript` notifications come from Script Editor, not Terminal
- Script Editor won't appear in settings until first use
- Terminal itself does not appear in the Notifications list

**Additional settings:**
- Configure Do Not Disturb / Focus mode schedule
- Adjust notification sound preferences
- Set banner display duration

**Important**: Respect user's macOS notification settings. Do not attempt to override or bypass system preferences.

## Limitations

- **No interaction capture**: Cannot detect if user clicked notification or took action
- **No confirmation**: No way to verify notification was seen
- **Do Not Disturb**: Notifications may be suppressed by user's DND settings
- **Content constraints**: No rich formatting (HTML, markdown, images)
- **Async only**: Notifications don't block execution (fire-and-forget)
- **Platform-specific**: macOS only, gracefully degrades on other platforms
