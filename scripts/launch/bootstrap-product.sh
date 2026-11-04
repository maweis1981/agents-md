#!/usr/bin/env bash
# Per-product Google setup for the launch stack (docs/launch-runbook.md,
# step B). Run it in Google Cloud Shell, signed in as the owner, after
# setup-growth-ops.sh. Safe to re-run: every step reuses what exists.
#
# It does, for one product:
#   1. the GCP project (created by the owner's identity, no Cloud org needed)
#   2. the launch-agent service account as Owner on that project
#   3. the GA4 property: adopt --ga4-property, or create one under --ga4-account
#   4. launch-agent as Administrator on the GA4 account
#   5. Firebase on the project, linked to that GA4 property
#   6. the iOS and Android Firebase apps (their GA4 app streams) + config files
#   7. GA4: web stream, 14-month retention, key events, custom dimensions
# and prints the ids as a launch.yaml block.
#
# Usage (Doubo as the example):
#   bash bootstrap-product.sh \
#     --slug doubo --name "Doubo" --project doubo-prod \
#     --sa launch-agent@growth-ops-xxxx.iam.gserviceaccount.com \
#     --ga4-property 558471154 --domain doubo.tv \
#     --bundle-id com.maweis1981.streamline --app-store-id 6821588266 \
#     --package tv.doubo.streamline --activation-event playback_start
#
# New product without a GA4 property: replace --ga4-property with
#   --ga4-account <numeric account id> [--timezone Asia/Taipei] [--currency USD]
#
# GA4 calls need Analytics scopes, so the first run asks once for:
#   gcloud auth application-default login --scopes=...   (printed below)

set -euo pipefail

SLUG="" NAME="" PROJECT="" SA="" GA_PROPERTY="" GA_ACCOUNT="" DOMAIN=""
BUNDLE="" APPSTORE="" PACKAGE="" ACTIVATION="" TZ_NAME="Etc/UTC" CURRENCY="USD"
OUT_DIR="$HOME/launch-out"
while [ $# -gt 0 ]; do
  case "$1" in
    --slug) SLUG="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --sa) SA="$2"; shift 2 ;;
    --ga4-property) GA_PROPERTY="${2#properties/}"; shift 2 ;;
    --ga4-account) GA_ACCOUNT="${2#accounts/}"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    --bundle-id) BUNDLE="$2"; shift 2 ;;
    --app-store-id) APPSTORE="$2"; shift 2 ;;
    --package) PACKAGE="$2"; shift 2 ;;
    --activation-event) ACTIVATION="$2"; shift 2 ;;
    --timezone) TZ_NAME="$2"; shift 2 ;;
    --currency) CURRENCY="$2"; shift 2 ;;
    --out) OUT_DIR="$2"; shift 2 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done
[ -n "$SLUG" ] && [ -n "$SA" ] || { echo "--slug and --sa are required (see --help)" >&2; exit 2; }
[ -n "$GA_PROPERTY" ] || [ -n "$GA_ACCOUNT" ] || { echo "give --ga4-property or --ga4-account" >&2; exit 2; }
NAME="${NAME:-$SLUG}"; PROJECT="${PROJECT:-$SLUG-prod}"
OPS_PROJECT="${SA#*@}"; OPS_PROJECT="${OPS_PROJECT%%.iam.gserviceaccount.com}"
mkdir -p "$OUT_DIR"

say() { printf '\n▶ %s\n' "$*"; }
for c in gcloud jq curl; do command -v "$c" >/dev/null || { echo "missing $c" >&2; exit 1; }; done

FB="https://firebase.googleapis.com/v1beta1"
GA="https://analyticsadmin.googleapis.com/v1beta"
GA_ALPHA="https://analyticsadmin.googleapis.com/v1alpha"

# api METHOD URL TOKEN [JSON] -> body on stdout; non-2xx -> body on stderr, exit 1
api() {
  local method="$1" url="$2" token="$3" body="${4:-}" resp code
  local args=(-sS -X "$method" "$url" -H "Authorization: Bearer $token"
    -H "x-goog-user-project: $OPS_PROJECT" -H "Content-Type: application/json" -w $'\n%{http_code}')
  [ -n "$body" ] && args+=(--data "$body")
  resp="$(curl "${args[@]}")"
  code="${resp##*$'\n'}"; resp="${resp%$'\n'*}"
  if [ "$code" -ge 200 ] && [ "$code" -lt 300 ]; then printf '%s' "$resp"; else
    printf '%s %s -> %s\n%s\n' "$method" "$url" "$code" "$resp" >&2; return 1; fi
}

