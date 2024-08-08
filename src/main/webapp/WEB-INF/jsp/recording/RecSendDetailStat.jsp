<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!doctype html>
<html>
<head> 
<script>
	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var userId	  	= loginInfo.SVCCOMMONID.rows.userId;
	var workIp		= loginInfo.SVCCOMMONID.rows.workIp;
	var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
	var depth		= loginInfo.SVCCOMMONID.rows.depth;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	var workMenu	= "녹취전송조회";
	
</script>
<body>
	<div class="sub_wrap" style="min-width: 0px;">
		<div class="btns_top">
			<button type="button" id="btnSearch" class="btn_m search">조회</button>
			<button type="button" id="btnReset" class="btn_m">초기화</button>
		</div>
		<div class="search_area" style="height:auto">
			<div class="row" id="div_tenant">
				<ul class="search_terms">
					<li><strong class="title ml20">태넌트</strong> 
						<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select>
					</li>
				</ul>
			</div>
			<div class="row">
				<ul class="search_terms">
					<li><strong class="title  ml20">검색</strong> 
						<select id="s_FindSearch" name="s_FindSearch" style="width: 140px" class="list_box">
							<option value="">선택</option>
							<option value="dn_no">내선번호</option>
							<option value="user_id">상담사ID</option>
							<option value="user_name">상담사명</option>
						</select> 
						<input type="text" id="s_FindText" name="s_FindText" style="width: 140px" />
					</li>
				</ul>
			</div>
			<div class="row">
				<ul class="search_terms">
					<li>
						<strong class="title ml20">검색기간</strong> 
						<span class="select_date">
								<input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From">
						</span> 
						~
						<span class="select_date">
							<input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To">
						</span> 
						<select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
					</li>	
				 </ul>
			</div>
		</div>
		<div style="margin:10px 30px;text-align: center">
			<table class="input_table " style="border-top: #3d7aa5 solid 3px">
				<thead>
					<tr>
						<td align="center" style="background-color: #f3f3f3">변환 종류</td>
						<td align="center" style="background-color: #f3f3f3">변환 상태</td>
						<td align="center" style="background-color: #f3f3f3">개수</td>
					</tr>
				</thead>
				<tbody id="dataTbody">
					<tr id="tr_0">
						<td>0</td>
						<td>녹취 시작</td>
						<td id="td_0">0</td>
					</tr>
					<tr id="tr_1">
						<td>1</td>
						<td>녹취 완료</td>
						<td id="td_1">0</td>
					</tr>
					<tr id="tr_2">
						<td>2</td>
						<td>변환 중</td>
						<td id="td_2">0</td>
					</tr>
					<tr id="tr_3">
						<td>3</td>
						<td>변환 완료</td>
						<td id="td_3">0</td>
					</tr>
					<tr id="tr_9">
						<td>9</td>
						<td>변환 실패 또는 패킷 없는 콜</td>
						<td id="td_9">0</td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>
</body>
</html>
<script type="text/javascript">
	$(document).ready(function() {
		
		fnArgoSetting();	
		fnSearchListCnt();
		
		
		$("#btnSearch").click(function(){
			fnSearchListCnt();
		})
		
		$("#btnReset").click(function(){

			$('#s_FindTenantId option[value="' + tenantId +  '"]').prop('selected', true);
			$('#s_FindSearch option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
			
			fnArgoSetting();
		});
	});
	
	
	function fnArgoSetting(){

		argoSetDatePicker();

		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		argoCbCreate("s_FindTenantId", "comboBoxCode",
				"getTenantList", {}, {
				});
		
		
		$("#s_txtDate1_From").val(opener.$("#s_txtDate1_From").val());
		$("#s_txtDate1_To").val(opener.$("#s_txtDate1_To").val());
		$("#s_FindText").val(opener.$("#s_FindText").val());
		
		$('#s_FindSearch option[value="' + opener.$("#s_FindSearch").val() + '"]').prop('selected', true);
		$('#s_FindTenantId option[value="' + opener.$("#s_FindTenantId").val() + '"]').prop('selected', true);
		$('#selDateTerm1 option[value="'+opener.$("#selDateTerm1").val()+'"]').prop('selected', true);
	}
	
	function fnSearchListCnt(){
		argoJsonSearchList(
				'recordFile',
				'getRecSendDetailStat',
				's_',
				{
					"tenantId" : $("s_FindTenantId").val(),
				},
				function(data, textStatus, jqXHR) {
					try {
						if (data.isOk()) {

							if (data.getRows() != "") {
								var dataTbody = $("#dataTbody");
								
								$.each(data.getRows(),function(index, row) {
									
									$("#td_"+row.uploadKind).text(row.cnt);
									
								});
							}else{
								$("[id^=td_]").each(function(){
									$(this).text("0");
								});
							}
						}
					} catch (e) {
						console.log(e);
					}
				});
	}
</script>


