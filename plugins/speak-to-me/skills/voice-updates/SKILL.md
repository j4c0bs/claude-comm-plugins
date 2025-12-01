---
name: voice-updates
description: Provide voice updates during tasks when users explicitly request progress notifications or voice communication
---

# Voice Updates Skill

Use macOS `say` command to communicate with users via voice during work. This enables proactive communication without stopping execution.

## When to Activate

ONLY activate when users explicitly request voice updates with phrases like:
- "Keep me updated on progress with voice"
- "Use voice to notify me when you find something"
- "Speak to me about what you're working on"
- "Give me voice updates while you work"

## Use Cases

Voice updates are reserved for **notable moments only**:

✅ **DO use voice for**:
- Progress milestones during long-running tasks ("Build completed successfully")
- Important findings or insights ("Found the authentication bug in the login module")
- Requesting user attention without blocking ("I need your input on the schema")
- Critical warnings or errors that need awareness

❌ **DO NOT use voice for**:
- Every tool call or routine operation
- Reading code, file paths, or technical output
- Lists of items or structured data
- Minor or trivial status updates

## Voice Selection Strategy

### Priority Order

1. **Check chat context**: If user explicitly requested a specific voice in the conversation, use it
2. **Check CLAUDE.md**: Read project's CLAUDE.md and search for voice preference
3. **Use context-based defaults**: Select appropriate voice based on message context

### Finding Voice Preference in CLAUDE.md

Users may specify their preferred voice in CLAUDE.md using various formats:

```markdown
## Voice Settings
Preferred voice: Samantha
```

Or simply:
```markdown
voice: Samantha
```

Or any natural format mentioning voice preference. Search CLAUDE.md for patterns like:
- "voice: [name]"
- "Preferred voice: [name]"
- "Use [name] voice"

### Context-Based Voice Selection

When no user preference is found, select voice based on message context:

| Context   | Voice    | Character            | Use For                              |
| --------- | -------- | -------------------- | ------------------------------------ |
| Progress  | Samantha | Friendly, natural    | Routine progress updates             |
| Emphasis  | Fred     | Deep, authoritative  | Important findings, errors, warnings |
| Attention | Albert   | Distinguished, clear | Requesting user input or attention   |

**How to determine context**:
- **Progress**: Milestone updates, status reports, completion notices
- **Emphasis**: Discoveries, bugs found, errors, critical information
- **Attention**: Questions for user, blocked on decision, need input

### Available Voices

**Recommended realistic voices** (prefer these):
- **Samantha** - Friendly, natural (excellent default)
- **Fred** - Deep, authoritative (good for emphasis)
- **Albert** - Distinguished, clear (good for attention)
- **Ralph** - Mature, professional
- **Kathy** - Warm, approachable
- **Eddy** - Natural, modern
- **Flo** - Clear, professional
- **Reed** - Neutral, informative
- **Rocko** - Dynamic, engaging
- **Sandy** - Friendly, conversational
- **Shelley** - Professional, clear

**Avoid novelty voices** (unless user explicitly requests):
- Good News, Bad News, Whisper, Bells, Boing, Bubbles, Bahh, Cellos, Jester, Organ, Trinoids, Zarvox

## Content Guidelines

### Message Requirements

Voice messages must be:
1. **Short**: Under 20-30 words (5-10 seconds of speech)
2. **Natural**: Conversational language that sounds good spoken
3. **Clear**: Simple, direct communication
4. **Vocalizable**: No lists, code blocks, or special characters

### Content Validation

Before using voice, verify:
- [ ] Message is under 30 words
- [ ] Content is naturally spoken language
- [ ] No lists, bullet points, or code blocks
- [ ] No file paths or technical syntax
- [ ] This is a notable moment worth vocalizing
- [ ] Message adds value without disrupting flow

### Valid Examples

✅ **Good voice messages**:
- "Build completed successfully. All tests passed."
- "I found the authentication bug in the login module."
- "Working through the test suite. About halfway done."
- "I need your input on the database schema before continuing."
- "Warning: deployment script has a critical error."
- "Refactoring complete. Ready for your review."

❌ **Bad voice messages**:
- "Found files: config.json, package.json, tsconfig.json" *(list)*
- "Error on line 42: TypeError: Cannot read property" *(too technical)*
- "Installing dependencies with npm install" *(too routine)*
- "Searching files... Found match... Opening file... Reading" *(too verbose)*
- Reading code snippets or file contents *(not vocalizable)*

## Implementation Workflow

