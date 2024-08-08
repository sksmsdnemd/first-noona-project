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
var fvChart02 ;

	$(function(){
		
		var multiService = new argoMultiService(fnCallbackChart);
		
		multiService.argoList("ARGOCOMMON", "SP_DASHBOARD01_01", "__", {})   /* 결재/인원현황 argoSelect*/
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_02", "__", {})   /* 공지사항 */
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_03", "__", {})   /* 인원현황 */
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_04", "__", {})   /* 업무별 인입현황 */
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_05", "__", {})   /* 업무별 인입상세 */
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_06", "__", {})   /* 콜인입현황*/
		            .argoList("ARGOCOMMON", "SP_DASHBOARD01_07", "__", {})   /* 상담그룹별 콜처리현황 */
	                 ;
		
		multiService.action();  
		
		function chart_resize(){
			var h = $(".chart_area .cont_box").height();
			$(".chart_div").height(h)	
		}
		
		//테이블 스크롤 체크
		$.fn.hasVerticalScrollBar = function() {
			return this.get(0) ? this.get(0).scrollHeight > this.innerHeight() : false;
		}
		$(window).on("resize", function(){
			chart_resize();			
			if($(".grid_b").hasVerticalScrollBar()){
				$(".grid_h").addClass("pr17");
			}else{
				$(".grid_h").removeClass("pr17");
			}
		})
		
		$(window).trigger("resize");		
	});
//------------------------------------------------------------------
//공지사항 상세 조회
//------------------------------------------------------------------
function fnGetPopup(obj){
	
var pNotiId=	$(obj).attr("data-value");
	gPopupOptions = {"pNotiId":pNotiId} ;        	    	
	argoPopupWindow('공지사항', gGlobal.ROOT_PATH+'/CM/CM1030S01F.do',  '1066', '689' );
}

//------------------------------------------------------------------
//큐그룹코드 설정 화면 오픈
//------------------------------------------------------------------
function fnGetPopup2(){
	
	gPopupOptions = {} ;        	    	
	argoPopupWindow('큐그룹관리', gGlobal.ROOT_PATH+'/common/QueueGroupMngF.do',  '800', '500' ); 
}

function fnCallbackChart(data, textStatus, jqXHR){
    if(data.isOk()){
    	
    	fnSetDashboard01(data.getRows(0)) ; // 결재/인원현황 처리
    	fnSetDashboard02(data.getRows(1)) ; // 공지사항
    	fnSetDashboard03(data.getRows(2)) ; // 인원현황
    	
    	fnMakeChart01(data.getRows(3)) ; // 업무별인입현황
    	fnSetDashboard04(data.getRows(4)) ; // 업무별 인입상세
    	
    	fnMakeChart02(data.getRows(5)); //콜인입현황
    	fnMakeChart03(data.getRows(6)); //상담그룹별 콜처리현황   	
    }
}

//------------------------------------------------------------------
//결재  설정
//------------------------------------------------------------------
function fnSetDashboard01(row) {	
	
	var aprroval_html = "";
	if( row.length > 1 ){
		aprroval_html +='<div class="title">종합결제함</div>'
		aprroval_html +='<a href="#" class="btn_more" title="more">more</a>'
		aprroval_html +='<div class="cont">'
		aprroval_html +=	'<ul class="info_list">'
		for( var i=0; i<row.length; i++ ){
			aprroval_html +=		'<li><a href="#">'+ row[i].approval +'</a><span class="num">'+ row[i].totalCnt +'</span></li>'	
		}	
		aprroval_html +=	'</ul></div>' ;
	}else{
		$(".box.approval").addClass("one");
		aprroval_html +='<div class="title">'+ row[0].approval +'</div>'
		//aprroval_html +='<a href="#" class="btn_more" title="more">more</a>'
		aprroval_html +='<a href="#" class="btn_more" title="more" id="HR2030" onclick="top.add_tab(this)" data-path="/HR/HR2030M01F.do" data-useroption="Y">근태신청/처리</a>'
		aprroval_html +='<div class="cont">'
		aprroval_html +=	'<ul class="info_list">'
		aprroval_html +=		'<li><span class="count_one"><strong class="num">'+ row[0].totalCnt +'</strong>건</span></li>'
		aprroval_html +=	'</ul></div>'
	} 
	$(".box.approval .cont_box").append( aprroval_html );	
}
//------------------------------------------------------------------
//공지사항
//------------------------------------------------------------------
function fnSetDashboard02(rowList) {
	$.each(rowList, function( index, row ) {	

		var strHtml = '<li><span class="info_title"><a href="#" onclick="fnGetPopup(this);"'  + ' data-value="' +row.notiId + '">'
            + row.notiTitle + '</a></span><span class="info_user">'
            + row.agentInfo + '</span><span class="info_date">'
            + row.modifyDt  + '</span></li>' ;   
            
	$("#divNoti").append( strHtml );
	});	
}

