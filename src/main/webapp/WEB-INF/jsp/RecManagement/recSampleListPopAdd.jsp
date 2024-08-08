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

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "샘플콜분류관리";
	var workLog 	= "";
	
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	  	
	  	ArgSetting();
	  	fnInitCtrlPop();
	});
	
	var cudMode;
	
	function fnInitCtrlPop() {
		cudMode = sPopupOptions.cudMode;
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		$("#s_FindTenantId").val(sPopupOptions.pTenantId).attr("selected", "selected");
	}
	
	function ArgSetting() {
		fvCurRow = sPopupOptions.pRowIndex;
	    console.log(fvCurRow);
	    argoSetValue('ip_InsId', userId );
	    if(fvCurRow.flag =='I') {
	
		}else if(fvCurRow.flag =='I_I'){
		  
		}else{
			argoSetValues("ip_", fvCurRow);
		}
	}
	
	function fnSavePop(){
		var aValidate;
		var str = document.getElementById('ip_GroupName');
	
		aValidate = {
			rows:[ 
					 {"check": "length", "id":"ip_GroupName"		, "minLength":1, "maxLength":50,  "msgLength":"분류명을 입력하세요."}
			    ]
		};	
		
		if (argoValidator(aValidate) != true) return;
		
		argoConfirm("저장 하시겠습니까?", function(){
			var blank_pattern = /[\s]/g;
			if( blank_pattern.test( str.value) == true){
				argoAlert(' 공백은 사용할 수 없습니다. ');
				return false;
			}
	
			argoJsonSearchOne("recSample", "getMaxRecSampleCallGrpId", "s_", {tenantId:$('#s_FindTenantId option:selected').val()}, fndept);
		});
	}
	
	function fndept(data, textStatus, jqXHR) {
		if (data.isOk()) {
			if(fvCurRow.flag == "I"){
				var info = data.getRows();
				console.log(info)
				argoSetValue('ip_NewGroupId', info.groupId);
				argoSetValue('ip_GroupId', info.groupId);
				argoSetValue('ip_TopParentId', info.groupId);
				argoSetValue('ip_ParentId', info.groupId);
				argoSetValue('ip_Level', "1");
			}else if(fvCurRow.flag == "I_I"){
				var info = data.getRows();
				var le = Number(fvCurRow.level);
				argoSetValue('ip_GroupId', info.groupId);
				argoSetValue('ip_ParentId', fvCurRow.groupId);
				argoSetValue('ip_Depth', fvCurRow.depth);
				argoSetValue('ip_Level', le+1);
			}else{
				
			}
			//alert(tenantId);
			argoJsonSearchOne("recSample", "getRecSampleCallDepth", "ip_", {tenantId:$('#s_FindTenantId option:selected').val()}, fnDetailInfoCallback);
		}
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			//alert(tenantId);
			if(fvCurRow.flag == "I"){
				var info = data.getRows();
				argoSetValue('ip_Depth', info.depth);
				argoSetValue('ip_TenantId',tenantId);				
				Resultdata = argoJsonUpdate("recSample", "setSampleCallGrpInsert", "ip_", {cudMode:"I", tenantId:$('#s_FindTenantId option:selected').val()});
				workLog = '[depth:' + info.depth + '] 등록';
			}else if( fvCurRow.flag == "I_I"){
				var info = data.getRows();
				argoSetValue('ip_Depth', fvCurRow.depth + info.depth);
				argoSetValue('ip_TopParentId', fvCurRow.topParentId);
				argoSetValue('ip_ParentId', fvCurRow.groupId);
				argoSetValue('ip_TenantId',tenantId);				
				Resultdata = argoJsonUpdate("recSample", "setSampleCallGrpInsert", "ip_", {cudMode:"I", tenantId:$('#s_FindTenantId option:selected').val()});
				workLog = '[group:' + fvCurRow.groupId + '] 서브등록';
			} else if(sPopupOptions.flag == "U"){
				Resultdata = argoJsonUpdate("recSample", "setSampleCallGrpUpdate", "ip_", {"cudMode":"U", tenantId:$('#s_FindTenantId option:selected').val()});
				workLog = '[depth:' + argoGetValue('ip_Depth') + '] 수정';
			}
			
			if(Resultdata.isOk()) {
			   	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:$('#s_FindTenantId option:selected').val(), userId:userId
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
                       	<input type="hidden" id="ip_GroupId" name="ip_GroupId" />
                        <input type="hidden" id="ip_NewGroupId" name="ip_NewGroupId" />
<!--                         <input type="hidden" id="ip_TenantId" name="ip_TenantId" /> -->
                        <input type="hidden" id="ip_TopParentId" name="ip_TopParentId" />
                        <input type="hidden" id="ip_ParentId" name="ip_ParentId" />
                        <input type="hidden" id="ip_Depth" name="ip_Depth" />
                        <input type="hidden" id="ip_InsId" name="ip_InsId" />
                        <input type="hidden" id="ip_Level" name="ip_Level" />  
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
                        		<th align="center">태넌트<span class="point">*</span></th>
                        		<td>
                        			<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
									<input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" /> 
									<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1">
                        		</td>
                            </tr>
                        	<tr>
                        		<th align="center">분류명<span class="point">*</span></th>
                        		<td><input type="text" name="ip_GroupName" id="ip_GroupName" style="width: 200px" class="mr10" /></td>
                            </tr>
                            <tr>
                            	<th align="center">설명</th>
                        		<td><input type="text" name="ip_GroupDesc" id="ip_GroupDesc" style="width: 200px" class="mr10" /></td>
                            </tr>
                        </tbody>
                    </table>
                </div>           
            </div>            
        </section>
    </div>
</body>

</html>
