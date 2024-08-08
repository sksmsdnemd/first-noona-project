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
	var workMenu 	= "리소스관리";
	var workLog 	= "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	function fnInitCtrl(){	
		
		argoCbCreate("s_FindSystemId", "sysGroup", "getSystemComboList", {sort_cd:'SYSTEM_ID'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindResCode", "baseCode", "getBaseComboList", {classId:'res_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
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
		 	argoPopupWindow('리소스등록', 'ResMonPopAddF.do', '500', '400');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});

		$("#btnReset").click(function(){
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$('#s_FindResCode option[value=""]').prop('selected', true);
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
					argoPopupWindow('리소스수정', 'ResMonPopAddF.do', '500', '400');
				}
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'sysGroupName', 	caption: '시스템그룹명', 			size: '12%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemId', 		caption: '시스템ID', 			size: '7%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemName', 	caption: '시스템명', 			size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resCodeName', 	caption: '리소스구분', 			size: '9%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resName', 		caption: '리소스코드', 			size: '13%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resDesc', 		caption: '리소스명', 			size: '11%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'alarmMinor', 	caption: 'Minor경고값(%)', 	size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'alarmMajor', 	caption: 'Major경고값(%)', 	size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'alarmCritical', 	caption: 'Critical경고값(%)', 	size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'sysGroupId', 	caption: 'sysGroupId', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resClass', 		caption: 'resClass', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resCode', 		caption: 'resCode', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resId', 			caption: 'resId', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resMax', 		caption: 'resMax', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resUsed', 		caption: 'resUsed', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'lastUpdate', 	caption: 'lastUpdate', 		size: '0%', 	sortable: true, attr: 'align=left'   }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'sysGroupId', 'resClass', 'resCode', 'resId', 'resMax', 'resUsed', 'lastUpdate');
	}
	
	function fnSearchListCnt(){
		
		if(argoGetValue('s_FindText') != ''){
			if(argoGetValue('s_FindKey') == ''){
				argoAlert("검색항목을 선택하세요.") ; 
		 		return ;
			}
		}

		argoJsonSearchOne('resMon', 'getResMonCount', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						var totalData = data.getRows()['cnt'];
						paging(totalData, "1");
						
						$("#totCount").text(totalData);
						
						if(totalData == 0){
							argoAlert('조회 결과가 없습니다.');
						}
						
						w2ui.grid.lock('조회중', true);
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function fnSearchList(startRow, endRow){

		argoJsonSearchList('resMon', 'getResMonList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {

							gObject2 = {  "recid" 			: index
					    				, "sysGroupId"		: row.sysGroupId
					   					, "systemId"		: row.systemId
										, "resClass" 		: row.resClass
										, "resCode" 		: row.resCode
										, "resName" 		: row.resName
										, "resId" 			: row.resId
										, "resMax" 			: row.resMax
										, "resUsed" 		: row.resUsed
										, "alarmCritical"	: row.alarmCritical
										, "alarmMajor" 		: row.alarmMajor
										, "alarmMinor" 		: row.alarmMinor
										, "lastUpdate" 		: row.lastUpdate
										, "systemName" 		: row.systemName
										, "resCodeName" 	: row.resCodeName
										, "sysGroupName" 	: row.sysGroupName
										, "resDesc" 		: row.resDesc
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
	
	var sysGroupId 	= "";
	var systemId 	= "";
	var resClass 	= "";
	var resCode 	= "";
	var resName 	= "";
	
	function fnDeleteList(){
		
		try{
			var arrChecked = w2ui['grid'].getSelection();

		 	if(arrChecked.length == 0) {
		 		argoAlert("삭제할 리소스를 선택하세요") ; 
		 		return ;
		 	}

			argoConfirm('선택한 리소스 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				
				$.each(arrChecked, function( index, value ) {
					
					sysGroupId 	= w2ui['grid'].getCellValue(value, 10);
					systemId 	= w2ui['grid'].getCellValue(value, 2);
					resClass 	= w2ui['grid'].getCellValue(value, 11);
					resCode 	= w2ui['grid'].getCellValue(value, 12);
					resName 	= w2ui['grid'].getCellValue(value, 5);

					var param = { 
									 "sysGroupId" 	: sysGroupId
									,"systemId" 	: systemId
									,"resClass"  	: resClass
									,"resCode"   	: resCode
									,"resName"   	: resName
					};

					multiService.argoDelete("resMon", "setResMonDelete", "__", param);
					
					workLog = '[시스템그룹:' + sysGroupId + ' | 시스템ID:' + systemId + ' | 리소스코드:' + resCode + ' | 리소스명:' + resName+ '] 삭제';
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
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템설정관리</span><strong class="step">리소스관리</strong></div>
        <section class="sub_contents">
            <div class="search_area">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">시스템</strong>
                            <select id="s_FindSystemId" name="s_FindSystemId" style="width:300px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title">리소스구분</strong>
                            <select id="s_FindResCode" name="s_FindResCode" style="width:300px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">검색</strong>
                            <select id="s_FindKey" name="s_FindKey" style="width: 117px" class="list_box">
								<option value="">선택하세요!</option>
								<option value="a.res_name">리소스명</option>
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