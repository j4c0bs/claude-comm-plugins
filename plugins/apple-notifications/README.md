# Apple Notifications Plugin for Claude Code

Send macOS desktop notifications for important events and milestones during Claude Code execution.

## Overview

The Apple Notifications plugin enables Claude to autonomously send desktop notifications for notable moments like task completions, important findings, and critical errors. Notifications appear in macOS Notification Center without interrupting your workflow.

## Features

- **Autonomous activation**: Claude decides when notifications add value
- **Five notification categories**: Completion, Discovery, Milestone, Attention, Error
- **Customizable sounds**: Optional audio cues based on urgency
- **Platform detection**: Gracefully handles non-macOS environments
- **Flexible implementation**: Supports both terminal-notifier and osascript

## Quick Start

The skill activates automatically when appropriate. No manual commands needed.

### Example Scenarios

Claude will send notifications for:
- **Long-running tasks**: "Build Complete - All 247 tests passed in 4m 12s"
- **Important findings**: "Security Issue - SQL injection risk found in user input handler"
- **Milestones**: "Migration Progress - Completed 5 of 12 database migrations"
- **Critical errors**: "Tests Failed - 14 errors found in test suite"
- **User attention needed**: "Input Required - Choose authentication strategy to continue"

## Setup & Requirements

### Option 1: terminal-notifier (Recommended)

Install via Homebrew for the best experience:
```bash
brew install terminal-notifier
```

**Benefits:**
- Works across all terminal clients (Terminal.app, iTerm2, VS Code)
- No permission configuration needed
- Custom app name instead of "Script Editor"

### Option 2: osascript (Built-in)

Uses macOS built-in AppleScript - no installation needed.

**Important for macOS:**

Script Editor must have notification permissions enabled. If Script Editor doesn't appear in System Settings → Notifications, you need to trigger it first:

1. Open Script Editor app
2. Create a new script with this content:
   ```applescript
   display notification "Test notification"
   ```
3. Click Run (▶️ button)
4. macOS will prompt you to allow notifications for Script Editor
5. Click "Allow"
6. Now go to System Settings → Notifications → Script Editor
7. Set to "Banners" or "Alerts"

## When Notifications Are Sent

Claude autonomously decides based on:

✅ **DO send for:**
- Long-running operations completing (>2 minutes)
- Critical errors or important findings
- Significant milestones in multi-step tasks
- Important discoveries warranting awareness

❌ **DON'T send for:**
- Routine operations or trivial updates
- Tasks completing in under 30 seconds
- User is actively engaged (they'll see output)
- Every step of a process (only key milestones)

## Disabling Notifications

### With terminal-notifier
Control via System Settings → Notifications → terminal-notifier

### With osascript
1. System Settings → Notifications → Script Editor
2. Change to "None" to disable
3. Or adjust banner style, sounds, and duration

## Implementation Details

The skill uses a fallback approach:
1. Try terminal-notifier if available (best experience)
2. Fall back to osascript if terminal-notifier not installed
3. Gracefully skip on non-macOS platforms

## Notification Categories

### Completion
- **Use for**: Long-running tasks finishing
- **Sound**: Glass (success chime)
- **Example**: "Build Complete - All 142 tests passed successfully"

### Discovery
- **Use for**: Important findings, bugs, security issues
- **Sound**: Funk (attention)
- **Example**: "Security Issue - Found vulnerability in auth module"

### Milestone
- **Use for**: Progress updates in multi-step processes
- **Sound**: None (silent)
- **Example**: "Migration Progress - Completed 5 of 15 migrations"

### Attention
- **Use for**: User input needed, blocked on decision
- **Sound**: Purr (gentle)
- **Example**: "Input Required - Cannot proceed without approval"

### Error
- **Use for**: Critical failures, test failures
- **Sound**: Basso (serious)
- **Example**: "Tests Failed - 14 errors found"

## Integration with Other Plugins

**Complements voice-updates plugin:**
- Notifications: Visual, persistent, background awareness
- Voice: Audio, immediate attention, explicit requests

Claude won't send both for the same event - it chooses the most appropriate method.

## Troubleshooting

### No notifications appearing with osascript

**Cause**: Script Editor notifications not enabled or Script Editor not in notification settings.

**Solution**:
1. Open Script Editor app
2. Run this script to trigger the system prompt:
   ```applescript
   display notification "Test notification"
   ```
3. Allow notifications when prompted
4. Go to System Settings → Notifications → Script Editor
5. Set to "Banners" or "Alerts"

### Notifications not working with terminal-notifier

**Check installation**:
```bash
command -v terminal-notifier || echo "Not installed"
```

**Install if needed**:
```bash
brew install terminal-notifier
```

### Do Not Disturb mode suppressing notifications

Check if Focus mode is enabled. Notifications will be queued but not displayed during Focus.

## Plugin Components

### Skill: `apple-notifications`

Auto-activates when Claude needs to inform you of important events. Contains comprehensive instructions for:
- When to send notifications (activation criteria)
- Implementation methods (terminal-notifier vs osascript)
- Five notification categories with examples
- Platform detection and error handling
- Character escaping and message formatting
- Script Editor permission setup

## Platform Compatibility

- **macOS**: Fully supported
- **Linux/Windows**: Gracefully skipped (no errors)

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test on macOS
4. Submit pull request with clear description

## License

MIT

## Support

- **Issues**: Report bugs at repository issue tracker
- **Documentation**: See `skills/apple-notifications/SKILL.md`

---

**Version**: 1.0.0
**Author**: Jeremy Jacobs
**Keywords**: notifications, macos, alerts, desktop, productivity
