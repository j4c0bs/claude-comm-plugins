---
name: cross-agent-communication
description: Communicate with Claude Code agents in other repositories
---

# Cross-Agent Communication

Use when leveraging agents/commands/skills from another repo (bypasses --add-dir limitation). Supports multiple concurrent conversations with intelligent session management.

**IMPORTANT:** Sessions are automatically managed based on conversation context, topic relatedness, and recency. The skill handles resume vs. new session decisions autonomously.

## Important: Output Handling

**Do NOT use bash variable capture** - it causes hangs:
- ❌ `response=$(claude -p "msg" --output-format json)` - HANGS
- ❌ `claude -p "msg" --output-format json > file.json` - HANGS
- ✅ `claude -p --output-format json "msg"` - Direct stdout works

## Workflow

### Step 1: Initialize Parent Session Context

Check conversation history for existing parent session ID:

```bash
# Check if we have a parent session ID in our context
# Look for pattern "intercom-session-" in conversation history
# If not found, generate new ID:
PARENT_SESSION_ID="intercom-session-$(uuidgen)"

# Reference it explicitly so it persists in context:
# [Intercom] Using parent session: $PARENT_SESSION_ID
```

**Key insight:** The parent session ID persists in Claude's conversation context. When a new Claude session starts, there's no ID in context, so a new one is generated automatically.

### Step 2: Read State File and Decide Resume vs. New

Use Read tool to load state from `/tmp/cross-agent-sessions.json` (default) or user-specified location.

**State format (v2):**
```json
{
  "version": "2.0.0",
  "repos": {
    "/path/to/repo": {
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

**Resume Decision Algorithm:**

1. Get all sessions for target repo
2. Filter to sessions with current `parent_session_id`
3. Get most recently used session (sort by `last_used_at` DESC)
4. Check ALL criteria (must pass ALL to resume):
   - ✓ Session exists for this repo
   - ✓ Session matches current parent_session_id
   - ✓ Session used within last 15 minutes
   - ✓ New message is topically related (see heuristic below)
5. If ALL pass: RESUME session
6. If ANY fail: CREATE NEW session

### Step 3: Topic Relatedness Check

**Heuristic (zero-cost, keyword-based):**

```bash
# Pseudo-logic for topic relatedness:

# 1. Check for continuation phrases
if message contains "follow up" OR "also" OR "additionally" OR "regarding that" OR "about that":
  return RELATED

# 2. Extract keywords (remove stopwords: the, a, an, and, or, but, is, are, was, were, to, from, in, on, at, for, with)
topic_words = extract_keywords(session.topic_summary)
new_words = extract_keywords(new_message)
last_words = extract_keywords(session.last_message_preview)

# 3. Calculate overlap ratios
topic_overlap = count(topic_words ∩ new_words) / max(count(topic_words), 1)
recent_overlap = count(last_words ∩ new_words) / max(count(last_words), 1)

# 4. Check thresholds
if topic_overlap > 0.30 OR recent_overlap > 0.40:
  return RELATED
else:
  return UNRELATED
