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
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId    = loginInfo.SVCCOMMONID.rows.userId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var groupId	  = loginInfo.SVCCOMMONID.rows.groupId;
	var depth     = loginInfo.SVCCOMMONID.rows.depth;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	var workMenu  = "조작로그조회";
	var workLog   = "";
	var isUseUserCombo = 1;

	var dataArray = new Array();
	var markArray = new Array();
	
	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			if($('#s_FindTenantId option:selected').val() == ''){
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
			fnGroupCbChange("s_FindGroupId");
		} else if (kind == "group") {
			if($('#s_FindGroupId option:selected').val() == ''){
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		}
	}
	
	function fnInitCtrl(){		

		argoSetDatePicker();
		
		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);

		$('.timepicker.rec').timeSelect({use_sec:true});		
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
// 		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindMenu", "comboBoxCode", "getMenuList", {findTenantId:tenantId, actionLog:"Y"}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		fnGroupCbChange("s_FindGroupId");
		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
// 			if(grantId != "Manager"){
				$('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId, FindGroupId:groupId + '_' + depth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
// 			}
		}
	
		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
		
		$("#s_FindTenantId").change(function() { fnSetSubCb('tenant'); 	});
		$("#s_FindGroupId").change(function()  { fnSetSubCb('group'); 	});

		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});
		
		$("#btnMarkAdd").click(function(){
			fnMarkAdd();
		});	
		
		$("#btnMarkDel").click(function(){
			fnMarkDel();
		});
		
		$("#btnSampAdd").click(function(){
			fnSampAdd();
		});
		
		$('.clickSearch').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		
		$("#btnExcel").click(function(){
			var excelArray = [];
			argoJsonSearchList('actionLog', 'getActionLogList', 's_', {"iSPageNo":100000000, "iEPageNo":100000000}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {

							gObject = {   "순번" 		: index + 1
					    				, "작업일자"	: row.logDate
										, "관리자ID" 	: row.userId
										, "관리자명" 	: row.userName
										, "메뉴명" 	: row.workMenu
										, "작업자IP" 	: row.workIp
										, "내용" 		: row.workLog
									};
							excelArray.push(gObject);
						});
						
						gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
						argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
						workLog = '[TenantId:'
							+ tenantId
							+ ' | UserId:' + userId
							+ ' | GrantId:'
							+ grantId
							+ '] Excel Export';
						
						
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

		// 2018.02.07 사용자 콤보박스 표시 여부
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_USER_COMBO"}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						isUseUserCombo = data.getRows()['code'];

						if (isUseUserCombo == 1) {
						   $("#s_FindUserId").attr('style', "width:150px;");
						}
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function fnInitGrid(){
		
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: false
	        },
	        columns: [  
	                     { field: 'recid', 		caption: 'recid', 	size: '0%', 	attr: 'align=center' }
		            	,{ field: 'logDate', 	caption: '작업일자', 	size: '15%', 	attr: 'align=center' }
			           	,{ field: 'userId', 	caption: '관리자ID',	size: '10%',	attr: 'align=center' }
			           	,{ field: 'userName', 	caption: '관리자명', 	size: '10%', 	attr: 'align=center' }
			           	,{ field: 'workMenu', 	caption: '메뉴명', 	size: '15%', 	attr: 'align=center' }
			           	,{ field: 'workIp', 	caption: '작업자IP', 	size: '15%', 	attr: 'align=center' }
			           	,{ field: 'workLog', 	caption: '내용', 		size: '35%', 	attr: 'align=left'   }
			           	
	        ],
	        records: dataArray
	    });	 
		w2ui['grid'].hideColumn('recid');
	}
	
	function fnSearchListCnt(){
		w2ui.grid.lock('조회중', true);
		
		argoJsonSearchOne('actionLog', 'getActionLogCount', 's_', {grantId : grantId, controlAuth:controlAuth}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					
					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}

				}
			} catch (e) {
				console.log(e);
			}
		});
	}

	function fnSearchList(startRow, endRow){

		argoJsonSearchList('actionLog', 'getActionLogList', 's_', {grantId : grantId, controlAuth:controlAuth,"iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();

					if (data.getRows() != ""){ 
						dataArray = [];

						$.each(data.getRows(), function( index, row ) {

							gridObject = {    "recid" 			: index
				    						, "logDate"			: row.logDate
											, "userId" 			: row.userId
											, "userName" 		: row.userName
											, "workMenu"		: row.workMenu
											, "workIp" 			: row.workIp
											, "workLog" 		: row.workLog
											, w2ui: row.workMenu == "내선녹취오류" ? { "style": "background-color: #FFB54F" } : {}	
										};
										
							dataArray.push(gridObject);
						});
						
						w2ui['grid'].add(dataArray);
					}					
				w2ui.grid.unlock();
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
		
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location">
        	<span class="location_home">HOME</span><span class="step">운용관리</span><strong class="step">조작로그조회</strong>
        </div>
        <section class="sub_contents">
            <div class="search_area row4" id="searchPanel">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px; display:none;" class="clickSearch"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
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
                            <select id="s_FindUserId" name="s_FindUserId" style="display:none; width:150px;" class="list_box" title="사용자의 그룹을 먼저 선택하세요!"></select>
			    			<input type="text" id="s_FindUserNameText" name="s_FindUserNameText" style="width:150px" class="clickSearch"/>
                        </li>
                        <li></li>
                    </ul>
                </div>
                <div class="row"  id="div_call">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">메뉴</strong>
                            <select id="s_FindMenu" name="s_FindMenu" style="width: 150px" class="list_box"></select>                        
						</li>
                        <li>
                            <strong class="title">내용</strong>
							<input type="text"	id="s_FindContent" name="s_FindContent" style="width:150px" class="clickSearch"/>
                        </li>
                    </ul>
                </div>              
                <div class="row">
                    <ul class="search_terms">
                    	<li style="width:683px">
                            <strong class="title ml20">작업일자</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
							<span class="text_divide" style="width:434px">&nbsp; ~ &nbsp;</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                            <select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
                        </li>
                    </ul>
                </div>                
            </div>
            <div class="btns_top">
				<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
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