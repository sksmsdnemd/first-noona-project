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

	var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
	var workMenu 	= "키관리";
	var workLog 	= "";
	if(loginInfo!=null){	
		var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;	
		var userId      = loginInfo.SVCCOMMONID.rows.userId;
		var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
		var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
		var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
		var convertFlag = loginInfo.SVCCOMMONID.rows.convertFlag;
		var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
		var depth		= loginInfo.SVCCOMMONID.rows.depth;
		var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
		var backupAt	= loginInfo.SVCCOMMONID.rows.backupAt;
	}else{
		var tenantId    = 'bridgetec';	
		var userId      = 'btadmin';
		var grantId     = 'SuperAdmin';
		var workIp      = '127.0.0.1';
		var playerKind  = '0';
		var convertFlag = '1';
		var groupId		= '1';
		var depth		= 'A';
		var controlAuth	= null;
	}
	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();

	});

	function fnInitCtrl(){
		argoSetDatePicker();
		argoSetValue("s_RecFrmTm", "00:00:00");
		argoSetValue("s_RecEndTm", "23:59:59");
		
		$('.timepicker.rec').timeSelect({
			use_sec : true
		});
		
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
		 	argoPopupWindow('키 등록', 'LicensePopAddF.do', '471', '190');
		});	

// 		$("#btnDelete").click(function(){
// 			fnDeleteList();
// 		});	

		$("#btnReset").click(function(){
			$("#s_txtDate1_From").val("");
			$("#s_txtDate1_To").val("");
			$("#s_FindGubun").val("");
			argoSetValue("s_RecFrmTm", "00:00:00");
			argoSetValue("s_RecEndTm", "23:59:59");
		});
		
		$('#s_FindText').keydown(function(key){
 			fnSearchListCnt();
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
	        		gPopupOptions = {cudMode:"U",pRowIndex:record} ;   	
	    		 	argoPopupWindow('키 수정', 'LicensePopAddF.do', '471', '190');
				}
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubun', 			caption: '구분', 		size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunName', 		caption: '구분', 		size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userId', 		caption: '사용자', 	size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'encKey', 			caption: '키', 	size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'licTime', 		caption: '라이센스 시작일', 		size: '17%', 	sortable: true, attr: 'align=center' }
						,{ field: 'licTimeEnd', 		caption: '라이센스 종료일', 	size: '17%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid','gubun');
	}
	
	function fnSearchListCnt(){
		argoJsonSearchOne('sysInfo', 'getLicenseListCnt', 's_', {}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					
					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
					
					w2ui.grid.lock('조회중', true);
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow){
		argoJsonSearchList('sysInfo', 'getLicenseList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {  "recid" 			: index
										, "userId" 		: row.insId
										, "encKey" 	: row.encKey
										, "licTime" : row.licTime
										, "gubunName" : row.gubun == "0" ? "DB":"FILE"
										, "gubun" : row.gubun
										, "licTimeEnd" : row.licTimeEnd
										
							}
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	var sysGroupId = "";
	
// 	function fnDeleteList(){
		
// 		try{
// 			var arrChecked = w2ui['grid'].getSelection();
			
// 			if(arrChecked.length == 0){
// 				argoAlert("삭제할 시스템을 선택하세요"); 
// 		 		return ;
// 			}

// 			argoConfirm('선택한 시스템 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
// 				var multiService = new argoMultiService(fnCallbackDelete);
				
// 				$.each(arrChecked, function( index, value ) {
// 					tenantId = w2ui['grid'].getCellValue(value, 1);
// 					systemId = w2ui['grid'].getCellValue(value, 3);
// 					processId = w2ui['grid'].getCellValue(value, 11);
// 					var param = { 
// 									"tenantId" : tenantId, 
// 									"systemId"   : systemId,
// 									"processId"   : processId
// 								};
// 					multiService.argoDelete("sysInfo", "getLicenseDelete", "__", param);
					
// 					workLog = '[시스템ID:' + systemId + '] 삭제';
// 					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
// 									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
// 				});
// 				multiService.action();
// 		 	});
		 	
// 		}catch(e){
// 			console.log(e) ;	 
// 		}
// 	}
	
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
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템설정관리</span><strong class="step">시스템정보관리</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">구분</strong>
                            <select id="s_FindGubun" name="s_FindGubun" style="width:300px;" class="list_box">
                                <option value="">선택하세요!</option>
                                <option value="0">DB</option>
                                <option value="1">FILE</option>
                            </select>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                   		<li style="width: 672px"><strong class="title ml20">시작일</strong>
							<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From">
							</span> 
							<span class="timepicker rec" id="rec_time1">
								<input type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time" value="00:00:00">
								<a href="#" class="btn_time">시간 선택</a>
							</span> 
							<span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span> 
							<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To">
							</span> 
							<span class="timepicker rec" id="rec_time2">
								<input type="text" id="s_RecEndTm" name="s_RecEndTm" class="input_time" value="23:59:59">
								<a href="#" class="btn_time">시간 선택</a>
							</span> &nbsp;
	                   	</li>
                   		<li style="width: 672px"><strong class="title ml20">종료일</strong>
							<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_txtDate2_From" name="s_txtDate2_From">
							</span> 
							<span class="timepicker rec" id="rec_time1">
								<input type="text" id="s_RecFrmTm2" name="s_RecFrmTm2" class="input_time" value="00:00:00">
								<a href="#" class="btn_time">시간 선택</a>
							</span> 
							<span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span> 
							<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_txtDate2_To" name="s_txtDate2_To">
							</span> 
							<span class="timepicker rec" id="rec_time2">
								<input type="text" id="s_RecEndTm2" name="s_RecEndTm2" class="input_time" value="23:59:59">
								<a href="#" class="btn_time">시간 선택</a>
							</span> &nbsp;
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
<!--                 <button type="button" id="btnDelete" class="btn_m confirm">삭제</button> -->
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