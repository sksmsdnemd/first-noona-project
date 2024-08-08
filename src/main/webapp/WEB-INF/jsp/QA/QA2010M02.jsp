<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String recTableType = Globals.REC_TABLE_TYPE(); 
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<style type="text/css">
#grid_grid_frecords{
	top: 56px !important;
}

#grid_grid_records{
	top: 56px !important;
	overflow: hidden;
}

</style>

<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/velocejs/veloce.popupWindow.js?ver=2017010611"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.spin.js"/>"></script>
<script type="text/javascript">
var recTableType = '<%=recTableType%>';
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;
var workMenu 	= "통화품질평가-녹음파일조회";
var workLog 	= "";
var dataArray 	= new Array();
var fvTimesId='';
var fvAgentId='';
var fvAgentNm='';
var fvValueYn='Y';
var sQaaId = '';
var sQaaNm ='';
var sTimesId = '';
var sTimesNm = '';
var fvRecordId = "";
var fvValueYn = "";
var fvSheetkey = "";
var fvRecTalkTm = "";
var sRecTableNm = "";
var callbackAfterSearchCondition = {};
var sTimesRecMonthFromTo = new Array();
//var callPlayRecord = playRecord.bind(null, w2ui['grid'], 0);

$(document).ready(function() {
	top.windowStepFlag = true;
	top.windowStepVal = "QA2010M02"; 
	fvTimesId = 	argoGetValue("timesId");
	fvAgentId = 	argoGetValue("agentId");
	fvAgentNm = 	argoGetValue("agentNm");
	fvItemIndex = 	argoGetValue("currIndex");
	sTimesNm = 		argoGetValue("sTimesNm");
	sTimesId = 		argoGetValue("sTimesId");
	sQaaId= 		argoGetValue("sQaaId");
	sQaaNm = 		argoGetValue("sQaaNm");
	sRecTableNm = argoQaTimesRecTable(fvTimesId, recTableType);
	sTimesRecMonthFromTo = argoQaTimesRecMonthFromTo(fvTimesId); 
	
	console.log("sTimesRecMonthFromTo : " + sTimesRecMonthFromTo);
	
	fnInitCtrl();
	fnInitGrid();
	fnShowTooltip();
	fnTimesSet(fvTimesId);
	argoSetValue("s_User1Nm", fvAgentNm);
	argoSetValue("s_User1Id", fvAgentId);
	fnSearchListCnt();
});


function fnInitCtrl(){
	argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정 
	$("#s_RecFrmTm").prop("readonly", false);
	$("#s_RecEndTm").prop("readonly", false);
	$("#s_TalkFrmTm").prop("readonly", false);
	$("#s_TalkEndTm").prop("readonly", false);
	$('.timepicker.voice').timeSelect({use_sec:false});
	$('.timepicker.tel').timeSelect({use_sec:true});
	
	$("#btnSearch").click(function(){
		fnSearchListCnt();
		//fnRecSearchReasonAddPop();
	});
	
	$("#btn_Step3").click(function(){
		fnPageMove('N');
	})
	
	$("#btn_Step1").click(function(){
		fnPageMove('P');
	});
	
	$("#btnValue").click(function(){
		fnPageMove('N');
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

function fnTimesSet(timesId){
	argoJsonSearchOne('QA','SP_QA1030M01_02','__',  {"timesId":timesId}, function(data,textStatus,jqXHR){
		if(data.isOk()){
			argoSetValues("s_", data.getRows());		
		}
	});
}

function fnSearchList(startRow, endRow){
	//w2ui.grid.lock();
	//var valueYn = ($('input[type="checkbox"]:checked').val()=='1' ? '1':'0'); 
	//var recFrmDt = argoGetValue("s_RecFrmDt").replace(/-/gi, "");
	//var recEndDt = argoGetValue("s_RecEndDt").replace(/-/gi, "");
	
	LoadingWithMask();
	setTimeout(function() {
	
		w2ui.grid.clear();
		callbackAfterSearchCondition.startRow = startRow;
		callbackAfterSearchCondition.endRow = endRow;
		
		//argoJsonSearchList('QA', 'SP_QA2010M02_02', 's_', {"startRow":startRow, "endRow":endRow, "valueYn":valueYn, "recFrmDt":recFrmDt, "recEndDt":recEndDt, "tableNm":sRecTableNm}, function (data, textStatus, jqXHR){
		argoJsonSearchList('QA', 'SP_QA2010M02_02', '_', callbackAfterSearchCondition, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					
					
					if(data.getProcCnt() == 0){
						return;
					}
					//debugger;
					dataArray = [];
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							
							//console.log("row.mediaScr : " + row.mediaScr);
							/* if(row.mediaScr == "1"){
								debugger;
							} */
							
							gObject2 = {  "recid" 			: index
										, "tenantId"	  	: row.tenantId
										, "recKey"	  		: row.recKey
										, "recordId"	  	: row.recordId
										//, "recordScr"		: row.mediaScr==0?"":'<img src="../images/bg_approval.png" style="width:20px; height:20px; cursor:pointer;"></img>'
										, "recordScr"		: row.mediaScr=="1"?'<img src="../images/bg_approval.png" style="width:20px; height:20px;"></img>':""
			       	 					, "recordListen"	: "<img alt='' src='../images/speak_up.png' style='cursor:pointer;'></img>"
										, "sttListen"		: "<img alt='' src='../images/icon_code.png' style='cursor:pointer;'></img>"
					    				, "recYmd"			: row.recYmd
										, "starttime" 		: row.starttime
										, "endtime"	  		: row.endtime
										, "talkTm" 			: row.talkTm
										, "inoutKind" 		: row.inoutKind
										, "sabun"			: row.sabun
										, "agentNm"			: row.agentNm
										, "valueYn" 		: row.valueYn==1?true:false
										, "mediaScr" 		: row.mediaScr
										};
							dataArray.push(gObject2);
						});
						
						w2ui['grid'].add(dataArray);	
						
					}
					/* if(w2ui['grid'].getSelection().length == 0){
						w2ui['grid'].click(0,0);
					} */
				}
				
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
		closeLoadingWithMask();
	}, 0); // 대기 시간을 0으로 설정
	//w2ui.grid.unlock();
	
}

