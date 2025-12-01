---
name: cross-agent-communication
description: Communicate with Claude Code agents in other repositories
---

# Cross-Agent Communication

Use when leveraging agents/commands/skills from another repo (bypasses --add-dir limitation). Supports resuming conversations.

**IMPORTANT:** Always resume sessions when continuing conversations. Do not resume conversations for new topics. If only some context is needed from a previous conversation when discussing a new topic, include a summary in your message instead of resuming the conversation.

## Important: Output Handling

**Do NOT use bash variable capture** - it causes hangs:
- ❌ `response=$(claude -p "msg" --output-format json)` - HANGS
- ❌ `claude -p "msg" --output-format json > file.json` - HANGS
- ✅ `claude -p --output-format json "msg"` - Direct stdout works

## Workflow

### Step 1: Send Message
```bash
cd /path/to/other/repo && claude -p --output-format json "message"
```
JSON output appears in bash result. Extract `session_id` and `result` from output.

### Step 2: Save Session State

Use Write tool to save to `/tmp/cross-agent-sessions.json` (default) or user-specified directory like `claude-notes/intercom/`:

**Default location** (`/tmp/cross-agent-sessions.json`):
```json
{
  "/path/to/other/repo": {
    "session_id": "extracted-session-id",
    "updated_at": "timestamp"
  }
}
```

**Project-local storage**: When user specifies a project directory (e.g., `claude-notes/intercom/cross-agent-sessions.json`), use that location instead. This keeps session state tied to the project.

### Step 3: Resume Conversation
Read session_id from state file, then:
```bash
cd /path/to/other/repo && claude -p --output-format json --resume SESSION_ID "follow-up"
```

## JSON Response Fields
- `.session_id` - For resuming conversation
- `.result` - Agent's response text
- `.total_cost_usd` - API cost
- `.num_turns` - Number of agentic turns

## Multi-Agent Example

When communicating with multiple repos, the state file tracks all sessions:
```json
{
  "/Users/user/repos/backend-api": {"session_id": "abc-123", "updated_at": "..."},
  "/Users/user/repos/frontend": {"session_id": "def-456", "updated_at": "..."}
}
```

## State Storage Options

1. **Temporary** (default): `/tmp/cross-agent-sessions.json`
   - Simple, works immediately
   - Auto-cleaned on system reboot
   - Shared across all projects

2. **Project-local**: `claude-notes/intercom/` or user-specified path
   - Per-project session state
   - Persists across reboots
   - Can be committed or gitignored as needed

## Cost Control
Add `--max-turns N` to limit agentic turns:
```bash
claude -p --output-format json --max-turns 3 "message"
```

## Prompt Caching Benefits

Multi-turn conversations leverage prompt caching for cost efficiency:
- First turn: ~$0.065
- Subsequent turns: ~$0.005 (92% savings)

Always resume sessions when possible to maximize caching benefits.
