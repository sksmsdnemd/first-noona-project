<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId	  = loginInfo.SVCCOMMONID.rows.userId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 	  = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "현재장애로그조회";
	var workLog   = "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	function fnInitCtrl(){
		
		argoSetDatePicker();
		$('.timepicker.rec').timeSelect({use_sec:true});
		
		fnArogoSetting();
		
		argoCbCreate("s_FindSystemId", "sysGroup", "getSystemComboList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindProcessId", "procInfo", "getProcSlaveComboList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindErrType", "baseCode", "getBaseComboList", {classId:'errtype_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindErrGrade", "baseCode", "getBaseComboList", {classId:'errgrade_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnAuthBtnChk(parent.$("#authKind").val());

		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});

		$("#btnReset").click(function(){
			
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$('#s_FindProcessId option[value=""]').prop('selected', true);
			$('#s_FindErrType option[value=""]').prop('selected', true);
			$('#s_FindErrGrade option[value=""]').prop('selected', true);
			$('#s_FindKey option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
			
			fnArogoSetting();
		});

		$('#s_FindText').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		
		$("#btnDelete").click(function(){
			fnDeleteList();
		});
		
		$("#btnExcel").click(function(){
			var excelArray = new Array();
			argoJsonSearchList('errCode','getCurErrList','s_', {"iSPageNo":100000000, "iEPageNo":100000000}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {

							gObject = {   "순번" 		: index + 1
					    				, "장애코드"	: row.errCode
					   					, "장애구분"	: row.errTypeName
										, "장애등급" 	: row.errGradeName
										, "시스템명" 	: row.systemName
										, "프로세스명" 	: row.processName
										, "발생일" 	: fnStrMask("DHMS", row.errDate)
										, "장애메시지" 	: row.errMsg
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
	
	function fnArogoSetting(){

		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}];
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		argoSetValue("s_FindSRegTime", "00:00:00");
		argoSetValue("s_FindERegTime", "23:59:59");
		$('#selDateTerm1 option[value="T_0"]').prop('selected', true);
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
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'errCode', 		caption: '장애코드', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'errTypeName', 	caption: '장애구분', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'errGradeName', 	caption: '장애등급', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'systemName', 	caption: '시스템명', 		size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processName', 	caption: '프로세스명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'errDate', 		caption: '발생일', 		size: '16%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'errMsg', 		caption: '장애메시지', 		size: '38%', 	sortable: true, attr: 'align=left'   }
	            		,{ field: 'errKey', 		caption: 'errKey', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'errType', 		caption: 'errType', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'errGrade', 		caption: 'errGrade', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'systemId', 		caption: 'systemId', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'processId', 		caption: 'processId', 	size: '0%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'errKey', 'errType', 'errGrade', 'systemId', 'processId');
	}
	
	function fnSearchListCnt(){

		argoSetValue("s_FindSErrDate", $("#s_txtDate1_From").val().replace(/-/gi,"") + $("#s_FindSRegTime").val().replace(/:/gi,""));
		argoSetValue("s_FindEErrDate", $("#s_txtDate1_To").val().replace(/-/gi,"") + $("#s_FindERegTime").val().replace(/:/gi,""));

		argoJsonSearchOne('errCode', 'getCurErrCount', 's_', {}, function (data, textStatus, jqXHR){
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

		argoSetValue("s_FindSErrDate", $("#s_txtDate1_From").val().replace(/-/gi,"") + $("#s_FindSRegTime").val().replace(/:/gi,""));
		argoSetValue("s_FindEErrDate", $("#s_txtDate1_To").val().replace(/-/gi,"") + $("#s_FindERegTime").val().replace(/:/gi,""));

		argoJsonSearchList('errCode', 'getCurErrList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							gObject2 = {  "recid" 			: index
					    				, "errCode"			: row.errCode
					   					, "errTypeName"		: row.errTypeName
										, "errGradeName" 	: row.errGradeName
										, "systemName" 		: row.systemName
										, "processName" 	: row.processName
										, "errDate" 		: fnStrMask("DHMS", row.errDate)
										, "errMsg" 			: row.errMsg
										, "errKey" 			: row.errKey
										, "errType" 		: row.errType
										, "errGrade" 		: row.errGrade
										, "systemId" 		: row.systemId
										, "processId" 		: row.processId
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
	
	function fnDeleteList(){
		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length==0) {
		 		argoAlert("삭제할 장애로그를 선택하세요") ; 
		 		return ;
		 	}
			
			argoConfirm('선택한 장애로그 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				
				$.each(arrChecked, function( index, value ) {
					
					errKey    = w2ui['grid'].getCellValue(value, 8);
					errCode   = w2ui['grid'].getCellValue(value, 1);
					systemId  = w2ui['grid'].getCellValue(value, 11);
					processId = w2ui['grid'].getCellValue(value, 12);

					argoJsonSearchList('comboBoxCode', 'getOsuIpList', 's_', {"updateType":"N", "errKey":errKey, "systemId":systemId, "processId":processId}, function (data, textStatus, jqXHR){
						try{
							if(data.isOk()){
								if(data.getRows() != ""){
									
								}
							}
						} catch(e) {
							console.log(e);			
						}
					});
				});
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
        <div class="location"><span class="location_home">HOME</span><span class="step">장애관리</span><strong class="step">현재장애로그조회</strong></div>
        <section class="sub_contents">
            <div class="search_area row3">
                <div class="row">
                    <ul class="search_terms">
                    	<li style="width:345px">
                    		<strong class="title ml20">시스템</strong>
                            <select id="s_FindSystemId" name="s_FindSystemId" style="width:200px;" class="list_box">
                            </select>
						</li>
						<li style="width:345px">
                            <strong class="title">프로세스명</strong>
                            <select id="s_FindProcessId" name="s_FindProcessId" style="width:200px;" class="list_box"></select>
						</li>
                        <li>
                            <strong class="title">검색</strong>
                            <select id="s_FindKey" name="s_FindKey" style="width:117px" class="list_box">
                            	<option value="">선택하세요!</option>
								<option value="a.err_code" >장애코드</option>
								<option value="a.err_msg" >장애메시지</option>
							</select>
							<input type="text"	id="s_FindText" name="s_FindText" class="InputReadL" style="width:150px"/>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li style="width:345px">
                            <strong class="title ml20">장애구분</strong>
                            <select id="s_FindErrType" name="s_FindErrType" style="width:200px;" class="list_box">
                            </select>                   
                        </li>
                        <li>
                        	<strong class="title">장애등급</strong>
                            <select id="s_FindErrGrade" name="s_FindErrGrade" style="width:200px;" class="list_box">
                            </select>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">장애발생일</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                            <span class="timepicker rec" id="rec_time1"><input type="text" id="s_FindSRegTime" name="s_FindSRegTime" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
							<span class="text_divide">~</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                            <span class="timepicker rec" id="rec_time2"><input type="text" id="s_FindERegTime" name="s_FindERegTime" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                            <select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
                        </li>
                    </ul>
                </div>
            </div>     
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
<!--                 <button type="button" id="btnDelete" class="btn_m confirm">삭제</button> -->
                <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
                <input type="hidden" id="s_FindSErrDate" name="s_FindSErrDate" >
                <input type="hidden" id="s_FindEErrDate" name="s_FindEErrDate" >
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