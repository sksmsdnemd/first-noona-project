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
	var workMenu 	= "고객정보수정";
	var workLog 	= "";

	var dataArray 	= new Array();
	var filteredDynimicData = new Array();
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
		dynimicTableSet();
	});
	
	
	function fnConvCamel(str) {
		var before = str.toLowerCase();
		var after = "";
		var bs = before.split("_");

		if(bs.length < 2) {
			return bs;
		}
		for (var i=0; i<bs.length; i++) {
			if(bs[i].length > 0){
				if(i==0)
					after += bs[i].toLowerCase();
				else
					after += bs[i].toLowerCase().substr(0,1).toUpperCase()+bs[i].substr(1,bs[i].length-1);
			}
		}
		return after;
	}
	
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
        
        var multiService = new argoMultiService(fnCallbackSearch);
    	multiService.argoList("recSearchNew", "getCustDetailPopHeaderList", "_", {"findTenantId":popOption.tenantId})
    		        .argoList("recSearchNew", "getCustDetailPopDataList", "_", {"recKey":popOption.recKey}); 
    	multiService.action(); 
	}

	function fnCallbackSearch(data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				var custDataHeader  = data.getRows(0);
				var custData 		= data.getRows(1);
				if(data.getRows(0) != ""){
					$.each(custDataHeader, function(index, obj){
						$.each(custData, function(index2, obj2){
							if(obj.code == obj2.code){
								$("#recDetailTable").append(
									'<tr>'+
						            	'<th>'+obj.codeNm+'</th>'+
						                '<td>'+
						                	'<input type="text" id="ip_'+fnConvCamel(obj2.code)+'Dat" name="ip_CustEtcDat" value="'+obj2.custData+'" style="width:330px;">'+
						                	'<input type="hidden" id="ip_'+fnConvCamel(obj2.code)+'Col" name="ip_CustEtcCol" value="'+obj2.code+'">'+
						                '</td>'+
						            '</tr>'
								);
							}
						});
					});
		    	}
		    } 
		} catch(e) {
			argoAlert(e);
		}
	}
	
	
	function fnInitCtrl(){
		
		$("#btnChange").click(function(){
			argoConfirm("수정하시겠습니까?",function (){
					var callId = popOption.callId;
					var recKey = popOption.recKey;
					var multiService = new argoMultiService(fnCallbackSave);
					multiService.argoUpdate("recSearchNew", "getRecSearchCustUpdateNew", "ip_", {"encKey":popOption.encKey,"callId":callId});
					
					var custDataInput = $("input[name='ip_CustEtcDat']");
					var custColInput = $("input[name='ip_CustEtcCol']");
					$.each(custDataInput, function(index, obj){
						var param = {
							"recKey" 		: recKey,
							"colId" 		: custColInput.eq(index).val(),
							"custData" 		: custDataInput.eq(index).val(),
							"tenantId"		: tenantId
						}
						multiService.argoUpdate("recSearchNew", "setCustDetailPopDataUpdt", "_", param);
					});
					
					multiService.action();
				}	
			);
		});
	}
	
	function fnCallbackSave(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	argoAlert('warning', '고객정보가 성공적으로 수정 되었습니다.','', 'parent.fnSearchListCnt(); argoPopupClose();');
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
                       	<button type="button" class="btn_m confirm" id="btnChange" name="btnSavePop">수정</button>   
                       	<input type="hidden" id="ip_RecKey" name="ip_RecKey"/>
                    </span>               
                </div>
                <div class="input_area">
                	<table  class="input_table" id="recDetailTable"> 
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
                                	<input type="text" readonly="readonly" id="ip_FindCustTel" name="ip_FindCustTel"  style="width:330px;" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" >                                  
                                </td>
                            </tr>
                            <tr>
                            	<th>고객명</th>
                                <td>
                                	<input type="text" readonly="readonly" id="ip_CustName" name="ip_CustName" style="width:330px;">
                                </td>
                                
                            </tr>
                            <tr>
                            	<th>고객번호</th>
                                <td>
                                	<input type="text" readonly="readonly" id="ip_FindCustNo" name="ip_FindCustNo"  style="width:330px;" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" >
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