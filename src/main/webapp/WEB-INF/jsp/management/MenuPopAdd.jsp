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

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 	  = loginInfo.SVCCOMMONID.rows.userId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "메뉴관리";
	var workLog   = "";
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	var cudMode;
	var fvCurRow;
	
	function fnInitCtrlPop() {
		
		cudMode = sPopupOptions.cudMode;
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		
		fvCurRow = sPopupOptions.pRowIndex;
		argoSetValue('ip_InsId', userId);
		argoSetValue('ip_UptId', userId);
		
		if(cudMode == "A") {
			$("input:radio[id='use_yes']").prop("checked", true);
			argoSetValues("ip_", fvCurRow);
		}else if(cudMode == "I"){
			$("input:radio[id='use_yes']").prop("checked", true);
		}else if(cudMode == "U"){
			argoSetValues("ip_", fvCurRow);
		}
	}
	
	function fnSavePop(){
	
		var Resultdata;
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
						 {"check":"length", "id":"ip_MenuName", "minLength":1, "maxLength":50, "msgLength":"메뉴명을 입력하세요."}
						,{"check":"length", "id":"ip_MenuAuthDef", "minLength":1, "maxLength":50, "msgLength":"메뉴기본권한을 선택하세요."}
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
				
			if(cudMode == "A") {
				var depth1 = $("#ip_Depth1Id").val();
				var depth2 = $("#ip_Depth2Id").val();
				var depth3 = $("#ip_Depth3Id").val();
					
				if(depth1 != 0 && depth2 == 0 && depth3 == 0){
					argoJsonSearchOne("menu", "getDeptMenuMaxId2", "ip_", {}, function (data, textStatus, jqXHR){
						if(data.isOk()){
							$("#ip_Depth2Id").val(data.getRows().depth2Id);
							fnInsertMenu();
						}
					});
				}else if(depth1 != 0 && depth2 != 0 && depth3 == 0){
					argoJsonSearchOne("menu", "getDeptMenuMaxId3", "ip_", {}, function (data, textStatus, jqXHR){
						if(data.isOk()){
							$("#ip_Depth3Id").val(data.getRows().depth3Id);
							fnInsertMenu();
						}
					});
				}
			}else if(cudMode == "I"){
				var depth1 = "";
				argoJsonSearchOne("menu", "getDeptMenuMaxId1", "__", {}, function (data, textStatus, jqXHR){
					depth1 = data.getRows().depth1Id;
	
					$("#ip_Depth1Id").val(depth1);
				 	$("#ip_Depth2Id").val("0");
				 	$("#ip_Depth3Id").val("0");
	
				 		fnInsertMenu();
				});
			}else if(cudMode == "U"){
			 	Resultdata = argoJsonUpdate("menu", "setMenuUpdate", "ip_", {"cudMode":cudMode});
				if(Resultdata.isOk()) {	
			 		argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
				}else{
					argoAlert("저장에 실패하였습니다");	
				}
			}	
		});
	}
	
	function fnInsertMenu(){
		try{
			Resultdata = argoJsonUpdate("menu", "setMenuInsert", "ip_", {"cudMode":"I"});
		
			if(Resultdata.isOk()) {	
				argoJsonUpdate("menu", "setAuthByMenuInsert", "ip_", {"cudMode":"I"});
				workLog = ("[사용자ID:" + userId + " | 메뉴 명:"+ $("#ip_MenuName").val() + "] 메뉴 등록");
				
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
	    		argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
	   		}else {
	    		argoAlert("저장에 실패하였습니다");	 
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
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
					<span class="btn_r">
						<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>   
						<input type="hidden" id="ip_Depth1Id" name="ip_Depth1Id" />
						<input type="hidden" id="ip_Depth2Id" name="ip_Depth2Id" />
						<input type="hidden" id="ip_Depth3Id" name="ip_Depth3Id" />
						<input type="hidden" id="ip_InsId" name="ip_InsId" />
						<input type="hidden" id="ip_UptId" name="ip_UptId" />
					</span>               
				</div>
                <div class="input_area">
					<table class="input_table">
						<colgroup>
                        	<col width="150">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>메뉴명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_MenuName" name="ip_MenuName" style="width:300px;" class="mr10">                               
                                </td>
                            </tr>
                        	<tr>
                            	<th>메뉴기본권한<span class="point">*</span></th>
                                <td>
                                	<select id="ip_MenuAuthDef" name="ip_MenuAuthDef" style="width:300px;">
                                		<option value="">선택하세요!</option>
                                		<option value="0">없음</option>
                                		<option value="1">조회</option>
                                		<option value="2">제어가능</option>                                		
                                    </select>
                                </td>
                            </tr>
                            <tr>
                            	<th>메뉴링크<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_SrcDo" name="ip_SrcDo" style="width:300px;" class="mr10">
                                </td>
                            </tr>
							<tr>
                            	<th>표시여부<span class="point">*</span></th>
                                <td>
                                	<span class="checks"><input type="radio" id="use_yes" name="ip_DisplayFlag" value='0'><label for="use_yes">예</label></span>
                                    <span class="checks ml15"><input type="radio" id="use_no" name="ip_DisplayFlag" value='1'><label for="use_no">아니오</label></span>
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
