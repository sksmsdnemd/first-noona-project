<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
	String recTableType = Globals.REC_TABLE_TYPE(); 
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<style type="text/css">
#grid_grid2_frecords{
	top: 56px !important;
}

#grid_grid2_records{
	top: 56px !important;
	overflow: hidden;
}
</style>

<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<script type="text/javascript">
var recTableType = '<%=recTableType%>';
console.log("recTableType : " + recTableType);

var fvValueCnt=0;
var fvValueCnt2=0;
var fvTimesId='', fvAgentId, fvAgentNm;
var fvLoginId='';
var fvQaaId, fvQaaNm, fvValueYn, fvTimesNm;
var fvAgentId, fvAgentNm, fvValueYn;
var fvTimesFrmRecDt = "";
var fvTimesEndRecDt = "";
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var userName    = loginInfo.SVCCOMMONID.rows.userName;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "통화품질평가-배정인원조회";
var workLog 	= "";
var dataArray 	= new Array();


$(document).ready(function() {
	top.windowStepFlag = false;
	top.windowStepVal = ""; 
	fvLoginId = userId;
	fnInitCtrl();
	fnInitGrid();
	fnInitGrid2(0);
	fnShowTooltip();
	fnAutoSearch();
	fnSearchList();
});

function fnInitCtrl(){
	
	$("#btn_Step2").click(function(){
		fnPageMove();
	})
	
	$("#btn_Search").click(function(){
		fnSearchList();
	})
	
	$("#btnQaa").click(function(){
		fnUserChoice();		
	})

	$("#s_QaaNm").keyup(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13)
 		 	fnUserChoice();
 		 }
	});
	
	$("#btn_Times").click(function(){
		fnTimesChoice();		
	})
	
	var sStdMonth = argoSetFormat(argoCurrentDateToStr(),"-","4-2") ;
	argoSetValue('s_StdMonth', sStdMonth) ;
	
	// 평가자 자동 셋팅 추가
	argoSetValue('s_QaaNm',userName);
	argoSetValue('s_QaaId',userId);
	
	$(".yearMonth_date").dateSelect();
	
	$("#btnExcel").click(function(){
		var tableNm = argoRecDynimicTable(fvTimesFrmRecDt.substr(0,6), fvTimesEndRecDt.substr(0,6), recTableType);
		var excelArray = new Array();
		argoJsonSearchList('QA', 'SP_QA2010M01_02', '__', {timesId:fvTimesId, qaaId:fvQaaId, tableNm:tableNm}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					$.each(data.getRows(), function( index, row ) {
						gObject = {  "순번" 			: index
									, "소속"			: row.deptInfo
				   					, "사번"	  		: row.sabun
									, "상담사명" 		: row.agentNm						
									};
						if(row.recordId != null){
							var recordIds 			= argoNullConvert(row.recordId).split("||");
							var recordTimes 		= argoNullConvert(row.recordTime).split("||");
							var scores 				= argoNullConvert(row.score).split("||");
							var qaValueStatuss 		= argoNullConvert(row.qaValueStatus).split("||");
							var totalComments 		= argoNullConvert(row.totalComment).split("||");
							for (var i=1; i<recordIds.length+1; i++) {
								gObject[i+"차_" + "녹취시간"] = argoNullConvert(recordTimes[i-1]);
								gObject[i+"차_" + "점수"] = argoNullConvert(scores[i-1]);
								gObject[i+"차_" + "진행상태"] = argoNullConvert(qaValueStatuss[i-1]);
								gObject[i+"차_" + "의견"] = argoNullConvert(totalComments[i-1]);
							}	
						}
						excelArray.push(gObject);
					});
					gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
					argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
					workLog = '[TenantId:'
						+ tenantId
						+ ' | UserId:' + userId
						+ ' | GrantId:'
						+ grantId
						+ '] Excel Export';
					
					
					argoJsonUpdate(
						"actionLog",
						"setActionLogInsert",
						"ip_",
						{
							tenantId : tenantId,
							userId : userId,
							actionClass : "action_class",
							actionCode : "W",
							workIp : workIp,
							workMenu : workMenu,
							workLog : workLog
						});
				}
			} catch (e) {
				console.log(e);
			}
		});
	});	
	
	
}

