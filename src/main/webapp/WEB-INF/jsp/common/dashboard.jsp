<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>ARGO</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />

<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/argo.main.css?ver=20170103"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/amcharts/amcharts.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/pie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/serial.js"/>"></script>

<script>
	$(function(){
		
		function fnChartResize(){
			var h = $(".chart_area .cont_box").height();
			$(".chart_div").height(h)	
		}
		
		$(window).on("resize", function(){
			fnChartResize();
		})
		
		$(window).trigger("resize");
		
		
		//2016년 6월 콜 실적통계 (파이차트)
		argoJsonSearchList('ARGOCOMMON','SP_DASHBOARD_01','__',{}, fnCallbackMakeChartPie );
		
		/* 성과실적과 비중(누적 막대그래프) */
	  	argoJsonSearchList('ARGOCOMMON','SP_DASHBOARD_02','__',{}, fnCallbackMakeChartStackedColumn );
		
		/* 퇴직률 통계(Line Curve Chart) */
		argoJsonSearchList('ARGOCOMMON','SP_DASHBOARD_03','__',{}, fnCallbackMakeChartLine );
		
		/* 인원통계(Bar Chart - 가로) */
		argoJsonSearchList('ARGOCOMMON','SP_DASHBOARD_04','__',{}, fnCallbackMakeChartBar);
		
	});


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHART 
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
 function fnCallbackMakeChartPie(data, textStatus, jqXHR){
	    if(data.isOk()){
	    fnMakeChartPie(data.getRows());
	    }
	    }	

 function fnMakeChartPie(chartData){
	 try{
	 
	    var colorArry = ["#67b7dc",
	 					"#eed44a",
						"#d593b9",
						"#92c96c",
						"#F8FF01",
						"#B0DE09",
						"#04D215",
						"#0D8ECF",
						"#0D52D1",
						"#2A0CD0",
						"#8A0CCF",
						"#CD0D74",
						"#754DEB",
						"#DDDDDD",
						"#999999",
						"#333333",
						"#000000",
						"#57032A",
						"#CA9726",
						"#990000",
						"#4B0C25"]; //
	    var pie_item1 = {
	    		"type": "pie",
				"balloonText": "[[title]]<br><span style='font-size:14px'><b>[[value]]</b> ([[percents]]%)</span>",
				"innerRadius": "62%",
				"labelRadius": 10,
				"pullOutRadius": "0%",
				"startRadius": "0%",
				"groupPercent": -5,
				"hoverAlpha": 0.71,
				"labelColorField": "#525252",
				"labelTickAlpha": 0.89,
				"labelTickColor": "#525252",
				"marginBottom": 40,
				"marginTop": 50,
				"pullOutDuration": 0,
				"pullOutEffect": "easeOutSine",
				"sequencedAnimation": false,
				"titleField": "title",
				"valueField": "value",
				"fontFamily": "Nanum Gothic",
				"fontSize": 12,
				"allLabels": [
					{
						"align": "center",
						"bold": true,
						"color": "#E67531",
						"id": "Label-1",
						"size": 26,
						"text": "1,560",
						"y": "44%"
					},
					{
						"align": "center",
						"color": "#F1AC82",
						"id": "Label-2",
						"size": 16,
						"text": "call",
						"y": "55%"
					}
				],
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
					"align": "right",
					"bottom": 9,
					"equalWidths": false,
					"fontSize": 12,
					"gradientRotation": -1,
					"horizontalGap": -1,
					"left": 0,
					"markerType": "circle",
					"position": "right",
					"right": -1,
					"top": 1,
					"verticalGap": 12
				},
				"titles": []
	      };
	    
	    var pieChart1 = argoAmChart('chartPie', 'custom', chartData ,colorArry);
		    pieChart1.init();
		    pieChart1.addItem(pie_item1);
		    pieChart1.makeChart(); 

	}  catch(e) {
	 	alert( e);
	}
	}
 
 function fnCallbackMakeChartStackedColumn(data, textStatus, jqXHR){
	    if(data.isOk()){
	    	fnMakeChartStackedColumn(data.getRows());
	    }
	    }
 
 /* legend가 가변일 경우 예*/
 function fnMakeChartStackedColumn(data){
	 try{
		 // legend 및 column을 조회 결과의  컬럼명으로 처리
		 var colorArry = [  "#5571c6",
							"#55c6c2",
							"#db9d61",
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
		                  ]; // 순서데로 칼라 지정
		 
		 var graphArray = new Array();
   		 var graphColumn  ;	 
   		 
   		 // 첫번째 데이터로 생성
		 if(data.length>0)	{
			graphColumn = data[0];
		 } 
             var colIndex =0 ;
             var strColNm ;
             
			 for (var colNm in graphColumn) {
				 
        	 if (colIndex > 0) { //첫 컬럼은 title이므로 제외 

             var graphInfo = new Object();
        	 
             strColNm = colNm.toUpperCase(); //영문일 경우 컬럼 명이 소문자로 변화되어 오므로
     
             graphInfo.balloonText = strColNm + "([[value]])" ;
             graphInfo.id = "AmGraph-" + colIndex;
             graphInfo.title = strColNm;
             graphInfo.fillAlphas = 1;
             graphInfo.type = "column";
             graphInfo.valueField = colNm;
             graphInfo.lineColor  = colorArry[colIndex-1];
             graphArray.push(graphInfo);  
            
        	 }
        	 colIndex++ ;
         }

         var serial_graph1 = new Object();
         serial_graph1.graphs = graphArray;
         
  
        var serial_item1 = {
        		"type": "serial",
				"categoryField": "title",
				"columnSpacing": 0,
				"columnWidth": 0.43,
				"maxSelectedSeries": 20,
				"maxSelectedTime": -2,
				"autoMarginOffset": 24,
				"marginBottom": 23,
				"marginTop": 65,
				"minMarginTop": -1,
				"fontSize": 12,
				"sequencedAnimation": false,
				"startDuration": 0.7,
				"startEffect": "easeOutSine",
				"fontFamily": "Nanum Gothic",
				"categoryAxis": {
					"gridPosition": "start",
					"tickPosition": "start",
					"axisAlpha": 0,
					"gridAlpha": 0
				},
				"trendLines": [],
				"guides": [],
				"valueAxes": [
					{
						"id": "ValueAxis-1",
						"stackType": "regular",
						"autoGridCount": false,
						"title": "",
						"titleBold": false
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
					"autoMargins": false,
					"forceWidth": true,
					"marginLeft": 18,
					"marginRight": 5,
					"position": "right",
					"useGraphSettings": true,
					"verticalGap": 14
				},
				"titles": []
        };
        
	        chart = new argoAmChart('chartStackedRow', "custom", data,colorArry);
	        chart.init();
	        chart.addItem(serial_item1);
	        chart.addItem(serial_graph1);
	        chart.makeChart();
	    
	}  catch(e) {
	 alert( e);
	}
}  
 
function fnCallbackMakeChartLine(data, textStatus, jqXHR){
	    if(data.isOk()){
	    	fnMakeChartLine(data.getRows());
	    }
	    }
	    
function fnMakeChartLine(chartData){
	 try{
		 var colorArry = [  "#5571c6",
							"#55c6c2",
							"#db9d61",
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
		                  ]; // 순서데로 칼라 지정		 
		 
		 var chart_item1 = {
					"type": "serial",
					"categoryField": "title",
					"columnSpacing": 0,
					"autoMargins": false,
					"marginBottom": 48,
					"marginLeft": 62,
					"marginRight": 20,
					"marginTop": 61,
					"sequencedAnimation": false,
					"startDuration": 0.7,
					"startEffect": "easeOutSine",
					"color": "#575757",
					"fontFamily": "Nanum Gothic",
					"fontSize": 12,
					"categoryAxis": {
						"gridPosition": "start",
						"axisAlpha": 0
					},
					"trendLines": [],
					"graphs": [
						{
							"balloonText": "근태 of [[category]]:[[value]]",
							"bullet": "round",
							"id": "AmGraph-1",
							"title": "근태",
							"type": "smoothedLine",
							"valueField": "value1"
						},
						{
							"balloonText": "QA모니터링 of [[category]]:[[value]]",
							"bullet": "square",
							"id": "AmGraph-2",
							"title": "QA모니터링",
							"type": "smoothedLine",
							"valueField": "value2"
						},
						{
							"balloonText": "생산성평가 of [[category]]:[[value]]",
							"bullet": "square",
							"id": "AmGraph-3",
							"title": "생산성평가",
							"type": "smoothedLine",
							"valueField": "value3"
						}
					],
					"guides": [],
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
						"align": "right",
						"autoMargins": false,
						"bottom": 16,
						"marginBottom": 36,
						"marginLeft": 2,
						"marginRight": 7,
						"marginTop": 19,
						"position": "right",
						"useGraphSettings": true
					},
					"titles": []
			      };
			    
			    var pieChart1 = argoAmChart('chartRowCurve', 'custom', chartData, colorArry);
			    pieChart1.init();
			    pieChart1.addItem(chart_item1);
			    pieChart1.makeChart(); 
			    
			    
	}  catch(e) {
	 alert( e);
	}
	} 

