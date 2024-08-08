<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
    <jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true"/>

    <script>

        var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
        var tenantId = loginInfo.SVCCOMMONID.rows.tenantId;
        var userId = loginInfo.SVCCOMMONID.rows.userId;
        var grantId = loginInfo.SVCCOMMONID.rows.grantId;
        var workIp = loginInfo.SVCCOMMONID.rows.workIp;
        var workMenu = '내선패턴관리';
        var workLog = "";
        var dataArray = new Array();

        $(document).ready(function () {

            fnInitCtrl();
            fnInitGrid();
            fnSearchListCnt();
        });

        var fvKeyId;

        function fnSetSubCb(kind) {
            if (kind == "system") {
                if ($('#s_FindSystemId option:selected').val() == '') {
                    $("#s_FindProcessId").find("option").remove();
                } else {
                    argoCbCreate("s_FindProcessId", "comboBoxCode", "getProcessList", {
                        findSystemId: $('#s_FindSystemId option:selected').val(),
                        FindProcessName: "MRU"
                    }, {"selectIndex": 0, "text": '선택하세요!', "value": ''});
                }
            }
        }

        function fnInitCtrl() {


            argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
                "selectIndex": 0,
                "text": '선택하세요!',
                "value": ''
            });
            $("#s_FindTenantId").val(tenantId).attr("selected", "selected");

            argoCbCreate("s_FindSystemId", "comboBoxCode", "getMruSystemList", {}, {
                "selectIndex": 0,
                "text": '선택하세요!',
                "value": ''
            });

            if (grantId != "SuperAdmin" && grantId != "SystemAdmin") {
                $("#div_tenant").hide();
            }

            $("#s_FindTenantId").change(function () {
                fnSetSubCb('tenant');
            });
            $("#s_FindSystemId").change(function () {
                fnSetSubCb('system');
            });

            $("#btnSearch").click(function () { //조회
                fnSearchListCnt();
            });


            $("#btnAdd").click(function () {
                fvKeyId = "";
                gPopupOptions = {cudMode: "I", sTenantId: $('#s_FindTenantId option:selected').val()};
                argoPopupWindow('내선패턴등록', 'DnPtrnPopupEditF.do', '800', '300');
            });

            $("#btnDelete").click(function () {
                fnDeleteList();
            });

            $("#btnReset").click(function () {

                $('#s_FindSystemId option[value=""]').prop('selected', true);
                $("#s_FindProcessId").find("option").remove();
                $('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
            });

            $(".clickSearch").keydown(function (key) {
                if (key.keyCode == 13) {
                    fnSearchListCnt();
                }
            });


        }

        function fnInitGrid() {
            $('#gridList').w2grid({
                name: 'grid',
                show: {
                    lineNumbers: true,
                    footer: true,
                    selectColumn: true
                },
                onDblClick: function (event) {
                    var record = this.get(event.recid);
                    if (record.recid >= 0) {
                        gPopupOptions = {
                            cudMode: 'U',
                            pRowIndex: record,
                        };
                        argoPopupWindow('내선패턴수정', 'DnPtrnPopupEditF.do', '800', '300');
                    }
                },
                columns: [{field: 'recid', caption: 'recid', size: '0%', attr: 'align=center', sortable: true}
                    , {field: 'ptrnId', caption: '패턴ID', size: '10%', attr: 'align=center'}
                    , {field: 'tenantId', caption: '태넌트ID', size: '10%', attr: 'align=center'}
                    , {field: 'systemId', caption: '시스템ID', size: '10%', attr: 'align=center'}
                    , {field: 'systemName', caption: '시스템 명', size: '10%', attr: 'align=center', sortable: true}
                    , {field: 'processId', caption: '프로세스 ID', size: '10%', attr: 'align=center'}
                    , {field: 'processName', caption: '프로세스 명', size: '10%', attr: 'align=center'}
                    , {field: 'ipPattern', caption: 'IP 패턴', size: '20%', attr: 'align=center'}
                    , {field: 'dnPattern', caption: '내선번호 패턴', size: '20%', attr: 'align=center'}
                    , {field: 'excpPtrnAt', caption: '예외패턴여부', size: '10%', attr: 'align=center'}
                    , {field: 'startIp', caption: '시작IP', size: '7%', attr: 'align=center' , hidden:true}
                    , {field: 'endIp', caption: '종료IP', size: '7%', attr: 'align=center', hidden:true}
                    , {field: 'startDnNo', caption: '시작내선번호', size: '7%', attr: 'align=center', hidden:true}
                    , {field: 'endDnNo', caption: '종료내선번호', size: '7%', attr: 'align=center', hidden:true}
                    , {field: 'stateIp', caption: '대역구분', size: '7%', attr: 'align=center', hidden:true}
                ],
                records: dataArray
            });
            w2ui['grid'].hideColumn('recid','ptrnId');
        }


        function fnSearchListCnt() {


            argoJsonSearchOne('userTel', 'getDnPtrnCount', 's_', {}, function (data, textStatus, jqXHR) {
                try {
                    if (data.isOk()){
                        var totalData = data.getRows()['cnt'];
                        paging(totalData, "1");
                        $("#totCount").html(totalData);

                        if (totalData == 0) {
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
            argoJsonSearchList('userTel', 'getDnPtrnList', 's_', {
                "iSPageNo": startRow,
                "iEPageNo": endRow
            }, function (data, textStatus, jqXHR) {

                try {
                    if (data.isOk()) {
                        w2ui.grid.clear();
                        if (data.getRows() != "") {
                            var excpPtrnAt;
                            dataArray = [];

                            $.each(data.getRows(), function (index, row) {
                                if (row.excpPtrnAt == "1")
                                    excpPtrnAt = "O";
                                else excpPtrnAt = "";

                                gridObject = {
                                    "recid": index
                                    , "ptrnId" : row.ptrnId
                                    , "tenantId": row.tenantId
                                    , "systemId": row.systemId
                                    , "systemName": row.systemName
                                    , "processId": row.processId
                                    , "processName": row.processName
                                    , "ipPattern": row.startIp != null && row.startIp != ''? row.startIp + ' ~ ' + row.endIp : ''
                                    , "dnPattern":  row.startDnNo != null && row.startDnNo != ''? row.startDnNo + ' ~ ' + row.endDnNo : ''
                                    , "excpPtrnAt": excpPtrnAt
                                    , "startIp": row.startIp
                                    , "endIp": row.endIp
                                    , "startDnNo": row.startDnNo
                                    , "endDnNo": row.endDnNo
                                    , "stateIp": row.stateIp
                                };

                                dataArray.push(gridObject);

                            });
                            w2ui['grid'].add(dataArray);
                        }

                    }
                } catch (e) {
                    console.log(e);
                }

                workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
                    + ' | GrantId:' + grantId + '] 조회';
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


        /** 선택된 내선패턴 삭제 */
        function fnDeleteList() {
            try {
                var arrChecked = w2ui['grid'].getSelection();

                if (arrChecked.length == 0) {
                    argoAlert("삭제할 항목을 선택하세요");
                    return;
                }

                argoConfirm('선택한 항목 ' + arrChecked.length + '건을  삭제하시겠습니까?', function () {

                    var multiService = new argoMultiService(fnCallbackDelete);

                    $.each(arrChecked, function (index, value) {
                        var selectPtrnId = w2ui['grid'].getCellValue(value, 1);
                        var param = {
                            "ptrnId": selectPtrnId
                        };
                        workLog = '[내선패턴] 삭제';
                        multiService.argoDelete("userTel", "deleteDnPtrn", "__", param);
                    });
                    multiService.action();
                });

            } catch (e) {
                console.log(e);
            }
        }

        /** 내선패턴 삭제 후 처리 */
        function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
            try {
                if (Resultdata.isOk()) {
                    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
                        tenantId: tenantId,
                        userId: userId,
                        actionClass: "action_class",
                        actionCode: "W",
                        workIp: workIp,
                        workMenu: workMenu,
                        workLog: workLog
                    });
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
    <div class="location">
        <span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">사용자관리</span><strong
            class="step">내선패턴관리</strong>
    </div>
    <section class="sub_contents">
        <div class="search_area row2" id="searchPanel">
            <div class="row" id="div_tenant">
                <ul class="search_terms">
                    <li>
                        <strong class="title ml20">태넌트</strong>
                        <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
                    </li>
                </ul>
            </div>
            <div class="row" id="div_system">
                <ul class="search_terms">
                    <li>
                        <strong class="title ml20">시스템</strong>
                        <select id="s_FindSystemId" name="s_FindSystemId" style="width: 150px;"
                                class="check_box"></select>
                    </li>
                    <li>
                        <strong class="title">프로세스</strong>
                        <select id="s_FindProcessId" name="s_FindProcessId" style="width: 150px;" class="list_box"
                                title="프로세스에 해당하는 시스템을 먼저 선택하세요!"></select>
                    </li>
                </ul>
            </div>
        </div>
        <div class="btns_top">
            <div class="sub_l">
                <strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount"></span>
            </div>
            <button type="button" id="btnSearch" class="btn_m search">조회</button>
            <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
            <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
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