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
	var workMenu 	= "프로세스관리";
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
		argoCbCreate("ip_ProcessParamCd", "baseCode", "getBaseComboList", {classId:'process_param'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		$("#ip_SysGroupId").change(function(){
	 		fnSetSubCb('group');
	 	});
		
		$("#ip_SlaveSystemId").change(function(){
	 		fnSetSubCb('slave');
	 	});
		
		$("#ip_ProcessCode").change(function(){
	 		fnSetText('procCd');
	 	});
		
		$("#ip_ProcessParamCd").change(function(){
	 		fnSetText('procPr');
	 	});
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
	
		argoSetValue('ip_ProcessClass', 'process_class' );
		argoSetValue('ip_AlarmFlag', '');
		argoSetValue('ip_InsId', userId);
		
		if(cudMode == 'I') {
			$("input:radio[id='use_yes']").prop("checked", true);
		
		}else{
	
			fvCurRow = sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow);
	
		   	argoSetValue('ip_ProcessName', fvCurRow.processName);
		   	
		   	$("#ip_SysGroupId").attr("disabled", true);
		   	$("#ip_SystemId").attr("disabled", true);
		}
	}
	
	function fnSetSubCb(val) {
		if(val == 'group'){
			if($('#ip_SysGroupId option:selected').val() == ''){
				$("#ip_SystemId").find("option").remove();
				$("#ip_ProcessCode").find("option").remove();
				$("#ip_ProcessName").val('');
			}else{
				argoCbCreate("ip_SystemId", "sysGroup", "getSystemComboList", {sort_cd:'SYSTEM_ID', sysGoupId:$('#ip_SysGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				argoCbCreate("ip_ProcessCode", "baseCode", "getBaseComboList", {classId:'process_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				argoCbCreate("ip_SlaveSystemId", "sysGroup", "getSystemComboList", {}, {"selectIndex":0, "text":'선택하세요!', "value":'0'});
			}
		}
		if(val == 'slave'){
	
			if($('#ip_SlaveSystemId option:selected').val() == ''){
				$("#ip_SlaveProcessId").find("option").remove();
			}else{
				var systemId  = ""
				var processCd = "";
	
				if($('#ip_SlaveSystemId option:selected').val() != undefined){
					systemId = $('#ip_SlaveSystemId option:selected').val();
				}
				if($('#ip_ProcessCode option:selected').val() != undefined){
					processCd = $('#ip_ProcessCode option:selected').val();
				}
	
				argoCbCreate("ip_SlaveProcessId", "procInfo", "getProcSlaveComboList", {systemId:systemId, findProcessCode:processCd}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
		}
	}
	
	function fnSetText(val) {
		
		var setText = "";
		if(val == 'procCd'){
			setText = $('#ip_ProcessCode option:selected').text();
			if($('#ip_ProcessCode option:selected').val() == ''){
				argoSetValue('ip_ProcessName', '');
			}else{
				argoSetValue('ip_ProcessName', setText);
			}
		}else{
			setText = $('#ip_ProcessParamCd option:selected').text();
			argoSetValue('ip_ProcessParam', setText);
		}
	}
	
	function fnSavePop(){
	
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
				       	  {"check":"length", "id":"ip_SysGroupId", "minLength":1, "maxLength":50, "msgLength":"시스템그룹을 선택하세요."}
				         ,{"check":"length", "id":"ip_SystemId", "minLength":1, "maxLength":50, "msgLength":"시스템을 선택하세요."}
				         ,{"check":"length", "id":"ip_ProcessCode", "minLength":1, "maxLength":50, "msgLength":"프로세스구분 선택하세요."}
				         ,{"check":"length", "id":"ip_ProcessName", "minLength":1, "maxLength":50, "msgLength":"프로세스명을 입력하세요."}
				         ,{"check":"length", "id":"ip_ProcessParam", "minLength":1, "maxLength":128, "msgLength":"프로세스 파라미터를 입력하세요."}
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
	
			argoJsonSearchOne("procInfo", "getMaxProcessId", "s_", {}, fnDetailInfoCallback);
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				var info = data.getRows();
				var resultData;
				
				if(cudMode == "I"){
					argoSetValue('ip_ProcessId', info.systemId);
					
					var systemId    = $('#ip_SystemId').val();
					var processCode = $('#ip_ProcessCode').val();
					
					argoJsonSearchOne("procInfo", "getMaxPortIdx", "s_", {systemId:systemId, processCode:processCode}, function (data, textStatus, jqXHR){		
						if(data.isOk()) {
	            	    	var portIdx = data.getRows()['portIdx'];
	            	    			
	            	    	if(portIdx > 100){
	            	    		argoAlert("같은 시스템에 같은 프로세스를 100개 이상 등록할수 없습니다.");
	            	    		return;
	            	    	}else{
	            	    		argoSetValue('ip_PortIdx', portIdx);
	            	    		Resultdata = argoJsonUpdate("procInfo", "setProcInfoInsert", "ip_", {"cudMode":cudMode});
	            	    		workLog = '[시스템그룹:' + argoGetValue('ip_SysGroupId') + ' | 시스템ID:' + argoGetValue('ip_SystemId') + ' | 프로세스ID:' + argoGetValue('ip_ProcessId') + '] 등록';
	            	    				
	            	    		if(Resultdata.isOk()) {	
	            	    			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
	            									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
	            	    		   	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
	            	    		}else {
	            	    		   	argoAlert("저장에 실패하였습니다");	 
	            	    		} 	    				
	            	    	}
	            	   	}
					});
				}else{
					argoSetValue("ip_UptId", "btadmin");
	
					Resultdata = argoJsonUpdate("procInfo", "setProcInfoUpdate", "ip_", {"cudMode":cudMode});
					workLog = '[시스템그룹:' + argoGetValue('ip_SysGroupId') + ' | 시스템ID:' + argoGetValue('ip_SystemId') + ' | 프로세스ID:' + argoGetValue('ip_ProcessId') + '] 수정';
					
					if(Resultdata.isOk()) {	
						argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
										,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
				    }else {
				    	argoAlert("저장에 실패하였습니다");	 
				    } 
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
            <div class="pop_cont h0 pt20">
            	<div class="input_area">
            		<table class="input_table">
            			<colgroup>
            				<col width="14%">
                            <col width="26%">
                            <col width="18%">
                            <col width="42%">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>시스템그룹<span class="point">*</span></th>
                                <td><select id="ip_SysGroupId" name="ip_SysGroupId" style="width:200px;"></select></td>
                                <th>시스템<span class="point">*</span></th>
                                <td><select id="ip_SystemId" name="ip_SystemId" style="width:200px;"></select></td>   
							</tr>
							<tr>
								<th>프로세스구분<span class="point">*</span></th>
								<td><select id="ip_ProcessCode" name="ip_ProcessCode" style="width:200px;"></select></td>
								<th>프로세스명<span class="point">*</span></th>
								<td><input type="text" id="ip_ProcessName" name="ip_ProcessName" style="width:200px;"></td>       
							</tr>
							<tr>
								<th>사용여부<span class="point">*</span></th>
								<td><span class="checks"><input type="radio" id="use_yes" name="ip_UseFlag" value='0'><label for="use_yes">예</label></span>
                                    <span class="checks ml15"><input type="radio" id="use_no" name="ip_UseFlag" value='1'><label for="use_no">아니오</label></span></td>
								<th>프로세스파라미터<span class="point">*</span></th>
								<td>
									<select id="ip_ProcessParamCd" name="ip_ProcessParamCd" style="width:165px;"></select>
									<input type="text" id="ip_ProcessParam" name="ip_ProcessParam" style="width:165px;">
								</td>     
							</tr>
							<tr> 
								<th>Slave시스템<span class="point"></span></th>
								<td><select id="ip_SlaveSystemId" name="ip_SlaveSystemId" style="width:200px;"></select></td>
								<th>Slave프로세스<span class="point"></span></th>
								<td><select id="ip_SlaveProcessId" name="ip_SlaveProcessId" style="width:200px;"></select></td>        
							</tr>
							<tr>
								<th>PortIndex<span class="point"></span></th>
								<td colspan="3">
									<input type="text" id="ip_PortIdx" name="ip_PortIdx" onKeyPress="return argoNumkeyCheck(event)" style="width:200px;">
									<!-- <input type="text" id="ip_PortIdxText" name="ip_PortIdxText" style="width:200px;"> -->
								</td>
							</tr>
							<tr>
                            	<th>프로세스환경</th>
                                <td class="lh0" colspan="3"><textarea id="ip_IniContent" name="ip_IniContent" class="w100" style="height:240px;" readonly></textarea></td>
                            </tr>
							<tr>
								<th>설명<span class="point"></span></th>
								<td colspan="3">
									<input type="text" id="ip_ProcessDesc" name="ip_ProcessDesc" class="w100">
								</td>          
							</tr>                              
						</tbody>
					</table>
				</div>
                <div class="btn_areaB txt_r">
                    <button type="button" id="btnSavePop" name="btnSavePop" class="btn_m confirm" data-grant="W">저장</button>   
                    <input type="hidden" id="ip_ProcessId" name="ip_ProcessId" >
                    <input type="hidden" id="ip_ProcessClass" name="ip_ProcessClass" >
                    <input type="hidden" id="ip_AlarmFlag" name="ip_AlarmFlag" >
                    <input type="hidden" id="ip_InsId" name="ip_InsId" >
                    <input type="hidden" id="ip_UptId" name="ip_UptId" >                 
            	</div>              
            </div>            
        </section>
    </div>
</body>

</html>
