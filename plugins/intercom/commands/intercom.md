---
name: intercom
description: Send messages to Claude Code agents in other repositories
---

# Cross-Agent Communication via Intercom

Send a message to a Claude Code agent in another repository. This command manages multiple concurrent sessions automatically with intelligent resume logic based on conversation context and topic relatedness.

## Usage

You should:

1. **Initialize parent session context**:
   - Check conversation history for existing "intercom-session-*" ID
   - If not found, generate new parent session ID
   - Reference it explicitly for context persistence

2. **Validate the target repository path** provided by the user

3. **Determine the state file location**:
   - Use `/tmp/cross-agent-sessions.json` by default
   - If user specifies a project-local path (e.g., `claude-notes/intercom/`), use that instead

4. **Read state and apply resume logic**:
   - Load v2 state format (multi-session per repo)
   - Filter sessions by parent_session_id and recency (15 min)
   - Check topic relatedness using keyword heuristic
   - Decide: RESUME existing or CREATE new session

5. **Execute the appropriate command**:
   - **New session**: `cd TARGET_REPO && claude -p --output-format json "MESSAGE"`
   - **Resume session**: `cd TARGET_REPO && claude -p --output-format json --resume SESSION_ID "MESSAGE"`

6. **Parse the JSON response** from bash output to extract:
   - `session_id` - Save for future conversations
   - `result` - The agent's response to display
   - `total_cost_usd` - Cost information
   - `num_turns` - Number of agentic turns

7. **Update session state**:
   - Create/update session object with full metadata
   - Set status="active", parent_session_id, timestamps
   - Write back to state file in v2 format

8. **Cleanup if needed**:
   - If repo exceeds session limit (default: 5), remove oldest inactive sessions
   - Always preserve active sessions

9. **Display the response** to the user with session information

## Critical: Bash Output Handling

**NEVER use bash variable capture or output redirection** - it causes indefinite hangs:

❌ **DO NOT DO THIS**:
```bash
response=$(cd /path && claude -p --output-format json "msg")
claude -p --output-format json "msg" > file.json
```

✅ **ALWAYS DO THIS**:
```bash
cd /path/to/repo && claude -p --output-format json "message"
```

Let the JSON output appear directly in the bash result, then parse it using the Read/Write tools.

## State File Format (v2)

```json
{
  "version": "2.0.0",
  "repos": {
    "/absolute/path/to/repo": {
      "sessions": [
        {
          "session_id": "uuid-1",
          "topic_summary": "Authentication flow",
          "created_at": "2025-12-06T10:00:00Z",
          "last_used_at": "2025-12-06T10:15:00Z",
          "parent_session_id": "intercom-session-abc123",
          "message_count": 3,
          "last_message_preview": "How do we handle token refresh?",
          "cost_usd": 0.075,
          "status": "active"
        }
      ],
      "session_limit": 5
    }
  },
  "current_parent_session": "intercom-session-abc123",
  "config": {
    "default_session_limit": 5,
    "auto_cleanup_enabled": true
  }
}
```

**Key differences from v1:**
- Multiple sessions per repository
- Rich metadata (topic, parent context, timestamps)
- Session status tracking (active/inactive)
- Automatic migration from v1 on first read

## Workflow Steps

1. **Validate**: Check that the target repository path exists and is accessible
2. **Read State**: Check if there's an existing session for this repo
3. **Execute**: Run the appropriate `claude -p` command
4. **Parse**: Extract session_id and result from JSON output
5. **Save**: Update the state file with the new/updated session
6. **Display**: Show the agent's response to the user

## Cost Efficiency Note

Multi-turn conversations benefit from prompt caching:
- First turn: ~$0.065
- Subsequent turns: ~$0.005 (92% savings)

Always resume sessions when possible to maximize these savings.

## Additional Options

Users can optionally specify:
- `--max-turns N` to limit agentic turns
- `--new-session` to force a new conversation (skip resume logic)
- `--list-sessions` to show all sessions for target repo
- `--cleanup` to manually trigger cleanup for target repo
- Custom state file location for project-local storage

**Session Management:**
The command intelligently decides whether to resume or create new sessions based on:
- Parent session context (same conversation flow)
- Recency (within 15 minutes)
- Topic relatedness (keyword-based heuristic)

**Default behavior:** Bias toward creating new sessions unless all resume criteria pass.
