<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
        <meta HTTP-EQUIV="Expires" CONTENT="-1"/>
        <link rel="shortcut icon" href="images/favicon.png"/>
        <link rel="icon" href="images/favicon.png"/>
        <title>软件中心 - CloudXNS设置</title>
        <link rel="stylesheet" type="text/css" href="index_style.css"/>
        <link rel="stylesheet" type="text/css" href="form_style.css"/>
        <link rel="stylesheet" type="text/css" href="usp_style.css"/>
        <link rel="stylesheet" type="text/css" href="ParentalControl.css">
        <link rel="stylesheet" type="text/css" href="css/icon.css">
        <link rel="stylesheet" type="text/css" href="css/element.css">
        <script type="text/javascript" src="/state.js"></script>
        <script type="text/javascript" src="/popup.js"></script>
        <script type="text/javascript" src="/help.js"></script>
        <script type="text/javascript" src="/validator.js"></script>
        <script type="text/javascript" src="/js/jquery.js"></script>
        <script type="text/javascript" src="/general.js"></script>
        <script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
        <script type="text/javascript" src="/dbconf?p=cloudxns_&v=<% uptime(); %>"></script>
        <script type="text/javascript" src="/res/rsa.js"></script>
        <script type="text/javascript" src="/res/md5.js"></script>
        <script type="text/javascript" src="/res/sha1.js"></script>
        <script type="text/javascript">
        var $G = function(id) {
            return document.getElementById(id);
        };
        var Base64;
        if(typeof btoa == "Function") {
            Base64 = {encode:function(e){ return btoa(e); }, decode:function(e){ return atob(e);}};
        } else {
            Base64 ={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t="";var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,"");while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){e=e.replace(/\r\n/g,"\n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t="";var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}
        }
        function init() {
            show_menu();
            buildswitch();
            var rrt = document.getElementById("switch");
            if (document.form.cloudxns_enable.value != "1") {
                rrt.checked = false;
                document.getElementById('cloudxns_detail_table').style.display = "none";
            } else {
                rrt.checked = true;
                document.getElementById('cloudxns_detail_table').style.display = "";
            }
            //双wan开始判断
            var lb_mode = '<% nvram_get("wans_mode"); %>';
            if(lb_mode !== "lb"){
                document.getElementById('double_wan_set').style.display = "none";
                document.getElementById('select_wan').style.display = "none";
                document.form.cloudxns_config_wan.value = 0;
            } else {
                check_selected("cloudxns_config_wan", db_cloudxns_.cloudxns_config_wan);
            }
            version_show();
            write_cloudxns_run_status();
            check_selected("cloudxns_auto_start", db_cloudxns_.cloudxns_auto_start);
            check_selected("cloudxns_refresh_time", db_cloudxns_.cloudxns_refresh_time);
        }

        var kn = '00AC69F5CCC8BDE47CD3D371603748378C9CFAD2938A6B021E0E191013975AD683F5CBF9ADE8BD7D46B4D2EC2D78AF146F1DD2D50DC51446BB8880B8CE88D476694DFC60594393BEEFAA16F5DBCEBE22F89D640F5336E42F587DC4AFEDEFEAC36CF007009CCCE5C1ACB4FF06FBA69802A8085C2C54BADD0597FC83E6870F1E36FD';
        var ke = '010001';

        var rsa = new RSAKey();

        rsa.setPublic(kn, ke);

        function onSubmitCtrl() {
            var _form = document.form;
            if(trim(_form.cloudxns_config_api_key.value)=="" || trim(_form.cloudxns_config_secret_key.value)=="" || trim(_form.cloudxns_config_domain.value)==""){
                alert("提交的表单不能为空!");
                return false;
            }
            document.form.action_mode.value = ' Refresh ';
            document.form.SystemCmd.value = "cloudxns_config.sh";
            document.form.submit();
            showLoading(2);
            setTimeout("conf2obj()", 8000);
        }
        function qj2bj(str){
            var tmp = "";
            for(var i=0;i<str.length;i++){
                if(str.charCodeAt(i) >= 65281 && str.charCodeAt(i) <= 65374){
                    tmp += String.fromCharCode(str.charCodeAt(i)-65248)
                }else if(str.charCodeAt(i) == 12288){
                    tmp += ' ';
                }else{
                    tmp += str[i];
                }
            }
            return tmp;
        }
        function conf2obj() {
            $.ajax({
                type: "get",
                url: "dbconf?p=cloudxns_",
                dataType: "script",
                success: function(xhr) {
                    var p = "cloudxns_";
                    var params = ["run_status"];
                    for (var i = 0; i < params.length; i++) {
                        if (typeof db_cloudxns_[p + params[i]] !== "undefined") {
                            $("#cloudxns_"+params[i]).val(db_cloudxns_[p + params[i]]);
                        }
                    }
                    $("#cloudxns_run_state").html(Base64.decode(db_cloudxns_['cloudxns_run_status']));
                    check_selected("cloudxns_auto_start", db_cloudxns_.cloudxns_auto_start);
                    check_selected("cloudxns_refresh_time", db_cloudxns_.cloudxns_refresh_time);
                }
            });
        }

        function buildswitch(){
            $("#switch").click(
            function(){
                if(document.getElementById('switch').checked){
                    document.form.cloudxns_enable.value = 1;
                    document.getElementById('cloudxns_detail_table').style.display = "";
                }else{
                    document.form.cloudxns_enable.value = 0;
                    document.getElementById('cloudxns_detail_table').style.display = "none";
                }
            });
        }

        function check_selected(obj, m) {
            var o = document.getElementById(obj);
            for (var c = 0; c < o.length; c++) {
                if (o.options[c].value == m) {
                    o.options[c].selected = true;
                    break;
                }
            }
        }

        function write_cloudxns_run_status(){
            $.ajax({
                type: "get",
                url: "dbconf?p=cloudxns_",
                dataType: "script",
                success: function() {
                    var p = "cloudxns_";
                    var params = ["run_status"];
                    for (var i = 0; i < params.length; i++) {
                        if (typeof db_cloudxns_[p + params[i]] !== "undefined") {
                            $("#cloudxns_"+params[i]).val(db_cloudxns_[p + params[i]]);
                        }
                    }
                    $("#cloudxns_run_state").html(Base64.decode(db_cloudxns_['cloudxns_run_status']));

                    setTimeout("write_cloudxns_run_status()", 10000);
                }
            });
        }

        function version_show(){
            $("#cloudxns_version_status").html("<i>当前版本：" + db_cloudxns_['cloudxns_version']);
            $.ajax({
                url: 'https://koolshare.ngrok.wang/cloudxns/config.json.js',
                type: 'GET',
                success: function(res) {
                    var txt = $(res.responseText).text();
                    if(typeof(txt) != "undefined" && txt.length > 0) {
                        //console.log(txt);
                        var obj = $.parseJSON(txt.replace("'", "\""));
                        $("#cloudxns_version_status").html("<i>当前版本：" + obj.version+ "</i>");
                        if(obj.version != db_cloudxns_["cloudxns_version"]) {
                            $("#cloudxns_version_status").html("<font color=\"#66FF66\">有新版本：" + res.version + "</font>");
                        }
                    }
                }
            });
        }

        function done_validating(action) {
            return true;
        }

        function reload_Soft_Center() {
            location.href = "/Main_Soft_center.asp";
        }
        </script>
    </head>
    <body onload="init();">
        <div id="TopBanner"></div>
        <div id="Loading" class="popup_bg"></div>
        <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
        <form method="post" name="form" action="/applydb.cgi?p=cloudxns_" target="hidden_frame">
            <input type="hidden" name="current_page" value="Module_cloudxns.asp"/>
            <input type="hidden" name="next_page" value="Module_cloudxns.asp"/>
            <input type="hidden" name="group_id" value=""/>
            <input type="hidden" name="modified" value="0"/>
            <input type="hidden" name="action_mode" value=""/>
            <input type="hidden" name="action_script" value=""/>
            <input type="hidden" name="action_wait" value="5"/>
            <input type="hidden" name="first_time" value=""/>
            <input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
            <input type="hidden" name="SystemCmd" value=""/>
            <input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
            <input type="hidden" id="cloudxns_enable" name="cloudxns_enable" value='<% dbus_get_def("cloudxns_enable", "0"); %>'/>
            <input type="hidden" id="cloudxns_run_status" name="cloudxns_run_status" value='<% dbus_get_def("cloudxns_run_status", "0"); %>'/>

            <table class="content" align="center" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="17">&nbsp;</td>
                    <td valign="top" width="202">
                        <div id="mainMenu"></div>
                        <div id="subMenu"></div>
                    </td>
                    <td valign="top">
                        <div id="tabMenu" class="submenuBlock"></div>
                        <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
                            <tr>
                                <td align="left" valign="top">
                                    <table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
                                        <tr>
                                            <td bgcolor="#4D595D" colspan="3" valign="top">
                                                <div>&nbsp;</div>
                                                <div style="float:left;" class="formfonttitle">CloudXNS DDNS</div>
                                                <div style="float:right; width:15px; height:25px;margin-top:10px"><img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img></div>
                                                <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
                                                <div class="formfontdesc" style="padding-top:5px;margin-top:0px;float: left;" id="cmdDesc">
                                                <div>使用CloudXNS实现的ddns服务</div>
                                                <ul style="padding-top:5px;margin-top:10px;float: left;">
                                                <li>使用前需要将域名添加到CloudXNS中，并添加一条A记录，使用之后将自动更新ip</li>
                                                <li>点 <a href="https://www.cloudxns.net/Support/detail/id/51.html" target="_blank"><i><u>这里</u></i></a> 查看官方说明以及如何获取API KEY</li>
                                                </ul>
                                                </div>
                                                <!--<div class="formfontdesc" id="cmdDesc"></div>-->
                                                <table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="routing_table">
                                                    <thead>
                                                    <tr>
                                                        <td colspan="2">开关设置</td>
                                                    </tr>
                                                    </thead>
                                                    <tr>
                                                    <th>开启CloudXNS</th>
                                                        <td colspan="2">
                                                            <div class="switch_field" style="display:table-cell;float: left;">
                                                                <label for="switch">
                                                                    <input id="switch" class="switch" type="checkbox" style="display: none;">
                                                                    <div class="switch_container" >
                                                                        <div class="switch_bar"></div>
                                                                        <div class="switch_circle transition_style">
                                                                            <div></div>
                                                                        </div>
                                                                    </div>
                                                                </label>
                                                            </div>
                                                            <div id="cloudxns_version_status" style="padding-top:5px;margin-left:30px;margin-top:0px;float:left;"><i>当前版本：<% dbus_get_def("cloudxns_version", "未知"); %></i></div>
                                                            <div id="cloudxns_changelog_show" style="padding-top:5px;margin-right:30px;margin-top:0px;float: right;"><a href="https://raw.githubusercontent.com/koolshare/merlin_cloudxns/master/Changelog.txt" target="_blank"><em><u>[ 更新日志 ]</u></em></a></div>
                                                    </td>
                                                    </tr>
                                                </table>
                                                <table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="cloudxns_detail_table">
                                                    <thead>
                                                    <tr>
                                                        <td colspan="2">基本设置</td>
                                                    </tr>
                                                    </thead>
                                                    <tr>
                                                        <th width="35%">API KEY</th>
                                                        <td>
                                                            <input type="password" name="cloudxns_config_api_key" style="width:430px;margin-top: 3px;" id="cloudxns_config_api_key" class="input_ss_table" autocomplete="new-password" autocorrect="off" autocapitalize="off" maxlength="256" value="<% dbus_get_def("cloudxns_config_api_key", ""); %>" onBlur="switchType(this, false);" onFocus="switchType(this, true);"/>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th width="35%">SECRET KEY</th>
                                                        <td>
                                                            <input type="password" name="cloudxns_config_secret_key" style="width:430px;margin-top: 3px;" id="cloudxns_config_secret_key" class="input_ss_table" autocomplete="new-password" autocorrect="off" autocapitalize="off" maxlength="256" value="<% dbus_get_def("cloudxns_config_secret_key", ""); %>" onBlur="switchType(this, false);" onFocus="switchType(this, true);"/>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th width="35%">域名</th>
                                                        <td>
                                                            <input type="text" class="input_ss_table" style="width:430px;margin-top: 3px;" id="cloudxns_config_domain" name="cloudxns_config_domain" maxlength="40" placeholder="填写完整域名,如：router.domain.com" value='<% dbus_get_def("cloudxns_config_domain", ""); %>' >
                                                        </td>
                                                    </tr>

                                                    <thead>
                                                    <tr>
                                                        <td colspan="3">运行状态</td>
                                                    </tr>
                                                    </thead>
                                                    <tr>
                                                        <th width="35%">状态</th>
                                                        <td>
                                                            <a>
                                                                <span id="cloudxns_run_state"></span>
                                                            </a>
                                                        </td>
                                                    </tr>

                                                    <thead>
                                                    <tr>
                                                        <td colspan="4">启动设置</td>
                                                    </tr>
                                                    </thead>
                                                    <tr>
                                                        <th width="35%">开机自启</th>
                                                        <td>
                                                            <select id="cloudxns_auto_start" name="cloudxns_auto_start" class="input_option"  >
                                                                <option value="1">是</option>
                                                                <option value="0">否</option>
                                                            </select>
                                                        </td>
                                                    </tr>
                                                    <thead>
                                                    <tr>
                                                        <td colspan="4">刷新设置</td>
                                                    </tr>
                                                    </thead>
                                                    <tr>
                                                        <th width="35%">刷新时间</th>
                                                        <td>
                                                            <select id="cloudxns_refresh_time" name="cloudxns_refresh_time" class="input_option"  >
                                                                <option value="1">1H</option>
                                                                <option value="5">5H</option>
                                                                <option value="10">10H</option>
                                                            </select>
                                                        </td>
                                                    </tr>

                                                    <thead id="double_wan_set">
                                                    <tr>
                                                        <td colspan="4">双WAN设置</td>
                                                    </tr>
                                                    </thead>
                                                    <tr id="select_wan">
                                                        <th width="35%">加速WAN口</th>
                                                        <td>
                                                            <select id="cloudxns_config_wan" name="cloudxns_config_wan" class="input_option"  >
                                                                <option value="1">WAN1</option>
                                                                <option value="2">WAN2</option>
                                                            </select>
                                                        </td>
                                                    </tr>

                                                 </table>
                                                 <div id="warn" style="display: none;margin-top: 20px;text-align: center;font-size: 20px;margin-bottom: 20px;"class="formfontdesc" ></div>
                                                <div class="apply_gen">
                                                    <button id="cmdBtn" class="button_gen" onclick="onSubmitCtrl();">提交</button>
                                                </div>
                                                <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>
                                                <div class="KoolshareBottom">
                                                    <br/>论坛技术支持： <a href="http://www.koolshare.cn" target="_blank"> <i><u>www.koolshare.cn</u></i> </a> <br/>
                                                    后台技术支持： <i>Xiaobao</i> <br/>
                                                    Shell, Web by： <i>freexiaoyao</i><br/>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="10" align="center" valign="top"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </form>
        <div id="footer"></div>
    </body>
</html>
