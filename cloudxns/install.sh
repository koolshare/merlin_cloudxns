#!/bin/sh
source /koolshare/scripts/base.sh
MODULE=cloudxns
VERSION="0.0.1"
cd /tmp
cp -rf /tmp/cloudxns/scripts/* /koolshare/scripts/
cp -rf /tmp/cloudxns/webs/* /koolshare/webs/
cp -rf /tmp/cloudxns/res/* /koolshare/res/

chmod a+x /koolshare/scripts/cloudxns_config.sh
chmod a+x /koolshare/scripts/cloudxns_update.sh
chmod a+x /koolshare/scripts/uninstall_cloudxns.sh
ln -sf /koolshare/scripts/cloudxns_config.sh /koolshare/init.d/S99cloudxns.sh
dbus set cloudxns_version="${VERSION}"
dbus set softcenter_module_cloudxns_install=1
dbus set softcenter_module_cloudxns_name=${MODULE}
dbus set softcenter_module_cloudxns_title="CloudXNS DDNS"
dbus set softcenter_module_cloudxns_description="使用CloudXNS的ddns服务。"
dbus set softcenter_module_cloudxns_version=`dbus get cloudxns_version`
rm -rf /tmp/cloudxns* >/dev/null 2>&1
logger "[软件中心]: 完成CloudXNS DDNS安装"
exit