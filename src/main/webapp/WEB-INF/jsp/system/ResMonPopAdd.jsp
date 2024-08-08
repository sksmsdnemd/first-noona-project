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
	var workMenu 	= "리소스관리";
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
		
		argoCbCreate("ip_SysGroupId", "sysGroup", "getSysGroupComboList", {sort_cd:'SYS_GROUP_ID'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_ResCode", "baseCode", "getBaseComboList", {classId:'res_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		$("#ip_SysGroupId").change(function(){
	 		fnSetSubCb('group');
	 	});
		
		$("#ip_ResCode").change(function(){
	 		fnSetSubCb('res');
	 	});
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
	
		argoSetValue('ip_ResClass', 'res_class');
		
		if(cudMode == 'I') {
			argoSetValue("ip_ResUsed","0");
			argoSetValue("ip_ResMax","0");
			argoSetValue("ip_AlarmMinor","70");
			argoSetValue("ip_AlarmMajor","80");
			argoSetValue("ip_AlarmCritical","90");
			
		}else{
			fvCurRow = sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow);
	
		   	$("#ip_SysGroupId").attr("disabled", true);
		   	$("#ip_SystemId").attr("disabled", true);
		   	$("#ip_ResCode").attr("disabled", true);
		   	$("#ip_ResName").attr("disabled", true);
		}
	}
	
	function fnSetSubCb(val) {
		
		if(val == 'group'){
			if($('#ip_SysGroupId option:selected').val() == ''){
				$("#ip_SystemId").find("option").remove();
			}else{
				argoCbCreate("ip_SystemId", "sysGroup", "getSystemComboList", {sort_cd:'SYSTEM_ID', sysGoupId:$('#ip_SysGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
		}
		if(val == 'res'){
			if($('#ip_ResCode option:selected').val() == ''){
				$("#ip_ResName").find("option").remove();
			}else{
				argoCbCreate("ip_ResName", "resMon", "getResComboList", {sort_cd:'RES_NAME', resCode:$('#ip_ResCode option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
		}
	}
	
	function fnSavePop(){
	
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
				          {"check":"length", "id":"ip_SysGroupId", "minLength":1, "maxLength":50, "msgLength":"시스템그룹을 선택하세요."}
				         ,{"check":"length", "id":"ip_SystemId", "minLength":1, "maxLength":50, "msgLength":"시스템을 선택하세요."}
				         ,{"check":"length", "id":"ip_ResCode", "minLength":1, "maxLength":50, "msgLength":"리소스구분을 선택하세요."}
				         ,{"check":"length", "id":"ip_ResName", "minLength":1, "maxLength":50, "msgLength":"리소스명을 선택하세요."}
				         ,{"check":"length", "id":"ip_AlarmMinor", "minLength":1, "maxLength":3, "msgLength":"Minor경고값을 입력하세요."}
				         ,{"check":"length", "id":"ip_AlarmMajor", "minLength":1, "maxLength":3, "msgLength":"Major경고값을 입력하세요."}
				         ,{"check":"length", "id":"ip_AlarmCritical", "minLength":1, "maxLength":3, "msgLength":"Critical경고값을 입력하세요."}
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
				
			var minVal = $("#ip_AlarmMinor").val();
			var maxVal = $("#ip_AlarmMajor").val();
			var crtVal = $("#ip_AlarmCritical").val();
				
			if(parseInt(minVal) >= parseInt(maxVal)) {
				argoAlert("Minor 경고값은 Major 경고값 보다 크거나 같을 수 없습니다.");
				return;
			} else if(parseInt(minVal) >= parseInt(crtVal)) {
				argoAlert("Minor 경고값은 Critical 경고값 보다 크거나 같을 수 없습니다.");
				return;
			} else if(parseInt(maxVal) >= parseInt(crtVal)) {
				argoAlert("Major 경고값은 Critical 경고값 보다 크거나 같을 수 없습니다."); 
				return; 
			} else if(parseInt(crtVal) > 100) {
				argoAlert("Critical 경고값은  100 보다 클 수 없습니다."); 
				return; 
			}
	
			argoJsonSearchOne("resMon", "getMaxResId", "s_", {systemId:$('#ip_SystemId').val()}, fnDetailInfoCallback);
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				var info = data.getRows();
				
				if(cudMode == "I"){
					argoSetValue('ip_ResId', info.resId);
					Resultdata = argoJsonUpdate("resMon", "setResMonInsert", "ip_", {"cudMode":cudMode});
					workLog = '[시스템그룹:' + argoGetValue('ip_SysGroupId') + ' | 시스템ID:' + argoGetValue('ip_SystemId') + ' | 리소스코드:' + argoGetValue('ip_ResCode') + ' | 리소스명:' +  argoGetValue('ip_ResName') + '] 등록';
				}else{
					Resultdata = argoJsonUpdate("resMon","setResMonUpdate","ip_", {"cudMode":cudMode});
					workLog = '[시스템그룹:' + argoGetValue('ip_SysGroupId') + ' | 시스템ID:' + argoGetValue('ip_SystemId') + ' | 리소스코드:' + argoGetValue('ip_ResCode') + ' | 리소스명:' +  argoGetValue('ip_ResName') + '] 수정';
				}
	
			    if(Resultdata.isOk()) {	
			    	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
			    }else {
			    	argoAlert("저장에 실패하였습니다");	 
			    }
			}
		} catch (e) {
			console.log(e);
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
						<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>   
                       	<input type="hidden" id="ip_ResClass" name="ip_ResClass" >
                       	<input type="hidden" id="ip_ResId" name="ip_ResId" >
                       	<input type="hidden" id="ip_ResMax" name="ip_ResMax" >
                       	<input type="hidden" id="ip_ResUsed" name="ip_ResUsed" >
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
                            	<th>시스템그룹<span class="point">*</span></th>
                                <td>
                                	<select id="ip_SysGroupId" name="ip_SysGroupId" style="width:200px;">
                                    </select>                                   
                                </td>
                            </tr>
                            <tr>
                            	<th>시스템<span class="point">*</span></th>
                                <td>
                                	<select id="ip_SystemId" name="ip_SystemId" style="width:200px;">
                                    </select>
                                </td>
                            </tr>
                        	<tr>
                            	<th>리소스구분<span class="point">*</span></th>
                                <td>
                                	<select id="ip_ResCode" name="ip_ResCode" style="width:200px;">
                                    </select>
                                </td>
                            </tr>
                        	<tr>
                            	<th>리소스명<span class="point">*</span></th>
                                <td>
                                	<select id="ip_ResName" name="ip_ResName" style="width:200px;">
                                    </select>
                                </td>
                            </tr>                      
                            <tr>
                            	<th>Minor경고값<span class="point">*</span></th>
                                <td>
                                	<input type="text" onKeyPress="return argoNumkeyCheck(event)" id="ip_AlarmMinor" name="ip_AlarmMinor" style="width:200px;" class="mr10"  maxlength="3">
                                </td>
                            </tr>
                            <tr>
                            	<th>Major경고값<span class="point">*</span></th>
                                <td>
                                	<input type="text" onKeyPress="return argoNumkeyCheck(event)" id="ip_AlarmMajor" name="ip_AlarmMajor" style="width:200px;" class="mr10"  maxlength="3">
                                </td>
                            </tr>
                            <tr>
                            	<th>Critical경고값<span class="point">*</span></th>
                                <td>
                                	<input type="text" onKeyPress="return argoNumkeyCheck(event)" id="ip_AlarmCritical" name="ip_AlarmCritical" style="width:200px;" class="mr10"  maxlength="3">
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
