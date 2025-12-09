# Notification Examples

Comprehensive real-world scenarios demonstrating notification usage.

## Example 1: Test Suite Completion

**Scenario**: Running comprehensive test suite that takes 4 minutes

```bash
# After tests complete
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "All 247 tests passed in 4m 12s" with title "Tests Complete" sound name "Glass"' 2>/dev/null || true
fi
```

## Example 2: Security Vulnerability Found

**Scenario**: Analyzing codebase and discovering security issue

```bash
# After finding vulnerability
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "SQL injection risk in user input handler" with title "Security Issue" subtitle "High Priority" sound name "Funk"' 2>/dev/null || true
fi
```

## Example 3: Migration Progress

**Scenario**: Running 15 database migrations, notify at milestones

```bash
# After completing 5 of 15 migrations
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "Completed 5 of 15 database migrations" with title "Migration Progress"' 2>/dev/null || true
fi
```

## Example 4: Build Failure

**Scenario**: Build fails with compilation errors

```bash
# After build fails
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "23 TypeScript compilation errors found" with title "Build Failed" sound name "Basso"' 2>/dev/null || true
fi
```

## Example 5: User Input Required

**Scenario**: Multiple valid approaches, need user to decide

```bash
# When blocked on user decision
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e 'display notification "Choose authentication strategy to continue" with title "Input Required" sound name "Purr"' 2>/dev/null || true
fi
```

## Example 6: Character Escaping

**Scenario**: Message contains apostrophes

```bash
# Handle apostrophes properly
if [[ "$OSTYPE" == "darwin"* ]]; then
  osascript -e "display notification \"User's session token expired\" with title \"Authentication Error\"" 2>/dev/null || true
fi
```

## Example 7: Long-Running Deployment

**Scenario**: Deployment taking 8 minutes, notify at milestones

```bash
# Milestone 1: Build phase complete (2 minutes)
osascript -e 'display notification "Build phase complete, starting deployment" with title "Deployment Progress"' 2>/dev/null || true

# Milestone 2: Database migrations complete (5 minutes)
osascript -e 'display notification "Database migrations complete" with title "Deployment Progress"' 2>/dev/null || true

# Final: Deployment complete (8 minutes)
osascript -e 'display notification "Deployment successful in 8m 24s" with title "Deployment Complete" sound name "Glass"' 2>/dev/null || true
```