```

### Step 4: Execute Command

**If RESUME:**
```bash
cd /path/to/repo && claude -p --output-format json --resume SESSION_ID "message"
```

**If NEW SESSION:**
```bash
cd /path/to/repo && claude -p --output-format json "message"
```

### Step 5: Save/Update Session State

Extract from JSON response:
- `session_id` - For resuming conversation
- `result` - Agent's response text
- `total_cost_usd` - API cost
- `num_turns` - Number of agentic turns

Generate topic summary:
- Use first 50 characters of user message
- Or extract key terms (remove stopwords, take first 5-7 words)

Update or create session object:
```json
{
  "session_id": "extracted-from-response",
  "topic_summary": "generated-summary",
  "created_at": "ISO-8601-timestamp (if new)",
  "last_used_at": "ISO-8601-timestamp (now)",
  "parent_session_id": "$PARENT_SESSION_ID",
  "message_count": "increment or 1 if new",
  "last_message_preview": "first-60-chars-of-message",
  "cost_usd": "accumulated-cost",
  "status": "active"
}
```

Write updated state back to file using Write tool.

### Step 6: Cleanup if Session Limit Exceeded

After saving session state:

1. Count total sessions for this repo
2. If count > session_limit (default: 5):
   - Separate sessions into active (current parent) and inactive
   - Keep ALL active sessions (never remove)
   - Sort inactive sessions by `last_used_at` ASC (oldest first)
   - Remove oldest inactive sessions until count ≤ limit
   - Log cleanup actions for visibility

**Example cleanup:**
```
Repo /path/to/backend has 6 sessions (limit: 5)
- 2 active (current parent)
- 4 inactive (old parents)
→ Remove 1 oldest inactive session
→ Keep 5 sessions: 2 active + 3 newest inactive
```

## JSON Response Fields
- `.session_id` - For resuming conversation
- `.result` - Agent's response text
- `.total_cost_usd` - API cost
- `.num_turns` - Number of agentic turns

## Multi-Repository & Multi-Session Example

The state file tracks multiple sessions per repository:

```json
{
  "version": "2.0.0",
  "repos": {
    "/Users/user/repos/backend-api": {
      "sessions": [
        {
          "session_id": "abc-123",
          "topic_summary": "Authentication flow",
          "parent_session_id": "intercom-session-xyz",
          "status": "active"
        },
        {
          "session_id": "abc-456",
          "topic_summary": "Database migrations",
          "parent_session_id": "intercom-session-xyz",
          "status": "active"
        }
      ],
      "session_limit": 5
    },
    "/Users/user/repos/frontend": {
      "sessions": [
        {
          "session_id": "def-789",
          "topic_summary": "Component refactoring",
          "parent_session_id": "intercom-session-xyz",
          "status": "active"
        }
      ],
      "session_limit": 5
    }
  },
  "current_parent_session": "intercom-session-xyz"
}
```

**Example flow:**
1. "Ask backend-api about auth" → Creates session abc-123
2. "Ask backend-api about database" → Creates session abc-456 (different topic)
3. "Follow up on auth" → Resumes session abc-123 (topic match)
4. "Ask frontend about components" → Creates session def-789 (different repo)

## Migration from v1 to v2

When reading state file, check format version:

1. **Detect format:** Check for `version` field
2. **If v1 (old format):**
   ```bash
   # Create backup
   cp $STATE_FILE ${STATE_FILE}.v1.backup

   # Migrate each repo entry to v2 format
   # Convert: {"/repo": {"session_id": "x", "updated_at": "y"}}
   # To: repos["/repo"].sessions = [{"session_id": "x", "status": "inactive", ...}]
   ```
3. **Set migrated sessions:**
   - `status` = "inactive" (from old parent session)
   - `parent_session_id` = "migrated-v1"
   - `created_at` = old `updated_at`
   - `last_used_at` = old `updated_at`
   - `message_count` = 1
   - `topic_summary` = "Migrated from v1"
   - `cost_usd` = 0.0

4. **Write v2 format** with migrated data
5. **Validate JSON** structure on read
6. **Graceful degradation:** If corrupted, recreate empty state

## State Storage Options

1. **Temporary** (default): `/tmp/cross-agent-sessions.json`
   - Simple, works immediately
   - Auto-cleaned on system reboot
   - Shared across all projects

2. **Project-local**: `claude-notes/intercom/` or user-specified path
   - Per-project session state
   - Persists across reboots
   - Can be committed or gitignored as needed

**Note:** Migration from v1 happens automatically on first read. A backup is created at `${STATE_FILE}.v1.backup`.

## Cost Control
Add `--max-turns N` to limit agentic turns:
```bash
claude -p --output-format json --max-turns 3 "message"
```

## Prompt Caching Benefits

Multi-turn conversations leverage prompt caching for cost efficiency:
- First turn: ~$0.065
- Subsequent turns: ~$0.005 (92% savings)

The intelligent session management automatically resumes when appropriate to maximize caching benefits while avoiding confusion from mixing unrelated topics.

## Observability & Logging

When making resume decisions, log the reasoning for visibility:

```
[Intercom] Using parent session: intercom-session-abc123
[Intercom] Analyzing /path/to/backend-api
  → Found 3 existing sessions
  → 1 active in current parent
  → Most recent: "Authentication flow" (5 min ago)
  → Topic check: RELATED (keyword overlap: 45%)
  → Decision: RESUMING session uuid-1
```

When starting new sessions:
```
[Intercom] Using parent session: intercom-session-abc123
[Intercom] Analyzing /path/to/frontend
  → Found 2 existing sessions
  → 0 active in current parent
  → Decision: STARTING NEW SESSION
  → Topic: "Component state management"
```

When cleanup occurs:
```
[Intercom] Session cleanup for /path/to/backend-api
  → 6 sessions found (limit: 5)
  → 2 active (preserved)
  → Removed 1 oldest inactive session (uuid-old-123)
  → Kept 5 sessions
```
