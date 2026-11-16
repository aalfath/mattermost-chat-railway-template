# Start script for Mattermost on Railway. Runs under busybox sh as root.
set -eu
bb=/usr/local/bin/busybox

# One volume holds everything Mattermost writes to disk.
DATA_DIR="${MM_DATA_DIR:-/mattermost/data}"

# Database: Railway gives postgresql://user:pass@host:port/db. Mattermost's
# config store only recognises postgres://, and the private network has no TLS.
DB_URL="${MM_SQLSETTINGS_DATASOURCE:-${DATABASE_URL:-}}"
if [ -z "$DB_URL" ]; then
  echo "railway-start: set DATABASE_URL (or MM_SQLSETTINGS_DATASOURCE) to a PostgreSQL URL" >&2
  exit 1
fi
case "$DB_URL" in postgresql://*) DB_URL="postgres://${DB_URL#postgresql://}" ;; esac
case "$DB_URL" in
  *\?*) ;;
  *) DB_URL="${DB_URL}?sslmode=${PGSSLMODE:-disable}&connect_timeout=10" ;;
esac
export MM_SQLSETTINGS_DRIVERNAME=postgres
export MM_SQLSETTINGS_DATASOURCE="$DB_URL"
# Keep the System Console settings in the database, so they survive redeploys.
export MM_CONFIG="${MM_CONFIG:-$DB_URL}"

export MM_SERVICESETTINGS_LISTENADDRESS=":${PORT:-8065}"
if [ -z "${MM_SERVICESETTINGS_SITEURL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export MM_SERVICESETTINGS_SITEURL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

export MM_FILESETTINGS_DIRECTORY="${MM_FILESETTINGS_DIRECTORY:-$DATA_DIR/files/}"
export MM_PLUGINSETTINGS_DIRECTORY="${MM_PLUGINSETTINGS_DIRECTORY:-$DATA_DIR/plugins}"
export MM_PLUGINSETTINGS_CLIENTDIRECTORY="${MM_PLUGINSETTINGS_CLIENTDIRECTORY:-$DATA_DIR/client-plugins}"
export MM_LOGSETTINGS_FILELOCATION="${MM_LOGSETTINGS_FILELOCATION:-$DATA_DIR/logs}"
export MM_BLEVESETTINGS_INDEXDIR="${MM_BLEVESETTINGS_INDEXDIR:-$DATA_DIR/bleve-indexes}"

# Railway volumes are mounted root-owned. Fix ownership once, not on every boot.
$bb mkdir -p "$MM_FILESETTINGS_DIRECTORY" "$MM_PLUGINSETTINGS_DIRECTORY" \
  "$MM_PLUGINSETTINGS_CLIENTDIRECTORY" "$MM_LOGSETTINGS_FILELOCATION" "$MM_BLEVESETTINGS_INDEXDIR"
if [ "$($bb stat -c %u "$DATA_DIR")" != "2000" ] || [ ! -f "$DATA_DIR/.railway-owned" ]; then
  $bb chown -R 2000:2000 "$DATA_DIR"
  $bb touch "$DATA_DIR/.railway-owned"
  $bb chown 2000:2000 "$DATA_DIR/.railway-owned"
fi

cd /mattermost
exec $bb chpst -u 2000:2000 /mattermost/bin/mattermost "$@"
