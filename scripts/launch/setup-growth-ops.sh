#!/usr/bin/env bash
# One-time setup of the growth-ops identity for the launch stack
# (docs/launch-runbook.md, step A). Run it in Google Cloud Shell, signed in
# as the owner. Safe to re-run: it creates only what is missing.
#
# Usage:
#   bash setup-growth-ops.sh [--project growth-ops-xxxx] [--key]
#
#   --project  id of the operations project (default: growth-ops-<6 random>,
#              reused if a project named "growth-ops" already exists)
#   --key      also create a JSON key for the service account and write it,
#              base64-encoded, to ~/launch-agent.json.b64 (store it as the
#              LAUNCH_GCP_SA_JSON_B64 secret, then delete the file)

set -euo pipefail

SA_NAME="launch-agent"
PROJECT=""
MAKE_KEY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="$2"; shift 2 ;;
    --key) MAKE_KEY=1; shift ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

say() { printf '\n▶ %s\n' "$*"; }
need() { command -v "$1" >/dev/null || { echo "missing $1 (run this in Cloud Shell)" >&2; exit 1; }; }
need gcloud; need jq

OWNER="$(gcloud config get-value account 2>/dev/null)"
[ -n "$OWNER" ] || { echo "not signed in: run gcloud auth login" >&2; exit 1; }
echo "Signed in as $OWNER"

# 1. Operations project -------------------------------------------------------
if [ -z "$PROJECT" ]; then
  PROJECT="$(gcloud projects list --filter='name=growth-ops' --format='value(projectId)' | head -1)"
fi
if [ -z "$PROJECT" ]; then
  PROJECT="growth-ops-$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"
fi
if gcloud projects describe "$PROJECT" >/dev/null 2>&1; then
  say "Project $PROJECT exists"
else
  say "Creating project $PROJECT"
  gcloud projects create "$PROJECT" --name="growth-ops"
fi

# 2. APIs the agent calls from this project ----------------------------------
say "Enabling APIs on $PROJECT"
gcloud services enable --project "$PROJECT" \
  cloudresourcemanager.googleapis.com serviceusage.googleapis.com iam.googleapis.com \
  firebase.googleapis.com analyticsadmin.googleapis.com analyticsdata.googleapis.com \
  tagmanager.googleapis.com searchconsole.googleapis.com siteverification.googleapis.com \
  androidpublisher.googleapis.com bigquery.googleapis.com

# 3. Service account ----------------------------------------------------------
SA="${SA_NAME}@${PROJECT}.iam.gserviceaccount.com"
if gcloud iam service-accounts describe "$SA" --project "$PROJECT" >/dev/null 2>&1; then
  say "Service account $SA exists"
else
  say "Creating service account $SA"
  gcloud iam service-accounts create "$SA_NAME" --project "$PROJECT" \
    --display-name="Launch agent (growth-ops)"
fi
# Lets the account use this project's API quota when it calls Google APIs.
gcloud projects add-iam-policy-binding "$PROJECT" --member="serviceAccount:$SA" \
  --role="roles/serviceusage.serviceUsageConsumer" --condition=None >/dev/null

# 4. Key (optional) -------------------------------------------------------------
if [ "$MAKE_KEY" = 1 ]; then
  OUT="$HOME/launch-agent.json.b64"
  TMP="$(mktemp)"
  say "Creating a key for $SA"
  gcloud iam service-accounts keys create "$TMP" --iam-account "$SA" --project "$PROJECT"
  base64 -w0 "$TMP" >"$OUT"
  rm -f "$TMP"
  chmod 600 "$OUT"
  echo "Wrote $OUT (base64). Store its contents as LAUNCH_GCP_SA_JSON_B64, then: rm $OUT"
fi

# 5. What only the owner can do -------------------------------------------------
cat <<EOF

✓ growth-ops ready
  project:          $PROJECT
  service account:  $SA

Next (docs/launch-runbook.md):
  A2  GA4: bootstrap-product.sh grants this account Administrator on each
      product's GA4 account, or add it by hand in GA4 Admin → Account access.
  A3  GTM: Tag Manager → Admin → User management → add $SA (Publish).
  A4  Play Console → Users and permissions → invite $SA.
  A5  App Store Connect → Users and Access → Integrations → Team key (App Manager).
  A6  Store the secrets in the Claude cloud environment (never in a repo).
EOF
