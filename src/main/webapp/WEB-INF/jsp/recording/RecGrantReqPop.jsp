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
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo")).SVCCOMMONID.rows;
	var workMenu 	= "녹취권한요청";

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
	    // 태넌트 Selectbox
        argoCbCreate("selTenant", "comboBoxCode", "getTenantList", {}, {
            "selectIndex" : 0,
            "text" : '선택하세요!',
            "value" : ''
        });

        // 태넌트 변경 이벤트 처리
        $("#selTenant").change(function(e) {
            var param = {tenantId: this.value};
            argoCbCreate("selGroup", "comboBoxCode", "getGroupListByParentId", param, {"selectIndex":0, "text":'선택하세요!', "value":''});
            fnGroupCbChange("selGroup");
        });

        // 그룹 변경 이벤트 처리
        $("#selGroup").change(function(e) {
            selectedGroup();
        });

        // 요청권한 변경 이벤트 처리
        $("input[name='rdRecGrant']").change(function(e) {
            setAprvrIdsOptions();
        });

        argoSetDatePicker();
        jData =[{"codeNm":"당일", "code":"T_0"}] ;
        argoSetDateTerm('selStartDt', {"targetObj":"start_date", "selectValue":"T_0"}, jData);
        $("#selStartDt").hide();
        argoSetDateTerm('selEndDt', {"targetObj":"grant_date", "selectValue":"T_0"}, jData);
        $("#selEndDt").hide();

        var today = moment().format("YYYY-MM-DD"); moment("20230000")
        $("#grant_date_From").change(function(e) {
            var strTodayDate = today;
            var setEndDayDate = new Date($("#grant_date_From").val());

            if(strTodayDate>setEndDayDate) {
                argoAlert("만료일은 과거로 설정하실 수 없습니다.");
                $("#grant_date_From").val(today);
                return;
            }
        });

        $("#start_date_From").change(function(e) {
            var strTodayDate = today;
            var setEndDayDate = new Date($("#start_date_From").val());

            if(strTodayDate>setEndDayDate) {
                argoAlert("시작일은 과거로 설정하실 수 없습니다.");
                $("#start_date_From").val(today);
                return;
            }
        });

        /** 체크 버튼 이벤트 처리 */
        $("#btnCheck").click(function(){
            check(); // 저장
        });

        /** 저장 버튼 이벤트 처리 */
        $("#btnSave").click(function(){
            save(); // 저장
        });

        // 초기화
        init();
    });


	/**
	 * Document Init
	 */
	function init() {
	    // 그리드 초기화
		initGrid();

		// Set 태넌트
		$("#selTenant").val(model.tenantId).trigger('change');
		$('#liTenant').css('display', loginInfo.grantId != "SuperAdmin" ? 'none' : '');

        // Set 사용자 리스트
        setRecList();

        //
        $('#spRecGrantD').css('display', loginInfo.grantId == "Agent"? 'none' : '');
	}


    /**
     * 그리드 초기화
     */
	function initGrid(){
        $('#divRecGrid').w2grid({
            name: 'recGrid',
            show: {
                lineNumbers: true,
                footer: true,
                selectColumn: true,
            },
            multiSelect: true,
            columns: [
                 { field: 'recid'           , caption: 'recid'        , size:   '0px' , 	attr: 'align=center' }
                ,{ field: 'recDate'         , caption: '통화일자'     , size: '100px' , 	attr: 'align=center' }
                ,{ field: 'recTime'         , caption: 'recTime'      , size:   '0px' , 	attr: 'align=center' }
                ,{ field: 'groupName'       , caption: '그룹'         , size: '120px' , 	attr: 'align=center' }
                ,{ field: 'userId'          , caption: '상담사ID'     , size: '120px' , 	attr: 'align=center' }
                ,{ field: 'userName'        , caption: '상담사명'     , size: '120px' , 	attr: 'align=center' }
                ,{ field: 'custName'        , caption: '고객명'       , size: '120px' , 	attr: 'align=center' }
                ,{ field: 'dnNo'            , caption: '내선'         , size:  '60px' , 	attr: 'align=center' }
                ,{ field: 'callId'          , caption: '콜ID'         , size: '240px' , 	attr: 'align=center' }
                ,{ field: 'isEnableText'    , caption: '신청여부'     , size:  '80px' , 	attr: 'align=center' }
                ,{ field: 'tenantId'        , caption: 'tenantId'     , size:   '2px' , 	attr: 'align=center' }
                ,{ field: 'groupId'         , caption: 'groupId'      , size:   '0px' , 	attr: 'align=center' }
                ,{ field: 'isEnable'        , caption: 'isEnable'      , size:  '0px' , 	attr: 'align=center' }
            ],
            records: new Array(),
        });

        // 컬럼 Hide
        w2ui['recGrid'].hideColumn('recid', 'tenantId', 'groupId', 'isEnable', 'recTime');
    }

	/**
	 * Set 통화내역 리스트
	 */
	function setRecList() {
	    var data = model.recList;

        if (data) {
            w2ui['recGrid'].clear();

            var rows = [];
            $.each(data, function(index, item) {
                item['valid'] = false;
                rows.push(item);
            });
            w2ui['recGrid'].add(rows);
        }

        w2ui.recGrid.unlock();
    }


    /**
     * 그룹 선택 처리
     */
    function selectedGroup() {
        var groupId = $("#selGroup").val();

        var groupIds = [{field: 'groupId', value: groupId, operator: 'contains'}];
        argoJsonSearchList('Group', 'getChildGroupList', null, {tenantId: model.tenantId, groupId: groupId}, callback);
        function callback(res) {
            if (res.isOk()) {
                var data = res.SVCCOMMONID || {};

                //console.log("# getChildGroupList data:", data);
                $.each(data.rows, function(index, item) {
                    //groupIds.push(item.groupId);
                    groupIds.push({field: 'groupId', value: item.groupId, operator: 'contains'});
                });
            }
        };

        //console.log("# groupIds:", groupIds);
        w2ui['recGrid'].search(groupIds, 'OR');

        // 행 선택 처리
        w2ui['recGrid'].selectAll();

        // 승인자 Selectbox Options 생성
        setAprvrIdsOptions();
    }


    /**
     * 승인권한자 Selectbox Options 생성
     */
    function setAprvrIdsOptions() {
        var tenantId = $("#selTenant").val();
        var groupId = $("#selGroup").val();
        var options = {"selectIndex": 0, "text": '선택하세요!', "value": ''};

        $("#selAprvrId").empty();
        $("#selAprvrId").append($('<option>').text(options.text).attr('value', options.value || ''));    // 선택하세요 추가

        if (groupId == "") {
            return;
        }

        // 승인권한자 리스트(Selectbox) 조회 - Group
        var selParam = {tenantId: tenantId, groupId: groupId};
        var recGrant = argoGetValue('rdRecGrant') == 'L' ? 'recListeningYn' :  argoGetValue('rdRecGrant') == 'D' ? 'recDownloadYn' : "";
        selParam[recGrant] = 'Y';
        var aprvrKeyList = [];
        argoCbCreate("selAprvrId", "recGrantAprv", "getRecGrantAprvrList", selParam, options, callback, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});
        function callback(res) {
            var aprvrList = res.SVCCOMMONID.rows;
            $.each(aprvrList, function(index, item) {
                $("#selAprvrId").append($('<option>').text(item.userName).attr('value', item.userId).attr('data-tenantId', item.tenantId));
            });
         }
    }


    /**
     * 유효성 검사
     */
    var isValidSave = false;
    var saveValidData = {};
    function checkValid() {
        // 태넌트 check
        if ($("#selTenant").val() == "") {
            argoAlert("태넌트를 선택하세요.");
            return ;
        }

        // 그룹 check
        if ($("#selGroup").val() == "") {
            argoAlert("그룹을 선택하세요.");
            return ;
        }

        // 통화내역 선택 여부 check
        var rows = w2ui['recGrid'].getSelection();
        if (rows.length == 0) {
            argoAlert("통화내역을 선택하세요.");
            return ;
        }

        // 승인자 체크
        if ($("#selAprvrId").val() == "") {
            argoAlert("승인자를 선택하세요.");
            return ;
        }

        // 사유 체크
        if ($("#reqReason").val() == "") {
            argoAlert("요청사유를 입력하세요.");
            return ;
        }

        saveValidData = {
            tenantId: argoGetValue('selTenant'),
            userId  : argoGetValue('selAprvrId'),
            recGrant: argoGetValue('rdRecGrant'),
            startDt : argoGetValue('start_date_From').replaceAll('-', ''),
        };
        isValidSave = true;

        return true;
    }


    /**
     * 저장 가능여부 조회
     */
    function check() {
        if (checkValid() != true) {
            return;
        }

        var selRow;    // grid row
        var startDt     = argoGetValue('start_date_From').replaceAll('-', '');
        var endDt       = argoGetValue('grant_date_From').replaceAll('-', '');
        var recGrant    = argoGetValue('rdRecGrant');
        var aprvrIds    = $('#selAprvrId option:selected').toArray().map(item => item.value).join();

        // 중복 체크
        var selParam = {
            tenantId        : loginInfo.tenantId,
            userId          : loginInfo.userId,
            recGrant        : recGrant,
            startDt         : startDt,
        }
        argoJsonSearchList('recGrantAprv', 'getRecGrantAprvList', null, selParam, callback, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});
        function callback(data, textStatus, jqXHR) {
            if (data.isOk()) {
                var aprvList = data.SVCCOMMONID.rows || [];
                var keyList = [];
                $.each(aprvList, function(index, item) {
                    keyList.push(item.recKey);
                });

                var records = w2ui['recGrid'].records;
                if (records) {
                    $.each(records, function(index, item) {
                        item.isEnable = keyList.indexOf(item.recKey) == -1 ? true : false;
                        item.isEnableText = item.isEnable == true ? "가능" : "중복";

                        // 중복건 선택 해제
                        if (item.isEnable == false) {
                            w2ui['recGrid'].unselect(item.recid);
                        }
                    });

                    w2ui['recGrid'].refresh();
                }
            }
        }

        return true;
    }


    /**
     * 사용자권한 저장
     */
	function save() {
	    if (check() != true) {
	        return;
	    }

		argoConfirm("저장 하시겠습니까?", function(){
            var logs = new Array(); // action log array

            var selRow;    // grid row
            var startDt     = argoGetValue('start_date_From').replaceAll('-', '');
            var endDt       = argoGetValue('grant_date_From').replaceAll('-', '');
            var recGrant    = argoGetValue('rdRecGrant');
            //var aprvrIds    = $('#selAprvrId option:selected').toArray().map(item => item.value).join();
            var log;    // action log

            // 저장 처리
            var params = [];
            $.each(w2ui['recGrid'].getSelection(), function(index, item) {
                selRow = w2ui['recGrid'].get(item);
                params.push({
                    recKey          : selRow.recKey,
                    tenantId        : loginInfo.tenantId,
                    userId          : loginInfo.userId,
                    recGrant        : recGrant,
                    aprvStatus      : 'R',
                    startDt         : startDt,
                    endDt           : endDt,
                    recTime         : selRow.recDateOrg +""+ selRow.recTimeOrg,
                    aprvrId         : argoGetValue('selAprvrId'),
                    reqReason       : argoGetValue('reqReason'),
                });

                log = "[TenantId:"+ model.tenantId +" | UserId:"+ selRow.userId +"] 권한요청";
                log += " (권한:"+ recGrant +")";
                log += " (콜ID:"+ selRow.callId +")";
                logs.push(log);
			});

			// Update
            argoJsonUpdate("recGrantAprv", "setRecGrantAprvInsert", null, {params}, savCallback, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});

            /** 저장 Callback 처리 - Action Log 저장 */
			function savCallback(res) {
                if (res && res.resultCode == '0000') {
                    //argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCntAfterCallback(); argoPopupClose();');
                    
                    argoAlert('warning', '성공적으로 저장 되었습니다..', '',	'parent.fnSearchListCnt(); argoPopupClose();');
                    
                    $.each(logs, function(index, item) {
                        argoJsonUpdate("actionLog", "setActionLogInsert", null, {tenantId: loginInfo.tenantId, userId: loginInfo.userId, actionClass: "action_class", actionCode:"W", workIp:loginInfo.workIp, workMenu: workMenu, workLog: item});
                    });
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
            	    <ul class="search_terms">
                        <li id="liTenant">
                            <strong class="title ml20">테넌트</strong>
                            <select id="selTenant" name="selTenant" style="width:150px;"  class="list_box"></select>
                        </li>
                        <li>
                            <strong class="title ml20">그룹</strong>
                            <select id="selGroup" name="selGroup" style="width: 150px" class="list_box">
                                <option value="">선택하세요.</option>
                            </select>
                        </li>
                    </ul>
					<span class="btn_r">
						<button type="button" class="btn_m confirm" id="btnSave" name="btnSave">저장</button>
                       	<input type="hidden" id="ip_Salt" name="ip_Salt" />
                       	<input type="hidden" id="ip_InsId" name="ip_InsId" />
                       	<input type="hidden" id="ip_TenantId" name="ip_TenantId" />
                    </span>
                </div>

                <div>
                    <div class="grid_area h25 pt0">
                        <div id="divRecGrid" style="width: 100%; height: 175px;"></div>
                        <br>

                        <div class="input_area">
                            <table class="veloce_input_table" style="margin-bottom: 25px;">
                                <colgroup>
                                    <col width="158">
                                    <col width="">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">시작일자<span class="point"></span></th>
                                        <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="start_date_From" name="start_date_From"></span>
                                            <select id="selStartDt" name="selStartDt" style="width:70px;" class="mr5"></select>
                                        </td>
                                        <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">만료일자<span class="point"></span></th>
                                        <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="grant_date_From" name="grant_date_From"></span>
                                            <select id="selEndDt" name="selEndDt" style="width:70px;" class="mr5"></select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">요청권한</th>
                                        <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                            <input type="radio" name="rdRecGrant" id="rdRecGrant" value="L" checked /><label>청취</label>
                                            <span id="spRecGrantD" style="display:none;" >
                                                <input type="radio" name="rdRecGrant" id="rdRecGrant" value="D" /><label>다운로드</label>
                                            </span>
                                        </td>
                                        <th style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인자</th>
                                        <td style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                            <select id="selAprvrId" name="selAprvrId" style="width: 150px" class="list_box">
                                                <option value="">선택하세요.</option>
                                            </select>
                                        </td>
                                    </tr>

                                    <tr>
                                        <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">요청사유</th>
                                        <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                            <textarea id="reqReason" name="reqReason" rows="4" style="width:100%;" class="mr10" maxlength="200"></textarea>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</body>

</html>
