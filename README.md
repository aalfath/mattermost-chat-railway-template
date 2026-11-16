# Mattermost on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/mattermost-2?utm_medium=integration&utm_source=button&utm_campaign=mattermost)

A Railway template for [Mattermost](https://mattermost.com) Team Edition, the open-source team chat with channels, threads, file sharing and search.

## What it deploys

| Service | Source | Notes |
|---|---|---|
| **Mattermost** | this repo (`Dockerfile`) | `mattermost/mattermost-team-edition:12.0.2`, pinned by digest. Public domain, health check `/api/v4/system/ping`, volume at `/mattermost/data` |
| **Postgres** | Railway PostgreSQL | Messages, users, teams and the System Console settings |

The official image has no shell, so the `Dockerfile` copies in a pinned static busybox to run `start.sh`. The script:

- turns Railway's `postgresql://` `DATABASE_URL` into the `postgres://…?sslmode=disable` form Mattermost needs,
- stores Mattermost's configuration in Postgres (`MM_CONFIG`), so System Console changes survive redeploys,
- listens on `PORT` (8065) and sets the Site URL from the Railway domain,
- keeps uploaded files, plugins, logs and search indexes on the one volume (`/mattermost/data`),
- fixes the volume's ownership once, then runs Mattermost as its own user (uid 2000), not root.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Connection to the Postgres service |
| `MM_SERVICESETTINGS_SITEURL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL. Change it when you add a custom domain |
| `PORT` | `8065` | Port Mattermost listens on |

Any other Mattermost setting can be set as an `MM_<SECTION>_<SETTING>` variable ([environment variables](https://docs.mattermost.com/administration-guide/configure/environment-configuration-settings.html)) or in the System Console. A variable locks that setting in the System Console.

## First start

Open the Railway domain and create your account: the first account becomes the system admin. Do it right after the deploy. After that, new people join by invitation only (open sign-up is off by default).

Email (SMTP) is not configured, so email notifications and password-reset mails are off until you set SMTP in **System Console → Environment → SMTP**.

## Updates

The Mattermost version is pinned in the `Dockerfile`. When it changes here, Railway shows an "update available" notice in projects deployed from this template; read `CHANGELOG.md` before you apply it. Mattermost runs its database migrations on start, so take a Postgres backup first and don't skip several major versions at once.
