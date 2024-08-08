<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko" style="background:#FFFFFF;">
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
	<script type="text/javascript"	src="<c:url value="/scripts/velocejs/veloce.basic.js?ver=2018121207"/>"></script>
	<script type="text/javascript" src="<c:url value="/scripts/player/player_api_others.js"/>"></script>
<%
	String strTenant 	= request.getParameter("tenant_id");
	String strCallID 	= request.getParameter("call_id") == null ? "" : request.getParameter("call_id");
	String strIP 		= request.getParameter("ip");
	String strPort 		= request.getParameter("port");
	String strManagerID = request.getParameter("manager_id");
	String strEncKey 	= "BRIDGETEC_VELOCE"; 
			//request.getParameter("enc_key");
	String strDnno 		= request.getParameter("dn_no");
	String strRecTime 	= request.getParameter("rec_time");
	
	//String strLogListeningKey 	= request.getParameter("logListeningKey");
	//String strLogWorkerId 		= request.getParameter("logWorkerId");
    String strAutoPlay 			= request.getParameter("AutoPlay");
	String app_use 				= request.getParameter("app_use");
	
	if (strPort == "" || strPort == null)
		strPort = "7210";
	
	String strHASH_TABLE 	= "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	String strKey 			= "BRIDGETEC_VELOCE";

	java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("ssmmMMyyyyddHH");
	String strTime = formatter.format(new java.util.Date());

// 	System.out.println(strCallID);
	int nKeyLen = strCallID.length();
	int nKeyTableSize = strHASH_TABLE.length();

	while (strKey.length() < nKeyLen) {
		strKey = strKey + strKey;
	}

	while (strTime.length() < nKeyLen) {
		strTime = strTime + strTime;
	}

	char chKey;
	char chTime;
	char chUcid;
	char chEncKey;

	int nChar;
	char[] szEncKey = new char[nKeyLen];

	for (int i = 0; i < nKeyLen; i++) 
	{
		chKey 		= strKey.charAt(i);
		chTime 		= strTime.charAt(i);
		chUcid 		= strCallID.charAt(i);
		int nKey 	= (int) chKey;
		int nTime 	= (int) chTime;
		int nUcid 	= (int) chUcid;
		if(nUcid >= 0 && nKey >= 0 && nTime >= 0 && nKeyTableSize >= 0) {
			nChar 	= (int) ((nUcid + nKey + nTime) % nKeyTableSize);
		} else {
			nChar	= 0;
		}
		chEncKey 	= strHASH_TABLE.charAt(nChar);
		szEncKey[i] = chEncKey;
	}

	strEncKey = new String(szEncKey);
	//테스트 
	if (strIP == "" || strIP == null)
		//strIP = "172.19.132.158";
		strIP = "100.100.107.37";
	//테스트
// 	String strURL 		= "http://" + strIP + ":" + strPort + "/fileplay2/"+strDnno+"/" + strManagerID + "/" + strCallID + "/" + strEncKey + "/"+strDnno+".mp3";
// 	String strLogURL 	= "http://" + strIP + ":" + strPort + "/rec_log?call_id="+strCallID+"&tenant_id=VLC_SSO_TENANT_ID&worker_id="+strManagerID+"&realtime_flag=0&reason=RTITLE&reason_text=RTEXT";

	String protocol 	= request.isSecure() ? "https://" : "http://";
	String strURL 		= protocol + strIP + ":" + strPort + "/fileplay2/"+strDnno+"/" + strManagerID + "/" + strCallID + "/" + strEncKey + "/"+strDnno+".mp3";
	String strLogURL 	= protocol + strIP + ":" + strPort + "/rec_log?call_id="+strCallID+"&tenant_id=VLC_SSO_TENANT_ID&worker_id="+strManagerID+"&realtime_flag=0&reason=RTITLE&reason_text=RTEXT";
