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
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>

<script>

	var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
	var workMenu 	= "녹취파일삭제분류 등록";
	var workLog 	= "";
	var dataArray = new Array();
	var dataApplyArray = new Array();
	if(loginInfo!=null){	
		var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;	
		var userId      = loginInfo.SVCCOMMONID.rows.userId;
		var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
		var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
		var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
		var convertFlag = loginInfo.SVCCOMMONID.rows.convertFlag;
		var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
		var depth		= loginInfo.SVCCOMMONID.rows.depth;
		var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
		var backupAt	= loginInfo.SVCCOMMONID.rows.backupAt;
	}else{
		var tenantId    = 'bridgetec';	
		var userId      = 'btadmin';
		var grantId     = 'SuperAdmin';
		var workIp      = '127.0.0.1';
		var playerKind  = '0';
		var convertFlag = '1';
		var groupId		= '1';
		var depth		= 'A';
		var controlAuth	= null;
	}
	
    
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
		cudMode = sPopupOptions.cudMode;
		fnInitGrid();
	  	fnInitCtrlPop();
	  	ArgSetting();
	  	fnSearchListCnt();
	});
	
	var cudMode;

	var colDeleteComment = 6;
    var colGubunCode = 7;
    var colDeleteUseFlag = 2;
    var colStorageDay = 3;
    
	function fnInitCtrlPop() {
		$("#btnSavePop").click(function(){
			fnDelGubunUpdate();
		});
		
		$("#btnSearch").click(function (){
			fnSearchListCnt();
		});
		
		$("#btnApply").click(function (){
			fnGubunApply();
		});
		$("#delApply").click(function (){
			var arrChecked = w2ui['gridSeleted'].getSelection();
			$.each(arrChecked, function(index, colIndex) {
				w2ui['gridSeleted'].remove(colIndex);	
			});
		});
	}
	
	function fnDelGubunUpdate(){
		try{
			var arrChecked = w2ui['grid'].getSelection();

			if (arrChecked.length <= 0) {
				argoAlert("분류를 체크해주세요.");
				return false;
			}
			
			$.each(arrChecked, function(index, colIndex) {
				var tmpDeleteComment = w2ui['grid'].getCellValue(colIndex,colDeleteComment);
				var tmpGubunCode = w2ui['grid'].getCellValue(colIndex,colGubunCode);
				var tmpStorageDay = w2ui['grid'].getCellValue(colIndex,colStorageDay);
				var tmpDeleteUseFlag = $("#selDelUseFlag_"+colIndex).val();
				var parm = {"gubunDelDesc": tmpDeleteComment ,"gubunCode": tmpGubunCode ,"gubunData": tmpStorageDay , "gubunDelUseFlag": tmpDeleteUseFlag };
				
				if(tmpDeleteUseFlag == 1){ //기간
// 					argoJsonUpdate("recSearch", "setRecDelGubunDateUpdate" , "ip_", parm );
					argoJsonUpdate("recSearch", "setRecDelGubunDateUpdate" , "ip_", parm );
				}else{ //용량
// 					argoJsonUpdate("recSearch", "getRecDelGubunVolUpdateList" , "ip_", parm );
				}
				argoAlert('warning', '성공적으로 삭제분류 등록 되었습니다..','', 'parent.fnSearchListCnt(); argoPopupClose();');
			});
		}catch(e){
			console.log(e);
		}
	}
	
