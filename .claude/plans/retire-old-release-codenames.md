# Retire Old Release Codenames (focal, jammy, oracular)

Remove the retired Ubuntu codenames from `release.infrahouse.com.tf`, **one at a time**, keeping
only **noble**. Same spirit as the GPG-rotation runbook: staged, each step verified before the
next, and explicit about what's destroyed and what depends on it.

## Context

`release.infrahouse.com.tf` builds one `debian-repo` per codename via a `for_each` over
`local.supported_codenames = ["focal", "jammy", "noble", "oracular"]` (module
`registry.infrahouse.com/infrahouse/debian-repo/aws` **3.2.0** — note: still the single
`gpg_public_key` input, *not* 4.0.0's `gpg_public_keys` list).

Retiring a codename = removing its element from that list. Because the `for_each` key is the
codename string (a `toset`), Terraform destroys **only** `module.release_infrahouse_com["<codename>"]`
and its children — noble and the others are untouched (no index-shift risk). Verify that in every
plan anyway.

## ⚠️ What each removal destroys (and irreversibility)

Removing one codename destroys that module instance's resources:
- **S3 content bucket** `infrahouse-release-<codename>` — and `bucket_force_destroy = true`, so it
  is deleted **even though it holds the published `.deb` packages + repo metadata**. That package
  history is **gone** (not just the infra). Treat as irreversible.
- S3 access-logs bucket, CloudFront distribution + OAC + cache policy, the HTTP-auth function.
- **Route53** `release-<codename>.infrahouse.com` A record → the URL starts returning NXDOMAIN/404.
- **ACM** certificate (us-east-1) + validation records.
- **Secrets Manager** `packager-key-<codename>` and `packager-passphrase-<codename>` (the signing
  key + passphrase). The `infrahouse/secret/aws` module governs the deletion/recovery window —
  check whether they're recoverable or force-deleted before you apply.
- The globally-unique S3 bucket name `infrahouse-release-<codename>` is released on delete.

**Rollback reality:** re-adding the codename + restoring `files/DEB-GPG-KEY-infrahouse-<codename>`
and re-applying recreates the *infrastructure*, but **not the packages** (bucket was force-destroyed)
and not the old signing key/secret values. So the real safety is the pre-flight gate below, not
rollback.

## Pre-flight gate (run BEFORE removing each codename)

Do not remove a codename until all of these are clear **for that codename**:

- [ ] **No live consumers.** Nothing still has `deb … release-<codename>.infrahouse.com …` in its
  `sources.list`. cloud-init already dropped focal/jammy/oracular (only `noble` is allowed in
  `terraform-aws-cloud-init`), but check for legacy long-lived instances / AMIs / one-off boxes.
- [ ] **No recent traffic.** CloudFront/S3 access logs for the bucket show no meaningful `apt`
  fetches over a recent window (e.g. last 30 days).
- [ ] **No code/doc references** to `release-<codename>.infrahouse.com` in other repos
  (puppet-code, terraform-aws-cloud-init, docs, external READMEs). Grep the org.
- [ ] **Not mid-rotation.** The noble GPG rotation is a *separate* change on a different codename;
  don't interleave. Land codename removals when no noble rotation apply/export is in flight.

## Removal procedure (repeat per codename, one at a time)

For `CODENAME` in the chosen order:

- [ ] Pre-flight gate above passes for `CODENAME`.
- [ ] Remove `"CODENAME"` from `local.supported_codenames` in `release.infrahouse.com.tf`.
- [ ] `git rm files/DEB-GPG-KEY-infrahouse-CODENAME` (now orphaned).
- [ ] `terraform plan` — **confirm the plan destroys ONLY `module.release_infrahouse_com["CODENAME"]`
  resources** (bucket, logs bucket, CloudFront, OAC, cache policy, auth fn, Route53 record, ACM
  cert + validation, `packager-key-CODENAME` / `packager-passphrase-CODENAME`). No changes to
  `["noble"]` or any remaining codename. If anything else shows up, stop.
- [ ] Apply.
- [ ] Verify destroyed: `dig +short release-CODENAME.infrahouse.com` → empty; `aws s3 ls
  s3://infrahouse-release-CODENAME` → gone; secrets no longer listed (or in pending-deletion).
- [ ] Verify **unaffected**: `noble` (and any not-yet-removed codenames) still resolve and
  `apt-get update` clean against them.
- [ ] Commit as its own PR (one codename per PR → small, reviewable, easy to bisect).

## Suggested order (adjust to your fleet knowledge)

Least-risk / least-likely-to-have-consumers first, so any surprise dependency surfaces on the
lowest-stakes repo:

1. [ ] **oracular** — 24.10 interim release, already EOL; least likely to have anything pinned.
2. [ ] **focal** — 20.04, oldest; keys already expired, cloud-init dropped it long ago.
3. [ ] **jammy** — 22.04 LTS; most likely to still have a straggler, so do it last with the most
   scrutiny.

(Order is independent — `for_each` keys by codename — so this is purely about surfacing surprises
gently, not a technical constraint.)

## Notes / interaction with the GPG rotation

- This is orthogonal to the noble key rotation (`terraform-aws-debian-repo` runbook): that touches
  only `noble`. Keeping the two changes in separate PRs avoids a scary combined plan.
- This account still pins `debian-repo` **3.2.0** (`gpg_public_key`). The noble rotation will need
  a bump to **4.0.0** (`gpg_public_keys` list) — a separate change; don't bundle it with codename
  removals.
- After all three are gone, `supported_codenames` should be `["noble"]` and only
  `files/DEB-GPG-KEY-infrahouse-noble` should remain.

## Cross-references
- GPG rotation runbook: `terraform-aws-debian-repo/.claude/plans/gpg-key-rotation-design.local.md`
- Publish-race caveat (relevant if applying near a repo publish): terraform-aws-debian-repo#43