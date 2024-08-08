<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

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

<script>
    var loginInfo 		= JSON.parse(sessionStorage.getItem("loginInfo")).SVCCOMMONID.rows || {};
    var workMenu 		= "녹취권한관리";
	var grantId   		= loginInfo.grantId;
	var controlAuth 	= loginInfo.controlAuth;

    $(document).ready(function(param) {
        // 태넌트 Selectbox
        argoCbCreate("selTenant", "comboBoxCode", "getTenantList", {findTenantId: loginInfo.tenantId}, {"selectIndex" : 0, "text" : '선택하세요!', "value" : ''});

        // 태넌트 변경 이벤트 처리
        $("#selTenant").change(function(e) {
            // 그룹 Selectbox
            //argoCbCreate("selGroup", "comboBoxCode", "getGroupListByParentId", {tenantId: this.value}, {"selectIndex":0, "text": '선택하세요!', "value":''});
            argoCbCreate("selGroup", "comboBoxCode", "getGroupList", {findTenantId:this.value, controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
            fnGroupCbChange("selGroup");

            // 권한 Selectbox
            //argoCbCreate("selGrant", "comboBoxCode", "getGrantList", {findTenantId: this.value}, {"selectIndex": 0, "text": '선택하세요!', "value": ''});
        });

        // 검색조건 초기화
        initSearchCond();

        /** 조회 버튼 이벤트 처리 */
        $('#btnSearch').click(function(e) {
            searchAprvList(1);
        });

        /** 초기화 버튼 이벤트 처리 */
        $('#btnReset').click(function(e) {
            initSearchCond();
        });

        /** 신청자 엔터키 이벤트 처리 */
        $("#schUserName").on("keyup",function(key) {
            if (key.keyCode == 13) {
                searchAprvList(1);
            }
        });

        // 초기화
        init();
        if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
    });


    /**
     * 초기화
     */
    function init() {
        // 그리드 초기화
        initAprvGrid();
        $('#paging').hide();

        // Set 테넌트
        $("#selTenant").val(loginInfo.tenantId).trigger("change");
    }

    /**
     * 그리드 초기화
     */
    function initAprvGrid() {
        $('#divAprvGrid').w2grid({
            name: 'aprvGrid',
            show: {
                lineNumbers: true,
                footer: true,
                //selectColumn: true,
            },
            //multiSelect: true,
            columns: [
                 { field: 'recid'           , caption: 'recid'        , size:   '0%' , 	attr: 'align=center' }
                ,{ field: 'tenantId'        , caption: '태넌트'       , size: '8%' , 	attr: 'align=center' }
                ,{ field: 'groupName'       , caption: '그룹'         , size: '9%' , 	attr: 'align=center' }
                ,{ field: 'userId'          , caption: '신청자ID'     , size: '9%' , 	attr: 'align=center' }
                ,{ field: 'userName'        , caption: '신청자명'     , size: '9%' , 	attr: 'align=center' }
                ,{ field: 'recGrant'        , caption: 'recGrant'     , size:   '0%' , 	attr: 'align=center' }
                ,{ field: 'dispRecGrant'    , caption: '신청권한'     , size:  '7%' , 	attr: 'align=center' }
                ,{ field: 'startDt'         , caption: 'startDt'      , size:   '0%' , 	attr: 'align=center' }
                ,{ field: 'dispStartDt'     , caption: '시작일자'     , size: '10%' , 	attr: 'align=center' }
                ,{ field: 'endDt'           , caption: 'endDt'        , size:   '0%' , 	attr: 'align=center' }
                ,{ field: 'dispEndDt'       , caption: '만료일자'     , size: '10%' , 	attr: 'align=center' }
                ,{ field: 'reqDate'         , caption: '신청일시'     , size: '10%' , 	attr: 'align=center' }
                ,{ field: 'aprvStatus'      , caption: 'aprvStatus'   , size:   '0%' , 	attr: 'align=center' }
                ,{ field: 'dispAprvStatus'  , caption: '승인상태'     , size: '8%' , 	attr: 'align=center' }
                ,{ field: 'aprvrName'       , caption: '승인자명'     , size: '8%' , 	attr: 'align=center' }
                ,{ field: 'aprvDate'        , caption: '승인일시'     , size: '9%' , 	attr: 'align=center' }
                ,{ field: 'recTime'         , caption: 'recTime'     , size:    '0%' , 	attr: 'align=center' }
            ],
            onDblClick: function(event) {
                var record= this.get(event.recid);
                if(record.recid >= 0 ) {
                    gPopupOptions = record ;
                    argoPopupWindow('녹취권한승인내역', 'RecGrantAprvPopF.do', '800', '760');
                }
            },
            records: new Array(),
        });

        // 컬럼 Hide
        w2ui['aprvGrid'].hideColumn('recid', 'recGrant', 'startDt', 'endDt', 'aprvStatus', 'recTime');
    }

    /**
     * 검색조건 초기화
     */
    function initSearchCond() {
        $("#selTenant").val(loginInfo.tenantId).trigger('change');
        $("#selGroup").val('');
        $("#schUserName").val('');
        $("#selGrant").val('');
        $("#selAprvStatus").val('');

        //$("#selDateTerm1").val('T_0');

        argoSetDatePicker();
        var jData = [];

        argoSetDateTerm('selDateTerm1', {"targetObj"     : "selReqDt", "selectValue"   : "T_0"}, jData);

        var today =  moment().format("YYYY-MM-DD");
        $("#selReqDt_To").val(today);
//         $("#selReqDt_To").change(function(e) {
//             var strTodayDate = new Date(today);
//             var setEndDayDate = new Date($("#selReqDt_To").val());
//
//             if(strTodayDate > setEndDayDate) {
//                 argoAlert("만료일은 과거로 설정하실 수 없습니다.");
//                 $("#selReqDt_To").val(today);
//                 return;
//             }
//         });

        $("#selReqDt_From").val(today);
//         $("#selReqDt_From").change(function(e) {
//             var strTodayDate = new Date(today);
//             var setEndDayDate = new Date($("#selReqDt_From").val());
//
//             if(strTodayDate > setEndDayDate) {
//                 argoAlert("시작일은 과거로 설정하실 수 없습니다.");
//                 $("#selReqDt_From").val(today);
//                 return;
//             }
//         });
    }


    /**
     * Set 승인 그리드
     */
    function setAprvGrid(data) {
        var $grid = w2ui['aprvGrid'];

        $grid.searchReset();
        $grid.clear();
        if (data.rows && data.rows.length > 0) {
            var rows = new Array();
            $.each(data.rows, function(index, row) {
                row.recid = index;
                row.dispRecGrant = row.recGrant == "D" ? "다운로드" : row.recGrant == "L" ? "청취" : "";
                row.dispStartDt = moment(row.startDt).format("YYYY-MM-DD");
                row.dispEndDt = moment(row.endDt).format("YYYY-MM-DD");
                row.dispAprvStatus = row.aprvStatus == "R" ? "신청" : row.aprvStatus == "A" ? "승인" : row.aprvStatus == "J" ? "반려" : "";
                rows.push(row);
            });
            $grid.add(rows);
        }
        else {
            argoAlert('조회 결과가 없습니다.');
        }

        $grid.unlock();
    }


    /**
     * 페이지 번호 선택 이벤트 처리
     */
    var _page = 1;
    var _perPage = 15;
    function fnSearchList(page) {
        _page = page;
        searchAprvList(page);
    }

    /**
     * 승인 리스트 조회
     */
    function searchAprvList(page) {
        var param = {
              tenantId      : $('#selTenant').val()
            , groupId       : $('#selGroup').val()
            , likeUserName  : $('#schUserName').val()
            , recGrant      : $('#selGrant').val()
            , aprvStatus    : $('#selAprvStatus').val()
            , reqDtFrom     : $('#selReqDt_From').val().replaceAll('-', '')
            , reqDtTo       : $('#selReqDt_To').val().replaceAll('-', '')
            , page          : page || null
            , perPage       : _perPage
            , searchType    : loginInfo.recAprvYn == 'Y' ? '' : 'ALL'
            , schUserId     : loginInfo.userId
            , controlAuth	: controlAuth
        };
        argoJsonSearchList('recGrantAprv', 'getRecGrantAprvList', 's_', param, callback, {SVC_ARGO_PATH : "/ARGO/REC/GRANTCONTROL.do"});
        function callback(res) {
            if (res.isOk()) {
                var data = res.SVCCOMMONID || {};

                // pagination
                pageNavi(data.totCnt, _page, _perPage, "1");
                $("#totCnt").html(data.totCnt);
                $('#paging').show();

                // set grid
                setAprvGrid(data);

                // 조작로그 저장
                var workLog = '[TenantId:'+ loginInfo.tenantId +' | UserId:'+ loginInfo.userId +'] 녹취권한승인 조회';
                argoJsonUpdate("actionLog", "setActionLogInsert", null, {
                    tenantId    : loginInfo.tenantId,
                    userId      : loginInfo.userId,
                    actionClass : "action_class",
                    actionCode  : "W",
                    workIp      : loginInfo.workIp,
                    workMenu    : workMenu,
                    workLog     : workLog
                });
           }
        }
    }

</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역조회</span><strong class="step">녹취권한관리</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li id="div_tenant">
                            <strong class="title ml20">태넌트</strong>
                            <select id="selTenant" name="selTenant" style="width: 150px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px;display:none" class="clickSearch"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                        </li>
                        <li style="width:280px">
                            <strong class="title ml20">그룹</strong>
                            <select id="selGroup" name="selGroup" style="width:150px" class="list_box">
                                <option value="">선택하세요!</option>
                            </select>
                        </li>
                        <li style="width:420px">
                            <strong class="title ml20" style="width:80px">신청자</strong>
                            <input type="text" 	id="schUserName" name="schUserName" style="width:150px" class="clickSearch"/>
                        </li>
                    </ul>
                </div>

                <div class="row">
                    <ul class="search_terms">
                        <li style="width: 530px"><strong class="title ml20">신청일자</strong>
                            <span class="select_date">
                                <input type="text" class="datepicker onlyDate" id="selReqDt_From" name="selReqDt_From">
                            </span>
                            <span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span>
                            <span class="select_date">
                                <input type="text" class="datepicker onlyDate" id="selReqDt_To" name="selReqDt_To">
                            </span>
                            </span> &nbsp; <select id="selDateTerm1" name="" style="width: 70px;" class="mr5"></select>
                        </li>
                        <li  style="width:272px">
                           <strong class="title ml20" style="width:78px">녹취권한</strong>
                            <select id="selGrant" name="selGrant" style="width:150px;" class="list_box">
                                <option value="">선택하세요!</option>
                                <option value="L">청취</option>
                                <option value="D">다운로드</option>
                            </select>
                        </li>
                        <li  style="width:272px">
                           <strong class="title ml20" style="width:78px">승인상태</strong>
                            <select id="selAprvStatus" name="selAprvStatus" style="width:150px;" class="list_box">
                                <option value="">선택하세요!</option>
                                <option value="R">신청</option>
                                <option value="A">승인</option>
                                <option value="J">반려</option>
                            </select>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="btns_top">
	            <div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCnt">0</span>
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            
	            <div class="grid_area h25 pt0">
	                <div id="divAprvGrid" style="width: 100%; height: 415px;"></div>
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