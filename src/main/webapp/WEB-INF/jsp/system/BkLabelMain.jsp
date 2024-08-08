<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "백업레이블관리";
	var workLog 	= "";

	var dataArray 	= new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	function fnInitCtrl(){	

		argoSetDatePicker();
		
		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		
		fnAuthBtnChk(parent.$("#authKind").val());

		$('.timepicker.rec').timeSelect({use_sec:true});
		
		argoSetValue("s_txtDate1_From", "");
		argoSetValue("s_txtDate1_To", "");
		argoSetValue("s_RecFrmTm", "");
		argoSetValue("s_RecEndTm", "");
		
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
			
		});	

		$("#btnDelete").click(function(){
			fnDeleteList();
		});

		$("#btnReset").click(function(){
			$('#s_FindKey option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
			argoSetValue("s_txtDate1_From", "");
			argoSetValue("s_txtDate1_To", "");
			argoSetValue("s_RecFrmTm", "");
			argoSetValue("s_RecEndTm", "");
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
					argoPopupWindow('백업레이블수정', 'BkLabelPopAddF.do', '900', '350');
				}
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'bkLabelId', 		caption: '레이블ID', 		size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'lastBkTime', 	caption: '백업일', 		size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'fromCondition', 	caption: '녹취시작일시', 		size: '13%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'endCondition', 	caption: '녹취종료일시', 		size: '13%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'storeYear', 		caption: '보관주기', 		size: '6%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkFileCnt', 		caption: '백업파일수', 		size: '7%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'usedSpace', 		caption: '사용중인공간', 		size: '10%', 	sortable: true, attr: 'align=right' }
	            		,{ field: 'usableSpace', 	caption: '사용가능공간', 		size: '10%', 	sortable: true, attr: 'align=right' }
	            		,{ field: 'useRate', 		caption: '사용율', 		size: '11%', 	sortable: true, attr: 'align=right' }
	            		,{ field: 'bkRunFlag', 		caption: '상태', 			size: '4%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkDevice', 		caption: 'bkDevice',	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaKind', 		caption: 'mediaKind', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'storePlace', 	caption: 'storePlace', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'lastWorker', 	caption: 'lastWorker', 	size: '0%', 	sortable: true, attr: 'align=center' }	            		
	        ],
	        records: dataArray
	    });

		w2ui['grid'].hideColumn('recid', 'bkDevice', 'mediaKind', 'storePlace', 'lastWorker');
	}
	
	function fnSearchListCnt(){
		
		if(argoGetValue('s_FindText') != ''){
			if(argoGetValue('s_FindKey') == ''){
				argoAlert("검색항목을 선택하세요.") ; 
		 		return ;
			}
		}
		
		var recFrmDt = argoGetValue('s_txtDate1_From').replace('-', '').replace('-', '');
		var recFrmTm = argoGetValue('s_RecFrmTm').replace(':', '').replace(':','');
		var recEndDt = argoGetValue('s_txtDate1_To').replace('-', '').replace('-', '');
		var recEndTm = argoGetValue('s_RecEndTm').replace(':', '').replace(':','');
		
		argoJsonSearchOne('bkLabel', 'getBkLabelCount', 's_', {findFromCondition:recFrmDt + recFrmTm, findEndCondition:recEndDt + recEndTm}, function (data, textStatus, jqXHR){
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
		
		var recFrmDt = argoGetValue('s_txtDate1_From').replace('-', '').replace('-', '');
		var recFrmTm = argoGetValue('s_RecFrmTm').replace(':', '').replace(':','');
		var recEndDt = argoGetValue('s_txtDate1_To').replace('-', '').replace('-', '');
		var recEndTm = argoGetValue('s_RecEndTm').replace(':', '').replace(':','');

		argoJsonSearchList('bkLabel', 'getBkLabelList', 's_', {findFromCondition:recFrmDt + recFrmTm, findEndCondition:recEndDt + recEndTm, "iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						
						dataArray = new Array();
						var useRateHtml;
						var startNum = 0;
						var endNum   = 0;
						
						$.each(data.getRows(), function( index, row ) {
							
							useRateHtml = "";
							startNum 	= Math.round(row.useRate * 0.7);
							endNum 		= 70 - startNum;

							useRateHtml += '<img src="../images/icons/gr01.gif" height="12" width="' + startNum + '%" align="left">';
							useRateHtml += '<img src="../images/icons/gr02.gif" height="12" width="' + endNum + '%" align="left">';

							gObject2 = {  "recid" 			: index
										, "bkLabelId"		: row.bkLabelId
				   						, "lastBkTime"		: row.lastBkTime
										, "fromCondition" 	: row.fromCondition
										, "endCondition" 	: row.endCondition
										, "storeYear" 		: row.storeYear
										, "bkFileCnt" 		: row.bkFileCnt
										, "usedSpace" 		: row.usedSpace + "(MB)"
										, "usableSpace" 	: row.usableSpace + "(MB)"
										, "useRate" 		: useRateHtml + row.useRate + "%"
										, "bkRunFlag" 		: row.bkRunFlag
										, "bkDevice" 		: row.bkDevice
										, "mediaKind" 		: row.mediaKind
										, "storePlace" 		: row.storePlace
										, "lastWorker" 		: row.lastWorker
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

		 	if(arrChecked.length == 0) {
		 		argoAlert("삭제할 백업레이블을 선택하세요") ; 
		 		return ;
		 	}

			argoConfirm('선택한 백업레이블 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				var bkLabelId 	 = "";
				
				$.each(arrChecked, function( index, value ) {
					
					bkLabelId = w2ui['grid'].getCellValue(value, 1);

					var param = { 
									"bkLabelId" : bkLabelId
							
								};

					multiService.argoDelete("bkLabel", "setBkLabelDelete", "__", param);
					
					workLog = '[레이블ID:' + bkLabelId + '] 삭제';
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
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">백업관리</span><strong class="step">백업레이블관리</strong></div>
        <section class="sub_contents">
            <div class="search_area">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">검색</strong>
                            <select id="s_FindKey" name="s_FindKey" style="width: 117px" class="list_box">
								<option value="">선택하세요!</option>
								<option value="bk_label_id">레이블ID</option>
								<option value="bk_device">백업장치</option>
								<option value="last_worker">최종작업자</option>
							</select>
							<input type="text"	id="s_FindText" name="s_FindText" style="width:180px"/>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">녹취일자</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                            <span class="timepicker rec" id="rec_time1"><input type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time" value="00:00:00"><a href="#" class="btn_time">시간 선택</a></span>
							<span class="text_divide">~</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                            <span class="timepicker rec" id="rec_time2"><input type="text" id="s_RecEndTm" name="s_RecEndTm" class="input_time" value="23:59:59"><a href="#" class="btn_time">시간 선택</a></span>
                            <select id="selDateTerm1" name="selDateTerm1" style="width:86px; display:none;" class="mr5"></select>
                        </li>
                    </ul>
                </div>
            </div>     
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <!-- <button type="button" id="btnAdd" class="btn_m confirm">등록</button> -->
                <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 415px;"></div>
	                <!-- <div class="list_paging" id="paging">
                		<ul class="paging">
                 		<li><a href="#" id='' class="on"></a>1</li>
                 		</ul>
                	</div> -->
                </div>
	        </div>
        </section>
    </div>
</body>

</html>