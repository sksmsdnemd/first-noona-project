<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
var workMenu 	= "항목별 평가의견";
var workLog 	= "";
var dataArray 	= new Array();


var timesList = "";
$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchList();
});

function fnInitCtrl(){
	argoSetYearMonthPicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	argoSetDateTerm('selDateTerm1',{"targetObj":"s_txtDate1" , "selectValue":"M_0", "onlyMonth":"Y"}    );// 기간선택 콤보 설정
	argoCbCreate("s_QaEvalType", "ARGOCOMMON", "SP_UC_GET_CMCODE_01",{sort_cd:'QA_EVAL_TYPE'},{"selectIndex":0, "text":'<전체>', "value":''});
	argoSetDeptChoice("btn_Dept", {"targetObj":"s_Dept", "multiYn":'Y'}); //조직선택 팝업 연결처리(멀티)
	argoSetUserChoice01("btn_User", {"targetObj":"s_Agent", "multiYn":'Y'}); //상담사선택 팝업 연결처리(멀티)
	argoSetUserChoice03("btn_Qaa", {"targetObj":"s_Qaa", "multiYn":'Y'}); //상담사선택 팝업 연결처리(멀티)
	argoCbCreate("#s_QaValueStatus", "ARGOCOMMON", "SP_UC_GET_CMCODE_01", {sort_cd : 'QA_VALUE_STATUS'}, {"selectIndex" : 2,"text" : '<전체>',"value" : ''}); // 진행상태
	
    $("#btn_Search").click(function(){
    	fnInitGrid();
    	fnSearchList();
    });
    
    $("#btn_Times").click(function(){
		fnTimesChoice();		
	});
	
	$("#btnExcel").click(function(){
		argoGridExlConvert(w2ui['grid'], workMenu);
	});	
}

//-------------------------------------------------------------
// 그리드 초기설정
//-------------------------------------------------------------


