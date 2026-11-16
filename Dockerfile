# Mattermost Team Edition for Railway.
# The official image is distroless (no shell), so a static busybox is copied in
# to run the small start script: it fixes the volume's ownership, maps Railway's
# variables onto Mattermost's settings, then starts Mattermost as uid 2000.
FROM busybox:1.37.0-musl@sha256:f6a95d611e0a8780fabdb2aec43e31275b2720dfefa3e41b16835bfc42454478 AS busybox

FROM mattermost/mattermost-team-edition:12.0.2@sha256:0e435f3397390c36797d0c09b6fcfd73841ebf89bb292d6c6e109082a21ad7b6

COPY --from=busybox /bin/busybox /usr/local/bin/busybox
COPY start.sh /usr/local/bin/railway-start.sh

# Root only for the ownership fix; the script drops to the mattermost user.
USER root
ENTRYPOINT ["/usr/local/bin/busybox", "sh", "/usr/local/bin/railway-start.sh"]
