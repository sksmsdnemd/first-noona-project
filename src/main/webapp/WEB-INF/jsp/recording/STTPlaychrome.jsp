<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="java.net.URLDecoder"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="author" content="ARGO" />
	<meta name="description" content="ARGO" />
	<meta name="keywords" content="ARGO" />
	<link rel="stylesheet" 	href="<c:url value="/css/playerSkin.css?ver=2017011301"/>"	type="text/css" />
	<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
	<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>"  type="text/css" />
	<script type="text/javascript"	src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.core.js?ver=2017021401"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.common.js?ver=2017022810"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.util.js?ver=2017021601"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017021301"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.popWindow.js?ver=2017010611"/>"></script>
	<script type="text/javascript"  src="<c:url value="/scripts/argojs/argo.popSmallWindow.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
	<script type="text/javascript"	src="<c:url value="/scripts/velocejs/veloce.basic.js?ver=2018121207"/>"></script>
	<script type="text/javascript" src="<c:url value="/scripts/player/player_C.js"/>"></script>
	<script type="text/javascript">
	var playList	= new Array();
	var dataArray 	= new Array();
	var player		= new sttPlayer();
	var nowPlayRow = 0;
	var isUseRecReason;
	//청취사유 플래그
	var recLogFlagArray = new Array();
	
	// 구간반복 클릭 횟수
	var clickCnt = 0;
<%
	String 	strAutoPlay 	= request.getParameter("AutoPlay");
	if (strAutoPlay == "" || strAutoPlay == null)
		strAutoPlay	= "1";
	String 	recData			= request.getParameter("recData");
	String 	app_use 		= request.getParameter("app_use");
	String	recProtocol		= request.getParameter("recProtocol");
	
	String strManagerID ="";
	String strDnno = "";
	String strRecTime = "";
	if (recData != "" && recData != null)
	{
		System.out.println("============================================================START STTPlay============================================================================");
		String		decodeData	= URLDecoder.decode(recData, "UTF-8");
		System.out.println(decodeData);
		
		JSONParser	jsonParser	= new JSONParser();
		JSONArray	jsonArray	= (JSONArray) jsonParser.parse(decodeData);
		
		String 		strHASH_TABLE 	= "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		String 		strKey 			= "BRIDGETEC_VELOCE";
		
		java.text.SimpleDateFormat 	formatter 	= new java.text.SimpleDateFormat("ssmmMMyyyyddHH");
		String 						strTime 	= formatter.format(new java.util.Date());
		
		for (int index = 0; index < jsonArray.size(); index++) {
			JSONObject	item				= (JSONObject)jsonArray.get(index);
			String 		strTenant 			= (String)item.get("tenant_id");
			String 		strCallID 			= (String)item.get("call_id");
			String 		strIP 				= (String)item.get("ip");
// 			String 		strPort 			= "7210";
			String 		strPort 			= (item.containsKey("port") && item.get("port").toString() != "") ? item.get("port").toString() : "7210";
			strManagerID 					= (String)item.get("manager_id");
			String 		strEncKey 			= (String)item.get("enc_key");
			strDnno 			= (String)item.get("dn_no");
			strRecTime 			= (String)item.get("rec_time");
			String		userName			= (String)item.get("userName");
			String		custTel				= (String)item.get("custTel");
			long		endTime				= (Long)item.get("endTime");
			String		custName			= (String)item.get("custName");
			int 		nKeyLen 			= strCallID.length();
			int 		nKeyTableSize 		= strHASH_TABLE.length();
			
			while (strKey.length() < nKeyLen) {
				strKey = strKey + strKey;
			}
			
			while (strTime.length() < nKeyLen){
				strTime = strTime + strTime;
			}
			
			char chKey;
			char chTime;
			char chUcid;
			char chEncKey;
			
			int 	nChar;
			char[] 	szEncKey = new char[nKeyLen];
			
			for (int i = 0; i < nKeyLen; i++)  {
				chKey = strKey.charAt(i);
				chTime = strTime.charAt(i);
				chUcid = strCallID.charAt(i);
				int nKey = (int) chKey;
				int nTime = (int) chTime;
				int nUcid = (int) chUcid;
				if(nUcid >= 0 && nKey >= 0 && nTime >= 0 && nKeyTableSize >= 0) {
					nChar = (int) ((nUcid + nKey + nTime) % nKeyTableSize);
				} else {
					nChar = 0;
				}
				chEncKey = strHASH_TABLE.charAt(nChar);
				szEncKey[i] = chEncKey;
			}
			
			String protocol 		= request.isSecure() ? "https://" : "http://";

// 			String protocol 		= recProtocol; //request.isSecure() ? "https://" : "http://";
			
			strEncKey 				= new String(szEncKey);
// 			String strLogURL 		= "http://" + strIP + ":" + strPort + "/rec_log?call_id="+strCallID+"&tenant_id=strTenant&worker_id="+strManagerID+"&realtime_flag=0&reason=RTITLE&reason_text=RTEXT";
// 			String strLogURL 		= "http://" + strIP + ":" + strPort + "/rec_log?call_id="+strCallID+"&tenant_id="+strTenant+"&worker_id="+strManagerID+"&realtime_flag=0";
// 			String strURL 			= "http://" + strIP + ":" + strPort + "/fileplay2/"+strDnno+"/" + strManagerID + "/" + strCallID + "/" + strEncKey + "/" +strDnno+".mp3";
			String strLogURL 		= protocol + strIP + ":" + strPort + "/rec_log?call_id="+strCallID+"&tenant_id="+strTenant+"&worker_id="+strManagerID+"&realtime_flag=0";
			String strURL 			= protocol + strIP + ":" + strPort + "/fileplay2/"+strDnno+"/" + strManagerID + "/" + strCallID + "/" + strEncKey + "/" +strDnno+".mp3";
			
			//System.out.println("윤영식2 ::::::"+strURL);		
	%>
			var strLogURL	= "<%=strLogURL%>";
			var url			= "<%=strURL%>";
			var cell		= new Object();
			var tenantId	= "<%=strTenant%>"; 
			 
			cell.recTime	= "<%=strRecTime%>";
			cell.endTime	= "<%=endTime%>";
			cell.userName	= "<%=userName%>";
			cell.custName	= "<%=custName%>";
			cell.custTel	= "<%=custTel%>";
			cell.logurl		= "<%=strLogURL%>";
			
			playList[url] = cell;
	<%
		}
	}
	
