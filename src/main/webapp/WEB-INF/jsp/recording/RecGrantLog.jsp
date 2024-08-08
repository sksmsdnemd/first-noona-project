<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Pragma", "no-cache");
	response.setDateHeader("Expires", 0);
%>
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="Pragma" content="no-cache" />
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->

<script>

	var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;
	var userId      = loginInfo.SVCCOMMONID.rows.userId;
	var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
	var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
	var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
	var depth		= loginInfo.SVCCOMMONID.rows.depth;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	
	var workMenu    = "청취권한이력조회";
	var workLog     = "";
	var ControlAuthGroup = new Array();
	var isUseUserCombo   = 1;
	var workPage	= "1";
	
	var dataArray = new Array();
	var markArray = new Array();
	
	$(document).ready(function() {
		if(controlAuth == null){
			controlAuth = "";
		}
		fnInitCtrl();
		fnParamSetting();
		fnInitGrid();
		argoSetValue("s_RecFrmTm", "00:00:00");
        argoSetValue("s_RecEndTm", "23:59:59");
        argoSetValue("s_CallFrmTm", "00:00:00");
        argoSetValue("s_CallEndTm", "23:59:59");

		//fnSearchListCnt();
		//setReason();
		
	});
	
	//페이지 재 로드시 파라미터 세팅
	function fnParamSetting()
	{
		var paramText;
		paramText = parent.$("#RecGrantLogF").val().split("||");
		//alert(paramText);
		if(paramText.length > 1)
		{
			var paramSet;
			for (var i = 0; i < paramText.length; i++) 
			{
				paramSet = paramText[i].split("::")
				$("#" + paramSet[0]).val(paramSet[1]);
				
				if(paramSet[0] == "s_FindTenantId")
				{
					argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					fnGroupCbChange("s_FindGroupId");
				}
				else if(paramSet[0] == "s_FindGroupId")
				{
					if($('#s_FindGroupId option:selected').val() == "")
					{
						//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					}
					else
					{
						//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					}
				}
				else if(paramSet[0] == "div_tenant" || paramSet[0] == "div_user" || paramSet[0] == "div_cust")
				{
					if(paramSet[1] != "")
					{
						$("#"+paramSet[0]).hide();
						$("#"+paramSet[1]).attr("class", "btn_tab confirm");
						//rowCnt--;
					}
				}
				else if(paramSet[0] == "selectionPage")
				{
					workPage = paramSet[1];
				}
			}
		}
	}

	function fnSetSubCb(kind) 
	{
		if (kind == "tenant") 
		{
			if($('#s_FindTenantId option:selected').val() == '')
			{
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
			else
			{
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				//SetGridHideColumn($('#s_FindTenantId option:selected').val());
				fnSearchListCnt();	
				fnGroupCbChange("s_FindGroupId");
			}
		} 
		else if (kind == "group") 
		{
			if($('#s_FindGroupId option:selected').val() == '')
			{
				//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
			else
			{
				//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		}
	}
	
	function fnInitCtrl()
	{		
		argoSetDatePicker();
		
		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code" :"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);

		$('.timepicker.rec').timeSelect({use_sec:true});		
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnGroupCbChange("s_FindGroupId");
		//fnAuthBtnChk(parent.$("#authKind").val());
		
		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
		$("#s_FindTenantId").change(function() {	fnSetSubCb('tenant'); 	});
		$("#s_FindGroupId").change(function() {		fnSetSubCb('group'); 	});
		
		if(grantId == "GroupManager" || grantId == "Agent")
		{
			$('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
			//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId, FindGroupId:groupId + '_' + depth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			
			if(grantId == "Agent"){
				$('#s_FindUserId option[value="' + userId + '"]').prop('selected', true);
				$("#btnUserDisplay").hide();
				$("#s_FindUserId").attr("disabled", true);
				$('#s_FindGroupId option[value=""]').prop('selected', true);
			}
		}
		
		
		$("#btnSearch").click(function(){ //조회
			workPage = "1";
			fnSearchListCnt();			
		});
		
		$('.clickSearch').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		
		argoJsonSearchList('recSearch', 'getControlList', 's_', {"findTenantId":tenantId, "userId":userId}, function (data, textStatus, jqXHR)
		{
			try{
				if(data.isOk()){
					if (data.getRows() != ""){
						ControlAuthGroup = [];

						$.each(data.getRows(), function( index, row ) {
							ControlAuthGroup.push(row.groupId);
						});
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
		
		// 2018.02.07 사용자 콤보박스 표시 여부
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_USER_COMBO"}, function (data, textStatus, jqXHR)
		{
			try
			{
				if(data.isOk())
				{
					if(data.getRows() != "")
					{
						isUseUserCombo   = data.getRows()['code'];

						if (isUseUserCombo == 0) 
						{
							$("#s_FindUserId").attr("style", "display:none;");
						}
					}
				}
			} 
			catch(e) 
			{
				console.log(e);			
			}
		});
		
		$("#btnExcel").click(function()
		{
			var excelArray = new Array();			
			argoJsonSearchList('recSearch', 'getRecGrantList', 's_', {"iSPageNo":1, "iEPageNo":100000000, userId:userId, controlAuth:controlAuth, grantId:grantId}, function (data, textStatus, jqXHR)
			{
				try 
				{
					if (data.isOk()) 
					{
						$.each(data.getRows(), function( index, row ) 
						{
							gObject = {   "순번" 			: index + 1
					    				, "시작시간"		: fnStrMask("YMD", row.recDate)
					   					, "만료시간"		: fnStrMask("HMS", row.recTime)
										, "권한부여한 날짜" 	: row.groupName
										, "권한받은 사용자" 	: row.userId
										, "통화일자" 		: row.userName
										, "녹취시간" 		: row.dnNo
										, "내선" 			: fnSecondsConv(row.endTime)
										, "통화시간" 		: row.callKind
										, "구분" 			: row.custTel
										, "콜아이디" 		: row.custName
									};
										
							excelArray.push(gObject);
						});
						
						gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
						argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
						
						workLog = '[TenantId:' + tenantId + ' | UserId:' + userId + ' | GrantId:' + grantId + '] Excel Export';
						argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
										,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
					}
				} 
				catch (e) 
				{
					console.log(e);
				}
			});
		});
		
		$("#btnReset").click(function()
		{
			$("#s_FindUserNameText").val('');	//사용자
			$("#s_FindDnText").val('');			//내선
			$("#s_FindCallIdText").val('');		//콜아이디
			//$("#s_FindReasonText").val('');		//조회사유
			$('#s_FindField option[value=""]').prop('selected', true);
			
			argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
			argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			fnGroupCbChange("s_FindGroupId");
			
			jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
			argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
			argoSetValue("s_RecFrmTm", "00:00:00");
			argoSetValue("s_RecEndTm", "23:59:59");
			argoSetValue("s_CallFrmTm", "00:00:00");
			argoSetValue("s_CallEndTm", "23:59:59");
			$('#selDateTerm1 option[value="T_0"]').prop('selected', true);
			
			if(grantId == "GroupManager" || grantId == "Agent"){
				$('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
				//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId, FindGroupId:groupId + '_' + depth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				
				if(grantId == "Agent"){
					$('#s_FindUserId option[value="' + userId + '"]').prop('selected', true);
				}
			}
		});
	}
	
	var idxRecKey 		= 1;
	
	var idxFmtRecDate = 3;
	var idxFmtRecTime = 4;
//	var idxRecDate 		= 24;
//	var idxRecTime		= 25;
//	var idxGroupName	= 4;
//	var idxUserId		= 5;
//	var idxUserName		= 6;
//	var idxCustTel		= 7;
//	var idxCustName		= 8;
//	var idxDnNo			= 9;
//	var idxEndTime		= 26;
	var idxCustNo		= 12;
	var idxCustEtc		= 16;
//	var idxCallId		= 23;
//	var idxFileName		= 27;
	
	
	
	var idxGroupName	= 5;
	var idxUserId		= 6;
	var idxUserName		= 7;
	var idxCustTel		= 8;
	var idxCustName		= 9;
	
	var idxDnNo			= 10;
	var idxCallId		= 25;
	var idxRecDate 		= 26;
	var idxRecTime		= 27;	
	var idxEndTime		= 28;
	var idxFileName		= 29;
	
	function fnInitGrid()
	{
		$('#gridList').w2grid(
		{ 
	        name: 'grid', 
	        show: {
	            lineNumbers: false,
	            footer: true,
	            selectColumn: false
	        },
	        onClick: function(event) 
	        {
	        	if (event.recid >= 0) 
	        	{
	        		if (event.column != null) 
	        		{
		        		$('#clip_target').val(w2ui['grid'].getCellValue(event.recid, event.column));
		        		$('#clip_target').select();
		        		var successful = document.execCommand('copy');	        			
	        		}
	        	}	
	        },
	        columns: [  
	        			 { field: 'recid', 			caption: 'recid', 		size: '0px', 	attr: 'align=center' }
	        		    ,{ field: 'recKey', 		caption: 'recKey', 		size: '0px', 	attr: 'align=center' }
		            	,{ field: 'startDate', 		caption: '시작기간', 		size: '90px', 	attr: 'align=center', frozen: true }
			           	,{ field: 'endDate', 		caption: '만료기간', 		size: '90px', 	attr: 'align=center', frozen: true }
			           	,{ field: 'insDate', 		caption: '권한부여일', 		size: '90px', 	attr: 'align=center', frozen: true }
			           	,{ field: 'userName', 		caption: '권한받은사용자',	size: '110px', 	attr: 'align=center', frozen: true }
			           	,{ field: 'recTimeDate', 	caption: '통화일자', 		size: '90px', 	attr: 'align=center', frozen: true }
			           	,{ field: 'recTimeTime', 	caption: '녹화시간', 		size: '90px', 	attr: 'align=center', frozen: true }
			           	//,{ field: 'dnNo', 			caption: '내선', 			size: '60px', 	attr: 'align=center' }
			           	,{ field: 'dnNo', 			caption: '내선', 			size: '80px', 	attr: 'align=center' }
			           	,{ field: 'endTime', 		caption: '통화시간',		size: '80px', 	attr: 'align=center' }
			           	,{ field: 'callKind', 		caption: '구분', 			size: '60px', 	attr: 'align=center' }
			           	//2019-02-08 yoonys start
			           	,{ field: 'authDiv', 		caption: '권한구분', 			size: '85px', 	attr: 'align=center' }
			           	//2019-02-08 yoonys end			           	
			           	,{ field: 'callId', 		caption: '콜아이디', 		size: '430px', 	attr: 'align=left'   }
			           	
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'recKey');
		$('#gridList').hide();
		$('#paging').hide();
	}
	
	function fnSearchListCnt()
	{
		//페이지 리로드시 기존 파라미터 세팅 start
		var param01 = $("#s_FindTenantId").val();
		var param02 = $('#s_FindGroupId').val();
		var param03 = $('#s_FindUserId').val();
		var param04 = $('#s_FindUserNameText').val();
		var param05 = $('#s_FindDnText').val();
		var param11 = $('#s_FindCallIdText').val();
		var param12 = $('#s_txtDate1_From').val();
		var param13 = $('#s_txtDate1_To').val();
		var param14 = $('#s_RecFrmTm').val();
		var param15 = $('#s_RecEndTm').val();
		var param16 = $('#s_CallFrmTm').val();
		var param17 = $('#s_CallEndTm').val();
		var param18 = $('#selDateTerm1').val();
		
		var param19 = (document.getElementById('div_tenant').style.display != "") ? "btnTenantDisplay" : "";
		var param20 = (document.getElementById('div_user').style.display != "") ? "btnUserDisplay" : "";
		
		var pageParam = 's_FindTenantId::'		+ param01
					+ '||s_FindGroupId::'		+ param02
					+ '||s_FindUserId::'		+ param03
					+ '||s_FindUserNameText::'	+ param04
					+ '||s_FindDnText::'		+ param05
					+ '||s_FindCallIdText::'	+ param11
					+ '||s_txtDate1_From::'		+ param12
					+ '||s_txtDate1_To::'		+ param13
					+ '||s_RecFrmTm::'			+ param14
					+ '||s_RecEndTm::'			+ param15
					+ '||s_CallFrmTm::'			+ param16
					+ '||s_CallEndTm::'			+ param17
					+ '||selDateTerm1::'		+ param18
					+ '||div_tenant::'			+ param19
					+ '||div_user::'			+ param20
					;
		
		parent.$("#RecGrantLogF").val(pageParam);
		//페이지 리로드시 기존 파라미터 세팅 end
		
		w2ui.grid.lock('조회중', true);
		
		$("#s_FindDnText").val(jQuery.trim($("#s_FindDnText").val()));				//내선 공백제거
		$("#s_FindUserNameText").val(jQuery.trim($("#s_FindUserNameText").val()));	//사용자 공백제거
		
		//$("#s_FindReasonText").val(jQuery.trim($("#s_FindReasonText").val()));		//조회사유 공백제거
		
		var downFlagValue = $("#s_FindAuthDiv").val();
		if(downFlagValue=="00")
			{
				downFlagValue="";
			}
		
		var param	= {"insId" : userId,"findAuthDiv" : downFlagValue};
		argoJsonSearchOne('recSearch', 'getRecGrantListCnt', 's_', param, function (data, textStatus, jqXHR)
		{
			try 
			{
				if (data.isOk()) 
				{
					var totalData = data.getRows()['cnt'];
					var searchCnt = argoGetValue('s_SearchCount');
					//paging(totalData, "1", searchCnt, "2");
// 					paging(totalData, workPage, searchCnt, "2");
					paging(totalData, workPage, searchCnt);

					$("#totCount").text(totalData);
					
					if(totalData == 0)
					{
						argoAlert('조회 결과가 없습니다.');
					}
				}
				
				workLog = '[TenantId:' + tenantId + ' | UserId:' + userId + ' | GrantId:' + grantId + '] 통화내역조회';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			} 
			catch (e) 
			{
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow)
	{
		var downFlagValue = $("#s_FindAuthDiv").val();
		if(downFlagValue=="00")
			{
				downFlagValue="";
			}
		var param	= {"iSPageNo":startRow, "iEPageNo":endRow, "insId" : userId,"findAuthDiv" : downFlagValue};
		argoJsonSearchList('recSearch', 'getRecGrantList', 's_', param, function (data, textStatus, jqXHR)
		{
			try
			{
				if(data.isOk())
				{
					w2ui.grid.clear();
					if (data.getRows() != "")
					{ 
						dataArray = [];
						$.each(data.getRows(), function( index, row ) 
						{
							var startDate	= row.startDate.replace("'", "").replace("'", "");
							var endDate		= row.endDate.replace("'", "").replace("'", "");
							var insDate		= row.insDate.replace("'", "").replace("'", "");
							//console.log(row);
							gridObject = {  
											  "recid"			: index
							                , "recKey" 			: row.recKey
					    					, "startDate" 		: startDate
					   						, "endDate" 		: endDate
											, "insDate" 		: insDate
											, "userName" 		: row.userName
											, "recTimeDate" 	: row.recTimeDate
											, "recTimeTime" 	: row.recTimeTime
											, "dnNo" 			: row.dnNo
											, "endTime" 		: row.endTime
											, "callKind" 		: row.callKind
											, "callId" 			: row.callId
											, "authDiv"			: (row.downloadFlag=="Y"?"청취/다운":"청취")
											, w2ui: { "style": "background-color: #" + row.markingColor }		
										};
							//console.log(gridObject);			
							dataArray.push(gridObject);
						});
						//alert("test");
						w2ui['grid'].add(dataArray);
						$('#gridList').show();
						$('#paging').show();
					}					
				}
				w2ui.grid.unlock();
			} 
			catch(e) 
			{
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
	
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location">
        	<span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역조회</span><strong class="step">통화내역조회</strong>
        </div>
        <section class="sub_contents">
            <div class="search_area row4" id="searchPanel">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px; display:none;" class="clickSearch"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                        </li>
                        
                        <li>
                            <strong class="title ml20">권한구분</strong>
                            <select id="s_FindAuthDiv" name="s_FindAuthDiv" style="width: 140px" class="list_box">
                            <!-- 전체 -->
                            <!-- 청취권한 -->
                            <!-- 청취다운권한 -->
                            <option value="00">전체</option>
                            <option value="Y">청취/다운</option>
                            <option value="N">청취</option>
                            </select>
                        </li>
                        
                    </ul>
                </div>
                <div class="row" id="div_user">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">그룹</strong>
                            <select id="s_FindGroupId" name="s_FindGroupId" style="width: 140px" class="list_box"></select>
                            <!--  
							<input type="checkbox" class="checkbox" id="s_FindSelectSubGroup" name="s_FindSelectSubGroup" data-defaultChecked=true value="1" checked><label for="s_FindSelectSubGroup">하위그룹포함</label>
							-->
                        </li>
                        <li>
                            <strong class="title ml20">사용자</strong>
                            <select id="s_FindUserId" name="s_FindUserId" style="width:140px;" class="list_box" title="사용자의 그룹을 먼저 선택하세요!"></select>
                            <input type="text"	id="s_FindUserNameText" name="s_FindUserNameText" style="width:140px" class="clickSearch"/>
                        </li>
                        <!-- <li>
                            <strong class="title">조회사유</strong>
                           
                             <select id="s_FindReason" name="s_FindReason" style="width:200px;" class="list_box">
			    				<option id="reason_init" value=""> ==조회사유를 선택하세요== </option>
			    			</select>
			    			<input type="text"	id="s_FindReasonText" name="s_FindReasonText" style="width:200px" class="clickSearch"/>
                        </li> -->
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">내선</strong>
                            <input type="text"	id="s_FindDnText" name="s_FindDnText" style="width:140px" class="clickSearch"/>
                        </li>
                        <li>
                            <strong class="title ml20">콜아이디</strong>
							<input type="text"	id="s_FindCallIdText" name="s_FindCallIdText" style="width:140px" class="clickSearch"/>
                        </li>
                        <!-- <li>
                            <strong class="title">조회사유</strong>
                           
                             <select id="s_FindReason" name="s_FindReason" style="width:200px;" class="list_box">
			    				<option id="reason_init" value=""> ==조회사유를 선택하세요== </option>
			    			</select>
			    			<input type="text"	id="s_FindReasonText" name="s_FindReasonText" style="width:200px" class="clickSearch"/>
                        </li> -->
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li style="width:476px">
                            <strong class="title ml20">녹취일자</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                            <span class="text_divide" style="width:234px">&nbsp; ~ &nbsp;</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                            &nbsp;<select id="selDateTerm1" name="" style="width:70px;" class="mr5"></select>
                        </li>
                    	<li>
                            <strong class="title ml20">통화시간</strong>
                            <span class="timepicker rec" id="rec_time1"><input type="text" id="s_CallFrmTm" name="s_CallFrmTm" class="input_time" value="00:00:00"><a href="#" class="btn_time">시간 선택</a></span>
							<span class="text_divide">~</span>
                            <span class="timepicker rec" id="rec_time2"><input type="text" id="s_CallEndTm" name="s_CallEndTm" class="input_time" value="23:59:59"><a href="#" class="btn_time">시간 선택</a></span>
                        </li>
                    </ul>
                </div>                
            </div>
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
	            	<select id="s_SearchCount" name="s_SearchCount" style="width: 50px" class="list_box">
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="30">30</option>
						<option value="40">40</option>
						<option value="50">50</option>
					</select>
                </div>
				<input type="text"	id="clip_target" name="clip_target" style="width:150px; position:absolute; top:-9999em;"/>
				
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 432px;"></div>
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