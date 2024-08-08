<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
    <style>
        .btn_type1 {
            font-size:12px;
            height:19px;
            padding:0 5px 0 5px;
        }
    </style>
    <script>

        var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
        var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
        var userId    	= loginInfo.SVCCOMMONID.rows.userId;
        var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
        var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
        var workMenu 	= "그룹정보관리";
        var workLog 	= "";
        var dataArray;

        $(document).ready(function(param) {
            fnInitCtrl();
            fnInitGrid();
            fnSearchList();
        });

        var fvKeyId ;

        function fnInitCtrl(){

            argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});

            fnAuthBtnChk(parent.$("#authKind").val());

            if(grantId != "SuperAdmin" && grantId != "SystemAdmin"){
                $("#div_tenant").hide();
            }

            $('#s_FindTenantId option[value="'+tenantId+'"]').prop('selected', true);

            $("#btnSearch").click(function(){ //조회
                fnSearchList();
            });

            $("#s_FindKey").change(function(){
                var sSel = argoGetValue('s_FindKey');
                if(sSel == ""){
                    $("#s_FindText").val("");
                }
            });

            $("#btnDelete").click(function(){
                fnDeleteList();
            });

            $("#btnReset").click(function(){
                argoSetValue("s_FindGroupId", "");
                argoSetValue("s_FindGroupName", "");
                $('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
            });

            $(".clickSearch").keydown(function(key){
                if(key.keyCode == 13){
                    fnSearchList();
                }
            });

            $("#btnAdd").click(function(){
                gPopupOptions = {cudMode:"I", groupId:"0", tenantId:$('#s_FindTenantId option:selected').val(), userId:userId, "parentId":"0", "topParentId":"1", "depth":""};
                argoPopupWindow('그룹등록', 'GroupPopupEditF.do', '680', '270');
            });
        }

        function subAdd(idx){
            var parentId    = w2ui['grid'].getCellValue(idx, 2);
            var topParentId = w2ui['grid'].getCellValue(idx, 3);
            var curGroupId  = w2ui['grid'].getCellValue(idx, 4);
            var curDepth    = w2ui['grid'].getCellValue(idx, 5);

            gPopupOptions = {cudMode:"I", groupId:curGroupId, tenantId:$('#s_FindTenantId option:selected').val(), userId:userId, "parentId":parentId, "topParentId":topParentId, "depth":curDepth};
            argoPopupWindow('하위그룹등록', 'GroupPopupEditF.do', '680', '270');
        }

        function subChangePos(idx, dir){
            var parentId      = w2ui['grid'].getCellValue(idx, 2);
            var topParentId   = w2ui['grid'].getCellValue(idx, 3);
            var curGroupId 	  = w2ui['grid'].getCellValue(idx, 4);
            var curDepth 	  = w2ui['grid'].getCellValue(idx, 5);
            var curGroupName  = w2ui['grid'].getCellValue(idx, 7);

            var destGroupId   = w2ui['grid'].getCellValue(idx+dir, 4);
            var destDepth 	  = w2ui['grid'].getCellValue(idx+dir, 5);
            var destGroupName = w2ui['grid'].getCellValue(idx+dir, 7);

            var JobContent	  = curGroupName + "(" + curGroupId.trim() + ") -> " + destGroupName + "(" + destGroupId.trim() + ")";

            try {
                argoConfirm(JobContent + "위치를 이동 하시겠습니까?", function(){

                    Resultdata = argoJsonUpdate("Group", "setGroupChangeUpdate", "ip_", {"tenantId":$('#s_FindTenantId option:selected').val(), "adminId":userId,
                        "srcGroupId":curGroupId, "srcDepth":curDepth, "destGroupId":destGroupId, "destDepth":destDepth});

                    if(Resultdata.isOk()) {
                        argoJsonUpdate("Group", "setGroupChangeUpdate2", "ip_", {"tenantId":$('#s_FindTenantId option:selected').val(), "adminId":userId,
                            "srcGroupId":curGroupId, "srcDepth":curDepth, "destGroupId":destGroupId, "destDepth":destDepth});

                        argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId,
                            actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:"그룹정보관리", workLog:"[그룹:" + JobContent + "] 위치이동"});

                        argoAlert('warning', '성공적으로 저장 되었습니다.', '');
                        //argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
                        fnSearchList(idx+dir);

                    }else {
                        argoAlert("저장에 실패하였습니다");
                    }
                });
            } catch (e) {
                console.log(e);
            }

            //w2ui.grid.selectAll();
            //w2ui['grid'].select();
            //gPopupOptions = {cudMode:"I",groupId:gGroupId,tenantId:tenantId,userId:agentId,"parentId":parentId,"topParentId":topParentId,"depth":depth} ;
            //argoPopupWindow('하위그룹이동', 'GroupPopupChangePosF.do',  '800', '600' );
        }

        function fnInitGrid()
        {
            $('#gridList').w2grid(
                {
                    name: 'grid',
                    show: {
                        lineNumbers: true,
                        footer: true,
                        selectColumn: true
                    },
                    multiSelect: true,
                    onDblClick: function(event) {
                        var record = this.get(event.recid);
                        if(record.recid >= 0 )
                        {
                            var groupId		= w2ui['grid'].getCellValue(event.recid, 4);
                            gPopupOptions 	= {cudMode:'U', groupId: groupId,  tenantId:$('#s_FindTenantId option:selected').val(), pRowIndex:record};
                            argoPopupWindow('하위그룹수정', 'GroupPopupEditF.do', '680', '270');
                        }
                    },
                    columns: [
                        { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, 	attr: 'align=center' }
                        ,{ field: 'tenantId', 		caption: 'tenantId', 	size: '0%', 	sortable: true, 	attr: 'align=center' }
                        ,{ field: 'parentId', 		caption: 'parentId', 	size: '0%', 	sortable: true, 	attr: 'align=center' }
                        ,{ field: 'topParentId', 	caption: 'topParentId', size: '0%', 	sortable: true, 	attr: 'align=center' }
                        ,{ field: 'groupId', 		caption: '그룹ID', 		size: '10%', 	sortable: false, 	attr: 'align=center' }
                        ,{ field: 'depth', 		    caption: 'depth', 		size: '0%', 	sortable: true, 	attr: 'align=center' }
                        ,{ field: 'groupNameTree',	caption: '그룹명', 		size: '30%', 	sortable: false, 	attr: 'align=left'   }
                        ,{ field: 'groupName', 		caption: '그룹명', 		size: '0%', 	sortable: true, 	attr: 'align=left'   }
                        ,{ field: 'groupMngId', 	caption: '그룹대표ID', 		size: '10%', 	sortable: false, 	attr: 'align=center' }
                        ,{ field: 'groupDesc', 		caption: '설명', 			size: '20%', 	sortable: false, 	attr: 'align=center' }
                        ,{ field: 'subButton', 		caption: '하부', 			size: '10%', 	sortable: false, 	attr: 'align=center' }
                        ,{ field: 'moveButton', 	caption: '위치이동', 		size: '20%', 	sortable: false, 	attr: 'align=center' }
                    ],
                    records: dataArray
                });

            w2ui['grid'].hideColumn('recid', 'tenantId', 'topParentId', 'depth', 'parentId', 'groupName');
        }

        function fnSearchList(pos){

            $("#btnAdd").hide();

            argoJsonSearchList('Group', 'getGroupList', 's_', {}, function (data, textStatus, jqXHR){
                try{
                    if(data.isOk()){
                        w2ui.grid.clear();
                        if (data.getRows() != ""){

                            dataArray     = new Array();
                            var subMove   = "";
                            var subAdd    = "";
                            var groupName = "";

                            $.each(data.getRows(), function( index, row )
                            {
                                subMove = "";
                                if (index > 1)  {
                                    subMove = subMove + ' <button type="button" id="sub" class="btn_m btn_type1" onclick="javascript:subChangePos(' + index + ',-1);"><img src="../images/ico_arr_top.gif" style="height: 12px;">&nbsp;위로</button>';
                                }

                                if (index > 0 && index < (data.getProcCnt()-1))
                                {
                                    subMove = subMove + ' <button type="button" id="sub" class="btn_m btn_type1" onclick="javascript:subChangePos(' + index + ',1);">아래로&nbsp;<img src="../images/ico_arr_down.gif" style="height: 12px;"></button>';
                                }

                                subAdd = ' <button type="button" id="sub" class="btn_m btn_type1" onclick="javascript:subAdd(' + index + ');">서브추가</button>';
// 							subAdd = ' <button type="button" id="sub" class="btn_m grid" onclick="javascript:subAdd(' + index + ');">서브추가</button>';

                                if (row.depthLen > 1)
                                {
                                    groupName = '<pre>' + row.head + '<img src="../images/minusbottom.gif"><img src="../images/folder.gif">' + row.groupName + '</pre>' ;
                                }
                                else
                                {
                                    groupName = row.groupName;
                                }

                                gObject2 = {  "recid" 			: index
                                    , "tenantId"		: row.tenantId
                                    , "parentId" 		: row.parentId
                                    , "topParentId" 	: row.topParentId
                                    , "groupId"			: row.groupId
                                    , "depth"			: row.depth
                                    , "groupNameTree"	: groupName
                                    , "groupName"		: row.groupName
                                    , "valueTitleId" 	: row.valueTitleId
                                    , "groupMngId" 		: row.groupMngId
                                    , "groupDesc" 		: row.groupDesc
                                    , "subButton" 		: subAdd
                                    , "moveButton" 		: subMove
                                };

                                dataArray.push(gObject2);

                            });
                            w2ui['grid'].add(dataArray);
                        }else{
                            argoAlert('조회 결과가 없습니다.');
                            if($("#s_FindTenantId").val() != ""){
                                $("#btnAdd").show();
                            }
                        }
                    }
                    w2ui['grid'].select(pos);
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

        var gGroupId;
        function fnDeleteList(){
            try{
                var arrChecked = w2ui['grid'].getSelection();

                if(arrChecked.length == 0){
                    argoAlert("삭제할 그룹을 선택하세요");
                    return ;
                }

                argoConfirm('선택한 그룹 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
                    var multiService = new argoMultiService(fnCallbackDelete);
                    $.each(arrChecked, function( index, value ) {

                        gGroupId      = w2ui['grid'].getCellValue(value, 4);
                        var tTenantId = w2ui['grid'].getCellValue(value, 1);
                        var param = {
                            "groupId"  : gGroupId,
                            "tenantId" : tTenantId
                        };

                        multiService.argoDelete("Group", "setGroupDelete", "__", param);
                    });
                    multiService.action();
                });

            }catch(e){
                console.log(e) ;
            }
        }

        function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
            try {
                if (Resultdata.isOk()) {
                    workLog = '[그룹ID:'+ gGroupId +'] 삭제';
                    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
                        ,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
                    argoAlert('성공적으로 삭제 되었습니다.');
                    fnSearchList();
                }
            } catch (e) {
                argoAlert(e);
            }
        }

    </script>
</head>
<body>
<div class="sub_wrap">
    <div class="location"><span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">사용자관리</span><strong class="step">그룹정보관리</strong></div>
    <section class="sub_contents">
        <div class="search_area row2">
            <div class="row" id="div_tenant">
                <ul class="search_terms">
                    <li>
                        <strong class="title ml20">태넌트</strong>
                        <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
                        <input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px;display:none"/>
                        <input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                    </li>
                </ul>
            </div>
            <div class="row">
                <ul class="search_terms">
                    <li>
                        <strong class="title ml20">그룹 ID</strong>
                        <input type="text"	id="s_FindGroupId" name="s_FindGroupId" style="width:150px" class="clickSearch"/>
                    </li>
                    <li>
                        <strong class="title ml20">그룹명</strong>
                        <input type="text"	id="s_FindGroupName" name="s_FindGroupName" style="width:150px" class="clickSearch"/>
                    </li>
                </ul>
            </div>
        </div>
        <div class="btns_top">
            <button type="button" id="btnSearch" class="btn_m search">조회</button>
            <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
            <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
            <button type="button" id="btnReset" class="btn_m">초기화</button>
        </div>
        <div class="h136">
            <div class="btn_topArea fix_h25"></div>
            <div class="grid_area h25 pt0">
                <div id="gridList" style="width: 100%; height: 100%;"></div>
            </div>
        </div>
    </section>
</div>
</body>

</html>