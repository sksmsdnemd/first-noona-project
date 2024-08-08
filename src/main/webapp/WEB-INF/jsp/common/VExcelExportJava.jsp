<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
%>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/jquery-table2excel.js"/>"></script>

<script>

	var pExcelUrl = "";
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     	return this[key] === undefined ? value : this[key];
	    };
	    
	    var strHead = "";
	    var strForm = "";
		var strList = "";
		var sColKey = sPopupOptions.pColKey;
		var sColVal = sPopupOptions.pColVal;
		var sExcelFileName = sPopupOptions.pExcelFileName+".xlsx";
		pExcelUrl 	= sPopupOptions.pExcelUrl;
		
		console.log(pExcelUrl);
		
		var jsonPar = {"excelColKey":sColKey,"excelColName":sColVal};
		
		var xhr = new XMLHttpRequest();
		xhr.open("POST", pExcelUrl, true);
		xhr.responseType = 'blob';
		xhr.onload = function() {
		 	var blob = xhr.response;
		    var file = new File([blob],  { type: 'application/octet-stream' } ); 
		    const link = document.createElement( 'a' );
		    link.style.display = 'none';
		    document.body.appendChild( link );
		    
		    link.href = URL.createObjectURL( blob );
		    link.download = sExcelFileName;
		    link.click();
		    link.remove();
		    argoPopupClose();
		}
		xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");   
		xhr.send("testlist="+JSON.stringify(jsonPar)+"&excelFileName="+sExcelFileName);
	});

</script>
</head>
<body>
	<div id="div_excel">
    	<table id="excel_data">
        	<tr  id="excel_export"></tr>
        </table>
	</div>
</body>

</html>
