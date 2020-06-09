#!/bin/bash

SERVEUR=""
FTP_USER="ftp_user"
FTP_PASS="passpass"
FILE_BACKUP="/mnt/ftp/file_backup"
BDD_BACKUP="/mnt/ftp/bdd_backup"
MAIL=""
BACKUPDATE=$(date +"%Y%m%d-%H%M")
IP_HOST=$(hostname -I | awk '{print $1}')
WEB_URL="/var/www/wordpress"
envoiMail() 
{ 
  echo $1 | mail -s "Backup_Notification [$2]" -a "From: Backup_Notif <mail@gmail.com> " $MAIL
}

wget -q --spider ftp://$FTP_USER:$FTP_PASS@$SERVEUR/
if [ $? -eq 0 ];
then
	[ ! -d $FILE_BACKUP ] && mkdir $FILE_BACKUP && chmod 770 $FILE_BACKUP
	[ ! -d $BDD_BACKUP ] && mkdir $BDD_BACKUP && chmod 770 $BDD_BACKUP
	echo "Rsync..."
	rsync -azv --no-owner --no-group --inplace --append --progress --stats --delete --exclude-from=rsync_exclude.txt $WEB_URL  $FILE_BACKUP
	if [ "$?" -eq "0" ]
	then
		echo "Rsync ok"
	else
		echo "[Erreur] Envoi de mail"
		envoiMail "Erreur lors de la copie avec rsync" "Erreur Rsync"
	fi
	echo "Dump Mysql db"
	cd $BDD_BACKUP
	cp $WEB_URL/.htaccess ./
	if [ -f *.sql ]; then
		rm *.sql
	fi
	mysqldump --user=Wordpress_user --password=secret wordpress > $BACKUPDATE.sql
	echo -e "IP_OLD=$(hostname -I | awk '{print $1}')\nSQL_BACKUP=$BACKUPDATE.sql" > config
	if [ "$?" -eq "0" ]
	then
		echo "Mysql OK"
	else
		echo "[Erreur] Envoi de mail"
		envoiMail "Erreur de connexion à la base de données" "Erreur Mysql"
	fi
	echo "Archive..."
	cd $FILE_BACKUP/..
	tar cfz wordpress-$BACKUPDATE.tar.gz bdd_backup/ file_backup/
	find $BDD_BACKUP -maxdepth 1 -type f -name '*.tar.gz' -mtime +3 | xargs rm -vf
	if [ -e "$FILE_BACKUP/../wordpress-$BACKUPDATE.tar.gz" ]
	then
		echo "Archive OK" 
		envoiMail "La sauvegarde automatique à été réalisée avec succès" "Backup-OK"
	else
		echo "[Erreur] Envoi de mail"
		envoiMail "Erreur lors de la création de l'archive" "Erreur Archivage"
	fi
else
	echo "[Erreur] Envoi de mail"
	envoiMail "Le serveur FTP [$SERVEUR] est injoignable" "Erreur FTP"
fi
