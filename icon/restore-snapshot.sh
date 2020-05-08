#!/bin/bash
RED='\033[0;31m'
GREEN="\033[1;32m"
BLUE="\033[1;34m"
NOCOLOR="\033[0m"
 
RESTORE_DIR=${DEFAULT_PATH}
 
ORIGIN_IP=`ifconfig eth0 | grep inet | awk '{print $2}'`
 
S3_PATH="https://s3.ap-northeast-2.amazonaws.com/icon-leveldb-backup/MainctzNet"
 
## Var Check
if [[ $1 == "" ]]; then
    NOW_IP=$ORIGIN_IP
else
    NOW_IP=$1
fi

## Process Check
if [[ 0 != `ps -ef | grep -v grep | grep -E "icon_service|loopchain" | wc -l`  ]]; then
    echo "$RED Process running $GREEN" 
    ps -ef | grep -v grep | grep icon
    echo "$RED stop Process please $NOCOLOR"
    exit 0
fi
 
## IP Check
if [[ ! $NOW_IP =~ ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3} ]]
   then
        echo "$RED IP info Fault $NOCOLOR"
        exit 0
fi
 
function trapshell {
     echo "$RED STOP SHELL $NOCOLOR"
     exit 0;
}
 
function Download_Backup {
    icon_latest=$(curl -s ${S3_PATH}/backup_list | head -n 1)
    filename=$(echo $icon_latest | awk -F/ '{print $NF}')
    mkdir -p $RESTORE_DIR
    echo "$GREEN \n\n\n PHASE 2 \n Down Load Backup File $filename \n\n\n $BLUE"
    axel -a ${S3_PATH}/$icon_latest --output $RESTORE_DIR/$filename
}
 
function Restore_DB {
    echo -e "$GREEN \n Restore process $filename \n\n\n $NOCOLOR"
    tar -I pigz -xf $RESTORE_DIR/$filename -C $RESTORE_DIR
    mv $RESTORE_DIR/.storage/db_CHANGEIP\:7100_icon_dex/ $RESTORE_DIR/.storage/db_$NOW_IP:7100_icon_dex
}
 
trap trapshell 1 2 15
Download_Backup
Restore_DB
echo "Done."