// 	function fnDelGubunVolListToUpdate(listMethod,UpdateMethod,parm){
// 		argoJsonSearchList('recSearch', listMethod, 's_', parm, function (data, textStatus, jqXHR){ 
// 			if (data.isOk()) {
// 				if (data.getRows() != ""){
// 					dataArray = new Array();
// 					var result = "";
// 					$.each(data.getRows(), function( index, row ) {
// // 						result += "구분 : "+row.gubunName +" 날짜 : " + row.gubunTime +"<br/>";
// 					});
// 					result += "삭제분류를 시작하겠습니까?";
// 					argoConfirm(result, function (){argoJsonUpdate("recSearch", UpdateMethod , "ip_", parm )} );
// 				}else{
// 					argoAlert("삭제할 분류가 없습니다.");
// 				}
// 			}
// 		});
// 	}

	function fnGubunApply(){
		var arrChecked = w2ui['grid'].getSelection();
		var records = w2ui['gridSeleted'].records
		var blankChk = false;
		
		if(arrChecked.length <= 0){
			argoAlert("체크박스를 선택해주세요.");
			return false;
		}
		
		$.each(arrChecked , function(row,colIndex){
			if($("#gridSelectDelFlag"+colIndex).val()=="1" && $("#gridDelStartDate"+colIndex).val() ==""){
				argoAlert("상세요청기간을 등록해주세요.");
				blankChk = true;
			}else if($("#gridSelectDelFlag"+colIndex).val()=="2" && $("#gridDelEndDate"+colIndex).val() ==""){
				argoAlert("상세요청기간을 등록해주세요.");
				blankChk = true;
			}
		});
		$.each(arrChecked , function(row,colIndex){
			var gridRecord = w2ui['grid'].get(colIndex);
			var chk = false;
			for(var i=0;i<records.length;i++){
				if(records[i].gubunCode == gridRecord.gubunCode){
					chk = true;
					break;
				}
			}
			if(!chk && !blankChk ){
				var record = {}; 
				Object.assign(record, gridRecord);
				record.deleteWorkGubunCd = $("#gridSelectDelFlag"+colIndex).val();
				record.deleteWorkGubun = $("#gridSelectDelFlag"+colIndex).val()=="1"?"일":"기간";
				record.delDateDiplay = $("#gridDelStartDate"+colIndex).val() + ($("#gridSelectDelFlag"+colIndex).val()=="1"?"(일)" : " ~ "+  $("#gridDelEndDate"+colIndex).val() +"(기간)");
				record.delDateStartData = $("#gridDelStartDate"+colIndex).val();
				record.delDateEndData =  $("#gridDelEndDate"+colIndex).val();
				w2ui['gridSeleted'].add(record);
			}else if(chk){
				argoAlert("중복 적용건이 존재합니다.<br>제외 후, 다시 적용해주세요.");
				return false;
			};
		});
		w2ui['grid'].refresh();
	}
	
	function ArgSetting() {
		fvCurRow = sPopupOptions.pRowIndex;
		if(cudMode == "U"){
			$("#s_EncKey").val(fvCurRow.encKey);
			$("input:radio[name='s_FindGubun']:input[value='"+fvCurRow.gubun+"']").prop("checked", true);
			$("input:radio[name='s_UseFlag']:input[value='"+fvCurRow.useFlag+"']").prop("checked", true);
			
			$("input:radio[name='s_FindGubun']").attr("disabled", true);
			$("#s_EncKey").attr("disabled", true);
		}
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
	        recordHeight : 30,
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'gubunCode', 		caption: '분류코드', 		size: '7%', 	sortable: true, attr: 'align=center' }
		         	 	,{ field: 'gubunName', 		caption: '분류명', 		size: '7%', 	sortable: true, attr: 'align=center' }
		         	 	,{ field: 'deleteWorkGubun', 		caption: '삭제요청구분', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDate', 		caption: '상제요청기간(일/기간)', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDnNo', 		caption: '삭제요청내선', 		size: '7%', 	sortable: true, attr: 'align=center' , editable: { type: 'text' }}
		         		,{ field: 'insId', 		caption: '작업자', 		size: '10%', 	sortable: true, attr: 'align=center' }
		         		,{ field: 'deletePath', 		caption: '삭제 경로', 		size: '17%', 	sortable: true, attr: 'align=center' }
		         		,{ field: 'deleteComment', 		caption: '사유', 		size: '25s%', 	sortable: true, attr: 'align=center' , editable: { type: 'text' }}
	        ],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid','deleteUseFlag','storageDay','deleteComment');
		
		$('#gridSeleted').w2grid({ 
	        name: 'gridSeleted', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'gubunCode', 		caption: '분류코드', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'gubunName', 		caption: '분류명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'deleteWorkGubunCd', 		caption: '삭제요청구분', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'deleteWorkGubun', 		caption: '삭제요청구분', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDateDiplay', 		caption: '상제요청기간(일/기간)', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDateStartData', 		caption: '상제요청기간(일/기간)', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDateEndData', 		caption: '상제요청기간(일/기간)', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDnNo', 		caption: '삭제요청내선', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'insId', 		caption: '작업자', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'deletePath', 		caption: '삭제 경로', 		size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'deleteComment', 		caption: '사유', 		size: '25s%', 	sortable: true, attr: 'align=center' , editable: { type: 'text' }}
	        ],
	        records: dataApplyArray
	    });
		w2ui['gridSeleted'].hideColumn('recid','delDateStartData','delDateEndData','deleteWorkGubunCd');
	}
	
	function fnSearchListCnt(){
		w2ui.grid.lock('조회중', true);
		argoJsonSearchOne('recSearch', 'getRecFilePathListCnt', 's_', {} , function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1","3","3");
					
					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSelectDelFalgChange(index){
		var delFlag = $("#gridSelectDelFlag"+index).val();
		if(delFlag=="1"){
			$("#gridEndDateForm"+index).hide(); 
		}else{
			$("#gridEndDateForm"+index).show();
		}
	}
	
	function fnDataChange(obj){
		$(obj).val($(obj).val().replace(/[^0-9]/g,""));
	}
	
	function fnSearchList(startRow, endRow){
		var parm = {};
		parm.iSPageNo = startRow;
		parm.iEPageNo = endRow;
		
		argoJsonSearchList('recSearch', 'getRecFilePathList', 's_', parm, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();
					
					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							var gridDelStyle = "border-color: #d3d3d3;"
							    			  +"border-style: solid;"
						    				  +"border-width: 1px;";
							var gridSelDelWork = "<select id='gridSelectDelFlag"+index+"' style='width: 90px;text-align: center;' onchange='fnSelectDelFalgChange("+index+")'>"
													+ "<option value='1'>일</option><option value='2'>기간</option>"
												+"</select>";
							var gridDelStartDate = "<input id='gridDelStartDate"+index+"' onkeyup='this.value=this.value.replace(/[^0-9]/g,\"\");'"
						    						+"style='"+gridDelStyle+"'/>";
							var gridDelEndDate = "<span id='gridEndDateForm"+index+"' style='display:none;' >" 
													+" ~ <input id='gridDelEndDate"+index+"'style='"+gridDelStyle+"' value='' onkeyup='this.value=this.value.replace(/[^0-9]/g,'');'"
													+">" 
													+"</span>";
							
							gObject2 = {  "recid" 			: index
					   					, "gubunName"		: row.gubunName
					   					, "gubunCode"		: row.gubunCode
										, "deleteWorkGubun" 	: gridSelDelWork
										, "delDate" 		: gridDelStartDate+gridDelEndDate
										, "insId" 	: row.insId
										, "deletePath" 	: row.deletePath
										, "deleteComment"	: row.deleteComment
										, "gubunCode" : row.gubunCode 
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
	
// 	function fnSavePop(strEn){
// 		var aValidate = {
// 				rows:[ 
// 				          {"check":"length", "id":"s_EncKey" , "minLength":1, "maxLength":50,  "msgLength":"키를 입력해주세요."}
// 				         ,{"check":"length", "id":"s_FindTenantId"    , "minLength":1, "maxLength":50,  "msgLength":"태넌트를 선택하세요."}
// 				         ,{"check":"length", "id":"s_SystemId" , "minLength":1, "maxLength":50,  "msgLength":"시스템명을  입력하세요."}
// 				         ,{"check":"length", "id":"s_FindProcessCode"  , "minLength":1, "maxLength":50,  "msgLength":"프로세스를 선택하세요."}
// 				         ,{"check":"length", "id":"s_FindGubun"  , "minLength":1, "maxLength":50,  "msgLength":"구분을 선택하세요."}
// 				         ,{"check":"length", "id":"s_UseFlag"  , "minLength":1, "maxLength":50,  "msgLength":"사용여부을 선택하세요."}
// 					]
// 			};
// 		if (argoValidator(aValidate) != true) return;
		
// 		if(cudMode == "I"){
// 				argoConfirm("저장 하시겠습니까?", function(){
// 					argoJsonUpdate("sysInfo", "getLicenseInsert", "s_", {"key":strEn}, function(data, textStatus, jqXHR) {
// 						if(data.isOk()) {
// 							workLog = '[시스템ID:' + data.getRows().systemId + '] 등록';
// 					    	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
// 					    					,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
// 					    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
// 					    }else {
// 					    	argoAlert("저장에 실패하였습니다");	 
// 					    }
// 					});
// 				});
// 		}else{
// 			var fvCurRow = sPopupOptions.pRowIndex;
// 			var licSeq = (cudMode == "U" ? fvCurRow.licSeq:"");			
// 			argoConfirm("저장 하시겠습니까?", function(){
// 				argoJsonUpdate("sysInfo", "getLicenseUpdate", "s_", {"key":strEn,"licSeq":licSeq}, function(data, textStatus, jqXHR) {
// 					if(data.isOk()) {
// 				    	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
// 				    					,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
// 				    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
// 				    	workLog = '[시스템ID:' + argoGetValue('ip_SystemId') + '] 수정';
// 				    }else {
// 				    	argoAlert("저장에 실패하였습니다");	 
// 				    }
// 				});
// 			});
// 		}
		
// 		$(function () {
// 			workLog = '[시스템ID:' + info.systemId + '] 등록';
// 		}else{
// 			Resultdata = argoJsonUpdate("sysInfo", "setSysInfoUpdate", "ip_", {"cudMode":cudMode});
// 			workLog = '[시스템ID:' + argoGetValue('ip_SystemId') + '] 수정';
// 	}

	

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents"> 
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
	            	<div class="sub_l">
		            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
	                </div>
                	<span class="btn_r">
                       	<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>   
                       	<input type="hidden" id="ip_FindSearchType" name="ip_FindSearchType" value="1" >
                    </span>               
                </div>
                <div class="input_area">
                	<table class="input_table">
                		<colgroup>
            				<col width="14%">
                            <col width="26%">
                            <col width="18%">
                            <col width="42%">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>분류코드</th>
                                <td>
                                	<input type="text"	id="s_FindGubunCode" name="s_FindGubunCode" style="width: 270px;"/>
                                </td>
                                <th>분류명</th>
                                <td>
                                	<input type="text"	id="s_FindGubunName" name="s_FindGubunName" style="width: 270px;"/> 
                                	<button type="button" class="btn_m search" id="btnSearch" name="btnSearch">조회</button>  
                                </td>   
							</tr>
						</tbody>
                	</table>
                	<table class="input_table">
                		<div class="btn_topArea">
		                	<div class="sub_l">
				            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
			                </div>
		                	<span class="btn_r">
		                		<button type="button" class="btn_m confirm" id="btnApply" name="btnApply">적용</button>
		                	</span>
	                	</div>
			            <div class="grid_area h25 pt0">
			                <div id="gridList" style="width: 100%; height: 147px;"></div>
			                <div class="list_paging" id="paging">
		                		<ul class="paging">
		                 			<li><a href="#" id='' class="on"></a>1</li>
		                 		</ul>
		                	</div>
		                </div>
                    </table  style="margin-bottom: 25px;">
                	<table class="input_table">
                		<div class="btn_topArea">
		                	<div class="sub_l">
				            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
			                </div>
		                	<span class="btn_r">
		                		<button type="button" class="btn_m confirm" id="delApply" name="delApply">제외</button>
		                	</span>
		                </div>
			            <div class="grid_area h25 pt0">
			                <div id="gridSeleted" style="width: 100%; height: 415px;"></div>
		                </div>
                    </table>
                </div>           
            </div>            
        </section>
    </div>
</body>

</html>
