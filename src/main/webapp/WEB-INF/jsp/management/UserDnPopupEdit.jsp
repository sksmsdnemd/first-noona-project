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
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var userId2    	= loginInfo.SVCCOMMONID.rows.userId;
	var workMenu 	= "내선번호관리";
	var workLog 	= "";
	
	$(function () {
		var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	var cudMode;
	var systemId;
	var processId;
	var userId;
	var dnNo;
	var dnNo;
	var reqTenantId;
	var orgIp;
	function fnInitCtrlPop() {
		cudMode 	= sPopupOptions.cudMode;
		systemId 	= sPopupOptions.systemId;
		processId 	= sPopupOptions.processId;
		userId 		= sPopupOptions.userId;
		reqTenantId = sPopupOptions.tenantId;
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});
		
		$("#ip_FindSystemId").change(function(){
	 		fnSetSubCb("system");
	 	});
		
		if(cudMode =='I') {
			 $("#hien1").hide();
			 $("#hien2").hide();
		}else{
			$("#ip_DnNo").attr("disabled", true);
			$("#ip_EDnNo").attr("disabled", true);
			$("#hien1").show();
			$("#hien2").show();
		};
	}
	
	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			if($('#ip_FindSystemId option:selected').val() == ''){
				argoCbCreate("ip_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:reqTenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				argoCbCreate("ip_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
			fnGroupCbChange("ip_FindGroupId");
		} else if (kind == "system") {
			if($('#ip_FindSystemId option:selected').val() == ''){
				$("#ip_FindProcessId").find("option").remove();
			}else{
				argoCbCreate("ip_FindProcessId", "comboBoxCode", "getProcessList2", {findSystemId:$('#ip_FindSystemId option:selected').val(), FindProcessName:"MRU"}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		} else if (kind == "groupNone") {
			if($('#ip_FindGroupId option:selected').val() == ''){
				$("#ip_FindUserId").find("option").remove();
			}else{
				argoCbCreate("ip_FindUserId", "comboBoxCode", "getUserList", {findTenantId:reqTenantId, FindGroupId:$('#ip_FindGroupId option:selected').val() + "_"}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		}
	}
	
	function ArgSetting() {
		argoSetDatePicker();
// 		argoCbCreate("ip_FindSystemId", "comboBoxCode", "getMruSystemList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_FindSystemId", "comboBoxCode", "getMruVssSystemList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:reqTenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		fnGroupCbChange("ip_FindGroupId");
		
		$("#ip_FindSystemId").change(function() {	fnSetSubCb('system');		});
		$("#ip_FindGroupId").change(function() {	fnSetSubCb('groupNone');	});
		
		if(cudMode =='I') {
			var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
			
			$("#ip_TenantId").val(reqTenantId);
			$("#ip_InsId").val(loginInfo.SVCCOMMONID.rows.agentId);
			$("#ip_UptId").val(loginInfo.SVCCOMMONID.rows.agentId);
			
		}else{
			fvCurRow= sPopupOptions.pRowIndex ;
			
			console.log("fvCurRow : " + fvCurRow);
	
		   	argoSetValues("ip_", fvCurRow);
	
		   	$("#ip_TenantId").val(reqTenantId);
		   	
		   	$('#ip_FindSystemId option[value=' + fvCurRow.systemId + ']').prop("selected", true);
		   	fnSetSubCb("system");
		   	$('#ip_FindProcessId option[value=' + fvCurRow.processId + ']').prop("selected", true);
		   	
		   	if (fvCurRow.groupId != "") {
		   		$('#ip_FindGroupId option[value=' + fvCurRow.groupId + ']').prop("selected", true);
		   		fnSetSubCb("groupNone");
		   		$('#ip_FindUserId option[value=' + fvCurRow.userId + ']').prop("selected", true);
		   	}
	
			$('#ip_UserId option[value=' + userId + ']').prop("selected", true);
			$('input:text[name="ip_SDnNo"]').val(dnNo);
			
			var useFlagC;
			var ch = fvCurRow.useFlag;
			if( ch == "O"){
				useFlagC = "0"
			}else{
				useFlagC = "1"
			}
			$('input:radio[name="ip_UseFlag"]').filter('[value=' + useFlagC + ']').prop('checked', 'checked');
			
			//phoneIp세팅_20180312_start
			var phoneIp = fvCurRow.phoneIp;
			orgIp = fvCurRow.phoneIp;
			if(phoneIp.indexOf(".") == -1){
				$("input:radio[name='ip_PhoneIpKind']:radio[value='port']").attr("checked", true);
			}else{
				$("input:radio[name='ip_PhoneIpKind']:radio[value='ip']").attr("checked", true);
			}
			//phoneIp세팅_20180312_end
		}
	}
	
	function fnSavePop(){
		
		var cnt = 0;
		var totCnt = 1;
 
		var sDnNo= parseInt($("#ip_DnNo").val() );
		var eDnNo = "";
		if($("#ip_EDnNo").val() != ""){
			eDnNo=parseInt($("#ip_EDnNo").val());
			totCnt =  eDnNo - sDnNo +1 ;
		}
		
		var exitAt = false;
		var phoneIpArr = new Array(); 
		var tmpIp = $("#ip_PhoneIp").val();
		var params = {sDnNo:sDnNo, eDnNo :eDnNo};
		
		if(cudMode =='I') {
			argoJsonSearchOne('userTel', 'getUserTelNoCnt', 'ip_', params , function (Resultdata, textStatus, jqXHR){
				if(Resultdata.isOk()) {
					cnt = Resultdata.getRows()['cnt'];
					if(cnt > 0 ){
						
						argoAlert("등록된 내선번호입니다 ! <br/>총 " +cnt+"건" );
						exitAt=true;
						return;
					}
				}
			});
			
	
		}
		
		if(tmpIp != orgIp){
			
			if (totCnt > 1){
				
				var sIp = $("#ip_PhoneIp").val();
				var arr = sIp.split('.');
				phoneIpArr.push(sIp);
				for(var i = 0 ; i < totCnt-1 ; i++ ){
					arr[3] = parseInt(arr[3]) + 1 ;
					phoneIpArr.push(arr.join('.'));
				}
			}
			
			params = {phoneIp:$("#ip_PhoneIp").val(), phoneIpArr : phoneIpArr};
			
			
			argoJsonSearchOne('userTel', 'getUserPhoneIpCnt', 'ip_', params, function (Resultdata, textStatus, jqXHR){
				if(Resultdata.isOk()) {	 
					if(Resultdata.getRows()['cnt'] > 0 ){
						argoAlert("등록된 IP번호입니다<br/>총&nbsp;" +Resultdata.getRows()['cnt']+"&nbsp;건");
						exitAt=true;
						return;
					}
				}
			});
			
			
			
			
			
		}
		
		//조건 추가_20180312_start
		var phoneIp		= $("#ip_PhoneIp").val();
		var phoneIpKind	= $("input:radio[name='ip_PhoneIpKind']:checked").val();
	
		if(phoneIp != null && phoneIp != ""){
			if(phoneIpKind == "ip"){
				if(phoneIp.indexOf(".") == -1){
					argoAlert("전화기IP를 잘못 입력하였습니다.");
					return;
				}
			}else{
				if(isNaN(phoneIp)){
					argoAlert("IVR Port를 숫자로  입력하세요.");
					return;
				}
				if(phoneIp.length != 5){
					argoAlert("IVR Port를 5자리로 입력하세요.");
					return;
				}
				if(phoneIp % 2 != 0){
					argoAlert("IVR Port를 짝수로 입력하세요");
					return;
				}
			}
		}
		//조건 추가_20180312_end
		
		if(!exitAt){
			argoConfirm("저장 하시겠습니까?", function(){
				fnDetailInfoCallback();	
			});
		}
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		
		var aValidate;
		try {
			if(cudMode == "I"){
				aValidate = {
			        rows:[ 
							 {"check":"length", "id":"ip_DnNo", "minLength":1, "maxLength":50, "msgLength":"내선번호를 입력하세요."}
							,{"check":"length", "id":"ip_FindSystemId", "minLength":1, "maxLength":50, "msgLength":"시스템을 입력하세요."}
							,{"check":"length", "id":"ip_FindProcessId", "minLength":1, "maxLength":50, "msgLength":"프로세스를 입력하세요."}
						]
				};
				
				if (argoValidator(aValidate) != true) return;
				
				var sDn  = parseInt($("#ip_DnNo").val());
				var eDn  = parseInt($("#ip_EDnNo").val());
				var phIp = $("#ip_PhoneIp").val();
				
				if(phIp == null || phIp == ""){
	
					phIp = "0.0.0." + $("#ip_DnNo").val() + "";
				}
				
				var dnTotCnt = eDn - sDn ;
				var phIpEnd  = phIp.split('.');
				var phIpNum  = parseInt(phIpEnd[3]);
				if(sDn >= eDn){
					argoAlert("시작값이 종료값보다 크거나 같을수 없습니다.!!");
					return;
				}
				
				if($("#ip_EDnNo").val() == ""){
					
					
					$("#ip_PhoneIp").val(phIp);
					Resultdata = argoJsonUpdate("userTel", "setUserTelNoInsert", "ip_", {"cudMode":cudMode});
					workLog = '[내선번호:' + $("#ip_DnNo").val() + '] 등록';
				}else{
					for(var i = 0 ; i <= dnTotCnt ; i++){
						$("#ip_DnNo").val(sDn+i);
						var phoneIp = phIpEnd[0] + "." + phIpEnd[1] + "." + phIpEnd[2] + "." + Number(phIpNum+i);
						
						var param = {"phoneIp" : phoneIp };
						
						$("#ip_PhoneIp").val(phoneIp);
						Resultdata = argoJsonUpdate("userTel", "setUserTelNoInsert", "ip_", {"cudMode":cudMode});
						workLog = '[내선번호(멀티):' + $("#ip_DnNo").val() + '] 등록';
						
					}
				}	
			}else{
				aValidate = {
					rows:[ 
							{"check":"length", "id":"ip_PhoneIp", "minLength":1, "maxLength":50, "msgLength":"전화기IP(IVR Port)를 입력하세요."}
						]
				};
					
				if (argoValidator(aValidate) != true) return;
				
				Resultdata = argoJsonUpdate("userTel", "setUserTelNoUpdate", "ip_", {"cudMode":cudMode});
				workLog = '[내선번호:' + argoGetValue('ip_DnNo') + '] 수정';
			}
	
		    if(Resultdata.isOk()) {	
			   	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId2
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
			}else {
			   	argoAlert("저장에 실패하였습니다");	 
			}
		} catch (e) {
			console.log(e);
		}
	}
	function lpad(str, length){
		
		str = "0000000"+str;
		str = str.slice(-1*length);
		return str;
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
                    </span>               
                </div>
                <div class="input_area">
                
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158px;">
                            <col width="">
                        	<col width="158px;">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr style="height:50px;">
                        		<th>내선번호<span class="point">*</span></th>
                                <td>
                           			<input type="text" name="ip_DnNo" id="ip_DnNo" style="width: 85px" class="mr10 onlyNum" />~ &nbsp; 
                           			<input type="text" name="ip_EDnNo" id="ip_EDnNo" style="width: 85px" class="mr10 onlyNum" />
                                </td>
                            	<th>
                            		<input type='radio' name='ip_PhoneIpKind'  style="margin-top: -1px; vertical-align: middle;" value='ip'  checked="checked"/>전화기IP<br>
                            		<input type='radio' name='ip_PhoneIpKind'  style="margin-top: -1px; vertical-align: middle;" value='port' />IVR Port
                            	</th>
                                <td>
                                	<input type="text" name="ip_PhoneIp" id="ip_PhoneIp" style="width:200px" class="mr10"  />
									<!-- <input style="width:0px;" type="text" name="ip_Org_phoneIp" style="width: 50%"	class="mr10"  /> -->
                                </td>
                            </tr>
                            <tr>
                            	<th>시스템<span class="point">*</span></th>
                                <td>
                                	<select id="ip_FindSystemId" name="ip_FindSystemId" style="width:200px;" class="list_box"> </select>
								</td>
								<th>프로세스<span class="point">*</span></th>
                                <td>
                                	 <select id="ip_FindProcessId" name="ip_FindProcessId" style="width:200px;" class="list_box"> </select>
                                </td>
                            </tr>
                            <tr>
                                <th>CTI_ID</th>
                                <td>
                                	<input type="text" name="ip_DnNoRef" style="width: 200px" class="mr10"  />
                                	<!-- <input style="width:0px;" type="text" name="ip_Org_dnNoRef" style="width: 200px"	class="mr10"  /> -->
                                </td>
                                <th>사용여부</th>
                                <td>
                                	<span> <label> <input type="radio" name="ip_UseFlag" id="ip_UseFlagY" value="0" checked/> </label></span>예 
									<span> <label> <input type="radio" name="ip_UseFlag" id="ip_UseFlagN" value="1" /> </label></span>아니요
                                </td>
							</tr>
                            <tr id="hien1">
                            	<th>그룹</th>
                                <td>
									 <select id="ip_FindGroupId" name="ip_FindGroupId" style="width:200px;" class="list_box"></select>
								</td>
								<th>상담사ID</th>
								<td>
									<select id="ip_FindUserId" name="ip_FindUserId" style="width:200px;" class="list_box"></select>
	                            	<input type="hidden" id="ip_InsId" name="ip_InsId" />
	                            	<input type="hidden" id="ip_UptId" name="ip_UptId" />
	                            	<input type="hidden" id="ip_TenantId" name="ip_TenantId" />
                                </td> 
                            </tr>
                            <!-- 
                            <tr id="hien2">
                            	<th>상태코드</th>
                                <td>
									<input type="text" name="ip_DnStatusName" style="width: 50%" class="mr10"  readonly />
								</td>
								<th>최종변격시각</th>
                                <td>
									<input type="text" name="ip_LastUptDate" style="width: 50%" class="mr10"  readonly />
								</td>
                            </tr>
                             -->
                        </tbody>
                    </table>
                </div>           
            </div>            
        </section>
    </div>
</body>

</html>
