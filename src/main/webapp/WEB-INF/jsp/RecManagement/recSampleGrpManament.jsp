<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<meat http-equiv="x-ua-compatible" content>
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
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
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->
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
	var userId    = loginInfo.SVCCOMMONID.rows.userId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var grantId    = loginInfo.SVCCOMMONID.rows.grantId;
	var workMenu  = "샘플콜분류관리";
	var workLog   = "";
//2222222
	$(function () {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});
	
	function fnInitGrid(){
	   
	   $('#grid').w2grid({ 
	        name: 'grid',
	        show: {
	            lineNumbers: true,
	            footer:true,
	            selectColumn: true
	        },
	        multiSelect: true,
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >=0 ) {
					gPopupOptions = {cudMode:'U', "flag":"U", pRowIndex:record, pTenantId:$('#s_FindTenantId option:selected').val()} ;   	
					argoPopupWindow('샘플콜분류수정', 'recSampleListPopAddF.do', '680', '250');  
				}
	        },
           columns: [
						{ field: 'recid', 		caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' },
			            { field: 'tenantId',	caption: 'tenantId', 	size: '0%', 	sortable: true, attr: 'align=center' },
			            { field: 'groupId', 	caption: '분류ID', 		size: '15%',	sortable: true, attr: 'align=center' },
			            { field: 'depthPath', 	caption: '분류명', 		size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'depthTree',	caption: '분류명', 		size: '40%', 	sortable: true, attr: 'align=left'   },
			            { field: 'topParentId', caption: 'topParentId', size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'parentId', 	caption: 'parentId', 	size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'depth', 		caption: 'depth', 		size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'groupDesc', 	caption: '설명', 			size: '40%',	sortable: true, attr: 'align=center' },
			            { field: 'sortCol', 	caption: 'sortCol', 	size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'isExist', 	caption: 'isExist', 	size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'level', 		caption: 'level', 		size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'groupName', 	caption: 'groupName', 	size: '0%',		sortable: true, attr: 'align=center' },
			            { field: 'subAdd', 		caption: '하부', 			size: '15%', 	sortable: true, attr: 'align=center' }
	        ]
	    });
		w2ui['grid'].hideColumn('recid', 'tenantId', 'topParentId', 'parentId', 'depth', 'sortCol', 'isExist', 'level', 'groupName', 'depthPath');
	   
	}
		
	function fnInitCtrl(){		
		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		$("#btnSearch").bind("click",function(){ //조회
			fnSearchList();			
		});
		
		$("#btnSort").click(function(){
			argoPopupWindow('샘플콜분류조회', 'recSampleGrpPopAddF.do', '600', '490');
		});	
		
		$("#btnAdd").click(function(){
			parm={"flag":"I"};
			gPopupOptions = {cudMode:'I', pRowIndex:parm, pTenantId:$('#s_FindTenantId option:selected').val()};
			argoPopupWindow('샘플콜분류등록', 'recSampleListPopAddF.do', '680', '250');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});	
		
		$("#btnReset").click(function(){
			argoSetValue("s_FindDepthPath", "");
			argoSetValue("s_FindGroupName", "");
		});	
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
	}
	
	function sub(idx){
		var groupId;
		var topParentId;
		var parentId;
		var parm;
		
		groupId 	= w2ui['grid'].getCellValue(idx,2);
		topParentId = w2ui['grid'].getCellValue(idx,5);
		parentId 	= w2ui['grid'].getCellValue(idx,6);
		depth		= w2ui['grid'].getCellValue(idx,7);
		level		= w2ui['grid'].getCellValue(idx,11);
		
		parm={
				"groupId"     : groupId,
				"topParentId" : topParentId,
				"parentId"    : parentId,
				"depth"		  : depth,
				"level"       : level,
				"flag"		  : "I_I"	
			};
			
		gPopupOptions = {cudMode:'I', pRowIndex:parm, pTenantId:$('#s_FindTenantId option:selected').val()} ;   	
		argoPopupWindow('샘플콜서브추가', 'recSampleListPopAddF.do', '680', '250');  
	}	
	
	function sortSh(){
		argoPopupWindow('샘플콜분류조회', 'recSampleGrpPopAddF.do', '600', '490');
	}
	
	function fnSerch(param) {
		argoSetValue("s_FindDepthPath", param.depthPath);
		argoSetValue("s_FindGroupName", param.groupName);
		fnSearchList();
	}
	
	function fnSearchList(){
		argoJsonSearchList('recSample', 'getSampleCallGrpList', 's_', {tenantId:$('#s_FindTenantId option:selected').val()}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){
						var dataArray2;
						var gObject2;
						var records;
						var subAdd    = "";
						var depthTree = "";
						
						dataArray2 = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							if( row.level != "3"){
								subAdd = ' <button type="button" id="sub" class="btn_m btn_type1" onclick="javascript:sub(' + index + ');">서브추가</button>';
							}else{
								subAdd = '';
							}
							
							if (row.depthLen > 3) {
								depthTree = '<pre>' + row.head + '<img src="../images/minusbottom.gif"><img src="../images/folder.gif">' + row.groupName + '</pre>' ;
							} else {
								depthTree = row.groupName;
							}
							
							gObject2 = {  "recid"       	:  index
									    , "tenantId"    	:  row.tenantId
					    			    , "groupId"     	:  row.groupId
					    			    , "groupName"   	:  row.groupName
					    			    , "depthTree"   	:  depthTree
										, "topParentId" 	:  row.topParentId
										, "parentId"    	:  row.parentId
										, "depth"       	:  row.depth
										, "groupDesc"   	:  row.groupDesc
										, "sortCol"     	:  row.sortCol
										, "isExist"     	:  row.isExist
										, "level"       	:  row.level
										, "depthPath"   	:  row.depthPath
										, "subAdd"      	:  subAdd
										};
							
					    	 dataArray2.push(gObject2);
						});
						
						w2ui['grid'].add(dataArray2);
					}else{
						argoAlert('조회 결과가 없습니다.');
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
	
	var gGroupId;
	var tTenantId;
	function fnDeleteList(){
		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("삭제할 샘플콜분류를 선택하세요"); 
		 		return ;
			}

			argoConfirm('선택한 샘플콜분류 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				$.each(arrChecked, function( index, value ) {

					gGroupId  = w2ui['grid'].getCellValue(value, 2);
					tTenantId = w2ui['grid'].getCellValue(value, 1);
					var param = { 
									"groupId" : gGroupId, 
									"tenantId"   : tTenantId
								};
					multiService.argoDelete("recSample","setRecSampleCallGroupDelete","__", param);
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
				workLog = '[그룹ID:' + gGroupId + '] 삭제';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				argoAlert('성공적으로 삭제 되었습니다.');
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
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">샘플콜관리</span><strong class="step">샘플콜분류관리</strong></div>
        <section class="sub_contents">
            <div class="search_area">
            	<div class="row" id="div_tenant">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">태넌트</strong> 
							<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
							<input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" /> 
							<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1">
						</li>
					</ul>
				</div>
                <div class="row">
                   <ul class="search_terms">
                        <li>
                            <strong class="title ml20">분류명</strong>
                            <input type="text"	id="s_FindDepthPath" name="s_FindDepthPath" class="mr10" onclick="javascript:sortSh();" style="width:200px" readOnly/>
                            <input type="text"	id="s_FindGroupName" name="s_FindGroupName" class="mr10" onclick="javascript:sortSh();" style="width:200px" readOnly/>
                            <button type="button" id="btnSort" class="btn_m" >분류조회</button>
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
	               <div id="grid" style="width: 100%; height: 415px;  overflow: hidden;" ></div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>