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
var workMenu 	= "평가항목관리";
var workLog 	= "";
var dataArray 	= new Array();
var vPartCd		= "";
var vMajorCd	= "";

$(function () {
	// 상단 버튼 이벤트
	$("#btnAddTop").click(function(){fnAdd('T')});
	$("#btnSaveTop").click(function(){fnSaveTop()});
	$("#btnDeleteTop").click(function(){
		fnDeleteTop();
	});
	
	$("#btnAdd01").click(function(){fnAdd('A')});
	$("#btnSave01").click(function(){fnSave01()});
	$("#btnDelete01").click(function(){
		fnDelete01();
	});		
	
		
	$("#btnAdd02").click(function(){fnAdd('B')});
	$("#btnSave02").click(function(){fnSave02()});
	$("#btnDelete02").click(function(){
		fnDelete02();
	});		
	
	
	$(".count_num").countNum({
		max:2100,
		min:2000,
		set_num:argoSetFormat(argoCurrentDateToStr(),"-","4")
	});
	
	fnInitGrid();
	fnSearchCategoryList();
});


function fnInitGrid(){
	$('#grCategoriList').w2grid({ 
        name: 'gridTop', 
        show: {
            lineNumbers: true,
            footer: false
        },
        multiSelect: false,
        reorderRows:true,
        onClick: function(event) {
        	var record = this.get(event.recid);
        	vPartCd = record.codeId
        	fnSearchList01(vPartCd);
        },
        columns: [  
				 	 { field: 'recid', 			caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
        	 		,{ field: 'codeId', 	 	caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
        	 		,{ field: 'codeName', 		caption: '구분', size: '100%', 		editable:{ type:"text" }, sortable: false, attr: 'align=left' }
       	],
        records: dataArray
    });
	w2ui['gridTop'].hideColumn('recid' );
	w2ui['gridTop'].hideColumn('codeId' );
	
	
	$('#grList01').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false
        },
        multiSelect: false,
        reorderRows:true,
        onClick: function(event) {
        	var record = this.get(event.recid);
        	vMajorCd = record.majorCd
        	fnSearchList02(vMajorCd);
        },
        columns: [  
				 	 { field: 'recid', 			caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
        	 		,{ field: 'majorCd', 	 	caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
        	 		,{ field: 'minorCd', 		caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
        	 		,{ field: 'itemNm', 		caption: '대분류명', 	size: '75%', 		editable:{ type:"text" }, sortable: false, attr: 'align=left' }
        	 		,{ field: "hideYn", 		caption: "사용여부", 	size: "80px", 		editable:{ type:"checkbox" } 		 ,sortable: false }
        	 		,{ field: 'sortSeq', 		caption: '', 		size: '0%', 		sortable: true, attr: 'align=centerm', sortable: false }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('majorCd' );
	w2ui['grid'].hideColumn('minorCd' ); 
	w2ui['grid'].hideColumn('sortSeq' );  
	 
	$("#grList02").w2grid({
         name : "grid2"
       , show: {
	         lineNumbers: true,
	         footer: false,
	         selectColumn: true
         }
       , reorderRows:true
       , onChange: function (event) {
	       	var record = this.get(event.recid);
	       	var key = Object.keys(record);
	       	if(key[event.column] == "valueYn"){
	       		event.preventDefault();
	       	}
       },
       
       columns : [               
    	    { field: 'recid', 	 		caption: '', 						size: '0%', 		sortable: false, attr: 'align=center' }
    	    ,{ field: 'majorCd', 	 	caption: '', 						size: '0%', 		sortable: false, attr: 'align=left', editable:{ type:"text" }}
    	    ,{ field: 'minorCd', 	 	caption: '', 						size: '0%', 		sortable: false, attr: 'align=left', editable:{ type:"text" }}
    	    ,{ field: 'itemNm', 	 	caption: '소분류명', 				size: '50%', 		sortable: false, attr: 'align=left', editable:{ type:"text" }}
	 		,{ field: 'hideYn', 		caption: '사용여부', 				size: '80px', 		editable:{ type:"checkbox" }, sortable: false, attr: 'align=center' }
	 		,{ field: 'valueYn', 		caption: '평가표 등록', 				size: '85px', 		editable:{ type:"checkbox" }, sortable: false, attr: 'align=center' }
	 		,{ field: 'sortSeq', 		caption: '', 						size: '0%', 		sortable: false, attr: 'align=center' }
       ]
   	});
	
    w2ui['grid2'].hideColumn('recid' );
    w2ui['grid2'].hideColumn('majorCd' );
    w2ui['grid2'].hideColumn('minorCd' );
	w2ui['grid2'].hideColumn('sortSeq' );
}


function fnSearchCategoryList(){
	argoJsonSearchList('QA', 'SP_QA1020S04_04', 's_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getProcCnt() == 0){
					return;
				}
				w2ui.gridTop.clear();
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
				    				, "codeId"			: row.codeId
				   					, "codeName"	  	: row.codeName
									
									};
						dataArray.push(gObject2);
					});
					w2ui['gridTop'].add(dataArray);
				}
				if(w2ui['gridTop'].getSelection().length == 0){
					w2ui['gridTop'].click(0,0);
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


function fnSearchList01(partCd){
	argoJsonSearchList('QA', 'SP_QA1020S04_01', 's_', {"gbn":"A","majorCd":"","partCd":argoNullConvert(partCd)}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				w2ui.grid2.clear();
				
				if(data.getProcCnt() == 0){
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
				    				, "majorCd"			: row.majorCd
				   					, "minorCd"	  		: row.minorCd
									, "itemNm" 			: row.itemNm
									, "hideYn"			: row.hideYn==0?true:false
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

function fnSearchList02(majorCd){
	if(argoNullConvert(majorCd) == ""){
		w2ui.grid2.clear();
	}
	argoJsonSearchList('QA', 'SP_QA1020S04_01', 's_', {"gbn":"B","majorCd":majorCd,"partCd":vPartCd}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid2.clear();
				if(data.getProcCnt() == 0){
					return;
				}
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
									, "majorCd"			: row.majorCd
									, "minorCd"			: row.minorCd
				    				, "itemNm"			: row.itemNm
				   					, "hideYn"	  		: row.hideYn==0?true:false
									, "valueYn" 		: row.valueYn==1?true:false
									, "sortSeq"			: row.sortSeq
						};
						dataArray.push(gObject2);
					});
					w2ui['grid2'].add(dataArray);
				}
				/* if(w2ui['grid'].getSelection().length == 0){
					w2ui['grid'].click(0,0);
				} */
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
function fnAdd(gbn){
	if(gbn == 'T'){
		w2ui.gridTop.add({
	        recid: w2ui.gridTop.records.length + 1
	    	, codeName: '[입력]'
	    });
		w2ui['gridTop'].click(w2ui.gridTop.records.length,1);
		// 추가버튼 클릭 시 포커스 가장 아래로 이동
		argoScrollToBottom('grCategoriList');
	}else if(gbn == 'A'){
		if(argoNullConvert(vPartCd) == ""){
			argoAlert("등록된 구분을 선택해 주세요.");
			return;
		}
		
		w2ui.grid.add({
	        recid: w2ui.grid.records.length + 1
	    	, itemNm: '[입력]'
	    	, hideYn: true
	    });
		w2ui['grid'].click(w2ui.grid.records.length,1);
		// 추가버튼 클릭 시 포커스 가장 아래로 이동
		argoScrollToBottom('grList01');
	}else if(gbn == 'B'){
		if(argoNullConvert(vPartCd) == ""){
			argoAlert("등록된 구분을 선택해 주세요.");
			return;
		}
		
		if(argoNullConvert(vMajorCd) == ""){
			argoAlert("등록된 대분류를 선택해 주세요.");
			return;
		}
		
		w2ui.grid2.add({
	        recid: w2ui.grid2.records.length + 1
	    	, itemNm: '[입력]'
	    	, hideYn: true
	    });
		w2ui['grid2'].click(w2ui.grid2.records.length,1);
		// 추가버튼 클릭 시 포커스 가장 아래로 이동
		argoScrollToBottom('grList02');
	}else{
		return;
	}
}

//그리드 체크박스로 데이터 삭제
function fnDeleteTop(){
	try{
		
		var arrChecked = w2ui['gridTop'].getSelection();
			if(arrChecked.length==0) {
				argoAlert("삭제할 구분을 선택하세요.") ; 
				return ;
			}
			
		if(w2ui.grid.records.length > 0){
			argoAlert("대분류가 추가 된 건에 대해서는 삭제가 불가능합니다.");
			return;
		} 
		
		$.each(arrChecked, function( index, value ) {
			argoJsonSearchOne("QA", "SP_QA1020S04_06", "__", {code:argoNullConvert(w2ui['gridTop'].get(value).codeId)}, function (Resultdata, textStatus, jqXHR) {
				if (Resultdata.isOk()) {
					if(Resultdata.getRows().length == 0){
						argoConfirm('선택한 구분 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
							var multiService = new argoMultiService(fnCallbackCategoryDelete);
							$.each(arrChecked, function( index, value ) {
								var param = { 
									"cudGubun":"D", 
									"code":argoNullConvert(w2ui['gridTop'].get(value).codeId)
								};
								multiService.argoDelete("QA", "SP_QA1020S04_05", "__", param);
							});
							multiService.action();
					 	});
					}else{
						var itemCnt = Resultdata.getRows()['itemCnt']; 
						var insertTenantNm = Resultdata.getRows()['tenantName'];
						argoAlert("해당 구분은 다른 태넌트에서 대분류가 추가되어 삭제가 불가합니다.<br><br>태넌트:"+insertTenantNm+"<br>"+"건수:"+itemCnt);
						return;
					}
				}
			});
		});
	}catch(e){
		console.log(e) ;	 
	}
}


//그리드 체크박스로 데이터 삭제
function fnDelete01(){
	try{
		
		var arrChecked = w2ui['grid'].getSelection();
	 	if(arrChecked.length==0) {
	 		argoAlert("삭제할 평가항목을 선택하세요.") ; 
	 		return ;
	 	}
	 	
		if(w2ui.grid2.records.length > 0){
			argoAlert("소분류가 추가 된 건에 대해서는 삭제가 불가능합니다.");
			return;
		}
		
		argoConfirm('선택한 평가항목 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
			var multiService = new argoMultiService(fnCallbackDelete);
			$.each(arrChecked, function( index, value ) {
				var param = { 
					"gbn":"A",
					"cudGubun":"D", 
					"majorCd":argoNullConvert(w2ui['grid'].get(value).majorCd)
				};
				multiService.argoDelete("QA", "SP_QA1020S04_02", "__", param);
			});
			multiService.action();
	 	}); 
		
	}catch(e){
		console.log(e) ;	 
	}
}



function fnCallbackCategoryDelete(Resultdata, textStatus, jqXHR) {
	try {
		if (Resultdata.isOk()) {
			workLog = '[평가항목] 삭제';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId ,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			argoAlert('성공적으로 삭제 되었습니다.');
			fnSearchCategoryList();
		}
	} catch (e) {
		argoAlert(e);
	}
}


function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
	try {
		if (Resultdata.isOk()) {
			workLog = '[평가항목] 삭제';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId ,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			argoAlert('성공적으로 삭제 되었습니다.');
			fnSearchList01(vPartCd);
		}
	} catch (e) {
		argoAlert(e);
	}
}


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//그리드 편집내역 저장 (최상위 구분)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
function fnSaveTop(){
  argoConfirm("구분을 적용하시겠습니까?", function(){
  	try{
  		var multiService = new argoMultiService(fnCallbackSaveTop);
  		w2ui.gridTop.records.forEach(function(obj, index) {
  			var param = { 
 					"cudGubun":argoNullConvert(obj.codeId)==""?"C":"U", 
 					"code":argoNullConvert(obj.codeId),
 					"codeName":w2ui.gridTop.getCellValue(index,2),
 					"sortSeq":index
 				};
 				multiService.argoInsert("QA", "SP_QA1020S04_05", "__", param);
  	    });
			multiService.action();
	    }catch(e){
  		console.log(e)
  	}			    						
	});
}	

function fnCallbackSaveTop(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('구분을 성공적으로 저장 하였습니다.');
	    	fnSearchCategoryList();
	    }
	} catch(e) {
		console.log(e);    		
	}
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//그리드 편집내역 저장 (대분류)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
function fnSave01(){
	
	if(w2ui.gridTop.getSelection().length == 0){
		argoAlert("구분 선택 후 대분류를 추가해 주세요.");
		return;
	}
	
	if(vPartCd == ""){
		argoAlert("카테고리 등록완료 후 소분류를 추가해 주세요.");
		return;
	}
	
    argoConfirm("대분류를 적용하시겠습니까?", function(){
    	try{
    		var multiService = new argoMultiService(fnCallbackSave01);
    		w2ui.grid.records.forEach(function(obj, index) {
    			console.log("index : " + index);
    			console.log("obj.itemNm : " + obj.itemNm);
    			var param = { 
   					"gbn":"A",
   					"cudGubun":argoNullConvert(obj.majorCd)==""?"C":"U", 
   					"majorCd":argoNullConvert(obj.majorCd),
   					"minorCd":"00000",
   					"itemNm":argoNullConvert(w2ui.grid.getCellValue(index,3)),
   					"hideYn":argoNullConvert(w2ui.grid.getCellValue(index,4))==true?"0":"1",
   					"sortSeq":index,
   					"partCd":vPartCd
   				};
   				multiService.argoInsert("QA", "SP_QA1020S04_02", "__", param);
    	    });
			multiService.action();
	    }catch(e){
    		console.log(e)
    	}			    						
 	});
}	

