# Fork distribution

Part of the [root maintenance contract](../MAINTENANCE.md). Read the root's
accepted baseline and shared adoption/publication rules before this unit.
Load for every full maintenance run or changes to this responsibility.

### CONTACTS-003: `fix(fork): install contacts script and smoke verify`

- **Provenance:** `45f72694b27f20f366c4def163f2ac5f3f027040`; **surfaces/invariant:**
  `bin/{upgrade,smoke}` preserve the fork install/smoke contract without making it
  part of source synchronization.
- **Proof:** `sh -n bin/upgrade bin/smoke && make -n install`; **rollback:** revert
  the provenance commit. **Upstream issue/PR:** untracked; audit 2026-09-09 recorded none.
- **Retire when:** a separately authorized runtime migration removes the fork path.

## Update and verification

Compare the candidate upstream implementation with each retained behavior above.
Keep its provenance and adoption/retirement decision with this unit when it changes.
Run the focused proof named above and the root verification gate before claiming
maintenance success.
