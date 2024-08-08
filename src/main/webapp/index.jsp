<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Refresh" content="0; URL=common/LoginF.do" />
<title>VELOCEIndex</title>
<body>
</body>
</html>