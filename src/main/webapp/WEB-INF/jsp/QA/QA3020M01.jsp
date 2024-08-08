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
<script>
var recTableType = '<%=recTableType%>';
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var userName    = loginInfo.SVCCOMMONID.rows.userName;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var qaYn 		= loginInfo.SVCCOMMONID.rows.qaYn;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;
var workMenu 	= "평가완료";
var workLog 	= "";
var dataArray 	= new Array();


$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchList();
});


var gSheetkey = new Array();
var gTenantId = new Array();
function fnInitCtrl(){
	argoSetYearMonthPicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	argoSetDateTerm('selDateTerm1',{"targetObj":"s_txtDate1" , "selectValue":"M_0", "onlyMonth":"Y"}    );// 기간선택 콤보 설정
	argoCbCreate("#s_QaValueStatus", "ARGOCOMMON", "SP_UC_GET_CMCODE_01", {sort_cd : 'QA_VALUE_STATUS'}, {"selectIndex" : 0,"text" : '<전체>',"value" : ''}); // 진행상태
	argoSetDeptChoice("btn_Dept1", {"targetObj" : "s_Dept1","multiYn" : 'Y'}); //조직선택 팝업 연결처리(멀티)
	argoSetUserChoice01("btn_User1", {"targetObj" : "s_User1","multiYn" : 'Y'}); //상담사선택 팝업 연결처리(멀티)
	argoSetUserChoice03("btn_Qaa", {"targetObj" : "s_Qaa","multiYn" : 'Y'}); //상담사선택 팝업 연결처리(멀티)
	//var sRecTableNm = "";sRecTableNm = argoQaTimesRecTable(fvTimesId, recTableType);
	
	$("#btn_Search").click(function(){
		fnSearchList();
	});
	
	$("#btn_Noti").click(function(){
		fnNoti();
	});
	
	$("#btn_Seungin").click(function(){
		fnSeungin();
	});
	
	$("#btn_NotiCancel").click(function(){
		fnNotiCancel();
	});
	
	$("#btn_SeunginCancle").click(function() {
		fnSeunginCancle();
	});
	
	$("#btn_Delete").click(function() {
		fnDelete();
	});
	
	$("#btn_ConvertRatePop").click(function() {
		fnConvertRatePop();
	});
	


	// 평가계획 선택 로직 분리 20221201 gyu
	$("#btn_Times").click(function() {
		oOptions = {"targetObj" : "s_Times","multiYn" : 'Y', "targetYm" : "s_txtDate1" ,"stdMonthFrom" : argoGetValue("s_txtDate1_From"), "stdMonthTo" : argoGetValue("s_txtDate1_To")};
		oOptions.get = function(key, value) {
		 return this[key] === undefined ? value : this[key];
		};
		gPopupOptions = oOptions;
		
		$("#s_TimesNm").focusout(function(){
			 if($("#s_TimesNm").val().trim()=='')  $("#s_TimesId").val('') ;
		});	
		
		argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/QaTimesChoiceF.do', '900', '600');
	});
	
	
	
	$("#btnExcel").click(function(){
		argoGridExlConvert(w2ui['grid'], workMenu);
		/* var excelArray = new Array();
		argoJsonSearchList('QA', 'SP_QA3020M01_01', 's_', {}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					$.each(data.getRows(), function( index, row ) {
						gObject = {  "순번" 			: index
				   					, "평가계획"	  	: row.timesNm
									, "평가자"		: row.qaaNm
									, "소속" 		: row.deptInfo
									, "사번"			: row.sabun
									, "상담사명"		: row.agentNm
									, "평가일자"		: row.valueYmd
									, "평가점수"		: row.totalScore
									, "진행상태"		: row.qaValueStatusNm
									, "적용여부"		: row.notiYn==1?"적용":"미적용"
									, "상담사확인"		: row.confirmYn==1?"확인":"미확인"
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
        		var timesId = record.timesId;
        		argoQaResultDetail(sheetkey, timesId);
        	} 
        	
        	if(key[event.column] == "recordListen"){
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
          { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
          , { caption:"평가대상자", 	span:3 }
          , { caption:"평가정보", 	span:8 }
          , { caption:"", 	master:true }
          , { caption:"", 	master:true }
      	],
        columns: [  
			 	 { field: 'recid', 			caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'tenantId', 	 	caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'qaaId', 	 		caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'recordId', 		caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'sheetId', 		caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'sheetkey', 		caption: '', 				size: '0%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'timesId', 		caption: '', 				size: '0%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'qaValueStatus', 	caption: '', 				size: '0%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'timesNm', 		caption: '평가계획', 			size: '15%',  	sortable: true, attr: 'align=left' }
       	 		,{ field: 'qaaNm', 			caption: '평가자', 			size: '8%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'deptInfo', 		caption: '소속', 				size: '15%',  	sortable: true, attr: 'align=left' }
		       	,{ field: 'sabun', 			caption: '사번', 				size: '9%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'agentNm', 		caption: '상담사명', 			size: '10%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'recordListen', 	caption: '청취', 				size: '5%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'sttListen', 		caption: 'STT', 			size: '5%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'valueYmd', 		caption: '평가일자', 			size: '10%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'totalScore', 	caption: '평가점수', 			size: '5%',  	sortable: true, attr: 'align=right' }
		       	,{ field: 'convertRate', 	caption: '환산배율', 			size: '5%',  	sortable: true, attr: 'align=right' }
		       	,{ field: 'convertScore', 	caption: '환산점수', 			size: '5%',  	sortable: true, attr: 'align=right' }
		       	,{ field: 'qaValueStatusNm',caption: '진행상태', 			size: '5%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'detailPop', 		caption: '상세보기', 			size: '5%',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'notiYn', 		caption: '적용여부', 			size: '5%', 	editable:{ type:"text" }, sortable: true, attr: 'align=center' }
		       	,{ field: 'confirmYn', 		caption: '상담사<br>확인', 	size: '5%', 	editable:{ type:"text" }, sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('tenantId' );
	w2ui['grid'].hideColumn('qaaId' );
	w2ui['grid'].hideColumn('recordId' ); 
	w2ui['grid'].hideColumn('sheetId' ); 
	w2ui['grid'].hideColumn('sheetkey' );
	w2ui['grid'].hideColumn('timesId' ); 
	w2ui['grid'].hideColumn('qaValueStatus' );
}

function fnSearchList(){
	argoJsonSearchList('QA', 'SP_QA3020M01_01', 's_', {}, function (data, textStatus, jqXHR){
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
										, "tenantId"			: row.tenantId
										, "qaaId"				: row.qaaId
					   					, "recordId"	  		: row.recordId
										, "sheetId" 			: row.sheetId
										, "sheetkey"	  		: row.sheetkey
										, "timesId"	  			: row.timesId
										, "qaValueStatus" 		: row.qaValueStatus
										, "timesNm" 			: row.timesNm
										, "qaaNm"				: row.qaaNm
										, "deptInfo"			: row.deptInfo
										, "sabun" 				: row.sabun										
										, "agentNm" 			: row.agentNm			
										, "recordListen"		: "<img alt='' src='../images/speak_up.png' style='cursor:pointer;'></img>"
										, "sttListen"			: "<img alt='' src='../images/icon_code.png' style='cursor:pointer;'></img>"
					   					, "valueYmd"	  		: row.valueYmd
										, "totalScore" 			: row.totalScore
										, "convertRate" 		: row.convertRate
										, "convertScore" 		: row.convertScore
										, "qaValueStatusNm"	  	: row.qaValueStatusNm=="완료"?'<span style="color: #2080D0; font-weight: bold;">' + row.qaValueStatusNm + '</span>':'<span style="color: #008000; font-weight: bold;">' + row.qaValueStatusNm + '</span>'
										, "detailPop" 			: '<img src="../images/bg_approval.png" style="width:20px; height:20px; cursor:pointer;"></img>'
										, "notiYn" 				: row.notiYn==1?"<span style='font-weight: bold;'>적용</span>":"<span style='font-weight: bold;'>미적용</span>"
										, "confirmYn"			: row.confirmYn==1?"<span style='font-weight: bold;'>확인</span>":"<span style='font-weight: bold;'>미확인</span>"
									};
						dataArray.push(gObject2);
					});
					
					
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


// 평가건 완료
function fnSeungin() {
	var arrChecked = w2ui['grid'].getSelection();
 	if(arrChecked.length==0) {
 		argoAlert("완료처리할 항목을 선택하세요.") ; 
 		return ;
 	}
 	
 	if(arrChecked.length > 200) {
 		argoAlert("※한번에 최대 200개까지만 승인이 가능합니다");
		return;
 	}
 	
	gSheetkey = new Array();
	isCheck = true;
	var isMyQaChk = true;
	var msg = "";
	
	
	$.each(arrChecked, function(index, value) {
		sValue = w2ui['grid'].get(value).qaValueStatus;
		var qaaId = w2ui['grid'].get(value).qaaId;
		sSheetkey = w2ui['grid'].get(value).sheetkey;
		gSheetkey.push(sSheetkey);
		
		//저장상태만 완료 가능 하도록 수정 
		 if (sValue != '10') {
		 	//argoAlert("저장 건에 대해서만 완료가 가능합니다.");
		 	isCheck=false;
		 	//return false;
		 }
		
		 if (qaaId != userId) {
			 	//argoAlert("본인이 평가한 건에 대해서만 완료가 가능합니다.");
			 	//isCheck=false;
			 	//return false;
			 	isCheck=false;
			 	isMyQaChk = false;
			 	//return false;
			 	
		 }
	});
	
	if(qaYn == "A"){
		isCheck = true;
	}
	
	if( isCheck ) {
		if(isMyQaChk == false){
			msg = "<span style='color:red'>※ 본인이 평가하지 않은 평가결과가 선택되었습니다.</span> <br><br>완료처리 하시겠습니까?";
		}else{
			msg = "완료처리 하시겠습니까?";
		}
		argoConfirm(msg, function(){
			try{
				var multiService = new argoMultiService(fnSunginCallbackSave);
				$.each(gSheetkey, function( index, value) {						 
					var param = {"sheetkey":value, "gbn":"SI"}	
					multiService.argoUpdate("QA","SP_QA3020M01_02","ip_", param);
				});
				multiService.action();
			}catch(e){
				console.log(e);
			}
		});
	}else{
		argoAlert("본인이 평가한 건 중<br>진행상태가 [저장]인 결과에 대해서만 완료처리가 가능합니다.");
	}
}

function fnSunginCallbackSave(data, textStatus, jqXHR) {
	if (data.isOk()) {
		argoAlert("완료 처리 되었습니다.");
		fnSearchList();
	}
};

// 평가건 적용
function fnNoti() {
	var arrChecked = w2ui['grid'].getSelection();
 	if(arrChecked.length==0) {
 		argoAlert("적용처리할 항목을 선택하세요.") ; 
 		return ;
 	}
 	
 	if(arrChecked.length > 200) {
 		argoAlert("※한번에 최대 200개까지만 적용이 가능합니다");
		return;
 	}
 	
	gSheetkey = new Array();
	isCheck = true;
	var isMyQaChk = true;
	var msg = "";
	
	$.each(arrChecked, function(index, value) {
		sValue = w2ui['grid'].get(value).qaValueStatus;
		var qaaId = w2ui['grid'].get(value).qaaId;
		sSheetkey = w2ui['grid'].get(value).sheetkey;
		gSheetkey.push(sSheetkey);
		
		 if (sValue != '40') {
		 	//argoAlert("완료 건에 대해서만 적용이 가능합니다.");
		 	isCheck=false;
		 	//return false;
		 }
		 if (qaaId != userId) {
		 	//argoAlert("본인이 평가한 건에 대해서만 적용이 가능합니다.");
		 	isCheck=false;
		 	isMyQaChk = false;
		 	//return false;
		 }
	});
	
	
	if(qaYn == "A"){
		isCheck = true;
	}
	
	
	if( isCheck ) {
		
		if(isMyQaChk == false){
			msg = "<span style='color:red'>※ 본인이 평가하지 않은 평가결과가 선택되었습니다.</span> <br><br>적용 시 상담사가 결과를 확인 할 수 있습니다. 적용하시겠습니까?";
		}else{
			msg = "적용 처리 하시겠습니까?<br>적용 시 상담사가 결과를 확인 할 수 있습니다.";
		}
		
		argoConfirm(msg, function(){
			try{
				var multiService = new argoMultiService(fnCallbackSave);
				$.each(gSheetkey, function( index, value) {						 
					var param = {"sheetkey":value, "gbn":"NY"}	
					multiService.argoUpdate("QA","SP_QA3020M01_02","ip_", param);
				});
				multiService.action();
			}catch(e){
				console.log(e);
			}
		});
	}else{
		argoAlert("본인이 평가한 건 중<br>진행상태가 [완료]인 결과에 대해서만 적용처리가 가능합니다.");
	}
}

function fnCallbackSave(data, textStatus, jqXHR) {
	if (data.isOk()) {
		argoAlert("적용처리가 완료되었습니다.");
		fnSearchList();
	}
};
	
// 적용 취소
function fnNotiCancel() {
	
	var arrChecked = w2ui['grid'].getSelection();
 	if(arrChecked.length==0) {
 		argoAlert("적용취소할 항목을 선택하세요.") ; 
 		return ;
 	}
 	
 	if(arrChecked.length > 200) {
 		argoAlert("※한번에 최대 200개까지만 적용취소가 가능합니다");
		return;
 	}
 	
	gSheetkey = new Array();
	isCheck = true;
	var isMyQaChk = true;
	var msg = "";
	
	$.each(arrChecked, function(index, value) {
		sValue = w2ui['grid'].get(value).notiYn;
		var qaaId = w2ui['grid'].get(value).qaaId;
		sSheetkey = w2ui['grid'].get(value).sheetkey;
		gSheetkey.push(sSheetkey);
		
		 //if (sValue != '1') {
		//	argoAlert("적용처리된 건에 대해서만 적용취소가 가능합니다.");
		// 	isCheck=false;
		// 	return false;
		// }
		 if (qaaId != userId) {
			 //argoAlert("본인이 평가한 건에 대해서만 적용취소가 가능합니다.");
			 isCheck=false;
			 isMyQaChk = false;
			 //return false;
		 }
	});
	
	if(qaYn == "A"){
		isCheck = true;
	}
	
	if( isCheck ) {
		
		if(isMyQaChk == false){
			msg = "<span style='color:red'>※ 본인이 평가하지 않은 평가결과가 선택되었습니다.</span> <br><br>적용취소 하시겠습니까?";
		}else{
			msg = "적용취소 하시겠습니까?";
		}
		
		argoConfirm(msg, function(){
			try{
				var multiService = new argoMultiService(fnNotiCancelCallbackSave);
				$.each(gSheetkey, function( index, value) {						 
					var param = {"sheetkey":value, "gbn":"NC"}	
					multiService.argoUpdate("QA", "SP_QA3020M01_02", "__", param);
				});
				multiService.action();
			}catch(e){
				console.log(e);
			}
		});
	}else{
		argoAlert("본인이 평가한 건에 대해서만 적용취소가 가능합니다.");
	}
}

function fnNotiCancelCallbackSave(data, textStatus, jqXHR) {
	if (data.isOk()) {
		argoAlert("적용취소가 완료되었습니다.");
		fnSearchList();
	}
};

// 완료취소 추가
function fnSeunginCancle() {
	var arrChecked = w2ui['grid'].getSelection();
 	if(arrChecked.length==0) {
 		argoAlert("완료취소할 항목을 선택하세요.") ; 
 		return ;
 	}
 	
 	if(arrChecked.length > 200) {
 		argoAlert("※한번에 최대 200개까지만 완료취소가 가능합니다");
		return;
 	}
 	
	gSheetkey = new Array();
	isCheck = true;
	
	$.each(arrChecked, function(index, value) {
		sValue = w2ui['grid'].get(value).qaValueStatus;
		var qaaId = w2ui['grid'].get(value).qaaId;
		sSheetkey = w2ui['grid'].get(value).sheetkey;
		gSheetkey.push(sSheetkey);
		
		 if (sValue != '40') {
			//argoAlert("완료처리된 건에 대해서만 완료취소가 가능합니다.");
		 	isCheck=false;
		 	//return false;
		 }
		 if (qaaId != userId) {
		 	//argoAlert("본인이 평가한 건에 대해서만 완료취소가 가능합니다.");
		 	isCheck=false;
		 	//return false;
		 }
	});
	
	if(qaYn == "A"){
		isCheck = true;
	}
	
	if( isCheck ) {
		argoConfirm("완료취소 처리 하시겠습니까?", function(){
			try{
				var multiService = new argoMultiService(fnCallbackSeunginCancle);
				$.each(gSheetkey, function( index, value) {						 
					var param = {"sheetkey":value, "gbn":"SC"}	
					multiService.argoUpdate("QA","SP_QA3020M01_02","ip_", param);
				});
				multiService.action();
			}catch(e){
				console.log(e);
			}
		});
	}else{
		argoAlert("본인이 평가한 건 중<br>진행상태가 [저장]인 건에 대해서만 완료취소가 가능합니다.");
	}
}

function fnCallbackSeunginCancle(data, textStatus, jqXHR) {
	if(data.isOk()) {
		argoAlert("성공적으로 완료취소 되었습니다" );
		fnSearchList();
	}
}


// 삭제 추가
function fnDelete() {
	var arrChecked = w2ui['grid'].getSelection();
 	if(arrChecked.length==0) {
 		argoAlert("삭제할 항목을 선택하세요.") ; 
 		return ;
 	}
 	
 	if(arrChecked.length > 200) {
 		argoAlert("※한번에 최대 200개까지만 삭제가 가능합니다");
		return;
 	}
 	
	gSheetkey = new Array();
	isCheck = true;
	
	$.each(arrChecked, function(index, value) {
		sValue = w2ui['grid'].get(value).qaValueStatus;
		var qaaId = w2ui['grid'].get(value).qaaId;
		sSheetkey = w2ui['grid'].get(value).sheetkey;
		gSheetkey.push(sSheetkey);
		
		 /* if (sValue != '40') {
			argoAlert("완료처리된 건에 대해서만 완료취소가 가능합니다.");
		 	isCheck=false;
		 	return false;
		 } */
		 if (qaaId != userId) {
		 	//argoAlert("본인이 평가한 건에 대해서만 삭제가 가능합니다.");
		 	isCheck=false;
		 	//return false;
		 }
	});
	
	if(qaYn == "A"){
		isCheck = true;
	}
	
	if( isCheck ) {
		argoConfirm("선택한 평가 결과를 삭제 하시겠습니까?<br><span style='color:red; font-size:9pt;'>※ 삭제 시 복구할 수 없습니다.</span>", function(){
			try{
				var multiService = new argoMultiService(fnCallbackDelete);
				$.each(gSheetkey, function( index, value) {						 
					var param = {"sheetkey":value, "gbn":"D"}	
					multiService.argoUpdate("QA","SP_QA3020M01_02","ip_", param);
				});
				multiService.action();
			}catch(e){
				console.log(e);
			}
		});
	}else{
		argoAlert("본인이 평가한 건에 대해서만 삭제 가능합니다.");
	}
}

