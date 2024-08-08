<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<style type="text/css">
#grid_grid_column_1{
	height: 55px;
}
</style> 
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<script type="text/javascript">
//공통 변수 세팅
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가항목별 보고서";
var workLog 	= "";
var dataArray 	= new Array();

$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
});
 
function fnInitCtrl(){
	argoSetDeptChoice("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); //조직선택 팝업 연결처리(멀티)
	argoSetUserChoice01("btn_User1", {"targetObj":"s_User1", "multiYn":'Y'}); //상담사선택 팝업 연결처리(멀티)
	argoCbCreate("#s_QaValueStatus", "ARGOCOMMON", "SP_UC_GET_CMCODE_01", {sort_cd : 'QA_VALUE_STATUS'}, {"selectIndex" : 2,"text" : '<전체>',"value" : ''}); // 진행상태
	
	$("#btn_Search").click(function(){
		fnSearchList();		
	});
    
	$("#btn_Times").click(function(){
		fnTimesChoice();		
	});
	
	$("#btnExcel").click(function(){
		argoGridExlConvert(w2ui['grid'], workMenu);
	});	
}

function fnInitGrid(){
	var columnGroups = [
		{ caption:"", master:true}
		,{ caption:"", master:true}
		,{ caption:"", master:true}
		,{ caption:"", master:true}
		,{ caption:"", master:true}
		,{ caption:"", master:true}
	];
	
	var columns = [
		{ field: 'recid', 				caption: '', 			size: '0%', 	sortable: true, attr: 'align=center', hidden: true }
		,{ field: 'team', 				caption: '소속', 			size: '10%', 	sortable: true, attr: 'align=left' }
		,{ field: 'sabun', 				caption: '사번', 			size: '7%', 	sortable: true, attr: 'align=center' }
		,{ field: 'agentNm', 			caption: '상담사명', 		size: '7%', 	sortable: true, attr: 'align=center' }
		,{ field: 'totalScore', 		caption: '총점', 			size: '5%', 	sortable: true, attr: 'align=center' }
		,{ field: 'rank', 				caption: '순위', 			size: '5%', 	sortable: true, attr: 'align=center' }
	];
	
	if(typeof(w2ui['grid']) != "undefined" && w2ui['grid'] !=null){
		w2ui['grid'].columnGroups = columnGroups;
		w2ui['grid'].columns = columns;
		w2ui['grid'].reset();
	}else{
		dataArray = [];
		$("#grList").w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: false,
	            footer: true,
	            selectColumn: false
	        },
	        columnGroups : columnGroups,
	        multiSelect: false,
	        onClick: function(event) {
	        	var record = this.get(event.recid);
	        	fvAgentId = record.sabun;
	        	fvAgentNm = record.agentNm;
	        },  
	        columns: columns,
	        records: dataArray
	    });
	}  
}


function fnExcelDynamicHeader(){
	var multiService = new argoMultiService(fnCallbackExcelDynamicMakeHeader);
	multiService.argoList("QA", "SP_QA4030M01_03", "s_", {sortCd:"MAJOR_CD"}) // 대분류(점수)
		        .argoList("QA", "SP_QA4030M01_03", "s_", {sortCd:"MINOR_CD"});// 소분류 (점수)			
	multiService.action();
}

