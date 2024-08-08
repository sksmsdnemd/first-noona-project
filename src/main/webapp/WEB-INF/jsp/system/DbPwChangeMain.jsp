<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="com.bridgetec.common.util.security.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017021301"/>"></script>

<!-- 순서에 유의 -->
<script type="text/javascript" src="<c:url value="/scripts/security/rsa.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/jsbn.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/prng4.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/rng.js"/>"></script>

<script>
	$(function () {
	    fnSysinfoIpList();
		pageOpenValue();
	});

	var serverPort		 = document.location.protocol == "http:" ? 7060 : 7070;
	const userIdEnc		 = '<spring:eval expression="@code['Globals.ARGO.RDB.Account']"/>';
	const dbPort 		 = '<spring:eval expression="@code['Globals.ARGO.RDB.DbPort']"/>';
	const dbIp 			 = '<spring:eval expression="@code['Globals.ARGO.RDB.DbIp']"/>';
	const sid 			 = '<spring:eval expression="@code['Globals.ARGO.RDB.Sid']"/>';
	var userId 			 = "";
	var bWauFlag		 = true;
	var loginInfo 		 = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId		 = loginInfo.SVCCOMMONID.rows.tenantId;
    var adminuserId 	 = loginInfo.SVCCOMMONID.rows.userId;
    var bAdminFlag 		 = false;

	// default value
	function pageOpenValue(){
		$("#s_FindDBIP").val(dbIp+":"+dbPort+"/"+sid);
		fnDbIDEncrypt();
	}

	// DB ID 복호화
	function fnDbIDEncrypt(){
		var param = {"id" :userIdEnc};
		$.ajax({
			url : "/BT-VELOCE/common/DbPassWordDecryptF.do",
			type : "POST",
			data:param,
			success : function(data) {
				$("#s_inpDBID").val(data.id);
				userId = data.id;
			},error : function(xhr, status, error) {
				argoAlert("DbPassWordDecryptF" + error);
			}
		});
	}
	var arrWAU = new Array();
	var arrWAU = [];
	// 접속서버 리스트
	function fnSysinfoIpList() {
		var objHtml = "";
		objHtml += "<tr>";
		objHtml += "<th>시스템</th>";
		objHtml += "<th>패스워드변경</th>";
		objHtml += "<th>리부트</th>";
		objHtml += "</tr>";
		argoJsonSearchList('sysGroup', 'getSysIpList', 's_', null, function (data, textStatus, jqXHR) {
			if(data.isOk()) {
				$.each(data.getRows(), function( index, row ) {
					$.ajax({
						url : document.location.protocol + "//"+row.code+":"+serverPort+"/ProcessCheck.do",
						type : "POST",
						async: false,
						data : {},
						contentType: "application/json; charset=utf-8",
						success : function(jsonData) {
							if(JSON.parse(decodeURI(jsonData)).result != "NG") {
								arrWAU.push({"name":row.codeNm, "ip":row.code, "connect":true});
								objHtml += "<tr>";
								objHtml += "<td>"+row.systemName+" ("+row.code+")</td>";
								objHtml += "<td style='text-align:center; height:42px;' id='"+row.code.replaceAll(".","")+"_1'>대기</td>";
								objHtml += "<td style='text-align:center; height:42px;' id='"+row.code.replaceAll(".","")+"_2'>대기</td>";
								objHtml += "</tr>";
							}
							else{
								arrWAU.push({"name":row.codeNm, "ip":row.code, "connect":false});
								objHtml += "<tr>";
								objHtml += "<td>"+row.systemName+" ("+row.code+")</td>";
								objHtml += "<td colspan='2' style='text-align:center; height:42px;'>"+JSON.parse(decodeURI(jsonData)).data+"</td>";
								objHtml += "</tr>";
								bWauFlag = false;
							}
							
						},
						error : function(xhr, status, error) {
							arrWAU.push({"name":row.codeNm, "ip":row.code, "connect":false});
							objHtml += "<tr>";
							objHtml += "<td>"+row.systemName+" ("+row.code+")</td>";
							objHtml += "<td colspan='2' style='text-align:center; height:42px;'>서버 통신 장애!!</td>";
							objHtml += "</tr>";
							bWauFlag = false;
						}
					});
				});
			}
		});
		$(".resultData").append(objHtml);
	}

	// 패스워드 변경 confirm 알림창
	function fnDbPwChangeConfirm(){		
		if(bWauFlag==false){
			argoAlert("WAU 프로세스 전부 연결 가능해야 DB 패스워드 변경 가능 합니다.");
			return false;
		}
		if($("#btnAdminChk").attr('disabled') === undefined && bAdminFlag == true){
			argoAlert("관리자 패스워드 인증해주세요.");
			return false;
		}
		if($("#s_inpDBPwChange").val() == ""){
			argoAlert("변경 패스워드를 입력해 주세요.");
			return false;
		}
		if( $("#s_inpDBPwChangeChk").val() == ""){
			argoAlert("패스워드 확인.");
			return false;
		}
		if($("#s_inpDBPwChange").val() != $("#s_inpDBPwChangeChk").val()){
			argoAlert("변경 패스워드 확인이 일치하지 않습니다.");
			return false;
		}
		if(confirm("변경하시겠습니까?")){
			fnDbEncrypt();
		}
	}

	//관리자 인증
	function fnAdminPwChk()
	{
		if($("#s_inpAdminPw").val() == ""){
			argoAlert(adminuserId+" 관리자 패스워드 입력해 주세요.");
			return false;
		}
		$("#s_TenantId").val(tenantId);
		$("#s_AgentId").val(adminuserId);
		// rsa 암호화 Start
		var oriUserPwd = $('#s_inpAdminPw').val();
		var rsa = new RSAKey();
		rsa.setPublic($('#RSAModulus').val(), $('#RSAExponent').val());
		
		var AgentPw = rsa.encrypt(oriUserPwd);
		// rsa 암호화 End

		argoJsonSearchOne("ARGOCOMMON", "login", "s_", {CallMothd:"salt", AgentPw:AgentPw}, function (LoginData, textStatus2, jqXHR2) {
			var pawCheck = LoginData.getRows().length;
			if(pawCheck == 0){
				//로그인 실패
				$.ajax({
					url : "/BT-VELOCE/common/GetRsaKeyF.do",
					type : "POST",
					async: false,
					success : function(data) {
                    	$("#RSAModulus").val(data.RSAModulus);
                    	$("#RSAExponent").val(data.RSAExponent);
                    	bAdminFlag = true;
					},error : function(xhr, status, error) {
						argoAlert("GetRsaKeyF :"+error);
					}
				});
				
				argoAlert("관리자 패스워드 확인 해주세요");
			}else{
				$("#btnAdminChk").text("인증성공");
				$("#btnAdminChk").attr('disabled', true);
			}	
		});

	}

	// 암호화
	function fnDbEncrypt(){
		var param = {"sid":sid, "id" : userId, "pwChange" : $("#s_inpDBPwChange").val()};
		$.ajax({
			url : "/BT-VELOCE/common/DbPassWordSecurityF.do",
			type : "POST",
			data:param,
			async: false,
			success : function(data) {
				fnDbPwChange(data);
			},error : function(xhr, status, error) {
				argoAlert("DbPassWordSecurityF :"+error);
			}
		});
	}

	// 패스워드 변경
	function fnDbPwChange(param){
		var bStartFlag = true;
		$.each(arrWAU, function(index, row){
			if(row.connect == false)
				return true;

			$.ajax({
				url : document.location.protocol + "//"+row.ip+":"+serverPort+"/DBPwChange.do",
				type : "POST",
				data:JSON.stringify(param),
				async: false,
				success : function(data) {
					var result = JSON.parse(decodeURI(data));
					if(result.result == "OK"){
						$("#"+row.ip.replaceAll(".","")+"_1").html(result.data);
					}else{
						$("#"+row.ip.replaceAll(".","")+"_1").html(result.data);
						bStartFlag = false;
					}
				},error : function(xhr, status, error) {
					$("#"+row.ip.replaceAll(".","")+"_1").html(error);
					bStartFlag = false;
				}
			});
		});

		if(bStartFlag == true){
			fnDBPwChangeResult(param);
		}else{
			argoAlert("패스워드 확인 필요합니다.");
		}
	}

	// function fnDbPassWordSecurity(param){
	// 	$.ajax({
	// 		url : "/BT-VELOCE/common/ProDbPassWordChangeF.do",
	// 		type : "POST",
	// 		data:{"pwChange": $("#s_inpDBPwChange").val()},
	// 		async: false,
	// 		success : function(data) {
	// 			console.log("fnDbPassWordSecurity = success");
	// 			fnDBPwChangeResult(param);
	// 		},error : function(xhr, status, error) {
	// 			console.log("fnDbPassWordSecurity = error");
	// 		}
	// 	});
	// }

	function fnDBPwChangeResult(param){
		$.each(arrWAU, function(index, row){
			if(row.connect == false)
				return true;

			$.ajax({
				url : document.location.protocol + "//"+row.ip+":"+serverPort+"/MwsReboot.do",
				type : "POST",
				data:JSON.stringify(param),
				async: false,
				success : function(data) {
					var result = JSON.parse(decodeURI(data));
					if(result.result == "OK"){
						$("#"+row.ip.replaceAll(".","")+"_2").html(result.data);
					}else{
						$("#"+row.ip.replaceAll(".","")+"_2").html(result.data);
						bStartFlag = false;
					}
				},error : function(xhr, status, error) {
					$("#"+row.ip.replaceAll(".","")+"_2").html(error);
					bStartFlag = false;
				}
			});
		});
	}

