<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
%>
<link rel="stylesheet" 	href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.contants.css?ver=2017021601"/>"	type="text/css" />

<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript"  src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>

<!-- 순서에 유의 -->
<script type="text/javascript" src="<c:url value="/scripts/security/rsa.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/jsbn.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/prng4.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/rng.js"/>"></script>

<script>

$(function () {
	
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
	};
    
  	fnInitCtrl();
});


function fnInitCtrl() {
	
	$("#btnSave").click(function(){
		fnSave();
	});	
	
	$("#ip_BfPw").focusout(function(){
		return fnValidatePw(0, this.value) ;
	});

	$("#ip_AfPw1").focusout(function(){
		return fnValidatePw(1, this.value) ;
	});	
	
	$("#ip_AfPw2").focusout(function(){
		return fnValidatePw(2, this.value) ;
	});		
	
	$("#btnClose").click(function(){
		argoPopupClose();
	});
	
	$("#ip_BfPw").focus();
}


function fnSave(){
			
	var aValidate = {
		rows:[ 
				 {"check":"length", "id":"ip_BfPw"     , "minLength":1, "maxLength":100,  "msgLength":"기존 비밀번호를 입력하세요"}
				,{"check":"length", "id":"ip_AfPw1"    , "minLength":1, "maxLength":20,  "msgLength":"변경 비밀번호를 입력하세요"}
				,{"check":"length", "id":"ip_AfPw2"    , "minLength":1, "maxLength":20,  "msgLength":"비밀번호 확인을 입력하세요"}
			]
	};	
			
	if (argoValidator(aValidate,"small") != true) return;
		   
	var sBfPwd  = argoGetValue('ip_BfPw') ;
	var sAfPwd1 = argoGetValue('ip_AfPw1') ;
	var sAfPwd2 = argoGetValue('ip_AfPw2') ;
		   	
	if(sAfPwd1 != sAfPwd2){
		argoSmallAlert("새 비밀번호 및 비밀번호 확인 값이<br>동일하지 않습니다.");
		return false ;
	}
		   
	if(fnValidatePw(1, sAfPwd1) && fnValidatePw(2, sAfPwd1)) {	
		
		var Resultdata = argoJsonUpdate("userInfo", "pwdUpdate", "ip_"
									, {"tenantId":sPopupOptions.pTenantId, "userId":sPopupOptions.pUserId, "userPwd":sAfPwd1, "Salt":""});          	
		
		if(Resultdata.isOk()) {
			if(sPopupOptions.chkTy == "svr") {
				argoSmallAlert('warning', '성공적으로 변경 되었습니다.', '', 'argoPopupClose();');
			} else {
				argoSmallAlert('warning', '성공적으로 변경 되었습니다.<br>다시 로그인 하십시오', '', 'argoPopupClose();');
			}
		}else {
			argoSmallAlert(Resultdata.getRows()['resultMsg']) ;
			return;
		}    	        
	}            
}


