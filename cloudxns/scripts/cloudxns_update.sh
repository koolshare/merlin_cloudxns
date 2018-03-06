#!/bin/sh

#################################################
#由CloudXNS DDNS with BashShell修改而来
#源项目地址:https://github.com/lixuy/CloudXNS-DDNS-with-BashShell
# Mod: Clang   2017-11-09
# http://koolshare.cn/home.php?mod=space&uid=29821&do=thread&view=me&from=space
#################################################

# ====================================变量定义====================================
# 导入skipd数据
eval `dbus export cloudxns`
# 引用环境变量等
source /koolshare/scripts/base.sh
export PERP_BASE=/koolshare/perp
#CONF START
# API KEY
API_KEY=${cloudxns_config_api_key}
SECRET_KEY=${cloudxns_config_secret_key}
# 域名
DDNS="${cloudxns_config_domain}"
CHECKURL="https://ip.ngrok.wang"
#CONF END
[ "${cloudxns_config_ntp}" == "" ] && ntp_server="ntp1.aliyun.com" || ntp_server=${cloudxns_config_ntp}
echo ${ntp_server}
ntpclient -h ${ntp_server} -i3 -l -s > /dev/null 2>&1
URL="http://www.cloudxns.net/api2/ddns"
JSON="{\"domain\":\"$DDNS\"}"
NOWTIME=$(env LANG=en_US.UTF-8 date +'%a %h %d %H:%M:%S %Y')
HMAC=$(echo -n ${API_KEY}${URL}${JSON}${NOWTIME}${SECRET_KEY}|md5sum|awk '{print $1}')
date

# 获得外网地址
arIpAdress() {
    #双WAN判断
    local wans_mode=$(nvram get wans_mode)
    if [ "${cloudxns_config_wan}" == "1" ] && [ "${wans_mode}" == "lb" ]; then
        inter=$(nvram get wan0_pppoe_ifname)
    elif [ "${cloudxns_config_wan}" == "2" ] && [ "${wans_mode}" == "lb" ]; then
        inter=$(nvram get wan1_pppoe_ifname)
    else
        inter=$(nvram get wan0_pppoe_ifname)
    fi
    echo ${inter}
}
#将执行脚本写入crontab定时运行
add_cloudxns_cru(){
    if [ "${cloudxns_auto_start}" == "1" ]; then
        [ ! -L /koolshare/init.d/S99cloudxns.sh ] && ln -sf /koolshare/scripts/cloudxns_config.sh /koolshare/init.d/S99cloudxns.sh
    fi
    if [ "${cloudxns_refresh_time}" == "0" ]; then
        stop_cloudxns
    else
        if [ "${cloudxns_refresh_time_check}" == "1" ]; then
            cru a cloudxns "*/${cloudxns_refresh_time} * * * * /koolshare/scripts/cloudxns_update.sh restart"
        elif [[ "${cloudxns_refresh_time_check}" == "2" ]]; then
            cru a cloudxns "0 */${cloudxns_refresh_time} * * * /koolshare/scripts/cloudxns_update.sh restart"
        else
            stop_cloudxns
        fi
    fi
}
cloudxns_ddns_stop(){
    nvram set ddns_enable_x=0
    nvram commit
}
cloudxns_ddns_start(){
    # ddns setting
    if [ "${cloudxns_enable}"x = "1"x ];then
        # ddns setting
        if [[ "${cloudxns_config_ddns}" == "1" ]] && [[ "${cloudxns_config_domain}" != "" ]]; then
            nvram set ddns_enable_x=1
            nvram set ddns_hostname_x=${cloudxns_config_domain}
            ddns_custom_updated 1
            nvram commit
        elif [[ "${cloudxns_config_ddns}" == "2" ]]; then
            echo "ddns no setting"
        else
            cloudxns_ddns_stop
        fi
    else
        cloudxns_ddns_stop
    fi
}
#停止服务
stop_cloudxns(){
    #停掉cru里的任务
    local cloudxnscru=$(cru l | grep "cloudxns")
    if [ ! -z "${cloudxnscru}" ]; then
        cru d cloudxns
    fi
    if [ "$cloudxns_auto_start" == "0" ]; then
        rm -f /koolshare/init.d/S99cloudxns.sh
    fi
}
cloudxns_update(){
    if (echo ${CHECKURL} |grep -q "://");then
        IPREX='([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
        LOCALIP=$(ping $DDNS -c1|grep -Eo "$IPREX"|tail -n1)
        #URLIP=$(curl $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -s $CHECKURL|grep -Eo "$IPREX"|tail -n1)
        URLIP=$(curl $(if [ -n "${OUT}" ]; then echo "--interface ${OUT}"; fi) -s ${CHECKURL})
        echo "[DNS IP]:${LOCALIP}"
        echo "[URL IP]:${URLIP}"
        if [ "${LOCALIP}" == "${URLIP}" ];then
            dbus set cloudxns_run_status="`echo wan ip未改变，无需更新|base64_encode`"
            exit
        fi
    fi
    OUT=$(arIpAdress)
    POST=$(curl $(if [ -n "$OUT" ]; then echo "--interface $OUT"; fi) -k -s $URL -X POST -d $JSON -H "API-KEY: $API_KEY" -H "API-REQUEST-DATE: $NOWTIME" -H "API-HMAC: $HMAC" -H 'Content-Type: application/json')
    if (echo ${POST} |grep -q "success");then
        dbus set cloudxns_run_status="`echo 更新成功|base64_encode`"
        cloudxns_ddns_start
    else
        dbus set cloudxns_run_status="`echo 更新失败:${POST}|base64_encode`"
        cloudxns_ddns_stop
    fi
}
# ====================================主逻辑====================================

case ${ACTION} in
start)
    #此处为开机自启动设计
    if [ "${cloudxns_enable}" == "1" ];then
        add_cloudxns_cru
        cloudxns_update
    fi
    ;;
stop | kill )
    cloudxns_ddns_stop
    stop_cloudxns
    ;;
restart)
    if [ "${cloudxns_enable}" == "1" ];then
        stop_cloudxns
        add_cloudxns_cru
        cloudxns_update
    fi
    ;;
*)
    echo "Usage: $0 (start|stop|restart|kill)"
    exit 1
    ;;
esac

