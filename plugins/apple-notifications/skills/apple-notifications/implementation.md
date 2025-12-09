# Implementation Guide

Technical details for sending macOS desktop notifications.

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

## Recommended Implementation Pattern

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

**Recommended:**
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

**Solution 1**: Escape apostrophes with `'\"'\"'`
```bash
osascript -e 'display notification "User'\"'\"'s authentication failed" with title "Error"'
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
