<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<style>
		.select2-container--default .select2-results>.select2-results__options{ max-height:80px; }
</style>
<script>
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var userName    = loginInfo.SVCCOMMONID.rows.userName;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;
var workMenu 	= "점수환산";
var workLog 	= "";
var dataArray 	= new Array();

var fvTenantId	= "";
var fvSheetKey	= "";

$(function () {
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
	};
	
	fvTenantId = sPopupOptions.pTenantIdArr;
	fvSheetKey = sPopupOptions.pSheetKeyArr;
	
	console.log("fvTenantId : " + fvTenantId);
	console.log("fvSheetKey : " + fvSheetKey);
	
	
	$("#btnSave").click(function(){
		fnSave();
	});
	
});


function fnSave(){
	try{
		var inputValue = argoGetValue("ip_ConvertRate");
		if(inputValue > 10){
			argoAlert("환산배율을 10이하로 입력해 주세요.");
			return;
		}

        // 정규식을 사용하여 숫자 판별
        var isValid = /^\d+(\.\d{0,1})?$/.test(inputValue);

        // 판별 결과에 따라 처리
        if (!isValid) {
        	argoAlert('숫자만 입력해 주세요.<br>소수점 첫째 자리까지<br>입력 가능합니다.');
        	return;
        }
		
		
		var multiService = new argoMultiService(fnCallbackUpdate);
		
		$.each(fvSheetKey, function(idx, value){
			
			var param = {"tenantId":fvTenantId[idx], "sheetkey":fvSheetKey[idx], "convertRate":argoGetValue("ip_ConvertRate")}	
			multiService.argoUpdate("QA","SP_QA3020S02_01","ip_", param);
			
			//fvSheetKey
			
		})
		/* $.each(gSheetkey, function( index, value) {						 
			var param = {"sheetkey":value, "gbn":"D"}	
			multiService.argoUpdate("QA","SP_QA3020M01_02","ip_", param);
		}); */
		multiService.action();
	}catch(e){
		console.log(e);
	}
}



function fnCallbackUpdate(data, textStatus, jqXHR) {
	if(data.isOk()) {
		
		//argoSmallAlert("새 비밀번호 및 비밀번호 확인 값이<br>동일하지 않습니다.");
		//argoSmallAlert('성공적으로 저장 되었습니다.');
		//argoPopupClose();
		//parent.fnSearchList();
		
		
		argoSmallAlert('warning', '성공적으로 변경 되었습니다.', '', 'parent.fnSearchList(); argoPopupClose();');
		//argoAlert("성공적으로 저장 되었습니다" );
		//parent.fnSearchList();
	}
}



</script>

</head>
<body>
	<div class="sub_wrap pop small">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt11">
            	<div class="cont_area">
                    <div class="txt_r">
                    <input type="text" id="ip_ConvertRate" name="ip_ConvertRate" style="width:100%" placeholder="환산배율을 입력하세요. ex) 0.7">
                    <!-- <textarea id="ip_Comment" name="ip_Comment" placeholder="환산배율을 입력하세요." style="width:330px;height:80px;"></textarea> -->
                    </div>
                </div>
                <div class="btn_areaB txt_r">
                    <button type="button" class="btn_m confirm" id="btnSave">저장</button>   
                </div> 
            </div>            
        </section>
    </div>
</body>
</html>
