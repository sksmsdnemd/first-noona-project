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

	$(document).ready(function(param) {
		fnInitCtrl();
		
		fnSearchListCnt();

	});

	function fnInitCtrl() {
		argoSetDatePicker();
		fnInitGrid();

		$("#btnSearch").click(function() { //조회
			fnSearchListCnt();
		});

		$("#btnReset").click(
				function() {
					argoSetValue("s_FindGroupId", "");
					$('#s_FindTenantId option[value="' + tenantId + '"]').prop(
							'selected', true);
				});

		$("#ip_Limit").keyup(function() {
			$("#ip_Limit").val($("#ip_Limit").val().replace(/[^0-9]/g, ''));
		});
		
		$("#btnAdd2").click(function(){
			gPopupOptions = {cudMode:'I'} ;
			argoPopupWindow('녹취파일분류 등록', 'RecFilePathPopAdd2F.do', '800', '740');
		});
	}

	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >=0 ) {
					gPopupOptions = {cudMode:'U', pRowIndex:record} ;
					argoPopupWindow('녹취파일분류 수정', 'RecFilePathPopAdd2F.do', '800', '740');
				}
	        },
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'gubunCode', 		caption: '분류코드', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunName', 		caption: '분류이름', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunPath', 	caption: '분류경로', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunUseFlag', 		caption: '구분사용여부', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunUseFlagText', 		caption: '구분사용여부', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'deleteUseFlag', 		caption: '삭제사용여부', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'deleteUseFlagText', 		caption: '삭제사용여부', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'storageDay', 		caption: '보관기간', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'storageVolumn', 		caption: '보관용량', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'storageUseVolumn', 		caption: '보관사용중용량', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'deletePath', 		caption: '삭제경로', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunDesc', 		caption: '분류설명', 		size: '8%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid','deleteUseFlag','gubunUseFlag');
	}
	
	function fnSearchListCnt(){
		w2ui.grid.lock('조회중', true);

		argoJsonSearchOne('recSearch', 'getRecFilePathListCnt', 's_', {} , function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					
					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	function fnSearchList(startRow, endRow){
		argoJsonSearchList('recSearch', 'getRecFilePathList', 's_', {"iSPageNo":startRow,"iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();

					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {  "recid" 			: index
					    				, "gubunCode"			: row.gubunCode
					   					, "gubunName"			: row.gubunName
										, "gubunPath" 		: row.gubunPath
										, "gubunDesc" 	: row.gubunDesc
										, "gubunUseFlag" 		: row.gubunUseFlag	 
										, "gubunUseFlagText" 		: row.gubunUseFlag == "1" ? "사용" : "사용안함"
										, "deleteUseFlagText" 		: row.deleteUseFlag	== "1" ? "사용" : "사용안함"
										, "deleteUseFlag" :  row.deleteUseFlag
										, "storageDay" 		: row.storageDay
										, "storageVolumn" 		: row.storageVolumn
										, "storageUseVolumn" 		: row.storageUseVolumn
										, "deletePath" 		: row.deletePath
										};
							dataArray.push(gObject2);
						});
						
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
			} catch(e) {
				console.log(e);			
			}
		});
	}

	function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchList();
			}
		} catch (e) {
			argoAlert(e);
		}
	}

	
	var saveFlag = true;
	function fnGubunInfoDetail() {
		argoJsonSearchOne('recSearch', 'getRecFileGubunInfo', 's_', {},
				function(data, textStatus, jqXHR) {
					console.log(data);
					try {
						if (data.isOk()) {
							if (data.getRows() != "") {
								saveFlag = false;
								$("#btnSaveGubunInfo").html("수정");
								var row = data.SVCCOMMONID.rows;
								$("#s_FindGubunStatus").val(row.gubunStatus);
								$("#s_FindGubunStartDate").val(
										row.gubunStartDate); 
								$("#s_FindGubunFileMax").val(row.gubunFileMax);
								$("#s_FindGubunSelectDay").val(
										row.gubunSelectDay);
								$("#s_FindGubunMediaSpace").val(
										row.gubunMediaSpace);
								$("#s_FindGubunMediaFreeSpace").val(
										row.gubunMediaFreeSpace);
								$("#s_FindGubunDirectory").val(
										row.gubunDirectory);
								$("#s_FindDeleteDirectory").val(row.deleteDirectory);
							} else {
								saveFlag = true;
								$("#btnSaveGubunInfo").html("저장");
								$("#s_FindGubunStatus").val("");
								$("#s_FindGubunStartDate").val("");
								$("#s_FindGubunFileMax").val("");
								$("#s_FindGubunSelectDay").val("");
								$("#s_FindGubunMediaSpace").val("");
								$("#s_FindGubunMediaFreeSpace").val("");
								$("#s_FindGubunDirectory").val("");
								$("#s_FindDeleteDirectory").val("");
							}
						}
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
			<span class="location_home">HOME</span><span class="step">운용관리</span>
			<span class="step">사용자관리</span><strong class="step">그룹정보관리</strong>
		</div>
		<section class="sub_contents">
			<div class="search_area row3">
				<div class="row">
					<ul class="search_terms">
						<li>
                            <strong class="title_wide ml20">분류코드</strong>
							<input type="text"	id="s_FindGubunCode" name="s_FindGubunCode" style="width: 231px;"/>
                        </li>
						<li>
                            <strong class="title_wide ml20">분류명</strong>
							<input type="text"	id="s_FindGubunName" name="s_FindGubunName" style="width: 231px;"/>
                        </li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">분류사용유무</strong> 
							<select id="s_FindGubunUseFlag" name="s_FindGubunUseFlag" style="width: 231px;" class="list_box">
									<option value="">선택하세요!</option>
									<option value="1">사용</option>
									<option value="0">사용안함</option>
							</select>
						</li>
						<li><strong class="title_wide ml20">삭제사용유무</strong> 
							<select id="s_FindDeleteUseFlag" name="s_FindDeleteUseFlag" style="width: 231px;" class="list_box">
									<option value="">선택하세요!</option>
									<option value="1">사용</option>
									<option value="0">사용안함</option>
							</select>
						</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">사용중용량</strong> 
							<input type="text"	id="s_FindStorageUseVolumn" name="s_FindStorageUseVolumn" style="width: 231px;"/>
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
				<button type="button" id="btnAdd2" class="btn_m search"onclick="">등록</button>
			</div>
			<div class="table_grid detail hide"
				style="position: absolute; width: 49%; margin-top: 10px; height: 70%; border: none; right: 0px; background: #ffffff;">
				<div class="btns_top">
					<button type="button" id="btnUpdate" class="btn_m confirm"
						onclick="javascript:fnGroupUpadate();">수정</button>
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
							<th>상위그룹명</th>
							<td id="td_parentGroupNm"
								style="text-align: left; padding-left: 10px"></td>
						</tr>
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
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
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