//------------------------------------------------------------------
//인원현황
//------------------------------------------------------------------
function fnSetDashboard03(rowList) {
	$.each(rowList, function( index, row ) {	
		$("#totalCnt1").html( row.totalCnt1 );	   
		$("#totalCnt2").html( row.totalCnt2 );	
		$("#totalCnt3").html( row.totalCnt3 );	
		$("#totalCnt4").html( row.totalCnt4 );	
		});	
}

//------------------------------------------------------------------
//업무별 인입상세
//------------------------------------------------------------------
function fnSetDashboard04(rowList) {
	 var sLastTime = "" ;
	 
	 if(rowList.length> 0 )  sLastTime = rowList[0].lastTime ; //당일 최종시간
	 	 
	 $(".grid_infoDate").html( sLastTime );
	 
	$.each(rowList, function( index, row ) {
		var strHtml = '<tr>'
			 		+ '<td>' + row.title + '</td>'
	                + '<td>' + row.total1 + '</td>'
	                + '<td>' + row.total2 + '</td>'
	                + '<td>' + row.total3 + '</td>'
	                + '<td>' + row.total4 + '</td>'
	                + '<td>' + row.total5 + '</td>'
	                + '<td>' + row.total6 + '</td>'
	                + '<td>' + row.total7 + '</td> </tr>' ;
	
	    $('#trList > tbody:last').append(strHtml);
		 
		});	
}

//------------------------------------------------------------------
//업무별 인입현황
//------------------------------------------------------------------	    
function fnMakeChart01(chartData){
	 try{
		 var sTotal = 0 ;
		 
		 if(chartData.length> 0 )  sTotal = chartData[0].total1 ; // 가운데 전체 응답율
		 	 
		 sTotal = sTotal+'%' ;
	 
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
				"marginTop": 40,
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
						"text": sTotal,
						"y": "44%"
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
	    
	    var pieChart1 = argoAmChart('chart01', 'custom', chartData ,colorArry);
		    pieChart1.init();
		    pieChart1.addItem(pie_item1);
		    pieChart1.makeChart(); 

	}  catch(e) {
	 	alert( e);
	}
	}

//------------------------------------------------------------------
//콜인입현황 챠트
//------------------------------------------------------------------	    
function fnMakeChart02(chartData){
	 try{
		 var chart_item1 = {
         	    "type"   : "serial",
        	    "theme"  : "light",
        	    "legend" : {
        	        "useGraphSettings": false
        	        ,position:"bottom"
        	        ,align:"center"
        	        ,borderAlpha:1
        	        ,borderColor:"#969595"
        	      //  ,marginTop:40
        	    },
        	    "dataProvider"   : chartData,
        	    "synchronizeGrid": false,
        	    "marginTop"      : 45,
        	    "position":"top",
        	    "valueAxes": [{
        	        "id"           :"v1",
        	        "axisColor"    : "#FF6600",
        	        "axisThickness": 2,
        	        "axisAlpha"    : 1,
        	        "position"     : "left"
        	    }, {
        	        "id"           :"v2",
        	        "axisColor"    : "#FCD202",
        	        "axisThickness": 2,
        	        "axisAlpha"    : 1,
        	        "position"     : "right"
        	    }, {
        	        "id"           :"v3",
        	        "axisColor"    : "#B0DE09",
        	        "axisThickness": 2,
        	        "gridAlpha"    : 0,
        	        "offset"       : 50,
        	        "axisAlpha"    : 1,
        	        "position"     : "left"
        	    }],
        	    "graphs": [
        	        {
        	        	"valueAxis" : "v1",	
        	        	 "lineColor": "#FF6600", 
        	        	 "balloonText":"[응대율]:[[value]]",
             	        "bullet"    : "round",
             	        "bulletBorderThickness": 2,
             	        "hideBulletsCount": 30,	
						"title"     : "응대율",
						"valueField": "value1",
						"fillAlphas": 0
				     }, {
		        	        "valueAxis" : "v2",
		        	        "lineColor" : "#5571c6",
		        	        "balloonText":"[인입]:[[value]]",
		        	        "bullet"    : "square",
		        	        "bulletBorderThickness": 1,
		        	        "hideBulletsCount": 30,
		        	        "title"     : "인입",
		        	        "valueField": "value2",
		        			"fillAlphas": 0
		        	    }, {
		        	        "valueAxis" : "v2",
		        	        "lineColor" : "#db9d61",
		        	        "balloonText":"[응대]:[[value]]",
		        	        "bullet"    : "triangleUp",
		        	        "bulletBorderThickness": 1,
		        	        "hideBulletsCount": 30,
		        	        "title"     : "응대",
		        	        "valueField": "value3",
		        			"fillAlphas": 0
		        	    }],
	      	    "chartScrollbar": {},
        	    "chartCursor": {
        	        "cursorPosition": "mouse"
        	    },
        	    "categoryField": "title",
        	    "categoryAxis": {
        	        "parseDates": true,
        	        "axisColor" : "#DADADA",
        	        "minorGridEnabled": false
        	       
        	    },
        	    "export": {
        	    	"enabled": false,
        	        "position": "bottom-right"
        	     }	
			    };			    
			    
			    fvChart02 = AmCharts.makeChart("chart02", chart_item1);
			    /*  zoomToIndexes 가 안됨.
			    fvChart02 = argoAmChart('chart02', "serial", chartData, colorArry);
			    fvChart02.init();
			    fvChart02.addItem(chart_item1);
			    fvChart02.makeChart(); 
			    */
			    // 최근 6개로 zoom 처리
			    
			    fvChart02.zoomToIndexes(chartData.length - 6, chartData.length - 1);
			    
	}  catch(e) {
	 alert( e);
	}
	} 

