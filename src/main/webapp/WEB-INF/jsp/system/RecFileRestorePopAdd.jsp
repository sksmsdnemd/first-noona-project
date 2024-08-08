<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<%-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script> --%>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "녹취파일복원 팝업";
	var workLog 	= "";
	
	$(document).attr("title","test");
	
	var dataArray = new Array();
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
	    
	    fnInitGrid();
	    fnSearchList();
	    
	});
	
	function fnSearchList(){
		var rowData = sPopupOptions.pRowIndex;
		$("#thUcId").text("RECKEY");
		$("#ucid").text(rowData.recKey);
		fnRecKeySearchList(rowData);
	}
	
	// 병합 내역 조회
	function fnRecKeySearchList(rowData){
		argoJsonSearchList('recSearch', 'getRecRestoreRecKeySearchList', 's_', {"findRecKey":rowData.recKey}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if(data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, rows ) {

							gObject2 = {	"recid" 			: index
									, "recDate"			: rows.recDate
									, "recTime" 			: rows.recTime
									, "dnNo"		: rows.dnNo
									, "tenanatId"		: rows.tenantId
									, "userId"		: rows.userId
									, "callId"		: rows.callId
									};
							
							dataArray.push(gObject2);
							
						});
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
			} catch(e) {
				console.log(e);			
			}
		});
	}
		
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid',
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: false
	        },
	        multiSelect: true,
	        columns: [  
	        			 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'recDate', 		caption: '통화일자', 		size: '6%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'recTime', 		caption: '통화일자', 		size: '6%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'dnNo', 	caption: '내선번호', 		size: '5%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'tenanatId', 		caption: '테넌트ID', 		size: '7%', 	sortable: true, attr: 'align=center' }
						,{ field: 'callId', 			caption: '콜아이디', 			size: '20%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid');
	}
	

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="input_area">
            		<table class="input_table">
							<tr>
								<th id="thUcId">
									UCID
								</th>
								<td colspan="4" id="ucid">
								</td>
							</tr>
                        <tbody id="tBody">
                        	
						</tbody>
					</table>
					<table>
						<tbody>
							<div class="h136">
				            	<div class="btn_topArea fix_h25"></div>
					            <div class="grid_area h25 pt0">
					                <!-- <div id="gridList" style="width: 100%; height: 415px;"></div> -->
					                <div id="gridList" style="width: 100%; height: 310px;"></div>
					            </div>
					        </div>
						</tbody>
					</table>
				</div>
            </div>            
        </section>
    </div>
</body>

</html>
