#!/usr/bin/env bash

PATH="/usr/local/bin:$PATH"
# insert path to source folder. ie /home/user/projects
PATH_TO_SOURCE="/home/projects"
# insert path to script folder. ie /home/user/backup/scripts
PATH_TO_SCRIPT="/home/user/backup/scripts"
# insert destination path folder. ie /home/user/backup/files/progetti
PATH_TO_ZIP="/home/user/backup/files/progetti"
date=$(date +%Y%m%d)
ARCHIVE="alboino_progetti_${date}.tar.gz"
# insert s3 url. ie username/projects/
PATH_S3="username/projects/"

cd ${PATH_TO_SCRIPT}

# check if a file for current date exists. If it does, delete it.
if [ -f ${PATH_TO_ZIP}/${ARCHIVE} ]
then
        rm ${PATH_TO_ZIP}/${ARCHIVE}
        echo "A file for current date already exists: deleted."
fi

echo "[$(date)] Creating archive ${ARCHIVE}"
tar -czf ${PATH_TO_ZIP}/${ARCHIVE} --exclude-vcs -X  ${PATH_TO_SCRIPT}/exclude-list.txt ${PATH_TO_SOURCE}
echo "Archive created."

echo "Transfer operation started..."
# check if file exists
if [ -f ${PATH_TO_ZIP}/${ARCHIVE} ]
then
        # trasnfer to Amazon S3. You can specify the storage class
        aws s3 cp ${PATH_TO_ZIP}/${ARCHIVE} s3://${PATH_S3}${ARCHIVE} --storage-class=GLACIER
        echo "Transfer completed. Clearing archives..."
        rm ${PATH_TO_ZIP}/*.tar.gz
        echo "All done!"
else
        echo "Archive ${ARCHIVE} not found!"
fi
echo ""