function fnCallbackSave01(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('대분류를 성공적으로 저장 하였습니다.');
	    	fnSearchList01(vPartCd);
	    }
	} catch(e) {
		console.log(e);    		
	}
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//그리드 편집내역 저장 (소분류)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
function fnSave02(){
	
	if(w2ui.grid.getSelection().length == 0){
		argoAlert("대분류를 선택 후 소분류를 추가해 주세요.");
		return;
	}
	
	var majorCd = argoNullConvert(w2ui.grid.getCellValue(w2ui.grid.getSelection()[0],1));	
	
	
	
	if(vPartCd == ""){
		argoAlert("카테고리 등록완료 후 소분류를 추가해 주세요.");
		return;
	}
	
	if(majorCd == ""){
		argoAlert("대분류 등록완료 후 소분류를 추가해 주세요.");
		return;
	}
  
	argoConfirm("소분류를 적용하시겠습니까?", function(){
  		var multiService = new argoMultiService(fnCallbackSave02);
		w2ui.grid2.records.forEach(function(obj, index) {
			console.log("argoNullConvert(obj.minorCd) : " + argoNullConvert(obj.minorCd));
			
			var param = { 
				"gbn":"B",
				"cudGubun":argoNullConvert(obj.minorCd)==""?"C":"U", 
				"majorCd":majorCd,
				"minorCd":argoNullConvert(obj.minorCd),
				"itemNm":argoNullConvert(w2ui.grid2.getCellValue(index,3)),
				"hideYn":argoNullConvert(w2ui.grid2.getCellValue(index,4))==true?"0":"1",
				"sortSeq":index,
				"partCd":vPartCd
			};
			multiService.argoInsert("QA", "SP_QA1020S04_02", "__", param);
	    });
		multiService.action();
	});
}	

