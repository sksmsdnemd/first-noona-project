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
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>

<script>

	var dataArray;
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	});
	
	$(document).ready(function(param) {
	  	fnInitCtrlPop();
	  	fnInitGrid();
	  	fnSearchList();	
	});
	
	var reqGroupId;
	var tenantId;
	var userId;
	
	function fnInitCtrlPop() {
		reqGroupId = sPopupOptions.groupId;
		tenantId   = sPopupOptions.tenantId;
		userId     = sPopupOptions.userId;
	}
	
	function callback(data, textStatus, jqXHR) {
		try{
			if(data.isOk()){
			var depth = data.SVCCOMMONID.rows.depth;
				$("#ip_Depth").val(fvCurRow.depth+depth);
			}
		} catch(e) {
			console.log(e);			
		}	
	}
	
	function groupIdCallback(data, textStatus, jqXHR) {
		try{
			if(data.isOk()){
				if(cudMode =='I') {
					var maxGroupId = data.SVCCOMMONID.rows.groupId;
					$("#ip_GroupId").val(maxGroupId);
					fnDetailInfoCallback();
				}else{
					fnDetailInfoCallback();
				}
			}
		} catch(e) {
			console.log(e);			
		}	
	}
	
	function fnSavePop(){
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
						 {"check":"length", "id":"ip_GroupName", "minLength":1, "maxLength":50, "msgLength":"그룹이름을 입력하세요."}
				        ,{"check":"length", "id":"ip_GroupDesc", "minLength":1, "maxLength":50, "msgLength":"그룹설명을 입력하세요."}
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
			 argoJsonSearchOne('Group', 'getMaxGroupId', 'ip_', {}, groupIdCallback);
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("Group", "setGroupInsert", "ip_", {"cudMode":cudMode});
			}else{
				$("#ip_UptId").val($("#ip_InsId").val());
				Resultdata = argoJsonUpdate("Group", "setGroupUpdate", "ip_", {"cudMode":cudMode});
			}
	
			if(Resultdata.isOk()) {	
			   	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
			}else {
			   	argoAlert("저장에 실패하였습니다");	 
			}
		} catch (e) {
			console.log(e);
		}
	}
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: false
	        },
	        multiSelect: false,
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'groupId', 		caption: '그룹ID', 		size: '10%', 	sortable: true, attr: 'align=center' }
						,{ field: 'depth', 		    caption: 'depth', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'groupNameTree',	caption: '그룹명', 		size: '45%', 	sortable: true, attr: 'align=left'   }
	            		,{ field: 'groupDesc', 		caption: '설명', 			size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'btnMove', 		caption: '하부이동', 		size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'btnChange', 		caption: '위치교환', 		size: '15%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid','depth');
	}
	
	function fnSearchList(){
		argoJsonSearchList('Group', 'getGroupList', 's_', {"findTenantId":tenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){
						dataArray = new Array();
						var subMove   = "";
						var subChange = "";
						var groupName = "";
						
						$.each(data.getRows(), function( index, row ) {
							subMove   = "";
							subChange = "";
							
							if ((row.groupId != reqGroupId) && (row.depth != "A"))
							{
								subChange = ' <button type="button" id="sub" class="btn_m grid" onclick="javascript:subChangePos(' + index + ');">교환</button>';
								subMove   = ' <button type="button" id="sub" class="btn_m grid" onclick="javascript:subMove(' + index + ');">이동</button>';
							}
							
							if (row.depthLen > 1) {
								groupName = '<pre>' + row.head + '<img src="../images/minusbottom.gif"><img src="../images/folder.gif">' + row.groupName + '</pre>' ;
							} else {
								groupName = row.groupName;
							}
							
							gObject2 = {  "recid" 			: index
					    				, "groupId"			: row.groupId
					    				, "depth"			: row.depth
					   					, "groupNameTree"	: groupName
										, "groupDesc" 		: row.groupDesc
										, "btnMove" 		: subMove
										, "btnChange" 		: subChange
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
		});
	}
	
	function subMove(idx){
	 	var toGroupId = w2ui['grid'].getCellValue(idx, 1);
	 	var toDepth   = w2ui['grid'].getCellValue(idx, 2);
	
		argoConfirm("이동 하시겠습니까?", function(){
			try {
				if(cudMode == "I"){
					Resultdata = argoJsonUpdate("Group", "setGroupInsert", "ip_", {"cudMode":cudMode});
				}else{
					$("#ip_UptId").val($("#ip_InsId").val());
					Resultdata = argoJsonUpdate("Group", "setGroupUpdate", "ip_", {"cudMode":cudMode});
				}
	
			    if(Resultdata.isOk()) {	
			    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
			    }else {
			    	argoAlert("저장에 실패하였습니다");	 
			    }
			} catch (e) {
				console.log(e);
			}
		});
	}
	
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
                <div class="input_area">
                	<div id="gridList" style="width: 100%; height: 540px;"></div>
                   	<input type="hidden" id="ip_TopParentId" name="ip_TopParentId" >
                   	<input type="hidden" id="ip_ParentId" name="ip_ParentId" >
                   	<input type="hidden" id="ip_Depth" name="ip_Depth" >
                   	<input type="hidden" id="ip_GroupId" name="ip_GroupId" >
                   	<input type="hidden" id="ip_InsId" name="ip_InsId" >
                   	<input type="hidden" id="ip_UptId" name="ip_UptId" >
                   	<input type="hidden" id="ip_TenantId" name="ip_TenantId" >
                   	<input type="hidden" id="ip_ValueTitleId" name="ip_ValueTitleId">
                   	<input type="hidden" id="ip_GroupMngId" name="ip_GroupMngId">
                </div>           
            </div>            
        </section>
    </div>
</body>

</html>
