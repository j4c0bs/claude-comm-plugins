# Intercom Plugin for Claude Code

Enable Claude Code agents in separate repositories to communicate via CLI invocation.

## Overview

The Intercom plugin solves a key limitation: the `--add-dir` flag doesn't load agents, commands, or skills from added directories. This plugin bypasses that by invoking Claude Code directly in target repositories, enabling true cross-agent communication.

## Features

- **Cross-repo communication**: Send messages to Claude Code agents in other repositories
- **Multiple concurrent sessions**: Maintain separate conversations per topic with the same repo
- **Intelligent session management**: Automatic resume/new session decisions based on context and topic
- **Cost efficiency**: Leverage prompt caching for 92% cost savings on subsequent turns
- **Flexible storage**: Choose between temporary or project-local session state
- **Autonomous activation**: Skills auto-trigger when appropriate
- **Manual control**: Use `/intercom` command for explicit invocation
- **Session limits**: Automatic cleanup of old sessions (configurable per-repo)

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

## Multiple Concurrent Sessions

The Intercom plugin supports multiple concurrent conversations with the same repository, each tracked separately by topic:

### Automatic Session Management

Claude automatically decides whether to resume an existing session or start a new one based on:
- **Conversation context**: Are you continuing the same parent conversation?
- **Recency**: Was the session used recently (within 15 minutes)?
- **Topic relatedness**: Is the new message about the same topic?

### Example: Multiple Topics

```
User: "Ask the backend-api repo about authentication"
[Creates session 1: "Authentication flow"]

User: "Now ask them about database migrations"
[Creates session 2: "Database migrations"]

User: "Follow up on that auth question"
[Resumes session 1: topic matches + recent + same parent context]
```

### Session Limits

By default, the plugin keeps the 5 most recent sessions per repository. Older inactive sessions are automatically cleaned up. Active sessions (from your current conversation) are always preserved.

## How It Works

### Step 1: Initialize Parent Session

First invocation generates a unique parent session ID:
```
[Intercom] Using parent session: intercom-session-abc123
```

This ID persists in your conversation context. When you start a new Claude session, a new parent ID is generated.

### Step 2: Intelligent Session Selection

The plugin checks existing sessions for the target repo:
1. Filters sessions from your current parent session
2. Checks if most recent was used within 15 minutes
3. Analyzes topic relatedness using keyword matching
4. **Resumes** if all criteria pass, otherwise **creates new**

### Step 3: Send Message

The plugin executes `claude -p --output-format json` in the target repository:

**New session:**
```bash
cd /path/to/other/repo && claude -p --output-format json "your message"
```

**Resume session:**
```bash
cd /path/to/other/repo && claude -p --output-format json --resume abc-123 "follow-up"
```

### Step 4: Parse Response

JSON output includes:
- `session_id` - For resuming the conversation
- `result` - The agent's response
- `total_cost_usd` - API cost for this turn
- `num_turns` - Number of agentic turns taken

### Step 5: Save Session State

Session information is saved with rich metadata:

**Default location**: `/tmp/cross-agent-sessions.json`
```json
{
  "version": "2.0.0",
  "repos": {
    "/path/to/repo": {
      "sessions": [
        {
          "session_id": "abc-123",
          "topic_summary": "Authentication flow",
          "created_at": "2025-12-06T10:00:00Z",
          "last_used_at": "2025-12-06T10:15:00Z",
          "parent_session_id": "intercom-session-xyz",
          "message_count": 3,
          "last_message_preview": "How do we handle...",
          "cost_usd": 0.075,
          "status": "active"
        }
      ],
      "session_limit": 5
    }
  },
  "current_parent_session": "intercom-session-xyz"
}
```

**Project-local**: `claude-notes/intercom/cross-agent-sessions.json` (when specified)

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

Track multiple sessions across multiple repositories simultaneously:

```json
{
  "version": "2.0.0",
  "repos": {
    "/Users/user/repos/backend-api": {
      "sessions": [
        {
          "session_id": "abc-123",
          "topic_summary": "Authentication flow",
          "status": "active"
        },
        {
          "session_id": "abc-456",
          "topic_summary": "Database migrations",
          "status": "active"
        }
      ]
    },
    "/Users/user/repos/frontend": {
      "sessions": [
        {
          "session_id": "def-789",
          "topic_summary": "Component refactoring",
          "status": "active"
        }
      ]
    }
  }
}
```

Each repository can maintain multiple concurrent conversations, each tracked by topic.

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

## Migration from v1 to v2

If you have an existing v1 state file, it will be automatically migrated to v2 on first use:

1. **Backup created**: `${STATE_FILE}.v1.backup`
2. **Sessions converted**: Each old session becomes an inactive session in v2 format
3. **Metadata added**: Topic summary set to "Migrated from v1"
4. **No data loss**: All session IDs preserved

The migration happens transparently - no action required.

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
5. **v2 format**: Ensure state file has `version` field

### Communication Hangs

If the `claude -p` command hangs indefinitely:
1. **Check for bash capture**: Ensure you're not using `$()` or `>`
2. **Verify target repo path**: Must be valid Claude Code project
3. **Check permissions**: Ensure target repo is accessible
4. **Review command syntax**: Follow exact patterns from documentation

### Sessions Not Resuming

If sessions aren't resuming when expected:
1. **Check recency**: Sessions older than 15 minutes won't auto-resume
2. **Check topic**: Unrelated messages create new sessions (by design)
3. **Check parent context**: New Claude sessions get new parent IDs
4. **Check logs**: Look for `[Intercom]` decision logging

### Too Many Sessions

If you're accumulating too many sessions:
1. **Check limit**: Default is 5 per repo (configurable)
2. **Cleanup happens**: Automatically when limit exceeded
3. **Active preserved**: Active sessions never removed
4. **Manual cleanup**: Use `--cleanup` flag if needed

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

**Version**: 1.1.0
**Author**: Jeremy Jacobs
**Keywords**: communication, multi-agent, cross-repo, cli
