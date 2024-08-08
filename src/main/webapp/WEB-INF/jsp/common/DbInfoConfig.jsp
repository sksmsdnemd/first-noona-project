<%@ page language="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>

<script type="text/javascript">
	
	var param;
	var userPw;
	var userId;
	var loUserPw;
	var loUserId;
	var driver;
	var url;
	var encryptType;
	var encryptList;
	var encryptSalt;
	var dbKind;
	var dbPort;
	var dbIp;
	var sid;
	var centerCd;
	var centerNm;
	var archiveSerIp;
	var archiveDir;
	var failOver;
	var loadBalance;
	var termValList;
	var agentUseYn;
	var recAuth;
	var authUserId1;
	var authUserId2;
	var swatInitPwType;
	var swatInitPw;
	var validationSql;
	var duplicateLogin;

	$(document).ready(function() {
		window.onkeydown = function()	{
			//Ctrl + Shift + E
			if( event.which ===  69 && event.shiftKey && event.ctrlKey ) {
				goPage();
			}
		};
		
		loUserPw		= '<spring:eval expression="@code['Globals.admin.passwd']"/>';
		loUserId		= '<spring:eval expression="@code['Globals.admin.id']"/>';
		userPw			= '<spring:eval expression="@code['Globals.ARGO.RDB.Password']"/>';
		userId			= '<spring:eval expression="@code['Globals.ARGO.RDB.Account']"/>';
		dbKind			= '<spring:eval expression="@code['Globals.ARGO.RDB.Kind']"/>';
		encryptType		= '<spring:eval expression="@code['Globals.encryptType']"/>';
		encryptList		= '<spring:eval expression="@code['Globals.encryptList']"/>';
		encryptSalt		= '<spring:eval expression="@code['Globals.encryptSalt']"/>';
		driver			= '<spring:eval expression="@code['Globals.ARGO.RDB.Driver']"/>';
		url				= '<spring:eval expression="@code['Globals.ARGO.RDB.Url']"/>';
		dbPort			= '<spring:eval expression="@code['Globals.ARGO.RDB.DbPort']"/>';
		dbIp			= '<spring:eval expression="@code['Globals.ARGO.RDB.DbIp']"/>';
		sid				= '<spring:eval expression="@code['Globals.ARGO.RDB.Sid']"/>';
		centerCd		= '<spring:eval expression="@code['Globals.ARGO.RDB.CenterCd']"/>';
		centerNm		= '<spring:eval expression="@code['Globals.ARGO.RDB.CenterNm']"/>';
		archiveSerIp	= '<spring:eval expression="@code['Globals.ARGO.RDB.ArchiveSerIp']"/>';
		archiveDir		= '<spring:eval expression="@code['Globals.ARGO.RDB.ArchiveDir']"/>';
		failOver		= '<spring:eval expression="@code['Globals.ARGO.RDB.FailOver']"/>';
		loadBalance		= '<spring:eval expression="@code['Globals.ARGO.RDB.LoadBalance']"/>';
		validationSql	= '<spring:eval expression="@code['Globals.ARGO.RDB.ValidationSql']"/>';
		termValList		= '<spring:eval expression="@code['Globals.termValList']"/>';
		agentUseYn		= '<spring:eval expression="@code['Globals.agentUseYn']"/>';
		recAuth			= '<spring:eval expression="@code['Globals.recAuth']"/>';
		authUserId1		= '<spring:eval expression="@code['Globals.authUserId1']"/>';
		authUserId2		= '<spring:eval expression="@code['Globals.authUserId2']"/>';
		swatInitPwType	= '<spring:eval expression="@code['Globals.swatInitPwType']"/>';
		swatInitPw		= '<spring:eval expression="@code['Globals.swatInitPw']"/>';
		duplicateLogin	= '<spring:eval expression="@code['Globals.VLC.SESSION.Security']"/>';

		$("#encryptType").val(encryptType);
		$("#encryptList").val(encryptList);
		$("#encryptSalt").val(encryptSalt);
		$("#driverKind").val(dbKind);
		
// 		if(url.indexOf("?useUnicode=true&characterEncoding=utf8") == -1) {
		if(url.indexOf("useUnicode=true&characterEncoding=utf8") == -1) {
			$("input:checkbox[id='preventBrokenKor']").prop("checked", false);
		} else {
			$("input:checkbox[id='preventBrokenKor']").prop("checked", true);
		}
		
		if(url.indexOf("/"+sid) == -1) {
			$("input:checkbox[id='serviceName']").prop("checked", false);
		} else {
			$("input:checkbox[id='serviceName']").prop("checked", true);
		}
		
		$("#driver").val(driver);
		$("#url").val(url);
		$("#validationSql").val(validationSql);
		
		$("#dataPort").val(dbPort);
		$("#dataIp").val(dbIp);
		$("#dataSid").val(sid);
		$("#centerCd").append("<option value="+centerCd+" selected>"+centerNm+"</option>");
		$("#centerNm").val(centerNm);
		$("#centerId").val(centerCd);
		$("#archiveSerIp").val(archiveSerIp);
		$("#archiveDir").val(archiveDir);
		$("#failOver").val(failOver);
		$("#loadBalance").val(loadBalance);
		$("#agentUseYn").val(agentUseYn);
		$("#recAuth").val(recAuth);
		$("#authUserId1").val(authUserId1);
		$("#authUserId2").val(authUserId2);

		$("#swatInitPwType").val(swatInitPwType == '' ? 'acc' : swatInitPwType);
		$("#duplicateLogin").val(duplicateLogin);

		var encList = encryptList.split("|");
		
		$.each(encList,function(index, row){ 
			$("#encryptType").append("<option value="+row+" selected>"+row+"</option>");
		});
		
		decryptVal();
		
		$("#driverKind").bind('change',function(){
			var driverKind  = $("#driverKind").val();
			var changeUrl = "";
			var preventBrokenKorStr = "";
			if($("input:checkbox[id='preventBrokenKor']").is(":checked")) {
				if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB') {
					preventBrokenKorStr = "&useUnicode=true&characterEncoding=utf8";
				} else {
					preventBrokenKorStr = "?useUnicode=true&characterEncoding=utf8";
				}
			}
			
			if(driverKind == 'MSSQL'){
				$("#driver").val("com.microsoft.sqlserver.jdbc.SQLServerDriver");
				changeUrl = "jdbc:sqlserver://"+$("#dataIp").val()+":"+$("#dataPort").val()+";databaseName="+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
				$("#validationSql").val("SELECT 1");
			}else if(driverKind == 'ORACLE'){
				$("#driver").val("oracle.jdbc.driver.OracleDriver");
				if($("input:checkbox[id='serviceName']").is(":checked")) {
					changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
				} else {
				changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				}
				$("#url").val(changeUrl);
				$("#validationSql").val("SELECT 1 FROM DUAL");
			}else if(driverKind == 'TIBERO'){
				$("#driver").val("com.tmax.tibero.jdbc.TbDriver");
				changeUrl = "jdbc:tibero:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
				$("#validationSql").val("SELECT 1 FROM DUAL");
			}else if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB'){
				$("#driver").val("com.mysql.jdbc.Driver");
				changeUrl = "jdbc:mysql://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+"?allowMultiQueries=true"+preventBrokenKorStr;
				$("#url").val(changeUrl);
				$("#validationSql").val("SELECT 1");
// 			}else if(driverKind == 'MARIADB'){
// 				$("#driver").val("org.mariadb.jdbc.Driver");
// 				changeUrl = "jdbc:mariadb://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
// 				$("#url").val(changeUrl);
// 				$("#validationSql").val("SELECT 1");
			}
		});
	
		$(".fouOut").on('focusout', function(){
			var driverKind  = $("#driverKind").val();
			var changeUrl = "";
			var preventBrokenKorStr = "";
			if($("input:checkbox[id='preventBrokenKor']").is(":checked")) {
				if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB') {
					preventBrokenKorStr = "&useUnicode=true&characterEncoding=utf8";
				} else {
					preventBrokenKorStr = "?useUnicode=true&characterEncoding=utf8";
				}
			}
			
			if(driverKind == 'MSSQL'){
				changeUrl = "jdbc:sqlserver://"+$("#dataIp").val()+":"+$("#dataPort").val()+";databaseName="+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
			}else if(driverKind == 'ORACLE'){
				if($("input:checkbox[id='serviceName']").is(":checked")) {
					changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
				} else {
				changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				}
				$("#url").val(changeUrl);
			}else if(driverKind == 'TIBERO'){
				changeUrl = "jdbc:tibero:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
			}else if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB'){
				changeUrl = "jdbc:mysql://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+"?allowMultiQueries=true"+preventBrokenKorStr;
				$("#url").val(changeUrl);
// 			}else if(driverKind == 'MARIADB'){
// 				changeUrl = "jdbc:mariadb://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
// 				$("#url").val(changeUrl);
			}
		});
		
		$("#preventBrokenKor").bind('change', function() {
			var driverKind  = $("#driverKind").val();
			var changeUrl = "";
			var preventBrokenKorStr = "";
			if($("input:checkbox[id='preventBrokenKor']").is(":checked")) {
				if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB') {
					preventBrokenKorStr = "&useUnicode=true&characterEncoding=utf8";
				} else {
					preventBrokenKorStr = "?useUnicode=true&characterEncoding=utf8";
				}
			}
			
			if(driverKind == 'MSSQL'){
				changeUrl = "jdbc:sqlserver://"+$("#dataIp").val()+":"+$("#dataPort").val()+";databaseName="+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
			}else if(driverKind == 'ORACLE'){
				if($("input:checkbox[id='serviceName']").is(":checked")) {
					changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
				} else {
					changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				}
				$("#url").val(changeUrl);
			}else if(driverKind == 'TIBERO'){
				changeUrl = "jdbc:tibero:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
			}else if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB'){
				changeUrl = "jdbc:mysql://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+"?allowMultiQueries=true"+preventBrokenKorStr;
				$("#url").val(changeUrl);
// 			}else if(driverKind == 'MARIADB'){
// 				changeUrl = "jdbc:mariadb://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
// 				$("#url").val(changeUrl);
			}
		});
		
		$("#serviceName").bind('change', function() {
			var driverKind  = $("#driverKind").val();
			var changeUrl = "";
			var preventBrokenKorStr = "";
			if($("input:checkbox[id='preventBrokenKor']").is(":checked")) {
				if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB') {
					preventBrokenKorStr = "&useUnicode=true&characterEncoding=utf8";
				} else {
					preventBrokenKorStr = "?useUnicode=true&characterEncoding=utf8";
				}
			}
			
			if(driverKind == 'MSSQL'){
				changeUrl = "jdbc:sqlserver://"+$("#dataIp").val()+":"+$("#dataPort").val()+";databaseName="+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
			}else if(driverKind == 'ORACLE'){
				if($("input:checkbox[id='serviceName']").is(":checked")) {
					changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
				} else {
				changeUrl = "jdbc:oracle:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				}
				$("#url").val(changeUrl);
			}else if(driverKind == 'TIBERO'){
				changeUrl = "jdbc:tibero:thin:@"+$("#dataIp").val()+":"+$("#dataPort").val()+":"+$("#dataSid").val()+preventBrokenKorStr;
				$("#url").val(changeUrl);
			}else if(driverKind == 'MYSQL5' || driverKind == 'MYSQL8' || driverKind == 'MARIADB'){
				changeUrl = "jdbc:mysql://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+"?allowMultiQueries=true"+preventBrokenKorStr;
				$("#url").val(changeUrl);
// 			}else if(driverKind == 'MARIADB'){
// 				changeUrl = "jdbc:mariadb://"+$("#dataIp").val()+":"+$("#dataPort").val()+"/"+$("#dataSid").val()+preventBrokenKorStr;
// 				$("#url").val(changeUrl);
			}
		});
		
		if($("#swatInitPwType").val() == 'acc') {
			$("#swatInitPw").val('');
			$("#swatInitPw").hide();
		}
		$("#swatInitPwType").bind('change', function() {
			if($("#swatInitPwType").val() == 'acc') {
				$("#swatInitPw").val('');
				$("#swatInitPw").hide();
			} else {
				$("#swatInitPw").show();
			}
		});
		
		var termArr = [
			{name : "당일&nbsp;&nbsp;&nbsp;", value : "당일:T_0"},
			{name : "1주일&nbsp;", value : "1주일:W_1"},
			{name : "2주일&nbsp;", value : "2주일:W_2"},
			{name : "3주일&nbsp;&nbsp;&nbsp;", value : "3주일:W_3"},
			{name : "4주일&nbsp;&nbsp;&nbsp;", value : "4주일:W_4"},
			{name : "5주일&nbsp;&nbsp;&nbsp;", value : "5주일:W_5"},
			{name : "1개월&nbsp;", value : "1개월:M_1"},
			{name : "2개월&nbsp;", value : "2개월:M_2"},
			{name : "3개월&nbsp;", value : "3개월:M_3"},
			{name : "4개월&nbsp;&nbsp;&nbsp;", value : "4개월:M_4"},
			{name : "5개월&nbsp;&nbsp;&nbsp;", value : "5개월:M_5"},
			{name : "6개월&nbsp;&nbsp;&nbsp;", value : "6개월:M_6"},
			{name : "7개월&nbsp;", value : "7개월:M_7"},
			{name : "8개월&nbsp;", value : "8개월:M_8"},
			{name : "9개월&nbsp;", value : "9개월:M_9"},
			{name : "10개월&nbsp;", value : "10개월:M_10"},
			{name : "11개월&nbsp;", value : "11개월:M_11"},
			{name : "12개월&nbsp;", value : "12개월:M_12"},
			{name : "시간대별&nbsp;", value : "시간대별:S_1"}
		];
		
		$.each(termArr,function(index, row) {
			var checkYn = "";
			if(termValList.indexOf(row.value) != -1) {
				checkYn = "checked";
			}
			
			$("#termVal").append("<input type='checkbox' value="+row.value+" name='termVal' "+checkYn+">"+row.name);
			
			if((index + 1) % 6 == 0) {
				$("#termVal").append("<br/>");
			}
		});
		
	});
	
	function decryptVal(){
		var decryptId			= userId;
		var decryptPw			= userPw;
		var decryptLoId			= loUserId;
		var decryptLoPw			= loUserPw;
		var decryptSwatInitPw	= swatInitPw;
		var param = {
				        decryptId			: decryptId
				      , decryptPw			: decryptPw
				      , decryptLoId			: decryptLoId
				      , decryptLoPw			: decryptLoPw
				      , decryptSwatInitPw	: decryptSwatInitPw
				      , Code				: "ENC"
					};
		
		$.ajax({
			type : 'post',
            data : param,
			url  : gGlobal.ROOT_PATH + "/dbInfoConfig.do",
			success : function(data) {
				$("#userId").val(data.chId);
				$("#userPw").val(data.chPw);
				$("#loUserId").val(data.chLoId);
				$("#loUserPw").val(data.chLoPw);
				$("#swatInitPw").val(data.chSwatInitPw);
			},
			error : function(xhr, status, error) {
                console.log(error);
			}
		});
	}

	function fnConfirm() {

		argoConfirm('수정 하시겠습니까?',  butSet);
	}
	
	function butSet() {

		argoShowLoadMsg();
		
		var chUserId			= $("#userId").val();
		var chUserPw			= $("#userPw").val();
		var chUserLoId			= $("#loUserId").val();
		var chUserLoPw			= $("#loUserPw").val();
		var chDriver			= $("#driver").val();
		var chUrl				= $("#url").val();
		var chEncryptType		= $("#encryptType").val();
		var chEncryptList		= $("#encryptList").val();
		var chEncryptSalt		= $("#encryptSalt").val();
		var chDbKind			= $("#driverKind").val();
		var chDbPort			= $("#dataPort").val();
		var chDbIp				= $("#dataIp").val();
		var chSid				= $("#dataSid").val();
		var chCenterCd			= $("#centerCd").val();
		var chCenterNm			= $("#centerNm").val();
		var chArchiveSerIp		= $("#archiveSerIp").val();
		var chArchiveDir		= $("#archiveDir").val();
		var chFailOver			= $("#failOver").val();
		var chLoadBalance		= $("#loadBalance").val();
		var chRecAuth			= $("#recAuth").val();
		var chAuthUserId1		= $("#authUserId1").val();
		var chAuthUserId2		= $("#authUserId2").val();
		var chSwatInitPwType	= $("#swatInitPwType").val();
		var chSwatInitPw		= $("#swatInitPw").val();
		var chValidationSql		= $("#validationSql").val();
		var chDuplicateLogin	= $("#duplicateLogin").val();

		var chTermValList 	= "";
		$("input[name=termVal]:checked").each(function(i, e) {
			if(i == 0) {
				chTermValList += $(this).val();
			} else {
				chTermValList += "|" + $(this).val();
			}
		});

		var chAgentUseYn 	= $("#agentUseYn").val();

		if(chRecAuth == "Y"){
			if(chAuthUserId1 == "" || chAuthUserId2 == ""){
				alert("아이디를입력하세요.");
				argoHideLoadMsg();
				return;

			}

		}
		
		param = { 
					  chUserId			: chUserId
					, chUserPw			: chUserPw
					, chUserLoId		: chUserLoId
					, chUserLoPw		: chUserLoPw
					, chDriver			: chDriver
					, chUrl				: chUrl
					, chEncryptType		: chEncryptType
					, chEncryptList		: chEncryptList
					, chEncryptSalt		: chEncryptSalt
					, chDbKind			: chDbKind
					, chDbPort			: chDbPort
					, chDbIp			: chDbIp
					, chSid				: chSid
					, chCenterCd		: chCenterCd
					, chCenterNm		: chCenterNm
					, chArchiveSerIp	: chArchiveSerIp
					, chArchiveDir		: chArchiveDir
					, chFailOver		: chFailOver
					, chLoadBalance		: chLoadBalance
					, chTermValList		: chTermValList
					, chAgentUseYn		: chAgentUseYn
					, chRecAuth			: chRecAuth
					, chAuthUserId1     : chAuthUserId1
					, chAuthUserId2     : chAuthUserId2
					, chSwatInitPwType	: chSwatInitPwType
					, chSwatInitPw		: chSwatInitPw
					, chValidationSql	: chValidationSql
					, chDuplicateLogin	: chDuplicateLogin
					, Code				: "SAVE"
		};
		
		$.ajax({
			type : 'post',
            data : param,
			url  : gGlobal.ROOT_PATH+"/dbInfoConfig.do",
			success : function(data) {
				if(data.ret=="success"){
					window.setTimeout(function(){
						argoAlert("수정 되었습니다.");
						argoHideLoadMsg();
				  	},5000);
					console.log(data);
				}else{
					argoHideLoadMsg();
					argoAlert("수정에 실패하였습니다.");
				}
			},error : function(xhr, status, error) {
                console.log(error);
			}
		});
	}
	
	
	
	function goPage(){
		window.location.replace(gGlobal.ROOT_PATH + '/Maintenance/vlcdmlF.do');
	}
	
	// 암호화
    function fnDbEncrypt(){
            if( $("#dbPwChange").val() == ""){
            		argoAlert("패스워드 확인.");
                    return false;
            }
            if($("#dbPwChange").val() != $("#dbPwChangeChk").val()){
            		argoAlert("변경 패스워드 확인이 일치하지 않습니다.");
                    return false;
            }

            if($("#dbPwChange").val() == $("#userPw").val()){
            		argoAlert("현재 DB 패스워드하고 동일 합니다.");
                    return false;
            }

            var param = {"sid":$("#dataSid").val(), "id" : $("#userId").val(), "pwChange" : $("#dbPwChange").val()};
            $.ajax({
                    url : "/BT-VELOCE/common/DbPassWordSecurityF.do",
                    type : "POST",
                    data:param,
                    async: false,
                    success : function(data) {
                            fnDBPwChange(data);
                    },error : function(xhr, status, error) {
                            argoAlert("DbPassWordSecurityF :"+error);
                    }
            });
    }
	
    function fnDBPwChange(data){
        var serverPort           = document.location.protocol == "http:" ? 7060 : 7070;
        var url = document.location.protocol+"//127.0.0.1:"+serverPort+"/"+ "DBPwChange.do" ;
        var param = {};
        param.sid = data.sid;
        param.id = data.id;
        param.pwChange = data.pwChange;
        param.paramDataType = "json";
        param.url = url;

        $.ajax({
                url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
                type : "POST",
                data:JSON.stringify(param),
                dataType : "json",
                contentType: "application/json; charset=utf-8",
                async: false,
                success : function(data) {
                        var result = JSON.parse(decodeURI(data));
                        if(result.result == "OK"){
                                fnDbRebootStart(param,result.data)
                        }else{
                                argoAlert("Fail :"+result.data);
                        }
                },error : function(xhr, status, error) {
                        argoAlert("fnDBPwChange :"+error+", status :"+status);
                }
        });
	}

    function fnDbRebootStart(param,systemInfo){
        var serverPort           = document.location.protocol == "http:" ? 7060 : 7070;
        $.each(systemInfo, function(index, row){
                var url = document.location.protocol + "//"+row.system_ip+":"+serverPort+"/MwsReboot.do";
                param.url = url;
                $.ajax({
                        url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
                        type : "POST",
                        data:JSON.stringify(param),
                        dataType : "json",
                        contentType: "application/json; charset=utf-8",
                        async: true,
                        success : function(data) {
                                var result = JSON.parse(decodeURI(data));
                                console.log(row.system_ip + ":" + result.data);
                        },error : function(xhr, status, error) {
                                console.log(row.system_ip + ":" + status);
                        }
                });
        });
        argoAlert("1분후 웹 재시작 시작합니다.");
	}