# wait_op OPERATION_NAME TOKEN -> waits (at most 10 polls) for a Firebase operation
wait_op() {
  local op="$1" token="$2" i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if [ "$(api GET "$FB/$op" "$token" | jq -r '.done // false')" = "true" ]; then
      api GET "$FB/$op" "$token" | jq -e '.error == null' >/dev/null \
        || { api GET "$FB/$op" "$token" >&2; return 1; }
      return 0
    fi
    sleep $((i * 3))
  done
  echo "operation $op still running after 10 polls; re-run the script later" >&2; return 1
}

CLOUD_TOKEN="$(gcloud auth print-access-token)"
GA_TOKEN="$(gcloud auth application-default print-access-token 2>/dev/null || true)"
if [ -z "$GA_TOKEN" ] || ! api GET "$GA/accountSummaries?pageSize=1" "$GA_TOKEN" >/dev/null 2>&1; then
  cat >&2 <<EOF
GA4 steps need Analytics scopes. Run once, then re-run this script:

  gcloud auth application-default login --scopes=openid,https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/analytics.edit,https://www.googleapis.com/auth/analytics.manage.users
  gcloud auth application-default set-quota-project $OPS_PROJECT
EOF
  exit 1
fi

# 1. Project --------------------------------------------------------------------
if gcloud projects describe "$PROJECT" >/dev/null 2>&1; then say "Project $PROJECT exists"; else
  say "Creating project $PROJECT"; gcloud projects create "$PROJECT" --name="$NAME"; fi
gcloud services enable --project "$PROJECT" firebase.googleapis.com \
  firebaseinstallations.googleapis.com analyticsadmin.googleapis.com bigquery.googleapis.com

# 2. launch-agent owns the product project ---------------------------------------
say "Granting $SA Owner on $PROJECT"
gcloud projects add-iam-policy-binding "$PROJECT" --member="serviceAccount:$SA" \
  --role="roles/owner" --condition=None >/dev/null

# 3. GA4 property ------------------------------------------------------------------
if [ -z "$GA_PROPERTY" ]; then
  GA_PROPERTY="$(api GET "$GA/properties?filter=parent:accounts/$GA_ACCOUNT&pageSize=200" "$GA_TOKEN" \
    | jq -r --arg n "$NAME" '.properties[]? | select(.displayName==$n) | .name' | head -1)"
  GA_PROPERTY="${GA_PROPERTY#properties/}"
  if [ -z "$GA_PROPERTY" ]; then
    say "Creating GA4 property $NAME"
    GA_PROPERTY="$(api POST "$GA/properties" "$GA_TOKEN" "$(jq -nc --arg p "accounts/$GA_ACCOUNT" \
      --arg n "$NAME" --arg tz "$TZ_NAME" --arg c "$CURRENCY" \
      '{parent:$p, displayName:$n, timeZone:$tz, currencyCode:$c}')" | jq -r '.name')"
    GA_PROPERTY="${GA_PROPERTY#properties/}"
  fi
fi
GA_ACCOUNT="$(api GET "$GA/properties/$GA_PROPERTY" "$GA_TOKEN" | jq -r '.parent')"
GA_ACCOUNT="${GA_ACCOUNT#accounts/}"
say "GA4 property $GA_PROPERTY (account $GA_ACCOUNT)"

# 4. launch-agent as GA4 account Administrator ---------------------------------------
if api GET "$GA_ALPHA/accounts/$GA_ACCOUNT/accessBindings?pageSize=200" "$GA_TOKEN" \
    | jq -e --arg u "$SA" '.accessBindings[]? | select(.user==$u)' >/dev/null; then
  say "$SA already has GA4 access"
else
  say "Granting $SA Administrator on GA4 account $GA_ACCOUNT"
  api POST "$GA_ALPHA/accounts/$GA_ACCOUNT/accessBindings" "$GA_TOKEN" \
    "$(jq -nc --arg u "$SA" '{user:$u, roles:["predefinedRoles/admin"]}')" >/dev/null \
    || echo "  ↳ add it by hand: GA4 Admin → Account access management → $SA (Administrator)"
