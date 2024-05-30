#!/usr/bin/env bash
set -x
workdir="/var/www"
wget https://osm-sandbox.s3.amazonaws.com/osm-sandbox.backup-fixed.sql -O $workdir/osm-sandbox.backup.sql
while "$flag" = true; do
  pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&2 || continue
  flag=false
  sed -i 's/osm-sandbox.org/'"$SERVER_URL"'/g' $workdir/osm-sandbox.backup.sql
  sed -i 's/admin@osm-sandbox.org/'"$MAILER_FROM"'/g' $workdir/osm-sandbox.backup.sql
  pg_restore -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -W  $workdir/osm-sandbox.backup.sql
done
