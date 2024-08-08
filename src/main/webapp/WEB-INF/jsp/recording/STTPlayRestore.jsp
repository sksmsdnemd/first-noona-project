<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
	
	// 구간반복 클릭 횟수
	var clickCnt = 0;
	var strAutoPlay = '<c:out value="${param.strAutoPlay}"/>';
	if(strAutoPlay == "" || strAutoPlay == NULL)
		strAutoPlay = "1";

	var recData = decodeURIComponent('<c:out value="${param.recData}"/>');
	var url;
	const jsonArray = JSON.parse(recData);
	
	for(idx in jsonArray){
		url = document.location.protocol + "//" + jsonArray[idx].ip + ":" + jsonArray[idx].port + "/fileplay2/"+jsonArray[idx].restoreKind +"/"  + jsonArray[idx].recKey + "/" +jsonArray[idx].dn_no+".mp3";
		var cell		= new Object();
		cell.recTime	= jsonArray[idx].rec_time;
 		cell.endTime	= jsonArray[idx].endTime;
 		cell.custTel	= jsonArray[idx].custTel;
		cell.managerID	= jsonArray[idx].manager_id;
		cell.DnNo		= jsonArray[idx].dn_no;
		cell.recKey		= jsonArray[idx].recKey;
		cell.userID		= jsonArray[idx].user_id;
		cell.callID		= jsonArray[idx].call_id;
		playList[url] = cell;
	};

	var playFlag = true;
	$(window).load(function() {
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
		            	,{ field: 'userID', 	caption: '상담사ID', 	size: '80px', 	attr: 'align=center' }
		            	,{ field: 'callID', 	caption: '콜아이디', 	size: '250px', 	attr: 'align=center' }
		               	
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'recurl');
		var count = 0;
		for (var index in playList)
		{
			var item		= playList[index];
			var gridObject 	= {
					'recid': count,
					'recurl': index,
					'recTime' : item.recTime,
					'userID' : item.userID,
					'callID' : item.callID,
					'managerID' : item.managerID,
					'DnNo' : item.DnNo,
					'recKey' : item.recKey,
					
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
		if( strAutoPlay == "1" )
		{
			w2ui.grid.select(0);
			var arrChecked 	= w2ui['grid'].getSelection();
			if (arrChecked.length <= 0)
				return;
			
			playAudio(0);
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
			var newDnno = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].DnNo;
			var newrecTime = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].recTime;
			var newID = w2ui['grid'].records[w2ui['grid'].getSelection()[0]].managerID;
			$("#aTotal").textContent="00:00";
			$("#rtVEL").text(newrecTime);
			$("#dnVEL").text(newDnno);
			$("#midVel").text(newID);

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
					<li><span>&middot</span> 통화시간 : <span id="rtVEL"></span></li>
					<li><span>&middot</span> 내선 : <span id="dnVEL"></span></li>
					<li><span>&middot</span> 청취자 : <span id="midVel"></span></li>
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
