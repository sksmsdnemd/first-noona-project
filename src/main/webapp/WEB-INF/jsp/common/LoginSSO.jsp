<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="com.bridgetec.common.*"%>
<%@ page language="java" import="java.util.*,egovframework.com.cmm.util.EgovUserDetailsHelper" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<title>VELOCE</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />

<%
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Pragma", "no-cache");
	response.setDateHeader("Expires", 0);
%>
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="Pragma" content="no-cache" />

<link rel="stylesheet" href="<c:url value="/css/argo.common.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.login.css"/>" type="text/css" />

<style>
li:has (>a.active ){
	
}

.test1 .test2:parent {
	color: red
}
</style>

<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017021301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js"/>"></script>
<%-- <script type="text/javascript" src="<c:url value="/scripts/security/security.js"/>"></script> --%>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>

<script type="text/javascript">


	$(document).ready(function(){
		
		if(vlcOPT.VLC_SSO_DEBUG=="0")
		{
			ssoSend();
			$("#SSO_DEBUG").hide();
		}
		else{
			
			$("#ssoLogin").on('click',function(){
				
				ssoSend_DEBUG();
			
		});
		
		$(".clickSearch").keydown(function(key){
			 if(key.keyCode == 13){
				 ssoSend_DEBUG();
			 }
		});			
		}
				
			
	});
	function ssoSend() {
	  
	  ssoParamTenantId = vlcOPT.VLC_SSO_TENANT_ID;
	  ssoParamUserId = decodeURI("<%=request.getParameter("id")%>");
	  
	  var CSRF_TOKEN = "<%=request.getParameter("CSRF_TOKEN")%>";
		var ssoTenantId = ssoParamTenantId;
		var ssoUserId   = ssoParamUserId;
		if(ssoTenantId == ""){  
			argoAlert("회사를 입력하세요");
			return;
		}
		
		if(ssoUserId == ""){
			argoAlert("사용자를 입력하세요");
			return;
		}
		
		var securedLoginForm = $("#securedLoginForm")
		
		$("#tenantId").val(ssoTenantId) ;
		$("#userId").val(ssoUserId) ;
		securedLoginForm.submit();
	}
	
	function ssoSend_DEBUG(){
		var ssoParamTenantId = "<%=request.getParameter("tenant_id")%>";
		var ssoParamTenantId =  vlcOPT.VLC_SSO_TENANT_ID;
		var ssoParamUserId = decodeURI("<%=request.getParameter("user_id")%>");
		
		$("#s_TenantId").val(ssoParamTenantId);
		$("#s_UserId").val(ssoParamUserId);
		var ssoTenantId = $("#s_TenantId").val();
		var ssoUserId = $("#s_UserId").val();

		if (ssoTenantId == "") {
			argoAlert("회사를 입력하세요");
			return;
		}

		if (ssoUserId == "") {
			argoAlert("사용자를 입력하세요");
			return;
		}

		var securedLoginForm = $("#securedLoginForm")
		
		$("#tenantId").val(ssoTenantId) ;
		$("#userId").val(ssoUserId) ;
		securedLoginForm.submit();
	}
</script>
</head>
<body>
	<c:choose>
		<c:when test="${sessionMAP.sabun eq null}">
			<div class="login_wrap" id="SSO_DEBUG">
				<section class="log_section">
					<div class="argo_logo">
						<img src="../images/veloce/login_veloce.png" alt="VELOCE">
					</div>
					<div class="login_box">
						<!-- <div class="login_title"><img src="../images/login_bs.png" alt="고객사BI"></div> -->
						<div class="login_title">
							<font style="font-size: 20px; color: #777676; font-weight: 600;">SSO 로그인</font>
						</div>
						<div class="log_cont">
							<div class="log_info2">SSO연동 입력 : 센터 / 회사 / 사용자ID를 입력 하세요!</div>
							<div class="version"></div>
							<div class="input_area2">
								<input type="text" id="s_CenterCd" name="s_CenterCd" value="C1" class="clickSearch" readonly><br /> 
								<input type="text" id="s_TenantId" name="s_TenantId" placeholder="TENANT를 입력하세요!" class="clickSearch"><br /> 
								<input type="text" id="s_UserId" name="s_UserId" placeholder="사용자ID를 입력하세요!" class="clickSearch"> 
								<a href="#" id="ssoLogin" class="btn_login" style="height: 140px;">전송</a>
							</div>
						</div>
					</div>
					<div class="copyright">Copyright (c) Bridgetec.corp. All right Reserved.</div>
				</section>
			</div>


			<form name="securedLoginForm" id="securedLoginForm" action="/BT-VELOCE/common/LoginF.do" method="post" style="display: block;">
				<input type="hidden" name="tenantId" id="tenantId" value="">
				<input type="hidden" name="userId" id="userId" value="">
			</form>
		</c:when>
	</c:choose>
</body>

</html>