fi

# 5. Firebase + GA4 link -------------------------------------------------------------
if api GET "$FB/projects/$PROJECT" "$CLOUD_TOKEN" >/dev/null 2>&1; then
  say "$PROJECT is already a Firebase project"
else
  say "Adding Firebase to $PROJECT"
  wait_op "$(api POST "$FB/projects/$PROJECT:addFirebase" "$CLOUD_TOKEN" '{}' | jq -r '.name')" "$CLOUD_TOKEN"
fi
LINKED="$(api GET "$FB/projects/$PROJECT/analyticsDetails" "$CLOUD_TOKEN" 2>/dev/null \
  | jq -r '.analyticsProperty.id // empty' || true)"
if [ -z "$LINKED" ]; then
  say "Linking Firebase to GA4 property $GA_PROPERTY"
  wait_op "$(api POST "$FB/projects/$PROJECT:addGoogleAnalytics" "$CLOUD_TOKEN" \
    "$(jq -nc --arg p "$GA_PROPERTY" '{analyticsPropertyId:$p}')" | jq -r '.name')" "$CLOUD_TOKEN"
elif [ "${LINKED#properties/}" != "$GA_PROPERTY" ]; then
  echo "✗ Firebase is linked to $LINKED, not $GA_PROPERTY. One property per product: fix by hand." >&2; exit 1
else
  say "Firebase already linked to GA4 property $GA_PROPERTY"
fi

# 6. Apps and config files ---------------------------------------------------------------
IOS_APP="" ANDROID_APP=""
if [ -n "$BUNDLE" ]; then
  IOS_APP="$(api GET "$FB/projects/$PROJECT/iosApps" "$CLOUD_TOKEN" \
    | jq -r --arg b "$BUNDLE" '.apps[]? | select(.bundleId==$b) | .appId' | head -1)"
  if [ -z "$IOS_APP" ]; then
    say "Adding iOS app $BUNDLE"
    wait_op "$(api POST "$FB/projects/$PROJECT/iosApps" "$CLOUD_TOKEN" "$(jq -nc --arg b "$BUNDLE" \
      --arg n "$NAME iOS" --arg s "$APPSTORE" '{bundleId:$b, displayName:$n} + (if $s=="" then {} else {appStoreId:$s} end)')" \
      | jq -r '.name')" "$CLOUD_TOKEN"
    IOS_APP="$(api GET "$FB/projects/$PROJECT/iosApps" "$CLOUD_TOKEN" \
      | jq -r --arg b "$BUNDLE" '.apps[]? | select(.bundleId==$b) | .appId' | head -1)"
  fi
  api GET "$FB/projects/$PROJECT/iosApps/$IOS_APP/config" "$CLOUD_TOKEN" \
    | jq -r '.configFileContents' | base64 -d >"$OUT_DIR/GoogleService-Info.plist"
  say "iOS app $IOS_APP → $OUT_DIR/GoogleService-Info.plist"
fi
if [ -n "$PACKAGE" ]; then
  ANDROID_APP="$(api GET "$FB/projects/$PROJECT/androidApps" "$CLOUD_TOKEN" \
    | jq -r --arg p "$PACKAGE" '.apps[]? | select(.packageName==$p) | .appId' | head -1)"
  if [ -z "$ANDROID_APP" ]; then
    say "Adding Android app $PACKAGE"
    wait_op "$(api POST "$FB/projects/$PROJECT/androidApps" "$CLOUD_TOKEN" "$(jq -nc --arg p "$PACKAGE" \
      --arg n "$NAME Android" '{packageName:$p, displayName:$n}')" | jq -r '.name')" "$CLOUD_TOKEN"
    ANDROID_APP="$(api GET "$FB/projects/$PROJECT/androidApps" "$CLOUD_TOKEN" \
      | jq -r --arg p "$PACKAGE" '.apps[]? | select(.packageName==$p) | .appId' | head -1)"
  fi
  api GET "$FB/projects/$PROJECT/androidApps/$ANDROID_APP/config" "$CLOUD_TOKEN" \
    | jq -r '.configFileContents' | base64 -d >"$OUT_DIR/google-services.json"
  say "Android app $ANDROID_APP → $OUT_DIR/google-services.json"
