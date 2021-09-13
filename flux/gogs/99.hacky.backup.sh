#
# This is horrible, horrible - for good backups read about gogs included backup/restore functionality
#


YYYYMMDDhhmmss=$(date +%Y%m%d%H%M%S)
sudo tar cvf _var_gogs.hackybackup.$YYYYMMDDhhmmss.tgz _var_gogs/

