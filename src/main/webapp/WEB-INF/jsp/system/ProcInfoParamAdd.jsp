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
	var workMenu 	= "프로세스 환경 정보 설정";
	var workLog 	= "";
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	fnProcIniDefCheck();
	
	});
	
	var modeChk;
	var procId;
	var procNm;
	var procCd;
	
	var sysGroupId;
	var systemId;
	
	function fnInitCtrlPop(){
		//console.log(sPopupOptions);
		procId = sPopupOptions.procId;
		procNm = sPopupOptions.procNm;
		procCd = sPopupOptions.procCd;
		
		sysGroupId = sPopupOptions.sysGroupId;
		systemId   = sPopupOptions.systemId;
		
		$("#btnSavePop").click(function(){
			setIniContent();
		});		
	}
	
	function fnProcIniDefCheck(){
	
		argoJsonSearchList('procInfo', 'getProcIniDefList', 's_', {iniProcessCode:procCd, processId:procId}, function (data, textStatus, jqXHR){
			try{
				
				if(data.isOk()){
					if(data.getRows() != ""){
						modeChk = procId;
					}else{
						modeChk = "0";
					}
	
					fnProcIniDefList(modeChk);
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function fnProcIniDefList(modeChk){
		
		argoJsonSearchList('procInfo', 'getProcIniDefList', 's_', {iniProcessCode:procCd, processId:modeChk}, function (data, textStatus, jqXHR){
			try{
				
				if(data.isOk()){
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						
						var keyProc 	 = "";
						var keyOrder 	 = "";
						var procName	 = "";
						var sectionName  = "";
						var keyName 	 = "";
						var keyTitle 	 = "";
						var keyValue 	 = "";
						var keyDesc 	 = "";
						var inputType 	 = "";
						var valueList 	 = "";
						var defaultValue = "";
						var objHtml 	 = '<tr><th align="center">항목</th><th align="center">값</th><th align="center">설명</th></tr>';
						var arrValueList = "";
						var valueListCnt = 0;
						var index 		 = "";
						var checkFlag 	 = "";
						
						$(".resultData").append(objHtml);
	
						$.each(data.getRows(), function( index, row ) {
	
							keyProc		 	= row.processCode;
					   		keyOrder 		= row.keyOrder;
							procName	 	= row.processName;
							sectionName 	= row.sectionName;
							keyName 		= row.keyName;
							keyTitle 		= row.keyTitle;
							keyValue 		= row.keyValue;
							if(row.keyValue == null || row.keyValue == "null"){
								keyValue 	= "";
							}
							keyDesc 		= row.keyDesc;
							if(row.keyDesc == null || row.keyDesc == "null"){
								keyDesc 	= "";
							}
							inputType 		= row.inputType;
							valueList 		= row.valueList;
							defaultValue 	= row.defaultValue;
							
							if(row.valueList != null && row.valueList != ""){
								arrValueList = row.valueList.split(",");
							}else{
								arrValueList = "";
							}
							
							valueListCnt = arrValueList.length;
							objHtml 	 = "";
							checkFlag 	 = "";
							
							if(inputType == "SECTION" || inputType == "TEXT"){
								if(inputType == "TEXT"){
									objHtml += '<tr>';
									objHtml += '<td style="padding-left:5px"><span id="keyTitle' + index + '">' + keyTitle + '</span></td>';
									objHtml += '<td><input type="text" style="width:99%" id="keyValue' + index + '" name="keyValue' + index + '" value="' + keyValue + '"/></td>';
									objHtml += '<td><span id="keyDesc' + index + '" title="' + keyDesc + '" style="padding-left:6px;">' + keyDesc + '</span></td>';
									objHtml += '<td style="display:none"><span id="keyName' + index + '">' + keyName + '</span></td>';
								}else{
									objHtml += '<tr style="background-color:pink">';
									objHtml += '<td colspan="3" style="padding-left:5px"><span id="keyTitle' + index + '">' + keyTitle + '</span></td>';
									objHtml += '<td style="display:none"><input type="text" style="width:99%" name="keyValue' + index + '" id="keyValue' + index + '" value="' + keyValue + '"/></td>';
									objHtml += '<td style="display:none"><span id="keyDesc' + index + '" title="' + keyDesc + '" style="padding-left:6px;">' + keyDesc + '</span></td>';
									objHtml += '<td style="display:none"><span id="keyName' + index + '">' + keyName + '</span></td>';
								}
								
								objHtml += '<td style="display:none"><span id="data' + index + '">' + inputType + '</span></td>';
								objHtml += '<td style="display:none"><span id="keyProc' + index + '">' + keyProc + '</span></td>';
								objHtml += '<td style="display:none"><span id="keyOrder' + index + '">' + keyOrder + '</span></td>';
								objHtml += '<td style="display:none"><span id="processName">' + procName + '</span></td></td>';
								objHtml += '<td style="display:none"><span id="selectionName' + index + '">' + sectionName + '</span></td>';
								objHtml += '<td style="display:none"><span id="defaultValue' + index + '">' + defaultValue + '</span></td>';
								objHtml += '<td style="display:none"><span id="valueList' + index + '">' + valueList + '</span></td>';		
								objHtml += '</tr>';
								
							}else if(inputType == "RADIO"){
								objHtml += '<tr><td style="padding-left:5px"><span id="keyTitle' + index + '">' + keyTitle + '</span></td>';
								objHtml += '<td>';
								
								if(valueListCnt > 0){
									for(var j = 0; j < valueListCnt; j++){
										if(keyValue == arrValueList[j]){
											checkFlag = "checked";
										}else{
											checkFlag = "";
										}
										objHtml += '<input type="radio" name="' + inputType + keyOrder + '" id="' + inputType + keyOrder 
												+ '" value="' + arrValueList[j] + '" ' + checkFlag + '/>' + arrValueList[j];
									}
								}
								objHtml += '</td>';
								objHtml += '<td><span id="keyDesc' + index + '" title="' + keyDesc + '" style="padding-left:6px;">' + keyDesc + '</span></td>';
								
								objHtml += '<td style="display:none"><span id="keyName' + index + '">' + keyName + '</span></td>';
								objHtml += '<td style="display:none"><span id="data' + index + '">' + inputType + '</span></td>';
								objHtml += '<td style="display:none"><span id="keyProc' + index + '">' + keyProc + '</span></td>';
								objHtml += '<td style="display:none"><span id="keyOrder' + index + '">' + keyOrder + '</span></td>';
								objHtml += '<td style="display:none"><span id="processName">' + procName + '</span></td>';
								objHtml += '<td style="display:none"><span id="selectionName' + index + '">' + sectionName + '</span></td>';
								objHtml += '<td style="display:none"><span id="defaultValue' + index + '">' + defaultValue + '</span></td>';
								objHtml += '<td style="display:none"><span id="valueList' + index + '">' + valueList + '</span></td>';
								objHtml += '</tr>';
								
							}else if(inputType == "COMBO"){
								objHtml += '<tr><td style="padding-left:5px"><span id="keyTitle' + index + '">' + keyTitle + '</span></td>';
								objHtml += '<td><select id="' + inputType + keyOrder + '" name="' + inputType + keyOrder + '" style="width: 40%" class="list_box">';
								if(valueListCnt > 0){
									for(var j = 0; j < valueListCnt; j++){
										if(keyValue == arrValueList[j]){
											checkFlag = "selected";
										}else{
											checkFlag = "";
										}
										objHtml += '<option value="' + arrValueList[j] + '" ' + checkFlag + '>' + arrValueList[j] + '</option>';
									}
								}
								objHtml += '</select></td>';
								objHtml += '<td><span id="keyDesc' + index + '" title="' + keyDesc + '" style="padding-left:6px;">' + keyDesc + '</span></td>';
								objHtml += '<td style="display:none"><span id="keyName' + index + '">' + keyName + '</span></td>';
								objHtml += '<td style="display:none"><span id="data' + index + '">' + inputType + '</span></td>';
								objHtml += '<td style="display:none"><span id="keyProc' + index + '">' + keyProc + '</span></td>';
								objHtml += '<td style="display:none"><span id="keyOrder' + index + '">' + keyOrder + '</span></td>';
								objHtml += '<td style="display:none"><span id="processName">' + procName + '</span></td>';
								objHtml += '<td style="display:none"><span id="selectionName' + index + '">' + sectionName + '</span></td>';
								objHtml += '<td style="display:none"><span id="defaultValue' + index + '">' + defaultValue + '</span></td>';
								objHtml += '<td style="display:none"><span id="valueList' + index + '">' + valueList + '</span></td>';
								objHtml += '</tr>';
							}
							
							$(".resultData").append(objHtml);
						});
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function setIniContent(){
		var rowCount = $("#tblMain tr").size();
		
		var type 			= "";
		var keyName 		= "";
		var keyValue 		= "";
		var keyDesc			= "";
		var keyTitle 		= "";
		var keyProc    		= "";
		var keyOrder  	 	= "";
		var processName   	= "";
		var selName       	= "";
		var defaultVal    	= "";
		var valueList     	= "";
		var strData 	   	= "";
		var strKeyName    	= "";
		var strKeyDesc	   	= "";
		var strKeyValue   	= "";
		var strKeyTitle   	= "";
		var strKeyProcess 	= "";
		var strKeyOrder   	= "";
		var strProcessName	= "";
		var strSelName    	= "";
		var strDefaultVal 	= "";
		var strValueList  	= "";
		var strType   		= "";
		var strToken  		= "\r\n";
		 
		if(rowCount > 0){
			argoConfirm("저장 하시겠습니까?", function(){
				for(var i=1; i < rowCount; i++){//row갯수만큼 0번째 인덱스는 타이틀이므로 제외
					type = $("#tblMain tr:eq("+i+") td:eq(4)").children().text();
				
					if(type == "RADIO"){
						var radioName 	= $("#tblMain tr:eq(" + i + ") td:eq(1)").children().attr('name');
						strKeyValue 	= $("input:radio[name=" + radioName + "]:checked").val();
						strKeyTitle 	= $("#tblMain tr:eq(" + i + ") td:eq(0)").children().text();
						strKeyDesc 		= $("#tblMain tr:eq(" + i + ") td:eq(2)").children().text();
						strKeyName  	= $("#tblMain tr:eq(" + i + ") td:eq(3)").children().text();
						strKeyProcess  	= $("#tblMain tr:eq(" + i + ") td:eq(5)").children().text();
						strKeyOrder 	= $("#tblMain tr:eq(" + i + ") td:eq(6)").children().text();
						strProcessName 	= $("#tblMain tr:eq(" + i + ") td:eq(7)").children().text();
						strSelName 		= $("#tblMain tr:eq(" + i + ") td:eq(8)").children().text();
						strDefaultVal 	= $("#tblMain tr:eq(" + i + ") td:eq(9)").children().text();
						strValueList 	= $("#tblMain tr:eq(" + i + ") td:eq(10)").children().text();
						strType 		= type;
						
						if(i != (rowCount -1)){
							strData += strKeyName + strKeyValue + strToken;
						}else{
							strData += strKeyName + strKeyValue;
						}
					}
					
					if(type == "TEXT" || type == "SECTION" || type == "COMBO"){
						strKeyValue 	= $("#tblMain tr:eq(" + i + ") td:eq(1)").children().val();
						strKeyName  	= $("#tblMain tr:eq(" + i + ") td:eq(3)").children().text();
						strKeyProcess  	= $("#tblMain tr:eq(" + i + ") td:eq(5)").children().text();
						strKeyOrder 	= $("#tblMain tr:eq(" + i + ") td:eq(6)").children().text();
						strKeyTitle 	= $("#tblMain tr:eq(" + i + ") td:eq(0)").children().text();
						strKeyDesc 		= $("#tblMain tr:eq(" + i + ") td:eq(2)").children().text();
						strProcessName 	= $("#tblMain tr:eq(" + i + ") td:eq(7)").children().text();
						strSelName 		= $("#tblMain tr:eq(" + i + ") td:eq(8)").children().text();
						strDefaultVal 	= $("#tblMain tr:eq(" + i + ") td:eq(9)").children().text();
						strValueList 	= $("#tblMain tr:eq(" + i + ") td:eq(10)").children().text();
						strType 		= type;
						
						if(i != (rowCount -1)){
							strData += strKeyName + strKeyValue + strToken;
						}else{
							strData += strKeyName + strKeyValue;
						}
					}
					 
					argoSetValue("ip_ProcessCode", strKeyProcess);
					argoSetValue("ip_KeyOrder", strKeyOrder);
					argoSetValue("ip_KeyValue", strKeyValue);
					argoSetValue("ip_Type", strType);
					argoSetValue("ip_KeyTitle", strKeyTitle);
					argoSetValue("ip_KeyDesc", strKeyDesc);
					argoSetValue("ip_KeyName", strKeyName);
					argoSetValue("ip_SelName", strSelName);
					argoSetValue("ip_DefaultVal", strDefaultVal);
					argoSetValue("ip_ValueList", strValueList);
					argoSetValue("ip_ProcessName", strProcessName);
					argoSetValue("ip_ProcessId", procId);
					
					
					//console.log(sysGroupId);
					//console.log(systemId);
					//console.log(strData);
					if(modeChk == "0"){
						Resultdata = argoJsonUpdate("procInfo", "setSysIniDefInsert", "ip_", {});
					}else{
						
						Resultdata = argoJsonUpdate("procInfo", "setSysIniDefUpdate", "ip_", {});
					}
					
					if(i + 1 == rowCount){
						
						argoJsonUpdate("procInfo", "setSysIniContUpdate", "ip_", {sysGroupId:sysGroupId, systemId:systemId, iniContent:strData}, fnCallbackSave);
					};
				}
			});
		}
	}
	
	function fnCallbackSave(data, textStatus, jqXHR){
		try{
		    if(data.isOk()) {
		    	var workFlag = "등록";
		    	
		    	if(modeChk != "0"){
		    		workFlag = "수정";
		    	}
		    	workLog = '[시스템ID:' + systemId + ' | 프로세스ID:' + procId + ' | 프로세스명:' + procNm+ '] ' + workFlag;
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
		    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
	    	} else {
	    		argoAlert("저장에 실패하였습니다.");
	    	}
		} catch(e) {
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
            		<table class="input_table" id="tblMain">
            			<colgroup>
            				<col width="25%">
                            <col width="20%">
                            <col width="55%">
                        </colgroup>
                        <tbody class="resultData">                                     
						</tbody>
					</table>
				</div>
                <div class="btn_areaB txt_r">
                    <button type="button" id="btnSavePop" name="btnSavePop" class="btn_m confirm" data-grant="W">저장</button>
                    <input type="hidden" id="ip_ProcessCode" name="ip_ProcessCode" >
					<input type="hidden" id="ip_ProcessName" name="ip_ProcessName" >
                    <input type="hidden" id="ip_SelName" name="ip_SelName" >
                    <input type="hidden" id="ip_KeyName" name="ip_KeyName" >
                    <input type="hidden" id="ip_KeyOrder" name="ip_KeyOrder" >
                    <input type="hidden" id="ip_KeyTitle" name="ip_KeyTitle" >
                    <input type="hidden" id="ip_KeyValue" name="ip_KeyValue" >
                    <input type="hidden" id="ip_Type" name="ip_Type" >
                    <input type="hidden" id="ip_DefaultVal" name="ip_DefaultVal" >
                    <input type="hidden" id="ip_ValueList" name="ip_ValueList" >
                    <input type="hidden" id="ip_KeyDesc" name="ip_KeyDesc" >
                    <input type="hidden" id="ip_ProcessId" name="ip_ProcessId" >
            	</div>
            	<div class="btn_areaB txt_r">                  
            	</div>              
            </div>            
        </section>
    </div>
</body>

</html>
