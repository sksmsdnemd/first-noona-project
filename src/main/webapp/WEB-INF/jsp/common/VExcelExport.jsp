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

<!-- csv변환 라이브러리 -->
<script type="text/javascript" src="<c:url value="/scripts/argojs/table2csv.js"/>"></script>

<script>

	var workMenu = "";
	var headerCnt = 1;
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     	return this[key] === undefined ? value : this[key];
	    };
	    
	    var strHead = "";
	    var strForm = "";
		var strList = "";
		workMenu 	= sPopupOptions.workMenu;
		
		// jslee 엑셀 다중헤더를 위한 headerCnt 추가
		headerCnt	= argoNullConvert(sPopupOptions.headerCnt)==""?1:argoNullConvert(sPopupOptions.headerCnt);
		
	    $.each(sPopupOptions.pRowIndex, function( index, row ) {
	    	strList="";
	    	$.each(row, function( key, value ) {
	    		 if(index == 0){
	    			 strHead += '<th>' + key + '</th>';
	    		 }
	    		 strList += '<td>'+ value + '</td>';
	    	});
	    	strForm += '<tr>' + strList + '</tr>';
	    	
	    });
	  
	    $("#excel_export").append(strHead);
	   	$("#excel_data").append(strForm);
	   	
	   	argoJsonSearchList('ARGOCOMMON','searchExlCsvCode','_', {}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var exlCsvCode = data.getRows()[0].exlcsvCode; 
					if(exlCsvCode == "EXL"){
						excelExport();
					}else if(exlCsvCode == "CSV"){
						csvExport();
					}
				}
			} catch (e) {
				console.log(e);
			}
		});
	});
	
	
	
	function excelExport(){
		$("#div_excel").table2excel({
				 exclude  : ".noExl"
				,name     : "Data"
				,filename : workMenu + ".xls"
				,headerCnt : headerCnt
		  });
		
		setTimeout("argoPopupClose();",1500);
	}; 
	
	function csvExport(){
		var options = {
			"separator": ",",    // 구분자
			"newline": "\n",     // 개행문자
			"quoteFields": true, // 
			"excludeColumns": "",
			"excludeRows": "",
			"trimContent": true,
			"filename": workMenu + ".csv",
			"appendTo": "#output"
		}
		$("#excel_data").table2csv("download", options);
		setTimeout("argoPopupClose();",1500);
	}

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
