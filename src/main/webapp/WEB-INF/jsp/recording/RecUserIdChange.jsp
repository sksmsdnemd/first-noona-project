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
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var userId    = loginInfo.SVCCOMMONID.rows.userId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "상담사일괄변경";
	var workLog   = "";
	
	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});
	
	function fnInitCtrl(){
		
		argoSetDatePicker();
		$('.timepicker.rec').timeSelect({use_sec:true});
		
		fnArogoSetting();
		
		$("#btnSearch").click(function(){ //조회
			fnSearchList();			
		});

		$("#btnReset").click(function(){
			fnArogoSetting();
			$("#s_FindDnNo").val('');
		});

		$('.clickSearch').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
		});
		
		$("#btnUserChange").click(function(){
			fnUserChangeAll();
		});	
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
		argoSetValue("s_FindTenantId", tenantId);
	}
	
	function fnArogoSetting(){

		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code" :"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		argoSetValue("s_FindSRegTime", "00:00:00");
		argoSetValue("s_FindERegTime", "23:59:59");
		$('#selDateTerm1 option[value="T_0"]').prop('selected', true);
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
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >= 0) {
					gPopupOptions = {cudMode:'U', pRowIndex:record};
					argoPopupWindow('상담사일괄변경상세', 'RecUserIdChangeDetailF.do',  '900', '620' );
				}
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'recTime', 		caption: '통화일자', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'dnNo', 			caption: '내선번호', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'groupId', 		caption: '그룹ID',		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'groupName', 		caption: '그룹', 			size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userId', 		caption: '상담사ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'minRecTime', 	caption: '최근통화시간1', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'maxRecTime', 	caption: '최근통화시간2', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'dnNoBat', 		caption: '내선번호2', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userIdBat', 		caption: '상담사ID2', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'blankCnt', 		caption: '건수', 			size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'blankStart', 	caption: '최초건수일시', 		size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'blankEnd', 		caption: '마지막건수일시', 	size: '17%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'startDate', 		caption: '최초건수일시', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'endDate', 		caption: '마지막건수일시', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userIdCombo',	caption: '지정상담사', 		size: '12%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userIdSelect', 	caption: '선택', 			size: '5%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'minRecTime', 'maxRecTime', 'dnNoBat', 'userIdBat', 'groupId', 'startDate', 'endDate');
	}

	function fnSearchList(){;
	
		var findSTime = $("#s_txtDate1_From").val().replace(/-/gi,"") + $("#s_FindSRegTime").val().replace(/:/gi,"");
		var findETime = $("#s_txtDate1_To").val().replace(/-/gi,"") + $("#s_FindERegTime").val().replace(/:/gi,"");
		var findBTime = argoDateToStr(argoAddDate($("#s_txtDate1_From").val().replace(/-/gi,""),-3)) + '000000';
		var checkDnNo = "";
		var checkUser = "";
		var totCnt    = 0;
		var btnHtml   = "";
		
		argoSetValue("s_FindSRecTime", findSTime);
		argoSetValue("s_FindERecTime", findETime);
		argoSetValue("s_FindBefTime",  findBTime);
		
		w2ui.grid.lock('조회중', true);

		argoJsonSearchList('recordFile', 'getRecFileList', 's_', {"tenantId":argoGetValue("s_FindTenantId")}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();
					totCnt = 0;
					
					var startFlag = "Y";
					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							if(index == 0 || (checkDnNo != row.dnNo)){
								
								checkUser = '<select id="s_' + totCnt + '" name="s_' + totCnt + '" style="width:150px;">';
								
								var optionId    = "";
								var optionArray = new Array();
								var cntFlag     = 0;
								var totDnCnt    = 0;
								var termTime    = "";
								var termStart   = "";
								
								$.each(data.getRows(), function( idx, rw ) {
									
									if((row.dnNo == rw.dnNo)){
										if(rw.userIdBat != null){
											if(rw.userIdBat != optionId){
												var optionAdd = "Y";
												
												if(optionArray.length > 0){
													var optionCkId = "";
													for(var i=0; i<optionArray.length; i++){
														optionCkId = optionArray[i];
														
														if(optionCkId == rw.userIdBat){
															optionAdd = "N";
														}
													}
												}
												optionArray[cntFlag] = rw.userIdBat;
												
												if(optionAdd == "Y"){
													checkUser += '<option id="' + rw.userIdBat + '" value="' + rw.userIdBat + '">' + rw.userIdBat + '_' + rw.userNameBat + '</option>';
												}
												cntFlag++;
											}
											optionId = rw.userIdBat;
										}
										
										if(termTime != rw.recTimeTerm){
											if(startFlag == "Y"){
												termStart = rw.recTimeTerm;
												startFlag = "N";
											}
											totDnCnt++;
											termTime = rw.recTimeTerm;
										}
									}
								});

								checkUser += '</select>';
								
								btnHtml = '<a href="javascript:fnUserSearch(' + totCnt + ');"><img src="../images/icon_searchOff.png"></a>';
								
								gObject2 = {  "recid" 			: totCnt
					    					, "recTime"			: fnStrMask("YMD", row.recTime)
					   						, "dnNo"			: row.dnNo
											, "groupId" 		: row.groupId
											, "groupName" 		: row.groupName
											, "userId" 			: row.userId
											, "minRecTime" 		: row.minRecTime
											, "maxRecTime" 		: row.maxRecTime
											, "dnNoBat" 		: row.dnNoBat
											, "userIdBat" 		: row.userIdBat
											, "blankCnt" 		: totDnCnt
											, "blankStart" 		: fnStrMask("DHMS",termStart)
											, "blankEnd" 		: fnStrMask("DHMS",termTime)
											, "startDate" 		: termStart
											, "endDate" 		: termTime
											, "userIdCombo" 	: checkUser
											, "userIdSelect" 	: btnHtml
										};
								
								dataArray.push(gObject2);
								totCnt++;
								startFlag = "Y";
							}
							checkDnNo = row.dnNo;
						});
						
						w2ui['grid'].add(dataArray);
					}
					$("#totCount").text(totCnt);
					if(totCnt == 0){
						argoAlert('조회 결과가 없습니다.');
					}
				}
				w2ui.grid.unlock();
			} catch(e) {
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
	
	function fnUserSearch(idx){
		
		gPopupOptions = {cudMode:"S", recId:idx};
	 	argoPopupWindow('상담사검색', 'UserSearchPopupF.do', '900', '700');	
	}
	
	function fnAppendOption(idx, userId, userNm){
		
		var appendHtml = '<option id="' + userId + '" value="' + userId + '">' + userId + '_' + userNm + '</option>';
		
		$("#s_"+idx).find("option").remove();
		$("#s_"+idx).append(appendHtml);
	}
	
	function fnUserChangeAll(){
		try{
			
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("상담사 일괄변경할 내선번호를 선택하세요"); 
		 		return ;
			}

			argoConfirm('상담사 일괄변경을 하시겠습니까?', function() {
				var dnNo         = "";
				var strUserId    = "";
				var strStartDt   = "";
				var strEndDt     = "";
				var strRecId     = "";
				
				/** (2023.08.18) 상담사일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) START */
				var strCallDt    = "";
				/** (2023.08.18) 상담사일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) END */
				
				var multiService = new argoMultiService(fnCallbackSave);
				
				$.each(arrChecked, function( index, value ) {
					strRecId   = w2ui['grid'].getCellValue(value, 0);
				    /** (2023.08.18) 상담사일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) START */
					strCallDt  = w2ui['grid'].getCellValue(value, 1).replace(/-/gi, '');
				    /** (2023.08.18) 상담사일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) END */
					dnNo   	   = w2ui['grid'].getCellValue(value, 2);
					strStartDt = w2ui['grid'].getCellValue(value, 11);
					strEndDt   = w2ui['grid'].getCellValue(value, 12);
					strUserId  = $("#s_" + strRecId).val();
					
					if(strUserId == null){
						strUserId = "";
					}
					
					var param = { 
									"tenantId"		: argoGetValue("s_FindTenantId"),
									"dnNo" 			: dnNo,
									"userId" 		: strUserId,
									"findSRecTime" 	: argoGetValue("s_FindSRecTime"),
									"findERecTime" 	: argoGetValue("s_FindERecTime"),
									"callDt"        : strCallDt /** (2023.08.18) 상담사일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) */
								};

					multiService.argoUpdate("recordFile", "setRecFileUserIdUpdate", "__", param);
					
					workLog = '[내선번호:' + dnNo + ' | 기간:' + strStartDt + '~' + strEndDt + ' | 변경ID:' + userId + '] 변경';
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
									,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				});
				
				multiService.action();
		 	}); 
		}catch(e){
			console.log(e) ;	 
		}
	}
	
	function fnCallbackSave(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {	  
		    	argoAlert('성공적으로 변경 되었습니다.');
		    	fnSearchList();
		    }
		} catch(e) {
			argoAlert(e);    		
		}
	}

