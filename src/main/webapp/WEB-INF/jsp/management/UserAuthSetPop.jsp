<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<link rel="stylesheet" href="<c:url value='/css/w2ui-1.5.rc1.css'/>" type="text/css" />
<link rel="stylesheet" href="<c:url value='/css/w2ui-1.5.rc1.min.css'/>" type="text/css" />
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery-1.11.3.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.popWindow.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/w2ui-1.5.rc1.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/w2ui-1.5.rc1.min.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/argojs/argo.alert.js'/>"></script>
<script type="text/javascript" src="<c:url value='/scripts/jquery/jquery-ui.js?ver=2017011301'/>"></script>


<script>
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo")).SVCCOMMONID.rows;
	var tenantId  	= loginInfo.tenantId;
	var userId    	= loginInfo.userId;
	var grantId   	= loginInfo.grantId;
	var workIp 		= loginInfo.workIp;
	var controlAuth	= loginInfo.controlAuth;
	var authRank	= loginInfo.authRank;
	var workLog 	= "";
	
	var workMenu 	= "사용자권한설정팝업";

	var model;  // popup parameter
    $(function () {
        // popup parameter
        var sPopupOptions = parent.gPopupOptions || {};
        sPopupOptions.get = function(key, value) {
            return this[key] === undefined ? value : this[key];
        };
        model = sPopupOptions;
        //console.log("load model:", model);
    });

    /**
     * Document load
     */
    $(document).ready(function(e) {
        // 태넌트 Selectbox
	    argoCbCreate("selTenant", "comboBoxCode", "getTenantList", {}, {});

        // 태넌트 변경 이벤트 처리
        $("#selTenant").change(function(e) {
        	argoCbCreate("selGroupId", "comboBoxCode", "getGroupList", {findTenantId:this.value, controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
        	fnGroupCbChange("selGroupId");
        	argoJsonSearchList('comboBoxCode', 'getGroupList', null, {findTenantId: this.value}, function (res, textStatus, jqXHR) {
                if (res.isOk()) {
                    initSelControlGroup(res.SVCCOMMONID.rows);
                }
            });
        	
        	searchUserList();
        	w2ui.userGrid.clear();
        	$("#selCount").text("0명");
        	
        	
        });

        /** 조회 버튼 이벤트 처리 */
        $('#btnSearch').click(function(e) {
            searchUserList();
        });

        /** [저장] 버튼 클릭 이벤트 처리 */
        $("#btnSave").click(function(){
            save(); // 저장
        });

        /** [추가] 버튼 클릭 이벤트 처리 */
        $("#btnAddUser").click(function(){
            addUserGrid();
        });

        /** [삭제] 버튼 클릭 이벤트 처리 */
        $("#btnRemoveUser").click(function(){
            removeUserGrid();
        });

        
        /** 제어그룹 [조회] 버튼 클릭 이벤트 처리 */
        $("#btnSearchCa").click(function() {
        	fnControlAuthSearch();
        });
        
        $('#searchCa').keyup(function(event){
            if(event.keyCode == 13){
            	fnControlAuthSearch();
            }
        });

        // 초기화
        init();
        searchUserList();
	});
    
    
    
    
    
    var caOldValue = "";
    function fnControlAuthSearch(){
    	var searchCa = $("#searchCa").val();    // 제어그룹 검색어
        var caArr = $("#selControlAuth option:contains("+ searchCa +")");   // 제어그룹 셀렉트박스 리스트
        
        if(caOldValue != searchCa) {
            caOldIndex = 0;
            caOldValue = searchCa;
        }
        else {
            if(caOldIndex == caArr.length) {
                caOldIndex = 0;
            }
        }

        var scrPosition = 0;
        var $selControlAuth = $('#selControlAuth'); // 제어그룹 Selectbox
        if (caArr.length > 0) {
            var caArrVal = caArr[caOldIndex].value;
            var optionTop = $selControlAuth.find('[value="'+ caArrVal +'"]').offset().top;
            var selectTop = $selControlAuth.offset().top;
            $selControlAuth.scrollTop($selControlAuth.scrollTop() + (optionTop - selectTop));
            caOldIndex++;
        }
        else {
            $selControlAuth.scrollTop(0);
            caOldIndex = 0;
            caOldValue = "";
        }
    }


	/**
	 * Document Init
	 */
	function init() {
	    // 그리드 초기화
		initSelUserGrid();  // 사용자 그리드
		initUserGrid();     // 사용자 그리드

        // Set 테넌트
        $("#selTenant").val(model.tenantId || loginInfo.tenantId).trigger("change");

        // 사용자권한 Manager
        console.log("#init", loginInfo.groupId)
        if (loginInfo.grantId == "Manager") {
            // 태넌트 Selectbox 숨김
            $("#liTenantSel").hide();

            // Manager disabled - 제어그룹, 승인내역확인
            $(".input_table_tr_auth_manager_disable").find(":input").attr('disabled', true);
        }
	}


    /**
     * 사용자 그리드 초기화
     */
	function initSelUserGrid() {
        $('#divSelUserGrid').w2grid( {
            name:'selUserGrid',
            show:{
                selectColumn: true
            },
            multiSelect : true,
            onSelect: function(event) {
            },
            columns: [
                {field:'recid'      , caption: '순번'      , size:  '50px', sortable: true, attr: 'align=center' },
                {field:'userId'     , caption: '사용자ID'   , size: '30%', sortable: true, attr: 'align=center' },
                {field:'userName'   , caption: '사용자명'   , size: '30%', sortable: true, attr: 'align=center' },
                {field:'groupId'    , caption: 'groupId'    , size: '0px', sortable: true, attr: 'align=center' },
                {field:'groupName'  , caption: '그룹명'     , size: '30%', sortable: true, attr: 'align=center' },
                {field:'tenantId'   , caption: 'tenantId'   , size:  '0%', sortable: true, attr: 'align=center' },
            ],
            records: new Array()
        });

        w2ui['selUserGrid'].hideColumn('recid', 'groupId', 'tenantId');
    }


    /**
     * 사용자 그리드 초기화
     */
    function initUserGrid() {
        $('#divUserGrid').w2grid({
            name: 'userGrid',
            show: {
                selectColumn: true
            },
            multiSelect : true,
            onSelect : function(event) {
            },
            columns : [
                {field:'recid'      , caption: '순번'      , size:  '50px', sortable: true, attr: 'align=center' },
                {field:'userId'     , caption: '사용자ID'   , size: '30%', sortable: true, attr: 'align=center' },
                {field:'userName'   , caption: '사용자명'   , size: '30%', sortable: true, attr: 'align=center' },
                {field:'groupId'    , caption: 'groupId'    , size: '0px', sortable: true, attr: 'align=center' },
                {field:'groupName'  , caption: '그룹명'     , size: '30%', sortable: true, attr: 'align=center' },
                {field:'tenantId'   , caption: 'tenantId'   , size:  '0%', sortable: true, attr: 'align=center' },
            ],
            records : new Array()
        });

        w2ui['userGrid'].hideColumn( 'recid', 'groupId', 'tenantId');
    }


    /**
     * 그룹 Selectbox 초기화
     */
    function initSelGroup(list) {
        var options = {"selectIndex": 0, "text": '선택하세요!', "value": ''};

        // 그룹 Selectbox
        $("#selGroupId").empty();
        $("#selGroupId").append($('<option>').text(options.text).attr('value', options.value || ''));    // 선택하세요 추가

        $.each(list, function(index, item) {
            $("#selGroupId").append($('<option>').text(item.codeNm).attr('value', item.code));
        });
        fnGroupCbChange("selGroupId");
    }


    /**
     * 제어그룹 Selectbox 초기화
     */
    function initSelControlGroup(list) {
        var options = {"selectIndex": 0, "text": '선택하세요!', "value": ''};

        // 제어그룹
        $("#selControlAuth").empty();
        $("#selControlAuth").append($('<option>').text(options.text).attr('value', options.value || ''));    // 선택하세요 추가

        $.each(list, function(index, item) {
            $("#selControlAuth").append($('<option>').text(item.codeNm).attr('value', item.code));
        });
        fnGroupCbChange("selControlAuth");
    }


    /**
     * 사용자 조회
     */
    function searchUserList() {
        var schTenantId = $('#selTenant option:selected').val() || "";
        var schGroupId	= $('#selGroupId').val() || "";
        var schUserName	= $('#schUserName').val() || "";

        var param = {
              findTenantId  	: schTenantId
            , findGroupId   	: schGroupId
            , findUserNameText  : schUserName
            , authRank      	: loginInfo.authRank
            , controlAuth   	: loginInfo.controlAuth
        };
        param['grantId'] = loginInfo.grantId;
        param['userId'] = loginInfo.userId;
        argoJsonSearchList('userAuth', 'getUserInfoAuthSetList', 's_', param, setSelUserGrid);
    }
    


    /**
     * Set 사용자 그리드
     */
    function setSelUserGrid(data, textStatus, jqXHR) {
        if(data.isOk()) {
            w2ui['selUserGrid'].searchReset();
            w2ui['selUserGrid'].clear();

            //console.log("# setSelUserGrid data.getRows() : ", data.getRows());
            if (data && data.getRows().length > 0) {
                var rows = new Array();
                $.each(data.getRows(), function(index, row) {
                    rows.push({
                          "recid" 			: index
                        , "userId"			: row.userId
                        , "userName"		: row.userName
                        , "groupId"			: row.groupId
                        , "groupName"		: row.groupName
                        , "tenantId"		: row.tenantId
                    });
                });
                w2ui['selUserGrid'].add(rows);
            }
            else {
                //argoAlert('조회 결과가 없습니다.');
            }
        }

         w2ui['selUserGrid'].unlock();
	}


    /**
     * 그리드 - 사용자 추가
     */
	function addUserGrid() {
	    var $grid = w2ui['userGrid'];
	    var $selGrid = w2ui['selUserGrid'];
	    var userKeyList = [];
	    $.each($grid.records, function(index, item) {
	        userKeyList.push(item.tenantId + item.userId);
	    });

	    var rows = [];
	    var row;
	    var recid = $grid.records.length;
	    
	    var maxRecId = 0;
	    
    	$.each(w2ui.userGrid.records, function(idx, obj){
	        if(maxRecId <= obj.recid){
	        	maxRecId = obj.recid + 1;
	        }
	    })
	    
	    
	    $.each($selGrid.getSelection(), function(index, item) {
	        
	    	
	    	
	    	row = $selGrid.get(item);
	        if (userKeyList.indexOf(row.tenantId + row.userId) < 0) {
	        	
	        	
	        	rows.push({
	                  "recid" 			: maxRecId
                    , "userId"			: row.userId
                    , "userName"		: row.userName
                    , "groupId"			: row.groupId
                    , "groupName"		: row.groupName
                    , "tenantId"		: row.tenantId
	            });
	        	
	        	maxRecId = maxRecId + 1;
	        }
	    });
	    $grid.add(rows);
	    $("#selCount").text(w2ui.userGrid.records.length + "명");
	}

    /**
     * 그리드 - 사용자 제거
     */
    function removeUserGrid() {
        var $grid = w2ui['userGrid'];

        // remove
        $.each($grid.getSelection(), function(index, item) {
            $grid.remove($grid.get(item).recid);
        });
        $("#selCount").text(w2ui.userGrid.records.length + "명");
    }

    /**
     * 사용자권한 저장
     */
    var logs = new Array(); // action log array
	function save() {
	    // 사용자 선택 여부 check
	    /* var $grid = w2ui['userGrid'];
        var rows = $grid.getSelection();
        if (rows.length == 0) {
            argoAlert("사용자를 선택하세요") ;
            return ;
        } */
        
        if (w2ui.userGrid.records.length == 0) {
            argoAlert("사용자를 선택하세요") ;
            return ;
        }
        var $grid = w2ui['userGrid'];
        var rows = w2ui.userGrid.records;
        var targetCnt = "대상인원 : " + $("#selCount").text();
		argoConfirm(targetCnt + "<br>저장 하시겠습니까?", function(){
            var logs = new Array(); // action log array
            var row;    // grid row
            //var controlAuth     = $('#selControlAuth option:selected').toArray().map(item => item.value).join();
            var controlAuthValueArr = $('#selControlAuth option:selected').toArray().map(item => item.value);
            var recListeningYn  = argoGetValue('chkRecListeningYn') || 'N';
            var recAprvYn       = argoGetValue('rdRecAprvConfirmYn');
            var qaYn            = argoGetValue('rdQaYn');
            var log;    // action log

            var userCtrlAuth = "";
    	    $.each(controlAuthValueArr, function(idx, value){
    	        if(argoNullConvert(value) != ""){
    	        	userCtrlAuth = userCtrlAuth + value + ",";
    	        }
    	    });
    	    userCtrlAuth = userCtrlAuth.slice(0, -1);
            
            
            var param = {};
            var multiService = new argoMultiService(fnCallbackUpdate);
			
            $.each(rows, function(index, item) {
                param = {
                    tenantId        : item.tenantId, // model.tenantId,
                    userId          : item.userId,
                    controlGroup    : userCtrlAuth,
                    recListeningYn  : recListeningYn,
                    recAprvYn       : recAprvYn,
                    qaYn            : qaYn,
                    uptId           : loginInfo.userId
                };
                multiService.argoUpdate("userInfo","setUserAuthUpdate","__", param);
                log = "[TenantId:"+ item.tenantId +" | UserId:"+ item.userId +"] 수정";
                log += " (청취승인권한:"+ recListeningYn +")";
                log += " (승인내역확인권한:"+ recAprvYn +")";
                log += " (평가권한:"+ qaYn +")";
                logs.push(log);
			});
            
            multiService.action();

            // Update
			//argoJsonUpdate("userAuth", "setUserAuthUpsert", null, {params}, callback, {SVC_ARGO_PATH : "/ARGO/USERCONTROL.do"});

            /** 저장 Callback 처리 - Action Log 저장 */
			/* function callback(res) {
                if (res && res.resultCode == '0000') {
                    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');

                    $.each(logs, function(index, item) {
                        argoJsonUpdate("actionLog", "setActionLogInsert", null, {
                            tenantId: loginInfo.tenantId, userId: loginInfo.userId, actionClass: "action_class", actionCode:"W", workIp: loginInfo.workIp, workMenu: workMenu, workLog: item
                        });
                    });
                }
                else {
                    console.log(res.resultMsg);
                }
            } */
		});
	}
    
    
	function fnCallbackUpdate(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
		    	$.each(logs, function(index, item) {
                    argoJsonUpdate("actionLog", "setActionLogInsert", null, {
                        tenantId: loginInfo.tenantId, userId: loginInfo.userId, actionClass: "action_class", actionCode:"W", workIp: loginInfo.workIp, workMenu: workMenu, workLog: item
                    });
                });
		    }
		} catch(e) {
			argoAlert(e);    		
		}
	}
    
    

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
                    <ul class="search_terms">
                        <li id="liTenantSel">
                            <strong class="title ml20">테넌트</strong>
                            <select id="selTenant" name="selTenant" style="width:150px;"  class="list_box"></select>
                        </li>
                        <li>
                            <strong class="title ml20">그룹</strong>
                            <select id="selGroupId" name="selGroupId" style="width: 150px" class="list_box"></select>
                        </li>
                        <li>
                            <strong class="title ml20">사용자</strong>
                            <input type="text" id="schUserName" name="schUserName" style="width:150px;" class="mr10" />
                        </li>
                    </ul>
					<span class="btn_r">
					    <button type="button" id="btnSearch" class="btn_m search">조회</button>
                    </span>
                </div>

                <div class="grid_area h25 pt0" style="height:154px;">
                    <div id="divSelUserGrid" style="float:left; width:100%; height:154px; margin-top:5px;" ></div>
                </div>

                <div class="btn_topArea" style="margin-top: 25px; height:40px;">
					<span class="btn_l">
						대상인원 :
                    </span>
                    <span class="btn_l" id="selCount">
						0명
                    </span>
					<span class="btn_r">
						<button type="button" class="btn_m" id="btnAddUser" name="btnSave">추가</button>
						<button type="button" class="btn_m" id="btnRemoveUser" name="btnSave">삭제</button>
						<button type="button" class="btn_m confirm" id="btnSave" name="btnSave">저장</button>
                       	<input type="hidden" id="ip_Salt" name="ip_Salt" />
                       	<input type="hidden" id="ip_InsId" name="ip_InsId" />
                       	<input type="hidden" id="ip_TenantId" name="ip_TenantId" />
                    </span>
                </div>

                 <div class="grid_area h25 pt0" style="height:165px;">
                    <div id="divUserGrid" style="float:left; width:100%; height:154px; margin-top:5px;" ></div>
                 </div>

                <div class="input_area">
                    <table class="veloce_input_table" style="margin-bottom: 25px;">
                        <colgroup>
                            <col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr class='input_table_tr_auth_manager_disable'>
                                <th rowspan="2" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">제어그룹<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    	키보드의 ctrl 버튼을 누른 상태에서 제어할 그룹을 선택하시면 다중 선택이 가능합니다. ( 필요시 하부그룹까지 선택 )<br>
                                    <input type="text" id="searchCa" name="searchCa">
                                    <button type="button" class="btn_m confirm" id="btnSearchCa" name="btnSearchCa">조회</button>
                               </td>
                            </tr>
                            <tr class='input_table_tr_auth_manager_disable'>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    <select name="selControlAuth" id="selControlAuth" class="s8"  style="width: 100%; height: 108px;" multiple="multiple"  >
                                    </select>
                                </td>
                            </tr>

                            <tr>
                                <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인권한<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    <input type="checkbox" class="checkbox" id="chkRecListeningYn" name="chkRecListeningYn" value="Y" checked>
                                    <label for="ckRecListeningYn" style="width: 60px">청취</label>
                                    <span style="width: 100px">&nbsp;&nbsp;</span>
                                </td>
                            </tr>
                            <tr class='input_table_tr_auth_manager_disable'>
                                <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">승인내역확인<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    <input type="radio" name="rdRecAprvConfirmYn" id="rdRecAprvConfirmYn" value="Y" /><label>예</label>
                                    <input type="radio" name="rdRecAprvConfirmYn" id="rdRecAprvConfirmYn" value="N" checked /><label>아니요</label>
                                </td>
                            </tr>
                            <tr>
                                <th colspan="1" style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">평가권한<span class="point"></span></th>
                                <td colspan="3"  style="padding: 4px 10px;line-height: 17px;border: 1px solid #d3d3d3;">
                                    <input type="radio" name="rdQaYn" id="rdQaYn" value="A" /><label>전체권한</label>
                                    <input type="radio" name="rdQaYn" id="rdQaYn" value="Y" /><label>평가권한</label>
                                    <input type="radio" name="rdQaYn" id="rdQaYn" value="N" checked/><label>없음</label>
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
