<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<%-- <script type="text/javascript" src="<c:url value="/ProcessScript/QA/QA1030S03.js"/>?<%=Globals.DEPLOY_KEY()%>"></script> --%>
<script>
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var groupId   	= loginInfo.SVCCOMMONID.rows.groupId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가계획 복사";
var workLog 	= "";
var dataArray 	= new Array();

$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchList1();
	fnSearchList2(); 
});

var fvStdMonth1, fvStdMonth2;
var ipStdMonth1 = "";
var ipStdMonth2 = ""; 
function fnInitCtrl(){

	$(".yearMonth_date").dateSelect({onChange: function (dateText, inst) {
			if(argoGetValue("s_StdMonth1") != fvStdMonth1){
				fvStdMonth1 = argoGetValue("s_StdMonth1");
				fnSearchList1();
			}
			if(argoGetValue("s_StdMonth2") != fvStdMonth2){
				fvStdMonth2 = argoGetValue("s_StdMonth2");
				fnSearchList2();
			}
		} 
	});
	
	var date = new Date();
    var yyyy = date.getFullYear();
    var mm = date.getMonth();
    if (mm == 0){
    	mm = 12;
    	yyyy=yyyy-1;
    }
    if (mm < 10) mm = "0" + mm;
    var sStdMonth1 = yyyy +'-'+ mm; 
	var sStdMonth2 = argoSetFormat(argoCurrentDateToStr(),"-","4-2") ;
	fvStdMonth1 = sStdMonth1;
	fvStdMonth2 = sStdMonth2;
	argoSetValue('s_StdMonth1', sStdMonth1) ;
	argoSetValue('s_StdMonth2', sStdMonth2) ;
	
	$("#s_StdMonth2").keyup(function(){
		ipStdMonth2 = $("#s_StdMonth2").val();
	}); 
	
	$("#btnMoveAdd").click(function(){			
		fnMove("down" , -1) ;
	});
	
	$("#btnMoveRemove").click(function(){			
		fnMove("up", -1) ;
	});		
	
	$("#btnSave").click(function(){
		fnSave();
	});
}

