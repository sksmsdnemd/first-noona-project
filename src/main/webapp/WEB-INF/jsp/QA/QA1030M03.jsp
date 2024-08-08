<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript">
var fvTimesId='';
var fvTimesNm='';
var fvQaaId="";
var fvGridSelNum = 0;
var fvStatus = '';

//공통 변수 세팅
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가계획관리-상담사배정";
var workLog 	= "";
var dataArray 	= new Array();

$(document).ready(function() {
	top.windowStepFlag = true;
	top.windowStepVal = "QA1030M03"; 
	
	fnInitCtrl();
	fnInitGrid();
	fnSearchList();
});

function fnInitCtrl(){
	
	fvTimesId = argoGetValue("timesId");
	fvTimesNm = argoGetValue("timesNm");
	fvStatus = argoGetValue("fvStatus");
	
	if(fvStatus!="생성"){
		argoDisable(true,"btnAuto,btnDel");
	}
	
	$("#status").html("<em class='state_ico' >"+fvStatus+"</em>"+fvTimesNm);
	$("#btnAdd").click(function(){
		fnAddAgent();
    });
	
	$("#btn_step1").click(function() {
		fnPageMove('N');
	})
	 
	$("#btnQaPrev , #btn_step2").click(function(){
		fnPageMove('Y');
	})
	
	$("#btnAuto").click(function(){
		fnAllocAgentAutoDivide();
	})
	
	$("#btnDel").click(function(){
		fnAgentDelte();
	})
}

function fnAllocAgentAutoDivide(){
	argoConfirm("자동배정을 진행하시겠습니까?<br><br> <span style='font-size:9pt; color:red;'> 기 배정인원은 초기화 되며 \"관리소속\"에 해당되는 피평가자가<br>자동 배분됩니다. </span>", function(){
		argoJsonCallSP("QA","SP_QA1030M03_03","_", {timesId:fvTimesId}, function(data, textStatus, jqXHR){
			if(data.isOk){
				fnSearchList();
			}
		});
		multiService.action();
	});
}

