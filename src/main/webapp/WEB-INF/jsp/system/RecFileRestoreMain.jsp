<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/velocejs/veloce.popupWindow.js?ver=2017010611"/>"></script>

<style>
#mask {
	position: absolute;
	left: 0;
	top: 0;
	z-index: 100;
	background-color: #ffffff;
	display: none;
}

#loadingImg {
	position: absolute;
	left: 45%;
	top: 50%;
	z-index: 120;
}

.restoreCircle {
	width: 50px;
	height: 50px;
	border-radius: 50%;
}
</style>
<script>
	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	if (loginInfo != null) {
		var tenantId = loginInfo.SVCCOMMONID.rows.tenantId;
		var userId = loginInfo.SVCCOMMONID.rows.userId;
		var grantId = loginInfo.SVCCOMMONID.rows.grantId;
		var workIp = loginInfo.SVCCOMMONID.rows.workIp;
		var playerKind = loginInfo.SVCCOMMONID.rows.playerKind;
		var convertFlag = loginInfo.SVCCOMMONID.rows.convertFlag;
		var groupId = loginInfo.SVCCOMMONID.rows.groupId;
		var depth = loginInfo.SVCCOMMONID.rows.depth;
		var controlAuth = loginInfo.SVCCOMMONID.rows.controlAuth;
		var backupAt = loginInfo.SVCCOMMONID.rows.backupAt;
	} else {
		var tenantId = 'bridgetec';
		var userId = 'btadmin';
		var grantId = 'SuperAdmin';
		var workIp = '127.0.0.1';
		var playerKind = '0';
		var convertFlag = '1';
		var groupId = '1';
		var depth = 'A';
		var controlAuth = null;
	}

	var workMenu = "녹취파일복원";
	var workLog = "";
	var recAuth = '<spring:eval expression="@code['Globals.recAuth']"/>';
	
	var serverIp;
	var dataArray = new Array();
	var tmpSelection;
	var serverPort = document.location.protocol == "http:" ? 7060 : 7070;

	$(document).ready(
			function() {
				fnInitCtrl();
				fnSysinfoIpList();
				fnInitGrid();

				serverIp =  $("#s_FindIp option:selected").val() + ":" + serverPort + "/";
			});

	// 접속서버 리스트
	function fnSysinfoIpList() {
		argoJsonSearchList('sysInfo', 'getSysinfoIpList', 's_', null, function(
				data, textStatus, jqXHR) {
			var row = data.SVCCOMMONID.rows;
			var html;

			for (var i = 0; i < row.length; i++) {
				var rowi = row[i];
// 				html += "<option value='"+document.location.protocol+"//"+rowi.systemIp+"'>"+rowi.systemName+"("+rowi.systemIp+")</option>";
				html += "<option value='"+rowi.systemIp+"'>"+rowi.systemName+"("+rowi.systemIp+")</option>";
			}
			$("#s_FindIp").html(html);
		});
	}

	var idxRecDate = 1;
	var idxRecTime = 2;
	var idxRecStatus = 3;
	var idxRestoreStatusCd = 4;
	var idxDnNo = 5;
	var idxCallId = 6;
	var idxTenantId = 7;
	var idxUserId = 8;
	var idxFileName = 9;
	var idxRestoreCnt = 10;
	var idxRecKey = 11;
	var idxRestoreMergeKey = 12;
	var idxRestoreKind = 13;
	var idxCustTel = 14;

	function fnInitCtrl() {
		$("#btnSearch").click(function() { //조회
			fnSearchListCnt();
		});

		$("#btnServerSearch").click(function() {
			if (confirm("로그조회 하시겠습니까?")) {
				$("#loadingImg").show();
				wrapWindowByMask();
				fnRestoreSearchList();
			}
		});

		$("#s_SearchCount").change(function() {
			dataPerPage = $("#s_SearchCount option:selected").val();
		});

		$("#s_FindSystemId").change(
				function() {
					if ($('#s_FindSystemId option:selected').val() == '') {
						$("#s_FindSysName").find("option").remove();
					} else {
						argoCbCreate("s_FindSysName", "comboBoxCode",
								"getSystemName", {
									findSystemId : $(
											'#s_FindSystemId option:selected')
											.text()
								});
					}
				});

		$("#s_FindIp").change(
				function() {
					serverIp =  $("#s_FindIp option:selected").val() + ":" + serverPort + "/";
				})
	}

	function fnInitGrid() {
		argoSetDatePicker();
		$("#s_txtDate")
				.val(argoSetFormat(argoCurrentDateToStr(), "-", "4-2-2"));

		argoSetTimePicker({
			use_sec : true
		});

		$('#gridList').w2grid({
			name : 'grid',
			show : {
				lineNumbers : true,
				footer : true,
				selectColumn : true
			},

			onDblClick : function(event) {
				fnPopupRecPlay(event.recid);
			},
			multiSelect : true,
			columns : [ {
				field : 'recid',
				caption : 'recid',
				size : '0%',
				sortable : true,
				attr : 'align=center'
			}//1
			, {
				field : 'recDate',
				caption : '통화일자',
				size : '8%',
				sortable : true,
				attr : 'align=center'
			}//2
			, {
				field : 'recTime',
				caption : '통화일자',
				size : '8%',
				sortable : true,
				attr : 'align=center'
			}//3
			, {
				field : 'recStatus',
				caption : '복원상태',
				size : '8%',
				sortable : true,
				attr : 'align=center'
			}//4
			, {
				field : 'restoreStatusCd',
				caption : '복원CD',
				size : '8%',
				sortable : true,
				attr : 'align=center'
			}//5
			, {
				field : 'dnNo',
				caption : '내선번호',
				size : '8%',
				sortable : true,
				attr : 'align=center'
			}//6
			, {
				field : 'callId',
				caption : '콜아이디',
				size : '25%',
				sortable : true,
				attr : 'align=center'
			},//7
			{
				field : 'tenantId',
				caption : '테넌트ID',
				size : '10%',
				sortable : true,
				attr : 'align=center'
			}//8
			, {
				field : 'userId',
				caption : '상담원ID',
				size : '10%',
				sortable : true,
				attr : 'align=center'
			}//9
			, {
				field : 'fileName',
				caption : '파일이름',
				size : '10%',
				sortable : true,
				attr : 'align=center'
			}//10
			, {
				field : 'restoreCnt',
				caption : '파일개수',
				size : '5%',
				sortable : true,
				attr : 'align=center'
			}//11
			, {
				field : 'recKey',
				caption : '',
				size : '5%',
				sortable : true,
				attr : 'align=center'
			}//12
			, {
				field : 'restoreMergeKey',
				caption : '',
				size : '5%',
				sortable : true,
				attr : 'align=center'
			}//13
			,{
				field : 'restoreKind',
				caption : '',
				size : '5%',
				sortable : true,
				attr : 'align=center'
			}
			//14
			,{
				field : 'custTel',
				caption : '',
				size : '5%',
				sortable : true,
				attr : 'align=center'
			}
			, {
				field : 'blank',
				caption : '',
				size : '5%',
				sortable : true,
				attr : 'align=center'
			}

			],
			records : dataArray
		});

		w2ui['grid'].hideColumn('row');
		w2ui['grid'].hideColumn('restoreStatusCd');
		w2ui['grid'].hideColumn('restoreMergeKey');
		w2ui['grid'].hideColumn('recid');
		w2ui['grid'].hideColumn('recKey');
		w2ui['grid'].hideColumn('restoreKind');
		w2ui['grid'].hideColumn('blank');
		w2ui['grid'].hideColumn('custTel');
	}

	function fnPopupRecPlay(state) {
		if (state >= 0) {
			fnRecFilePlay(state);
		}
	}

	function fnRecFilePlay(index) {

		// web재생
		if (index < 0) {
			var arrChecked = w2ui['grid'].getSelection();
			if (arrChecked.length == 0) {
				return;
			}
			$.each(arrChecked, function(row, colIndex) {
				index = w2ui['grid'].getCellValue(colIndex, 0);
				alert(index);
				return false;
			});
		}

		var callPlayRecord = playRecord.bind(null, w2ui['grid'], index); // now
		velocePopupWindow('청취(고객명 :  정보없음 )', 'about:blank',
				'594', '386', '', 'sttPlay', callPlayRecord,
				"fnSelectedRow");

		return;
	}

	//리스트 로우 개수
	var dataPerPage = 15;
	function fnSearchListCnt() {
		fnRestoreStatusView();

		argoJsonSearchOne('recSearch', 'getRecRestoreSearchListCnt', 's_', {},
				function(data, textStatus, jqXHR) {
					try {
						if (data.isOk()) {
							var totalData = data.getRows()['cnt'];
							paging(totalData, "1", dataPerPage, "3");

							$("#totCount").text(totalData);

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

	// 타이머
	var timer;
	function playInter(playFlag, delay, fn) {

		if (playFlag == "Y") {
			clearInterval(timer);
			timer = setInterval(fn, delay);
		} else {
			clearInterval(timer);
		}
	}

	// 현재 current page 에서 리로드
	function fnSearchListResearching() {
		fnSearchList(dataPerPage, (dataPerPage * $("#paging a.on").attr('id')));
	}

	// 복원 상태 확인
	function fnRestoreStatus(status) {
		var url = document.location.protocol + "//" + serverIp;
		var param = {};
		param.result = "0";
		param.url = url + "VocRestoreStatus.do";
		param.paramDataType = "json";
		
		
		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			data : JSON.stringify(param),
			contentType: "application/json; charset=utf-8",
			success : function(data) {
				var result = JSON.parse(decodeURI(data));
				fnRestoreStatusView();
				if (result.result == "OK") {
					playInter('N');
					$("#restLoading").css("display", "none");
					argoAlert(status + "이 완료되었습니다.");
					fnSearchListResearching();
				} else {

				}
			},
			error : function(xhr, status, error) {
				$("#restLoading").css("display", "none");
				console.log("fnDbEncrypt = error");
			}
		})
	}
	// 복원상태값 조회
	function fnRestoreStatusView() {
		argoJsonSearchList('recSearch', 'getRecRestoreStatusList', 's_', null,
			function(data, textStatus, jqXHR) {
				if (data.isOk()) {
					var row = data.SVCCOMMONID.rows;
					var restCnt0 = 0;
					var restCnt1 = 0;
					var restCnt2 = 0;
					var restCnt3 = 0;
					var restCnt4 = 0;
					var restCnt5 = 0;
					var restCnt6 = 0;

					for (var i = 0; i < row.length; i++) {
						var status = row[i].status;
						var cnt = row[i].cnt;
						// 0==복원대기 1==변환중+전송중 2=변환중 3==전송중 4==복원완료 5==복원실패 10==병합파일 11==병합
						switch (status) {
							case "0":restCnt0=cnt; break;
							case "2":restCnt1+=cnt; restCnt2=cnt; break;
							case "3":restCnt1+=cnt; restCnt3=cnt; break;
							case "4":restCnt4=cnt; break;
							case "5":restCnt5=cnt; break;
							case "11":restCnt6=cnt; break;
						}
					}
					$("#rest0").text(restCnt0);
					$("#rest1").text(restCnt1);
					$("#rest2").text(restCnt2);
					$("#rest3").text(restCnt3);
					$("#rest4").text(restCnt4);
					$("#rest5").text(restCnt5);
					$("#rest6").text(restCnt6);
				}
			});
	}

	// 로그조회
	function fnRestoreSearchList() {

		var url = document.location.protocol + "//" + serverIp;
		var restoreKind;
		if($("#s_resotre_kind").val() == "1")
			restoreKind = "VocRestoreVpaSearchList.do";
		else if($("#s_resotre_kind").val() == "2")
			restoreKind = "VocRestoreSearchList.do";
		else if($("#s_resotre_kind").val() == "3")
			restoreKind = "VocRestoreVssSearchList.do";

		var param = {};

		param.dnNo = $("#s_FindDnName").val();
		param.recKey = $("#s_FindCallID").val();
		param.recDate = $("#s_txtDate").val().replaceAll('-', '');
		param.recFrmTm = $("#s_RecFrmTm").val().replaceAll(':', '');
		param.recEndTm = $("#s_RecEndTm").val().replaceAll(':', '');
		param.url = url + restoreKind;
		param.paramDataType = "json";

		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			data : JSON.stringify(param),
			contentType : "application/json; charset=utf-8",
			success : function(data) {
				var result = JSON.parse(decodeURI(data));

				if (result.result == "NG") {
					argoAlert(result.data);
				} else {
					fnSearchListCnt();
				}
				$("#loadingImg").hide();
				$('#mask').hide();
			},
			error : function(xhr, status, error) {
				$("#loadingImg").hide();
				$('#mask').hide();
			}
		});

	}

	// 복원상태 0초기화
	function fnRestoreStatusViewReset() {
		$("#rest0").text(0);
		$("#rest1").text(0);
		$("#rest2").text(0);
		$("#rest3").text(0);
		$("#rest4").text(0);
		$("#rest5").text(0);
		$("#rest6").text(0);
	}

	// 복원 
	function fnRestore() {
		var num = w2ui["grid"].getSelection();
		var list = w2ui["grid"].records;

		if (num.length == 0) {
			argoAlert('한 개 이상 체크하세요.');
			return false;
		}

		var url = document.location.protocol + "//" + serverIp;
		var param = {};
		param.recKey = new Array();
		param.RecTime = new Array();
		param.restoreKind = new Array();
		param.totalCount = String(num.length);
		param.url = url + "VocRestoreSelect.DO";
		param.paramDataType = "json";

		for (var i = 0; i < num.length; i++) {
			param.recKey.push(list[num[i]].recKey);
			param.RecTime.push(list[num[i]].recDate.replaceAll('-', '')+list[num[i]].recTime.replaceAll(':', ''));
			param.restoreKind.push(list[num[i]].restoreKind);
		}

		playInter('Y', 3000, "fnRestoreStatus('복원');");
		argoAlert("녹취파일 복원이 시작되었습니다.");
		fnRestoreStatusViewReset();
		$("#restLoading").css("display", "");

		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			data : JSON.stringify(param),
			contentType: "application/json; charset=utf-8",
			success : function(data) {
				var result = JSON.parse(decodeURI(data));
				if (result.result == "NG") {
					argoAlert(result.data);
				}
			},
			error : function(xhr, status, error) {
				console.log("fnDbEncrypt = error");
			}
		});
	}

	// 전체복원
	function fnRestoreAll() {

		if (!confirm("현재 필터를 근거하여 파일을 복원 하시겠습니다.")) {
			return false;
		}

		var url = document.location.protocol + "//" + serverIp;
		var param = {};
		param.dnNo = $("#s_FindDnName").val();
		param.recKey = $("#s_FindCallID").val();
		param.recDate = $("#s_txtDate").val().replaceAll('-', '');
		param.recFrmTm = $("#s_RecFrmTm").val().replaceAll(':', '');
		param.recEndTm = $("#s_RecEndTm").val().replaceAll(':', '');
		param.restoreKind = $("#s_resotre_kind").val();
		param.url = url + "VocRestoreAll.DO";
		param.paramDataType = "json";

		playInter('Y', 3000, "fnRestoreStatus('복원');");
		argoAlert("녹취파일 복원이 시작되었습니다.");
		fnRestoreStatusViewReset();
		$("#restLoading").css("display", "");

		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			data : JSON.stringify(param),
			contentType: "application/json; charset=utf-8",
			success : function(data) {
				var result = JSON.parse(decodeURI(data));
				if (result.result == "NG") {
					argoAlert(result.data);
				}

			},
			error : function(xhr, status, error) {
				console.log("fnDbEncrypt = error");
			}
		});
	}

	function fnSearchList(startRow, endRow) {

		argoJsonSearchList(
				'recSearch',
				'getRecRestoreSearchList',
				's_',
				{
					"iSPageNo" : startRow,
					"iEPageNo" : endRow
				},
				function(data, textStatus, jqXHR) {
					try {
						if (data.isOk()) {
							w2ui.grid.clear();
							console.log(data);
							if (data.getRows() != "") {
								dataArray = new Array();
								dataChilrenArr = new Array();
								$
										.each(
												data.getRows(),
												function(index, row) {
													var processStatus = '';
													if (row.restoreStatusCd == '0') {
														processStatus = "gray";
													} else if (row.restoreStatusCd == '2' || row.restoreStatusCd == '3') {
														processStatus = "blue";
													} else if (row.restoreStatusCd == '10'
															|| row.restoreStatusCd == '11'
															|| row.restoreStatusCd == '4') {
														processStatus = "green";
													} else if (row.restoreStatusCd == '5') {
														processStatus = "Red";
													}

													var processIcon = '<img src="../images/icons/circle_' + processStatus + '.gif">'
													gObject2 = {
														"recid" : index,
														"dnNo" : row.dnNo,
														"tenantId" : row.tenantId,
														"recDate" : row.recDate,
														"recStatus" : row.restoreStatusStr
																+ " "
																+ processIcon,
														"recTime" : row.recTime,
														"userId" : row.userId,
														"fileName" : row.fileName,
														"restoreCnt" : row.restoreCount,
														"recKey" : row.recKey,
														"restoreStatusCd" : row.restoreStatusCd,
														"restoreMergeKey" : row.restoreMergeKey,
														"callId" : row.callId,
														"restoreKind" : row.restoreKind
													};

													dataArray.push(gObject2);

												});
								console.log(dataArray);
								w2ui['grid'].add(dataArray);
							}
						}
						w2ui.grid.unlock();
					} catch (e) {
						console.log(e);
					}
				});
	}

	// 초기화
	function fnFindReset() {
		$("#s_FindIp option:eq(0)").attr("selected","selected");
		argoSetValue('s_FindDnName', '');
		argoSetValue('s_FindCallID', '');
		argoSetValue('s_txtDate', stringNon_ToDateformat(
				argoCurrentDateToStr(), 'yyyy-mm-dd'));
		argoSetValue('s_RecFrmTm', '00:00:00');
		argoSetValue('s_RecEndTm', '23:59:59');
	}

	//로그조회 로딩바
	function wrapWindowByMask() {
		//화면의 높이와 너비를 구한다.
		var maskHeight = $(document).height();
		var maskWidth = $(window).width();

		//마스크의 높이와 너비를 화면 것으로 만들어 전체 화면을 채운다.
		$('#mask').css({
			'width' : maskWidth,
			'height' : maskHeight
		});

		//애니메이션 효과 - 일단 1초동안 까맣게 됐다가 80% 불투명도로 간다.
		//$('#mask').fadeIn(1000);      
		$('#mask').fadeTo("slow", 0.6);
	}

	// 복원중 초기화
	function fnRestoreRollback() {
		var num = w2ui["grid"].getSelection();
		var list = w2ui["grid"].records;

		if (num.length == 0) {
			argoAlert('한 개 이상 체크하세요.');
			return false;
		}

		var url = document.location.protocol + "//" + serverIp;
		var param = {};
		param.recKey = new Array();
		param.totalCount = String(num.length);

		// now
		for (var i = 0; i < num.length; i++) {
			param.recKey.push(list[num[i]].recKey);
		}

		argoAlert("복원중인 파일 초기화가 시작되었습니다.");
		fnRestoreStatusViewReset();
		fnRestoreStatusView();
		$("#restLoading").css("display", "");
		param.url = url + "VOCRESTOREROLLBACK.DO";
		param.paramDataType = "json";

		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			data : JSON.stringify(param),
			contentType: "application/json; charset=utf-8",
			success : function(data) {
				var result = JSON.parse(decodeURI(data));
				if (result.result == "OK") {

					argoAlert("복원중인 파일 초기화가 완료되었습니다.");
					fnSearchListResearching();
				} else {
					argoAlert(result.data);
				}
				$("#restLoading").css("display", "none");
			},
			error : function(xhr, status, error) {
				$("#restLoading").css("display", "none");
				console.log("fnDbEncrypt = error");
			}
		});
	}

	//병합
	function fnRestoreMurge() {
		var num = w2ui["grid"].getSelection();
		var list = w2ui["grid"].records;

		if (num.length <= 1 ) {
			argoAlert('두 개 이상 체크하세요.');
			return false;
		}

		var url = document.location.protocol + "//" + serverIp;
		var param = {};
		param.recKey = new Array();
		param.restoreKind = new Array();
		param.totalCount = String(num.length);
		param.url = url + "VOCRESTOREMERGE.DO";
		param.paramDataType = "json";
		
		for (var i = 0; i < num.length; i++) {
			param.recKey.push(list[num[i]].recKey);
			param.restoreKind.push(list[num[i]].restoreKind);
		}

		$("#restLoading").css("display", "");
		playInter('Y', 3000, "fnRestoreStatus('병합');");
		argoAlert(num.length + "개의 파일을 병합을 시작합니다.");
		fnRestoreStatusViewReset();

		$.ajax({
			url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
			type : "POST",
			data : JSON.stringify(param),
			contentType: "application/json; charset=utf-8",
			success : function(data) {
			},
			error : function(xhr, status, error) {
				console.log("fnDbEncrypt = error");
			}
		});
	}

	/*
	 *	재생 목록을 팝업에 보내는 함수
	 */
	var playRecord = function(grid, rowIndex) {
		var arrChecked = [];
		if (rowIndex === undefined) {
			arrChecked = w2ui['grid'].getSelection();
			tmpSelection = arrChecked;
		} else {
			arrChecked.push(rowIndex);
			tmpSelection = arrChecked;
		}
		var form = document.getElementById("stt_form");
		if (form == null) {
			form = document.createElement("form");
			form.setAttribute("id", "stt_form");
			form.setAttribute("method", "post");
			form.setAttribute("target", "sttPlay");

			var agent = navigator.userAgent.toLowerCase();

			if (agent.indexOf("chrome") != -1)
				var playUrl = gGlobal.ROOT_PATH + "/recording/STTPlayRestoreF.do";
			
			form.setAttribute("action", playUrl);

			document.getElementsByTagName("body").item(0).appendChild(form);

			var recData = document.createElement("input");
			recData.setAttribute("type", "hidden");
			recData.setAttribute("id", "recData");
			recData.setAttribute("Name", "recData");

			form.appendChild(recData);
		}

		var recList = [];

		$.each(arrChecked, function(row, colIndex)
		{
			var recItem = new Object();

			var tenantId = grid.getCellValue(colIndex, idxTenantId);
			var recKey = grid.getCellValue(colIndex, idxRecKey);
			var recTime = grid.getCellValue(colIndex, idxRecDate) + " " + grid.getCellValue(colIndex, idxRecTime);
			var custTel = grid.getCellValue(colIndex, idxCustTel);
			var fmtRecTime = grid.getCellValue(colIndex,idxRecDate)+ " " + grid.getCellValue(colIndex, idxRecTime);
			var dnNo = grid.getCellValue(colIndex, idxDnNo);
			var userId2 = grid.getCellValue(colIndex, idxUserId);	//녹취한 아이디 기존 userid 사용중이라 2로 정함
			var call_id = grid.getCellValue(colIndex, idxCallId);
			var restoreKind = grid.getCellValue(colIndex, idxRestoreKind);
		
			recItem.tenant_id = tenantId;
			recItem.recKey = recKey;
			recItem.ip = $("#s_FindIp option:selected").val();
			recItem.port = serverPort;
			recItem.manager_id = userId;
			recItem.enc_key = 'BRIDGETEC_VELOCE';
			recItem.dn_no = dnNo;
			recItem.rec_time = fmtRecTime;
			recItem.custTel = custTel;
			recItem.user_id = userId2;
			recItem.call_id = call_id;
			recItem.restoreKind = restoreKind;

			recList.push(recItem);

		});
		var recData = document.getElementById("recData");
		var txtRecData = JSON.stringify(recList);
		recData.value = encodeURIComponent(txtRecData);
		gPopupOptions = {};
		gPopupOptions.grid = w2ui.grid;
		form.submit();
		return true;
	}

	/*
	 *	일괄 재생
	 */
	function fnMultiRecPlay() {
		if (w2ui['grid'].getSelection().length == 0) {
			argoAlert("한 개 이상의 녹취를 선택해주세요.");				
			return;
		}
		
		if (playerKind == null || playerKind == "0") {
			var callPlayRecord = playRecord.bind(null, w2ui['grid']);
			velocePopupWindow('청취', 'about:blank', '594', '386', '', 'sttPlay',
					callPlayRecord, "fnSelectedRow");
		} else {
			fnRecFilePlay(-1);
		}
	}

	function fnSelectedRow(){
		for( var i = 0; i < tmpSelection.length ; i++){
			w2ui['grid'].select(tmpSelection[i]);
		}
	}

	function fnSearchInfo() {
		var arrChecked = w2ui['grid'].getSelection();
		var record = w2ui["grid"].records[arrChecked[0]];

		if (arrChecked.length <= 0) {
			argoAlert("파일을 체크해주세요.");
			return false;
		} else if (arrChecked.length > 1) {
			argoAlert("한 개만 체크헤주세요.");
			return false;
		}

		if (record.recid >= 0) {
			gPopupOptions = {
				cudMode : 'U',
				pRowIndex : record
			};
			argoPopupWindow('복원/병합 파일', 'RecFileRestorePopAddF.do', '800',
					'460');
		}
	}
