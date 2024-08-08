<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<script type="text/javascript">
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가계획관리-QAA배정";
var workLog 	= "";
var dataArray 	= new Array();

var fvTimesId='';
var fvStatus='';
$(document).ready(function() {
	top.windowStepFlag = true;
	top.windowStepVal = "QA1030M02"; 
	fvTimesId = argoGetValue("timesId");
	fnInitCtrl();
	fnInitGrid();
	fnSearchList();
});

function fnInitCtrl(){
	
	argoSetUserChoice04("btnAdd", {"targetObj" : "qaa","multiYn" : 'Y', "popName" : 'QAA 강사 선택'}); //상담사선택 팝업 연결처리(멀티)
	
	
	$("#btnAuto").click(function(){
		fnAllocAgentAutoDivide();
	})
	
	$("#btnQaNext , #btn_step3").click(function(){
		fnPageMove('N');
	});
	
	$("#btnQaPrev , #btn_step1").click(function(){
		fnPageMove('P');
	});
	
	$("#btnDel").click(function(){
		fnQaaDel();
	});
	
	$("#qaaId").click(function(){
		fnSave();
	});
	fnSearchDetailInfo();
}


function fnAllocAgentAutoDivide(){
	argoConfirm("자동배분을 진행하시겠습니까?<br><br> <span style='font-size:9pt; color:red;'>기존 배분인원은 초기화 되며 \"관리소속\"에 해당되는 평가자와 피평가자가<br>자동 배분됩니다. </span>", function(){
		argoJsonCallSP("QA","SP_QA1030M03_03","_", {timesId:fvTimesId}, function(data, textStatus, jqXHR){
			if(data.isOk){
				argoAlert('warning', '자동배분이 완료 되었습니다.','', 'fnSearchList();');
			}
		});
		multiService.action();
	});
}

function fnSave(){
	var qaaIdArr = argoGetValue("qaaId").split(",");
	try{
	var multiService = new argoMultiService(fnCallbackSave);
	 
	for(var i = 0; i<qaaIdArr.length; i++){
		var param = {
				"gbn":"C"
				,"timesId":fvTimesId
				,"qaaId":qaaIdArr[i]
		}
		multiService.argoInsert("QA","SP_QA1030M02_03","__",param);
	} 
	multiService.action();
	
	}catch(e){
		console.log(e);
	}
}

function fnCallbackSave(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	fnSearchDetailInfo();
	    	fnSearchList();
	    }
	} catch(e) {
		argoAlert(e);    		
	}
}

//평가계획 상세
function fnSearchDetailInfo(){
	argoJsonSearchOne('QA','SP_QA1030M02_01','__',  {"timesId":fvTimesId}, function(data,textStatus,jqXHR){
		if(data.isOk()){
			var rows = data.getRows();
			fnSetDetailInfo(rows) ;	    		
		}
	});
}

