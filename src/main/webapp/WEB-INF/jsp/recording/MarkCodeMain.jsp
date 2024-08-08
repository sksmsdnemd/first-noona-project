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
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 	  = loginInfo.SVCCOMMONID.rows.userId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var workMenu  = "마킹정보관리";
	var workLog   = "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});
	
	function fnInitCtrl(){	
		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);

		$("#btnSearch").click(function(){ //조회
			fnSearchList();			
		});
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
		
		$("#btnAdd").click(function(){ 
			if($("#s_FindTenantId").val() == ""){
				argoAlert("태넌트를 선택한 후 등록 하여 주십시오.");
				return;
			}
			gPopupOptions = {cudMode:"I", tenantId:$("#s_FindTenantId").val()}; 
			
		 	argoPopupWindow('마킹정보등록', 'MarkCodePopAddF.do', '550', '310');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});		

		$("#btnReset").click(function(){
			$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
			$("#s_FindText").val('');
		});
		
		$('#s_FindText').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
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
					gPopupOptions = {cudMode:'U', pRowIndex:record};
					argoPopupWindow('마킹정보수정', 'MarkCodePopAddF.do', '550', '310');
				}
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'tenantId', 		caption: 'tenantId', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'markingId', 		caption: '마킹ID', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'markingClass', 	caption: '마킹분류명', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'markingColor', 	caption: '마킹색상코드', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'markingDesc', 	caption: '마킹설명', 		size: '40%', 	sortable: true, attr: 'align=center' }
	            		
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'tenantId');
	}
	
	var totCnt = 0;

	function fnSearchList(){

		argoJsonSearchList('recordFile', 'getMarkCodeList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();

					if(data.getRows() != ""){
						totCnt = data.getRows().length;
						$("#totCount").text(totCnt);
						
						if(totCnt == 0){
							argoAlert('조회 결과가 없습니다.');
						}
						
						dataArray = [];		
						$.each(data.getRows(), function( index, row ) {

							gObject2 = {  "recid" 			: index
					    				, "tenantId"		: row.tenantId
					   					, "markingId"		: row.markingId
										, "markingClass" 	: row.markingClass
										, "markingColor"	: row.markingColor
										, "markingDesc" 	: row.markingDesc
										, w2ui: {"style": "background-color: #" + row.markingColor }
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
	
	function fnDeleteList(){
		
 		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("삭제할 마킹정보를 선택하세요"); 
		 		return ;
			}

			argoConfirm('선택한 마킹정보 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				var tenant = "";
				var markId = "";

				$.each(arrChecked, function( index, value ) {
					
					tenant = w2ui['grid'].getCellValue(value, 1);
					markId = w2ui['grid'].getCellValue(value, 2);
					
					var param = { 
									"tenantId" 	: tenant, 
									"markingId"	: markId
								};

					multiService.argoDelete("recordFile", "setMarkCodeDelete", "__", param);
					
					workLog = '[태넌트:' + tenant + ' | 마킹ID:' + markId + '] 삭제';
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
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
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><strong class="step">마킹정보관리</strong></div>
        <section class="sub_contents">
            <div class="search_area">
            	<div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width:200px" class="list_box"></select>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">마킹분류</strong>
							<input type="text"	id="s_FindText" name="s_FindText" style="width:200px"/>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
                <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 415px;"></div>
                </div>
	        </div>
        </section>
    </div>
</body>

</html>