<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<script>
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
// 	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
// 	var workMenu 	= "내선별녹취상태";
// 	var workLog 	= "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});

	function fnInitCtrl() {
		argoSetDatePicker();
		$("#s_findRecDate").val(argoSetFormat(argoDateToStr(argoAddDate(argoCurrentDateToStr(), -1)), "-", "4-2-2"));

		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex" : 0});
		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);

		$("#btnSearch").click(function() { //조회
			fnSearchListCnt();
		});

		$("#btnReset").click(function() {
			$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
			$("#s_findRecDate").val(argoSetFormat(argoDateToStr(argoAddDate(argoCurrentDateToStr(), -1)),"-","4-2-2"));
			$('#s_FindOmissionAt	option[value=""]').prop('selected', true);
		});
	}

	function fnInitGrid() {
		$('#gridList').w2grid({
			name : 'grid',
			show : {
				lineNumbers : true,
				footer : true
			},
			multiSelect : true,
			onDblClick : function(event) {
				var record = this.get(event.recid);
				if(record.recid >=0 ) {
					gPopupOptions = {pRowIndex:record};
					argoPopupWindow('정합성 상세정보', 'SystemRecCnfrmtyDetailF.do', '1000', '600');
				}
			},
			columnGroups : [
				 {caption : "상담APP", span : 20}
				,{caption : "VELOCE MANAGER", span : 22}
				,{caption : "", master : true}
			],
			columns : [
				 { field : 'recid',			caption : 'recid',		size : '0%', 	sortable : true,	attr : 'align=center' }

				,{ field : 'appRecDate',	caption : '녹취일자',		size : '12%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCallId',		caption : '콜아이디',		size : '25%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appUcid',		caption : 'UCID',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appDnNo',		caption : '내선번호',		size : '8%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appHop',		caption : 'HOP',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCallKind',	caption : '통화종류',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appUserId',		caption : '사용자아이디',	size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appUserName',	caption : '사용자명',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustTel',	caption : '고객전화번호',	size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustno',		caption : '고객번호',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustname',	caption : '고객명',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc1',	caption : '고객정보1',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc2',	caption : '고객정보2',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc3',	caption : '고객정보3',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc4',	caption : '고객정보4',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc5',	caption : '고객정보5',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc6',	caption : '고객정보6',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc7',	caption : '고객정보7',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'appCustEtc8',	caption : '고객정보8',		size : '0%',	sortable : true,	attr : 'align=center' }

				,{ field : 'velRecTime',	caption : '녹취일시',		size : '12%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCallId',		caption : '콜아이디',		size : '25%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velDnNo',		caption : '내선번호',		size : '8%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velGroupId',	caption : '그룹아이디',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velGroupName',	caption : '그룹명',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velUserId',		caption : '사용자아이디',	size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velUserName',	caption : '사용자명',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velPhoneIp',	caption : '전화기IP',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velEndTime',	caption : '통화시간',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCallKind',	caption : '통화종류',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustTel',	caption : '고객전화번호',	size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustNo',		caption : '고객번호',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustName',	caption : '고객명',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc1',	caption : '고객정보1',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc2',	caption : '고객정보2',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc3',	caption : '고객정보3',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc4',	caption : '고객정보4',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc5',	caption : '고객정보5',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc6',	caption : '고객정보6',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc7',	caption : '고객정보7',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'velCustEtc8',	caption : '고객정보8',		size : '0%',	sortable : true,	attr : 'align=center' }
				,{ field : 'recGubun',		caption : '눅취구분',		size : '0%',	sortable : true,	attr : 'align=center' }

				,{ field : 'omissionAt',	caption : '누락여부',		size : '10%',	sortable : true,	attr : 'align=center' }
			],
			records : dataArray
		});

		w2ui['grid'].hideColumn('recid', 'appUcid', 'appHop', 'appCallKind', 'appUserId', 'appUserName', 'appCustTel', 'appCustno', 'appCustname', 'appCustEtc1', 'appCustEtc2', 'appCustEtc3', 'appCustEtc4', 'appCustEtc5', 'appCustEtc6', 'appCustEtc7', 'appCustEtc8', 'velGroupId', 'velGroupName', 'velUserId', 'velUserName', 'velPhoneIp', 'velEndTime', 'velCallKind', 'velCustTel', 'velCustNo', 'velCustName', 'velCustEtc1', 'velCustEtc2', 'velCustEtc3', 'velCustEtc4', 'velCustEtc5', 'velCustEtc6', 'velCustEtc7', 'velCustEtc8', 'recGubun');
	}

	function fnSearchListCnt(){
		w2ui.grid.lock('조회중', true);

		argoJsonSearchOne('sysCheck', 'getRecCnfrmtyCnt', 's_', {}, function (data, textStatus, jqXHR){
			try {
				if(data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					$("#totCount").html(totalData);

					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
				}
			} catch (e) {
				console.log(e);
			}
		});
	}

	function fnSearchList(startRow, endRow) {
		w2ui.grid.lock('조회중', true);

		argoJsonSearchList('sysCheck', 'getRecCnfrmtyList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function(data, textStatus, jqXHR) {
			try {
				if(data.isOk()) {
					w2ui.grid.clear();
					if(data.getRows() != "") {
						dataArray = new Array();
						
						$.each(data.getRows(), function(index, row) {
							gObject = {
								"recid" 		: index,
								"appRecDate"	: row.appRecDate == null ? "" : fnStrMask("YMD", row.appRecDate),
								"appCallId"		: row.appCallId,
								"appUcid"		: row.appUcid,
								"appDnNo"		: row.appDnNo,
								"appHop"		: row.appHop,
								"appCallKind"	: row.appCallKind,
								"appUserId"		: row.appUserId,
								"appUserName"	: row.appUserName,
								"appCustTel"	: row.appCustTel,
								"appCustNo"		: row.appCustNo,
								"appCustName"	: row.appCustName,
								"appCustEtc1"	: row.appCustEtc1,
								"appCustEtc2"	: row.appCustEtc2,
								"appCustEtc3"	: row.appCustEtc3,
								"appCustEtc4"	: row.appCustEtc4,
								"appCustEtc5"	: row.appCustEtc5,
								"appCustEtc6"	: row.appCustEtc6,
								"appCustEtc7"	: row.appCustEtc7,
								"appCustEtc8"	: row.appCustEtc8,

								"velRecTime"	: row.velRecTime == null ? "" : fnStrMask("DHMS", row.velRecTime),
								"velCallId"		: row.velCallId,
								"velDnNo"		: row.velDnNo,
								"velGroupId"	: row.velGroupId,
								"velGroupName"	: row.velGroupName,
								"velUserId"		: row.velUserId,
								"velUserName"	: row.velUserName,
								"velPhoneIp"	: row.velPhoneIp,
								"velEndTime"	: row.velEndTime,
								"velCallKind"	: row.velCallKind,
								"velCustTel"	: row.velCustTel,
								"velCustNo"		: row.velCustNo,
								"velCustName"	: row.velCustName,
								"velCustEtc1"	: row.velCustEtc1,
								"velCustEtc2"	: row.velCustEtc2,
								"velCustEtc3"	: row.velCustEtc3,
								"velCustEtc4"	: row.velCustEtc4,
								"velCustEtc5"	: row.velCustEtc5,
								"velCustEtc6"	: row.velCustEtc6,
								"velCustEtc7"	: row.velCustEtc7,
								"velCustEtc8"	: row.velCustEtc8,
								"recGubun"		: row.recGubun,
								
								"omissionAt" 	: row.omissionAt == "Y" ? "누락" : "",
								w2ui : {"style" : row.omissionAt == "Y" ? "background-color: #FFD8D8" : ""}
							};

							dataArray.push(gObject);
						});

						w2ui['grid'].add(dataArray);
					} else {
						argoAlert('조회 결과가 없습니다.');
					}
				}
				w2ui.grid.unlock();
			} catch (e) {
				console.log(e);
			}
		});
	}
</script>
</head>
<body>
	<div class="sub_wrap">
		<div class="location">
			<span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템점검</span><strong class="step">정합성체크</strong>
		</div>
		<section class="sub_contents">
			<div class="search_area row2">
				<div class="row">
					<ul class="search_terms">
						<li>
							<strong class="title ml20">태넌트</strong>
							<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select>
							<input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" />
							<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1">
						</li>
						<li>
							<strong class="title ml20">녹취일자</strong>
							<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_findRecDate" name="s_findRecDate">
							</span>
						</li>
						<li>
							<strong class="title ml20">누락여부</strong>
							<select id="s_FindOmissionAt" name="s_FindOmissionAt" class="list_box"  style="width: 150px" >
								<option value="" selected>선택하세요!</option>
								<option value="Y">누락</option>
								<option value="N">정상</option>
							</select>
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<div class="sub_l">
					<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span>
				</div>
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
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