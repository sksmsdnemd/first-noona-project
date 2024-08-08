<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->


<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "시스템정보관리";
	var workLog 	= "";

	var dataArray 	= new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});

	function fnInitCtrl(){		
		$("#btnDownload").click(function(){
			fnDownload();
		});
	}

	function fnInitGrid(){

		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        multiSelect: true,
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'apiName', 	caption: 'API이름', 		size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'fileName', 	caption: '파일이름', 	size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'download', 		caption: '다운로드', 		size: '15%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'sysGroupId', 'useFlag');
	}
	
	
	function fnSearchList(){
		var btnDown = $("<button>").attr("type","button")
		.attr("class","btn_m confirm")
		.attr("text","다운로드");
		dataArray = [
					 {  "recid": 0, "apiName"	: "상담 APP 연동 샘플", "fileName": "RecordAPISample.zip", "download" : btnDown.attr("onclick","fnDownload('RecordAPISample.zip')") },
					 {  "recid": 1, "apiName"	: "상담 APP 연동 샘플", "fileName": "RecordAPISample.zip", "download" : btnDown.attr("onclick","fnDownload('RecordAPISample.zip')") }
					];
		
		w2ui['grid'].add(dataArray);
	}
	
	function fnDownload(fileName){
		var fileName = w2ui['grid'].getCellValue(value, 2);
		var form = $('<form>');
		form.attr('action', gGlobal.ROOT_PATH + "/SampleAPI/RecordAPISampleF.do");
		form.attr('method', 'post');
		form.appendTo('body');
		var input = $('<input>').attr("type","text");
		input.attr("name","fileName");
		input.val(fileName);
		form.append(input);
		form.submit();
		form.remove();
	}
	
	function getTimeStamp() {
	    var d = new Date();
	    var date = leadingZeros(d.getFullYear(), 4) + '-' + leadingZeros(d.getMonth() + 1, 2) + '-' + leadingZeros(d.getDate(), 2) + ' ';
	    var time = leadingZeros(d.getHours(), 2) + ':' + leadingZeros(d.getMinutes(), 2) + ':' + leadingZeros(d.getSeconds(), 2);

	    return date + " / " + time;
	}
	
	function fnExcelSampleDownload(){
		var form = $('<form>');
		form.attr('action', gGlobal.ROOT_PATH + "/SampleAPI/RecordAPISampleF.do");
		form.attr('method', 'post');
		form.appendTo('body');
		var input = $('<input>').attr("type","text");
		input.attr("name","fileName");
		input.val("ExcelSample.xlsx");
		form.append(input);
		form.submit();
		form.remove();
	}
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템설정관리</span><strong class="step">시스템정보관리</strong></div>
        <section class="sub_contents">
            <div class="search_area">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">시스템그룹</strong>
                            <select id="s_FindSysGroupId" name="s_FindSysGroupId" style="width:300px;" class="list_box">
                                <option>선택하세요!</option>
                            </select>
                        </li>                   
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">검색</strong>
                            <select id="s_FindKey" name="s_FindKey" style="width: 117px" class="list_box">
								<option value="">선택하세요!</option>
								<option value="system_id">시스템ID</option>
								<option value="system_name">시스템명</option>
							</select>
							<input type="text"	id="s_FindText" name="s_FindText" style="width:180px"/>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 415px;"></div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>