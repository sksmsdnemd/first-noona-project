﻿﻿<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
	response.setHeader("Cache-Control","no-cache");
	response.setHeader("Pragma","no-cache");
	response.setDateHeader("Expires",0);
%>
<meta http-equiv="Cache-Control" content="no-cache"/>
<meta http-equiv="Expires" content="0"/>
<meta http-equiv="Pragma" content="no-cache"/>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/velocejs/veloce.popupWindow.js?ver=2017010611"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.ajax-cross-origin.min.js"/>"></script>
<style type="text/css">
</style>
<%
	//삼천리 커스텀
	String apirectime = request.getParameter("callDate");
	if (apirectime == null) {
		apirectime = "20190318010101";
	}

	//고객전화번호인지 DN개념인지 정확한 확인필요
	String apicusttel = request.getParameter("LV_PHONENUMBER");
	if (apicusttel == null) {
		apicusttel = "99999999999";
	}

	String apiRecSearch = request.getParameter("USE_SAP");
	if (apiRecSearch == null) {
		apiRecSearch = "0";
	} else {
		apiRecSearch = "1";
	}
	
	boolean isHttps = request.isSecure();
%>
<script>

	/************그리드 열 순서 정보 시작*********/
	var idxRecKey = 2;
	var idxFmtRecDate = 4;
	var idxFmtRecTime = 5;
	var idxGroupName = 6;
	var idxUserId = 7;
	var idxUserName = 8;
	var idxCustTel = 9;
	var idxCustName = 10
	var idxDnNo = 11
	var idxCustNo = 14
	//var idxCustEtc = 18;
	var idxCallId = 18;
	var idxRecDate = 19;
	var idxRecTime = 20;
	var idxEndTime = 21;
	var idxFileName = 22;
	var idxMfuIp = 27;
	var idxPhoneIp = 30;
	var idxMaskCustEtc = 31;
	/************그리드 열 순서 정보 종료*********/
	
	/************로그인 정보 시작*********/
	var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
	if(loginInfo!=null){	
		var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;	
		var userId      = loginInfo.SVCCOMMONID.rows.userId;
		var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
		var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
		var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
		var convertFlag = loginInfo.SVCCOMMONID.rows.convertFlag;
		var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
		var depth		= loginInfo.SVCCOMMONID.rows.depth;
		var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
		var backupAt	= loginInfo.SVCCOMMONID.rows.backupAt;
	}else{
		var tenantId    = 'bridgetec';	
		var userId      = 'btadmin';
		var grantId     = 'SuperAdmin';
		var workIp      = '127.0.0.1';
		var playerKind  = '0';
		var convertFlag = '1';
		var groupId		= '1';
		var depth		= 'A';
		var controlAuth	= null;
	}
	/************로그인 정보 종료*********/
	
	/************기타 정보 시작*********/
	var playerProtocol = "http://";
	var workMenu    = "통화내역조회";
	var workLog     = "";
	var ControlAuthGroup = new Array();
	var isUseUserCombo   = 1;
	var workPage	= "1";
	var gPopupOptions	= {};
	var mfsIp;
	var mfuNatIp;
	var tmpSelection;
	var dataArray = new Array();
	var markArray = new Array();
	var termValList  = '<spring:eval expression="@code['Globals.termValList']"/>';
	var termValArr = termValList.split("|");
	var maxTerm;
	var recAuth = '<spring:eval expression="@code['Globals.recAuth']"/>';
	var custInfoAuthStr = '<spring:eval expression="@code['Globals.custInfoChange']"/>'.split("|");
	var custInfoAuth = false;
	var isUseRecReason;
	/************기타 정보 종료*********/
	
	jData = [];
	
	for (var i = 0; i < termValArr.length; i++) {
		var text = termValArr[i].split(":");
		var arrTxt = {};
		arrTxt.codeNm = text[0];
		arrTxt.code = text[1];
		jData.push(arrTxt);
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
	
	$(document).ready(function() {
		$("#searchPanel").hide();
		$("#searchPanel_SAP").hide();
		$("#searchPanel_SAP2").hide();
		
		vlcOPT.VLC_REC_API_USE = "<%=apiRecSearch%>";
		getConfigValue();
		
		// 청취사유 사용여부
		if(vlcOPT.VLC_REC_API_USE=="1"){
			//getRecSearchAPI();
		}else{
			$("#searchPanel").show();
			$("#searchPanel_SAP").show();
			$("#searchPanel_SAP2").show();
			
			if(controlAuth == null){
				controlAuth = "";
			}
			
			fnInitCtrl();
			fnParamSetting();
			fnInitGrid();
			
			if(vlcOPT.VLC_CUST_ALL){
				$("#btnExcelImport").hide();
			}
			
			argoSetValue("s_RecFrmTm", "00:00:00");
			argoSetValue("s_RecEndTm", "23:59:59");
			argoSetValue("s_CallFrmTm", "00:00:00");
			argoSetValue("s_CallEndTm", "00:00:00");
		}
		
		for(var i=0;i<custInfoAuthStr.length;i++){
			if(custInfoAuthStr[i] == grantId){
				custInfoAuth = true;
			}
		}
	});
	
	$(window).load(function(){
		vlcOPT.VLC_REC_API_USE = "<%=apiRecSearch%>";
		$("#btnFileDown").hide();
		if(backupAt == "0" || backupAt == ""){
			$("#btnFileDown").show();
		}
		
		if(vlcOPT.VLC_REC_API_USE=="1"){
			if(mfsIp==null){
				argoJsonSearchOne('comboBoxCode', 'getMfuIpList', 's_', {}, function (data, textStatus, jqXHR){
					try{
						if(data.isOk()){
							if(data.getRows() != ""){
								mfsIp = data.getRows()['code'];
								mfuNatIp = data.getRows()['ipNat'] == undefined ? "" : data.getRows()['ipNat'];
							} else {
								mfsIp = "";
								mfuNatIp = "";
							}
						}
					} catch(e) {
						console.log(e);			
					}
				});
			}
			getRecSearchAPI();
			$('#paging').hide();
		}else{
			fnPlayConfProc();
			$("#is_callexcept").val('N').prop('selected',true);
			fnRecGrant(grantId);
			argoSetValue("s_RecFrmTm", "00:00:00");
			argoSetValue("s_RecEndTm", "23:59:59");
			argoSetValue("s_CallFrmTm", "00:00:00");
			argoSetValue("s_CallEndTm", "00:00:00");
		}
		workPage = "1";
		fnSearchListCnt();
	});
	
	function getRecSearchAPI(){
		$('#paging').hide();
		fnInitGrid();
		var API_TENANT_ID = vlcOPT.VLC_SSO_TENANT_ID;
		var API_REC_TIME = "<%=apirectime%>";
		var API_CUST_TEL = "<%=apicusttel%>";
	
		argoJsonSearchList('recSearchNew'
				, 'getRecSearchList_APINew'
				,'s_'
				, {
					"s_API_TENANT_ID" : API_TENANT_ID,
					"s_API_REC_TIME" : API_REC_TIME,
					"s_API_CUST_TEL" : API_CUST_TEL
				 }
				,function(data, textStatus, jqXHR) {
					try {
						if (data.isOk()) {
							w2ui.grid.clear();
							if (data.getRows() != "") {
								dataArray = [];
								$.each(data.getRows(), function(index, row) {

									var holdTime = 0;
									if (row.hold > 0) {
										if (row.callTime > row.convertTime) {
											holdTime = fnSecondsConv(row.callTime - row.convertTime);
										}
									}
									
									//스크린 청취 플래그를 통해서 판단
									var btnMediaScr = "";
									if (row.mediaScr == 1) {
										if(playerKind==1){
											btnMediaScr = "<button type='button' class='btn_m' onclick='fnRecFilePlay("+index+","+true+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";	
										}else{
											btnMediaScr = "<button type='button' class='btn_m' onclick='fn_scrPopup("+index+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";
										}
									}
									
									gridObject = {
										"mediaScr" : btnMediaScr,
										"grantEtc" : "<button type=\"button\" class=\"btn_m\" onclick=\"fnGrantEtc('" + index + "', '" + userId + "', '" + row.userId + "')\" style=\"height: 17px;\">설정</button>",
										"recid" : index,
										"recKey" : row.recKey,
										"recDate" : fnStrMask( "YMD", row.recDate),
										"recTime" : fnStrMask( "HMS", row.recTime),
										"groupName" : row.groupName,
										"userId" : row.userId,
										"userName" : row.userName,
										"dnNo" : row.dnNo,
										"endTime" : fnSecondsConv(row.endTime),
										"callKind" : row.callKind,
										"custTel" : row.custTel,
										"custName" : row.custName,
										"custNo" : row.custNo,
										"callId" : row.callId,
										"holdCnt" : row.hold,
										"tranTel" : row.tranTel,
										"holdTime" : holdTime,
										"custEtc1" : row.custEtc1,
										"custEtc2" : row.custEtc2,
										"custEtc3" : row.custEtc3,
										"custEtc4" : row.custEtc4,
										"custEtc5" : row.custEtc5,
										"custEtc6" : row.custEtc6,
										"custEtc7" : row.custEtc7,
										"custEtc8" : row.custEtc8,
										"maskCustEtc1" : row.maskCustEtc1,
										"maskCustEtc2" : row.maskCustEtc2,
										"maskCustEtc3" : row.maskCustEtc3,
										"maskCustEtc4" : row.maskCustEtc4,
										"maskCustEtc5" : row.maskCustEtc5,
										"maskCustEtc6" : row.maskCustEtc6,
										"maskCustEtc7" : row.maskCustEtc7,
										"maskCustEtc8" : row.maskCustEtc8,
										"recDateOrg" : row.recDate,
										"recTimeOrg" : row.recTime,
										"endTimeOrg" : row.endTime,
										"fileName" : row.fileName,
										"custEtc10" : row.custEtc10,
										"custEtc9" : row.custEtc9,
										"mfuIp" : row.mfuIp,
										"mediaScrCd" : row.mediaScr,
										"encKey" : row.encKey,
										"phoneIp": row.phoneIp,
										w2ui : {
											"style" : "background-color: #" + row.markingColor
										}
									};
									dataArray.push(gridObject);
								});
								w2ui['grid'].add(dataArray);
								$('#gridList').show();
								$('#paging').show();
							} else {
								argoAlert('warning', "조회결과가 없습니다.", '',
										'window.open("", "_self", "");window.close();');
								return;
							}
						}
						w2ui.grid.unlock();
					} catch (e) {
						console.log(e);
					}
				});

	}

	function getSelectedCells2Rows(selectCells) {
		var length = selectCells.length;
		var result = [];
		var preRecId = -1;
		for ( var index in selectCells) {
			var cell = selectCells[index];
			if (cell.recid != preRecId) {
				result.push(cell.recid);
				preRecId = cell.recid;
			}
		}
		return result;
	}

	function fnRecGrant(grantId) {
		$("#is_callexcept").change(function(e) {
			if ($("#is_callexcept").val() == "Y") {
				document.getElementById('div_cust').style.display = "none";
				document.getElementById('div_call').style.display = "none"
				$("#btnCustDisplay").attr('disabled', true);
				$("#btnCallDisplay").attr('disabled', true);
			} else {                                                                                               
				document.getElementById('div_cust').style.display = "";
				document.getElementById('div_call').style.display = "";
				$("#btnCustDisplay").attr('disabled', false);
				$("#btnCallDisplay").attr('disabled', false);
			}
		});
	}

	function fnPlayConfProc() {
		var playK = VLC_StringProc_NVL(playerKind, "1");
		if (convertFlag == "0") {
			$("#btnWavConv").show();

		} else {
			$("#btnWavConv").hide();
		}
	};

	//페이지 재 로드시 파라미터 세팅
	function fnParamSetting() {
		var paramText;
		paramText = parent.$("#RecSearchNewF").val().split("||");
		if (argoNullConvert(paramText) != "" && paramText.length > 1) {
			var paramSet;
			var rowCnt = 5;
			for (var i = 0; i < paramText.length; i++) {
				paramSet = paramText[i].split("::");
				$("#" + paramSet[0]).val(paramSet[1]);
				if (paramSet[0] == "s_FindTenantId") {
					argoCbCreate("s_FindGroupId", "comboBoxCode","getGroupList", {findTenantId : $('#s_FindTenantId option:selected').val(),userId : userId,controlAuth : controlAuth, grantId : grantId}, {
								"selectIndex" : 0,
								"text" : '선택하세요!',
								"value" : ''});
					argoCbCreate("s_FindMarkKind", "comboBoxCode","getMarkCodeList", {findTenantId : $('#s_FindTenantId option:selected').val()}, {
								"selectIndex" : 0,
								"text" : '선택하세요!',
								"value" : ''});
					fnGroupCbChange("s_FindGroupId");
				} else if (paramSet[0] == "s_FindGroupId") {
					if ($('#s_FindGroupId option:selected').val() == "") {
						//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					} else {
						//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
					}
				} else if (paramSet[0] == "div_tenant"
						|| paramSet[0] == "div_user"
						|| paramSet[0] == "div_cust"
						|| paramSet[0] == "div_call") {

					if (paramSet[1] != "") {
						$("#" + paramSet[0]).hide();
						$("#" + paramSet[1]).attr("class", "btn_tab confirm");
						rowCnt--;
					}
				} else if (paramSet[0] == "selectionPage") {
					workPage = paramSet[1];
				}
			}
			$("#searchPanel").attr("class", "search_area row" + rowCnt);
		}
	}

	function fnInitCtrl() {
		argoSetDatePicker();
		
		argoSetDateTerm('selDateTerm1', {
			"targetObj" : "s_txtDate1",
			"selectValue" : "T_0"
		}, jData);

		$('.timepicker.rec').timeSelect({
			use_sec : true
		});

		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});
		
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {
			findTenantId : tenantId,
			userId 		: userId,
			controlAuth : controlAuth,
			grantId 	: grantId
		}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});
		
		argoCbCreate("s_FindMarkKind", "comboBoxCode", "getMarkCodeList", {
			findTenantId : tenantId
		}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});

		argoSetValue("s_RecFrmTm", "00:00:00");
		argoSetValue("s_RecEndTm", "23:59:59");
		argoSetValue("s_CallFrmTm", "00:00:00");
		argoSetValue("s_CallEndTm", "00:00:00");
		fnGroupCbChange("s_FindGroupId");
		fnAuthBtnChk(parent.$("#authKind").val());

		// 상담사 권할일 경우 샘플콜등록 버튼 숨기기
		if(grantId == "Agent") {
			$("#btnSampAdd").hide();
		}
		
		if (convertFlag == "0") {
			$("#btnWavConv").show();
		} else {
			$("#btnWavConv").hide();
		}

		if (grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager") {
			Display_Input_Panel(searchPanel, div_tenant, btnTenantDisplay);
			$("#btnTenantDisplay").hide();
		}

		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);

		$("#s_FindTenantId").change(function() {
			fnSetSubCb('tenant');
		});
		$("#s_FindGroupId").change(function() {
			fnSetSubCb('group');
		});

		if (grantId == "GroupManager" || grantId == "Agent" || grantId == "Manager") {
			$("#btnExcelInfoChange").hide();
			$("#btnInfoChange").hide();
			$('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
			//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId, FindGroupId:groupId + '_' + depth}, {"selectIndex":0, "text":'선택하세요!', "value":''});

			if (grantId == "Agent") {
				$('#s_FindUserId option[value="' + userId + '"]').prop(
						'selected', true);
				Display_Input_Panel(searchPanel, div_user, btnTenantDisplay);
				$("#btnUserDisplay").hide();
				$("#s_FindUserId").attr("disabled", true);
				$('#s_FindGroupId option[value=""]').prop('selected', true);
			}
		}
		
		$("#btnInfoChange").click(function(){ 
			if(!custInfoAuth){
				alert('권한이 없는 사용자입니다.');
				return false;
			}
			
			var vGrid = w2ui["grid"];
			var checkedNum = vGrid.getSelection();
			if(checkedNum.length == 0){
				argoAlert("한 건 이상 체크해주세요.");
				return false;
			}else if(checkedNum.length > 1){
				argoAlert("한 건만 체크해주세요.");
				return false;				
			}else{
				gPopupOptions = {cudMode:'U', pRowIndex:vGrid.get(checkedNum) } ;
			}
			argoPopupWindow('고객정보 수정', 'RecSearchInfoPopNewF.do', '550', '500');
		});

		//20181122 yoonys
		$("#btnExcelImport").click(function() {
			argoPopupWindow('고객정보 일괄등록', gGlobal.ROOT_PATH + '/common/VExcelFormF.do', '500', '500');
		});

		$("#btnSearch").click(function() { //조회
			workPage = "1";
			fnSearchListCnt();
		});

		$("#btnMarkAdd").click(function() {
			fnMarkAdd();
		});

		$("#btnMarkDel").click(function() {
			fnMarkDel();
		});

		$("#btnSampAdd").click(function() {
			fnSampAdd();
		});

		$("#btnPlay").click(function() {
			if(recAuth == "Y"){
				fnAuthRecPlay();
			}else{
				fnMultiRecPlay();
			}
		});

		$("#btnWavConv").click(function() {
			fnWavConv();
		});

		$("#btnMp3Conv").click(function() {
			fnWavConv();
		});

		$("#btnFileDown").click(function() {
			fnFileDownConfm();
		});

		$('.clickSearch').keydown(function(key) {
			if (key.keyCode == 13) {
				fnSearchListCnt();
			}
		});
		
		$("#is_callexcept").change(function(){
			if($("#is_callexcept").val() == "N"){
				w2ui['grid'].showColumn('grantEtc');				
			}else{
				w2ui['grid'].hideColumn('grantEtc');
			}
			fnSearchListCnt();
		});

		if (grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager") {
			argoJsonSearchList('recSearchNew', 'getControlListNew', 's_', {
				"findTenantId" : tenantId,
				"userId" : userId
			}, function(data, textStatus, jqXHR) {
				try {
					if (data.isOk()) {
						if (data.getRows() != "") {
							ControlAuthGroup = [];
							$.each(data.getRows(), function(index, row) {
								ControlAuthGroup.push(row.groupId);
							});
						}
					}
				} catch (e) {
					console.log(e);
				}
			});
		}

		argoJsonSearchOne('comboBoxCode', 'getMfuIpList', 's_', {}, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					if (data.getRows() != "") {
						mfsIp = data.getRows()['code'];
						mfuNatIp = data.getRows()['ipNat'] == undefined ? "" : data.getRows()['ipNat'];
					} else {
						mfsIp = "";
						mfuNatIp = "";
					}
				}
			} catch (e) {
				console.log(e);
			}
		});

		// 2018.02.07 사용자 콤보박스 표시 여부
		argoJsonSearchOne('comboBoxCode', 'getConfigValue', 's_', {
			"section" : "INPUT",
			"keyCode" : "USE_USER_COMBO"
		}, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					if (data.getRows() != "") {
						isUseUserCombo = data.getRows()['code'];

						if (isUseUserCombo == 0) {
							$("#s_FindUserId").attr("style", "display:none;");
						}
					}
				}
			} catch (e) {
				console.log(e);
			}
		});

		$("#btnExcel").click(function() {dnExcelSampleDownload();});
		$("#btnReset").click(
				function() {
					$('#s_FindMarkKind option[value=""]').prop('selected', true);
					$('#s_FindCallKind option[value=""]').prop('selected', true);
					$("#s_FindUserNameText").val(''); //사용자
					$("#s_FindDnText").val(''); //내선
					$("#s_FindCustNameText").val(''); //고객명
					$("#s_FindCustTelText").val(''); //전화번호
					$("#s_FindCustNoText").val(''); //고객번호
					$("#s_FindCallIdText").val(''); //콜아이디
					
					$("#s_FindField2").val(''); 
					$("#s_FindFieldText2").val(''); //추가검색
					$("#s_FindTranTelText").val('');
					argoCbCreate("s_FindTenantId", "comboBoxCode",
							"getTenantList", {}, {
								"selectIndex" : 0,
								"text" : '선택하세요!',
								"value" : ''
							});
					$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
					argoCbCreate("s_FindGroupId", "comboBoxCode",
							"getGroupList", {
								findTenantId : tenantId,
								userId : userId,
								controlAuth : controlAuth,
								grantId : grantId
							}, {
								"selectIndex" : 0,
								"text" : '선택하세요!',
								"value" : ''
							});
					fnGroupCbChange("s_FindGroupId");
					
					argoSetDateTerm('selDateTerm1', {
						"targetObj" : "s_txtDate1",
						"selectValue" : "T_0"
					}, jData);
					argoSetValue("s_RecFrmTm", "00:00:00");
					argoSetValue("s_RecEndTm", "23:59:59");
					argoSetValue("s_CallFrmTm", "00:00:00");
					argoSetValue("s_CallEndTm", "00:00:00");
					$('#selDateTerm1 option[value="T_0"]').prop('selected',true);

					if (grantId == "GroupManager" || grantId == "Agent" || grantId == "Manager") {
						$('#s_FindGroupId option[value="' + groupId + '_'+ depth + '"]').prop('selected', true);
						if (grantId == "Agent") {
							$('#s_FindUserId option[value="' + userId + '"]').prop('selected', true);
						}
					}
				});
		
		$("#btnExcelInfoChange").click(function(){
			if(!custInfoAuth){
				alert('권한이 없는 사용자입니다.');
				return false;
			}
			var fGN = argoGetValue('s_FindGroupId');
			if (fGN.indexOf("_") != -1) {
				fGN = fGN.split("_")[0];
			}
			var termS = $("#selDateTerm1").val();
			if (termS == "S_1") {
				termS = "0";
			} else {
				termS = "1";
			}
			gPopupOptions = {
				param : serializeFormNoService("s_")+"&userId="+userId+"&controlAuthGroup="+ControlAuthGroup+"&controlAuth="+controlAuth
				+"&grantId="+grantId+"&groupId="+groupId+"&findGroupIdnew="+fGN+"&findTS="+termS
			};
			argoPopupWindow('고객정보 수정', 'RecSearchExcelInfoPopNewF.do', '550', '300');
		});
		
		argoCbCreate("#s_FindField2", "recSearchNew", "getCustEtcListNew", {findTenantId : argoGetValue("s_FindTenantId")}, {"selectIndex" : 0,"text" : '<선택>',"value" : ''});
	}
	
	function fnInitGrid() {
		$('#gridList').w2grid({
			name : 'grid',
			show : {
				lineNumbers : true,
				footer : true,
				selectColumn : true
			},
			//팝업메뉴
			onMenuClick : function(event) {
				var selectedText = "";
				var recid = "";
				for ( var index in arrSelected) {
					var newRecid = arrSelected[index].recid;
					if (recid != newRecid) {
						selectedText += "\r\n";
						recid = newRecid;
					}
					selectedText += w2ui['grid'].getCellValue(recid,
							arrSelected[index].column);
					selectedText += " ";
				}
				var clipboard = document.createElement("textarea");
				document.body.appendChild(clipboard);
				clipboard.value = selectedText;
				clipboard.select();
				var successful = document.execCommand('copy');
				document.body.removeChild(clipboard);
			},
			onDblClick : function(event) {
				if (event.recid >= 0) {
					if(recAuth == "Y"){
						fnAuthRecPlay(event.recid);
					}else{
						fnRecFilePlay(event.recid);
					}
				}
			},
			onClick : function(event) {
				if (event.recid >= 0) {
					//IE,crome에서 확인
					if (event.column != null) {
						$('#clip_target').val(w2ui['grid'].getCellValue(event.recid, event.column));
						$('#clip_target').select();
						var successful = document.execCommand('copy');

					}
				}
			},
			onSelect : function(event) {
				arrSelected = w2ui['grid'].getSelection();
			},
			columns : 
			[{
				field : 'grantEtc',
				caption : '권한부여',
				size : '90px',
				attr : 'align=center',
				frozen : true
			}, {
				field : 'recid',
				caption : 'recid',
				size : '0px',
				attr : 'align=center'
			}, {
				field : 'recKey',
				caption : 'recKey',
				size : '0px',
				attr : 'align=center'
			}, {
				field : 'mediaScr',
				caption : '스크린',
				size : '90px',
				attr : 'align=center',
				frozen : true
			}, {
				field : 'recDate',
				caption : '통화일자',
				size : '90px',
				attr : 'align=center',
				frozen : true
			}, {
				field : 'recTime',
				caption : '녹취시간',
				size : '75px',
				attr : 'align=center',
				frozen : true
			}, {
				field : 'groupName',
				caption : '그룹명',
				size : '150px',
				attr : 'align=center',
				frozen : true
			}, { 
				field : 'userId',
				caption : '상담사ID',
				size : '80px',
				attr : 'align=center',
				frozen : true
			}, {
				field : 'userName',
				caption : '상담사명',
				size : '80px',
				attr : 'align=center',
				frozen : true
			}, {
				field : 'custTel',
				caption : '전화번호',
				size : '200px',
				attr : 'align=center',
				frozen : true
			}, {
				field : 'custName',
				caption : '고객명',
				size : '80px',
				attr : 'align=center',
				frozen : true
			}
			, {
				field : 'dnNo',
				caption : '내선',
				size : '80px',
				attr : 'align=center'
			}, {
				field : 'endTime',
				caption : '통화시간',
				size : '80px',
				attr : 'align=center'
			}, {
				field : 'callKind',
				caption : '구분',
				size : '60px',
				attr : 'align=center'
			}, {
				field : 'custNo',
				caption : '고객번호',
				size : '100px',
				attr : 'align=center'
			}, {
				field : 'holdCnt',
				caption : '보류횟수',
				size : '80px',
				attr : 'align=center'
			}, {
				field : 'tranTel',
				caption : '호전환번호',
				size : '80px',
				attr : 'align=center'
			}, {
				field : 'holdTime',
				caption : '보류시간',
				size : '80px',
				attr : 'align=center'
			}, {
				field : 'callId',
				caption : '콜아이디',
				size : '320px',
				attr : 'align=left'
			}, {
				field : 'recDateOrg',
				caption : '콜아이디',
				size : '0px',
				attr : 'align=left'
			}, {
				field : 'recTimeOrg',
				caption : '콜아이디',
				size : '0px',
				attr : 'align=left'
			}, {
				field : 'endTimeOrg',
				caption : '콜아이디',
				size : '0px',
				attr : 'align=left'
			}, {
				field : 'fileName',
				caption : '콜아이디',
				size : '0px',
				attr : 'align=left'
			}, {
				field : 'custEtc9',
				caption : 'custEtc9',
				size : '150px',
				attr : 'align=left'
			},{
				field : 'custEtc10',
				caption : '마킹메모',
				size : '150px',
				attr : 'align=left'
			}, {
				field : 'groupId',
				caption : '그룹ID',
				size : '150px',
				attr : 'align=left'
			}, {
				field : 'tenantId',
				caption : '태넌트ID',
				size : '150px',
				attr : 'align=left'
			}, {
				field : 'mfuIp',
				caption : 'mfuIp',
				size : '0px',
				attr : 'align=left'
			}, {
				field : 'mediaScrCd',
				caption : '스크린코드',
				size : '0px',
				attr : 'align=left'
			},{
				field : 'encKey',
				caption : '고객정보암호화키',
				size : '0px',
				attr : 'align=left'
			},{
				field : 'phoneIp',
				caption : '사용자IP',
				size : '0px',
				attr : 'align=left'
			}],
			records : dataArray
		});

		w2ui.grid.menu = [ {
			id : 1,
			text : '복사하기'
		} ];

		w2ui['grid'].hideColumn( 'recid', 'recKey', 'custEtc9', 'recDateOrg', 'recTimeOrg','groupId','tenantId',
				'endTimeOrg', 'fileName', 'mfuIp','mediaScrCd','encKey','phoneIp');
		if (vlcOPT.VLC_SCREEN_LISTEN == "0") {
			w2ui['grid'].hideColumn('mediaScr');
		}

		if (vlcOPT.VLC_ETC_GRANT_USE == "0") {
			w2ui['grid'].hideColumn('grantEtc');
			$("#is_callexcept_node").css("display","none");
		}

		$('#gridList').hide();
		$('#paging').hide();
		
		// 20230718 jslee 동적컬럼 생성
		fnInitDynamicGrid();
	}
	
	
	// 20230718 init그리드 이후 동적컬럼을 이어붙이기 위한 메서드 
	function fnInitDynamicGrid(){
	 	var multiService = new argoMultiService(fnCallbackSearchGridColumns);
		multiService.argoList("recSearchNew", "getRecSearchDynimicHeaderNew", "s_", {});
		multiService.action();
	}
	
	function fnCallbackSearchGridColumns(data, textStatus, jqXHR) {
		try{
			if(data.isOk()){
		    	var gridDynimicHeader1 = data.getRows(0);
		    	var columns = new Array();
		    	columns = w2ui.grid.columns; 
		    	$.each(gridDynimicHeader1, function(index, row){
		    		columns.push({ field: row.code, caption: row.codeNm, size: '180px', sortable: true, attr: 'align=center'});
		    	});
		    } 
		} catch(e) {
			argoAlert(e);
		}
	}
	
	function fnSearchListCnt() {
		if (argoGetValue("#s_FindCustNameText") == "" && argoGetValue("#s_FindCustTelText") == "" && argoGetValue("#s_FindCustNoText") == "") {
			var diffDate = fnDiffDate(argoGetValue("#s_txtDate1_From"),
			argoGetValue("#s_txtDate1_To"));
			var maxTerm = argoGetSearchMaxTerm(argoGetValue("#s_txtDate1_To"), jData);
			if (diffDate > 31) {
				argoAlert("검색조건(고객명/전화번호/고객번호) 미입력시 31일 기간만 조회가 가능합니다.");
 				return; 
			}
		}

		//페이지 리로드시 기존 파라미터 세팅 start
		var param01 = $("#s_FindTenantId").val();
		var param02 = $('#s_FindGroupId').val();
		var param03 = $('#s_FindUserId').val();
		var param04 = $('#s_FindUserNameText').val();
		var param05 = $('#s_FindDnText').val();
		var param06 = $('#s_FindCustNameText').val();
		var param07 = $('#s_FindCustTelText').val();
		var param08 = $('#s_FindCustNoText').val();
		var param09 = $('#s_FindCallKind').val();
		var param10 = $('#s_FindMarkKind').val();
		var param11 = $('#s_FindCallIdText').val();
		var param12 = $('#s_txtDate1_From').val();
		var param13 = $('#s_txtDate1_To').val();
		var param14 = $('#s_RecFrmTm').val();
		var param15 = $('#s_RecEndTm').val();
		var param16 = $('#s_CallFrmTm').val();
		var param17 = $('#s_CallEndTm').val();
		var param18 = $('#selDateTerm1').val();
		var param19 = (document.getElementById('div_tenant').style.display != "") ? "btnTenantDisplay" : "";
		var param20 = (document.getElementById('div_user').style.display != "") ? "btnUserDisplay" : "";
		var param21 = (document.getElementById('div_cust').style.display != "") ? "btnCustDisplay" : "";
		var param22 = (document.getElementById('div_call').style.display != "") ? "btnCallDisplay" : "";
		var param23 = $('#s_FindField2').val();
		var param24 = $('#s_FindFieldText2').val();
		


		var pageParam = 's_FindTenantId::' + param01 + '||s_FindGroupId::'
				+ param02 + '||s_FindUserId::' + param03
				+ '||s_FindUserNameText::' + param04 + '||s_FindDnText::'
				+ param05 + '||s_FindCustNameText::' + param06
				+ '||s_FindCustTelText::' + param07 + '||s_FindCustNoText::'
				+ param08 + '||s_FindCallKind::' + param09
				+ '||s_FindMarkKind::' + param10 + '||s_FindCallIdText::'
				+ param11 + '||s_txtDate1_From::' + param12
				+ '||s_txtDate1_To::' + param13 + '||s_RecFrmTm::' + param14
				+ '||s_RecEndTm::' + param15 + '||s_CallFrmTm::' + param16
				+ '||s_CallEndTm::' + param17 + '||selDateTerm1::' + param18
				+ '||div_tenant::' + param19 + '||div_user::' + param20
				+ '||div_cust::' + param21 + '||div_call::' + param22
				+ '||s_FindField2::' + param23 + '||s_FindFieldText2::' + param24
				;

		parent.$("#RecSearchNewF").val(pageParam);
		
		//페이지 리로드시 기존 파라미터 세팅 end
		if(argoNullConvert(w2ui.grid) != ""){w2ui.grid.lock('조회중', true);}
		$("#s_FindDnText").val(jQuery.trim($("#s_FindDnText").val())); //내선 공백제거
		$("#s_FindUserNameText").val(jQuery.trim($("#s_FindUserNameText").val())); //사용자 공백제거
		$("#s_FindCustNameText").val( jQuery.trim($("#s_FindCustNameText").val())); //고객명 공백제거
		$("#s_FindCustTelText").val(jQuery.trim($("#s_FindCustTelText").val())); //전화번호 공백제거
		$("#s_FindCustNoText").val(jQuery.trim($("#s_FindCustNoText").val())); //고객번호 공백제거

		//2018-12-10 yoonys
		//feat. 전북은행
		//특정사용자가 원칙적으로 듣지 못하는 통화를 듣는 권한부여기능이 추가됨으로써
		//일반청취 와 일반청취 UNION 권한받은 콜에대한 쿼리를 다르게 가져간다. 
		//var useGrant = vlcOPT.VLC_LIST_GRANT;
		var useGrant = document.getElementById("is_callexcept");
		var fGN = argoGetValue('s_FindGroupId');
		if (fGN.indexOf("_") != -1) {
			fGN = fGN.split("_")[0];
		}
		
		var termS = $("#selDateTerm1").val();
		if (termS == "S_1") {
			termS = "0";
		} else {
			termS = "1";
		}
		
		if ($("#is_callexcept").val() == "N") {
			argoJsonSearchOne('recSearchNew', 'getRecSearchListCntNew', 's_', {
				userId : userId,
				controlAuthGroup : ControlAuthGroup,
				controlAuth : controlAuth,
				grantId : grantId,
				groupId : groupId,
				findGroupIdnew : fGN,
				findTS : termS
			}, function(data, textStatus, jqXHR) {
				try {
					if (data.isOk()) {
						var totalData = data.getRows()['cnt'];
						var searchCnt = argoGetValue('s_SearchCount');
						paging(totalData, workPage, searchCnt, "4");
						$("#totCount").text(totalData);
						if (totalData == 0) {
							argoAlert('조회 결과가 없습니다.');
							return;
						}
					}

					workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
							+ ' | GrantId:' + grantId + '] 통화내역조회';
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
						tenantId : tenantId,
						userId : userId,
						actionClass : "action_class",
						actionCode : "W",
						workIp : workIp,
						workMenu : workMenu,
						workLog : workLog
					});
				} catch (e) {
					console.log(e);
				}
			});
		} else {
			argoJsonSearchOne('recSearchNew', 'getRecSearchListCnt_GrantNew', 's_', {
				userId : userId,
				controlAuthGroup : ControlAuthGroup,
				controlAuth : controlAuth,
				grantId : grantId,
				groupId : groupId,
				findGroupIdnew : fGN,
				findTS : termS
			}, function(data, textStatus, jqXHR) {
				try {
					if (data.isOk()) {
						var totalData = data.getRows()['cnt'];
						var searchCnt = argoGetValue('s_SearchCount');
						paging(totalData, workPage, searchCnt, "2");
						$("#totCount").text(totalData);
						if (totalData == 0) {
							argoAlert('조회 결과가 없습니다.');
							return;
						}
					}

					workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
							+ ' | GrantId:' + grantId + '] 통화내역조회';
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
						tenantId : tenantId,
						userId : userId,
						actionClass : "action_class",
						actionCode : "W",
						workIp : workIp,
						workMenu : workMenu,
						workLog : workLog
					});
				} catch (e) {
					console.log(e);
				}
			});
		}
	}
	
	var strMyURL = "http://"+workIp+":8090";
	var strProxyURL = "/BT-VELOCE/proxy.jsp";
	
	function fnFileDownConfm(){
		var mainData = {'cmd' : 'filedownstatus'};
		OnHttpSend(strProxyURL,strMyURL,mainData);
	}
	
	function fnStopDown(){
		var mainData = {'cmd' : 'filedownstop'};
		OnHttpSend(strProxyURL, strMyURL, mainData);
	}
	function fnFileDownAll(){
		var string = "";
		string = serializeFormNoService('s_');
		var keyValue = string.split("&");
		var data = {};
		var tmpArr = {};
		for( var i = 0 ; i < keyValue.length ; i++ ){
			var tmp = keyValue[i].split("=");
			var key  = tmp[0]; 
			tmpArr[key]= tmp[1];
		}
		
		var convertTime = function (val) {
			var result = 0;
			hour = val.substring(0,2);
			result += Number(hour) * 60 * 60;
			min = val.substring(2,4)
			result += Number(min) * 60 ;
			sec  = val.substring(4,6)
			result += Number(sec) ;
			return result;
		};
		
		data['filename'] = "";
		data['path'] = "";
		data['tenantid'] 	= tmpArr['findTenantId'];
		data['agentdn'] 	= tmpArr['findDnText'];
		data['agentid'] 	= tmpArr['findUserNameText']; 
		data['srectime'] 	= tmpArr['txtDate1_From'] + tmpArr['recFrmTm'];
		data['erectime'] 	= tmpArr['txtDate1_To'] + tmpArr['recEndTm'];
		data['custname'] 	= tmpArr['findCustNameText'];
		data['custtel'] 	= tmpArr['findCustTelText'];
		data['custno'] 		= tmpArr['findCustNoText'];
		data['scalltime'] 	= convertTime(tmpArr['callFrmTm']);
		data['ecalltime'] 	= convertTime(tmpArr['callEndTm']);
		
		if(convertTime(tmpArr['callEndTm']) < 1){
			data['ecalltime'] 	= '9999';
		}
		data['callkind'] 	= tmpArr['findCallKind'];
		data['groupid'] 	= tmpArr['findGroupId'];
		
		if(tmpArr['findField'] != "" || tmpArr['findField'] != null){
			data[tmpArr['findField'].toLowerCase()] = tmpArr['findFieldText'];
		}
		
		var dataCnt = {};
		dataCnt['1'] = data;
		
		var mainData = {'cmd' : 'filevocadd'};
		mainData['filelist'] = dataCnt;
		mainData['downloadkey'] = "123456";
		OnHttpSend(strProxyURL,strMyURL,mainData);
	}

	function OnHttpSend(strProxyURL, strUrl, strValue) {
		var data = JSON.stringify(strValue)
		var strPost = "url=" + Base64.encode(strUrl) + "&" + "data=" + Base64.encode(data);
		var result = "";
		var xdr = getXMLHttpRequest();
		if (xdr) {
			xdr.onload = function() {
				var resdata = xdr.responseText;
				var jsonObj = JSON.parse(resdata);
				var key1 = "cmd";
				var recKey = "";
				var recTime = "";
			}
			xdr.onerror = function() {
				alert("error!");
			}
			xdr.open('POST', strProxyURL + "?" + strPost);
			xdr.onreadystatechange = function() {
		        if(xdr.readyState == 4 && xdr.status == 200){
		            var res = JSON.parse(xdr.response);
		            var cmd = res["cmd"];
		            if(cmd == "filedownstatus"){
		            	result = res["value"];
		            	if(result > 0){
			            	argoConfirm(res["value"] +' 건이 진행 중입니다.<br/>요청을 보내시겠습니까?</br><button type="button" class="btn_m" onclick="javascript:fnStopDown();">이전 요청 중지하기</button> ',"fnFileDownAll()");
		            	}else if( $("#totCount").text() > 0 ){
		            		argoConfirm( $("#totCount").text() + " 건에 대해 요청 하시겠습니까?","fnFileDownAll()");
		            	}else {
		            		argoAlert("요청할 내용이 없습니다.");
		            	}
		            }
		            if(cmd== "filevocadd"){
		            	if(res["value"] == "SUCCEED"){
			            	argoAlert('정상적으로 요청되었습니다.');
			            }
		            }if(cmd == "filedownstop"){
		            	if(res["value"] == "SUCCEED"){
			            	argoAlert('정상적으로 요청되었습니다.');
			            }
	            	}
		        }
		    }
			xdr.timeout = 3000;
			setTimeout(function() {
				xdr.send(null);
			}, 0);
		}
		return result;
	}
	
	function fnGrantEtc(index, exUserId, exAgentId) {
		var recInfo = "";
		argoPopupWindow('청취권한부여', 'RecGrantF.do?callId='
		+ w2ui['grid'].getCellValue(index, 26) + '&recKey='
		+ w2ui['grid'].getCellValue(index, 2) + "&userId=" + exUserId
		+ "&agentId=" + exAgentId, '800', '600');
	}

	function fnSearchList(startRow, endRow) {
		//2018-12-10 yoonys
		//feat. 전북은행
		//특정사용자가 원칙적으로 듣지 못하는 통화를 듣는 권한부여기능이 추가됨으로써
		//일반청취 와 일반청취 UNION 권한받은 콜에대한 쿼리를 다르게 가져간다. 
		var useGrant = document.getElementById("is_callexcept");
		if ($("#is_callexcept").val() == "N") {
			var fGN = argoGetValue('s_FindGroupId');
			if (fGN.indexOf("_") != -1) {
				fGN = fGN.split("_")[0];
			}
			var termS = $("#selDateTerm1").val();
			if (termS == "S_1") {
				termS = "0";
			} else {
				termS = "1";
			}
			
			argoJsonSearchList(
					'recSearchNew',
					'getRecSearchListNew',
					's_',
					{
						"iSPageNo" : startRow,
						"iEPageNo" : endRow,
						userId : userId,
						controlAuthGroup : ControlAuthGroup,
						controlAuth : controlAuth,
						grantId : grantId,
						groupId : groupId,
						findGroupIdnew : fGN,
						findTS : termS
					},
					function(data, textStatus, jqXHR) {
						try {
							if (data.isOk()) {
								w2ui.grid.clear();
								if (data.getRows() != "") {
									dataArray = [];
									$.each(data.getRows(), function(index, row) {
										var holdTime = 0;
										if (row.hold > 0) {
											if (row.callTime > row.convertTime) {
												holdTime = fnSecondsConv(row.callTime - row.convertTime);
											}
										}
										//20180926 yoonys start
										//스크린 청취 플래그를 통해서 판단
										//0이면 없음
										//1이면 innerHTML?
										var btnMediaScr;
										if (row.mediaScr == 1) {
											if(playerKind==1){
												btnMediaScr = "<button type='button' class='btn_m' onclick='fnRecFilePlay("+index+","+true+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";	
											}else{
												btnMediaScr = "<button type='button' class='btn_m' onclick='fn_scrPopup("+index+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";
											}
										}else{
											btnMediaScr="";
										}

										gridObject = {
											"mediaScr" : btnMediaScr,
											"grantEtc" : "<i class=\"fa fa-cog\" aria-hidden=\"true\"></i><button type=\"button\" class=\"btn_m\" onclick=\"fnGrantEtc('"
													+ index
													+ "', '"
													+ userId
													+ "', '"
													+ row.userId
													+ "')\" style=\"height: 17px; width:50px;font-size:11px\">설정</button>",
											"recid" : index,
											"recKey" : row.recKey,
											"recDate" : fnStrMask(
													"YMD",
													row.recDate),
											"recTime" : fnStrMask(
													"HMS",
													row.recTime),
											"groupName" : row.groupName,
											"userId" : row.userId,
											"userName" : row.userName,
											"dnNo" : row.dnNo,
											"endTime" : fnSecondsConv(row.endTime),
											"callKind" : row.callKind,
											"custTel" : row.custTel,
											"custName" : row.custName,
											"custNo" : row.custNo,
											"callId" : row.callId,
											"holdCnt" : row.hold,
											"tranTel" : row.tranTel,
											"holdTime" : holdTime,
											"recDateOrg" : row.recDate,
											"recTimeOrg" : row.recTime,
											"endTimeOrg" : row.endTime,
											"fileName" : row.fileName,
											"custEtc10" : row.custEtc10,
											"custEtc9" : row.custEtc9,
											"groupId":row.groupId,
											"tenantId":row.tenantId,
											"mfuIp" : row.mfuIp,
											"mediaScrCd" : row.mediaScr,
											"encKey" : row.encKey,
											"phoneIp": row.phoneIp,
											w2ui : {
												"style" : "background-color: #"
														+ row.markingColor
											}
										};
										dataArray
												.push(gridObject);
									});
								}
							}
							w2ui.grid.unlock();
						} catch (e) {
							console.log(e);
						}
					});
		} else {
			argoJsonSearchList(
					'recSearchNew',
					'getRecSearchList_GrantNew',
					's_',
					{
						"iSPageNo" : startRow,
						"iEPageNo" : endRow,
						"userId" : userId,
						controlAuthGroup : ControlAuthGroup,
						grantId : grantId
					},
					function(data, textStatus, jqXHR) {
						try {
							if (data.isOk()) {
								w2ui.grid.clear();

								if (data.getRows() != "") {
									dataArray = [];
									$.each(data.getRows(),function(index, row) {
										var holdTime = 0;
										if (row.hold > 0) {
											if (row.callTime > row.convertTime) {
												holdTime = fnSecondsConv(row.callTime
														- row.convertTime);
											}
										}

										//20180926 yoonys start
										//스크린 청취 플래그를 통해서 판단
										//0이면 없음
										//1이면 innerHTML?
										var btnMediaScr;
										if (row.mediaScr == 1) {
											if(playerKind==1){
												btnMediaScr = "<button type='button' class='btn_m' onclick='fnRecFilePlay("+index+","+true+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";	
											}else{
												btnMediaScr = "<button type='button' class='btn_m' onclick='fn_scrPopup("+index+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";
											}
										}else{
											btnMediaScr="";
										}
										
										gridObject = {
											"mediaScr" : btnMediaScr,
											"grantEtc" : "<i class=\"fa fa-cog\" aria-hidden=\"true\"></i><button type=\"button\" class=\"btn_m\" onclick=\"fnGrantEtc('"
													+ index
													+ "', '"
													+ userId
													+ "', '"
													+ row.userId
													+ "')\" style=\"height: 17px; width:50px;\">설정</button>",
											"recid" : index,
											"recKey" : row.recKey,
											"recDate" : fnStrMask(
													"YMD",
													row.recDate),
											"recTime" : fnStrMask(
													"HMS",
													row.recTime),
											"groupName" : row.groupName,
											"userId" : row.userId,
											"userName" : row.userName,
											"dnNo" : row.dnNo,
											"endTime" : row.endTime,
											"callKind" : row.callKind,
											"custTel" : row.decCustTel,
											"custName" : row.custName,
											"custNo" : row.decCustNo,
											"callId" : row.callId,
											"holdCnt" : row.hold,
											"tranTel" : row.tranTel,
											"holdTime" : holdTime,
											"maskCustEtc1" : row.maskCustEtc1,
											"maskCustEtc2" : row.maskCustEtc2,
											"maskCustEtc3" : row.maskCustEtc3,
											"maskCustEtc4" : row.maskCustEtc4,
											"maskCustEtc5" : row.maskCustEtc5,
											"maskCustEtc6" : row.maskCustEtc6,
											"maskCustEtc7" : row.maskCustEtc7,
											"maskCustEtc8" : row.maskCustEtc8,
											"recDateOrg" : row.recDate,
											"recTimeOrg" : row.recTime,
											"endTimeOrg" : row.endTime,
											"fileName" : row.fileName,
											"custEtc10" : row.custEtc10,
											"custEtc9" : row.custEtc9,
											"groupId":row.groupId,
											"tenantId":row.tenantId,
											"mfuIp" : row.mfuIp,
											"mediaScrCd" : row.mediaScr,
											"encKey" : row.encKey,
											"phoneIp": row.phoneIp,
											w2ui : {
												"style" : "background-color: #"
														+ row.markingColor
											}
										};
										dataArray
												.push(gridObject);
									});
								}
							}
							w2ui.grid.unlock();
						} catch (e) {
							console.log(e);
						}
					});

			w2ui.grid.on('click', function(event) {
				event.onComplete = function() {
					var sel = w2ui['grid'].getSelection();
					var galfd = dataArray[sel].dFlAg;
					if (galfd == "Y") {
						$("#btnMp3Conv").show();
					} else {
						$("#btnMp3Conv").hide();
					}

				}
			});
		}
		fnSearchDynamicGrid(dataArray);
	}
	
	
	// 동적컬럼 생성 
	function fnSearchDynamicGrid(dataArray){
		var recKeys = "";
		$.each(dataArray, function(index, obj){
			recKeys = recKeys + obj.recKey + ",";
		});
		
		if(recKeys.length != 0){
			recKeys = recKeys.slice(0, -1);
		}
		
	 	var multiService = new argoMultiService(fnCallbackSearchGridData);
		multiService.argoList("recSearchNew", "getSearchCustEtcsNew", "s_", {"recKeys":recKeys});
		multiService.action();
	}  
	
	function fnCallbackSearchGridData(data, textStatus, jqXHR) {
		try{
			if(data.isOk()){
				var gridEtcDatas = data.getRows(0);
				var objData = new Array();
				$.each(dataArray, function(index, obj){
					var dsGrep = $.grep(gridEtcDatas, function(n,i){
						return (n.recKey == obj.recKey);
					});
					
					$.each(dsGrep, function( index2, row2 ) {
						obj[row2.colId] = argoNullConvert(row2.custData) ; 
					});
					
					dataArray[index]= obj;
				});
				
				w2ui['grid'].add(dataArray);
				$('#gridList').show();
				$('#paging').show();
				
		    } 
		} catch(e) {
			argoAlert(e);
		}
	}
	

	function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}

	function fnMarkAdd() {
		try {
			var arrChecked = w2ui['grid'].getSelection();
			if (arrChecked.length == 0) {
				argoAlert("마킹등록 할 통화내역을 선택하세요");
				return;
			}

			argoConfirm('선택한 통화내역 ' + arrChecked.length + '건을 마킹등록 하시겠습니까?',
					function() {
						var recKey = "";
						var callId = "";
						markArray = new Array();

						$.each(arrChecked, function(index, value) {
							recKey = w2ui['grid'].getCellValue(value, 2);
							callId = w2ui['grid'].getCellValue(value, 26);
							gObject = {
								"recKey" : recKey,
								"callId" : callId, 
							};

							markArray.push(gObject);
						});

						gPopupOptions = {
							cudMode : "I",
							markArray : markArray,
							tenantId :  $('#s_FindTenantId option:selected').val()
						};
						argoPopupWindow('마킹등록', 'RecSearchMarkF.do', '460',
								'620');
					});
		} catch (e) {
			console.log(e);
		}
	}

	function fnMarkDel() {
		try {

			var arrChecked = w2ui['grid'].getSelection();
			if (arrChecked.length == 0) {
				argoAlert("마킹삭제 할 통화내역을 선택하세요");
				return;
			}

			argoConfirm(
					'선택한 통화내역 ' + arrChecked.length + '건을 마킹삭제 하시겠습니까?',
					function() {

						var recKey = "";
						var callId = "";
						var recDate = "";
						var userName = "";

						var multiService = new argoMultiService(fnCallbackSave);

						$.each(arrChecked, function(index, row) {

							recKey = w2ui['grid'].getCellValue(row, idxRecKey);
							callId = w2ui['grid'].getCellValue(row, idxCallId);
							recDate = w2ui['grid']
									.getCellValue(row, idxRecDate);
							userName = w2ui['grid'].getCellValue(row,
									idxUserName);

							var param = {
								"recKey" : recKey,
								"callId" : callId,
								"recDate" : recDate,
								"userName" : userName,
								"custEtc9" : "",
								"custEtc10" : ""
							};

							multiService.argoUpdate("recordFile",
									"setRecFileMemoUpdate", "__", param);

							workLog = '[CallID:' + callId + ' | 녹취키:' + recKey
									+ ' | 상담사ID:' + userName + '] 마킹삭제';
							argoJsonUpdate("actionLog", "setActionLogInsert",
									"ip_", {
										tenantId : tenantId,
										userId : userId,
										actionClass : "action_class",
										actionCode : "W",
										workIp : workIp,
										workMenu : workMenu,
										workLog : workLog
									});
						});
						multiService.action();
					});
		} catch (e) {
			console.log(e);
		}
	}

	function fnCallbackSave(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}

	function fnSampAdd() {
		try {
			var arrChecked = w2ui['grid'].getSelection();
			if (arrChecked.length == 0) {
				argoAlert("샘플콜등록 할 통화내역을 선택하세요");
				return;
			}
			
			// 샘플콜 등록여부 체크 Start
			var exstChk = "";
			$.each(arrChecked, function(index, value) {
				var selectRecKey = w2ui['grid'].getCellValue(value, idxRecKey);
				argoJsonSearchOne('recSample', 'getSampleCallExstYn', '', {"selectRecKey":selectRecKey}, function (data, textStatus, jqXHR) {
					try {
						if (data.isOk()) {
							if(data.getRows()['exstYn'] == "Y") {
								w2ui['grid'].unselect(w2ui['grid'].getCellValue(value, 1));
								exstChk = "Y";
							}
						}
					} catch(e) {
						console.log(e);
					}
				});
			});
			
			if(exstChk == "Y") {
				exstChk = "";
				argoAlert("이미 샘플콜로 등록된 통화가 포함되어 있습니다.");
				return;
			}
			// 샘플콜 등록여부 체크 End

			argoConfirm('선택한 통화내역 ' + arrChecked.length + '건을 샘플콜등록 하시겠습니까?',
					function() {
						var recKey = "";
						var callId = "";
						markArray = new Array();
						$.each(arrChecked, function(index, value) {
							recKey = w2ui['grid'].getCellValue(value, idxRecKey);
							callId = w2ui['grid'].getCellValue(value, idxCallId);
							gObject = {
								"recKey" : recKey,
								"callId" : callId
							};
							markArray.push(gObject);
						});
						gPopupOptions = {
							cudMode : "I",
							markArray : markArray,
							tenantId :  $('#s_FindTenantId option:selected').val()
						};
						argoPopupWindow('샘플콜등록', 'RecSearchSampF.do', '500', '610');
					});
		} catch (e) {
			console.log(e);
		}
	}
	
	function pad(n) {
		return (n.length < 3) ? pad('0' + n) : n;
	}
	
	function atoi(ip) {
		return parseInt(ip.split('.').map(function (el) {
			return pad(el);
		}).join(''), 10);
	}
	
	function inRange(ipAddr, startIp, endIp) {
		return (atoi(ipAddr) >= atoi(startIp)) && (atoi(ipAddr) <= atoi(endIp));
	}

	/*
	 *	재생 목록을 팝업에 보내는 함수
	 */
	var playRecord = function(grid,rowIndex) {
		var arrChecked = [] ;
		arrChecked = rowIndex;
		tmpSelection = rowIndex;
		var tenantId2 = $('#s_FindTenantId option:selected').val();
		var logTenantId = tenantId;
		var logWorkerId = userId;
		var logWorkIp = workIp;
		var logRealtimeFlag = "0"; //파일청취
		var logListeningKey = "";
		var logUserId = "";
		var form = document.getElementById("stt_form");
		if (form == null) {
			form = document.createElement("form");
			form.setAttribute("id", "stt_form");
			form.setAttribute("method", "post");
			form.setAttribute("target", "sttPlay");

			var agent = navigator.userAgent.toLowerCase();

			if (agent.indexOf("chrome") != -1) {
				var playUrl = gGlobal.ROOT_PATH + "/recording/STTPlaychromeF.do";
			} else {
				var playUrl = gGlobal.ROOT_PATH + "/recording/STTPlayieF.do";
			}
			form.setAttribute("action", playUrl);
			document.getElementsByTagName("body").item(0).appendChild(form);
			var recData = document.createElement("input");
			recData.setAttribute("type", "hidden");
			recData.setAttribute("id", "recData");
			recData.setAttribute("Name", "recData");
			form.appendChild(recData);
		}

		var recList = [];

		$.each(arrChecked, function(row, colIndex)
		{
			var recItem = new Object();
			var custName = w2ui['grid'].getCellValue(colIndex, idxCustName);
			var telNo = w2ui['grid'].getCellValue(colIndex, idxCustTel);
			logListeningKey = w2ui['grid'].getCellValue(colIndex, idxRecDate) + w2ui['grid'].getCellValue(colIndex, idxRecTime);
			logUserId = w2ui['grid'].getCellValue(colIndex, idxUserId);
			logDnNo = w2ui['grid'].getCellValue(colIndex, idxDnNo);
			logRecKey = w2ui['grid'].getCellValue(colIndex, idxRecKey);
			var callId = grid.getCellValue(colIndex, idxCallId);
			var recTime = grid.getCellValue(colIndex, idxRecDate) + " " + grid.getCellValue(colIndex, idxRecTime);
			var custName = grid.getCellValue(colIndex, idxCustName);
			var userName = grid.getCellValue(colIndex, idxUserName);
			var custTel = grid.getCellValue(colIndex, idxCustTel);
			var endTime = grid.getCellValue(colIndex, idxEndTime);
			var fmtRecTime = logListeningKey = grid.getCellValue(colIndex, idxFmtRecDate) + " " + grid.getCellValue(colIndex, idxFmtRecTime);
			//청취로그  start
			var logDnNo = grid.getCellValue(colIndex, idxDnNo);
			var tenantId2 = $('#s_FindTenantId option:selected').val();
			var rowMfsIp = w2ui['grid'].getCellValue(colIndex, idxMfuIp);
			recItem.tenant_id = tenantId2;
			recItem.call_id = callId;
			// nat ip range 포함 여부 체크
			var natRangeYn = false;
			argoJsonSearchList('ipInfo', 'getNatRangeList', 's_', {"tenantId":tenantId}, function(data, textStatus, jqXHR) {
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
				recItem.ip = (rowMfsIp == "" ? mfsIp : rowMfsIp);
			}
			recItem.port = <%= isHttps %> ? 7220 : 7210;
			recItem.manager_id = userId;
			recItem.enc_key = 'BRIDGETEC_VELOCE';
			recItem.dn_no = logDnNo;
			recItem.rec_time = fmtRecTime;
			recItem.userName = userName;
			recItem.custTel = custTel;
			recItem.endTime = endTime;
		 	recItem.custName = custName;
			recList.push(recItem);
			logListeningKey = recTime.replace(" ","");
			
			workLog = '[TenantId:'
				+ tenantId
				+ ' | UserId:' + userId
				+ ' | GrantId:'
				+ grantId
				+ '] 파일 청취';
			
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
		});

		var recData = document.getElementById("recData");
		var txtRecData = JSON.stringify(recList);
		recData.value = encodeURIComponent(txtRecData);
		gPopupOptions.grid = w2ui.grid;
		form.submit();
		return true;
	}

	/*
	 *	일괄 재생
	 */
	function fnMultiRecPlay() {
		fnRecFilePlay(-1);
	}
	
	function fnSelectedRow(){
		for( var i = 0; i < tmpSelection.length ; i++){
			w2ui['grid'].select(tmpSelection[i]);
		}
	}

	function fnAuthRecPlay(index){
		gPopupOptions = {
			tenantId :  $('#s_FindTenantId option:selected').val()
			, playIndex : index
		};
		argoPopupWindow('인증', 'RecAuthPopF.do', '600', '300');
	}
	
	//listeningKey
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
	
	function setZeroNumFn(num) {
	    if (Number(num) < 10)
	        return "0" + num;
	    return num;
	}
	
	function fnRecFilePlay(index,scrType){
		if (index < 0) {
			index = w2ui['grid'].getSelection();
			if (index.length == 0) {
				argoAlert("한 개 이상의 녹취를 선택해주세요.");				
				return;
			}
		}else{
			index = new Array(index);			
		}
		
		if(isUseRecReason == "1"){
			gPopupOptions = {pRowIndex:index,pScrType:scrType,"cudMode":"0"};   	
	 		argoPopupWindow('청취사유등록', 'RecSearchRecLogPopAddF.do', '470', '370');	
		}else{
			fnRecFilePlayCallBack(index,scrType);
		}
	}
	
	//scrType==true:스크린 || scrType===undefined:voice녹취
	function fnRecFilePlayCallBack(index,scrType) {
		var FileList;
		var tenantId2 = $('#s_FindTenantId option:selected').val();
		var mediaScr = "";
		var logUserId = "";
		var logDnNo = "";
		var logRecKey = "";
		
		// web재생
		if (playerKind == null || playerKind == "0") {
			tmpSelection = index;
			index = index[0];		
			var callId = w2ui['grid'].getCellValue(index, idxCallId);
			var recTime = w2ui['grid'].getCellValue(index, idxRecDate) + " "+ w2ui['grid'].getCellValue(index, idxRecTime);
			var custName = w2ui['grid'].getCellValue(index, idxCustName);
			var fmtRecTime = w2ui['grid'].getCellValue(index,idxFmtRecDate)+ " " + w2ui['grid'].getCellValue(index, idxFmtRecTime);
			var telNo = w2ui['grid'].getCellValue(index, idxCustTel);
			custName = VLC_StringProc_NVL(custName, "정보없음");
			var callPlayRecord = playRecord.bind(null, w2ui['grid'], tmpSelection);
			velocePopupWindow('청취(고객명 : ' + custName + ')', 'about:blank','594', '386', '', 'sttPlay', callPlayRecord, "fnSelectedRow");
			if (isUseRecReason == "0") {
				fnRecIsNotUseRecReason(tmpSelection,0);
			}
			return;
		}
		
		var url;
		var iCmd;
		var mediaScrCd = "";
		var ws_data = "";
		var ws;
		var arrChecked;
		
		if(index >= 0){
			mediaScrCd =  w2ui['grid'].getCellValue(index, 35);
		}
		
		// 단일재생 
		if (index >= 0 && mediaScrCd != "1") {
			iCmd = "0";
			w2ui['grid'].select(index);
			tmpSelection = index;
			arrChecked = new Array(index);
			
			ws_data="cmd=" + iCmd + "&mfu_ip=" + mfsIp + "&mfu_port=7200&tenant_id=" + tenantId2
			+ "&user_id=" + w2ui['grid'].getCellValue(index, idxUserId)
			+ "&call_id=" + w2ui['grid'].getCellValue(index, idxCallId);
			
		}else{ //일괄재생 || 스크린 재생
			iCmd = "4";
			try {
				var scrSrc = (scrType == true ? "|screen|" : "|voice|" );				
				arrChecked = index;				
				FileList = "";
				$.each(arrChecked, function(index, colIndex) {
					var tmpCustTel = w2ui['grid'].getCellValue(colIndex, idxCustTel);
					var paramUserId = w2ui['grid'].getCellValue(colIndex, idxUserId) == "" ? "btadmin" : w2ui['grid'].getCellValue(colIndex, idxUserId); 
					FileList += tenantId2 + '|' + userId + '|'
							+ w2ui['grid'].getCellValue(colIndex, idxRecKey)+ '|'
							+ w2ui['grid'].getCellValue(colIndex, idxRecDate)
							+ w2ui['grid'].getCellValue(colIndex, idxRecTime)+ '|'
							+ w2ui['grid'].getCellValue(colIndex, idxDnNo)+ '|'
							+ paramUserId+ '|'
							+ w2ui['grid'].getCellValue(colIndex, idxUserName)+ '| |'
							+ w2ui['grid'].getCellValue(colIndex, idxCustName)+ '|'
							+ tmpCustTel.replace(/#/gi,"")+ '|'
							+ w2ui['grid'].getCellValue(colIndex, idxEndTime)
							+ scrSrc
							+ w2ui['grid'].getCellValue(colIndex, idxCallId)+ '|,';
				});
				ws_data="cmd=" + iCmd + "&mfu_ip=" + mfsIp +"&mfu_port=7200&tenant_id=" + encodeURI(tenantId2)
					+ "&filelist=" + encodeURI(FileList);
				
			} catch (e) {
				console.log(e);
			};
		}
		
		//청취로그  start
		if ( isUseRecReason == "0") {
			fnRecIsNotUseRecReason(arrChecked,0);
		}
		
		ws = new WebSocket("ws://localhost:8282");
		ws.onopen = function(e){
			console.log(e);			
			ws.send( ws_data );
		};
		
		ws.onclose = function(e){
			console.log(e);
		};	
				
		return;
	}
	
	// logRealtimeFlag 0=일반청취 / 1=실시간감청 / 2=파일변환 / 3=상담APP / 4=샘플콜
	function fnRecIsNotUseRecReason(indexs,logRealtimeFlag){
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
	}
	
	
	var ChildWin = null;
	function fnWavDownWeb(urls) {
		function download_next(i) {
			if (i >= urls.length) {
				return;
			}
			var a = document.createElement('a');
			a.href = urls[i];
			(document.body || document.documentElement).appendChild(a);
			if (a.click) {
				a.click(); // The click method is supported by most browsers.
			} else {
				$(a).click(); // Backup using jquery
			}
			a.parentNode.removeChild(a);
			setTimeout(function() {download_next(i + 1);}, 1500);
		}
		// Initiate the first download.
		download_next(0);
		return false;
	}
	
	function fnWavConv(index){
		index = w2ui['grid'].getSelection();
		if (index.length == 0) {
			argoAlert("한 개 이상의 녹취를 선택해주세요.");				
			return;
		}
		
		if(isUseRecReason == "1"){
			gPopupOptions = {pRowIndex:index,"cudMode":"2"};   	
	 		argoPopupWindow('파일변환로그등록', 'RecSearchRecLogPopAddF.do', '470', '370');	
		}else{
			fnWavConvCallBack(index);
		}
	}
	
	function fnWavConvCallBack(index) {
		var FileList;
		var tenantId2 = $('#s_FindTenantId option:selected').val();
		var url;
		
		var logTenantId = tenantId;
		var logWorkerId = userId;
		var logWorkIp = workIp;
		var ListeningKey = getTimeStamp2();
		var logUserId = "";
		var logDnNo = "";
		var logRecKey = "";

		try {
			FileList = "";
			var wavArray = index;
			
			var urls=new Array();
			for (var convCnt = 0; convCnt < wavArray.length; convCnt++) { 
				var pUserId = w2ui['grid'].getCellValue(wavArray[convCnt], idxUserId);
				var pDnNo = w2ui['grid'].getCellValue(wavArray[convCnt],idxDnNo);
				var pCallID = w2ui['grid'].getCellValue(wavArray[convCnt], idxCallId);
				var resultFileName = w2ui['grid'].getCellValue(wavArray[convCnt], idxFmtRecDate).replaceAll("-","")+"_";
				resultFileName += w2ui['grid'].getCellValue(wavArray[convCnt], idxFmtRecTime).replaceAll(":","")+"_";
				resultFileName += w2ui['grid'].getCellValue(wavArray[convCnt], idxCustNo)+"_";
				resultFileName += w2ui['grid'].getCellValue(wavArray[convCnt], idxUserName)+"_";
				resultFileName += w2ui['grid'].getCellValue(wavArray[convCnt], idxDnNo); 
				var protocol = <%= isHttps %> ? "https://" : "http://";
				var port = <%= isHttps %> ? "7220" : "7210";
				var url = protocol + mfsIp + ":" + port + "/filedown/"
						+ pDnNo + "/" + pUserId + "/" + pCallID
						+ "/" + resultFileName + ".mp3";
				urls.push(url);
				
				workLog = '[TenantId:'
					+ tenantId
					+ ' | UserId:' + userId
					+ ' | GrantId:'
					+ grantId
					+ '] 파일 변환';
				
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
			if(isUseRecReason == "0"){
				fnRecIsNotUseRecReason(wavArray,2);
			}
			fnWavDownWeb(urls);
		} catch (e) {
			console.log(e);
		};
	}
</script>

<script type="text/javascript">
	function Display_Input_Panel(panel, obj, btn) {
		if (obj.style.display == "none") {
			obj.style.display = "";
			btn.className = "btn_tab";
		} else {
			obj.style.display = "none";
			btn.className = "btn_tab confirm";
		}

		var nDisplayPanelCount = 1;

		if (document.getElementById('div_tenant').style.display == "")
			nDisplayPanelCount++;
		if (document.getElementById('div_user').style.display == "")
			nDisplayPanelCount++;
		if (document.getElementById('div_cust').style.display == "")
			nDisplayPanelCount++;
		if (document.getElementById('div_call').style.display == "")
			nDisplayPanelCount++;

		switch (nDisplayPanelCount) {
		case 0:
			panel.className = "search_area";
			break;
		case 2:
			panel.className = "search_area row2";
			break;
		case 3:
			panel.className = "search_area row3";
			break;
		case 4:
			panel.className = "search_area row4";
			break;
		case 5:
			panel.className = "search_area row5";
			break;
		}
	}
	
	
	function fn_showSpan(obj){
		if(obj.checked){
			$("#groupMultiSelect").removeAttr("hidden");
			$("#groupSingSelect").attr("hidden","hidden");
		}else{
			$("#groupSingSelect").removeAttr("hidden");
			$("#groupMultiSelect").attr("hidden","hidden");
		};
	}
	
	//now
	function fn_scrPopup(colIndex){
		if (colIndex < 0) {
			colIndex = w2ui['grid'].getSelection();
			if (colIndex.length == 0) {
				argoAlert("한 개 이상의 녹취를 선택해주세요.");				
				return;
			}
		}else{
			colIndex = new Array(String(colIndex));			
		}
		
		if(isUseRecReason == "1"){
			gPopupOptions = {pRowIndex:colIndex,"cudMode":"01"};   	
	 		argoPopupWindow('청취사유등록', 'RecSearchRecLogPopAddF.do', '470', '370');	
		}else{
			fn_scrPopupCallBack(colIndex);
		}
	}
	
	function fn_scrPopupCallBack(colIndex) {
		var ci = colIndex[0];
		var rowMfuIp = $(w2ui['grid'].get(ci)).attr("mfuIp");
		var mfuIp = (rowMfuIp == "" ? mfsIp : rowMfuIp);
		var port = <%= isHttps %> ? 7220 : 7210;
		var dnNo = $(w2ui['grid'].get(ci)).attr("dnNo");
		var userId = userId;
		var callId = $(w2ui['grid'].get(ci)).attr("callId");

		var scrForm = document.getElementById("scr_form");
		if (scrForm == null) {
			scrForm = $('<form></form>');
			scrForm.attr("id","scr_form");
			scrForm.attr("method","post");
			scrForm.attr("target","scrPlayPop");
			scrForm.attr("action","STTPlayscreenF.do");
			scrForm.append($("<input/>", {type: "hidden", id: "mfuIp", Name:"mfuIp", value:mfuIp}));
			scrForm.append($("<input/>", {type: "hidden", id: "mfuPort", Name:"mfuPort", value:port}));
			scrForm.append($("<input/>", {type: "hidden", id: "dnNo", Name:"dnNo", value:dnNo}));
			scrForm.append($("<input/>", {type: "hidden", id: "userId", Name:"userId", value:userId}));
			scrForm.append($("<input/>", {type: "hidden", id: "callId", Name:"callId", value:callId}));
			scrForm.appendTo("body");
		}
		window.open("", "scrPlayPop", "location=no, height=700, width=1000, scrollbars=yes, status=no");
		scrForm.target = "scrPlayPop";
		scrForm.submit();
		scrForm.remove();
		
		//청취로그  start
		if (isUseRecReason == "0") {
			fnRecIsNotUseRecReason(colIndex,"01");
		}
	}
	
	function dnExcelSampleDownload(){
		//excel parameter start
		var fGN = argoGetValue('s_FindGroupId');
		if (fGN.indexOf("_") != -1) {
			fGN = fGN.split("_")[0];
		}
		var termS = $("#selDateTerm1").val();
		if (termS == "S_1") {
			termS = "0";
		} else {
			termS = "1";
		}
		//excel parameter end
		//excel export start
		var param = serializeFormNoService("s_")+"&userId="+userId+"&controlAuthGroup="+ControlAuthGroup+"&controlAuth="+controlAuth
		+"&grantId="+grantId+"&groupId="+groupId+"&findGroupIdnew="+fGN+"&findTS="+termS
		var actionUrl = gGlobal.ROOT_PATH + "/RecSearch/DataExcelExportF.do?"+param+"&excelImSvcName=recSearchNew"
											+"&excelImMethodName=getRecSearchListNew&disInsColNum=0";
		var excelFileName = "통화내역조회";
		var colKey = ['recDate','recTime','groupName','userId','userName','dnNo','endTime','callKind','custTel','custName','custNo','callId','hlod','tranTel'];
		var calVal = ['통화일자','통화일자','그룹명','상담사ID','상담사명','내선','통화','구분','전화번호','고객명','고객번호','콜아이디','보류회수','호전화'];
		gPopupOptions = {pExcelUrl:actionUrl , pColKey:colKey , pColVal:calVal,pExcelFileName:excelFileName } ;
		argoPopupWindow('Excel Export',gGlobal.ROOT_PATH+ '/common/VExcelExportJavaF.do','150', '40');
		//excel export end 
	}
	
	/* 전화번호 입력 - 'dash' 가 들어올 시 제거*/
	function setCallNumber(object) {
		var val = $(object).val();
		val = val.replace(/-/g, '');

		$(object).val(val);
	}
</script>
</head>
	<body>
		<div class="sub_wrap">
			<div class="location" id="searchPanel_SAP">
				<button type="button" id="btnTenantDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_tenant, btnTenantDisplay)">태넌트</button>
				<button type="button" id="btnUserDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_user, btnUserDisplay)">사용자정보</button>
				<button type="button" id="btnCustDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_cust, btnCustDisplay)">고객정보</button>
				<button type="button" id="btnCallDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_call, btnCallDisplay)">통화정보</button>
				<span style="width: 100px">&nbsp;</span> <span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역조회</span><strong class="step">통화내역조회</strong>
			</div>
			<section class="sub_contents">
				<div class="search_area row5" id="searchPanel">
					<div class="row" id="div_tenant">
						<ul class="search_terms">
							<li>
								<strong class="title ml20">태넌트</strong> 
								<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
								<input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" /> 
								<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1">
							</li>
						</ul>
					</div>
					<div class="row" id="div_user">
						<ul class="search_terms">
							<li>
								<strong class="title ml20">내선번호</strong> 
								<input type="text" id="s_FindDnText" name="s_FindDnText" style="width: 140px" class="clickSearch" />
							</li>
							<li>
								<strong class="title" style="margin-left: 20px;">사용자</strong>
								<!-- <select id="s_FindUserId" name="s_FindUserId" style="width:140px;" class="list_box" title="사용자의 그룹을 먼저 선택하세요!"></select> -->
								<input type="text" id="s_FindUserNameText" name="s_FindUserNameText" style="width: 140px" class="clickSearch" />
							</li>
							<li style="margin-left: 15px;"><strong class="title ml20">그룹</strong>
								<select id="s_FindGroupId" name="s_FindGroupId" style="width: 140px" class="list_box"></select>
							</li>
						</ul>
					</div>
					<div class="row" id="div_cust">
						<ul class="search_terms" style="width: 1200px;">
							<li><strong class="title ml20">고객명</strong> 
								<input type="text" id="s_FindCustNameText" name="s_FindCustNameText" style="width: 140px" class="clickSearch" /> 
								<input type="hidden" id="s_FindCustNameText_hidden" name="s_FindCustNameText_hidden" style="width: 140px" class="clickSearch" />
							</li>
							<li><strong class="title ml20">전화번호</strong> 
								<input type="text" id="s_FindCustTelText" name="s_FindCustTelText" style="width: 140px" class="clickSearch" onkeyup="javascript:setCallNumber(this);"/> 
								<input type="hidden" id="s_FindCustTelText_hidden" name="s_FindCustTelText_hidden" style="width: 140px" class="clickSearch" />
							</li>
							<li><strong class="title">고객번호</strong> 
								<input type="text" id="s_FindCustNoText" name="s_FindCustNoText" style="width: 140px" class="clickSearch" />
							</li>
							
							<li><strong class="title">추가검색(new)</strong> 
								<select id="s_FindField2" name="s_FindField2" style="width: 118px;" class="list_box">
									<option value="">== 추가검색어 ==</option>
								</select> 
								<input type="text" id="s_FindFieldText2" name="s_FindFieldText2" style="width: 120px" class="clickSearch" /> 
							</li>
						</ul>
					</div>
					<div class="row" id="div_call">
						<ul class="search_terms">
							<li><strong class="title ml20">통화구분</strong> 
								<select id="s_FindCallKind" name="s_FindCallKind" style="width: 140px" class="list_box">
									<option value="">선택하세요!</option>
									<option value="1">수신</option>
									<option value="2">발신</option>
								</select>
							</li>
							<li><strong class="title ml20">마킹구분</strong> 
								<select id="s_FindMarkKind" name="s_FindMarkKind" style="width: 140px" class="list_box"></select>
							</li>
							<li><strong class="title">콜아이디</strong> <input type="text" id="s_FindCallIdText" name="s_FindCallIdText" style="width: 140px" class="clickSearch" /></li>
							<li><strong class="title">호전환 번호</strong> <input type="text" id="s_FindTranTelText" name="s_FindTranTelText" style="width: 140px" class="clickSearch" /></li>
						</ul>
					</div>
					<div class="row">
						<ul class="search_terms">
							<li style="width: 672px"><strong class="title ml20">녹취일자</strong>
								<span class="select_date">
									<input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From">
								</span> 
								<span class="timepicker rec" id="rec_time1">
									<input type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time" value="00:00:00">
									<a href="#" class="btn_time">시간 선택</a>
								</span> 
								<span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span> 
								<span class="select_date">
									<input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To">
								</span> 
								<span class="timepicker rec" id="rec_time2">
									<input type="text" id="s_RecEndTm" name="s_RecEndTm" class="input_time" value="23:59:59">
									<a href="#" class="btn_time">시간 선택</a>
								</span> &nbsp;
								<select id="selDateTerm1" name="" style="width: 70px;" class="mr5"></select>
							</li>
							<li>
								<strong class="title ml20">통화시간</strong> 
								<span class="timepicker rec" id="rec_time1">
									<input type="text" id="s_CallFrmTm" name="s_CallFrmTm" class="input_time" value="00:00:00">
									<a href="#" class="btn_time">시간 선택</a>
								</span>
								<span class="text_divide">~</span> 
								<span class="timepicker rec" id="rec_time2">
									<input type="text" id="s_CallEndTm" name="s_CallEndTm" class="input_time" value="00:00:00">
									<a href="#" class="btn_time">시간 선택</a>
								</span>
							</li>
							<li id="is_callexcept_node">
								<strong class="title">청취권한</strong>
								<select id="is_callexcept" name="is_callexcept" style="width: 80px" class="list_box">
									<option value="Y">예</option>
									<option value="N">아니오</option>
								</select> <!-- <strong class="title">본인 콜 제외</strong> --> <!-- <input type="checkbox" id="is_callexcept" name="is_callexcept"> -->
							</li>
						</ul>
					</div>
				</div>
				<div class="btns_top" id="searchPanel_SAP2">
					<div class="sub_l">
						<strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount">0</span>
						<select id="s_SearchCount" name="s_SearchCount" style="width: 50px" class="list_box">
							<option value="15">15</option>
							<option value="20">20</option>
							<option value="30">30</option>
							<option value="40">40</option>
							<option value="50">50</option>
						</select>
					</div>
					<input type="text" id="clip_target" name="clip_target" style="width: 150px; position: absolute; top: -9999em;" />
					<button type="button" id="btnSearch" class="btn_m search">조회</button>
	 				<button type="button" id="btnExcelInfoChange" class="btn_m confirm" >일괄수정</button>
	 				<button type="button" id="btnInfoChange" class="btn_m confirm" >정보수정</button>
					<button type="button" id="btnMarkAdd" class="btn_m confirm">마킹등록</button>
					<button type="button" id="btnMarkDel" class="btn_m confirm">마킹삭제</button>
					<button type="button" id="btnSampAdd" class="btn_m confirm">샘플콜등록</button>
					<button type="button" id="btnPlay" class="btn_m">일괄재생</button>
					<button type="button" id="btnWavConv" class="btn_m">파일변환</button>
					<button type="button" id="btnFileDown" class="btn_m">수동백업</button>
					<button type="button" id="btnExcelImport" class="btn_m confirm">고객정보 일괄등록</button>
					<button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
					<button type="button" id="btnReset" class="btn_m">초기화</button>
				</div>
				<div class="h136">
					<div class="btn_topArea fix_h25"></div>
					<div class="grid_area h25 pt0">
						<div id="gridList" style="width: 100%; height: 432px;"></div>
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