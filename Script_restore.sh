#!/bin/bash

WEB_URL="/var/www/"
WEB_DIRECTORY="wordpress"
WP_VERSION="wordpress-5.3-fr_FR.tar.gz"
WP_URL_DOWNLOAD="https://fr.wordpress.org/$WP_VERSION"
FTP_IP=""
TEMP_DIR="/home/$USER/tmp"
IP_NEW=$(hostname -I | awk '{print $1}')

echo "Deny from all" > ~/.htaccess
sudo cp ~/.htaccess $WEB_URL$WEB_DIRECTORY
sudo chown www-data:www-data $WEB_URL$WEB_DIRECTORY/.htaccess

sudo mkdir /mnt/ftp
sudo chown $USER:$USER /mnt/ftp/
sudo curlftpfs -o rw,uid=1000,gid=1000,allow_other ftp://ftp_user:passpass@$FTP_IP /mnt/ftp/
cd /mnt/ftp
BACKUP_FILE=$(ls -1tr *.tar.gz | tail -1)
mkdir $TEMP_DIR
sudo cp $BACKUP_FILE $TEMP_DIR
cd $TEMP_DIR
sudo tar xzvf $BACKUP_FILE
sudo cp -R ./file_backup/$WEB_DIRECTORY $WEB_URL
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

cd $WEB_URL
sudo wget $WP_URL_DOWNLOAD
sudo tar xvf $WP_VERSION
sudo rm $WP_VERSION
sudo chown www-data:www-data -R ./$WEB_DIRECTORY

source $TEMP_DIR/bdd_backup/config
mysql --defaults-extra-file=/etc/mysql/mysql-backup-script.cnf --execute="CREATE DATABASE wordpress;"
mysql --defaults-extra-file=/etc/mysql/mysql-backup-script.cnf wordpress < $TEMP_DIR/bdd_backup/$SQL_BACKUP
mysql --defaults-extra-file=/etc/mysql/mysql-backup-script.cnf wordpress --execute="UPDATE wp_options SET option_value = replace(option_value, 'http://$IP_OLD', 'http://$IP_NEW') WHERE option_name = 'home' OR option_name = 'siteurl';"
mysql --defaults-extra-file=/etc/mysql/mysql-backup-script.cnf wordpress --execute="UPDATE wp_posts SET guid = replace(guid, 'http://$IP_OLD','http://$IP_NEW');"
mysql --defaults-extra-file=/etc/mysql/mysql-backup-script.cnf wordpress --execute="UPDATE wp_posts SET post_content = replace(post_content, 'http://$IP_OLD', 'http://$IP_NEW');"
mysql ---defaults-extra-file=/etc/mysql/mysql-backup-script.cnf wordpress --execute="UPDATE wp_postmeta SET meta_value = replace(meta_value,'$IP_OLD','http://$IP_NEW');"


sudo cp $TEMP_DIR/bdd_backup/.htaccess  $WEB_URL$WEB_DIRECTORY/
