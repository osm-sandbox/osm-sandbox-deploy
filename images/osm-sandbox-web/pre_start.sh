#!/usr/bin/env bash
set -x
## DB restoring
export PGPASSWORD=$POSTGRES_PASSWORD
workdir="/var/www"
curl -o $workdir/osm-sandbox.backup.sql https://osmsandbox.s3.amazonaws.com/osm-sandbox.backup-fixed.sql

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
      sed -i 's/www.hot.boxes.osmsandbox.us/'"$SERVER_URL"'/g' $workdir/osm-sandbox.backup.sql
      # Import the SQL backup file into PostgreSQL
      psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -f $workdir/osm-sandbox.backup.sql
    fi
  fi
done

# Change ORG name
find config/locales/ -type f -exec sed -i "s/OpenStreetMap/${ORGANIZATION_NAME}/g" {} +
