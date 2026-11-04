# Launch runbook

[English](./launch-runbook.md) ・ [简体中文](./launch-runbook.zh-CN.md)

Follow this once and an agent can take over the [launch stack](./launch-stack.md).
**Part A is once** (about 30 minutes); **part B is per product** (about 10
minutes). The scripts are in [`scripts/launch/`](../scripts/launch/) and run in
Cloud Shell as the owner, so project creation works without a Cloud
organization.

Doubo is the worked example; a new product only changes the arguments.

## Before you start

1. Sign in with the Google account that manages the product's GA4 (for Doubo,
   the one that can open GA4 property 558471154).
2. Open <https://console.firebase.google.com> once and accept the terms;
   otherwise adding Firebase returns 403.
3. Open Cloud Shell (<https://shell.cloud.google.com>) and get the scripts:

   ```bash
   git clone https://github.com/maweis1981/agents-md && cd agents-md/scripts/launch
   ```

   Until PR #9 merges, add `-b claude/blissful-planck-pdki67` to the clone.

## A. Once: the growth-ops identity

### A1. Run the setup script

```bash
bash setup-growth-ops.sh --key
```

It creates the `growth-ops-xxxx` project, enables the APIs, creates
`launch-agent@growth-ops-xxxx.iam.gserviceaccount.com`, and writes the key to
`~/launch-agent.json.b64`. Note the **project id** and the **service-account
email**.

### A2. GA4

Nothing to do: part B adds the account as Administrator on the GA4 account.
If the script says it could not, add it by hand: GA4 → Admin → **Account**
access management → the service-account email → Administrator.

### A3. GTM

<https://tagmanager.google.com> → the account that holds the product's
containers (Doubo: `GTM-NDPJBD6N`) → Admin → **User management** → add the
service-account email: account permission User, all containers **Publish**.

### A4. Google Play

Play Console → **Users and permissions** → Invite new users → the
service-account email, with these **account** permissions:

- View app information
- Manage store presence
- Manage orders and subscriptions
- View financial data
- Release to testing tracks
- Release to production

### A5. App Store Connect

App Store Connect → **Users and Access** → **Integrations** → App Store
Connect API → **Team Keys** → generate one with the **App Manager** role.

- Note the **Issuer ID** and **Key ID**.
- Download `AuthKey_XXXX.p8`. It can be downloaded only once.

### A6. Store the credentials in the Claude cloud environment

Session title bar → the cloud environment menu → **Edit** → environment
variables (or Network secrets, where offered):

| Variable | Value |
| --- | --- |
| `LAUNCH_GCP_SA_JSON_B64` | the output of `cat ~/launch-agent.json.b64` in Cloud Shell |
| `ASC_ISSUER_ID` | the Issuer ID from A5 |
| `ASC_KEY_ID` | the Key ID from A5 |
| `ASC_KEY_P8_B64` | the output of `base64 -w0 AuthKey_XXXX.p8` |

Then **delete the local copies**: `rm ~/launch-agent.json.b64` and the
downloaded `.p8`. New sessions pick the variables up.

**Never paste these values into a chat, an issue or a repository.**

### A7. Let the agent use them

The Claude Code auto-mode check refuses credential use it was not told about.
Either:

- **Each session:** say at the start, "this session may use the `LAUNCH_*` and
  `ASC_*` credentials for launch work".
- **Permanently:** add the launch commands to `permissions.allow` in the product
  repository's `.claude/settings.json` and commit it. Only sessions with that
  one repository attached read this file.

Paid or irreversible actions (campaigns, prices, review submissions) still ask
you first.

## B. Per product: the Google setup in one command

### B1. Run the bootstrap script (Doubo's values)

```bash
bash bootstrap-product.sh \
  --slug doubo --name "Doubo" --project doubo-prod \
  --sa launch-agent@growth-ops-xxxx.iam.gserviceaccount.com \
  --ga4-property 558471154 --domain doubo.tv \
  --bundle-id com.maweis1981.streamline --app-store-id 6821588266 \
  --package tv.doubo.streamline --activation-event playback_start
```

The first run stops and prints two commands that grant the GA4 scopes:
`gcloud auth application-default login …` (approve in the browser), then
`set-quota-project`. Run both, then run the bootstrap command again.

It then does, in order:

1. creates `doubo-prod`;
2. makes the service account Owner on it;
3. adopts GA4 property 558471154 and adds the service account as GA4
   Administrator;
4. adds Firebase to the project and **links it to that property** (no second
   property);
5. adds the iOS and Android apps, which appear in GA4 as two app streams;
6. checks the web stream and sets 14-month retention;
7. marks the key events `first_open`, `purchase` and `playback_start`;
8. registers the custom dimensions.

It ends with a `launch.yaml` block, and writes both config files to
`~/launch-out/`.

**New product without a GA4 property:** replace `--ga4-property` with
`--ga4-account <numeric GA4 account id>`. The script creates the property; set
its time zone and currency with `--timezone` and `--currency`.

### B2. The three remaining manual steps

1. **AdMob → Firebase:** AdMob → Apps → each app → App settings → link to
   Firebase project `doubo-prod`. Do it for iOS and for Android. Ad revenue then
   flows into GA4.
2. **BigQuery export:** GA4 → Admin → Product links → BigQuery links → choose
   `doubo-prod`, Daily.
3. **Tell the agent you're done** and paste the `launch.yaml` block (ids only,
   not secrets). No need to download the config files: the agent fetches them
   from Firebase with the service account.

The agent then:

- writes and validates `launch.yaml`;
- places the config files in the iOS and Android projects;
- wires analytics on all three surfaces per `launch-analytics` (off by default
  until you confirm);
- runs the GTM and Search Console steps of `launch-google-stack`.

## Verify

- [ ] Firebase console → Project settings → Integrations → Google Analytics
      shows property 558471154.
- [ ] GA4 → Admin → Data streams lists web, iOS and Android.
- [ ] GA4 → Admin → Key events lists `first_open`, `purchase` and
      `playback_start`.
- [ ] The service account is an Administrator in GA4 account access management.
- [ ] Running the bootstrap script again prints only "exists" / "already"
      lines and creates nothing.

## Common errors

| Error | Cause and fix |
| --- | --- |
| `addFirebase` 403 | Firebase terms not accepted (see "Before you start", step 2), or you are not Owner of the project |
| `addGoogleAnalytics` 403 | Your account cannot edit that GA4 account, or the property is already linked to another Firebase project |
| "Firebase is linked to …, not …" | The project is linked to a different property. One property per product: unlink it in the Firebase console, then re-run |
| `accessBindings` fails | You are not a GA4 account administrator, or the ADC login lacked the `analytics.manage.users` scope. Add the account by hand (A2) |
| Key creation fails with `disableServiceAccountKeyCreation` | Your account belongs to an organization with that policy. Turn it off for the `growth-ops` project, or use Workload Identity Federation |
| An operation is still running after 10 polls | Re-run later; finished steps are skipped |
