#!/bin/sh

eval `dbus export cloudxns`
if [ "${cloudxns_enable}" == "1" ];then
    /koolshare/scripts/cloudxns_update.sh restart
else
    /koolshare/scripts/cloudxns_update.sh stop
fi 
