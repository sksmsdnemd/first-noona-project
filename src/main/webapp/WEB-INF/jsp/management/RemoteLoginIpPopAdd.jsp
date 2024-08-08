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
	var workMenu = "원격로그인IP 관리";
	var dataArray;
	var overlapParentLevel = 0;
	
	var cudMode;
	var ipSeq = "";
	
	$(document).ready(function(param) {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	    cudMode = sPopupOptions.cudMode;
	    
	    fnInitCtrl();
	    
	    ArgSetting();
	});
	
	function ArgSetting(){
		setDetailTable();
	}
	
	function fnInitCtrl() {
		argoCbCreate("ip_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		$("#btnAdd").click(function (){
			fnLoginIpInsert();
		});
		
		$("input[name='ip_FindIpFlag01']").change(function(){
			if($("input[name='ip_FindIpFlag01']:checked").val()=="0"){
				$("#trEndIp").hide();
			}else{
				$("#trEndIp").show();
			}
		});
	}
	
	function setDetailTable() {
		var row = sPopupOptions.pRowIndex;
		if (cudMode == "U") {
			ipSeq = row.ipSeq;
			$("#ip_FindTenantId").val(row.tenantId);
			$("#ip_FindIpFlag"+row.ipFlag).attr("checked",true);
			$("#ip_FindStartIp").val(row.startIp);
			$("#ip_FindEndIp").val(row.endIp);
			$("#ip_FindLoginFlag"+row.loginFlag).attr("checked",true);
			$("#ip_FindUseFLag"+row.useFlag).attr("checked",true);
			$("#ip_FindComments").val(row.ipComments);
			if(row.ipFlag == "1"){
				$("#trEndIp").show();
			}
		}
	}
	
	function fnValidateIPaddress(inpText) {
		var regExp =  new RegExp('^([1-9]?[0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([1-9]?[0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([1-9]?[0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([1-9]?[0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$');
		var regResult = regExp.test(inpText);
		if(!regResult){
			argoAlert("IP를 확인해주세요.<br/>ex) 255.255.255.1");
		}
		return regResult;
	}
	
	function fnBlankCheck(){
		if($("#ip_FindTenantId").val() == ""){
			argoAlert("태넌트를 선택해주세요.");
			return false;
		}
		
		if($("#ip_FindStartIp").val() == ""){
			argoAlert("시작IP를 작성해주세요.");
			return false;
		}else{
			chk = fnValidateIPaddress($("#ip_FindStartIp").val());
		}
		
		if($("input[name='ip_FindIpFlag01']:checked").val()=="1"){//범위
			if($("#ip_FindEndIp").val() == ""){
				argoAlert("범위IP를 작성해주세요.");
				return false;
			}else{
				chk = fnValidateIPaddress($("#ip_FindEndIp").val());
			}
		}else{
			$("#ip_FindEndIp").val("");
		}
		return true;
	}
	
	function fnLoginIpInsert() {
		if(!fnBlankCheck()){
			return false;
		}
		
		argoJsonSearchOne('userInfo', 'getLoginIpDuplicateCheck', 'ip_', {"cudMode":cudMode , "ipSeq":ipSeq} , function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					
					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoConfirm("저장 하시겠습니까?", function() {
							var Resultdata;
							
							if (cudMode == "I") {
								Resultdata = argoJsonUpdate("userInfo","setLoginIpInsert", "ip_", {});
							} else {
								Resultdata = argoJsonUpdate("userInfo","setLoginIpUpdate", "ip_", {"ipSeq":ipSeq});
							}
					
							if (Resultdata.isOk()) {
								argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
							} else {
								argoAlert("저장에 실패하였습니다");
							}
						});
					}else{
						argoAlert("중복된 IP입니다.");
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
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="btns_top">
            		<button type="button" id="btnAdd" class="btn_m confirm">등록</button>
            	</div>
            	<div class="input_area">
            		<table class="input_table">
						<tr>
							<th>태넌트</th>
							<td style="text-align: left; width:100px;">
								<select id="ip_FindTenantId" name="ip_FindTenantId" style="width:220px;"></select>
							</td>
						</tr>
						<tr>
							<th>범위</th>
							<td style="text-align: left;">
								<span> <label> <input type="radio" name="ip_FindIpFlag01" id="ip_FindIpFlag0" value="0" checked/> </label></span>특정 
								<span> <label> <input type="radio" name="ip_FindIpFlag01" id="ip_FindIpFlag1" value="1" /> </label></span>범위
							</td>
						</tr>
						<tr>
							<th>시작IP</th>
							<td style="text-align: left;">
								<input style="width:220px;" type="text" id="ip_FindStartIp" name="ip_FindStartIp" value="" onkeyup="" placeholder="255.255.255.1" />
							</td>
						</tr>
						<tr id="trEndIp" style="display:none;">
							<th>범위IP</th>
							<td style="text-align: left;">
								<input style="width:220px;" type="text" id="ip_FindEndIp" name="ip_FindEndIp" value="" placeholder="255.255.255.1" />
								</select>
							</td>
						</tr>
						<tr>
							<th>로그인</th>
							<td style="text-align: left;">
								<span> <label> <input type="radio" name="ip_FindLoginFlag01" id="ip_FindLoginFlag0" value="0"  checked/> </label></span>허용 
								<span> <label> <input type="radio" name="ip_FindLoginFlag01" id="ip_FindLoginFlag1" value="1"/> </label></span>금지
							</td>
						</tr>
						<tr>
							<th>상태</th>
							<td style="text-align: left;">
								<span> <label> <input type="radio" name="ip_FindUseFLag01" id="ip_FindUseFLag0" value="0"  checked/> </label></span>사용 
								<span> <label> <input type="radio" name="ip_FindUseFLag01" id="ip_FindUseFLag1" value="1"/> </label></span>미사용
							</td>
						</tr>
						<tr>
							<th>설명</th>
							<td style="text-align: left;">
								<textarea rows="5" id="ip_FindComments" name="ip_FindComments"></textarea>
							</td>
						</tr>
					</table>
				</div>
            </div>            
        </section>
    </div>
</body>

</html>
