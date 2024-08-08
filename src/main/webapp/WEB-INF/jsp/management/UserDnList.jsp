<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<style>
	.ui-autocomplete
	{
		max-height: 100px;
		overflow-y: auto; /* prevent horizontal scrollbar */
		overflow-x: hidden;
	}
	/* IE 6 doesn't support max-height
	* we use height instead, but this forces the menu to always be this tall
	*/
	html .ui-autocomplete
	{
		height: 100px;
	}
</style>
<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	var workMenu 	= "내선번호관리";
	var workLog 	= "";
	var dataArray 	= new Array();
	
	$(document).ready(function() {
		
		if(controlAuth == null){
			controlAuth = "";
		}
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	var fvKeyId ; 

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			fnGroupCbChange("s_FindGroupId");
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
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value": ''});
		$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
	
		// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId, controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindSystemId", "comboBoxCode", "getMruSystemList", {} ,{"selectIndex":0, "text":'선택하세요!', "value":''});
		fnGroupCbChange("s_FindGroupId");
		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		if(grantId != "SuperAdmin" && grantId != "SystemAdmin"){
			$("#div_tenant").hide();
		}
	
		$("#s_FindTenantId").change(function(){		fnSetSubCb('tenant');	});
		$("#s_FindGroupId").change(function(){		fnSetSubCb('group');	});
		$("#s_FindSystemId").change(function(){	 	fnSetSubCb('system');	});

		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});
		
		
		$("#btnAdd").click(function(){
			fvKeyId = ""; 
			gPopupOptions = {cudMode:"I", tenantId:$('#s_FindTenantId option:selected').val()} ;   
			argoPopupWindow('내선번호정보등록', 'UserDnPopupEditF.do', '800', '300');
		});	
		
		$("#btnGubunAdd").click(function(){
			fvKeyId = ""; 
			gPopupOptions = {cudMode:"I", tenantId:$('#s_FindTenantId option:selected').val()} ;   
			argoPopupWindow('내선구분관리등록', 'UserDnTelGubunPopEditF.do', '900', '630');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});	
		
		/* $("#btnAddAll").click(function(){
			
		}); */
		
		$("#btnLive").click(function(){
			fnLiveApply();
		});

		$("#btnReset").click(function(){

			$('#s_FindGroupId option[value=""]').prop('selected', true);
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$("#s_FindProcessId").find("option").remove();
			argoSetValue("s_FindUserNameText", "");
			argoSetValue("s_FindDnText", "");
			argoSetValue("s_FindPhoneIp", "");
			
			argoSetValue("s_CallFrmTm", "00:00:00");
			argoSetValue("s_CallEndTm", "00:00:00");
			$("input:checkbox[id='s_FindLogin']").prop("checked", true);
			$("input:checkbox[id='s_FindLogout']").prop("checked", true);
			$("input:checkbox[id='s_FindStatusWait']").prop("checked", true);
			$("input:checkbox[id='s_FindStatusRec']").prop("checked", true);
			$("input:checkbox[id='s_FindStatusNone']").prop("checked", true);
			$('#s_FindTenantId option[value="'+tenantId+'"]').prop('selected', true);
			
			// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			fnGroupCbChange("s_FindGroupId");
		});
		
		$(".clickSearch").keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		
		
		$("#btnExcel").click(function() {
			
			var excelArray = new Array();
			argoJsonSearchList('userTel', 'getUserTelNoList', 's_', {	"iSPageNo" : 100000000 ,"iEPageNo" : 100000000, userId:userId, controlAuth:controlAuth, grantId:grantId}, function (data, textStatus, jqXHR){	
			try {
				if (data.isOk()) {
					var elapsedTime;
					var loginStatus;
					var useFlag;
					dataArray = [];
					
					$.each(data.getRows(), function( index, row ) {
						elapsedTime = fnSecondsConv(row.elapsedTime);
						
						if (row.agentStatus == "01")
							loginStatus = "로그인";
						else loginStatus = "로그아웃";
						
						if (row.useFlag == "0")
							useFlag = "O";
						else useFlag = "X"; 
						
						gObject = {	  "recid" 			: index
									, "dnNo" 			: row.dnNo
									, "phoneIp" 	   	: row.phoneIp
									, "groupId" 		: row.groupId
									, "groupName" 		: row.groupName
									, "userId" 			: row.userId
									, "userName" 		: row.userName
									, "custTel" 		: row.custTel
									, "dnStatus" 		: row.dnStatus
									, "dnStatusName"	: row.dnStatusName
									, "agentStatus" 	: loginStatus
									, "lastUptDate" 	: row.lastUptDate
									, "elapsedTime" 	: elapsedTime
									, "systemId" 		: row.systemId
									, "systemName" 		: row.systemName
									, "processId" 		: row.processId
									, "processName" 	: row.processName
									, "useFlag"			: useFlag
									, "dnNoRef" 		: row.dnNoRef
								};

							excelArray.push(gObject);
						});
		
						gPopupOptions = {
							"pRowIndex" : excelArray,
							"workMenu" : workMenu
						};
						
						argoPopupWindow(
								'Excel Export',
								gGlobal.ROOT_PATH
										+ '/common/VExcelExportF.do',
								'150', '40');
		
						workLog = 'Excel Export';
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
				} catch (e) {
					console.log(e);
				}
			});
		});
		
		//[input]사용자 자동검색 - start
		var dataList = "";
		/* var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId; */
		var authRank = loginInfo.SVCCOMMONID.rows.authRank;
		
		$('#s_FindUserNameText').autocomplete({
			source : function(request, response){
				argoJsonSearchList('recSearch', 'getRecUserInfo', '',{"tenantId":tenantId, "authRank":authRank, "srchKeyword":$('#s_FindUserNameText').val()}, function(data, textStatus, jqXHR){
					try {
						var strOption2 = "";
						if (data.isOk()) {
							
							function fnUserListBind (){
								response(
									$.map(data.getRows(), function(item){
										return{
											label : item.tenantName + " " + item.groupName + " " + item.userName+"("+item.userId+")" //테넌트네임, 그룹명, 사용자명(상담사ID)
					             ,value : item.userId		// 선택 시 input창에 표시되는 값
					             ,idx : item.SEQ // index
										};
									})
								);
							}
							fnUserListBind();
						}
					} catch (e) {
						console.log(e);
					}
				});
			}
			,focus : function(event, ui) { // 방향키로 자동완성단어 선택 가능하게 만들어줌	
					return false;
			}
			,minLength: 1// 최소 글자수
			,autoFocus : true // true == 첫 번째 항목에 자동으로 초점이 맞춰짐
			,delay: 100	//autocomplete 딜레이 시간(ms)
			//,select : function(evt, ui) { 
					//console.log(ui.item.label);
					//console.log(ui.item.idx);
			//} 
		});
		//[input]사용자 자동검색 - end
		
		
	}
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >=0 ) {
					gPopupOptions = {cudMode:'U', pRowIndex:record, tenantId:$('#s_FindTenantId option:selected').val()} ;   	
					argoPopupWindow('내선번호정보수정', 'UserDnPopupEditF.do', '800', '300');
				}
	        },	        
	        columns: [   { field: 'recid', 			caption: 'recid', 		size: '0%',		attr: 'align=center',	sortable: true }
			           	,{ field: 'dnNo', 			caption: '내선', 		size: '6%', 	attr: 'align=center' }
	            		,{ field: 'phoneIp', 	    caption: '전화기IP',  	size: '13%', 	attr: 'align=center',	sortable: true }
			           	,{ field: 'groupId', 		caption: '그룹ID',		size: '0%', 	attr: 'align=center' }
			           	,{ field: 'userId', 		caption: '상담사ID',	size: '9%', 	attr: 'align=center' }
			           	,{ field: 'dnGubun', 		caption: '구분명',	size: '9%', 	attr: 'align=center' }
			           	,{ field: 'userName', 		caption: '상담사명', 	size: '9%', 	attr: 'align=center' }
			           	,{ field: 'dnStatus', 		caption: '상태', 		size: '0%', 	attr: 'align=center' }
			           	,{ field: 'dnStatusName', 	caption: '통화상태', 	size: '8%', 	attr: 'align=center' }
			           	,{ field: 'agentStatus', 	caption: '로그인상태',	size: '8%', 	attr: 'align=center' }
			           	,{ field: 'custTel', 		caption: '전화번호', 	size: '0%', 	attr: 'align=center' }
			           	,{ field: 'elapsedTime',	caption: '경과시간', 	size: '10%', 	attr: 'align=right'  }
			           	,{ field: 'systemId', 		caption: '시스템ID', 	size: '0%', 	attr: 'align=center' }
			           	,{ field: 'systemName',		caption: '시스템명', 	size: '13%', 	attr: 'align=center' }
			           	,{ field: 'processId', 		caption: '프로세스ID', 	size: '0%', 	attr: 'align=center' }
			           	,{ field: 'processName', 	caption: '프로세스명', 	size: '10%', 	attr: 'align=center' }
			           	,{ field: 'useFlag', 		caption: '사용여부', 	size: '7%', 	attr: 'align=center' }
			           	,{ field: 'dnNoRef', 		caption: 'CTI', 		size: '7%', 	attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid', 'custTel', 'dnStatus', 'accessFlag','mainPage', 'loginCheckUse', 'loginCheckFrom', 'loginCheckTo', 'controlAuth', 'convertFlag', 'groupId', 'systemId', 'processId'); 
	}
	
	function fnSecondsConv(seconds){
		var pad = function(x) { 
			return (x < 10) ? "0" + x : x; 
		}
		
		return pad(parseInt(seconds / (60*60))) + ":" + pad(parseInt(seconds / 60 % 60)) + ":" + pad(seconds % 60);
	}
	 
	function fnSearchListCnt(){
		
		if ($("#s_FindStatusWait").prop("checked") == false && $("#s_FindStatusRec").prop("checked") == false && $("#s_FindStatusNone").prop("checked") == false) {
			argoAlert("통화 상태는 하나 이상 선택해야 합니다.");
			return;
		}
			
		if ($("#s_FindLogin").prop("checked") == false && $("#s_FindLogout").prop("checked") == false) {
			argoAlert("로그인 상태는 하나 이상 선택해야 합니다.");
			return;
		}
		
		argoJsonSearchOne('userTel', 'getUserTelNoCount', 's_', {userId:userId, controlAuth:controlAuth, grantId:grantId}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					$("#totCount").html(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
					
					w2ui.grid.lock('조회중', true);
				}
			} catch (e) {
				console.log(e);
			}
		});
	}	
	
	function fnSearchList(startRow, endRow){
		argoJsonSearchList('userTel', 'getUserTelNoList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow, userId:userId, controlAuth:controlAuth, grantId:grantId}, function (data, textStatus, jqXHR){		
		
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){ 
						var elapsedTime;
						var loginStatus;
						var useFlag;
						dataArray = [];
						
						$.each(data.getRows(), function( index, row ) {
							elapsedTime = fnSecondsConv(row.elapsedTime);
							
							if (row.agentStatus == "01")
								loginStatus = "로그인";
							else loginStatus = "로그아웃";
							
							if (row.useFlag == "0")
								useFlag = "O";
							else useFlag = "X"; 
							
							gridObject = {	  "recid" 			: index
											, "dnNo" 			: row.dnNo
											, "phoneIp" 	   	: row.phoneIp
											, "groupId" 		: row.groupId
											, "groupName" 		: row.groupName
											, "userId" 			: row.userId
											, "userName" 		: row.userName
											, "dnGubun"			: row.dnGubun
											, "custTel" 		: row.custTel
											, "dnStatus" 		: row.dnStatus
											, "dnStatusName"	: row.dnStatusName
											, "agentStatus" 	: loginStatus
											, "lastUptDate" 	: row.lastUptDate
											, "elapsedTime" 	: elapsedTime
											, "systemId" 		: row.systemId
											, "systemName" 		: row.systemName
											, "processId" 		: row.processId
											, "processName" 	: row.processName
											, "useFlag"			: useFlag
											, "dnNoRef" 		: row.dnNoRef
										};
										
							dataArray.push(gridObject);
							
						});
						w2ui['grid'].add(dataArray);
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
	
	function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
	function fnDeleteList(){
		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("삭제할 내선번호를 선택하세요"); 
		 		return ;
			}

			argoConfirm('선택한 내선번호 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				
				var multiService = new argoMultiService(fnCallbackDelete);
				var tenantId = $('#s_FindTenantId option:selected').val();
				
				$.each(arrChecked, function( index, value ) {
					var dnNo = w2ui['grid'].getCellValue(value, 1);
					var param = { 
									"tenantId" :  tenantId, 
									"dnNo"     :  dnNo
								};
					workLog = '[내선번호:' + dnNo + '] 삭제';
					multiService.argoDelete("userTel", "setUserTelNoDelete", "__", param);
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		}
	}	
	
	function fnLiveApply(){
		try{
			argoConfirm('내선번호를  실시간적용요청을 하시겠습니까?', function() {
// 				argoJsonSearchList('comboBoxCode', 'getOsuIpList', 's_', {"updateType":"1"}, function (data, textStatus, jqXHR){
// 					try{
// 						if(data.isOk()){
// 							if(data.getRows() != ""){
// 								$.each(data.getRows(), function( index, row ) {
// 									argoJsonSearchList('comboBoxCode', 'getMruProcessList', 's_', {"updateType":"1", "code":row.code, "codeNm":row.codeNm}, function (data, textStatus, jqXHR){
// 										try{
// 											if(data.isOk()){
// 											}
// 										} catch(e) {
// 											console.log(e);			
// 										}
// 									});
									
									
// 									/* VSS 데이터 전송*/
// 									argoJsonSearchList('comboBoxCode', 'getVssProcessList', 's_', {"updateType":"1", "code":row.code, "codeNm":row.codeNm}, function (data, textStatus, jqXHR){
// 										try{
// 											if(data.isOk()){
// 											}
// 										} catch(e) {
// 											console.log(e);			
// 										}
// 									});
// 								});
// 							}
// 						}
						
						argoJsonSearchList('comboBoxCode', 'getMruMruVSSIpList', 's_', {}, function (data, textStatus, jqXHR){
							$.each(data.getRows(), function( index, row ) {
								fnLiveApplyRequest(row.systemIp);
							});
						});
						
// 					} catch(e) {
// 						console.log(e);			
// 					}
// 				});
				
				workLog = ("[회사ID:" + tenantId + " | 사용자ID:" + userId + "] 실시간 적용 요청");
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			});
		}catch(e){
			console.log(e) ;	 
		}
	}

	function fnLiveApplyRequest(url){
		var param = {};
		param.url = "http://"+url+":7060/UpdateDnNo.do"
		param.paramDataType = "json";
		
		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			//async: false,
			data : JSON.stringify(param),
			contentType: "application/json; charset=utf-8",
			success : function(data) {
				console.log("success");
			},
			error : function(xhr, status, error) {
				console.log("error");
// 				$("#result").val(JSON.stringify(status, null, '\t') + "\r\n");
			}
		});
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location">
        	<span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">사용자관리</span><strong class="step">내선번호관리</strong>
        </div>
        <section class="sub_contents">
			<div class="search_area row4" id="searchPanel">
				<div class="row" id="div_tenant">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">태넌트</strong> 
							<select	id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
						</li>
					</ul>
				</div>
				<div class="row" id="div_user">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">그룹</strong> 
							<select id="s_FindGroupId" name="s_FindGroupId" style="width: 150px" class="list_box"></select>
						</li>
						<li>
							<strong class="title">사용자</strong> 
							<input type="text" id="s_FindUserNameText" name="s_FindUserNameText" style="width: 150px" class="clickSearch"/>
						</li>
						<li style="width: 385px; margin-top: 6px">
							<strong	class="title ml20">로그인상태</strong> 
							<input type="checkbox" class="checkbox" id="s_FindLogin" name="s_FindLogin" data-defaultChecked=true value="01" checked>
								<label for="s_FindLogin" style="width: 60px">로그인</label> 
							<input type="checkbox" class="checkbox" id="s_FindLogout" name="s_FindLogout" data-defaultChecked=true value="99" checked>
								<label for="s_FindLogout">로그아웃</label>
						</li>
					</ul>
				</div>
				<div class="row" id="div_dn">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">내선</strong> 
							<input type="text" id="s_FindDnText" name="s_FindDnText" style="width: 150px" class="clickSearch"/>
						</li>
						<li>
							<strong class="title">전화기 IP</strong> 
							<input type="text" id="s_FindPhoneIp" name="s_FindPhoneIp" style="width: 150px" class="clickSearch"/>
						</li>
						<li style="width: 385px; margin-top: 6px">
							<strong	class="title ml20">통화상태</strong> 
							<input type="checkbox" class="checkbox" id="s_FindStatusWait" name="s_FindStatusWait" data-defaultChecked=true value="01" checked>
								<label for="s_FindStatusWait" style="width: 60px">대기</label> 
							<span style="width: 100px">&nbsp;&nbsp;</span> 
							<input type="checkbox" class="checkbox" id="s_FindStatusRec" name="s_FindStatusRec"	data-defaultChecked=true value="10" checked>
								<label for="s_FindStatusRec">통화</label>
							<span style="width: 100px">&nbsp;&nbsp;</span> 	
							<input type="checkbox" class="checkbox" id="s_FindStatusNone" name="s_FindStatusNone" data-defaultChecked=true value="00" checked>
								<label for="s_FindStatusNone">미사용</label>
						</li>
					</ul>
				</div>
				<div class="row" id="div_system">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">시스템</strong> 
							<select	id="s_FindSystemId" name="s_FindSystemId" style="width: 150px;"	class="check_box"></select>
						</li>
						<li>
							<strong class="title">프로세스</strong>
							<select id="s_FindProcessId" name="s_FindProcessId"	style="width: 150px;" class="list_box" title="프로세스에 해당하는 시스템을 먼저 선택하세요!"></select>
						</li>
						<li>
							<strong class="title ml20">경과시간</strong> 
							<span class="timepicker rec" id="rec_time1">
								<input type="text" id="s_CallFrmTm" name="s_CallFrmTm" class="input_time" value="00:00:00">
								<a href="#" class="btn_time">시간 선택</a>
							</span>
							<span class="text_divide">~</span> 
							<span class="timepicker rec" id="rec_time2">
								<input type="text" id="s_CallEndTm" name="s_CallEndTm" class="input_time" value="00:00:00">
								<a href="#" class="btn_time">시간 선택</a>
							</span>
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
                <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
                <button type="button" id="btnGubunAdd" class="btn_m confirm">내선구분관리</button>
                <button type="button" id="btnLive" class="btn_m confirm">실시간적용요청</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
                <!-- <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button> -->
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	            	<div id="gridList" style="width: 100%; height: 415px;"></div>
	                <div class="list_paging" id="paging">
                		<ul class="paging">
                 			<li><a href="#" id='' class="on"></a>1</li>
                 		</ul>
                	</div>	            	
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>