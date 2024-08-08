<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script>
//공통 변수 세팅
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "사유코드관리";
var workLog 	= "";
var dataArray 	= new Array();
var vPartCd		= "";
var vMajorCd	= "";

$(function () {
	// 상단 버튼 이벤트
	$("#btnAdd").click(function(){fnAdd()});
	$("#btnSave").click(function(){fnSave()});
	$("#btnDelete").click(function(){
		fnDelete();
	});
		
	fnInitGrid();
	fnSearchList();
});


function fnInitGrid(){
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false
        },
        multiSelect: false,
        reorderRows:true,
        onChange: function (event) {
	       	var record = this.get(event.recid);
	       	var key = Object.keys(record);
	       	if(key[event.column] == "insrYn"){
	       		event.preventDefault();
	       	}
        },
        columns: [  
				 	 { field: 'recid', 			caption: '', 					size: '0%', 		sortable: false, attr: 'align=center' }
        	 		,{ field: 'codeId', 	 	caption: '', 					size: '0%', 		sortable: false, attr: 'align=center' }
        	 		,{ field: 'codeName', 		caption: '구분', 					size: '60%', 		editable:{ type:"text" }, sortable: false, attr: 'align=left' }
        	 		,{ field: 'insrYn', 		caption: '사유 등록여부', 			editable:{ type:"checkbox" },		size: '40%', 		sortable: false, attr: 'align=center' }
       	],
        records: dataArray
    });
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('codeId' );
}


function fnSearchList(){
	argoJsonSearchList('recSearch', 'getRecSearchReasonCodeList', 's_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getProcCnt() == 0){
					return;
				}
				w2ui.grid.clear();
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
				    				, "codeId"			: row.codeId
				   					, "codeName"	  	: row.codeName
				   					, "insrYn"			: row.insrYn=="Y"?true:false
									};
						dataArray.push(gObject2);
					});
					w2ui['grid'].add(dataArray);
				}
				if(w2ui['grid'].getSelection().length == 0){
					w2ui['grid'].click(0,0);
				}
			}
			w2ui.grid.unlock();
		} catch (e) {
			console.log(e);
		}
		
		workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
		+ ' | GrantId:' + grantId + '] 조회';
		argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
			tenantId : tenantId,
			userId : userId,
			actionClass : "action_class",
			actionCode : "W",
			workIp : workIp,
			workMenu : workMenu,
			workLog : workLog
		});
	});
}



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 그리드 행추가 모드
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
function fnAdd(){
	w2ui.grid.add({
        recid: w2ui.grid.records.length + 1
        , codeId : ""
    	, codeName: '[입력]'
    	, insrYn : false
    });
	w2ui['grid'].click(w2ui.grid.records.length,1);
	argoScrollToBottom('grList');
}

//그리드 체크박스로 데이터 삭제
function fnDelete(){
	try{
		
		var arrChecked = w2ui['grid'].getSelection();
		var reasonCode = "";
		var inrtCnt = 0;
	 	if(arrChecked.length==0) {
	 		argoAlert("삭제할 사유코드를 선택하세요.") ; 
	 		return ;
	 	}
	 	
	 	$.each(arrChecked, function( index, value ) {
	 		reasonCode = argoNullConvert(w2ui['grid'].get(value).codeId);
		});
	 	
	 	argoJsonSearchList('recSearch', 'getReasonInsertCnt', 's_', {"reasonCode":reasonCode}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					
					console.log("사유 등록건수 : " + data.getRows()[0].inrtCnt);
					inrtCnt = data.getRows()[0].inrtCnt;
					
					
					/* if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {  "recid" 			: index
					    				, "codeId"			: row.codeId
					   					, "codeName"	  	: row.codeName
					   					, "insrYn"			: row.insrYn
										};
							dataArray.push(gObject2);
						});
					} */
				}
			} catch (e) {
				console.log(e);
			}
		});
	 	
	 	if(inrtCnt != 0){
	 		argoAlert("해당 사유코드는<br>등록된 조회사유가 존재하여 삭제가 불가합니다.");
	 		return;
	 	}else{
	 	
			argoConfirm('선택한 사유코드를 삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				$.each(arrChecked, function( index, value ) {
					var param = { 
						"cudGubun":"D", 
						"code":argoNullConvert(w2ui['grid'].get(value).codeId)
					};
					multiService.argoDelete("recSearch", "SP_REC_SEARCH_REASONCODE_MANAGE", "__", param);
				});
				multiService.action();
		 	}); 
	 	}
		
	}catch(e){
		console.log(e) ;	 
	}
}



function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
	try {
		if (Resultdata.isOk()) {
			workLog = '[사유코드] 삭제';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId ,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			argoAlert('성공적으로 삭제 되었습니다.');
			fnSearchList();
		}
	} catch (e) {
		argoAlert(e);
	}
}



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//그리드 편집내역 저장
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
function fnSave(){
  argoConfirm("사유코드를 적용하시겠습니까?", function(){
  	try{
  		var multiService = new argoMultiService(fnCallbackSave);
  		w2ui.grid.records.forEach(function(obj, index) {
  			var param = { 
 					"cudGubun":argoNullConvert(obj.codeId)==""?"C":"U", 
 					"code":argoNullConvert(obj.codeId),
 					"codeName":w2ui.grid.getCellValue(index,2),
 					"sortSeq":index
 				};
 				multiService.argoInsert("recSearch", "SP_REC_SEARCH_REASONCODE_MANAGE", "__", param);
  	    	});
			multiService.action();
	    }catch(e){
  		console.log(e)
  	}			    						
	});
}	

function fnCallbackSave(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('성공적으로 저장 하였습니다.');
	    	fnSearchList();
	    }
	} catch(e) {
		console.log(e);    		
	}
}
</script>
 
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt0">
	            <div style="height: 380px;">        	
	                <div class="per33_l" style="width: 100%">
	                	<span class="btn_l" style="margin-top: 5px; color: red;">※ 순서변경 방법 : "#" 항목 드래그</span>
	                	<div class="pop_btn">
	                        <span class="btn_r pt5">
	                            <button type="button" id="btnAdd" class="btn_sm plus" title="추가" style="padding-top: 4.5px;">추가</button>
	                            <button type="button" id="btnSave" class="btn_sm save">저장</button>
	                            <button type="button" id="btnDelete" class="btn_sm delete">삭제</button>
	                        </span>
	                    </div>	
	                    <div class="grid_area h35 pt0" >
	                        <div id="grList" class="real_grid"></div>
	                    </div>
	                </div>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>
