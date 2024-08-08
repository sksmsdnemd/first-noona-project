<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<%-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script> --%>

<script>
	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId = loginInfo.SVCCOMMONID.rows.tenantId;
	var userId = loginInfo.SVCCOMMONID.rows.userId;
	var grantId = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu = "녹취파일분류";
	var dataArray;
	var overlapParentLevel = 0;
	
	var orgFilePath;
	var orgPath;
	var orgDeletePath;
	var gFilePath;
	var cudMode;
	$(document).ready(function(param) {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	    cudMode = sPopupOptions.cudMode;
	    
	    fnInitCtrl();
	    
	    setDetailTable(sPopupOptions.pRowIndex);
	    
		
	});
	
	//var fvKeyId;
	
	function fnInitCtrl() {
		
		argoCbCreate("s_FindSystemId", "sysGroup", "getSysCbList", {sort_cd : 'SYSTEM_ID'}, {"selectIndex" : 0,"text" : '선택하세요!',"value" : ''});
		argoCbCreate("s_FindGubunStatus", "baseCode", "getBaseComboList", {classId : 'gb_status'}, {"selectIndex" : 0,"text" : '선택하세요!',"value" : ''});
		
		$("#s_FindSystemId").change(function() {
			fnSystemChange();
		});
		
		$("#btnAdd").click(function (){
			fnGubunUpadate();
		});
	
		$('input:radio[name="ip_DeleteUseFlag"]').change(function(){
			fnChangeDeleteRadio(this);
		});
		
	}
	
	function fnSystemChange(){
		argoJsonSearchList('comboBoxCode', 'getSysGubunProcList', 's_', {findSystemId : $("#s_FindSystemId").val()}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					var html = '<option value="">선택하세요!</option>';
					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							html += '<option value="'+row.code+'">'+row.codeNm+'</option>';
						});
					}else{
						argoAlert("등록가능한 프로세스가 없습니다.");
					}
					$("#s_FindProcessCode").html(html);
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function setDetailTable(row) {
		if (cudMode == "U") {
			$("#s_FindSystemId").attr("disabled", true);
			$("#s_FindProcessCode").attr("disabled", true);
			$("#s_FindSystemId").val(row.systemId).prop("selected",true);
			$("#s_FindProcessCode").html('<option value="'+row.processId+'">'+row.processName+'</option>');
			$("#s_FindGubunKind").val(row.gubunKind);
			$("#s_FindGubunStatus").val(row.gubunStatus).prop("selected",true);;
			$("#s_FindGubunFileMax").val(row.gubunFileMax);
			$("#s_FindGubunSelectDay").val(row.gubunSelectDay);
			$("#s_FindGubunDirectory").val(row.gubunDirectory);
			$("#s_FindDeleteDirectory").val(row.deleteDirectory);
			$("#s_FindGubunMediaFreeSpace").val(row.gubunMediaFreeSpace);
		}
	}
	
	function fnGubunUpadate() {
		if($("#s_FindSystemId").val() == ""){
			argoAlert("시스템을 선택해주세요.");
			return false;
		}else if($("#s_FindProcessCode").val() == ""){
			argoAlert("프로세스를 선택해주세요.");
			return false;
		}else if($("#s_FindGubunKind").val() == ""){
			argoAlert("분류미디어를 선택해주세요.");
			return false;
		}else if($("#s_FindGubunStatus").val() == ""){
			argoAlert("실행상태를 선택해주세요.");
			return false;
		}else if($("#s_FindGubunFileMax").val() == ""){
			argoAlert("파일처리개수를 작성해주세요.");
			return false;
		}else if($("#s_FindGubunSelectDay").val() == ""){
			argoAlert("검색기간을 작성해주세요.");
			return false;
		}else if($("#s_FindGubunDirectory").val() == ""){
			argoAlert("분류베이스디렉토리를 작성해주세요.");
			return false;
		}else if($("#s_FindDeleteDirectory").val() == ""){
			argoAlert("삭제베이스디렉토리를 작성해주세요.");
			return false;
		}else if($("#s_FindGubunMediaFreeSpace").val() == ""){
			argoAlert("여유공간을 작성해주세요.");
			return false;
		}
		fnSavePop();
	}
	
	function fnChangeDeleteRadio(obj){
		if($(obj).attr("id")=="ip_DeleteUseFlag1"){ //기간
			$("#ip_LimitForm").css("display","");
			$("#ip_LimitTitle").text("기간");
			$("#ip_LimitData").text("년");
		}else if($(obj).attr("id")=="ip_DeleteUseFlag2"){ //용량
			$("#ip_LimitForm").css("display","");
			$("#ip_LimitTitle").text("용량");
			$("#ip_LimitData").text("MB");
		}else{ //사용안함
			$("#ip_LimitForm").css("display","none");
		}
	}
	
	function fnSavePop() {
		var aValidate;
		argoConfirm("저장 하시겠습니까?", function() {
			fnDetailInfoCallback();
		});
	}
	
	function fnDetailInfoCallback() {
		try {
	
			var Resultdata;
	
			if (cudMode == "I") {
				Resultdata = argoJsonUpdate("recSearch",
						"setSysGubunInfo", "s_", {
							"cudMode" : cudMode
						});
			} else {
				Resultdata = argoJsonUpdate("recSearch",
						"setSysGubunInfoUpdate", "s_", {
							"cudMode" : cudMode,
						});
			}
	
			if (Resultdata.isOk()) {
				argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
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
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="btns_top">
            		<button type="button" id="btnAdd" class="btn_m confirm">등록</button>
            	</div>
            	<div class="input_area">
            		<table class="input_table">
						<tr>
							<th>시스템</th>
							<td style="text-align: left; width:100px;">
								<select id="s_FindSystemId" name="s_FindSystemId" style="width:220px;"></select>
							</td>
						</tr>
						<tr>
							<th>프로세스</th>
							<td style="text-align: left;">
								<select id="s_FindProcessCode" name="s_FindProcessCode" style="width:220px;">
									<option value="">선택하세요!</option>
								</select>
							</td>
						</tr>
						<tr>
							<th>분류미디어</th>
							<td style="text-align: left;">
								<select id="s_FindGubunKind" name="s_FindGubunKind" style="width:220px;">
									<option value="">선택하세요!</option>
									<option value="1">Voice</option>
									<option value="2">Screan</option>
								</select>
							</td>
						</tr>
						<tr>
							<th>실행상태</th>
							<td style="text-align: left;">
								<select id="s_FindGubunStatus" name="s_FindGubunStatus" style="width:220px;">
								</select>
							</td>
						</tr>
						<tr>
							<th>파일처리개수</th>
							<td style="text-align: left;"><input style="width:220px;"
								type="text" id="s_FindGubunFileMax" name="s_FindGubunFileMax" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" value="" />
							</td>
						</tr>
						<tr>
							<th>검색기간</th>
							<td style="text-align: left;"><input style="width:220px;"
								type="text" id="s_FindGubunSelectDay" name="s_FindGubunSelectDay" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');" placeholder="일" value="" />
							</td>
						</tr>
						<tr>
							<th>분류베이스디렉토리</th>
							<td style="text-align: left;"><input style="width:220px;"
								type="text" id="s_FindGubunDirectory" name="s_FindGubunDirectory" value="" />
							</td>
						</tr>
						<tr>
							<th>삭제베이스디렉토리</th>
							<td style="text-align: left;"><input style="width:220px;"
								type="text" id="s_FindDeleteDirectory" name="s_FindDeleteDirectory" value="" />
							</td>
						</tr>
						<tr>
							<th>여유공간</th>
							<td style="text-align: left;"><input style="width:220px;"
								type="text" id="s_FindGubunMediaFreeSpace" name="s_FindGubunMediaFreeSpace" onkeyup="this.value=this.value.replace(/[^0-9]/g,'');"  placeholder="GB" value="" />
							</td>
						</tr>
					</table>
				</div>
            </div>            
        </section>
    </div>
</body>

</html>
