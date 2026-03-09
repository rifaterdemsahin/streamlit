# Environment Configuration

This document lists every configuration value that must be set to run, deploy, and operate this project end-to-end. All secrets are stored as **GitHub Actions repository secrets** at:

> **Settings → Secrets and variables → Actions**
> `https://github.com/rifaterdemsahin/streamlit/settings/secrets/actions`

---

## Required Secrets

### `FLY_API_TOKEN`

| Property | Value |
|----------|-------|
| **Where to set** | [GitHub Actions secrets](https://github.com/rifaterdemsahin/streamlit/settings/secrets/actions) |
| **Used by** | `.github/workflows/deploy.yml` |
| **Trigger** | Push to `main` branch |

**What it is:**
A Fly.io API token that authorises the GitHub Actions runner to deploy the application to your Fly.io account. Without it, `flyctl deploy` will be rejected.

**How to obtain:**
1. Log in to [fly.io](https://fly.io) and go to **Account → Access Tokens** (or run `flyctl auth token` locally).
2. Create a new token (optionally scoped to the specific app/org).
3. Copy the token value and paste it as the secret value on the GitHub secrets page above.

**Rationale:**
Fly.io uses token-based authentication for its CLI. The `deploy.yml` workflow runs `flyctl deploy --remote-only`, which requires this token to authenticate against the Fly.io API and trigger a remote build + deployment. Storing it as a GitHub secret keeps the token out of source code while still making it available to the CI runner.

---

### `FLY_APP_URL`

| Property | Value |
|----------|-------|
| **Where to set** | [GitHub Actions secrets](https://github.com/rifaterdemsahin/streamlit/settings/secrets/actions) |
| **Used by** | `.github/workflows/static.yml` |
| **Trigger** | Push to `main` branch / manual `workflow_dispatch` |
| **Format** | Must start with `https://` |
| **Default (if unset)** | `https://streamlit-2-hrnq.fly.dev` (derived from `fly.toml`) |

**What it is:**
The public HTTPS URL of your running Fly.io Streamlit application. The GitHub Pages static site (`index.html`) embeds this URL in an `<iframe>` so visitors see the live app inside the GitHub Pages shell. The `static.yml` workflow substitutes the `__FLY_APP_URL__` placeholder in `index.html` with this value at deploy time.

**How to obtain:**
After deploying to Fly.io (via `make deploy` or the `deploy.yml` workflow), your app URL takes the form:

```
https://<app-name>.fly.dev
```

Where `<app-name>` is the value of `app` in your `fly.toml`. For this repo the default is `streamlit-2-hrnq`, giving:

```
https://streamlit-2-hrnq.fly.dev
```

You can also run `flyctl status` locally to confirm the public hostname.

**Rationale:**
The GitHub Pages frontend is a static HTML page that iframes the dynamic Streamlit backend. Because the backend URL can change if you recreate the Fly.io app (e.g., with a different app name), the URL is externalised as a secret rather than being hardcoded in `index.html`. This lets you update the target URL without editing source files. If the secret is not set, the workflow falls back to the known default URL so the deployment does not break.

---

## Configuration at a Glance

| Secret | Workflow | Required | Default if unset |
|--------|----------|----------|------------------|
| `FLY_API_TOKEN` | `deploy.yml` | **Yes** – deploy will fail without it | None |
| `FLY_APP_URL` | `static.yml` | No | `https://streamlit-2-hrnq.fly.dev` |

---

## Setting Secrets — Step-by-step

1. Open **[Settings → Secrets and variables → Actions](https://github.com/rifaterdemsahin/streamlit/settings/secrets/actions)** in the repository.
2. Click **New repository secret**.
3. Enter the secret **Name** (e.g. `FLY_API_TOKEN`) and **Secret** value.
4. Click **Add secret**.

Repeat for each secret listed above. Secrets are encrypted at rest by GitHub and are only exposed to workflow runs on branches/PRs that have access.

---

## Local Development

No secrets are required to run the app locally:

```bash
pip install -r requirements.txt
streamlit run app.py
```

The app will be available at `http://localhost:8501`.
