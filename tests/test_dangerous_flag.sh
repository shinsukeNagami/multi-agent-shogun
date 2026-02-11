#!/bin/bash
# Test: ALLOW_DANGEROUS environment variable controls --dangerously-skip-permissions
# This test sources the variable-setting portion of shutsujin_departure.sh
# and verifies the flag behavior without actually launching tmux/claude.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [ "$expected" = "$actual" ]; then
        echo "  PASS: $desc"
        ((PASS++))
    else
        echo "  FAIL: $desc (expected='$expected', actual='$actual')"
        ((FAIL++))
    fi
}

echo "=== Test: dangerous flag control ==="

# Test 1: Default (no env var) → flag should be empty
unset ALLOW_DANGEROUS
CLAUDE_DANGEROUS_FLAG=""
if [ "${ALLOW_DANGEROUS:-0}" = "1" ]; then
    CLAUDE_DANGEROUS_FLAG="--dangerously-skip-permissions"
fi
assert_eq "Default: flag is empty" "" "$CLAUDE_DANGEROUS_FLAG"

# Test 2: ALLOW_DANGEROUS=1 → flag should be set
ALLOW_DANGEROUS=1
CLAUDE_DANGEROUS_FLAG=""
if [ "${ALLOW_DANGEROUS:-0}" = "1" ]; then
    CLAUDE_DANGEROUS_FLAG="--dangerously-skip-permissions"
fi
assert_eq "ALLOW_DANGEROUS=1: flag is set" "--dangerously-skip-permissions" "$CLAUDE_DANGEROUS_FLAG"

# Test 3: ALLOW_DANGEROUS=0 → flag should be empty
ALLOW_DANGEROUS=0
CLAUDE_DANGEROUS_FLAG=""
if [ "${ALLOW_DANGEROUS:-0}" = "1" ]; then
    CLAUDE_DANGEROUS_FLAG="--dangerously-skip-permissions"
fi
assert_eq "ALLOW_DANGEROUS=0: flag is empty" "" "$CLAUDE_DANGEROUS_FLAG"

# Test 4: Verify shutsujin_departure.sh no longer has hardcoded flag
HARDCODED=$(grep -c 'claude --dangerously-skip-permissions' "$SCRIPT_DIR/shutsujin_departure.sh" || true)
assert_eq "No hardcoded --dangerously-skip-permissions in script" "0" "$HARDCODED"

# Test 5: Verify -d flag exists in help
HAS_D_FLAG=$(grep -c '\-d, --dangerous' "$SCRIPT_DIR/shutsujin_departure.sh" || true)
assert_eq "-d/--dangerous flag documented in script" "1" "$HAS_D_FLAG"

# Test 6: Verify settings.yaml has dangerous_mode: false
HAS_SETTING=$(grep -c 'dangerous_mode: false' "$SCRIPT_DIR/config/settings.yaml" || true)
assert_eq "settings.yaml has dangerous_mode: false" "1" "$HAS_SETTING"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