function fnSetDetailInfo(data){
	$('#timesNm').html(data.timesNm);
	$('#qaEvalTypeNm').html(data.qaEvalType);
	$('#stdYm').html(data.timesId.substring(0,4)+"년 "+data.timesId.substring(4,6)+"월");
	$('#stdValue').html(data.valueFrmDt+" ~ "+ data.valueEndDt);
	$('#sheetNm').html(data.sheetNm);
	$('#qaaCnt').html(data.qaaCnt+" 명");
	$('#targetCnt').html(data.targetCnt+" 명");
	$('#valueCnt').html(data.valueCnt+" 건 진행");
	$("#timesValueStatusNm").html(data.timesValueStatus);
	fvStatus = data.timesValuesStatus;
	if(data.timesValueStatus !="생성"){
		argoDisable(true,"btnAuto,btnDel");
	}
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
        columns: [  
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center'}
       	 		,{ field: 'deptInfo', 	 	caption: '소속', 			size: '30%',  	sortable: true, attr: 'align=left' }
       	 		,{ field: 'sabun', 			caption: '사번', 			size: '20%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '20%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'targetCnt', 		caption: '평가대상건수', 	size: '15%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'valueCnt', 		caption: '평가건수', 		size: '15%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	w2ui['grid'].hideColumn('recid' );
}

function fnSearchList(){
	argoJsonSearchList('QA', 'SP_QA1030M02_02', 's_', {"timesId":fvTimesId}, function(data, textStatus, jqXHR) {
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
				    				, "deptInfo"		: row.deptInfo
				   					, "sabun"	  		: row.sabun
									, "agentNm" 		: row.agentNm
									, "targetCnt"	  	: row.targetCnt
									, "valueCnt" 		: row.valueCnt
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

function fnPageMove(type){
	var url;
	var param;
	if(type=='N'){
		if(w2ui['grid'].records.length==0){
			argoAlert("QAA가 배정되어 있지 않습니다.<br>QAA를 배정하여 주십시오.");
			return ;
		}
		param = {timesId:fvTimesId
				,timesNm:$("#timesNm").html()	
				,status:$("#timesValueStatusNm").html()
		};
		 url = "QA1030M03F.do";
		
	}else{
		url = "QA1030M01F.do";
		param={timesId:fvTimesId};
	}
	fnDynamicForm(param, url); 
}

function fnQaaDel(){
	try{
		var arrChecked = w2ui['grid'].getSelection();
	 	if(arrChecked.length==0) {
	 		argoAlert("대상을 선택하세요") ; 
			return ;
	 	}
	 	
	 	var flag = true;
		$.each(arrChecked, function( index, value ) {
			var valueCnt = w2ui['grid'].get(value).valueCnt;
			if(valueCnt !=0){
				flag = false;
				return;
			}
		});
	 	
		if(flag == false){
			argoAlert("평가를 진행한 QAA에 대해서는 삭제가 불가능합니다.");
			return;
		}
		
	 	argoConfirm('배정된 평가대상자 정보까지 삭제됩니다. <br> QAA를 삭제하시겠습니까?', function() {
			var multiService = new argoMultiService(fnCallbackDelete);
			$.each(arrChecked, function( index, value ) {
		 		multiService.argoDelete("QA","SP_QA1030M02_03","__", {"qaaId": w2ui['grid'].get(value).sabun
																	   ,"timesId":fvTimesId
																	   ,"gbn":"D"});
			});
			multiService.action();
	 	}); 
	}catch(e){
		console.log(e) ;	 
	}
}

function fnCallbackDelete(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {	  
	    	argoAlert('성공적으로 삭제 되었습니다.') ;
	    	fnSearchDetailInfo();
	    	fnSearchList();
	    }
	} catch(e) {
		argoAlert(e);    		
	}
}

function fnDynamicForm(obj, url) {
	var form = makeForm(obj);
	form.action = url;
	form.submit();
}
	
var makeForm = function(obj) {
	var f = document.createElement('form');
	f.method = 'post';
	for (ele in obj) {
		var input = document.createElement('input');
		input.type = 'hidden';
		input.name = ele;
		input.value = obj[ele];
		f.appendChild(input);
	}
	document.body.appendChild(f);
	return f;
};
	
function UpdateAgentNM(){
	Resultdata = argoJsonUpdate("QA", "SP_QA1030S02_02", "s_", { "timesId": fvTimesId , "loginId"  : userId});
	if (Resultdata.isOk()) {
		argoAlert('성공적으로 수정되었습니다.');
		fnSearchList();
	}
}
</script>


</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><span class="step">평가계획관리</span><strong class="step">QAA 배정</strong></div>
        <section class="sub_contents">        	
        	<div class="step_area">
            	<a href="#" class="btn_stepPrev tooltip_l" title="평가계획" id="btnQaPrev" >평가계획</a>
	            <a href="#" class="btn_stepNext tooltip_r" title="상담사 배정" id="btnQaNext" >상담사 배정</a>
                <div class="step_view step3">
                    <ul>
                        <li id="btn_step1" style = "cursor: pointer;">
                            <em class="num">1</em>
                            <p class="step">STEP 01</p>
                            <p class="title"> 평가계획</p>
                        </li>
                        <li class="on">
                            <em class="num">2</em>
                            <p class="step">STEP 02</p>
                            <p class="title">QAA 배정</p>
                        </li>
                        <li id="btn_step3" style = "cursor: pointer;">
                            <em class="num">3</em>
                            <p class="step">STEP 03</p>
                            <p class="title">상담사 배정</p>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="sub_l fix430 h93 top93">
            	<div class="btn_topArea h36"></div>
                <div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="110">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>평가계획</th>
                                <td id="timesNm"></td>
                            </tr>
                            <tr>
                            	<th>진행상태</th>
                                <td id="timesValueStatusNm"></td>
                            </tr>
                            <tr>
                            	<th>평가구분</th>
                                <td id="qaEvalTypeNm"></td>
                            </tr>
                            <tr>
                            	<th>기준년월</th>
                                <td id="stdYm"></td>
                            </tr>
                            <tr>
                            	<th>평가기간</th>
                                <td id="stdValue"></td>
                            </tr>
                            <tr>
                            	<th>평가표</th>
                                <td id="sheetNm"></td>
                            </tr>
                            <tr>
                            	<th>QAA</th>
                                <td id="qaaCnt"></td>
                            </tr>
                            <tr>
                            	<th>평가대상</th>
                                <td id="targetCnt"></td>
                            </tr>
                            <tr>
                            	<th>평가진행건수</th>
                                <td id="valueCnt"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="sub_r pl430 h93">
            	 <div class="btn_topArea h36">
                	<span class="btn_l">
                    	<button type="button" class="btn_m confirm" id="btnAuto">자동배분</button>
                    </span>
                	<span class="btn_r">
                    	<button type="button" class="btn_m" id="btnAdd" data-grant="W">추가</button>
                        <button type="button" class="btn_m confirm" id="btnDel" data-grant="W">삭제</button>                
                    </span>
                </div>
                <div class="grid_area h36 pt0">
                    <div id="grList" class="real_grid"></div>
                    <input type="hidden" id="qaaNm">
                    <input type="hidden" id="qaaId">
                    <input type="hidden" id="timesId" name="timesId" value="<c:out value="${timesId}"/>">
                </div>
            </div>
             <input type="hidden" id="s_User1Nm"   name="s_User1Nm" onChange="UpdateAgentNM();" >
             <input type="hidden" id="s_User1Id"   name="s_User1Id"> 
             <input type="hidden" id="s_BfAgentId" name="s_BfAgentId">
        </section>
    </div>

</body>
</html>
