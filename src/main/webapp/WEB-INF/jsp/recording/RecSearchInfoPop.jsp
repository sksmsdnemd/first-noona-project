<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->


<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
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
	var popOption;
	var workMenu 	= "시스템정보관리";
	var workLog 	= "";

	var dataArray 	= new Array();

	$(document).ready(function() {
		sPopupOptions = parent.gPopupOptions || {};
        sPopupOptions.get = function (key, value) {
            return this[key] === undefined ? value : this[key];
        };
        popOption = sPopupOptions.pRowIndex[0];
        tenantId = popOption.tenantId;
        groupId = popOption.groupId;
        
        fnInitCtrl();
		fnParamSetting();
	});
	
	function fnParamSetting(){
		argoCbCreate("ip_FindGroupId", "comboBoxCode",
		"getGroupList", {
			findTenantId : tenantId,
			userId : userId,
			controlAuth : controlAuth,
			grantId : grantId
		});
        fnGroupCbChange("ip_FindGroupId");
        $("#ip_FindGroupId").val(groupId);
        $("#ip_RecDate").val(popOption.recDate);
        $("#ip_RecTime").val(popOption.recTime);
        $("#ip_dnNo").val(popOption.dnNo);
        $("#ip_UserId").val(popOption.userId);
        $("#ip_FindCustTel").val(popOption.custTel);
        $("#ip_CustName").val(popOption.custName);
        $("#ip_FindCustNo").val(popOption.custNo);
        $("#ip_RecKey").val(popOption.recKey);
        
        $("#ip_CustEtc1").val(popOption.custEtc1);
        $("#ip_CustEtc2").val(popOption.custEtc2);
        $("#ip_CustEtc3").val(popOption.custEtc3);
        $("#ip_CustEtc4").val(popOption.custEtc4);
        $("#ip_CustEtc5").val(popOption.custEtc5);
        $("#ip_CustEtc6").val(popOption.custEtc6);
        $("#ip_CustEtc7").val(popOption.custEtc7);
        $("#ip_CustEtc8").val(popOption.custEtc8);
	}

	function fnInitCtrl(){
		
		$("#btnChange").click(function(){
			// 전화번호 자리수 체크
			var custTelLen = popOption.custTel == null ? 0 : popOption.custTel.length;
	 		if((custTelLen > 0 || $("#ip_FindCustTel").val().length > 0) && $("#ip_FindCustTel").val().length < 5) {
	 			argoAlert("전화번호는 5자리 이상 32자리 이하로 입력 가능합니다.");
	 			return;
			}
			
			argoConfirm("수정하시겠습니까?",
						function (){
						var fnidCustEtc = $("#ip_CustEtc1").val()+"|C"+$("#ip_CustEtc2").val()+"|C"+$("#ip_CustEtc3").val()+"|C"+$("#ip_CustEtc4").val()+"|C"
										+ $("#ip_CustEtc5").val()+"|C"+$("#ip_CustEtc6").val()+"|C"+$("#ip_CustEtc7").val()+"|C"+$("#ip_CustEtc8").val()+"|C";
						var callId = popOption.callId;
						argoJsonUpdate(
								"recSearch",
								"getRecSearchCustUpdate",
								"ip_",
								{"encKey":popOption.encKey,"fnidCustEtc":fnidCustEtc,"callId":callId},
								function(data){
									var result = data.SVCCOMMONID.procCnt;
									//argoAlert('warning', '수정완료되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
									argoAlert('warning', '수정완료되었습니다.', '',	'parent.fnSearchListCntAfterCallback(); argoPopupClose();');
								})
						}	
										
			);
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
                       	<button type="button" class="btn_m confirm" id="btnChange" name="btnSavePop">수정</button>   
                       	<input type="hidden" id="ip_RecKey" name="ip_RecKey"/>
                    </span>               
                </div>
                <div class="input_area">
                	<table  class="input_table"> 
                    	<tbody>
                    		<tr>
                            	<th>통화일자</th>
                                <td>
                                	<input type="text" id="ip_RecDate" name="ip_RecDate" value="" style="width:330px;" readonly="readonly">                                 
                                </td>
                            </tr>
                            <tr>
                            	<th>녹취시간</th>
                                <td>
                                	<input type="text" id="ip_RecTime" name="ip_RecTime" value="" style="width:330px;" readonly="readonly">                                 
                                </td>
                            </tr>
							<tr>
                            	<th>그룹명</th>
                                <td>
                                	<select style="width:330px;" id="ip_FindGroupId" name="ip_FindGroupId" disabled="disabled"></select>
                                	                           
                                </td>
                            </tr>
                            <tr>
                            	<th>내선번호</th>
                                <td>
                                	<input type="text" id="ip_dnNo" name="ip_dnNo" style="width:330px;" readonly="readonly">                                 
                                </td>
                            </tr>
                            <tr>
                            	<th>상담사ID</th>
                                <td>
                                	<input type="text" id="ip_UserId" name="ip_UserId" style="width:330px;" readonly="readonly">     
                                </td>
                            </tr>
                        	<tr>
                            	<th>전화번호</th>
                                <td>
                                	<input type="text" id="ip_FindCustTel" name="ip_FindCustTel"  style="width:330px;" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" >                                  
                                </td>
                            </tr>
                            <tr>
                            	<th>고객명</th>
                                <td>
                                	<input type="text" id="ip_CustName" name="ip_CustName" style="width:330px;">
                                </td>
                                
                            </tr>
                            <tr>
                            	<th>고객번호</th>
                                <td>
                                	<input type="text" id="ip_FindCustNo" name="ip_FindCustNo"  style="width:330px;" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" >
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC1</th>
                                <td>
                                	<input type="text" id="ip_CustEtc1" name="ip_CustEtc1" value="" style="width:330px;">
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC2</th>
                                <td>
                                	<input type="text" id="ip_CustEtc2" name="ip_CustEtc2" value="" style="width:330px;">
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC3</th>
                                <td>
                                	<input type="text" id="ip_CustEtc3" name="ip_CustEtc3" value="" style="width:330px;">
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC4</th>
                                <td>
                                	<input type="text" id="ip_CustEtc4" name="ip_CustEtc4" value="" style="width:330px;">
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC5</th>
                                <td>
                                	<input type="text" id="ip_CustEtc5" name="ip_CustEtc5" value="" style="width:330px;">
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC6</th>
                                <td>
                                	<input type="text" id="ip_CustEtc6" name="ip_CustEtc6" value="" style="width:330px;">
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC7</th>
                                <td>
                                	<input type="text" id="ip_CustEtc7" name="ip_CustEtc7" value="" style="width:330px;">
                                </td>
                            </tr>
                            <tr>
                            	<th>ETC8</th>
                                <td>
                                	<input type="text" id="ip_CustEtc8" name="ip_CustEtc8" value="" style="width:330px;">
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