fi

# 7. GA4 configuration -----------------------------------------------------------------------
STREAMS="$(api GET "$GA/properties/$GA_PROPERTY/dataStreams?pageSize=50" "$GA_TOKEN")"
WEB_STREAM=""
if [ -n "$DOMAIN" ]; then
  WEB_STREAM="$(jq -r --arg d "$DOMAIN" '.dataStreams[]? | select(.type=="WEB_DATA_STREAM")
    | select((.webStreamData.defaultUri // "") | test("//(www\\.)?" + ($d|gsub("\\.";"\\.")) + "/?$"))
    | .webStreamData.measurementId' <<<"$STREAMS" | head -1)"
  if [ -z "$WEB_STREAM" ]; then
    say "Creating web stream https://$DOMAIN"
    WEB_STREAM="$(api POST "$GA/properties/$GA_PROPERTY/dataStreams" "$GA_TOKEN" "$(jq -nc --arg d "$DOMAIN" \
      '{type:"WEB_DATA_STREAM", displayName:$d, webStreamData:{defaultUri:("https://"+$d)}}')" \
      | jq -r '.webStreamData.measurementId')"
    STREAMS="$(api GET "$GA/properties/$GA_PROPERTY/dataStreams?pageSize=50" "$GA_TOKEN")"
  fi
fi

say "GA4 retention: 14 months"
api PATCH "$GA/properties/$GA_PROPERTY/dataRetentionSettings?updateMask=eventDataRetention" "$GA_TOKEN" \
  '{"eventDataRetention":"FOURTEEN_MONTHS"}' >/dev/null || true

EXISTING_KEYS="$(api GET "$GA/properties/$GA_PROPERTY/keyEvents?pageSize=200" "$GA_TOKEN" | jq -r '.keyEvents[]?.eventName')"
for ev in first_open purchase $ACTIVATION; do
  if grep -qx "$ev" <<<"$EXISTING_KEYS"; then continue; fi
  say "Key event $ev"
  api POST "$GA/properties/$GA_PROPERTY/keyEvents" "$GA_TOKEN" \
    "$(jq -nc --arg e "$ev" '{eventName:$e, countingMethod:"ONCE_PER_EVENT"}')" >/dev/null || true
done

EXISTING_DIMS="$(api GET "$GA/properties/$GA_PROPERTY/customDimensions?pageSize=200" "$GA_TOKEN" \
  | jq -r '.customDimensions[]? | "\(.scope):\(.parameterName)"')"
for d in EVENT:method EVENT:trigger EVENT:feature EVENT:error_class EVENT:placement EVENT:source USER:plan; do
  if grep -qx "$d" <<<"$EXISTING_DIMS"; then continue; fi
  say "Custom dimension $d"
  api POST "$GA/properties/$GA_PROPERTY/customDimensions" "$GA_TOKEN" "$(jq -nc \
    --arg s "${d%%:*}" --arg p "${d#*:}" '{scope:$s, parameterName:$p, displayName:$p}')" >/dev/null || true
done

stream_of() { jq -r --arg t "$1" '.dataStreams[]? | select(.type==$t) | .name' <<<"$STREAMS" | head -1; }

# Summary --------------------------------------------------------------------------------------
cat <<EOF

✓ $NAME bootstrapped. Paste into launch.yaml (google: block):

google:
  gcp_project: $PROJECT
  ga4:
    account: accounts/$GA_ACCOUNT
    property: properties/$GA_PROPERTY
    streams:
      web: ${WEB_STREAM:-null}
      ios: $(stream_of IOS_APP_DATA_STREAM)
      android: $(stream_of ANDROID_APP_DATA_STREAM)
    bigquery_export: false
  firebase:
    project: $PROJECT
    ios_app: ${IOS_APP:-null}
    android_app: ${ANDROID_APP:-null}

Config files: $OUT_DIR (commit them into the app repos; they are not secrets).
Still by hand: BigQuery link (GA4 Admin → Product links), AdMob → each app →
link to Firebase project $PROJECT, GTM container (launch-google-stack step 6).
EOF
