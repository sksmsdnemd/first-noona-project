<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="java.io.*"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<title>VELOCE Manager</title>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" />
<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<style type="text/css">
@keyframes subtle-blink {
     0% {
         opacity: 1;
     }
     50% {
         opacity: 0.5;
     }
     100% {
         opacity: 1;
     }
 }
 #btnPlayerD.subtle-blink {
     animation: subtle-blink 2s infinite; /* 2초 간격으로 무한 반복 */
 }

 #btnPlayerD {
      background-color: #3498db; /* 파란색 배경 */
      color: #ffffff; /* 흰색 텍스트 */
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
      font-weight:bold;
      animation: subtle-blink 2s infinite;
 }
</style>

<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.ajax-cross-origin.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>

<script>


	var loginInfo  = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId   = loginInfo.SVCCOMMONID.rows.tenantId;
	var agentId    = loginInfo.SVCCOMMONID.rows.agentId;
	var userId     = loginInfo.SVCCOMMONID.rows.userId;
	
	var userName   = loginInfo.SVCCOMMONID.rows.userName;
	var grantId    = loginInfo.SVCCOMMONID.rows.grantId;
	var grantName  = loginInfo.SVCCOMMONID.rows.grantName;
	var loginTime  = loginInfo.SVCCOMMONID.rows.loginTime;
	var workIp 	   = loginInfo.SVCCOMMONID.rows.workIp;
	var mainPage   = loginInfo.SVCCOMMONID.rows.mainPage;
	var authRank   = loginInfo.SVCCOMMONID.rows.authRank;
	var strPathDo  = "";
	var workLog    = "";
	
	var windowStepFlag = false;
	var windowStepVal = ""; 
	
	var observer = null;

	$(document).ready(function() {
// 		fnPlayerCheck();	// process check(재생기 및 agent) - 미설치시 설치 페이지로 이동
		fnInitCtrl();
		fnMenuList();
		fnSessionTimeout();
		
		if(grantId == "SuperAdmin" || grantId == "SystemAdmin" || grantId == "Manager" || grantId == "GroupManager" || grantId == "Agent"){
			$('#ifDashboard').attr('src', '');
// 			$('#ifDashboard').attr('src', 'VIntroF.do');
// 			add_tab('/common/VIntroF.do', 'VELOCE', false);
			if(mainPage != "" && mainPage != null) {
				$("#"+mainPage).trigger("click");
			} else {
				$('#ifDashboard').attr('src', 'VIntroF.do');
				add_tab('/common/VIntroF.do', 'VELOCE', false);
			}
		}
		
		$(".user_name").text("" + userId + " / " + userName + " [" + grantName + "]");
// 		$(".user_connect").text("(" + loginTime + ")");
		
		$(".btn_allDelete").on( "click", function(){
			$(".history_tab li a[id!=DASHBOARD]").parent().remove();

		    [].slice.call(document.querySelectorAll('iframe')).forEach(function (frame) {

		    	if(frame.id != "ifDashboard"){
			        while (frame.contentWindow.document.body.firstChild) {
			            frame.contentWindow.document.body.removeChild(frame.contentWindow.document.body.firstChild);
			        }
			        frame.src = 'about:blank';
			        frame.parentNode.removeChild(frame);
		    	}
		    });

		    window.CollectGarbage && window.CollectGarbage();
			
			$(".content_wrap[data-id!=DASHBOARD]").remove();
			$(".history_tab li a[id=DASHBOARD]").addClass("on");
			$(".content_wrap[data-id=DASHBOARD]").show();
			currentID = "DASHBOARD";
			$(".section").addClass("dashboard");
			
			if(grantId == "SuperAdmin" || grantId == "SystemAdmin" || grantId == "Manager" || grantId == "GroupManager" || grantId == "Agent"){
				$('#ifDashboard').attr('src', '');
// 				$('#ifDashboard').attr('src', 'VIntroF.do');
// 				add_tab('/common/VIntroF.do', 'VELOCE', false);
				if(mainPage != "" && mainPage != null) {
					$("#"+mainPage).trigger("click");
				} else {
					$('#ifDashboard').attr('src', 'VIntroF.do');
					add_tab('/common/VIntroF.do', 'VELOCE', false);
				}
			}
			
			return false;
		});
		
		$(".wideCheck").click(function(){
			fnWideCheck();
		});	
		
		$("#btnDownload").click(function(){
			argoPopupWindow('파일다운로드', gGlobal.ROOT_PATH + '/common/VFileDownF.do', '850', '500');			
		});
		
		$("#btnPlayerD").click(function(){
			//location.href='/BT-VELOCE/data/VLCPlayer_NonActiveX.exe';
			argoAlert("청취가 되지 않을 경우, 아래의 단계를 따라 재생기를 설치해주세요.<br><span style='font-size:9pt; line-height:10px;'>1.툴바를 열어주세요.</span><br><span style='font-size:9pt; line-height:10px;'>2.즐겨찾기를 선택해주세요.</span><br><span style='font-size:9pt; line-height:10px;'>3.응용프로그램을 클릭해주세요.</span><br><span style='font-size:9pt; line-height:10px;'>4.IPCC녹취청취를 더블클릭해 주세요.</span>");
			
		});
		
		/* $("#btnSumBankD").click(function(){
			location.href='/BT-VELOCE/data/Veloce_SumBank.exe';
		}); */
		
		var target = document.getElementById('contentsDiv');
		
		observer = new MutationObserver(function(mutations) {
			fnSessionTimeout();
		});
		
		var config = {
			childList: true,				// 타겟의 하위 요소 추가 및 제거 감지
			attributes: true,				// 타켓의 속성 변경를 감지
			characterData: false,			// 타겟의 데이터 변경 감지
			subtree: true,					// 타겟의 자식 노드 아래로도 모두 감지
			attributeOldValue: false,		// 타겟의 속성 변경 전 속성 기록
			characterDataOldValue: false	// 타겟의 데이터 변경 전 데이터 기록
		};
		
		observer.observe(target, config);
		
		$("#ifDashboard").on("load", function(){
	        $(this).contents().on("mousedown, mouseup, click", function() {
	        	reqTimeAjax();
	        });
	    });
		
		fnServerGbTitleSetting();
	});
	
	
	function fnServerGbTitleSetting(){
		var serverGb =  argoGetValue("s_ServerGb");
		// 서버구분 죽전
		if(serverGb == "JJ"){
			$("#serverGbTitle").text("- 죽 전 -");
			//$("#serverGbTitle").text("- 운영계 -");
			$("#serverGbTitle").css("color", "red");
		}
		// 서버구분 일산
		else if(serverGb == "IS"){
			$("#serverGbTitle").text("- 일 산 -");
			//$("#serverGbTitle").text("- 운영계 -");
			$("#serverGbTitle").css("color", "red");
		}
		else{
			$("#serverGbTitle").text("- 개발계 -");
			$("#serverGbTitle").css("color", "blue");
		}
	}
	
	function sleep (delay) {
	   var start = new Date().getTime();
	   while (new Date().getTime() < start + delay);
	}
	
	// Process 확인 start
	var playerKind = loginInfo.SVCCOMMONID.rows.playerKind;
	var agentUseYn = '<spring:eval expression="@code['Globals.agentUseYn']"/>';
	
	function fnPlayerCheck() {
		if(playerKind == "1") {
			$.ajax({
				url: "http://127.0.0.1:8282?cmd=7",
				type: "get",
				cache: false,
				dataType: "json",
				crossDomain : true, 
				asynchronous : false,
				jsonpCallback: "callback",
				timeout : 5000, // set a timeout in milliseconds
				complete : function(xhr) {
					if(xhr.status == "200") {
						fnAgentCheck(true);
					} else {
// 						fnAgentCheck(false);

						// player 없으면 agent 확인이 안되는 이유로 임시적으로 player 먼저 설치하도록 수정
						fnInstallPage(false, true);
					}
				}
			});
		} else {
// 			fnAgentCheck(true);
			
			// player 없으면 agent 확인이 안되는 이유로 임시적으로 player 먼저 설치하도록 수정
			fnInstallPage(true, true);
		}
	}
	
	function fnAgentCheck(playerInstall) {
		if(agentUseYn == "Y") {
		 	$.ajax({
				url: "http://127.0.0.1:8282?cmd=8",
				type: "get",
				cache: false,
				dataType: "json",
				crossDomain : true, 
				asynchronous : true,
				jsonpCallback: "callback",
				timeout : 5000, // set a timeout in milliseconds
				complete : function(xhr) {
					if(xhr.status == "200") {
// 						if(eval(xhr.responseText.split("\r\n").reverse()[0]).result == "0001") {
						if((xhr.responseText.split("\r\n").reverse()[0]).result == "0001") {
							fnInstallPage(playerInstall, false);
						} else {
							fnInstallPage(playerInstall, true);
						}
					} else {
						fnInstallPage(playerInstall, false);
					}
				}
			});
		} else {
			fnInstallPage(playerInstall, true);
		}
	}
	
	function fnInstallPage(playerInstall, agnetInstall) {
		if(!playerInstall || !agnetInstall) {
			// careate element (form)
			var form = $("<form></form>");
		
			// set attribute (form)
			form.attr("method", "post").attr("action", "/BT-VELOCE/common/agentInstall.jsp");
		
			// careate element & set attribute (input)
			form.append($("<input/>", {type: "hidden", name: "playerKind", value: playerKind}));
			form.append($("<input/>", {type: "hidden", name: "playerInstall", value: playerInstall}));
			form.append($("<input/>", {type: "hidden", name: "agentUseYn", value: agentUseYn}));
			form.append($("<input/>", {type: "hidden", name: "agnetInstall", value: agnetInstall}));
		
			// append form (to body)
			form.appendTo("body");
		
			// submit form
			form.submit();
		}
	}
	// Process 확인 end
	
	function fnWideCheck(){
		
		$("#sideMenuArea ul").each( function(i, obj){
			var menuId = (obj.id).split("_");
			menuId = menuId[0] + "_0_0";
			
			if(!($("body").hasClass("side_w"))){
				if(obj.id == menuId){
					obj.style.display = "none";
				}
			}else{
				if($("#"+obj.id).hasClass("on")){
					obj.style.display = "block";
				}
			}
		});
	}
	
	function fnInitCtrl(){	

		($("body").hasClass("side_w") ? $("body").removeClass("side_w").addClass("side_n") : $("body").addClass("side_w").removeClass("side_n") );
		
		this.btn_sideNavi = $(".btn_sideNavi");
		this.btn_sideNavi.on( "click", function(e){
			($("body").hasClass("side_w") ? $("body").removeClass("side_w").addClass("side_n") : $("body").addClass("side_w").removeClass("side_n") );	
			return false;
		});
		
		$(".btn_allDelete").hide();
	}

	function fnMenuList(){
		
		argoJsonSearchList('menu', 'getMenuList', 's_', {"tenantId":tenantId, "grantId":grantId, "userId":userId}, function (data, textStatus, jqXHR){
			try{
				
				var depth1	 = "";
				var depth2   = "";
				var depth3   = "";
				var depth    = "";
				var menuNm   = "";
				var srcDo    = "";
				var menuAuth = "";
				var engNm    = "";
				var depHtml  = "";
				var depthId  = "";
				var srcStr   = "";
				var menuStr  = "";
				var authKind = "";
				var depthChk = "N";
				
				if(data.isOk()){
					if(data.getRows() != ""){
						$.each(data.getRows(), function(index, row){
							
							authKind = row.authKind;
							
							if(authKind != "0"){
								depth1  = row.depth1Id;
								depth2  = row.depth2Id;
								depth3  = row.depth3Id;
								depth   = depth1 + "_" + depth2 + "_" + depth3;
								menuNm  = row.menuName;
								srcDo   = row.srcDo;
								menuStr = "'" + menuNm + "'";
								srcStr  = "'" + srcDo + "'";
								
								if("a_" + depth == mainPage){
									depthChk = "Y";
								}
								
								if	   (depth1 == '1') engNm = "AM";
								else if(depth1 == '2') engNm = "SP";
								else if(depth1 == '3') engNm = "UM";
								else if(depth1 == '4') engNm = "AV";
								else if(depth1 == '5') engNm = "SM";
								else if(depth1 == '6') engNm = "FM";
								else if(depth1 == '7') engNm = "RC";
								
								if(loginInfo.SVCCOMMONID.rows.qaYn == "N"){
									if(depth1 == "7"){
										if((depth2=="0"&&depth3=="0") || (depth2=="3"&&depth3=="0") || (depth2=="3"&&depth3=="2")){
											if(depth2 == "0" && srcDo == "#"){
												//one depth
												depHtml  = '<li class="' + engNm + '"><a href="javascript:fnMenuTog(' + depth1 + ',' + depth2 + ',' + depth3 + ');">';
												depHtml += menuNm + '<span class="showHide">shiw/hide</span></a>';
												depHtml += '<div id="sideMenu_' + engNm + '"></div></li>';
												depHtml += '<span class="icon_arrow"></span><ul id="' + depth + '" style="display:none"></br></ul></div></li>';
												
												$('#sideMenuArea').append(depHtml);
												depHtml = "";
											}
											
											if(depth2 != "0" && srcDo == "#"){
												// two depth
												depthId = depth1 + '_0_0';
												
												depHtml  = '<li>';
												depHtml += '<a href="javascript:fnMenuTog(' + depth1 + ',' + depth2 + ',' + depth3 + ');"><strong>';
												depHtml += menuNm + '</strong><span class="icon_pm"></span></a><ul id = "' + depth + '" style="display:none" class="">';
												depHtml += '<li></li></br></ul></li></br>';
												
												$('#' + depthId).append(depHtml);
												depHtml = "";
												
											}else if(depth3 == "0" && srcDo != "#"){
												// two depth menu
												depthId = depth1 + '_0_0';
				
												depHtml  = '<li id="' + depth + '">';
												depHtml += '<a href="#" id="a_' + depth + '" onClick="linkGo(' + srcStr + ',' + menuStr + ',' + authKind + ');">';
												depHtml += '<strong>' + menuNm + '</strong><span></span></a></li></br>';
				
												$('#' + depthId).append(depHtml);
												depHtml = "";
												
											}else if(depth3 != "0" && srcDo != "#"){
												// three depth menu
												depthId = depth1 + "_" + depth2 + "_0";
				
												depHtml  = '<li id="' + depth + '">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
												depHtml += '<a href="#" id="a_' + depth + '" onClick="linkGo(' + srcStr + ',' + menuStr + ',' + authKind + ');" style="color:#a3b0c6; font-size:12px;">';
												depHtml += '<strong>-&nbsp;&nbsp;' + menuNm + '</strong></a></li></br>';
												
												$('#' + depthId).append(depHtml);
												depHtml = "";
											}
										}
									}else{
									
										if(depth2 == "0" && srcDo == "#"){
											//one depth
											depHtml  = '<li class="' + engNm + '"><a href="javascript:fnMenuTog(' + depth1 + ',' + depth2 + ',' + depth3 + ');">';
											depHtml += menuNm + '<span class="showHide">shiw/hide</span></a>';
											depHtml += '<div id="sideMenu_' + engNm + '"></div></li>';
											depHtml += '<span class="icon_arrow"></span><ul id="' + depth + '" style="display:none"></br></ul></div></li>';
											
											$('#sideMenuArea').append(depHtml);
											depHtml = "";
										}
										
										if(depth2 != "0" && srcDo == "#"){
											// two depth
											depthId = depth1 + '_0_0';
											
											depHtml  = '<li>';
											depHtml += '<a href="javascript:fnMenuTog(' + depth1 + ',' + depth2 + ',' + depth3 + ');"><strong>';
											depHtml += menuNm + '</strong><span class="icon_pm"></span></a><ul id = "' + depth + '" style="display:none" class="">';
											depHtml += '<li></li></br></ul></li></br>';
											
											$('#' + depthId).append(depHtml);
											depHtml = "";
											
										}else if(depth3 == "0" && srcDo != "#"){
											// two depth menu
											depthId = depth1 + '_0_0';
			
											depHtml  = '<li id="' + depth + '">';
											depHtml += '<a href="#" id="a_' + depth + '" onClick="linkGo(' + srcStr + ',' + menuStr + ',' + authKind + ');">';
											depHtml += '<strong>' + menuNm + '</strong><span></span></a></li></br>';
			
											$('#' + depthId).append(depHtml);
											depHtml = "";
											
										}else if(depth3 != "0" && srcDo != "#"){
											// three depth menu
											depthId = depth1 + "_" + depth2 + "_0";
			
											depHtml  = '<li id="' + depth + '">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
											depHtml += '<a href="#" id="a_' + depth + '" onClick="linkGo(' + srcStr + ',' + menuStr + ',' + authKind + ');" style="color:#a3b0c6; font-size:12px;">';
											depHtml += '<strong>-&nbsp;&nbsp;' + menuNm + '</strong></a></li></br>';
											
											$('#' + depthId).append(depHtml);
											depHtml = "";
										}
									
									}
								}else{
									if(depth2 == "0" && srcDo == "#"){
										//one depth
										depHtml  = '<li class="' + engNm + '"><a href="javascript:fnMenuTog(' + depth1 + ',' + depth2 + ',' + depth3 + ');">';
										depHtml += menuNm + '<span class="showHide">shiw/hide</span></a>';
										depHtml += '<div id="sideMenu_' + engNm + '"></div></li>';
										depHtml += '<span class="icon_arrow"></span><ul id="' + depth + '" style="display:none"></br></ul></div></li>';
										
										$('#sideMenuArea').append(depHtml);
										depHtml = "";
									}
									
									if(depth2 != "0" && srcDo == "#"){
										// two depth
										depthId = depth1 + '_0_0';
										
										depHtml  = '<li>';
										depHtml += '<a href="javascript:fnMenuTog(' + depth1 + ',' + depth2 + ',' + depth3 + ');"><strong>';
										depHtml += menuNm + '</strong><span class="icon_pm"></span></a><ul id = "' + depth + '" style="display:none" class="">';
										depHtml += '<li></li></br></ul></li></br>';
										
										$('#' + depthId).append(depHtml);
										depHtml = "";
										
									}else if(depth3 == "0" && srcDo != "#"){
										// two depth menu
										depthId = depth1 + '_0_0';
		
										depHtml  = '<li id="' + depth + '">';
										depHtml += '<a href="#" id="a_' + depth + '" onClick="linkGo(' + srcStr + ',' + menuStr + ',' + authKind + ');">';
										depHtml += '<strong>' + menuNm + '</strong><span></span></a></li></br>';
		
										$('#' + depthId).append(depHtml);
										depHtml = "";
										
									}else if(depth3 != "0" && srcDo != "#"){
										// three depth menu
										depthId = depth1 + "_" + depth2 + "_0";
		
										depHtml  = '<li id="' + depth + '">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
										depHtml += '<a href="#" id="a_' + depth + '" onClick="linkGo(' + srcStr + ',' + menuStr + ',' + authKind + ');" style="color:#a3b0c6; font-size:12px;">';
										depHtml += '<strong>-&nbsp;&nbsp;' + menuNm + '</strong></a></li></br>';
										
										$('#' + depthId).append(depHtml);
										depHtml = "";
									}
								}
							}
						});
						
						if(mainPage != "" && mainPage != null){	
							if(depthChk == "Y"){
								$("#"+mainPage).trigger("click");
							}
						}else{									
							if(grantId != "SuperAdmin" && grantId != "SystemAdmin" && grantId != "Manager"){
								$("#a_1_1_0").trigger("click");		//모니터링
							}else{
// 								$("#a_2_1_1").trigger("click");		//통화내역조회
							}
						}
					}

					if(userId!="btadmin" || grantId!="SuperAdmin")
					{
						$("#a_5_7_0").hide();
					}
				}
				
				
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function linkGo(value, menuNm, authKind){
		if(windowStepFlag == true){
			if(windowStepVal == "QA1030M02"){
				argoConfirm('<span style="font-size:11pt;">[STEP02-QAA배정] 진행 중입니다.<br>다른 화면으로 이동하시겠습니까?</span><br><span style="color:red; font-size:7pt;">※변경 내용을 저장하지 않을 시 작업이 손실될 수 있습니다.</span>', function() {
					windowStepFlag = false;
					windowStepVal = "";
					$('#ifDashboard').attr('src', '');
					argoSetValue("authKind", authKind);
					$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + value);
					add_tab(value, menuNm, true, authKind);
				}); 
			}else if(windowStepVal == "QA1030M03"){
				argoConfirm('<span style="font-size:11pt;">[STEP03-상담사 배정] 진행 중입니다.<br>다른 화면으로 이동하시겠습니까?</span><br><span style="color:red; font-size:7pt;">※변경 내용을 저장하지 않을 시 작업이 손실될 수 있습니다.</span>', function() {
					windowStepFlag = false;
					windowStepVal = "";
					$('#ifDashboard').attr('src', '');
					argoSetValue("authKind", authKind);
					$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + value);
					add_tab(value, menuNm, true, authKind);
				}); 
			}else if(windowStepVal == "QA2010M02"){
				argoConfirm('<span style="font-size:11pt;">[STEP02-녹음파일조회] 진행 중입니다.<br>다른 화면으로 이동하시겠습니까?</span>', function() {
					windowStepFlag = false;
					windowStepVal = "";
					$('#ifDashboard').attr('src', '');
					argoSetValue("authKind", authKind);
					$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + value);
					add_tab(value, menuNm, true, authKind);
				}); 
			}else if(windowStepVal == "QA2010M03"){
				argoConfirm('<span style="font-size:11pt;">[STEP03-통화품질평가]진행 중입니다.<br>다른 화면으로 이동하시겠습니까?</span><br><span style="color:red; font-size:7pt;">※변경 내용을 저장하지 않을 시 작업이 손실될 수 있습니다.</span>', function() {
					windowStepFlag = false;
					windowStepVal = "";
					$('#ifDashboard').attr('src', '');
					argoSetValue("authKind", authKind);
					$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + value);
					add_tab(value, menuNm, true, authKind);
				}); 
			}
			
			
		}else{
			windowStepFlag = false;
			windowStepVal = "";
			$('#ifDashboard').attr('src', '');
			argoSetValue("authKind", authKind);
			$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + value);
			add_tab(value, menuNm, true, authKind);
		}
	}

	var togName = "";
	
	function fnMenuTog(menuName, depth2, depth3){
		
		togName = menuName + "_" + depth2 + "_" + depth3;
		
		if(!($("body").hasClass("side_w"))){
			$(".btn_sideNavi").click();

			if(!$("#" + togName).hasClass("on")){
				$("#" + togName).toggle();
				$("#" + togName).removeClass();;
				$("#" + togName).addClass("on");
			}
		}else{
			$("#" + togName).toggle();
			
			if($("#" + togName).hasClass("on")){
				$("#" + togName).removeClass();;
				$("#" + togName).addClass("off");
			}else{
				$("#" + togName).removeClass();;
				$("#" + togName).addClass("on");
			}
		}
	}
	
	function add_tab(value, menuNm, delFlag, authKind){
		
		var tabHtml = "";
		var id 		= value;
		var delTab 	= "";
		
		if(delFlag){
			delTab = "delete_tab(this)";
		}

		var check = check_overlap(id);	
		
		var pageValHtml = "";
		var pageId 		= value.split("/");
		pageId 			= pageId[pageId.length-1].split(".")[0];
		
		var checkli 	= $(".history_tab li").length;

		if( check ){
		}else{
			var pathDo = "'" + value + "', ''";
			
			if(menuNm == "VELOCE"){
				tabHtml  = '<li><a href="#" id="' + value + '" class="on" onClick="linkGo(' + pathDo + ',' + authKind + ');">' + menuNm + '</a>';
				tabHtml += '<span class="bnt_refresh" onclick="linkGo(' + pathDo + ');">delete</span></li>';
			}else{
				if(checkli == 0){
					tabHtml  = '<li><a href="#" id="' + value + '" class="on" onClick="linkGo(' + pathDo + ',' + authKind + ');">' + menuNm + '</a>';
					tabHtml += '<span class="bnt_refresh" onclick="linkGo(' + pathDo + ');">delete</span></li>';
					strPathDo = value;
				}else{
					tabHtml  = '<li><a href="#" id="' + value + '" class="on" onClick="linkGo(' + pathDo + ',' + authKind + ');">' + menuNm + '</a>';
					tabHtml += '<span class="bnt_delete" onclick="' + delTab + ';">delete</span></li>';
				}
				pageValHtml = '<input type="hidden" id="' + pageId + '" name="' + pageId + '" value=""/>';
			}
			
			$(".history_tab").append(tabHtml);
			$("#pageValue").append(pageValHtml);
		}
		
		var total = $(".history_tab li").length;
		if(total == 1){
			$(".btn_allDelete").hide();
		}else{
			$(".btn_allDelete").hide();	//안보이게 변경
		}
			
		//메인 탭메뉴 변경 start
		var htmlObj2 = "";
		
		//탭갯수 제한
		var tabCnt = vlcOPT.VLC_TAB_CNT;
		if(total > 2 && !check){
			var id = "";
			$(".history_tab li").each( function(i, obj){
				
				id = $(obj).find("a").attr("id");
					
				if(i==1){
					htmlObj2 += tabHtml;
				}
				if(i+1 == total){
					htmlObj2 += '';
				}else{
					if(i < (tabCnt-1)){
						htmlObj2 += '<li>' + $(".history_tab li a[id='" + id + "']").parent().html() + '</li>';
					}
				}
			});
			
			$(".history_tab li").remove();
			$(".history_tab").append(htmlObj2);
		}
		//메인 탭메뉴 변경 end

		/* if(total > 10){
			$(".history_tab li").each( function(i, obj){
				var id = $(obj).find("a").attr("id");
				if(i==1){
					$(".history_tab li a[id='" + id + "']").parent().remove();
					$(".content_wrap[data-id='" + id + "']").remove();
				}
			});
		} */
	}
	
	function check_overlap(_id){
		
		var result = false;
		var total  = $(".history_tab li").length;

		$(".history_tab li").each( function(i, obj){
			var id = $(obj).find("a").attr("id");	
			if( id == _id ){
				result = true;	
				$(obj).find("a").addClass("on");
			}else{
				$(obj).find("a").removeClass();
			}
		});

		return result;
	}

	function delete_tab(_this){
		windowStepFlag = false;
		windowStepVal = "";
		
		var selector = $(_this);	
		var id 		 = selector.prev().attr("id");
		var pageId 	 = id.split("/");
		
		pageId = pageId[pageId.length-1].split(".")[0];
		
		$("#" + pageId).remove();

		selector.closest("li").remove();
		$(".content_wrap[data-id='" + id + "']").remove();
	    window.CollectGarbage && window.CollectGarbage();

	    var total = $(".history_tab li").length;
		if(total == 1){
			$(".btn_allDelete").hide();
		}
		
		$(".history_tab li").each( function(i, obj){
			if(i == 0){
				if(!$(obj).find("a").hasClass("on")){
					if(grantId == "SuperAdmin" || grantId == "SystemAdmin" || grantId == "Manager" || grantId == "GroupManager" || grantId == "Agent"){
						$('#ifDashboard').attr('src', '');
						$('#ifDashboard').attr('src', 'VIntroF.do');
					}else{
						$('#ifDashboard').attr('src', '');
						$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + strPathDo);
					}
				}
				$(obj).find("a").addClass("on");

			}else{
				$(obj).find("a").removeClass();
			}
		});
	}
	
	function fn_goMain() {
		if(mainPage != "" && mainPage != null) {
			$("#"+mainPage).trigger("click");
		} else {
			linkGo('/common/VIntroF.do','VELOCE');
		}
	}
	
	function fnArgoLogOutConfirm() {
		argoConfirm('로그아웃 하시겠습니까?', function() {
		    argoAjax("postsync", gGlobal.ROOT_PATH + "/argoLogOut.do", null, null, function(data, textStatus, jqXHR) {
                if (data.resultCode = '0000') {
                    window.location.replace(gGlobal.ROOT_PATH + '/');
                }
                else {
                    //alert(data.resultCode);
                }
            }, null);
		});
	}

	function fnPwdChange() {
		gPopupOptions = { pUserId:userId, pTenantId:tenantId, pLoginIp:workIp, chkTy:"svr" };

		var openWindowPwd = $("body").openWindow({
					title 		: "비밀번호 변경",
					url   		: gGlobal.ROOT_PATH + '/common/EnvF.do',
					width 		: 420,
					height 		: 280,
					pid    		: "Main",
					ptype  		: "M",
					multi  		: false,
					closeable 	: false 
		});
	}
	
	var objLeftTime;
	var objClickInfo;
	var latestTime;
	var expireTime;
	var timeInterval = 1000; // 1초 간격 호출
	var firstLocalTime = 0;
	var elapsedLocalTime = 0;
	var stateExpiredTime = false;
	var timer;
	
	function fnSessionTimeout() {
		objLeftTime = document.getElementById("leftTimeInfo");
		if (objLeftTime == null) {
			console.log("'leftTimeInfo' ID is not exist!");
			return;
		}
		objClickInfo = document.getElementById("clickInfo");
		
		$("#leftTimeImg").attr("src", "../images/icon_leftTime_green.gif");

		latestTime = getCookie("latestServerTime");
		expireTime = getCookie("expireSessionTime");
		
		elapsedTime = 0;
		firstLocalTime = (new Date()).getTime();
		showRemaining();
		
		clearInterval(timer);								// timer 생성전에 clear 한번 해줌
		timer = setInterval(showRemaining, timeInterval);	// timer 생성 - 1초 간격 호출
	}
	
	function showRemaining() {
		elapsedLocalTime = (new Date()).getTime() - firstLocalTime;
		 
		var timeRemaining = expireTime - latestTime - elapsedLocalTime;
		
		if ( timeRemaining < timeInterval ) {
			clearInterval(timer);
			observer.disconnect();
			
			objLeftTime.innerHTML = "00:00:00";
			objClickInfo.innerHTML = '시간만료'; //시간만료
			stateExpiredTime = true;
			$("#sessionInfo").hide();
			
// 			alert('로그인 세션시간이 만료 되었습니다.');//로그인 세션시간이 만료 되었습니다.

// 			window.location.replace(gGlobal.ROOT_PATH + '/');

			argoAlert('warning', '로그인 세션시간이 만료 되었습니다.', '', 'window.location.replace(gGlobal.ROOT_PATH+"/");');

			return;
		}
		
		var timeHour = Math.floor(((timeRemaining/1000)/60) / 60); 
		var timeMin = Math.floor(((timeRemaining/1000)/60) % 60);
		var timeSec = Math.floor((timeRemaining/1000) % 60);
		
		if(timeHour == 0 && timeMin == 5 && timeSec == 0) {
			$("#leftTimeImg").attr("src", "../images/icon_leftTime_red.gif");
			argoAlert('5분 뒤에 자동으로 로그아웃 됩니다.');
		}

		objLeftTime.innerHTML = pad(timeHour,2) +":"+ pad(timeMin,2) +":"+ pad(timeSec,2);
	}
	
	function getCookie(cname) {
		var name = cname + "=";
		var decodedCookie = decodeURIComponent(document.cookie);
		var ca = decodedCookie.split(';');
		
		for(var i = 0; i <ca.length; i++) {
			var c = ca[i];
			
			while (c.charAt(0) == ' ') {
				c = c.substring(1);
			}
			
			if (c.indexOf(name) == 0) {
				return c.substring(name.length, c.length);
			}
		}
		return "";
	}
	
	function pad(n, width) {
		n = n + '';
		return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
	}
	
	function reqTimeAjax() {
		if (stateExpiredTime==true) {
			alert('시간을 연장할수 없습니다.');//시간을 연장할수 없습니다.
			return;
		}
	
		$.ajax({
			url:'${pageContext.request.contextPath}/refreshSessionTimeout.do', //request 보낼 서버의 경로
			type:'get', // 메소드(get, post, put 등)
			data:{}, //보낼 데이터
			success: function(data) {
				//서버로부터 정상적으로 응답이 왔을 때 실행
				latestTime = getCookie("latestServerTime");
				expireTime = getCookie("expireSessionTime");
				
				fnSessionTimeout();
			}, error: function(err) {
				console.log("err : "+err);
			}
		});
		
		return false;
	}
	