function fnCallbackExcelDynamicMakeHeader(data, textStatus, jqXHR) {
	try{
		if(data.isOk()){
	    	var gridDynimicHeader1 = data.getRows(0);
	    	var gridDynimicHeader2 = data.getRows(1);
	    	
	    	if(argoGetValue("s_ViewGubun") == "P"){
	    		var columnGroups = [
	    			{ caption:"", master:true}
	    			,{ caption:"", master:true}
	    			,{ caption:"", master:true}
	    			,{ caption:"", master:true}
		    		,{ caption:"", master:true}
		    		,{ caption:"", master:true}
		    	];
		    	
		    	var columns = [
		    		{ field: 'recid', 				caption: '', 			size: '0px', 	sortable: true, attr: 'align=center', hidden: true }
		    		,{ field: 'team', 				caption: '소속', 			size: '150px', 	sortable: true, attr: 'align=left' , frozen: true}
		    		,{ field: 'sabun', 				caption: '사번', 			size: '80px', 	sortable: true, attr: 'align=center' , frozen: true}
		    		,{ field: 'agentNm', 			caption: '상담사명', 		size: '80px', 	sortable: true, attr: 'align=center' , frozen: true}
		    		,{ field: 'totalScore', 		caption: '총점', 			size: '50px', 	sortable: true, attr: 'align=center' , frozen: true}
		    		,{ field: 'rank', 				caption: '순위', 			size: '50px', 	sortable: true, attr: 'align=center' , frozen: true}
		    	];
	    	}else{
	    		var columnGroups = [
		    		{ caption:"", master:true }
		    		,{ caption:"", master:true }
		    		,{ caption:"", master:true }
		    		,{ caption:"", master:true }
		    	];
		    	
		    	var columns = [
		    		{ field: 'recid', 				caption: '', 			size: '0px', 	sortable: true, attr: 'align=center', hidden: true }
		    		,{ field: 'team', 				caption: '소속', 			size: '150px', 	sortable: true, attr: 'align=left', frozen: true }
		    		,{ field: 'totalScore', 		caption: '총점', 			size: '50px', 	sortable: true, attr: 'align=center', frozen: true}
		    		,{ field: 'rank', 				caption: '순위', 			size: '50px', 	sortable: true, attr: 'align=center', frozen: true}
		    	];
	    	}
	    	
	    	$.each(gridDynimicHeader1, function(index, row){
	    		columnGroups.push({ caption:row.codeNm, span:row.itemCnt });
	    	    console.log(row.itemCnt);
	    	});
	    	
	    	$.each(gridDynimicHeader2, function(index, row){
	    		columns.push({ field: row.code, caption: row.codeNm, size: '150px', sortable: true, attr: 'align=center'});
	    	});
	    	
			w2ui['grid'].columnGroups = columnGroups;
			w2ui['grid'].columns = columns;
			w2ui['grid'].reset();
			
			fnSearchList1();
	    } 
	} catch(e) {
		argoAlert(e);
	}
}


  //-------------------------------------------------------------
///그리드 컬럼 동적 생성을 위한 조회 
//-------------------------------------------------------------
function fnInitDynamicGrid(){
 	var multiService = new argoMultiService(fnCallbackSearchGridColumns);
	multiService.argoList("QA", "SP_QA4030M01_03", "s_", {sortCd:"MAJOR_CD"}) // 대분류(점수)
		        .argoList("QA", "SP_QA4030M01_03", "s_", {sortCd:"MINOR_CD"});// 소분류 (점수)			
	multiService.action();
}  
function fnCallbackSearchGridColumns(data, textStatus, jqXHR) {
	try{
		if(data.isOk()){
			
	    	var gridDynimicHeader1 = data.getRows(0);
	    	var gridDynimicHeader2 = data.getRows(1);
	    	
	    	if(argoGetValue("s_ViewGubun") == "P"){
	    		var columnGroups = [
	    			{ caption:"", master:true}
	    			,{ caption:"", master:true}
	    			,{ caption:"", master:true}
	    			,{ caption:"", master:true}
	    			,{ caption:"", master:true}
	    			,{ caption:"", master:true}
	    		];
		    	
		    	var columns = [
		    		{ field: 'recid', 				caption: '', 			size: '0px', 	sortable: true, attr: 'align=center', hidden: true }
		    		,{ field: 'team', 				caption: '소속', 			size: '150px', 	sortable: true, attr: 'align=left' , frozen: true}
		    		,{ field: 'sabun', 				caption: '사번', 			size: '80px', 	sortable: true, attr: 'align=center' , frozen: true}
		    		,{ field: 'agentNm', 			caption: '상담사명', 		size: '80px', 	sortable: true, attr: 'align=center' , frozen: true}
		    		,{ field: 'totalScore', 		caption: '총점', 			size: '50px', 	sortable: true, attr: 'align=center' , frozen: true}
		    		,{ field: 'rank', 				caption: '순위', 			size: '50px', 	sortable: true, attr: 'align=center' , frozen: true}
		    	];
	    	}else{
	    		var columnGroups = [
		    		{ caption:"", master:true }
		    		,{ caption:"", master:true }
		    		,{ caption:"", master:true }
		    		,{ caption:"", master:true }
		    	];
		    	
		    	var columns = [
		    		{ field: 'recid', 				caption: '', 			size: '0px', 	sortable: true, attr: 'align=center', hidden: true }
		    		,{ field: 'team', 				caption: '소속', 			size: '150px', 	sortable: true, attr: 'align=left', frozen: true }
		    		,{ field: 'totalScore', 		caption: '총점', 			size: '50px', 	sortable: true, attr: 'align=center', frozen: true}
		    		,{ field: 'rank', 				caption: '순위', 			size: '50px', 	sortable: true, attr: 'align=center', frozen: true}
		    	];
	    	}
	    	
	    	$.each(gridDynimicHeader1, function(index, row){
	    		columnGroups.push({ caption:row.codeNm, span:row.itemCnt });
	    	    console.log(row.itemCnt);
	    	});
	    	
	    	$.each(gridDynimicHeader2, function(index, row){
	    		columns.push({ field: row.code, caption: row.codeNm, size: '150px', sortable: true, attr: 'align=center'});
	    	});
	    	
			w2ui['grid'].columnGroups = columnGroups;
			w2ui['grid'].columns = columns;
			w2ui['grid'].reset();
			
			fnSearchList1();
	    } 
	} catch(e) {
		argoAlert(e);
	}
}


