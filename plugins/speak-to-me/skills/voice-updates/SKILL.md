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

**Context-based voices**: Samantha (progress), Fred (emphasis), Albert (attention)
**Other recommended voices**: Ralph, Kathy, Eddy, Flo, Reed, Rocko, Sandy, Shelley
**Avoid novelty voices**: Good News, Bad News, Whisper, Bells, Boing, Bubbles, etc.

## Content Guidelines

### Message Requirements

Voice messages must be:
1. **Short**: Under 20-30 words (5-10 seconds of speech)
2. **Natural**: Conversational language that sounds good spoken
3. **Clear**: Simple, direct communication
4. **Vocalizable**: No lists, code blocks, or special characters

### Examples

✅ **Good**:
- "Build completed successfully. All tests passed."
- "I found the authentication bug in the login module."
- "I need your input on the database schema before continuing."

❌ **Bad**:
- "Found files: config.json, package.json, tsconfig.json" *(list)*
- "Error on line 42: TypeError: Cannot read property" *(too technical)*

## Implementation

**Voice selection workflow**:
1. Check chat context for explicit voice request
2. If none, read CLAUDE.md and search for voice preference patterns
3. If not found, select based on context (progress→Samantha, emphasis→Fred, attention→Albert)
4. Verify voice exists, fallback to Samantha if not
5. Execute command below

**Execute voice command**:

```bash
say -v "$VOICE" "$MESSAGE" 2>/dev/null &
```

**Notes**: Use `&` for background execution (non-blocking). Redirect errors to `/dev/null` for graceful degradation. Can be called during thinking or tool use.

## Error Handling

All failures degrade gracefully without blocking execution:
- Voice not found → fallback to Samantha
- Say command fails → suppress error with `2>/dev/null`
- macOS unavailable → check `$OSTYPE`, skip voice gracefully
- CLAUDE.md parse error → use context-based default

## Best Practices

- **Frequency**: Long tasks (~1-2 min intervals or major milestones), short tasks (start/end only), interactive tasks (when blocked)
- **Tone**: Match context - neutral for progress, clear for findings, polite for attention, calm for errors
- **Value**: Complement written output, enable multitasking, inform without disrupting focus

## Example Session

```
User: "Keep me updated with voice while you refactor the authentication module"

[Voice: "Starting authentication refactoring"]
[Voice: "Halfway through. Moving session logic to new module"]
[Voice (Fred): "Found security issue in token validation"]
[Voice: "Refactoring complete. All tests passing"]
```