function fnCallbackDelete(data, textStatus, jqXHR) {
	if(data.isOk()) {
		argoAlert("성공적으로 삭제 되었습니다" );
		fnSearchList();
	}
}

//평가건 승인
function fnConvertRatePop() {		

	//var arrChecked = treeView.getCheckedRows(false);
	//var isCheck = true;

	var arrChecked = w2ui['grid'].getSelection();
 	if(arrChecked.length==0) {
 		argoAlert("점수환산할 항목을 선택하세요.") ; 
 		return ;
 	}

	if( arrChecked.length > 200) {
		argoAlert("※한번에 최대 200개까지만 점수환산이 가능합니다");
		return;
	}
	
	
	var isCheck = true;
	var rateFlg = false;
	gSheetkey = new Array();
	gTenantId = new Array();
	$.each(arrChecked, function(index, value) {
		//sValue = w2ui['grid'].get(value).qaValueStatus;
		var convertRate = w2ui['grid'].get(value).convertRate;
		if(convertRate != "0"){
			rateFlg = true;
		}
		var sheetkey = w2ui['grid'].get(value).sheetkey;
		var tenantId = w2ui['grid'].get(value).tenantId;
		gSheetkey.push(sheetkey);
		gTenantId.push(tenantId);
		
		
		
		 /* if (sValue != '40') {
			argoAlert("완료처리된 건에 대해서만 완료취소가 가능합니다.");
		 	isCheck=false;
		 	return false;
		 } */
		 //if (qaaId != userId) {
		 //	argoAlert("본인이 평가한 건에 대해서만 삭제가 가능합니다.");
		 //	isCheck=false;
		 //	return false;
		 //}
	});
	
	gPopupOptions = {"pTenantIdArr":gTenantId, "pSheetKeyArr":gSheetkey};
	
	if(rateFlg == true){
		argoConfirm("선택항목 중 점수환산이 진행된 평가결과가 존재합니다.<br>점수환산을 진행 하시겠습니까?", function(){
			argoSmallPopupWindow($("#btn_ConvertRatePop"), '점수환산(' + arrChecked.length+ '건)', 'QA3020S02F.do', '364', '230');
		});
	}else{
		argoSmallPopupWindow($("#btn_ConvertRatePop"), '점수환산(' + arrChecked.length+ '건)', 'QA3020S02F.do', '364', '230');
	}
}