function fnSearchListCnt(){
	var valueYn = ($('input[type="checkbox"]:checked').val()=='1' ? '1':'0');
	var recFrmDt = argoGetValue("s_RecFrmDt").replace(/-/gi, "");
	var recEndDt = argoGetValue("s_RecEndDt").replace(/-/gi, "");
	var recFrmTm = argoGetValue("s_RecFrmTm").replace(/:/gi, "");
	var recEndTm = argoGetValue("s_RecEndTm").replace(/:/gi, "");
	var talkFrmTm = argoGetValue("s_TalkFrmTm").replace(/:/gi, "");
	var talkEndTm = argoGetValue("s_TalkEndTm").replace(/:/gi, "");
	var callKind = argoGetValue("s_CallKind");
	var user1Id = argoGetValue("s_User1Id");
	
	if(sTimesRecMonthFromTo[0] > recFrmDt.substring(0, 6) || sTimesRecMonthFromTo[1] < recEndDt.substring(0, 6)){
		argoAlert("녹취기간 조회조건을 확인해주세요.<br>현재 평가계획에 설정된 기간을 초과하였습니다.<br>녹취기간을 평가계획관리에서 조정해 주세요.");
		return;
	}
	
	callbackAfterSearchCondition = {};
	callbackAfterSearchCondition = {
			"timesId":fvTimesId, 
			"valueYn":valueYn, 
			"recFrmDt":recFrmDt, 
			"recEndDt":recEndDt, 
			"recFrmTm":recFrmTm, 
			"recEndTm":recEndTm,
			"talkFrmTm":talkFrmTm,
			"talkEndTm":talkEndTm, 
			"tableNm":sRecTableNm,
			"callKind":callKind,
			"user1Id":user1Id
	};
	
	argoJsonSearchOne('QA', 'SP_QA2010M02_01', '_', callbackAfterSearchCondition, function(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				var totalData=data.getRows()['cnt'];
				pagingQa(totalData, dataPerPage, pageCount, "1")
				//argoJsonSearchOne('QA', 'SP_QA2010M02_03', 's_', {"recFrmDt":recFrmDt, "recEndDt":recEndDt}, fnValueYn); 
				argoJsonSearchOne('QA', 'SP_QA2010M02_03', '_', callbackAfterSearchCondition, fnValueYn);
			}
		} catch (e) {
			console.log(e);
		}
	});
}

function fnValueYn(data,textStatus, jqXHR){
	fvValueYn= data.getRows()['valueYn'];
}

