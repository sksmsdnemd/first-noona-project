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
.no-left-padding {
  padding-left: 0 !important;
}




</style>
<script type="text/javascript">
	
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var userId2    	= loginInfo.SVCCOMMONID.rows.userId;
	var workMenu 	= "내선구분관리";
	var workLog 	= "";
	
	var cudMode;
	var systemId;
	var processId;
	var userId;
	var dnNo;
	var dnNo;
	var reqTenantId;
	var orgIp;
	
	var dataArray 	= new Array();
	
	$(document).ready(function() {
		
		var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
		
		
		fnInitGrid();
		fnInitCtrl();
		fnSearchListCnt();
		
		
	});
	
	
	function fnInitGrid(){
		
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	//	        onDblClick : function(event) {
	//				if (event.recid >= 0) {
	//					$("#s_InsReasonId").val(w2ui['grid'].getCellValue(event.recid, 1));
	//					$("#s_InsSeasonName").val(w2ui['grid'].getCellValue(event.recid, 2));
	//				}
	//			},
	        multiSelect: true,
	        columns: [  
				 { field: 'recid', 		caption: 'recid', 		size: '0%',		attr: 'align=center',	sortable: true }
				,{ field: 'gubunId', 	caption: 'gubunId', 	size: '0%', 	sortable: true, attr: 'align=center' }
				,{ field: 'gubunName', 	caption: '구분명', 		size: '50%', 	sortable: true, attr: 'align=center'}
				,{ field: 'dnRange', 	caption: '내선대역', 		size: '50%', 	sortable: true, attr: 'align=center'  }
				,{ field: 'startDn', 	caption: '시작내선번호',	size: '0%', 	sortable: true, attr: 'align=center'  }
				,{ field: 'endDn', 	    caption: '종료내선번호',	size: '0%', 	sortable: true, attr: 'align=center'  }
	        ],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid', 'gubunId', 'startDn', 'endDn');
	}
	
	
	function fnInitCtrl(){
		cudMode 	= sPopupOptions.cudMode;
		systemId 	= sPopupOptions.systemId;
		processId 	= sPopupOptions.processId;
		userId 		= sPopupOptions.userId;
		reqTenantId = sPopupOptions.tenantId;
		
		$("#ip_InsId").val(loginInfo.SVCCOMMONID.rows.agentId);
		$("#ip_UptId").val(loginInfo.SVCCOMMONID.rows.agentId);
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});
		
		$("#btnDelete").click(function(){
			fnDeleteList();
		});	
		
	}
	
	
	function fnSearchListCnt(){
		
		argoJsonSearchOne('userTel', 'getUserTelNoGubunCount', 's_', {}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					$("#totCount").html(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
					
					w2ui.grid.lock('조회중', true);
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow){
		argoJsonSearchList('userTel', 'getUserTelNoGubunList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){		
		
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){ 
						dataArray = [];
						
						$.each(data.getRows(), function( index, row ) {
							
							var dnRange = row.startDn + "~" + row.endDn;
							
							gridObject = {	  "recid" 			: index
											, "gubunId" 			: row.gubunId
											, "gubunName" 	   	: row.gubunName
											, "startDn" 			: row.startDn
											, "endDn" 				: row.endDn
											, "dnRange" 			: dnRange
											
										};
										
							dataArray.push(gridObject);
							
						});
						w2ui['grid'].add(dataArray);
					}
					
				}
			} catch(e) {
				console.log(e);			
			}
			
			workLog = '[TenantId:' + reqTenantId + ' | UserId:' + userId
			+ ' | GrantId:' + grantId + '] 조회';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
				tenantId : reqTenantId,
				userId : userId,
				actionClass : "action_class",
				actionCode : "W",
				workIp : workIp,
				workMenu : workMenu,
				workLog : workLog
			});
		});
	}
	
	
	function fnSavePop(){
		
		var exitAt = false;
		
		var gubunName = $("#ip_gubunName").val();
		var startDn = parseInt($("#ip_startDn").val());
		var endDn = parseInt($("#ip_endDn").val());
		
		if(gubunName === ''){
			argoAlert("등록할 내선 구분명을 입력해주세요.");
			$("#ip_gubunName").focus();
			return;
		}
		
		if($("#ip_startDn") === '' || $("#ip_endDn").val() === '' ){
			argoAlert("등록할 내선 대역을 입력해주세요.");
			return;
		}
		
		if(startDn >= endDn){
			argoAlert("시작내선이 종료내선보다<br/>크거나 같을 수 없습니다.");
			return;
		}
		
		
		var params = {
				startDn:startDn
				,endDn:endDn
		};
		
		if(cudMode =='I') {
			argoJsonSearchOne('userTel', 'getUserTelNoGubunChk', 'ip_', params, function (Resultdata, textStatus, jqXHR){
				if(Resultdata.isOk()) {
					var dnChkCnt = parseInt(Resultdata.getRows()['cnt']);
					
					if(dnChkCnt > 0){
						argoAlert("입력한 내선대역이 존재합니다.");
						exitAt=true;
						return;	
					}
				}
			});
		}
		
		if(!exitAt){
			argoConfirm("저장 하시겠습니까?", function(){
				fnDetailInfoCallback();	
			});
		} 
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		
		try {
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("userTel", "setUserTelNoGubunInsert", "ip_", {"cudMode":cudMode});
				workLog = '[내선번호구분:' + $("#ip_gubunName").val() + '] 등록';
			}
	
		  if(Resultdata.isOk()) {	
			    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {userId:userId2
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
			}else {
			   	argoAlert("저장에 실패하였습니다");	 
			}
		} catch (e) {
			console.log(e);
		}
	}
	
	function fnDeleteList(){
		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("삭제할 내선구분을 선택하세요"); 
		 		return ;
			}

			argoConfirm('선택한 내선구분 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				
				var multiService = new argoMultiService(fnCallbackDelete);
				
				$.each(arrChecked, function( index, value ) {
					var gubunId = w2ui['grid'].getCellValue(value, 1);
					var gubunName = w2ui['grid'].getCellValue(value, 2);
					var param = { 
									"gubunId"  :  gubunId
								};
					workLog = '[내선구분:' + gubunName + '] 삭제';
					multiService.argoDelete("userTel", "setUserTelNoGubunDelete", "__", param);
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		}
	}	
	
	function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:reqTenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
</script>
</head>
<body>
    <div class="sub_wrap pop">
        <section class="pop_contents"> 
	        <div class="pop_cont pt5">
	        	<div class="btn_topArea" style="height: 34px;">
	        	<input type="hidden" id="ip_InsId" name="ip_InsId" />
	         <input type="hidden" id="ip_UptId" name="ip_UptId" />
           		<table class="input_table" >
	        			<tr>
	        				<th style="padding-right:17px;">구분명</th>
	        				<td ><input type="text"	id="ip_gubunName" name="ip_gubunName" style="width: 100%;"/></td>
	        				<th style="padding-right:17px;">시작내선</th>
	        				<td><input type="text"	id="ip_startDn" name="ip_startDn" style="width: 100%;"/></td>
	        				<th style="padding-right:17px;">종료내선</th>
	        				<td><input type="text"	id="ip_endDn" name="ip_endDn" style="width: 100%;"/></td>
	        			</tr>
	        		</table>
	        	</div>
	        	<div class="btn_topArea">
	        		<div class="sub_l">
					<strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount">0</span>
					</div>
		        	<span class="btn_r">
	                   	<button type="button" class="btn_m confirm" id="btnDelete" name="btnDelete">삭제</button>
	                   	<button type="button" class="btn_m search" id="btnSavePop" name="btnSearch">등록</button>      
	                </span>     
                </div>
	            <table class="input_table">
					<div class="grid_area h25 pt0">
	         			<div id="gridList" style="width: 100%; height: 415px;"></div>
	         			<div class="list_paging" id="paging">
	                		<ul class="paging">
	                 			<li><a href="#" id='' class="on"></a>1</li>
	                 		</ul>
	                	</div>
	         		</div>
	            </table>            
	         </div>
        </section>
    </div>
</body>

</html>
 