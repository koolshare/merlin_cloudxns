#!/bin/sh
eval `dbus export cloudxns_`
source /koolshare/scripts/base.sh
logger "[软件中心]: 正在卸载CloudXNS DDNS..."
MODULE=cloudxns
cd /
/koolshare/scripts/cloudxns_update.sh stop
rm -f /koolshare/scripts/cloudxns_config.sh
rm -f /koolshare/scripts/cloudxns_update.sh
rm -f /koolshare/webs/Module_cloudxns.asp
rm -f /koolshare/res/icon-cloudxns.png
rm -fr /tmp/cloudxns* >/dev/null 2>&1
values=`dbus list cloudxns | cut -d "=" -f 1`

for value in $values
do
dbus remove $value 
done
cru d cloudxns
logger "[软件中心]: 完成CloudXNS DDNS卸载"
rm -f /koolshare/scripts/uninstall_cloudxns.sh
