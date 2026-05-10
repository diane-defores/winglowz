---
artifact: technical_runbook
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "VoiceFlowz"
created: "2026-05-10"
updated: "2026-05-10"
status: reviewed
source_skill: sf-docs
scope: "firebase-firestore-ci-oidc"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "GitHub Actions"
  - "Google Cloud IAM"
  - "Workload Identity Federation"
  - "Firebase CLI"
  - "Cloud Firestore"
next_step: "Reuse this runbook for new repos before adding any Firebase deploy job."
---

# Firebase Firestore CI OIDC Playbook

This runbook is the canonical setup for deploying Firestore rules/indexes from
GitHub Actions without long-lived JSON keys.

## Target Outcome

- GitHub Action authenticates with Google using OIDC/WIF.
- Firestore deploy runs with short-lived credentials.
- No `firebase login` in CI.
- No service account private key in GitHub secrets.

## Required GitHub Secrets

- `FIREBASE_PROJECT_ID` (example: `winflowz-dev`)
- `GCP_WIF_PROVIDER`
- `GCP_WIF_SERVICE_ACCOUNT`

Expected `GCP_WIF_PROVIDER` format:

`projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID`

Do not prefix with `https://` or `//iam.googleapis.com/`.

## Required Workflow Pattern

In `.github/workflows/android-build.yml` (or equivalent deploy workflow):

1. Add job permissions:
   - `id-token: write`
   - `contents: read`
2. Authenticate with `google-github-actions/auth@v3`.
3. Use `token_format: access_token` when passing token to `firebase-tools`.
4. Export `FIREBASE_TOKEN` from `steps.<auth-id>.outputs.access_token`.
5. Deploy with:
   - `firebase deploy --only firestore --project "$FIREBASE_PROJECT_ID" --non-interactive`

## GCP Setup Checklist

1. Create project (or use existing).
2. Enable APIs:
   - `iam.googleapis.com`
   - `iamcredentials.googleapis.com`
   - `sts.googleapis.com`
   - `firebase.googleapis.com`
   - `firestore.googleapis.com`
3. Create deploy service account:
   - example: `github-firestore-deploy@<project>.iam.gserviceaccount.com`
4. Create WIF pool/provider (GitHub issuer):
   - issuer: `https://token.actions.githubusercontent.com`
5. Grant service account roles on project:
   - minimum for this runbook started with `roles/firebase.admin`
6. Grant principal permissions on the service account:
   - `roles/iam.workloadIdentityUser`
   - `roles/iam.serviceAccountTokenCreator`

## Repository Binding

Recommended repo binding member:

`principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/attribute.repository/OWNER/REPO`

If repository ownership/name changed, update:

- WIF provider attribute condition
- service account IAM member bindings

## Failure Matrix (Observed)

1. Error:
   `invalid_target` in `google-github-actions/auth`
   Fix:
   `GCP_WIF_PROVIDER` malformed. Use exact provider resource name.

2. Error:
   `unauthorized_client` / rejected by attribute condition
   Fix:
   provider condition does not match actual repo (`OWNER/REPO`) used by run.

3. Error:
   `iam.serviceAccounts.getAccessToken denied`
   Fix:
   missing `roles/iam.serviceAccountTokenCreator` on target service account for
   the federated principal.

4. Error:
   `Failed to authenticate, have you run firebase login?`
   Fix:
   pass `FIREBASE_TOKEN` from OIDC auth action access token (or use explicit
   credentials file path flow).

5. Error:
   `Permissions denied enabling firestore.googleapis.com`
   Fix:
   enable API as project admin before CI deploy.

6. Error:
   Firestore index `HTTP 400 this index is not necessary`
   Fix:
   remove unnecessary composite/single-field-equivalent indexes from
   `firestore.indexes.json` and redeploy.

## Reuse Steps for New Project

1. Copy the workflow OIDC deploy pattern.
2. Recreate WIF pool/provider for the new repo.
3. Set new GitHub secrets for project/provider/service-account.
4. Enable Firebase/Firestore APIs before first deploy.
5. Run deploy workflow and resolve index file validity errors first.

## Security Hardening After First Green Run

1. Narrow IAM bindings from pool-wide principals to exact repository principal.
2. Keep strict provider attribute conditions (`assertion.repository` and, if
   needed, `assertion.ref` for main branch only).
3. Replace broad admin role with least-privilege custom role once deploy
   permissions are confirmed.
