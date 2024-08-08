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
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.yearSelect.js"/>"></script>

<script type="text/javascript">
var recTableType = '<%=recTableType%>';
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가계획관리";
var workLog 	= "";
var dataArray 	= new Array();

//var currentRecYmdFrom = "";
//var currentRecYmdTo = "";

var fvGrdDeptCode =[], fvGrdDeptValue=[], fvValueCnt=0, fvTimesId , fvDeptCd , fvDeptId , fvDeptNm;
$(document).ready(function() {
	top.windowStepFlag = false;
	top.windowStepVal = ""; 
	fvTimesId = argoGetValue("ip_TimesId");
	fvDeptCd = loginInfo.SVCCOMMONID.rows.groupId;
	fvNodeId=fvTimesId;
	fnInitCtrl();
	fnInitTree();
});

var stdMonth='';
function fnInitCtrl(){
	$("#ip_RecFrmTm").prop("readonly", false);
	$("#ip_RecEndTm").prop("readonly", false);
	$("#ip_TalkFrmTm").prop("readonly", false);
	$("#ip_TalkEndTm").prop("readonly", false);
	$("#ip_ValueFrmDt").prop("readonly", false);
	$("#ip_ValueEndDt").prop("readonly", false);
	$("#ip_RecFrmDt").prop("readonly", false);
	$("#ip_RecEndDt").prop("readonly", false);
	
	$("#btn_Sheet").click(function(){
		fnQaSheetChoice();
	});
	
	
	argoCbCreate("#ip_QaEvalType", "ARGOCOMMON", "SP_UC_GET_CMCODE_01", {sort_cd : 'QA_EVAL_TYPE'}, {"selectIndex" : 0,"text" : '<선택>',"value" : ''}); // 업무그룹
	argoSetDeptChoice("btn_Dept1", {"targetObj" : "ip_Dept1","multiYn" : 'Y', "parentYn" :"Y"}); //조직선택 팝업 연결처리(멀티)
	argoJsonSearchList('ARGOCOMMON','SP_UC_GET_DEPT','__', {grantDeptCds:top.gMenu.GRANT_DEPT_CD, tenantId:tenantId}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){			
				$.each(data.getRows(), function( index, row ){
					 fvGrdDeptCode.push(row.deptCd);
	                 fvGrdDeptValue.push(row.deptNm);					
				});
		    } 
		} catch(e) {
			argoAlert(e);
		}
	});
	
	
	// 관리소속 전체 디폴트 세팅 _ hwang _ 221124
	argoJsonSearchOne("ARGOCOMMON", "SP_UC_GET_ACCESS_DEPT", "__", {}, function (Resultdata, textStatus, jqXHR) {
		if (Resultdata.isOk()) {
			fvDeptId = Resultdata.getRows()['deptCd']; 
			fvDeptNm = Resultdata.getRows()['deptNm']; 
			argoSetValue('ip_Dept1Id', fvDeptId ) ; 
			argoSetValue('ip_Dept1Nm', fvDeptNm ) ;
		}
	});
	
	var nowYear = argoSetFormat(argoCurrentDateToStr(),"-","4");
	if(fvTimesId != 'null'){
		nowYear=fvTimesId.substring(0,4);
	}
	argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	
	var yearSelect = $(".year_date").yearSelect({
		min:2010,
		max:2050,
		setYear:nowYear,
		onPrevYear:function(e){
			fnInitTree();
		},	
		onNextYear:function(e){
			fnInitTree();
		}	
	});	

	//녹취시간, 통화시간
	$('.timepicker.voice').timeSelect({use_sec:false});
	$('.timepicker.tel').timeSelect({use_sec:true});
	
	// 평가횟수
	$(".count_num").countNum({
		max:9999,
		min:0,
		set_num:1
	});	

	// 저장
	$("#btnSave").click(function(){
		fnSave();
	});
	
	//QAA배정으로 이동
	$("#btnQaNext").click(function(){
		fnQaEvalNext();
	});
	
	// 삭제
	$("#btnDel").click(function(){
		fnDel();
	});
	$("#btnCopy").click(function(){
		argoPopupWindow('평가계획 복사', 'QA1030S03F.do',  '732', '589');
	});
	
	// QAA 배정 탭 클릭 시 
	$("#btn_step2").click(function() {
		fnQaEvalNext();
	});

	// 3스텝으로 바로 넘어갈 수 있도록 수정
	$("#btn_step3").click(function() {
		// 평가계획 선택을 안했을 시 
		if(argoGetValue("ip_TimesId").length!=10){
			argoAlert("평가계획을 선택하여주세요.");
		}
		// QQA 상담사 선택 안했을 경우  
		else if($('#qaaCnt').html() < 1){
			argoAlert("QAA배정을 먼저 진행해 주세요.");
		}
		// 평가 계획 선택 & QAA선택 했을 경우
		else{
			fnPageMove();
		} 
	});
	
	if(argoNullConvert(fvTimesId) != ""){
		argoDisable(false, "btnSave");	
	}else{
		argoDisable(true, "btnSave");
	}
	
	
}