function fnCallbackMakeChartBar(data, textStatus, jqXHR){
	    if(data.isOk()){
	    	fnMakeChartBar(data.getRows());
	    }
	    }
	    
function fnMakeChartBar(chartData){
	 try{
		 var chart_item1 = {
					"type": "serial",
					"categoryField": "title",
					"columnWidth": 0.46,
					"rotate": true,
					"angle": 7,
					"autoMarginOffset": 22,
					"autoMargins": false,
					"marginBottom": 50,
					"marginLeft": 75,
					"marginRight": 47,
					"marginTop": 57,
					"zoomOutButtonTabIndex": 0,
					"sequencedAnimation": false,
					"startDuration": 0.7,
					"startEffect": "easeOutSine",
					"color": "#4A4A4A",
					"fontFamily": "Nanum Gothic",
					"fontSize": 12,
					"categoryAxis": {
						"gridPosition": "start",
						"axisAlpha": 0.57,
						"axisColor": "#A3A3A3",
						"boldLabels": true,
						"dashLength": 3,
						"gridAlpha": 0.23,
						"gridColor": "#444444",
						"labelOffset": 2,
						"minorGridAlpha": 0,
						"tickLength": 0
					},
					"trendLines": [],
					"graphs": [
						{
							"colorField": "color",
							"fillAlphas": 1,
							"id": "AmGraph-1",
							"lineColorField": "color",
							"title": "graph 1",
							"type": "column",
							"valueField": "value"
						}
					],
					"guides": [],
					"valueAxes": [
						{
							"id": "ValueAxis-1",
							"autoGridCount": false,
							"axisColor": "#A3A3A3",
							"tickLength": 0,
							"title": "",
							"titleBold": false
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
					"titles": [],
				} ;
		  var pieChart1 = argoAmChart('chartRowBar', 'custom', chartData);
		    pieChart1.init();
		    pieChart1.addItem(chart_item1);
		    pieChart1.makeChart(); 
 	    
	}  catch(e) {
	 alert( e);
	}
}
	    
	
</script>

</head>

<body>
	<div class="main_wrap">
        <div class="info_row">
            <div class="box approval">
                <div class="cont_box">
                    <div class="title">종합결제함</div>
                    <a href="#" class="btn_more" title="more">more</a>
                    <div class="cont">
                    	<ul class="info_list">
                        	<li><a href="#">근태신청</a><span class="num">1/1</span></li>
                            <li><a href="#">업무일지</a><span class="num">1/3</span></li>
                            <li><a href="#">시간의근무</a><span class="num">2/2</span></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="box notice">
                <div class="cont_box">
                    <div class="title">공지사항</div>
                    <a href="#" class="btn_more" title="more">more</a>
                    <div class="cont">
                    	<ul class="info_list">
                        	<li><span class="info_title"><a href="#">테스트 일정입니다.테스트 일정입니다.테스트 </a></span><span class="info_user">홍길동</span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">테스트 일정입니다.</a></span><span class="info_user">홍길동</span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">테스트 일정입니다.</a></span><span class="info_user">홍길동</span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">테스트 일정입니다.</a></span><span class="info_user">홍길동</span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">테스트 일정입니다.</a></span><span class="info_user">홍길동</span><span class="info_date">2016.10.17</span></li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="box schedule">
                <div class="cont_box">
                    <div class="title">스케쥴</div>
                    <a href="#" class="btn_more" title="more">more</a>
                    <div class="cont">
                    	<ul class="info_list">
                        	<li><span class="info_title"><a href="#">교육일정입니다.교육일정입니다.교육일정입니다.</a></span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">교육일정입니다.</a></span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">교육일정입니다.</a></span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">교육일정입니다.</a></span><span class="info_date">2016.10.17</span></li>
                            <li><span class="info_title"><a href="#">교육일정입니다.</a></span><span class="info_date">2016.10.17</span></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        <div class="char_row">
            <div class="chart_area">
                <div class="box call">
                    <div class="cont_box">
                        <div class="title">2016년 6월 콜 실적통계</div>
                        <div id="chartPie" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                        
                    </div>
                </div>
                <div class="box kpi">
                    <div class="cont_box">
                        <div class="title">성과실적과 비중</div>   
                        <div id="chartStackedRow" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                     
                    </div>
                </div>
            </div>
            <div class="chart_area">
                <div class="box retire">
                    <div class="cont_box">
                        <div class="title">퇴직률 통계</div>     
                        <div id="chartRowCurve" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                      
                    </div>
                </div>
                <div class="box people">
                    <div class="cont_box">
                        <div class="title">인원 통계</div>    
                        <div id="chartRowBar" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                     
                    </div>
                </div>                        
            </div>
        </div>
    </div>
</body>
</html>
