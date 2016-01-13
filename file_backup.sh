#!/usr/bin/env bash

# folders and paths
SOURCE="/var/www/html/"
BACKUP_PATH="/home/methlab/backup/progetti/current/"
ZIP_PATH="/home/methlab/backup/progetti"
SCRIPT_PATH="/home/methlab/scripts"
date=$(date +%Y%m%d)
ARCHIVE="methlab_progetti_${date}.zip"

cd ${SCRIPT_PATH}
echo "[$(date)] Backup procedure is running..."

# check if a file for current date exists. If it does, delete it.
if [ -f ${ZIP_PATH}/${ARCHIVE} ]
then
	rm ${ZIP_PATH}/${ARCHIVE}
	echo "a file for current date already exists: deleted."
fi

# running backup
rsync -adz --exclude-from=${SCRIPT_PATH}/exclude-list.txt ${SOURCE} ${BACKUP_PATH}

# zippo la cartella
echo "creating zip archive..."
zip -rq ${ZIP_PATH}/${ARCHIVE} ${BACKUP_PATH}
#tar -czf ${ZIP_PATH}/${ARCHIVE} ${BACKUP_PATH}
echo "archive ${ARCHIVE} successfully created"

# cleaning archives older than a week
find ${ZIP_PATH}/*.zip -mtime +6 -exec rm {} \;
echo "backup successfully completed!"
echo ""
