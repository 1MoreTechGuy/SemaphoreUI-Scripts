#/bin/bash
#File: migrate-semaphore-snap.sh
#Migrate SemaphoreUI from snap as root to package/binary as semaphore

TEMP_DIR = "/tmp/semaphore"
CONFIG_PATH = "/home/semaphore"
SUI_USER = "semaphore"


sudo su -l root <<EOF
set -x
snap stop semaphore.semaphored
cp -rf /root/snap/semaphore/common $CONFIG_PATH
rm -rf $CONFIG_PATH/repositories
cp -rf /root/snap/semaphore/common/repositories $TEMP_DIR
sed -i 's/\/root\/snap\/semaphore\/common\/database.boltdb/\/home\/semaphore\/database.boltdb/' $CONFIG_PATH/config.json
sed -i 's/\/root\/snap\/semaphore\/common\/repositories/\/tmp\/semaphore/' $CONFIG_PATH/config.json
adduser --system --group --home $CONFIG_PATH --no-create-home --shell /bin/bash $USER
cp /etc/skel/.* $CONFIG_PATH
chown -R $SUI_USER:$SUI_USER $TEMP_DIR
chmod o-rwx $CONFIG_PATH
chown -R $SUI_USER:$SUI_USER $CONFIG_PATH
EOF