//-------------------------------------------------------------
//목록조회 - 직급별/직책별/업부그룹별/근속기간별
//-------------------------------------------------------------
function fnSearchList(){
	if(argoGetValue('s_TimesId')==""){
		argoAlert("평가계획을 선택하세요");
		return;
	}
	fnInitDynamicGrid();
}

function fnSearchList1(){	
	var multiService = new argoMultiService(fnCallbackSearch);
	var timesId = argoGetValue("s_TimesId");
	var dept1Id = argoGetValue("s_Dept1Id");
	var user1Id = argoGetValue("s_User1Id");
	var viewGubun = argoGetValue("s_ViewGubun");
	var qaValueStatus = argoGetValue("s_QaValueStatus");
	var notiYn = argoGetValue("s_NotiYn");
	
	multiService.argoList("QA", "SP_QA4030M01_01", "_", {timesId:timesId, dept1Id:dept1Id, user1Id:user1Id, viewGubun:viewGubun, qaValueStatus:qaValueStatus, notiYn:notiYn})
		        .argoList("QA", "SP_QA4030M01_02", "_", {timesId:timesId, dept1Id:dept1Id, user1Id:user1Id, viewGubun:viewGubun, qaValueStatus:qaValueStatus, notiYn:notiYn}); 
	multiService.action(); 
}

function fnCallbackSearch(data, textStatus, jqXHR){
	try{
		if(data.isOk()){
			if(data.getRows(0) != ""){
				fnSetDynamicGridRows(data.getRows(0) ,data.getRows(1)) ;
	    	}else{
	    		argoAlert('조회 결과가 없습니다.');
	    		fnInitGrid();
	    		w2ui.grid.clear();
	    		w2ui['grid'].add([]);
	    	}
	    } 
	} catch(e) {
		argoAlert(e);
	} 
}

