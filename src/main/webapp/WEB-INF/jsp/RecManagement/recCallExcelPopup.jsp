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
<script type="text/javascript"  src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/jquery-table2excel.js"/>"></script>

<script>
$(function () {
	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    var str="";
    var dataStr="";
    var start = "<tbody><tr>";
    var end = "</tr></tbody>";
	var dataStr1 ="";
    $.each(sPopupOptions.pRowIndex, function( index, row ) {
    	dataStr1="";
    	$.each(row, function( key, value ) {
    		 if(index == 0){
    			 str += "<th>"+key+"</th>";
    		 }
    			 dataStr1 += '<td style="mso-number-format:"\@";">'+ value + '</td>';
    	});
   	 	dataStr += start+dataStr1+end;
    	
    });
  
    $("#excel_export").append(str);
   	$("#excel_data").append(dataStr);
   	excelExport();
});
function excelExport(){
	  $('#excel_data').attr('border', '1');
	  $("#excel_data").table2excel({
		   // exclude CSS class
		   exclude: ".noExl",
		   name: "Data",
		   filename: "분류콜관리" //do not include extension
	  });
	  argoPopupClose();
};

</script>
</head>
<body>
	<input type="button" id="btnExport" value=" Export Table data into Excel " />
    	<table id="excel_data" border="1">
        	<thead><tr  id="excel_export" ></tr></thead>
        </table>
</body>
</html>
