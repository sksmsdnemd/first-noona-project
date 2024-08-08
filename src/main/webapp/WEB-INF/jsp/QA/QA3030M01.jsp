<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
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
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<style type="text/css">
#grid_grid_frecords{
	top: 56px !important;
}

#grid_grid_records{
	top: 56px !important;
	overflow: hidden;
}
</style>
<script type="text/javascript">
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var userName    = loginInfo.SVCCOMMONID.rows.userName;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;
var qaYn 		= loginInfo.SVCCOMMONID.rows.qaYn;
var workMenu 	= "결과조회";
var workLog 	= "";
var dataArray 	= new Array();
var recTableType = '<%=recTableType%>';
var gSheetkey;
var gPopupOptions;
var procType="";
$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchList();
});

function fnInitCtrl(){
	
	// 상담사 권한일 시 컨트롤 처리
	/* if(grantId == "Agent"){
		argoSetValue("s_User1Id", userId);
		argoSetValue("s_User1Nm", userName);
		argoSetValue("s_NotiYn", "1");
		argoDisable(true, 's_User1Nm,s_NotiYn,btn_User1');
	} */
	
	if(qaYn == "N"){
		argoSetValue("s_User1Id", userId);
		argoSetValue("s_User1Nm", userName);
		argoSetValue("s_NotiYn", "1");
		argoDisable(true, 's_User1Nm,s_NotiYn,btn_User1');
	}
	
	argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	argoSetDateTerm('selDateTerm1',{"targetObj":"s_txtDate1" , "selectValue":"M_1"});// 기간선택 콤보 설정
	argoSetDeptChoice("btn_Dept1", {"targetObj" : "s_Dept1","multiYn" : 'Y'}); //조직선택 팝업 연결처리(멀티)
	argoSetUserChoice01("btn_User1", {"targetObj" : "s_User1","multiYn" : 'Y'}); //상담사선택 팝업 연결처리(멀티)
	
	$("#btnQaa").click(function(){
		fnUserChoice();		
	});
	
	argoSetUserChoice03("btn_Qaa", {"targetObj" : "s_Qaa","multiYn" : 'Y', "jikchkCd":"60"}); //상담사선택 팝업 연결처리(멀티)
	
	$("#btn_Search").click(function(){
		fnSearchList();
	});
	
	$("#btn_Times").click(function(){
		fnTimesChoice();		
	});
	
	$("#btnExcel").click(function(){
		argoGridExlConvert(w2ui['grid'], workMenu);
		/* var excelArray = new Array();
		argoJsonSearchList('QA', 'SP_QA3030M01_01', 's_', {}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					$.each(data.getRows(), function( index, row ) {
						gObject = {
							"순번" 				: index
							, "평가계획" 			: row.timesNm
							, "소속"	  			: row.deptInfo
							, "사번" 				: row.sabun
							, "상담사명" 			: row.agentNm
							, "평가일자"			: row.valueYmd
							, "평가점수" 			: row.totalScore										
						};
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
		}); */
	});	
	
}