### Step 1: Determine Voice Selection

If the voice is not explicitly defined, search for it in CLAUDE.md.

```bash
# 1. Check if user specified voice in current chat context
# 2. If not specified in chat, read CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    # Search for voice preference patterns:
    # - "voice: VoiceName"
    # - "Preferred voice: VoiceName"
    # - "Use VoiceName voice"
    # Extract voice name if found
fi

# 3. If no preference found, determine context
if [[ message contains discovery/error/warning ]]; then
    CONTEXT="emphasis"
    DEFAULT_VOICE="Fred"
elif [[ message requests user input ]]; then
    CONTEXT="attention"
    DEFAULT_VOICE="Albert"
else
    CONTEXT="progress"
    DEFAULT_VOICE="Samantha"
fi
```

### Step 2: Validate Voice Exists

```bash
# Verify the selected voice is available
if say -v "$VOICE" "" 2>&1 | grep -q "not found"; then
    # Voice not available, fall back to Samantha
    VOICE="Samantha"
fi
```

### Step 3: Execute Voice Command

```bash
# Use say command directly (no bash helper script needed)
say -v "$VOICE" "$MESSAGE" 2>/dev/null &
```

**Critical implementation notes**:
- Use `&` to run in background (non-blocking)
- Redirect errors to `/dev/null` (graceful degradation)
- Keep message under 100 words
- No bash variable capture needed
- Can be called during thinking or tool use

## Error Handling

### Voice Not Available

```bash
# Fallback to default if voice doesn't exist
if say -v "$VOICE" "" 2>&1 | grep -q "not found"; then
    VOICE="Samantha"
fi
```

### Say Command Fails

```bash
# Suppress errors, never block execution
say -v "$VOICE" "$MESSAGE" 2>/dev/null &
# Continue with work regardless of voice success/failure
```

### Platform Check

```bash
# Verify macOS platform
if [[ "$OSTYPE" != "darwin"* ]]; then
    # Skill not available on this platform
    # Exit gracefully without attempting voice
fi
```

### CLAUDE.md Parse Error

If CLAUDE.md exists but can't be parsed:
- Use context-based defaults
- Don't block execution on parse errors
- Fall back gracefully

## Best Practices

### Frequency Guidelines

Balance being helpful with not being intrusive:

- **Long tasks** (10+ minutes): Updates every 1-2 minutes or at major milestones
- **Medium tasks** (3-10 minutes): Updates at start, middle, completion
- **Short tasks** (< 3 minutes): Only start/completion or critical findings
- **Interactive tasks**: Attention requests when blocking on decisions

### Timing Considerations

- **Start of task**: Optional brief confirmation ("Starting the build")
- **During work**: Major milestones or discoveries only
- **Completion**: Success/failure summary ("Build completed successfully")
- **Blocking**: Immediate attention request if user input needed

### User Experience

Voice updates should:
- **Complement, not replace** written output in chat
- **Inform without disrupting** user's focus on other work
- **Provide value** beyond what's visible in terminal
- **Enable multitasking** - user can hear updates while doing other work

### Content Tone

Match tone to context:
- **Progress updates**: Neutral, informative ("Working through test suite")
- **Findings**: Clear, specific ("Found the bug in session handler")
- **Attention requests**: Polite, clear ("I need your input on the schema")
- **Errors**: Calm, factual ("Test suite is failing, investigating now")

## Example Session

```
User: "Keep me updated with voice while you refactor the authentication module"

Claude: [Activates voice-updates skill]
        [Checks for voice preference in CLAUDE.md - finds "voice: Samantha"]

        Working on refactoring...
        [Voice: "Starting authentication module refactoring"]

        ... continues work ...
        [Voice: "Halfway through. Moving user session logic to new module"]

        ... discovers issue ...
        [Voice (using Fred for emphasis): "Found a security issue in token validation"]

        ... completes work ...
        [Voice: "Refactoring complete. All tests passing"]
```

## Platform Requirements

This skill requires macOS (darwin platform). The `say` command is macOS-specific.

On non-macOS platforms:
- Skill will not activate
- No error messages (graceful degradation)
- Work continues normally without voice

## Integration Notes

Voice updates work seamlessly with:
- Background tool execution
- Long-running tasks
- Multi-step workflows
- Thinking/planning phases

Voice can be used:
- During thinking (doesn't stop thought process)
- During tool use (runs in background)
- Between steps (natural update points)

Voice should NOT:
- Block any execution
- Wait for completion confirmation
- Require user acknowledgment
