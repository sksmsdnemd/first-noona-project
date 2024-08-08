<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<style type="text/css">
.memo {line-height: 22px};

</style>
<script>
	var loginInfo; 	
	var userId; 	
	var tenantId; 	
	var workIp; 	
	var workMenu; 	
	var workLog; 	
	var workIp;    	
	var sPopupOptions;
	var sCudMode;
	
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
     		return this[key] === undefined ? value : this[key];
	    };
    	try{
    		sCudMode = sPopupOptions.cudMode;
    		if(sCudMode != "A"){
    			loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
    			userId 		= loginInfo.SVCCOMMONID.rows.userId;
    			tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
    			workIp	 	= loginInfo.SVCCOMMONID.rows.workIp;
    			workMenu 	= "청취사유";
    			workLog 	= "";
    			workIp    	= loginInfo.SVCCOMMONID.rows.workIp;
    		}
    		ArgSetting();
    	  	fnInitCtrl();	
    	}catch(e){
    		console.log(e);
    	}
	});
	
	
	function ArgSetting() {
		argoCbCreate("s_logReasonTitle", "baseCode","getBaseComboList", {"classId" : "rec_reason"}, {"selectIndex" : 0,"text" : '선택하세요!',"value" : ''});
		
		var recordIndexs = sPopupOptions.pRowIndex;
		if(sCudMode == "0" || sCudMode == "2" || sCudMode == "4" || sCudMode == "01"){
			fnRecSearchListenList(recordIndexs);
		}else if(sCudMode == "1" ){
			$("#popTitle").append("내선번호 : "+recordIndexs.dnNo+"          상담사 : " + recordIndexs.userName +"<br/>");
		}else if(sCudMode == "3"){
			$("#popTitle").append("내선번호 : "+recordIndexs.dnNo+"          청취차 : " + recordIndexs.workId +"<br/>");	
		}
	}
	
	
	
	function fnRecSearchListenList(recordIndexs){
		for(var i=0;i<recordIndexs.length;i++){
			var recordIndex = recordIndexs[i];
			var records = parent.w2ui['grid'].get(recordIndex);
			$("#popTitle").append("통화일자 : "+(sCudMode == "4" ? records.recTime : records.recDate+records.recTime)+"          상담사 : " + (records.userName == null ? "" : records.userName )+"<br/>");
		}
	}
	
	function setZeroNumFn(num) {
	    if (Number(num) < 10)
	        return "0" + num;
	    return num;
	}
	
	function fnInitCtrl() {
		// logRealtimeFlag 0=일반청취 / 1=실시간감청 / 2=파일변환 / 3=상담APP / 4=샘플콜 / x1=스크린 [ex)01=일반청취 스크린, 41=샘플콜 스크린, 31=상담APP 스크린]
		$("#popConfirm").click(function(){
			if($("#s_logReasonTitle").val() == ""){
				parent.argoAlert("분류를 선택해주세요.");
				return;
			}
			
			if(sCudMode == "0" || sCudMode == "2" || sCudMode == "4" || sCudMode == "01"){
				fnRecSearchLogInsert();
			}else if(sCudMode == "1" ){
				fnMonitoringLogInsert();
			}else if(sCudMode == "3" ){
				fnAppRecSearchLogInsert();
			}
			
			argoPopupClose();
		});
	}
	
	// 상담 APP 청취 로그 등록
	function fnAppRecSearchLogInsert(){
		var record = sPopupOptions.pRowIndex;
		var listeningKey = getTimeStamp2();
		
		var logListeningKey = listeningKey+"00";
		var logWorkId = userId;
		var logDnNo = record.dnNo;
		var logCallId = record.callId;
		var logTenantId = record.tenantId;
		var logRealtimeFlag = sCudMode ;
		var logRecReason = $("#s_logReasonTitle").val();
		var logRecReasonText = $("#str_reason").val(); 
		
		var insResult = argoJsonUpdate("recInfo", "setAppRecLogRealInsert", "", {"tenantId":logTenantId,"loginIp":logWorkId, "dnNo":logDnNo, "listeningKey":logListeningKey 
			, "callId" : logCallId ,"realtimeFlag":logRealtimeFlag , "recReason":logRecReason , "recReasonText":logRecReasonText });
		
			if(insResult.SVCCOMMONID.procCnt < "1"){
				parent.argoAlert("call_id를 확인해주세요.");
			}else{
				parent.setAudioReason();
			}	
	}
	
	// 실시간감청 로그 등록
	function fnMonitoringLogInsert(){
		var recordIndexs = sPopupOptions.pRowIndex;
		var sTenantId = sPopupOptions.pTenantId;
		var sScrType = sPopupOptions.pScrType;
		
		var sIdx = sPopupOptions.idx;
		var sEvent = sPopupOptions.event;
		
		var logListeningKey = getTimeStamp2()+"00";
		var logRealtimeFlag = sCudMode;
		var logRecReason = $("#s_logReasonTitle").val();
		var logRecReasonText = $("#str_reason").val();
		var logDnNo = recordIndexs.dnNo;
		
		var result = argoJsonUpdate("recInfo", "setRecLogRealInsert", "", {"tenantId":sTenantId, "workerId":userId, "listeningKey":logListeningKey 
			,"workerIp":workIp, "dnNo":logDnNo, "realtimeFlag":logRealtimeFlag , "recReason":logRecReason , "recReasonText":logRecReasonText });
		
		if(result.SVCCOMMONID.procCnt < 1){
			parent.argoAlert("녹음중인 내선이 아닙니다. 확인해주세요.");
		}else {
			parent.RealTimePlayCallBack(sIdx,sEvent);
		}
	}
	
	// 청취,파일변환 로그 등록
	function fnRecSearchLogInsert(){
		var recordIndexs = sPopupOptions.pRowIndex;
		var listeningKey = getTimeStamp2();
		
		for(var i=0;i<recordIndexs.length;i++){
			var recordIndex = recordIndexs[i];
			var record = parent.w2ui['grid'].get(recordIndex);
			
			var logListeningKey = listeningKey+setZeroNumFn(i);
			var logUserId = record.userId;
			var logDnNo = record.dnNo;
			var logUserIp = record.phoneIp;
			var logRealtimeFlag = sCudMode;
			var logRecKey = record.recKey;
			var logRecReason = $("#s_logReasonTitle").val();
			var logRecReasonText = $("#str_reason").val(); 
			var logRecTime = sCudMode == "4" ? record.recTime : record.recDate+record.recTime;
			
			argoJsonUpdate("recInfo", "setRecLogInsert", "", {"tenantId":tenantId, "workerId":userId, "listeningKey":logListeningKey
				,"workerIp":workIp, "userId":logUserId, "dnNo":logDnNo, "userIp":logUserIp, "realtimeFlag":logRealtimeFlag
				, "recKey":logRecKey , "recReason":logRecReason , "recReasonText":logRecReasonText , "recTime" : logRecTime.replace(/[:-\s]/g,"") });
		}
		
		if(sCudMode == "0" || sCudMode == "4" ){
			parent.fnRecFilePlayCallBack(recordIndexs,sPopupOptions.pScrType);	
		}else if(sCudMode == "2"){
			parent.fnWavConvCallBack(recordIndexs);
		}else if(sCudMode == "01"){
			parent.fn_scrPopupCallBack(recordIndexs);
		}
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
	
	//listeningKey
	function getTimeStamp2() {
	    var d = new Date();
	    var date = leadingZeros(d.getFullYear(), 4) + leadingZeros(d.getMonth() + 1, 2) + leadingZeros(d.getDate(), 2);
	    var time = leadingZeros(d.getHours(), 2) + leadingZeros(d.getMinutes(), 2) + leadingZeros(d.getSeconds(), 2);

	    return date + time;
	}
	
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="pop_alim" style="display:block;height: 77%;">
					<div class="pop_bgLayer"></div>
					<div class="pop_box" style="top: 50%;">
						<div class="pop_t" style="height: 220px;">
							<div class="pop_message" style="padding:0">
								<div class="memo">
									<div id="popTitle" style="overflow:scroll;height: 85px;overflow-x: hidden;margin-bottom: 10px;"></div>
									<table style="width:100%;"><colgroup><col width="15%"/><col width="85%"/></colgroup>
										<tr>
										<td><span style="font-size:17px; color:#e80101; ">*</span> 분류</td>
										<td> 
											<select id="s_logReasonTitle" name="s_logReasonTitle" class="list_box" style="margin-bottom: 5px;background-color: #ffffff; width: 150px;border: 0.5px solid #eaeaea;">
											</select>
										</td>
										<tr><td>청취사유</td><td><textarea id="str_reason" style="border: 0.5px solid #eaeaea;height: 80px;" placeholder="청취사유를 입력하세요."></textarea></td>
										</tr>
									</table>
								</div>
							</div>
						</div>
						<div class="pop_h">
							<div class="pop_message2"></div>
						</div>
						<div class="pop_b">
							<a href="#" class="pop_confirm" id="popConfirm" onclick="">OK</a>
							<a href="#" class="pop_cancel" onclick="argoPopupClose();">Cancel</a>
						</div>
					</div>
				</div>
            	
<!--                 <div class="btn_areaB txt_r"> -->
<!--                     <button type="button" id="btnSavePop" name="btnSavePop" class="btn_m confirm" data-grant="W">저장</button>    -->
<!--                     <input type="hidden" id="ip_ProcessId" name="ip_ProcessId" > -->
<!--                     <input type="hidden" id="ip_ProcessClass" name="ip_ProcessClass" > -->
<!--                     <input type="hidden" id="ip_AlarmFlag" name="ip_AlarmFlag" > -->
<!--                     <input type="hidden" id="ip_InsId" name="ip_InsId" > -->
<!--                     <input type="hidden" id="ip_UptId" name="ip_UptId" >                  -->
<!--             	</div>               -->
            </div>            
        </section>
    </div>
</body>

</html>
