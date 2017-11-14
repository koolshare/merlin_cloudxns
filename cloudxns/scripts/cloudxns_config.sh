#!/bin/sh

eval `dbus export cloudxns`
if [ "${cloudxns_enable}" == "1" ];then
    [ ! -x /koolshare/scripts/cloudxns_update.sh ] && chmod +x /koolshare/scripts/cloudxns_update.sh
    /koolshare/scripts/cloudxns_update.sh restart
else
    /koolshare/scripts/cloudxns_update.sh stop
fi 
