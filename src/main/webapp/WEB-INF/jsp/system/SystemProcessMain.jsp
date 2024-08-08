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
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "프로세스정보";
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
		argoCbCreate("s_FindProcessId", "comboBoxCode", "getProcessId", {sort_cd:'PROCESS_NAME'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindProcessName", "comboBoxCode", "getProcessName", {sort_cd:'PROCESS_NAME'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
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
			$('#s_FindProcessId option[value=""]').prop('selected', true);
			$("#s_FindProcessName").find("option").remove();
			$('#s_FindActFalg option[value=""]').prop('selected', true);
		});
		
		$("#s_FindSystemId").change(function(){
			if($('#s_FindSystemId option:selected').val() == ''){
				$("#s_FindSysName").find("option").remove();
			}else{
				argoCbCreate("s_FindSysName", "comboBoxCode", "getSystemName", {findSystemId:$('#s_FindSystemId option:selected').text()});
			}	
	 	});
		
		$("#s_FindProcessId").change(function(){
			if($('#s_FindProcessId option:selected').val() == ''){
				$("#s_FindProcessName").find("option").remove();
			}else{
				argoCbCreate("s_FindProcessName", "comboBoxCode", "getProcessName", {findProcessId:$('#s_FindProcessId option:selected').text()});
			}	
	 	});
		
		$("#btnExcel").click(function(){
			var excelArray = new Array();
			
			argoJsonSearchList('sysCheck', 'getSummaryProcess', 's_', {"iSPageNo":100000000, "iEPageNo":100000000}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {
							
							gObject = {   "번호" 			: index+1
										, "시스템아이디"		: row.systemId
					    				, "시스템명"		: row.systemName
										, "프로세스아이디" 	: row.processId
										, "프로세스명" 		: row.processName
										, "프로세스버전" 		: row.procVer
										, "포트인덱스" 		: row.mrsPortIdx
										, "Active 여부" 	: row.actFlag
										, "오류횟수" 		: row.errCnt
										, "MRU녹취건수" 	: row.mruRecCnt
										, "MTU변환수"		: row.mtuRecCnt
										, "MFU청취수"		: row.mfuCnt
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
	            	 	,{ field: 'systemId', 		caption: '시스템ID', 		size: '7%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemName', 	caption: '시스템명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processId', 		caption: '프로세스ID',  	size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processName', 	caption: '프로세스명', 		size: '9%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'procVer', 		caption: '프로세스버전', 		size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mrsPortIdx', 	caption: '포트인덱스', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'actFlag', 	    caption: 'Active여부', 	size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'errCnt', 	    caption: '오류횟수', 		size: '7%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mruRecCnt', 		caption: 'MRU녹취건수', 	size: '9%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mtuRecCnt', 		caption: 'MTU변환횟수', 	size: '9%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mfuCnt', 		caption: 'MFU청취수', 		size: '8%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid');
	}
	
	function fnSearchList(){
		
		w2ui.grid.lock('조회중', true);

		argoJsonSearchList('sysCheck', 'getSummaryProcess', 's_', {}, function(data, textStatus, jqXHR) {
			try {
				var cnt = data.SVCCOMMONID.procCnt;
				
				if(cnt < 5){
					$("#gridList").css("height", "315px");
					
				}else{
					$("#gridList").css("height", "615px");
				}
				
				if (data.isOk()) {
					w2ui.grid.clear();
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {

							gObject2 = {  "recid" 			: index
										, "systemId"		: row.systemId
					    				, "systemName"		: row.systemName
										, "processId" 		: row.processId
										, "processName" 	: row.processName
										, "procVer" 		: row.procVer
										, "mrsPortIdx" 		: row.mrsPortIdx
										, "actFlag" 		: row.actFlag
										, "errCnt" 			: row.errCnt
										, "mruRecCnt" 		: row.mruRecCnt
										, "mtuRecCnt"		: row.mtuRecCnt
										, "mfuCnt"			: row.mfuCnt
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
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템점검</span><strong class="step">프로세스정보</strong></div>
        <section class="sub_contents">
            <div class="search_area row3">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20" style="width: 85px">시스템아이디</strong>
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
                  <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">프로세스아이디</strong>
                            <select id="s_FindProcessId" name="s_FindProcessId" style="width:300px;" class="list_box">
                                <option>선택하세요!</option>
                            </select>
                        </li> 
                        <li>
                            <strong class="title ml20">프로세스명</strong>
                            <select id="s_FindProcessName" name="s_FindProcessName" style="width:300px;" class="list_box" disabled>
                                <option>선택하세요!</option>
                            </select>
                        </li> 
                    </ul>
                     <div class="row">
                    	<ul class="search_terms">
                    		<li>
	                            <strong class="title ml20" style="width: 85px">ACTIVE 여부</strong>
	                            <select id="s_FindActFalg" name="s_FindActFalg" style="width:300px;" class="list_box" >
	                                <option value="">선택하세요!</option>
	                                <option value="0">STD</option>
	                                <option value="1">ACT</option>
	                            </select>
                        	</li>     
                    	</ul>
                    </div>
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
	                <div id="gridList" style="width: 100%; height: 615px;"></div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>