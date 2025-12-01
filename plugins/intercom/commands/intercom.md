---
name: intercom
description: Send messages to Claude Code agents in other repositories
---

# Cross-Agent Communication via Intercom

Send a message to a Claude Code agent in another repository. This command manages session state automatically and handles multi-turn conversations.

## Usage

You should:

1. **Validate the target repository path** provided by the user
2. **Determine the state file location**:
   - Use `/tmp/cross-agent-sessions.json` by default
   - If user specifies a project-local path (e.g., `claude-notes/intercom/`), use that instead
3. **Check for existing session**: Read the state file to see if there's an active session for this repo
4. **Execute the appropriate command**:
   - **New conversation**: `cd TARGET_REPO && claude -p --output-format json "MESSAGE"`
   - **Resume existing**: `cd TARGET_REPO && claude -p --output-format json --resume SESSION_ID "MESSAGE"`
5. **Parse the JSON response** from bash output to extract:
   - `session_id` - Save for future conversations
   - `result` - The agent's response to display
   - `total_cost_usd` - Cost information
   - `num_turns` - Number of agentic turns
6. **Update session state**: Write the session_id back to the state file with current timestamp
7. **Display the response** to the user

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

## State File Format

```json
{
  "/absolute/path/to/repo": {
    "session_id": "session-id-here",
    "updated_at": "2025-11-30T12:00:00Z"
  }
}
```

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
- `--new-session` to force a new conversation (ignore existing session)
- Custom state file location for project-local storage
