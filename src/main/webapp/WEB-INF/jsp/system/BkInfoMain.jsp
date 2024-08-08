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
	var workMenu 	= "백업장치관리";
	var workLog 	= "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	function fnInitCtrl(){	
		
		argoCbCreate("s_FindSystemId", "sysInfo", "getSysInfoByProcCbList", {findProcessCode:'61', useFlag:'0'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindProcessId", "procInfo", "getProcSlaveComboList", {findProcessCode:'61'},{"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindMediaKind", "baseCode", "getBaseComboList", {classId:'media_kind'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindBkStatus", "baseCode", "getBaseComboList", {classId:'bk_status'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindBkDevice", "baseCode", "getBaseComboList", {classId:'bk_device'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnAuthBtnChk(parent.$("#authKind").val());

		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});
		
		$("#s_FindKey").change(function(){
			var sSel = argoGetValue('s_FindKey');
			if(sSel == ""){
				$("#s_FindText").val("");
			}
		});
		
		$("#btnAdd").click(function(){
			gPopupOptions = {cudMode:"I"} ;   	
			argoPopupWindow('백업장치등록', 'BkInfoPopAddF.do', '900', '600');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});

		$("#btnReset").click(function(){
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$('#s_FindProcessId option[value=""]').prop('selected', true);
			$('#s_FindMediaKind option[value=""]').prop('selected', true);
			$('#s_FindBkStatus option[value=""]').prop('selected', true);
			$('#s_FindBkDevice option[value=""]').prop('selected', true);
			$('#s_FindKey option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
		});
		
		$('#s_FindText').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
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
	        	if(record.recid >= 0) {
					gPopupOptions = {cudMode:'U', pRowIndex:record} ;   	
					argoPopupWindow('백업장치수정', 'BkInfoPopAddF.do', '900', '600');
				}
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 			size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'systemId', 		caption: '시스템ID', 			size: '7%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemName', 	caption: '시스템명', 			size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processName', 	caption: '프로세스명', 			size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaKindName', 	caption: '백업미디어', 			size: '9%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkStatusName', 	caption: '실행상태', 			size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'storageDay', 	caption: '보존일(단위:일)', 		size: '11%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkDate', 		caption: '백업날짜', 			size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDate', 		caption: '삭제날짜', 			size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkDirectory', 	caption: '백업디렉토리', 			size: '17%', 	sortable: true, attr: 'align=left'   }
	            		,{ field: 'gubunState', 	caption: '분류상태', 	size: '6%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processId', 		caption: 'processId', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaKind', 		caption: 'mediaKind', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkDevice', 		caption: 'bkDevice', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkKind', 		caption: 'bkKind', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkStatus', 		caption: 'bkStatus', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaFreeSpace', caption: 'mediaFreeSpace', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkPreventDate', 	caption: 'bkPreventDate', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkQuery', 		caption: 'bkQuery', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkDirectory2', 	caption: 'bkDirectory2', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkLabelHeader', 	caption: 'bkLabelHeader', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkTimeStart', 	caption: 'bkTimeStart', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkTimeEnd', 		caption: 'bkTimeEnd', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkFilesMax', 	caption: 'bkFilesMax', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delFilesMax', 	caption: 'delFilesMax', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'processId', 'mediaKind', 'bkDevice', 'bkKind', 'bkStatus', 'mediaFreeSpace', 'bkPreventDate', 'bkQuery'
				,'bkDirectory2', 'bkLabelHeader', 'bkTimeStart', 'bkTimeEnd', 'bkFilesMax', 'delFilesMax');
	}
	
	function fnSearchListCnt(){
		
		if(argoGetValue('s_FindText') != ''){
			if(argoGetValue('s_FindKey') == ''){
				argoAlert("검색항목을 선택하세요.") ; 
		 		return ;
			}
		}

		argoJsonSearchOne('bkInfo', 'getBkInfoCount', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");

					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
					w2ui.grid.lock('조회중', true);
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function fnSearchList(startRow, endRow){

		argoJsonSearchList('bkInfo', 'getBkInfoList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {

							gObject2 = {  "recid" 			: index
					    				, "systemName"		: row.systemName
					   					, "processName"		: row.processName
										, "mediaKindName" 	: row.mediaKindName
										, "bkStatusName" 	: row.bkStatusName
										, "storageDay" 		: row.storageDay
										, "bkDate" 			: fnStrMask("YMD", row.bkDate)
										, "delDate" 		: fnStrMask("YMD", row.delDate)	
										, "bkDirectory" 	: row.bkDirectory
										, "systemId" 		: row.systemId
										, "processId" 		: row.processId
										, "mediaKind" 		: row.mediaKind
										, "bkDevice" 		: row.bkDevice
										, "bkKind" 			: row.bkKind
										, "bkStatus" 		: row.bkStatus
										, "mediaFreeSpace" 	: row.mediaFreeSpace
										, "bkPreventDate" 	: row.bkPreventDate
										, "bkQuery" 		: row.bkQuery
										, "bkDirectory2" 	: row.bkDirectory2
										, "bkLabelHeader" 	: row.bkLabelHeader
										, "bkTimeStart" 	: row.bkTimeStart
										, "bkTimeEnd" 		: row.bkTimeEnd
										, "bkFilesMax" 		: row.bkFilesMax
										, "delFilesMax" 	: row.delFilesMax
										, "gubunState" 	: row.gubunState
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
	
	var systemId  = "";
	var processId = "";
	var mediaKind = "";
	
	function fnDeleteList(){
		try{
			var arrChecked = w2ui['grid'].getSelection();
			
		 	if(arrChecked.length == 0) {
		 		argoAlert("삭제할 백업장치를 선택하세요") ; 
		 		return ;
		 	}

			argoConfirm('선택한 백업장치 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				
				$.each(arrChecked, function( index, value ) {
					
					systemId  = w2ui['grid'].getCellValue(value, 1);
					processId = w2ui['grid'].getCellValue(value, 10);
					mediaKind = w2ui['grid'].getCellValue(value, 11);

					var param = { 
									 "systemId"		: systemId
									,"processId" 	: processId
									,"mediaKind" 	: mediaKind
								};

					multiService.argoDelete("bkInfo", "setBkInfoDelete", "__", param);
					
					workLog = '[시스템ID:' + systemId + ' | 프로세스ID:' + processId + ' | 백업미디어:' + mediaKind + '] 삭제';
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
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">백업관리</span><strong class="step">백업장치관리</strong></div>
        <section class="sub_contents">
            <div class="search_area">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">시스템</strong>
                            <select id="s_FindSystemId" name="s_FindSystemId" style="width:200px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title">프로세스</strong>
                            <select id="s_FindProcessId" name="s_FindProcessId" style="width:200px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title">백업미디어</strong>
                            <select id="s_FindMediaKind" name="s_FindMediaKind" style="width:150px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">실행상태</strong>
                            <select id="s_FindBkStatus" name="s_FindBkStatus" style="width:200px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title">백업장치</strong>
                            <select id="s_FindBkDevice" name="s_FindBkDevice" style="width:200px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title">검색</strong>
                            <select id="s_FindKey" name="s_FindKey" style="width:150px;" class="list_box">
                            	<option value="">선택하세요!</option>
								<option value="a.bk_directory">백업디렉토리</option>
								<option value="a.bk_directory_2">백업디렉토리2</option>
                            </select>
                            <input type="text"	id="s_FindText" name="s_FindText" style="width:180px"/>
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