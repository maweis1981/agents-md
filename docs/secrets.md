# Secrets & Credentials

> How AI agents handle `.env`, tokens, and cloud credentials.
> 中文：[`secrets.zh-CN.md`](./secrets.zh-CN.md)

AI agents touching shell, Git and cloud APIs make the secret-handling
attack surface much bigger than a normal team. Most "AI-caused
incidents" trace back to one of three things below.

## Hard rules

1. **No long-lived personal access tokens (PATs) for CI or agents.**
   Use OpenID Connect (OIDC) short-lived tokens — GitHub Actions, AWS,
   GCP, Azure and Vercel all support it.
2. **`.env` is never committed.** Add it to `.gitignore`; commit a
   `.env.example` with placeholder names.
3. **Secrets never appear in logs.** No `console.log(process.env)`,
   no `printenv | tee debug.log`. Mask before logging.
4. **One secret, one purpose.** Don't reuse a database password as an
   API key.
5. **Rotate on every credential leak**, even suspected ones. Don't
   debate it.
6. **Agents must not be able to print, copy, or upload secrets.**
   Wire your agent's tool list with this in mind.

## OIDC for short-lived cloud credentials

Long-lived AWS access keys / GCP service-account JSON files / Vercel
deploy tokens stored in a repo Secret are the #1 thing rotated after
an AI agent leak. Replace them.

### GitHub Actions → AWS

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123:role/gh-deploy
      aws-region: us-east-1
```

The IAM role trusts GitHub's OIDC provider and is scoped to the repo
and branch. No long-lived secret needed.

### GitHub Actions → GCP

`google-github-actions/auth@v2` with `workload_identity_provider`.

### Vercel / Cloudflare / Netlify

All expose project-scoped deploy tokens issued at deploy time. Avoid
shoving them into repo Secrets when the platform's CI integration
already handles auth.

## `.env` discipline

```
.env             # local, never committed
.env.local       # local, never committed
.env.example     # placeholders, committed
.env.production  # ONLY if values are non-sensitive; otherwise use platform secrets
```

`.gitignore` must contain at minimum:

```
.env
.env.local
.env.*.local
```

The agent must read `.env.example` to learn what variables exist, but
never read or echo `.env`.

## Pre-commit secret scanning

Set up `gitleaks` or `trufflehog` as a pre-commit hook:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.0
    hooks:
      - id: gitleaks
```

GitHub also offers **Push Protection** under Secret Scanning — turn
it on. It rejects pushes that contain known secret patterns.

## Production secrets live in environment scopes

For GitHub Actions, follow [`github-settings.md`](./github-settings.md):

- Production secrets stored as **environment secrets** scoped to a
  protected `production` environment.
- The `production` environment requires manual approval to deploy.
- Preview / staging environments hold separate, less-privileged
  secrets.

Never store a production DB password as a repo-level Actions secret.

## Forbidden agent behaviors

- Printing `process.env` or `os.environ` to console for "debugging".
- Reading `.env` into a chat session prompt to "understand the
  environment".
- Committing `.env.local` "by accident" because auto-commit was on.
- Adding a real secret to `.env.example` "so it works".
- Sending a `.env` file as an attachment / paste to any external
  service (including the agent's own API).

## When a leak happens

1. **Rotate immediately**, before any forensics.
2. **Audit the agent session** that touched the credential.
3. **Disable the affected agent's tool access** until rotation is
   complete.
4. **Search history for re-leaks**: `git log -p -- .env*` and
   `git log -p -G '<known leaked prefix>'`.
5. If a secret reached a public repo / paste site, treat as
   compromised even after rotation — services may have cached it.

## Reference

- [GitHub OIDC docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [OWASP Secret Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [`github-settings.md`](./github-settings.md) for the repo-level
  setup that backs these rules.
