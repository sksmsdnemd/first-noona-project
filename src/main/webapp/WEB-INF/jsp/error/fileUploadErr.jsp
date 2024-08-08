<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.bridgetec.argo.common.Constant"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html>
<html>
<head>
<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
%>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
</head>
<body>
{"resultMsg":"파일 업로드가 실패하였습니다(최대용량 초과).","resultSubMsg":"<c:out value="${exception.message}" />","resultCode":"<%=Constant.RESULT_CODE_ERR_FILESIZE%>","resultSubCode":""}
</body>
</html>