<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->    
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->
<script type="text/javascript" src="<c:url value="/scripts/amcharts/amcharts.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/pie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/radar.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/serial.js"/>"></script>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var groupId	  	= loginInfo.SVCCOMMONID.rows.groupId;
	var depth     	= loginInfo.SVCCOMMONID.rows.depth;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	var workIp		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  	= "요일별통계";
	var workLog		= "";
	var dataArray 	= new Array();
	var chartData1 	= [];
	var chartData2 	= [];
	
	$(document).ready(function() {
		if(controlAuth == null){
			controlAuth = "";
		}
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			if($('#s_FindTenantId option:selected').val() == ''){
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
			fnGroupCbChange("s_FindGroupId");
		} else if (kind == "group") {
			if($('#s_FindGroupId option:selected').val() == ''){
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		}
	}
	
	function fnInitCtrl(){		

		argoSetDatePicker();
		
		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code" :"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"M_1"}, jData);

		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {"tenantId":tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		fnGroupCbChange("s_FindGroupId");
		
		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
			if(grantId != "Manager"){
				$('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId, FindGroupId:groupId + '_' + depth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
		}

		$("#s_FindTenantId").change(function() {	fnSetSubCb('tenant'); 	});
		$("#s_FindGroupId").change(function() {	 	fnSetSubCb('group'); 	});

		$("#btnSearch").click(function(){ //조회
			fnSearchList();			
		});
		
		$("#s_FindUserNameText").keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
		});
		
		// 2018.02.07 사용자 콤보박스 표시 여부
		var isUseUserCombo = 1;
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_USER_COMBO"}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						isUseUserCombo = data.getRows()['code'];

						if (isUseUserCombo == 1) {
						   $("#s_FindUserId").attr('style', "width:150px;");
						}
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});

		$("#btnExcel").click(function(){
			var excelArray = new Array();
			argoJsonSearchList('recSearch', 'getRecChartWeekList', 's_', {userId:userId, controlAuth:controlAuth, grantId:grantId}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {

							gObject = {   "요일" 			: row.rday
					    				, "금주(통화수)"		: row.sumCnt1
					   					, "1주전(통화수)"	: row.sumCnt2
										, "2주전(통화수)" 	: row.sumCnt3
										, "3주전(통화수)" 	: row.sumCnt4
										, "금주(통화시간)" 	: fnSecondsConv(row.sumTime1)
										, "1주전(통화시간)" 	: fnSecondsConv(row.sumTime2)
										, "2주전(통화시간)" 	: fnSecondsConv(row.sumTime3)
										, "3주전(통화시간)" 	: fnSecondsConv(row.sumTime4)
									};
										
							excelArray.push(gObject);
						});
						
						gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
						argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
						workLog = '[TenantId:'
							+ tenantId
							+ ' | UserId:' + userId
							+ ' | GrantId:'
							+ grantId
							+ '] Excel Export';
						
						
						argoJsonUpdate(
							"actionLog",
							"setActionLogInsert",
							"ip_",
							{
								tenantId : tenantId,
								userId : userId,
								actionClass : "action_class",
								actionCode : "W",
								workIp : workIp,
								workMenu : workMenu,
								workLog : workLog
							});
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
	            lineNumbers: false,
	            footer: false,
	            selectColumn: false
	        },
	        columnGroups: [
	        	 { caption: '요일', 	span: 1,	master: true	}
	            ,{ caption: '통화수', 	span: 4						}
	        ],	        
	        columns: [  
            	 { field: 'rday', 		caption: '요일', 		size: '47px',  sortable: true, attr: 'align=center' }
            	,{ field: 'sumCnt1', 	caption: '금주', 		size: '100px', sortable: true, attr: 'align=center' }
	           	,{ field: 'sumCnt2', 	caption: '1주전', 	size: '100px', sortable: true, attr: 'align=center' }
	           	,{ field: 'sumCnt3', 	caption: '2주전', 	size: '100px', sortable: true, attr: 'align=center' }
	           	,{ field: 'sumCnt4', 	caption: '3주전', 	size: '100px', sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });	
		
		$('#gridList2').w2grid({ 
	        name: 'grid2', 
	        show: {
	            lineNumbers: false,
	            footer: false,
	            selectColumn: false
	        },
	        columnGroups: [
	             { caption: '요일', 	span: 1,	master: true	}
	            ,{ caption: '통화시간',	span: 4 					}
	        ],	        
	        columns: [  
            	 { field: 'rday', 		caption: '요일', 		size: '47px', sortable: true, attr: 'align=center'  }
	           	,{ field: 'sumTime1', 	caption: '금주', 		size: '100px', sortable: true, attr: 'align=center' }
	           	,{ field: 'sumTime2', 	caption: '1주전', 	size: '100px', sortable: true, attr: 'align=center' }
	           	,{ field: 'sumTime3', 	caption: '2주전', 	size: '100px', sortable: true, attr: 'align=center' }
	           	,{ field: 'sumTime4', 	caption: '3주전', 	size: '100px', sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });	
	}
	
	function fnSearchList(){
		
		argoJsonSearchList('recSearch', 'getRecChartWeekList', 's_', {userId:userId, controlAuth:controlAuth, grantId:grantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					w2ui.grid2.clear();
					chartData1 = [];
					chartData2 = [];
					dataArray  = [];
					
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							
							gridObject = {  
											  "recid" 		: index+1
			   								, "rday" 		: row.rday
											, "sumCnt1" 	: row.sumCnt1
											, "sumCnt2" 	: row.sumCnt2
											, "sumCnt3" 	: row.sumCnt3
											, "sumCnt4" 	: row.sumCnt4
											, "sumTime1" 	: fnSecondsConv(row.sumTime1)
											, "sumTime2" 	: fnSecondsConv(row.sumTime2)
											, "sumTime3" 	: fnSecondsConv(row.sumTime3)
											, "sumTime4" 	: fnSecondsConv(row.sumTime4)
										};
										
							dataArray.push(gridObject);
					    	
					    	chartData1.push(
								{
									"category"	: row.rday,
									"sumCnt1"	: row.sumCnt1,
									"sumCnt2"	: row.sumCnt2,
									"sumCnt3"	: row.sumCnt3,
									"sumCnt4"	: row.sumCnt4
						    	}
						    );
					    	chartData2.push(
						    	{
									"category"	: row.rday,
									"sumTime1"	: Math.ceil(row.sumTime1/60),
									"sumTime2"	: Math.ceil(row.sumTime2/60),
									"sumTime3"	: Math.ceil(row.sumTime3/60),
									"sumTime4"	: Math.ceil(row.sumTime4/60)
						    	}
						    );
						});
						
				    	w2ui['grid'].add(dataArray);
				    	w2ui['grid2'].add(dataArray);
						
						var char = AmCharts.makeChart("div_Chart1",
							{
								"type": "serial",
								"categoryField": "category",
								"columnSpacing": 0,
								"autoMargins": false,
								"marginBottom": 30,
								"marginLeft": 60,
								"marginRight": 20,
								"marginTop": 10,
								"sequencedAnimation": false,
								"startDuration": 0.7,
								"startEffect": "easeOutSine",
								"color": "#575757",
								"fontFamily": "Nanum Gothic",
								"fontSize": 12,
								"colors": [
									"#2A0Cee", "#55c6c2", "#0D8ECF", "#2A0CD0", "#db9d61", "#55c6c2", "#0D8ECF", "#2A0CD0", "#CD0D74", "#00CC00",	"#0000CC", "#DDDDDD",
									"#999999", "#DDDDDD", "#999999", "#333333", "#990000"
								],
								"graphs": [
									{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-1",
										"title": "금주 통화수  ",
										"type" : "smoothedLine",
										"lineThickness": 1.5,
										"valueField": "sumCnt1"
									}				
									,{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-2",
										"title": "1주전 통화수  ",
										"type" : "smoothedLine",
										"lineThickness": 0.9,
										"valueField": "sumCnt2"
									}				
									,{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-3",
										"title": "2주전 통화수  ",
										"type" : "smoothedLine",
										"lineThickness": 0.6,
										"valueField": "sumCnt3"
									}				
									,{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-4",
										"title": "3주전 통화수  ",
										"type" : "smoothedLine",
										"lineThickness": 0.3,
										"valueField": "sumCnt4"
									}				
								],
								"chartCursor": {
									"categoryBalloonDateFormat": "YYYY-MM-DD",
								    "cursorAlpha": 0,
								    "valueLineEnabled":true,
								    "valueLineBalloonEnabled":true,
								    "valueLineAlpha":0.5,
								    "fullWidth":true
								},									
								"guides": [],
								"categoryAxis": {
									"parseDates": false,
									"dashLength": 1,
									"labelRotation": 0,
									"gridPosition": "start",
									"minorGridEnabled": false
								},									
								"valueAxes": [
									{
										"id": "ValueAxis-1",
										"axisAlpha": 0.29,
										"tickLength": 0,
										"title": ""
									}
								],
								"allLabels": [],
								"balloon": {
									"animationDuration": 0.26,
									"borderColor": "#FB5050",
									"borderThickness": 1,
									"cornerRadius": 2,
									"disableMouseEvents": false,
									"fillAlpha": 1,
									"fixedPosition": false,
									"fontSize": 11,
									"pointerWidth": 4,
									"shadowAlpha": 0.23	
								},
								"legend": {
									"enabled": true,
									"align": "center",
									"autoMargins": false,
									"bottom": 5,
									"marginBottom": 5,
									"marginLeft": 5,
									"marginRight": 5,
									"marginTop": 5,
									"position": "right",
									"useGraphSettings": true
								},
								"titles": [],
								"dataProvider": chartData1
							}
						);		

						var char = AmCharts.makeChart("div_Chart2",
							{
								"type": "serial",
								"categoryField": "category",
								"columnSpacing": 0,
								"autoMargins": false,
								"marginBottom": 30,
								"marginLeft": 60,
								"marginRight": 20,
								"marginTop": 10,
								"sequencedAnimation": false,
								"startDuration": 0.7,
								"startEffect": "easeOutSine",
								"color": "#575757",
								"dataDateFormat": "YYYY-MM-DD",
								"fontFamily": "Nanum Gothic",
								"fontSize": 12,
								"colors": [
									"#2A0Cee", "#55c6c2", "#0D8ECF", "#2A0CD0", "#db9d61", "#55c6c2", "#0D8ECF", "#2A0CD0", "#CD0D74", "#00CC00",	"#0000CC", "#DDDDDD",
									"#999999", "#DDDDDD", "#999999", "#333333", "#990000"
								],
								"trendLines": [],
								"graphs": [
									{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-11",
										"title": "금주 통화(분)",
										"type" : "smoothedLine",
										"lineThickness": 1.5,
										"valueField": "sumTime1"
									}				
									,{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-12",
										"title": "1주전 통화(분)",
										"type" : "smoothedLine",
										"lineThickness": 0.9,
										"valueField": "sumTime2"
									}				
									,{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-13",
										"title": "2주전 통화(분)",
										"type" : "smoothedLine",
										"lineThickness": 0.6,
										"valueField": "sumTime3"
									}				
									,{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-14",
										"title": "3주전 통화(분)",
										"type" : "smoothedLine",
										"lineThickness": 0.3,
										"valueField": "sumTime4"
									}				
								],
								"chartCursor": {
									"categoryBalloonDateFormat": "YYYY-MM-DD",
								    "cursorAlpha": 0,
								    "valueLineEnabled":true,
								    "valueLineBalloonEnabled":true,
								    "valueLineAlpha":0.5,
								    "fullWidth":true
								},									
								"guides": [],
								"categoryAxis": {
									"parseDates": false,
									"dashLength": 1,
									"labelRotation": 0,
									"gridPosition": "start",
									"minorGridEnabled": false
								},									
								"valueAxes": [
									{
										"id": "ValueAxis-2",
										"axisAlpha": 0.29,
										"tickLength": 0,
										"title": ""
									}
								],
								"allLabels": [],
								"balloon": {
									"animationDuration": 0.26,
									"borderColor": "#FB5050",
									"borderThickness": 1,
									"cornerRadius": 2,
									"disableMouseEvents": false,
									"fillAlpha": 1,
									"fixedPosition": false,
									"fontSize": 11,
									"pointerWidth": 4,
									"shadowAlpha": 0.23	
								},
								"legend": {
									"enabled": true,
									"align": "center",
									"autoMargins": false,
									"bottom": 5,
									"marginBottom": 5,
									"marginLeft": 5,
									"marginRight": 5,
									"marginTop": 5,
									"position": "right",
									"useGraphSettings": true
								},
								"titles": [],
								"dataProvider": chartData2
							}
						);											
					}					
				}
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
        <div class="location">
        	<span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역집계</span><strong class="step">요일별 통계</strong>
        </div>
        <section class="sub_contents">
            <div class="search_area row3" id="searchPanel">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width: 200px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px; display:none;"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                        </li>
                    </ul>
                </div>
                <div class="row" id="div_user">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">그룹</strong>
                            <select id="s_FindGroupId" name="s_FindGroupId" style="width: 200px" class="list_box"></select>
                            <!--  
							<input type="checkbox" class="checkbox" id="s_FindSelectSubGroup" name="s_FindSelectSubGroup" data-defaultChecked=true value="1" checked><label for="s_FindSelectSubGroup">하위그룹포함</label>
							-->
                        </li>
                        <li style="width:420px">
                            <strong class="title">사용자</strong>
                            <select id="s_FindUserId" name="s_FindUserId" style="display:none; width:150px;" class="list_box" title="사용자의 그룹을 먼저 선택하세요!"></select>
                            <input type="text"	id="s_FindUserNameText" name="s_FindUserNameText" style="width:150px"/>
                        </li>
                    </ul>
                </div>
<!--                 <div class="row" style="display:none"> -->
                <div class="row" style="display:none">
                    <ul class="search_terms">
                    	<li style="width:683px">
                            <strong class="title ml20">녹취일자</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>                            
							<span class="text_divide" style="width:434px">&nbsp; ~ &nbsp;</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>                            
                            <select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select> 
                        </li>
                    </ul>
                </div>                
            </div>
            <div class="btns_top">
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div>
	            	<ul class="search_terms">
	            		<li style="width:450px">
	            			<div id="gridList" style="height:227px;"></div>
	            		</li>
	            		<li style="width:10px">&nbsp;</li>
	            		<li style="width:630px">	
	            			<div class="cont_box">
	            				<div id="div_Chart1" style="height:227px;"></div>
	            			</div> 
	            		</li>
	            		<!-- <li style="width:430px">	
	            			<div class="cont_box">
	            				<div id="div_Chart2" style="height:310px;"></div>
	            			</div> 
	            		</li> -->
	            	</ul>
	            </div>
	            <div class="btn_topArea fix_h25"></div>
	            <div>
	            	<ul class="search_terms">
	            		<li style="width:450px">
	            			<div id="gridList2" style="height:227px;"></div>
	            		</li>
	            		<li style="width:10px">&nbsp;</li>
	            		<!-- <li style="width:230px">	
	            			<div class="cont_box">
	            				<div id="div_Chart1" style="height:310px;"></div>
	            			</div> 
	            		</li> -->
	            		<li style="width:630px">	
	            			<div class="cont_box">
	            				<div id="div_Chart2" style="height:227px;"></div>
	            			</div> 
	            		</li>
	            	</ul>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>