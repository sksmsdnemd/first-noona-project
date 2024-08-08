<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="java.net.URLDecoder"%>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
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
	<link rel="stylesheet" href="<c:url value="/css/videoPlayerSkin.css"/>" type="text/css" />
</head>

<%
boolean isHttps = request.isSecure();


String dnNo = request.getParameter("dn_no");
String mfuIp = request.getParameter("ip");
String userId = request.getParameter("manager_id");
String callId = request.getParameter("call_id");
String tenantId = request.getParameter("tenant_id");
String loginIp 	= request.getParameter("loginIp");

%>


<Script Language=JavaScript>
	var protocol = <%= isHttps %> ? "https://" : "http://";
	var ip = "<%=mfuIp%>";
	var port = <%= isHttps %> ? 7220 : 7210;
	var userId = "<%=userId%>";
	var callId = "<%=callId%>";
	var dnNo = "<%=dnNo%>";
	var tenantId = "<%=tenantId%>";
	var loginIp = "<%=loginIp%>";

	$(document).ready(function(){
		getConfigValue();
	});
	
	
	
	function fnScreenPlay(){
		var strHASH_TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		var strKey = "BRIDGETEC_VELOCE";

		var date	= new Date();
		var year	= date.getFullYear().toString();
		var month	= (date.getMonth() + 1) < 10 ? '0' + (date.getMonth() + 1).toString() : (date.getMonth() + 1).toString();
		var day		= date.getDate() < 10 ? '0' + date.getDate().toString() : date.getDate().toString();
		var hour	= date.getHours() < 10 ? '0' + date.getHours().toString() : date.getHours().toString();
		var minites	= date.getMinutes() < 10 ? '0' + date.getMinutes().toString() : date.getMinutes().toString();
		var seconds	= date.getSeconds() < 10 ? '0' + date.getSeconds().toString() : date.getSeconds().toString();

		var strTime = seconds + minites + month + year + day + hour;

		var nKeyLen = callId.length;

		while(strKey.length < nKeyLen) {
			strKey = strKey + strKey;
		}

		while (strTime.length < nKeyLen){
			strTime = strTime + strTime;
		}

		var chKey;
		var chTime;
		var chUcid;
		var chEncKey;

		var nChar;
		var szEncKey = [];

		for (var i = 0; i < nKeyLen; i++)  {
			chKey = strKey.charAt(i);
			chTime = strTime.charAt(i);
			chUcid = callId.charAt(i);
			var nKey = chKey.charCodeAt(0);
			var nTime = chTime.charCodeAt(0);
			var nUcid = chUcid.charCodeAt(0);
			nChar = parseInt((nUcid + nKey + nTime) % strHASH_TABLE.length);
			chEncKey = strHASH_TABLE.charAt(nChar);
			szEncKey[i] = chEncKey;
		}

		var strEncKey = szEncKey.join("");
		var openUrl = protocol + ip + ":" + port + "/filescr/" + dnNo + "/" + userId + "/" + callId + "/" + strEncKey + "/" + dnNo + ".mp4";
		
		var source = $("<source>");
		source.attr("type","video/mp4");
		source.attr("src",openUrl);
		$("#video").html(source);
	}
	
	function getWindowPopupOpen(){
		var index = {};
		index.workId = userId;
		index.dnNo = dnNo;
		index.callId = callId;
		index.tenantId = tenantId;
		index.loginIp = loginIp;
		
		index.sCudMode = "A";
		
		gPopupOptions = {pRowIndex:index,"cudMode":"31"};   	
 		argoPopupWindow('청취사유등록', 'RecSearchRecLogPopAddF.do', '470', '370');
	}
	
	function getConfigValue(){
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_REC_REASON"}, function (data, textStatus, jqXHR){ 
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						isUseRecReason = data.getRows()['code'];
						if(isUseRecReason == "1"){
							getWindowPopupOpen();
						}else{
							var listeningKey = getTimeStamp2();
							var logListeningKey = listeningKey+"00";
							var logRealtimeFlag = "31";
							argoJsonUpdate("recInfo", "setAppRecLogRealInsert", "", {"tenantId":tenantId,"workerId":userId, "dnNo":dnNo, "listeningKey":logListeningKey 
								, "callId" : callId ,"realtimeFlag":logRealtimeFlag   ,"loginIp":loginIp });
							
							fnScreenPlay();								
						}	
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	} 
	
	function leadingZeros(n, digits) {
	    var zero = '';
	    n = n.toString();

	    if (n.length < digits) {
	        for (i = 0; i < digits - n.length; i++)
	            zero += '0';
	    }
	    return zero + n;
	}
	
	//listeningKey
	function getTimeStamp2() {
	    var d = new Date();
	    var date = leadingZeros(d.getFullYear(), 4) + leadingZeros(d.getMonth() + 1, 2) + leadingZeros(d.getDate(), 2);
	    var time = leadingZeros(d.getHours(), 2) + leadingZeros(d.getMinutes(), 2) + leadingZeros(d.getSeconds(), 2);

	    return date + time;
	}
</Script>

