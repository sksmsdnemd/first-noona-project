<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/amcharts/amcharts.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/pie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/radar.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/serial.js"/>"></script>

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp   = loginInfo.SVCCOMMONID.rows.workIp;
	var userId   = loginInfo.SVCCOMMONID.rows.userId;
	
	var workMenu  = "일자별녹취용량";
	var workLog	  = "";
	var dataArray = new Array();
	var chartData = [];
	
	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			if($('#s_FindTenantId option:selected').val() == ''){
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				argoCbCreate("s_FindMarkKind", "comboBoxCode", "getMarkCodeList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
		} else if (kind == "group") {
			if($('#s_FindGroupId option:selected').val() == ''){
				$("#s_FindUserId").find("option").remove();
			}else{
				argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		}
	}
	
	function fnInitCtrl(){		

		argoSetDatePicker();
		
		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1',{"targetObj":"s_txtDate1" , "selectValue":"M_1"}, jData);

		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {"tenantId":tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {"findTenantId":tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		// argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {"findTenantId":tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});

		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
		
		$("#s_FindTenantId").change(function() {	fnSetSubCb('tenant'); 	});
		$("#s_FindGroupId").change(function() {		fnSetSubCb('group'); 	});

		$("#btnSearch").click(function(){ //조회
			fnSearchList();			
		});
		
		$('#s_FindText').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
		});
		
		$("#btnExcel").click(function(){
			var excelArray = new Array();
			argoJsonSearchList('recSearch', 'getRecChartDateList', 's_', {}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {

							gObject = {   "순번" 		: index + 1
					    				, "통화일자"	: row.recTime
										//, "디스크사용량" 	: row.callTime/3600*3
					    				, "디스크사용량" 	: Math.round((row.callTime/3600*3)*10)/10
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
	            lineNumbers: true,
	            footer: true,
	            selectColumn: false
	        },
	        columns: [  
		    	       	 { field: 'recTime', 	caption: '통화일자', 	size: '95px', sortable: true, attr: 'align=center' }
			           	,{ field: 'callTime', 	caption: '디스크사용량', 	size: '85px', sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });	 
	}
	
	function fnSearchList(){
		
		argoJsonSearchList('recSearch', 'getRecChartDateList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					
					
					
					w2ui.grid.clear();
					chartData = [];
					
					
					
					//20191231  차트안나와서 수정
// 					AmCharts.clear();
					
					dataArray = [];
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							
							gridObject = {  
											  "recid" 		: index+1
				   							, "recTime" 	: row.recTime
											//, "callTime" 	: Math.round(row.callTime/3600*3,0)
											, "callTime" 	: Math.round((row.callTime/3600*3)*10)/10
										};
										
							dataArray.push(gridObject);
							
					    	chartData.push(
					    		{
									  "category"	: row.recTime
									//, "time_sum_mb"	: Math.round(row.callTime/3600*3,0)
									//, "time_sum_gb"	: Math.round(row.callTime/3600*3/1000,0)
									, "time_sum_mb"	: Math.round((row.callTime/3600*3)*10)/10
									, "time_sum_gb"	: Math.round((row.callTime/3600*3/1000)*10)/10
					    		}
					    	);
						});
						
						w2ui['grid'].add(dataArray);
						
						var char = AmCharts.makeChart("div_Chart",
							{
								"type": "serial",
								"theme": "light",
								"categoryField": "category",
								"columnSpacing": 0,
								"autoMargins": false,
								"marginBottom": 70,
								"marginLeft": 62,
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
									"#5571c6",						
									"#db9d61",
									"#55c6c2",
									"#0D8ECF",
									"#2A0CD0",
									"#CD0D74",
									"#CC0000",
									"#00CC00",
									"#0000CC",
									"#DDDDDD",
									"#999999",
									"#DDDDDD",
									"#999999",
									"#333333",
									"#990000"
								],
								"trendLines": [],
								"graphs": [
									{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-1",
										"title": "녹취용량(MB)",
										"fillAlphas": 0.5,
								        "lineAlpha": 0.5,
										"valueField": "time_sum_mb"
									},				
									{
										"balloonText": "[[title]] : <b>[[value]]</b>",
										"bullet": "round",
										"id": "AmGraph-2",
										"title": "녹취용량(GB)",
										"fillAlphas": 0.5,
								        "lineAlpha": 0.5,
										"valueField": "time_sum_gb"
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
									"labelRotation": 60,
									"gridPosition": "start",
									"minorGridEnabled": true
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
									"marginLeft": 0,
									"marginRight": 0,
									"marginTop": 5,
									"position": "top",
									"useGraphSettings": true
								},
								"titles": [],
								"dataProvider": chartData
							}
						);						
					}else{
						argoAlert('조회 결과가 없습니다.');
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
        	<span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역집계</span><strong class="step">일자별녹취용량</strong>
        </div>
        <section class="sub_contents">
            <div class="search_area row2" id="searchPanel">
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
                <div class="row">
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
	            		<li style="width:240px">	
	            			<div id="gridList" style="width:240px; height:410px;"></div>
	            		</li>
	            		<li style="width:10px">&nbsp;</li>
	            		<li style="width:850px">	
	            			<div class="cont_box">
	            				<div id="div_Chart" style="height:410px;"></div>
	            			</div> 
	            		</li>
	            	</ul>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>