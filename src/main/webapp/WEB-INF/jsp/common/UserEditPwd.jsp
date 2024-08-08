<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/security/sha512.js"/>"></script>
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
	argoSetConfig(); // 비밀번호 정책 확인을 위해 환경설정값 조회
	
	$("#btnSave").click(function(){
		fnSave();
	});	
	
	/*
	$("#ip_BfPw").focusout(function(){
		return fnValidatePw(0, this.value) ;
	});*/

	$("#ip_AfPw1").focusout(function(){
		return fnValidatePw(1, this.value) ;
	});	
	
	$("#ip_AfPw2").focusout(function(){
		return fnValidatePw(2, this.value) ;
	});		
	
}

//-------------------------------------------------------------
//저장
//-------------------------------------------------------------
function fnSave(){
	
	argoSmallConfirm("비밀번호를 변경 하시겠습니까?", function(){
			
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
		   
		   if(fnValidatePw(1, sAfPwd1) && fnValidatePw(2, sAfPwd1)) {	

			argoJsonSearchOne("ARGOCOMMON","SP_UC_GET_AGENT_PW","__", {agentId: sPopupOptions.pUserId, agentPw: hex_sha512(sBfPwd) ,agentChgPw: hex_sha512(sAfPwd1)}					
            , function (Resultdata, textStatus, jqXHR){		
            	    if(Resultdata.isOk()) {	 
            	    	
            	    	if(typeof(Resultdata.getRows()['resultCd'])!="undefined"){
        					var sResultCd = Resultdata.getRows()['resultCd'] ;            	    	
        					if(sResultCd=='SUCCESS') {
        						argoSmallAlert('warning', '성공적으로 변경 되었습니다.','', 'argoPopupClose();');
        						
        					}else { // 비밀번호 체크 결과 오류 메시지 넘어온 경우 해당 처리
        						argoSmallAlert(Resultdata.getRows()['resultMsg']) ;
        						return;
        					}
            	        }
            	 }            	
            })
		   }
	});
}
//-------------------------------------------------------------
//비밀번호 유효성 검사
//-------------------------------------------------------------
function fnValidatePw(pOpt ,pPw) {
	var sPwd = pPw.trim() ;
	var sPwdEnc ;
	if(pOpt==0) { // 사용안함.
		if(sPwd.length==0) {
			//argoSmallAlert("기존 비밀번호를 입력하세요");
		      return false ;
		}
		
		sPwdEnc = hex_sha512(sPwd) ;
		
		if(sPopupOptions.pPw != sPwdEnc) {
			argoSmallAlert("기존 비밀번호가 맞지않습니다");
			return false;
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
		
		if(argoGetConfig('PW_COMBI_YN')=="1") { // 암호복잡도설정 (영문+특문_숫자 8자 이상)
			var regExp = /^(?=.*[a-zA-Z])((?=.*\d)|(?=.*\W)).{8,20}$/;
			if ( !regExp.test(sPwd ) ) {
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
                        	<li>쉬운 비밀번호나 자주 쓰는 사이트의 비밀번호가 같으면 도용되기 쉬우므로 주기적으로 바꿔쓰는 것이 좋습니다.</li>
                        </ol>
                    </div>                     
                </div>
                <div class="btn_areaB txt_r">
                    <button type="button" class="btn_m confirm" id="btnSave" name="btnSave">저장</button>   
                </div> 
            </div>            
        </section>
    </div>
</body>
</html>
