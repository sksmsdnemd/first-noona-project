<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="com.bridgetec.argo.common.Constant"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
%>
<title>ARGO</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />

<link rel="stylesheet" href="../css/argo.common.css" type="text/css" />

<!-- Argo -->
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>   


<script type="text/javascript">

		
	function acceptFunction(param){
		var arr = new Array();
		arr = param;		
		alert(arr[0]+'//'+arr[1]);
	}
	function cancelFunction(param){alert(param);}
	
</script>
<style type="text/css"> 
	table{width: 500px;} 
	table, td { 
	   border-collapse: collapse; 
	   border: 1px black solid; 
	} 
	.t1 {padding:7px; text-align:left ; font-size:12px; font-weight:bold; background:#f1f1f2;}
	.t2 {padding:7px; text-align:left ; font-size:12px;}

    	
</style> 
</head>
<body>
<table>
	<tr> 
		<td class="t1">경고창</td> 
	</tr> 
	<tr> 
		<td class="t2">
			 <a href="javascript:argoConfirm('확인해보시겠습니까?', 'function', 'function', 'acceptFunction', ['param1', 'param2'], 'cancelFunction', 'param3');">확인(confirm)</a><br/><br/>
			 <a href="javascript:argoAlert('error', '에러입니다');">에러(error)</a><br/><br/>
			 <a href="javascript:argoAlert('warning', '경고입니다');">위험(warning)</a><br/><br/>
			 <a href="javascript:argoAlert('extend', '확장형메세지 입니다 <br>아래내역을 확인하세요', 'msg00872');">확대(extend)</a>
	 
		</td> 
	</tr>
	
</table> 

</body>
</html>