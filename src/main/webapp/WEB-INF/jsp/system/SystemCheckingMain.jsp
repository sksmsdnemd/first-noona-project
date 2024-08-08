<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>-->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "시스템별현황";
	var workLog 	= "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();

	});

	function fnInitCtrl(){		
		argoCbCreate("s_FindSystemId", "comboBoxCode", "getSystemId", {sort_cd:'SYSTEM_NAME'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindSysName", "comboBoxCode", "getSystemName", {sort_cd:'SYSTEM_NAME'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnAuthBtnChk(parent.$("#authKind").val());
				
		$("#btnSearch").click(function(){ //조회	
			fnSearchList();
		});
		
		$("#s_FindKey").change(function(){
			var sSel = argoGetValue('s_FindKey');
			if(sSel == ""){
				$("#s_FindText").val("");
			}
		});
		
		$("#btnAdd").click(function(){
			gPopupOptions = {cudMode:"I"} ;   	
		 	argoPopupWindow('시스템그룹등록', 'SysInfoPopAddF.do', '680', '345');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});	

		$("#btnReset").click(function(){
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$("#s_FindSysName").find("option").remove();
			
		});
		
		$("#s_FindSystemId").change(function(){
			if($('#s_FindSystemId option:selected').val() == ''){
				$("#s_FindSysName").find("option").remove();
			}else{
				argoCbCreate("s_FindSysName", "comboBoxCode", "getSystemName", {findSystemId:$('#s_FindSystemId option:selected').text()});
			}	
	 	});
		
		$("#btnExcel").click(function(){
			var excelArray = new Array();
			
			argoJsonSearchList('sysCheck', 'getSummarySystem', 's_', {"iSPageNo":100000000, "iEPageNo":100000000}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {
							
							gObject = {   "번호" 			: index+1
										, "시스템아이디"		: row.systemId
					    				, "시스템명"		: row.systemName
					    				, "시스템_IP"		: row.systemIp
										, "리소스코드명" 		: row.codeName
										, "리소스명" 		: row.resName
										, "전체사용량" 		: row.resTotal
										, "사용량" 		: row.resUsed
										, "사용률(%)" 		: row.useMaxPercent
										, "최대값시작시간" 	: row.regTimeMin
										, "최대값종료시간" 	: row.regTimeMax
									};
										
							excelArray.push(gObject);
						});
						
						gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
						argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
					}
				} catch (e) {
					console.log(e);
				}
			});
		});	
	}

	function fnInitGrid(){

		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true
	        },
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 			caption: '번호', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemId', 		caption: '시스템ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemName', 	caption: '시스템명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'systemIp', 		caption: '시스템_IP', 		size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'codeName', 		caption: '리소스코드명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resName', 		caption: '리소스명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resTotal', 		caption: '전체용량', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resUsed', 	    caption: '사용량', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'useMaxPercent', 	caption: '사용률(%)', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'regTimeMin', 	caption: '최대값시작시간', 	size: '13%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'regTimeMax', 	caption: '최대값종료시간', 	size: '13%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid');
	}
	
	function fnSearchList(){
		
		w2ui.grid.lock('조회중', true);

		argoJsonSearchList('sysCheck', 'getSummarySystem', 's_', {}, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {

							gObject2 = {  "recid" 			: index
										, "systemId"		: row.systemId
					    				, "systemName"		: row.systemName
					    				, "systemIp"		: row.systemIp
										, "codeName" 		: row.codeName
										, "resName" 		: row.resName
										, "resTotal" 		: row.resTotal
										, "resUsed" 		: row.resUsed
										, "useMaxPercent" 	: row.useMaxPercent
										, "regTimeMin" 		: row.regTimeMin
										, "regTimeMax" 		: row.regTimeMax
										};
										
							dataArray.push(gObject2);
						});
						
						w2ui['grid'].add(dataArray);
					}else{
						argoAlert('조회 결과가 없습니다.');
					}
				}
				w2ui.grid.unlock();
			} catch (e) {
				console.log(e);
			}
		});
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템점검</span><strong class="step">시스템별현황</strong></div>
        <section class="sub_contents">
            <div class="search_area">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">시스템아이디</strong>
                            <select id="s_FindSystemId" name="s_FindSystemId" style="width:300px;" class="list_box">
                                <option>선택하세요!</option>
                            </select>
                        </li> 
                        <li>
                            <strong class="title ml20">시스템명</strong>
                            <select id="s_FindSysName" name="s_FindSysName" style="width:300px;" class="list_box" disabled>
                                <option>선택하세요!</option>
                            </select>
                        </li>                    
                    </ul>
                </div>
            </div>
            <div class="btns_top">
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <!-- <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E" style="display: none;">Excel Export</button> -->
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