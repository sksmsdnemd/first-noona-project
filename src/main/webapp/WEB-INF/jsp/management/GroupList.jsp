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
    <script src="<c:url value="/scripts/velocejs/convertListToTree.js"/>"></script>
    <script src="<c:url value="/scripts/jstree3.3.3/dist/jstree.js"/>"></script>
    <link rel="stylesheet" href="<c:url value="/scripts/jstree3.3.3/dist/themes/default/style.css"/>" type="text/css"/>

    <script>
        var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
        var tenantId = loginInfo.SVCCOMMONID.rows.tenantId;
        var userId = loginInfo.SVCCOMMONID.rows.userId;
        var grantId = loginInfo.SVCCOMMONID.rows.grantId;
        var workIp = loginInfo.SVCCOMMONID.rows.workIp;
        var workMenu = "그룹정보관리";
        var workLog = "";
        var dataArray;
        var duplchkAt = false;

        $(document).ready(function (param) {
            fnInitCtrl();
            fnSearchList();

        });

        //var fvKeyId;

        function fnInitCtrl() {
            argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
                "selectIndex": 0
            });

            fnAuthBtnChk(parent.$("#authKind").val());

            if (grantId != "SuperAdmin" && grantId != "SystemAdmin") {
                $("#div_tenant").hide();
            }

            $('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);

            $("#btnSearch").click(function () { //조회
                fnSearchList();
            });
            /*
                        $("#s_FindKey").change(function () {
                            var sSel = argoGetValue('s_FindKey');
                            if (sSel == "") {
                                $("#s_FindText").val("");
                            }
                        });*/

            $("#btnDelete").click(function () {
                removeNode();
            });

            $("#btnReset").click(function () {
                argoSetValue("s_FindGroupId", "");
                $('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
            });

            $("#layerTree").css("height", ($("#layerTree").parent().height() - 30) + "px");
            
         	// 슈퍼어드민/시스템어드민/매너지 권한유저만 소속별 권한부여 버튼 사용가능
    		if(grantId != "SuperAdmin" && grantId != "SystemAdmin" && grantId != "Manager"){
    		    $("#btnGroupGrantManage").remove();
    		}else{
    			$("#btnGroupGrantManage").css("display", "inline-block");
    		}
         	
    		$("#btnGroupGrantManage").click(function(){
    			argoPopupWindow( '그룹별 권한관리', 'GroupGrantManageF.do',  '1000', '600' ); 
    		});

            
        }


        function fnGroupUpadate() {
            if (duplchkAt) {
                fnSavePop();
            } else {
                argoAlert("그룹아이디 중복확인이 필요합니다.");
                return;
            }
        }

        function fnSavePop() {
            var aValidate;
            argoConfirm("저장 하시겠습니까?", function () {
                aValidate = {
                    rows: [
                        {
                            "check": "length",
                            "id": "ip_GroupName",
                            "minLength": 1,
                            "maxLength": 50,
                            "msgLength": "그룹이름을 다시 확인하세요."
                        }
                    ]
                };

                if (argoValidator(aValidate) != true) return;


                gGroupId = $("ip_GroupId").val();
                fnDetailInfoCallback();
            });
        }

        function fnDetailInfoCallback() {
            try {

                var Resultdata;

                $("#ip_InsId").val(userId);
                if (cudMode == "I") {

                    if( $("#ip_TopParentId").val() == '') {
                        $('#ip_TopParentId').val($('#ip_GroupDesc').val());

                    }

                    Resultdata = argoJsonUpdate("Group", "setGroupInsert", "ip_", {
                        "cudMode": cudMode,
                        tenantId: $('#s_FindTenantId option:selected').val()
                    });
//                     workLog = '[그룹ID:' + gGroupId + '] 등록';
                    workLog = '[그룹ID:' + argoGetValue('ip_GroupId') + '] 등록';

                } else {

                    $("#ip_UptId").val($("#ip_InsId").val());
                    Resultdata = argoJsonUpdate("Group", "setGroupUpdate", "ip_", {
                        "cudMode": cudMode,
                        "orgGroupId": orgGroupId,

                        tenantId: $('#s_FindTenantId option:selected').val()
                    });
                    workLog = '[그룹ID:' + argoGetValue('ip_GroupId') + '] 수정';

                }

                if (Resultdata.isOk()) {
                    argoJsonUpdate("actionLog", "setActionLogInsert", "", {
                        tenantId: tenantId,
                        userId: userId,
                        actionClass: "action_class",
                        actionCode: "W",
                        workIp: workIp,
                        workMenu: workMenu,
                        workLog: workLog
                    });
                    argoAlert("저장하였습니다");
                    fnSearchList();
                    $(".detail").addClass("hide");
                } else {
                    argoAlert("저장에 실패하였습니다");
                }
            } catch (e) {
                console.log(e);
            }
        }


        /** 그룹아이디 중복체크관련 **/
        var gGroupId;

        /** GroupId 수정 관련 : GroupId 중복확인 */
        function duplchk() {

            if ($("#ip_GroupId").val() == null || $("#ip_GroupId").val() == "") {
                argoAlert("그룹아이디를 입력하세요.")
                return;
            }

            argoJsonSearchOne('Group', 'getGroupIdCnt', '', {
                "tenantId": tenantId,
                "findGroupId": $("#ip_GroupId").val()
            }, function (data, textStatus, jqXHR) {

                try {
                    if (data.isOk()) {
                        if (data.getRows() != "") {
                            // 중복아이디 존재
                            if (data.getRows()['cnt'] > 0) {
                                duplchkAt = false;
                                argoAlert("존재하는 그룹ID입니다.<br/>다시한번 확인해주세요.");
                            } else {
                                argoAlert("사용가능한 그룹ID입니다.")
                                duplchkAt = true;
                            }


                        }
                    }
                } catch (e) {
                    console.log(e);
                }
            });
        }
    </script>
    <script>

        var openAt = true;

        $(function () {
            /**Node Onclick Event*/
            $("#layerTree").on("click", ".jstree-anchor", function (e) {
                var id = $("#layerTree").jstree(true).get_node($(this)).id;
                var node = $('#layerTree').jstree(true).get_node(id);
                setDetailTable(node,"U");

            });

            $(".clickSearch").keyup(function () {
                var searchString = $(this).val();
                $('#layerTree').jstree('search', searchString);
            });


            /** 노드 위치 변경 이벤트 */
            /* $("#layerTree").bind('move_node.jstree', function (e, data) {

                var pNodeId = data.parent;
                var pNodeData = $('#layerTree').jstree(true).get_node(pNodeId);


                // 최상위로 이동 불가
                if (pNodeId == '#') {
                    argoAlert("최상위 그룹과 같은 레벨로는 지정이 불가합니다.");
                    $("#layerTree").jstree(true).refresh();
                    return;
                }

                argoConfirm(data.node.text + '를 ' + pNodeData.original.text + '의 하위부서로 이동하겠습니까?', function () {
                        changeParentId(data);
                    }, function () {
                        // 취소누를 시 tree refresh
                        $("#layerTree").jstree(true).refresh();
                    }
                );


            }); */
        });


        /** 노드 이동시 상위부서 변경 */
        function changeParentId(obj) {
            Resultdata = argoJsonUpdate("Group", "setParentIdUpdate", "", {
                groupId: obj.node.id
                , parentId: obj.parent
                , tenantId: $('#s_FindTenantId option:selected').val()
            });
            workLog = '[그룹ID:' + obj.node.id + '] 위치변경';

            fnSearchList();
        }

        function fnSearchList() {
        	var json = [];
        	setJsTree(json);
            argoJsonSearchList('Group', 'getGroupList', 's_', {}, function (data, textStatus, jqXHR) {
                try {
                    if (data.isOk()) {
                        // $("#tbody").empty();

                        if (data.getRows() != "") {
                            var json = [];

                            // 트리 open된 상태로 그리기
                            var state = {}
                            state.opened = true;

                            $.each(data.getRows(), function (index, row) {

// console.log("index : " + index);
                                var arrayData = {};
                                arrayData.id            = row.groupId;
                                arrayData.groupName     = row.groupName;
                                arrayData.pid           = row.parentId;
                                arrayData.groupLevel    = row.groupLevel;
                                arrayData.parentName    = row.parentName;
                                arrayData.groupDesc     = row.groupDesc;
                                arrayData.topParentId   = row.topParentId;
                                arrayData.cudMode       = "U";
                                arrayData.state         = state;
                                arrayData.text          = '[' + row.groupId + '] ' + row.groupName;

                                json.push(arrayData);

                            });

                            var treeJson = convertListToTree(json);

                            setJsTree(treeJson);
                        } else {
                            argoAlert('조회 결과가 없습니다.');
                        }
                    }

                } catch (e) {
                    console.log(e);
                }
                workLog = '[TenantId:' + tenantId + ' | UserId:' + userId + ' | GrantId:' + grantId + '] 조회';
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


        /** jsTree Settings */
        function setJsTree(json) {

            $('#layerTree').jstree({
                "plugins": ["checkbox", "changed", "dnd", "search", "contextmenu"],
                'core': {
                    'data': json,
                    check_callback: true
                },
                "themes": {
                    "theme": "default"
                },
                'checkbox': {
                    whole_node: false
                    , cascade: ""
                    , three_state: false

                },
                "search": {
                    "show_only_matches": true,
                    "search_callback": function (str, node) {
                        var word, words = [];
                        var searchFor = str.toLowerCase().replace(/^\s+/g, '').replace(/\s+$/g, '');
                        if (searchFor.indexOf(' ') >= 0) {
                            words = searchFor.split(' ');
                        } else {
                            words = [searchFor];
                        }
                        for (var i = 0; i < words.length; i++) {
                            word = words[i];
                            if ((node.text || "").toLowerCase().indexOf(word) >= 0) {
                                return true;
                            }
                        }
                        return false;
                    }
                }
                ,"contextmenu": {
                    "items": {
                        "create": {
                            "separator_before": false,
                            "separator_after": false,
                            "label": "새 그룹 추가",
                            "action": function (obj) {
                                this.addJsTree(obj);
                            },
                            "_disabled": true
                            
                        },
                        "remove": {
                            "separator_before": false,
                            "separator_after": true,
                            "label": "삭제",
                            "action": function (obj) {
                                this.removeNode(obj);
                            },
                        	"_disabled": true
                        }
                    }
                } 
            });

            $('#layerTree').jstree(true).settings.core.data = json;
            $('#layerTree').jstree(true).refresh();

        }

        /*Node Add*/
        function addJsTree(obj) {

            var newNode = {state: "open", text: "새 그룹"};
            var position = 'last';
            var selNode = $('#layerTree').jstree('get_selected');

            if(selNode.length > 1 ){
                argoAlert("하나의 그룹만 선택해주세요.");
                return;
            }

            if(selNode.length == 0) {
                 setDetailTable({parent:null},"I");
                 return;
            }

            var pNode = $('#layerTree').jstree(true).get_node(selNode);
            // if (pNode.original.pid == undefined) {
            //     argoAlert('지정되지 않은 그룹에 새 그룹을 추가할 수 없습니다.');
            //     return;
            // }

//             $('#layerTree').jstree("create_node", parent, newNode, position, function (new_node) {
                /* 새 그룹이 추가 된 부모Node 열기 */
                $('#layerTree').jstree("open_node", $('#layerTree').jstree("get_selected"));

                /* 현재 선택된 Node 선택 해제 하고, 새 그룹에 Focus */
//                 $('#layerTree').jstree("deselect_node", parent);
                $('#layerTree').jstree("select_node", selNode);
                setDetailTable({"parent":selNode},"I");
//             });
        }

        function showAll() {

            if (openAt) {
                $('#layerTree').jstree('close_all');
                openAt = false;
                $("#btnOpen").text("전체열기");

            } else {
                $('#layerTree').jstree('open_all');
                openAt = true;
                $("#btnOpen").text("전체닫기");

            }
        }


        /** ROW ONCLICK 시 DETAIL TABLE에 값 세팅  */
        var cudModea;
        var orgGroupId;

        function setDetailTable(row,pCudMode) {
            $(".detail").removeClass("hide");
            cudMode = pCudMode;
            if (cudMode == "U") {
            	$("#btnUpdate").text('수정');
            	// 상위부서가 없을때
                if (row.original.groupLevel == 1) {
                    $("#td_parentGroupNm").html('');
                } else {
                    $("#td_parentGroupNm").html('[' + row.original.pid + '] ' + row.original.parentName);
                }
            	
                /* cudMode==U : 값 세팅 */
                orgGroupId = row.original.id;
                $("#ip_GroupId").val(row.original.id);
                $("#ip_GroupName").val(row.original.groupName);
                $("#ip_GroupDesc").val(row.original.groupDesc);
                $("#ip_ParentId").val(row.original.pid);
                $("#ip_TopParentId").val(row.original.topParentId);

                duplchkAt = true;
                $("#btnDuplchk").hide();
            } else {
            	$("#btnUpdate").text('등록');
                var pNode = $('#layerTree').jstree(true).get_node(row.parent);
                if(pNode.parent == null){
                    $("#td_parentGroupNm").html('');
                    $("#ip_GroupId").val('');
                    $("#ip_GroupName").val('');
                    $("#ip_GroupDesc").val('');
                    $("#ip_ParentId").val('0');
                    $("#ip_TopParentId").val('');
                }else{
                    if (pNode.original.id != "" && pNode.original.id != null) {
                        $("#td_parentGroupNm").html('[' + pNode.original.id + '] ' + pNode.original.groupName);
                        $("#ip_GroupId").val('');
                        $("#ip_GroupName").val('');
                        $("#ip_GroupDesc").val('');
                        $("#ip_ParentId").val(pNode.original.id);
                        $("#ip_TopParentId").val(pNode.original.topParentId);
                    }
                }
                duplchkAt = false;
                $("#btnDuplchk").show();
            }
            
            // Update 화면 일 시, gGroupId 랑 입력 GroupId 가 다를때만 중복체크 활성화
            $("#ip_GroupId").on("keyup", function () {
//                 $(this).val($(this).val().replace(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/g, ''));

                if (cudMode == "U") {
                    if ($("#ip_GroupId").val() != orgGroupId) {
                        duplchkAt = false;
                        $("#btnDuplchk").show();
                    } else {
                        duplchkAt = true;
                        $("#btnDuplchk").hide();
                    }
                }
            });

        }

        function removeNode() {

            try {
                var selectedGroupList = new Array();
                var arrSelected = $("#layerTree").jstree(true).get_selected('full', true);

                $.each(arrSelected, function (index, item) {
                    if (!selectedGroupList.includes(item.id)) {
                        selectedGroupList.push(item.id);

                        if (item.children_d.length > 0) {
                            var arr = new Array()
                            $.each(item.children_d, function (idx, it) {
                                arr.push(it);
                            })
                            selectedGroupList = selectedGroupList.concat(arr);
                        }
                    }
                })

                if (selectedGroupList.length == 0) {
                    argoAlert("선택된 그룹이 없습니다.");
                    return;
                }


                argoConfirm("선택 그룹에 하위 그룹이 존재하는 경우,<br/>하위그룹도 함께 삭제됩니다.<br/>그룹을 삭제하시겠습니까?", function () {
                    var multiService = new argoMultiService(fnCallbackDelete);
                    //
                    for (var i = 0; i < selectedGroupList.length; i++) {
                        gGroupId = selectedGroupList[i];
                        var param = {
                            "findGroupId": selectedGroupList[i],
                            "findTenantId": $('#s_FindTenantId option:selected').val()
                        };


                        multiService.argoDelete("Group", "deleteGroupList", "", param);
                    }

                    multiService.action();
                });

            } catch (e) {
                console.log(e);
            }
        }


        function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
            try {
                if (Resultdata.isOk()) {
                    workLog = '[그룹ID:' + gGroupId + '] 삭제';
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
                    fnSearchList();
                }
            } catch (e) {
                argoAlert(e);
            }
        }
        
		$(window).resize(function() {
			$("#layerTree").css("height", ($("#layerTree").parent().height() - 30) + "px");
		});
    </script>


</head>
<body>
<div class="sub_wrap">
    <div class="location"><span class="location_home">HOME</span><span class="step">운용관리</span><span
            class="step">사용자관리</span><strong class="step">그룹정보관리</strong></div>
    <section class="sub_contents">
        <div class="search_area row2">
            <div class="row" id="div_tenant">
                <ul class="search_terms">
                    <li>
                        <strong class="title ml20">태넌트</strong>
                        <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px"
                                class="list_box"></select>
                        <input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText"
                               style="width:150px;display:none"/>
                        <input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none"
                               value="1">
                    </li>
                </ul>
            </div>

            <div class="row">
                <ul class="search_terms">
                    <li>
                        <strong class="title ml20">그룹 ID/그룹 명</strong>
                        <input type="text" id="s_FindGroupId" name="s_FindGroupId" style="width:150px"
                               class="clickSearch "/>
                    </li>
                    <%--                    <li>--%>
                    <%--                        <strong class="title ml20">그룹명</strong>--%>
                    <%--                        <input type="text" id="s_FindGroupName" name="s_FindGroupName" style="width:150px"--%>
                    <%--                               class="clickSearch"/>--%>
                    <%--                    </li>--%>
                </ul>
            </div>
        </div>
        <div class="btns_top">
        	<div class="sub_l">
				<button type="button" class="btn_m" id="btnGroupGrantManage" style="display: none;" >그룹별 권한관리</button>
			</div>
        
            <button type="button" id="btnSearch" class="btn_m search">조회</button>
            <!-- <button type="button" id="btnAdd" class="btn_m search" onclick="addJsTree()" style="display: none;">등록</button> -->
            <%--            <button type="button" id="btnAdd" class="btn_m confirm">등록</button>--%>
            <!-- <button type="button" id="btnDelete" class="btn_m confirm" style="display: none;">삭제</button> -->
            <button type="button" id="btnReset" class="btn_m">초기화</button>
        </div>


        <div class="table_grid tree"
             style="position:absolute;width: 49%; margin-top :10px; height: 70%; border:1px solid #e3e3e3">
            <button type="button" id="btnOpen" class="btn_m" onclick="showAll()">전체닫기</button>
            <div id="layerTree" style="display: block;  height: 100%; overflow: auto;"></div>
        </div>


        <div class="table_grid detail hide"
             style="position:absolute;width: 49%; margin-top :10px; height: 70%; border:none; right: 0px; background: #ffffff;">
            <div class="btns_top">
                <button type="button" id="btnUpdate" class="btn_m confirm" onclick="javascript:fnGroupUpadate();" style="display: none;">수정</button>
            </div>
            <div class="table_head"
                 style="height: 100%; border-left:none; border-right: none; border-bottom: none; background: #ffffff;">

                <table id="detailTable">
                    <colgroup>
                        <col width="30%">
                        <col>
                    </colgroup>
                    <tr>
                        <th>상위그룹명</th>
                        <td id="td_parentGroupNm" style="text-align: left; padding-left: 10px"></td>
                    </tr>
                    <tr>
                        <th>그룹아이디</th>
                        <td style="text-align: left;padding-left: 10px">
                            <input type="text" id="ip_GroupId" name="ip_GroupId" value=""  readonly="readonly"/>
                            <button type="button" class="btn_m" onclick="javascript:duplchk()" id="btnDuplchk">중복확인
                            </button>
                        </td>
                    </tr>
                    <tr>

                        <th>그룹명</th>
                        <td style="text-align: left; padding-left: 10px">
                            <input type="text" id="ip_GroupName" name="ip_GroupName" value=""/></td>
                    </tr>
                    <tr>
                        <th>그룹설명</th>
                        <td style="padding-left: 10px"><textarea id="ip_GroupDesc" name="ip_GroupDesc"
                                                                 style="border: none; height: 200px"></textarea></td>
                    </tr>
                    <input type="hidden" id="ip_ValueTitleId" name="ip_ValueTitleId" value=""/>
                    <input type="hidden" id="ip_GroupMngId" name="ip_GroupMngId" value=""/>
                    <input type="hidden" id="ip_TopParentId" name="ip_TopParentId" value=""/>
                    <input type="hidden" id="ip_ParentId" name="ip_ParentId" value=""/>
                    <input type="hidden" id="ip_InsId" name="ip_InsId" value=""/>
                    <input type="hidden" id="ip_UptId" name="ip_UptId" value=""/>
                </table>


            </div>
        </div>
    </section>

</div>

</body>

</html>