function fnMakeChart03(chartData){
	 try{
		 var chart_item1 = {
					  "type": "serial",
					  "theme": "light",
					  "marginRight":3,
					  "dataProvider": chartData,
					  "startDuration": 1,
					  "marginTop": 45,
					  "graphs": [{
					    "balloonText": "<b>[[title]]: [[totalCnt]]</b>",
					    "fillColorsField": "color",
					    "fillAlphas": 0.9,
					    "lineAlpha": 0.2,
					    "type": "column",
					    "valueField": "totalCnt"
					  }],
					  "chartCursor": {
					    "categoryBalloonEnabled": false,
					    "cursorAlpha": 0,
					    "zoomable": false
					  },
					  "categoryField": "title",
					  "categoryAxis": {
					    "gridPosition": "start",
					    "labelRotation": 45
					  },
					  "export": {
					    "enabled": false
					  }

					} ;			    
			    
		    var chart = argoAmChart('chart03', "serial", chartData);
		    chart.init();
		    chart.addItem(chart_item1);
		    chart.makeChart(); 

			    
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
                	
                </div>
            </div>
            <div class="box notice">
                <div class="cont_box">
                    <div class="title">공지사항</div>
                    <a href="#" class="btn_more" title="more" id="CM1030" onclick="top.add_tab(this)" data-path="/CM/CM1030M01F.do" data-useroption="Y">공지사항</a>
                    <div class="cont">
                    	<ul class="info_list" id="divNoti">
                        </ul>
                    </div>
                </div>
            </div>
            <div class="box personState">
                <div class="cont_box">
                    <div class="title">인원현황</div>
                    <a href="#" class="btn_more" title="more">more</a>
                    <a href="#" class="btn_more" title="more" id="HR2020" onclick="top.add_tab(this)" data-path="/HR/HR2020M01F.do" data-useroption="Y">CTI일일근무현황</a>
                    <div class="cont">
                    	<ul class="person_list">
                        	<li>
                            	<dl class="person_info">
                                	<dt>재직총원</dt>
                                    <dd><strong id="totalCnt1">0</strong>명</dd>
                                </dl>
                            </li>
                            <li>
                            	<dl class="person_info login">
                                	<dt>로그인수</dt>
                                    <dd>
                                    	<ul class="detail_info">
                                        	<li>
                                            	<p class="d_title">스텝</p>
                                                <p class="d_num"><strong id="totalCnt2">0</strong>명</p>
                                            </li>
                                            <li>
                                            	<p class="d_title">상담사</p>
                                                <p class="d_num"><strong id="totalCnt3">0</strong>명</p>
                                            </li>
                                        </ul>
                                    </dd>
                                </dl>
                            </li>
                            <li>
                            	<dl class="person_info">
                                	<dt>휴가/근태</dt>
                                    <dd><strong id="totalCnt4">0</strong>명</dd>
                                </dl>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <div class="char_row">
            <div class="chart_area">
                <div class="box call">
               
                    <div class="cont_box">
                     <a href="#" class="btn_set" title="설정" onclick="fnGetPopup2();">설정</a>
                        <div class="title">업무별 인입현황</div>
                        <div id="chart01" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                        
                    </div>
                </div>
                <div class="box kpi">
                    <div class="cont_box">
                        
                        <div class="title">업무별 인입상세</div>   
                        <span class="grid_infoDate">02/07 09:00</span>
                        <div class="grid_table">
                        	<div class="grid_h">
                            	<span class="grid_hs"></span>
                            	<table >
                                	<colgroup>
                                    	<col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                    </colgroup>
                                    <thead>
                                    	<tr>
                                        	<th rowspan="2">업무</th>
                                            <th colspan="3" class="br_b">당일</th>
                                            <th colspan="2" class="br_b">전영업일</th>
                                            <th rowspan="2">당월<br>인입</th>
                                            <th rowspan="2">전월<br>인입</th>
                                        </tr>
                                        <tr>
                                            <th>인입</th>
                                            <th>응대</th>
                                            <th>응대율</th>
                                            <th>인입</th>
                                            <th>응대율</th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                            <div class="grid_b">
                            	<table id="trList">
                                	<colgroup>
                                    	<col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                        <col width="12.5%">
                                    </colgroup>
                                    <tbody>
                                       
                                    
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="chart_area">
                <div class="box retire">
                    <div class="cont_box">
                        <div class="title">콜 인입현황</div>     
                        <div id="chart02" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                      
                    </div>
                </div>
                <div class="box people">
                    <div class="cont_box">
                        <div class="title">상담그룹별 콜처리현황</div>    
                        <div id="chart03" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                     
                    </div>
                </div>                        
            </div>
        </div>
    </div>
</body>
</html>