function fnInitGrid(){
	if(typeof(w2ui['grid']) != "undefined" && w2ui['grid'] !=null){
		if(argoGetValue("s_Gbn") == "D"){
			var columnGroups = [
	       	   	  { caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"평가항목", span:2 }
	             ,{ caption:"", master:true }
	        ];
			var columns = [  
				 	 { field: 'recid', 			caption: '', 				size: '0%', 	sortable: false, attr: 'align=center' }
				 	,{ field: 'timesNm', 	 	caption: '평가계획', 		size: '15%', 	sortable: false, attr: 'align=left' }
				 	,{ field: 'qaaNm', 	 		caption: '평가자', 			size: '7%', 	sortable: false, attr: 'align=center' }
		  	 		,{ field: 'team', 			caption: '팀', 				size: '7%', 	sortable: false, attr: 'align=center' }
		  	 		,{ field: 'sabun', 			caption: '사번', 			size: '7%', 	sortable: false, attr: 'align=center' }
		  	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '7%', 	sortable: false, attr: 'align=center' }
		  	 		,{ field: 'valueYmd', 		caption: '평가일', 			size: '7%', 	sortable: false, attr: 'align=center' }
		  	 		,{ field: 'score', 			caption: '점수', 			size: '5%',		sortable: false, attr: 'align=center' }
		  	 		,{ field: 'majorNm', 		caption: '대분류', 			size: '10%', 	sortable: false, attr: 'align=center' }
		  	 		,{ field: 'minorNm', 	    caption: '소분류', 			size: '10%', 	sortable: false, attr: 'align=center' }
		  	 		,{ field: 'valueText', 	    caption: '평가의견', 		size: '60%', 	sortable: false, attr: 'align=left' }
		  	];
		}else if(argoGetValue("s_Gbn") == "H"){
			
			var columnGroups = [
	       	   	  { caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"평가대상자", span:3 }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	             ,{ caption:"", master:true }
	        ];
			var columns = [  
				 { field: 'recid', 				caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
				 	,{ field: 'timesNm', 	 	caption: '평가계획', 		size: '15%', 	sortable: true, attr: 'align=left' }
				 	,{ field: 'qaaNm', 	 		caption: '평가자', 			size: '7%', 	sortable: true, attr: 'align=center' }
		  	 		,{ field: 'team', 			caption: '팀', 				size: '7%', 	sortable: true, attr: 'align=center' }
		  	 		,{ field: 'sabun', 			caption: '사번', 			size: '7%', 	sortable: true, attr: 'align=center' }
		  	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '7%', 	sortable: true, attr: 'align=center' }
		  	 		,{ field: 'valueYmd', 		caption: '평가일', 			size: '7%', 	sortable: true, attr: 'align=center' }
		  	 		,{ field: 'totalScore', 	caption: '총점', 			size: '5%',		sortable: true, attr: 'align=center' }
		  	 		,{ field: 'totalComment', 	caption: '종합의견', 		size: '60%', 	sortable: true, attr: 'align=left' }
		  	];
			
		}
		
		w2ui['grid'].columnGroups 	= columnGroups;
		w2ui['grid'].columns 		= columns;
		w2ui['grid'].hideColumn('recid' );
		w2ui["grid"].sort(null);
		w2ui['grid'].reset();
	}else{
		$('#grList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: false,
	            selectColumn: false
	        },
	        multiSelect: false,
	        columnGroups : [
	       	   { caption:"", master:true }
              ,{ caption:"", master:true }
              ,{ caption:"", master:true }
              ,{ caption:"", master:true }
              ,{ caption:"", master:true }
              ,{ caption:"", master:true }
              ,{ caption:"", master:true }
              ,{ caption:"", master:true }
              ,{ caption:"평가항목", span:2 }
              ,{ caption:"", master:true }
	        ],
	        columns: [  
				 	 { field: 'recid', 			caption: '', 				size: '0%', 	sortable: false, attr: 'align=center' }
				 	,{ field: 'timesNm', 	 	caption: '평가계획', 			size: '15%', 	sortable: false, attr: 'align=left' }
				 	,{ field: 'qaaNm', 	 		caption: '평가자', 			size: '7%', 	sortable: false, attr: 'align=center' }
	       	 		,{ field: 'team', 			caption: '팀', 				size: '7%', 	sortable: false, attr: 'align=center' }
	       	 		,{ field: 'sabun', 			caption: '사번', 				size: '7%', 	sortable: false, attr: 'align=center' }
	       	 		,{ field: 'agentNm', 		caption: '상담사명', 			size: '7%', 	sortable: false, attr: 'align=center' }
	       	 		,{ field: 'valueYmd', 		caption: '평가일', 			size: '7%', 	sortable: false, attr: 'align=center' }
	       	 		,{ field: 'score', 			caption: '점수', 				size: '5%',		sortable: false, attr: 'align=center' }
	       	 		,{ field: 'majorNm', 		caption: '대분류', 			size: '10%', 	sortable: false, attr: 'align=center' }
	       	 		,{ field: 'minorNm', 	    caption: '소분류', 			size: '10%', 	sortable: false, attr: 'align=center' }
	       	 		,{ field: 'valueText', 	    caption: '평가의견', 			size: '60%', 	sortable: false, attr: 'align=left' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid' );
		w2ui["grid"].sort(null);
		w2ui['grid'].reset();
	}

}

function fnSearchList(){	
	argoJsonSearchList("QA", "SP_QA4060M01_01", "s_", {}, function(data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				if(data.getProcCnt() == 0){
					return;
				}
				
				dataArray = [];
				var color = "";
				var colorFlg = "";
				
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						if(argoGetValue("s_Gbn") == "D"){
							if(index == 0){
								colorFlg = ""+row.sheetkey;
								//color = "#f3f6fa";
								color = "#e6e0ec";
								
							}else if(colorFlg != ""+row.sheetkey){
								colorFlg = ""+row.sheetkey;
								//if(color == "#ffffff"){
								if(color == "#ebf1de"){
									//color = "#f3f6fa";
									color = "#e6e0ec";
								}else{
									//color = "#ffffff";
									color = "#ebf1de";
								}
							}
							
							gObject2 = {  "recid" 			: index
								, "timesNm"			: row.timesNm
								, "qaaNm"			: row.qaaNm
			   					, "team"	  		: row.team
								, "sabun" 			: row.sabun
								, "agentNm" 		: row.agentNm
								, "valueYmd"		: row.valueYmd
								, "score"	  		: row.score
								, "majorNm"			: row.majorNm
								, "minorNm" 		: row.minorNm										
								, "valueText" 		: row.valueText
								, "w2ui": { "style": "background-color: " + color }
							};
						}else if(argoGetValue("s_Gbn") == "H"){
							gObject2 = {  "recid" 			: index
									, "timesNm"			: row.timesNm
									, "qaaNm"			: row.qaaNm
				   					, "team"	  		: row.team
									, "sabun" 			: row.sabun
									, "agentNm" 		: row.agentNm
									, "valueYmd"		: row.valueYmd
									, "totalScore"	  	: row.totalScore
									, "totalComment"	: row.totalComment
							};
						}
						dataArray.push(gObject2);
					});
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

function fnTimesChoice(){
	oOptions = {"targetObj" : "s_Times","multiYn" : 'Y', "targetYm" : "s_txtDate1" , "stdMonthFrom" : argoGetValue("s_txtDate1_From"), "stdMonthTo" : argoGetValue("s_txtDate1_To")};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    gPopupOptions = oOptions;
    
    $("#s_TimesNm").focusout(function(){
 		if($("#s_TimesNm").val().trim()=='')  $("#s_TimesId").val('') ;
	});	
    
    argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/QaTimesChoiceF.do', '900', '630');
}


// 평가 계획 변경 시 이벤트 추가 
function changeTimes() {
	timesList = argoGetValue('s_TimesId');
}

</script>
</head>
<body>
<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><strong class="step">항목별 평가의견</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">기준년월</strong>
                            <select id="selDateTerm1" name="selDateTerm1" style="width: 80px; display: hidden" class="mr5"></select>
						    <span class="yearMonth_date" id="d1"><input type="text" id="s_txtDate1_From" name="s_txtDate1_From" placeholder="년 - 월" class="input_ym onlyDate"><a href="#" class="btn_calendar">년/월 선택</a></span>
                            <span class="text_divide">~</span>
						    <span class="yearMonth_date" id="d1"><input type="text" id="s_txtDate1_To" name="s_txtDate1_To" placeholder="년 - 월" class="input_ym onlyDate"><a href="#" class="btn_calendar">년/월 선택</a></span> 
                        </li>
                        <li>
                           <strong class="title">평가계획</strong>
                            <input type="text" id="s_TimesNm" name="s_TimesNm" style="width:151px;"><button href="#" class="btn_termsSearch" id="btn_Times">검색</button>
                            <input type="hidden" id="s_TimesId" name="s_TimesId" onchange="changeTimes()">
                        </li>
                        <li>
                           <strong class="title">진행상태</strong>
                           <select id="s_QaValueStatus" name="s_QaValueStatus" style="width:80px;"></select>
                        </li>
                        <li>
                           <strong class="title">적용여부</strong>
                           <select id="s_NotiYn" name="s_NotiYn" style="width:80px;">
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
                           <input type="text"   id="s_DeptNm" name="s_DeptNm" style="width:100px;" readonly><button type="button" id="btn_Dept" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_DeptId" name="s_DeptId" >
                        </li>
                        <li>
                           <strong class="title">상담사</strong>
                           <input type="text"   id="s_AgentNm" name="s_AgentNm" style="width:100px;"><button type="button" id="btn_User" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_AgentId" name="s_AgentId" >
                        </li>
                        <li>
                           <strong class="title">평가자</strong>
                           <input type="text"   id="s_QaaNm" name="s_QaaNm" style="width:100px;"><button type="button" id="btn_Qaa" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_QaaId" name="s_QaaId" >
                        </li>
                        
                        <li class="pt3">
                       		<span class="checks ml20"><input type="radio" id="group1" name="s_Gbn" checked value="D"><label for="group1">항목별</label></span>
                            <span class="checks ml15"><input type="radio" id="group2" name="s_Gbn"  value="H"><label for="group2">종합의견</label></span>
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