function fnInitTree(){
 	var sStdYear=	argoGetValue("s_Year").substring(0,4);
	var param = {"year":sStdYear, grantDeptCd : fvDeptCd};
	argoJsonSearchList('QA','SP_QA1030M01_01','__', param, fnCallbackGetTreeList);
}

function fnSave(){
	
	var aValidate = {
	        rows:[ 
	          {"check":"length", "id":"ip_TimesNm"     	  , "minLength":1, "maxLength":500,  "msgLength":"평가계획명을 입력하세요."}
	          //,{"check":"length", "id":"ip_QaEvalType"     , "minLength":1, "maxLength":50,  "msgLength":"평가 구분을 선택하세요."}
	          ,{"check":"length", "id":"ip_RecFrmTm"     , "minLength":1, "maxLength":50,  "msgLength":"녹취 시간을 입력하세요."}
	          ,{"check":"length", "id":"ip_RecEndTm"     , "minLength":1, "maxLength":50,  "msgLength":"녹취 시간을 입력하세요."}
	          ,{"check":"length", "id":"ip_TalkFrmTm"     , "minLength":1, "maxLength":50,  "msgLength":"통화 시간을 입력하세요."}
	          ,{"check":"length", "id":"ip_TalkEndTm"     , "minLength":1, "maxLength":50,  "msgLength":"통화 시간을 입력하세요."}
	          ,{"check":"length", "id":"ip_SheetNm"     , "minLength":1, "maxLength":500,  "msgLength":"평가표를 선택하세요."}
	        ]
	    };	
	if (argoValidator(aValidate) != true) return;
	var recFrmTm = Number(argoGetValue("ip_RecFrmTm").replace(":",""));
	var recEndTm = Number(argoGetValue("ip_RecEndTm").replace(":",""));
	var talkFrmTm = Number(argoGetValue("ip_TalkFrmTm").replace(/:/gi,""));
	var talkEndTm = Number(argoGetValue("ip_TalkEndTm").replace(/:/gi,""));
	var recYmdFrom = argoGetValue("ip_RecFrmDt").replace(/-/gi, "");
    var recYmdTo = argoGetValue("ip_RecEndDt").replace(/-/gi, "");
	var minTable = "";
	var maxTable = "";
	var minStdmonth = "";
	var maxStdmonth = "";
    
    
    	
    if(recTableType != "YYYY" && recTableType != "YYYYMM"){
    	//var tableExistCheckQuery = argoRecDynimicTableValidate(recYmdFrom, recYmdTo);
        //console.log("tableExistCheckQuery : " + tableExistCheckQuery);
        //ARGOCOMMON.SP_UC_GET_SYSDATE
        //argoJsonSearchList('ARGOCOMMON', 'SP_UC_GET_SYSDATE', '_', {}, function (data, textStatus, jqXHR){
    }else{
	    argoJsonSearchList('QA', 'recFileTableExistCheck', '_', {"recTableType":recTableType}, function (data, textStatus, jqXHR){
	    	try{
				if(data.isOk()){
					minTable = data.getRows()[0].minRecTable;
					maxTable = data.getRows()[0].maxRecTable;
					var lastIdxMin = minTable.lastIndexOf("_");
					var lastIdxMax = maxTable.lastIndexOf("_");
					minStdmonth = minTable.substring(lastIdxMin + 1);
					maxStdmonth = maxTable.substring(lastIdxMax + 1);
					//console.log("minStdmonth : " + minStdmonth);
					//console.log("maxStdmonth : " + maxStdmonth);
				}
			} catch (e) {
				//console.log("실패");
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
	    
	    /* if(sysDateMonth < recYmdTo.substring(0,6)){
	    	argoAlert("녹취 종료일은 현재월을 초과할 수 없습니다.<br><span style='font-size:9pt;'>현재월 : " + sysDateMonth.substr(0,4)+"-"+sysDateMonth.substr(4,2) + "</span>" + "<br><span style='font-size:9pt;'>녹취종료일 : " + recYmdTo.substr(0,4) + "-" + recYmdTo.substr(4,2)+ "-" + recYmdTo.substr(6,2) + "</span>");
	    	return;
	    } */
	    
	    if(recYmdFrom > recYmdTo){ 
			argoAlert("녹취 시작일은 종료일보다 이전 날짜여야 합니다. <br>올바른 기간을 설정해 주세요.");
			return ;
		}
	    
	    if(recTableType == "YYYYMM"){
	    	if(minStdmonth > recYmdFrom.substring(0,6) || maxStdmonth < recYmdTo.substring(0,6)){
		    	argoAlert("녹취기간은<br>" + minStdmonth.substr(0,4) + "년 " + minStdmonth.substr(4,2) + "월 ~ " + maxStdmonth.substr(0,4) + "년 " + maxStdmonth.substr(4,2) + "월까지로<br>설정해 주세요.<br><br> 해당 범위에 포함되지 않을 경우<br>저장이 불가능합니다.");
		    	return;
		    }	
	    }else{
	    	if(minStdmonth > recYmdFrom.substring(0,4) || maxStdmonth < recYmdTo.substring(0,4)){
		    	argoAlert("녹취기간은<br>" + minStdmonth.substr(0,4) + "년 ~ " + maxStdmonth.substr(0,4) + "년까지로<br>설정해 주세요.<br><br> 해당 범위에 포함되지 않을 경우<br>저장이 불가능합니다.");
		    	return;
		    }
	    }
    }
    
    
    
    /* if(currentRecYmdFrom != "" && $("#status").text() == "진행"){
    	if(currentRecYmdFrom < recYmdFrom){
        	argoAlert("진행된 평가계획의 녹취기간 범위는 늘리는 것만 가능합니다.<br><span style='font-size:9pt;'>기존 녹취기간 : " + currentRecYmdFrom.substr(0,4)+"-"+currentRecYmdFrom.substr(4,2)+"-"+currentRecYmdFrom.substr(6,2) + " ~ " + currentRecYmdTo.substr(0,4)+"-"+currentRecYmdTo.substr(4,2)+"-"+currentRecYmdTo.substr(6,2) + "</span>");
    		return ;
        }
        if(currentRecYmdTo > recYmdTo){
        	argoAlert("진행된 평가계획의 녹취기간 범위는 늘리는 것만 가능합니다.<br><span style='font-size:9pt;'>기존 녹취기간 : " + currentRecYmdFrom.substr(0,4)+"-"+currentRecYmdFrom.substr(4,2)+"-"+currentRecYmdFrom.substr(6,2) + " ~ " + currentRecYmdTo.substr(0,4)+"-"+currentRecYmdTo.substr(4,2)+"-"+currentRecYmdTo.substr(6,2) + "</span>");
    		return ;
        }
    } */
    
	if(recFrmTm>=recEndTm){ 
		argoAlert("녹취시작시간은 종료시간보다 이전 날짜여야 합니다. <br>올바른 기간을 설정해 주세요.");
		return ;
	}
	if(talkFrmTm>=talkEndTm){
		//argoAlert("통화시간을 확인하여 주십시오.");
		argoAlert("통화시작시간은 종료시간보다 이전 날짜여야 합니다. <br>올바른 기간을 설정해 주세요.");
		return ;
	}
	
	if(argoGetValue("ip_Dept1Id").indexOf(loginInfo.SVCCOMMONID.rows.groupId)==-1){
		argoAlert("본인 소속이 포함되어 있지 않습니다. 확인해주십시오.");
		return ;
	}
	
	argoConfirm("해당 내역을 저장 하시겠습니까?", function(){
		var kpiYn = $('input:radio[name="result_radio"]:checked').val();
		var hideYn = '';
		if($("#check_use").is(":checked")){
			hideYn = 0;
		}else{
			hideYn = 1;
		}
		
		argoJsonSearchOne("QA","SP_QA1030M01_04","ip_", {"gbn":"U","kpiYn":kpiYn,"hideYn":hideYn}, function(data, textStatus, jqXHR){
			if(data.isOk){
				fvNodeTx, fvNodePid, fvNodeLevel;
				fvNodeId = data.getRows()['timesId'];
				fvOrgNodeId = ''; //변경전 node Id
				fvOrgNodePid = ''; //변경전 부모 node
				fvOrgSortNo = ''; //변경전 순차번호
				fvIsNode = false; //Tree Node 구분
				argoAlert("성공적으로 저장 되었습니다.");
				$('#trList').jstree("destroy").empty();
				fnInitTree();
			}
		});
	});
	
}

function fnDel(){
	if(argoGetValue("ip_TimesId").length!=10){
		argoAlert("평가계획을 선택하여주세요.");
		return ;
	}
	if($("#valueCnt").html()>0){
		argoAlert("이미 평가가 진행된 건에 대해서는 삭제가 불가능합니다.");
		return ;
	}
	argoConfirm("해당 평가 계획을 삭제 하시겠습니까?", function(){
		argoJsonCallSP("QA","SP_QA1030M01_04","ip_", {"gbn":"D"}, function(data, textStatus, jqXHR){
			if(data.isOk){
				argoAlert("해당 평가 계획이 삭제 되었습니다.");
				$('#trList').jstree("destroy").empty();
				fnInitTree();
				fnInitVar();
				fnFrmClear();
				
			}
		});
	});
}

// 트리 생성
var fvNodeTx, fvNodePid, fvNodeLevel;
var fvNodeId = '';
var fvOrgNodeId = ''; //변경전 node Id
var fvOrgNodePid = ''; //변경전 부모 node
var fvOrgSortNo = ''; //변경전 순차번호
var fvIsNode = false; //Tree Node 구분
function fnCallbackGetTreeList(data, textStatus, jqXHR){
	try {
		if(data.isOk()){
 			$('#trList').jstree("destroy").empty();
			if(data.getRows() != ""){
				deptRows = data.getRows();
				var itemArray = new Array();
	          
				$.each(deptRows, function( index, row ) {
            		var parentDeptCd = row.parentDeptCd ;
	            	if (parentDeptCd == null || parentDeptCd.length==0) parentDeptCd = "#";

	            	var obj = new Object();
		            	obj.id     = row.timesId  ;
		            	obj.parent = parentDeptCd;
		            	obj.text   = row.timesNm+ (parentDeptCd.length == 6 ? '':'[' + row.valueCnt  +']');
		            	obj.state  = { "selected" : false ,  "opened" : true  };
		            	itemArray.push(obj);
	            }); 

	            var tempArray = new Array();
				tempArray.push(itemArray);
				
				$('#trList').bind("loaded.jstree", function (event, data) {
					 fnSelectNode();
				}).on("changed.jstree", function (e, data) {
					if(data.selected.length) {
						fvNodeId = data.instance.get_node(data.selected[0]).id ;
						fvNodeTx = data.instance.get_node(data.selected[0]).text;
						fvNodePid = data.instance.get_node(data.selected[0]).parent;
						fvNodeLevel = data.instance.get_node(data.selected[0]).parents.length;
						if(fvNodeId.length < 10){
							argoDisable(true, "btnSave");
						}else{
							argoSetValue("ip_TimesId",fvNodeId);	
						}
						
					}
				}).on('show_contextmenu.jstree', function(e, reference, element) { // contextmenu 활성화시
					if(fvOrgNodeId != '') fnRemoveNode(fvOrgNodeId);
				    if ( reference.node.parents.length != 2) $('.vakata-context').hide(); //2번째 level에서만 contextmenu 활성화
				}).bind("click.jstree", function (e, data) { //싱글옵션이고 더블클릭 이면 선택값 넘기면 화면닫기
					fvIsNode = true;
					stdMonth=( fvNodeLevel==2 ? fvNodeId: fvNodePid);
					argoDisable(true, "btnSave");
					
					if(fvOrgNodeId != ''){ 
						fnRemoveNode(fvOrgNodeId);
						fnInitVar();
						argoDisable(true, "btnSave");
					} 
					if(fvNodeLevel==3){ 
						fnDetailInfo();
						if(fvNodeId.length < 10){
							argoDisable(true, "btnSave");
						}else{
							argoDisable(false, "btnSave");
						}
					}else{
						fnFrmClear();
						$("#status").html("전체");
						argoDisable(true, "btnSave");
					}
       			 })	.jstree({
					'core' : {
						"check_callback" : function(operation, node, node_parent, node_position, more) {
	                       if(operation == 'move_node') {
									//노드를 클릭해야 이동가능	
									if(!fvIsNode ){
										return false;
									}else{
										 if (node_parent.id == fvNodePid) return true //상위메뉴가 같은경우만 이동가능
				                         else return false;
									}		                            
		                        }else if(operation == 'create_node'){//노드생성시 부모도드 ID와 레벨값을 변수에 담아둔다
	                        		fvOrgNodePid = node_parent.id;
	                        }
	                    },
						'data' : itemArray
					}
					,"plugins" : [ "contextmenu", "dnd", "search"]
					, "contextmenu":{
		                "items": function () {
		                    return {
		                        "create": {
		                            "label": "평가계획추가",
		                            "action": function (data) {	                            		
		                            		try{
		                            			if(fvOrgNodeId != '' && fvOrgNodeId != fvNodeId) fnRemoveNode(fvOrgNodeId); //노드가 생성중일때 동일노드에서 재생성하면 생성진행중인 노드는 삭제한다
		                            			fnAdd();//폼초기화
		                            			var ref = $.jstree.reference(data.reference);
			                                    if(argoNullConvert(ref) == "" || argoNullConvert(fvNodeId) == ""){
			                                    	argoAlert("좌측 트리에서 원하는 년월을 선택한 후 다시 시도해 주세요.");
			                        				fnFrmClear();
			                                    	return;
			                                    }
		                            			
		                            			id = ref.get_selected();
				                                if(!id.length) { return false; }
				                                id = id[0];
				                                id = ref.create_node(id, {"type":"file"});
				                                if(id) { ref.edit(id, null, function (node, status) {
			                                        	argoSetValue("ip_TimesNm", node.text);
			                                        	argoDisable(false, "btnSave");
			                						}); 
				                                }
				                                fvOrgNodeId = id;
		                            		}catch(e){
		                            			console.log(e);
		                            		}         
		                            },
		                            "icon" : gGlobal.ROOT_PATH+"/images/icon_conAdd.png"
		                        }
		                    };
		                }
		            }
				});
	        }
	    } else {
	    	console.log('fnCallbackGetTreeList_EvalPlan : no data');
	    }
	} catch(e) {
		console.log('error fnCallbackGetTreeList_EvalPlan() : ' + e);
	}
	

}	

function fnSelectNode(){
	fnScrollMove();
	if(fvNodeId!=''&&fvNodeId!=null&&fvNodeId!='null') nodeId = fvNodeId;
	if(nodeId!=''&&nodeId!=null&&nodeId!='null'){
		$('#trList').jstree('select_node', nodeId);
		fnDetailInfo();
	}
}

function fnQaSheetChoice(){
	oOptions = {"targetObj":"ip_Sheet", "multiYn":'N',"stdMonth":stdMonth};
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
    if(argoGetCookie("sheetId")){
    	argoSetValue("ip_SheetId", argoGetCookie("sheetId")) ;
    	argoSetValue("ip_SheetNm", argoGetCookie("sheetNm")) ;
    }
    
    gPopupOptions = oOptions ;
	argoPopupWindow('평가표 선택', gGlobal.ROOT_PATH+'/common/QaSheetChoiceF.do', '900', '600' );
}
// 폼 초기화
function fnAdd(){
	argoFrmClear('inputArea'); //입력항목 초기화
	argoSetValue("ip_QaEvalType","");
	$("#ip_QaEvalType").trigger("change");
	$("input:checkbox[id='check_use']").prop("checked", true); /* by ID */
	
	$("#status").html("생성");
	var year = fvNodeId.substr(0,4);
	var month = fvNodeId.substr(4,6);
 	var lastDay = ( new Date(year, month, 0) ).getDate();
 	var startDt  = year+"-"+month+"-01";
 	var endDt	 = year+"-"+month+"-"+lastDay;
 	
 	// 관리소속 전체 디폴트 세팅 _ hwang _ 221124
 	argoSetValue("ip_Dept1Nm", fvDeptNm);
	argoSetValue("ip_Dept1Id", fvDeptId);
	argoSetValue("ip_ValueFrmDt", startDt);
	argoSetValue("ip_ValueEndDt", endDt);
	argoSetValue("ip_RecFrmDt", startDt);
	argoSetValue("ip_RecEndDt", endDt);
	argoSetValue("ip_FeedFrmDt", startDt);
	argoSetValue("ip_FeedEndDt", endDt);
	argoSetValue("ip_ValueCnt","1");
 	argoSetValue("ip_RecFrmTm","00:00");
 	argoSetValue("ip_RecEndTm","23:59");
 	argoSetValue("ip_TalkFrmTm","00:00:00");
 	argoSetValue("ip_TalkEndTm","00:10:00");
 	//currentRecYmdFrom = "";
 	//currentRecYmdTo = "";
 	
	$("#qaaCnt").html(0);
	$("#agentCnt").html(0);
	$("#valueCnt").html(0);
	
	$("input:radio[name='result_radio']:radio[value='1']").prop("checked", true); // 체크하기
	
	fvValueCnt=0;
	fnFrmDisable(false);
}


//노드삭제
function fnRemoveNode(n_id){
	try{
		$('#trList').jstree().delete_node($('#'+n_id));
		fvOrgNodeId = '';
	}catch(e){
		console.log(e)
	}
}

function fnInitVar(){
	fvNodeTx, fvNodePid, fvNodeLevel;
	fvNodeId = '';
	fvOrgNodeId = ''; //변경전 node Id
	fvOrgNodePid = ''; //변경전 부모 node
	fvOrgSortNo = ''; //변경전 순차번호
	fvIsNode = false; //Tree Node 구분
	
	//currentRecYmdFrom = "";
	//currentRecYmdTo = "";
}

function fnFrmClear(){
		argoFrmClear('inputArea'); //입력항목 초기화
		argoSetValue("ip_QaEvalType","");
		argoSetValue('ip_Dept1Id', fvDeptId ) ; 
		argoSetValue('ip_Dept1Nm', fvDeptNm ) ;
		$("#ip_QaEvalType").trigger("change");
		$("input:checkbox[id='check_use']").prop("checked", true); /* by ID */
		//currentRecYmdFrom = "";
		//currentRecYmdTo = "";
}
// 상세조회
function fnDetailInfo(){
	argoJsonSearchOne('QA','SP_QA1030M01_02','__',  {"timesId":fvNodeId}, function(data,textStatus,jqXHR){
		if(data.isOk()){
			if(data.getRows().length==0){
				fnInitVar();
				fnFrmClear();
				return;
				}
			var year = data.getRows()['timesId'].substr(0,4);
			var month = data.getRows()['timesId'].substr(4,2);
		 	var lastDay = ( new Date(year, month, 0) ).getDate();
		 	var startDt  = year+"-"+month+"-01";
		 	var endDt	 = year+"-"+month+"-"+lastDay;
		 	
			argoSetValues("ip_", data.getRows());
			//currentRecYmdFrom = data.getRows()
			//currentRecYmdTo
			//currentRecYmdFrom 	= data.getRows().recFrmDt.replace(/-/gi, "");
			//currentRecYmdTo 	= data.getRows().recEndDt.replace(/-/gi, "");
			
			$("#ip_QaEvalType").trigger("change");
			
			fvValueCnt = data.getRows()['valueCnt'];
		 	
			$("#qaaCnt").html(data.getRows()['qaaCnt']);
			$("#agentCnt").html(data.getRows()['agentCnt']);
			$("#valueCnt").html(data.getRows()['timesValueCnt']);
			
			if(data.getRows()['kpiYn']=='1'){
				$("input:radio[name='result_radio']:radio[value='1']").prop("checked", true); // 체크하기
				$("input:radio[name='result_radio']:radio[value='0']").prop("checked", false); // 해제하기
			}else{
				$("input:radio[name='result_radio']:radio[value='0']").prop("checked", true); // 체크하기
				$("input:radio[name='result_radio']:radio[value='1']").prop("checked", false); // 해제하기
			}
			if(data.getRows()['hideYn']=='1'){
				$("input[type=checkbox]").prop("checked",false);
			}else{
				$("input[type=checkbox]").prop("checked",true);
			}
			
			var deptNm='';
			var deptId="";
			
			if(data.getRows()['dept1Id'] != null){
				var deptIdArr = data.getRows()['dept1Id'].split(",");
				
				var cnt =0;
				
				// 관리소속 세팅
				if(fvGrdDeptCode.length>0){
					for(var i = 0; i<fvGrdDeptCode.length; i++){
						for(var j =0; j<deptIdArr.length; j++){
							if(deptIdArr[j]== fvGrdDeptCode[i]){
								if(cnt==0){
									deptNm=fvGrdDeptValue[i];
									deptId=fvGrdDeptCode[i];
								}else{
									deptNm+=","+fvGrdDeptValue[i];
									deptId+=","+fvGrdDeptCode[i];
								}
									cnt++;
									break ;
							} 
						}
					}
				}
			}
			argoSetValue("ip_Dept1Nm",deptNm);
			argoSetValue("ip_Dept1Id",deptId);
			$("#status").html(data.getRows()['timesValueStatus']);
			
			fnFrmDisable((data.getRows()['timesValueCnt']==0?false:true));
		}
	});
}

function fnQaEvalNext(){
	if(fvNodeId!='undefiend'&&fvNodeId!=''&&fvNodeId.length==10){
	window.location.replace("QA1030M02F.do?timesId="+fvNodeId); //ADD BY 2017.07.25 뒤로가기 비활성 처리 위해.
	}else{
		argoAlert("평가계획을 선택하여주세요.");
	}
}


function fnFrmDisable(flag) {
	argoDisable(flag, "btnDel, btn_Sheet, btn_minus");
	$("#ip_ValueCnt").prop("readonly", flag);
}

function fnScrollMove(){
	
	if(fvNodeId!=''&&fvNodeId!=null&&fvNodeId!='null') nodeId = fvNodeId;
	else	nodeId = argoSetFormat(argoCurrentDateToStr(),"","4-2");
	
	var node = document.getElementById(nodeId);
	if(node!=null){
		$('.tree_area').scrollTop($("#"+nodeId).offset().top -  $("#trList").offset().top-50);
	}
}


function fnPageMove(){
	var url;
	var param;

	param = {timesId:fvNodeId
						,timesNm:$("#ip_TimesNm").val()	
						,status: $("#status").text()
	};
	 url = "QA1030M03F.do";
		
	fnDynamicForm(param, url); 
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

</script>

</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><span class="step">평가계획관리</span><strong class="step">평가계획</strong></div>
        <section class="sub_contents">        	
        	<div class="step_area">
	            <a href="#" class="btn_stepNext tooltip_r" title="QAA 배정" id="btnQaNext">QAA 배정</a>
                <div class="step_view step3">
                    <ul>
                        <li class="on"  >
                            <em class="num">1</em>
                            <p class="step">STEP 01</p>
                            <p class="title"> 평가계획</p>
                        </li>
                        <li id="btn_step2" style = "cursor: pointer;">
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
            <div class="sub_l fix430 h93 top93" style="height: 728px;">
            	<div class="btn_topArea h36" >
	                <div class="top_inputBox text-center"  style="top:0px !important;">
                    	<span class="year_date">
                            <span class="btn_box"><a href="#" class="btn_yearPrev">Prev</a></span>
                            <input type="text" id="s_Year" name="s_Year" class="input_year" maxlength="4">   
                            <span class="btn_box"><a href="#" class="btn_yearNext">Next</a></span>                      
                        </span> 
                    </div>
                </div>
                <div class="tree_area">
                	<div id="trList" >
                    </div>
                </div>
            </div>
            <div class="sub_r pl430 h93">
            	<div class="btn_topArea h36">
                	<span class="btn_l">
                    	<span class="state_info pt3"><em class="state_ico" id="status">전체</em>평가 : <strong id="valueCnt">0</strong>건<span class="divide_colLine">|</span>QAA : <strong id="qaaCnt">0</strong>명<span class="divide_colLine">|</span>평가대상 : <strong id="agentCnt">0</strong>명</span> 
                    </span>
                	<span class="btn_r">
                		<button type="button" id="btnCopy" name="btnCopy" class="btn_m" data-grant="W">복사</button>
                        <button type="button" id="btnDel" name="btnDel" class="btn_m confirm" disabled="disabled" data-grant="W">삭제</button>   
                    	<button type="button" id="btnSave" name="btnSave" class="btn_m confirm" data-grant="W">저장</button>
                    	<button type="button" id="btnMagam" name="btnMagam" class="btn_m confirm" data-grant="W" style="display:none;">마감</button>   
                    </span>               
                </div>
                
                <div class="input_area" id="inputArea">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>평가계획<span class="point">*</span></th>
                                <td>
                                	<input type="hidden" id="ip_TimesId" name="ip_TimesId" value="<c:out value="${timesId}"/>">
                                	<!-- <input type="hidden" id="ip_DeptCd" name="ip_DeptCd"/>    -->                          	                                	
                                	<input type="text" id="ip_TimesNm" name="ip_TimesNm" style="width:400px;" class="mr10">
                                	<input type="checkbox" id="check_use"><label for="check_use">사용</label>
                                </td>
                            </tr>
                            <tr style="display: none;">
                            	<th>KPI적용<span class="point">*</span></th>
                                <td>
                                	<span class="checks"><input type="radio" id="result" name="result_radio"  value="1"><label for="result">실적반영</label></span>
                                    <span class="checks ml15"><input type="radio" id="not_result" name="result_radio" value="0"><label for="not_result">실적제외</label></span>
                                </td>
                            </tr>
                            <tr>
                            	<th>평가구분</th>
                                <td>
                                	<select id="ip_QaEvalType" name="ip_QaEvalType" style="width:145px;">
                                        <option>평가구분</option>
                                    </select>                                   
                                </td>
                            </tr>
                            <tr>
                            	<th>평가기간<span class="point">*</span></th>
                                <td>
                                	<span class="select_date"><input type="text" class="datepicker onlyDate" id="ip_ValueFrmDt" name="ip_ValueFrmDt" readonly></span>
                                    <span class="text_divide">~</span>
                                    <span class="select_date"><input type="text" class="datepicker onlyDate" id="ip_ValueEndDt" name="ip_ValueEndDt" readonly></span>
                                    
                                    <!--  <strong class="title ml20">평가일자</strong>
			                           <select id="selDateTerm1" name="" style="width:70px;" class="mr5"></select>
			                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
			                           <span class="text_divide">~</span>
			                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To"  name="s_txtDate1_To"></span> -->
                                    
                                </td>
                            </tr>
                            <tr>
                            	<th>녹취기간<span class="point">*</span></th>
                                <td>
                                	<span class="select_date"><input type="text" class="datepicker onlyDate" id="ip_RecFrmDt" name="ip_RecFrmDt" readonly></span>
                                    <span class="text_divide">~</span>
                                    <span class="select_date"><input type="text" class="datepicker onlyDate" id="ip_RecEndDt" name="ip_RecEndDt" readonly></span>
                                </td>
                            </tr>
                            <tr style="display: none;">
                            	<th>피드백기간<span class="point">*</span></th>
                                <td>
                                	<span class="select_date"><input type="text" class="datepicker" id="ip_FeedFrmDt" name="ip_FeedFrmDt" readonly></span>
                                    <span class="text_divide">~</span>
                                    <span class="select_date"><input type="text" class="datepicker" id="ip_FeedEndDt" name="ip_FeedEndDt" readonly></span>
                                </td>
                            </tr>
                            <tr>
                            	<th>녹취시간<span class="point">*</span></th>
                                <td>
                                	<span class="timepicker voice" id="voice_time1"><input type="text" id="ip_RecFrmTm" name="ip_RecFrmTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                                    <span class="text_divide">~</span>
                                    <span class="timepicker voice" id="voice_time2"><input type="text" id="ip_RecEndTm" name="ip_RecEndTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                                </td>
                            </tr>
                            <tr>
                            	<th>통화시간<span class="point">*</span></th>
                                <td>
                                	<span class="timepicker tel" id="tel_time1"><input type="text" id="ip_TalkFrmTm" name="ip_TalkFrmTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                                    <span class="text_divide">~</span>
                                    <span class="timepicker tel" id="tel_time2"><input type="text" id="ip_TalkEndTm" name="ip_TalkEndTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                                </td>
                            </tr>
                            <tr>
                            	<th>평가표<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_SheetNm" name="ip_SheetNm" style="width:430px;" readonly><button type="button" class="btn_termsSearch" id="btn_Sheet">검색</button>
                                    <input type="hidden" id="ip_SheetId" name="ip_SheetId" readonly>
                                </td>
                            </tr>
                            <tr>
                            	<th>평가횟수<span class="point">*</span></th>
                                <td>
                                	<span class="count_num mr40">
                                    	<button type="button" class="btn_minus" id="btn_minus">-</button><input type="text" id="ip_ValueCnt" name="ip_ValueCnt" style="width:50px;" class="input_num"><button type="button" class="btn_plus" id="btn_plus">+</button>
                                    </span>                                    
                                </td>
                            </tr>
                            <tr>
                            	<th>관리소속<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_Dept1Nm" name="ip_Dept1Nm" style="width:350px;" readonly><button href="#" class="btn_termsSearch" id="btn_Dept1">검색</button>
                                	 <input type="hidden" id="ip_Dept1Id" name="ip_Dept1Id" >
                                </td>
                            </tr>
                            <tr>
                            	<th>평가내용</th>
                                <td class="lh0"><textarea id="ip_ValueFocus" name="ip_ValueFocus" style="height:347px;"></textarea></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </div>
</body>
</html>