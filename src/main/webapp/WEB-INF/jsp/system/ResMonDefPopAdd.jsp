<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "리소스기본설정";
	var workLog 	= "";
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	var cudMode;
	
	function fnInitCtrlPop() {
		
		cudMode = sPopupOptions.cudMode;
	
		argoCbCreate("ip_ResCode", "baseCode", "getBaseComboList", {classId:'res_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
	
		argoSetValue('ip_ResClass', 'res_class');
		
		if(cudMode =='I') {
	
		}else{
			fvCurRow = sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow);
	
		   	$("#ip_ResCode").attr("disabled", true);
		   	$("#ip_ResName").attr("disabled", true);
		}
	}
	
	function fnSavePop(){
	
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
				          {"check":"length", "id":"ip_ResCode", "minLength":1, "maxLength":50, "msgLength":"리소스구분을 선택하세요."}
				         ,{"check":"length", "id":"ip_ResName", "minLength":1, "maxLength":50, "msgLength":"리소스코드를 입력하세요."}
				         ,{"check":"length", "id":"ip_ResDesc", "minLength":1, "maxLength":50, "msgLength":"리소스명을 입력하세요."}
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
				
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("resMonDef", "setResMonDefInsert", "ip_", {"cudMode":cudMode});
				workLog = '[리소스코드:' + argoGetValue('ip_ResCode') + ' | 리소스명:' + argoGetValue('ip_ResName') + '] 등록';
			}else{
				Resultdata = argoJsonUpdate("resMonDef", "setResMonDefUpdate", "ip_", {"cudMode":cudMode});
				workLog = '[리소스코드:' + argoGetValue('ip_ResCode') + ' | 리소스명:' + argoGetValue('ip_ResName') + '] 수정';
			}
	
		    if(Resultdata.isOk()) {	
			   	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			   	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
			}else {
			   	argoAlert("저장에 실패하였습니다");	 
			}
		});
	}

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
                	<span class="btn_r">
                       <button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>  
                       
                       <input type="hidden" id="ip_ResClass" name="ip_ResClass">
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
                            	<th>리소스구분<span class="point">*</span></th>
                                <td>
                                	<select id="ip_ResCode" name="ip_ResCode" style="width:145px;">
                                    </select>                                   
                                </td>
                            </tr>
                        	<tr>
                            	<th>리소스코드<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_ResName" name="ip_ResName" style="width:400px;" class="mr10">
                                </td>
                            </tr>                      
                            <tr>
                            	<th>리소스명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_ResDesc" name="ip_ResDesc" style="width:400px;" class="mr10">
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