function fnInitGrid() {
	$('#grList01').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        columns: [  
        		 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'timesId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'timesNm', 	 	caption: '평가계획명', 	size: '100%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'copyTargetYn', 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=left' }
       	],
        records: dataArray
    });
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('timesId' );
	w2ui['grid'].hideColumn('copyTargetYn');
	
	$('#grList02').w2grid({ 
        name: 'grid2', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: false
        },
        multiSelect: false,
        columns: [  
        		 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'timesId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'timesNm', 	 	caption: '평가계획명', 	size: '90%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'copyTargetYn', 	caption: '', 		size: '0%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	w2ui['grid2'].hideColumn('recid' );
	w2ui['grid2'].hideColumn('timesId' );
	w2ui['grid2'].hideColumn('copyTargetYn' );
}

function fnSearchList1(){
	 var stdMonth = argoGetValue("s_StdMonth1").replace("-","");
	 argoJsonSearchList('ARGOCOMMON', 'SP_UC_GET_QA_TIMES', 's_', {stdMonth : stdMonth, grantDeptCd:groupId}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				if(data.getProcCnt() == 0){
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
				    				, "timesId"			: row.timesId
				   					, "timesNm"	  		: row.timesNm
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

function fnSearchList2(){
	var stdMonth = argoGetValue("s_StdMonth2").replace("-","");
	 argoJsonSearchList('ARGOCOMMON', 'SP_UC_GET_QA_TIMES', 's_', {stdMonth : stdMonth, grantDeptCd:groupId}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid2.clear();
				if(data.getProcCnt() == 0){
					//argoAlert('조회 결과가 없습니다.');
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
				    				, "timesId"			: row.timesId
				   					, "timesNm"	  		: row.timesNm
				   					, "copyTargetYn"	: "N"
									};
						dataArray.push(gObject2);
					});
					w2ui['grid2'].add(dataArray);
				}
				if(w2ui['grid2'].getSelection().length == 0){
					w2ui['grid2'].click(0,0);
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

function fnMove(sUpDown, nIndex) {
	
	if(sUpDown=="down") { 	
		var arrChecked = w2ui['grid'].getSelection();
	 	if(arrChecked.length==0) {
	 		//argoAlert("복사할 평가계획을 선택하세요") ; 
	 		return ;
	 	} 
	 	
	 	dataArray = [];
		$.each(arrChecked, function( obj, index ) {
			gObject2 = {  "recid" 			: w2ui['grid2'].records.length+1 + index
	    				, "timesId"			: w2ui['grid'].get(index).timesId
	   					, "timesNm"	  		: w2ui['grid'].get(index).timesNm
	   					, "copyTargetYn"	: "Y"
	   					, "w2ui": { "style": "background-color: #d5f7d6" }
					};
			dataArray.push(gObject2);
		});
		w2ui['grid2'].add(dataArray);
		if(w2ui['grid2'].getSelection().length == 0){
			w2ui['grid2'].click(0,0);
		} 
			
	}else {
		var arrChecked = w2ui['grid2'].getSelection();
	 	if(arrChecked.length==0) {
	 		return ;
	 	}
	 	
	 	dataArray = [];
		$.each(arrChecked, function( obj, index ) {
			gObject2 = {  "recid" 			: w2ui['grid'].records.length+1 + index
	    				, "timesId"			: w2ui['grid2'].get(index).timesId
	   					, "timesNm"	  		: w2ui['grid2'].get(index).timesNm
	   					, "copyTargetYn"	: "Y"
					};
			dataArray.push(gObject2);
		});
		w2ui['grid'].add(dataArray);
		if(w2ui['grid'].getSelection().length == 0){
			w2ui['grid'].click(0,0);
		}
	}	
}

function fnSave() {
	try {
		var multiService = new argoMultiService(fnCallbackSave);
		var copyStdMonth = argoGetValue("s_StdMonth2").replace(/-/g, "");
		var cnt = 0;
		w2ui.grid2.records.forEach(function(obj, index) {
			var timesId	 	= obj.timesId;
			var stdMonth 	= copyStdMonth;
			var timesNm 	= obj.timesNm;
			if(obj.copyTargetYn == "Y"){
				cnt = cnt + 1;
				
				/* var qa=0;
				if($("input:checkbox[id='ip_QA']").is(":checked")){
					qa=1
				} */
				
				var qa=argoGetValue("ip_QA");
				var param = {timesId : timesId, stdMonth : stdMonth, timesNm : timesNm, qa:qa}
				multiService.argoInsert("QA", "SP_QA1030S03_01", "__", param);
			}
	    });
		
		if(cnt == 0){
			argoAlert("복사 대상 평가계획이 없습니다.<br><br><span style='font-size:9pt; color: red;'>평가계획을 복사하려면, 해당 계획을 좌측 목록에서 선택하고 [▶] 버튼을 클릭하세요.</span>");
			return;
		}
		
		var message = "";
		
		if(argoGetValue("ip_QA") == "0"){
			message = "<span style='font-size:9pt;'>[수동배분 선택]<br>복사 후 평가자와 피평가자를 직접 배정하여 주십시오.</span>";
		}else if(argoGetValue("ip_QA") == "1"){
			message = "<span style='font-size:9pt;'>[QAA/평가대상자 포함 선택]<br>복사대상 평가계획에 배정된 평가자와 피평가자가 함께 복사됩니다.</span>";
		}else if(argoGetValue("ip_QA") == "2"){
			message = "<span style='font-size:9pt;'>[자동배분 선택]<br>\"관리소속\"에 해당하는 평가자와 피평가자가 자동 배분됩니다.</span>";
		}
		
		
		
		argoConfirm(cnt+"개의 평가계획을 복사 생성하시겠습니까?<br><br>"+message, function(){
			multiService.action();
		});
			
	} catch (e) {
		console.log(e);
	}
}

function fnCallbackSave(data, textStatus, jqXHR) {
	try{
		if (data.isOk()) {
			argoAlert('warning', '평가계획이 복사 생성 되었습니다.','', 'parent.fnInitTree(); argoPopupClose();');
		}
	}catch(e){
		console.log(e);
	}
}


</script>
</head>
<body>
	<div class="sub_wrap pop">
		<section class="pop_contents">
			<div class="h45 pt15">
				<div class="btn_moves" style="left: 53.5% !important;top: 50px;height: auto;">
					<button type="button" class="btn_add" id="btnMoveAdd">add</button>
					<button type="button" class="btn_remove" id="btnMoveRemove" style="display: none;">remove</button>
				</div>
				<div class="sub_l per50_l" style="position: relative !important;">
					<div class="grid_info" style="text-align: center;">
						<ul>
							<li>
                           		<span class="yearMonth_date" id="d1"><input type="text" placeholder="년 - 월" maxlength="6" class="input_ym onlyDate" id="s_StdMonth1" name="s_StdMonth1"><a href="#" class="btn_calendar">년/월 선택</a></span>
                           	</li>
                           </ul>
					</div>
					<div class="grid_area h25 pt5">
						<div id="grList01" class="real_grid"></div>
					</div>
				</div>
				<div class="sub_r per50_r">
					<div class="grid_info" style="text-align: center;">
						<ul>
							<li>
                           		<span class="yearMonth_date" id="d1"><input type="text" placeholder="년 - 월"  class="input_ym onlyDate" id="s_StdMonth2" name="s_StdMonth2"><a href="#" class="btn_calendar">년/월 선택</a></span>
                           	</li>
                           </ul>
					</div>
					<div class="grid_area h25 pt5">
						<div id="grList02" class="real_grid"></div>
					</div>
				</div>
			</div>
			<div class="btn_areaB txt_r" style="text-align: inherit;">
				<!-- <input type="checkbox" id="ip_QA" name="ip_QA" data-defaultChecked=true value="0" checked="checked" ><label for="ip_QA" >QAA/평가대상자 포함</label> -->
				<span class="checks"><input type="radio" name="ip_QA"  id="ip_QA"  value="0"><label for="ip_QA">수동배분</label></span>
				<span class="checks ml10"><input type="radio" name="ip_QA"  id="ip_QA1"  value="1"><label for="ip_QA1">QAA/평가대상자 포함</label></span>
				<span class="checks ml10"><input type="radio" name="ip_QA"  id="ip_QA2"  value="2" checked="checked"><label for="ip_QA2">자동배분</label></span>
				
				
				<button type="button" id="btnSave" name="btnSave" class="btn_m confirm" style="float: right;">저장</button>
			</div>
		</section>
	</div>
</body>
</html>
