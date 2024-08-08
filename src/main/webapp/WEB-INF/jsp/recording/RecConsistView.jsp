<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true"/>

    <script>

        var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
        var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;
        var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
        var userId      = loginInfo.SVCCOMMONID.rows.userId;
        var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
        var groupId     = loginInfo.SVCCOMMONID.rows.groupId;
        var depth       = loginInfo.SVCCOMMONID.rows.depth;
        var controlAuth = loginInfo.SVCCOMMONID.rows.controlAuth;
        var workMenu    = "미전송내역조회";
        var workLog     = "";
        var dataArray   = new Array();

        $(document).ready(function () {
            fnInitCtrl();
            fnInitGrid();
            fnSearchListCnt();
        });

        function fnInitCtrl() {
            argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
                "selectIndex": 0
            });

            $('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);

            argoSetDatePicker();
            $('.timepicker.rec').timeSelect({use_sec: true});

            fnArgoSetting();

// 		    argoCbCreate("s_FindGroupId", "comboBoxCode", "getDepthGroupList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
            argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {
                findTenantId: tenantId,
                userId: userId,
                controlAuth: controlAuth,
                grantId: grantId
            }, {"selectIndex": 0, "text": '선택하세요!', "value": ''});
            argoCbCreate("s_FindMediaKind", "baseCode", "getBaseComboList", {classId: 'media_kind'}, {
                "selectIndex": 0,
                "text": '선택하세요!',
                "value": ''
            });

            fnGroupCbChange("s_FindGroupId");

            $("#btnSearch").click(function () { //조회
                fnSearchListCnt();
            });

            if (grantId == "GroupManager" || grantId == "Agent" || grantId == "Manager") {
                $('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
            }

            $("#btnReset").click(function () {

// 		    	$('#s_FindGroupId option[value=""]').prop('selected', true);
                $('#s_FindGroupId option[value="' + groupId + '_' + depth + '"]').prop('selected', true);
                $('#s_FindKey option[value=""]').prop('selected', true);
                $("#s_FindText").val('');
                $("#s_FindCustName").val('');
                $("#s_FindCustNo").val('');
                $("#s_FindCustTel").val('');

                fnArgoSetting();
            });

            $('#s_FindText').keydown(function (key) {
                if (key.keyCode == 13) {
                    fnSearchListCnt();
                }
            });

            $("#s_FindKey").change(function () {
                var sSel = argoGetValue('s_FindKey');
                if (sSel == "") {
                    $("#s_FindText").val("");
                }
                $("#s_FindText").focus();

            });

            $('.clickSearch').keydown(function (key) {
                if (key.keyCode == 13) {
                    fnSearchListCnt();
                }
            });
        }

        function fnArgoSetting() {

            jData = [{"codeNm": "당일", "code": "T_0"}, {"codeNm": "1주", "code": "W_1"}, {
                "codeNm": "2주",
                "code": "W_2"
            }, {"codeNm": "한달", "code": "M_1"}];
            argoSetDateTerm('selDateTerm1', {"targetObj": "s_txtDate1", "selectValue": "T_0"}, jData);
            argoSetValue("s_FindSRegTime", "00:00:00");
            argoSetValue("s_FindERegTime", "23:59:59");
            $('#selDateTerm1 option[value="T_0"]').prop('selected', true);
        }

        function fnInitGrid() {

            // if(grantId != "Agent"){
            // 	 $("#s_FindKey").append($('<option>').text('상담사ID').attr('value', 'a.user_id'));
            // 	 $("#s_FindKey").append($('<option>').text('상담사명').attr('value', 'b.user_name'));
            // }

            $('#gridList').w2grid({
                name: 'grid',
                show: {
                    lineNumbers: true,
                    footer: true,
                    selectColumn: true
                },
                multiSelect: true,
                columns: [
                    {field: 'recid'             , caption: 'recid', size: '0%', sortable: true, attr: 'align=center'}
                    , {field: 'recTime'         , caption: '통화일자', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'groupName'       , caption: '그룹', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'userId'          , caption: '상담사ID', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'userName'        , caption: '상담사명', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'mediaKindName'   , caption: '미디어구분', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'dbCallId'        , caption: '콜아이디', size: '10%', sortable: true, attr: 'align=center'}
                    // , {field: 'apiCallId'       , caption: '콜아이디', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'callType'        , caption: '콜 구분', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'custTel'         , caption: '고객번호', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'custName'        , caption: '고객명', size: '10%', sortable: true, attr: 'align=center'}
                    , {field: 'callKind'        , caption: '콜 구분', size: '10%', sortable: true, attr: 'align=center'}
                ],


                records: dataArray
            });

            w2ui['grid'].hideColumn('recid', 'mediaKind');
        }

        function fnSearchListCnt() {

            argoSetValue("s_FindSRecTime", $("#s_txtDate1_From").val().replace(/-/gi, "") + $("#s_FindSRegTime").val().replace(/:/gi, ""));
            argoSetValue("s_FindERecTime", $("#s_txtDate1_To").val().replace(/-/gi, "") + $("#s_FindERegTime").val().replace(/:/gi, ""));

            //w2ui.grid.lock('조회중', true);

            argoJsonSearchOne('recordFile', 'getAPIConstListCnt', 's_', {}, function (data, textStatus, jqXHR) {
                try {
                    if (data.isOk()) {
                        var totalData = data.getRows()['cnt'];
                        paging(totalData, "1");

                        $("#totCount").text(totalData);

                        if (totalData == 0) {
                            argoAlert('조회 결과가 없습니다.');
                        }
                    }
                } catch (e) {
                    console.log(e);
                }
            });
        }

        function fnSearchList(startRow, endRow) {


            console.log(startRow)
            console.log(endRow)

            argoJsonSearchList('recordFile', 'getAPIConstList', 's_', {
                "tenantId": tenantId,
                "iSPageNo": startRow,
                "iEPageNo": endRow
            }, function (data, textStatus, jqXHR) {
                try {
                    if (data.isOk()) {
                        w2ui.grid.clear();

                        if (data.getRows() != "") {
                            dataArray = new Array();

                            var uiArray = new Array();
                            var gObject2 = new Array();
                            uiArray = {"w2ui": {"style": "color: blue"}};


                            $.each(data.getRows(), function (index, row) {

                                var btnHtml = '<a href="javascript:fnRowDetail(' + index + ');"><img src="../images/icon_code.png"></a>';

                                gObject2 = {
                                    'recid': index
                                    , 'recTime': fnStrMask("YMD", row.recTime)
                                    , 'groupName': row.groupName
                                    , 'userId': row.userId
                                    , 'userName': row.userName
                                    , 'mediaKindName': row.mediaKindName
                                    , 'dbCallId': row.dbCallId
                                    // , 'apiCallId': row.apiCallId
                                    , 'callType': row.callType
                                    , 'custTel': row.custTel
                                    , 'custName': row.custName
                                    , 'callKind': row.callKind

                                };

                                if (row.apiCallId == "" || row.apiCallId == null) {
                                    gObject2['w2ui'] = {"style": "color:red"};
                                }

                                dataArray.push(gObject2);
                            });

                            w2ui['grid'].add(dataArray);
                        }
                    }
                    //w2ui.grid.unlock();
                } catch (e) {
                    console.log(e);
                }

                workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
                    + ' | GrantId:' + grantId + '] 정합성조회';
                argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
                    tenantId: tenantId,
                    userId: userId,
                    actionClass: "action_class",
                    actionCode: "W",
                    workIp: workIp,
                    workMenu: workMenu,
                    workLog: workLog
                });
            });
        }


    </script>