function fnCallbackSave02(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('소분류를 성공적으로 저장 하였습니다.');
	    	fnSearchList02(argoNullConvert(w2ui.grid.getCellValue(w2ui.grid.getSelection()[0],1)));
	    }
	} catch(e) {
		console.log(e);    		
	}
}

//그리드 체크박스로 데이터 삭제
function fnDelete02(){
	try{
		var majorCd = argoNullConvert(w2ui.grid.getCellValue(w2ui.grid.getSelection()[0],1));	
		var arrChecked = w2ui['grid2'].getSelection();
	 	var flag = true;
		if(arrChecked.length==0) {
	 		argoAlert("삭제할 평가항목을 선택하세요.") ; 
	 		return ;
	 	}
	 	
		$.each(arrChecked, function( index, value ) {
			if(w2ui['grid2'].get(value).valueYn == true){
				flag = false;
				return;
			}
		});
		
		if(flag == false){
			argoAlert("해당 평가항목은<br>평가표에 등록되어 삭제가 불가합니다.");
			return;
		}
		
		argoConfirm('선택한 평가항목 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
			var multiService = new argoMultiService(fnCallbackDelete02);
			$.each(arrChecked, function( index, value ) {
				var param = { 
					"gbn":"B",
					"cudGubun":"D", 
					"majorCd":argoNullConvert(majorCd),
					"minorCd":argoNullConvert(w2ui['grid2'].get(value).minorCd)
				};
				multiService.argoDelete("QA", "SP_QA1020S04_02", "__", param);
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
			workLog = '[평가항목] 삭제';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId ,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			argoAlert('성공적으로 삭제 되었습니다.');
			fnSearchList01(vPartCd);
		}
	} catch (e) {
		argoAlert(e);
	}
}


function fnCallbackDelete02(Resultdata, textStatus, jqXHR) {
	try {
		if (Resultdata.isOk()) {
			workLog = '[평가항목] 삭제';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId ,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			argoAlert('성공적으로 삭제 되었습니다.');
			fnSearchList02(vMajorCd);
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
            <div class="pop_cont h0 pt0">
	            <div style="height: 380px;">        	
	                <div class="per33_l">
	                	<span class="btn_l" style="margin-top: 5px; color: red;">※ 순서변경 방법 : "#" 항목 드래그</span>
	                	<div class="pop_btn">
	                        <span class="btn_r pt5">
	                            <button type="button" id="btnAddTop" class="btn_sm plus" title="추가" style="padding-top: 4.5px;">추가</button>
	                            <button type="button" id="btnSaveTop" class="btn_sm save">저장</button>
	                            <button type="button" id="btnDeleteTop" class="btn_sm delete">삭제</button>
	                        </span>
	                    </div>	
	                    <div class="grid_area h35 pt0" >
	                        <div id="grCategoriList" class="real_grid"></div>
	                    </div>
	                </div>
	                <div class="per33_l">
	                	<span class="btn_l" style="margin-top: 5px; color: red;"> </span>
	                	<div class="pop_btn" style="margin-top:5px;">
	                        <span class="btn_r pt5">
	                            <button type="button" id="btnAdd01" class="btn_sm plus" title="추가" style="padding-top: 4.5px;">추가</button>
	                            <button type="button" id="btnSave01" class="btn_sm save">저장</button>
	                            <button type="button" id="btnDelete01" class="btn_sm delete">삭제</button>
	                        </span>
	                    </div>	
	                    <div class="grid_area h35 pt0" >
	                        <div id="grList01" class="real_grid"></div>
	                    </div>
	                </div>
	                <div class="per33_r">
	                	<span class="btn_l" style="margin-top: 5px; color: red;"> </span>
	                	<div class="pop_btn" style="margin-top:5px;">
	                        <span class="btn_r pt5">
	                            <button type="button" id="btnAdd02" class="btn_sm plus" title="추가" style="padding-top: 4.5px;">추가</button>
	                            <button type="button" id="btnSave02" class="btn_sm save">저장</button>
	                            <button type="button" id="btnDelete02" class="btn_sm delete">삭제</button>
	                        </span>
	                    </div>	
	                    <div class="grid_area h35 pt0" >
	                        <div id="grList02" class="real_grid"></div>
	                    </div>
	                </div>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>
