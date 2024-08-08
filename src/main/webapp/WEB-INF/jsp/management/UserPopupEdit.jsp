﻿<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<link rel="stylesheet" href="<c:url value='/css/jquery.argo.scrollbar.css'/>" type="text/css" />
<link rel="stylesheet" href="<c:url value='/css/jquery-argo.ui.css?ver=2017030601'/>" type="text/css" />
<link rel="stylesheet" href="<c:url value='/css/argo.common.css?ver=2017021301'/>"	type="text/css" />
<link rel="stylesheet" href="<c:url value='/css/argo.contants.css?ver=2017021601'/>" type="text/css" />
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery-1.11.3.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery-ui.js?ver=2017011301'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery.scrollbar.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery.cookie.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.core.js?ver=2017011301'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.basic.js?ver=2017011901'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.common.js?ver=2017012503'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.alert.js?ver=2017011301'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.popWindow.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.pagePreview.js'/>"></script>

<!-- 순서에 유의 -->
<script type="text/javascript" src="<c:url value='/scripts/security/rsa.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/security/jsbn.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/security/prng4.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/security/rng.js'/>"></script>

<script>
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo")).SVCCOMMONID.rows;
	var workMenu 	= "사용자정보관리팝업";
	var workLog 	= "";

	var cudMode;
	var reqTenantId;

	var insId;
	var bExistCheck = false;


	var caOldvalue = "";
	var caOldindex = 0;
	$(window).load(function(){
		$("#btnSearchCA").click(function(){
			var searchCA = $("#searchCAtext").val();
			var caArr = $("#ip_ControlAuth option:contains("+searchCA+")");
			if(caOldvalue != searchCA) {
				caOldindex = 0;
				caOldvalue = searchCA;
			}
			else if(caOldindex==caArr.length) {
                caOldindex = 0;
			}

			var scrPosition = 0;
			var $cayys = $('#ip_ControlAuth');
			if(caArr.length>0) {
                var caArrVal = caArr[caOldindex].value;
                var optionTop = $cayys.find('[value="'+caArrVal+'"]').offset().top;
                var selectTop = $cayys.offset().top;
                $cayys.scrollTop($cayys.scrollTop() + (optionTop - selectTop));
                caOldindex++;
            }
			else {
                $cayys.scrollTop(0);
                caOldindex=0;
                caOldvalue="";
            }

		});

		// 권한 변경 이벤트 처리
        /* if (loginInfo.grantId == "SuperAdmin") {
            $("#btnInitPswd").show();
        }
        else {
            $("#btnInitPswd").hide();
        } */

        // [비밀번호초기화] 버튼 클릭 이벤트 처리
        /* $("#btnInitPswd").click(function(e) {
            setPswdInit();
        }); */
	});

	$(function () {
		// 2020.01.13 yoonjh
		// SuperAdmin && SystemAdmin 만 wave 변환여부 기능 사용가능. default = false
		if (loginInfo.authRank > 3) {
			$("#td_waveConvert").css("display", "none");
		}

		// Manager 이하 disabled
        $(".input_table_tr_auth").find(":input").attr('disabled', loginInfo.authRank > 2);

		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };

		cudMode 	= sPopupOptions.cudMode;
		reqTenantId = sPopupOptions.tenantId || loginInfo.tenantId;
		insId 		= sPopupOptions.insId;

        // 저장 버튼 클릭 이벤트 처리
		$("#btnSavePop").click(function(){
            if (cudMode == 'I') {
                addUserInfo();      // 등록
            }
			else if (cudMode == 'U') {
			    modifyUserInfo();   // 변경
			}
		});

		$("#btnInitLoginCount").click(function(){
			fnInitLoginCount();
		});

		$("#btnInitLastLoginDate").click(function(){
			fnInitLastLoginDate();
		});
		
		
		$("#ip_GrantId").change(function(){
			controlAuthHandleCtrl();
		});
		
		

		// 2018.02.07 사용자 콤보박스 표시 여부
		var isUseUserCombo   = 1;
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_CHECK_LOGIN_DATE"}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					if (data.getRows() != "") {
						isUseUserCombo   = data.getRows()['code'];

						if (isUseUserCombo == 1) {
						   $("#trLoginDateCheck").attr('style', "display:;");
						}
					}
				}
			}
			catch(e) {
				console.log(e);
			}
		});
	  	ArgSetting();

	});


	function ArgSetting() {
		argoSetDatePicker();

        // 'SuperAdmin' 아니면 로그인사용자의 제어그룹
        if (loginInfo.authRank > 2) {
            argoJsonSearchList('userAuth', 'getUserControlGroupList', null, {tenantId: loginInfo.tenantId, userId: loginInfo.userId, controlAuth: loginInfo.controlAuth, grantId: loginInfo.grantId}, function (res, textStatus, jqXHR) {
                if (res.isOk()) {
                    initSelGroup("ip_GroupId", res.SVCCOMMONID.rows);
                }
            });
        }
        // 'SuperAdmin' 권한이면 사용자 태넌트의 전체그룹
        else {
            argoCbCreate("ip_GroupId", "comboBoxCode", "getControlAuthList", {findTenantId: reqTenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
        } 
        
        //argoCbCreate("ip_GroupId", "comboBoxCode", "getControlAuthList", {findTenantId: reqTenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
        

		argoCbCreate("ip_ControlAuth", "comboBoxCode", "getControlAuthList", {findTenantId: reqTenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_GrantId", "comboBoxCode", "getGrantList",	{findTenantId: reqTenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_MainPage", "comboBoxCode", "getMenuList",{}, {"selectIndex":0, "text":'선택하세요!', "value":''});

		fnGroupCbChange("ip_GroupId");
		fnGroupCbChange("ip_ControlAuth");


		// 권한 나보다 높은거 삭제
		if(loginInfo.authRank > 1){
			for(var i = loginInfo.authRank ; i > 1 ; i-- ){
				$('#ip_GrantId option').eq(i-1).remove();
			}
		}

		if(loginInfo.grantId == "GroupManager"){
			$("#ip_ControlAuth").attr("disabled", true);
		}

		if(cudMode =='I') {
			$("#ip_TenantId").val(reqTenantId);
			$("#ip_InsId").val(insId);

		}
		else {
			$("#ip_UserId").attr("disabled", true);
			$("#ip_UserPwd").attr("disabled", true);
			$(".modify_hide").hide();
			
	 		$("#ip_InsId").val(insId);

			fvCurRow = sPopupOptions.pRowIndex;
            //console.log("fvCurRow:", fvCurRow);

		   	argoSetValues("ip_", fvCurRow);

		   	$("#ip_TenantId").val(reqTenantId);

			$('#ip_GroupId option[value=' + fvCurRow.groupId + ']').prop("selected", true);
			$('#ip_GrantId option[value=' + fvCurRow.grantId + ']').prop("selected", true);

			if (fvCurRow.mainPage != "") {
				$('#ip_MainPage option[value=' + fvCurRow.mainPage + ']').prop("selected", true);
			}

			if (fvCurRow.controlAuth != "" && fvCurRow.controlAuth != null) {
				var arrControlAuth = fvCurRow.controlAuth.split(",");

				$.each(arrControlAuth, function( index, data ) {
					$('#ip_ControlAuth option[value=' + data + ']').prop("selected", true);
				});
			}

			$('input:radio[name="ip_AccessFlag"]').filter('[value=' + fvCurRow.accessFlag + ']').attr('checked', true);
			$('input:radio[name="ip_RetireeFlag"]').filter('[value=' + fvCurRow.retireeFlag + ']').attr('checked', true);
			$('input:radio[name="ip_LoginCheckUse"]').filter('[value=' + fvCurRow.loginCheckUse + ']').attr('checked', true);
			$('input:radio[name="ip_ConvertFlag"]').filter('[value=' + fvCurRow.convertFlag + ']').attr('checked', true);
			$('input:radio[name="ip_BackupFlag"]').filter('[value=' + fvCurRow.backupFlag + ']').attr('checked', true);
			$('input:radio[name="ip_PlayerKind"]').filter('[value=' + fvCurRow.playerKind + ']').attr('checked', true);
			$('input:radio[name="ip_RealPlayKind"]').filter('[value=' + fvCurRow.realPlayKind + ']').attr('checked', true);

			$('#chkRecListeningYn').prop('checked', fvCurRow.recListeningYn == 'Y');
            $("input:radio[id ='rdRecAprvConfirmYn']:input[value='"+ fvCurRow.recAprvYn +"']").attr("checked", true);
            $("input:radio[id ='rdQaYn']:input[value='"+ fvCurRow.qaYn +"']").attr("checked", true);
		}
		
		controlAuthHandleCtrl();
	}

    /**
     * 그룹 Selectbox 초기화
     */
    function initSelGroup(emId, list) {
        var $sel = $("#"+ emId);
        var options = {"selectIndex": 0, "text": '선택하세요!', "value": ''};

        // 그룹 Selectbox
        $sel.empty();
        $sel.append($('<option>').text(options.text).attr('value', options.value || ''));    // 선택하세요 추가

        $.each(list, function(index, item) {
            $sel.append($('<option>').text(item.codeNm).attr('value', item.code));
        });
        fnGroupCbChange(emId);
    }

    /**
     * 사용자정보 등록
     */
	function addUserInfo() {
	    // 비밀번호 체크
        if (validationPassword == false) {
            return;
        }

        // 필수입력 체크
        var aValidate = {
            rows:[
                 {"check":"length", "id":"ip_UserId"    , "minLength":1, "maxLength":50, "msgLength":"사용자아이디 입력하세요."}
                ,{"check":"length", "id":"ip_UserName"  , "minLength":1, "maxLength":50, "msgLength":"사용자명을 입력하세요."}
                ,{"check":"length", "id":"ip_UserPwd"	, "minLength":1, "maxLength":50,  "msgLength":"비밀번호를 입력하세요."}
                ,{"check":"length", "id":"ip_GroupId"  	, "minLength":1, "maxLength":50, "msgLength":"그룹을 선택해 주세요."}
                ,{"check":"length", "id":"ip_GrantId"  	, "minLength":1, "maxLength":50, "msgLength":"권한을 선택해 주세요."}
            ]
        };
        if (argoValidator(aValidate) != true) return;

        // Save
        argoConfirm("저장 하시겠습니까?", function() {
            // rsa 암호화
            encryptRsa();

            var param = {
                recListeningYn  : argoGetValue('chkRecListeningYn') || 'N',
                recAprvYn       : argoGetValue('rdRecAprvConfirmYn'),
                qaYn            : argoGetValue('rdQaYn'),
                uptId           : loginInfo.userId,
                controlGroup    : $('#ip_ControlAuth option:selected').toArray().map(item => item.value).join(),
            };

            // Save 요청
            argoJsonUpdate("userInfo", "setUserInfoInsert", "ip_", param, callback, {SVC_ARGO_PATH : "/ARGO/USERCONTROL.do"});

            /** Save Callback 처리 - Action Log 저장 */
            function callback(res) {
                if (res && res.resultCode == '0000') {
                    // Action Log Insert
                    var workLog = '[유저ID:' + argoGetValue('ip_UserId') + '] 등록';
                    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId: loginInfo.tenantId, userId: loginInfo.userId
                        ,actionClass:"action_class", actionCode:"W", workIp: loginInfo.workIp, workMenu:workMenu, workLog:workLog});

                    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
                }
                else if (res && res.resultMsg) {
                    argoAlert(res.resultMsg);;
                }
                else {
                    console.log(res);
                }
            }
        });
	}

    
    function fnDeptDepthChk(str){
    	var depth = str.split(" ").length-1;
    	console.log("depth : " + depth);
    	return depth;
    }
    

    /**
     * 사용자정보 변경 처리
     */
	function modifyUserInfo() {
	    // 비밀번호 체크
	    if (validationPassword == false) {
	        return;
        }
	    
	    
	    var controlAuthNmArr = $('#ip_ControlAuth option:selected').toArray().map(item => item.text);
	    var controlAuthValueArr = $('#ip_ControlAuth option:selected').toArray().map(item => item.value);
	    var groupStepChk = "N";
	    var groupStepNm = "";
	    
	    var userCtrlAuth = "";
	    /* $.each(controlAuthNmArr, function(idx, value){
	        console.log(value);
	        var nbspCnt = 0;
	        nbspCnt = fnDeptDepthChk(value);
	        debugger;
	    }); */
	   	
	    $.each(controlAuthValueArr, function(idx, value){
	        if(argoNullConvert(value) != ""){
	        	userCtrlAuth = userCtrlAuth + value + ",";
	        }
	    });
	    userCtrlAuth = userCtrlAuth.slice(0, -1);
	    
	    /* if(groupStepChk == "Y"){
	    	//groupStepNm.slice(0, -1);
	    	argoAlert("제어소속 다중 선택은 4STEP만 가능합니다. 하기의 소속을 제거 후 다시 시도해 주세요.<br><br>" + "제거대상소속 : " + groupStepNm.slice(0, -2));
	    	return;
	    } */

        // 필수입력 체크
        var aValidate = {
            rows:[
                 {"check":"length", "id":"ip_UserId"    , "minLength":1, "maxLength":50, "msgLength":"사용자아이디 입력하세요."}
                ,{"check":"length", "id":"ip_UserName"  , "minLength":1, "maxLength":50, "msgLength":"사용자명을 입력하세요."}
                ,{"check":"length", "id":"ip_GroupId"  	, "minLength":1, "maxLength":50, "msgLength":"그룹을 선택해 주세요."}
                ,{"check":"length", "id":"ip_GrantId"  	, "minLength":1, "maxLength":50, "msgLength":"권한을 선택해 주세요."}
            ]
        };
        if (argoValidator(aValidate) != true) return;

        // Save
        argoConfirm("저장 하시겠습니까?", function() {
            // rsa 암호화
            encryptRsa();
            
            var param = {
                recListeningYn  : argoGetValue('chkRecListeningYn') || 'N',
                recAprvYn       : argoGetValue('rdRecAprvConfirmYn'),
                qaYn            : argoGetValue('rdQaYn'),
                uptId           : loginInfo.userId,
                //controlGroup    : $('#ip_ControlAuth option:selected').toArray().map(item => item.value).join()
                controlGroup	: userCtrlAuth
            };

            // Save 요청
            //argoJsonUpdate("userInfo", "setUserInfoUpdate", "ip_", param, callback, {SVC_ARGO_PATH : "/ARGO/USERCONTROL.do"});
            
            var multiService = new argoMultiService(callback);
            multiService.argoUpdate("userInfo","setUserInfoUpdate","ip_", param);
            multiService.argoUpdate("userInfo","setUserAuthUpdate","ip_", param);
            //debugger;
			multiService.action();
            

            /** Save Callback 처리 - Action Log 저장 */
            function callback(res) {
                if (res && res.resultCode == '0000') {
                    // 수정 내용 로깅 Start
                    var workLog = '[유저ID:' + argoGetValue('ip_UserId') + '] 수정';
                    if(fvCurRow.userName != $("#ip_UserName").val()) {
                        workLog += (" (사용자명 수정 : "+fvCurRow.userName+" -> "+$("#ip_UserName").val()+")");
                    }

                    if(fvCurRow.accessFlag != $("input[name='ip_AccessFlag']:checked").val()) {
                        workLog += (" (상담사접속권한 수정 : "+fvCurRow.accessFlagName+" -> "+$("input[name='ip_AccessFlag']:checked").next().text()+")");
                    }

                    if(fvCurRow.groupId != $("#ip_GroupId").val()) {
                        workLog += (" (그룹 수정 : "+fvCurRow.groupName+" -> "+$("#ip_GroupId option:checked").text()+")");
                    }

                    if(fvCurRow.grantId != $("#ip_GrantId").val()) {
                        workLog += (" (권한 수정 : "+fvCurRow.grantName+" -> "+$("#ip_GrantId option:checked").text()+")");
                    }

                    if(fvCurRow.retireeFlag != $("input[name='ip_RetireeFlag']:checked").val()) {
                        var bRetireeText = fvCurRow.retireeFlag == "0" ? "예" : "아니오";
                        workLog += (" (퇴직여부 수정 : "+bRetireeText+" -> "+$("input[name='ip_RetireeFlag']:checked").next().text()+")");
                    }

                    if(String(fvCurRow.mainPage).replace("null", "") != $("#ip_MainPage").val()) {
                        workLog += (" (메인페이지 수정 : "+$("#ip_MainPage option[value='"+fvCurRow.mainPage+"']").text()+" -> "+$("#ip_MainPage option:checked").text()+")");
                    }

                    if(fvCurRow.loginCheckUse != $("input[name='ip_LoginCheckUse']:checked").val()) {
                        var bLoginCheckUseText = fvCurRow.loginCheckUse == "1" ? "예" : "아니오";
                        workLog += (" (로그인사용기간 수정 : "+bLoginCheckUseText+" -> "+$("input[name='ip_LoginCheckUse']:checked").next().text()+")");
                    }

                    if(fvCurRow.loginCheckFrom != $("#ip_LoginCheckFrom").val().replace(/-/g, "") || fvCurRow.loginCheckTo != $("#ip_LoginCheckTo").val().replace(/-/g, "")) {
                        var bLoginCheckText = argoNullConvert((fvCurRow.loginCheckFrom)).replace(/(\d{4})(\d{2})(\d{2})/g, '$1-$2-$3') + " ~ " + argoNullConvert((fvCurRow.loginCheckTo)).replace(/(\d{4})(\d{2})(\d{2})/g, '$1-$2-$3');
                        var aLoginCheckText = argoNullConvert($("#ip_LoginCheckFrom").val()) + " ~ " + argoNullConvert($("#ip_LoginCheckTo").val());
                        workLog += (" (로그인가능기간 수정 : "+bLoginCheckText+" -> "+aLoginCheckText+")");
                    }

                    if(String(fvCurRow.controlAuth).replace("null", "") != $("#ip_ControlAuth").val()) {
                        workLog += (" (제어그룹 수정)");
                    }

                    if(fvCurRow.convertFlag != $("input[name='ip_ConvertFlag']:checked").val()) {
                        var bConvertFlagText = fvCurRow.convertFlag == "0" ? "예" : "아니오";
                        workLog += (" (Wave변환 수정 : "+bConvertFlagText+" -> "+$("input[name='ip_ConvertFlag']:checked").next().text()+")");
                    }

                    if(fvCurRow.playerKind != $("input[name='ip_PlayerKind']:checked").val()) {
                        var bPlayerKindText = fvCurRow.playerKind == "0" ? "웹재생" : "전용재생(Veloce)";
                        workLog += (" (재생방식 수정 : "+bPlayerKindText+" -> "+$("input[name='ip_PlayerKind']:checked").next().text()+")");
                    }
                    // 수정 내용 로깅 End

                    // Action Log Insert
                    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId: loginInfo.tenantId, userId: loginInfo.userId
                        ,actionClass:"action_class", actionCode:"W", workIp: loginInfo.workIp, workMenu:workMenu, workLog:workLog});

                    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
                }
                else if (res && res.resultMsg) {
                    $("#ip_UserPwd").val("");
                    argoAlert(res.resultMsg);;
                }
                else {
                    console.log(res);
                }
            }
        });
	}

    /**
     * 비밀번호 유효성 검사
     */
	function validationPassword() {
	    var userPwdCheck = $("#ip_UserPwd").val();
        var userIdCheck = $("#ip_UserId").val();

        if (userPwdCheck != "") {
            var regExp = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[~`!@#$%\\^&*()-]).{8,50}$/;

            if (!regExp.test(userPwdCheck)) {
                argoAlert("비밀번호를 확인하세요.<br>영문+숫자+특수문자 포함 8자 이상");
                return false ;
            }
            else if (/(\w)\1\1/.test(userPwdCheck)) {
                argoAlert("비밀번호를 확인하세요.<br>같은 문자를 3번 이상 사용하실 수 없습니다.");
                return false ;
            }
            else if(userPwdCheck.indexOf(userIdCheck) != -1) {
                argoAlert("비밀번호를 확인하세요.<br>ID는 비밀번호로 사용하실 수 없습니다.");
                return false ;
            }
        }

        return true;
	}

	/**
	 * RSA 암호화
	 */
	function encryptRsa() {
	    // rsa 암호화 Start
        var oriUserPwd = $('#ip_UserPwd').val();
        if (oriUserPwd != "") {
            var rsa = new RSAKey();
            rsa.setPublic($('#RSAModulus').val(), $('#RSAExponent').val());

            var encUserPwd = rsa.encrypt(oriUserPwd);
            $('#ip_UserPwd').val(encUserPwd);
        }
        // rsa 암호화 End
	}


    /**
	 * 로그인 오류 카운트 초기화
	 */
	function fnInitLoginCount() {
		argoConfirm("로그인 오류 카운트를 초기화하시겠습니까?", function() {
			var param = {tenantId: loginInfo.tenantId, userId: loginInfo.userId, "findUserId":$("#ip_UserId").val()};

		    Resultdata = argoJsonUpdate("userInfo","initLoginErrorCount","ip_", param);

		    if(Resultdata.isOk()) {
		    	argoAlert('성공적으로 초기화 되었습니다.');
		    }
		});
	}

    /**
	 * 최종 로그인 날짜 초기화
	 */
	function fnInitLastLoginDate() {
		argoConfirm("최종 로그인 날자를 초기화하시겠습니까?", function() {
			var param = {tenantId: loginInfo.tenantId, userId: loginInfo.userId, "findUserId":$("#ip_UserId").val()};

			Resultdata = argoJsonUpdate("userInfo","initLastLoginDate","ip_", param);

			if(Resultdata.isOk()) {
				argoAlert('성공적으로 초기화 되었습니다.');
			}
		});
	}

    /**
     * 비밀번호 초기화 처리
     */
    function setPswdInit() {
        argoConfirm("비밀번호를 초기화하시겠습니까?", function() {
            var param = {tenantId: reqTenantId, userId: $("#ip_UserId").val()};

            // Update
            argoJsonUpdate("userInfo", "setUserPswdInit", null, param, callback, {SVC_ARGO_PATH : "/ARGO/USERCONTROL.do"});

            /** 저장 Callback 처리 */
            function callback(res) {
                if (res && res.resultCode == '0000') {
                    argoAlert('성공적으로 초기화 되었습니다.');
                }
            }
        });
    }

    
    
    function controlAuthHandleCtrl(){
    	var selectGrantId = argoGetValue("ip_GrantId");
    	
    	if(selectGrantId == "GroupManager" || selectGrantId == "Agent"){
    		$("#ip_ControlAuth").attr("disabled", false);
    	}else{
    		argoSetValue("ip_ControlAuth", "");
        	$("#ip_ControlAuth").attr("disabled", true);
    	}
    }
    
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
					<span class="btn_r">
					    <!-- <button type="button" id="btnInitPswd" name="btnInitPswd" class="btn_m" style="display: none;">비밀번호초기화</button> -->
						<button type="button" id="btnInitLastLoginDate" name="btnInitLastLoginDate" class="btn_m">최종 로그인 날자 초기화</button>
						<button type="button" id="btnInitLoginCount" name="btnInitLoginCount" class="btn_m">로그인 오류 횟수 초기화</button>
						<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>
                       	<input type="hidden" id="ip_Salt" name="ip_Salt" />
                       	<input type="hidden" id="ip_InsId" name="ip_InsId" />
                       	<input type="hidden" id="ip_TenantId" name="ip_TenantId" />
                    </span>
                </div>
                <div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                        		<th>사용자ID<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_UserId" name="ip_UserId" style="width: 200px"	class="mr10" />
                                </td>
                            	<th>사용자명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_UserName" name="ip_UserName" style="width:200px;" class="mr10" />
                                </td>
                            </tr>
                            <tr>
                            	<th class="modify_hide">비밀번호<span class="point">*</span></th>
                                <td class="modify_hide">
                                	<input type="text" id="ip_UserPwd" name="ip_UserPwd" style="width:200px;-webkit-text-security:disc;" autocomplete="new-password" class="mr10" />
                                	<input type="hidden" id="RSAModulus" name="RSAModulus" value="${RSAModulus}">
									<input type="hidden" id="RSAExponent" name="RSAExponent" value="${RSAExponent}">
                                </td>
                            	<th>상담사접속권한</th>
                                <td callspan="3">
                                	<input type="radio" name="ip_AccessFlag" id="ip_AccessFlag" value="0" checked /><label>허용</label>
                                	<input type="radio" name="ip_AccessFlag" id="ip_AccessFlag" value="1" /><label>비허용</label>
								</td>
                            </tr>
                            <tr>
                            	<th>그룹<span class="point">*</span></th>
                                <td>
                                	 <select id="ip_GroupId" name="ip_GroupId" style="width:200px;" class="list_box">
                                     </select>
                                </td>
                                <th>권한<span class="point">*</span></th>
                                <td>
                                	<select id="ip_GrantId" name="ip_GrantId" style="width:200px;" class="list_box">
                                    </select>
                                </td>
							</tr>
                            <tr>
                            	<th>퇴직여부</th>
                                <td>
                                	<input type="radio" name="ip_RetireeFlag" id="retireeFlag" value="0" /><label>예</label>
                                	<input type="radio" name="ip_RetireeFlag" id="retireeFlag" value="1" checked /><label>아니오</label>
								</td>
								<th>메인페이지</th>
								<td>
                                	<select id="ip_MainPage" name="ip_MainPage" style="width:200px;" class="list_box">
                                    </select>
                                </td>    
                            </tr>
                            <tr id="trLoginDateCheck" style="display:none">
                            	<th>로그인 사용기간</th>
                                <td>
                                	<input type="radio" name="ip_LoginCheckUse" id="LoginCheckUse" value="1" /><label>예</label>
                                	<input type="radio" name="ip_LoginCheckUse" id="LoginCheckUse" value="0" checked /><label>아니오</label>
								</td>
								<th>로그인가능기간</th>
                                <td>
									<span class="select_date"><input type="text" id="ip_LoginCheckFrom" name="ip_LoginCheckFrom"  class="datepicker onlyDate"></span>
		                            <span class="text_divide">~</span>
		                            <span class="select_date"><input type="text" id="ip_LoginCheckTo" name="ip_LoginCheckTo"  class="datepicker onlyDate"></span>
								</td>
                            </tr>
                            <tr class='input_table_tr_auth'>
                            	<th rowspan="2">제어그룹</th>
                            	<td colspan="5">
                            		키보드의 ctrl 버튼을 누른 상태에서 제어할 그룹을 선택하시면 다중 선택이 가능합니다. ( 필요시 하부그룹까지 선택 )
                            		<br>
                            		<input type="text" id="searchCAtext" name="searchCAtext">
                            		<button type="button" class="btn_m confirm" id="btnSearchCA" name="btnSearchCA">조회</button>  
                               </td>
                            </tr>
                            <tr class='input_table_tr_auth'>
                            	<td colspan="5">
                            		<select name="ip_ControlAuth" id="ip_ControlAuth" class="s8"  style="width: 98%;height: 150px" multiple="multiple"  >
									</select> 
                            	</td>
                            </tr>
                            

                            <tr class='input_table_tr_auth' style="display: none;">
                            	<th>재생방식</th>
                                <td colspan="5">
                                	<input type="radio" name="ip_PlayerKind" id="ip_PlayerKind" value="0"/><label>웹재생</label>
                                	<input type="radio" name="ip_PlayerKind" id="ip_PlayerKind" value="1" checked /><label>전용재생(Veloce)</label>
									<input type="hidden" name="ip_RealPlayKind" id="ip_RealPlayKind" value="1" />
								</td>
                            </tr>

                            <tr>
                                <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인권한<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    <input type="checkbox" class="checkbox" id="chkRecListeningYn" name="chkRecListeningYn" value="Y" checked>
                                    <label for="ckRecListeningYn" style="width: 60px">청취</label>
                                </td>
                            </tr>
                            <tr class='input_table_tr_auth'>
                                <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인내역확인<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    <input type="radio" name="rdRecAprvConfirmYn" id="rdRecAprvConfirmYn" value="Y" /><label>예</label>
                                    <input type="radio" name="rdRecAprvConfirmYn" id="rdRecAprvConfirmYn" value="N" checked /><label>아니요</label>
                                </td>
                            </tr>
                            <tr>
                                <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">평가권한<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    <input type="radio" name="rdQaYn" id="rdQaYn" value="A" /><label>전체권한</label>
                                    <input type="radio" name="rdQaYn" id="rdQaYn" value="Y" /><label>평가권한</label>
                                    <input type="radio" name="rdQaYn" id="rdQaYn" value="N" checked/><label>없음</label>
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
