#!/bin/bash

# Test script for Apple notifications

echo "Testing Apple Notifications..."
echo "================================"
echo ""

echo "Test 1: Basic notification"
osascript -e 'display notification "This is a test notification from Claude Code" with title "Test #1: Basic"'
echo "✓ Sent basic notification"
sleep 2

echo ""
echo "Test 2: With subtitle"
osascript -e 'display notification "Testing notification with subtitle" with title "Test #2: Subtitle" subtitle "Additional context"'
echo "✓ Sent notification with subtitle"
sleep 2

echo ""
echo "Test 3: With sound (Glass)"
osascript -e 'display notification "Testing notification with sound" with title "Test #3: Sound" sound name "Glass"'
echo "✓ Sent notification with sound"
sleep 2

echo ""
echo "Test 4: Character escaping (apostrophe)"
osascript -e "display notification \"User's authentication test\" with title \"Test #4: Apostrophe\""
echo "✓ Sent notification with apostrophe"
sleep 2

echo ""
echo "Test 5: All parameters"
osascript -e 'display notification "Full featured notification test" with title "Test #5: Full" subtitle "All parameters" sound name "Funk"'
echo "✓ Sent full notification"

echo ""
echo "================================"
echo "All tests complete!"
echo ""
echo "Did you see 5 notifications appear?"
echo "If not, check:"
echo "1. System Preferences → Notifications → Script Editor (or Terminal)"
echo "2. Make sure 'Allow Notifications' is enabled"
echo "3. Notification style should be 'Alerts' or 'Banners'"
echo "4. Do Not Disturb should be disabled"
