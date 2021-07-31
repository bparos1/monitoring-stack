#!/bin/bash

## Creates backup directory and moves backup cron job
mkdir ~/backup
source ./backup/backup.env
envsubst < ./backup/cron_backup_template.sh > ~/backup/cron_backup.sh
envsubst < ./backup/cron_template.txt > ./backup/cron_text.txt
rm ./backup/cron_backup_template.sh
rm ./backup/cron_template.txt
chmod 0770 ~/backup/cron_backup.sh

## Perform backup of image / base configuration settings
docker commit $name ~/backup/$name:version0
docker save $name > ~/backup/$name.tar
