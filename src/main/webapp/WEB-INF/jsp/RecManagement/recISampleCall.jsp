<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">

<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->    
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->
<script type="text/javascript"	src="<c:url value="/scripts/velocejs/veloce.popupWindow.js?ver=2017010611"/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/fullcalendar-3.1.0/lib/moment.min.js'/>"></script>

<style>
.btn_type1 {
	font-size:12px; 
	height:19px; 
	padding:0 5px 0 5px;
} 
</style>

<%
	boolean isHttps = request.isSecure();
%>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId 	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var authRank = loginInfo.SVCCOMMONID.rows.authRank;
	var workMenu 	= "샘플콜조회";
	var workLog 	= "";
	var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
	var isUseRecReason;
	
	var gPopupOptions	= {};

	var mfsIp;
	var mfuNatIp;

	var tmpSelection;
	var dataArray = new Array();
	
	var reqDtFrom;
	var reqDtTo;
	
	var voicePlayYn = "N";

	$(document).ready(function(param) {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	var fvKeyId ; 
	
	function fnInitCtrl(){		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		argoSetDatePicker();
     var jData = [];
		
		var today =  moment().format("YYYY-MM-DD");
     $("#selReqDt_To").val(today);
     $("#selReqDt_From").val(today);
     argoSetDateTerm('selDateTerm1', {"targetObj"     : "selReqDt", "selectValue"   : "T_0"}, jData);
		
		
		$("#btnSearch").click(function(){ //조회	
			fnSearchListCnt();
		});
		
		$("#s_FindKey").change(function(){
			var sSel = argoGetValue('s_FindKey');
			if(sSel == ""){
				$("#s_FindText").val("");
			}
		});
		
		$("#btnDelete").click(function(){
			fnDeleteList();
		});	
		
		$("#btnSort").click(function(){
// 			gPopupOptions = {pTenantId:$('#s_FindTenantId option:selected').val()};
// 			argoPopupWindow('샘플콜분류조회', 'recSampleGrpPopAddF.do', '600', '490');
			sortSh();
		});	
		
		
		//[input]상담사 자동검색 - start
		var dataList = "";
		$('#s_FindUserNameText').autocomplete({
			source : function(request, response){
				argoJsonSearchList('recSearch', 'getRecUserInfo', '',{"tenantId":tenantId, "authRank":authRank, "srchKeyword":$('#s_FindUserNameText').val()}, function(data, textStatus, jqXHR){
					try {
						var strOption2 = "";
						if (data.isOk()) {
							
							function fnUserListBind (){
								response(
									$.map(data.getRows(), function(item){
										return{
											label : item.tenantName + " " + item.groupName + " " + item.userName+"("+item.userId+")" //테넌트네임, 그룹명, 상담사명(상담사ID)
					             ,value : item.userId		// 선택 시 input창에 표시되는 값
					             ,idx : item.SEQ // index
										};
									})
								);
							}
							fnUserListBind();
						}
					} catch (e) {
						console.log(e);
					}
				});
			}
			,focus : function(event, ui) { // 방향키로 자동완성단어 선택 가능하게 만들어줌	
					return false;
			}
			,minLength: 1// 최소 글자수
			,autoFocus : true // true == 첫 번째 항목에 자동으로 초점이 맞춰짐
			,delay: 100	//autocomplete 딜레이 시간(ms)
		});
		//[input]상담사 자동검색 - end
		
		
		//[input]등록자 자동검색 - start
		var insDataList = "";
		$('#s_FindInsNameText').autocomplete({
			source : function(request, response){
				argoJsonSearchList('recSearch', 'getRecUserInfo', '',{"tenantId":tenantId, "authRank":authRank, "srchKeyword":$('#s_FindInsNameText').val()}, function(data, textStatus, jqXHR){
					try {
						var strOption2 = "";
						if (data.isOk()) {
							
							function fnUserListBind (){
								response(
									$.map(data.getRows(), function(item){
										return{
											label : item.tenantName + " " + item.groupName + " " + item.userName+"("+item.userId+")" //테넌트네임, 그룹명, 상담사명(상담사ID)
					             ,value : item.userId		// 선택 시 input창에 표시되는 값
					             ,idx : item.SEQ // index
										};
									})
								);
							}
							fnUserListBind();
						}
					} catch (e) {
						console.log(e);
					}
				});
			}
			,focus : function(event, ui) { // 방향키로 자동완성단어 선택 가능하게 만들어줌	
					return false;
			}
			,minLength: 1// 최소 글자수
			,autoFocus : true // true == 첫 번째 항목에 자동으로 초점이 맞춰짐
			,delay: 100	//autocomplete 딜레이 시간(ms)
		});
		//[input]상담사 자동검색 - end
		
		
		$("#btnExcel").click(function(){
			var excelArray = new Array();
			var recTime;
			var vRecDate1; 
			var vRecTime;
			var proc;
			argoJsonSearchList('recSample', 'getSampleCallList', 's_', {tenantId:$('#s_FindTenantId option:selected').val(), "iSPageNo":100000000, "iEPageNo":100000000}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						if (data.getRows() != "") {
						$.each(data.getRows(), function( index, row ) {
							recTime     = row.recTime;
							vRecDate1	= recTime.substr(0,4) + "-" + recTime.substr(4,2) + "-" + recTime.substr(6,2);
							vRecTime	= recTime.substr(8,2) + ":" + recTime.substr(10,2) + ":" + recTime.substr(12,2);
							proc = vRecDate1+" "+vRecTime;
							gObject = {   "순번" 		: index + 1
					    				, "회사"		: row.tenantId
					   					, "분류"		: row.depthPath
										, "그룹" 		: row.groupName
										, "상담사id" 	: row.userId
										, "상담사명" 	: row.userName
										, "내선번호" 	: row.dnNo
										, "통화일자" 	: proc
										};
										
							excelArray.push(gObject);
						});
						
						gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
						argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
						
						workLog = '[TenantId:' + tenantId + ' | UserId:' + userId + ' | GrantId:' + grantId + '] Excel Export';
						argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:$('#s_FindTenantId option:selected').val(), userId:userId
										,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
						
						}
					}
				} catch (e) {
					console.log(e);
				}
			});
		});	

		$("#btnReset").click(function(){
			argoSetValue("s_FindDepthPath", "");
			argoSetValue("s_FindGroupName", "");
			argoSetValue("s_FindUserNameText", "");
			argoSetValue("s_FindInsNameText", "");
			
			
			var today =  moment().format("YYYY-MM-DD");
       $("#selReqDt_To").val(today);
       $("#selReqDt_From").val(today);
		});	
		
		argoJsonSearchOne('comboBoxCode', 'getMfuIpList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						mfsIp = data.getRows()['code'];
						mfuNatIp = data.getRows()['ipNat'] == undefined ? "" : data.getRows()['ipNat'];
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
		
		getConfigValue();
		
		
		$("#btnPlay").click(function() {
			fnRecFilePlay(-1);

			//fnMultiRecPlay();
			
		});
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
		
	}
	
	function getConfigValue(){
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {"section":"INPUT", "keyCode":"USE_REC_REASON"}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						isUseRecReason = data.getRows()['code'];
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	} 
	
	function sortSh(){
		gPopupOptions = {pTenantId:$('#s_FindTenantId option:selected').val()};
		argoPopupWindow('샘플콜분류조회', 'recSampleGrpPopAddF.do', '600', '490');
	}
	
	function memo(idx){
// 		content = w2ui['grid'].getCellValue(idx,11);
// 		recKey  = w2ui['grid'].getCellValue(idx,19);
		content = dataArray[idx].content;
		recKey  = dataArray[idx].recKey;
		parm = {
					"content" : content,
					"recKey"  : recKey
				};
		gPopupOptions = {pRowIndex:parm} ;
		argoPopupWindow('메모보기', 'recSampleMemoPopAddF.do', '600', '220');
	} 	
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
			name: 'grid', 
			show: {
				lineNumbers: true,
				footer: true,
				selectColumn: true
			},
			onDblClick: function(event) {
        	
				var record = this.get(event.recid);
				console.log(record.mediaScr);
        	
        	if (event.recid >=0 ) {
        		fnRecFilePlay(event.recid);
        	}	
       },
        multiSelect: true,
	       
	        columns: [  
						 { field: 'recid', 			 	caption: 'recid', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'tenantId', 	     	caption: 'tenantId', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'depthPath', 	 		caption: '분류', 					size: '20%', 	sortable: true, attr: 'align=left'   }
	            	 	,{ field: 'realtimeFlag', 		caption: '듣기', 					size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'workerId', 		    caption: '청취구분', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'recTime', 		 	caption: '통화일자', 				size: '20%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'endTime', 	        caption: '통화시간', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'groupName', 		 	caption: '그룹', 					size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'userId', 	     	caption: '상담사ID', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userName', 		 	caption: '상담사명', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'dnNo', 		     	caption: '내선번호', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'insId', 	        caption: '등록자', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'content', 	 		caption: '메모보기', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'content1', 	 		caption: '메모보기', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaScr', 		 	caption: 'mediaScr', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'uploadCntVoice',  	caption: 'uploadCntVoice', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'uploadCntScr', 	 	caption: 'uploadCntScr', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'groupId', 	     	caption: 'groupId', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'spGrpName', 		 	caption: 'spGrpName', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaVoice', 	 	caption: 'mediaVoiceID', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'recKey', 		 	caption: 'recKey', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'phoneIp', 	        caption: 'phoneIp', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'topParentGroupName', caption: 'topParentGroupName', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaKind', 	 		caption: 'mediaKind', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'callId', 	 		caption: 'callId', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'custTel', 	 		caption: 'custTel', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'recTimeConv', 	 	caption: 'recTimeConv', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mfuIp', 	 			caption: 'mfuIp', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'orgRecTime', 		 	caption: '통화일자', 				size: '20%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'mediaScr',  'tenantId', 'uploadCntVoice', 'uploadCntScr', 'groupId', 'spGrpName', 'mediaVoice', 
				'recKey', 'phoneIp', 'topParentGroupName', 'mediaKind', 'realtimeFlag', 'workerId', 'callId', 'custTel', 'recTimeConv', 'mfuIp','orgRecTime');
	}
	
	function getTimeStamp2() {
	    var d = new Date();
	    var date = leadingZeros(d.getFullYear(), 4) + leadingZeros(d.getMonth() + 1, 2) + leadingZeros(d.getDate(), 2);
	    var time = leadingZeros(d.getHours(), 2) + leadingZeros(d.getMinutes(), 2) + leadingZeros(d.getSeconds(), 2);

	    return date + time;
	}
	
	function leadingZeros(n, digits) {
	    var zero = '';
	    n = n.toString();

	    if (n.length < digits) {
	        for (i = 0; i < digits - n.length; i++)
	            zero += '0';
	    }
	    return zero + n;
	}
	
	function fnRecFilePlay(index,scrType){
		
		var arrChecked = "";
		var arrRecDate = "";
		var sortIndex = "";
		
		if(voicePlayYn == "Y"){
			argoAlert("이미 실행중입니다.");				
			return;
		}
		
		voicePlayYn = "Y";
		
		if (index < 0) {
			index = w2ui['grid'].getSelection();
			if (index.length == 0) {
				voicePlayYn = "N";
				argoAlert("한 개 이상의 녹취를 선택해주세요.");				
				return;
			}
			/* argoAlert("한 개 이상의 녹취를 선택해주세요.");
			return;argoPopupWindow */
		}else{
			index = new Array(index);
		}
		//var indexs = new Array(index);
		
		//23.07.14 통화내역조회 내 일괄재생 시 날짜,시간 ASC (오래된 순) -- start
		if(index.length > 1){
			arrChecked = new Array();
			arrRecDate = new Array();
			arrSortIndex = new Array();
			
			arrChecked = index
			
			$.each(arrChecked, function(index, item) {
				var recDate = w2ui['grid'].get(index).recDate;
				var recTime = w2ui['grid'].get(index).recTime;
				arrRecDate.push({'recIndex':item, 'date':recDate, 'time':recTime});
			});
			
			arrRecDate.sort(function(prev, cur) {
				var a = moment(prev.date + ' ' + prev.time, "YYYY-MM-DD HH:mm:ss");
				var b = moment(cur.date + ' ' + cur.time, "YYYY-MM-DD HH:mm:ss");

				//23.07.14 date을 기준으로 오름차순 -> time을 기준으로 오름차순
				return moment(a).isAfter(b) ? 1 : -1;
			});
			
			$.each(arrRecDate, function(arrIndex){
				arrSortIndex.push(arrRecDate[arrIndex].recIndex);
			});
			
			index = arrSortIndex;
		}
		//23.07.14 통화내역조회 내 일괄재생 시 날짜,시간 ASC (오래된 순) -- end
		
		
		if(isUseRecReason == "1"){
			gPopupOptions = {pRowIndex:index,"cudMode":"4"};
	 		argoPopupWindow('청취사유등록', gGlobal.ROOT_PATH+'/recording/RecSearchRecLogPopAddF.do', '470', '370');
	 		
		}else{
			fnRecFilePlayCallBack(index,scrType);
		}
	}
	
	function fnRecFilePlayCallBack(index, scrType) {
		var FileList;
		
	  	var logTenantId 	= tenantId;
		var logWorkerId 	= userId;
		var logWorkIp 		= workIp;
		var logRealtimeFlag = "4";	//파일청취
		
		var iCmd;
		var arrChecked;
		var ws;
		var ws_data;
		
		var nSelectCount = 0;
		
		var secValidate = "0";
		
		if (playerKind == null || playerKind == "0") {
			//dddd
			var tmpSelection = index;
			index = index[0];
			var callPlayRecord = playRecord.bind(null, w2ui['grid'], tmpSelection);
			
			//var callPlayRecord = playRecord.bind(null, w2ui['grid'], index);
			velocePopupWindow('청취(고객명 : ' + "샘플콜" + ')', 'about:blank', '594', '386', '', 'sttPlay', callPlayRecord, "fnSelectedRow");
			
			/* if ( isUseRecReason == "0") {
				fnRecIsNotUseRecReason(arrChecked,4);
			}  */
			
			voicePlayYn = "N";
			return;			
		}
		
		//record = w2ui['grid'].get(index[0]);
		debugger;

		if (index >= 0) {
			
			
			var callingSec = argoTimeToSeconds(dataArray[index].endTime);
			if(callingSec <= 2){
				secValidate = "1";
				voicePlayYn = "N"
				argoAlert("통화시간이 2초 이내의 녹취 이력은 청취할 수 없습니다.");
				return;
			}
			
			if(argoNullConvert(dataArray[index].mfuIp) != ""){
				mfsIp = argoNullConvert(dataArray[index].mfuIp);
			}
			
			ws_data="cmd=11&mfu_ip=" + mfsIp + "&mfu_port=7200" 
			+ "&tenant_id=" + dataArray[index].tenantId
			+ "&user_id=" + dataArray[index].userId
			+ "&call_id=" + dataArray[index].callId
			+ "&media_kind=" + "1"; // 샘플콜 스크린 재생 안함.
		}
		else{
			iCmd = "12";
			try {
				var scrSrc = (scrType == true ? "|screen|" : "|voice|" );				
				arrChecked = index;				
								
				FileList = "";
				
				$.each(arrChecked, function(index, colIndex) {
					
					var callingSec = argoTimeToSeconds(dataArray[colIndex].endTime);
					if(callingSec <= 2){
						secValidate = "1";
						voicePlayYn = "N"
						argoAlert("통화시간이 2초 이내의 녹취 이력은 청취할 수 없습니다.");
						return;
					}
					
					//var tmpCustTel = w2ui['grid'].getCellValue(colIndex, idxCustTel);
					var tmpCustTel = dataArray[colIndex].custTel;
					//var paramUserId = w2ui['grid'].getCellValue(colIndex, idxUserId) == "" ? "btadmin" : w2ui['grid'].getCellValue(colIndex, idxUserId);
					var paramUserId = dataArray[colIndex].userId == "" ? "btadmin" : dataArray[colIndex].userId;
					//FileList += w2ui['grid'].getCellValue(index, 34) + '|' + userId + '|'
					
					record = w2ui['grid'].get(colIndex);
					var agentMfuIp = argoNullConvert(record.mfuIp) == "" ? mfsIp : record.mfuIp;
					var paramUserId = record.userId == "" ? "btadmin" : record.userId;
					
					/* FileList += agentMfuIp + '|7200|'	+ record.recDateOrg
					+ record.recTimeOrg
					+ '|'
					+ record.endTimeOrg
					+ '|'
					+ record.dnNo
					+ '|'
					+ record.userName
					+ '|'
					+ record.custTel.replace(/#/gi,"")
					+ '|'
					+ record.callId
					+ '|,'; */
					
					/* FileList += 	
						agentMfuIp + '|7200|' + record.recDate
						+ dataArray[colIndex].orgRecTime
						+ '|'
						+ dataArray[colIndex].orgEndTime
						+ '|'
						+ dataArray[colIndex].dnNo
						+ '|'
						+ ''
						+ '|'
						+ record.custTel.replace(/#/gi,"")
						+ '|'
						+ dataArray[colIndex].callId
						+ '|,'; */
					FileList +=
						agentMfuIp + '|7200|' + record.recDate
						+ record.orgRecTime
						+ '|'
						+ record.orgEndTime
						+ '|'
						+ record.dnNo
						+ '|'
						+ ''
						+ '|'
						+ record.custTel.replace(/#/gi,"")
						+ '|'
						+ record.callId
						+ '|,';	
					nSelectCount++;
				});
				
				if(nSelectCount > 10) {
					voicePlayYn = "N";
					argoAlert("최대 10 개 까지 일괄재생 가능합니다.");
					return;
				}
				
				//ws_data="cmd=" + iCmd + "&mfu_ip=" + mfsIp +"&mfu_port=7200&tenant_id=" + encodeURI(tenantId2)
				ws_data="cmd=" + iCmd + "&mfu_ip=" + mfsIp +"&mfu_port=7200&tenant_id=" + encodeURI(tenantId)
					+ "&filelist=" + encodeURI(FileList);
				
			} catch (e) {
				console.log(e);
			};
		}
		
		/* if ( isUseRecReason == "0") {
			fnRecIsNotUseRecReason(arrChecked,4);
		}  */
		
		if(secValidate == "0"){
			ws = new WebSocket("ws://localhost:8282");
			
			ws.onopen = function(e){
				console.log(e);			
				ws.send( ws_data );
			};
			
			ws.onclose = function(e){
				voicePlayYn = "N"
				console.log(e);
			};	
					
			return;
		}
		
		
	}
		
	function fnSelectedRow() {
		for(var i = 0; i < tmpSelection.length ; i++) {
			w2ui['grid'].select(tmpSelection[i]);
		}
	}
	
	function timeCal(seconds) {
		var hour = parseInt(seconds/3600);
		var min  = parseInt((seconds%3600)/60);
		var sec  = seconds%60;
		if(min < 10 && sec > 9 ){
			return hour + ":" + "0" + min + ":" + sec;
		}else if( sec < 10 && min < 10){
			return hour + ":" + "0" + min + ":" + "0" + sec;
		}	
		return hour + ":" + min + ":" + sec;	
	}
	
	function fnSerch(param) {
		argoSetValue("s_FindDepthPath", param.depthPath);
		argoSetValue("s_FindGroupName", param.groupName);
		
		fnSearchListCnt();
	}
	
	function fnSearchListCnt(){
		
		reqDtFrom = $('#selReqDt_From').val().replaceAll('-', '');
		reqDtTo = $('#selReqDt_To').val().replaceAll('-', '');
	
		
		argoJsonSearchOne('recSample', 'getSampleCallCount', 's_', {"tenantId":$('#s_FindTenantId option:selected').val(), "reqDtFrom":reqDtFrom, "reqDtTo":reqDtTo}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					
					var totalData = data.getRows()['cnt'];
					var searchCnt = argoGetValue('s_SearchCount');
					paging(totalData, "1", searchCnt);
					$("#totCount").html(totalData);
					
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
						
					w2ui.grid.lock('조회중', true);
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow){
		var recTime;
		var vRecDate1; 
		var vRecTime;
		var proc;
		var endTime;
		var endTime1;
		
		reqDtFrom = $('#selReqDt_From').val().replaceAll('-', '');
		reqDtTo = $('#selReqDt_To').val().replaceAll('-', '');
		
		argoJsonSearchList('recSample', 'getSampleCallList', 's_', {tenantId:$('#s_FindTenantId option:selected').val(), "reqDtFrom":reqDtFrom, "reqDtTo":reqDtTo, "iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){ 
						dataArray = [];
						var subAdd;
						$.each(data.getRows(), function( index, row ) {
							
							subAdd 		= ' <button type="button" id="sub" class="btn_m btn_type1" onclick="javascript:memo(' + index + ');">메모보기</button>';
							recTime     = row.recTime;
							endTime     = row.endTime;
							vRecDate1	= recTime.substr(0,4)+"-"+recTime.substr(4,2)+"-"+recTime.substr(6,2);
							vRecTime	= recTime.substr(8,2)+":"+recTime.substr(10,2)+":"+recTime.substr(12,2);
							proc 		= vRecDate1+" "+vRecTime;
							endTime1 	= timeCal(endTime);
							
							gObject2 = {  "recid" 			  	: index
										, "tenantId"		  	: row.tenantId
					    				, "depthPath"		  	: row.depthPath
					   					, "realtimeFlag"	  	: ''
										, "workerId" 		  	: ''
										, "recTime" 		  	: proc
										, "groupName" 		  	: row.groupName
										, "userId" 			  	: row.userId
										, "userName" 		  	: row.userName
										, "dnNo" 			  	: row.dnNo
										, "endTime" 		  	: endTime1
										, "content" 		  	: row.content
										, "content1" 		  	: subAdd
										, "mediaScr" 		  	: row.mediaScr
										, "uploadCntVoice"    	: row.uploadCntVoice
										, "uploadCntScr"  		: row.uploadCntScr
										, "groupId" 		  	: row.groupId
										, "spGrpName" 		  	: row.spGrpName
										, "mediaVoice" 		  	: row.mediaVoice
										, "recKey" 		  	  	: row.recKey
										, "phoneIp"  		    : row.phoneIp
										, "topParentGroupName"  : row.topParentGroupName
										, "mediaKind"  			: row.mediaKind
										, "callId"  			: row.callId
										, "custTel"  			: row.custTel
										, "recTimeConv"  		: row.recTime
										, "mfuIp"  				: row.mfuIp
										, "orgRecTime"			: row.recTime
										, "orgEndTime"			: row.endTime
										, "recDate" : vRecDate1
										, "insId" : row.insId
										};
										
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
	
	var gGroupId;
	var tTenantId;
	var rRecKey;
	
	function fnDeleteList(){
		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("삭제할 샘플콜을 선택하세요"); 
		 		return ;
			}
			argoConfirm('선택한 샘플콜 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				$.each(arrChecked, function( index, value ) {
	
// 					gGroupId  = w2ui['grid'].getCellValue(value, 16);
// 					tTenantId = w2ui['grid'].getCellValue(value, 1);
// 					rRecKey   = w2ui['grid'].getCellValue(value, 19);
					gGroupId  = dataArray[value].groupId;
					tTenantId = dataArray[value].tenantId;
					rRecKey   = dataArray[value].recKey;
					var param = { 
									"groupId"  : gGroupId, 
									"tenantId" : tTenantId,
									"recKey"   : rRecKey
								};
					multiService.argoDelete("recSample", "setRecSampleCallDelete", "__", param);
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
				workLog = '[그룹ID:' +  gGroupId + '] 삭제';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
	var playRecord	= function(grid, rowIndex) {
		var arrChecked = [] ;
		
		/* if(rowIndex === undefined) {
			arrChecked = w2ui['grid'].getSelection();
			tmpSelection = arrChecked;
		} else {
			arrChecked.push(rowIndex);
			tmpSelection = arrChecked;
		} */
		arrChecked = rowIndex;
		tmpSelection = rowIndex;
		
		var tenantId2 		= $('#s_FindTenantId option:selected').val();
		var logTenantId 	= tenantId;
		var logWorkerId 	= userId;
		var logWorkIp 		= workIp;
		var logListeningKey = ""; 
		var logUserId 		= "";
		var logRealtimeFlag = "4";
		
		var form	= document.getElementById("stt_form");
		if (form == null) {
			form	= document.createElement("form");
			form.setAttribute("id", "stt_form");
			form.setAttribute("method", "post");
			form.setAttribute("target", "sttPlay");
			
			var agent = navigator.userAgent.toLowerCase();

			if (agent.indexOf("chrome") != -1) {
				var playUrl	= gGlobal.ROOT_PATH + "/recording/STTPlaychromeF.do";
			} else {
				//alert("IE재생");
				var playUrl	= gGlobal.ROOT_PATH + "/recording/STTPlayieF.do";
			}
			
			form.setAttribute("action", playUrl);
			
			document.getElementsByTagName("body").item(0).appendChild(form);
			
			var recData	= document.createElement("input");
			recData.setAttribute("type", "hidden");
			recData.setAttribute("id", "recData");
			recData.setAttribute("Name", "recData");
			
			form.appendChild(recData);
		}
		
		var recList	= [];
		
	 	$.each(arrChecked, function( row, colIndex ) {
	 		//var colIndex	= arrChecked[colIndex];
			var recItem		= new Object();
			
			//colIndex는 json 객체이므로 index property를 불러와야 함.
			//ex) colIndex, idxCustName -> colIndex.index, idxCustName
			//colIndex		= colIndex.index;	 
			var custName 	= "샘플콜";
			var telNo		= "샘플콜";
			
// 			logListeningKey = w2ui['grid'].getCellValue(colIndex, 25);
			logListeningKey = dataArray[colIndex].recTimeConv;
// 			logUserId 		= w2ui['grid'].getCellValue(colIndex, 7);
			logUserId 		= dataArray[colIndex].userId;
// 			logDnNo 		= w2ui['grid'].getCellValue(colIndex, 9);
// 			logRecKey 		= w2ui['grid'].getCellValue(colIndex, 19);
			logRecKey 		= dataArray[colIndex].recKey;
			
// 			var callId 		= grid.getCellValue(colIndex, 23);
			var callId 		= dataArray[colIndex].callId;
			var recTime		= logListeningKey;
			var custName 	= "샘플콜";
			var userName	= "샘플콜";
			var custTel		= "샘플콜";
// 			var endTime		= parseInt(w2ui['grid'].getCellValue(colIndex, 9));
			var endTime		= dataArray[colIndex].endTime;
			var fmtEndTime	= (parseInt(endTime.split(":")[0])*60*60) + (parseInt(endTime.split(":")[1])*60)
							+ (parseInt(endTime.split(":")[2]));
// 			var fmtRecTime 	= logListeningKey = logListeningKey;
			var fmtRecTime	= recTime.substr(0,4)+"-"+recTime.substr(4,2)+"-"+recTime.substr(6,2) + " "
							+ recTime.substr(8,2)+":"+recTime.substr(10,2)+":"+recTime.substr(12,2);
			
			//청취로그  start
			var logDnNo 	= dataArray[colIndex].dnNo;
// 			var tenantId2 	= w2ui['grid'].getCellValue(colIndex, 1);
			var tenantId2 	= dataArray[colIndex].tenantId;
			
			var rowMfuIp	= (dataArray[colIndex].mfuIp == "" || dataArray[colIndex].mfuIp == null) ? "undefined" : dataArray[colIndex].mfuIp;
			
			recItem.tenant_id	= tenantId2;
			recItem.call_id		= callId;
// 			recItem.ip			= mfsIp;
// 			recItem.ip			= (rowMfuIp == "undefined" ? mfsIp : rowMfuIp);

			// nat ip range 포함 여부 체크
			var natRangeYn = false;
			argoJsonSearchList('ipInfo', 'getNatRangeList', 's_', {"findTenantId":tenantId}, function(data, textStatus, jqXHR) {
				try {
					if(data.isOk()){
						if(data.getRows() != "") {
							$.each(data.getRows(), function(index, row) {
								if(!natRangeYn) {
									if("A" == (row.ipClass).trim()) {
										if((row.natIpRange).trim().split(".")[0] == workIp.split(".")[0]) {
											natRangeYn = true;
										}
									} else if("B" == (row.ipClass).trim()) {
										if((row.natIpRange).trim().split(".")[0] == workIp.split(".")[0]
											&& (row.natIpRange).trim().split(".")[1] == workIp.split(".")[1]) {
											natRangeYn = true;
										}
									} else if("C" == (row.ipClass).trim()) {
										if((row.natIpRange).trim().split(".")[0] == workIp.split(".")[0]
											&& (row.natIpRange).trim().split(".")[1] == workIp.split(".")[1]
											&& (row.natIpRange).trim().split(".")[2] == workIp.split(".")[2]) {
											natRangeYn = true;
										}
									}
								}
							});
						}
					}
				} catch(e) {
						console.log(e);			
				}
			});

			if(natRangeYn) {
				recItem.ip = mfuNatIp;
			} else {
				recItem.ip = (rowMfuIp == "undefined" ? mfsIp : rowMfuIp);
			}

// 			recItem.port		= 7210;
			recItem.port		= (<%= isHttps %> ? 7220 : 7210);
			recItem.manager_id	= userId;
			recItem.enc_key		= 'BRIDGETEC_VELOCE';
			recItem.dn_no		= logDnNo;
			recItem.rec_time	= fmtRecTime;
			recItem.userName	= userName;
			recItem.custTel		= custTel;
// 			recItem.endTime		= endTime;
			recItem.endTime		= fmtEndTime;
			recItem.custName	= custName;
			
			recList.push(recItem);
			logListeningKey = getTimeStamp2()+"00"; 
			//if(isUseRecReason != "1")
				//argoJsonUpdate("recInfo", "setRecLogInsert", "ip_", {"tenantId":logTenantId, "workerId":logWorkerId, "listeningKey":logListeningKey ,"workerIp":logWorkIp, "userId":logUserId, "dnNo":logDnNo, "realtimeFlag":logRealtimeFlag, "recKey":logRecKey});
	 	});
		
		var recData			= document.getElementById("recData");
		var txtRecData		= JSON.stringify(recList);
		recData.value		= encodeURIComponent(txtRecData);
		gPopupOptions.grid	= w2ui.grid;
		form.submit();
		
		return true;
	}
	
	function getSelectedCells2Rows(selectCells)
	{
		var length		= selectCells.length;
		var result		= [];
		var preRecId	= -1;
		for (var index in selectCells)
		{
			var cell	= selectCells[index];
			if (cell.recid != preRecId)
			{
				result.push(cell.recid);
				preRecId	= cell.recid;
			}
		}
		
		
		return result;
	}
	
	// logRealtimeFlag 0=일반청취 / 1=실시간감청 / 2=파일변환 / 3=상담APP / 4=샘플콜
	/* function fnRecIsNotUseRecReason(indexs,logRealtimeFlag){
		for(var i=0;i<indexs.length;i++){
			var index = indexs[i];
			var logTenantId = tenantId;
			var logWorkerId = userId;
			var logWorkIp = workIp;
			var logListeningKey = getTimeStamp2()+setZeroNumFn(index);
			
			var logPhoneIp = w2ui['grid'].getCellValue(index, idxPhoneIp);
			var logRecTime = w2ui['grid'].getCellValue(index, idxRecDate) + w2ui['grid'].getCellValue(index, idxRecTime);
			var logUserId = w2ui['grid'].getCellValue(index, idxUserId);
			var logDnNo = w2ui['grid'].getCellValue(index, idxDnNo);
			var logRecKey = w2ui['grid'].getCellValue(index, idxRecKey);
			
			argoJsonUpdate("recInfo", "setRecLogInsert", "ip_", {
				"tenantId" : logTenantId,
				"workerId" : logWorkerId,
				"listeningKey" : logListeningKey,
				"workerIp" : logWorkIp,
				"userId" : logUserId,
				"dnNo" : logDnNo,
				"userIp": logPhoneIp ,
				"recTime" :  logRecTime, 
				"realtimeFlag" : logRealtimeFlag,
				"recKey" : logRecKey
			});
		}
	} */
	
</script>
</head>
<body>
	<div class="sub_wrap">
		<div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">샘플콜관리</span><strong class="step">샘플콜조회</strong></div>
			<section class="sub_contents">
				<div class="search_area">
					<div class="row">
						<ul class="search_terms">
							<li id="div_tenant">
								<strong class="title ml20">태넌트</strong> 
								<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
								<input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" /> 
								<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1">
							</li>
							<li>
								<strong class="title ml20" >상담사</strong>
								<input type="text" id="s_FindUserNameText"
								name="s_FindUserNameText" style="width: 160px"
								class="clickSearch" />
							</li>
							<li>
								<strong class="title" >등록자</strong>
								<input type="text" id="s_FindInsNameText"
								name="s_FindInsNameText" style="width: 160px"
								class="clickSearch" />
							</li>
							<li style="width: 530px"><strong class="title ml20">통화일자</strong>
	                 <span class="select_date">
	                     <input type="text" class="datepicker onlyDate" id="selReqDt_From" name="selReqDt_From">
	                 </span>
	                 <span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span>
	                 <span class="select_date">
	                     <input type="text" class="datepicker onlyDate" id="selReqDt_To" name="selReqDt_To">
	                 </span>
	                 </span> &nbsp; <select id="selDateTerm1" name="" style="width: 70px;" class="mr5"></select>
	             </li>
					</ul>
				</div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">분류명</strong>
                            <input type="text"	id="s_FindDepthPath" name="s_FindDepthPath" class="mr10" onclick="javascript:sortSh();" style="width:200px" readOnly/>
                            <input type="text"	id="s_FindGroupName" name="s_FindGroupName" class="mr10" onclick="javascript:sortSh();" style="width:200px" readOnly/>
                            <button type="button" id="btnSort" class="btn_m" >분류조회</button>
                        </li>
                      </ul>
                </div>
            </div>
            <div class="btns_top">
	           <div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span>
	            	
	            	<select id="s_SearchCount" name="s_SearchCount" style="width: 50px"
						class="list_box">
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="30">30</option>
						<option value="40">40</option>
						<option value="50">50</option>
					</select>
					
					 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
                <button type="button" id="btnPlay" class="btn_m">일괄재생</button>
                <!-- <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button> -->
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
              <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 415px;"></div>
	                <div class="list_paging" id="paging">
                		<ul class="paging">
                 			<li><a href="#" id='' class="on"></a>1</li>
                 		</ul>
                	</div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>