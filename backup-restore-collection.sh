#!/bin/bash
source ./.env

# Username and Password
USERNAME="tools"
PASSWORD=$TOOLS_PASSWORD

# Timestamp for backup naming
TIME_STAMP=$(date +"%Y%m%d")

# Prompt user for action (backup or restore)
read -p "Enter the command (backup or restore): " ACTION
ACTION=$(echo "$ACTION" | tr '[:upper:]' '[:lower:]') # Convert to lowercase for consistency

# Validate action input
if [[ "$ACTION" != "backup" && "$ACTION" != "restore" ]]; then
  echo "Invalid action. Please enter 'backup' or 'restore'."
  exit 1
fi

# Prompt for environment (local, dev, or prod)
read -p "Enter the environment (local, dev, prod): " ENVIRONMENT
ENVIRONMENT=$(echo "$ENVIRONMENT" | tr '[:upper:]' '[:lower:]')

# Set the SOLR_HOST based on environment
case "$ENVIRONMENT" in
  local)
    SOLR_HOST="$LOCAL_HOST_URL"
    ;;
  dev)
    SOLR_HOST="$DEV_HOST_URL"
    ;;
  prod)
    SOLR_HOST="$PROD_HOST_URL"
    ;;
  *)
    echo "Invalid environment. Please enter 'local', 'dev', or 'prod'."
    exit 1
    ;;
esac

# Prompt for collection name based on action
if [ "$ACTION" == "backup" ]; then
  read -p "Enter the name of the collection to backup: " COLLECTION
  BACKUP_BACKUP_NAME="backup_${COLLECTION}_collection_${TIME_STAMP}"
  BACKUP_FOLDER_LOCATION="/backup-solr/"
  echo "Backing Up..."
  # Backup command
  BACKUP_RESPONSE=$(curl -s -u "$USERNAME:$PASSWORD" "$SOLR_HOST/solr/admin/collections?action=BACKUP&name=${BACKUP_BACKUP_NAME}&collection=${COLLECTION}&repository=s3&location=${BACKUP_FOLDER_LOCATION}&maxTime=1200&async=true")

  echo "Backup Response: $BACKUP_RESPONSE"

  if [ $? -ne 0 ]; then
    echo "Failed to backup the collection"
    exit 1
  fi

elif [ "$ACTION" == "restore" ]; then
  read -p "Enter the name of the backup to restore (e.g., SolrBACKUP2): " RESTORE_BACKUP_NAME
  read -p "Enter the name for the new collection to restore into: " NEW_COLLECTION

  RESTORE_LOCATION="s3:/"
  echo "Restoring..."
  # Restore command
  RESTORE_RESPONSE=$(curl -s -u "$USERNAME:$PASSWORD" "$SOLR_HOST/solr/admin/collections?action=RESTORE&name=/backup-solr/${RESTORE_BACKUP_NAME}&collection=${NEW_COLLECTION}&location=${RESTORE_LOCATION}")

  echo "Restore Response: $RESTORE_RESPONSE"

  if [ $? -ne 0 ]; then
    echo "Failed to restore the collection"
    exit 1
  fi
fi

exit 0
