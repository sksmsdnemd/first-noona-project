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
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->    
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "메뉴별권한관리";
	var workLog 	= "";
	var dataArray 	= new Array();

	$(document).ready(function(param) {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
		
	});
	
	var fvKeyId ; 

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			if($('#s_FindTenantId option:selected').val() == ''){
			}else{
				argoCbCreate("s_FindGrantId", "comboBoxCode", "getGrantList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
		} else if (kind == "group") {
		}
	}	
	
	function fnInitCtrl(){	
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGrantId", "comboBoxCode", "getGrantList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		if(grantId != "SuperAdmin" && grantId != "SystemAdmin"){
			$("#div_tenant").hide();
		}
		
		$("#s_FindTenantId").change(function() {	fnSetSubCb('tenant');	});
		
		$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
		
		$("#btnSearch").click(function(){ //조회
			if($("#s_FindGrantId").val() == ""){
				argoAlert('권한을 선택하여 주세요.');
			}
			fnSearchList();			
		});
		
		$("#btnSave").click(function(){
			fnSaveList();
		});
		
		$("#btnReset").click(function(){
			$('#s_FindTenantId		option[value=""]').prop('selected', true);
			$('#s_FindGrantId		option[value=""]').prop('selected', true);
			$('#s_FindGroupId		option[value=""]').prop('selected', true);
			$('#s_FindRetireeFlag	option[value=""]').prop('selected', true);
			$('#s_FindAgentStatus	option[value=""]').prop('selected', true);
			$('#s_FindLoginCheck	option[value=""]').prop('selected', true);

			$("#s_FindUserNameText").val('');
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
	        recordHeight : 26,
	        multiSelect: false,
	        columns: [  
					 	 { field: 'recid', 			caption: 'recid',	size: '0%',		sortable: true, 	attr: 'align=center' }
            	 		,{ field: 'depth1Id', 	 	caption: '메뉴1', 	size: '5%', 	sortable: false,	attr: 'align=center' }
            	 		,{ field: 'depth2Id', 		caption: '메뉴2', 	size: '5%', 	sortable: false, 	attr: 'align=center' }
            	 		,{ field: 'depth3Id', 		caption: '메뉴3',		size: '5%', 	sortable: false, 	attr: 'align=center' }
            	 		,{ field: 'menuName', 		caption: '메뉴명', 	size: '30%', 	sortable: false, 	attr: 'align=left'   }
            	 		,{ field: 'srcDo', 		 	caption: '메뉴링크',	size: '35%', 	sortable: false, 	attr: 'align=left'   }
            	 		,{ field: 'authKind', 	 	caption: '권한', 		size: '0%', 	sortable: true, 	attr: 'align=center' }
            	 		,{ field: 'authKindName',  	caption: '권한', 		size: '20%', 	sortable: false, 	attr: 'align=center' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'authKind'); 
	}
	
	function fnGetRadioAuth(index, value, checked, title){
		var strInput; 
		
		strInput = '<input type="radio" id="authKind' + index + "_" + value + '" name="authKind' + index + '" value="' + value + '" ' + checked + '/>' +
					'<label for="authKind' + index + "_" + value + '" style="width: 60px">' + title + '</label>';
		return strInput;
	}
	
	function fnSearchList(){
		
		argoJsonSearchList('menu', 'getMenuAuthList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					dataArray = [];
					if (data.getRows() != ""){ 
						var authKind;
						var menuId;
						var menuName;
						
						$.each(data.getRows(), function( index, row ) {
							menuId = "" + row.depth1Id + row.depth2Id + row.depth3Id;
							authKind = "";
							if (row.authKind == "0") {
								authKind += fnGetRadioAuth(index, '0', 'checked', '없음');
							}else{
								authKind += fnGetRadioAuth(index, '0', '', '없음');
							}
							
							authKind += " &nbsp;";

							if (row.authKind == "1") {
								authKind += fnGetRadioAuth(index, '1', 'checked', '조회');
							}else{
								authKind += fnGetRadioAuth(index, '1', '', '조회');
							}
							authKind += " &nbsp;";
							
							if (row.authKind == "2") {
								authKind += fnGetRadioAuth(index, '2', 'checked', '제어가능');
							}else{
								authKind += fnGetRadioAuth(index, '2', '', '제어가능');
							}
							
							menuName = '<pre>' ;
							if (row.depth > 0) {
								menuName += row.head + '<img src="../images/minusbottom.gif">';
							}
							
							menuName += '<img src="../images/folder.gif"> ' + row.menuName + '</pre>' ;
							
							gObject2 = {  "recid" 			: index
										, "depth1Id"		: row.depth1Id
					    				, "depth2Id"	  	: row.depth2Id
					   					, "depth3Id"	  	: row.depth3Id
										, "menuName" 		: menuName
										, "srcDo" 			: row.srcDo
										, "authKind" 		: row.authKind
										, "authKindName"	: authKind									
										};
										
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
			} catch (e) {
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
	
	var changeMenuName = "";
	function fnSaveList(){
		if ($('#s_FindGrantId option:selected').val() == "") {
			argoAlert('권한을 선택하여 주세요.');
			$('#s_FindGrantId').focus();
			return;
		}
		
		try{
			argoConfirm("권한 [" + $('#s_FindGrantId option:selected').text() + '] 변경 저장 하시겠습니까?', function() {
				
				var multiService = new argoMultiService(fnCallbackSave);
				var tenantId = $('#s_FindTenantId option:selected').val();
				var grantId = $('#s_FindGrantId option:selected').val();;
				var authKind;
				var cnt = 0;
				changeMenuName = "";
				
				$.each(dataArray, function( index, row ) {
					authKind = $(':input:radio[name=authKind' + index + ']:checked').val();
					
					if(authKind == undefined){
						authKind = "";
					}
				
					var param = { 
									"tenantId" 	: tenantId, 
									"grantId"   : grantId,
									"depth1Id"	: row.depth1Id,
									"depth2Id"	: row.depth2Id,
									"depth3Id"	: row.depth3Id,
									"authKind"	: authKind,
									"uptId"		: userId
								};
					multiService.argoUpdate("menu", "setMenuAuthUpdate", "__", param);

					// log에 변경된 메뉴명 남기기 위해서 추가
					if(row.authKind != authKind) {
						if(cnt == 0) {
							changeMenuName += $(row.menuName).text().trim();
						} else {
							changeMenuName += (", " + $(row.menuName).text().trim());
						}
						cnt++;
					}
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		}
	}
	
	function fnCallbackSave(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				workLog = '[태넌트:' + $('#s_FindTenantId option:selected').val() + " | 권한:" + $('#s_FindGrantId option:selected').val() + " | 메뉴:" + changeMenuName +'] 변경';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId,userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				argoAlert('성공적으로  저장 되었습니다.');
				fnSearchList();
			}
		} catch (e) {
			argoAlert(e);
		}
	}	
		
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">메뉴관리</span><strong class="step">메뉴별권한관리</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px; display:none;" class="clilkSearch"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                        </li>
                    </ul>
                </div>
                <div class="row" id="div_user">
                    <ul class="search_terms">
                        <li  style="width:280px">
                            <strong class="title ml20">권한</strong>
                            <select id="s_FindGrantId" name="s_FindGrantId" style="width:150px;" class="list_box"></select>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
	            <div class="sub_l">
	            	<!-- <strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span> --> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnSave" class="btn_m confirm">저장</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 100%;"></div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>