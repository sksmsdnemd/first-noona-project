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

<script>
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var userId 		= loginInfo.SVCCOMMONID.rows.userId;
var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var grantId 	= loginInfo.SVCCOMMONID.rows.grantId ;

var workMenu 	= "청취로그기본조회";

var workLog 	= "";
var dataArray 	= new Array();

var isUseRecReason = "0";

	$(document).ready(function(param) {
		// 청취 사유 사용여부 설정값 조회
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
		
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	var fvKeyId ; 
	
	function fnInitCtrl(){
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});
		
		/* if(grantId == "SuperAdmin" && grantId == "SystemAdmin"){
			$("#divTenantArea").show();
		} */
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#divTenantArea").hide();
		} 
		
		$("#s_FindTenantId").val(tenantId);
		
		argoSetDatePicker();
		
		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		
		fnAuthBtnChk(parent.$("#authKind").val());

		$('.timepicker.rec').timeSelect({use_sec:true});
		
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
		
		$("#btnReset").click(function(){
			$('#s_FindKey option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
			argoSetValue("s_txtDate1_From", today());
			argoSetValue("s_txtDate1_To", today());
			argoSetValue("s_RecFrmTm", "00:00:00");
			argoSetValue("s_RecEndTm", "23:59:59");
			$("#s_FindGroupKind option:eq(0)").attr("selected", "selected");
			$('#s_FindRealtimeFlag option[value=""]').prop('selected', true);
			$('#selDateTerm1 option[value="T_0"]').prop('selected', true);
			
			argoSetValue("s_FindWorkerId", "");
			argoSetValue("s_FindWorkerNm", "");
			argoSetValue("s_FindUserId", "");
			argoSetValue("s_FindUserNm", "");
		});	
		
		$(".clickSearch").keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		
		$("#btnReasonAdd").click(function(){
			argoPopupWindow('청취사유관리','RecSearchLogReasonPopAddF.do', '600', '600');
		});
	}
	
	function fnGetRecLogFlagName(flag){
		if(flag == "0"){
		    flag = "파일청취";
	    }else if(flag == "2"){
	    	flag = "파일변환";
	    }else if(flag == "1"){
	    	flag = "실시간청취"
	    }else if(flag == "3"){
	    	flag = "상담 APP"
	    }else if(flag == "4"){
	    	flag = " 샘플콜";
	    }else if(flag == "01"){
	    	flag = "일반청취스크린";
	    }else{
	    	flag = "샘플콜 스크린";
	    }
		return flag;
	}
	
	function today(){
		   
		var date = new Date();
   
        var year  = date.getFullYear();
        var month = date.getMonth() + 1; // 0부터 시작하므로 1더함 더함
        var day   = date.getDate();
    
		if (("" + month).length == 1) { month = "0" + month; }
        if (("" + day).length   == 1) { day   = "0" + day;   }
        
		return year+"-"+ month+"-"+ day;      
    }
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        multiSelect: true,
	        
	        columns: [  
						 { field: 'recid', 			     caption: 'recid', 				size: '0px', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'tenantId', 	         caption: 'tenantId', 			size: '0px', 	sortable: true, attr: 'align=center' ,frozen: true }
	            		,{ field: 'vworkSdate', 	     caption: '일자', 				size: '200px', 	sortable: true, attr: 'align=center' ,frozen: true }
	            		,{ field: 'realtimeFlag', 		 caption: '청취구분', 			size: '100px', 	sortable: true, attr: 'align=center' ,frozen: true }
	            		,{ field: 'workerId', 	         caption: '매니저ID', 			size: '100px', 	sortable: true, attr: 'align=center' ,frozen: true }
	            		,{ field: 'workerName', 		 caption: '매니저명', 			size: '100px', 	sortable: true, attr: 'align=center' ,frozen: true }
	            		,{ field: 'recTime', 		     caption: '통화일자', 			size: '200px', 	sortable: true, attr: 'align=center' ,frozen: true }
	            	 	,{ field: 'recReason', 	         caption: '청취사유분류', 		size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'recReasonText', 	     caption: '청취사유', 			size: '200px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userId', 	         caption: '상담사ID', 			size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userName', 		     caption: '상담사명', 			size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'dnNo', 		         caption: '내선번호', 			size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'vRecDate', 		     caption: 'vRecDate', 			size: '0px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'workerIp', 		     caption: '매니저접속IP', 		size: '150px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'workEdate', 		     caption: 'workEdate', 			size: '0px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'avgListeningTime', 	 caption: 'avgListeningTime', 	size: '0px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'totListeningTime', 	 caption: 'totListeningTime', 	size: '0px', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		if(isUseRecReason == "1") {
			w2ui['grid'].hideColumn('recid', 'tenantId', 'vRecDate', 'workEdate', 'avgListeningTime', 'totListeningTime');
		} else {
			w2ui['grid'].hideColumn('recid', 'tenantId', 'vRecDate', 'recReason', 'recReasonText', 'workEdate', 'avgListeningTime', 'totListeningTime');
		}
	}
	
	function fnSearchListCnt(){
		var recFrmDt = argoGetValue('s_txtDate1_From');
		var recFrmTm = argoGetValue('s_RecFrmTm');
		var recEndDt = argoGetValue('s_txtDate1_To');
		var recEndTm = argoGetValue('s_RecEndTm');
		argoJsonSearchOne('recInfo', 'getRecLogCount', 's_', {"tenantId":$("#s_FindTenantId").val(),findFromCondition:recFrmDt + " " + recFrmTm, findEndCondition:recEndDt + " " + recEndTm}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					
					$("#totCount").text(totalData);
					
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
	
	function fnSearchList(startRow, endRow) {
		var recFrmDt = argoGetValue('s_txtDate1_From');
		var recFrmTm = argoGetValue('s_RecFrmTm');
		var recEndDt = argoGetValue('s_txtDate1_To');
		var recEndTm = argoGetValue('s_RecEndTm');
		argoJsonSearchList('recInfo', 'getRecLogList', 's_', {"tenantId":$("#s_FindTenantId").val(), findFromCondition:recFrmDt + " " + recFrmTm, 
				findEndCondition:recEndDt + " " + recEndTm, "iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR) {
			try {
				if(data.isOk()) {
					w2ui.grid.clear();
					if (data.getRows() != "") {
						var recTime;
						var vRecDate1; 
						var vRecTime;
						var proc = "";
						dataArray = [];
						$.each(data.getRows(), function( index, row) {
							recTime = ($.trim(row.recTime || "")).replace(/-/gi, "").replace(/:/gi, "");
                            if (recTime) {
                                vRecDate1 = recTime.substr(0,4) + "-" + recTime.substr(4,2) + "-" + recTime.substr(6,2);
                                vRecTime  = recTime.substr(8,2) + ":" + recTime.substr(10,2) + ":" + recTime.substr(12,2);
                                proc 	  = vRecDate1 + " " + vRecTime;
                            }
                            var flag = row.realtimeFlag.trim();
                            flag = fnGetRecLogFlagName(flag);
							
							gObject2 = { 
                                  "recid" 			  : index
                                , "tenantId"		  : row.tenantId
                                , "vworkSdate"		  : row.workSdate
                                , "recReason"		  : row.recReason
                                , "recReasonText"	  : row.recReasonText
                                , "realtimeFlag"	  : flag
                                , "workerId" 		  : row.workerId
                                , "workerName" 		  : row.workerName
                                , "recTime" 		  : proc
                                , "userId" 			  : row.userId
                                , "userName" 		  : row.userName
                                , "dnNo" 			  : row.dnNo
                                , "vRecDate" 		  : row.vRecDate
                                , "workerIp" 	      : row.workerIp
                                , "workEdate" 		  : row.workEdate
                                , "avgListeningTime"  : row.avgListeningTime
                                , "totListeningTime"  : row.totListeningTime
                            };
										
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
			}
			catch (e) {
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
	
</script>
</head>
<body>
	<div class="sub_wrap">
		<div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">청취로그조회</span><strong class="step">청취로그기본조회</strong></div>
		<section class="sub_contents">
			<div class="search_area row4">
				<div class="row" id="divTenantArea">
					<ul class="search_terms">
						<li style="width:263px">
							<strong class="title ml20" style="width:60px; ">태넌트</strong>
							<select id="s_FindTenantId" name="s_FindTenantId" class="mr10 clickSearch" style="width:150px;"></select>
						</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li style="width:263px">
							<strong class="title ml20" style="width:60px">매니저ID</strong>
							<input type="text"	id="s_FindWorkerId" name="s_FindWorkerId" class="mr10 clickSearch" style="width:150px" />
						</li>
						<li style="width:420px">
							<strong class="title ml20" style="width:60px">매니저명</strong>
							<input type="text"	id="s_FindWorkerNm" name="s_FindWorkerNm" class="mr10 clickSearch" style="width:150px" />
						</li>
						<li style="display:none">
							<strong class="title ml20">집계방법</strong>
							<select id="s_FindGroupKind" name="s_FindGroupKind" style="width:150px;" class="list_box">
								<option value="1">기본수집</option>
								<option value="2">집계</option>
							</select>
                		</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li style="width:263px">
							<strong class="title ml20" style="width:50px">상담사ID</strong>
							<input type="text"	id="s_FindUserId" name="s_FindUserId" class="mr10 clickSearch" style="width:150px" />
						</li>
						<li style="width:420px">
							<strong class="title ml20" style="width:60px">상담사명</strong>
							<input type="text"	id="s_FindUserNm" name="s_FindUserNm" class="mr10 clickSearch" style="width:150px" />
						</li>
                 		<li>
<!--                  		logRealtimeFlag 0=일반청취 / 1=실시간감청 / 2=파일변환 / 3=상담APP / 4=샘플콜 / x1=스크린 [ex)01=일반청취 스크린, 41=샘플콜 스크린] -->
							<strong class="title ml20">청취구분</strong>
							<select id="s_FindRealtimeFlag" name="s_FindRealtimeFlag" style="width:150px;" class="list_box">
								<option value="">선택하세요!</option>
								<option value="0">파일청취</option>
								<option value="1">실시간청취</option>
								<option value="2">파일변환</option>
								<option value="4">샘플콜</option>
							</select>
						</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li style="width:683px">
							<strong class="title ml20">조회일자</strong>
							<span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
							<span class="timepicker rec" id="rec_time1"><input type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time" value="00:00:00"><a href="#" class="btn_time">시간 선택</a></span>
							<span class="text_divide" style="width:234px">&nbsp; ~ &nbsp;</span>
							<span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
							<span class="timepicker rec" id="rec_time2"><input type="text" id="s_RecEndTm" name="s_RecEndTm" class="input_time" value="23:59:59"><a href="#" class="btn_time">시간 선택</a></span>
							<select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<div class="sub_l">
					<strong>전체</strong>	: <span id="totCount" >0</span> 
				</div>
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
				<button type="button" id="btnReasonAdd" class="btn_m confirm">사유분류등록</button>
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