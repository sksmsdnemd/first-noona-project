<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "내선별녹취상태";
	var workLog 	= "";

	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();

	});

	function fnInitCtrl() {
		argoCbCreate("s_FindSystemId", "comboBoxCode", "getSystemId", {sort_cd:'SYSTEM_NAME'}, {"selectIndex" : 0, "text" : '선택하세요!', "value" : ''});
		argoCbCreate("s_FindSysName", "comboBoxCode", "getSystemName", {sort_cd:'SYSTEM_NAME'}, {"selectIndex" : 0, "text" : '선택하세요!', "value" : ''});

		fnAuthBtnChk(parent.$("#authKind").val());

		$("#btnSearch").click(function() { //조회	
			fnSearchList();
		});

		$("#btnReset").click(function() {
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$("#s_FindSysName").find("option").remove();
			$('#s_FindErrCont option[value=""]').prop('selected', true);
			$("#s_FindUserName").val("");
			$("#s_FindUserId").val("");
			$("#s_FindDnNo").val("");
			$("#s_FindPhoneIp").val("");

		});

		$("#s_FindSystemId").change(function() {
			if ($('#s_FindSystemId option:selected').val() == '') {
				$("#s_FindSysName").find("option").remove();
			} else {
				argoCbCreate("s_FindSysName", "comboBoxCode", "getSystemName", {findSystemId:$('#s_FindSystemId option:selected').text()});
			}
		});

		$("#btnExcel").click(function() {
			var excelArray = new Array();
			argoJsonSearchList('sysCheck', 'getSummaryRecode', 's_', {"iSPageNo":100000000, "iEPageNo":100000000}, function(data, textStatus, jqXHR) {
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function(index, row) {
							gObject = {
										"번호" 		 : index + 1,
										"오류내용" 		 : row.errContent,
										"녹취일자" 		 : row.recDate,
										"MRS 시스템 ID" : row.mrsSystemId,
										"내선번호" 		 : row.dnNo,
										"전화기IP" 	 : row.phoneIp,
										"상담사명" 		 : row.userName,
										"상담사ID" 	 : row.userId,
										"오류건수" 		 : row.recXCnt,
										"정상녹취건수" 	 : row.recOCount,
										"전체녹취건수" 	 : row.recAll
										};

							excelArray.push(gObject);
						});

						gPopupOptions = {
											"pRowIndex" : excelArray,
											"workMenu"  : workMenu
										};
						argoPopupWindow('Excel Export',	gGlobal.ROOT_PATH + '/common/VExcelExportF.do',	'150', '40');
					}
				} catch (e) {
					console.log(e);
				}
			});
		});
		
		$(".InputReadL").keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
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
			columns : [ 
			             { field : 'recid',			caption : '번호',			size : '0%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'errContent',	caption : '오류내용',		size : '10%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'recDate',		caption : '녹취일자',		size : '9%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'mrsSystemId',	caption : 'MRS 시스템ID',	size : '11%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'dnNo',			caption : '내선번호',		size : '8%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'phoneIp',		caption : '전화기IP',		size : '12%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'userName',		caption : '상담사명', 		size : '10%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'userId',		caption : '상담사ID',		size : '10%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'recXCnt',		caption : '오류건수',		size : '10%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'recOCount',		caption : '정상녹취건수',		size : '10%',	sortable : true,	attr : 'align=center' }
			            ,{ field : 'recAll', 		caption : '전체녹취건수',		size : '10%', 	sortable : true,	attr : 'align=center' }
			],
			records : dataArray
		});

		w2ui['grid'].hideColumn('recid');
	}

	function fnSearchList() {
		
		w2ui.grid.lock('조회중', true);

		argoJsonSearchList('sysCheck', 'getSummaryRecode', 's_', {}, function(data, textStatus, jqXHR) {
			try {
				var cnt = data.SVCCOMMONID.procCnt;
				if (cnt < 5) {
					$("#gridList").css("height", "315px");
				} else {
					$("#gridList").css("height", "615px");
				}
				
				if (data.isOk()) {
					w2ui.grid.clear();
					if (data.getRows() != "") {
						dataArray = new Array();
						$.each(data.getRows(), function(index, row) {

							gObject2 = {  "recid" 		: index
										, "errContent" 	: row.errContent
										, "recDate" 	: row.recDate
										, "mrsSystemId" : row.mrsSystemId
										, "dnNo" 		: row.dnNo
										, "phoneIp" 	: row.phoneIp
										, "userName" 	: row.userName
										, "userId" 		: row.userId
										, "recXCnt" 	: row.recXCnt
										, "recOCount" 	: row.recOCount
										, "recAll" 		: row.recAll
										};

							dataArray.push(gObject2);
						});

						w2ui['grid'].add(dataArray);
					}else{
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
			<span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템점검</span><strong class="step">내선별녹취상태</strong>
		</div>
		<section class="sub_contents">
			<div class="search_area row3">
				<div class="row">
					<ul class="search_terms">
						<li>
							<strong class="title ml20" style="width: 85px">시스템아이디</strong>
							<select id="s_FindSystemId" name="s_FindSystemId" style="width: 170px;" class="list_box">
								<option>선택하세요!</option>
							</select>
						</li>
						<li>
							<strong class="title ">시스템명</strong>
							<select id="s_FindSysName" name="s_FindSysName" style="width: 170px;" class="list_box" disabled>
								<option>선택하세요!</option>
							</select>
						</li>
						<li>
							<strong class="title " style="width: 85px">오류내용</strong>
							<select id="s_FindErrCont" name="s_FindErrCont"	style="width: 170px;" class="list_box">
								<option value="">선택하세요!</option>
								<option value="0">사용자미등록녹취</option>
								<option value="1">패킷미수신녹취</option>
							</select>
						</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li>
							<strong class="title ml20" style="width: 86px">상담사명</strong>
							<input type="text" id="s_FindUserName" name="s_FindUserName" class="InputReadL" style="width: 170px" />
						</li>
						<li>
							<strong class="title ">상담사ID</strong>
							<input type="text" id="s_FindUserId" name="s_FindUserId" class="InputReadL" style="width: 170px" />
						</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li>
							<strong class="title ml20" style="width: 85px">내선번호</strong>
							<input type="text" id="s_FindDnNo" name="s_FindDnNo" class="InputReadL" style="width: 170px" />
						</li>
						<li>
							<strong class="title ">전화기IP</strong> 
							<input type="text" id="s_FindPhoneIp" name="s_FindPhoneIp" class="InputReadL" style="width: 170px" />
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
				<!-- <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E" style="display: none;">Excel Export</button> -->
				<button type="button" id="btnReset" class="btn_m">초기화</button>
			</div>
			<div class="h136">
				<div class="btn_topArea fix_h25"></div>
				<div class="grid_area h25 pt0">
					<div id="gridList" style="width: 100%; height: 315px;"></div>
				</div>
			</div>
		</section>
	</div>
</body>

</html>