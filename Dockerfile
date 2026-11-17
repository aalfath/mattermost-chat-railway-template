# Mattermost Team Edition for Railway.
# The official image is distroless (no shell), so a static busybox is copied in
# to run the small start script: it fixes the volume's ownership, maps Railway's
# variables onto Mattermost's settings, then starts Mattermost as uid 2000.
FROM busybox:1.38.0-musl@sha256:80e38f9a1b39188b8bdb28879178edb322a4402b081a9aedda1924609decd6f6 AS busybox

FROM mattermost/mattermost-team-edition:12.1.0@sha256:35927b9c535a9eb74f0e45385d3fe5d8308b16e0464031f157a834da8af3ee73

COPY --from=busybox /bin/busybox /usr/local/bin/busybox
COPY start.sh /usr/local/bin/railway-start.sh

# Root only for the ownership fix; the script drops to the mattermost user.
USER root
ENTRYPOINT ["/usr/local/bin/busybox", "sh", "/usr/local/bin/railway-start.sh"]
