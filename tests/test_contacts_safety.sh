#!/bin/sh
# CONTACTS-001 behavioral safety fixture.
#
# The maintenance contract requires an isolated OSASCRIPT_BIN mock fixture that
# drives empty/unknown edit and delete inputs plus a failed JXA response,
# asserts a nonzero exit and no delete/save mock call, then drives one
# resolved-ID delete and asserts exactly that ID is deleted and saved.
#
# Nothing here touches the real Contacts database: every osascript invocation
# is routed to tests/mocks/osascript.

set -u

TEST_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH='' cd -- "$TEST_DIR/.." && pwd)
CONTACTS="$REPO_ROOT/contacts"
MOCK="$TEST_DIR/mocks/osascript"

if [ ! -x "$MOCK" ]; then
  echo "FATAL: mock is not executable: $MOCK" >&2
  exit 1
fi

WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/contacts-safety.XXXXXX")
trap 'rm -rf "$WORK_DIR"' EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  echo "  FAIL: $1"
}

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  echo "  ok: $1"
}

# run_case <name> <response_mode> -- <contacts args...>
# Sets: RUN_EXIT, RUN_LOG, RUN_OUT
run_case() {
  RUN_NAME="$1"; shift
  RUN_MODE="$1"; shift
  [ "$1" = "--" ] && shift

  RUN_LOG="$WORK_DIR/$(echo "$RUN_NAME" | tr ' /' '__').log"
  RUN_OUT="$WORK_DIR/$(echo "$RUN_NAME" | tr ' /' '__').out"
  : >"$RUN_LOG"

  echo "case: $RUN_NAME"
  set +e
  OSASCRIPT_BIN="$MOCK" \
  MOCK_CALL_LOG="$RUN_LOG" \
  MOCK_RESPONSE_MODE="$RUN_MODE" \
  "$CONTACTS" "$@" >"$RUN_OUT" 2>&1
  RUN_EXIT=$?
  set -e
}

assert_nonzero_exit() {
  if [ "$RUN_EXIT" -ne 0 ]; then
    pass "exited nonzero ($RUN_EXIT)"
  else
    fail "expected a nonzero exit, got 0"
  fi
}

assert_zero_exit() {
  if [ "$RUN_EXIT" -eq 0 ]; then
    pass "exited zero"
  else
    fail "expected exit 0, got $RUN_EXIT (output: $(cat "$RUN_OUT"))"
  fi
}

assert_no_destructive_call() {
  if grep -q '^KIND: delete$' "$RUN_LOG" 2>/dev/null; then
    fail "a destructive delete call reached the scripting layer"
  elif grep -q '^KIND: mutate$' "$RUN_LOG" 2>/dev/null; then
    fail "a mutating save call reached the scripting layer"
  else
    pass "no delete or save call reached the scripting layer"
  fi
}

count_kind() {
  grep -c "^KIND: $1\$" "$RUN_LOG" 2>/dev/null || echo 0
}

echo "== CONTACTS-001 safety fixture =="
echo

# ---------------------------------------------------------------------------
# Unsafe delete inputs must fail closed.
# ---------------------------------------------------------------------------

run_case "delete with no argument" no_match -- delete
assert_nonzero_exit
assert_no_destructive_call

run_case "delete with empty query" no_match -- delete ""
assert_nonzero_exit
assert_no_destructive_call

run_case "delete with unknown query" no_match -- delete --yes "no-such-person"
assert_nonzero_exit
assert_no_destructive_call

run_case "delete with unknown id" no_match -- delete --yes --id "NOT-A-REAL-ID"
assert_nonzero_exit
assert_no_destructive_call

run_case "delete with ambiguous query" multi_match -- delete --yes "Ada"
assert_nonzero_exit
assert_no_destructive_call

run_case "delete with unknown flag" no_match -- delete --yes --bogus x
assert_nonzero_exit
assert_no_destructive_call

run_case "delete when jxa fails" jxa_failure -- delete --yes "Ada Lovelace"
assert_nonzero_exit
assert_no_destructive_call

run_case "delete reporting failure is not success" delete_reports_failure -- delete --yes --id "ID-1"
assert_nonzero_exit

# ---------------------------------------------------------------------------
# Unsafe edit inputs must fail closed.
# ---------------------------------------------------------------------------

run_case "edit with no argument" no_match -- edit
assert_nonzero_exit
assert_no_destructive_call

run_case "edit with empty query" no_match -- edit ""
assert_nonzero_exit
assert_no_destructive_call

run_case "edit with unknown query" edit_no_match -- edit "no-such-person" --first Ada
assert_nonzero_exit

run_case "edit with unknown flag" no_match -- edit "Ada" --bogus x
assert_nonzero_exit
assert_no_destructive_call

run_case "edit when jxa fails" jxa_failure -- edit "Ada Lovelace" --first Ada
assert_nonzero_exit

# ---------------------------------------------------------------------------
# The one authorized path: a resolved-ID delete deletes exactly that ID.
# ---------------------------------------------------------------------------

run_case "resolved-id delete" resolved_delete -- delete --yes --id "ID-1"
assert_zero_exit

delete_calls=$(count_kind delete)
if [ "$delete_calls" -eq 1 ]; then
  pass "exactly one delete call was made"
else
  fail "expected exactly 1 delete call, got $delete_calls"
fi

# The delete call must carry the resolved ID as its trailing argument, and the
# trailing argument must be exactly that ID.
delete_argv=$(awk '
  /^=== CALL$/ { argv=""; body="" }
  /^ARGV: /    { argv=substr($0, 7) }
  /^KIND: delete$/ { print argv }
' "$RUN_LOG")

delete_target=${delete_argv##* }

if [ "$delete_target" = "ID-1" ]; then
  pass "the delete call targeted exactly ID-1"
else
  fail "delete call targeted '$delete_target' (full argv: '$delete_argv'), expected 'ID-1'"
fi

if grep -q 'ID-2' "$RUN_LOG"; then
  fail "an unrelated contact ID appeared in the delete path"
else
  pass "no unrelated contact ID reached the delete path"
fi

# The successful delete payload must be the one that saves.
if grep -q 'app.save()' "$RUN_LOG"; then
  pass "the delete payload saved the database"
else
  fail "the delete payload never saved"
fi

if grep -q '"deleted": true' "$RUN_OUT"; then
  pass "reported a successful deletion"
else
  fail "did not report a successful deletion (output: $(cat "$RUN_OUT"))"
fi

echo
echo "passed: $PASS_COUNT  failed: $FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ] || exit 1
echo "CONTACTS-001 safety fixture passed."