function fnUserChoice(){
	
	var timesId = argoGetValue("#s_TimesId").replace(/,/gi,'\',\'');
		
	oOptions = {"targetObj" : "s_Qaa","multiYn" : 'Y'};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
    $("#s_QaaNm").focusout(function(){
 		if($("#s_QaaNm").val().trim()=='')  $("#s_QaaId").val('') ;
	});	
    
	oOptions['searchKey'] = argoGetValue("s_QaaNm");
	gPopupOptions = oOptions;	
	argoPopupWindow('사용자 선택', gGlobal.ROOT_PATH+'/common/UserChoice03F.do', '900', '600');
	
}

function fnTimesChoice(){
	oOptions = {"targetObj" : "s_Times","multiYn" : 'Y', "stdMonth" : argoGetValue("s_StdMonth").replace("-", "")};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    gPopupOptions = oOptions;
    
    $("#s_TimesNm").focusout(function(){
 		if($("#s_TimesNm").val().trim()=='')  $("#s_TimesId").val('') ;
	});	
    argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/QaTimesChoiceF.do', '900', '600');
}

function fnInitGrid(){
	$("#grList1").w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false
        },
        multiSelect: false,
        onClick: function(event) {
        	var record = this.get(event.recid);
        	fvValueCnt2 = record.valueCnt2;
        	fvTimesId 	= record.timesId;
        	fvTimesNm 	= record.timesNm
        	fvQaaId 	= record.qaaId;
        	fvQaaNm 	= record.qaaNm;
	  		fvValueCnt 	= record.valueCnt;
	  		
	  		fvTimesFrmRecDt = record.recFrmDt;
	  		fvTimesEndRecDt = record.recEndDt;
	  		
	  		fnInitGrid2(fvValueCnt2);
	  		fnSearchList2(fvValueCnt2, fvTimesId, fvQaaId);
        }, 
        columns: [  
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'timesId', 	 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'timesNm', 	 	caption: '평가계획', 		size: '20%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'qaaId', 			caption: '평가자 사번', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'qaaNm', 			caption: '평가자명', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentCnt', 		caption: '배정인원', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'valueCnt', 		caption: '평가건수', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'valueCnt2', 		caption: '평가횟수', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'progress', 		caption: '진행율(%)', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'achievement', 	caption: '평가잔여일', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'avgScore', 	    caption: '평균점수', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'maxScore', 	    caption: '최고점수', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'minScore', 	    caption: '최저점수', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'saveCnt', 	    caption: '저장', 			size: '10%', 	sortable: true, attr: 'align=center' }
       			,{ field: 'seunginCnt', 	caption: '승인', 			size: '10%', 	sortable: true, attr: 'align=center' }
       			,{ field: 'recFrmDt', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       			,{ field: 'recEndDt', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('timesId' );
	w2ui['grid'].hideColumn('recFrmDt' );
	w2ui['grid'].hideColumn('recEndDt' );
	w2ui['grid'].hideColumn('agentCnt' );
	w2ui['grid'].hideColumn('valueCnt' );
	w2ui['grid'].hideColumn('valueCnt2' );
	w2ui['grid'].hideColumn('progress' );
}

function fnInitGrid2(valueCnt){
	var columnGroups = [
		{ caption:"", master:true },
		{ caption:"", master:true },
		{ caption:"", master:true },
		{ caption:"배정인원정보", span:3 }
		/* { caption:"배정인원정보", span:4 } */
	];
	
	var columns = [
		{ field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center', hidden: true, frozen: true}
		,{ field: 'qaProgress', 	caption: '타인평가여부', 	size: '100px', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center', frozen: true }
		,{ field: 'notmeQaaId', 	caption: '타인평가자명', 		size: '100px', 	sortable: true, attr: 'align=center', frozen: true }
		,{ field: 'deptInfo', 		caption: '소속', 			size: '150px', 	sortable: true, attr: 'align=left', frozen: true }
		,{ field: 'sabun', 			caption: '사번', 			size: '90px', 	sortable: true, attr: 'align=center', frozen: true }
		,{ field: 'agentNm', 		caption: '상담사명', 		size: '90px', 	sortable: true, attr: 'align=center', frozen: true }
	];
	
	for(var i=1; i<Number(valueCnt)+1; i++){
		columnGroups.push({caption:i+"차평가", span:6});
		columns.push({ field: "recordId"+i, 		caption: 'recordId', 	size: '0%', 	sortable: true, attr: 'align=center' ,hidden: true  });
		columns.push({ field: "recordTime"+i, 		caption: '녹취시간', 		size: '180px', 	sortable: true, attr: 'align=center' });
		columns.push({ field: "score"+i, 			caption: '점수', 			size: '70px', 	sortable: true, attr: 'align=center' });
		columns.push({ field: "qaValueStatus"+i, 	caption: '진행상태', 		size: '80px', 	sortable: true, attr: 'align=center' });
		columns.push({ field: "totalComment"+i, 	caption: '의견', 		 	size: '100px', 	sortable: true, attr: 'align=center' });
		columns.push({ field: "sheetkey"+i, 		caption: 'sheetkey', 	size: '0%', 	sortable: true, attr: 'align=center' ,hidden: true });
	}
	
	if(typeof(w2ui['grid2']) != "undefined" && w2ui['grid2'] !=null){
		w2ui['grid2'].columnGroups = columnGroups;
		w2ui['grid2'].columns = columns;
		w2ui['grid2'].reset();
	}else{
		dataArray = [];
		$("#grList2").w2grid({ 
	        name: 'grid2', 
	        show: {
	            lineNumbers: false,
	            footer: false,
	            selectColumn: false
	        },
	        columnGroups : columnGroups,
	        multiSelect: false,
	        onClick: function(event) {
	        	var record = this.get(event.recid);
	        	fvAgentId = record.sabun;
	        	fvAgentNm = record.agentNm;
	        	//fvQaProgress = record.qaProgress;
	        	//fvNotmeQaaId = record.notmeQaaId;
	        },  
	        onChange: function (event) {
	        	// 20230625 jslee 수정대상여부 추출하기 위해 컬럼의 정보를 json형태로 추출 {fieid:caption} 형태로 추출됨.
	        	var record = this.get(event.recid);
	        	// 20230625 jslee json의 컬럼값만 추출
	        	var key = Object.keys(record);
	        	// 20230625 jslee json의 키값에 해당하는 값이 컬럼의 인덱스와 일치할 시 이벤트 취소.
	        	if(key[event.column] == "qaProgress"){
	        		event.preventDefault();
	        	}
	        },
	        columns: columns,
	        records: dataArray
	    });
	}
}

function fnSearchList2(valueCnt, timesId, qaaId){
	var tableNm = argoRecDynimicTable(fvTimesFrmRecDt.substr(0,6), fvTimesEndRecDt.substr(0,6), recTableType);
	argoJsonSearchList('QA', 'SP_QA2010M01_02', '__', {timesId:timesId, qaaId:qaaId, tableNm:tableNm}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid2.clear();
				
				if(data.getProcCnt() == 0){
					fvAgentId = "";
		        	fvAgentNm = "";
					return;
				}
				
				dataArray = [];
				w2ui['grid2'].add(dataArray);
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						var color = row.qaProgress=='Y'?"#FFBFC0":"";
						gObject2 = {  "recid" 			: index
									, "qaProgress"		: row.qaProgress=='Y'?true:false
									, "notmeQaaId"		: row.notmeQaaId
									, "deptInfo"		: row.deptInfo
				   					, "sabun"	  		: row.sabun
									, "agentNm" 		: row.agentNm		
									, "w2ui": { "style": "background-color: " + color }
									};
						
						if(row.recordId != null){
							var recordIds = row.recordId.split("||");
							for (var i=1; i<recordIds.length+1; i++) {
								  gObject2["recordId"+i] = recordIds[i-1];
							}	
						}
						
						if(row.recordTime != null){
							var recordTimes = row.recordTime.split("||");
							for (var i=1; i<recordTimes.length+1; i++) {
								  gObject2["recordTime"+i] = recordTimes[i-1];
							}
						}			
						
						if(row.score != null){
							var scores = row.score.split("||");
							for (var i=1; i<scores.length+1; i++) {
								  gObject2["score"+i] = scores[i-1];
							}
						}
						
						if(row.qaValueStatus != null){
							var qaValueStatuss = row.qaValueStatus.split("||");
							var sheetkeys = row.sheetkey.split("||");
							for (var i=1; i<qaValueStatuss.length+1; i++) {
								if(qaValueStatuss[i-1] == "완료"){
									gObject2["qaValueStatus"+i] = '<span style="color: #2080D0; font-weight: bold;">' + qaValueStatuss[i-1] + '</span>';	
								}else{
									gObject2["qaValueStatus"+i] = '<span style="color: #008000; font-weight: bold;">' + qaValueStatuss[i-1] + '</span>';
								}
							}
						}
						
						if(row.recordId != null){
							var recordIds = row.recordId.split("||");
							for (var i=1; i<recordIds.length+1; i++) {
								  gObject2["recordId"+i] = recordIds[i-1];
							}	
						}
						
						var sabun = "'" + argoNullConvert(row.sabun) + "'";
						var agentNm = "'" + argoNullConvert(row.agentNm) + "'";
						var qaProgress = "'" + argoNullConvert(row.qaProgress) + "'";
						var notmeQaaId = "'" + argoNullConvert(row.notmeQaaId) + "'";
						
						for(var i=1; i<valueCnt+1; i++){
							var recordId = "''";
							var sheetkey = "''";
							
							if(row.recordId != null){
								var recordIds = row.recordId.split("||");
								recordId = "'" + argoNullConvert(recordIds[i-1]) + "'";
							}
							if(row.sheetkey != null){
								var sheetkeys = row.sheetkey.split("||");
								sheetkey = "'" + argoNullConvert(sheetkeys[i-1]) + "'";
							}
							
							gObject2["qaValueStatus"+i] = argoNullConvert(gObject2["qaValueStatus"+i]) + '<img src="../images/bg_approval.png" style="width:20px; height:20px; cursor:pointer;" onclick="fnPageMoveIcon('+sabun+', '+agentNm+', '+sheetkey+', '+recordId+', '+qaProgress+', '+notmeQaaId+')"></img>';
						}
						
						
						if(row.totalComment != null){
							var totalComments = row.totalComment.split("||");
							for (var i=1; i<totalComments.length+1; i++) {
								  gObject2["totalComment"+i] = totalComments[i-1];
							}
						}
						
						if(row.sheetkey != null){
							var sheetkeys = row.sheetkey.split("||");
							for (var i=1; i<sheetkeys.length+1; i++) {
								  gObject2["sheetkey"+i] = sheetkeys[i-1];
							}
						}
						
						dataArray.push(gObject2);
					});
					w2ui['grid2'].add(dataArray);
				}
				/* if(w2ui['grid2'].getSelection().length == 0){
					w2ui['grid2'].click(0,0);
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

function fnShowTooltip(){
	$(".tooltip_l").tooltip({
		position: {
			my: "left top",
			at: "right+5 top+13",
			collision: "none"
		}
	});

	$(".tooltip_r").tooltip({
		position: {
			my: "right top",
			at: "left+10 top+13",
			collision: "none"
		}
	});

	//Step 툴팁 자동실행
	$(".btn_stepPrev ").trigger("mouseover").addClass("on");
	$(".btn_stepNext ").trigger("mouseover").addClass("on");
	
	setTimeout(function(){
		$(".btn_stepPrev ").trigger("mouseout").removeClass("on");
		$(".btn_stepNext ").trigger("mouseout").removeClass("on");
	}, 1500);
}

function fnPageMove(sheetkey, recordId){
	var index = 0;//gridView1.getCurrent().itemIndex;
	var index2 = 0;//gridView2.getCurrent().itemIndex;
	var timesId = fvTimesId; 
	var agentId = fvAgentId;
	var agentNm = fvAgentNm;
	var qaaId = fvQaaId;
	var disable = false;
	// 검색 조건
	var sTimesId = fvTimesId;
	var sTimesNm = fvTimesNm;
	var sQaaId = fvQaaId;
	var sQaaNm = fvQaaNm;
	
	if(argoNullConvert(agentId)==""){
 		argoAlert("평가건을 선택하여 주세요.");
 		return ;
 	}
	
	if(qaaId!=fvLoginId){
		disable = true;
	}
	
	var param;
	var url;
	if(argoNullConvert(sheetkey)==""){
		param = {'timesId':timesId ,'agentId':agentId ,'agentNm':agentNm ,'currIndex': index ,'disable' : disable
				,'sQaaId':sQaaId ,'sQaaNm':sQaaNm ,'sTimesId':sTimesId ,'sTimesNm':sTimesNm  //검색 조건
				};
		url = "QA2010M02F.do";
	}else{
		param = {"recordId":recordId ,"timesId" : timesId ,"agentId" : agentId ,"sheetkey" : sheetkey ,"agentNm" : agentNm,"currIndex" : index, "disable" : disable
				,"sTimesId" : sTimesId ,"sTimesNm" : sTimesNm, "sQaaId" : sQaaId ,"sQaaNm" : sQaaNm ,"sTimesNm" : sTimesNm
				};
 		url ='QA2010M03F.do';
	}
 	fnDynamicForm(param,url);
}


function fnPageMoveIcon(agentId, agentNm, sheetkey, recordId, qaProgress, notmeQaaId){
	if(qaProgress == "Y"){
		argoAlert("해당 상담사는 다른QAA가 평가하여 진행이 불가능합니다.<br><br>평가자 : " + notmeQaaId);
		return;
	}
	
	var index = 0;
	var index2 = 0;
	var timesId = fvTimesId; 
	var agentId = agentId;
	var agentNm = agentNm;
	var qaaId = fvQaaId;
	var disable = false;
	// 검색 조건
	var sTimesId = fvTimesId;
	var sTimesNm = fvTimesNm;
	var sQaaId = fvQaaId;
	var sQaaNm = fvQaaNm;
	
	if(argoNullConvert(agentId)==""){
 		argoAlert("평가건을 선택하여 주세요.");
 		return ;
 	}
	
	if(qaaId!=fvLoginId){
		disable = true;
	}
	
	var param;
	var url;
	if(argoNullConvert(sheetkey)==""){
		param = {'timesId':timesId ,'agentId':agentId ,'agentNm':agentNm ,'currIndex': index ,'disable' : disable
				,'sQaaId':sQaaId ,'sQaaNm':sQaaNm ,'sTimesId':sTimesId ,'sTimesNm':sTimesNm  //검색 조건
				};
		url = "QA2010M02F.do";
	}else{
		param = {"recordId":recordId ,"timesId" : timesId ,"agentId" : agentId ,"sheetkey" : sheetkey ,"agentNm" : agentNm,"currIndex" : index, "disable" : disable
				,"sTimesId" : sTimesId ,"sTimesNm" : sTimesNm, "sQaaId" : sQaaId ,"sQaaNm" : sQaaNm ,"sTimesNm" : sTimesNm
				};
 		url ='QA2010M03F.do';
	}
 	fnDynamicForm(param,url);
}


function fnSearchList(index){
	try{
		argoJsonSearchList('QA', 'SP_QA2010M01_01', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if(data.getProcCnt() == 0){
						fvValueCnt2 = "";
			        	fvTimesId 	= "";
			        	fvTimesNm 	= "";
			        	fvQaaId 	= "";
			        	fvQaaNm 	= "";
				  		fvValueCnt 	= "";
						fvAgentId 	= "";
				        fvAgentNm 	= "";
						w2ui.grid2.clear();
						fnInitGrid2(0);
						return;
					}
					
					dataArray = [];
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {
								"recid" 			: index
			    				, "timesId"			: row.timesId
			   					, "timesNm"	  		: row.timesNm
								, "qaaId" 			: row.qaaId
								, "qaaNm"	  		: row.qaaNm
								, "agentCnt" 		: row.agentCnt
								, "valueCnt" 		: row.valueCnt
								, "valueCnt2"		: row.valueCnt2
								, "progress"		: row.progress
								, "achievement" 	: row.achievement										
								, "avgScore" 		: row.avgScore	
								, "maxScore"	  	: row.maxScore
								, "minScore" 		: row.minScore
								, "saveCnt" 		: row.saveCnt
								, "seunginCnt"		: row.seunginCnt
								, "recFrmDt"		: row.recFrmDt
								, "recEndDt"		: row.recEndDt
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
		
	}catch(e){
		console.log(e)
	}
}


function fnAutoSearch(){
	if(argoGetValue("searchYn")==1){
		fvTimesId = 	argoGetValue("timesId");
		fvTimesNm = 	argoGetValue("timesNm");
		sQaaId = 		argoGetValue("sQaaId");
		sQaaNm = 		argoGetValue("sQaaNm");
		sCurrIndex = 	argoGetValue("currIndex");
		sTimesId = 		argoGetValue("sTimesId");
		sTimesNm = 		argoGetValue("sTimesNm");
		argoSetValue("s_TimesId", sTimesId);
		argoSetValue("s_TimesNm", sTimesNm);
		argoSetValue("s_StdMonth", fvTimesId.substring(0,4)+"-"+fvTimesId.substring(4,6));
		argoSetValue("s_QaaId", sQaaId);
		argoSetValue("s_QaaNm", sQaaNm);
		fnSearchList(sCurrIndex);
	}
}
</script>
<style>
#step2{
	cursor: pointer;
}
</style>
</head>
<body>
	<div class="sub_wrap">
		<div class="location">
			<span class="location_home">HOME</span><span class="step">통화품질(QA)</span>
			<span class="step">통화품질평가</span><strong class="step">배정인원 조회</strong>
		</div>
		<section class="sub_contents">
			<div class="step_area">
				<a href="#" class="btn_stepNext tooltip_r" title="녹음파일 조회"
					id="btn_Step2">녹음파일 조회</a>
				<div class="step_view step3">
					<ul>
						<li class="on">
							<em class="num">1</em>
							<p class="step">STEP 01</p>
							<p class="title">배정인원 조회</p>
						</li>
						<li id="step2" onclick="fnPageMove()">
							<em class="num">2</em>
							<p class="step">STEP 02</p>
							<p class="title">녹음파일 조회</p>
						</li>
						<li>
							<em class="num">3</em>
							<p class="step">STEP 03</p>
							<p class="title">통화품질평가</p>
						</li>
					</ul>
				</div>
			</div>
			<div class="search_area top_br fix_h54">
				<div class="row">
					<ul class="search_terms">
					<li>
						<strong class="title ml20">기준년월</strong>
						<span class="yearMonth_date" id="d1"><input type="text" id="s_StdMonth" name="s_StdMonth" placeholder="년 - 월" class="input_ym onlyDate"><a href="#" class="btn_calendar">년/월 선택</a></span>
					</li>
						<li>
							<strong class="title">평가계획</strong> 
							<input type="text" id="s_TimesNm" name="s_TimesNm" style="width: 300px;"><button class="btn_termsSearch" id="btn_Times">검색</button>
							<input type="hidden" id="s_TimesId" name="s_TimesId">
						</li>
						
						<li>
							<strong class="title">평가자</strong>
							<input type="text" id="s_QaaNm" name="s_QaaNm" style="width: 300px;"><button class="btn_termsSearch" id="btnQaa">검색</button>
							<input type="hidden" id="s_QaaId" name="s_QaaId">
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<div class="btns_tl">
					<button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
				</div>
				<button type="button" class="btn_m search" id="btn_Search" data-grant="R">조회</button>
			</div>
			<div class="h191">
				<div class="half23">
					<div class="btn_topArea fix_h25"></div>
					<div class="grid_area h25 pt0">
						<div id="grList1" class="real_grid"></div>
						<input type="hidden" id="searchYn" name="searchYn" value="<c:out value="${searchYn}"/>">
						<input type="hidden" id="timesId" name="timesId" value="<c:out value="${timesId}"/>">
						<input type="hidden" id="timesNm" name="timesNm" value="<c:out value="${timesNm}"/>">
						<input type="hidden" id="sTimesId" name="sTimesId" value="<c:out value="${sTimesId}"/>">
						<input type="hidden" id="sTimesNm" name="sTimesNm" value="<c:out value="${sTimesNm}"/>">
						<input type="hidden" id="sQaaId" name="sQaaId" value="<c:out value="${sQaaId}"/>">
						<input type="hidden" id="sQaaNm" name="sQaaNm" value="<c:out value="${sQaaNm}"/>">
						<input type="hidden" id="currIndex" name="currIndex" value="<c:out value="${currIndex}"/>">
					</div>
				</div>
				<div class="half77">
					<div class="btn_topArea fix_h25"></div>
					<div class="grid_area h25 pt0">
						<div id="grList2" class="real_grid"></div>
					</div>
				</div>
			</div>
			
			<form name="form1" method="POST">
				<input type="hidden" name="sheetKey"/>
				<input type="hidden" name="notiYn"/>
				<input type="hidden" name="confirmYn"/>				
			</form>
		</section>
	</div>
</body>
</html>