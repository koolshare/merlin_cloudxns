#!/bin/sh
source /koolshare/scripts/base.sh
MODULE=cloudxns
VERSION="0.0.2"
cd /tmp
if [[ ! -x /koolshare/bin/base64_encode ]]; then
    cp -f /tmp/serverchan/bin/base64_encode /koolshare/bin/base64_encode
    chmod +x /koolshare/bin/base64_encode
    [ ! -L /koolshare/bin/base64_decode ] && ln -sf /koolshare/bin/base64_encode /koolshare/bin/base64_decode
fi
cp -rf /tmp/cloudxns/scripts/* /koolshare/scripts/
cp -rf /tmp/cloudxns/webs/* /koolshare/webs/
cp -rf /tmp/cloudxns/res/* /koolshare/res/

chmod a+x /koolshare/scripts/cloudxns_config.sh
chmod a+x /koolshare/scripts/cloudxns_update.sh
chmod a+x /koolshare/scripts/uninstall_cloudxns.sh
ln -sf /koolshare/scripts/cloudxns_config.sh /koolshare/init.d/S99cloudxns.sh
ntp_server=`dbus get cloudxns_config_ntp`
if [ "${ntp_server}" == "" ]; then
    dbus set cloudxns_config_ntp="ntp1.aliyun.com"
fi
dbus set cloudxns_version="${VERSION}"
dbus set softcenter_module_cloudxns_install=1
dbus set softcenter_module_cloudxns_name=${MODULE}
dbus set softcenter_module_cloudxns_title="CloudXNS DDNS"
dbus set softcenter_module_cloudxns_description="使用CloudXNS的ddns服务。"
dbus set softcenter_module_cloudxns_version=`dbus get cloudxns_version`
rm -rf /tmp/cloudxns* >/dev/null 2>&1
logger "[软件中心]: 完成CloudXNS DDNS安装"
exit