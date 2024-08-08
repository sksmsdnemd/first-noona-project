<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>VELOCE</title>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/argo.main.css?ver=20170103"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/amcharts.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/pie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/radar.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/serial.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> 

<style>
#div_chart_CallSum {
	width		: 100%;
	height		: 100%;
	font-size	: 11px;
}					
</style>

<style>
#div_DnReg {
	width		: 100%;
	height		: 500px;
}												
</style>

<style>
#div_chart_pie {
	width		: 100%;
	height		: 160px;
}												
</style>

<style>
#div_UserReg {
	width		: 100%;
	height		: 500px;
}												
</style>

<script>


	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    = loginInfo.SVCCOMMONID.rows.userId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	
	var dataArray = new Array();
	var chartData = [];
	
	var userAddCnt	= 0; 	//사용자등록건수
	var loginRate	= 0; 	//로그인비율
	var logoutRate	= 0; 	//로그아웃비율
	var reservRate	= 0; 	//미사용비율
	var totExtCnt	= 0; 	//전체내선수
	var callStaCnt	= 0; 	//대기
	var callIngCnt	= 0; 	//통화중
	var reservCnt	= 0; 	//미사용
	var callCnt		= 0; 	//오늘통화수

	$(document).ready(function() {

		 
		fnSearchUserInfo();
		fnSearchExtInfo();
		fnSearchRecCntList();
		fnSearchRecentList();
		
		fnInitGrid();
		fnSearchAction();
	});
	
	function fnSearchUserInfo(){
		argoJsonSearchList('ARGOCOMMON', 'getIntroUserInfo', 's_', {tenantId:tenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if (data.getRows() != ""){
						
						var agentStatus = "";
						var loginCnt 	= "";
						var logoutCnt 	= "";
						var reservCnt 	= "";
						
						$.each(data.getRows(), function( index, row ) {
							
							agentStatus = row.agentStatus;
							
							if(agentStatus == "00"){
								reservCnt = row.cnt;
							}else if(agentStatus == "01"){
								loginCnt = row.cnt;
							}else if(agentStatus == "99"){
								logoutCnt = row.cnt;
							}
							
							userAddCnt += row.cnt;
						});
						
						reservRate = reservCnt; //Math.round((userAddCnt-(loginCnt+logoutCnt))/userAddCnt*100);
						loginRate  = loginCnt; 	//Math.round((userAddCnt-(reservCnt+logoutCnt))/userAddCnt*100);
						logoutRate = logoutCnt; //100 - reservRate - loginRate;
					}
				}
				
				amChartPie();
				$("#userAddCnt").text(userAddCnt);
			} catch(e) {
				console.log(e);		
			}
		});
	}
	
	function fnSearchExtInfo(){
		argoJsonSearchList('ARGOCOMMON', 'getIntroExtInfo', 's_', {tenantId:tenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if (data.getRows() != ""){
						
						var dnStatus = "";
						var dnCnt 	 = "";
						
						$.each(data.getRows(), function( index, row ) {
							dnStatus = row.dnStatus;
							dnCnt 	 = row.cnt;
							
							// 10 : 통화중
							// 01 : 대기
							// 00 : 미사용
							if(dnStatus == "10"){
								callIngCnt = row.cnt;
							}else if(dnStatus == "01"){
								callStaCnt = row.cnt;
							}else if(dnStatus == "00"){
								reservCnt = row.cnt;
							}
							
							totExtCnt += row.cnt;
						});
					}
				}
				dataSetting();
			} catch(e) {
				console.log(e);		
			}
		});
	}

	function fnSearchRecCntList(){
		argoJsonSearchList('ARGOCOMMON', 'getIntroRecCntList', 's_', {tenantId:tenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					chartData 	 = [];
					var todayCnt = 0;
					
					if (data.getRows() != ""){
						$.each(data.getRows(), function( index, row ) {
							if(index == 0){
								todayCnt = row.sumCntM1;
								callCnt  = row.sumCntM1;
							}
							
							chartData.push(
						    	{
									"recDate"	: row.recDate.replace("전달", "전월"),
									"sumCntM1"	: todayCnt,
									"sumCntM"	: row.sumCntM1
						    	}
						    );
						});
					}
				}
				
				amChartBar();
				$("#callCnt").text(argoFormatterNumber(callCnt));
			} catch(e) {
				console.log(e);		
			}
		});
	}
	
	function fnSearchRecentList(){
		argoJsonSearchList('ARGOCOMMON', 'getIntroRecentList', 's_', {tenantId:tenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					chartData = [];
					
					if (data.getRows() != ""){
						$.each(data.getRows(), function( index, row ) {
							chartData.push(
						    	{
									"recTime"		: row.recTime,
									"recCount"		: row.recCount,
									"endTimeAvg"	: row.recAvg
						    	}
						    );
						});
					}
				}
				
				amChartLine();
			} catch(e) {
				console.log(e);		
			}
		});
	}
	
	
	function fnInitGrid(){
		
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            selectColumn: false
	        },
	        columns: [  
						 { field: 'recid', 		caption: '#', 		size: '5%', 	attr: 'align=center' }
		            	,{ field: 'logDate', 	caption: '작업일자', 	size: '17%', 	attr: 'align=center' }
			           	,{ field: 'workMenu', 	caption: '메뉴명', 	size: '20%', 	attr: 'align=center' }
			           	,{ field: 'workIp', 	caption: '작업자IP', 	size: '18%', 	attr: 'align=center' }
			           	,{ field: 'workLog', 	caption: '내용', 		size: '40%', 	attr: 'align=left'   }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn();
	}	
	
	function fnSearchAction(){
		
		var eDate = argoCurrentDateToStr();
		var sDate = argoDateToStr(argoAddDate(eDate,-30));
		
		argoJsonSearchList('actionLog', 'getActionLogList', 's_', {findTenantId:tenantId, findUserId:userId, iEPageNo:'25', iSPageNo:'25', txtDate1_From:sDate, txtDate1_To:eDate, grantId:grantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){
						dataArray = [];
						$.each(data.getRows(), function( index, row ) {
							
							gridObject = {  
											  "recid" 			: index + 1
					    					, "logDate"			: row.logDate
											, "workMenu"		: row.workMenu
											, "workIp" 			: row.workIp
											, "workLog" 		: row.workLog
											, w2ui: row.workMenu == "내선녹취오류" ? { "style": "background-color: #FFB54F" } : {}	
							};
									
							dataArray.push(gridObject);
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

	function dataSetting(){
		$("#totExtCnt").text(totExtCnt);
		$("#callStaCnt").text(callStaCnt);
		$("#callIngCnt").text(callIngCnt);
		$("#reservCnt").text(reservCnt);
	}
	
	function amChartPie(){
		
		var chart = AmCharts.makeChart( "div_chart_pie", 
			{
				"type"			: "pie",
				"colors"		: [
									"#150e72",
									"#3e8eef",
									"#d1ceef",
									"#2A0CD0",
									"#CD0D74",
									"#CC0000",
									"#00CC00",
									"#0000CC",
									"#DDDDDD",
									"#999999",
									"#333333",
									"#990000"
								  ],    
				"innerRadius"	: "50%",
				"labelRadius"	: 10,
				"pullOutRadius"	: "0%",
				"marginBottom"	: 30,
				"marginTop"		: 30,
				"titleField"	: "country",
				"valueField"	: "value",
				"fontFamily"	: "Nanum Gothic",
				"fontSize"		: 12,
				"allLabels"		: [
									{
									"align"	: "center",
									"bold"	: true,
									"color"	: "#E67531",
									"id"	: "Label-1",
									"size"	: 20,
									"text"	: "",
									"y"		: "34%"
									}
								  ],
				"balloon"		: {
									"animationDuration"	: 0.26,
									"borderColor"		: "#4B0C25",
									"borderThickness"	: 1,
									"cornerRadius"		: 2,
									"disableMouseEvents": false,
									"fillAlpha"			: 1,
									"fixedPosition"		: false,
									"fontSize"			: 11,
									"pointerWidth"		: 4,
									"shadowAlpha"		: 0.23
								  },
				"titles"		: [],
				"dataProvider"	: [   
					      			{
						    		"country"	: "로그인 ",
						    		"value"		: loginRate
						  			}, 
						  			{
						    		"country"	: "로그아웃 ",
						    		"value"		: logoutRate
						  			},
						  			{
									"country"	: "미사용 ",
									"value"		: reservRate
						  			}
						 		  ]
			}
		);		
	}

	function amChartBar(){
		var chart = AmCharts.makeChart("div_chart_CallSum", 
			{
		    	"theme"			: "light",
		    	"type"			: "serial",
				"colors"		: [
									"#150e72",
									"#55c6c2",
									"#0D8ECF",
									"#2A0CD0",
									"#CD0D74",
									"#CC0000",
									"#00CC00",
									"#0000CC",
									"#DDDDDD",
									"#999999",
									"#333333",
									"#990000"
								  ],    
		    	"dataProvider"	: chartData,
		    	"valueAxes"		: [
		    						{
		        					"unit"		: "건",
		        					"position"	: "left",
		        					"title"		: "",
		    						}
		    					  ],
		    	"startDuration"	: 1,
		    	"graphs"		: [
									{
		        					"balloonText"	: "통화건수 : <b>[[value]]</b>",
		        					"fillAlphas"	: 0.9,
		        					"lineAlpha"		: 0.2,
		        					"title"			: "이전통화건수",
		        					"type"			: "column",
		        					"valueField"	: "sumCntM"
		    						}
		    	       			  ],
		    	"plotAreaFillAlphas" : 0.1,
		    	"categoryField"	: "recDate",
		    	"categoryAxis"	: {
		        					"gridPosition"	: "start"
		    					  },
		    	"export"		: {
		    						"enabled"		: true
		     					  }
			}
		);
	}

	function amChartLine(){
		var char = AmCharts.makeChart("row_curveChart",
			{
				"type"			: "serial",
				"categoryField"	: "recTime",
				"columnSpacing"	: 0,
				"autoMargins"	: false,
				"marginBottom"	: 60,
				"marginLeft"	: 62,
				"marginRight"	: 20,
				"marginTop"		: 10,
				"sequencedAnimation": false,
				"startDuration"	: 0.7,
				"startEffect"	: "easeOutSine",
				"color"			: "#575757",
				"dataDateFormat": "YYYY-MM-DD",
				"fontFamily"	: "Nanum Gothic",
				"fontSize"		: 12,
				"colors"		: [
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
				"categoryAxis"	: {
									"parseDates"		: false,
									"dashLength"		: 1,
									"labelRotation"		: 50,
									"gridPosition"		: "start",
									"minorGridEnabled"	: true
								  },
				"trendLines"	: [],
				"graphs"		: [
									{
									"balloonText"	: "[[title]] : <b>[[value]]</b>",
									"bullet"		: "round",
									"id"			: "AmGraph-1",
									"title"			: "녹취건수",
									"valueField"	: "recCount"
									},
									{
									"balloonText"	: "[[title]] : <b>[[value]]</b>",
									"bullet"		: "round",
									"id"			: "AmGraph-2",
									"title"			: "평균녹취건수",
									"valueField"	: "endTimeAvg"
									}
								  ],
				"chartCursor"	: {
				        			"categoryBalloonDateFormat"	: "YYYY-MM-DD",
				        			"cursorAlpha"				: 0,
				        			"valueLineEnabled"			: true,
							        "valueLineBalloonEnabled"	: true,
							        "valueLineAlpha":0.5,
							        "fullWidth":true
				    			  },
				"guides"		: [],
				"valueAxes"		: [
									{
									"id"		: "ValueAxis-1",
									"axisAlpha"	: 0.29,
									"tickLength": 0,
									"title"		: ""
									}
								  ],
				"allLabels"		: [],
				"balloon"		: {
									"animationDuration"	: 0.26,
									"borderColor"		: "#FB5050",
									"borderThickness"	: 1,
									"cornerRadius"		: 2,
									"disableMouseEvents": false,
									"fillAlpha"			: 1,
									"fixedPosition"		: false,
									"fontSize"			: 11,
									"pointerWidth"		: 4,
									"shadowAlpha"		: 0.23	
								  },
				"legend"		: {
									"enabled"			: true,
									"align"				: "center",
									"autoMargins"		: false,
									"bottom"			: 5,
									"marginBottom"		: 5,
									"marginLeft"		: 0,
									"marginRight"		: 0,
									"marginTop"			: 5,
									"position"			: "top",
									"useGraphSettings"	: true
								  },
				"titles"		: [],
				"dataProvider"	: chartData 
			}
		);
	}

</script>
</head>
<body>
	<div class="main_wrap">
		<div class="info_row">
			<div class="box personState" style="width:550px; position:fixed; left:10px; top:20px;">
				<div class="cont_box" style="height:185px">
					<div class="title">상담사 로그인 현황</div>
					<div class="cont">
						<ul class="dn_list">
							<li>
								<dl class="person_info4">
									<dt>사용자현황</dt>
									<dd>
										<ul class="detail_info">
											 <li>
												<p class="d_title"></p>
												<p class="d_num" ></p>
											</li> 
											<li>
												<p class="d_title">사용자등록건수</p>
												<p class="d_num"><strong><span id="userAddCnt">0</span></strong>명</p>
											</li>
										</ul>
									</dd>
								</dl>
							</li>
							<li>
								<div id="div_chart_pie"></div>
							</li>
						</ul>
          			</div>
				</div>
			</div>
			<div class="box personState" style="width:550px; position:fixed; left:560px; top:20px;">
				<div class="cont_box" style="height:185px">                    
					<div class="title">내선 녹취 현황</div>
					<div class="cont">
						<ul class="dn_status">
							<li>
								<dl class="person_info2">
									<dt> 전체내선수</dt>
									<dd><strong><span id="totExtCnt">0</span></strong></dd>
								</dl>
							</li>
							<li>
								<dl class="person_info2">
									<dt> 대기</dt>
									<dd><strong><span id="callStaCnt">0</span></strong></dd>
								</dl>
							</li>
							<li>
								<dl class="person_info2">
									<dt> 통화중</dt>
									<dd><strong><span id="callIngCnt">0</span></strong></dd>
								</dl>
							</li>
							<li>
								<dl class="person_info2">
									<dt>미사용</dt>
									<dd><strong><span id="reservCnt">0</span></strong></dd>
								</dl>
							</li>
							<!-- <li>
								<dl class="person_info2">
									<dt>로그아웃</dt>
									<dd><strong><span id="logoutCnt">0</span></strong></dd>
								</dl>
							</li> -->
						</ul>
					</div>                    
				</div>
			</div>
		</div> <!-- infor row -->
		<br>
		<div class="info_row" >
			<div class="box personState"  style="width:550px; position:fixed; left:10px; top:220px;">
				<div class="cont_box" style="height:270px">
					<div class="title">녹취 건수 현황</div>
						<div class="cont">
						<ul class="dn_work">
							<li>
								<dl class="person_info3">
									<dt>오늘 통화수</dt>
									<dd><strong><span id="callCnt">0</span></strong>건</dd>
								</dl>
							</li>
							<li>
								<div id="div_chart_CallSum" style="height:180px; background-color: #FFFFFF;"></div>
							</li>
						</ul>
					</div>
				</div>
		 	</div>
		 	<div class="box personState"  style="width:550px; position:fixed; left:560px; top:220px;">

		 		<div class="cont_box" style="height:270px"> 
					<div class="title">최근 2주간 녹취 현황</div>                   
					<div id="row_curveChart" class="chart_div" style="height:220px; background-color: #FFFFFF;" ></div>   
				</div>
			</div>
		</div> <!-- infor row -->
		<div class="info_row" >
			<div class="box personState" style="width:1100px; position:fixed; left:10px; top:505px;">
				<div class="cont_box">
					<div class="title">최근 작업 내역</div>
	        		<!-- <a href="#" class="btn_more" title="more">more</a> -->
	        		<div id="gridList" style="width: 100%; height: 153px;"></div>
	        	</div>
        	</div>
	 	</div>
	</div>
</body>

</html>
										