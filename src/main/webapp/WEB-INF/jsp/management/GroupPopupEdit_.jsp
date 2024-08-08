<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var userId2   = loginInfo.SVCCOMMONID.rows.userId;
	var workMenu  = "그룹정보관리";
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
	var gGroupId;
	var tenantId;
	var userId;
	
	function fnInitCtrlPop() {
		cudMode  = sPopupOptions.cudMode;
		gGroupId = sPopupOptions.groupId;
		tenantId = sPopupOptions.tenantId;
		userId 	 = sPopupOptions.userId;
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		
		if(cudMode =='I') {
			var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
			fvCurRow= sPopupOptions;
			$("#ip_TenantId").val(tenantId);
			$("#ip_ValueTitleId").val("0");
			$("#ip_GroupMngId").val("");
		    $("#ip_TopParentId").val(fvCurRow.topParentId);
		    $("#ip_Depth").val(fvCurRow.depth);
		    $("#ip_ParentId").val(fvCurRow.groupId);
			$("#ip_InsId").val(loginInfo.SVCCOMMONID.rows.agentId);
			//argoJsonSearchOne('Group','getSubDepth','ip_', {"depth":fvCurRow.depth},callback);
		}else{
			fvCurRow= sPopupOptions.pRowIndex;
		    var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
		    $("#ip_InsId").val(loginInfo.SVCCOMMONID.rows.agentId);
		    $("#ip_GroupId").val(fvCurRow.groupId);
		   	argoSetValues("ip_", fvCurRow);
		}
	}
	
	function callback(data, textStatus, jqXHR) {
		try{
			if(data.isOk()){
				var depth = data.SVCCOMMONID.rows.depth;
				$("#ip_Depth").val(fvCurRow.depth+depth);
			}
		} catch(e) {
			console.log(e);			
		}	
	}
	
	function groupIdCallback(data, textStatus, jqXHR) {
		try{
			if(data.isOk()){
				if(cudMode =='I') {
					var maxGroupId = data.SVCCOMMONID.rows.groupId;
					$("#ip_GroupId").val(maxGroupId);
					fnDetailInfoCallback();
				}else{
				   	fnDetailInfoCallback();
				}
			}
		} catch(e) {
			console.log(e);			
		}	
	}
	
	function fnSavePop(){
		var aValidate;
		argoConfirm("저장 하시겠습니까?", function(){
			aValidate = {
				rows:[ 
			    		{"check":"length", "id":"ip_GroupName", "minLength":1, "maxLength":50, "msgLength":"그룹이름을 입력하세요."}
			    	]
		    };	
				
			if (argoValidator(aValidate) != true) return;
			
			argoJsonSearchOne('Group','getMaxGroupId','ip_', {},groupIdCallback);
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("Group","setGroupInsert","ip_", {"cudMode":cudMode});
				workLog = '[그룹ID:'+ gGroupId+'] 등록';
			}else{
				$("#ip_UptId").val($("#ip_InsId").val());
				Resultdata = argoJsonUpdate("Group","setGroupUpdate","ip_", {"cudMode":cudMode});
				workLog = '[그룹ID:'+ argoGetValue('ip_GroupId') +'] 수정';
			}
	
			if(Resultdata.isOk()) {	
			   	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId2
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
			}else {
			   	argoAlert("저장에 실패하였습니다");	 
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
                       	<input type="hidden" id="ip_TopParentId" name="ip_TopParentId" >
                       	<input type="hidden" id="ip_ParentId" name="ip_ParentId" >
                       	<input type="hidden" id="ip_Depth" name="ip_Depth" >
                       	<input type="hidden" id="ip_GroupId" name="ip_GroupId" >
                       	<input type="hidden" id="ip_InsId" name="ip_InsId" >
                       	<input type="hidden" id="ip_UptId" name="ip_UptId" >
                       	<input type="hidden" id="ip_TenantId" name="ip_TenantId" >
                       	<input type="hidden" id="ip_ValueTitleId" name="ip_ValueTitleId">
                       	<input type="hidden" id="ip_GroupMngId" name="ip_GroupMngId"> 
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
                            	<th>그룹명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_GroupName" name="ip_GroupName" style="width:400px;" class="mr10" />
                                </td>
                            </tr>
                            <tr>
                            	<th>설명<span class="point"></span></th>
                                <td>
                                	<input type="text" id="ip_GroupDesc" name="ip_GroupDesc" style="width:400px;" class="mr10">
                                </td>
                            </tr>
                            <tr>
                            	<th rowspan="2">제어그룹</th>
                            	<td colspan="5">
                            		키보드의 ctrl 버튼을 누른 상태에서 제어할 그룹을 선택하시면 다중 선택이 가능합니다. ( 필요시 하부그룹까지 선택 )
                               </td>
                            </tr>
                            <tr>
                            	<td colspan="5">
                            		<select name="ip_ControlAuth" id="ip_ControlAuth" class="s8"  style="width: 98%;height: 150px" multiple="multiple"  >
									</select> 
                            	</td>
                            </tr>
                            <tr>
                            	<th rowspan="2">사용자목록</th>
                            	<td colspan="5">
                            		키보드의 ctrl 버튼을 누른 상태에서 사용자를 선택하시면 다중 선택이 가능합니다.
                               </td>
                            </tr>
                            <tr>
                            	<td colspan="5">
                            		<select name="ip_ControlAuth" id="ip_ControlAuth" class="s8"  style="width: 98%;height: 150px" multiple="multiple"  >
									</select> 
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
