# One-time S3 Batch Replication back-fill (noble release bucket)

**Operational follow-up to the `debian-repo` 4.0.0 / CRR migration.** Not a blocker for the GPG
rotation; do it once the CRR apply is confirmed.

## Why

`debian-repo` 4.0.0 enabled S3 cross-region replication on `infrahouse-release-noble` (via the
`infrahouse/s3-bucket` module, `replication_region`). **CRR only replicates objects created *after*
it's enabled** — the existing ~3 GB of noble package contents (the whole current repo: pool/,
dists/, Packages, Release, etc.) will **not** back-fill to the replica automatically. Until we
back-fill, the DR replica does not actually protect the current repo.

Fix: run **S3 Batch Replication** once. It walks existing object versions and replicates them using
the bucket's existing replication rule.

## Prerequisites (confirm from the apply output first)

- [ ] CRR apply succeeded; the **replica bucket** exists (confirm exact name — the `s3-bucket`
  module names it; check the plan/state, don't assume). Same for the **logs** replica if you care
  about logs DR.
- [ ] **Versioning enabled on both** source and replica (module sets `enable_versioning = true` on
  the repo bucket; the replica is created versioned).
- [ ] The **replication rule is Enabled** on `infrahouse-release-noble` and points at the replica.
- [ ] An IAM role for the **Batch Operations job** (can reuse the replication role if its trust
  policy allows `batchoperations.s3.amazonaws.com`, else create one) with replicate permissions on
  source + destination.

## Procedure

**Easiest — console:** S3 → **Batch Operations** → *Create job* → Region = source region
(us-west-1) → *Manifest*: **"Create manifest using S3 Replication configuration"** → Operation:
**Replicate** → pick the batch IAM role → Run. S3 generates the manifest of existing, not-yet-
replicated objects itself.

**CLI equivalent** (`aws s3control create-job … --operation '{"S3ReplicateObject":{}}'` with a
generated manifest). Confirm account id, source bucket ARN, and role ARN before running:
```bash
ACCOUNT=493370826424 ; REGION=us-west-1 ; SRC=infrahouse-release-noble
aws s3control create-job --account-id "$ACCOUNT" --region "$REGION" \
  --operation '{"S3ReplicateObject":{}}' \
  --report '{"Enabled":false}' \
  --priority 10 --role-arn "arn:aws:iam::$ACCOUNT:role/<batch-ops-role>" \
  --manifest-generator "{\"S3JobManifestGenerator\":{\"SourceBucket\":\"arn:aws:s3:::$SRC\",\"EnableManifestOutput\":false,\"Filter\":{\"EligibleForReplication\":true}}}" \
  --no-confirmation-required --description "one-time CRR backfill: noble existing objects"
```
(`EligibleForReplication: true` limits the job to objects the replication rule covers that haven't
replicated yet.)

## Verify

- [ ] Job completes with ~0 failed tasks (check the job report / status).
- [ ] Object/version counts roughly match between source and replica
  (`aws s3api list-objects-v2 --bucket <src|replica> --query 'length(Contents)'`), or spot-check a
  few `pool/` and `dists/` keys exist on the replica.
- [ ] Replica `Release`/`InRelease`/`Packages.gz` present.

## Notes

- Volume is small (~3 GB) → the job is quick and cheap; cross-region transfer + PUT costs are
  negligible one-time.
- After this, steady-state CRR keeps the replica current on every publish — no repeat needed.
- Do the same for any other buckets you want DR'd (logs), if applicable.