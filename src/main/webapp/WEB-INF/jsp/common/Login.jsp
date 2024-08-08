<!-- 
/****************************************************************
 * 파일명: Login.jsp
 * 설명   : 로그인페이지
 * 수정일		       수정자       Version		
 ****************************************************************
 * 2018.02.12	     	1.0			최초생성
 ****************************************************************
 */
-->
<%@ page language="java" import= "java.util.*,egovframework.com.cmm.util.EgovUserDetailsHelper" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="com.bridgetec.common.util.security.*"%>
<%@ page import="com.bridgetec.argo.common.*" %>
<%@ page import="java.text.*" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<title>VELOCE</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />

<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
 response.setHeader("Cache-Control","no-cache");
 response.setHeader("Pragma","no-cache");
 response.setDateHeader("Expires",0);
%>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="Expires" content="0"/>
<meta http-equiv="Pragma" content="no-cache"/>


<link rel="shortcut icon" href="<c:url value='/images/icons/argo.ico'/>" />
<link rel="stylesheet" href="<c:url value='/css/argo.common.css'/>" type="text/css" />
<link rel="stylesheet" href="<c:url value='/css/argo.login.css'/>" type="text/css" />
    
<style>

@keyframes subtle-blink {
     0% {
         opacity: 1;
     }
     50% {
         opacity: 0.5;
     }
     100% {
         opacity: 1;
     }
 }
  /* 은은한 깜빡임 스타일 */
 #test2.subtle-blink {
     animation: subtle-blink 2s infinite; /* 2초 간격으로 무한 반복 */
 }

 #test2 {
      background-color: #3498db; /* 파란색 배경 */
      color: #ffffff; /* 흰색 텍스트 */
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
      font-weight:bold;
      animation: subtle-blink 2s infinite;
  }




li:has(> a.active){}
.test1 .test2:parent{ color:red }
.btn_m {
	display: inline-block;
	height: 28px;
	line-height: 26px;
	padding: 0 15px;
	border: 1px solid #d3d3d3;
	box-shadow: 1px 1px 0px rgba(135, 135, 135, 0.1);
	color: #606060;
	font-size: 13px;
	background: #fff;
	margin-right: 3px;
	margin-top: 10px;
	box-sizing: border-box;
	cursor: pointer;
}

    /* 기본 버튼 스타일 */
    #test1 {
        padding: 10px 20px;
        font-size: 16px;
        border: none;
        cursor: pointer;
        border-radius: 5px;
    }

    /* 강조 스타일 */
    /*  */


       

</style>    

<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery-1.11.3.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery.cookie.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.core.js'/>"></script>
<!-- 2018 VLEOCE START -->
<script type="text/javascript"	src="<c:url value='/scripts/velocejs/veloce.basic.js?ver=2018121207'/>"></script>
<!-- 2018 VLEOCE END -->
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.basic.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.alert.js?ver=2017021301'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.common.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.util.js'/>"></script>
<%-- <script type="text/javascript" src="<c:url value='/scripts/security/sha512.js'/>"></script> --%>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.popWindow.js'/>"></script>

<!-- 순서에 유의 -->
<script type="text/javascript" src="<c:url value='/scripts/security/rsa.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/security/jsbn.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/security/prng4.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/security/rng.js'/>"></script>


<%
	boolean isSwatUse = true;
	String workIp    = request.getRemoteAddr();
	String sessionId = session.getId(); 
	String ssoTenant = request.getParameter("tenantId");
	String ssoUserId = request.getParameter("userId");

	String CT = request.getParameter("CSRF_TOKEN");
	
	if(isSwatUse) {			
		AESUtil.setKey("ipron-swat", 256);
		if(ssoUserId!=null) {
			ssoUserId = ssoUserId.split("_")[0];
			ssoUserId = AESUtil.decrypt(ssoUserId);
		}
 		 AESUtil.setKey("BRIDGETEC_VELOCE", Constant.ME_SHARED_BIT); 
	}
