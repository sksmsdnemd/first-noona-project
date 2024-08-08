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

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 	  = loginInfo.SVCCOMMONID.rows.userId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "프로세스관리";
	var workLog   = "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
		
	});
	
	function fnInitCtrl(){	
		
		argoCbCreate("s_FindSystemId", "sysGroup", "getSysCbList", {sort_cd:'SYSTEM_ID'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindProcessCode", "baseCode", "getBaseComboList", {classId:'process_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
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
		 	argoPopupWindow('프로세스등록', 'ProcInfoPopAddF.do', '900', '600');
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});

		$("#btnReset").click(function(){
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$('#s_FindProcessCode option[value=""]').prop('selected', true);
			$('#s_FindKey option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
		});
		
		$('#s_FindText').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		
		$('#btnStart').click(function(){
			alert("프로세스 시작");
		});
		
		$('#btnKill').click(function(){
			alert("프로세스 중단");
		});
		
		$('#btnRestart').click(function(){
			alert("프로세스 다시시작");
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
					//console.log("TEST");
					//console.log(record);
					gPopupOptions = {cudMode:'U', pRowIndex:record} ;   
					
					argoPopupWindow('프로세스수정', 'ProcInfoPopAddF.do',  '900', '600' ); 
				}
	        },
			
			
			
			/**/
	        columns: [  
						 { field: 'recid', 			  caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'processStatus', 	  caption: '상태', 			size: '5%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'sysGroupName', 	  caption: '시스템그룹', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemId', 	      caption: '시스템ID', 		size: '7%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'systemName', 	  caption: '시스템명', 			size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'processId', 		  caption: '프로세스ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'portIdx', 		  caption: '순번', 			size: '4%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'processName', 	  caption: '프로세스명', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'processCodeName',  caption: '구분', 			size: '5%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'procVer', 		  caption: '프로세스버전',		size: '12%', 	sortable: true, attr: 'align=left'   }
	            	 	,{ field: 'slaveSystemName',  caption: 'Slave시스템', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'slaveProcessName', caption: 'Slave프로세스', 	size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processParam', 	  caption: '파라미터', 			size: '12%', 	sortable: true, attr: 'align=left'   }
	            	 	,{ field: 'sysGroupId', 	  caption: 'sysGroupId', 	size: '0%', 	sortable: true, attr: 'align=center' }           	 	
	            		,{ field: 'slaveSystemId', 	  caption: 'slaveSystemId', size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'slaveProcessId',   caption: 'slaveProcessId',size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processClass', 	  caption: 'processClass', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processCode', 	  caption: 'processCode', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'useFlag', 		  caption: 'useFlag', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'alarmFlag', 		  caption: 'alarmFlag', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'iniContent', 	  caption: 'iniContent', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processDesc', 	  caption: 'processDesc', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'insId', 			  caption: 'insId', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'insDate', 		  caption: 'insDate', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'uptId', 			  caption: 'uptId', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'paramSet', 		  caption: '설정', 			size: '4%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });

		w2ui['grid'].hideColumn('recid', 'sysGroupId', 'slaveSystemId', 'slaveProcessId', 'processClass', 'processCode'
								, 'useFlag', 'alarmFlag', 'iniContent', 'processDesc', 'insId', 'insDate', 'uptId');
		if(grantId != "SuperAdmin" && grantId != "SystemAdmin"){
			w2ui['grid'].hideColumn('paramSet');
		}
	}
	
	function fnSearchListCnt(){
		
		if(argoGetValue('s_FindText') != ''){
			if(argoGetValue('s_FindKey') == ''){
				argoAlert("검색항목을 선택하세요.") ; 
		 		return ;
			}
		}

		argoJsonSearchOne('procInfo', 'getProcInfoCount', 's_', {}, function (data, textStatus, jqXHR){
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
	
	var processStatus	= "on";
	
	function fnSearchList(startRow, endRow){

		argoJsonSearchList('procInfo', 'getProcInfoList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					var btnHtml = "";
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							btnHtml = '<a href="javascript:fnParamSet(' + index + ');"><img src="../images/icon_code.png"></a>';
							
							
							var processIcon	= '<img src="../images/icons/process_' + processStatus + '.gif">'
							

							gObject2 = {  "recid" 			: index
										, "processStatus"   : processIcon
					    				, "sysGroupName"	: row.sysGroupName
					   					, "systemName"		: row.systemName
										, "processId" 		: row.processId
										, "portIdx" 		: row.portIdx
										, "processName" 	: row.processName
										, "processCodeName" : row.processCodeName
										, "procVer" 		: row.procVer
										, "slaveSystemName" : row.slaveSystemName
										, "slaveProcessName": row.slaveProcessName
										, "processParam" 	: row.processParam
										, "sysGroupId" 		: row.sysGroupId
										, "systemId" 		: row.systemId
										, "slaveSystemId" 	: row.slaveSystemId
										, "slaveProcessId" 	: row.slaveProcessId
										, "processClass" 	: row.processClass
										, "processCode" 	: row.processCode
										, "useFlag" 		: row.useFlag
										, "alarmFlag" 		: row.alarmFlag
										, "iniContent" 		: row.iniContent
										, "processDesc" 	: row.processDesc
										, "insId" 			: row.insId
										, "insDate" 		: row.insDate
										, "uptId" 			: row.uptId
										, "paramSet" 		: btnHtml
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
	
	var sysGroupId = "";
	var systemId   = "";
	var processId  = "";
	
	function fnDeleteList(){
		
		try{
			var arrChecked = w2ui['grid'].getSelection();

		 	if(arrChecked.length == 0){
				argoAlert("삭제할 프로세스를 선택하세요"); 
		 		return ;
			}

			argoConfirm('선택한 프로세스 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				
				$.each(arrChecked, function( index, value ) {
					
					sysGroupId = w2ui['grid'].getCellValue(value, 13);
					systemId   = w2ui['grid'].getCellValue(value, 3);
					processId  = w2ui['grid'].getCellValue(value, 5);
					
					var param = { 
									 "sysGroupId" 	: sysGroupId
									,"systemId"  	: systemId
									,"processId" 	: processId
								};

					multiService.argoDelete("procInfo", "setProcInfoDelete", "__", param);
					
					workLog = '[시스템그룹:' + sysGroupId + ' | 시스템ID:' + systemId + ' | 프로세스ID:' + processId + '] 삭제';
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
	
	function fnParamSet(idx){
				var sysGroupId 	= w2ui['grid'].getCellValue(idx, 13);
		var systemId 	= w2ui['grid'].getCellValue(idx, 3);
		var procId 		= w2ui['grid'].getCellValue(idx, 5);
		var procNm 		= w2ui['grid'].getCellValue(idx, 7);
		var sysGroupId 	= w2ui['grid'].getCellValue(idx, 13);
		var procCd 		= w2ui['grid'].getCellValue(idx, 17);
		
		

		gPopupOptions = {cudMode:"U", procId:procId, procNm:procNm, procCd:procCd, sysGroupId:sysGroupId, systemId:systemId};
		//console.log(gPopupOptions);
	 	argoPopupWindow('프로세스 환경 정보 설정', 'ProcInfoParamAddF.do', '1000', '600');
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템설정관리</span><strong class="step">프로세스관리</strong></div>
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
                            <strong class="title">프로세스구분</strong>
                            <select id="s_FindProcessCode" name="s_FindProcessCode" style="width:300px;" class="list_box">
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
								<option value="a.process_name">프로세스명</option>
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
                <!-- <button type="button" id="btnStart" class="btn_m confirm">시작</button>
                <button type="button" id="btnKill" class="btn_m confirm">중지</button>
                <button type="button" id="btnRestart" class="btn_m confirm">다시시작</button>  -->
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