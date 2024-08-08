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
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var userId2   = loginInfo.SVCCOMMONID.rows.userId;
	var workMenu  = "그룹정보관리";
	var workLog   = "";
	
	$(function () 
	{
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
	    /*
	         테스트 코드 지우지 말것
	    var agentid	= "'2018020476','2018020477'";
		argoJsonSearchList('comboBoxCode','TEST','_', {"userList":agentid}, function (data, textStatus, jqXHR)
		{
			console.log(data.userId);
		});
		return;
		*/
		
	  	fnInitCtrlPop();
	  	ArgSetting();
	  	
	});
	
	var cudMode;
	var gGroupId;
	var tenantId;
	var userId;
	
	function fnInitCtrlPop() 
	{
		cudMode  = sPopupOptions.cudMode;
		gGroupId = sPopupOptions.groupId;
		tenantId = sPopupOptions.tenantId;
		userId 	 = sPopupOptions.userId;
		
		/*if (cudMode == "I")
		{
			$("#ip_Edittr1").hide();
			$("#ip_Edittr2").hide();
			$("#ip_Edittr3").hide();
			$("#ip_Edittr4").hide();
		}*/
		$("#ip_Edittr1").hide();
		$("#ip_Edittr2").hide();
		$("#ip_Edittr3").hide();
		$("#ip_Edittr4").hide();
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
		
		var param	= {"findTenantId" : tenantId, "findGroupId" : gGroupId};
		argoCbCreate("ip_userList", "comboBoxCode", "getUserCodeList", param, {"selectIndex":0, "text":'선택하세요!', "value":''});
		fnGroupCbChange("ip_userList");
	}
	
	function ArgSetting() 
	{
		argoCbCreate("ip_ControlAuth", "comboBoxCode", "getControlAuthList", {findTenantId: tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		fnGroupCbChange("ip_ControlAuth");
		
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
		    $("#ip_GroupId").val( fvCurRow.groupId);
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
	
	function fnSavePop()
	{
		var aValidate;
		argoConfirm("저장 하시겠습니까?", function()
		{
			aValidate = {
					rows:[ 
				    		{"check":"length", "id":"ip_GroupName", "minLength":1, "maxLength":50, "msgLength":"그룹이름을 입력하세요."}
				    	]
			    };	
					
			if (argoValidator(aValidate) != true) return;
			
			argoJsonSearchOne('Group','getMaxGroupId','ip_', {},groupIdCallback);
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) 
	{
		try 
		{
			if(cudMode == "I")
			{
				Resultdata = argoJsonUpdate("Group","setGroupInsert","ip_", {"cudMode":cudMode});
				workLog = '[그룹ID:'+ gGroupId+'] 등록';
			}
			else
			{
				$("#ip_UptId").val($("#ip_InsId").val());
				Resultdata = argoJsonUpdate("Group","setGroupUpdate","ip_", {"cudMode":cudMode});
				workLog = '[그룹ID:'+ argoGetValue('ip_GroupId') +'] 수정';
			}
	
			if(Resultdata.isOk()) 
			{
				var userAuth	= document.getElementById("ip_ControlAuth");
				var userList	= document.getElementById("ip_userList");
				var userDatas;
				//크롬, 엣지 등 웹 표준
				if (userList.selectedOptions != undefined)
					userDatas	= userList.selectedOptions;
				//ie11 용
				else
				{
					var length		= userList.options.length;
					var userDatas	= [];
					var index		= 0;
					for (var i = 0; i < length; i++)
					{
						if (userList.options[i].selected)
						{
							userDatas[index]	= userList.options[i];
							index++;
						}
					}
				}
				
				var isSuccess	= false;
				if (userDatas.length <= 0)
				{
					//argoAlert("최소 1명 이상의 사용자를 선택하셔야 합니다.");	 
					//return ;
					isSuccess	= true;
				}
				
				var userParam	= "";
				for (var i = 0; i < userDatas.length; i++)
				{
					var selectedGroup	= document.getElementById("ip_ControlAuth");
					var controlAuth	;
					//크롬, 엣지 등 웹 표준
					if (selectedGroup.selectedOptions != undefined)					
						controlAuth		= selectedGroup.selectedOptions;
					//ie11 용
					else
					{
						var length		= selectedGroup.options.length;
						var controlAuth	= [];
						var index		= 0;
						for (var t = 0; t < length; t++)
						{
							if (selectedGroup.options[t].selected)
							{
								controlAuth[index]	= selectedGroup.options[t];
								index++;
							}
						}
					}
					
					var controlAuthList	= "";
					for (var j = 0; j < controlAuth.length; j++)
					{
						if (j > 0)
							controlAuthList	+= "," + controlAuth[j].value;
						else
							controlAuthList	= controlAuth[j].value;
						
					}
					
					//var param			= {findControlAuth : controlAuth[j].value, findTenantId:tenantId, "userid":userDatas[i].value};
					var param			= {findControlAuth : controlAuthList, findTenantId:tenantId, "userid":userDatas[i].value};
					var result			= argoJsonUpdate("comboBoxCode", "updateUserAuth", '__', param);
					if (result.isOk())
						isSuccess	= true;
					else
						isSuccess	= false;
					
					if (!isSuccess)
						break;
				}
				
				/*
				userParam		= "'" + userParam + "'";
				fvCurRow		= sPopupOptions.pRowIndex;
				var groupId		= fvCurRow.groupId.trim();
				var param	= {"findTenantId":tenantId, "findGroupId" : groupId, "userList":userParam};
				var result	= argoJsonUpdate("comboBoxCode", "updateUserAuth", '_', param);
				*/
				if(isSuccess) 
				{
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId2
						,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
					argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
				}
			}			   	
			else 
			{
			   	argoAlert("저장에 실패하였습니다");	 
			}
		} 
		catch (e) 
		{
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
                            <tr id="ip_Edittr1">
                            	<th rowspan="2">제어그룹</th>
                            	<td colspan="5">
                            		키보드의 ctrl 버튼을 누른 상태에서 사용자를 선택하시면 다중 선택이 가능합니다.
                               </td>
                            </tr>
                            <tr id="ip_Edittr2">
                            	<td colspan="5">
                            		<select name="ip_ControlAuth" id="ip_ControlAuth" class="s8"  style="width: 98%;height: 150px" multiple="multiple"  >
                            		<!-- <select name="ip_ControlAuth" id="ip_ControlAuth" class="s8"  style="width: 98%;" > -->
									</select> 
                            	</td>
                            </tr>
                            <tr id="ip_Edittr3">
                            	<th rowspan="2">사용자목록</th>
                            	<td colspan="5">
                            		키보드의 ctrl 버튼을 누른 상태에서 사용자를 선택하시면 다중 선택이 가능합니다.
                               </td>
                            </tr>
                            <tr id="ip_Edittr4">
                            	<td colspan="5">
                            		<select name="ip_userList" id="ip_userList" class="s8"  style="width: 98%;height: 150px" multiple="multiple"  >
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