</script>
</head>
<body>
	<div class="sub_wrap" style="height : max-content;">
		<div class="location">
			<span class="location_home">HOME</span>
			<span class="step">시스템관리</span>
			<span class="step">시스템관리</span>
			<strong class="step">DB패스워드</strong>
		</div>
		<div class="btn_topArea">
			<span class="btn_r">
				<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop" onclick="fnDbPwChangeConfirm()">저장</button>
			</span>
		</div>
		<section class="sub_contents" id="section">
			<div style="width:99%; height:45%; border:1px solid #d6d6d6; padding:10px 5px;">
				<div style="margin-bottom:10px;">▶ DB 정보</div>
				<div class="input_area">
					<table class="input_table">
						<colgroup>
							<col width="20%" />
							<col width="80%" />
						</colgroup>
						<tbody>
							<tr style="height:50px;" id="trNo">
								<th>DB 정보</th>
								<td style="text-align: left;">
									<input type="text" readonly="readonly" id="s_FindDBIP" name="s_FindDBIP" style="width: 630px;" class="mr10" />
								</td>
							</tr>
							<tr style="height:50px;" id="trNo">
								<th>아이디</th>
								<td style="text-align: left;">
									<input type="text" name="s_inpDBID" readonly="readonly" id="s_inpDBID" style="width: 630px" class="mr10" />
								</td>
							</tr>
							<tr style="height:50px;" id="trNo">
								<th>관리자 패스워드 인증<span class="point">*</span></th>
								<td style="text-align: left;">
									<input type="password" name="s_inpAdminPw" id="s_inpAdminPw" style="width: 630px" class="mr10" />
									<button type="button" class="btn_m confirm" id="btnAdminChk" name="btnAdminChk" onclick="fnAdminPwChk()">인증</button>
									<input type="hidden" id="RSAModulus" name="RSAModulus" value="${RSAModulus}">
			                    	<input type="hidden" id="RSAExponent" name="RSAExponent" value="${RSAExponent}">
			                    	<input type="hidden" id="dateSetValue" name="dateSetValue" value="-400">
									<input type="hidden" id="s_TenantId" name="s_TenantId">
			                		<input type="hidden" id="s_AgentId" name="s_AgentId">
								</td>
							</tr>
							<tr style="height:50px;" id="trNo">
								<th>변경 패스워드<span class="point">*</span></th>
								<td style="text-align: left;">
									<input type="password" name="s_inpDBPwChange" id="s_inpDBPwChange" style="width: 630px" class="mr10" />
								</td>
							</tr>
							<tr style="height:50px;" id="trNo">
								<th>패스워드 확인<span class="point">*</span></th>
								<td colspan="3" style="text-align: left;">
									<input type="password" name="s_inpDBPwChangeChk" id="s_inpDBPwChangeChk" style="width: 630px" class="mr10" />
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>

			<div style="width:99%; height:55%; border:1px solid #d6d6d6; padding:10px 5px; margin-bottom:3px;">
				<div style="float:left; width:30%; margin-bottom:10px;">▶ DB 패스워드 변경 현황</div>
				<div>
					<table class="input_table" id="tblMain">
						<colgroup>
							<col width="20%" />
							<col width="20%" />
							<col width="60%" />
						</colgroup>
						<tbody class="resultData"></tbody>
					</table>
				</div>
			</div>
		</section>
    </div>
</body>

</html>