<body>
	<div class="container">
		<div class="video-container" id="video-container">
			<div class="playback-animation" id="playback-animation">
				<svg class="playback-icons">
					<use class="hidden" href="#play-icon"></use>
					<use href="#pause"></use>
				</svg>
			</div>
	
			<video controls class="video" id="video" onloadeddata="fn_loadEnd();" controlsList="nodownload" oncontextmenu="return false;">
				Your browser does not support HTML5 video.
			</video>
			
			<div class="video-controls hidden" id="video-controls">
				<div class="video-progress">
					<progress id="progress-bar" value="0" min="0"></progress>
					<input class="seek" id="seek" value="0" min="0" type="range" step="1">
					<div class="seek-tooltip" id="seek-tooltip">00:00</div>
				</div>
				
				<div class="bottom-controls">
					<div class="left-controls">
						<button data-title="Play (k)" id="play">
							<svg class="playback-icons">
								<use href="#play-icon"></use>
								<use class="hidden" href="#pause"></use>
							</svg>
						</button>
						
						<div class="volume-controls">
							<button data-title="Mute (m)" class="volume-button" id="volume-button">
								<svg>
									<use class="hidden" href="#volume-mute"></use>
									<use class="hidden" href="#volume-low"></use>
									<use href="#volume-high"></use>
								</svg>
							</button>
							
							<input class="volume" id="volume" value="1" data-mute="0.5" type="range" max="1" min="0" step="0.01">
						</div>
						
						<div class="time">
							<time id="time-elapsed">00:00</time>
							<span> / </span>
							<time id="duration">00:00</time>
						</div>
					</div>
					
					<div class="right-controls">
<!-- 
						<button data-title="PIP (p)" class="pip-button" id="pip-button">
							<svg>
								<use href="#pip"></use>
							</svg>
						</button>
 -->
						<button data-title="Full screen (f)" class="fullscreen-button" id="fullscreen-button">
							<svg>
								<use href="#fullscreen"></use>
								<use href="#fullscreen-exit" class="hidden"></use>
							</svg>
						</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	<svg style="display: none">
		<defs>
			<symbol id="pause" viewBox="0 0 24 24">
				<path d="M14.016 5.016h3.984v13.969h-3.984v-13.969zM6 18.984v-13.969h3.984v13.969h-3.984z"></path>
			</symbol>
			
			<symbol id="play-icon" viewBox="0 0 24 24">
				<path d="M8.016 5.016l10.969 6.984-10.969 6.984v-13.969z"></path>
			</symbol>
			
			<symbol id="volume-high" viewBox="0 0 24 24">
				<path d="M14.016 3.234q3.047 0.656 5.016 3.117t1.969 5.648-1.969 5.648-5.016 3.117v-2.063q2.203-0.656 3.586-2.484t1.383-4.219-1.383-4.219-3.586-2.484v-2.063zM16.5 12q0 2.813-2.484 4.031v-8.063q1.031 0.516 1.758 1.688t0.727 2.344zM3 9h3.984l5.016-5.016v16.031l-5.016-5.016h-3.984v-6z"></path>
			</symbol>
			
			<symbol id="volume-low" viewBox="0 0 24 24">
				<path d="M5.016 9h3.984l5.016-5.016v16.031l-5.016-5.016h-3.984v-6zM18.516 12q0 2.766-2.531 4.031v-8.063q1.031 0.516 1.781 1.711t0.75 2.32z"></path>
			</symbol>
			
			<symbol id="volume-mute" viewBox="0 0 24 24">
				<path d="M12 3.984v4.219l-2.109-2.109zM4.266 3l16.734 16.734-1.266 1.266-2.063-2.063q-1.547 1.313-3.656 1.828v-2.063q1.172-0.328 2.25-1.172l-4.266-4.266v6.75l-5.016-5.016h-3.984v-6h4.734l-4.734-4.734zM18.984 12q0-2.391-1.383-4.219t-3.586-2.484v-2.063q3.047 0.656 5.016 3.117t1.969 5.648q0 2.203-1.031 4.172l-1.5-1.547q0.516-1.266 0.516-2.625zM16.5 12q0 0.422-0.047 0.609l-2.438-2.438v-2.203q1.031 0.516 1.758 1.688t0.727 2.344z"></path>
			</symbol>
			
			<symbol id="fullscreen" viewBox="0 0 24 24">
				<path d="M14.016 5.016h4.969v4.969h-1.969v-3h-3v-1.969zM17.016 17.016v-3h1.969v4.969h-4.969v-1.969h3zM5.016 9.984v-4.969h4.969v1.969h-3v3h-1.969zM6.984 14.016v3h3v1.969h-4.969v-4.969h1.969z"></path>
			</symbol>
			
			<symbol id="fullscreen-exit" viewBox="0 0 24 24">
				<path d="M15.984 8.016h3v1.969h-4.969v-4.969h1.969v3zM14.016 18.984v-4.969h4.969v1.969h-3v3h-1.969zM8.016 8.016v-3h1.969v4.969h-4.969v-1.969h3zM5.016 15.984v-1.969h4.969v4.969h-1.969v-3h-3z"></path>
			</symbol>
			
			<symbol id="pip" viewBox="0 0 24 24">
				<path d="M21 19.031v-14.063h-18v14.063h18zM23.016 18.984q0 0.797-0.609 1.406t-1.406 0.609h-18q-0.797 0-1.406-0.609t-0.609-1.406v-14.016q0-0.797 0.609-1.383t1.406-0.586h18q0.797 0 1.406 0.586t0.609 1.383v14.016zM18.984 11.016v6h-7.969v-6h7.969z"></path>
			</symbol>
		</defs>
	</svg>
	
	<script type="text/javascript" src="<c:url value="/scripts/player/video_player.js"/>"></script>
</body>
</html>