//-------------------------------------------------------------
//그리드 로우 동적생성 ==> 조직데이터를 세로로  / 분석데이터를 가로로  처리
//-------------------------------------------------------------
function fnSetDynamicGridRows(dsRows,dsDatas) {
	dataArray = new Array();
	var footerSumObj = {};
	var footerAvgObj = {};
	
	footerSumObj.recid = 'S-1';
	footerSumObj.w2ui = { summary: true };
	footerSumObj.team = "<span style='float: right;'>합계 =></span>";
	
	footerAvgObj.recid = 'S-2';
	footerAvgObj.w2ui = { summary: true };
	footerAvgObj.team = "<span style='float: right;'>평균 =></span>";
	
	$.each(dsRows, function( index, row ) {	    	   
		var obj = {};
		if(argoGetValue("s_ViewGubun") == "P"){
			obj.recid      = index;
			obj.team       = row.team;
			obj.sabun      = row.sabun;
			obj.agentNm    = row.codeNm;
			obj.totalScore = row.totalSum;
			obj.rank  	   = row.totalRank;
			obj.code       = row.code;
			obj.codeNm     = row.codeNm;
			footerSumObj.totalScore = argoNullConvertZero(footerSumObj.totalScore) + argoNullConvertZero(row.totalSum);
			footerSumObj.totalCnt   = argoNullConvertZero(footerSumObj.totalCnt) + 1;
		}else{
			obj.recid      = index;
			obj.team       = row.team;
			obj.totalScore = row.totalSum;
			obj.rank  	   = row.totalRank;
			obj.code       = row.code;
			obj.codeNm     = row.codeNm;
			footerSumObj.totalScore = argoNullConvertZero(footerSumObj.totalScore) + argoNullConvertZero(row.totalSum);
			footerSumObj.totalCnt   = argoNullConvertZero(footerSumObj.totalCnt) + 1;
		}
		
		var dsGrep = $.grep( dsDatas, function(n,i){
			return (n.code == row.code);
		});
		
		$.each(dsGrep, function( index2, row2 ) {
			obj[row2.columnId ] = argoNullConvertZero(row2.totalScore) ; 
			footerSumObj[row2.columnId] = argoNullConvertZero(footerSumObj[row2.columnId]) + argoNullConvertZero(row2.totalScore);
			footerAvgObj["AVG_"+row2.columnId] = argoNullConvertZero(footerAvgObj["AVG_"+row2.columnId]) + argoNullConvertZero(row2.totalScore);
			footerAvgObj["CNT_"+row2.columnId] = argoNullConvertZero(footerAvgObj["CNT_"+row2.columnId]) + 1;
		});
		
		dataArray[index]= obj;
	});
	
	footerAvgObj.totalScore = argoNullConvertZero(footerSumObj.totalScore) / (argoNullConvertZero(footerSumObj.totalCnt)==0?1:argoNullConvertZero(footerSumObj.totalCnt));
	footerAvgObj.totalScore = Math.round(footerAvgObj.totalScore * 100) / 100;
	
	$.each(w2ui['grid'].columns, function(index, row){
		if(typeof(footerAvgObj["AVG_" + row.field]) != "undefined"){
			footerAvgObj[row.field] = argoNullConvertZero(footerAvgObj["AVG_"+row.field]) / (argoNullConvertZero(footerAvgObj["CNT_"+row.field])==0?1:argoNullConvertZero(footerAvgObj["CNT_"+row.field]));
			footerAvgObj[row.field] = Math.round(footerAvgObj[row.field] * 100) / 100;
			delete footerAvgObj["AVG_" + row.field];
			delete footerAvgObj["CNT_" + row.field];
		}
	})
	
	
	dataArray.push(footerSumObj);
	dataArray.push(footerAvgObj);
	
	w2ui.grid.clear();
	if(dataArray.length == 0){
		return;
	}
	w2ui['grid'].add(dataArray);
} 

function fnTimesChoice(){
	oOptions = {"targetObj" : "s_Times","multiYn" : 'N', "stdMonthFrom" : "", "stdMonthTo" : ""};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    gPopupOptions = oOptions;
    
    $("#s_TimesNm").focusout(function(){
 		if($("#s_TimesNm").val().trim()=='')  $("#s_TimesId").val('') ;
	});	
    
    argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/QaTimesChoiceF.do', '900', '600');
}











</script>


</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><strong class="step">평가항목별 보고서</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">평가계획</strong>
                            <input type="text"   id="s_TimesNm" name="s_TimesNm" style="width:230px;"><button type="button" id="btn_Times" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_TimesId" name="s_TimesId" >
                        </li>
                        <li>
                           <strong class="title">소속</strong>
                           <input type="text"   id="s_Dept1Nm" name="s_Dept1Nm" style="width:230px;" readonly><button type="button" id="btn_Dept1" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_Dept1Id" name="s_Dept1Id" >
                        </li>
                        <li>
                           <strong class="title">상담사</strong>
                           <input type="text"   id="s_User1Nm" name="s_User1Nm" style="width:230px;"><button type="button" id="btn_User1" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_User1Id" name="s_User1Id" >
                        </li>                  
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                       <li class="pt3">
                            <span class="checks ml20"><input type="radio" id="group1" name="s_ViewGubun" checked value="P"><label for="group1">개인별</label></span>
                            <span class="checks ml15"><input type="radio" id="group2" name="s_ViewGubun"  value="D"><label for="group2">팀별</label></span>
                        </li> 
                        <li>
                           <strong class="title">진행상태</strong>
                           <select id="s_QaValueStatus" name="s_QaValueStatus" style="width:90px;"></select>
                        </li>
                        <li>
                           <strong class="title">적용여부</strong>
                           <select id="s_NotiYn" name="s_NotiYn" style="width:90px;">
								<option value="">&lt;전체&gt;</option>
                           		<option value="1">적용</option>
                           		<option value="0">미적용</option>
                           </select>
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
            <div class="h136">
                <div class="btn_topArea fix_h25"></div>
                <div class="grid_area h25 pt0">
                    <div id="grList" class="real_grid float-left"></div>
                </div>
            </div>
        </section>
    </div>

</body>
</html>