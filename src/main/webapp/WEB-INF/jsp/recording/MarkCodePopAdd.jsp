<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/jscolor.min.js"/>"></script>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "마킹정보관리";
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
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		
		if(cudMode =='I') {
			argoSetValue("ip_TenantId", sPopupOptions.tenantId);
			$('#ip_MarkingColor').focus();   
		}else{
			fvCurRow = sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow);
		}
	}
	
	function fnSavePop(){
	
		argoConfirm("저장 하시겠습니까?", function(){
				var aValidate = {
				        rows:[]
				};	
				
				if (argoValidator(aValidate) != true) return;
	
				argoJsonSearchOne("recordFile", "getMaxMarkingId", "ip_", {}, fnDetailInfoCallback);
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				var info = data.getRows();
				var resultData;
				
				if(cudMode == "I"){
					argoSetValue("ip_MarkingId", info.markingId);
					workLog = '[태넌트:' + argoGetValue("ip_TenantId") + ' | 마킹ID:' + argoGetValue("ip_MarkingId") + '] 등록';
					Resultdata = argoJsonUpdate("recordFile", "setMarkCodeInsert", "ip_", {});
				}else{
					workLog = '[태넌트:' + argoGetValue("ip_TenantId") + ' | 마킹ID:' + argoGetValue("ip_MarkingId") + '] 수정';
					Resultdata = argoJsonUpdate("recordFile", "setMarkCodeUpdate", "ip_", {});
				}
				
				if(Resultdata.isOk()) {
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				   	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
				}else {
				   	argoAlert("저장에 실패하였습니다");	 
				} 
			}
		} catch (e) {
			console.log(e);
		}
	}
	
	function setTextColor(picker) {
		document.getElementsByTagName('body')[0].style.color = '#' + picker.toString()
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
                       	<input type="hidden" id="ip_TenantId" name="ip_TenantId"/>
                       	<input type="hidden" id="ip_MarkingId" name="ip_MarkingId"/>
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
                            	<th>마킹 분류명<span class="point"></span></th>
                                <td>
                                	<textarea id="ip_MarkingClass" name="ip_MarkingClass" maxlength="100" style="width:300px; height:30px;"></textarea>                                 
                                </td>
                            </tr>
                            <tr>
                            	<th>마킹 색상<span class="point"></span></th>
                                <td>
                                	<input type="text" id="ip_MarkingColor" name="ip_MarkingColor" style="width:176px;">
                                	<button type="button" class="btn_m jscolor {valueElement:'ip_MarkingColor'}">Marking Color</button>
                                </td>
                            </tr>
                        	<tr>
                            	<th>마킹 내용<span class="point"></span></th>
                                <td>
                                	<textarea id="ip_MarkingDesc" name="ip_MarkingDesc" maxlength="100" style="width:300px; height:100px;"></textarea>
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