</script>
</head>
<body>
	<div class="sub_wrap">
        <section class="pop_contents">
            <div class="pop_cont pt5">
				<div class="btns_top">
	                <button type="button" id="btnAdd" onclick="javascript:fnConfirm();" class="btn_m confirm">수정</button>
	                <button type="button" id="btnDBPwChange" onclick="fnDBPwChange();" class="btn_m confirm">패스워드 변경</button>
<!-- 	                <button type="button" onclick="javascript:goPage();" class="btn_m confirm">비밀통로</button> -->
	                <!-- <button type="button" id="btnReset" class="btn_m">초기화</button> -->
				</div>
               	<div class="input_area" style="padding-bottom: 1px">
               		<table class="input_table" style="margin-bottom: 30px">
                       	<tbody>
                       		<tr>
	                      		<td colspan="1" align="center">
	                      			<span><strong class="title ml20" >목록</strong></span>
	                      		</td>
	                      		<td colspan="1" align="center">
	                      			<span><strong class="title ml20" >구분</strong></span>
	                      		</td>
	                      		<td colspan="2" align="center">
	                      			<span><strong class="title ml20" >설정값</strong></span>
	                      		</td>
	                      		<td colspan="2" align="center">
	                      			<span><strong class="title ml20" >설명</strong></span>
	                      		</td>
                       		</tr>
                       		<tr>
	                      		<th colspan="1" rowspan="16" align="left">
	                      			<span><strong class="title " >DBINFO등록</strong></span>
	                      		</th>
                       		</tr>
                       		<tr>
                   		   		<th colspan="1"><strong class="title ">센터명</strong></th>
                           		<td colspan="2">
                            	 	<select id="centerCd" name="centerCd" style="width:100px;" class="list_box">
                            			<option>선택하세요!</option>
                        			</select>
                        			<input type="text"	id="centerNm" name="centerNm" style="width:180px" class="mr10" readonly/>
                           		</td>
                           		<td></td>
                        	</tr>
                        	<tr>
                        		<th colspan="1"><strong class="title ">센터ID</strong></th>
                            	<td colspan="2">
                            		<input type="text"	id="centerId" name="centerId" style="width:180px" class="mr10" readonly/>
                            	</td>
                            	<td></td>
                        	</tr>
                         	<tr>
                          		<th colspan="1"><strong class="title ">DBMS종류</strong></th>
                             	<td colspan="2">
                              		<select id="driverKind" name="driverKind" style="width: 140px" class="list_box">
										<option value="MSSQL">MSSQL</option>
										<option value="ORACLE">ORACLE</option>
										<option value="TIBERO">TIBERO</option>
										<option value="MYSQL5">MYSQL 5.x 이하</option>
										<option value="MYSQL8">MYSQL 8.x 이상</option>
										<option value="MARIADB">MARIADB</option>
									</select>&nbsp;&nbsp;
									<input type="checkbox" id="preventBrokenKor">&nbsp;한글깨짐방지
                              	</td>
                              	<td>
                              		- 기본적으로 한글깨짐방지 체크 안해도 한글이 깨지지는 않음. 한글이 깨지는 DB의 경우에만 한글깨짐방지 체크.<br/>
                              		- MYSQL, MARIADB의 경우만 해당함.
                              	</td>
                        	</tr>
                        	<tr>
                        		<th colspan="1"> <strong class="title ">Database접속IP</strong></th>
                             	<td colspan="2">
                          			<input type="text" class="fouOut"	id="dataIp" name="dataIp" style="width:220px"/>
							 	</td>
							  	<td>
							 		오라클 Single 구성   - IP 1개만 입력 (예 : 100.100.107.10)<br/>
									오라클 Rac 구성 - ' , ' (콤마) 구분자로 IP 2개를 입력(예 : 100.100.107.10,100.100.107.11)
							 	</td>
                        	</tr>
                        	<tr>
                           		<th colspan="1"><strong class="title ">Database명(SID)</strong></th>
                             	<td colspan="2">
                           			<input type="text" class="fouOut"	id="dataSid" name="dataSid" style="width:180px"/>&nbsp;&nbsp;
                           			<input type="checkbox" id="serviceName">&nbsp;serviceName 사용
                             	</td>
                             	<td>
                             		- ORACLE의 경우 serviceName을 사용하는 경우 serviceName 사용 항목에 체크.<br/>
                             		- ORACLE의 경우만 해당함.
                             	</td>
						 	</tr>
						 	<tr>
						 		<th colspan="1"> <strong class="title ">Database Port</strong></th>
                             	<td colspan="2">
                          			<input type="text" class="fouOut" id="dataPort" name="dataPort" style="width:180px"/>
                             	</td>
                             	<td></td>
						 	</tr>
						  	<tr>
                           		<th colspan="1"><strong class="title ">DatabaseUrl</strong></th>
                               	<td colspan="2">
                           			<input type="text"	id="url" name="url" style="width:450px" readonly/>
                               	</td>
                               	<td></td>
						  	</tr>
						  	<tr>
						  		<th colspan="1"> <strong class="title ">DatabaseDriver</strong></th>
                            	<td colspan="2">
                          			<input type="text"	id="driver" name="driver" style="width:300px" readonly/>
                               	</td>
                               	<td></td>
						  	</tr>
                           	<tr>
	                        	<th colspan="1"><strong class="title ">사용자ID</strong></th>
	                            <td colspan="2">
	                          		<input type="text"	id="userId" name="userId" style="width:280px"/>
								</td>
								<td></td>
                           	</tr>
                           	<tr>
                           		<th colspan="1"> <strong class="title ">비밀번호</strong></th>
	                        	<td colspan="2">
	                           		<input type="password"	id="userPw" name="userPw" style="width:280px"/>
								</td>
								<td></td>
                           	</tr>
                           	<tr>
                           		<th colspan="1"> <strong class="title ">VALIDATION SQL</strong></th>
	                        	<td colspan="2">
	                           		<input type="text"	id="validationSql" name="validationSql" style="width:300px" readonly/>
								</td>
								<td></td>
                           	</tr>
                           	<tr>
								<th colspan="1"> <strong class="title ">Fail Over(Oracle Rac)</strong></th>
								<td colspan="2">
		                        	<select id="failOver" name="failOver" style="width: 117px" class="list_box">
										<option value="ON">ON</option>
										<option value="OFF">OFF</option>
									</select>
									<span>(장애발생시 연결서버 변경)</span>
                               </td>
                               <td>
                               		 - 한쪽에서 장애가 발생했을때 다른쪽으로 넘겨서 처리할지 여부<br/>
                               </td>
                           	</tr>
                           	<tr>
                           		<th colspan="1"><strong class="title ">Load Balance(Oracle Rac)</strong></th>
                               	<td colspan="2">
									<select id="loadBalance" name="loadBalance" style="width: 117px" class="list_box">
										<option value="ON">ON</option>
										<option value="OFF">OFF</option>
									</select>
									<span>(분산처리)</span>
								</td>
								<td>
								  	- L4를 사용하면 L4 구성에 따라 맞추는것이 좋음 <br/>
								  	- L4에서 hash모드로 구성되어 로드밸런싱을 하지않는경우on으로설정하여db로드밸런싱이 되도록함<br/>
								   	- L4에서 로드밸런싱을 하는 경우 off로 설정하여 각각의 db에 일정비율의 요청이 들어가도록 함<br/>
								</td>
                           	</tr>
                           	<tr>
	                        	<th colspan="1"><strong class="title ">아카이브서버IP</strong></th>
	                           	<td colspan="2">
	                            	<input type="text"	id="archiveSerIp" name="archiveSerIp" style="width:180px"/>
	                            </td>
	                            <td></td>
                           	</tr>
                           	<tr>
                           		<th colspan="1"><strong class="title ">아카이브 디렉토리</strong></th>
	                           	<td colspan="2">
                         			<input type="text"	id="archiveDir" name="archiveDir" style="width:180px"/>
	                            </td>
	                            <td></td>
                           	</tr>
                           	<tr>
	                      		<th colspan="1" rowspan="4" align="left">
	                      			<span><strong class="title ">암호화정보</strong></span>
	                      		</th>
                      	   	</tr>
                      	   	<tr>
		                    	<th colspan="1"><strong class="title ">encryptType</strong></th>
		                    	<td colspan="2">
		                    		<select id="encryptType" name="encryptType" style="width:180px">
		                    		</select>
		                    	</td>
		                    	<td></td>
		                    </tr>
                            <tr>
                            	<th colspan="1"><strong class="title ">encryptList</strong></th>
		                    	<td colspan="2">
		                    		<input type="text"	id="encryptList" name="encryptList" style="width:180px"/>
		                    	</td>
		                    	<td></td>
                            </tr>
                            <tr>
                            	<th colspan="1"><strong class="title ">encryptSalt</strong></th>
                            	<td colspan="2">
		                    		<select id="encryptSalt" name="encryptSalt" style="width:180px">
		                    			<option value="Y">Y</option>
		                    			<option value="N">N</option>
		                    		</select>
		                    	</td>
		                    	<td></td>
                           	</tr>
                           	<tr>
                           		<th colspan="1" rowspan="5" align="left">
	                      			<span><strong class="title ">로그인정보</strong></span>
	                      		</th>
                           	</tr>
                            <tr>
	                        	<th colspan="1"><strong class="title ">Login ID</strong></th>
	                            <td colspan="2">
	                          		<input type="text"	id="loUserId" name="loUserId" style="width:280px"/>
								</td>
								<td></td>
                           	</tr>
                           	<tr>
                           		<th colspan="1"> <strong class="title ">Login PW</strong></th>
	                            <td colspan="2">
	                           		<input type="password"	id="loUserPw" name="loUserPw" style="width:280px"/>
								</td>
								<td></td>
                           	</tr>
                           	<tr>
                           		<th colspan="1"> <strong class="title ">중복로그인 허용여부</strong></th>
	                            <td colspan="2">
	                            	<select id="duplicateLogin" name="duplicateLogin" style="width:100px">
		                    			<option value="">선택</option>
		                    			<option value="0">허용</option>
		                    			<option value="1">비허용</option>
		                    		</select>
								</td>
								<td></td>
                           	</tr>
                           	<tr>
                           		<th colspan="1"> <strong class="title ">SWAT 연동 초기 비밀번호</strong></th>
	                            <td colspan="2">
	                            	<select id="swatInitPwType" name="swatInitPwType" style="width:100px">
		                    			<option value="acc">계정</option>
		                    			<option value="pw">비밀번호</option>
		                    		</select>
	                           		<input type="password"	id="swatInitPw" name="swatInitPw" style="width:200px"/>
								</td>
								<td>
								  	- 계정 선택시 SWAT 연동된 계정이 초기 로그인 비밀번호로 설정됨<br/>
								  	- 비밀번호 선택시 입력된 비밀번호가 초기 로그인 비밀번호로 설정됨<br/>
								</td>
                           	</tr>
                           	
                           	<tr>
                           		<th colspan="2" rowspan="2" align="left">
	                      			<span><strong class="title ">검색기간 기본설정</strong></span>
	                      		</th>
                           	</tr>
                            <tr>
	                            <td colspan="2" id="termVal"></td>
								<td>- 화면의 검색 조건 중 검색기간에 대한 select 값을 설정한다.</td>
                           	</tr>

							<tr>
								<th colspan="2"><strong class="title ">Agent 사용여부</strong></th>
								<td colspan="3">
									<select id="agentUseYn" name="agentUseYn" style="width:180px">
										<option value="Y">Y</option>
										<option value="N">N</option>
									</select>
								</td>
							</tr>
							<tr>
								<th colspan="2" rowspan="2"><strong class="title ">청취인증 사용여부</strong></th>
								<td rowspan="2">
									<select id="recAuth" name="recAuth" style="width:180px">
										<option value="Y">Y</option>
										<option value="N">N</option>
									</select>

								</td>
								<th colspan="1"><strong class="title ">인증 ID (1)</strong></th>
								<td>
									<input type="text"	id="authUserId1" name="authUserId2" style="width:280px"/>
								</td>
							</tr>

							<tr>

								<th colspan="1"><strong class="title ">인증 ID (2)</strong></th>
								<td>
									<input type="text"	id="authUserId2" name="authUserId2" style="width:280px"/>
								</td>
							</tr>
							<tr>
							         <th colspan="1" rowspan="4" align="left">
							                 <span><strong class="title ">DB패스워드</strong></span>
							         </th>
							 </tr>
							 <tr>
							         <th colspan="1"><strong class="title ">변경 패스워드</strong></th>
							         <td colspan="2">
							                 <input type="password"  id="dbPwChange" name="dbPwChange" style="width:280px"/>
							        </select>
							</td>
							<td rowspan="2">
							        <button type="button" id="btnDBPwChange" onclick="fnDbEncrypt();" class="btn_m confirm">확인</button>
				            </td>
					        </tr>
							<tr>
							    <th colspan="1"><strong class="title ">변경 패스워드 확인</strong></th>
					            <td colspan="2">
					                    <input type="password"  id="dbPwChangeChk" name="dbPwChangeChk" style="width:280px"/>
					            </td>
							</tr>

						</tbody>
                   	</table>
                </div>
            </div>
        </section>
    </div>
</body>

</html>