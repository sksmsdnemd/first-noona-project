<!-- 
/****************************************************************
 * 파일명: LoginConfig.jsp
 * 설명   : 로그인페이지 CONFIG
 * 수정일		       수정자       Version		
 ****************************************************************
 * 2018.02.12	     	1.0			최초생성
 ****************************************************************
 */
-->
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="com.bridgetec.common.*" %>
<%@ page language="java" import= "java.util.*,egovframework.com.cmm.util.EgovUserDetailsHelper" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
%>
<title>VELOCE</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />
<link rel="stylesheet" href="<c:url value="/css/argo.common.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.login.css"/>" type="text/css" />

<style>
li:has(> a.active){}
.test1 .test2:parent{ color:red }
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
		
		$("#login").on('click',function(){
			formCheck();
		})
	
	});
	
	function formCheck() {
		var key  = "BRIDGETEC_VELOCE";
		var enId = $("#s_AgentId").val();
		var enPw = $("#agentPwView").val();
		
		if(enId == ''){
			argoAlert("아이디를 입력하세요");
			return;
		}
		
		if(enPw == ''){
			argoAlert("비밀번호를 입력하세요");
			return;
		}
		
		var codeValue = "LOG"
		var param = {
						  key  : key
						, enId : enId
						, enPw : enPw
						, Code : codeValue
					};
		
		$.ajax({
			type : 'post',
	        data: param,
			url : gGlobal.ROOT_PATH + "/dbInfoConfig.do",
			dataType : "json",
			success : function(data) {
				//console.log(data);
				if(data.ret=="failId"){
					argoAlert("아이디가 맞지 않습니다");
					return;
				}else if(data.ret=="failPw"){
					argoAlert("비밀번호가 틀립니다");
					return;
				}else if(data.ret=="success"){
					window.location.replace(gGlobal.ROOT_PATH+"/common/DbInfoConfigF.do");
				}
			},error : function(xhr, status, error) {
	            console.log(error);
	       }
		});	
	}
	
	function eventCheck(){
	    var code = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	    if (code==13) {
	        formCheck();
	    }       
	}
	
</script>
</head>
<body >
	<c:choose>
		<c:when test="${sessionMAP.sabun eq null}">
			<div class="login_wrap">
				<section class="log_section">
			    	<div class="argo_logo"><img src="../images/veloce/login_veloce.png" alt="VELOCE"></div>
			        <div class="login_box">
			        	<div class="login_title"><!-- <img src="../images/login_bs.png" alt="고객사BI"> --></div>
			            <div class="log_cont">
			            	<div class="log_info">아이디와 비밀번호를 입력해 주세요 .</div>
			            	<div class="version"></div>
			                <div class="input_area">
			                	<input type="text" id="s_AgentId" name="s_AgentId" onkeyup="eventCheck();" placeholder="아이디를 입력하세요.">
			                    <input type="password" id="agentPwView" name="agentPwView" onkeyup="eventCheck();" placeholder="비밀번호를 입력하세요.">
			                    <input type="hidden" id="s_LoEnType" name="s_LoEnType" value="login">
			                    <input type="hidden" id="dateSetValue" name="dateSetValue" value="-400">
			                    <a href="#" id="login" class="btn_login" style="height: 90px;">로그인</a>
			                </div>
			            </div>
			        </div>
			        <div class="copyright">Copyright (c) Bridgetec.corp. All right Reserved.</div>
			    </section> 
			</div>
		</c:when>
		<c:otherwise>
			<script type="text/javascript">
				window.location.replace(gGlobal.ROOT_PATH+"/common/DbInfoConfigF.do");
			</script>
		</c:otherwise>
	</c:choose>
</body>

</html>
