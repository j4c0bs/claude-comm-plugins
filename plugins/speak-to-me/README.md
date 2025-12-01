# Speak-to-Me Plugin for Claude Code

Give Claude a voice! This plugin uses macOS's `say` command to enable proactive voice communication during work.

## Overview

Claude Code is powerful, but sometimes you're focused on other tasks while Claude works through complex operations. The Speak-to-Me plugin empowers Claude to communicate with you via voice during work - providing progress updates, sharing important findings, or requesting attention - all without stopping execution.

## Features

- **Proactive voice communication**: Claude can speak to you during work without blocking
- **Intelligent voice selection**: Respects your preferences while adapting to context
- **Notable moments only**: Reserved for meaningful updates, not routine operations
- **Natural language**: Short, conversational messages designed to be spoken
- **Non-blocking**: Runs in background, complements written output
- **Platform-aware**: macOS only, gracefully degrades on other platforms

## Quick Start

### Installation

```bash
# Install from marketplace
claude plugin install speak-to-me@claude-comm-plugins

# Or add locally
claude plugin add /path/to/claude-comm-plugins/plugins/speak-to-me
```

### Using the Plugin

Simply ask Claude to use voice during work:

```
"Keep me updated on progress with voice"
"Use voice to notify me when you find something"
"Speak to me about what you're working on"
```

The voice-updates skill will activate autonomously and Claude will provide voice updates at notable moments.

## How It Works

### Voice Selection Flow

Claude determines which voice to use following this priority:

1. **Chat context**: If you explicitly request a specific voice ("use Samantha voice"), Claude uses it
2. **CLAUDE.md preference**: Claude checks your project's CLAUDE.md for voice preferences
3. **Context-based selection**: Claude selects appropriate voice based on message context

### Context-Based Voices

When no preference specified, Claude chooses voices contextually:

| Context            | Default Voice | When Used                              |
| ------------------ | ------------- | -------------------------------------- |
| Progress updates   | Samantha      | Routine status, milestones, completion |
| Important findings | Fred          | Discoveries, bugs, errors, warnings    |
| Attention requests | Albert        | Needs input, blocked on decision       |

## Voice Preferences

### Setting Your Preferred Voice

Add voice preferences to your project's `CLAUDE.md`:

```markdown
## Voice Settings
Preferred voice: Samantha
```

Or simply:
```markdown
voice: Samantha
```

Claude will use your preferred voice for all updates when specified.

### Requesting Specific Voice in Chat

You can request a specific voice during the conversation:

```
"Use Fred voice for updates"
"Keep me updated with Samantha voice"
```

## Content Guidelines

Voice updates are reserved for **notable moments only**:

### ✅ Claude WILL use voice for:
- Progress milestones during long tasks
- Important findings or insights
- Requesting your attention without blocking
- Critical warnings or errors

### ❌ Claude will NOT use voice for:
- Every tool call or routine operation
- Reading code or file paths
- Lists of items
- Minor status updates

### Message Format

All voice messages are:
- **Short**: Under 20-30 words (5-10 seconds)
- **Natural**: Conversational language
- **Clear**: Simple, direct communication
- **Vocalizable**: No lists, code, or special characters

## Available Voices

### Recommended Voices

Claude prefers these realistic, natural-sounding voices:

- **Samantha** - Friendly, natural (excellent default)
- **Fred** - Deep, authoritative (good for important updates)
- **Albert** - Distinguished, clear (good for attention requests)
- **Ralph** - Mature, professional
- **Kathy** - Warm, approachable
- **Eddy, Flo, Reed, Rocko, Sandy, Shelley** - Clear, natural voices

### Novelty Voices

Claude avoids novelty voices (Good News, Bells, Whisper, etc.) unless you explicitly request them, as they can be distracting or unclear.

### Checking Available Voices

To see all available voices on your system:

```bash
say -v "?" | grep en_US
```

## Platform Requirements

This plugin requires **macOS** (darwin). The `say` command is macOS-specific.

On non-macOS platforms:
- Plugin installs but skill remains inactive
- No errors or warnings
- Work continues normally without voice

## Use Cases

### Long-Running Tasks

Perfect for builds, test suites, or refactoring sessions where you're multitasking:

