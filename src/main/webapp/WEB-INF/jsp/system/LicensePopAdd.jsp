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

	var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
	var workMenu 	= "키관리";
	var workLog 	= "";
	if(loginInfo!=null){	
		var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;	
		var userId      = loginInfo.SVCCOMMONID.rows.userId;
		var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
		var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
		var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
		var convertFlag = loginInfo.SVCCOMMONID.rows.convertFlag;
		var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
		var depth		= loginInfo.SVCCOMMONID.rows.depth;
		var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
		var backupAt	= loginInfo.SVCCOMMONID.rows.backupAt;
	}else{
		var tenantId    = 'bridgetec';	
		var userId      = 'btadmin';
		var grantId     = 'SuperAdmin';
		var workIp      = '127.0.0.1';
		var playerKind  = '0';
		var convertFlag = '1';
		var groupId		= '1';
		var depth		= 'A';
		var controlAuth	= null;
	}
	
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
		cudMode = sPopupOptions.cudMode;
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	var cudMode;
	
	function fnInitCtrlPop() {
		$("#s_SystemId").change(function (){
			fnCbChange();	
		})

		$("#btnSavePop").click(function(){
			fnEncryptSearch();
		});	
	}
	
	function fnCbChange(){
		argoCbCreate("s_FindProcessCode", "procInfo", "getProcSlaveComboList", {"systemId":$("#s_SystemId").val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
	}
	
	function ArgSetting() {
		fvCurRow = sPopupOptions.pRowIndex;
		if(cudMode == "U"){
			$("#s_EncKey").val(fvCurRow.encKey);
			$("input:radio[name='s_FindGubun']:input[value='"+fvCurRow.gubun+"']").prop("checked", true);
			$("input:radio[name='s_UseFlag']:input[value='"+fvCurRow.useFlag+"']").prop("checked", true);
			
			$("input:radio[name='s_FindGubun']").attr("disabled", true);
			$("#s_EncKey").attr("disabled", true);
		}
	}
	
// 	function fnSavePop(strEn){
// 		var aValidate = {
// 				rows:[ 
// 				          {"check":"length", "id":"s_EncKey" , "minLength":1, "maxLength":50,  "msgLength":"키를 입력해주세요."}
// 				         ,{"check":"length", "id":"s_FindTenantId"    , "minLength":1, "maxLength":50,  "msgLength":"태넌트를 선택하세요."}
// 				         ,{"check":"length", "id":"s_SystemId" , "minLength":1, "maxLength":50,  "msgLength":"시스템명을  입력하세요."}
// 				         ,{"check":"length", "id":"s_FindProcessCode"  , "minLength":1, "maxLength":50,  "msgLength":"프로세스를 선택하세요."}
// 				         ,{"check":"length", "id":"s_FindGubun"  , "minLength":1, "maxLength":50,  "msgLength":"구분을 선택하세요."}
// 				         ,{"check":"length", "id":"s_UseFlag"  , "minLength":1, "maxLength":50,  "msgLength":"사용여부을 선택하세요."}
// 					]
// 			};
// 		if (argoValidator(aValidate) != true) return;
		
// 		if(cudMode == "I"){
// 				argoConfirm("저장 하시겠습니까?", function(){
// 					argoJsonUpdate("sysInfo", "getLicenseInsert", "s_", {"key":strEn}, function(data, textStatus, jqXHR) {
// 						if(data.isOk()) {
// 							workLog = '[시스템ID:' + data.getRows().systemId + '] 등록';
// 					    	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
// 					    					,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
// 					    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
// 					    }else {
// 					    	argoAlert("저장에 실패하였습니다");	 
// 					    }
// 					});
// 				});
// 		}else{
// 			var fvCurRow = sPopupOptions.pRowIndex;
// 			var licSeq = (cudMode == "U" ? fvCurRow.licSeq:"");			
// 			argoConfirm("저장 하시겠습니까?", function(){
// 				argoJsonUpdate("sysInfo", "getLicenseUpdate", "s_", {"key":strEn,"licSeq":licSeq}, function(data, textStatus, jqXHR) {
// 					if(data.isOk()) {
// 				    	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
// 				    					,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
// 				    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
// 				    	workLog = '[시스템ID:' + argoGetValue('ip_SystemId') + '] 수정';
// 				    }else {
// 				    	argoAlert("저장에 실패하였습니다");	 
// 				    }
// 				});
// 			});
// 		}
		
// 		$(function () {
// 			workLog = '[시스템ID:' + info.systemId + '] 등록';
// 		}else{
// 			Resultdata = argoJsonUpdate("sysInfo", "setSysInfoUpdate", "ip_", {"cudMode":cudMode});
// 			workLog = '[시스템ID:' + argoGetValue('ip_SystemId') + '] 수정';
// 	}

	function fnEncryptSearch(){
		var param = {};
		param.encKey = $("#s_EncKey").val();
		param.findGubun = $("input:radio[name='s_FindGubun']:checked").val();
		param.useFlag = $("input:radio[name='s_UseFlag']:checked").val();
		param.userId = userId;
		
		$.ajax({
			url : gGlobal.ROOT_PATH + "/License/LicenseEncryptF.do",
			type : "POST",
			contentType: "application/json; charset=utf-8",
			crossDomain : true, // 크로스도메인 해결 플러그인
			data : JSON.stringify(param),
			success : function(data) {
		    	argoAlert('warning', data, '',	'parent.fnSearchListCnt(); argoPopupClose();');
			},
			error : function(xhr, status, error) {
				console.log("fnDbEncrypt = error");
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
                            	<th>구분<span class="point">*</span></th>
                                <td>
                                	<label><input type="radio" id="s_GubunD" name="s_FindGubun" checked="checked" value="0">&nbsp;DB&nbsp;&nbsp;&nbsp;</label>
                                	<label><input type="radio" id="s_GubunF" name="s_FindGubun" value="1">&nbsp;FILE</label>
                                </td>
                            </tr>
                            <tr>
                            	<th>KEY<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="s_EncKey" name="s_EncKey" style="width: 250px" class="clickSearch" /> 
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
