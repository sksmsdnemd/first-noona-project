<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<script>
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
		};
		   
// 		fnInitCtrlPop();
		ArgSetting();
	});
	
	function ArgSetting() {
		fvCurRow = sPopupOptions.pRowIndex;

		for (key in fvCurRow) {
			if("velGroupId" == key || "velGroupName" == key) {
				var velGroupTxt = fvCurRow["velGroupName"];
				if(fvCurRow["velGroupId"] != null) {
					velGroupTxt += " ["+fvCurRow["velGroupId"]+"]";
				}
				$("#velGroupInfo").html(velGroupTxt)
			} else if("appUserId" == key || "appUserName" == key) {
				var appUserTxt = fvCurRow["appUserName"];
				if(fvCurRow["appUserId"] != null) {
					appUserTxt += " ["+fvCurRow["appUserId"]+"]";
				}
				$("#appUserInfo").html(appUserTxt)
			} else if("velUserId" == key || "velUserName" == key) {
				var velUserTxt = fvCurRow["velUserName"];
				if(fvCurRow["velUserId"] != null) {
					velUserTxt += " ["+fvCurRow["velUserId"]+"]";
				}
				$("#velUserInfo").html(velUserTxt)
			} else {
				$("#"+key).html(fvCurRow[key]);
			}
		}

// 	   	argoSetValues("ip_", fvCurRow);
	}
</script>
</head>
<body>
	<div class="sub_wrap pop">
		<section class="pop_contents">            
			<div class="pop_cont pt5">
				<div class="input_area">
					<table class="input_table">
						<colgroup>
							<col style="width:160px;" />
							<col style="width:400px;" />
							<col style="width:400px;" />
						</colgroup>
						<tbody>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;"></td>
								<td class="text-center" style="background: #fafafa; font-weight:600;">상담APP</td>
								<td class="text-center" style="background: #fafafa; font-weight:600;">VELOE MANAGER</td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">녹취일시</td>
								<td id="appRecDate" class="text-center"></td>
								<td id="velRecTime" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">콜아이디</td>
								<td id="appCallId" class="text-center"></td>
								<td id="velCallId" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">UCID</td>
								<td id="appUcid" class="text-center"></td>
								<td id="" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">내선번호</td>
								<td id="appDnNo" class="text-center"></td>
								<td id="velDnNo" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">HOP</td>
								<td id="appHop" class="text-center"></td>
								<td id="" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">통화종류</td>
								<td id="appCallKind" class="text-center"></td>
								<td id="velCallKind" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">통화종류</td>
								<td id="appCallKind" class="text-center"></td>
								<td id="velCallKind" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">그룹</td>
								<td id="" class="text-center"></td>
								<td id="velGroupInfo" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">사용자</td>
								<td id="appUserInfo" class="text-center"></td>
								<td id="velUserInfo" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">전화기IP</td>
								<td id="" class="text-center"></td>
								<td id="velPhoneIp" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">통화시간</td>
								<td id="" class="text-center"></td>
								<td id="velEndTime" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객전화번호</td>
								<td id="appCustTel" class="text-center"></td>
								<td id="velCustTel" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객번호</td>
								<td id="appCustno" class="text-center"></td>
								<td id="velCustNo" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객명</td>
								<td id="appCustname" class="text-center"></td>
								<td id="velCustName" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보1</td>
								<td id="appCustEtc1" class="text-center"></td>
								<td id="velCustEtc1" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보2</td>
								<td id="appCustEtc2" class="text-center"></td>
								<td id="velCustEtc2" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보3</td>
								<td id="appCustEtc3" class="text-center"></td>
								<td id="velCustEtc3" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보4</td>
								<td id="appCustEtc4" class="text-center"></td>
								<td id="velCustEtc4" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보5</td>
								<td id="appCustEtc5" class="text-center"></td>
								<td id="velCustEtc5" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보6</td>
								<td id="appCustEtc6" class="text-center"></td>
								<td id="velCustEtc6" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보7</td>
								<td id="appCustEtc7" class="text-center"></td>
								<td id="velCustEtc7" class="text-center"></td>
							</tr>
							<tr>
								<td class="text-center" style="background: #fafafa; font-weight:600;">고객정보8</td>
								<td id="appCustEtc8" class="text-center"></td>
								<td id="velCustEtc8" class="text-center"></td>
							</tr>
						</tbody>
					</table>
				</div>
				<div class="blank_h20"></div>
			</div>
		</section>
	</div>
</body>

</html>                     