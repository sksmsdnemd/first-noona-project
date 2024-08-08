<!-- 
/****************************************************************
 * 파일명: agentInstall.jsp
 * 설명   : agent 설치 페이지
 * 수정일		       수정자       Version		
 ****************************************************************
 * 2020.04.14	     	1.0			최초생성
 ****************************************************************
 */
-->
<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ include file="/WEB-INF/jsp/include/common.jsp"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<title>Agent Install</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />

<%
 response.setHeader("Cache-Control","no-cache");
 response.setHeader("Pragma","no-cache");
 response.setDateHeader("Expires",0);
%>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="Expires" content="0"/>
<meta http-equiv="Pragma" content="no-cache"/>


<link rel="stylesheet" href="<c:url value="/css/argo.agentInstall.css"/>" type="text/css" />
    


<%

%>

<script type="text/javascript">

	function fnDownload(type) {
		if(type == "player") {
			location.href='/BT-VELOCE/data/VLCPlayer_NonActiveX.exe';
		} else if(type == "agent") {
 			alert("agent 설치 파일 위치와 파일명이 필요해요!!!!!!");
//			location.href='/BT-VELOCE/data/Veloce-Agent.exe';
		}
	}
	
	function fnMain() {
		window.setTimeout(function(){ window.location.replace(gGlobal.ROOT_PATH + "/common/VMainF.do"); }, 500);
	}
</script>
</head>
<body>
	<div class="ai_wrap">
		<section class="ai_section">
	    	<div class="argo_logo"><img src="../images/veloce/login_veloce.png" alt="VELOCE"></div>
	        <div class="ai_box">
	        	<div class="ai_title"><font style="font-size:20px; color:#777676; font-weight:600;">프로그램 통합설치</font></div>
	            <div class="ai_cont">
	                <div class="input_area" style="padding: 10px;">
	                	<table class="input_table">
							<colgroup>
								<col width="25%" />
								<col />
								<col width="20%" />
							</colgroup>
							<tbody class="resultData">                                     
								<tr>
									<th align="center"><span style="font-size:14px;">프로그램</span></th>
									<th align="center"><span style="font-size:14px;">기능</span></th>
									<th align="center"><span style="font-size:14px;">설치상태</span></th>
								</tr>
								
								<!-- player 없으면 agent 확인이 안되는 이유로 임시적으로 player 먼저 설치하도록 수정 -->
								<c:if test="${ !param.playerInstall }">
								<tr>
									<td style="padding-left:5px;">
										<span style="font-weight: bold; font-size:13px;">전용재생기</span><br/>
										<span style="font-size:12px;">(VLCPlayer)</span>
									</td>
									<td style="padding-left:5px;">
										<span style="font-size:13px;">녹취 파일을 재생할 수 있는 프로그램 입니다.</span>
									</td>
									<td style="padding-left:5px; text-align: center;">
										<c:choose>
											<c:when test="${param.playerKind eq '1' and param.playerInstall}">
												<span style="color: #606060; font-size:13px; font-weight: bold;">설치됨</span>
											</c:when>
											<c:when test="${param.playerKind eq '1' and not param.playerInstall}">
												<span style="color: #3876b8; font-size:13px; font-weight: bold;">미설치</span>
												<button type="button" class="btn_tab" style="font-size: 12px;" onclick="javascript:fnDownload('player');">다운로드</button>
											</c:when>
											<c:otherwise><span style="color: #606060; font-size:13px; font-weight: bold;">미사용</span></c:otherwise>
										</c:choose>
									</td>
								</tr>
								</c:if>
								
								<!-- player 없으면 agent 확인이 안되는 이유로 임시적으로 player 먼저 설치하도록 수정 -->
								<c:if test="${ param.playerInstall }">
								<tr>
									<td style="padding-left:5px;">
										<span style="font-weight: bold; font-size:13px;">VeloceAgent</span><br/>
										<span style="font-size:12px;">(VLCAgent)</span>
									</td>
									<td style="padding-left:5px;">
										<span style="font-size:13px;">agent 프로그램 입니다.</span>
									</td>
									<td style="padding-left:5px; text-align: center;">
										<c:choose>
											<c:when test="${param.agentUseYn eq 'Y' and param.agnetInstall}">
												<span style="color: #606060; font-size:13px; font-weight: bold;">설치됨</span>
											</c:when>
											<c:when test="${param.agentUseYn eq 'Y' and not param.agnetInstall}">
												<span style="color: #3876b8; font-size:13px; font-weight: bold;">미설치</span>
												<button type="button" class="btn_tab" style="font-size: 12px;" onclick="javascript:fnDownload('agent');">다운로드</button>
											</c:when>
											<c:otherwise><span style="color: #606060; font-size:13px; font-weight: bold;">미사용</span></c:otherwise>
										</c:choose>
									</td>
								</tr>
								</c:if>
							</tbody>
						</table>
	                </div>
	                <div>* 프로그램 <span style="color: red;">설치 완료 후</span>에는 아래의 <span style="color: red;">[메인페이지로 이동] 버튼을 클릭</span>하여 주시기 바랍니다.</div>
	            </div>
				<div style="text-align: center;"><button type="button" id="btnReset" class="btn_m confirm" onclick="javascript:fnMain();">메인페이지로 이동</button></div>
	        </div>
	        <div class="copyright">Copyright (c) Bridgetec.corp. All right Reserved.</div>
	    </section> 
	</div>
</body>

</html>
