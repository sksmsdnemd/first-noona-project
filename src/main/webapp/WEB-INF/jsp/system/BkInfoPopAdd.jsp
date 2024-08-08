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
	var workMenu 	= "백업장치관리";
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
		
		argoSetDatePicker();
	
		for(var i = 0; i < 24; i++){
	        $("#ip_BkTimeStart").append("<option value='" + i + "'>" + i + "</option>");
	        $("#ip_BkTimeEnd").append("<option value='" + i + "'>" + i + "</option>");
		}
		
		for(var i=0; i <= 10; i++){
			if(i == 0){
				$("#ip_StorageDayText").append("<option value='" + i + "'>반년</option>");
			}else{
				$("#ip_StorageDayText").append("<option value='" + i + "'>" + i + "년</option>");
			}
		}
		
		argoCbCreate("ip_SystemId", "sysInfo", "getSysInfoByProcCbList", {findProcessCode:'61', useFlag:'0'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_ProcessId", "procInfo", "getProcSlaveComboList", {findProcessCode:'61'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_BkDevice", "baseCode", "getBaseComboList", {classId:'bk_device'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_MediaKind", "baseCode", "getBaseComboList", {classId:'media_kind'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_BkKind", "baseCode", "getBaseComboList", {classId:'bk_kind'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
	
		$("#ip_StorageDayText").change(function(){
			
				var storageDayTxt = $("#ip_StorageDayText").val();
				
				if(storageDayTxt != ""){
					var storageDay = 180;
					if(storageDayTxt != "0"){
						storageDay = storageDayTxt * 365;
					}	
					$("#ip_StorageDay").val(storageDay);
				} 
	 	});
		
		$("#ip_MediaFreeSpaceText").change(function(){
			
			var mediaFreeTxt = $("#ip_MediaFreeSpaceText").val();
			$("#ip_MediaFreeSpace").val(mediaFreeTxt);
		});
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		
		$("#ip_BkQuery").attr("disabled", true);
	
		if(cudMode =='I') {
			
			$('#ip_MediaFreeSpaceText option[value="500"]').prop('selected', true);
			$('#ip_BkTimeStart option[value="19"]').prop('selected', true);
			$('#ip_BkTimeEnd option[value="8"]').prop('selected', true);
			$('#ip_MediaFreeSpace').val("500");
			$('#ip_StorageDay').val("365");
			$('#ip_BkPreventDate').val("1");
			$('#ip_BkFilesMax').val("50");
			$('#ip_BkDirectory').val("X:\\VelStor-BK");
			$("#ip_GubunRadioY").prop("checked",true);
			argoSetValue("ip_BkDate", argoSetFormat(argoCurrentDateToStr(), "-", "4-2-2"));
			argoSetValue("ip_DelDate", argoSetFormat(argoCurrentDateToStr(), "-", "4-2-2"));
	
		}else{
	
			fvCurRow = sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow);
		   	
		   	var selVal = fvCurRow.mediaFreeSpace;
		   	$('#ip_MediaFreeSpaceText option[value="' + selVal + '"]').prop('selected', true);
		   	
		   	$("#ip_GubunRadio"+fvCurRow.gubunState).prop("checked",true);
		   	$("#ip_SystemId").attr("disabled", true);
		   	$("#ip_ProcessId").attr("disabled", true);
		   	$("#ip_MediaKind").attr("disabled", true);
		}
	}
	
	function fnSavePop(){
	
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
						 {"check":"length", "id":"ip_SystemId", "minLength":1, "maxLength":50, "msgLength":"시스템을 선택하세요."}
						,{"check":"length", "id":"ip_ProcessId", "minLength":1, "maxLength":50, "msgLength":"프로세스를 선택하세요."}
						,{"check":"length", "id":"ip_MediaKind", "minLength":1, "maxLength":50, "msgLength":"백업미디어를 선택하세요."}
						,{"check":"length", "id":"ip_BkDevice", "minLength":1, "maxLength":50, "msgLength":"백업장치를 선택하세요."}
						,{"check":"length", "id":"ip_BkKind", "minLength":1, "maxLength":50, "msgLength":"백업종류를 선택하세요."}
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
				
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("bkInfo", "setBkInfoInsert", "ip_", {"cudMode":cudMode});
				workLog = '[시스템ID:' + argoGetValue('ip_SystemId') + ' | 프로세스ID:' + argoGetValue('ip_ProcessId') + ' | 백업미디어:' + argoGetValue('ip_MediaKind') + '] 등록';
			}else{
				Resultdata = argoJsonUpdate("bkInfo", "setBkInfoUpdate", "ip_", {"cudMode":cudMode});
				workLog = '[시스템ID:' + argoGetValue('ip_SystemId') + ' | 프로세스ID:' + argoGetValue('ip_ProcessId') + ' | 백업미디어:' + argoGetValue('ip_MediaKind') + '] 수정';
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
            <div class="pop_cont h0 pt20">
            	<div class="input_area">
            		<table class="input_table">
            			<colgroup>
            				<col width="20%">
                            <col width="35%">
                            <col width="16%">
                            <col width="29%">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>시스템ID<span class="point">*</span></th>
                                <td><select id="ip_SystemId" name="ip_SystemId" style="width:190px;"></select></td>
                                <th>프로세스<span class="point">*</span></th>
                                <td><select id="ip_ProcessId" name="ip_ProcessId" style="width:190px;"></select></td>   
							</tr>
							<tr>
								<th>백업미디어<span class="point">*</span></th>
								<td><select id="ip_MediaKind" name="ip_MediaKind" style="width:190px;"></select></td>
								<th>백업장치<span class="point">*</span></th>
								<td><select id="ip_BkDevice" name="ip_BkDevice" style="width:190px;"></select></td>       
							</tr>
							<tr>
								<th>백업종류<span class="point">*</span></th>
								<td><select id="ip_BkKind" name="ip_BkKind" style="width:190px;"></select></td>
								<th>보존일<span class="point"></span></th>
								<td>
									<select id="ip_StorageDayText" name="ip_StorageDayText" style="width:100px;">
										<option value="">선택하세요!</option>
									</select>
									<input type="text"	id="ip_StorageDay" name="ip_StorageDay" class="InputReadL onlyNum" style="width:85px"/>(단위:일)
								</td>    
							</tr>
							<tr> 
								<th>백업일<span class="point"></span></th>
								<td><span class="select_date"><input type="text" class="datepicker" id="ip_BkDate" name="ip_BkDate" readonly></span></td>
								<th>삭제일<span class="point"></span></th>
								<td><span class="select_date"><input type="text" class="datepicker" id="ip_DelDate" name="ip_DelDate" readonly></span></td>        
							</tr>
							<tr>
								<th>백업여유공간<span class="point"></span></th>
								<td>
									<select id="ip_MediaFreeSpaceText" name="ip_MediaFreeSpaceText" style="width:100px;">
										<option value="">선택하세요!</option>
										<option value="500">DVD</option>
										<option value="1000">100G 이하</option>
										<option value="5000">100~500G</option>
										<option value="10000">500G이상</option></select>
									<input type="text"	id="ip_MediaFreeSpace" name="ip_MediaFreeSpace" class="InputReadL onlyNum" style="width:85px"/>(단위:MB)
								</td>
								<th>백업방지기간<span class="point"></span></th>
								<td><input type="text" id="ip_BkPreventDate" name="ip_BkPreventDate" class="onlyNum" style="width:190px;">(단위:일)</td>  
							</tr>
							<tr>
                            	<th>백업시작시각<span class="point"></span></th>
								<td><select id="ip_BkTimeStart" name="ip_BkTimeStart" class="onlyNum" style="width:190px;"></select>(단위:시)</td>
								<th>백업종료시각<span class="point"></span></th>
								<td><select id="ip_BkTimeEnd" name="ip_BkTimeEnd" class="onlyNum" style="width:190px;"></select>(단위:시)</td>
                            </tr>
                            <tr>
                            	<th>처리파일수<span class="point"></span></th>
								<td><input type="text" id="ip_BkFilesMax" name="ip_BkFilesMax" class="onlyNum" style="width:190px;"></td>
								<th>백업레이블헤더<span class="point"></span></th>
								<td><input type="text" id="ip_BkLabelHeader" name="ip_BkLabelHeader" style="width:190px;"></td>
                            </tr>
                            <tr>
                            	<th>파일분류<span class="point"></span></th>
								<td><input type="radio" id="ip_GubunRadioY" name="ip_GubunRadio" value="Y"/>사용 <input type="radio" id="ip_GubunRadioN" name="ip_GubunRadio" value="N"/>미사용</td>
								<th><span class=""></span></th>
								<td></td>
                            </tr>
                            <tr>
                            	<th>선택백업SQL문<span class="point"></span></th>
								<td colspan="3"><input type="text" id="ip_BkQuery" name="ip_BkQuery" style="width:620px;"></td>
                            </tr>
                            <tr>
                            	<th rowspan="3">백업디렉토리경로설정<span class="point"></span></th>
								<td colspan="3"><span class="fontRed">※ 해당 경로에 사용자(리눅스 계정)의 쓰기 권한을 꼭 주세요</span></td>
                            </tr>
                            <tr>
								<td>백업디렉토리</td>
								<td colspan="2"><input type="text" id="ip_BkDirectory" name="ip_BkDirectory" style="width:400px;"></td>
                            </tr>
                            <tr>
								<td>이중백업디렉토리</td>
								<td colspan="2"><input type="text" id="ip_BkDirectory2" name="ip_BkDirectory2" style="width:400px;"></td>
                            </tr>                     	              
						</tbody>
					</table>
				</div>
                <div class="btn_areaB txt_r">
                    <button type="button" id="btnSavePop" name="btnSavePop" class="btn_m confirm" data-grant="W">저장</button>                   
            	</div>              
            </div>            
        </section>
    </div>
</body>

</html>
