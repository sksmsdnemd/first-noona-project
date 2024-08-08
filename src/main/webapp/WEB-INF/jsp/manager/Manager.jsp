<!-- 
/****************************************************************
 * 파일명: Login.jsp
 * 설명   : 로그인페이지
 * 수정일		       수정자       Version		
 ****************************************************************
 * 2018.02.12	     	1.0			최초생성
 ****************************************************************
 */
-->
<%@ page language="java" import= "java.util.*,egovframework.com.cmm.util.EgovUserDetailsHelper" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
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

<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017021301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/sha512.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>  



<script type="text/javascript">
	    

	
	$(function () {

	});
	


</script>
</head>
<body>
	<span>test</span>
</body>

</html>
