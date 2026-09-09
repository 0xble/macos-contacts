# Maintenance

## Background

Maintained fork: `0xble/macos-contacts` of `Sheldenshi/macos-contacts`; the
maintained branch is `main`. The named upstream branch means upstream's live default
branch, resolved on every run before fetching; it is not statically pinned to `main`.
Canonical checkout: `/Users/brianle/Repos/macos-contacts`.
Accepted upstream baseline: `7521bb193677b1f4208bc0558710093bff0e123b` (fetched
2026-09-09). Publish only to `origin`; never push to `upstream`.

## Preserve

- Contact selection/mutation uses resolved IDs, rejects unsafe empty or unknown
  arguments, and returns failure exits rather than silent success.
- JXA shell compatibility and `--json`/`list` CLI behavior survive reconciliation;
  source sync, publication, installation, and runtime activation are separate
  stages requiring separate authorization and proof.

## Active patches

### CONTACTS-001: `fix(contacts): harden jxa invocation`

- **Status:** Active; source difference confirmed against upstream's then-current
  default branch on 2026-09-09.
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

- **Status:** Active; source difference confirmed against upstream's then-current
  default branch on 2026-09-09.
- **Provenance:** `b5f2c98885ac8dad522eef84461ec1be46391f11`; **surfaces/invariant:**
  `contacts` accepts `--json`, exposes `list`, and rejects other unknown flags.
- **Proof:** `bash -n contacts && ./contacts --help`; **rollback:** revert this
  commit after command-interface equivalence is verified.
- **Upstream issue/PR:** untracked; audit 2026-09-09 recorded none. **Retire when:**
  released upstream supplies this command contract and focused proof passes.

### CONTACTS-003: `fix(fork): install contacts script and smoke verify`

- **Status:** Active; source difference confirmed against upstream's then-current
  default branch on 2026-09-09.
- **Provenance:** `45f72694b27f20f366c4def163f2ac5f3f027040`; **surfaces/invariant:**
  `bin/{upgrade,smoke}` preserve the fork install/smoke contract without making it
  part of source synchronization.
- **Proof:** `sh -n bin/upgrade bin/smoke && make -n install`; **rollback:** revert
  the provenance commit. **Upstream issue/PR:** untracked; audit 2026-09-09 recorded none.
- **Retire when:** a separately authorized runtime migration removes the fork path.

## Update

Every run resolves upstream's live default branch before fetching it, then fetches
`origin` and `upstream` separately, reconciles `main` onto latest
`upstream/$UPSTREAM_DEFAULT`, preserves only recorded active patches, and runs the
listed proof plus `make -n install` before authorized publication. For CONTACTS-001,
the missing isolated behavioral fixture blocks source-sync success (not merely
publication) until the required mock acceptance procedure passes. Update this
register with any patch addition/change/retirement; missing or stale coverage blocks
publication. Immediately before `Updated` or `Already current`, resolve and fetch
upstream's live default branch again and require zero upstream-only commits; otherwise
report `Blocked` with exact failed stage, refs, and evidence. Publish to `origin` or
report that concrete blocker.

## Verify

```text
UPSTREAM_DEFAULT="$(git ls-remote --symref upstream HEAD | awk '/^ref:/ {sub("refs/heads/", "", $2); print $2; exit}')"
test -n "$UPSTREAM_DEFAULT"
git fetch --prune upstream "refs/heads/$UPSTREAM_DEFAULT:refs/remotes/upstream/$UPSTREAM_DEFAULT"
git diff --check
git rev-list --left-right --count "upstream/$UPSTREAM_DEFAULT...main"
```

A fresh final fetch must show zero upstream-only commits; after authorized
publication local `main` and `origin/main` must have identical SHAs. Installed or
runtime proof is required only when separately authorized.
