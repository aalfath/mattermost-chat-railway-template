# Changelog

## 12.1.0 (2026-11-17)

- No breaking changes. Messages, users and settings in Postgres and files on the `/mattermost/data` volume are kept; Mattermost migrates its database schema at start.
- Mattermost [v12.1.0](https://github.com/mattermost/mattermost/releases/tag/v12.1.0): bot attributes, burn-on-read permission policies and other fixes.
- Images: `mattermost/mattermost-team-edition:12.1.0@sha256:35927b9c535a9eb74f0e45385d3fe5d8308b16e0464031f157a834da8af3ee73`; the start-script helper moves to `busybox:1.38.0-musl@sha256:80e38f9a1b39188b8bdb28879178edb322a4402b081a9aedda1924609decd6f6`.

## 12.0.2, README update (2026-11-16)

- Added the Deploy on Railway button for the published template (mattermost-2). No change to the app or its settings.

## 12.0.2 (2026-11-16)

- First version of the template: Mattermost Team Edition 12.0.2 (`mattermost/mattermost-team-edition:12.0.2@sha256:0e435f3397390c36797d0c09b6fcfd73841ebf89bb292d6c6e109082a21ad7b6`) with Railway PostgreSQL.
- Configuration is stored in Postgres; files, plugins, logs and search indexes live on the volume at `/mattermost/data`.
