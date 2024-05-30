#!/usr/bin/env bash
set -x
## DB restoring
export PGPASSWORD=$POSTGRES_PASSWORD
workdir="/var/www"
curl -o $workdir/osm-sandbox.backup.sql https://osm-sandbox.s3.amazonaws.com/osm-sandbox.backup-fixed.sql
flag=true
while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  sed -i 's/osm-sandbox.org/'"$SERVER_URL"'/g' $workdir/osm-sandbox.backup.sql
  sed -i 's/admin@osm-sandbox.org/'"$MAILER_FROM"'/g' $workdir/osm-sandbox.backup.sql
  psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -f $workdir/osm-sandbox.backup.sql
done

# Change ORG name
find config/locales/ -type f -exec sed -i "s/OpenStreetMap/${ORGANIZATION_NAME}/g" {} +
