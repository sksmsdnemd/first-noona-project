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
<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />

<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>

<script type="text/javascript" src="<c:url value="/scripts/amcharts/amcharts.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/serial.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/amcharts/radar.js"/>"></script>

<script>

	var fvChart02 ; // 성과실적 : 이동버튼에 따라 차트 데이터만 재설정 하기 위해 
	var fvChart02Month ;

$(function(){		
		
		fnGetMonth(argoDateToStr(new Date()));

		var multiService = new argoMultiService(fnCallbackChart);
		
		multiService.argoList("ARGOCOMMON", "SP_DASHBOARD02_01", "__", {})   /* 콜처리현황 */
					.argoList("ARGOCOMMON", "SP_DASHBOARD02_04", "__", {stdMonth:fvChart02Month})   /* 개인스케쥴-근무유형 */
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_01", "__", {})   /* 결재/인원현황 argoSelect*/
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_02", "__", {})   /* 공지사항 */
					.argoList("ARGOCOMMON", "SP_DASHBOARD01_03", "__", {})   /* 인원현황 */
					
	                 ;
		
		multiService.action(); 
		
		fnGetMonth(argoDateToStr(prevM)); // 전월 기준		

        fnGetDate(argoDateToStr(new Date()));
		fnSearchList01(); //개인스케줄
		
		fnInitChart();	
		fnSearchChart02(); // 성과실적 조회
		
		
		// 콜처리현황 부서명 표기
		$('#deptNm').text(top.gLoginUser.DEPT_NM) ;
		
		
		/************* 개인스케쥴 *************/
		$(".btn_scPrev").on("click", function(){
			fnGetDate(argoDateToStr(prevD));
			fnSearchList01();
		})	
		
		$(".btn_scNext").on("click", function(){
			fnGetDate(argoDateToStr(nextD));
			fnSearchList01();
		})		
		
		$(".scrollbar-inner").scrollbar();	
		
		/************* 성과실적 *************/
		//이전달	
		$(".btn_pePrev").on("click", function(){
			fnGetMonth(argoDateToStr(prevM));
			fnSearchChart02();
		})
		//다음달
		$(".btn_peNext").on("click", function(){
			fnGetMonth(argoDateToStr(nextM));
			fnSearchChart02();
		})
		
		
		function chart_resize(){
			var h = $(".chart_area.h280 .cont_box").height();
			$(".chart_div").height(h)	
		}		
		
		$(window).on("resize", function(){
			chart_resize();				
		})
		
		$(window).trigger("resize");
		
		
	});
	//------------------------------------------------------------------
	//개인스케쥴 일자 및 이동버튼 처리
	//------------------------------------------------------------------    	
    var intDayCnt1 = 0;
    var intDayCnt2 = 0;
	
	var vn_day1
	var week = ["일", "월", "화", "수", "목", "금", "토"];		
	var prevD;
	var prev_day;		
	var nextD;
	var next_day;		
	
	var fvScheduleDate ; // 개인스케쥴  현재일자
	
    function fnGetDate(obj) { //월요일 ~ 일요일 구하기		
    	fvScheduleDate = obj ;
        var year = obj.substring(0, 4);
        var month = obj.substring(4, 6);
        var day = obj.substring(6, 8);

        vn_day1 = new Date(year, month - 1, day);

        var i = vn_day1.getDay(); //기준일의 요일을 구한다.( 0:일요일, 1:월요일, 2:화요일, 3:수요일, 4:목요일, 5:금요일, 6:토요일 )
        intDayCnt1 = 0 - i;
        intDayCnt2 = 6 - i;
		
		var sDate = intDayCnt1;
		date_day = [];
		while(sDate <= intDayCnt2){
			var date_st = new Date(vn_day1.getFullYear(), vn_day1.getMonth(), vn_day1.getDate() + sDate);
			//var date_day = date_st.getFullYear()+"년 "+(date_st.getMonth()+1)+"월 "+date_st.getDate()+"일 "+ week[date_st.getDay()]+"요일";	
			date_day.push((date_st.getMonth()+1) + "/" + date_st.getDate())			
			sDate++;								
		}

		$(".txt_date").each(function(i){
			$(this).text(date_day[i]);
	
		});
		
		prevD = new Date(vn_day1.getFullYear(), vn_day1.getMonth(), vn_day1.getDate() + (--intDayCnt1));
		nextD = new Date(vn_day1.getFullYear(), vn_day1.getMonth(), vn_day1.getDate() + (++intDayCnt2));

    }	
	
	//------------------------------------------------------------------
	//성과실적 일자 및 이동버튼 처리
	//------------------------------------------------------------------    
	var result_day = "";
	var prevM = "";
	var nextM = "";
	function fnGetMonth(obj) { //년, 월 구하기		
        var year = obj.substring(0, 4);
        var month = obj.substring(4, 6);
        var day = obj.substring(6, 8);
		
		result_day = new Date(year, month - 1, day);
					
		var result_date = year + "년 " + month + "월"
		$(".grid_infoDate.result").text(result_date);
		fvChart02Month = year + month ;

		prevM = new Date(result_day.getFullYear(), result_day.getMonth() - 1, result_day.getDate() );
		nextM = new Date(result_day.getFullYear(), result_day.getMonth() + 1, result_day.getDate() );
		
    }
	
	function fnInitChart(){
		
		fvChart02 = new AmCharts.AmRadarChart();
	//	fvChart02.dataProvider = generateChartData();
		fvChart02.categoryField = "title";
		fvChart02.marginTop = 15;
		fvChart02.sequencedAnimation = false;
		fvChart02.depth3D = 20;
		fvChart02.angle = 30;
		fvChart02.fontSize = 13;
		
		// value
		var valueAxis = new AmCharts.ValueAxis();
		valueAxis.axisTitleOffset = 20;
		valueAxis.id = "v1";
		valueAxis.minimum = 0;
		valueAxis.axisAlpha = 0.15;
		valueAxis.dashLength = 3;
		valueAxis.axisColor =  "#FF6600"
		fvChart02.addValueAxis(valueAxis);
	
			// GRAPH            
		var graph = new AmCharts.AmGraph();		
		graph.balloonText = "[본인]: [[value]]";					
		graph.bullet = "round";
		graph.gapPeriod = 1;
		graph.id = "AmGraph-1";
		graph.valueField = "value1";		
		graph.lineAlpha = 1;
		graph.fillAlphas = 0;	
		graph.lineColor= "#5571c6";    	 
		fvChart02.addGraph(graph);
		
		var graph2 = new AmCharts.AmGraph();		
		graph2.balloonText = "[팀평균]: [[value]]";					
		graph2.bullet = "round";
		graph2.gapPeriod = 1;
		graph2.id = "AmGraph-2";
		graph2.valueField = "value2";		
		graph2.lineAlpha = 1;
		graph2.fillAlphas = 0;	
		graph2.lineColor= "#db9d61"; 
		fvChart02.addGraph(graph2);		
		
		var graph3 = new AmCharts.AmGraph();		
		graph3.balloonText = "[업무평균]: [[value]]";					
		graph3.bullet = "round";
		graph3.gapPeriod = 1;
		graph3.id = "AmGraph-3";
		graph3.valueField = "value3";		
		graph3.lineAlpha = 1;
		graph3.fillAlphas = 0;	
		graph3.lineColor= "#55c6c2"; 
		fvChart02.addGraph(graph3);			

		fvChart02.write("chart02");			
	}	
	
	function fnCallbackChart(data, textStatus, jqXHR){
	    if(data.isOk()){
	    	
	    	fnMakeChart01(data.getRows(0)) ; // 콜처리현황
	    	
	    	// 개인스케쥴 - 근무유형
	    	 $.each(data.getRows(1), function( index, row ) {
	    		 $('#worktypeInfo').text(row.worktypeInfo) ;
	    	 });
	    	
	    	// 우선 관리자모드와 동일하게 처리
	     	fnSetDashboard01(data.getRows(2)) ; // 결재/인원현황 처리
	    	fnSetDashboard02(data.getRows(3)) ; // 공지사항
	    	fnSetDashboard03(data.getRows(4)) ; // 인원현황
	    }
	}
	//------------------------------------------------------------------
	//공지사항 상세 조회
	//------------------------------------------------------------------
	function fnGetPopup(obj){
		
	var pNotiId=	$(obj).attr("data-value");
		gPopupOptions = {"pNotiId":pNotiId} ;        	    	
		argoPopupWindow('공지사항', gGlobal.ROOT_PATH+'/CM/CM1030S01F.do',  '1066', '689' );
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
	//개인스케쥴
	//------------------------------------------------------------------	    
	function fnSearchList01(){
		/*
		var rowList = [];
		rowList.push({	 idx  : 1  ,code: "출근" 	,codeNm:"08:55" }) ;
		rowList.push({	 idx  : 1  ,code: "퇴근" 	,codeNm:"13:00" }) ;
		rowList.push({	 idx  : 1  ,code: "근태" 	,codeNm:"반차" }) ;		
		rowList.push({	 idx  : 1  ,code: "기타" 	,codeNm:"업무평가(11:00)" }) ;
		rowList.push({	 idx  : 1  ,code: "기타" 	,codeNm:"교육(10:00)" }) ;
		
		rowList.push({	 idx  : 2  ,code: "출근" 	,codeNm:"08:57" }) ;
		rowList.push({	 idx  : 2  ,code: "퇴근" 	,codeNm:"18:55" }) ;		

		rowList.push({	 idx  : 3  ,code: "기타" 	,codeNm:"창립기념일" }) ;
		*/		
		var param = {"stdDate": fvScheduleDate}
		
		argoJsonSearchList('ARGOCOMMON','SP_DASHBOARD02_03','__', param, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						var rowList = data.getRows();
						// 일주일 loop
						$(".sc_list").each(function(i){
							$(this).empty() ;
							
							var strHtml1 ="" ;
							var strHtml2="";
							var strHtml3="";
							
							// 요일 인덱스별 데이터 filtering 
							 var data = $.grep( rowList, function(n,j){
							        return (n.idx == i);
							    });
				             
							  $.each(data, function( index, row ) {
								  var strHtml = "";
								  
								  if(row.code == "출근" || row.code == "퇴근") {
									  strHtml1 = strHtml1 + '<li><strong>' + row.code + '</strong>' + row.codeNm +'</li>' ;
								  }else if(row.code == "근태") {
									  strHtml2 = strHtml2 + '<li>'+ row.codeNm +'</li>' ;					  
								  }else if(row.code == "기타") {
									  strHtml3 = strHtml3 + '<li>'+ row.codeNm +'</li>' ;					  
								  }			  
								  });
							  
							 if(strHtml1.length>0) $(this).append(strHtml1);  
							 
							 if(strHtml2.length>0) {
								 strHtml2 = '<li><strong>근태</strong><ul class="d_list">' + strHtml2 + '</ul></li>'
								 $(this).append(strHtml2);  
							 }
							 
							 if(strHtml3.length>0) {
								 strHtml3 = '<li><strong>기타</strong><ul class="d_list">' + strHtml3 + '</ul></li>'
								 $(this).append(strHtml3);  	
								 }						
						});
					}
				}
			} catch(e) {
				console.log(e);
			}
		});
	}
	
	//------------------------------------------------------------------
	//성과실적
	//------------------------------------------------------------------	    
	function fnSearchChart02(){
		
		var param = {"stdMonth": fvChart02Month}
		
		argoJsonSearchList('ARGOCOMMON','SP_DASHBOARD02_02','__', param, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						fvChart02.dataProvider = data.getRows();
				    	fvChart02.validateData();							

					}
				}
			} catch(e) {
				console.log(e);
			}
		});
	}		
	//------------------------------------------------------------------
	//콜처리현황 챠트
	//------------------------------------------------------------------	    
	function fnMakeChart01(chartData){
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
	        	    "graphs": [
	        	        {
	        	        //	"valueAxis" : "v1",	
	        	        	 "lineColor": "#5571c6", 
	        	        	 "balloonText": "[본인]:[[value]]",
	             	        "bullet"    : "round",
	             	        "bulletBorderThickness": 2,
	             	        "hideBulletsCount": 30,	
							"title"     : "본인",
							"valueField": "value1",
							"fillAlphas": 0
					     }, {
			        	//        "valueAxis" : "v1",
			        	        "lineColor" : "#db9d61",
			        	    	 "balloonText":"[팀평균]:[[value]]",
			        	        "bullet"    : "square",
			        	        "bulletBorderThickness": 1,
			        	        "hideBulletsCount": 30,
			        	        "title"     : "팀평균",
			        	        "valueField": "value2",
			        			"fillAlphas": 0
			        	    }, {
			        	//        "valueAxis" : "v1",
			        	        "lineColor" : "#55c6c2",
			        	    	 "balloonText":"[업무평균]:[[value]]",
			        	        "bullet"    : "triangleUp",
			        	        "bulletBorderThickness": 1,
			        	        "hideBulletsCount": 30,
			        	        "title"     : "업무평균",
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
				    
				    var chart01 = AmCharts.makeChart("chart01", chart_item1);
				    /*  zoomToIndexes 가 안됨.
				    fvChart02 = argoAmChart('chart02', "serial", chartData, colorArry);
				    fvChart02.init();
				    fvChart02.addItem(chart_item1);
				    fvChart02.makeChart(); 
				    */
				    // 최근 6개로 zoom 처리
				    
				    chart01.zoomToIndexes(chartData.length - 6, chartData.length - 1);
				    
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
                                            	<p class="d_title">관리자</p>
                                                <p class="d_num"><strong id="totalCnt2">0</strong>명</p>
                                            </li>
                                            <li>
                                            	<p class="d_title">사용자</p>
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
            <div class="chart_area schedule">
                
                <div class="box scheduleW">
                    <div class="cont_box">
                        <div class="title">개인 스케쥴</div>   
                        <span class="grid_infoDate" id="worktypeInfo"></span>
                        <span class="sc_btns">
                            <a href="#" class="btn_scPrev">전주 이동</a>
                            <a href="#" class="btn_scNext">다음주 이동</a>
                        </span>
                        <div class="grid_table">
                        	<!--
                        	<div class="grid_h">
                            	<span class="grid_hs"></span>
                            	<table>
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
                                        	<th></th>
                                            <th><span class="txt_date"></span><span class="txt_day">일</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">월</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">화</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">수</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">목</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">금</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">토</span></th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                            <div class="grid_b">
                            	<table>
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
                                        <tr>
                                            <th>출근</th>
                                            <td></td>
                                            <td>08:42</td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>                                           
                                        </tr>
                                        <tr>
                                            <th>퇴근</th>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>                                          
                                        </tr>
                                        <tr>
                                            <th>근태</th>
                                            <td>11:00</td>
                                            <td></td>
                                            <td></td>
                                            <td>연차휴가</td>
                                            <td></td>
                                            <td></td>
                                            <td></td>                                         
                                        </tr>
                                        <tr >
                                            <th>기타</th>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td>창립기념일</td>
                                            <td></td>
                                            <td>
                                            	교육(14:00)<br>
                                                교육(14:00)<br>
                                                업무평가(18:30)
                                            </td>
                                            <td></td>                                         
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            -->
                            
                            <div class="grid_h">
                            	<span class="grid_hs"></span>
                            	<table>
                                	<colgroup>
                                        <col width="14.5%">
                                        <col width="14.5%">
                                        <col width="14%">
                                        <col width="14%">
                                        <col width="14%">
                                        <col width="14.5%">
                                        <col width="14.5%">
                                    </colgroup>
                                    <thead>
                                    	<tr>
                                            <th><span class="txt_date"></span><span class="txt_day">일</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">월</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">화</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">수</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">목</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">금</span></th>
                                            <th><span class="txt_date"></span><span class="txt_day">토</span></th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                            <div class="grid_b single">
                            	<table>
                                	<colgroup>
                                    	<col width="14.5%">
                                        <col width="14.5%">
                                        <col width="14%">
                                        <col width="14%">
                                        <col width="14%">
                                        <col width="14.5%">
                                        <col width="14.5%">
                                    </colgroup>
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div class="sc_scroll scrollbar-inner">
                                                    <ul class="sc_list">
                                                        <li><strong>출근</strong>08:42</li>
                                                        <li><strong>퇴근</strong>18:10</li>
                                                        <li>
                                                            <strong>기타</strong>
                                                            <ul class="d_list">
                                                                <li>교육(14:00)</li>
                                                                <li>업무평가(18:30)</li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </td>
                                            <td>
                                            	<div class="sc_scroll scrollbar-inner">
                                                    <ul class="sc_list">
                                                        <li><strong>출근</strong>08:42</li>
                                                        <li><strong>퇴근</strong>18:10</li>
                                                        <li>
                                                            <strong>근태</strong>
                                                            <ul class="d_list">
                                                                <li>연차휴가</li>
                                                                <li>연차휴가2</li>
                                                            </ul>
                                                        </li>
                                                        <li>
                                                            <strong>기타</strong>
                                                            <ul class="d_list">
                                                                <li>교육(14:00)</li>
                                                                <li>업무평가(18:30)</li>
                                                                <li>교육(14:00)</li>
                                                                <li>업무평가(18:30)</li>
                                                                <li>교육(14:00)</li>
                                                                <li>업무평가(18:30)</li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="sc_scroll scrollbar-inner">
                                                    <ul class="sc_list">
                                                        <li><strong>출근</strong>08:42</li>
                                                        <li><strong>퇴근</strong>18:10</li>
                                                    </ul>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="sc_scroll scrollbar-inner">
                                                    <ul class="sc_list">
                                                        <li><strong>출근</strong>08:42</li>
                                                        <li><strong>퇴근</strong>18:10</li>
                                                    </ul>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="sc_scroll scrollbar-inner">
                                                    <ul class="sc_list">
                                                       <li><strong>출근</strong>08:42</li>
                                                       <li></li>
                                                    </ul>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="sc_scroll scrollbar-inner">
                                                    <ul class="sc_list">
                                                        <li></li>
                                                        <li></li>
                                                    </ul>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="sc_scroll scrollbar-inner">
                                                    <ul class="sc_list">
                                                        <li></li>
                                                        <li></li>
                                                    </ul>
                                                </div>
                                            </td>                                         
                                        </tr>                                        
                                    </tbody>
                                </table>
                            </div>                            
                        </div>
                    </div>
                </div>
            </div>
            <div class="chart_area h280">
                <div class="box retire">
                    <div class="cont_box">
                        <div class="title">콜처리 현황</div>     
                        <span class="grid_infoDate" id="deptNm"></span>
                        <div id="chart01" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                      
                    </div>
                </div>
                <div class="box people">
                    <div class="cont_box">
                        <div class="title">성과실적</div>    
                        <span class="sc_btns">
                            <a href="#" class="btn_pePrev">전달 이동</a>
                            <a href="#" class="btn_peNext">다음달 이동</a>
                        </span>
                        <span class="grid_infoDate result"></span>
                        <div id="chart02" class="chart_div" style="width: 100%; height: 200px; background-color: #FFFFFF;" ></div>                     
                    </div>
                </div>                        
            </div>
        </div>
    </div>
</body>
</html>