%>
	var playFlag = true;
	$(window).load(function() {
		
		// 청취사유 사용여부
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_REC_REASON"}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						isUseRecReason = data.getRows()['code'];
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
		
		
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        multiSelect : false,
	        show: 
	        {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        onClick: function(event) 
	        {
	        	if (event.recid >= 0) {
	        		if (event.column != null) {
		        		$('#clip_target').val(w2ui['grid'].getCellValue(event.recid, event.column));
		        		$('#clip_target').select();
		        		var successful = document.execCommand('copy');	        			
	        		}
	        	}	
	        	
	        },
			onDblClick : function(event) {
				if (event.recid >= 0) {
					audio.pause();
					playAudio(event.recid);
					
				}
			},
    
	        columns: [  
	        		     { field: 'recid', 		caption: 'recid', 	size: '0px', 	attr: 'align=center' }
	        		    ,{ field: 'recurl', 	caption: 'url', 	size: '0px', 	attr: 'align=center' }
	        	        ,{ field: 'recTime', 	caption: '녹음시간', 	size: '160px', 	attr: 'align=center' }
	        	        ,{ field: 'endTime', 	caption: '통화시간', 	size: '90px', 	attr: 'align=center' }
		            	,{ field: 'userName', 	caption: '상담사명', 	size: '80px', 	attr: 'align=center' }
		            	,{ field: 'custName', 	caption: '고객명', 	size: '80px', 	attr: 'align=center' }
		    			,{ field: 'custTel', 	caption: '전화번호', 	size: '80px', 	attr: 'align=center' }
		               	
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'recurl', 'reclog');
		var count = 0;
		for (var index in playList)
		{
			var item		= playList[index];
			var gridObject 	= {
					'recid': count,
					'recurl': index,
					'reclog' : item.logurl,
					'recTime' : item.recTime,
					'endTime' : fnSecondsConv(item.endTime),
					'userName' : item.userName,
					'custName' : item.custName,
					'custTel' : item.custTel
					
			}
			
			
			dataArray.push(gridObject);
			count++;
		}
		
	
		w2ui['grid'].add(dataArray);
		$('#gridList').show();
		w2ui.grid.unlock();
		
		var playPause 	= $('#playPause');
		var sArea 		= $('#progress');
		var seekBar 	= $('#progress-pin');
		var tProgress 	= $('#current_time');
		var tTime 		= $('#aTotal');
		var sHover 		= $('#sHover');
		var insTime 	= $('#insTime');
		var playBack 	= $('#playBack'), playQuick = $('#playQuick');
		var speed1 		= $('#speed_1'), speed2 = $('#speed_2'), speed3 = $('#speed_3'), speed4 = $('#speed_4'); 
		
		var logPl 			= null;
		var strReason 		= null;
		var strReasonText 	= null;
		var curTime 		= 0;
		var duration 		= 0;

		
		
		
		sArea.on('click',player.areaCheck);
		
		player.initPlayer(sArea, seekBar, tProgress, tTime, sHover, insTime); 
		
		playPause.on('click', function(){ 
			
			if(audio.paused){
				playAudio(nowPlayRow);
			}else{
				changePlayCon();
				audio.pause();
			}
		});
		
		
	
		playBack.on('click', player.play_back);
		playQuick.on('click', player.play_quick);
		
		speed1.on( "click", { speed: 0.5 }, player.setSpeed );
		speed2.on( "click", { speed: 1.0 }, player.setSpeed );
		speed3.on( "click", { speed: 1.5 }, player.setSpeed );
		speed4.on( "click", { speed: 2.0 }, player.setSpeed );
		
		// speed btn css change
		speed1.on( "click", changeSpeedCss );
		speed2.on( "click", changeSpeedCss );
		speed3.on( "click", changeSpeedCss );
		speed4.on( "click", changeSpeedCss );
		
		
		// 구간반복 버튼 클릭 이벤트 Start
		$("#repeat_btn").css({color:"#fff", "background-color": "#191a1c"});
		$("#repeat_btn").on("click", function() {
			if(!$("#repeat_btn").attr("name")) {
				$("#repeat_btn").attr("name", "repeat_btn");
				$("#repeat_btn").css({color:"#191a1c", "background-color": "#fff"});
			} else {
				$("#repeat_btn").removeAttr("name");
				$("#repeat_btn").css({color:"#fff", "background-color": "#191a1c"});
				
				clickCnt = 0;
				$("#gstime").val("");
				$("#getime").val("");
				
				$("#progress-gspin").css("display", "none");
				$("#progress-gspin").css("margin-left", "0px");
				$("#progress-gepin").css("display", "none");
				$("#progress-gepin").css("margin-left", "0px");
			}
		});
		// 구간반복 버튼 클릭 이벤트 End
		
		// 재생 종료 시 
		audio.onended = function() {
			changePlayCon();
			if(dataArray.length > 1){
				if((nowPlayRow + 1) < dataArray.length ){
					playAudio(nowPlayRow+1);
				}else{
					playAudio(0);
				}
			} else {
				audio.currentTime = 0;
			}
		};
		sArea.mousemove(function(event){ player.showHover(event); });
		sArea.mouseout(player.hideHover);
		if( "<%=strAutoPlay%>" == "1" )
		{
			
			
			w2ui.grid.select(0);
			var arrChecked 	= w2ui['grid'].getSelection();
			if (arrChecked.length <= 0)
				return;
			
			playAudio(0);
			return;
		}
		
		
		if("<%=app_use%>"!="1")
		{
			//$(window).unload(function(player)
			//{
			//	player.stop_play();
			//	player	= null;
			//}.bind(this, player));
		}
		
	});
	
	function changeSpeedCss() {
		if(audio.playbackRate == "0.5") {
			$('#speed_1').css({color:"#191a1c", "background-color": "#fff"});
			$('#speed_2').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_3').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_4').css({color:"#fff", "background-color": "#191a1c"});
		} else if(audio.playbackRate == "1") {
			$('#speed_1').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_2').css({color:"#191a1c", "background-color": "#fff"});
			$('#speed_3').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_4').css({color:"#fff", "background-color": "#191a1c"});
		} else if(audio.playbackRate == "1.5") {
			$('#speed_1').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_2').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_3').css({color:"#191a1c", "background-color": "#fff"});
			$('#speed_4').css({color:"#fff", "background-color": "#191a1c"});
		} else if(audio.playbackRate == "2") {
			$('#speed_1').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_2').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_3').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_4').css({color:"#191a1c", "background-color": "#fff"});
		} else {
			$('#speed_1').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_2').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_3').css({color:"#fff", "background-color": "#191a1c"});
			$('#speed_4').css({color:"#fff", "background-color": "#191a1c"});
		}
	}
	
	/* 청취 사유 팝업창 열기*/
	function confirmRecLog(recid){
		var logHtml = '<div class="memo">' +'&middot 통화일자 : '+ w2ui["grid"].getCellValue(recid,2) +'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&middot 상담사 : '+ w2ui["grid"].getCellValue(recid,4)+'<table style="width:100%;"><colgroup><col width="15%"/><col width="85%"/></colgroup>'
			+'<tr><td><span style="font-size:17px; color:#e80101; ">*</span> 분류</td><td> <select id="s_logReasonTitle" name="s_logReasonTitle" class="list_box" style="background-color: #ffffff; width: 150px;border: 0.5px solid #eaeaea;">'
			+ '<option value="">선택하세요!</option>'
			+ '<option value="고객요청">고객요청</option>'
			+ '<option value="민원처리">민원처리</option>'
			+ '<option value="기관제출">기관제출</option>'
			+ '<option value="업무처리확인">업무처리확인</option>'
			+ '<option value="QA평가">QA평가</option>'
			+ '<option value="본인콜 확인">본인콜 확인</option>'
			+ '<option value="기타2">기타2</option>'
			+ '<option value="기타3">기타3</option>'
			+ '</select></td>'
			+ '<tr><td>청취사유</td><td><textarea id="str_reason" style="border: 0.5px solid #eaeaea;height:16px;" placeholder="청취사유를 입력하세요."></textarea></td>'
			+'</tr></table></div>';

			
			var html = "";
			html += '<div class="pop_alim">'
	        html += 	'<div class="pop_bgLayer"></div>'
	        html += 	'<div class="pop_box">'
	        html +=             '<div class="pop_t">'
	        html +=                 '<div class="pop_message" style="padding:0">'+logHtml+'</div>'
	        html +=             '</div>'
			html +=             '<div class="pop_h">'
	        html +=                 '<div class="pop_message2"></div>'
	        html +=             '</div>'
	        html +=             '<div class="pop_b">'
	        html +=                    	'<a href="#" class="pop_confirm" onclick="javascript:saveRecLog('+String(recid)+')">OK</a>'
	        html +=                     '<a href="#" class="pop_cancel" onclick="javascript:closePopupWindow()">Cancel</a>'
	        html +=             '</div>'
	        html +=     '</div>'
	        html += '</div>'
			
			$("body").append( html );
	        $(".pop_alim").css("display", "block");
	        setTimeout(function(){	$(".pop_bgLayer").css("opacity", "0.4");},10);
	}
	
	
	
	
	
	/* 청취 사유 팝업창 닫기*/
	function closePopupWindow(){
		$(".pop_alim").remove();
		return;
	}
	
	
	/* 청취사유 등록 */
	function saveRecLog(recid){

		
		var strReason = $(".memo").find("select[id=s_logReasonTitle]").val();
		var strReasonText = $(".memo").find("#str_reason").val();
		
		if(strReason == ""  )  {
			alert("청취사유를 입력하셔야 재생이 가능합니다.");
				return;
		}else{
			var strlogurl 	= strLogURL;	
			var strTenant 	= vlcOPT.VLC_SSO_TENANT_ID;
			strlogurl = strlogurl.replace("strTenant",strTenant);
			strlogurl = strlogurl.replace("RTITLE",strReason);
			strlogurl = strlogurl.replace("RTEXT",strReasonText);
		//reason=RTITLE&reason_text=RTEXT";
// 			strlogurl += "&RTITLE="+strReason+"&RTEXT="+strReasonText;
			strlogurl += "&reason="+strReason+"&reason_text="+strReasonText;
			
			//
			var httpRequest = new XMLHttpRequest();
			httpRequest.open("GET", strlogurl, true);
			httpRequest.send();
		
			httpRequest.onreadystatechange = function() {
				$(".pop_alim").remove();
			};
			
			recLogFlagArray.push(String(recid));
			playAudio(recid);
		}
	}
	

	function changePlayCon(){
		if(playFlag){
			$('#playPause img').prop('src','../images/player/pause.png');
			$('#playPause img').css('margin-left','4px');				
			playFlag = false;
		}else{
			$('#playPause img').prop('src','../images/player/play.png');
			$('#playPause img').css('margin-left','7px');
			playFlag = true;
		}
	}
	
	
	function playAudio(recid) {
		
		changePlayCon();
		
		w2ui['grid'].select(recid);
		
		player.play_pause(function(isRunning) {
			
			nowPlayRow	= recid;
			var strUrl 		= w2ui['grid'].getCellValue(recid, 1);
			if (audio.src == "" || audio.src != strUrl)
				audio.src		= strUrl;
			var strTenant 	= vlcOPT.VLC_SSO_TENANT_ID;
			
			var newDnno = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].recurl;
			newDnno = newDnno.split("/");
			newDnno = newDnno[newDnno.length-1].split(".mp3")[0];
			var newrecTime = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].recTime;
// 			audio.currentTime = 0;
			$("#aTotal").textContent="00:00";
			$("#rtVEL").text(newrecTime);
			$("#dnVEL").text(newDnno);
			
// 			var strlogurl = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].reclog;
// 			var httpRequest = new XMLHttpRequest();
// 			httpRequest.open("GET", strlogurl, true);
// 			httpRequest.send();
			
// 			httpRequest.onreadystatechange = function()
// 			{
// // 				console.log("insert log status[" + httpRequest.status + "]");
// 				//alert(httpRequest.responseText);
// 			    return;
// 			};
			
			// speed btn css change
			changeSpeedCss();
			
			return true;
		});
	}
	  
	</script>
	<title>Player</title>