</script>
</head>
<body>
	<div class="sub_wrap">
		<div id="mask">
			<img alt="loading" id="loadingImg" src="../images/large-loading.gif"
				style="display: none;">
		</div>
		<div class="location">
			<span class="location_home">HOME</span><span class="step">시스템관리</span><span
				class="step">시스템점검</span><strong class="step">시스템별현황</strong>
		</div>
		<section class="sub_contents">
			<div class="search_area row3">
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title ml20">IP</strong> <select
							id="s_FindIp" name="s_FindIp" style="width: 300px;"
							class="list_box">
								<option>선택하세요!</option>
						</select></li>
						<li>
							<strong class="title ml20">복원종류</strong> 
							<select id="s_resotre_kind" style="width: 80px;">
								<option value="1">VPA</option>
								<!-- <option value="2">BRU</option> -->
								<option value="3">VSS</option>
							</select>
							<input type="text" id="s_FindPort" name="s_FindPort" value="7060" hidden />
						</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title ml20">내선번호</strong> <input
							type="text" id="s_FindDnName" name="s_FindDnName"
							style="width: 300px" /></li>
						<li><strong class="title ml20">CALLID</strong> <input
							type="text" id="s_FindCallID" name="s_FindCallID"
							style="width: 300px" /></li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li style="width: 672px"><strong class="title ml20">녹취일자</strong>
							<span class="select_date"> <input type="text"
								class="datepicker onlyDate" id="s_txtDate" name="s_txtDate">
						</span> <span class="timepicker rec" id="rec_time1"> <input
								type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time"
								value="00:00:00"> <a href="#" class="btn_time">시간 선택</a>
						</span> <span class="text_divide" style="width: 234px">&nbsp; ~
								&nbsp;</span> <span class="timepicker rec" id="rec_time2"> <input
								type="text" id="s_RecEndTm" name="s_RecEndTm"
								class="input_time on" value="23:59:59"> <a href="#"
								class="btn_time">시간 선택</a>
						</span> &nbsp;</li>
						<button type="button" id="btnServerSearch" class="btn_m search"
							style="float: right;">로그조회</button>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<div class="sub_l">
					<strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount">0</span>&nbsp;
					<select id="s_SearchCount" name="s_SearchCount" style="width: 50px"
						class="list_box">
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="30">30</option>
						<option value="40">40</option>
						<option value="50">50</option>
					</select>&nbsp;&nbsp;&nbsp;
				</div>
				<button type="button" id="btnSearchInfo" class="btn_m confirm"
					onclick="fnSearchInfo();">내역보기</button>
				<button type="button" id="btnRestoreMerge" class="btn_m confirm"
					onclick="fnRestoreMurge();">병합</button>
				<button type="button" id="btnRestoreRollback" class="btn_m confirm"
					onclick="fnRestoreRollback();">복원중 초기화</button>
				<button type="button" id="btnRestoreAll" class="btn_m confirm"
					onclick="fnRestoreAll();">전체복원</button>
				<button type="button" id="btnRestore" class="btn_m confirm"
					onclick="fnRestore();">복원</button>
					<button type="button" id="btnRestorePlay" class="btn_m confirm"
					onclick="fnMultiRecPlay();">일괄청취</button>
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
				<button type="button" id="btnReset" class="btn_m"
					onclick="fnFindReset();">초기화</button>
			</div>
			<div class="btns_middle">
				<!--0==조회 1=변환중 2==전송중 3==복원완료 4==복원실패 10==병합파일 11==병합-->
				<strong style="width: 25px">[ 복원상태 ]</strong> 복원대기 : <span id="rest0">0</span>
				&nbsp; 복원중 (총 건수 : <span id="rest1">0</span> , 변환중 : <span id="rest2">0</span> , 전송중 : <span id="rest3">0</span>)
				&nbsp; 복원완료 : <span id="rest4">0</span> 
				&nbsp; 복원실패 : <span id="rest5">0</span> 
				&nbsp; 병합파일 : <span id="rest6">0</span> 
				&nbsp; <img alt="로딩중" id="restLoading"
					src="../images/large-loading.gif" style="display: none;">
			</div>
			<div class="h136">
				<div class="btn_topArea fix_h25"></div>
				<div class="grid_area h25 pt0">
					<div id="gridList" style="width: 100%; height: 415px;"></div>
					<div class="list_paging" id="paging">
						<ul class="paging">
							<li><a href="#" id='' class="on">1</a></li>
						</ul>
					</div>
				</div>
			</div>
		</section>
	</div>
</body>

</html>
