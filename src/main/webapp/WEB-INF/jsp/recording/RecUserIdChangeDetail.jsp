<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var userId    = loginInfo.SVCCOMMONID.rows.userId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "상담사일괄변경";
	var workLog   = "";
	
	var dataArray = new Array();
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	  	fnInitGrid();
	  	fnSearchList();
	});
	
	function fnInitCtrlPop() {
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		
		var cudMode = sPopupOptions.cudMode;
		fvCurRow 	= sPopupOptions.pRowIndex;
		
		argoSetValues("ip_", fvCurRow);
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
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'recKey', 		caption: 'recKey', 		size: '0%', 	sortable: true, attr: 'align=center' } 
						,{ field: 'tenantId', 		caption: 'tenantId', 	size: '0%', 	sortable: true, attr: 'align=center' } 
						,{ field: 'recTime', 		caption: '통화일자', 		size: '30%', 	sortable: true, attr: 'align=center' }
						,{ field: 'groupId', 		caption: '그룹ID', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'groupName', 		caption: '그룹명', 		size: '20%', 	sortable: true, attr: 'align=center' }
						,{ field: 'dnNo', 			caption: '내선번호', 		size: '15%', 	sortable: true, attr: 'align=center' }
						,{ field: 'callId', 		caption: '콜아이디', 		size: '25%', 	sortable: true, attr: 'align=center' }
						,{ field: 'callKind', 		caption: '통화구분', 		size: '10%', 	sortable: true, attr: 'align=center' }		
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'tenantId', 'recKey', 'groupId');
	}
	
	function fnSearchList(){;
	
		argoJsonSearchList('recordFile', 'getRecFileCallList', 'ip_', {"tenantId":tenantId}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();
					var strCallKind = "";
					if (data.getRows() != ""){
						dataArray = new Array();
						
						$.each(data.getRows(), function( index, row ) {
							if(row.callKind == 1){
								strCallKind = "수신";	
							}else if(row.callKind == 2){
								strCallKind = "발신";
							}else{
								strCallKind = "";
							}
							
							gObject2 = {  "recid" 		: index
										, "recKey"		: row.recKey
					   					, "tnantId"		: row.tnantId
										, "recTime" 	: fnStrMask("DHMS",row.recTime)
										, "dnNo" 		: row.dnNo
										, "groupId" 	: row.groupId
										, "groupName" 	: row.groupName
										, "callId" 		: row.callId
										, "callKind" 	: strCallKind
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
	
	function fnUserSearch(idx){
		
		gPopupOptions = {cudMode:"S", recId:idx};
	 	argoPopupWindow('상담사검색', 'UserSearchPopupF.do', '900', '700');	
	}
	
	function fnAppendOption(idx, userId, userNm){
		
		$("#ip_UserId").val(userId);
		$("#ip_UserName").val(userNm);
	}
	
	function fnSavePop(){
		
		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("일괄변경할 통화를 선택하세요"); 
		 		return ;
			}
			
			var aValidate = {
			        rows:[ 
			       			{"check":"length", "id":"ip_UserId", "minLength":1, "maxLength":50, "msgLength":"상담사을 선택하세요."}
			        	]
			};
			
			if (argoValidator(aValidate) != true) return;
	
			argoConfirm('선택한 통화 ' + arrChecked.length + '건을 일괄변경 하시겠습니까?', function() {
	
				var multiService = new argoMultiService(fnCallbackUpdate);
				
				$.each(arrChecked, function( index, value ) {
					strRecKey = w2ui['grid'].getCellValue(value, 1);
					/** (2023.08.18) 상담사일괄변경상세 일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) START */
					strRecTime = w2ui['grid'].getCellValue(value, 3).substr(0, 10).replace(/-/gi, '');
					/** (2023.08.18) 상담사일괄변경상세 일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) END */
										
					var param = { 
									"recKey" : strRecKey,
									"recTime" : strRecTime /** (2023.08.18) 상담사일괄변경상세 일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) */
								};
	
					multiService.argoUpdate("recordFile", "setRecFileCallUserIdUpdate", "ip_", param);
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		} 
	}
	
	function fnCallbackUpdate(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
	
				workLog = '[내선번호:' + argoGetValue("ip_DnNo") + ' | 변경ID:' + userId + '] 변경';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				
				argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
			}
		} catch (e) {
			argoAlert(e);
		}
	}

</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location" style="width:860px"></div>
		<section class="sub_contents" style="width:860px">
         	<div class="search_area" style="height:50px">
                <div class="row">
                    <ul class="search_terms">
                    	<li style="width:400px">
                    		<strong class="title ml20">상담사</strong>
                            <input type="text"	id="ip_UserId" name="ip_UserId" style="width:115px" readonly/>
                            <input type="text"	id="ip_UserName" name="ip_UserName" style="width:115px" readonly/>
                            <a href="javascript:fnUserSearch(0);"><img src="../images/icon_searchOff.png"></a>
                        </li>
                    </ul>
            	</div> 
            </div>
            <div class="input_area" style="width:860px">
	            <div class="grid_area h25 pt0" >
	                <div id="gridList" style="width: 860px; height: 415px;"></div>
                </div>
	        </div>
        	<div class="btn_areaB txt_r" style="width:860px">
                <button type="button" class="btn_m confirm" id="btnSavePop" data-grant="W">상담사일괄변경</button>                  
				<input type="hidden" id="ip_DnNo" name="ip_DnNo" />
            	<input type="hidden" id="ip_StartDate" name="ip_StartDate" />
            	<input type="hidden" id="ip_EndDate" name="ip_EndDate" />
			</div>
 		</section>
    </div>
</body>

</html>
