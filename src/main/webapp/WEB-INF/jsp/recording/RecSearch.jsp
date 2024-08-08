<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

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
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="Pragma" content="no-cache" />
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<script type="text/javascript" src="<c:url value='/scripts/fullcalendar-3.1.0/lib/moment.min.js'/>"></script>

<script type="text/javascript" src="<c:url value='/scripts/velocejs/veloce.popupWindow.js?ver=2017010611'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery.ajax-cross-origin.min.js'/>"></script>
<style type="text/css">
/* .pop_box .pop_t .pop_message{ color:#595959; font-size:16px; text-align:left; padding-left:145px; height:137px; display:table-cell; width:410px; font-weight:600; line-height:22px; padding-right:10px; position:relative; top:20px;}; */
/* .pop_alim.small .pop_box .pop_t .pop_message{color: #505050;font-size: 14px;text-align: left;height:auto;display:table-cell;width: 100%;font-weight:600;line-height: 20px;position:relative;padding:38px 15px 28px 114px;min-height:96px;box-sizing: border-box;}; */

	.ui-autocomplete
	{
		max-height: 100px;
		overflow-y: auto; /* prevent horizontal scrollbar */
		overflow-x: hidden;
	}
	/* IE 6 doesn't support max-height
	* we use height instead, but this forces the menu to always be this tall
	*/
	html .ui-autocomplete
	{
		height: 100px;
	}
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
	var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
    var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;
    var userId      = loginInfo.SVCCOMMONID.rows.userId;
    var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
    var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
    var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
    var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
    var depth		= loginInfo.SVCCOMMONID.rows.depth;
    var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
    var backupAt	= loginInfo.SVCCOMMONID.rows.backupAt;
    var authRank    = loginInfo.SVCCOMMONID.rows.authRank;
    var groupName	= loginInfo.SVCCOMMONID.rows.groupName;
	
    var searchGroupName = "";
    if(groupName.split("_").length == "1"){
    	searchGroupName = "EMPTY_CODE";
    }else{
    	searchGroupName = groupName.split("_")[0];
    }
    //var searchGroupname = groupName.split("_");
    
    
	var callbackAfterSearchCondition = {};
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
	
	// 검색기간 select box properties 파일에 가져오기
	var termValList  = '<spring:eval expression="@code['Globals.termValList']"/>';
	var termValArr = termValList.split("|");
	var maxTerm;
	var recAuth = '<spring:eval expression="@code['Globals.recAuth']"/>';
	var custInfoAuthStr = '<spring:eval expression="@code['Globals.custInfoChange']"/>'.split("|");
	var custInfoAuth = false;
	var isUseRecReason;
	
	var voicePlayYn = "N";
	
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
		
		// 슈퍼어드민 권한유저만 사유코드관리 사용가능
		if(grantId != "SuperAdmin"){
		    $("#btnReasonCodeManage").remove();
		}else{
			$("#btnReasonCodeManage").css("display", "inline-block");
		}
		
		// 슈퍼어드민/시스템어드민/매너지 권한유저만 소속별 권한부여 버튼 사용가능
		if(grantId != "SuperAdmin" && grantId != "SystemAdmin" && grantId != "Manager"){
		    $("#btnGroupGrantManage").remove();
		}else{
			$("#btnGroupGrantManage").remove();
			//$("#btnGroupGrantManage").css("display", "inline-block");
		}
		
		
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
			fnInitGrid();
			loadSearchCond();
			$("#s_FindFieldText").show();
			$("#s_FindFieldText_jbbank").hide();

			if(vlcOPT.VLC_CUST_ALL){
				$("#btnExcelImport").hide();
			}
			
			argoSetValue("s_RecFrmTm", "00:00:00");
			argoSetValue("s_RecEndTm", "23:59:59");
			argoSetValue("s_CallFrmTm", "00:00:00");
			argoSetValue("s_CallEndTm", "23:59:59");
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

			argoSetValue("s_RecFrmTm", "00:00:00");
			argoSetValue("s_RecEndTm", "23:59:59");
			argoSetValue("s_CallFrmTm", "00:00:00");
			argoSetValue("s_CallEndTm", "23:59:59");
		}
	});

    function displayRecPlayBtn() {
    	console.log("displayRecPlayBtn authRank : " + authRank);
    	
    	if(authRank < 3){
    		$('#btnPlay').show();
    	}else{
    		var downloadListenGb = argoGetValue("s_DownloadListen");
    		if(downloadListenGb == "1" || authRank < 4){
        		$('#btnPlay').show();
        	}else{
        		$('#btnPlay').hide();
        	}
    	}
    	
        //if ($("#chkListeningYn").is(':checked') || authRank < 4)  $('#btnPlay').show(); else $('#btnPlay').hide();
    }
    function displayRecDownloadBtn() {
    	var downloadListenGb = argoGetValue("s_DownloadListen");
    	if(downloadListenGb == "2" || authRank < 3){
    		$('#btnWavConv').show();
    	}else{
    		$('#btnWavConv').hide();
    	}
        //if ($("#chkDownloadYn").is(':checked') || authRank < 3)  $('#btnWavConv').show(); else $('#btnWavConv').hide();
    }

	function switchRecGrant(display) {
        $('#div_cust').css('display', display? 'none' : '');
        $('#div_call').css('display', display? 'none' : '');
        $("#btnCustDisplay").attr('disabled', display);
        $("#btnCallDisplay").attr('disabled', display);

        var rowCnt = $('#searchPanel').find('.row').length - $('#searchPanel').find('.row:hidden').length;
        $("#searchPanel").attr("class", "search_area row" + rowCnt);
	}

	function getRecSearchAPI(){
		$('#paging').hide();
		fnInitGrid();
	    //AND F.TENANT_ID = '$API_TENANT_ID$'
	    //AND F.REC_TIEM ='$API_REC_TIME$';
		var API_TENANT_ID = vlcOPT.VLC_SSO_TENANT_ID;
		var API_REC_TIME = "<%=apirectime%>";
		var API_CUST_TEL = "<%=apicusttel%>";
	
		argoJsonSearchList('recSearch'
				, 'getRecSearchList_API'
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

									//20180926 yoonys start
									//스크린 청취 플래그를 통해서 판단
									//0이면 없음
									//1이면 innerHTML?
									var btnMediaScr;
									if (row.mediaScr == 1) {
										if(playerKind==1){
											btnMediaScr = "<button type='button' class='btn_m' onclick='fnRecFilePlay(\""+index+"\","+true+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";
											//btnMediaScr = "<button type='button' class='btn_m' onclick='fnRecFilePlay("+index+","+true+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";	
										}else{
											btnMediaScr = "<button type='button' class='btn_m' onclick='fn_scrPopup("+index+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";
										}
									}else{
										btnMediaScr="";
									}
														
									
									gridObject = {
										"mediaScr" : btnMediaScr,
										"recid" : index,
										"recKey" : row.recKey,
										"recDate" : fnStrMask( "YMD", row.recDate),
										"recTime" : fnStrMask( "HMS", row.recTime),
										"groupName" : row.groupName,
										"userId" : row.userId,
										"userName" : row.userName,
										"dnNo" : row.dnNo,
										"endTime" : fnSecondsConv(row.endTime),
										"callKind" : row.callKind
										//, "custTel" 		: VLC_PRIVACY_MASK(1,4,fnGetSDKVLCDEC(row.custTel))
										,
										"custTel" : row.custTel,
										"custName" : row.custName,
										"custNo" : row.custNo,
										"callId" : row.callId,
										"holdCnt" : row.hold,
										"tranTel" : row.tranTel,
										"holdTime" : holdTime,
										//, "custEtc1" 		: VLC_PRIVACY_MASK(1,7,fnGetSDKVLCDEC(row.custEtc1))
										
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
										"recTime2": row.recTime2,
										"callId2": row.callId2,
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

	function VLC_PRIVACY_MASK(POS_FLAG, MASK_CNT, TEXT) {
		var proc = VLC_StringProc_NVL(TEXT, 'ERROR');
		//*모음을 만든다
		if (proc == 'ERROR' || TEXT.length <= MASK_CNT) {
			return TEXT;
		} else {
			var token = "";
			for (var cnt = 0; cnt < MASK_CNT; cnt++) {
				token += '*';
			}
			if (POS_FLAG == 0) {
				//TEXT = TEXT.substring((TEXT.length-1)-(MASK_CNT+1),TEXT.length);
				//console.log("토큰앞 : "+token);
				//TEXT = token+TEXT;
			} else if (POS_FLAG == 1) {
				TEXT = TEXT.substring(0, TEXT.length - MASK_CNT);
				//console.log(TEXT);
				TEXT = TEXT + token;
			}
		}
		return TEXT;
	}

	function fnJbbankCustEtc(jbbStr) {

		var jbbCode = [ '01', '04', '05', '09', '10', '12', '13', '14', '60',
				'61', '62', '70', '80', '90', '91', '92', '93', '94', '95',
				'96', '97', '98', '99', '100', '101', '102', '103', '104',
				'105', '106', '107', '00' ];
		var jbbName = [ '비밀번호', '보안카드비밀번호', 'OTP비밀번호', '카드비밀번호', '계좌비밀번호',
				'주민등록번호(2회입력)', '비밀번호(2회입력)', '오토라이프 주민등록번호 입력', '욕설', '성희롱',
				'업무방해', '인증번호', '팩스번호', '개인정보동의', '휴대폰본인인증', '마케팅 동의',
				'출금 동의(신청)', '출금 동의(변경)', '약정 동의(멤버쉽론)', '약정 동의(뉴카드론)',
				'약정 동의(비대면대출)', '약정 동의(체인지업론)', '약정 동의(피플펀드론)', '자동이체 동의(신청)',
				'약정 동의(가계대출)', '타행계좌 출금동의', '오토론 개인정보동의', '오토론 약정동의',
				'담보제공인 동의', '오토라이프 개인정보동의', '오토라이프 약정동의', '선택녹취' ];

		if (VLC_StringProc_NVL(jbbStr, "9999") != "9999") {
			for (var jbbNum = 0; jbbNum < jbbCode.length; jbbNum++) {
				if (jbbCode[jbbNum] == jbbStr) {
					return jbbName[jbbNum];
				}
			}
		}
	}

	function fnGetSDKVLCDEC(plainText) {
		var result = "";
		if (plainText == "" || plainText == null)
			return result;

		if (VLC_StringProc_NVL(plainText, "ERROR") != "ERROR") {
			result = plainText;
			if (plainText.length >= 24) {

				result = result.trim();
				var param = {
					"plainText" : result
				};
				$.ajax({
					type : 'post',
					async : false,
					data : param,
					url : gGlobal.ROOT_PATH + "/SDKDEC.do",
					dataType : "json",
					success : function(data) {
						result = data.test;
					},
					error : function(xhr, status, error) {
						result = "-";
					}
				});
			}
		} else {
			result = "";
		}
		return result;

	}

	function fnGetSDKVLCENC(plainText) {
		var result = "";
		if (plainText == "" || plainText == null)
			return result;

		if (VLC_StringProc_NVL(plainText, "ERROR") != "ERROR") {
			result = plainText;
			//if(plainText.length>=24){

			result = result.trim();
			var param = {
				"plainText" : result
			};
			$.ajax({
				type : 'post',
				async : false,
				data : param,
				url : gGlobal.ROOT_PATH + "/SDKENC.do",
				dataType : "json",
				success : function(data) {
					result = data.test;
				},
				error : function(xhr, status, error) {
					result = "-";
				}
			});
			//}		
		} else {
			result = "";
		}
		return result;

	}

	function fnPlayConfProc() {
		var playK = VLC_StringProc_NVL(playerKind, "1");
	};


	/**
	 * 페이지 재 로드시 파라미터 세팅
	 */
	function loadSearchCond() {
	    if (!parent.$("#RecSearchF").val()) {
	        return;
        }

	    var searchCond = JSON.parse(parent.$("#RecSearchF").val());
        if (searchCond.s_FindTenantId) {
            argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupListByParentId", {tenantId: $('#s_FindTenantId').val()}
                , {"selectIndex" : 0, "text" : '선택하세요!', "value" : ''}
            );

            argoCbCreate("s_FindMarkKind", "comboBoxCode", "getMarkCodeList"
                , {findTenantId : $('#s_FindTenantId').val()}
                , {"selectIndex" : 0, "text" : '선택하세요!', "value" : ''}
            );
            fnGroupCbChange("s_FindGroupId");
        }
        
        $.each(searchCond, function(key, value) {
        	if (key.startsWith('s_') || key.startsWith('sel')) {
                $("#"+ key).val(value);
            }
            else if (key.startsWith('chk')) {
                $("#"+ key).prop('checked', $.parseJSON(value));
            }
        });

        if (searchCond.strOption) {
            $('#s_FindField').append(searchCond.strOption);
            $('#s_FindField').val(searchCond.s_FindField);
        }

        if (searchCond.selectionPage) {
            workPage = searchCond.selectionPage;
        }

        if (searchCond.div_tenant == 'none') {
            $("#div_tenant").hide();
            $("#btnTenantDisplay").attr("class", "btn_tab confirm");
        }
        if (searchCond.div_user == 'none') {
            $("#div_user").hide();
            $("#btnUserDisplay").attr("class", "btn_tab confirm");
        }
        
		if(argoGetValue("s_DownloadListen") == "1"){
			switchRecGrant(true);
		}else {
            if (searchCond.div_cust == 'none') {
                $("#div_cust").hide();
                $("#btnCustDisplay").attr("class", "btn_tab confirm");
            }
            if (searchCond.div_call == 'none') {
                $("#div_call").hide();
                $("#btnCallDisplay").attr("class", "btn_tab confirm");
            }
        }
		
        /* if ($.parseJSON(searchCond.chkListeningYn)) {
            switchRecGrant(true);
        }
        else {
            if (searchCond.div_cust == 'none') {
                $("#div_cust").hide();
                $("#btnCustDisplay").attr("class", "btn_tab confirm");
            }
            if (searchCond.div_call == 'none') {
                $("#div_call").hide();
                $("#btnCallDisplay").attr("class", "btn_tab confirm");
            }
        } */
        
        var rowCnt = $('#searchPanel').find('.row').length - $('#searchPanel').find('.row:hidden').length;
        $("#searchPanel").attr("class", "search_area row" + rowCnt);

        // 페이지 재입시 조회 처리
        fnSearchListCnt();
        /* if (searchCond.dataArray) {
            w2ui['grid'].add(searchCond.dataArray);
            $('#gridList').show();
            $('#paging').show();
            $("#totCount").text(searchCond.totalData);
            displayRecPlayBtn();
            displayRecDownloadBtn();
            w2ui.grid.unlock();

            pageNavi(searchCond.totalData, searchCond.selectionPage, searchCond.searchCnt, '2', function (pn) {
                var startRow  = ((pn -1) * searchCond.searchCnt) +1;
                var endRow    = pn * searchCond.searchCnt;
                fnSearchList(startRow, endRow);
            });

            callbackAfterSearchCondition = searchCond.callbackAfterSearchCondition;
        } */
	}

	/**
     * Set 조회조건
     */
    function setSearchCond(key, val) {
        var searchCond = JSON.parse(parent.$("#RecSearchF").val());
        searchCond[key] = val;
        parent.$("#RecSearchF").val(JSON.stringify(searchCond));
    }


	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			if ($('#s_FindTenantId option:selected').val() == '') {
				$('#s_FindGroupId option').remove();
				$('#s_FindGroupId').append($('<option>', {
				    value: "",
				    text: "선택하세요!"
				}));
						
				$('#s_FindMarkKind option').remove();
				$('#s_FindMarkKind').append($('<option>', {
				    value: "",
				    text: "선택하세요!"
				}));		

				$('#s_FindDnGubunText option').remove();
				$('#s_FindDnGubunText').append($('<option>', {
				    value: "",
				    text: "선택하세요!"
				}));

			} else {
				 argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupListByParentId", {tenantId: $('#s_FindTenantId').val()}, {
							"selectIndex" : 0,
							"text" : '선택하세요!',
							"value" : ''
						});
				argoCbCreate("s_FindMarkKind", "comboBoxCode",
						"getMarkCodeList", {
							findTenantId : $('#s_FindTenantId option:selected').val()
						}, {
							"selectIndex" : 0,
							"text" : '선택하세요!',
							"value" : ''
						});

				argoCbCreate("s_FindDnGubunText", "comboBoxCode",
						"getUserDnGubunList", {
							findTenantId : $('#s_FindTenantId option:selected').val()
						}, {
						"selectIndex" : 0,
						"text" : '선택하세요!',
						"value" : ''
					});
				//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
				SetGridHideColumn($('#s_FindTenantId option:selected').val());
				//fnSearchListCnt();	
				fnGroupCbChange("s_FindGroupId");
			}
		} else if (kind == "group") {
			if ($('#s_FindGroupId option:selected').val() == '') {
				//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			} else {
				//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:$('#s_FindTenantId option:selected').val(), FindGroupId:$('#s_FindGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
		}
	}

	function fnInitCtrl() {
		
		
		/* var ctrlDown = false;
	    var ctrlKey = 17, vKey = 86, cKey = 67;
	 
	    $(document).keydown(function(e)
	    {
	        if (e.keyCode == ctrlKey) ctrlDown = true;
	    }).keyup(function(e)
	    {
	        if (e.keyCode == ctrlKey) ctrlDown = false;
	    });
		
		$("#s_RecFrmTm").keydown(function(e){
	        if (ctrlDown && (e.keyCode == vKey || e.keyCode == cKey)) {
				console.log("컨트롤 씨브이 눌렀음!!! ");        	
				return false;
	        }
	    }); */
		
		$("#s_RecFrmTm").prop("readonly", false);
		$("#s_RecEndTm").prop("readonly", false);
		$("#s_CallFrmTm").prop("readonly", false);
		$("#s_CallEndTm").prop("readonly", false);
		argoCbCreate("#ip_ReasonCode", "ARGOCOMMON", "getBaseCodeList", {sort_cd : 'REC_SEARCH_REASON_CD'}, {});
		switchRecGrant($("#chkListeningYn").is(':checked'));
		
		$("#ip_ReasonCode").change(function(){
			// 기타사유 선택시 팝업창 출력
			if(argoGetValue("ip_ReasonCode") == "00000"){
				fnRecSearchReasonAddPop();
			}
		});
		
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
		
		argoCbCreate("s_FindDnGubunText", "comboBoxCode", "getUserDnGubunList", {findTenantId : tenantId}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});
		
		 /* argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupListByParentId", {tenantId: $('#s_FindTenantId').val() || tenantId}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		}); */
		argoSetDeptChoice("btn_Group1", {"targetObj" : "s_FindGroup","multiYn" : 'N'}); //조직선택 팝업 연결처리(멀티)
		$('#clearButton').on('click', function() {
	        argoSetValue("s_FindGroupId", "")
	        argoSetValue("s_FindGroupNm", "")
	    });
		//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindMarkKind", "comboBoxCode", "getMarkCodeList", {
			findTenantId : tenantId
		}, {
			"selectIndex" : 0,
			"text" : '선택하세요!',
			"value" : ''
		});
		
		$("#btnReasonCodeManage").click(function(){
			argoPopupWindow( '사유코드관리', 'RecReasonCodemanageF.do',  '400', '500' ); 
		});
		
		$("#btnGroupGrantManage").click(function(){
			argoPopupWindow( '그룹별 권한관리', 'GroupGrantManageF.do', '1000', '600' ); 
		});
		
		argoSetValue("s_RecFrmTm", "00:00:00");
		argoSetValue("s_RecEndTm", "23:59:59");
		argoSetValue("s_CallFrmTm", "00:00:00");
		argoSetValue("s_CallEndTm", "23:59:59");

		//fnGroupCbChange("s_FindGroupId");

		fnAuthBtnChk(parent.$("#authKind").val());

		// 상담사 권할일 경우 샘플콜등록 버튼 숨기기
		if(grantId == "Agent") {
			$("#btnSampAdd").hide();
			
			argoSetValue("s_FindUserNameText", userId);
			//argoSetValue("s_FindUserNameText", "btadmin");
		}

		if (grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager") {
			//Display_Input_Panel(searchPanel, div_tenant, btnTenantDisplay);
			
			//$("#btnTenantDisplay").hide();
		}

        /** 녹취권한 */
        //$('#btnRecGrantReq').css('display', authRank > 2 ? '' : 'none'); // Manager 권한 이하 [권한요청] button show
        console.log("authRank : " + authRank);
        $('#btnPlay').css('display',  authRank < 4 ? '' : 'none');  // Manager 권한 이상 [일괄재생] button show
        //$('#btnStt').css('display',  authRank < 4 ? '' : 'none');  // Manager 권한 이상 [일괄재생] button show
        //$('#spChkDownloadYn').css('display', grantId == 'Manager'  ? '' : 'none');    // Manager 권한은 [다운로드] checkbox show
        switchRecGrant(false);
        // 청취 checkbox 변경 이벤트 처리
		/* $("#chkListeningYn").change(function() {
            switchRecGrant($("#chkListeningYn").is(':checked'));
        }); */
        $("#s_DownloadListen").change(function() {
        	if(argoGetValue("s_DownloadListen") == "1"){
        		switchRecGrant(true);
        	}else{
        		switchRecGrant(false);
        	}
        });
        

		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);

		$("#s_FindTenantId").change(function() {
			fnSetSubCb('tenant');
		});
		/* $("#s_FindGroupId").change(function() {
			fnSetSubCb('group');
		}); */



		if (grantId == "GroupManager" || grantId == "Agent" || grantId == "Manager") {
			$("#btnExcelInfoChange").hide();
			$("#btnInfoChange").hide();
			//$('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);

			if (grantId == "Agent") {
				$('#s_FindUserId option[value="' + userId + '"]').prop('selected', true);
// 				Display_Input_Panel(searchPanel, div_user, btnTenantDisplay);
// 				$("#btnUserDisplay").hide();
// 				$("#s_FindUserId").attr("disabled", true);
				//$('#s_FindGroupId option[value=""]').prop('selected', true);
			}
		}
		


		$("#btnInfoChange").click(function(){
			if(!custInfoAuth){
				alert('권한이 없는 상담사입니다.');
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
			argoPopupWindow('고객정보 수정', 'RecSearchInfoPopF.do', '550', '500');
		});

		$("#btnExcelImport").click(function() {
			argoPopupWindow('고객정보 일괄등록', gGlobal.ROOT_PATH + '/common/VExcelFormF.do', '500', '500');
		});

		$("#btnSearch").click(function() { //조회
		    if (!isValidSearch()) {
		        return;
		    }

		    // 조회 사유 등록 팝업
			fnRecSearchReasonAddPop();
		});
		
		
		$("#btnSearchDetail").click(function() { //조회
			var arrChecked = w2ui['grid'].getSelection();
		 	var maskingYn = "N";
			if(arrChecked.length==0) {
		 		argoAlert("녹취 이력을 선택해 주세요.") ;
		 		return ;
		 	}
		 	
		 	$.each(arrChecked, function(idx, value){
		 		if(w2ui.grid.get(value).maskingYn == "Y"){
		 			maskingYn = "Y"
		 			return;
		 		}
		 	});
		 	$("#mySelect option:selected").text();
		 	if(maskingYn == "Y"){
		 		argoAlert("조회 사유를<br>" + $("#ip_ReasonCode option[value='00000']").text() + "으로<br>선택 후 조회한 경우에만 상세조회가 가능합니다.");
		 		return;
		 	}
		 	
		 	$.each(arrChecked, function(idx, value){
		 		w2ui.grid.get(value).custName = w2ui.grid.get(value).fullCustName;
		 		w2ui.grid.get(value).custTel = w2ui.grid.get(value).fullCustTel;
		 		w2ui.grid.get(value).custNo = w2ui.grid.get(value).fullCustNo;
		 		w2ui.grid.set(value);
		 	});
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
		
		$("#btnStt").click(function(){
			var chkArr = w2ui['grid'].getSelection();
			if(chkArr.length != 1){
				argoAlert("한 개의 녹취 건을 선택해 주세요.");
				return;
			}else{
				var callId = w2ui['grid'].get(chkArr[0]).callId;
				var listeningYn = w2ui['grid'].get(chkArr[0]).listeningYn;
				if (listeningYn != 'Y') {
			        argoAlert('STT 조회 권한이 없습니다.');
			        voicePlayYn = "N";
			        return;
			    }
				argoSttView(callId);
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
				//fnSearchListCnt();
				fnRecSearchReasonAddPop();
			}
		});

		if (grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager") {
			argoJsonSearchList('recSearch', 'getControlList', 's_', {
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

		// 2018.02.07 상담사 콤보박스 표시 여부
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

		$("#btnExcel").click(function() {
            dnExcelSampleDownload();
        });
		
        $("#btnRecGrantReq").click(function() {
            // 선택여부 check
            var rows = w2ui['grid'].getSelection();
            var secValidate = "0";
            
            if (rows.length == 0) {
                argoAlert("권한 요청할 통화내역을 선택하세요.") ;
                return ;
            }

            $.each(rows, function(idx, value){
    		    var callingSec = argoTimeToSeconds(w2ui["grid"].get(value).endTime);
    		    if(callingSec <= 2){
    				secValidate = "1";
    				argoAlert("통화시간이 3초 이상인 녹취 이력만 선택해 주세요.");
    				return;
    			}
    		});
            
            if(secValidate == "0"){
	            var selList = new Array();
	            $.each(rows, function(index, item) {
	                selList.push(w2ui['grid'].get(item));
	            });
	
	            // popup parameter
	            gPopupOptions = {
	                tenantId: grantId == 'SuperAdmin' ? $('#s_FindTenantId option:selected').val() : tenantId,
	                recList: selList
	            } ;
	            // popup
	            argoPopupWindow('녹취권한요청', 'RecGrantReqPopF.do', '1064', '600');
            }
        });

		$("#btnReset").click(
				function() {

					$('#s_FindMarkKind option[value=""]').prop('selected', true);
					$('#s_FindCallKind option[value=""]').prop('selected', true);

					$("#s_FindUserNameText").val(''); //상담사
					$("#s_FindDnText").val(''); //내선
					$("#s_FindDnGubunText").val('');
					$("#s_FindCustNameText").val(''); //고객명
					$("#s_FindCustTelText").val(''); //전화번호
					$("#s_FindCustNoText").val(''); //고객번호
					$("#s_FindCallIdText").val(''); //콜아이디
					$("#s_FindFieldText").val(''); //추가검색

					$("#s_FindTranTelText").val('');
					
					$("#chkGetCallGroup").prop("checked", false);
					$("#chkListeningYn").prop("checked", false);
					$("#chkDownloadYn").prop("checked", false);
					switchRecGrant(false);
					
// 					$("#s_FindReasonText").val('');		//조회사유
					$('#s_FindField option[value=""]').prop('selected', true);

					argoCbCreate("s_FindTenantId", "comboBoxCode",
							"getTenantList", {}, {
								"selectIndex" : 0,
								"text" : '선택하세요!',
								"value" : ''
							});
					$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
					/* argoCbCreate("s_FindGroupId", "comboBoxCode",
							"getGroupList", {
								findTenantId : tenantId,
								userId : userId,
								controlAuth : controlAuth,
								grantId : grantId
							}, {
								"selectIndex" : 0,
								"text" : '선택하세요!',
								"value" : ''
							}); */
					/* argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupListByParentId", {tenantId: $('#s_FindTenantId').val() || tenantId}, {
						"selectIndex" : 0,
						"text" : '선택하세요!',
						"value" : ''
					});		 */
							
					//fnGroupCbChange("s_FindGroupId");
					
					argoSetValue("selDateTerm1", "T_0")
					/* argoSetDateTerm('selDateTerm1', {
						"targetObj" : "s_txtDate1",
						"selectValue" : "T_0"
					}, jData); */
					argoSetValue("s_RecFrmTm", "00:00:00");
					argoSetValue("s_RecEndTm", "23:59:59");
					argoSetValue("s_CallFrmTm", "00:00:00");
					argoSetValue("s_CallEndTm", "23:59:59");
					/* $('#selDateTerm1 option[value="M_1"]').prop('selected',
							true); */

					if (grantId == "GroupManager" || grantId == "Agent" || grantId == "Manager") {
						//$('#s_FindGroupId option[value="' + groupId + '_'+ depth + '"]').prop('selected', true);
						//argoCbCreate("s_FindUserId", "comboBoxCode", "getUserList", {findTenantId:tenantId, FindGroupId:groupId + '_' + depth}, {"selectIndex":0, "text":'선택하세요!', "value":''});

						if (grantId == "Agent") {
							$('#s_FindUserId option[value="' + userId + '"]').prop('selected', true);
						}
					}
				});
		/*2019-01-07 yoonys start*/
		$("#s_FindField").change(function() {
			var jbbCode = [ '01', '04', '05', '09', '10', '12',
					'13', '14', '60', '61', '62', '70', '80',
					'90', '91', '92', '93', '94', '95', '96',
					'97', '98', '99', '100', '101', '102',
					'103', '104', '105', '106', '107', '00' ];
			var jbbName = [ '비밀번호', '보안카드비밀번호', 'OTP비밀번호',
					'카드비밀번호', '계좌비밀번호', '주민등록번호(2회입력)',
					'비밀번호(2회입력)', '오토라이프 주민등록번호 입력', '욕설',
					'성희롱', '업무방해', '인증번호', '팩스번호', '개인정보동의',
					'휴대폰본인인증', '마케팅 동의', '출금 동의(신청)',
					'출금 동의(변경)', '약정 동의(멤버쉽론)', '약정 동의(뉴카드론)',
					'약정 동의(비대면대출)', '약정 동의(체인지업론)',
					'약정 동의(피플펀드론)', '자동이체 동의(신청)',
					'약정 동의(가계대출)', '타행계좌 출금동의', '오토론 개인정보동의',
					'오토론 약정동의' , '담보제공인 동의', '오토라이프 개인정보동의',
					'오토라이프 약정동의', '선택녹취' ];
			if ($('#s_FindField option:selected')[0].id == "custEtc6") {
				$("#s_FindFieldText").hide();
				$("#s_FindFieldText_jbbank").show();
				for (var jbbNum = 0; jbbNum < jbbCode.length; jbbNum++) {
					$("#s_FindFieldText_jbbank").append(
							$('<option>', {
								value : jbbCode[jbbNum],
								text : jbbName[jbbNum]
							}));
					
				}
				//break;
			} else {
				$("#s_FindFieldText").val('');
				$("#s_FindFieldText").show();
				$("#s_FindFieldText_jbbank").hide();
				$("#s_FindFieldText").focus();
			}
			//}
		});
		
		//[input]상담사 자동검색 - start
		var dataList = "";
		//var authRank = loginInfo.SVCCOMMONID.rows.authRank;
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
		
		
		/* $("#btnExcelInfoChange").click(function(){
			if(!custInfoAuth){
				alert('권한이 없는 상담사입니다.');
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

		('고객정보 수정', 'RecSearchExcelInfoPopF.do', '550', '300');
		}) */
	}

	var idxCustEtc = 19;    // TODO : 확인피리요

	function fnRecSearchReasonAddPop(){
		workPage = 1;
		
		
		// 체크되어있으면 조회사유 등록
    	var pCallbackFunctionNm = argoNullConvert("fnSearchListCnt();");
		var pTenantId = argoNullConvert(argoGetValue("s_FindTenantId"));
		var pDnNo = argoNullConvert(argoGetValue("s_FindDnText"));
		var pUserId = argoNullConvert(argoGetValue("s_FindUserNameText"));
		var pGroupId = argoNullConvert(argoGetValue("s_FindGroupId"));
		var pCustName = argoNullConvert(argoGetValue("s_FindCustNameText"));
		var pCustTel = argoNullConvert(argoGetValue("s_FindCustTelText"));
		var pCustNo = argoNullConvert(argoGetValue("s_FindCustNoText"));
		var pFindField = argoNullConvert(argoGetValue("s_FindField"));
		var pFindFieldText = argoNullConvert(argoGetValue("s_FindFieldText"));
		var pCallKind = argoNullConvert(argoGetValue("s_FindCallKind"));
		var pCustEtc9 = argoNullConvert(argoGetValue("s_FindMarkKind"));
		var pCallId = argoNullConvert(argoGetValue("s_FindCallIdText"));
		var pTranTel = argoNullConvert(argoGetValue("s_FindTranTelText"));
		var pFrmRecDate = argoNullConvert(argoGetValue("s_txtDate1_From"));
		var pFrmRecTm = argoNullConvert(argoGetValue("s_RecFrmTm"));
		var pToRecDate = argoNullConvert(argoGetValue("s_txtDate1_To"));
		var pToRecTm = argoNullConvert(argoGetValue("s_RecEndTm"));
		var pFrmCallTm = argoNullConvert(argoGetValue("s_CallFrmTm"));
		var pToCallTm = argoNullConvert(argoGetValue("s_CallEndTm"));
		var pSoliKind = argoNullConvert(argoGetValue("s_FindDnGubunText"));
		
		var pChkListeningYn = "";
		if(argoGetValue("s_DownloadListen") == "1"){
			pChkListeningYn = "Y";
		}
		
		var pChkDownloadYn = "";
		if(argoGetValue("s_DownloadListen") == "2"){
			pChkDownloadYn = "Y";
		}
		
		//var pChkListeningYn = argoNullConvert(argoGetValue("s_DownloadListen"));
		//var pChkDownloadYn = argoNullConvert(argoGetValue("chkDownloadYn"));
		var pMaskingYn = "1";
    	
		// 기타사유일 경우 팝업창 출력
    	if(argoGetValue("ip_ReasonCode") == "00000"){
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
    				pChkListeningYn : pChkListeningYn,
    				pChkDownloadYn : pChkDownloadYn,
    				pCallbackFunctionNm : pCallbackFunctionNm
    		};
     		argoPopupWindow('통화내역 조회사유 등록', 'RecSearchReasonPopAddF.do', '600', '300');
    	}else{
    		var param = {
   				pTenantId : pTenantId,
   				pDnNo : pDnNo,
   				pUserId : pUserId,
   				pGroupId : pGroupId,
   				pCustName : pCustName,
   				pCustTel : pCustTel,
   				pCustNo : pCustNo,
   				pFindField : pFindField,
   				pFindFieldText : pFindFieldText,
   				pCallKind : pCallKind,
   				pCustEtc9 : pCustEtc9,
   				pCallId : pCallId,
   				pTranTel : pTranTel,
   				pFrmRecDate : pFrmRecDate,
   				pFrmRecTm : pFrmRecTm,
   				pToRecDate : pToRecDate,
   				pToRecTm : pToRecTm,
   				pFrmCallTm : pFrmCallTm,
   				pToCallTm : pToCallTm,
   				pSoliKind : pSoliKind,
   				pChkListeningYn : pChkListeningYn,
   				pChkDownloadYn : pChkDownloadYn,
   				pReasonCode : argoGetValue("ip_ReasonCode")
    		} 
    		fnSaveRecSearchReason(param);
    	}
	    
	}
	
	function fnSaveRecSearchReason(param) {
		if ($("#ip_ReasonCode").val() == "") {
			argoAlert("조회사유를 선택해 주세요.");
			return;
		}
		var multiService = new argoMultiService(fnCallbackRecSearchReasonSave);
		multiService.argoInsert("recSearch", "SP_REC_SEARCH_REASON_SAVE","__", param);
		multiService.action();
	}
	
	function fnCallbackRecSearchReasonSave(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				fnProgressViewSearch(function(){fnSearchListCnt();});
			}
		} catch (e) {
			console.log(e);
		}
	}
	
	function fnProgressViewSearch(callback) {
		// 화면에 로딩 마스크를 표시하는 코드
		// 이 함수 내에서 비동기 작업이 수행됩니다.
		LoadingWithMask();
		
		// 비동기 작업 완료 후, fnSearchListCnt 함수 호출
		setTimeout(function() {
				// 비동기 작업 완료 후에 fnSearchListCnt 함수 호출
				//parent.fnSearchListCnt();
				callback();
				setTimeout(function() {
					// 비동기 작업 완료 후에 fnSearchListCnt 함수 호출
					//parent.fnSearchListCnt();
					argoPopupClose();
			}, 0);
		}, 0); // 대기 시간을 0으로 설정
	}
	
	

	function fnInitGrid() {

		$('#gridList').w2grid(
				{
					name : 'grid',
					//selectType : 'column',
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
							selectedText += w2ui['grid'].getCellValue(recid, arrSelected[index].column);
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
					    var record = this.get(event.recid);
					    if (record.listeningYn != 'Y' && grantId != 'SuperAdmin') {
					        argoAlert('청취권한이 없습니다.');
					        return;
					    }
						
						if (event.recid >= 0) {
							if(recAuth == "Y") {
								fnAuthRecPlay(event.recid);
							}
							else{
								/*if(record.mediaScrCd == '1'){
									fnRecFilePlay(event.recid, true);
								}else{
									fnRecFilePlay(event.recid);
								} */						
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
					onChange: function (event) {
			        	var record = this.get(event.recid);
			        	var key = Object.keys(record);
			        	if(key[event.column] == "listeningYnView"){
			        		event.preventDefault();
			        	}
			        },
					onSelect : function(event) {
			        //	if(w2ui.grid.columns[event.column].field == "recDate"){
			        //		event.preventDefault();
			        //	}
					},
					columns : [
						{
							field : 'recid',
							caption : 'recid',
							size : '0px',
							attr : 'align=center'
						}, {
							field : 'recKey',
							caption : 'recKey',
							size : '0px',
							attr : 'align=center'
						}
						
						, {
							field : 'mediaScr',
							caption : '스크린',
							size : '90px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}
						,{field : 'listeningYnView', caption : '청취권한', editable:{ type:"checkbox" }, size : '100px', frozen : true}
						, {
							field : 'recDate',
							caption : '통화일자',
							size : '90px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, {
							field : 'recTime',
							caption : '녹취시간',
							size : '75px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, {
							field : 'endTime',
							caption : '통화시간',
							size : '80px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, {
							field : 'groupName',
							caption : '그룹명',
							size : '150px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, { 
							field : 'userId',
							caption : '상담사ID',
							size : '80px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, {
							field : 'userName',
							caption : '상담사명',
							size : '80px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, {
							field : 'custTel',
							caption : '전화번호',
							size : '200px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, {
							field : 'custName',
							caption : '고객명',
							size : '80px',
							sortable: true,
							attr : 'align=center',
							frozen : true
						}, 
						/*여기가 통화시간 순서였던 자리  */
						
						{
							field : 'dnNo',
							caption : '내선',
							size : '80px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'dnGubun',
							caption : '내선구분',
							size : '80px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'dnGubunId',
							caption : '내선구분아이디',
							size : '80px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'callKind',
							caption : '통화구분',
							size : '80px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custNo',
							caption : '고객번호',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'holdCnt',
							caption : '보류횟수',
							size : '80px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'tranTel',
							caption : '호전환번호',
							size : '80px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'holdTime',
							caption : '보류시간',
							size : '80px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc1',
							caption : 'custEtc1',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc2',
							caption : 'custEtc2',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc3',
							caption : 'custEtc3',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc4',
							caption : 'custEtc4',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc5',
							caption : 'custEtc5',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc6',
							caption : 'custEtc6',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc7',
							caption : 'custEtc7',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'custEtc8',
							caption : 'custEtc8',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}, {
							field : 'callId',
							caption : '콜아이디',
							size : '320px',
							sortable: true,
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
						}, 
						/*
							2024.03.07 jslee
							fileName 두 번 선언해서 제거함
						*/ 
						/* {
							field : 'fileName',
							caption : '콜아이디',
							size : '0px',
							attr : 'align=left'
						},  */
						{
							field : 'custEtc9',
							caption : 'custEtc9',
							size : '150px',
							sortable: true,
							attr : 'align=left'
						},{
							field : 'custEtc10',
							caption : '마킹메모',
							size : '150px',
							sortable: true,
							attr : 'align=left'
						}, {
							field : 'groupId',
							caption : '그룹ID',
							size : '150px',
							sortable: true,
							attr : 'align=left'
						}, {
							field : 'tenantId',
							caption : '태넌트ID',
							size : '150px',
							sortable: true,
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
							caption : '상담사IP',
							size : '0px',
							attr : 'align=left'
						},{
							/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) START */
							field : 'mediaScrOrg',
							caption : '스크린여부Org',
							size : '0px',
							attr : 'align=left'
						},{
							field : 'mediaVoice',
							caption : '음성녹음여부',
							size : '0px',
							attr : 'align=left'
						},{
							field : 'uploadCntScr',
							caption : '스크린업로드완료개수',
							size : '0px',
							attr : 'align=left'
						},{
							field : 'uploadCntVoice',
							caption : '음성업로드완료개수',
							size : '0px',
							attr : 'align=left'
						},{
							field : 'mediaKind',
							caption : '종류',
							size : '0px',
							attr : 'align=left'
						},{
							field : 'fileName',
							caption : '파일명',
							size : '0px',
							attr : 'align=left'
							/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) END */
						},
						{field : 'listeningYn'  ,caption : 'listeningYn',size : '0px'},
						{field : 'downloadYn'   ,caption : 'downloadYn' ,size : '0px'},
						{field : 'recTime2'   ,caption : 'recTime2' ,size : '0px'},
						{field : 'callId2'   ,caption : 'callId2' ,size : '50px'},
						{
							field : 'fullCustName',
							caption : 'fullCustName',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						},
						{
							field : 'fullCustTel',
							caption : 'fullCustTel',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						},
						{
							field : 'fullCustNo',
							caption : 'fullCustNo',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						},
						{
							field : 'maskingYn',
							caption : 'maskingYn',
							size : '100px',
							sortable: true,
							attr : 'align=center'
						}
					],
					records : dataArray
				});

		
		
		w2ui['grid'].hideColumn( 'recid', 'recKey', 'custEtc1',
				'custEtc2', 'custEtc3', 'custEtc4', 'custEtc5', 'custEtc6',
				'custEtc7', 'custEtc8','custEtc9', 'recDateOrg', 'recTimeOrg','groupId','tenantId',
				'endTimeOrg', 'fileName', 'mfuIp','mediaScrCd','encKey','phoneIp','dnGubunId'
				/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) START */
				, 'mediaScrOrg', 'mediaVoice', 'uploadCntScr', 'uploadCntVoice', 'mediaKind', /* 'fileName', */
				/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) END */
				'listeningYn', 'downloadYn', 'recTime2', 'callId2', 'fullCustTel', 'fullCustNo', 'maskingYn', 'fullCustName'
        );
		if (vlcOPT.VLC_SCREEN_LISTEN == "0") {
			w2ui['grid'].hideColumn('mediaScr');
		}

		if (vlcOPT.VLC_REC_API_USE != "1") {
			SetGridHideColumn(tenantId);
		}
		//$('#gridList').hide();
		$('#paging').hide();
		
		
		//jslee
		//w2ui.grid.selectType = "cell";
		//w2ui.grid.reset();
	}

	var strOption = "";

	function SetGridHideColumn(tenantId) {
		w2ui['grid'].hideColumn('recid', 'recKey', 'custEtc1', 'custEtc2',
				'custEtc3', 'custEtc4', 'custEtc5', 'custEtc6', 'custEtc7',
				'custEtc8');

		argoJsonSearchList('recSearch', 'getRecSearchFiledList', 's_', {"findTenantId" : tenantId},function(data, textStatus, jqXHR) {
            try {
                if (data.isOk()) {
                    w2ui['grid'].showColumn();
                    if (data.getRows() != "") {
                        var colName;
                        var colTitle;
                        var colIndex;

                        $.each(data.getRows(), function(index, row) {
                            colName = "custEtc" + row.fieldId;
                            colIndex = Number(row.fieldId) + idxCustEtc;
                            colTitle = row.fieldName;
                            w2ui['grid'].showColumn(colName);
                            w2ui['grid'].columns[colIndex].caption = colTitle;
                            strOption += '<option id="' + colName + '" value="' + colName + '">' + colTitle + '</option>';
                        });
                        if ($('#s_FindField').find("option").length < 2) {
                            $('#s_FindField').append(strOption);
                        }
                    }
                }
            } catch (e) {
                console.log(e);
            }

        });
		
	}
	//20180801 yoonys start
	function setReason() {
		argoJsonSearchList(
				'recSearch',
				'getRecSearchReasonList',
				's_',
				{
					"findTenantId" : tenantId
				},
				function(data2, textStatus, jqXHR) {
					try {
						var strOption2 = "";
						if (data2.isOk()) {
							if (data2.getRows() != "") {
								var colName;
								var colTitle;
								var colIndex;

								$.each(data2.getRows(), function(index, row) {
                                    colName = row.fieldId;
                                    colTitle = row.fieldName;
                                    var colTitle2 = colTitle.split("_")[1];
                                    strOption2 += '<option id="' + colName + '" value="' + colTitle + '">' + colTitle + '</option>';
                                });
								if ($('#s_FindReason').find("option").length < 2) {
									$('#s_FindReason').append(strOption2);
								}
								var revalue = this.value;
								if (revalue != "90_기타(직접입력)") {
									$("#s_FindReasonText").attr("disabled",true);
									$("#s_FindReasonText").val(colTitle2);
								} else {
									$("#s_FindReasonText").attr("disabled",false);
									$("#s_FindReasonText").val("");
								}
							}
						}
					} catch (e) {
						console.log(e);
					}
				});
	}
	//20180801 yoonys end


    /**
     * 조회조건
     */
	function saveSearchCond() {
	    var searchCond = {};
	    
        $('#searchPanel').find(':input').each(function() {
        	/* if(this.id == "s_FindGroupId"){
    	    	debugger;	
    	    } */
        	
        	
        	if (this.id.startsWith('s_') || this.id.startsWith('sel')) {
                searchCond[this.id] = this.value;
            }
            else if (this.id.startsWith('chk')) {
                searchCond[this.id] = $("#"+ this.id).is(':checked');
            }
        });

        searchCond['div_tenant']= $('#div_tenant').css('display');
        searchCond['div_user']  = $('#div_user').css('display');
        searchCond['div_cust']  = $('#div_cust').css('display');
        searchCond['div_call']  = $('#div_call').css('display');
        searchCond['strOption']  = strOption;
        searchCond['s_FindFieldText'] = $('#s_FindField').val() == "custEtc6" ? $('#s_FindFieldText_jbbank').val() : $('#s_FindFieldText').val();

        parent.$("#RecSearchF").val(JSON.stringify(searchCond));
	}

    /**
     * 조회 유효성 검사
     */
	function isValidSearch() {
	    /* 암호화 파라미터 숨김처리 */
        if (argoGetValue("#s_FindCustNameText") == "" && argoGetValue("#s_FindCustTelText") == "" && argoGetValue("#s_FindCustNoText") == "") {
            var diffDate = fnDiffDate(argoGetValue("#s_txtDate1_From"), argoGetValue("#s_txtDate1_To"));
            var maxTerm = argoGetSearchMaxTerm(argoGetValue("#s_txtDate1_To"), jData);
            if (diffDate > 31) {
                argoAlert("검색조건(고객명/전화번호/고객번호) 미입력시 31일 기간만 조회가 가능합니다.");
                return false;
            }
        }
        return true;
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
    
	function fnSearchListCnt() {
		//debugger;
		
		//w2ui.grid.lock('조회중', true);
		//debugger;
		//console.log("LoadingWithMask() 돌기전");
		//LoadingWithMask();
		$("#s_FindDnText").val(jQuery.trim($("#s_FindDnText").val())); //내선 공백제거
		$("#s_FindUserNameText").val(
				jQuery.trim($("#s_FindUserNameText").val())); //상담사 공백제거
		$("#s_FindCustNameText").val( jQuery.trim($("#s_FindCustNameText").val())); //고객명 공백제거
		$("#s_FindCustTelText").val(jQuery.trim($("#s_FindCustTelText").val())); //전화번호 공백제거
		$("#s_FindCustNoText").val(jQuery.trim($("#s_FindCustNoText").val())); //고객번호 공백제거

		//2018-12-10 yoonys
		//feat. 전북은행
		//특정상담사가 원칙적으로 듣지 못하는 통화를 듣는 권한부여기능이 추가됨으로써
		//일반청취 와 일반청취 UNION 권한받은 콜에대한 쿼리를 다르게 가져간다. 
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
		
		
		var listenYn = "";
		/* if(argoGetValue("s_DownloadListen") == "1" && grantId != "SuperAdmin"){
			listenYn = "Y";
		} */
		if(argoGetValue("s_DownloadListen") == "1"){
			listenYn = "Y";
		}
		
		var downloadYn = "";
		/* if(argoGetValue("s_DownloadListen") == "2" && grantId != "SuperAdmin"){
			downloadYn = "Y";
		} */
		if(argoGetValue("s_DownloadListen") == "2"){
			downloadYn = "Y";
		}
		
		
		callbackAfterSearchCondition = {
			findTenantId : argoGetValue("s_FindTenantId"),
			findTenantIdText : argoGetValue("s_FindTenantIdText"),
			FindSearchVisible : argoGetValue("s_FindSearchVisible"),
			FindDnText : argoGetValue("s_FindDnText"),
			FindDnGubunText : argoGetValue("s_FindDnGubunText"),
			FindUserNameText : argoGetValue("s_FindUserNameText"),
			FindGroupId : argoGetValue("s_FindGroupId"),
			FindCustNameText : argoGetValue("s_FindCustNameText"),
			FindCustNameText_hidden : argoGetValue("s_FindCustNameText_hidden"),
			FindCustTelText : argoGetValue("s_FindCustTelText"),
			FindCustTelText_hidden : argoGetValue("s_FindCustTelText_hidden"),
			FindCustNoText : argoGetValue("s_FindCustNoText"),
			FindField : argoGetValue("s_FindField"),
			FindFieldText : argoGetValue("s_FindFieldText"),
			FindFieldText_jbbank : argoNullConvert($("#FindFieldText_jbbank").val()),
			FindCallKind : argoGetValue("s_FindCallKind"),
			FindMarkKind : argoGetValue("s_FindMarkKind"),
			FindCallIdText : argoGetValue("s_FindCallIdText"),
			FindTranTelText : argoGetValue("s_FindTranTelText"),
			txtDate1_From : argoGetValue("s_txtDate1_From").replace(/-/g, ""),
			RecFrmTm : argoGetValue("s_RecFrmTm").replace(/:/g, ""),
			txtDate1_To : argoGetValue("s_txtDate1_To").replace(/-/g, ""),
			RecEndTm : argoGetValue("s_RecEndTm").replace(/:/g, ""),
			CallFrmTm : argoGetValue("s_CallFrmTm").replace(/:/g, ""),
			CallEndTm : argoGetValue("s_CallEndTm").replace(/:/g, ""),
			SearchCount : argoGetValue("s_SearchCount"),
			userId : userId,
			controlAuthGroup : ControlAuthGroup,
// 			controlAuth : controlAuth,
			grantId : grantId,
			groupId : groupId,
			findGroupIdnew : fGN,
			findTS : termS,
			
			//listeningYn : $("#chkListeningYn").is(':checked') && grantId != 'SuperAdmin' ? "Y" : "",
		    //downloadYn  : $("#chkDownloadYn").is(':checked') && grantId != 'SuperAdmin' ? "Y" : "",
		    listeningYn : listenYn,
		    downloadYn  : downloadYn,
		    tenantId : tenantId,
		    callGroupYn  : $("#chkGetCallGroup").is(':checked')  ? "Y" : "",
		    //마스킹여부
		    //기타사유일 경우에만 마스킹 해제한다.
		   	//maskingYn	 : $("#ip_ReasonRegistrationYn").is(":checked") ? "N" : "Y",
		    maskingYn	 : argoGetValue("ip_ReasonCode")=="00000" ? "N" : "Y",
		   	searchGroupName : searchGroupName,
		   	controlAuth : controlAuth
		}
		
		// 페이지 리로드시 기존 파라미터 세팅
		saveSearchCond();
		setSearchCond('callbackAfterSearchCondition', callbackAfterSearchCondition);
		
        argoJsonSearchOne('recSearch', 'getRecSearchListCnt', '', callbackAfterSearchCondition, function(data, textStatus, jqXHR) {
            try {
                if (data.isOk()) {
                	//debugger;
                	//LoadingWithMask();
                    var totalData = data.getRows()['cnt'];
                    var searchCnt = argoGetValue('s_SearchCount');
                    paging(totalData, workPage, searchCnt, "2");

                    setSearchCond("totalData", totalData);
                    setSearchCond("searchCnt", searchCnt);

                    $("#totCount").text(totalData);

                    if (totalData == 0) {
                        argoAlert('조회 결과가 없습니다.');
                        closeLoadingWithMask();
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

			argoConfirm('선택한 통화내역 ' + arrChecked.length + '건을 마킹등록 하시겠습니까?', function() {
                var markArray = new Array();
                var record = {};
                $.each(arrChecked, function(index, value) {
                    record = w2ui['grid'].get(value);
                    markArray.push({
                        "recKey"    : record.recKey,
                        "callId"    : record.callId,
                        "fmtRecDate": record.recDate.replace(/-/gi, ''), /** (2023.08.18) TB_REC_FILE 테이블 마킹 등록 작업 (HAGUANGHO) */
                    });
                });

                gPopupOptions = {
                    cudMode : "I",
                    markArray : markArray,
                    tenantId :  $('#s_FindTenantId option:selected').val()
                };
                argoPopupWindow('마킹등록', 'RecSearchMarkF.do', '460', '620');
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
						
						/** (2023.08.18) TB_REC_FILE 테이블 마킹 삭제 작업 (HAGUANGHO) START */
						var fmtRecDate = '';
						/** (2023.08.18) TB_REC_FILE 테이블 마킹 삭제 작업 (HAGUANGHO) END */

						var multiService = new argoMultiService(fnCallbackSave);

						$.each(arrChecked, function(index, value) {
							recKey = w2ui['grid'].get(value).recKey;
							callId = w2ui['grid'].get(value).callId;
							recDate = w2ui['grid'].get(value).recDate.replace(/-/gi, '');
							userName = w2ui['grid'].get(value).userName;
							fmtRecDate = w2ui['grid'].get(value).recDate.replace(/-/gi, '');

							var param = {
								"recKey" : recKey,
								"callId" : callId,
								"recDate" : recDate,
								"userName" : userName,
								"fmtRecDate" : fmtRecDate, /** (2023.08.18) TB_REC_FILE 테이블 마킹 삭제 작업 (HAGUANGHO) */
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
				//fnSearchListCnt();
				fnSearchListCntAfterCallback();
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
			var sampleAddFlag = true;
			$.each(arrChecked, function(index, value) {
				var selectRecKey = w2ui['grid'].get(value).recKey;
				var fileNm       = argoNullConvert(w2ui['grid'].get(value).fileName);

				if(fileNm == ""){
					sampleAddFlag = false;
					return;
				}
				//recKey = w2ui['grid'].get(value).recKey;
				
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


			if(sampleAddFlag == false){
				sampleAddFlag = true;
				argoAlert("선택한 통화이력에 파일이 존재하지 않아 등록이 불가합니다.");
				return;
			}


			argoConfirm('선택한 통화내역 ' + arrChecked.length + '건을 샘플콜등록 하시겠습니까?',
					function() {
						var recKey = "";
						var callId = "";
						
                        /** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) START */
                        var custTel          = "";
                        var dnNo             = "";
                        var endTime          = "";
                        var mediaScr         = "";
                        var mediaVoice       = "";
                        var mfuIp            = "";
                        var phoneIp          = "";
                        var recDate          = "";
                        var recTime          = "";
                        var userId           = "";
                        var uploadCntScr     = "";
                        var uploadCntVoice   = "";
                        var mediaKind        = "";
                        var fileName         = "";
                        /** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) END */

						markArray = new Array();
						$.each(arrChecked, function(index, value) {
                            recKey 				= argoNullConvert(w2ui['grid'].get(value).recKey);
							callId 				= argoNullConvert(w2ui['grid'].get(value).callId);
                            custTel             = argoNullConvert(w2ui['grid'].get(value).custTel);
                            dnNo                = argoNullConvert(w2ui['grid'].get(value).dnNo);
                            endTime             = argoNullConvert(w2ui['grid'].get(value).endTimeOrg);
                            mediaScr            = argoNullConvert(w2ui['grid'].get(value).mediaScrOrg);
                            mediaVoice          = argoNullConvert(w2ui['grid'].get(value).mediaVoice);
                            mfuIp               = argoNullConvert(w2ui['grid'].get(value).mfuIp);
                            phoneIp             = argoNullConvert(w2ui['grid'].get(value).phoneIp);
                            recDate             = argoNullConvert(w2ui['grid'].get(value).recDateOrg);
                            recTime             = argoNullConvert(w2ui['grid'].get(value).recTimeOrg);
                            userId              = argoNullConvert(w2ui['grid'].get(value).userId);
                            uploadCntScr        = argoNullConvert(w2ui['grid'].get(value).uploadCntScr);
                            uploadCntVoice      = argoNullConvert(w2ui['grid'].get(value).uploadCntVoice);
                            mediaKind           = argoNullConvert(w2ui['grid'].get(value).mediaKind)==""?"0":argoNullConvert(w2ui['grid'].get(value).mediaKind);
                            fileName            = argoNullConvert(w2ui['grid'].get(value).fileName);

							gObject = {
								"recKey"         : recKey,
								"callId"         : callId,
								/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) START */
								"custTel"        : custTel,
								"dnNo"           : dnNo,
								"endTime"        : endTime,
								"mediaScr"       : mediaScr,
								"mediaVoice"     : mediaVoice,
								"mfuIp"          : mfuIp,
								"phoneIp"        : phoneIp,
								"recTime"        : recDate + recTime,
								"userId"         : userId,
								"uploadCntScr"   : uploadCntScr,
								"uploadCntVoice" : uploadCntVoice,
								"mediaKind"      : mediaKind,
								"fileName"       : fileName
								/** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) END */
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
        var record = {};
		$.each(arrChecked, function(row, colIndex) {
			var recItem = new Object();

			//colIndex는 json 객체이므로 index property를 불러와야 함.
			record = w2ui['grid'].get(colIndex);
			var custName = record.custName;
			var telNo = record.custTel;
			logListeningKey = record.recDate + record.recTime;
			logUserId = record.userId;
			logRecKey = record.recKey;

			var callId = record.callId;
			var recTime = record.recDate + " " + record.recTime;
			
			var userName = record.userName;
			var custTel = record.custTel;
			var endTime = record.endTimeOrg;
			var fmtRecTime = logListeningKey = record.recDate + " " + record.recTime;

			//청취로그  start
			var logDnNo = record.dnNo;
			var tenantId2 = $('#s_FindTenantId option:selected').val();
			
			var rowMfsIp = record.mfuIp;

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
				recItem.ip = (argoNullConvert(rowMfsIp) == "" ? mfsIp : rowMfsIp);
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
		//gPopupOptions.grid = w2ui.grid;
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


	function fnRecFilePlay(index,scrType) {
		
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
		}
		else {
			index = new Array(index);			
		}
		
		
		//23.07.14 통화내역조회 내 일괄재생 시 날짜,시간 ASC (오래된 순) -- start
		if (index.length > 1) {
			arrChecked = new Array();
			arrRecDate = new Array();
			arrSortIndex = new Array();
			
			arrChecked = index;
			
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
			
			$.each(arrRecDate, function(arrIndex) {
				arrSortIndex.push(arrRecDate[arrIndex].recIndex);
			});
			
			index = arrSortIndex;
		}
		//23.07.14 통화내역조회 내 일괄재생 시 날짜,시간 ASC (오래된 순) -- end
		
		if (isUseRecReason == "1") {
			gPopupOptions = {pRowIndex: index, pScrType: scrType, "cudMode": "0"};
	 		argoPopupWindow('청취사유등록', 'RecSearchRecLogPopAddF.do', '470', '370');	
		}
		else {
			fnRecFilePlayCallBack(index, scrType);
		}
	}
	
	//scrType==true:스크린 || scrType===undefined:voice녹취
	function fnRecFilePlayCallBack(index, scrType) {
	    var record = {};
		var FileList;
		var tenantId2 = $('#s_FindTenantId option:selected').val();
		//var tenantId2 = "";
		var mediaScr = "";
		var logUserId = "";
		var logDnNo = "";
		var logRecKey = "";
		
		// web재생
		if (playerKind == null || playerKind == "0") {
			tmpSelection = index;
			index = index[0];
			record = w2ui['grid'].get(index);
			var callId = record.callId;
			var recTime = record.recDate + " "+ record.recTime;
			var custName = record.custName;
			var fmtRecTime = record.recDate + " "+ record.recTime;
			var telNo = record.custTel;
			custName = VLC_StringProc_NVL(custName, "정보없음");
			var callPlayRecord = playRecord.bind(null, w2ui['grid'], tmpSelection);
			
			velocePopupWindow('청취(고객명 : ' + custName + ')', 'about:blank',
					'594', '386', '', 'sttPlay'
					, callPlayRecord, "fnSelectedRow");
			
			if (isUseRecReason == "0") {
				fnRecIsNotUseRecReason(tmpSelection,0);
			}
			
			voicePlayYn = "N";
			return;
		}
		
		var url;
		var iCmd;
		var mediaScrCd = "";
		var mediaKind = "1";
		var ws_data = "";
		var ws;
		var arrChecked;
		var nSelectCount = 0;
		var secValidate = "0";

		if (scrType){
			mediaKind = "2";			
		}
		
		if (index >= 0) {
			mediaScrCd =  w2ui['grid'].get(index).mfuIp;
		}
		// 단일재생||스크린재생 
		if (index >= 0 && mediaScrCd != "1") {
			record = w2ui['grid'].get(index[0]);
			
			if (record.listeningYn != 'Y') {
		        argoAlert('청취권한이 없습니다.');
		        voicePlayYn = "N";
		        return;
		    }
			
			var callingSec = argoTimeToSeconds(record.endTime);
			if(callingSec <= 2){
				secValidate = "1";
				voicePlayYn = "N";
				argoAlert("통화시간이 2초 이내의 녹취 이력은 청취할 수 없습니다.");
				return;
			}
			
			iCmd = "11";
			w2ui['grid'].select(index);
			tmpSelection = index;
			arrChecked = new Array(index);
			
			
			if(argoNullConvert(record.mfuIp) != ""){
				mfsIp = record.mfuIp;
			}
			
			ws_data="cmd=" + iCmd + "&mfu_ip=" + mfsIp + "&mfu_port=7200&tenant_id=" + record.tenantId
			+ "&user_id=" + record.userId
			+ "&call_id=" + record.callId
			+ "&media_kind=" + mediaKind;
			
			console.log("ws_data single : " + ws_data);
		}
		else { //일괄재생 || 스크린 재생
			iCmd = "12";
			try {
				
				//스크린 보이스
				var scrSrc = (scrType == true ? "|screen|" : "|voice|" );				
				arrChecked = index;				
								
				FileList = "";
				
				$.each(arrChecked, function(index, colIndex) {
				    record = w2ui['grid'].get(colIndex);
				    
				    var callingSec = argoTimeToSeconds(record.endTime);
					if(callingSec <= 2){
						secValidate = "1";
						voicePlayYn = "N";
						argoAlert("통화시간이 2초 이내의 녹취 이력은 청취할 수 없습니다.");
						return;
					}
				    
				    var agentMfuIp = argoNullConvert(record.mfuIp) == "" ? mfsIp : record.mfuIp;
					var paramUserId = record.userId == "" ? "btadmin" : record.userId;
					FileList += agentMfuIp + '|7200|'	+ record.recDateOrg
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
				
				console.log("ws_data multi : " + ws_data);
				
			} catch (e) {
				console.log(e);
			};
		}
		
		
		if(secValidate == "0"){
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
				
				voicePlayYn = "N"
				console.log(e);
				
			};	
			return;
		}
		
	}
	
	// logRealtimeFlag 0=일반청취 / 1=실시간감청 / 2=파일변환 / 3=상담APP / 4=샘플콜
	function fnRecIsNotUseRecReason(indexs, logRealtimeFlag) {
	    var record = {};
		for(var i=0; i<indexs.length; i++) {
		    record = w2ui['grid'].get(i);
			var index = indexs[i];

			argoJsonUpdate("recInfo", "setRecLogInsert", "ip_", {
				"tenantId"      : tenantId,
				"workerId"      : userId,
				"listeningKey"  : getTimeStamp2() + setZeroNumFn(index),
				"workerIp"      : workIp,
				"userId"        : record.userId,
				"dnNo"          : record.dnNo,
				"userIp"        : record.phoneIp ,
				"recTime"       : record.recDate + record.recTime,
				"realtimeFlag"  : logRealtimeFlag,
				"recKey"        : record.recKey
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
			// Delete the temporary link.
			a.parentNode.removeChild(a);
			// Download the next file with a small timeout. The timeout is necessary
			// for IE, which will otherwise only download the first file.
			setTimeout(function() {
				download_next(i + 1);
			}, 1500);
		}
		// Initiate the first download.
		download_next(0);

		return false;
	}
	
	function fnCbEncKey(callId){
		var param = {"callId":callId};		
		var rsEncKey = "";		
		$.ajax({
			url  : gGlobal.ROOT_PATH + "/RecSearch/fnCbEncKeyF.do",
			type : "POST",
			data : param,
			async : false,
			dataType : "json",
			success : function(data) {
				console.log(data);
			},
			error : function(xhr, status, error) {
				console.log("error");
				$("#result").val(JSON.stringify(status, null, '\t') + "\r\n");
			}
		});	
		return rsEncKey;
	}
	

	function fnWavConv(index){
		index = w2ui['grid'].getSelection();
		var secValidate = "0";
		
		if (index.length == 0) {
			argoAlert("한 개 이상의 녹취를 선택해주세요.");				
			return;
		}
		
		$.each(index, function(idx, value){
		    console.log(value);
		    var callingSec = argoTimeToSeconds(w2ui["grid"].get(value).endTime);
		    if(callingSec <= 2){
				secValidate = "1";
				argoAlert("통화시간이 3초 이상인 녹취 이력만 선택해 주세요.");
				return;
			}
		});
		
		if(secValidate == "0"){
			if(isUseRecReason == "1"){
				gPopupOptions = {pRowIndex:index,"cudMode":"2"};   	
		 		argoPopupWindow('파일변환로그등록', 'RecSearchRecLogPopAddF.do', '470', '370');	
			}else{
				fnWavConvCallBack(index);
			}
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
			var record = {};
			for (var convCnt = 0; convCnt < wavArray.length; convCnt++) {
			    record = w2ui['grid'].get(wavArray[convCnt]);
				var pUserId = record.userId;
				var pDnNo = record.dnNo;
				var pCallID = record.callId;

                //소스추가 start toss core
				var resultFileName = record.recDate.replaceAll("-","") +"_";
				resultFileName += record.recTime.replaceAll(":","") +"_";
				resultFileName += (record.custNo || "") +"_";
				resultFileName += (record.userName || "") +"_";
				resultFileName += record.dnNo;
                //소스추가 end

				var protocol = <%= isHttps %> ? "https://" : "http://";
				var port = <%= isHttps %> ? "7220" : "7210";
				var url = protocol + mfsIp + ":" + port + "/filedown/" + pDnNo
						+ "/" + userId + "/" + pCallID + "/" + resultFileName
						+ ".mp3";
				urls.push(url);

				workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
						+ ' | GrantId:' + grantId + '] 파일 변환';

				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
					tenantId : tenantId,
					userId : userId,
					actionClass : "action_class",
					actionCode : "W",
					workIp : workIp,
					workMenu : workMenu,
					workLog : workLog
				});
			}

			if (isUseRecReason == "0") {
				fnRecIsNotUseRecReason(wavArray, 2);
			}

			fnWavDownWeb(urls);
		} catch (e) {
			console.log(e);
		}
		;
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

	function fn_showSpan(obj) {

		if (obj.checked) {
			$("#groupMultiSelect").removeAttr("hidden");
			$("#groupSingSelect").attr("hidden", "hidden");
		} else {
			$("#groupSingSelect").removeAttr("hidden");
			$("#groupMultiSelect").attr("hidden", "hidden");
		};

	}

	//now
	function fn_scrPopup(colIndex) {
		if (colIndex < 0) {
			colIndex = w2ui['grid'].getSelection();
			if (colIndex.length == 0) {
				argoAlert("한 개 이상의 녹취를 선택해주세요.");
				return;
			}
		} else {
			colIndex = new Array(String(colIndex));
		}

		if (isUseRecReason == "1") {
			gPopupOptions = {
				pRowIndex : colIndex,
				"cudMode" : "01"
			};
			argoPopupWindow('청취사유등록', 'RecSearchRecLogPopAddF.do', '470', '370');
		} else {
			fn_scrPopupCallBack(colIndex);
		}
	}

	function fn_scrPopupCallBack(colIndex) {
		var ci = colIndex[0];

		var rowMfuIp = $(w2ui['grid'].get(ci)).attr("mfuIp");
		var mfuIp = (argoNullConvert(rowMfuIp) == "" ? mfsIp : rowMfuIp);
		var port = <%=isHttps%> ? 7220 : 7210;
		var dnNo = $(w2ui['grid'].get(ci)).attr("dnNo");
		var userId = userId;
		var callId = $(w2ui['grid'].get(ci)).attr("callId");

		var scrForm = document.getElementById("scr_form");
		if (scrForm == null) {
			scrForm = $('<form></form>');
			scrForm.attr("id", "scr_form");
			scrForm.attr("method", "post");
			scrForm.attr("target", "scrPlayPop");
			scrForm.attr("action", "STTPlayscreenF.do");

			scrForm.append($("<input/>", {
				type : "hidden",
				id : "mfuIp",
				Name : "mfuIp",
				value : mfuIp
			}));
			scrForm.append($("<input/>", {
				type : "hidden",
				id : "mfuPort",
				Name : "mfuPort",
				value : port
			}));
			scrForm.append($("<input/>", {
				type : "hidden",
				id : "dnNo",
				Name : "dnNo",
				value : dnNo
			}));
			scrForm.append($("<input/>", {
				type : "hidden",
				id : "userId",
				Name : "userId",
				value : userId
			}));
			scrForm.append($("<input/>", {
				type : "hidden",
				id : "callId",
				Name : "callId",
				value : callId
			}));

			scrForm.appendTo("body");
		}

		window .open("", "scrPlayPop", "location=no, height=700, width=1000, scrollbars=yes, status=no");

		scrForm.target = "scrPlayPop";
		scrForm.submit();
		scrForm.remove();

		//청취로그  start
		if (isUseRecReason == "0") {
			fnRecIsNotUseRecReason(colIndex, "01");
		}
	}

	function dnExcelSampleDownload() {
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
		var param = serializeFormNoService("s_") + "&userId=" + userId
				+ "&controlAuthGroup=" + ControlAuthGroup + "&controlAuth="
				+ controlAuth + "&grantId=" + grantId + "&groupId=" + groupId
				+ "&findGroupIdnew=" + fGN + "&findTS=" + termS

		var actionUrl = gGlobal.ROOT_PATH + "/RecSearch/DataExcelExportF.do?"
				+ param + "&excelImSvcName=recSearch"
				+ "&excelImMethodName=getRecSearchList&disInsColNum=0";

		var excelFileName = "통화내역조회";
		var colKey = [ 'recDate', 'recTime', 'groupName', 'userId', 'userName',
				'dnNo', 'endTime', 'callKind', 'custTel', 'custName', 'custNo',
				'callId', 'hlod', 'tranTel' ];
		var calVal = [ '통화일자', '통화일자', '그룹명', '상담사ID', '상담사명', '내선', '통화',
				'구분', '전화번호', '고객명', '고객번호', '콜아이디', '보류회수', '호전화' ];

		gPopupOptions = {
			pExcelUrl : actionUrl,
			pColKey : colKey,
			pColVal : calVal,
			pExcelFileName : excelFileName
		};
		argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportJavaF.do', '150', '40');
		//excel export end 
	}


	function fnSearchListCntAfterCallback() {
        argoJsonSearchOne('recSearch', 'getRecSearchListCnt', '_', callbackAfterSearchCondition, function(data, textStatus, jqXHR) {
            try {
                if (data.isOk()) {
                    var totalData = data.getRows()['cnt'];
                    var searchCnt = argoGetValue('s_SearchCount');
                    paging(totalData, pageCurrentCnt, searchCnt, "2");
                    $("#totCount").text(totalData);
                    if (totalData == 0) {
                        argoAlert('조회 결과가 없습니다.');
                        closeLoadingWithMask();
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

	function fnSearchList(startRow, endRow) {
		
		LoadingWithMask();
	    
		// 비동기 작업 완료 후, fnSearchListCnt 함수 호출
		setTimeout(function() {
			// 비동기 작업 완료 후에 조회
				
			setSearchCond("selectionPage", Math.ceil(endRow / argoGetValue("s_SearchCount")));
			callbackAfterSearchCondition.iSPageNo = startRow;
			callbackAfterSearchCondition.iEPageNo = endRow;
	        argoJsonSearchList('recSearch', 'getRecSearchList', '_', callbackAfterSearchCondition, function(data, textStatus, jqXHR) {
	            try {
	                if (data.isOk()) {
	                    w2ui.grid.clear();
				
	                    if (data.getRows() != "") {
	                        dataArray = [];
	                        
	                        var callIdChk = '';
	                        var markingColor = '';
	                        
	                      	//콜그룹핑
							var callGrpYn = $("#chkGetCallGroup").is(':checked')  ? "Y" : "";
	                        
							var totalCallTm = 0;
	                      	
	                        $.each(data.getRows(), function(index, row) {
	                        	totalCallTm = totalCallTm + row.endTime; 
	                            
	                        	var holdTime = 0;
	                            if (row.hold > 0) {
	                                if (row.callTime > row.convertTime) {
	                                	// 2024.08.05 jsele 보류시간 산식 변경
	                                    //holdTime = fnSecondsConv(row.callTime - row.convertTime);
	                                	holdTime = fnSecondsConv(row.callTime - row.endTime);
	                                }
	                            }
	                            
								var btnMediaScr;
								if (row.mediaScr == 1) {
	                                if(playerKind==1){
	                                    btnMediaScr = "<button type='button' class='btn_m' onclick='fnRecFilePlay(\""+index+"\","+true+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";
	                                }else{
	                                    btnMediaScr = "<button type='button' class='btn_m' onclick='fn_scrPopup("+index+")' style='height: 17px;width: 50px;font-size:11px;' >화면</button>";
	                                }
	                            }else{
	                                btnMediaScr="";
	                            }
	                            
	                            
													
								//콜그룹핑
								if(callGrpYn == "Y"){
											
		                            if(index == 0){
		                            	callIdChk = row.callId2;
		                            	markingColor = '#FFFFFF'; //#FAFAFA
		                            }else{
		                            	if(callIdChk != row.callId2){
		                            		callIdChk = row.callId2;
		                            		
		                            		if(markingColor == '#E5E5E5' ){
		                            			markingColor = '#FFFFFF';
		                            		}else{
		                            			markingColor = '#E5E5E5';
		                            		}
		                            		
		                            	}else{
		                           			if(markingColor == '#E5E5E5' ){
		                               			markingColor = '#E5E5E5';
		                            		}else{
		                            			markingColor = '#FFFFFF';
		                            		}
		                            	}
		                            }
								}
	                            
								
								if(row.markingColor != null){
	                            	markingColor = '#'+row.markingColor
	                            }
	                            

	                            gridObject = {
	                            	"recid" : index,
	                            	"recKey" : row.recKey,
	                            	"mediaScr" : btnMediaScr,
	                            	"listeningYnView" : row.listeningYn=="Y"?true:false,
	                                "recDate" : fnStrMask( "YMD", row.recDate),
	                                "recTime" : fnStrMask( "HMS", row.recTime),
	                              	//2024.08.05 jslee 통화시간 기준 변경 END_TIME > CALL_TIME_I
	                                //"endTime" : fnSecondsConv(row.endTime),
	                                "endTime" : fnSecondsConv(row.callTime),
	                                "groupName" : row.groupName,
	                                "userId" : row.userId,
	                                "userName" : row.userName,
	                                "custTel" : row.custTel,
	                                "custName" : row.custName,
	                                "dnNo" : row.dnNo,
	                                "dnGubun": row.dnGubun,
	                                "dnGubunId": row.dnGubunId,
	                                "callKind" : row.callKind,
	                                "custNo" : row.custNo,
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
	                                "callId" : row.callId,
	                                "recDateOrg" : row.recDate,
	                                "recTimeOrg" : row.recTime,
	                                "endTimeOrg" : row.endTime,
	                                "fileName" : row.fileName,
	                                "custEtc9" : row.custEtc9,
	                                "custEtc10" : row.custEtc10,
	                                "groupId":row.groupId,
	                                "tenantId":row.tenantId,
	                                "mfuIp" : row.mfuIp,
	                                "mediaScrCd" : row.mediaScr,
	                                "encKey" : row.encKey,
	                                "phoneIp": row.phoneIp,
	                                /** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) START */
	                                "mediaScrOrg": row.mediaScr,
	                                "mediaVoice": row.mediaVoice,
	                                "uploadCntScr": row.uploadCntScr,
	                                "uploadCntVoice": row.uploadCntVoice,
	                                "mediaKind": row.mediaKind,
	                                "fileName": row.fileNameIndex,
	                                "listeningYn": row.listeningYn,
	                                "downloadYn": row.downloadYn,
	                                /** (2023.08.09) TB_REC_SAMPLECALL 테이블에 새롭게 추가한 컬럼들에 등록할 데이터를 팝업창에 넘겨주기 위한 파라미터 설정 (HAGUANGHO) END */
	                                "recTime2": row.recTime2,
	                                "callId2": row.callId2,
	                                "fullCustName": row.fullCustName,
	                                "fullCustTel": row.fullCustTel,
	                                "fullCustNo": row.fullCustNo,
	                                "maskingYn":row.maskingYn,
	                                w2ui : {
	                                	"style" : "background-color:" + markingColor
	                                    //"style" : "background-color: #" + row.markingColor
	                                }
	                            };
	                            dataArray.push(gridObject);
	                        });

	                        var footerSumObj = {};
	                        footerSumObj.recid = 'S-1';
	    					footerSumObj.w2ui = { summary: true };
	    					footerSumObj.recDate = "<span style='float: right;'>합계 =></span>";
	    					footerSumObj.endTime = fnSecondsConv(totalCallTm);
	    					dataArray.push(footerSumObj);
	    					
	                        w2ui['grid'].add(dataArray);
	                        $('#gridList').show();
	                        $('#paging').show();

	                        
	                        

	                        // 그리드 데이터 저장
	                        setSearchCond("dataArray", dataArray);
	                    }
	                }
	                
	                console.log("w2ui.grid.records.length : " + w2ui.grid.records.length);
	                console.log("argoGetValue(s_DownloadListen) : " + argoGetValue("s_DownloadListen"));
	             	// 녹취권한에 따른 일괄재생, WAV 변환 버튼 display
                    /* if(w2ui.grid.records.length > 0 && argoGetValue("s_DownloadListen") == "1"){
                    	displayRecPlayBtn();
                    } */
                    /* else{
                    	$("#btnPlay").hide();
                    } */
                    
                    if(w2ui.grid.records.length > 0 && argoGetValue("s_DownloadListen") == "2"){
                        displayRecDownloadBtn();
                    }else{
                    	$("#btnWavConv").hide();
                    }
	                
	                closeLoadingWithMask();
	                w2ui.grid.unlock();
	                $("#grid_grid_fsummary input[type='checkbox']").hide();
	            } catch (e) {
	                console.log(e);
	            }
	        });
				
				
		}, 0); // 대기 시간을 0으로 설정
	}

	
</script>
</head>
<body>
	<div id='loadingImg' style='position:absolute; top:0; left:0; display: none; opacity: 0.9; z-index:8900;'>
		<img src='../images/veloce/spinnerRed.gif' style='position: relative; z-index:8000; display: block; margin: 0px auto; top: 30% '/>
	</div>
	<div class="sub_wrap">
		<div class="location" id="searchPanel_SAP">
			<span style="color:red; font-weight:bold; float: left; font-size: 11pt;">※ 통화 종료시간 이후 약 10분 이후부터 스크린 청취가 가능합니다.</span>
			<button type="button" id="btnTenantDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_tenant, btnTenantDisplay)">태넌트</button>
			<button type="button" id="btnUserDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_user, btnUserDisplay)">상담사정보</button>
			<button type="button" id="btnCustDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_cust, btnCustDisplay)">고객정보</button>
			<button type="button" id="btnCallDisplay" class="btn_tab" onclick="Display_Input_Panel(searchPanel, div_call, btnCallDisplay)">통화정보</button>
			<span style="width: 100px">&nbsp;</span> <span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역조회</span><strong class="step">통화내역조회</strong>
		</div>
		<section class="sub_contents">
			<div class="search_area row5" id="searchPanel">
				<div class="row" id="div_tenant">
					<ul class="search_terms">
						<li id="findTenantIdLi">
							<strong class="title ml20">태넌트</strong> 
							<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
							<input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" /> 
							<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1">
						</li>
					</ul>
				</div>
				<div class="row" id="div_user" style="width: 1350px;">
					<!-- 상담사 고객명 전화번호 고객번호 -->
					<ul class="search_terms">
						<li>
							<strong class="title ml20" >상담사</strong>
							<input type="text" id="s_FindUserNameText" name="s_FindUserNameText" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">고객명</strong> 
							<input type="text" id="s_FindCustNameText" name="s_FindCustNameText" style="width: 140px" class="clickSearch" /> <input type="hidden" id="s_FindCustNameText_hidden" name="s_FindCustNameText_hidden" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">전화번호</strong> 
							<input type="text" id="s_FindCustTelText" name="s_FindCustTelText" style="width: 140px" class="clickSearch" onkeyup="javascript:setCallNumber(this);" /> <input type="hidden" id="s_FindCustTelText_hidden" name="s_FindCustTelText_hidden" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title">고객번호</strong>
							<input type="text" id="s_FindCustNoText" name="s_FindCustNoText" style="width: 140px" class="clickSearch" /></li>
						<li>
							<strong class="title ml20">조회사유 등록</strong>
							<select id="ip_ReasonCode" name="ip_ReasonCode" style="width: 190px;"></select>
						</li>
					</ul>
				</div>
				<div class="row" id="div_cust" style="width: 1350px;">
					<ul class="search_terms" style="width: 1350px;">
						<li>
							<strong class="title ml20">내선번호</strong> 
							<input type="text" id="s_FindDnText" name="s_FindDnText"style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">내선구분</strong>
							<select id="s_FindDnGubunText" name="s_FindDnGubunText" style="width: 140px" class="list_box"></select>
						</li>
						
						
						
						<!-- <li><strong class="title ml20">그룹</strong>
							<select id="s_FindGroupId" name="s_FindGroupId"
							style="width: 140px" class="list_box"></select>
						</li> -->
						
						
						
						<li>
							<div class="input-wrapper" style="position: relative;">
	                        	<strong class="title ml20">그룹</strong>
	                        	<input type="text" id="s_FindGroupNm" name="s_FindGroupNm" style="width:114px;" readonly><button type="button" class="btn_termsSearch" id="btn_Group1">검색</button>
	                        	
	                        	<button id="clearButton" 
		                        	style="position: absolute;
								    right: 27px;
								    top: 48%;
								    transform: translateY(-50%);
								    background-color: #FFFFFF;
								    color: #c2c4c7;
								    border: none;
								    cursor: pointer;">X</button>
	                        	<input type="hidden" id="s_FindGroupId" name="s_FindGroupId">
	                        </div>
                        </li>
                        
						
						
						<li>
							<strong class="title">추가검색어</strong> 
							<select id="s_FindField" name="s_FindField" style="width: 140px;" class="list_box">
								<option value="">== 추가검색어 ==</option>
							</select> 
							<input type="text" id="s_FindFieldText" name="s_FindFieldText" style="width: 120px" class="clickSearch" /> 
							<select id="s_FindFieldText_jbbank" name="s_FindFieldText_jbbank" style="width: 140px;" class="list_box"></select>
						</li>
					</ul>
				</div>
				<div class="row" id="div_call" style="width: 1350px;">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">통화구분</strong> 
							<select id="s_FindCallKind" name="s_FindCallKind" style="width: 140px" class="list_box">
								<option value="">선택하세요!</option>
								<option value="1">Inbound</option>
								<option value="2">Outbound</option>
							</select>
						</li>
						<li>
							<strong class="title ml20">마킹구분</strong> 
							<select id="s_FindMarkKind" name="s_FindMarkKind" style="width: 140px" class="list_box"></select>
						</li>
						<li>
							<strong class="title ml20">콜아이디</strong> 
							<input type="text" id="s_FindCallIdText" name="s_FindCallIdText" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title">호전환 번호</strong>
							<input type="text" id="s_FindTranTelText" name="s_FindTranTelText" style="width: 165px" class="clickSearch" />
						</li>
						<li>
							<strong class="title">콜그룹핑</strong>
							<input type="checkbox" class="checkbox" id="chkGetCallGroup" name="chkGetCallGroup" value="Y">
							<label for="chkGetCallGroup" style="width: 60px">그룹핑</label>
							<span style="width: 100px">&nbsp;&nbsp;</span>
						</li>
					</ul>
				</div>
				<div class="row" style="width: 1350px;">
					<ul class="search_terms">
						<li style="width: 672px">
							<strong class="title ml20">녹취일자</strong>
							<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"/>
							</span> 
							<span class="timepicker rec" id="rec_time1"> 
								<input type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time" value="00:00:00"> <a href="#" class="btn_time">시간 선택</a>
							</span> 
							<span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span>
							<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"/>
							</span>
							<span class="timepicker rec" id="rec_time2">
								<input type="text" id="s_RecEndTm" name="s_RecEndTm" class="input_time" value="23:59:59"/>
								<a href="#" class="btn_time">시간 선택</a>
							</span> &nbsp; 
							<select id="selDateTerm1" name="" style="width: 70px;" class="mr5"></select>
						</li>
						<li>
							<strong class="title ml20">통화시간</strong>
							<span class="timepicker rec" id="rec_time1">
								<input type="text" id="s_CallFrmTm" name="s_CallFrmTm" class="input_time" value="00:00:00"/>
								<a href="#" class="btn_time">시간 선택</a>
							</span>
							<span class="text_divide">~</span>
							<span class="timepicker rec" id="rec_time2">
								<input type="text" id="s_CallEndTm" name="s_CallEndTm" class="input_time" value="23:59:59"/>
								<a href="#" class="btn_time">시간 선택</a>
							</span>
						</li>
						<li id="is_callexcept_node">
							<strong class="title ml20">녹취권한</strong>
							<select id="s_DownloadListen" name="s_DownloadListen" style="width: 140px" class="list_box">
								<option value="">선택하세요!</option>
								<option value="1">청취</option>
								<option value="2">다운로드</option>
							</select>
						
							<!-- <input type="checkbox" class="checkbox" id="chkListeningYn" name="chkListeningYn" value="Y">
							<label for="chkListeningYn" style="width: 60px">청취</label>
							<span style="width: 100px">&nbsp;&nbsp;</span>
							<span id="spChkDownloadYn">
							    <input type="checkbox" class="checkbox" id="chkDownloadYn" name="chkDownloadYn" value="Y" >
							    <label for="chkDownloadYn" style="width: 60px">다운로드</label>
							</span> -->
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top" id="searchPanel_SAP2">
				<div class="sub_l">
					<strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount">0</span>
					<select id="s_SearchCount" name="s_SearchCount" style="width: 50px"
						class="list_box">
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="30">30</option>
						<option value="40">40</option>
						<option value="50">50</option>
						<option value="200">200</option>
					</select>
					
					<button type="button" class="btn_m" id="btnReasonCodeManage" style="display: none;" >사유코드관리</button>
					<button type="button" class="btn_m" id="btnGroupGrantManage" style="display: none;" >그룹별 권한관리</button>
					<!-- <span style="color:red; font-weight:bold;">※ 통화 종료 후 약 10분 이후부터 스크린 청취가 가능합니다.</span> -->
				</div>
				<input type="text" id="clip_target" name="clip_target"
					style="width: 150px; position: absolute; top: -9999em;" />
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
				<button type="button" id="btnSearchDetail" class="btn_m search">상세조회</button>
				<!-- <button type="button" id="btnExcelInfoChange" class="btn_m confirm">일괄수정</button> -->
				<!-- <button type="button" id="btnInfoChange" class="btn_m confirm">정보수정</button> -->
				<button type="button" id="btnMarkAdd" class="btn_m confirm">마킹등록</button>
				<button type="button" id="btnMarkDel" class="btn_m confirm">마킹삭제</button>
				<button type="button" id="btnSampAdd" class="btn_m confirm">샘플콜등록</button>
				<button type="button" id="btnRecGrantReq" class="btn_m confirm">권한요청</button>
				<button type="button" id="btnPlay" class="btn_m" style="display: none;">일괄재생</button>
				<button type="button" id="btnStt" class="btn_m">STT</button>
				<button type="button" id="btnWavConv" class="btn_m" style="display: none;">파일변환</button>
				<button type="button" id="btnFileDown" class="btn_m">수동백업</button>
				<button type="button" id="btnExcelImport" class="btn_m confirm">고객정보 일괄등록</button>
				<button type="button" id="btnReset" class="btn_m">초기화</button>
			</div>
			<div class="h136">
				<div class="btn_topArea fix_h25"></div>
				<div class="grid_area h25 pt0">
					<div id="gridList" style="width: 100%; height: 460px;"></div>
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
<script>
	/* 전화번호 입력 */
	/* - 'dash' 가 들어올 시 제거*/
	function setCallNumber(object) {
		var val = $(object).val();
		val = val.replace(/-/g, '');

		$(object).val(val);
	}
</script>