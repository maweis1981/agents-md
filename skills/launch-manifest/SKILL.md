---
name: launch-manifest
description: Use when starting a new product, or before any launch-stack work (analytics, stores, ads, search), to create or validate the product's launch.yaml and print what is still missing. TRIGGER when a repo has no launch.yaml and the task touches GA4, Firebase, GTM, Search Console, App Store Connect, Google Play, AdMob or attribution.
---

# Launch manifest

`launch.yaml` at the product repository root is the single source of truth
for the product's identity and every external resource id. Long form:
`docs/launch-stack.md`. Template: `templates/launch.yaml`.

## When the file is missing

1. Copy `templates/launch.yaml` to the repo root.
2. Fill what the repository already knows. Search before asking:
   - bundle id: `PRODUCT_BUNDLE_IDENTIFIER` in `*.xcodeproj/project.pbxproj`
   - package: `applicationId` / `namespace` in `app/build.gradle(.kts)`
   - domain: `CNAME`, `_config.yml` `url`, `next.config.*`, Pages settings
   - GA4 / GTM ids: `G-…` and `GTM-…` in site config or analytics docs
   - AdMob ids: `GADApplicationIdentifier`, the manifest `APPLICATION_ID`, `app-ads.txt`
   - store ids: App Store links (`apps.apple.com/…/id<digits>`), Play links (`id=<package>`)
3. Leave the rest as `null`, or `TODO(owner): <what> — <console path>` when
   only the owner can produce it (app records, AdMob ad units).
4. Commit it with the change that first needs it. Do not open a PR for the
   manifest alone.

## Validate (every launch-stack task starts here)

- `version: 1`; `product.slug` is lowercase `[a-z0-9-]`; `product.domain`
  has no scheme or path.
- Bundle id and package are reverse-DNS and match the code.
- `conversions` has exactly `first_open`, `activation`, `purchase`,
  `ad_revenue`; `activation.event` is set before analytics ships.
- Only `first_open`, `activation`, `purchase` may have `import: true`.
- `ads.live` and `monetization.live` match the flags in the apps.
- No credentials, tokens, keys or emails other than service-account ids.

## Report

After validating, print a short checklist grouped by owner:

- **Agent can do now** (credentials present, ids missing).
- **Owner must do** (each `TODO(owner)` with its console path).
- **Done** (ids present and verified).

## Writing back

- A skill that creates a resource writes its id here in the same change.
- Never overwrite a non-null id with a different one. Stop and ask: two ids
  means a duplicate resource exists.
- Keep comments in the file; edit values in place.
