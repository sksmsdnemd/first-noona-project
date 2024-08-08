<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true"/>

    <!-- 순서에 유의 -->
    <script type="text/javascript" src="<c:url value="/scripts/security/rsa.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/scripts/security/jsbn.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/scripts/security/prng4.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/scripts/security/rng.js"/>"></script>

    <script>
        var tenantId;
        var sPopupOptions;
        var findUserId1;
        var findUserId2;
        var playIndex;

        var findSort1;
        var findSort2;

        $(function () {
            findUserId1 = '<spring:eval expression="@code['Globals.authUserId1']"/>';
            findUserId2 = '<spring:eval expression="@code['Globals.authUserId2']"/>';

            sPopupOptions = parent.gPopupOptions || {};
            sPopupOptions.get = function (key, value) {
                return this[key] === undefined ? value : this[key];
            };

            tenantId = sPopupOptions.tenantId;
            playIndex = sPopupOptions.playIndex;
            setting();

            $("#btnSavePop").click(function () {
                fnSavePop();
            })


        });

        function setting() {
            argoJsonSearchList('userInfo', 'getUserSaltValue'
                , 's_'
                , {
                    findUserId1: findUserId1
                    , findUserId2: findUserId2
                    , findTenantId: tenantId
                }
                , function (data, textStatus, jqXHR) {
                    try {
                        if (data.isOk()) {
                            if (data.getRows() != "") {
                                $.each(data.getRows(), function (index, row) {
                                    $("#groupId" + (index + 1)).text(row.groupName + " (" + row.userId + ")");
                                    console.log( (index + 1)+" : " + row.salt)
                                    var html = '<input type="hidden" name="ip_Salt' + (index + 1) + '" id="ip_Salt' + (index + 1) + '" value="' + row.salt + '" />'
                                        + '<input type="hidden" name="ip_UserId' + (index + 1) + '" id="ip_UserId' + (index + 1) + '" value="' + row.userId + '" />';
                                    $(".btn_l").append(html);
                                });

                            }
                        }
                    } catch (e) {
                        console.log(e);
                    }
                });

        }

        function fnSavePop() {


            var authAt;

console.log($("#ip_UserId1").val() + "     " + $("#ip_Salt1").val() +"     " + $("#findAuthUserPwd1").val())
console.log($("#ip_UserId2").val() + "     " + $("#ip_Salt2").val() +"     " + $("#findAuthUserPwd2").val())
            argoJsonSearchOne('userInfo', 'checkAuthUserPwd', '', {
                "findTenantId": tenantId,
                "findUserId1": $("#ip_UserId1").val(),
                "findUserId2": $("#ip_UserId2").val(),
                "findSalt1": $("#ip_Salt1").val(),
                "findSalt2": $("#ip_Salt2").val(),
                "findUserPwd1": $("#findAuthUserPwd1").val(),
                "findUserPwd2": $("#findAuthUserPwd2").val()
            }, function (data, textStatus, jqXHR) {
                try {
                    if (data.isOk()) {
                        if (data.getRows() != "") {
                            authAt = data.getRows()['authAt'];

                            if (authAt == "Y") {
                                argoAlert('warning', '인증완료되었습니다.', '', 'fnDetailInfoCallback()');
                            } else {
                                argoAlert("비밀번호를 다시 확인해주세요.");
                                return;
                            }
                        }
                    }
                } catch (e) {
                    argoAlert("청취 권한 인증 중 오류가 발생하였습니다.");
                    console.log(e);
                    return;
                }
            });

        }

        function fnDetailInfoCallback(data, textStatus, jqXHR) {
            try {
                if (playIndex != "undefinded" && playIndex != "") {
                    parent.fnRecFilePlay(playIndex);
                } else {
                    parent.fnMultiRecPlay();
                }
                argoPopupClose();

            } catch (e) {
                console.log(e);
            }
        }

    </script>
</head>
<body>
<div class="sub_wrap pop">
    <section class="pop_contents">
        <div class="pop_cont pt5">

            <div class="input_area" style="margin-top: 70px;">
                <table class="input_table">
                    <colgroup>
                        <col width="30%">
                        <col width="">
                        <col width="20%">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th id="groupId1"></th>
                        <td>
                            <input type="password" id="findAuthUserPwd1" name="findAuthUserPwd1" style="width:100%"/>
                            <input type="hidden" id="RSAModulus" name="RSAModulus" value="${RSAModulus}">
                            <input type="hidden" id="RSAExponent" name="RSAExponent" value="${RSAExponent}">
                        </td>
                        <td rowspan="2" style="text-align: center">
							<span class="btn_l">
								<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">인증</button>
                    		</span>
                        </td>
                    </tr>
                    <tr>
                        <th id="groupId2"></th>
                        <td>
                            <input type="password" id="findAuthUserPwd2" name="findAuthUserPwd2" style="width:100%"/>
                        </td>
                    </tr>
                    </tbody>
                </table>

            </div>
        </div>
    </section>
</div>
</body>

</html>


