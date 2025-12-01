# Intercom Plugin for Claude Code

Enable Claude Code agents in separate repositories to communicate via CLI invocation.

## Overview

The Intercom plugin solves a key limitation: the `--add-dir` flag doesn't load agents, commands, or skills from added directories. This plugin bypasses that by invoking Claude Code directly in target repositories, enabling true cross-agent communication.

## Features

- **Cross-repo communication**: Send messages to Claude Code agents in other repositories
- **Session management**: Automatic state tracking for multi-turn conversations
- **Cost efficiency**: Leverage prompt caching for 92% cost savings on subsequent turns
- **Flexible storage**: Choose between temporary or project-local session state
- **Autonomous activation**: Skills auto-trigger when appropriate
- **Manual control**: Use `/intercom` command for explicit invocation

## Quick Start

### Using the Skill (Autonomous)

Claude Code will automatically use the cross-agent-communication skill when appropriate. Simply describe your need to communicate with another repository:

```
"Check with the agent in /path/to/backend-api about the authentication flow"
```

### Using the Command (Manual)

Explicitly invoke the `/intercom` command:

```
/intercom /path/to/other/repo "What tests are failing?"
```

## How It Works

### Step 1: Send Message

The plugin executes `claude -p --output-format json` in the target repository:

```bash
cd /path/to/other/repo && claude -p --output-format json "your message"
```

### Step 2: Parse Response

JSON output includes:
- `session_id` - For resuming the conversation
- `result` - The agent's response
- `total_cost_usd` - API cost for this turn
- `num_turns` - Number of agentic turns taken

### Step 3: Save Session State

Session information is saved to track conversations:

**Default location**: `/tmp/cross-agent-sessions.json`
```json
{
  "/path/to/repo": {
    "session_id": "abc-123",
    "updated_at": "2025-11-30T12:00:00Z"
  }
}
```

**Project-local**: `claude-notes/intercom/cross-agent-sessions.json` (when specified)

### Step 4: Resume Conversations

Subsequent messages automatically resume the session:

```bash
cd /path/to/other/repo && claude -p --output-format json --resume abc-123 "follow-up question"
```

## Critical Warning: Bash Capture Issue

**NEVER use bash variable capture or output redirection** with `claude -p --output-format json`:

❌ **DO NOT DO THIS** (causes indefinite hang):
```bash
response=$(claude -p --output-format json "msg")
claude -p --output-format json "msg" > file.json
```

✅ **ALWAYS DO THIS** (let output appear directly):
```bash
claude -p --output-format json "msg"
```

The plugin handles parsing and state management for you.

## State Storage Options

### Temporary (Default)

- **Location**: `/tmp/cross-agent-sessions.json`
- **Pros**: Simple, works immediately, auto-cleaned on reboot
- **Cons**: Lost on system restart
- **Use when**: Testing, one-off communications

### Project-Local

- **Location**: `claude-notes/intercom/` or user-specified
- **Pros**: Persists across reboots, per-project state
- **Cons**: Requires setup
- **Use when**: Ongoing collaboration, team projects

## Cost Efficiency

Multi-turn conversations benefit significantly from prompt caching:

| Turn Type        | Typical Cost | Savings |
| ---------------- | ------------ | ------- |
| First turn       | ~$0.065      | -       |
| Subsequent turns | ~$0.005      | 92%     |

**Best practice**: Always resume existing sessions when continuing a conversation.

## Advanced Usage

### Limit Agentic Turns

Control costs by limiting the number of turns:

```bash
cd /path/to/repo && claude -p --output-format json --max-turns 3 "message"
```

### Force New Session

Start a fresh conversation ignoring existing sessions:

```
/intercom --new-session /path/to/repo "message"
```

### Custom State Location

Specify project-local storage:

```
Use claude-notes/intercom/ for session state
```

## Multi-Repository Communication

Track sessions with multiple repositories simultaneously:

```json
{
  "/Users/user/repos/backend-api": {
    "session_id": "abc-123",
    "updated_at": "2025-11-30T10:00:00Z"
  },
  "/Users/user/repos/frontend": {
    "session_id": "def-456",
    "updated_at": "2025-11-30T11:30:00Z"
  }
}
```

Each repository maintains its own conversation thread.

## Plugin Components

### Skill: `cross-agent-communication`

Auto-activates when Claude Code detects cross-repository communication needs. Contains complete instructions for:
- Output handling (avoiding bash capture)
- Session state management
- JSON response parsing
- Multi-repository tracking

### Command: `/intercom`

Provides explicit control over cross-agent communication:
- Validates target repository paths
- Manages session state automatically
- Parses JSON responses
- Displays agent responses
- Tracks costs and turns

## Troubleshooting

### Plugin Not Loading

1. Verify installation: `claude --plugin list`
2. Check plugin structure matches conventions
3. Ensure `.claude-plugin/plugin.json` exists
4. Restart Claude Code session

### Command Not Found

1. Check plugin is enabled: `claude --plugin list`
2. Verify `commands/intercom.md` exists
3. Run `/help` to see available commands
4. Restart Claude Code if needed

### Session State Not Persisting

1. Check state file location (default: `/tmp/cross-agent-sessions.json`)
2. Verify write permissions
3. For project-local storage, ensure directory exists
4. Check `.gitignore` includes session state files

### Communication Hangs

If the `claude -p` command hangs indefinitely:
1. **Check for bash capture**: Ensure you're not using `$()` or `>`
2. **Verify target repo path**: Must be valid Claude Code project
3. **Check permissions**: Ensure target repo is accessible
4. **Review command syntax**: Follow exact patterns from documentation

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly with multiple repositories
4. Submit pull request with clear description

## License

MIT

## Support

- **Issues**: Report bugs at repository issue tracker
- **Documentation**: See `skills/` and `commands/` directories
- **Examples**: Check `examples/` (if available)

---

**Version**: 1.0.0
**Author**: Jeremy Jacobs
**Keywords**: communication, multi-agent, cross-repo, cli