</head>
<body>
	<div id="playerCover">
		<!-- <div class="title"><p>청취 (고객명 : 정보없음)</p><button><img src="/images/player/x.png"/></button></div> -->
		<div>
			<div class="play_area">
				<div class="btn_play">
				  <button id="playBack" class="back"><img src="../images/player/back.png"/></button>
				  <button id="playPause"><img src="../images/player/play.png"/></button>
				  <button id="playQuick" class="quick"><img src="../images/player/quick.png"/></button>
				</div>
				<div class="btn_speed">
					<button id="speed_1">x 0.5</button>
					<button id="speed_2">x 1.0</button>
					<button id="speed_3">x 1.5</button>
					<button id="speed_4">x 2.0</button>
					<!-- 구간반복 버튼 추가 Start -->
					<button id="repeat_btn">구간</button>
					<input type="hidden" id="gstime" style="width:40px; text-align:center;" value="">
					<input type="hidden" id="getime" style="width:40px; text-align:center;" value="">
					<!-- 구간반복 버튼 추가 End -->
				</div>
			</div>
			<div id="ri_info">
				<ul class="play_info">
				<!-- String 		strManagerID 		= (String)item.get("manager_id");
			String 		strEncKey 			= (String)item.get("enc_key");
			String 		strDnno 			= (String)item.get("dn_no");
			String 		strRecTime 			= (String)item.get("rec_time"); -->
					<li><span>&middot</span> 통화시간 : <span id="rtVEL"><%= strRecTime%></span></li>
					<li><span>&middot</span> 내선 : <span id="dnVEL"><%= strDnno%></span></li>
					<li><span>&middot</span> 청취자 : <span id="midVel"><%= strManagerID%></span></li>
				</ul>
				<div class="controls">
					<div id="insTime">00:00</div>
				    <span id="current_time" class="current-time">00:00</span>
				    <div class="slider" id="slider" data-direction="horizontal">
				      <div class="progress" id="progress">
				   		<div id="sHover"></div>
				   		<div class="pin" id="progress-pin" data-method="rewind"></div>
				   		<!-- 구간반복 마킹 표시 추가 Start -->
				   		<div class="gpin" id="progress-gspin" data-method="rewind"></div>
				   		<div class="gpin" id="progress-gepin" data-method="rewind"></div>
				   		<!-- 구간반복 마킹 표시 추가 End -->
				      </div>
				    </div>
				    <span id="aTotal" class="total-time">00:00</span>
				</div>
			</div>
		</div>
		
		<div id="gridList" style="margin:1.8% 3% 0 3%;height: 170px;background-color: #ffffff;">
		
		</div>
	</div><!--playerCover-->
</body>
</html>