%>
	<script type="text/javascript">
		var player		= new sttPlayer();
		
		// 구간반복 클릭 횟수
		var clickCnt = 0;
		
		$(window).load(function() {
			//var player		= new sttPlayer();
			
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
			var strUrl 	= "<%=strURL%>";
			
			sArea.on('click',player.areaCheck);
			playPause.on('click', player.play_pause);
			playBack.on('click', player.play_back);
			playQuick.on('click', player.play_quick);
			
			speed1.on( "click", { speed: 0.5 }, player.setSpeed );
			speed2.on( "click", { speed: 1.0 }, player.setSpeed );
			speed3.on( "click", { speed: 1.5 }, player.setSpeed );
			speed4.on( "click", { speed: 2.0 }, player.setSpeed );
			
			// speed btn css change
			$('#speed_2').css({color:"#191a1c", "background-color": "#fff"});
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
			
			sArea.mousemove(function(event){ player.showHover(event); });
			sArea.mouseout(player.hideHover);
			
			
			
			player.initPlayer(strUrl, sArea, seekBar, tProgress, tTime, sHover, insTime, function() {
				
					strReason 		= $('#s_logReasonTitle').val();
					strReasonText 	= $("#str_reason").val();
					var strlogurl 	= "<%=strLogURL%>";	
					var strTenant 	= vlcOPT.VLC_SSO_TENANT_ID;
					
					strlogurl = strlogurl.replace("VLC_SSO_TENANT_ID",strTenant);
					strlogurl = strlogurl.replace("RTITLE",strReason);
					strlogurl = strlogurl.replace("RTEXT",strReasonText);
					
					var httpRequest = new XMLHttpRequest();
					httpRequest.open("GET", strlogurl, true);
					httpRequest.send();
					
					httpRequest.onreadystatechange = function() {
						//alert(httpRequest.status);
						//alert(httpRequest.responseText);
					    return;
					};
				return true;
			}); 
			
			
			if( "<%=strAutoPlay%>" == "1" ) {
				playAudio();
				return;
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
		
		function playAudio() {
			player.play_pause(function(isRunning) {
				var arrChecked 	= w2ui['grid'].getSelection();	
				if(arrChecked.length == 0) 
					return ;
				
				var strUrl 		= w2ui['grid'].getCellValue(arrChecked[0], 1);
				var strlogurl	= w2ui['grid'].getCellValue(arrChecked[0], 2);
				if (audio.src == "" || audio.src != strUrl)
					audio.src		= strUrl;
				var strTenant 	= vlcOPT.VLC_SSO_TENANT_ID;
				
				strlogurl = strlogurl.replace("VLC_SSO_TENANT_ID",strTenant);
				
				var httpRequest = new XMLHttpRequest();
				httpRequest.open("GET", strlogurl, true);
				httpRequest.send();
				
				httpRequest.onreadystatechange = function() {
					console.log("insert log status[" + httpRequest.status + "]");
					//alert(httpRequest.responseText);
				    return;
				};
				
				// speed btn css change
				changeSpeedCss();
				
				return true;
			});
		}
	</script>
	<title>Player</title>
</head>
<body>
	<div id="playerCover" style="height: 135px;margin-top:0;">
		<!-- <div class="title"><p>청취 (고객명 : 정보없음)</p><button><img src="/images/player/x.png"/></button></div> -->
		<div>
			<div class="play_area">
				<div class="btn_play">
				  <button id="playBack" class="back"><img src="../images/player/back.png"/></button>
				  <button id="playPause"><img src="../images/player/play.png"/></button>
				  <button id="playQuick" class="quick"><img src="../images/player/quick.png"/></button>
				</div>
				<div class="btn_speed" style="font-size:13px;">
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
					<li><span>&middot</span> 통화시간 : <%= strRecTime%></li>
					<li><span>&middot</span> 내선 : <%= strDnno%></li>
					<li><span>&middot</span> 청취자 : <%= strManagerID%></li>
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
				    <span id="aTotal" class="total-time">--:--</span>
				</div>
			</div>
		</div>
		
	</div><!--playerCover-->
</body>
</html>
