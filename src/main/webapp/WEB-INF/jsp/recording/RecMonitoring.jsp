
<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript">
	var tmpNextTime ;
	var prevNextTime;
</script>
<script type="text/javascript" src="<c:url value='/scripts/velocejs/realTimePlayer.js'/>"></script>

<script>

	
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp    	= loginInfo.SVCCOMMONID.rows.workIp;
	var controlAuth = loginInfo.SVCCOMMONID.rows.controlAuth;
	var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
	var playerKind	= loginInfo.SVCCOMMONID.rows.playerKind;
	var realPlayKind = loginInfo.SVCCOMMONID.rows.realPlayKind;
	var workMenu  = "모니터링";
	var workLog   = "";
	var isUseRecReason;
	
	var dataArray 	= new Array();
	var layerVal  	= new Array();
	var arrIpList 	= new Array();	
	
	$(document).ready(function() {
		

		if(controlAuth == null){
			controlAuth = "";
		}
		
		fnInitCtrl();
		fnParamSetting();
		fnInitGrid();
		fnSearchList();
		getConfigValue();
	});
	
	var fvKeyId ;
	
	function getConfigValue(){
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_REC_REASON"}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						isUseRecReason = data.getRows()['code'];
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	} 

	function fn_popClose(){
		rStop();
	}
	
	let player = new WavPlayer();
	var intervalTime ;
	var playStatus = "W";
	function rPlay(){

		prevNextTime = 0;

		// var promise	= player.play('http://'+gPopupOptions.mrsIp+':8181/play?agentDn='+gPopupOptions.agentDn+'&tenantId='+gPopupOptions.tenantId);
		// if (promise !== undefined)
		// {
		// 	promise.catch (error =>
		// 	{
		// 		argoAlert("실시간 청취를 할 수 없습니다.<br/>RTL PROCESS를 확인하세요.");
		// 		return;
		// 	});
		//
		// }
		
		
		$(document).ready(function ()  {
			
		   intervalTime = setInterval(function(){
		       if(tmpNextTime == prevNextTime){
		    	   
		    	   playStatus = "W";
		    	   
		       }else if (prevNextTime == 0 || prevNextTime == "undefined"){
					playStatus	= "CW";	    	   
		    	   
		       }else{
		    	   playStatus = "C";
		       }
			    prevNextTime= tmpNextTime;
		    },1500);
		});
		$(".btn_popClose").attr("onclick","javascript:fn_popClose();");
		
	}
	
	function rStop(){
		clearInterval(intervalTime);
		player.stop();
	}

	//페이지 재 로드시 파라미터 세팅
	function fnParamSetting(){
		var paramText;
		paramText = parent.$("#RecMonitoringF").val().split("||");
		
		if(paramText.length > 1){
			var paramSet;
					
			for (var i = 0; i < paramText.length; i++) {
				paramSet = paramText[i].split("::")
				$("#" + paramSet[0]).val(paramSet[1]);
				
				if(paramSet[0] == "s_FindTenantId"){
					// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					//argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					fnGroupCbChange("s_FindGroupId")
				}else if(paramSet[0] == "s_FindSystemId"){
					if(paramSet[1] != ""){
						argoCbCreate("s_FindProcessId", "comboBoxCode", "getProcessList", {findSystemId:$('#s_FindSystemId option:selected').val(), FindProcessName:"MRU"}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					}
				}else if(paramSet[0] == "s_FindStatusWait" || paramSet[0] == "s_FindStatusRec" || paramSet[0] == "s_FindLogin" || paramSet[0] == "s_FindLogout"){
					if(paramSet[1] == "true"){
						$("#"+paramSet[0]).prop("checked", true);
					}else{
						$("#"+paramSet[0]).prop("checked", false);
					}
				}
			}
		}
	}

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			//if($('#s_FindTenantId option:selected').val() == ''){
				// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				//argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			//	argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId, controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			//}else{
				// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			//	argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			//}
			
			argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			fnGroupCbChange("s_FindGroupId")
		} else if (kind == "system") {
			if($('#s_FindSystemId option:selected').val() == ''){
				$("#s_FindProcessId").find("option").remove();
			}else{
				argoCbCreate("s_FindProcessId", "comboBoxCode", "getProcessList", {findSystemId:$('#s_FindSystemId option:selected').val(), FindProcessName:"MRU"}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		} else if (kind == "groupNone") {
			if($('#s_FindGroupId option:selected').val() == ''){
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		}
	}
	
	function fnInitCtrl(){		

		$('.timepicker.rec').timeSelect({use_sec:true});		
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		//argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId, controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindSystemId", "comboBoxCode", "getMruVssSystemList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindMarkKind", "comboBoxCode", "getMarkCodeList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnGroupCbChange("s_FindGroupId")
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
		
		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
	
		$("#s_FindTenantId").change(function() {	fnSetSubCb('tenant'); 	});
		$("#s_FindGroupId").change(function() {	 	fnSetSubCb('group'); 	});
		$("#s_FindSystemId").change(function() {	fnSetSubCb('system'); 	});
		
		$("#autoRefresh").change(function()	{	 	
			if($("input:checkbox[id='autoRefresh']").is(":checked")){
				var delayTime = $("#refreshValue option:selected").val();	
				playInter("Y", delayTime);
			}
		});

		$("#btnSearch").click(function(){ //조회
			fnSearchList();			
		});
		
		
		$("#btnAdd").click(function(){
			fvKeyId = ""; 
			gPopupOptions = {cudMode:"I"} ;   	
		 	argoPopupWindow('시스템그룹등록', 'SysInfoPopAddF.do', '680', '345');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});	
		
		$("#btnAddAll").click(function(){
			
		});	

		$("#btnReset").click(function(){
			$('#s_FindKey option[value=""]').prop('selected', true);
			$('#s_FindSysGroupId option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
		});
				
		$('.clickSearch').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
		});
		
		//Agent시 검색조건 disabled
		if(grantId == "Agent"){
			// $('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
			$('#s_FindUserNameText').val(userId);
			$('#s_FindGroupId').attr("disabled", true);
			$('#s_FindUserNameText').attr("disabled", true);
			$('#s_FindDnText').attr("disabled", true);
			$('#s_FindSystemId').attr("disabled", true);
			$('#s_FindProcessId').attr("disabled", true);
			$('#s_FindStatusWait').attr("disabled", true);
			$('#s_FindStatusRec').attr("disabled", true);
			$('#s_FindLogin').attr("disabled", true);
			$('#s_FindLogout').attr("disabled", true);
		}
		
		$("#s_FindSort").change(function(){
			fnSearchList();
		});
		
		
		
	}

	function getTimeStamp() {
	    var d = new Date();
	    var date = leadingZeros(d.getFullYear(), 4) + '-' + leadingZeros(d.getMonth() + 1, 2) + '-' + leadingZeros(d.getDate(), 2) + ' ';
	    var time = leadingZeros(d.getHours(), 2) + ':' + leadingZeros(d.getMinutes(), 2) + ':' + leadingZeros(d.getSeconds(), 2);

	    return date + " / " + time;
	}
	
	function getTimeStamp2() {
	    var d = new Date();
	    var date = leadingZeros(d.getFullYear(), 4) + leadingZeros(d.getMonth() + 1, 2) + leadingZeros(d.getDate(), 2);
	    var time = leadingZeros(d.getHours(), 2) + leadingZeros(d.getMinutes(), 2) + leadingZeros(d.getSeconds(), 2);

	    return date + time;
	}
	
	function leadingZeros(n, digits) {
	    var zero = '';
	    n = n.toString();

	    if (n.length < digits) {
	        for (i = 0; i < digits - n.length; i++)
	            zero += '0';
	    }
	    return zero + n;
	}
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        columns: [  
			           	 { field: 'dnNo', 			caption: '내선', 		size: '45px', attr: 'align=center' }
			           	,{ field: 'groupName', 		caption: '그룹명', 	size:'100px', attr: 'align=center' }
			           	,{ field: 'userId', 		caption: '상담사ID',	size: '80px', attr: 'align=center' }
			           	,{ field: 'userName', 		caption: '상담사명', 	size: '60px', attr: 'align=center' }
			           	,{ field: 'dnNo', 			caption: '내선', 		size: '45px', attr: 'align=center' }
			           	,{ field: 'dnStatus', 		caption: '상태', 		size: '45px', attr: 'align=center' }
			           	,{ field: 'dnStatusName', 	caption: '상태', 		size: '45px', attr: 'align=center' }
			           	,{ field: 'agentStatus', 	caption: '로그인상태',	size: '45px', attr: 'align=center' }
			           	,{ field: 'custTel', 		caption: '전화번호', 	size: '90px', attr: 'align=center' }
			           	,{ field: 'lastUptDate',	caption: '변경시각', 	size:'150px', attr: 'align=center' }
			           	,{ field: 'elapsedTime',	caption: '경과시간', 	size:'120px', attr: 'align=center' }
			           	,{ field: 'systemId', 		caption: '시스템ID', 	size: '90px', attr: 'align=center' }
			           	,{ field: 'systemName',		caption: '시스템명', 	size: '90px', attr: 'align=center' }
			           	,{ field: 'processId', 		caption: '프로세스ID', 	size: '90px', attr: 'align=center' }
			           	,{ field: 'processName', 	caption: '프로세스명', 	size: '90px', attr: 'align=center' }
			           	,{ field: 'diffTime', 		caption: '최종시간', 	size: '90px', attr: 'align=center' }
	        ],
	        records: dataArray
	    });
	}
	
	
	function fnSearchList(){
		$("#s_FindStatusWait").change(function() {
		    if(this.checked) {
		    	$('#s_FindLogin.checkbox')[0].checked=true;
		    	$('#s_FindLogout.checkbox')[0].checked=false;
		    }
		});
		
		$("#s_FindLogout").change(function() {
			
			
		    if(this.checked) {
		    	//if(!$("#s_FindStatusRec").is(':checked'))
		    	//{	
			    	$('#s_FindStatusWait.checkbox')[0].checked=false;
			    	$('#s_FindLogin.checkbox')[0].checked=false;
		    	//}
		    }
		});
		
		
		
		if($("#s_FindStatusWait").is(':checked'))
		{
			$('#s_FindLogin.checkbox')[0].checked=true;
	    	$('#s_FindLogout.checkbox')[0].checked=false;
	    }
		
		//페이지 리로드시 기존 파라미터 세팅 start
		var param01 = $("#s_FindTenantId").val();
		var param02 = $('#s_FindGroupId').val();
		var param03 = $('#s_FindUserNameText').val();
		var param04 = $('#s_FindDnText').val();
		var param05 = $('#s_FindSystemId').val();
		var param06 = $('#s_FindProcessId').val();
		var param07 = $('#s_CallFrmTm').val();
		var param08 = $('#s_CallEndTm').val();
		var param09 = $('#s_FindStatusWait').is(':checked');
		var param10 = $('#s_FindStatusRec').is(':checked');
		var param11 = $('#s_FindLogin').is(':checked');
		var param12 = $('#s_FindLogout').is(':checked');
		
		var pageParam = 's_FindTenantId::'		+ param01
					+ '||s_FindGroupId::'		+ param02
					+ '||s_FindUserNameText::'	+ param03
					+ '||s_FindDnText::'		+ param04
					+ '||s_FindSystemId::'		+ param05
					+ '||s_FindProcessId::'		+ param06
					+ '||s_CallFrmTm::'			+ param07
					+ '||s_CallEndTm::'			+ param08
					+ '||s_FindStatusWait::'	+ param09
					+ '||s_FindStatusRec::'		+ param10
					+ '||s_FindLogin::'			+ param11
					+ '||s_FindLogout::'		+ param12;
		parent.$("#RecMonitoringF").val(pageParam);
		//페이지 리로드시 기존 파라미터 세팅 end
		
		$("#s_FindUserNameText").val(jQuery.trim($("#s_FindUserNameText").val()));	//사용자 공백제거
		$("#s_FindDnText").val(jQuery.trim($("#s_FindDnText").val()));				//내선 공백제거

		$("#loginSt_01").text("0");
		$("#loginSt_99").text("0");
		$("#dnStatus_01").text("0");
		$("#dnStatus_10").text("0");
		$("#etCount_00").text("0");
		$("#etCount_05").text("0");
		$("#etCount_10").text("0");
		
		argoJsonSearchList('recSearch', 'getRecMonitoringList', 's_', {userId:userId, controlAuth:controlAuth, grantId:grantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){ 
						dataArray = [];
						$.each(data.getRows(), function( index, row ) {
							
							gridObject = {  
											  "recid" 			: index+1
											, "dnNo" 			: row.dnNo
											, "groupName" 		: row.groupName
											, "userId" 			: row.userId
											, "userName" 		: row.userName
											, "custTel" 		: row.custTel
											, "dnStatus" 		: row.dnStatus
											, "dnStatusName"	: row.dnStatusName
											, "agentStatus" 	: row.agentStatus
											, "lastUptDate" 	: row.lastUptDate
											, "elapsedTime" 	: row.elapsedTime
											, "systemId" 		: row.systemId
											, "systemName" 		: row.systemName
											, "processId" 		: row.processId
											, "processName" 	: row.processName
											, "phoneIp" 		: row.phoneIp
											, "userIp" 			: row.userIp
											, "diffTime" 		: row.diffTime
											, "recCustTel" 		: row.recCustTel
											, "rtFlag" 			: row.rtFlag
											, "rtUserName" 		: row.rtUserName
											, "mediaKind" 		: row.mediaKind
											, "rtSystemId" 		: row.rtSystemId
											, "rtProcessId" 	: row.rtProcessId
										};
										
							dataArray.push(gridObject);
						});
						w2ui['grid'].add(dataArray);
						
						fnSetData(dataArray);
					}else{
						$("#data_List").empty();
					}					
				}	
			} catch(e) {
				console.log(e);			
			}
			
			workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
			+ ' | GrantId:' + grantId + '] 조회';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
				tenantId : tenantId,
				userId : userId,
				actionClass : "action_class",
				actionCode : "W",
				workIp : workIp,
				workMenu : workMenu,
				workLog : workLog
	});
		});
	}
	
	function fnSetData(data){

		var totCnt = data.length;
		var rowCnt = 0;
		var lastRow = 0;

		if(totCnt > 0){
			lastRow = totCnt % 10;
			
			if(lastRow == 0){
				rowCnt = Math.floor(totCnt / 10);
			}else{
				rowCnt = Math.floor(totCnt / 10) + 1;
			}
		}
		
		var startNum  = 0;
		var endNum    = 0;
		var loginCnt  = 0;
		var logoutCnt = 0;
		var dnStaCnt  = 0;
		var dnRecCnt  = 0;
		var diffTime  = 0;
		var standard1 = '<spring:eval expression="@code['Globals.monitoring.standard1']"/>';
		var standard2 = '<spring:eval expression="@code['Globals.monitoring.standard2']"/>';
		var etCnt_00  = 0;
		var etCnt_05  = 0;
		var etCnt_10  = 0;
		var strName   = '';
		
		var objHtml_0 = '';
		var objHtml_1 = '';
		var objHtml_2 = '';
		var objHtml_3 = '';
		var objHtml_4 = '';
		var objHtml_5 = '';
		
		$(".resultData").remove();
		
		for(var i=0; rowCnt > i; i++){
			
			startNum = (i * 10) + 1;
			endNum = (i * 10) + 10;

			objHtml_1 = '<tbody class="resultData"><tr><td rowspan="4" width="10%">' + startNum + ' ~ ' + endNum + '</td>';
			objHtml_3 = '</tr><tr>';
			objHtml_4 = '</tr><tr>';
			objHtml_5 = '</tr><tr>';

			if(rowCnt == i + 1){
				if(lastRow == 0){
					endNum = i * 10 + 10;
				}else{
					endNum = i * 10 + lastRow;
				}
			}
			
			var imageName;
			
			$.each(data,function(index, row) {

				//strName = row.userName.substr(0, 3);
				strName = row.userName;
				
				if(row.userName == null || row.userName == ""){
					strName = "";
				}else if(row.userName.length > 3){
					
					strName = row.userName;
					//.substr(0, 3);
					//console.log(strName);
				}
				
				if(index >= startNum - 1 && index < endNum){
					diffTime = row.diffTime;
					
					objHtml_2 += '<td rowspan="2" width="4%" ondblclick="RealTimePlay(' + index + ',event);" onmouseover="openPopLay(' + index + ',event);" onmouseout="closePopLay();">';
					
					if(row.dnStatus == "01"){
						objHtml_2 += '<img src="../images/icons/img_rec_01.gif" style="cursor:pointer"></td>';
						
					}else if(row.dnStatus == "10"){
// 						if(row.diffTime <= 5){
						if(row.diffTime < standard1){
							if(row.rtFlag == "1" && row.rtUserName) {
								objHtml_2 += '<img src="../images/icons/img_rec15_10.gif" style="cursor:pointer"></td>';
							} else {
								objHtml_2 += '<img src="../images/icons/img_rec_10.gif" style="cursor:pointer"></td>';
							}
							etCnt_00++;
// 						}else if(5 < row.diffTime && row.diffTime <= 10){
						}else if(standard1 <= row.diffTime && row.diffTime < standard2){
							if(row.rtFlag == "1" && row.rtUserName) {
								objHtml_2 += '<img src="../images/icons/img_rec15_10.gif" style="cursor:pointer"></td>';
							} else {
								objHtml_2 += '<img src="../images/icons/img_rec05_10.gif" style="cursor:pointer"></td>';
							}
							etCnt_05++;
// 						}else if(10 < row.diffTime){
						}else if(standard2 <= row.diffTime){
							if(row.rtFlag == "1" && row.rtUserName) {
								objHtml_2 += '<img src="../images/icons/img_rec15_10.gif" style="cursor:pointer"></td>';
							} else {
								objHtml_2 += '<img src="../images/icons/img_rec10_10.gif" style="cursor:pointer"></td>';
							}
							etCnt_10++;
						}else{
							if(row.rtFlag == "1" && row.rtUserName) {
								objHtml_2 += '<img src="../images/icons/img_rec15_10.gif" style="cursor:pointer"></td>';
							} else {
								objHtml_2 += '<img src="../images/icons/img_rec_01.gif" style="cursor:pointer"></td>';
							}
						}
						dnRecCnt++;
					}

					if(row.agentStatus == "01"){
						objHtml_2 += '<td align="center" width="5%" class="cell_login_txt">[' + row.dnNo + ']</td>';
						objHtml_3 += '<td align="center" width="5%" class="cell_login_txt">' + strName + '</td>';
						loginCnt++;
						if(row.dnStatus == "01")
						{	
							dnStaCnt++;
						}
					}else if(row.agentStatus == "99"){
						objHtml_2 += '<td align="center" width="5%">[' + row.dnNo + ']</td>';
						objHtml_3 += '<td align="center" width="5%">' + strName + '</td>';
						logoutCnt++;
						//dnStaCnt--;
					}else{
						objHtml_2 += '<td align="center" width="5%">[' + row.dnNo + ']</td>';
						objHtml_3 += '<td align="center" width="5%">' + strName + '</td>';
						logoutCnt++;
						//dnStaCnt--;
					}
					
					if(row.dnStatus == "10"){
						objHtml_4 += '<td colspan="2" align="center" width="9%">' + fnSecondsConv(row.elapsedTime) + '</td>';
						objHtml_5 += '<td colspan="2" align="center" width="9%">' + argoNullToSpace(row.recCustTel) + '</td>';
					} else {
						if(row.agentStatus == '01') {
							objHtml_4 += '<td colspan="2" align="center" width="9%">' + fnSecondsConv(row.elapsedTime) + '</td>';
						} else {
							objHtml_4 += '<td colspan="2" align="center" width="9%"></td>';
						}
						objHtml_5 += '<td colspan="2" align="center" width="9%"></td>';
					}
					
					if(totCnt == index+1){
						if(lastRow > 0){
							for(var k=0; 10 - lastRow > k; k++){
								objHtml_2 += '<td rowspan="2" width="4%"></td>';
								objHtml_2 += '<td align="center" width="5%"></td>';
								objHtml_3 += '<td align="center" width="5%"></td>';
								objHtml_4 += '<td colspan="2" align="center" width="9%"></td>';
								objHtml_5 += '<td colspan="2" align="center" width="9%"></td>';
							}
						}
					}
				}
			});

			objHtml_0 += objHtml_1 + objHtml_2 + objHtml_3 + objHtml_5 + objHtml_4 + '</tr></tbody>';
			
			objHtml_2 = '';
			objHtml_3 = '';
			objHtml_4 = '';
			objHtml_5 = '';
		}
		
		$("#data_List").append(objHtml_0);
		$("#loginSt_01").text(loginCnt);
		$("#loginSt_99").text(logoutCnt);
		$("#dnStatus_01").text(dnStaCnt);
		$("#dnStatus_10").text(dnRecCnt);
		$("#etCount_00").text(etCnt_00);
		$("#etCount_05").text(etCnt_05);
		$("#etCount_10").text(etCnt_10);
		
		$("#updateTime").text(getTimeStamp());
		
		if($("input:checkbox[id='autoRefresh']").is(":checked")){
			var delayTime = $("#refreshValue option:selected").val();	
			playInter("Y", delayTime);
		}else{
			playInter("N");
		}
	}
	
	var timer
	
	function playInter(playFlag, delay){
		
		if(playFlag == "Y"){
			clearInterval(timer);
			timer = setInterval("fnSearchList();", delay);
		}else{
			clearInterval(timer);
		}
	}

	function openPopLay(idx, event) {
		
    	var row = dataArray[idx];

    	if(row.recid >= 0) {
			var loginName = "";

			if(row.agentStatus == "01"){
				loginName = "로그인";
			}else{
				loginName = "로그아웃"
			}
			
			$("#userNm").text(" " + row.userName + " / [ " + row.dnNo + " ]");
			$("#userId").text(row.userId );			
			$("#groupNm").text(row.groupName);		
			$("#userIp").text(row.userIp);			
			$("#telIp").text(row.phoneIp);			
			$("#statusNm").text(loginName);			
			$("#lastUpdate").text(row.lastUptDate);	
			$("#systemNm").text(row.systemName);	
// 			$("#processNm").text(row.processName);
			$("#rtUserName").text(argoNullToSpace(row.rtUserName));
			
			var divTop = event.pageY - 350;
			var divLeft = event.pageX - 145;
			
			$("#popLay").css({
				"top" 		: divTop,
				"left" 		: divLeft,
				"position" 	: "absolute",
				"z-index" 	: 2
			}).show();
    	}
	}
	
	function RealTimePlay(idx, event){
		if(isUseRecReason == "1"){
			var row 	= dataArray[idx];
			
			gPopupOptions = {pRowIndex:row,"cudMode":"1" , pTenantId : $("#s_FindTenantId").val(),"idx":idx,"event":event};   	
	 		argoPopupWindow('청취사유등록', 'RecSearchRecLogPopAddF.do', '470', '370');	
		}else{
			RealTimePlayCallBack(idx, event);
		}
			
	}
	
	function RealTimePlayCallBack(idx, event) {
		var MrsCnt  = 0;
    	var row 	= dataArray[idx];
		var mrsIp= "";
		
		var browserType =  window.navigator.userAgent.toLowerCase();
		if (realPlayKind == "0" &&(browserType.indexOf("chrome") > -1)) {
			gPopupOptions = {agentId	: row.userId, agentDn	: row.dnNo , mrsIp: "100.100.107.21", agentName : row.userName,tenantId	: tenantId} ; 
			argoPopupWindow('실시간감청', 'RealTimePlayF.do', '594', '284');

			return;
		}
    	
    	if(row.recid >=0 ) {
			var logTenantId 	= tenantId;
			var logWorkerId 	= userId;
			var logWorkIp 		= workIp;
			var logRealtimeFlag = "1";	//실시간청취
			var logListeningKey = "";
			var logUserId 		= "";
			var logDnNo 		= "";
			var logRecKey 		= "";
			var logUserIp 		= "";
			var ws;
			var ws_data= "";
			var logRtSystemId = row.rtSystemId == undefined ? row.systemId : row.rtSystemId;
			var logRtProcessId = row.rtProcessId == undefined ? row.processId : row.rtProcessId;
			
			argoJsonSearchList('comboBoxCode', 'getDnMrsIpList_new', '', {"findSystemId":logRtSystemId, "findProcessId":logRtProcessId}, function (data, textStatus, jqXHR){
				try{
					arrIpList = [];

					if(data.isOk()){
						if (data.getRows() != ""){ 
							$.each(data.getRows(), function( index, row ) {
								if(vlcOPT.VLC_NAT_IP=="1") {
									arrIpList[index] = row.codeNm;
								} else {
									arrIpList[index] = row.code;
								}
								MrsCnt += 1;								
								
							});
							
							var mrs_ip1 = arrIpList[0] == undefined ? "0" : arrIpList[0];
							var mrs_ip2 = arrIpList[1] == undefined ? "0" : arrIpList[1];
							
// 							ws_data="cmd=3&mrs_ip1="+arrIpList[0]+"&mrs_port1="+(row.processName == "VSS" ? "7620" : "7600")
// 												+"&mrs_ip2="+arrIpList[1]+"&mrs_port2="+(row.processName == "VSS" ? "7620" : "7600")
// 												+"&scr_ip="+(row.mediaKind=="2"?row.userIp:"0.0.0.0")+"&scr_port=5009&agent_id="+row.userId+"&agent_dn="+row.dnNo;
							ws_data="cmd=3&mrs_ip1="+mrs_ip1+"&mrs_port1="+(row.processName == "VSS" ? "7620" : "7620")
												+"&mrs_ip2="+mrs_ip2+"&mrs_port2="+(row.processName == "VSS" ? "7620" : "7620")
												+"&scr_ip="+(row.mediaKind=="2"?row.userIp:"0.0.0.0")+"&scr_port=5009&agent_id="+row.userId+"&agent_dn="+row.dnNo;
							
							ws = new WebSocket("ws://localhost:8282");
					
							ws.onopen = function(e){
								console.log(e);
								ws.send( ws_data );
							};
					
							ws.onclose = function(e){
								console.log(e);
							};
				
							// 실시간 청취 클릭시 감청자 정보를 TB_MNG_USERTELNO에 업데이트
							argoJsonUpdate("recSearch", "setRtUserIdUpdate", "ip_", {tenantId : $("#s_FindTenantId").val(), rtUserName : loginInfo.SVCCOMMONID.rows.userName, dnNo : row.dnNo});
							
							//청취로그  start
							logListeningKey = getTimeStamp2();
							logUserId 		= row.userId;
							logDnNo 		= row.dnNo;
							//logRecKey 		= getTimeStamp2();
							logUserIp		= row.phoneIp;
							if(isUseRecReason != "1"){
								argoJsonUpdate("recInfo", "setRecLogRealInsert", "", {"tenantId":logTenantId, "workerId":logWorkerId, "listeningKey":logListeningKey
										,"workerIp":logWorkIp, "userId":logUserId, "dnNo":logDnNo, "userIp":logUserIp, "realtimeFlag":logRealtimeFlag, "recKey":logRecKey});
							}
							//청취로그  end
							workLog = '[TenantId:'
								+ tenantId
								+ ' | UserId:' + userId
								+ ' | GrantId:'
								+ grantId
								+ '] 실시간 청취';
							
							argoJsonUpdate(
								"actionLog",
								"setActionLogInsert",
								"ip_",
								{
									tenantId : tenantId,
									userId : userId,
									actionClass : "action_class",
									actionCode : "W",
									workIp : workIp,
									workMenu : workMenu,
									workLog : workLog
								});
						}
					}
				} catch(e) {
					console.log(e);			
				}
			});			
			
			if (MrsCnt < 1) {
				//alert(arrIpList[0]);
				return;
			}
    	}
	}
	
	function closePopLay() {
		$("#popLay").hide();
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location">
        	<span class="location_home">HOME</span><span class="step">상태모니터링</span><strong class="step">모니터링</strong>
        </div>
        <section class="sub_contents">
			<div class="search_area row3" id="searchPanel">
				<div class="row" id="div_tenant">
					<ul class="search_terms">
						<li><strong class="title ml20">태넌트</strong>
							<select	id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select>
						</li>
						<li><strong class="title">정렬</strong> 
							<select	id="s_FindSort" name="s_FindSort" style="width: 140px;"	class="check_box">
								<option value="dn">내선번호</option>
								<option value="id">상담사ID</option>
								<option value="nm">상담사이름</option>
								<option value="st">상담사상태</option>
							</select>
						</li>
					</ul>
				</div>
				<div class="row" id="div_user">
					<ul class="search_terms">
						<li><strong class="title ml20">그룹</strong> 
							<select	id="s_FindGroupId" name="s_FindGroupId" style="width: 140px" class="list_box"></select>
						</li>
						<li><strong class="title">사용자</strong> 
							<input type="text" id="s_FindUserNameText" name="s_FindUserNameText" style="width: 140px" class="clickSearch"/>
						</li>
						<li><strong class="title">내선</strong> 
							<input type="text" id="s_FindDnText" name="s_FindDnText" style="width: 226px" class="clickSearch"/>
						</li>
						<li style="margin-top: 6px"><strong class="title">통화상태</strong> 
							<input type="checkbox"	class="checkbox" id="s_FindStatusWait" name="s_FindStatusWait"	data-defaultChecked=true value="01" checked>
							<label for="s_FindStatusWait" style="width: 100px">대기</label> 
							<span style="width: 100px">&nbsp;&nbsp;</span> 
							<input type="checkbox"	class="checkbox" id="s_FindStatusRec" name="s_FindStatusRec" data-defaultChecked=true value="10" checked>
							<label for="s_FindStatusRec">통화</label>
						</li>
					</ul>
				</div>
				<div class="row" id="div_system">
					<ul class="search_terms">
						<li><strong class="title ml20">시스템</strong> 
							<select	id="s_FindSystemId" name="s_FindSystemId" style="width: 140px;"	class="check_box"></select>
						</li>
						<li><strong class="title">프로세스</strong>
							<select id="s_FindProcessId" name="s_FindProcessId"	style="width: 140px;" class="list_box" title="프로세스에 해당하는 시스템을 먼저 선택하세요!"></select>
						</li>
						<li><strong class="title">경과시간</strong>
							<span class="timepicker rec" id="rec_time1">
								<input type="text" id="s_CallFrmTm" name="s_CallFrmTm" class="input_time" value="00:00:00">
								<a href="#" class="btn_time">시간 선택</a>
							</span>
							<span class="text_divide">~</span>
							<span class="timepicker rec"	id="rec_time2">
								<input type="text" id="s_CallEndTm"	name="s_CallEndTm" class="input_time" value="00:00:00">
								<a href="#" class="btn_time">시간 선택</a>
							</span>
						</li>
						<li style="margin-top: 6px">
							<strong	class="title">로그인상태</strong>
							<input type="checkbox"	class="checkbox" id="s_FindLogin" name="s_FindLogin" data-defaultChecked=true value="01" checked>
							<label for="s_FindLogin" style="width: 60px">로그인</label>
							<input type="checkbox" class="checkbox" id="s_FindLogout" name="s_FindLogout" data-defaultChecked=true value="99" checked>
							<label for="s_FindLogout">로그아웃</label>
						</li>
					</ul>
				</div>
						
			</div>
			<div class="btns_top">
                <div class="sub_l">
                	<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>
                	<img src="../images/icons/ico_refresh.gif">
	            	<select id="refreshValue" name="refreshValue" style="width:70px" class="list_box">
						<option value="5000">5 Sec</option>
						<option value="10000">10 Sec</option>
						<option value="20000">20 Sec</option>
						<option value="30000">30 Sec</option>
					</select>
					<input type="checkbox" id="autoRefresh" name="autoRefresh" checked>
					<label>Auto Refresh &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
					<img src="../images/icon_arrR.png">
					<label><strong>최근업데이트시간 : </strong></label><span id="updateTime"></span> 
                </div>  
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="input_area">
	            	<table class="input_table">
	            		<colgroup>
                        	<col width="8%">
                            <col width="15%">
                            <col width="8%">
                            <col width="15">
                            <col width="8%">
                            <col width="15%">
                            <col width="8%">
                            <col width="15%">
                            <col width="8%">
						</colgroup>
						<tbody>
							<tr>
								<td rowspan="2" align="center"><strong>요약</strong></td>
								<td align="center"><strong>로그인</strong></td>
								<td align="center"><span id="loginSt_01">0</span></td>
								<td align="center"><strong>로그아웃</strong></td>
								<td align="center"><span id="loginSt_99">0</span></td>
								<td align="center"><strong><img src="../images/icons/ico_01.gif"> 대기</strong></td>
								<td align="center"><span id="dnStatus_01">0</span></td>
								<td align="center"><strong><img src="../images/icons/ico_10.gif"> 녹음중</strong></td>
								<td align="center"><span id="dnStatus_10">0</span></td>
							</tr>
							<tr>
								<td colspan="2" align="center"><strong>경과시간</strong></td>
								<td align="center"><strong><spring:eval expression="@code['Globals.monitoring.standard1']"/>분 미만</strong></td>
								<td class="EtClass" align="center"><span id="etCount_00">0</span></td>
								<td align="center"><strong><spring:eval expression="@code['Globals.monitoring.standard2']"/>분 미만</strong></td>
								<td class="EtClass_05" align="center"><span id="etCount_05">0</span></td>
								<td align="center"><strong><spring:eval expression="@code['Globals.monitoring.standard2']"/>분 경과</strong></td>
								<td class="EtClass_10" align="center"><span id="etCount_10">0</span></td>
							</tr>
						</tbody>	
					</table>		
				</div>
				<div style="width: 100%; height: 20px;"></div>
				<div class="table_grid">		
					<div class="table_head">
						<table>
							<tbody>
								<tr>
									<th align="center" width="10%"><strong>구분</strong></th>
									<th colspan="2" align="center" width="9%"><strong>1</strong></th>
									<th colspan="2" align="center" width="9%"><strong>2</strong></th>
									<th colspan="2" align="center" width="9%"><strong>3</strong></th>
									<th colspan="2" align="center" width="9%"><strong>4</strong></th>
									<th colspan="2" align="center" width="9%"><strong>5</strong></th>
									<th colspan="2" align="center" width="9%"><strong>6</strong></th>
									<th colspan="2" align="center" width="9%"><strong>7</strong></th>
									<th colspan="2" align="center" width="9%"><strong>8</strong></th>
									<th colspan="2" align="center" width="9%"><strong>9</strong></th>
									<th colspan="2" align="center" width="9%"><strong>10</strong></th>
								</tr>
							</tbody>
						</table>
					</div>
					<div class="table_list">
						<table id="data_List">
                        	
						</table>
					</div>
				</div>
				<!-- <span id="popLay" style="position: absolute; display: none;"><div> -->
				<div id="popLay" style="display: none;">
					<table class="input_table2" style="font-size:8pt;">
						<colgroup>
							<col width="100">
		                   	<col width="100">
		             	</colgroup>
						<tbody>
		                	<tr><td colspan="2"><img src="../images/bg_photo.png"><strong>&nbsp;&nbsp;&nbsp;<span id="userNm"></span></strong></td></tr>
		                  	<tr><th>상담사ID</th><td><span id="userId"></span></td></tr>
		                    <tr><th>그룹</th><td><span id="groupNm"></span></td></tr>
		                    <tr><th>상담사IP</th><td><span id="userIp"></span></td></tr>
		                    <tr><th>전화기IP</th><td><span id="telIp"></span></td></tr>                         
		                    <tr><th>상태</th><td><span id="statusNm"></span></td></tr>
		                    <tr><th>최종변경시각</th><td><span id="lastUpdate"></span></td></tr>
		                    <tr><th>시스템명</th><td><span id="systemNm"></span></td></tr>
<!-- 							<tr><th>프로세스명</th><td><span id="processNm"></span></td></tr> -->
							<tr><th>감청자</th><td><span id="rtUserName"></span></td></tr>
						</tbody>
					</table>
				</div>
   				<!-- </span> -->
	        </div>
        </section>
    </div>
</body>

</html>