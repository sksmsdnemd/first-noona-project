<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<link rel="stylesheet" href="<c:url value='/css/w2ui-1.5.rc1.css'/>" type="text/css" />
<link rel="stylesheet" href="<c:url value='/css/w2ui-1.5.rc1.min.css'/>" type="text/css" />
<link rel="stylesheet" href="<c:url value='/css/veloce.common.css'/>" type="text/css" />

<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery-1.11.3.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.popWindow.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/w2ui-1.5.rc1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/w2ui-1.5.rc1.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.alert.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery-ui.js?ver=2017011301'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.timeSelect.js'/>"></script>

<script type="text/javascript" src="<c:url value='/scripts/fullcalendar-3.1.0/lib/moment.min.js'/>"></script>


<script>
    var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo")).SVCCOMMONID.rows || {};
// 	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
// 	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
// 	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
// 	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
// 	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
// 	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
// 	var authRank	= loginInfo.SVCCOMMONID.rows.authRank;
	var workMenu 	= "녹취권한승인내역";

    var model;  // popup parameter
    $(function () {
        // popup parameter
        sPopupOptions = parent.gPopupOptions || {};
        sPopupOptions.get = function(key, value) {
            return this[key] === undefined ? value : this[key];
        };
        model = sPopupOptions;
    });

	$(document).ready(function(e) {
        /** 취소 버튼 이벤트 처리 */
        $("#btnReqCancel").click(function() {
        	if(model.dispAprvStatus == '신청' && loginInfo.userId == model.userId){
            	cancelAprv(); 
        	}else{
        		argoAlert("권한이 불충분합니다.<br>조건을 확인해 주세요.<br><br>" + "<span style='font-size:10pt;'>1.승인상태가 '신청'이어야 합니다.</span>" + "<br><span style='font-size:10pt;'>2.신청자ID와 로그인ID가 일치하여야 합니다.</span>");
        	}
        });

        /** 승인 버튼 이벤트 처리 */
        $("#btnApproval").click(function() {
        	if(model.dispAprvStatus == '신청' && loginInfo.userId == model.aprvrId){
        		saveApproval(); // 승인
        	}else{
        		argoAlert("권한이 불충분합니다.<br>조건을 확인해 주세요.<br><br>" + "<span style='font-size:10pt;'>1.승인상태가 '신청'이어야 합니다.</span>" + "<br><span style='font-size:10pt;'>2.승인자ID와 로그인ID가 일치하여야 합니다.</span>");
        	}
        });

        /** 반려 버튼 이벤트 처리 */
        $("#btnReject").click(function() {
        	if(model.dispAprvStatus == '신청' && loginInfo.userId == model.aprvrId){
            	saveReject(); // 반려
        	}else{
        		argoAlert("권한이 불충분합니다.<br>조건을 확인해 주세요.<br><br>" + "<span style='font-size:10pt;'>1.승인상태가 '신청'이어야 합니다.</span>" + "<br><span style='font-size:10pt;'>2.승인자ID와 로그인ID가 일치하여야 합니다.</span>");
        	}
        });

        // 초기화
        init();
    });


	/**
	 * Document Init
	 */
	function init() {
        searchAprv();
	}

    /**
     * 권한승인정보 조회
     */
	function searchAprv() {
	    var param = {
	        tenantId    : model.tenantId,
	        userId      : model.userId,
	        recKey      : model.recKey,
	        recTime     : model.recTime,
	        recGrant    : model.recGrant,
	        startDt     : model.startDt,
	    }
	    argoJsonSearchOne('recGrantAprv', 'getRecGrantAprv', null, param, function (data, textStatus, jqXHR) {
	        if (data.isOk()) {
	            setDetail(data.SVCCOMMONID.rows);
            }
	    }, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});
	}

    /**
     * Set 권한승인정보
     */
	function setDetail(data) {
	    //console.log("# setDetail model:", model);
	    //console.log("# setDetail data:", data);
	    $("#userName").text(data.userName);
	    $("#reqDate").text(data.reqDate);
	    $("#callId").text(data.callId);
	    $("#custName").text(data.custName);
	    $("#dnNo").text(data.dnNo);
	    $("#recTime").text(moment(data.recTime, "YYYYMMDDHHmmss").format("YYYY-MM-DD HH:mm:ss"));
	    $("#endTime").text(moment(data.endTime, "ss").format("HH:mm:ss"));
	    $("#recGrant").text(data.recGrant == "D" ? "다운로드" : data.recGrant == "L" ? "청취" : "");
	    $("#aprvStatus").text(data.aprvStatus == "R" ? "신청" : data.aprvStatus == "A" ? "승인" : data.aprvStatus == "J" ? "반려" : "");
	    $("#startDt").text(moment(data.startDt).format("YYYY-MM-DD"));
	    $("#endDt").text(moment(data.endDt).format("YYYY-MM-DD"));
	    $("#reqReason").val(data.reqReason);
	    $("#aprvrIds").text(data.aprvrIds);
	    $("#aprvDate").text(data.aprvDate || "");
        $("#aprvrName").text(data.aprvrName);
        $("#aprvReason").text(data.aprvReason  || "");

	    // 신청취소 버튼 show/hide
	    if (data.userId != loginInfo.userId || data.aprvStatus != "R") {
	        $("#divReqBtn").hide();
	    }

        // 승인, 반려 버튼 show/hide
	    if (data.aprvrId == loginInfo.userId && data.aprvStatus == "R") {
            $("#divAprvBtn").show();
            $("#aprvDate").text(moment().format("YYYY-MM-DD"));
        }
        else {
            $("#divAprvBtn").hide();
        }
	}


    /**
     * 신청취소 처리
     */
	function cancelAprv() {
	    var param = {
            tenantId    : model.tenantId,
            userId      : model.userId,
            recKey      : model.recKey,
            recGrant    : model.recGrant,
            startDt     : model.startDt,
        }
	    argoConfirm("신청취소 하시겠습니까?", function() {
	        argoJsonUpdate("recGrantAprv", "setRecGrantAprvDelete", null, param, callback, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});
            function callback(res) {
                if (res && res.resultCode == '0000') {
                    // 조작로그 저장
                    var workLog = '[TenantId:'+ loginInfo.tenantId +' | UserId:'+ loginInfo.userId +'] 녹취권한요청 취소';
                    argoJsonUpdate("actionLog", "setActionLogInsert", null, {
                        tenantId    : loginInfo.tenantId,
                        userId      : loginInfo.userId,
                        actionClass : "action_class",
                        actionCode  : "W",
                        workIp      : loginInfo.workIp,
                        workMenu    : workMenu,
                        workLog     : workLog
                    });

                    argoAlert('warning', '성공적으로 취소 되었습니다.', '',	'parent.searchAprvList(1); argoPopupClose();');
                }
                else {
                    console.log(res.resultMsg);
                }
            }
        });
	}

    /**
     * 승인 처리
     */
	function saveApproval() {
	    var param = {
            tenantId    : model.tenantId,
            userId      : model.userId,
            recKey      : model.recKey,
            recGrant    : model.recGrant,
            startDt     : model.startDt,
            endDt       : model.endDt,
            reqReason   : model.reqReason,
            aprvrId     : loginInfo.userId,
            aprvReason  : $("#aprvReason").val(),
            aprvStatus  : "A"
        }
        argoConfirm("승인 하시겠습니까?", function() {
            argoJsonUpdate("recGrantAprv", "setRecGrantAprvByAprvrUpdate", null, param, callback, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});
            function callback(res) {
                if (res && res.resultCode == '0000') {
                    // 조작로그 저장
                    var workLog = '[TenantId:'+ loginInfo.tenantId +' | UserId:'+ loginInfo.userId +'] 녹취권한요청 승인';
                    argoJsonUpdate("actionLog", "setActionLogInsert", null, {
                        tenantId    : loginInfo.tenantId,
                        userId      : loginInfo.userId,
                        actionClass : "action_class",
                        actionCode  : "W",
                        workIp      : loginInfo.workIp,
                        workMenu    : workMenu,
                        workLog     : workLog
                    });

                    argoAlert('warning', '성공적으로 승인 되었습니다.', '',	'parent.searchAprvList(1); argoPopupClose();');
                }
                else {
                    console.log(res.resultMsg);
                }
            }
        });
    }

    /**
     * 반려 처리
     */
    function saveReject() {
        var param = {
            tenantId    : model.tenantId,
            userId      : model.userId,
            recKey      : model.recKey,
            recGrant    : model.recGrant,
            startDt     : model.startDt,
            aprvrId     : loginInfo.userId,
            aprvReason  : $("#aprvReason").val(),
            aprvStatus  : "J"
        }
        argoConfirm("반려 하시겠습니까?", function() {
            argoJsonUpdate("recGrantAprv", "setRecGrantAprvByAprvrUpdate", null, param, callback, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});
            function callback(res) {
                if (res && res.resultCode == '0000') {
                    // 조작로그 저장
                    var workLog = '[TenantId:'+ loginInfo.tenantId +' | UserId:'+ loginInfo.userId +'] 녹취권한요청 반려';
                    argoJsonUpdate("actionLog", "setActionLogInsert", null, {
                        tenantId    : loginInfo.tenantId,
                        userId      : loginInfo.userId,
                        actionClass : "action_class",
                        actionCode  : "W",
                        workIp      : loginInfo.workIp,
                        workMenu    : workMenu,
                        workLog     : workLog
                    });

                    argoAlert('warning', '성공적으로 반려 되었습니다.', '',	'parent.searchAprvList(1); argoPopupClose();');
                }
                else {
                    console.log(res.resultMsg);
                }
            }
        });
    }

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
            	    <span><h3>신청내역</span>
					<span class="btn_r">
					    <div id="divReqBtn">
						    <button type="button" class="btn_m confirm" id="btnReqCancel" name="btnReqCancel">신청취소</button>
						</div>
                    </span>
                </div>

                <div>
                    <div class="input_area">
                        <table class="veloce_input_table" style="margin-bottom: 25px;">
                            <colgroup>
                                <col width="158">
                                <col width="220">
                                <col width="158">
                                <col width="">
                            </colgroup>
                            <tbody>
                                <tr>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">신청자<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="userName"></span>
                                    </td>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">신청일시<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="reqDate"></span>
                                    </td>
                                </tr>


                                <tr>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">신청권한</th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="recGrant"></span>
                                    </td>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인상태</th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="aprvStatus"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">시작일자<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="startDt"></span>
                                    </td>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">만료일자<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="endDt"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">사유</th>
                                    <td colspan="3" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <textarea id="reqReason" name="reqReason" rows="4" style="width:100%;" class="mr10" maxlength="200" readonly></textarea>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="btn_topArea">
                        <span><h3>통화내역</span>
                    </div>
                    <div class="input_area">
                        <table class="veloce_input_table" style="margin-bottom: 25px;">
                            <colgroup>
                                <col width="158">
                                <col width="220">
                                <col width="158">
                                <col width="">
                            </colgroup>
                            <tbody>
                                 <tr>
                                    <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">콜ID</th>
                                    <td colspan="3" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="callId"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">고객명<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="custName"></span>
                                    </td>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">내선번호<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="dnNo"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">통화시작시각<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="recTime"></span>
                                    </td>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">통화시간<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="endTime"></span>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div class="btn_topArea">
                        <span><h3>권한승인</span>
                        <span class="btn_r" >
                            <div id="divAprvBtn">
                                <button type="button" class="btn_m confirm" id="btnApproval" name="btnApproval">승인</button>
                                <button type="button" class="btn_m confirm" id="btnReject" name="btnReject">반려</button>
                            </div>
                        </span>
                    </div>
                    <div class="input_area">
                        <table class="veloce_input_table" style="margin-bottom: 25px;">
                            <colgroup>
                                <col width="158">
                                <col width="220">
                                <col width="158">
                                <col width="">
                            </colgroup>
                            <tbody>
                                <tr>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인자<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="aprvrName"></span>
                                    </td>
                                    <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인일시<span class="point"></span></th>
                                    <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <span id="aprvDate"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">사유</th>
                                    <td colspan="3" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                        <textarea id="aprvReason" name="aprvReason" rows="4" style="width:100%;" class="mr10" maxlength="200"></textarea>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </section>
    </div>
</body>

</html>
