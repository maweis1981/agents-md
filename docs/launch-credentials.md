# Launch credentials

[English](./launch-credentials.md) ・ [简体中文](./launch-credentials.zh-CN.md)

The one-time setup that lets an agent run the [launch stack](./launch-stack.md)
skills against every product, without a new grant per product. The owner does
this once; afterwards each new product only adds itself to resources the
identity already reaches.

## The identity

One Google Cloud project owned by the owner, used only for operations:
`growth-ops` (any id). Inside it, one service account:
`launch-agent@growth-ops.iam.gserviceaccount.com`. The agent uses this
account for every Google API. Nothing else runs in that project.

Apple and the ad networks do not accept Google identities, so they get their
own keys (below).

Step by step, with scripts that do the Google part: [launch runbook](./launch-runbook.md).

## Grants

| Where | Grant | Why |
| --- | --- | --- |
| Google Cloud | Enable on `growth-ops`: Cloud Resource Manager, Service Usage, Firebase Management, Google Analytics Admin, Tag Manager, Search Console, Site Verification, Google Play Android Developer, BigQuery | The service account calls these APIs from its own project |
| Google Cloud, per product | `Owner` on each product's GCP project (or `Firebase Admin` + `Service Usage Admin` + `BigQuery Admin`) | Add Firebase, apps, the BigQuery export |
| Google Cloud, project creation | With a Cloud organization or folder: `Project Creator` on it. **Without one** (a personal Google account), a service account cannot create projects: the owner creates each product project in the console (one click) and grants the account `Owner` on it | Projects need a parent for service-account creation |
| GA4 | **Account** access management → add the account as `Administrator` on each GA4 account that holds product properties (Firebase "Users and permissions" and Cloud IAM do **not** grant GA4 access) | Properties, streams, key events, links |
| GTM | Account → User management → add the account with `Publish` on all containers | Create and publish web containers |
| Search Console | After the agent verifies a site with the account, it becomes an owner; add the owner's own Google account as owner too | Sitemaps and reports |
| Google Play | Play Console → Users and permissions → invite the account with account-level permissions: manage store presence, manage products, release apps, view financial data | Products, listings, Data safety, releases |
| App Store Connect | Users and Access → Integrations → **Team key** with role `App Manager`; keep the issuer id, key id and `.p8` file | Products, prices, localizations, builds |
| Google Ads | A manager (MCC) account, a developer token, and an OAuth client with a refresh token for the owner | Conversion actions and GA4 import; Google Ads does not accept service accounts directly |
| Apple Search Ads | Account settings → API → add a user with `API Account Manager`, upload a public key | Campaigns and attribution reports |

## Where the secrets live

- **Cloud sessions:** environment secrets of the cloud environment, one per
  value: `LAUNCH_GCP_SA_JSON_B64`, `ASC_ISSUER_ID`, `ASC_KEY_ID`,
  `ASC_KEY_P8_B64`, `GOOGLE_ADS_DEVELOPER_TOKEN`, `GOOGLE_ADS_REFRESH_TOKEN`,
  `GOOGLE_ADS_CLIENT_ID`, `GOOGLE_ADS_CLIENT_SECRET`, `ASA_*`.
- **Local sessions:** the owner's keychain or password manager, exported into
  the shell only for the session.
- Never in a repository, a manifest, an issue, a PR, or a log line. Skills
  print the account email, never key material.

## Let the agent use them

A Claude Code auto-mode permission check refuses an agent that reads a
credential it was not explicitly allowed to use ("Credential Exploration").
Allow exactly these, in the user or project settings
(`.claude/settings.json` → `permissions.allow`), and nothing broader:

- reading the `LAUNCH_*`, `ASC_*`, `GOOGLE_ADS_*` and `ASA_*` variables;
- outbound calls to `*.googleapis.com`, `oauth2.googleapis.com`,
  `api.appstoreconnect.apple.com`, `googleads.googleapis.com` and
  `api.searchads.apple.com`.

Paid or irreversible actions still need a human in the turn: creating ad
campaigns, setting budgets, submitting a build for review, changing prices
on a live product.

## Rotation

- Rotate the service-account key and the App Store Connect key every 90
  days, or immediately if one is pasted anywhere it should not be.
- Remove the account from a product's GA4 account, GTM container and Play
  app when the product is retired.
