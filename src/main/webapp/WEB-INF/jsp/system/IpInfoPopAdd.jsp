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
	var workMenu 	= "IP정보관리";
	var workLog 	= "";
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	
	$(document).ready(function(e) {
		var initIpNatVal = $("#ip_IpNat").val();
				
		if(initIpNatVal == "") {
			$("#ip_nat_chk").prop( "checked", false );
			$("#ip_IpNat").prop( "disabled", true );
		} else {
			$("#ip_nat_chk").prop( "checked", true );
			$("#ip_IpNat").prop( "disabled", false );
		}
				
// 		$("#ip_IpNat").prop( "disabled", true );
		$("#ip_nat_chk").change(function() {
			if($("#ip_nat_chk").is(":checked")) {
				$("#ip_IpNat").prop( "disabled", false );
				if(initIpNatVal != "") {
					$("#ip_IpNat").val(initIpNatVal);
				}
			} else {
				$("#ip_IpNat").prop( "disabled", true );
				$("#ip_IpNat").val("");
			}
		});
	});
	
	
	
	var cudMode;
	var ipUseItem;
	var ipUse;
	
	function fnInitCtrlPop() {
		
		cudMode = sPopupOptions.cudMode;
	
		argoCbCreate("ip_SysGroupId", "sysGroup", "getSysGroupComboList", {sort_cd:'SYS_GROUP_ID'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			 
		argoSetDatePicker();
		
		$("#ip_SysGroupId").change(function(){
	 		fnSetSubCb();
	 	});
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	var ipCodeId = new Array();
	
	function ArgSetting() {
		
		var sHtml = "";
		argoJsonSearchList('baseCode', 'getBaseCodeBaseList', 's_', {classId:'ip_use'}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						$.each(data.getRows(), function(index, row) {
							ipCodeId[index] = row.codeId; 
							sHtml += "<li style='width:160px;'><input type='checkbox' id='ip_" + row.codeId + "'><label for='ip_" + row.codeId + "'>" + row.codeName +"</label></li>" ;		
						});
					}
	
					$('#useCheck').html(sHtml);
					fvCurRow = sPopupOptions.pRowIndex;
				   	argoSetValues("ip_", fvCurRow);
				   	
				   	ipUseItem = fvCurRow.ipUseItem;
			
					var itemSplit = ipUseItem.substr(0).split(',');
					
				   	$.each(itemSplit, function(index, value){	   		
				   		ipUse = value.split('-');
				   		
				   		if(ipUse[1] == "1"){
				   			$("input:checkbox[id='ip_" + ipUse[0] + "']").prop("checked", true);
				   		}
				   	});
				}
			} catch(e) {
					console.log(e);			
			}
		});
	
		argoSetValue('ip_IpUseClass', 'ip_use' );
		argoSetValue('ip_IpUseCode', '' );
		argoSetValue('ip_InsId', userId );
		argoSetValue('ip_UptId', userId );
		
		if(cudMode =='I') {
			$("input:radio[id='use_yes']").prop("checked", true);
	
		}else{
			
			fvCurRow = sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow);
		   	
		   	ipUseItem = fvCurRow.ipUseItem;
	
		   	$("#ip_SysGroupId").attr("disabled", true);
		   	$("#ip_SystemId").attr("disabled", true);
		   	$("#ip_SystemIp").attr("disabled", true);
	
		}
	}
	
	function fnSetSubCb() {
		if($('#ip_SysGroupId option:selected').val() == ''){
			$("#ip_SystemId").find("option").remove();
		}else{
			argoCbCreate("ip_SystemId", "sysGroup", "getSystemComboList", {sort_cd:'SYSTEM_ID', sysGoupId:$('#ip_SysGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		}
	}
	
	function fnSavePop(){
	
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
				          {"check":"length", "id":"ip_SysGroupId" , "minLength":1, "maxLength":50,  "msgLength":"시스템그룹을 선택하세요."}
				         ,{"check":"length", "id":"ip_SystemId"   , "minLength":1, "maxLength":50,  "msgLength":"시스템을  선택하세요."}
				         ,{"check":"length", "id":"ip_SystemIp"   , "minLength":1, "maxLength":50,  "msgLength":"시스템IP를 입력하세요."}
					 ]
			};	
				
			if (argoValidator(aValidate) != true) return;
				
			ipUseItem = "";
			if(ipCodeId.length > 0){
					
				for(var i = 0; i < ipCodeId.length; i++){
					var ipCd = ipCodeId[i];
						
					if($("input:checkbox[id='ip_" + ipCd + "']").is(":checked")){
						ipUseItem += ipCd.toLocaleString() + "-1,";
					}else{
						ipUseItem += ipCd.toLocaleString() + "-0,";
					} 
				}
				ipUseItem = ipUseItem.slice(0,-1);
			}
			argoSetValue('ip_IpUseItem', ipUseItem);
				
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("ipInfo", "setIpInfoInsert", "ip_", {"cudMode":cudMode});
				workLog = '[시스템그룹:' + argoGetValue('ip_SysGroupId') + ' | 시스템ID:' + argoGetValue('ip_SystemId') + ' | 시스템IP:' + argoGetValue('ip_SystemIp') + '] 등록';
			}else{
				Resultdata = argoJsonUpdate("ipInfo","setIpInfoUpdate","ip_", {"cudMode":cudMode});
				workLog = '[시스템그룹:' + argoGetValue('ip_SysGroupId') + ' | 시스템ID:' + argoGetValue('ip_SystemId') + ' | 시스템IP:' + argoGetValue('ip_SystemIp') + '] 수정';
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
                       <input type="hidden" id="ip_IpUseClass" name="ip_IpUseClass">
                       <input type="hidden" id="ip_IpUseCode" name="ip_IpUseCode">
                       <input type="hidden" id="ip_IpUseItem" name="ip_IpUseItem">
                       <input type="hidden" id="ip_InsId" name="ip_InsId">
                       <input type="hidden" id="ip_UptId" name="ip_UptId">
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
                            	<th>시스템<span class="point">*</span></th>
                                <td>
                                	<select id="ip_SystemId" name="ip_SystemId" style="width:145px;">
                                    </select>                                   
                                </td>
                            </tr>
                            <tr>
                                <th>시스템IP<span class="point">*</span></th>
                                <td>
                                    <input type="text" id="ip_SystemIp" name="ip_SystemIp" style="width:400px;" class="mr10">
                                </td>
                            </tr>
                            <tr>
                                <th>도메인주소</th>
                                <td>
                                    <input type="text" id="ip_DomainAddr" name="ip_DomainAddr" style="width:400px;" class="mr10">
                                </td>
                            </tr>
                            <tr>
                                <th>MFU IP</th>
                                <td>
                                    <input type="text" id="ip_MfuIp" name="ip_MfuIp" style="width:400px;" class="mr10">
                                </td>
                            </tr>
                            <tr>
                            	<th>용도<span class="point"></span></th>
                                <td >
									<ul class="check_list" id="useCheck">
									</ul>
									<ul><li>분류항목이  IP구분으로 설정된 내용을 표시.</li></ul>
                                </td>
                            </tr>                         
                            <tr>
                            	<th>설명<span class="point"></span></th>
                                <td>
                                	<input type="text" id="ip_IpDesc" name="ip_IpDesc" style="width:400px;" class="mr10">
                                </td>
                            </tr>
                            <tr>
                            	<th>NAT 사용<span class="point"></span></th>
                                <td>
                                    <input type='checkbox' id='ip_nat_chk'><label>사용</label>
                                	<input type="text" id="ip_IpNat" name="ip_IpNat" style="width:400px;" class="mr10">
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
