## Some (very) basic scripts to backup your data on a Linux Server

* * *

_Disclaimer: these are my first bash scripts! I did my best to make them as good as possible but I'm not script guru.
Feel free to edit them as you like and let me know if need to be fixed.

* * *

### Description:
Three scripts to backup databases, files, and send them to an Amazon S3 bucket.
They are meant to be scheduled using cron; tested under an Ubuntu 14.04 server (although should work any Linux distribution).

file_backup.sh uses rsync utility to keep files in synct from the project directory (i.e. /var/www) to another directory used as a backup.
After the folders have been synced, the backup dictory is zipped using current date as file name.
Archives older than a week are then deleted.
Rsync procedure uses a txt file to exclude some files from backup. In my the example, logs and cache files are left out.