function fnInitGrid(){
	
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false
            
        },
        multiSelect: false,
        onDblClick: function(event) {
        },
        onClick: function(event) {
        	var record = this.get(event.recid);
        	fvQaaId = record.qaaId;
        	fnSearchList2(fvQaaId);
        },
        columns: [  
        		 { field: 'recid', 			caption: '', 		size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'deptInfo', 		caption: '소속', 		size: '30%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'sabun', 	 		caption: '사번', 		size: '20%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentNm', 		caption: '평가자명', 	size: '20%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'targetCnt', 		caption: '평가대상건', size: '15%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'valueCnt', 		caption: '평가건', 	size: '15%', 	sortable: true, attr: 'align=center' }
	       	 	,{ field: 'centerNm', 		caption: '', 		size: '10%', 	sortable: true, attr: 'align=center' }
	   	 		,{ field: 'qaaId', 			caption: '', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('centerNm' );
	w2ui['grid'].hideColumn('qaaId' );
	
	$("#grList2").w2grid({
        name : "grid2"
      , show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
      },
	  multiSelect: true,
      columns : [               
   	   		 { field: 'recid', 	 		caption: '', 		size: '0%', 	sortable: true, attr: 'align=center' }
   	    	,{ field: 'deptInfo', 	 	caption: '소속', 		size: '60%', 	sortable: true, attr: 'align=left' }
	 		,{ field: 'sabun', 			caption: '사번', 		size: '15%', 	sortable: true, attr: 'align=center' }
	 		,{ field: 'agentNm', 		caption: '상담사명', 	size: '15%', 	sortable: true, attr: 'align=center' }
	 		,{ field: 'valueCnt', 		caption: '평가건수', 	size: '10%', 	sortable: true, attr: 'align=center' }
      ]
  	});   
	
   w2ui['grid2'].hideColumn('recid' );
	
}

function fnSearchList(){
	argoJsonSearchList('QA', 'SP_QA1030M02_02', 's_', {timesId : fvTimesId}, function (data, textStatus, jqXHR){
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
				    				, "deptInfo"		: row.deptInfo
				   					, "sabun"	  		: row.sabun
									, "agentNm" 		: row.agentNm
									, "targetCnt"	  	: row.targetCnt
									, "valueCnt" 		: row.valueCnt
									, "centerNm" 		: row.centerNm
									, "qaaId"			: row.qaaId
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

function fnSearchList2(qaaId){
	
	argoJsonSearchList('QA', 'SP_QA1030M03_01', 's_', {"timesId":fvTimesId,"qaaId":qaaId}, function (data, textStatus, jqXHR){
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
				    				, "deptInfo"		: row.deptInfo
				   					, "sabun"	  		: row.sabun
									, "agentNm" 		: row.agentNm
									, "valueCnt"	  	: row.valueCnt
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

function fnAdd(){
	
}

function fnPageMove(type){
	var url;
	var param;
	
	if(type == 'N') {
		url = "QA1030M01F.do";
		param={timesId:fvTimesId};
		fnDynamicForm(param, url);
	}
	else {
		window.location.replace("QA1030M02F.do?timesId="+fvTimesId);
	}
 
}

function fnAddAgent(){
	var cudGubun ='';
	if(fvStatus != '생성') {
		cudGubun = 'R'
	}
	gPopupOptions = {"pTimesId":fvTimesId, "pQaaId":fvQaaId , "cudGubun" : cudGubun} ;   	
	argoPopupWindow('평가대상자 관리', 'QA1030S01F.do',  '1150', '689');
}


function fnAgentDelte(){
	try{
		var arrChecked = w2ui['grid2'].getSelection();
	 	if(arrChecked.length==0) {
	 		argoAlert("삭제할 평가대상자를 선택하세요") ; 
	 		return ;
	 	}
		argoConfirm('선택한 평가대상자를 ' + arrChecked.length + '건을  <br>삭제하시겠습니까?', function() {
			var multiService = new argoMultiService(fnCallbackDelete);
			$.each(arrChecked, function( index, value ) {
			  	var valueCnt = w2ui['grid2'].get(value).valueCnt;
				var agentId  = w2ui['grid2'].get(value).sabun; 
				console.log("삭제시 AGENTID : " + agentId);
				multiService.argoDelete("QA","SP_QA1030M03_02","__", {"qaaId":fvQaaId, "timesId":fvTimesId,"agentId":agentId});
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
			argoAlert('성공적으로 삭제 되었습니다.');
			fnSearchList();
		}
	} catch (e) {
		argoAlert(e);
	}
}
</script>
</head>
<body>
		<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><span class="step">평가계획관리</span><strong class="step">상담사 배정</strong></div>
        <section class="sub_contents">        	
        	<div class="step_area">
            	<a href="#" class="btn_stepPrev tooltip_l" title="QAA 배정" id="btnQaPrev">QAA 배정</a>
                <div class="step_view step3">
                    <ul>
                        <li id="btn_step1" style = "cursor: pointer;">
                            <em class="num" >1</em>
                            <p class="step">STEP 01</p>
                            <p class="title"> 평가계획</p>
                        </li>
                        <li id="btn_step2" style = "cursor: pointer;">
                            <em class="num" >2</em>
                            <p class="step">STEP 02</p>
                            <p class="title">QAA 배정</p>
                        </li>
                        <li class="on">
                            <em class="num">3</em>
                            <p class="step">STEP 03</p>
                            <p class="title">상담사 배정</p>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="sub_l fix600 h93 top93">
            	<div class="btn_topArea h36">
                	<span class="btn_l pt8 pl5">
                    	<span class="state_info" id="status"></span> 
                    </span>
                </div>
                <div class="grid_area h36 pt0">
                    <div id="grList" class="real_grid"></div>
                </div>
            </div>
            <div class="sub_r pl600 h93">
            	 <div class="btn_topArea h36">
                 	<span class="btn_l">
                    	<button type="button" class="btn_m confirm" id="btnAuto" style="display: none;">자동배정</button>
                    </span>
                	<span class="btn_r">
                    	<button type="button" class="btn_m" id="btnAdd">추가</button>
                        <button type="button" class="btn_m confirm" id="btnDel">삭제</button>                
                    </span>
                </div>
                <div class="grid_area h36 pt0">
                    <div id="grList2" class="real_grid"></div>
                    <input type="hidden" id="timesId" name="timesId" value="<c:out value="${timesId}"/>">
                    <input type="hidden" id="timesNm" name="timesNm" value="<c:out value="${timesNm}"/>">
                    <input type="hidden" id="fvStatus" name="fvStatus" value="<c:out value="${status}"/>">
                </div>
            </div>
        </section>
    </div>
</body>
</html>
