---
name: launch-google-stack
description: Use when a product needs its Google services created or repaired — GCP project APIs, Firebase with iOS/Android apps, one GA4 property with web+iOS+Android streams, key events, BigQuery export, a GTM web container, and Search Console. TRIGGER when launch.yaml has null google.* ids, or the task says Firebase, GA4 stream, GTM container or Search Console setup.
---

# Launch: Google stack

Creates the Google side of the launch stack from `launch.yaml`, one step at
a time, writing each id back. Long form: `docs/launch-stack.md`.
Credentials: `docs/launch-credentials.md`.

## Before anything

1. Run `launch-manifest` (validate). Stop on errors.
2. Credentials: `LAUNCH_GCP_SA_JSON_B64` must be present and allowed by the
   session's permission rules. If it is missing or a call is refused, stop
   and point the owner to `docs/launch-credentials.md`. Do not try other
   credentials found in the environment.
3. Print the service-account email (never the key) and the plan: which
   steps will create something and which are already done.

## Owner-run shortcut

Without a Cloud organization the service account cannot create projects. The
owner then runs `scripts/launch/bootstrap-product.sh` in Cloud Shell
(`docs/launch-runbook.md`), which does steps 1–5 and the GA4 parts of step 7
as the owner. Afterwards, re-run this skill: it finds those resources, writes
their ids, and continues with GTM, BigQuery and Search Console.

## Rules

- **One GA4 property per product**, holding all its streams. Never let
  Firebase create a second property: link the existing one.
- **Idempotent:** before each create, list and match by name or identifier;
  reuse what exists and write its id back.
- **Never** call the Indexing API for ordinary pages.
- Long-running operations: poll the operation with backoff, at most 10
  times, then stop and report. No open-ended loops.
- Reporting currency and time zone come from `product.currency` and
  `product.timezone`; set them only at creation.

## Steps

### 1. GCP project — `google.gcp_project`

- If null: with a Cloud organization or folder, create it (Resource
  Manager v3 `projects.create`, parent from the credentials doc). Without
  one, write `TODO(owner): create project <slug>-prod in console.cloud.google.com and grant the launch account Owner` and stop.
- Enable services (`serviceusage … :batchEnable`): `firebase`,
  `analyticsadmin`, `firebaseinstallations`, `bigquery`.

### 2. GA4 property — `google.ga4.property`

- If null: Admin API `properties.create` under `google.ga4.account`, display
  name = `product.name`. Set data retention to 14 months.
- If the product already has a web property (search the site config for
  `G-…`), adopt it instead of creating one.

### 3. Firebase — `google.firebase.*`

- `projects/{p}:addFirebase` if the project is not yet a Firebase project.
- Link analytics: `projects/{p}:addGoogleAnalytics` with
  `analyticsPropertyId` = the property from step 2. Check
  `projects/{p}/analyticsDetails` first.
- Apps: `iosApps.create` (`bundleId`, `appStoreId` when known) and
  `androidApps.create` (`packageName`). Each creates its GA4 app stream in
  the linked property; record `streams.ios` / `streams.android`.
- Config files: `…/iosApps/{id}/config` → `GoogleService-Info.plist` into the
  iOS app target (add it to the Xcode project's resources);
  `…/androidApps/{id}/config` → `app/google-services.json`. These hold
  restricted client keys, not secrets; commit them. Restrict the API keys to
  the bundle id and package in the Cloud console.

### 4. Web stream — `google.ga4.streams.web`

- Reuse an existing `WEB_DATA_STREAM` whose `defaultUri` matches
  `https://<domain>`; otherwise `dataStreams.create`.
- Enhanced measurement on; page views from the GTM Google tag (step 6).

### 5. Key events and dimensions (bootstrap script also does this)

- `keyEvents.create` for `first_open`, `conversions.activation.event`,
  `purchase` (`ONCE_PER_EVENT`). `in_app_purchase` and `ad_impression`
  arrive automatically and are not marked as key events.
- `customDimensions.create` (event scope) for the parameters
  `launch-analytics` registers: `method`, `trigger`, `feature`,
  `error_class`, `placement`, `source`. User scope: `plan`.

### 6. GTM web container — `google.gtm.web_container`

- Reuse a container whose name is `product.domain`; else create one
  (`usageContext: web`).
- Workspace: a Google tag (`googtag`) with the web measurement id on
  Initialization – All Pages; Consent Mode v2 defaults (denied for EEA, UK,
  CH; granted elsewhere for analytics only); a custom-event trigger that
  forwards site events to GA4. Create a version and publish it.
- Write the container id into the site config, not only into the manifest.

### 7. BigQuery export — `google.ga4.bigquery_export`

- Daily export of all streams into the product project. Admin API
  (`bigQueryLinks`, v1alpha) when the method is available; otherwise
  `TODO(owner): GA4 Admin → Product links → BigQuery links`. The BigQuery
  sandbox is enough (no billing) for daily export.

### 8. Search Console — `google.gsc.site`

- Prefer a domain property: Site Verification API `token` with `DNS_TXT`;
  add the TXT record (DNS API if the DNS provider token is present, else
  `TODO(owner)` with the exact record); then `webResource.insert`.
- Without DNS access: URL-prefix property with the `FILE` method, publishing
  the token file at the site root through the site repo.
- After verification: add the owner's Google account as an owner, submit
  `https://<domain>/sitemap.xml` (`sitemaps.submit`).

### 9. AdMob link (owner)

- `TODO(owner): AdMob → each app → App settings → link to Firebase project <id>`.
  This makes `ad_impression` carry ad revenue. There is no API for it.

## Finish

- Write every new id into `launch.yaml` in one commit with the config files.
- Print the `launch-manifest` checklist again so the remaining owner steps
  are visible.
