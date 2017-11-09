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
ntpclient -h ntp1.aliyun.com -i3 -l -s > /dev/null 2>&1
URL="http://www.cloudxns.net/api2/ddns"
JSON="{\"domain\":\"$DDNS\"}"
NOWTIME=$(env LANG=en_US.UTF-8 date +'%a %h %d %H:%M:%S %Y')
HMAC=$(echo -n ${API_KEY}${URL}${JSON}${NOWTIME}${SECRET_KEY}|md5sum|awk '{print $1}')
date

# 获得外网地址
arIpAdress() {
    #双WAN判断
    local wans_mode=$(nvram get wans_mode)
    if [ "$cloudxns_config_wan" == "1" ] && [ "$wans_mode" == "lb" ]; then
        inter=$(nvram get wan0_pppoe_ifname)
    elif [ "$cloudxns_config_wan" == "2" ] && [ "$wans_mode" == "lb" ]; then
        inter=$(nvram get wan1_pppoe_ifname)
    else
        inter=$(nvram get wan0_pppoe_ifname)
    fi
    echo ${inter}
}
#将执行脚本写入crontab定时运行
add_cloudxns_cru(){
    if [ -f /koolshare/scripts/cloudxns_update.sh ]; then
        #确保有执行权限
        chmod +x /koolshare/scripts/cloudxns_update.sh
        cru a cloudxns "0 */${cloudxns_refresh_time} * * * /koolshare/scripts/cloudxns_update.sh restart"
    fi
}

#停止服务
stop_cloudxns(){
    #停掉cru里的任务
    local cloudxnscru=$(cru l | grep "cloudxns")
    if [ ! -z "${cloudxnscru}" ]; then
        cru d cloudxns
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
    else
        dbus set cloudxns_run_status="`echo 更新失败:${POST}|base64_encode`"
    fi
}
# ====================================主逻辑====================================

case $ACTION in
start)
	#此处为开机自启动设计
	if [ "$cloudxns_enable" == "1" ] && [ "$cloudxns_auto_start" == "1" ];then
    add_cloudxns_cru
    cloudxns_update
	fi
	;;
stop | kill )
    stop_cloudxns
	;;
restart)
    stop_cloudxns
    add_cloudxns_cru
    cloudxns_update
    ;;
*)
    echo "Usage: $0 (start|stop|restart|kill)"
    exit 1
    ;;
esac

