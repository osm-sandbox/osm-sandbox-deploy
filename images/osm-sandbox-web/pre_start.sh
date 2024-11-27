#!/usr/bin/env bash
set -x
## DB restoring
export PGPASSWORD=$POSTGRES_PASSWORD
workdir="/var/www"
curl -o $workdir/osm-sandbox.backup.sql $BACKUP_FILE_URL

# Function to check if any tables exist in the PostgreSQL database
check_number_of_tables() {
  num_tables=$(psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -tc "SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';")
  [ "$num_tables" -gt 10 ]
}

flag=true
# While loop to attempt the restore process if no tables exist
while [ "$flag" = true ]; do
  if pg_isready -h $POSTGRES_HOST -p 5432 >/dev/null 2>&1; then
    if check_number_of_tables; then
      echo "The database already has already table. Skipping restore."
      flag=false
    else
      flag=false
      sed -i 's/osm-sandbox.org/'"$SERVER_URL"'/g' $workdir/osm-sandbox.backup.sql
      # Import the SQL backup file into PostgreSQL
      psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -f $workdir/osm-sandbox.backup.sql
    fi
  fi
done

psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB "INSERT INTO oauth_applications (owner_type, owner_id, name, uid, secret, redirect_uri, scopes, confidential, created_at, updated_at) VALUES ('User', 1, 'Tasking Manager', '${TM_OAUTH_CLIENT_ID}', '${TM_OAUTH_CLIENT_SECRET_HASHED}', E'https://tasks.openstreetmap.us/static/pdeditor/land2.html\r\nhttps://tasks.teachosm.org/static/pdeditor/land2.html', 'read_prefs write_prefs write_api read_gpx write_notes', false, now() at time zone 'utc', now() at time zone 'utc');"

# Change ORG name
find config/locales/ -type f -exec sed -i "s/OpenStreetMap/${ORGANIZATION_NAME}/g" {} +
