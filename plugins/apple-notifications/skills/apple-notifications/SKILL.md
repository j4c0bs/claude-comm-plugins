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

## Quick Start

### Basic Notification
```bash
# Check platform and send notification
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "All 142 tests passed successfully" with title "Tests Complete" sound name "Glass"' 2>/dev/null || true
fi
```

### With Subtitle and Sound
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "Found vulnerability in auth module" with title "Security Issue" subtitle "High Priority" sound name "Funk"' 2>/dev/null || true
fi
```

## Workflow Overview

### Step 1: Determine If Notification Is Warranted

Before sending a notification, evaluate:
1. **Duration**: Has the task been running for >2 minutes, or will results appear much later?
2. **Significance**: Is this information important enough to warrant notification?
3. **User context**: Is the user likely away or multitasking?
4. **Redundancy**: Is this information not already visible in immediate conversation output?

If ALL criteria suggest a notification would add value, proceed to Step 2.

### Step 2: Select Notification Category

Choose the appropriate category:
- **Completion**: Long-running task finished → use "Glass" sound
- **Discovery**: Important finding or issue detected → use "Funk" sound
- **Milestone**: Progress update in multi-step process → silent
- **Attention**: User input needed, blocked on decision → use "Purr" sound
- **Error**: Critical failure occurred → use "Basso" sound

For detailed category patterns and examples, see [categories.md](categories.md).

### Step 3: Format Notification Content

- **Title** (required, ~40 char limit): Identify the event type clearly
- **Message** (required, ~200 char limit): Core information with quantifiable details
- **Subtitle** (optional, ~30 char limit): Secondary context if needed
- **Sound** (optional): Use category defaults or omit for silent

### Step 4: Execute Notification Command

**Platform check first:**
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS detected, proceed with notification
else
  # Not macOS, skip gracefully
fi
```

For implementation details, fallback patterns, and error handling, see [implementation.md](implementation.md).

## Best Practices

### Frequency Guidelines

- **Long tasks (>2 minutes)**: Send at major milestones (1-2 minute intervals) and always at completion
- **Short tasks (<2 minutes)**: Only send at completion if significant
- **Interactive tasks**: Send when blocked on user input or critical error requires attention

### Content Guidelines

**Do**:
- Lead with outcome or finding
- Include quantifiable details when available
- Keep scannable (user sees for ~3 seconds)
- Front-load important information

**Don't**:
- Include code snippets or file paths
- Use technical jargon unnecessarily
- Send duplicate notifications for same event
- Include sensitive information (passwords, tokens, keys)

### Integration with Other Communication

- Don't send notification AND voice update for same event
- If user is actively engaged, skip notification (they'll see output)
- Notifications for background awareness when user might be multitasking

## Additional Resources

- **[implementation.md](implementation.md)** - Technical implementation details, fallback patterns, error handling, character escaping
- **[categories.md](categories.md)** - Detailed breakdown of all 5 notification categories with patterns and examples
- **[examples.md](examples.md)** - 7 comprehensive real-world scenarios
- **[troubleshooting.md](troubleshooting.md)** - Platform requirements, permissions setup, common issues

## Limitations

- **No interaction capture**: Cannot detect if user clicked notification or took action
- **No confirmation**: No way to verify notification was seen
- **Do Not Disturb**: Notifications may be suppressed by user's DND settings
- **Content constraints**: No rich formatting (HTML, markdown, images)
- **Async only**: Notifications don't block execution (fire-and-forget)
- **Platform-specific**: macOS only, gracefully degrades on other platforms
