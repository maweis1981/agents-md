# Launch stack

[English](./launch-stack.md) ・ [简体中文](./launch-stack.zh-CN.md)

How an agent stands up the services around a new product (website, search,
analytics, app stores, ads and attribution) from one manifest, and how it
re-runs the same steps safely later. The skills that do the work are
`launch-manifest`, `launch-google-stack` and `launch-analytics` (first
batch); see [the skill map](#skill-map).

## The end state

Work backwards from what a product must have on launch day:

| Area | Launch-day state |
| --- | --- |
| Website | SEO and GEO baseline (sitemap, robots, hreflang, JSON-LD, `llms.txt`), consent banner with Consent Mode v2, GTM, `app-ads.txt` published |
| Search | Google Search Console site verified, sitemap submitted |
| Analytics | One GA4 property with three data streams (web, iOS, Android); Firebase linked; key events marked; BigQuery daily export on |
| Stores | App Store Connect and Google Play: in-app products, localized listings, privacy declarations |
| Monetization | Paywall, entitlements and ads built but **dormant** behind flags; Pro removes ads |
| Attribution | Conversions with value and currency imported into Google Ads; SKAdNetwork and Apple Search Ads on iOS; Play Install Referrer on Android |
| Monitoring | Realtime and DebugView for development; a daily SEO/GEO/GA4 report; a funnel dashboard |

## Domain model: `launch.yaml`

Every product repository keeps one manifest at its root,
[`launch.yaml`](../templates/launch.yaml). It is the single source of truth
for the product's identity and for every external resource id.

- **Product**: name, domain, locales.
- **Surfaces**: `web`, `ios`, `android` (and `windows` when present), each
  with its platform identity (bundle id, package name, store ids).
- **Bindings**: one block per external service, holding the ids the skills
  create (GCP project, GA4 property and streams, Firebase apps, GTM
  container, GSC site, AdMob apps and units, store products).
- **Conversions**: the product's canonical funnel events, which of them carry
  value, and which are imported into ad platforms.

Rules:

- Skills read the manifest, create only what is missing, and write the new
  ids back. A second run changes nothing (idempotent).
- Ids are not secrets and are committed. Credentials never go in the
  manifest or the repository (see [launch credentials](./launch-credentials.md)).
- A field the agent cannot fill automatically is left as `TODO(owner): …`
  with the console path, so the remaining manual work is always visible.

## What can be automated

| Service | By API (agent) | Manual (owner, usually once per account) |
| --- | --- | --- |
| Google Cloud | Enable APIs, IAM on the project | Creating a project needs an organization or folder for a service account; without one the owner creates the project |
| Firebase | Add Firebase to the project, add iOS and Android apps, download their config, link GA4 | — |
| GA4 | Properties, web streams, key events, custom dimensions, Google Ads and BigQuery links, Measurement Protocol secrets | Accepting the data-sharing terms on a new account |
| GTM (web) | Containers, tags, triggers, variables, versions, publish | — |
| Search Console | Add the site, verify it (DNS TXT or HTML file), submit sitemaps | — |
| App Store Connect | In-app purchases and subscriptions, prices, localizations, builds, review submission | Creating the app record, the App Privacy questionnaire, agreements, tax and banking |
| Google Play | In-app products and subscriptions, listings, Data safety, releases | Creating the app, the Advertising ID declaration |
| AdMob | Reporting | Apps, ad units, Privacy & messaging (GDPR and US-state consent) |
| Google Ads | Conversion actions, GA4 import, campaigns | Account and billing |
| Apple Search Ads | Campaigns and keywords | Account and billing |
| DNS (e.g. Cloudflare) | Verification records | — |

## Canonical conversions and value

The event names and parameters live in the `launch-analytics` skill. The
conversion rules every product follows:

- `purchase` carries `value` and `currency` (the currency the user paid in).
  Sandbox and test purchases are excluded. On mobile, Firebase logs
  `in_app_purchase` automatically for StoreKit and Play Billing; do not log
  it again by hand.
- Ad revenue comes from linking AdMob to Firebase (`ad_impression` with
  value). Do not log it by hand.
- Only three conversions are imported into ad platforms: `first_open`, the
  product's **activation** event (its first valuable action), and
  `purchase`. Importing more confuses bidding.
- SKAdNetwork conversion values (0–63) use one scheme across products: the
  low bit is activation, the higher bits are revenue buckets.

## Lessons from the first product (Doubo)

These are rules, not suggestions:

- Never push ordinary pages through the Google Indexing API, and never
  publish thousands of near-identical generated pages. Doubo lost about 95%
  of its Google impressions overnight; these two were the likeliest causes.
- Publish `app-ads.txt` before linking apps in AdMob, or the first
  verification fails and has to be retried.
- The ads SDK adds the advertising-id permission on Android. Remove it while
  ads are dormant so the Play declarations stay true, and test that the
  manifest matches the flag.
- Consent is denied by default in the EEA, the UK and Switzerland.
- iOS never requests the IDFA (no App Tracking Transparency prompt).
- Free allowances start counting on go-live day, not during free releases.
- Never run CI on macOS runners for a private repository (10× cost). Give
  Android CI enough timeout headroom for the release build.

## Skill map

| Skill | Status | Does |
| --- | --- | --- |
| `launch-manifest` | first batch | Create and validate `launch.yaml`; print the per-product checklist |
| `launch-google-stack` | first batch | GCP, Firebase, GA4 streams, BigQuery export, GTM web container, GSC |
| `launch-analytics` | first batch | Canonical events, the analytics facade on each surface, consent, value rules |
| `launch-web-seo` | next | Website SEO/GEO baseline and indexing guardrails |
| `launch-store-apple` | next | App Store Connect products, localizations, privacy checklist |
| `launch-store-play` | next | Play products, listing, Data safety, Advertising ID |
| `launch-monetization` | next | Dormant paywall, entitlements and ads; Pro removes ads |
| `launch-attribution` | next | Ads conversion import, SKAdNetwork, Apple Search Ads, Install Referrer |
| `growth-daily-report` | next | The daily SEO/GEO/GA4 report, configured from `launch.yaml` |

## Rollout

1. The owner sets up the growth-ops identity once and bootstraps the first
   product ([launch runbook](./launch-runbook.md), with scripts).
2. Pilot the first batch on an existing product and fix what breaks.
3. Extract the remaining skills from that product's working code.
4. Run the whole set end to end on the next new product.
