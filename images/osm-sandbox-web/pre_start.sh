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

# TODO: Get actual environment variable replacement working
TM_OAUTH_CLIENT_ID="7yDot3Plq2g0cbapXcTEpSKldYWDk-BTyeUNl6YtC0I"
TM_OAUTH_CLIENT_SECRET_HASHED="3964467e2b098792858b163f69f673a5846254dc8af671d33ef03b36a9cac6e8"

psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "INSERT INTO oauth_applications (owner_type, owner_id, name, uid, secret, redirect_uri, scopes, confidential, created_at, updated_at) VALUES ('User', 1, 'Tasking Manager', '${TM_OAUTH_CLIENT_ID}', '${TM_OAUTH_CLIENT_SECRET_HASHED}', E'https://tasks.openstreetmap.us/static/sandbox-id/land2.html\r\nhttps://tasks.teachosm.org/static/pdeditor/land2.html', 'read_prefs write_prefs write_api read_gpx write_notes', false, now() at time zone 'utc', now() at time zone 'utc');"

# Change ORG name
find config/locales/ -type f -exec sed -i "s/OpenStreetMap/${ORGANIZATION_NAME}/g" {} +

# Patch OpenStreetMap Rails application to support the password OAuth grant type.
# This is needed so that the Dashboard API server can use a username/password combo
# to retrieve an OAuth token for a sandbox, and return that token to a frontend
# application (like iD) to use to authenticate and edit the sandbox.
sed -i 's/grant_flows %w\[authorization_code\]/grant_flows %w[password authorization_code]/' config/initializers/doorkeeper.rb

# Add resource_owner_from_credentials block for password grant authentication
sed -i '/orm :active_record/a\
\
  # Enable resource owner password credentials grant flow; see:\
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Resource-Owner-Password-Credentials-flow\
  resource_owner_from_credentials do |_routes|\
    User.authenticate(:username => params[:username], :password => params[:password])\
  end' config/initializers/doorkeeper.rb
