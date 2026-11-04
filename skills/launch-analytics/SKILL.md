---
name: launch-analytics
description: Use when adding, renaming or reviewing product analytics events on web, iOS or Android — enforces one canonical event taxonomy across platforms, an Analytics facade with Firebase/GA4 behind it, consent defaults, value/currency rules and GA4 naming limits. TRIGGER on code that logs analytics events, on analytics SDK setup, or on funnel/conversion definitions.
---

# Launch: analytics

One event language for every surface of a product, sent to the product's
single GA4 property (web through GTM, apps through Firebase). Long form:
`docs/launch-stack.md`. Property and streams: `launch-google-stack`.

## Architecture

- Product code calls an **`Analytics` facade** with typed events. It never
  calls Firebase, gtag or GTM directly.
- **Sinks** behind the facade: Firebase Analytics (apps), `dataLayer` push
  (web, GTM forwards to GA4), a debug sink that logs to the console in
  development builds, and a no-op sink while consent is denied.
- One events file per surface, mirroring the table below. A new event is
  added to all surfaces' files in the same PR, even if only one emits it yet.
- Apps: no Google Tag Manager for mobile. Web: keep GTM.

## Canonical events

| Funnel | Event | Parameters | Notes |
| --- | --- | --- | --- |
| Activation | `first_open` | — | Automatic (Firebase). Web: not sent. |
| Activation | product's activation event | per product | Named in `launch.yaml` `conversions.activation.event`, e.g. `playback_start`. |
| Activation | `sign_up` / `login` | `method` | Only if the product has accounts. |
| Monetization | `gate_hit` | `feature` | A free limit refused an action. |
| Monetization | `paywall_view` | `trigger` (a `feature` or `settings`) | |
| Monetization | `purchase_start` | `product_id` | |
| Monetization | `in_app_purchase` | automatic | Firebase logs StoreKit and Play Billing purchases with value and currency. Never log by hand. |
| Monetization | `purchase` | `value`, `currency`, `transaction_id`, `items` | Web and license-key purchases only (apps get `in_app_purchase`). |
| Monetization | `purchase_fail` | `reason` (`cancelled`, `pending`, `error`) | |
| Monetization | `restore` | `result` | |
| Ads | `ad_impression` | automatic | From the AdMob ↔ Firebase link, with revenue. Never log by hand. |
| Ads | `remove_ads_tap` | `placement` | |
| Errors | `<domain>_error` | `error_class` | A short enum, never a raw message. |
| Web → app | `cta_click` | `target`, `location` | Store links carry `utm_source/medium/campaign`. |

Product-specific events follow the same shape: `noun_verb` past or present,
one meaning per name.

## Naming and limits (GA4)

- `snake_case`, ≤ 40 characters, starts with a letter. Not prefixed
  `firebase_`, `google_`, `ga_`. Do not reuse automatic names.
- ≤ 25 parameters per event; parameter names ≤ 40 characters; string values
  ≤ 100 characters.
- Parameters used in reports are registered as custom dimensions
  (`launch-google-stack` step 5). Standard properties allow 50 event-scoped
  dimensions: register only what a report needs.
- User properties: `plan` (`free` | `pro` | `tester`); add others only when
  a decision depends on them. ≤ 25, names ≤ 24 characters.

## Value and currency

- Money always travels as `value` (decimal number) + `currency` (ISO 4217,
  the currency the user paid in). Never a formatted string, never cents.
- Keep test money out of reports: do not log `purchase` for sandbox,
  TestFlight or license-test purchases, and check in DebugView whether the
  platform's automatic `in_app_purchase` arrives for them; if it does, mark
  test installs with a `plan`-like user property (`tester`) and filter it.
- Ad revenue is never estimated in the app; it comes from the AdMob link.

## Privacy and consent

- Never send URLs, stream or playlist addresses, file names, search text,
  emails, names, or free text. Enums and counts only.
- Consent defaults: analytics **denied** in the EEA, the UK and Switzerland
  until the user agrees; granted elsewhere. Ads storage and personalization
  denied by default everywhere until the consent flow (UMP on apps) says
  otherwise.
- A Settings toggle turns analytics off on every surface
  (`setAnalyticsCollectionEnabled(false)` on apps).
- iOS: no IDFA, no App Tracking Transparency prompt; link Firebase Analytics
  without ad-id support.
- Android: no `AD_ID` permission unless ads are live (`launch-monetization`).
- The release that first ships analytics also updates: the App Store App
  Privacy answers, the Play Data safety form, and the privacy policy in every
  site locale.

## Dormant until configured

- Without the Firebase config file (`GoogleService-Info.plist`,
  `google-services.json`) the facade uses the debug/no-op sink and the app
  builds and runs unchanged.
- Debug builds send to the same property only through DebugView
  (`-FIRDebugEnabled` / `adb shell setprop debug.firebase.analytics.app <package>`);
  never point debug builds at production without debug mode.

## Verify before merging

- Each new event appears in DebugView with its parameters on each surface
  that emits it.
- A test asserts that the events file of each surface lists the same names.
- No parameter value can contain user-entered text.
