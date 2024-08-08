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
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->
<style>
.btn_type1 {
	font-size:12px; 
	height:19px; 
	padding:0 5px 0 5px;
}
</style>
<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 	  = loginInfo.SVCCOMMONID.rows.userId;
	var grantId 	  = loginInfo.SVCCOMMONID.rows.grantId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 	  = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "메뉴관리";
	var workLog   = "";
	var msgCheck  = "N";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});
	
	function fnInitCtrl(){
		
		var optionHtml = '<option selected="selected" value="">선택하세요!</option>';
		
		argoCbCreate("s_FindDepth1", "menu", "getDeptMenu1", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		$("#s_FindDepth1").change(function(){
			if($('#s_FindDepth1 option:selected').val() == ''){
				$("#s_FindDepth2").find("option").remove();
				$("#s_FindDepth3").find("option").remove();
				$("#s_FindDepth2").append(optionHtml);
				$("#s_FindDepth3").append(optionHtml);
			}else{
				argoCbCreate("s_FindDepth2", "menu", "getDeptMenu2", {"findDepth1":$("#s_FindDepth1").val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				$("#s_FindDepth3").find("option").remove();
				$("#s_FindDepth3").append(optionHtml);
			}	
	 	});
		
		$("#s_FindDepth2").change(function(){
			if($('#s_FindDepth2 option:selected').val() == ''){
				$("#s_FindDepth3").find("option").remove();
				$("#s_FindDepth3").append(optionHtml);
			}else{
				argoCbCreate("s_FindDepth3", "menu", "getDeptMenu3", {"findDepth1":$("#s_FindDepth1").val(), "findDepth2":$("#s_FindDepth2").val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}	
	 	});
		
		$("#btnSearch").click(function(){
			fnSearchList();			
		});
		
		$("#btnAdd").click(function(){ 
			gPopupOptions = {cudMode:"I"} ;   	
		 	argoPopupWindow('메뉴등록', 'MenuPopAddF.do', '500', '280');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});
		
		$(".clickSearch").keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
		});
		
		$("#btnReset").click(function(){
			$('#s_FindDepth1 option[value=""]').prop('selected', true);
			$('#s_FindDepth1').change();
			$("#s_FindMenuName").val('');
		});
	}
	
	function fnInitGrid(){

		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        multiSelect: true,
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >=0 ) {
					gPopupOptions = {cudMode:'U', pRowIndex:record} ;
					argoPopupWindow('메뉴수정', 'MenuPopAddF.do', '500', '280');
				}
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'depth1Id', 		caption: '메뉴1ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'depth2Id', 		caption: '메뉴2ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'depth3Id', 		caption: '메뉴3ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'menuName', 		caption: '메뉴명', 		size: '16%', 	sortable: true, attr: 'align=left'   }
	            		,{ field: 'displayFlag', 	caption: '표시여부', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'displayFlagNm', 	caption: '표시여부', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'menuAuthDef', 	caption: '메뉴기본권한', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'menuAuthDefNm', 	caption: '메뉴기본권한', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'srcDo', 			caption: '메뉴링크', 		size: '30%', 	sortable: true, attr: 'align=left'   }
	            		,{ field: 'subMenu', 		caption: '하부메뉴', 		size: '10%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid','displayFlag','menuAuthDef');
	}
	
	function fnSearchList(){

		argoJsonSearchList('menu', 'getMenuMngList', 's_', {"tenantId":tenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					
					w2ui.grid.clear();
					
					var btnHtml 	= "";
					var strDisplay 	= "";
					var strAuthDef 	= "";
					
					if(data.getRows() != ""){
						dataArray = new Array();
						
						$.each(data.getRows(), function( index, row ) {
							
							if(row.displayFlag == "0")		strDisplay = "예";
							else if(row.displayFlag == "1")	strDisplay = "아니오";
							else							strDisplay = "";

							if(row.menuAuthDef == "0")		strAuthDef = "없음";
							else if(row.menuAuthDef == "1")	strAuthDef = "조회";
							else if(row.menuAuthDef == "2")	strAuthDef = "제어가능";
							else							strAuthDef = "";
							
							if(row.depth3Id == "0" && row.srcDo == "#"){
								btnHtml = '<button type="button" id="sub" class="btn_m btn_type1" onclick="javascript:fnMenuAdd(' + index + ');" style="width:80px">서브추가</button>';
							}else{
								btnHtml = '';
							}
							
							gObject2 = {  "recid" 			: index
					    				, "depth1Id"		: row.depth1Id
					   					, "depth2Id"		: row.depth2Id
										, "depth3Id" 		: row.depth3Id
										, "menuName"		: row.menuName
										, "displayFlag" 	: row.displayFlag
										, "displayFlagNm"	: strDisplay
										, "menuAuthDef" 	: row.menuAuthDef
										, "menuAuthDefNm"	: strAuthDef
										, "srcDo" 			: row.srcDo
										, "subMenu" 		: btnHtml
										};
										
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
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
	
	function fnMenuAdd(idx){
		
		var depthId1;
		var depthId2;
		var depthId3;
		var param;
		depthId1 = w2ui['grid'].getCellValue(idx,1);
		depthId2 = w2ui['grid'].getCellValue(idx,2);
		depthId3 = w2ui['grid'].getCellValue(idx,3);
		
		param = {
					"depth1Id"	: depthId1,
					"depth2Id"	: depthId2,
					"depth3Id"	: depthId3
				};
		gPopupOptions = {cudMode:'A', pRowIndex:param};
		argoPopupWindow('메뉴 서브추가', 'MenuPopAddF.do', '500', '280');
		
	}
	
	function fnDeleteList(){
		
 		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("삭제할 메뉴를 선택하세요"); 
		 		return ;
			}

			argoConfirm('선택한 메뉴 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				var param = "";

				$.each(arrChecked, function( index, value ) {
					
					param = { 
								"depth1Id" 	: w2ui['grid'].getCellValue(value, 1), 
								"depth2Id"  : w2ui['grid'].getCellValue(value, 2),
								"depth3Id"  : w2ui['grid'].getCellValue(value, 3)
							};
					multiService.argoDelete("menu", "setAuthByMenuDelete", "__", param);
					
					msgCheck = "N";
				});
				multiService.action();
				
				$.each(arrChecked, function( index, value ) {
					
					param = { 
								"depth1Id" 	: w2ui['grid'].getCellValue(value, 1), 
								"depth2Id"  : w2ui['grid'].getCellValue(value, 2),
								"depth3Id"  : w2ui['grid'].getCellValue(value, 3)
							};
					multiService.argoDelete("menu", "setMenuDelete", "__", param);
					
					msgCheck = "Y";
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		} 
	}
	
	function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				if(msgCheck == "Y"){
					argoAlert('성공적으로 삭제 되었습니다.');
					
					
					workLog = ("[사용자ID:" + userId + "] 메뉴 삭제");
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
					fnSearchList();
				}
			}
		} catch (e) {
			argoAlert(e);
		}
	}

</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">메뉴관리</span><strong class="step">메뉴관리</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
            	<div class="row">
                    <ul class="search_terms">
						<li>
							<strong class="title ml20">메뉴명</strong>
							<input type="text"	id="s_FindMenuName" name="s_FindMenuName" class="clickSearch" style="width:366px"/>
                        </li>                   
					</ul>
				</div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">메뉴Depth</strong>
                            <select id="s_FindDepth1" name="s_FindDepth1" style="width:120px" class="list_box">
							</select>
							<select id="s_FindDepth2" name="s_FindDepth2" style="width:120px" class="list_box">
								<option value="">선택하세요!</option>
							</select>
							<select id="s_FindDepth3" name="s_FindDepth3" style="width:120px" class="list_box">
								<option value="">선택하세요!</option>
							</select>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
                <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width:100%; height: 100%;"></div>
                </div>
	        </div>
        </section>
    </div>
</body>

</html>