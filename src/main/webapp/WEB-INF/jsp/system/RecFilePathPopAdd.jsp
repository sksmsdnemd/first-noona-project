<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script src="<c:url value="/scripts/velocejs/convertListToTree.js"/>"></script>
<script src="<c:url value="/scripts/jstree3.3.3/dist/jstree.js"/>"></script>
<link rel="stylesheet"
	href="<c:url value="/scripts/jstree3.3.3/dist/themes/default/style.css"/>"
	type="text/css" />

<script>
	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId = loginInfo.SVCCOMMONID.rows.tenantId;
	var userId = loginInfo.SVCCOMMONID.rows.userId;
	var grantId = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu = "녹취파일분류";
	var dataArray;
	var duplchkAt = false;
	var CodeAt = false;
	var deletePathAt = false;
	var overlapParentLevel = 0;

	var orgFilePath;
	var orgFilePathId;
	var orgPath;
	var orgDeletePath;
	var gFilePath;
	var cudModea;
	$(document).ready(function(param) {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	    cudModea = sPopupOptions.cudModea;
	    
	    setDetailTable(sPopupOptions.pRowIndex);
	    
		fnInitCtrl();
		fnSearchList();

	});

	//var fvKeyId;

	function fnInitCtrl() {
		$("#btnSaveGubunInfo").click(function() {
			fnSaveGubunInfo();
		});
		
		

		
		fn_overlapView($("#ip_FilePath"),'filePath');
		fn_overlapView($("#ip_PathCode"),'pathCode');
		fn_overlapView($("#ip_DeletePath"),'deletePath');
	}
	
	function duplchk(obj, inpId) {
		//btnFilePath/btnPathCode
		if ($("#" + inpId).val() == null || $("#" + inpId).val() == "") {
			if ($(obj).attr("id") == "btnFilePath") {
				argoAlert("분류 PATH를 입력하세요.");
				return;
			} else if($(obj).attr("id") == "btnDeletePath"){
				argoAlert("삭제 PATH를 코드를 입력하세요.");
				return;
			}else {
				argoAlert("분류 코드를 입력하세요.");
				return;
			}
		}

		argoJsonSearchOne('recSearch', 'getRecFilePathCnt', 'ip_', {
			"orgFilePathId" : orgFilePathId,
			"overlapParentLevel" : overlapParentLevel,
			"inpId" : $(obj).attr("id")
		}, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					if (data.getRows() != "") {
						// 중복아이디 존재
						if (data.getRows()['cnt'] > 0) {
							if ($(obj).attr("id") == "btnFilePath") {
								duplchkAt = false;
								argoAlert("존재하는 구분경로 입니다.<br/>다시한번 확인해주세요.");
							} else if($(obj).attr("id") == "btnDeletePath"){
								deletePathAt = false;
								argoAlert("존재하는 삭제경로 입니다.<br/>다시한번 확인해주세요.");
							} else {
								CodeAt = false;
								argoAlert("존재하는 분류 코드입니다.<br/>다시한번 확인해주세요.");
							}
						} else {
							if ($(obj).attr("id") == "btnFilePath") {
								duplchkAt = true;
								argoAlert("사용가능한 구분경로 입니다.");
							} else if($(obj).attr("id") == "btnDeletePath"){
								deletePathAt = true;
								argoAlert("사용가능한 삭제경로 입니다.");
							} else {
								CodeAt = true;
								argoAlert("사용가능한 분류 코드입니다.");
							}
						}
					}
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSaveGubunInfo() {
		if (!fnBlankChk()) {
			return;
		}
		// insert
		if (saveFlag) {
			argoJsonUpdate("recSearch", "setRecFileGubunInfo", "s_", {},
					function(data, textStatus, jqXHR) {
						try {
							if (data.isOk()) {
								if (data.SVCCOMMONID.procCnt > 0) {
									argoAlert('저장되었습니다.');
								} else {
									argoAlert('잠시 후 다시 시도해주세요.');
								}
							}
						} catch (e) {
							console.log(e);
						}
					});
			// update
		} else {
			argoJsonUpdate("recSearch", "setRecFileGubunInfoUpdate", "s_", {},
					function(data, textStatus, jqXHR) {
						try {
							if (data.isOk()) {
								if (data.SVCCOMMONID.procCnt > 0) {
									argoAlert("저장되었습니다.");
								} else {
									argoAlert("잠시 후 다시 시도해주세요.");
								}

							}
						} catch (e) {
							console.log(e);
						}
					});
		}
	}
	
	function fn_overlapView(obj,type){
		var strChk = "";
		var btnId = "";
		$(obj).on("keyup", function() {
			if(type=='deletePath'){
				strChk = orgDeletePath;
				btnId = "btnDeletePath";
				$(this).val($(this).val().replace(/[/\\]/g, ''));
				$(this).val($(this).val().replace(/[/]/g, ''));
			}else if(type=='filePath'){
				strChk = orgPath;
				btnId = "btnFilePath";
				$(this).val($(this).val().replace(/[/\\]/g, ''));
				$(this).val($(this).val().replace(/[/]/g, ''));
			}else if(type=='pathCode'){
				$(this).val($(this).val().replace(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/g, ''));
			}
			
			if (cudMode == "U") {
				if ($(this).val() != strChk) {
					duplchkAt = false;
					$("#"+btnId).show();
				} else {
					duplchkAt = true;
					$("#"+btnId).hide();
				}
			}
		});
	} 
	

	
	function setDetailTable(row) {
		if (cudMode == "U") {
			/* cudMode==U : 값 세팅 */
			orgFilePathId = row.id;
			orgPath = row.filePathPath;
			orgDeletePath = row.deletePath;
			$("#ip_FilePath").val(row.filePathPath);
			$("#ip_GroupName").val(row.filePathName);
			$("#ip_GroupDesc").val(row.filePathDesc);
			$("#ip_ParentId").val(row.id);
			$("#ip_PathCode").val(row.id);
			$("#ip_DeletePath").val(row.deletePath);
			$("#ip_StorageVolumn").val(row.storageVolumn);
			$("#ip_Limit").val(row.storageDay);
			$("#ip_PathCode").attr("disabled", true);
// 			fnChangeDeleteRadio($("#ip_DeleteUseFlag" + row.deleteUseFlag));
			$("#ip_DeletePath").val(row.deletePath);
			$("#ip_StorageUseVolumn").val(row.storageUseVolumn);
			$("#ip_UseFlag" + row.gubunUseFlag).prop("checked", true);
			$("#ip_DeleteUseFlag" + row.deleteUseFlag).prop("checked", true);

			duplchkAt = true;
			CodeAt = true;
			deletePathAt = true;

			$("#btnFilePath").hide();
			$("#btnPathCode").hide();
			$("#btnDeletePath").hide();
		} else {
			orgFilePathId = "";
			var pNode = $('#layerTree').jstree(true).get_node(row.parent);

			CodeAt = false;
			duplchkAt = false;
			deletePathAt = false;
			
			$("#ip_PathCode").attr("disabled", false);
			$("#ip_Limit").val("");
			$("#td_parentGroupNm").html('');
			$("#ip_FilePath").val('');
			$("#ip_GroupName").val('');
			$("#ip_GroupDesc").val('');
			$("#ip_ParentId").val('');
			$("#ip_PathCode").val('');
			$("#ip_TopParentId").val('');
			$("#ip_StorageUseVolumn").val('');
			$("#ip_DeletePath").val('');
			$("#ip_Limit").val('');
			$("#ip_StorageVolumn").val('');
			$("#ip_StorageUseVolumn").val('');
			$("#ip_LimitForm").css("display","none");
			$("#ip_UseFlagY").prop("checked", true);
			$("#ip_DeleteUseFlag0").prop("checked", true);
		}
	}
	
	// 공백체크
	function fnBlankChk() {
		if ($("#s_FindSystemId").val() == "") {
			argoAlert("시스템을 선택해주세요.");
			return false;
		}
		if ($("#s_FindProcessCode").val() == "") {
			argoAlert("프로세스를 구분을 선택해주세요.");
			return false;
		}
		if ($("#s_FindGubunStatus").val() == "") {
			argoAlert("구분상태를 선택해주세요.");
			return false;
		}
		if ($("#s_FindGubunStartDate").val() == "") {
			argoAlert("구분시작일을 선택해주세요.");
			return false;
		}
		if ($("#s_FindGubunFileMax").val() == "") {
			argoAlert("구분파일처리개수을 채워주세요.");
			return false;
		}
		if ($("#s_FindGubunSelectDay").val() == "") {
			argoAlert("구분파일검색기간을 채워주세요.");
			return false;
		}
		if ($("#s_FindGubunMediaSpace").val() == "") {
			argoAlert("구분디렉토리용량을 채워주세요.");
			return false;
		}
		if ($("#s_FindGubunMediaFreeSpace").val() == "") {
			argoAlert("구분디렉토리여유공간을 채워주세요.");
			return false;
		}
		if ($("#s_FindGubunDirectory").val() == "") {
			argoAlert("구분베이스디렉토리를 채워주세요.");
			return false;
		}
		if($("#s_FindDeleteDirectory").val()==""){
			argoAlert("삭제베이스디렉토리를 채워주세요.");
			return false;
		}
		return true;
	}
	
	function fnGubunUpadate() {
		if (!duplchkAt) {
			argoAlert("PATH 중복확인이 필요합니다.");
			return;
		} else if (!CodeAt) {
			argoAlert("분류코드 중복확인이 필요합니다.");
			return;
		}else if(!deletePathAt){
			argoAlert("삭제 PATH 중복확인이 필요합니다.");
			return;
		}else if ($("#ip_Limit").val() == "") {
			argoAlert("보관기간을 입력해주세요.");
			return;
		} else if ($("#ip_GroupName").val() == "") {
			argoAlert("분류명을 입력해주세요.");
			return;
		} else {
			fnSavePop();
		}
	}
	


	function fnSavePop() {
		var aValidate;
		argoConfirm("저장 하시겠습니까?", function() {
			aValidate = {
				rows : [ {
					"check" : "length",
					"id" : "ip_GroupName",
					"minLength" : 1,
					"maxLength" : 50,
					"msgLength" : "그룹이름을 다시 확인하세요."
				} ]
			};

			if (argoValidator(aValidate) != true)
				return;

			gFilePath = $("ip_FilePath").val();
			fnDetailInfoCallback();
		});
	}

	function fnDetailInfoCallback() {
		try {

			var Resultdata;

			$("#ip_InsId").val(userId);
			if (cudMode == "I") {
				Resultdata = argoJsonUpdate("recSearch",
						"setRecFilePathInsert", "ip_", {
							"cudMode" : cudMode
						});
			} else {

				$("#ip_UptId").val($("#ip_InsId").val());
				Resultdata = argoJsonUpdate("recSearch",
						"setRecFilePathUpdate", "ip_", {
							"cudMode" : cudMode,
							"orgFilePathId" : orgFilePathId
						});

				Resultdata = argoJsonUpdate("recSearch",
						"setRecFilePathUseUpdate", "ip_", {
							"cudMode" : cudMode,
							"orgFilePathId" : orgFilePathId
						});
			}

			if (Resultdata.isOk()) {
				argoAlert("저장하였습니다");
				
				$(".detail").addClass("hide");
			} else {
				argoAlert("저장에 실패하였습니다");
			}
		} catch (e) {
			console.log(e);
		}
	}

</script>
</head>
<body>
	<div class="sub_wrap">
		<div class="location">
			<span class="location_home">HOME</span><span class="step">운용관리</span>
			<span class="step">사용자관리</span><strong class="step">그룹정보관리</strong>
		</div>
		<section class="sub_contents">
			<div class="search_area row5">
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">시스템</strong> <select
							id="s_FindSystemId" name="s_FindSystemId" style="width: 300px;"
							class="list_box">
								<option value="">선택하세요!</option>
						</select></li>
						<li><strong class="title title_wide ml20">프로세스구분</strong> <select
							id="s_FindProcessCode" name="s_FindProcessCode"
							style="width: 300px;" class="list_box">
								<option value="">선택하세요!</option>
						</select></li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">구분상태</strong> <select
							id="s_FindGubunStatus" name="s_FindGubunStatus"
							style="width: 300px;" class="list_box">
								<option value="">선택하세요!</option>
								<option value="Y">Y</option>
								<option value="N">N</option>
						</select></li>
						<li><strong class="title_wide ml20">구분시작일</strong> <span
							class="select_date" style="width: 284px;"> <input
								type="text" class="datepicker onlyDate" style="width: 300px;"
								readonly="readonly" id="s_FindGubunStartDate"
								name="s_FindGubunStartDate">
						</span> <span class="timepicker rec" id="rec_time1"></span></li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">구분파일처리개수</strong> <input
							type="text" id="s_FindGubunFileMax" name="s_FindGubunFileMax"
							style="width: 300px" value=""
							onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" /></li>
						<li><strong class="title_wide ml20">구분파일검색기간</strong> <input
							type="text" id="s_FindGubunSelectDay" name="s_FindGubunSelectDay"
							style="width: 300px" value="" value=""
							onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" /></li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">구분디렉토리용량</strong> <input
							type="text" id="s_FindGubunMediaSpace"
							name="s_FindGubunMediaSpace" style="width: 300px" value=""
							placeholder="MB"
							onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" /></li>
						<li><strong class="title_wide ml20">구분디렉토리여유공간</strong> <input
							type="text" id="s_FindGubunMediaFreeSpace"
							name="s_FindGubunMediaFreeSpace" style="width: 300px" value=""
							placeholder="MB"
							onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" /></li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">구분베이스디렉토리</strong> <input
							type="text" id="s_FindGubunDirectory" name="s_FindGubunDirectory"
							style="width: 300px" value="" /></li>
						<li><strong class="title_wide ml20">삭제베이스디렉토리</strong> <input
							type="text" id="s_FindDeleteDirectory" name="s_FindDeleteDirectory"
							style="width: 300px" value="" /></li>
						<li>
							<button type="button" id="btnSaveGubunInfo" class="btn_m confirm"
								style="margin-left: 13px;" value="저장">저장</button>
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
				<button type="button" id="btnAdd" class="btn_m search"
					onclick="addJsTree()">등록</button>
			</div>


			<div class="table_grid tree"
				style="position: absolute; width: 49%; margin-top: 10px; height: 70%; border: 1px solid #e3e3e3">
				<button type="button" id="btnOpen" class="btn_m" onclick="showAll()">전체닫기</button>
				<div id="layerTree"
					style="display: block; height: 100%; overflow: auto;"></div>
			</div>


			<div class="table_grid detail hide"
				style="position: absolute; width: 49%; margin-top: 10px; height: 70%; border: none; right: 0px; background: #ffffff;">
				<div class="btns_top">
					<button type="button" id="btnUpdate" class="btn_m confirm"
						onclick="javascript:fnGubunUpadate();">수정</button>
					<button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
				</div>
				<div class="table_head"
					style="height: 100%; border-left: none; border-right: none; border-bottom: none; background: #ffffff;">

					<table id="detailTable">
						<colgroup>
							<col width="30%">
							<col>
						</colgroup>
						<tr>
							<th>분류명</th>
							<td style="text-align: left; padding-left: 10px"><input
								type="text" id="ip_GroupName" name="ip_GroupName" value="" /></td>
						</tr>
						<tr>
							<th>분류코드</th>
							<td style="text-align: left; padding-left: 10px"><input
								type="text" id="ip_PathCode" name="ip_PathCode" value="" />
								<button type="button" class="btn_m"
									onclick="javascript:duplchk(this,'ip_PathCode')"
									id="btnPathCode">중복확인</button></td>
						</tr>
						<tr>
							<th>분류경로</th>
							<td style="text-align: left; padding-left: 10px"><input
								type="text" id="ip_FilePath" name="ip_FilePath" value="" />
								<button type="button" class="btn_m"
									onclick="javascript:duplchk(this,'ip_FilePath')"
									id="btnFilePath">중복확인</button></td>
						</tr>
						<tr>
							<th>삭제경로</th>
							<td style="text-align: left; padding-left: 10px"><input
								type="text" id="ip_DeletePath" name="ip_DeletePath" value="" />
								<button type="button" class="btn_m"
									onclick="javascript:duplchk(this,'ip_DeletePath')"
									id="btnDeletePath">중복확인</button></td>
						</tr>
						<tr>
							<th>분류 사용 여부</th>
							<td style="text-align: left; padding-left: 10px"><input
								type="radio" id="ip_UseFlagY" name="ip_UseFlag" value="Y">사용함
								<input type="radio" id="ip_UseFlagN" name="ip_UseFlag" value="N">사용안함
							</td>
						</tr>
						<tr>
							<th>삭제 사용 여부</th>
							<td style="text-align: left; padding-left: 10px">
								<input type="radio" id="ip_DeleteUseFlag1" name="ip_DeleteUseFlag" value="1">기간삭제
								<input type="radio" id="ip_DeleteUseFlag2" name="ip_DeleteUseFlag" value="2">용량삭제
								<input type="radio" id="ip_DeleteUseFlag0" name="ip_DeleteUseFlag" value="0">사용안함
							</td>
						</tr>
						<tr id="ip_LimitForm" style="display:none;">
							<th>삭제<span id="ip_LimitTitle">기간</span></th>
							<td style="text-align: left; padding-left: 10px"><input
								type="text" id="ip_Limit" name="ip_Limit" value="" />&nbsp;&nbsp;<spen id="ip_LimitData"><spen id="ip_LimitData">년</spen></td>
						</tr>
						<tr>
							<th>보관용량</th>
							<td style="text-align: left; padding-left: 10px"><input
								type="text" id="ip_StorageVolumn" name="ip_StorageVolumn" value="" /></td>
						</tr>
						<tr>
							<th>사용 중 용량</th>
							<td style="text-align: left; padding-left: 10px"><input
								type="text" id="ip_StorageUseVolumn" name="ip_StorageUseVolumn" value="" /></td>
						</tr>
						<tr>
							<th>설명</th>
							<td style="padding-left: 10px"><textarea id="ip_GroupDesc"
									name="ip_GroupDesc" style="height: 300px"></textarea>
						</tr>
						<input type="hidden" id="ip_ValueTitleId" name="ip_ValueTitleId"
							value="" />
						<input type="hidden" id="ip_GroupMngId" name="ip_GroupMngId"
							value="" />
						<input type="hidden" id="ip_TopParentId" name="ip_TopParentId"
							value="" />
						<input type="hidden" id="ip_ParentId" name="ip_ParentId" value="" />
						<input type="hidden" id="ip_InsId" name="ip_InsId" value="" />
						<input type="hidden" id="ip_UptId" name="ip_UptId" value="" />
					</table>


				</div>
			</div>
		</section>

	</div>

</body>

</html>