</script>
</head>
<body>
		<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><strong class="step">평가완료</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
            	<div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">평가년월</strong>
                            <select id="selDateTerm1" name="selDateTerm1" style="width: 80px; display: hidden" class="mr5"></select>
						    <span class="yearMonth_date" id="d1"><input type="text" id="s_txtDate1_From" name="s_txtDate1_From" placeholder="년 - 월" class="input_ym onlyDate"><a href="#" class="btn_calendar">년/월 선택</a></span>
                            <span class="text_divide">~</span>
						    <span class="yearMonth_date" id="d1"><input type="text" id="s_txtDate1_To" name="s_txtDate1_To" placeholder="년 - 월" class="input_ym onlyDate"><a href="#" class="btn_calendar">년/월 선택</a></span>
                        </li>
                    	<li>
                           <strong class="title">평가계획</strong>
                           <input type="text" id="s_TimesNm" name="s_TimesNm" style="width:160px;"><button type="button" class="btn_termsSearch" id="btn_Times">검색</button>
                           <input type="hidden" id="s_TimesId" name="s_TimesId">
                        </li>
                        <li>
                           <strong class="title">평가자</strong>
                           <input type="text" id="s_QaaNm" name="s_QaaNm" style="width:80px;"><button type="button" class="btn_termsSearch" id="btn_Qaa">검색</button>
                           <input type="hidden" id="s_QaaId" name="s_QaaId">
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                        	<strong class="title ml20">소속</strong>
                        	<input type="text" id="s_Dept1Nm" name="s_Dept1Nm" style="width:140px;" readonly><button type="button" class="btn_termsSearch" id="btn_Dept1">검색</button>
                        	<input type="hidden" id="s_Dept1Id" name="s_Dept1Id">
                        </li>
                        <li>
                           <strong class="title">상담사</strong>
                           <input type="text"   id="s_User1Nm" name="s_User1Nm" style="width:100px;"><button type="button" id="btn_User1" class="btn_termsSearch">검색</button>
                           <input type="hidden" id="s_User1Id" name="s_User1Id" >
                        </li>
                        <li>
                           <strong class="title">진행상태</strong>
                           <select id="s_QaValueStatus" name="s_QaValueStatus" style="width:100px;"></select>
                        </li>
                        <li>
                           <strong class="title">적용여부</strong>
                           <select id="s_NotiYn" name="s_NotiYn" style="width:100px;">
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
                <button type="button" class="btn_m" id="btn_ConvertRatePop" data-grant="W">점수환산</button>
                <button type="button" class="btn_m confirm" id="btn_Seungin" data-grant="W">완료</button>
                <button type="button" class="btn_m confirm" id="btn_SeunginCancle" data-grant="W">완료취소</button>
                <button type="button" class="btn_m confirm" id="btn_Noti" data-grant="W">적용</button>
                <button type="button" class="btn_m confirm" id="btn_NotiCancel" data-grant="W">적용취소</button>
                <button type="button" class="btn_m confirm" id="btn_Delete" data-grant="W">삭제</button>
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