function fnInitGrid(){
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: false,
            footer: false,
            selectColumn: false
        },
        multiSelect: false,
        onAdd: function(target, eventData){
            this.add({
                  recid: this.total + 1
                , sheetNm: '[입력]'					
            })
        },
        onClick: function(event) {
        	var record = this.get(event.recid);
        	if(record.recid >=0 ) {
        		fvRecordId = record.recordId;
        		fvSheetkey = record.sheetkey;
        		fvRecTalkTm = record.talkTm;
			}
        	
        	var key = Object.keys(record);
        	/* if(key[event.column] == "recordScr"){
        		if(record.mediaScr == "1"){
        			argoScrPopup(record.recKey, sRecTableNm);
        		}
        	} */
        	
        	if(key[event.column] == "recordListen"){
        		argoRecPlay(record.recKey, playerKind, sRecTableNm);
        	}
        	
        	if(key[event.column] == "sttListen"){
        		argoTaPopup(record.recKey, sRecTableNm);
        	}
        	
        	
        	
        	
        },
        onDblClick: function(event) {
        	var record = this.get(event.recid);
        },
        onChange: function (event) {
        	// 20230625 jslee 수정대상여부 추출하기 위해 컬럼의 정보를 json형태로 추출 {fieid:caption} 형태로 추출됨.
        	var record = this.get(event.recid);
        	// 20230625 jslee json의 컬럼값만 추출
        	var key = Object.keys(record);
        	// 20230625 jslee json의 키값에 해당하는 값이 컬럼의 인덱스와 일치할 시 이벤트 취소.
        	if(key[event.column] == "valueYn"){
        		event.preventDefault();
        	}
        },
        columnGroups : [
            { caption:"녹취정보", 	  span:12 }
          , { caption:"상담사 정보", span:2 }
          , { caption:"", master:true }
          , { caption:"", master:true }
       ],
        
        columns: [{ field: 'recid', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
        		,{ field: 'tenantId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=left' }
        		,{ field: 'recKey', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=left' }
        		,{ field: 'recordId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=left' }
        		,{ field: 'recordScr', 		caption: '스크린 유무', 	size: '8%', 	sortable: true, attr: 'align=center' }
        		,{ field: 'recordListen', 	caption: '청취', 			size: '5%', 	sortable: true, attr: 'align=center' }
        		,{ field: 'sttListen', 		caption: 'STT', 		size: '5%', 	sortable: true, attr: 'align=center' }
        		,{ field: 'recYmd', 	 	caption: '녹취일자', 		size: '16%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'starttime', 		caption: '시작', 			size: '16%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'endtime', 		caption: '종료', 			size: '16%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'talkTm', 		caption: '통화시간', 		size: '16%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'inoutKind', 		caption: '인/아웃', 		size: '13%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'sabun', 			caption: '사번', 			size: '16%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentNm', 	    caption: '상담사명', 		size: '16%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'valueYn', 	    caption: '평가여부', 		size: '8%', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center' }
       	 		,{ field: 'mediaScr', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('tenantId' );
	w2ui['grid'].hideColumn('recKey' );
	w2ui['grid'].hideColumn('recordId' );
	w2ui['grid'].hideColumn('mediaScr' );
	/* w2ui['grid'].hideColumn('sttListen' ); */
}


var dataPerPage=16; 
var pageCount=5;
function pagingQa(totalData, dataPerPage, pageCount, currentPage){

	var defaultYn="N";
	if(totalData==0){
		totalData=1;
		defaultYn="Y";
	}
   var totalPage = Math.ceil(totalData/dataPerPage);    // 총 페이지 수
   var pageGroup = Math.ceil(currentPage/pageCount);    // 페이지 그룹
   
   var last = pageGroup * pageCount;    // 화면에 보여질 마지막 페이지 번호

   if(last > totalPage)
       last = totalPage;
   
   var first = last - (pageCount-1);    // 화면에 보여질 첫번째 페이지 번호
   var next = last+1;
   var prev = first-1;
	if(last%pageCount==0){
		first =last - (pageCount-1);
	}else{
		first = last - ((last%pageCount)-1);
	}
	prev = first-1;
	if(first<1) first = 1
	
	
   var html = "";
   
    if(prev > 0){
        html += '<a href="#" class="first" id="first">first</a><a href="#" class="prev" id="prev">prev</a>';
    }
   
	html += '<ul class="paging">';

	for(var i=first; i <= last; i++){
		html += '<li><a href="#" id='+i+'>'+i+'</a></li>';
   }
   html +='</ul>';
   
   if(last < totalPage){
   		html += '<a href="#" class="next" id="next">next</a><a href="#" class="last" id="last">last</a>';
   }
   
   $("#paging").html(html);    // 페이지 목록 생성
   $("#paging a#" + currentPage).addClass("on");    // 현재 페이지 표시
   
   var startRow  = ((currentPage -1)*dataPerPage)+1;
   var endRow    = currentPage * dataPerPage;
  
   if(totalData!=0){
	  fnSearchList(startRow,endRow);
   }
   
   if(defaultYn=='N'){
	   $("#paging a").click(function(){
	       
	       var $item = $(this);
	       var $id = $item.attr("id");
	       var selectedPage = $item.text();
	       
	       if($id == "next")    selectedPage = next;
	       if($id == "prev")    selectedPage = prev;
	       if($id == "first")    selectedPage = 1;
	       if($id == "last")	 selectedPage = totalPage;
	       pagingQa(totalData, dataPerPage, pageCount, selectedPage);
	   });
   }
}

function fnPageMove(type){
	var timesId = argoGetValue("s_TimesId");
	var agentId = argoGetValue("s_User1Id");
	var timesNm = argoGetValue("s_TimesNm");
	var d = 	argoGetValue("disable");
	if(type=='N'){
		
		//var secValidate = "0";
		//var callingSec = argoTimeToSeconds(fvRecTalkTm);
		//debugger;
		//if(callingSec <= 2){
		//	secValidate = "1";
		//	argoAlert("통화시간이 2초 이내인 녹취 이력은 평가할 수 없습니다.");
		//	return;
		//}
		
		/* if(argoNullConvert(fvRecordId) == ""){
			argoAlert("녹취건을 선택하여주세요.");
			return ;
		} */
		if(argoNullConvert(fvRecordId) == ""){
			argoConfirm("녹취이력이 선택되지 않았습니다. 그대로 평가를 진행하시겠습니까?", function(){
				var recordId = "TEMP_REC_KEY";
				var sheetkey = fvSheetkey;
				
				if(sheetkey==null&&fvValueYn=='N'){
					argoAlert("평가 횟수를 초과하였습니다.");
					return ;
				}
				
				var param = {recordId:recordId
									,timesId:timesId
									,agentId:agentId
									,sheetkey:sheetkey
									,agentNm:fvAgentNm
									,sTimesId : sTimesId
									,sTimesNm : sTimesNm
									,sQaaId : sQaaId
									,sQaaNm : sQaaNm
									,currIndex:fvItemIndex
									,disable : argoGetValue("disable")
									};
		 		var url ='QA2010M03F.do';
		 		fnDynamicForm(param,url);
			});
		}else{
			var recordId = fvRecordId;
			var sheetkey = fvSheetkey;
			
			if(sheetkey==null&&fvValueYn=='N'){
				argoAlert("평가 횟수를 초과하였습니다.");
				return ;
			}
			
			var param = {recordId:recordId
								,timesId:timesId
								,agentId:agentId
								,sheetkey:sheetkey
								,agentNm:fvAgentNm
								,sTimesId : sTimesId
								,sTimesNm : sTimesNm
								,sQaaId : sQaaId
								,sQaaNm : sQaaNm
								,currIndex:fvItemIndex
								,disable : argoGetValue("disable")
								};
	 		var url ='QA2010M03F.do';
	 		fnDynamicForm(param,url);
		}
 		
 		
 		
 		
 		
 		
 		
	}else{
		
		var param = {timesId:fvTimesId
							,sQaaId : sQaaId
							,sQaaNm : sQaaNm
							,currIndex:fvItemIndex
							,searchYn:"1"
							,disable : argoGetValue("disable")
							,sTimesId : sTimesId
							,sTimesNm : sTimesNm
		};
 		var url ='QA2010M01F.do';
 		fnDynamicForm(param,url);
	}
}



function fnRecSearchReasonAddPop(){
	var pCallbackFunctionNm = "fnSearchListCnt();";
	var pTenantId = "";
	var pDnNo = "";
	var pUserId = argoGetValue("s_User1Id");
	var pGroupId = "";
	var pCustName = "";
	var pCustTel = "";
	var pCustNo = "";
	var pFindField = "";
	var pFindFieldText = "";
	var pCallKind = argoGetValue("s_CallKind");
	var pCustEtc9 = "";
	var pCallId = "";
	var pTranTel = "";
	var pFrmRecDate = argoGetValue("s_RecFrmDt");
	var pFrmRecTm = argoGetValue("s_RecFrmTm");
	var pToRecDate = argoGetValue("s_RecEndDt");
	var pToRecTm = argoGetValue("s_RecEndTm");
	var pFrmCallTm = argoGetValue("s_TalkFrmTm");
	var pToCallTm = argoGetValue("s_TalkEndTm");
	var pSoliKind = "";
	gPopupOptions = {
			pTenantId: pTenantId,
			pDnNo: pDnNo,
			pUserId: pUserId,
			pGroupId: pGroupId,
			pCustName: pCustName,
			pCustTel: pCustTel,
			pCustNo: pCustNo,
			pFindField: pFindField,
			pFindFieldText: pFindFieldText,
			pCallKind: pCallKind,
			pCustEtc9: pCustEtc9,
			pCallId: pCallId,
			pTranTel: pTranTel,
			pFrmRecDate: pFrmRecDate,
			pFrmRecTm: pFrmRecTm,
			pToRecDate: pToRecDate,
			pToRecTm: pToRecTm,
			pFrmCallTm: pFrmCallTm,
			pToCallTm: pToCallTm,
			pSoliKind : pSoliKind,
			pCallbackFunctionNm : pCallbackFunctionNm
	};    	
	argoPopupWindow('통화내역 조회사유 등록', '../recording/RecSearchReasonPopAddF.do', '600', '300');	
}

function LoadingWithMask() {
    //화면의 높이와 너비를 구합니다.
    var maskHeight = $(document).height();
    var maskWidth  = window.document.body.clientWidth;
     
    //화면에 출력할 마스크를 설정해줍니다.
    var mask       = "<div id='mask' style='position:absolute; z-index:9000; background-color:#000000; display:none; left:0; top:0;'></div>";
    /* var loadingImg = '';
      
    loadingImg += "<div id='loadingImg' style='position:absolute; top:0; left:0;'>";
    loadingImg += " <img src='../images/veloce/Spinner.gif' style='position: relative; z-index:9100; display: block; margin: 0px auto;'/>";
    loadingImg += "</div>";   */
  
    //화면에 레이어 추가
    $('body').append(mask);
    //.append(loadingImg);
        
    //마스크의 높이와 너비를 화면 것으로 만들어 전체 화면을 채웁니다.
    $('#mask').css({
            'width' : maskWidth
            , 'height': maskHeight
            , 'opacity' : '0.3'
    }); 
  
    
  //마스크의 높이와 너비를 화면 것으로 만들어 전체 화면을 채웁니다.
    $('#loadingImg').css({
            'width' : maskWidth
            , 'height': maskHeight
    }); 
    
    //마스크 표시
    $('#mask').show();   
  
    //로딩중 이미지 표시
    $('#loadingImg').css("display", "block");
}

function closeLoadingWithMask() {
    $('#mask').hide();
    $('#mask').remove();
    $("#loadingImg").css("display", "none");
}
</script>


<style>
#step1, #step3{
	cursor: pointer;
}
</style>
</head>
<body>
	<div id='loadingImg' style='position:absolute; top:0; left:0; display: none; opacity: 0.9; z-index:8900;'>
		<img src='../images/veloce/spinnerRed.gif' style='position: relative; z-index:8000; display: block; margin: 0px auto; top: 30% '/>
	</div>
	
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><span class="step">통화품질평가</span><strong class="step">녹음파일 조회</strong></div>
        <section class="sub_contents">
        	<div id="foo"></div>        	
        	<div class="step_area">
            	<a href="#" class="btn_stepPrev tooltip_l" title="배정인원 조회" id="btn_Step1">배정인원 조회</a>
	            <a href="#" class="btn_stepNext tooltip_r" title="통화품질평가" id="btn_Step3">통화품질평가</a>
                <div class="step_view step3">
                    <ul>
                        <li id="step1" onclick="fnPageMove('P');">
                            <em class="num">1</em>
                            <p class="step">STEP 01</p>
                            <p class="title"> 배정인원 조회</p>
                        </li>
                        <li class="on">
                            <em class="num">2</em>
                            <p class="step">STEP 02</p>
                            <p class="title">녹음파일 조회</p>
                        </li>
                        <li id="step3" onclick="fnPageMove('N');">
                            <em class="num">3</em>
                            <p class="step">STEP 03</p>
                            <p class="title">통화품질평가</p>
                        </li>
                    </ul>
                </div>
            </div> 
            <div class="search_area row3 top_br">
            	<div class="row">
                    <ul class="search_terms">
                        <li>
                           <strong class="title ml20">평가계획</strong>
                           <input type="text" id="s_TimesNm" name="s_TimesNm" style="width:290px;" readonly>
                            <input type="hidden" id="s_TimesId" name="s_TimesId">
                        </li>
                        <li>
                           <strong class="title">녹취기간</strong>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_RecFrmDt" name="s_RecFrmDt"></span>
                           <span class="text_divide">~</span>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_RecEndDt" name="s_RecEndDt"></span> 
                           <!-- <strong class="title">녹취기간</strong>
                           <span><input type="text" id="s_RecFrmDt" name="s_RecFrmDt" readonly="readonly" style="width: 90px;"></span>
                           <span class="text_divide">~</span>
                           <span><input type="text" id="s_RecEndDt" name="s_RecEndDt" readonly="readonly" style="width: 90px;"></span> -->
                        </li>
                        
                        <li>
                        	<strong class="title ml20">통화구분</strong>
                        	<select id="s_CallKind" name="s_CallKind" style="width: 140px" class="list_box">
								<option value="">선택하세요!</option>
								<option value="1">Inbound</option>
								<option value="2">Outbound</option>
							</select>
						</li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                           <strong class="title ml20">상담사</strong>
                           <input type="text"id="s_User1Nm" name="s_User1Nm" style="width: 290px;" readonly>
						   <input type="hidden" id="s_User1Id" name="s_User1Id">
                        </li>
                        <li>
                        	<strong class="title">녹취시간</strong>
                        	<span class="timepicker voice" id="voice_time1"><input type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                            <span class="text_divide">~</span>
                            <span class="timepicker voice" id="voice_time2"><input type="text" id="s_RecEndTm" name="s_RecEndTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                        </li>
                        <li>
                        	<strong class="title ml20">통화시간</strong>
                        	<span class="timepicker tel" id="tel_time1"><input type="text" id="s_TalkFrmTm" name="s_TalkFrmTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                            <span class="text_divide">~</span>
                            <span class="timepicker tel" id="tel_time2"><input type="text" id="s_TalkEndTm" name="s_TalkEndTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                        </li>  
                    </ul>
                </div>   
                <div class="row">
                    <ul class="search_terms">
                        <li class="pt4 ml20">
                        	<input type="checkbox" id="check_1" id="valueYn" value="1" checked="checked" ><label for="check_1" class="checks ml67">평가건 제외</label>
                        </li>
                    </ul>
                </div>              
            </div>   
            <div class="btns_top">
                <button type="button" class="btn_m search" id="btnSearch" data-grant="R">조회</button>                
                <button type="button" class="btn_m confirm" id="btnValue" data-grant="W">품질평가</button>
            </div>        
            <div class="h260">
                <div class="btn_topArea fix_h25"></div>
                <div class="grid_area h70 pt0">
                    <div id="grList" class="real_grid"></div>
                    	<input type="hidden" id="timesId" name="timesId" value="<c:out value="${timesId}"/>">
						<input type="hidden" id="agentId" name="agentId" value="<c:out value="${agentId}"/>">
						<input type="hidden" id="agentNm" name="agentNm" value="<c:out value="${agentNm}"/>">
						<input type="hidden" id="currIndex" name="currIndex" value="<c:out value="${currIndex}"/>">
						<input type="hidden" id="sTimesId" name="sTimesId" value="<c:out value="${sTimesId}"/>">
						<input type="hidden" id="sTimesNm" name="sTimesNm" value="<c:out value="${sTimesNm}"/>">
						<input type="hidden" id="sQaaId" name="sQaaId" value="<c:out value="${sQaaId}"/>">
						<input type="hidden" id="sQaaNm" name="sQaaNm" value="<c:out value="${sQaaNm}"/>">		
						<input type="hidden" id="disable" name="disable" value="<c:out value="${disable}"/>">									
                </div>
                <div class="list_paging" id="paging">
                	<ul class="paging">
                 		<li><a href="#" id='' class="on">1</a></li>
                 	</ul>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>