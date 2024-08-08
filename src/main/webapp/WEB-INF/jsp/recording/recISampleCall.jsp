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

<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet" 	href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.contants.css?ver=2017021601"/>"	type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript"  src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>

<script>
var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
var userId = loginInfo.SVCCOMMONID.rows.userId;
var tenantId = loginInfo.SVCCOMMONID.rows.tenantId;
var workIp = loginInfo.SVCCOMMONID.rows.workIp;
var grantId = loginInfo.SVCCOMMONID.rows.grantId;

var workMenu = "샘플콜조회";
var workLog = "";
var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;

var mfsIp;
var mfuNatIp;

var dataArray = new Array();
	$(document).ready(function(param) {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	var fvKeyId ; 
	
	
	function fnInitCtrl(){		

		fnAuthBtnChk(parent.$("#authKind").val());
		
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
			argoPopupWindow('샘플콜분류조회', 'recSampleGrpPopAddF.do',  '600', '490' );
		});	
		
		$("#btnExcel").click(function(){
			var excelArray = new Array();
			var recTime;
			var vRecDate1; 
			var vRecTime;
			var proc;
			argoJsonSearchList('recSample','getSampleCallList','s_', {tenantId:tenantId,"iSPageNo":100000000,"iEPageNo":100000000}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {
							recTime     = row.recTime;
							vRecDate1	= recTime.substr(0,4)+"-"+recTime.substr(4,2)+"-"+recTime.substr(6,2);
							vRecTime	= recTime.substr(8,2)+":"+recTime.substr(10,2)+":"+recTime.substr(12,2);
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
						argoPopupWindow('Excel Export',  gGlobal.ROOT_PATH+'/common/VExcelExportF.do',  '150', '40');
						
						alert()
						workLog = '[TenantId:' + tenantId + ' | UserId:' + userId + ' | GrantId:' + grantId + '] Excel Export';
						argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
										,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
					}
				} catch (e) {
					console.log(e);
				}
			});
			

		});	

		$("#btnReset").click(function(){
			argoSetValue("s_FindDepthPath", "");
			argoSetValue("s_FindGroupName", "");
		});	
		
		argoJsonSearchOne('comboBoxCode','getMfuIpList','s_', {}, function (data, textStatus, jqXHR){
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

	}
	function sortSh(){
		argoPopupWindow('샘플콜분류조회', 'recSampleGrpPopAddF.do',  '600', '490' );
	}
	
	function memo(idx){
		content = w2ui['grid'].getCellValue(idx,11);
		recKey = w2ui['grid'].getCellValue(idx,19);
		parm={
				"content" : content,
				"recKey" : recKey
		};
		gPopupOptions = {pRowIndex:parm} ;
		argoPopupWindow('메모보기', 'recSampleMemoPopAddF.do',  '600', '200' );
	} 	
	
	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        onDblClick: function(event) {
	        	if (event.recid >=0 ) {
	        		//w2ui['grid'].select(evnet.recid);
	        		fnRecFilePlay(event.recid);
	        	}	
	        },
	        multiSelect: true,
	       
	        columns: [  
						 { field: 'recid', 			 	caption: 'recid', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'tenantId', 	     	caption: 'tenantId', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'depthPath', 	 		caption: '분류', 					size: '20%', 	sortable: true, attr: 'align=left' }
	            	 	,{ field: 'realtimeFlag', 		caption: '듣기', 					size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'workerId', 		    caption: '청취구분', 				size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'recTime', 		 	caption: '통화일자', 				size: '20%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'groupName', 		 	caption: '그룹', 					size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'userId', 	     	caption: '상담사ID', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userName', 		 	caption: '상담사명', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'dnNo', 		     	caption: '내선번호', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'endTime', 	        caption: '통화시간', 				size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'content', 	 		caption: '메모보기', 				size: '0%', 	sortable: true, attr: 'align=center' }
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
	            		
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'mediaScr','content', 'tenantId','uploadCntVoice','uploadCntScr','groupId','spGrpName','mediaVoice','recKey','phoneIp','topParentGroupName','mediaKind','realtimeFlag','workerId','callId','custTel','recTimeConv');
	   
	}
	
	function fnRecFilePlay(index) {
		
		var FileList;

		console.log("playerKind="+playerKind);	
		
	    var logTenantId 	= tenantId;
		var logWorkerId 	= userId;
		var logWorkIp 		= workIp;
		var logRealtimeFlag = "0";	//파일청취
		var logListeningKey = "";
		var logUserId 		= "";
		var logDnNo 		= "";
		var logRecKey 		= "";

		if (playerKind == null || playerKind == "0") {

			var callId 		= w2ui['grid'].getCellValue(index, 23);
			var recTime		= w2ui['grid'].getCellValue(index, 25);
			var telNo		= w2ui['grid'].getCellValue(index, 24);
			
			// nat ip range 포함 여부 체크
			var mfuIp		= "";
			var natRangeYn	= false;
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
				mfuIp = mfuNatIp;
			} else {
				mfuIp = mfsIp;
			}
			
// 		    var strUrl = "/BT-VELOCE/recording/RecPlayerF.do?tenant_id=" + encodeURI(encodeURIComponent(tenantId)) + "&call_id=" + callId + "&ip=" + mfsIp + "&port=7210&agent_id=" + userId +
		    var strUrl = "/BT-VELOCE/recording/RecPlayerF.do?tenant_id=" + encodeURI(encodeURIComponent(tenantId)) + "&call_id=" + callId + "&ip=" + mfuIp + "&port=7210&agent_id=" + userId +
		    			 "&recTime=" + recTime + "&telNo=" + telNo;
		    var win = window.open(strUrl, "playForm", "toolbar=no,directories=no,width=334, height=150,menubar=0,resizable=no,scrollbars=0,location=0,status=0");
			win.focus();
			
			//청취로그  start
			logListeningKey = w2ui['grid'].getCellValue(index, 25);
			logUserId 		= w2ui['grid'].getCellValue(index, 7);
			logDnNo 		= w2ui['grid'].getCellValue(index, 9);
			logRecKey 		= w2ui['grid'].getCellValue(index, 19);
			//logRealtimeFlag	= w2ui['grid'].getCellValue(index, 3);

			argoJsonUpdate("recInfo","setRecLogInsert","ip_", {"tenantId":logTenantId,"workerId":logWorkerId,"listeningKey":logListeningKey
					,"workerIp":logWorkIp,"userId":logUserId,"dnNo":logDnNo,"realtimeFlag":logRealtimeFlag,"recKey":logRecKey});
			//청취로그  end
			
			return;			
		}

	    var url;

	    //URLEncoder.encode(tenantId, "UTF-8");

		if (index >= 0) {
			//alert(index);
			w2ui['grid'].select(index);
			//alert(w2ui['grid'].getCellValue(index, idxCallId));
			url = "http://127.0.0.1:8282?cmd=0&tenant_id=" + tenantId + "&call_id=" + w2ui['grid'].getCellValue(index, 23);
		
			//청취로그  start
			logListeningKey = w2ui['grid'].getCellValue(index, 25);
			logUserId 		= w2ui['grid'].getCellValue(index, 7);
			logDnNo 		= w2ui['grid'].getCellValue(index, 9);
			logRecKey 		= w2ui['grid'].getCellValue(index, 19);
			//logRealtimeFlag	= w2ui['grid'].getCellValue(index, 3);
			
			argoJsonUpdate("recInfo","setRecLogInsert","ip_", {"tenantId":logTenantId,"workerId":logWorkerId,"listeningKey":logListeningKey
					,"workerIp":logWorkIp,"userId":logUserId,"dnNo":logDnNo,"realtimeFlag":logRealtimeFlag,"recKey":logRecKey});
			//청취로그  end
		}
	
		var xhr = new XMLHttpRequest();
			
		xhr.open("post" , url , true);
		xhr.onreadystatechange = function() {
			if(xhr.readyState == 4 && xhr.status == 200)
			{
				var data = xhr.responseText;
				var rsCode = data.split("^");
				//if( rsCode[0] == "({'result':'0000'});" ){
				if( rsCode[0].trim().indexOf("'result':'0000'")!=-1){		
					//alert('success');
				}else{
					alert('fail : ' + rsCode[0]);
				}
			}
		}
			
		xhr.send();
		//xhr.clear();
		return;
	}
	
	function timeCal(seconds) {
		var hour = parseInt(seconds/3600);
		var min = parseInt((seconds%3600)/60);
		var sec = seconds%60;
		if(min < 10 && sec > 9 ){
			return hour+":"+"0"+min+":"+sec;
		}else if( sec < 10 && min < 10){
			return hour+":"+"0"+min+":"+"0"+sec;
		}	
		return hour+":"+min+":"+sec;	
		
		

	}
	function fnSerch(param) {
		argoSetValue("s_FindDepthPath", param.depthPath);
		argoSetValue("s_FindGroupName",param.groupName);
		fnSearchListCnt();
	}
	
	function fnSearchListCnt(){
		argoJsonSearchOne('recSample','getSampleCallCount','s_', {"tenantId":tenantId}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					$("#totCount").html(totalData);
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
		argoJsonSearchList('recSample','getSampleCallList','s_', {tenantId:tenantId,"iSPageNo":startRow,"iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if (data.getRows() != ""){ 
						dataArray = [];
						var subAdd;
						$.each(data.getRows(), function( index, row ) {
							
							subAdd = ' <button type="button" id="sub" class="btn_m" onclick="javascript:memo('+index+');">메모보기</button>';
							recTime     = row.recTime;
							
							endTime     = row.endTime;
							vRecDate1	= recTime.substr(0,4)+"-"+recTime.substr(4,2)+"-"+recTime.substr(6,2);
							vRecTime	= recTime.substr(8,2)+":"+recTime.substr(10,2)+":"+recTime.substr(12,2);
							proc = vRecDate1+" "+vRecTime;
							endTime1 = timeCal(endTime);
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
		argoConfirm('선택한 샘플콜 ' +arrChecked.length + '건을  삭제하시겠습니까?', function() {
			var multiService = new argoMultiService(fnCallbackDelete);
			$.each(arrChecked, function( index, value ) {

				 gGroupId =  w2ui['grid'].getCellValue(value, 16);
				 tTenantId =  w2ui['grid'].getCellValue(value, 1);
				 rRecKey =  w2ui['grid'].getCellValue(value, 19);
				var param = { 
						"groupId"  : gGroupId, 
						"tenantId" : tTenantId,
						"recKey"   : rRecKey
				};
				multiService.argoDelete("recSample","setRecSampleCallDelete","__", param);
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
				workLog = '[그룹ID:'+ gGroupId +'] 삭제';
				argoJsonUpdate("actionLog","setActionLogInsert","ip_", {tenantId:tenantId,userId:userId
								,actionClass:"action_class",actionCode:"W",workIp:workIp,workMenu:workMenu,workLog:workLog});
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">샘플콜관리</span><strong class="step">샘플콜조회</strong></div>
        <section class="sub_contents">
            <div class="search_area">
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
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
                <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
                <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
                
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