</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">전송상태조회</span><strong class="step">상담사일괄변경</strong></div>
        <section class="sub_contents">
            <div class="search_area">
                <div class="row">
                    <ul class="search_terms">
                    	<li id="div_tenant">
							<strong class="title ml20">태넌트</strong> 
							<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
						</li>
                    
                    	<li style="width:340px">
                    		<strong class="title ml20">내선번호</strong>
                            <input type="text"	id="s_FindDnNo" name="s_FindDnNo" class="clickSearch" style="width:115px"/>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">검색기간</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                            <span class="timepicker rec" id="rec_time1"><input type="text" id="s_FindSRegTime" name="s_FindSRegTime" class="input_time"><a href="#" class="btn_time">시간 선택</a></span> 
							<span class="text_divide">~</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                            <span class="timepicker rec" id="rec_time2"><input type="text" id="s_FindERegTime" name="s_FindERegTime" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                            <select id="selDateTerm1" name="" style="width:86px; display:none" class="mr5"></select>
                        </li>
                    </ul>
                </div>
            </div>     
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnUserChange" class="btn_m confirm">상담사일괄변경</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
                <input type="hidden" id="s_FindSRecTime" name="s_FindSRecTime" />
                <input type="hidden" id="s_FindERecTime" name="s_FindERecTime" />
                <input type="hidden" id="s_FindBefTime"  name="s_FindBefTime" />
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 415px;"></div>
                </div>
	        </div>
        </section>
    </div>
</body>

</html>