#!/usr/bin/env bash

PATH="/usr/local/bin:$PATH"
DB_HOST="localhost"
source /home/methlab/scripts/.env

# Linux bin paths, change this if it can't be autodetected via which command
MYSQL="$(which mysql)"

# Backup Dest directory, change this if you have someother location
DUMP_PATH="/home/methlab/backup/database"
SCRIPT_PATH="/home/methlab/scripts"

# List of databases to EXCLUDE from dump
EXCLUDED="information_schema mysql phpmyadmin performance_schema"

# Get all database list first
DBS="$($MYSQL -u $DB_USERNAME -h $DB_HOST -p$DB_PASSWORD -Bse 'show databases')"

# Destination directory
date=$(date +%Y%m%d)
MyFOLDER=${DUMP_PATH}/${date}
MyARCHIVE="methlab_database_${date}.zip"

cd ${SCRIPT_PATH}
echo "[$(date)] Beginning dump operation."

# check if destination directory exists. If not, procede.
if [ ! -d ${MyFOLDER} ]
then
	# check archive for current date exists. If it does, delete it...
	if [ -f ${DUMP_PATH}/${MyARCHIVE} ]
	then
		rm ${DUMP_PATH}/${MyARCHIVE}
		echo "file for current date already exists: deleted."
	fi

	# ...otherwise, procede.
	echo "creating directory ${MyFOLDER}... Ok."
	mkdir -p ${MyFOLDER}

	# for each database, create a dump
	COUNTER=0
	for db in $DBS
	do
	    skipdb=-1
	    # check if current db is in ignore list...
	    if [ "${EXCLUDED}" != "" ];
	    then
        	for i in ${EXCLUDED}
	        do
        		if [ ${db} = ${i} ];
			then
				skipdb=1
			fi
	        done
	    fi
	    
	    # if not, create dump.
	    if [ "$skipdb" -eq -1 ];
	    then
	        mysqldump -u $DB_USERNAME -h $DB_HOST -p$DB_PASSWORD $db > ${MyFOLDER}/db_${db}.sql
		echo " - ${db}: exported."
		COUNTER=$((COUNTER+1))
	    else
		echo " - ${db}: skipped."
	    fi
	done
	# count exported databases
	if [ "$COUNTER" -gt 0 ];
	then
		# at least one, create a single archive with all dumped db.
		echo "creating archive..."
		zip -r ${DUMP_PATH}/${MyARCHIVE} ${MyFOLDER}
		echo "...done"
	else
		echo "no database to export."
		exit 0
	fi

	# delete temporary folder
	echo "cleaning temp files..."
	rm -rf ${MyFOLDER}
	echo "archived databases: $COUNTER. Operation completed!"

	# transfer to Amazon S3
	echo "sending files to Amazon S3 bucket..."
	aws s3 cp ${DUMP_PATH}/${MyARCHIVE} s3://methlab/database/${MyARCHIVE}
	echo "...done."
 
	# delete archives older than 2 weeks
	find ${DUMP_PATH}/* -mtime +13 -exec rm {} \;
else
	echo "directory ${MyFOLDER} already exists: operation aborted.";
fi
echo ""
