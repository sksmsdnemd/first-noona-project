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
	var workMenu 	= "시스템정보관리";
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
			 
		argoSetDatePicker();
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		
		argoSetValue('ip_SystemClass', '');
		argoSetValue('ip_SystemCode', '');
		argoSetValue('ip_AlarmFlag', '');
		argoSetValue('ip_InsId', userId);
		argoSetValue('ip_UptId', userId);
		
		if(cudMode == 'I') {
			$("input:radio[id='use_yes']").prop("checked", true);
	
		}else{
			
			fvCurRow = sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow);
	
		   	if(fvCurRow.useFlag == "0         "){
		   		$("input:radio[id='use_yes']").prop("checked", true);
		   	}else{
		   		$("input:radio[id='use_no']").prop("checked", true);
		   	};
	
		   	$("#ip_SysGroupId").attr("disabled", true);
		}
	}
	
	function fnSavePop(){
	
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
				          {"check":"length", "id":"ip_SysGroupId" , "minLength":1, "maxLength":50,  "msgLength":"시스템그룹을 선택하세요."}
				         ,{"check":"length", "id":"ip_SystemName" , "minLength":1, "maxLength":50,  "msgLength":"시스템명을  입력하세요."}
				         ,{"check":"length", "id":"ip_SetupDate"  , "minLength":1, "maxLength":50,  "msgLength":"설치일자를 선택하세요."}
				         ,{"check":"length", "id":"ip_UseFlag"    , "minLength":1, "maxLength":50,  "msgLength":"사용여부를 선택하세요."}
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
	
			argoJsonSearchOne("sysInfo", "getMaxSystemId", "s_", {}, fnDetailInfoCallback);
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				var info = data.getRows();
				
				if(cudMode == "I"){
					argoSetValue('ip_SystemId', info.systemId);
					Resultdata = argoJsonUpdate("sysInfo", "setSysInfoInsert", "ip_", {"cudMode":cudMode});
					workLog = '[시스템ID:' + info.systemId + '] 등록';
				}else{
					Resultdata = argoJsonUpdate("sysInfo", "setSysInfoUpdate", "ip_", {"cudMode":cudMode});
					workLog = '[시스템ID:' + argoGetValue('ip_SystemId') + '] 수정';
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
                       	<input type="hidden" id="ip_SystemId" name="ip_SystemId" >
                        <input type="hidden" id="ip_SystemClass" name="ip_SystemClass" >
                        <input type="hidden" id="ip_SystemCode" name="ip_SystemCode" >
                        <input type="hidden" id="ip_AlarmFlag" name="ip_AlarmFlag" >
                        <input type="hidden" id="ip_InsId" name="ip_InsId" >
                        <input type="hidden" id="ip_UptId" name="ip_UptId" >
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
                                	<select id="ip_SysGroupId" name="ip_SysGroupId" style="width:145px;">
                                    </select>                                   
                                </td>
                            </tr>
                        	<tr>
                            	<th>시스템명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_SystemName" name="ip_SystemName" style="width:400px;" class="mr10">
                                	<!-- <input type="hidden" id="ip_ScheId" name="ip_ScheId" > -->
                                </td>
                            </tr>
                            <tr>
                            	<th>설치일자<span class="point">*</span></th>
                                <td>
                                	<span class="select_date"><input type="text" id="ip_SetupDate" name="ip_SetupDate" class="datepicker onlyDate"></span>
                                </td>
                            </tr>
							<tr>
                            	<th>사용여부<span class="point">*</span></th>
                                <td>
                                	<span class="checks"><input type="radio" id="use_yes" name="ip_UseFlag" value='0'><label for="use_yes">예</label></span>
                                    <span class="checks ml15"><input type="radio" id="use_no" name="ip_UseFlag" value='1'><label for="use_no">아니오</label></span>
                                </td>
                            </tr>                            
                            <tr>
                            	<th>설명<span class="point"></span></th>
                                <td>
                                	<input type="text" id="ip_SystemDesc" name="ip_SystemDesc" style="width:400px;" class="mr10">
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
