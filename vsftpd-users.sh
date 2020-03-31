#!/bin/sh
useradd -p `openssl passwd -1 $2` $1
mkdir /home/$1
chown $1:$1 /home/$1
#chmod 0777 /home/$1
#chmod a-w /home/$1
echo "success"

