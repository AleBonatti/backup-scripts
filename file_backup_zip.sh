# cartelle e file vari
SOURCE="/var/www/"
BACKUP_PATH="/home/user/backup/progetti/current/"
ZIP_PATH="/home/user/backup/progetti"
SCRIPT_PATH="/home/user/scripts/"
date=$(date +%Y%m%d)
ARCHIVE="projects_backup_${data}.zip"
LogFile="projects_backup.log"

cd ${SCRIPT_PATH}
echo "Inizio procedura backup progetti in corso (${data})..."

# verifico se esiste gia un file per questa data. se esiste lo cancello
if [ -f ${ZIP_PATH}/${ARCHIVE} ]
then
	rm ${ZIP_PATH}/${ARCHIVE}
	echo "file per la data attuale già esistente: rimosso"
fi

# eseguo il backup
rsync -adz --exclude-from=${SCRIPT_PATH}exclude-list.txt ${SOURCE} ${PATH_TO_BACKUP}

# zippo la cartella
echo "creazione archivio in corso..."
zip -rq ${ZIP_PATH}/${ARCHIVE} ${PATH_TO_BACKUP}
#tar -czf ${ZIP_PATH}/${ARCHIVE} ${PATH_TO_BACKUP}
echo "creazione file backup progetti ${ARCHIVE} completata con successo"

# faccio pulizia degli archivi più vecchi di una settimana
find ${ZIP_PATH}/*.zip -mtime +6 -exec rm {} \;
echo "backup completato con successo!"
echo ""
