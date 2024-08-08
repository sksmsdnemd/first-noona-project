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
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "회사정보관리팝업";
	var workLog 	= "";
	
	var cudMode;
	
	var insId;
	var bExistCheck = false;
	
	$(function () {
		var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
		cudMode = sPopupOptions.cudMode;
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
		
		$("#btnExpireCancle").click(function(){
			fnExpireCancle();
		});	
		
	  	ArgSetting();
	});
	
	function ArgSetting() {
		if(cudMode =='I') {
			
			$("#ip_InsId").val(insId);
			$("#btnExpireCancle").hide();
			$("#expireDateTr").hide();
	   		$("#expireReasonTr").hide();
		}else{
			fvCurRow= sPopupOptions.pRowIndex;
		   	argoSetValues("ip_", fvCurRow)	
		   	$("#ip_TenantId").attr("disabled", true);
		   	
		   	if(sPopupOptions.pRowIndex.expireDate != "" && sPopupOptions.pRowIndex.expireDate != null) {
				$("#btnSavePop").hide();
				$("#btnExpireCancle").show();
		   		
		   		$("#ip_TenantName").attr("disabled", true);
		   		$("#ip_AgentCount").attr("disabled", true);
		   		$("#ip_ManagerCount").attr("disabled", true);
		   		$("#ip_BasePath").attr("disabled", true);
		   	} else {
		   		$("#btnExpireCancle").hide();

		   		$("#expireDateTr").hide();
		   		$("#expireReasonTr").hide();
		   	}
		}
	}
	
	function fnSavePop(){
		var aValidate;
		
		argoConfirm("저장 하시겠습니까?", function(){
				
			aValidate = {
		        rows:[ 
					 	 {"check":"length", "id":"ip_TenantId", "minLength":1, "maxLength":50, "msgLength":"회사아이디 입력하세요."}
						,{"check":"length", "id":"ip_TenantName", "minLength":1, "maxLength":50, "msgLength":"회사명을 입력하세요."}
		        	]
		    };	
			if (argoValidator(aValidate) != true) return;
	
			if(cudMode == "I"){
				argoJsonSearchOne('userInfo', 'getTenantOverlapCheck', '', {"findTenantNameText": $("#ip_TenantId").val() }, function (data, textStatus, jqXHR){
					try{
						if(data.isOk()){
							
							$.each(data.getRows(), function( index, row ) {
								if(row == 1){
									argoAlert($("#ip_TenantId").val() + "(은/는) 이미 존재합니다.");
									bExistCheck = true;
								
									return;
								} else {
									fnDetailInfoCallback();	 
								}
							});
						}
					} catch(e) {
						argoAlert("중복 데이터 확인 중 오류가 발생하였습니다.");
						
						console.log(e);
						return;
					}
				});
			}
			
			if(cudMode == "U"){
				fnDetailInfoCallback();	 
			}
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("userInfo", "setTenantInfoInsert", "ip_", {"cudMode":cudMode});
				//2018-10-10 yoonys start
				argoJsonUpdate("userInfo", "setAuthInfoInsert", "ip_", {"cudMode":cudMode});
// 				console.log("권한생성완료");
				argoJsonUpdate("userInfo", "setMenuAuthInfoInsert", "ip_", {"cudMode":cudMode,"userId":userId});
// 				console.log("메뉴권한생성완료");
				argoJsonUpdate("userInfo", "setGroupInfoInsert", "ip_", {"cudMode":cudMode,"userId":userId});
// 				console.log("최상위그룹생성완료");
				//2018-10-10 yoonys end
				workLog = '[TenantInfo:' + argoGetValue('ip_TenantId') + '] 등록';
			}else{
				Resultdata = argoJsonUpdate("userInfo", "setTenantInfoUpdate", "ip_", {"cudMode":cudMode});
				workLog = '[TenantInfo:' + argoGetValue('ip_TenantId') + '] 수정';
			}
	
			if(Resultdata.isOk()) {	
			    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
			}else {
			   	argoAlert("저장에 실패하였습니다");	 
			}
		} catch (e) {
			console.log(e);
		}
	}
	
	function fnExpireCancle() {
		argoConfirm("해지취소 하시겠습니까?", function() {
			try {
				Resultdata = argoJsonUpdate("userInfo", "setTenantExpireCancle", "ip_", {"cudMode":cudMode});
				
				if(Resultdata.isOk()) {
					workLog = '[TenantInfo:' + argoGetValue('ip_TenantId') + '] 해지취소';
				    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				    argoAlert('warning', '성공적으로 해지취소 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
				} else {
				   	argoAlert("해지취소에 실패하였습니다");	 
				}
			} catch (e) {
				console.log(e);
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
                       <button type="button" class="btn_m confirm" id="btnExpireCancle" name="btnExpireCancle">해지취소</button>   
                       <button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>   
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
                        		<th>회사ID<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_TenantId" name="ip_TenantId" style="width: 300px"	class="mr10" />
                                </td>
                            </tr>
                            <tr>
                            	<th>회사명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_TenantName" name="ip_TenantName" style="width:300px;" class="mr10" />
                                </td>
                            </tr>
<!-- 
                            <tr>
                            	<th>디스크할당량<br>(기간  or 용량)</th>
                                <td>
                                	<input type="text" id="ip_DiskLimit" name="ip_DiskLimit" style="width: 300px"	class="mr10" />
								</td>
                            </tr>
 -->
                            <tr>
								<th>상담사수</th>
								<td>
                                	<input type="text" id="ip_AgentCount" name="ip_AgentCount" style="width: 300px"	class="mr10 onlyNum" />
                                </td>
                            </tr>
                            <tr>
								<th>내선수</th>
								<td>
                                	<input type="text" id="ip_ManagerCount" name="ip_ManagerCount" style="width: 300px"	class="mr10 onlyNum" />
                                </td>
                            </tr>
                            <tr>
								<th>기본경로</th>
								<td>
                                	<input type="text" id="ip_BasePath" name="ip_BasePath" style="width: 300px"	class="mr10" />
                                </td>
                            </tr>
<!-- 
                            <tr>
                            	<th>라이선스번호</th>
                                <td>
                                	<input type="text" id="ip_SerialNo" name="ip_SerialNo" style="width: 300px"	class="mr10" />
								</td>
                            </tr>
 -->
							<tr id="expireDateTr">
								<th>해지일자</th>
								<td>
                                	<input type="text" id="ip_ExpireDate" name="ip_ExpireDate" style="width: 300px"	class="mr10" disabled />
                                </td>
                            </tr>
							<tr id="expireReasonTr">
								<th>해지사유</th>
								<td>
									<textarea id="ip_ExpireReason" name="ip_ExpireReason" style="width: 300px; height: 80px;" disabled></textarea>
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