</script>
</head>
<body>
	<div id="wrap">
    
    	<!-- S:Side Navi(Left) -->
    	<aside class="side_navi">
        	<!-- <h1 class="side_logo"><a href="javascript:linkGo('/common/VIntroF.do');">VELOCE</a></h1> -->
<!--         	<h1 class="side_logo"><a href="javascript:linkGo('/common/VIntroF.do','VELOCE');">VELOCE</a></h1> -->
        	<h1 class="side_logo"><a href="javascript:fn_goMain();">VELOCE</a></h1>
            <div class="gnb_scroll scrollbar-inner">
                <ul class="gnb" id="sideMenuArea">
                </ul>
            </div>
        </aside>  
        <!-- E:Side Navi(Left) -->
        
        <!-- S:Content(Right) -->  	 
        <section class="section dashboard">  
        	<!-- S:header -->      	
        	<header class="header">                
                <!-- <a class="btn_sideNavi"><span>side_menu</span></a> -->
				<a class="btn_sideNavi wideCheck" href="#"><span class="icon_arrow">side_menu</span></a>
				
				<font id="serverGbTitle" style="font-size:20px;color:blue;font-weight:600; margin-left: 20px;/* margin-top: 30px; */top: 4px;position: relative;"></font>
				<!-- <font id="locationInfo" style="font-size:20px;color:red;font-weight:600; margin-left: 20px;/* margin-top: 30px; */top: 4px;position: relative;">-운영계-</font> -->
                <input type="hidden" id="s_ServerGb" name="s_ServerGb" value="${serverAddrGb}" >
                
                <span class="project_logo"></span>
                <div class="top_r">
                    <p class="user_info">
                        <span class="user_photo" id="userImg"></span>                                                                     
                        <span class="user_name"></span>
                        <!-- <span class="user_connect"></span> -->
                        <span id="sessionInfo">&nbsp;
                        	<img src="../images/icon_leftTime_green.gif" id="leftTimeImg">&nbsp;
                        	<span id="leftTimeInfo">00:00:00</span>&nbsp;
                        	<span id="clickInfo" style="font-weight:bold; cursor:pointer;" onClick="reqTimeAjax();return false;">연장</span>
                        </span>
                    </p>
                    <ul class="util">
						<!-- <li><a href="javascript:fnArgoUserEdit()" class="btn_setting">개인정보변경</a></li> -->
						
						<%-- <c:if test="${sessionMAP.grantId eq 'Agent'}">
						<li><a href="javascript:fnPwdChange();" class="btn_setting">비밀번호변경</a></li>
						</c:if> --%>
                        <li><a href="javascript:fnArgoLogOutConfirm();" class="btn_logout">로그아웃</a></li>
                    </ul>                
                </div>
            </header>
            <!-- E:header --> 
            
            <!-- S:History Tab --> 
            <article class="history">            	
            	<ul class="history_tab">                
                </ul>
              	<div class="history_control">
					<a href="#" class="btn_allPrev non_control">Prev</a>
                    <a href="#" class="btn_allNext">next</a>                
                	<a href="#" class="btn_allDelete">전체삭제</a>
                </div>
            </article>
            <!-- E:History Tab -->  
            
            <!-- S:Contents --> 
            <article class="contents">
            	<div class="content_wrap" data-id="DASHBOARD" id="contentsDiv">
            		<iframe id="ifDashboard" src=""></iframe>
            		<input type="hidden" id="authKind" name="authKind"/>
            		<div id="pageValue"></div>
            	</div>        
            </article>
            <!-- E:Contents --> 
            
            <article class="bottom">
            	<button type="button" id="btnDownload" class="btn_tab" style="display:none;">File Download</button>
            	<button type="button" id="btnPlayerD" class="btn_tab">재생기설치</button>
            	<!-- <button type="button" id="btnSumBankD" class="btn_tab">썸뱅크설치</button> -->
            	<span class="copyright">Copyright (c) Bridgetec.corp. All right Reserved.</span>
            </article>
            
        </section>    
        <!-- E:Content(Right) -->
            
	</div>
</body>

</html>