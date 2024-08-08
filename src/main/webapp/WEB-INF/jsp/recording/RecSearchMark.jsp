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
	var workMenu 	= "마킹등록";
	var workLog 	= "";
	
	var dataArray 	= new Array();
	
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
		cudMode   = sPopupOptions.cudMode;
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
	        multiSelect: false,
	        columns: [  
		            	 { field: 'recid', 		caption: 'recid', 	size: '0px', 	attr: 'align=center' }
		            	,{ field: 'markCode', 	caption: '마킹코드', 	size: '120px', 	attr: 'align=center' }
			           	,{ field: 'markCodeNm', caption: '마킹구분',	size: '220px', 	attr: 'align=center' }
	        ],
	        records: dataArray
	    });	 
		w2ui['grid'].hideColumn('recid');
	}
	
	function ArgSetting() {
		
		
		argoJsonSearchList('comboBoxCode', 'getMarkCodeList', 's_', {findTenantId:tmpTenantId}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					
					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
	
							gridObject = {  
											  "recid" 			: index
				    						, "markCode" 		: row.code
				    						, "markCodeNm" 		: row.codeNm
				    						, w2ui				: { "style": "background-color: #" + row.markingColor }
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
		
		var custEtc9  = "";
		var custEtc10 = "";
	
	 	if(arrChecked.length==0) {
	 		argoAlert("마킹구분을 선택하세요") ; 
	 		return ;
	 	}else{
	 		$.each(arrChecked, function( index, value ) {
	 			custEtc9 = w2ui['grid'].getCellValue(value, 1);
			});
	 		
	 		custEtc10 = argoGetValue("ip_Memo");
	 	}
	
		argoConfirm("저장 하시겠습니까?", function(){
	
			if(cudMode == "I"){
				var multiService = new argoMultiService(fnCallbackSave);
					$.each(markArray, function( index, row ) {
						
						var param = { 
										"recKey" 	: row.recKey,
										"callId" 	: row.callId,
										"fmtRecDate" : row.fmtRecDate, 	/** (2023.08.18) TB_REC_FILE 테이블 마킹 등록 작업 (HAGUANGHO) */
										"custEtc9" 	: custEtc9,
										"custEtc10" : custEtc10 								
									};
	
						multiService.argoUpdate("recordFile", "setRecFileMemoUpdate", "__", param);
						
						workLog = '[CallID:' +  row.callId + ' | 녹취키:' + row.recKey + ' | 마킹구분:' + custEtc9 + ' | 메모:' + custEtc10 + '] 등록';
						argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
										,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
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
		                <div id="gridList" style="width: 420px; height: 417px;"></div>
		                <br>
		                <div class="input_area" style="width: 420px;">
	                		<table class="input_table">
	                    		<colgroup>
	                        		<col width="80px">
	                            	<col width="340px">
	                        	</colgroup>
	                        	<tbody>
	                        		<tr>
	                            		<th width="80px">메모<span class="point"></span></th>
	                                	<td width="340px">
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