```
User: "Run the full test suite and keep me updated with voice"

Claude: [Voice: "Starting test suite"]
        [Works silently for 2 minutes]
        [Voice: "Halfway through. 47 tests passed so far"]
        [Works silently for 2 more minutes]
        [Voice: "Test suite complete. All 94 tests passed"]
```

### Important Discoveries

Get notified immediately when Claude finds something critical:

```
User: "Debug the authentication issue and use voice to tell me what you find"

Claude: [Investigates silently]
        [Voice: "Found the bug. Session tokens are expiring too early"]
        [Continues fix]
```

### Requesting Attention

Claude can ask for your input without stopping work:

```
User: "Refactor the database schema with voice updates"

Claude: [Works on refactoring]
        [Voice: "I need your input on the user table design"]
        [Continues other work while waiting]
```

## Best Practices

### Frequency

- **Long tasks**: Updates every 1-2 minutes or at milestones
- **Medium tasks**: Start, middle, completion
- **Short tasks**: Only critical findings or completion

### Timing

Voice updates work best for:
- Tasks that take more than 2-3 minutes
- Complex investigations with uncertain outcomes
- Operations where you're multitasking
- Situations where you need ambient awareness

### User Experience

Voice complements written output - you get:
- Real-time audio updates while working elsewhere
- Complete written output in chat for reference
- Ability to multitask while Claude works
- Immediate awareness of important findings

## Examples

### Example 1: Build Process

```
User: "Build the project and keep me updated with voice"

Claude: [Voice: "Starting the build"]
        ... runs build ...
        [Voice: "Build completed successfully"]
```

### Example 2: Code Refactoring

```
User: "Refactor the authentication module with voice updates"

Claude: [Voice: "Starting authentication refactoring"]
        ... works for 1 minute ...
        [Voice: "Halfway through. Moving session logic to new module"]
        ... works for 1 more minute ...
        [Voice: "Found a security issue in token validation"]
        ... fixes issue ...
        [Voice: "Refactoring complete. All tests passing"]
```

### Example 3: Custom Voice

```
User: "Debug the API endpoints and use Fred voice to update me"

Claude: [Uses Fred voice throughout]
        [Voice: "Starting endpoint debugging"]
        [Voice: "Found CORS configuration error"]
        [Voice: "Fix applied. All endpoints working"]
```

## Troubleshooting

### Voice Not Working

1. **Verify macOS**: Run `uname -s` - should output "Darwin"
2. **Test say command**: Run `say "test"` - should hear audio
3. **Check volume**: Ensure system volume is not muted
4. **Verify plugin**: Run `/plugin list` to confirm installation

### Wrong Voice Used

1. **Check CLAUDE.md**: Verify voice preference format
2. **Explicit request**: Request specific voice in chat
3. **Voice availability**: Run `say -v "?" | grep en_US` to list voices

### Too Many/Few Updates

Claude automatically adjusts frequency based on:
- Task duration
- Notable moments
- User context

If frequency doesn't match your preference, provide feedback:
- "Use voice less frequently"
- "Give me more frequent voice updates"

### Voice Cuts Off

Ensure messages are under 100 words. Claude automatically enforces this limit for optimal voice delivery.

## Technical Details

### Implementation

- **Command**: `say -v "VoiceName" "message"`
- **Execution**: Background process (`&` flag)
- **Error handling**: Graceful degradation (`2>/dev/null`)
- **Blocking**: Never blocks Claude's execution
- **Integration**: Works during thinking and tool use

### Performance

- **No overhead**: Voice runs in separate process
- **Non-blocking**: Claude continues work immediately
- **Fast feedback**: ~200ms from trigger to audio start
- **Resource usage**: Minimal (macOS system service)

## Contributing

Contributions welcome! Areas for enhancement:

- Additional platform support (Windows SAPI, Linux espeak)
- Voice personality configurations
- Volume/rate control
- Multi-language voice support

## License

MIT

## Support

- **Issues**: Report bugs at repository issue tracker
- **Documentation**: See `skills/voice-updates/SKILL.md` for technical details
- **Questions**: Open a discussion in the repository

---

**Version**: 1.0.0
**Author**: Jeremy Jacobs
**Keywords**: voice, audio, notifications, macos, accessibility
**Platform**: macOS (darwin)