</head>
<body>
<div class="sub_wrap">
    <div class="location">
        <span class="location_home">HOME</span>
        <span class="step">통화내역관리</span>
        <span class="step">전송상태조회</span>
        <strong class="step">미전송내역조회</strong>
    </div>
    <section class="sub_contents">
        <div class="search_area">
            <div class="row">
                <ul class="search_terms">
                    <li style="width:340px">
                        <strong class="title ml20">태넌트</strong>
                        <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
                    </li>
                </ul>
            </div>
            <div class="row">
                <ul class="search_terms">
                    <li style="width:340px">
                        <strong class="title ml20">그룹</strong>
                        <select id="s_FindGroupId" name="s_FindGroupId" style="width:200px;" class="list_box">
                        </select>
                    </li>
                    <li style="width:340px">
                        <strong class="title">검색</strong>
                        <select id="s_FindKey" name="s_FindKey" style="width:100px" class="list_box">
                            <option value="">선택하세요!</option>
                            <!-- <option value="dn_no" >내선번호</option> -->
                        </select>
                        <input type="text" id="s_FindText" name="s_FindText" style="width:102px"/>
                    </li>

                </ul>
            </div>

            <div class="row">
                <ul class="search_terms">
                    <li>
                        <strong class="title ml20">검색기간</strong>
                        <span class="select_date">
                            <input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From">
                        </span>
                        <span class="timepicker rec" id="rec_time1">
                            <input type="text" id="s_FindSRegTime" name="s_FindSRegTime" class="input_time">
                            <a href="#" class="btn_time">시간 선택</a>
                        </span>
                        <span class="text_divide">~</span>
                        <span class="select_date">
                            <input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To">
                        </span>
                        <span class="timepicker rec" id="rec_time2">
                            <input type="text" id="s_FindERegTime" name="s_FindERegTime" class="input_time">
                            <a href="#" class="btn_time">시간 선택</a>
                        </span>
                        <select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
                    </li>
                </ul>
            </div>
        </div>
        <div class="btns_top">
            <div class="sub_l">
                <strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount">0</span>
            </div>
            <button type="button" id="btnSearch" class="btn_m search">조회</button>
            <button type="button" id="btnReset" class="btn_m">초기화</button>
            <input type="hidden" id="s_FindSRecTime" name="s_FindSRecTime"/>
            <input type="hidden" id="s_FindERecTime" name="s_FindERecTime"/>
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