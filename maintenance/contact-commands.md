# Safe contact commands

Part of the [root maintenance contract](../MAINTENANCE.md). Read the root's
accepted baseline and shared adoption/publication rules before this unit.
Load for every full maintenance run or changes to this responsibility.

### CONTACTS-001: `fix(contacts): harden jxa invocation`

- **Provenance:** `d8b6f9e7902776136b94379758519f17bd6c53d3` through
  `5c0222ea83e406c572c48e38dc5f08f8052ff47e`.
- **Surfaces/invariant:** `contacts`; safe JXA invocation, non-empty matching,
  resolved-delete IDs, and failing edit/delete operations must not mutate the
  wrong contact or report success.
- **Proof:** `bash -n contacts && ./contacts --help` is structural only. Before any
  future source-sync success, an isolated `OSASCRIPT_BIN` mock fixture is required:
  drive empty/unknown edit and delete inputs plus a failed JXA response; assert a
  nonzero exit and no `delete`/`save` mock call, then drive one resolved-ID delete
  and assert exactly that ID is deleted and saved. This behavioral fixture is missing,
  so reconciliation may report `Blocked` but must not report sync success until it
  exists and passes. **Rollback:** revert the relevant contiguous hardening commits
  only after this safe-fixture proof.
- **Upstream issue/PR:** untracked; audit 2026-09-09 recorded none, not an absence
  claim. Live-check and type direct/associated/related before altering this family.
- **Retire when:** released upstream passes the same safe-fixture proof without
  the fork changes.

### CONTACTS-002: `feat(contacts): accept --json no-op, add list subcommand, reject unknown flags`

- **Provenance:** `b5f2c98885ac8dad522eef84461ec1be46391f11`; **surfaces/invariant:**
  `contacts` accepts `--json`, exposes `list`, and rejects other unknown flags.
- **Proof:** `bash -n contacts && ./contacts --help`; **rollback:** revert this
  commit after command-interface equivalence is verified.
- **Upstream issue/PR:** untracked; audit 2026-09-09 recorded none. **Retire when:**
  released upstream supplies this command contract and focused proof passes.

## Update and verification

Compare the candidate upstream implementation with each retained behavior above.
Keep its provenance and adoption/retirement decision with this unit when it changes.
Run the focused proof named above and the root verification gate before claiming
maintenance success.
