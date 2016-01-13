#!/usr/bin/env bash

PATH="/usr/local/bin:$PATH"
DB_HOST="localhost"
source /home/methlab/scripts/.env

# Linux bin paths, change this if it can't be autodetected via which command
MYSQL="$(which mysql)"

# Backup Dest directory, change this if you have someother location
DUMP_PATH="/home/methlab/backup/database"
SCRIPT_PATH="/home/methlab/scripts"

# DO NOT BACKUP these databases
EXCLUDED="information_schema mysql phpmyadmin performance_schema"

# Get all database list first
DBS="$($MYSQL -u $DB_USERNAME -h $DB_HOST -p$DB_PASSWORD -Bse 'show databases')"

# nome directory dove salvare
date=$(date +%Y%m%d)
MyFOLDER=${DUMP_PATH}/${date}
MyARCHIVE="methlab_database_${date}.zip"

cd ${SCRIPT_PATH}
echo "[$(date)] operazione export database iniziata"

# verifico se la cartella esiste già
if [ ! -d ${MyFOLDER} ]
then
	# verifico se esiste gia un file per questa data. se esiste lo cancello
	if [ -f ${DUMP_PATH}/${MyARCHIVE} ]
	then
		rm ${DUMP_PATH}/${MyARCHIVE}
		echo "file per la data attuale già esistente: rimosso"
	fi

	#se non c'è la creo e proseguo
	echo "creazione directory ${MyFOLDER}..."
	mkdir -p ${MyFOLDER}

	# per ogni db, creo un file esportazione
	COUNTER=0
	for db in $DBS
	do
	    skipdb=-1
	    # verifico se il db è nella lista di quelli da saltare
	    if [ "${EXCLUDED}" != "" ];
	    then
        	for i in ${EXCLUDED}
	        do
			#echo " verifica $db - $i"
        		if [ ${db} = ${i} ];
			then
				skipdb=1
			fi
			#echo " - verifica $db - $i: $skipdb"
	        done
	    fi
	    
	    # se non lo è, lo esporto
	    if [ "$skipdb" -eq -1 ];
	    then
	        mysqldump -u $DB_USERNAME -h $DB_HOST -p$DB_PASSWORD $db > ${MyFOLDER}/db_${db}.sql
		echo " - ${db}: Ok."
		COUNTER=$((COUNTER+1))
	    else
		echo " - ${db}: non esportato."
	    fi
	done
	# se è stato esportato almeno un db
	if [ "$COUNTER" -gt 0 ];
	then
		# zippo la cartella
		echo "creazione archivio in corso..."
		zip -r ${DUMP_PATH}/${MyARCHIVE} ${MyFOLDER}
		echo "archiviazione completata"
	else
		echo "nessun database da esportare"
		exit 0
	fi

	# cancello comunque la vecchia cartella
	echo "pulizia file temporanei in corso..."
	rm -rf ${MyFOLDER}
	echo "database archiviati: $COUNTER. Operazione completata"

	# trasferisco su Amazon S3
	echo "trasferimento file verso Amazon S3 in corso..."
	aws s3 cp ${DUMP_PATH}/${MyARCHIVE} s3://methlab/database/${MyARCHIVE}
	echo "trasferimento completato"
 
	# cancello comunque i file più vecchi di due settimane
	find ${DUMP_PATH}/* -mtime +13 -exec rm {} \;
else
	echo "directory già ${MyFOLDER} esistente: impossibile continuare";
fi
echo ""
