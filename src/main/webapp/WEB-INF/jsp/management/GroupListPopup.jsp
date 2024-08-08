<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true"/>
    <style>
        .table_grid.tree tr td {
            padding: 0 10px;
            border: none;
        }
    </style>
    <script>

        var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
        var workIp = loginInfo.SVCCOMMONID.rows.workIp;
        var userId2 = loginInfo.SVCCOMMONID.rows.userId;
        var workMenu = "그룹정보관리";
        var workLog = "";


        var gGroupId;
        var tenantId;
        var sPopupOptions;
        var gGroupName;
        $(function () {

            sPopupOptions = parent.gPopupOptions || {};
            sPopupOptions.get = function (key, value) {
                return this[key] === undefined ? value : this[key];
            };

            gGroupId = sPopupOptions.groupId;
            tenantId = sPopupOptions.tenantId;

            fnSearchList();


            $("#btnSavePop").click(function () {
                changeParentId();
            })

        });
        var selectedGroupId;

        function changeParentId() {
            selectedGroupId = $("input:radio[name=selectParentId]:checked").val();
            var selectedGroupName = "";

            $("input#groupId").each(function () {
                if ($(this).val() == selectedGroupId) {
                    selectedGroupName = $(this).next().val();
                    return;
                }
            })
            argoConfirm("[" + gGroupName + "] 의 상위그룹을 <br/>[" + selectedGroupName + "] 로 변경하시겠습니까?", function () {
                fnDetailInfoCallback();
            });


        }

        function fnDetailInfoCallback() {
            var Resultdata = argoJsonUpdate("Group", "setParentIdUpdate", "s_", {
                selectedGroupId: selectedGroupId,
                groupId: gGroupId,
                tenantId: tenantId
            });


            if (Resultdata.isOk()) {
                argoAlert('warning', '성공적으로 저장 되었습니다.', '', 'parent.fnSearchList(); argoPopupClose();');
            } else {
                argoAlert("저장에 실패하였습니다");
            }
        }

        function fnSearchList() {


            argoJsonSearchList('Group', 'getGroupList', 's_', {"findTenantId": tenantId}, function (data, textStatus, jqXHR) {
                try {
                    if (data.isOk()) {

                        $("#sTbody").empty();

                        if (data.getRows() != "") {
                            var groupName = "";

                            $.each(data.getRows(), function (index, row) {

                                if (row.childCnt > 0) {
                                    groupName = '<td style="text-align: left" onclick="javascript:change(this)"><span style="margin-left:' + row.groupLevel * 15 + 'px;"><img src="../images/icon_selectArrow.png"></span>' + ' [' + row.groupId + '] ' + row.groupName;
                                } else {
                                    groupName = '<td style="text-align: left" onclick="javascript:change(this)"><span style="margin-left:' + row.groupLevel * 20 + 'px;"></span> ' + ' [' + row.groupId + '] ' + row.groupName;
                                }
                                if (row.groupId == gGroupId) {
                                    groupName += ' <img src="../images/icon_calendar_l.png">';
                                    gGroupName = row.groupName;
                                }

                                var html = '<input type="hidden" id="parentName" value="' + row.parentName + '" />'
                                    + '<input type="hidden" id="parentId" value="' + row.parentId + '" />'
                                    + '<input type="hidden" id="topParentId" value="' + row.topParentId + '" />'
                                    + '<input type="hidden" id="groupId" value="' + row.groupId + '" />'
                                    + '<input type="hidden" id="groupName" value="' + row.groupName + '" />'
                                    + '<input type="hidden" id="groupDesc" value="' + row.groupDesc + '" />'
                                    + '<input type="hidden" id="sort" value="' + row.sort + '" />'

                                groupName += html;
                                groupName += '</td>'

                                var $tr = $("<tr></tr>");
                                var td_radio = '<td></td>';

                                // console.log(row.sort);
                                if ((row.sort).indexOf(gGroupId) == -1) {
                                    td_radio = '<td><input type="radio" name="selectParentId" id="radio_' + row.groupId + '" value="' + row.groupId + '" /></td>';
                                }

                                $tr.append(td_radio).append(groupName);

                                $("#sTbody").append($tr);


                            });

                        }
                    }
                    // w2ui['grid'].select(pos);
                } catch (e) {
                    console.log(e);
                }
            });
        }

        function change(obj) {
            var groupId = $(obj).find("#groupId").val();

            // 자신의 하위부서로는 이동할 수 없음
            if ($(obj).find("#sort").val().indexOf(gGroupId) == -1) {
                $("#radio_" + groupId).prop("checked", true);
            }

        }

    </script>
</head>
<body>
<div class="sub_wrap pop">
    <section class="pop_contents">
        <div class="pop_cont pt5">
            <div class="btn_topArea">
					<span class="btn_r">
						<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop"
                                style="font-size:10px">저장</button>
                    </span>
            </div>
            <div class="table_grid tree" style="height: 100%; border:1px solid #e3e3e3">
                <div class="table_head" style="height: 100%;background: #ffffff;">
                    <table class="table-hover">
                        <colgroup>
                            <col width="10px;"/>
                            <col width=""/>

                        </colgroup>
                        <thead>
                        <tr>
                            <th colspan="3">그룹리스트</th>
                        </tr>
                        </thead>
                        <tbody id="sTbody">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </section>
</div>
</body>

</html>


