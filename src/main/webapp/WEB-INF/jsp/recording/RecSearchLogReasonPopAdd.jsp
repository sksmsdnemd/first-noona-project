<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<style type="text/css">
.memo {line-height: 22px};

</style>
<script>
	var loginInfo; 	
	var userId; 	
	var tenantId; 	
	var workIp; 	
	var workMenu; 	
	var workLog; 	
	var workIp;    	
	var sPopupOptions;
	var dataArray 	= new Array();
	
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
     		return this[key] === undefined ? value : this[key];
	    };
    	try{
//     		if(sCudMode != "A"){
//     			loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
//     			userId 		= loginInfo.SVCCOMMONID.rows.userId;
//     			tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
//     			workIp	 	= loginInfo.SVCCOMMONID.rows.workIp;
//     			workMenu 	= "청취사유관리";
//     			workLog 	= "";
//     			workIp    	= loginInfo.SVCCOMMONID.rows.workIp;
//     		}
   			fnInitGrid();
    		ArgSetting();
    	  	fnInitCtrl();	
    	}catch(e){
    		console.log(e);
    	}
	});

	function ArgSetting() {
		fnSearchList();
	}
	
	function fnInitCtrl(){
		$("#btnSearch").click(function(){
			fnLogReasonInsert();
		});
		
		$("#btnDelete").click(function(){
			fnLogReasonDelete();
		});
	}
	
	function fnLogReasonDelete(){
		var classId = "rec_reason"; 
		var indexs = w2ui['grid'].getSelection();
		
		if(indexs.length > 0) {
			var delCnt = 0;
			for(var i=0;i<indexs.length;i++){
				var index = w2ui['grid'].get(indexs[i]);
				var result = argoJsonUpdate("baseCode", "setBaseCodeDelete" , "ip_", {"classId":classId,"codeId":index.classId} );
				delCnt += Number(result.SVCCOMMONID.procCnt);
			}
			argoAlert(delCnt+"건 삭제되었습니다.");
		} else {
			argoAlert("삭제할 청취사유를 선택해 주세요.");
		}
		
		fnSearchList();
	}
	
	function fnLogReasonInsert(){
		var classId = "rec_reason"; 
		var codeId = $("#s_InsReasonId").val();
		var className = "청취사유분류";
		var codeName = $("#s_InsSeasonName").val();
		
		if(codeId == "") {
			argoAlert("사유ID를 입력해 주세요.");
			$("#s_InsReasonId").focus();
			return;
		}
		
		if(codeName == "") {
			argoAlert("사유를 입력해 주세요.");
			$("#s_InsReasonId").focus();
			return;
		}
		
		argoJsonSearchOne('baseCode', 'isBaseCodeExist', 's_', {"classId":classId,"codeId":codeId}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					
					if(totalData == 0){
						var result = argoJsonUpdate("baseCode", "setBaseCodeInsert", "s_", {"classId":classId,"codeId":codeId,"className":className,"codeName":codeName,"codeDesc":""});
						
						if(result.SVCCOMMONID.procCnt > 0){
							parent.argoAlert("등록되었습니다.");
							$("#s_InsReasonId").val("");
							$("#s_InsSeasonName").val("");
						}
					}else{
						parent.argoAlert("중복된 사유ID입니다.");
					}
				}
				fnSearchList();
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(){
		var classId = "rec_reason"; 
		w2ui.grid.lock('조회중', true);
		argoJsonSearchList('baseCode', 'getBaseComboList', 's_', {"classId":classId} , function (data, textStatus, jqXHR){ 
			try {
				if (data.isOk()) {
					w2ui.grid.clear();
					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							var gObject2 = {  "recid" 			: index
				   					, "classId"		: row.code
				   					, "codeId"		: row.codeNm
									};
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
					w2ui.grid.unlock();
				}
			} catch (e) {
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
	            selectColumn: true
	        },
// 	        onDblClick : function(event) {
// 				if (event.recid >= 0) {
// 					$("#s_InsReasonId").val(w2ui['grid'].getCellValue(event.recid, 1));
// 					$("#s_InsSeasonName").val(w2ui['grid'].getCellValue(event.recid, 2));
// 				}
// 			},
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 			     caption: 'recid', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'classId', 	         caption: '사유아이디', 			size: '50%', 	sortable: true, attr: 'align=center'}
	            		,{ field: 'codeId', 	     caption: '사유제목', 				size: '50%', 	sortable: true, attr: 'align=center'  }
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
	        <div class="pop_cont pt5">
	        	<div class="btn_topArea" style="height: 34px;">
                    <table class="input_table" >
	        			<tr>
	        				<th>사유ID</th>
	        				<td><input type="text"	id="s_InsReasonId" name="s_InsReasonId" style="width: 100%;"/></td>
	        				<th>사유</th>
	        				<td><input type="text"	id="s_InsSeasonName" name="s_InsSeasonName" style="width: 100%;"/></td>
	        			</tr>
	        		</table>
	        	</div>
	        	<div class="btn_topArea">
		        	<span class="btn_r">
	                   	<button type="button" class="btn_m confirm" id="btnDelete" name="btnDelete">삭제</button>
	                   	<button type="button" class="btn_m search" id="btnSearch" name="btnSearch">등록</button>      
	                </span>     
                </div>
	            <table class="input_table">
					<div class="grid_area h25 pt0">
	         			<div id="gridList" style="width: 100%; height: 415px;"></div>
	         		</div>
	            </table>            
	         </div>
        </section>
    </div>
</body>

</html>