%>

<script type="text/javascript">
	var sessionChk 	= '<%=request.getAttribute("IsSessionValid")%>';  //ADD BY 2016-07-13 세션만료여부
	var resultMsg 	= decodeURIComponent('<%=request.getAttribute("resultMsg")%>');
	var errorCd 	= '<%=request.getAttribute("errorCd")%>';
	var workIp 		= '';
	var sessionId 	= '<%=sessionId%>';
	var ssoTenant 	= decodeURIComponent('<%=request.getAttribute("ssoTenant")%>');
	var ssoUserId 	= decodeURIComponent('<%=request.getAttribute("ssoUserId")%>');
	var ssoCheck 	= "N";
	var isUsCheckLoginIp;
	$(".login_wrap").hide();
	$(function () {
		
		selectTenantMake();

        if (resultMsg != 'null') {
            argoAlert(resultMsg);
        }
		if (ssoUserId != null && ssoUserId != "" && ssoUserId != "null") {
			ssoCheck = "Y";
		}

		// 통합로그인 체크
		if (ssoCheck == "Y") {
			//$(".login_wrap").hide();
			$("#s_TenantId").val(ssoTenant);
			$("#s_AgentId").val(ssoUserId);
			//argoJsonSearchOne("ARGOCOMMON", "login", "__", {CallMothd:"ssoCheck", tenantId:ssoTenant, agentId:ssoUserId, ssoCheck:ssoCheck}, loginCallback);
		}
		else {
			loadBody();
			$(".login_wrap").show();
		}
		
		if(vlcOPT.VLC_TENANT_SHOW=="1") {
			$('#s_TenantId').show();
		} else {
			$('#s_TenantId').hide();
		}
		
		fnServerGbTitleSetting();
		
		$("#btnPlayerD").click(function(){
			location.href='/BT-VELOCE/data/VLCPlayer_NonActiveX.exe';
		});
	});
	
	
	function fnServerGbTitleSetting(){
		var serverGb =  argoGetValue("s_ServerGb");
		// 서버구분 죽전
		if(serverGb == "JJ"){
			$("#serverGbTitle").text("- 죽 전 -");
			//$("#serverGbTitle").text("- 운영계 -");
			$("#serverGbTitle").css("color", "red");
		}
		// 서버구분 일산
		else if(serverGb == "IS"){
			$("#serverGbTitle").text("- 일 산 -");
			//$("#serverGbTitle").text("- 운영계 -");
			$("#serverGbTitle").css("color", "red");
		}
		else{
			$("#serverGbTitle").text("- 개발계 -");
			$("#serverGbTitle").css("color", "blue");
		}
	}
	
	
	
	function loadBody() {
		try {
			//세션만료에 따른 로그인창 오픈시
			if (errorCd == 'dateLicense'){
				argoAlert(resultMsg);
			}

			if (sessionChk == 'N') {
				argoAlert("세션이 만료되었거나  중복 로그인 되어 로그아웃 합니다.<br>다시 로그인 하십시요.");
			}
			
			if (argoGetCookie("loginId")) {
                $('#s_AgentId').val(argoGetCookie("loginId"));
                $('#id_check').get(0).checked = true;
                $('#agentPwView').focus();
            }
            else {
                $('#s_AgentId').focus();    
            }
            
			if (argoGetCookie("loginTenant")) {
                $('#s_TenantId').val(argoGetCookie("loginTenant"));
            }
			
 			var cookiesList = $.cookie();
 			
 			fnAdminPwChk();
		}
		catch(e) {
			argoAlert('error='+e.text);    		
		}
	}
	
	function fnAdminPwChk() {
		$.ajax({
			url : "/BT-VELOCE/common/GetRsaKeyF.do",
			type : "POST",
			async: false,
			success : function(data) {
                  	$("#RSAModulus").val(data.RSAModulus);
                  	$("#RSAExponent").val(data.RSAExponent);
                  	bAdminFlag = true;
			},error : function(xhr, status, error) {
				argoAlert("GetRsaKeyF :"+error);
			}
		});
				
	}
	
	function getConfigValue(){
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_CHECK_LOGIN_IP"}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						isUsCheckLoginIp = data.getRows()['code'];
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	} 
	
	function eventCheck() {
	    var code = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	    if (code == 13) {
	        formCheck();
	    }       
	}
	
	var Result;
	function formCheck() {
		try {    	
			if($.trim($('#s_AgentId').val()) == "") {
		        argoAlert('아이디를 입력하세요.');
		        $('#id_check').focus();
		        return;
		    }
			
		    if($.trim($('#agentPwView').val()) == "") {
		    	argoAlert('비밀번호를 입력하세요.');
		        $('#id_check').focus();
		        return;           
		    }
		    
		    if(vlcOPT.VLC_TENANT_SHOW=="1") {
			    if($('#s_TenantId').val() == "") {
			    	argoAlert('테넌트를 선택하세요.');
			        $('#id_check').focus();
			        return;           
			    }
			}
		   
			if($("#pass_visible").css("display") == "none") {
		    	$("#pass_check").prop("checked", false);
		    } 
		    var dateSetValue = Number($('#dateSetValue').val());
		    
		    if(vlcOPT.VLC_TENANT_SHOW=="1") {
		    	//수동으로 입력함 아무것도 하지않음
		    }
		    else {
		   		$('#s_TenantId').val(vlcOPT.VLC_SSO_TENANT_ID);
		    }
		    
            // 20220617 농협 이슈로 로그인 단순화 Start
		    var AgentPw 	 = $('#agentPwView').val();
			var dateSetValue = Number($('#dateSetValue').val());
			
			// rsa 암호화
			$.ajax({
				url : "/BT-VELOCE/common/GetRsaKeyF.do",
				type : "POST",
				async: false,
				success : function(data) {
	                  	$("#RSAModulus").val(data.RSAModulus);
	                  	$("#RSAExponent").val(data.RSAExponent);
	                  	bAdminFlag = true;
				},error : function(xhr, status, error) {
					argoAlert("GetRsaKeyF :"+error);
				}
			});
			
	        var rsa = new RSAKey();
	        rsa.setPublic($('#RSAModulus').val(), $('#RSAExponent').val());
	        AgentPw = rsa.encrypt(AgentPw);
			argoJsonSearchOne("ARGOCOMMON", "login", "s_", {AgentPw: AgentPw}, loginCallback, {SVC_ARGO_PATH : "/ARGO/login.do"});
            // 20220617 농협 이슈로 로그인 단순화 End
		}
		catch(e) {
			argoAlert(e);
		}
	}

	
	function loginCallback(Result, textStatus, jqXHR) {
	    console.log("#### Result:", Result);
		var pawCheck = Result.getRows().length;
		console.log("#### pawCheck:", pawCheck);
		if (pawCheck == 0) {
            // 로그인 실패시 RSA sessionKey가 삭제되기 때문에 페이지 새로고침 시켜줌.
            //argoAlert('warning', 'ID 또는 비밀번호가 틀립니다.', '', 'location.replace("'+gGlobal.ROOT_PATH + '/common/LoginF.do");');
            argoAlert('warning', Result.resultMsg, '', 'location.replace("'+gGlobal.ROOT_PATH + '/common/LoginF.do");');

            if(vlcOPT.VLC_TENANT_SHOW=="1") {
                argoJsonUpdate("userInfo", "setLoginFail", "ip_", {tenantId:$('#s_TenantId').val(), userId:$('#s_AgentId').val()});
            } else {
                argoJsonUpdate("userInfo", "setLoginFail", "ip_", {tenantId:vlcOPT.VLC_SSO_TENANT_ID, userId:$('#s_AgentId').val()});
            }
            return;
		}
		
		if (Result.isOk()) {
	    	if (typeof(Result.getRows()['resultCd']) != "undefined") {
	    		
	            if (Result.getRows()['resultCd'] == "LOGINOK" || ssoCheck == "Y") { //로그인이 성공일 경우
	            	var result = Result.SVCCOMMONID.rows;
	            	var objIp  = {"workIp":workIp};
	            	
	            	sessionStorage['loginInfo'] = JSON.stringify(Result);	//HTML5 sessionStorage : IE8이하 에선 수행되지않음
	            	
	            	if($("#id_check").is(":checked")) {
	            		argoSetCookie("loginId",$('#s_AgentId').val(), 365); //아이디저장에 체크 시 쿠키에 저장
	            	}
	            	else {
	            		argoRemoveCookie("loginId"); 
	            	}
	            	
                    argoRemoveCookie("loginPw");

	            	if (vlcOPT.VLC_TENANT_SHOW=="1") {
	            		argoSetCookie("loginTenant",$('#s_TenantId').val(), 365);
					}
					else {
						argoSetCookie("loginTenant",vlcOPT.VLC_SSO_TENANT_ID, 365);
					}
					    
		            if(ssoCheck == "Y") {
		            	 var workLog = '[TenantId:' + ssoTenant + ' | 사용자Id:' + ssoUserId + '] SSO로그인';
		        		argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:ssoTenant, userId:ssoUserId, actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:"SSO로그인", workLog:workLog});
		        		window.setTimeout(function(){ window.location.replace(gGlobal.ROOT_PATH + "/common/VMainF.do"); }, 500);
		            }
		            else {
		            	if (vlcOPT.VLC_TENANT_SHOW=="1") {
			                var workLog = '[TenantId:' + $('#s_TenantId').val() + ' | 사용자Id:' + $('#s_AgentId').val() + '] 로그인';
			        		argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:$('#s_TenantId').val(), userId:$('#s_AgentId').val(), actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:"로그인", workLog:workLog});
			                window.setTimeout(function(){ window.location.replace(gGlobal.ROOT_PATH + "/common/VMainF.do"); }, 500);
						}
						else {
		            		var workLog = '[TenantId:' + vlcOPT.VLC_SSO_TENANT_ID + ' | 사용자Id:' + $('#s_AgentId').val() + '] 로그인';
			        		argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:vlcOPT.VLC_SSO_TENANT_ID, userId:$('#s_AgentId').val(), actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:"로그인", workLog:workLog});
			        		window.setTimeout(function(){ window.location.replace(gGlobal.ROOT_PATH + "/common/VMainF.do"); }, 500);
		            	}
		           	}	
	            }
	            else {
	                argoAlert(Result.resultMsg);
	            }
	    	}
	    }
	    else {
	    	argoAlert('로그인을 실패하였습니다.');
	    	return;
	 	}
	}
	
	
	function selectTenantMake(){
	    var inputValue = $('#s_TenantIdList').val();
	    var inputText = $('#s_TenantNmList').val();
	    var valuesArray = inputValue.split(',');
	    var textsArray = inputText.split(',');

	    var selectElement = $('#s_TenantId');
	    for (var i = 0; i < valuesArray.length; i++) {
	      var optionValue = valuesArray[i].trim(); // 공백 제거
	      var optionValueText = textsArray[i].trim(); // 공백 제거
	      if (optionValue) {
	        var newOption = $('<option>', {
	          value: optionValue,
	          text: optionValueText
	        });
	        selectElement.append(newOption);
	      }
	    }
	}
	
	function fn_goMain() {
		window.setTimeout(function(){ window.location.replace(gGlobal.ROOT_PATH + "/common/VMainF.do"); }, 500);
	}

	
	
	
	window.sessionStorage.clear();

	
	
	