function fnValidatePw(pOpt ,pPw) {
	
	var sPwd = pPw.trim();
	var sPwdEnc;
	var pwCombiYN = "Y";
	
	if(pOpt==0) { // 사용안함.
		if(sPwd.length==0) {
			//argoSmallAlert("기존 비밀번호를 입력하세요");
			return false ;
		}
	
		if(sPopupOptions.chkTy == "svr") {
			// rsa 암호화
	        var rsa = new RSAKey();
	        rsa.setPublic($('#RSAModulus').val(), $('#RSAExponent').val());
	        
	        argoJsonSearchOne('ARGOCOMMON', 'login', '', {"TenantId":sPopupOptions.pTenantId, "AgentId":sPopupOptions.pUserId, "AgentPw":rsa.encrypt($("#ip_BfPw").val())}, function (data, textStatus, jqXHR) {
	        	try {
	        		if(data.isOk()) {
	        			if(data.getRows() != "") {
	        				
	        			} else {
	        				argoSmallAlert('warning', '기존 비밀번호가 맞지않습니다.', '', 'parent.fnPwdChange();argoPopupClose();');
	        				$("#ip_BfPw").val("");
	        				return;
	        			}
	        		} else {
	        			argoSmallAlert('warning', '기존 비밀번호가 맞지않습니다.', '', 'parent.fnPwdChange();argoPopupClose();');
        				$("#ip_BfPw").val("");
        				return;
	        		}
	        	} catch(e) {
	        		argoSmallAlert('warning', '기존  비밀번호 확인 중 오류가 발생하였습니다.', '', 'parent.fnPwdChange();argoPopupClose();');
					$("#ip_BfPw").val("");
					console.log(e);
					return;
				}
	        });
		} else {
			if(sPopupOptions.pPw != sPwd) {
				argoSmallAlert("기존 비밀번호가 맞지않습니다");
				$("#ip_BfPw").val("");
				return false;
			}
		}
		
	}else if(pOpt==1) {
		if(sPwd.length==0) {
			//argoSmallAlert("변경 비밀번호를 입력하세요");
			return false ;
		}
		if(sPwd == argoGetValue('ip_BfPw')) {
			argoSmallAlert("기존 비밀번호와 변경 비밀번호가 <br>동일합니다.");
			return false ;
		}
		if(pwCombiYN == "Y") { // 암호복잡도설정 (영문+특문+숫자 8자 이상)
			var regExp = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[~`!@#$%\\^&*()-]).{8,20}$/;
			if ( !regExp.test(sPwd )) {
				argoSmallAlert("비밀번호를 확인하세요.<br>영문+숫자+특수문자 포함 8자 이상");
				return false ;
			}			
		}
		
	}else if(pOpt==2) {
		if(sPwd.length==0) {
			//argoSmallAlert("비밀번호 확인을 입력하세요");
			return false ;
		}
		if(sPwd != argoGetValue('ip_AfPw1')) {
			argoSmallAlert("새 비밀번호 및 비밀번호 확인 값이<br>동일하지 않습니다.");
			return false ;
		}
	}
	
	return true;
}


</script>
</head>
<body>
	<div class="sub_wrap pop small">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt11">
            	<div class="cont_area">
                	<ul class="cont_list">
                    	<li>
                        	<strong class="title" style="width:105px;">기존 비밀번호</strong>
			                <input type="password" id="ip_BfPw" name="ip_BfPw" style="width:200px;">
							<input type="hidden" id="RSAModulus" name="RSAModulus" value="${RSAModulus}">
							<input type="hidden" id="RSAExponent" name="RSAExponent" value="${RSAExponent}">
                        </li>
                        <li>
                        	<strong class="title" style="width:105px;">변경 비밀번호</strong>
			                <input type="password" id="ip_AfPw1" name="ip_AfPw1" style="width:200px;">
                        </li>
                        <li>
                        	<strong class="title" style="width:105px;">비밀번호 확인</strong>
			                <input type="password" id="ip_AfPw2" name="ip_AfPw2" style="width:200px;">
                        </li>
                    </ul>
                	<div class="cont_info">
                    	<ol class="info_list">
                        	<!-- <li>쉬운 비밀번호나 자주 쓰는 사이트의 비밀번호가 같으면 도용되기 쉬우므로 주기적으로 바꿔쓰는 것이 좋습니다.</li> -->
                        	<li>비밀번호는 영문자 /숫자 /특수문자를 포함하여 설정하셔야 합니다.<br>(8자리이상)</li>
                        </ol>
                    </div>                     
                </div>
                <div class="btn_areaB txt_r">
                	<button type="button" id="btnClose" class="btn_m">닫기</button> 
                    <button type="button" class="btn_m confirm" id="btnSave" name="btnSave">저장</button> 
                </div> 
            </div>            
        </section>
    </div>
</body>
</html>
