#!/usr/bin/env bash

PATH="/usr/local/bin:$PATH"
# insert path to script folder. ie /home/user/backup/scripts
PATH_TO_SCRIPT="/home/user/backup/scripts"
# insert destination path folder. ie /home/user/backup/files/progetti
PATH_TO_ZIP="/home/user/backup/files/progetti"

date=$(date +%Y%m%d)
ARCHIVE="methlab_progetti_${date}.zip"
# insert s3 url. ie username/projects/
PATH_S3="username/projects/"

cd ${PATH_TO_SCRIPT}
echo "[$(date)] ${ARCHIVE} transfer operation started"

# check if file exists
if [ -f ${PATH_TO_ZIP}/${ARCHIVE} ]
then
	# trasnfer to Amazon S3
	aws s3 cp ${PATH_TO_ZIP}/${ARCHIVE} s3://${PATH_S3}${ARCHIVE}
	echo "transfer completed!"
else
        echo "archive ${ARCHIVE} not found!"
fi
echo ""
