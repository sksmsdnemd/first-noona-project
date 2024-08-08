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

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "샘플콜등록";
	var workLog 	= "";
	
	var dataArray = new Array();
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	fnInitGrid();
	  	ArgSetting();
	});
	
	var cudMode;
	var markArray;
	var tmpTenantId;
	
	function fnInitCtrlPop() {
		cudMode	  = sPopupOptions.cudMode;
		markArray = sPopupOptions.markArray;
		tmpTenantId = sPopupOptions.tenantId;
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function fnInitGrid(){
		
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true,
	        },
	        multiSelect: true,
	        columns: [  
		            	 { field: 'recid', 			caption: 'recid', 		size: '0px', 	attr: 'align=center' }
		            	,{ field: 'depthPath', 		caption: '분류명', 		size: '50%', 	attr: 'align=left'   }
		            	,{ field: 'groupDesc', 		caption: '설명', 			size: '50%', 	attr: 'align=left'   }
		            	,{ field: 'tenatId', 		caption: 'tenatId', 	size: '0px', 	attr: 'align=center' }
			           	,{ field: 'groupId', 		caption: 'groupId', 	size: '0px', 	attr: 'align=center' }
			           	,{ field: 'groupName', 		caption: 'groupName', 	size: '0px', 	attr: 'align=center' }
			           	,{ field: 'topParentId', 	caption: 'topParentId', size: '0px', 	attr: 'align=center' }
			           	,{ field: 'parentId', 		caption: 'parentId', 	size: '0px', 	attr: 'align=center' }
			           	,{ field: 'depth', 			caption: 'depth', 		size: '0px', 	attr: 'align=center' }
			           	
	        ],
	        records: dataArray
	    });	 
		w2ui['grid'].hideColumn('recid', 'tenatId', 'groupId', 'groupName', 'topParentId', 'parentId', 'depth');
	}
	
	function ArgSetting() {
		
		argoJsonSearchList('recSample', 'getSampleCallGrpList', 's_', {tenantId:tmpTenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						dataArray = [];
						$.each(data.getRows(), function( index, row ) {
							
							gridObject = {  
										  	  "recid" 			: index
				    						, "tenatId" 		: row.tenatId
				    						, "groupId" 		: row.groupId
				    						, "groupName" 		: row.groupName
				    						, "topParentId" 	: row.topParentId
				    						, "parentId" 		: row.parentId
				    						, "depth" 			: row.depth
				    						, "groupDesc" 		: row.groupDesc
				    						, "depthPath" 		: row.depthPath
										};
										
							dataArray.push(gridObject);
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
	
	function fnSavePop(){
		
		var arrChecked = w2ui['grid'].getSelection();
		
		var content    = "";
		var recKey 	   = "";
		var groupId    = "";
		var groupName  = "";
	
	 	if(arrChecked.length == 0) {
	 		argoAlert("분류를 선택하세요") ; 
	 		return ;
	 	}else{
	 		content = argoGetValue("ip_Memo");
	 	}
	
		argoConfirm("저장 하시겠습니까?", function(){
	
			if(cudMode == "I"){
				var multiService = new argoMultiService(fnCallbackSave);
				
		 			$.each(markArray, function( index, row ) {
		 					
		 				$.each(arrChecked, function( idx, value ) {
		 		 			groupId   = w2ui['grid'].getCellValue(value, 4);
		 		 			groupName = w2ui['grid'].getCellValue(value, 5);

		 		 			var param = { 
											"tenantId"	: tmpTenantId,
											"groupId"	: groupId,
											"insId" 	: userId,
											"content" 	: content,
											"recKey" 	: row.recKey,
											/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) START */
											"callId"         : row.callId,
											"custTel"        : row.custTel,
											"dnNo"           : row.dnNo,
											"endTime"        : row.endTime,
											"mediaScr"       : row.mediaScr,
											"mediaVoice"     : row.mediaVoice,
											"mfuIp"          : row.mfuIp,
											"phoneIp"        : row.phoneIp,
											"recTime"        : row.recTime,
											"userId"         : row.userId,
											"uploadCntScr"   : row.uploadCntScr,
											"uploadCntVoice" : row.uploadCntVoice,
											"mediaKind"      : row.mediaKind,
											"fileName"       : row.fileName
											/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) END */
										};
							
							multiService.argoInsert("recSample", "setRecSampleCallInsert", "__", param);
							
							workLog = '[그룹ID:' +  groupId + ' | 그룹명:' + groupName + ' | 녹취키:' + row.recKey + '] 샘플콜등록';
							argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tmpTenantId, userId:userId
											,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
						});
					});
		 			multiService.action();
			}
		});
	}
	
	function fnCallbackSave(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {	  
		    	//argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
		    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCntAfterCallback(); argoPopupClose();');
		    }
		} catch(e) {
			argoAlert(e);    		
		}
	}

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
                	<span class="btn_r">
                       <button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>   
                    </span>               
                </div>
            	<div>
		            <div class="grid_area h25 pt0">
		                <div id="gridList" style="width: 460px; height: 415px;"></div>
		                <br>
		                <div class="input_area" style="width: 460px;">
	                		<table class="input_table">
	                    		<colgroup>
	                        		<col width="50px">
	                            	<col width="400px">
	                        	</colgroup>
	                        	<tbody>
	                        		<tr>
	                            		<th width="50px">메모<span class="point"></span></th>
	                                	<td width="390px">
	                                		<textarea id="ip_Memo" name="ip_Memo" maxlength="50"></textarea>
	                                	</td>
	                            	</tr>
	                        	</tbody>
	                    	</table>
	                	</div>
		            </div>
		    	</div>
	        </div>
        </section>
    </div>
</body>

</html>
