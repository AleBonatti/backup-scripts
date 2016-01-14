#!/usr/bin/env bash

PATH="/usr/local/bin:$PATH"
PATH_TO_SCRIPT="/home/methlab/scripts/"
PATH_TO_ZIP="/home/methlab/backup/progetti"

date=$(date +%Y%m%d)
ARCHIVE="methlab_progetti_${date}.zip"

cd ${PATH_TO_SCRIPT}
echo "[$(date)] ${ARCHIVE} transfer operation started"

# check if file exists
if [ -f ${PATH_TO_ZIP}/${ARCHIVE} ]
then
	# trasnfer to Amazon S3
	aws s3 cp ${PATH_TO_ZIP}/${ARCHIVE} s3://methlab/progetti/${ARCHIVE}
	echo "transfer completed!"
else
        echo "archive ${ARCHIVE} not found!"
fi
echo ""
