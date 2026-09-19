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

## Maintenance units

The root is the sole enrollment and scheduling unit. A full maintenance run
accounts for every row, including no-change reviews. Scoped changes load their
unit and named dependencies before acting.

| Unit | Purpose / required behavior | Load when | Contract |
| --- | --- | --- | --- |
| Safe contact commands | Safe JXA mutation and compatible argument handling | Every full run or changes to this responsibility | [Safe contact commands](maintenance/contact-commands.md) |
| Fork distribution | Fork installation and smoke verification | Every full run or changes to this responsibility | [Fork distribution](maintenance/distribution.md) |

All entries are active. Source differences were confirmed against upstream
then-current default branch on 2026-09-09. The contact-command behavioral fixture
gap remains a source-sync blocker, as specified in Update and its unit.

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

A fresh final fetch must show zero upstream-only commits; after authorized
publication local `main` and `origin/main` must have identical SHAs. Installed or
runtime proof is required only when separately authorized.
