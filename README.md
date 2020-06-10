# Wordpress_Auto_Save

Ce script permet de sauvegarder automatiquement un site Wordpress sur un serveur FTP distant et de pouvoir restorer sa sauvegarde.

## Prérequis
- Un serveur FTP distant accessible
- CurlFtpFS
- Rsync
- Archive (tar.gz) contenant une version de WordPress identique de préférence avec la version sauvegardée

## Variables
### Script de Sauvegarde
- `SERVEUR` : IP du serveur FTP
- `FTP_USER` : Nom d'utilisateur du serveur FTP
- `FTP_PASS` : Mot de passe du serveur FTP
- `FILE_BACKUP` : Emplacement de la sauvegarde des fichiers WordPress
- `BDD_BACKUP` : Emplacement de la sauvegarde de la base de données MySQL sous forme d'un fichier SQL
- `MAIL` : Mail de notification de Sauvegarde ( Envoi d'alerte en cas de réussite ou échec)
- `BACKUPDATE` : Récupére l'heure au moment de la Backup
- `IP_HOST` : Récupére l'IP du serveur sur lequel s'effectue la sauvegarde
- `WEB_URL` : Contient le chemin vers l'installation de WordPress

### Script de Restauration
- `WEB_URL` : Contient le chemin vers l'installation de WordPress
- `WEB_DIRECTORY` : Contient le nom du dossier de WordPress
- `WP_VERSION` : Contient le nom et la version de l'archive WordPress
- `WP_URL_DOWNLOAD` : Chemin vers l'archive de WordPress
- `FTP_IP` : IP du serveur FTP
- `TEMP_DIR` : Répertoire de stockage temporaire des fichiers décompréssés
- `IP_NEW` : IP de la nouvelle machine qui restore la backup

## License
MIT / BSD