function fnInitGrid(){
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        onClick: function(event) {
        	var record = this.get(event.recid);
        	var key = Object.keys(record);
        	if(key[event.column] == "detailPop"){
        		var sheetkey = record.sheetkey;
        		var sabun = record.sabun;
        		var timesId = record.timesId;
    			gPopupOptions = {"sheetkey":sheetkey, "sabun":sabun, "timesId":timesId};      
    			argoPopupWindow('상세보기', gGlobal.ROOT_PATH+'/QA/QA3030S01F.do',  '1120', '689' );
        	} 
        	
        	if(key[event.column] == "recordListen"){
        		//argoRecPlay(record.recordId, playerKind);
        		//debugger;
        		var sRecTableNm = argoQaTimesRecTable(record.timesId, recTableType);
        		argoRecPlay(record.recordId, playerKind, sRecTableNm);
        	}
        	if(key[event.column] == "sttListen"){
        		var sRecTableNm = argoQaTimesRecTable(record.timesId, recTableType);
        		argoTaPopup(record.recordId, sRecTableNm);
        	}
        },
        onChange: function (event) {
        	var record = this.get(event.recid);
        	var key = Object.keys(record);
        	if(key[event.column] == "notiYn" || key[event.column] == "confirmYn"){
        		event.preventDefault();
        	} 
        },
        columnGroups : [
          { caption:"", 			master:true }
          , { caption:"", 			master:true }
          , { caption:"", 			master:true }
          , { caption:"", 			master:true }
          , { caption:"", 			master:true }
          , { caption:"평가대상자", 	span:3 }
          , { caption:"평가정보", 		span:6 }
      	],
        columns: [  
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'recordId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'sheetkey', 		caption: '', 			size: '0%',  	sortable: true, attr: 'align=center' }
			 	,{ field: 'timesId', 		caption: '', 			size: '0%',  	sortable: true, attr: 'align=center' }
			 	,{ field: 'timesNm', 	 	caption: '평가계획', 		size: '25%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'deptInfo', 		caption: '소속', 			size: '25%',  	sortable: true, attr: 'align=left' }
       	 		,{ field: 'sabun', 			caption: '사번', 			size: '10%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '10%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'recordListen', 	caption: '청취', 			size: '5%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'sttListen', 		caption: 'STT', 		size: '5%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'valueYmd', 		caption: '평가일자', 		size: '10%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'totalScore', 	caption: '평가점수', 		size: '10%',  	sortable: true, attr: 'align=right' }
		       	,{ field: 'convertRate', 	caption: '환산배율', 		size: '5%',  	sortable: true, attr: 'align=right' }
		       	,{ field: 'convertScore', 	caption: '환산점수', 		size: '5%',  	sortable: true, attr: 'align=right' }
		       	,{ field: 'detailPop', 		caption: '상세보기', 		size: '5%',  	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('recordId' );
	w2ui['grid'].hideColumn('sheetkey' );
	w2ui['grid'].hideColumn('timesId' ); 
	
	
}


function fnSearchList(){
	
	argoJsonSearchList('QA', 'SP_QA3030M01_01', 's_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				if(data.getProcCnt() == 0){
					return;
				}
				
				var totalScore = 0;
				var convertScore = 0;
				var cnt = 0;
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						totalScore = totalScore + row.totalScore;
						convertScore = convertScore + row.convertScore;
						cnt = cnt + 1;
						gObject2 = {
										"recid" 				: index
					    				, "recordId"			: row.recordId
					   					, "sheetkey"	  		: row.sheetkey
					   					, "timesId"	  			: row.timesId
										, "timesNm" 			: row.timesNm
										, "deptInfo"	  		: row.deptInfo
										, "sabun" 				: row.sabun
										, "agentNm" 			: row.agentNm
										, "recordListen"		: "<img alt='' src='../images/speak_up.png' style='cursor:pointer;'></img>"
										, "sttListen"			: "<img alt='' src='../images/icon_code.png' style='cursor:pointer;'></img>"
										, "valueYmd"			: row.valueYmd
										, "totalScore" 			: row.totalScore										
										, "convertRate" 		: row.convertRate
										, "convertScore" 		: row.convertScore
										, "detailPop" 			: '<img src="../images/bg_approval.png" style="width:20px; height:20px; cursor:pointer;"></img>'			
									};
						dataArray.push(gObject2);
					});
					//w2ui['grid'].add(dataArray);
					
					
					var footerAvgObj = {};
					footerAvgObj.recid = 'S-1';
					footerAvgObj.w2ui = { summary: true };
					footerAvgObj.timesNm = "<span style='float: right;'>평균 =></span>";
					
					Math.round(footerAvgObj.totalScore * 100) / 100;
					footerAvgObj.totalScore = cnt == 0?0:Math.round(totalScore / cnt * 100) / 100;
					footerAvgObj.convertScore = cnt == 0?0:Math.round(convertScore / cnt * 100) / 100;
					
					
					dataArray.push(footerAvgObj);
					
					w2ui['grid'].add(dataArray);
					
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

function fnUserChoice(){
	var timesId = argoGetValue("#s_TimesId").replace(/,/gi,'\',\'');
	oOptions = {"targetObj" : "s_Qaa","multiYn" : 'Y', "jikchkCd":"50"};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
    $("#s_QaaNm").focusout(function(){
 		if($("#s_QaaNm").val().trim()=='')  $("#s_QaaId").val('') ;
	});	
    
	oOptions['searchKey'] = argoGetValue("s_QaaNm");
	gPopupOptions = oOptions;	
	argoPopupWindow('직책별 상담사 선택', gGlobal.ROOT_PATH+'/common/UserChoice03F.do', '900', '600');
}

function fnTimesChoice(){
	oOptions = {"targetObj" : "s_Times","multiYn" : 'Y', "targetYm" : "s_txtDate1" };
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
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><strong class="step">결과조회</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
            	<div class="row">
                    <ul class="search_terms">
                        <li>
                           <strong class="title ml20">평가일자</strong>
                           <select id="selDateTerm1" name="" style="width:70px;" class="mr5"></select>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                           <span class="text_divide">~</span>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To"  name="s_txtDate1_To"></span>
                        </li>
                    	<li>
                           <strong class="title">평가계획</strong>
                           <input type="text" id="s_TimesNm" name="s_TimesNm" style="width:200px;"><button type="button" class="btn_termsSearch" id="btn_Times">검색</button>
                           <input type="hidden" id="s_TimesId" name="s_TimesId">
                        </li>
						<li>
                           <strong class="title">적용여부</strong>
                           <select id="s_NotiYn" name="s_NotiYn" style="width:110px;">
								<option value="">&lt;전체&gt;</option>
                           		<option value="1">적용</option>
                           		<option value="0">미적용</option>
                           </select>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                        	<strong class="title ml20">소속</strong>
                        	<input type="text" id="s_Dept1Nm" name="s_Dept1Nm" style="width:200px;" readonly><button type="button" class="btn_termsSearch" id="btn_Dept1">검색</button>
                        	<input type="hidden" id="s_Dept1Id" name="s_Dept1Id">
                        </li>
                        <li>
                           <strong class="title">상담사</strong>
                           <input type="text"   id="s_User1Nm" name="s_User1Nm" style="width:200px;"><button type="button" id="btn_User1" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_User1Id" name="s_User1Id" >
                        </li>
                        <li style="display: none;">
							<strong class="title">평가자</strong>
							<input type="text" id="s_QaaNm" name="s_QaaNm" style="width: 200px;"><button type="button" id="btnQaa" class="btn_termsSearch">검색</button>
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
            <div class="h136">
                <div class="btn_topArea fix_h25"></div>
                <div class="grid_area h25 pt0">
                    <div id="grList" class="real_grid"></div>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>