</script>
</head>
<body>
	<c:choose>
		<c:when test="${sessionMAP.sabun eq null}">
			<div class="login_wrap">
				<section class="log_section">
			    	<div class="argo_logo"><img src="../images/veloce/login_veloce.png" alt="VELOCE"></div>
			        <div class="login_box">
			        	<!-- <div class="login_title"><img src="../images/login_bs.png" alt="고객사BI"></div> -->
			        	<div class="login_title">    
			        	<font id="serverGbTitle" style="font-size:20px; color:blue; font-weight:600;"></font>&nbsp;&nbsp;&nbsp;
			        	<!-- <font style="font-size:20px; color:red; font-weight:600;">-운영계-</font>&nbsp;&nbsp;&nbsp; -->
			        	<input type="hidden" id="s_ServerGb" name="s_ServerGb" value="${serverAddrGb}" >
			        	
			        	<font style="font-size:20px; color:#777676; font-weight:600;">VELOCE 로그인</font></div>
			            <div class="log_cont">
			            	<div class="log_info">아이디와 비밀번호를 입력해 주세요.</div>
			                <div class="input_area">
			                	<!-- <input type="text" id="s_TenantId" name="s_TenantId" onkeyup="eventCheck();" placeholder="회사를 입력하세요."> --> 
                          	 	<select id="s_TenantId" name="s_TenantId" style="width: 140px; margin-bottom:7px;"></select>
			                	<input type="hidden" id="s_TenantIdList" name="s_TenantIdList" value="${tenantIdList }" >
			                	<input type="hidden" id="s_TenantNmList" name="s_TenantNmList" value="${tenantNmList }" >
			                	<input type="text" id="s_AgentId" name="s_AgentId" onkeyup="eventCheck();" placeholder="아이디를 입력하세요.">
			                    <input type="password" id="agentPwView" name="agentPwView" onkeyup="eventCheck();" placeholder="비밀번호를 입력하세요.">
			                    <input type="hidden" id="s_LoEnType" name="s_LoEnType" value="login">
			                    <input type="hidden" id="dateSetValue" name="dateSetValue" value="-400">
			                    <input type="hidden" id="RSAModulus" name="RSAModulus" value="${RSAModulus}">
			                    <input type="hidden" id="RSAExponent" name="RSAExponent" value="${RSAExponent}">
			                    <a href="javascript:formCheck();" class="btn_login">로그인</a>
			                </div>
			                <div class="check_area">
			                	<!-- <select id="s_TenantId" name="s_TenantId" class="mr15" style="width:120px;">
		                        	<option>선택</option>
		                        </select> -->
			                	<input type="checkbox" id="id_check" ><label for="id_check">아이디 저장</label>
<!-- 		                    	<input type="checkbox" id="pass_check"><label id="pass_visible" for="pass_check">비밀번호 저장</label> -->
			                </div>
			            </div>
			        </div>
			        <div class="copyright">
			        	Copyright (c) Bridgetec.corp. All right Reserved.
			        </div>
			        <br/>
			        <div  style="text-align: center; font-size:12px;">
			        	사용자 ID, 패스워드 관리 소홀 및 부정사용에 의해 발생되는 모든 결과에 대한 책임은 사용자 본인에게 있습니다.
			        
			        </div>
			        
			        <article class="bottom">
		            	<!-- <button type="button" id="btnDownload" class="btn_tab" style="display:none;">File Download</button> -->
		            	<button type="button" id="btnPlayerD" class="btn_m" style="display: none;">재생기설치</button>
		            	

		            	
		            	<!-- <button type="button" id="btnSumBankD" class="btn_tab">썸뱅크설치</button> -->
		            </article>
			    </section> 
			</div>
		</c:when>
		<c:otherwise>
		<script type="text/javascript">
			window.location.replace(gGlobal.ROOT_PATH+"/common/VMainF.do");
		</script>
		</c:otherwise>
	</c:choose>
</body>

</html>
