# Troubleshooting & Setup

Platform requirements, permissions, and common issues.

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

## Setting Up Permissions

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

## Common Issues

### Notifications not appearing
1. **Check platform**: Ensure you're on macOS (`$OSTYPE` = `darwin*`)
2. **Check permissions**: For osascript, verify Script Editor is in System Settings → Notifications
3. **Check Do Not Disturb**: Notifications may be suppressed by Focus mode
4. **Test manually**: Run a simple notification command to isolate the issue

### "Script Editor" shows instead of app name
- This is expected when using osascript
- For custom app names, use terminal-notifier instead

### Apostrophes breaking commands
- Use double quotes for the outer command (see [implementation.md](implementation.md) for escaping details)

### Notifications truncated
- Respect character limits (Title: ~40, Message: ~200, Subtitle: ~30)
- Front-load important information

## User Control

Users can control notifications through:
- **System Settings → Notifications**: Enable/disable per app
- **Focus modes**: Schedule Do Not Disturb times
- **Notification style**: Choose between Banners (temporary) or Alerts (require action)
- **Sound preferences**: Adjust volume or disable sounds

These preferences should be respected by the implementation.
