<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<script>
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "NAT 대역관리";
	var workLog 	= "";
	
	$(function() {

	});
	
	$(document).ready(function() {
		$("#btnAddRange").click(function() {	fn_addRow();	});
		$("#btnSaveRange").click(function() {	fn_saveRange();	});
		$("#s_FindTenantId").change(function() {	initList();	});
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		$("#s_FindTenantId").val(tenantId).prop("selected", true);
		
		initList();
	});
	
	function initList() {
		$("#resultData").empty();
		
		argoJsonSearchList('ipInfo', 'getNatRangeList', 's_', {"tenantId":tenantId}, function (data, textStatus, jqXHR){
			try {
				if(data.isOk()){
					if(data.getRows() != ""){
						$.each(data.getRows(), function(index, row) {
							var html = "";
							html += "<tr>";
							html += "<td>";
							html += "<select id='ipClass' name='ipClass' style='width: 60px;' onChange='javascript:fn_clsChange(this)'>";
							html += "<option value='A'>A</option>";
							html += "<option value='B'>B</option>";
							html += "<option value='C'>C</option>";
							html += "</select>";
							html += "</td>";
							html += "<td>";
							html += "<input type='text' style='width:50px;' name='natIp_01' onkeyup='javascript:fn_valCheck(this);'>";
							html += ".<input type='text' style='width:50px;' name='natIp_02' onkeyup='javascript:fn_valCheck(this);'>";
							html += ".<input type='text' style='width:50px;' name='natIp_03' onkeyup='javascript:fn_valCheck(this);'>";
							html += ".<input type='text' style='width:50px;' name='natIp_04' onkeyup='javascript:fn_valCheck(this);'>";
							html += "</td>";
							html += "<td><button type='button' class='btn_s' onclick='javascript:fn_delRow(this);'>삭제</button></td>";
							html += "</tr>";
							
							$("#resultData").append(html);
							
							$($("select[name=ipClass]")[index]).val((row.ipClass).trim()).prop("selected", true);
							
							$($("input[name=natIp_01]")[index]).val((row.natIpRange).trim().split(".")[0]);
							$($("input[name=natIp_02]")[index]).val((row.natIpRange).trim().split(".")[1]);
							$($("input[name=natIp_03]")[index]).val((row.natIpRange).trim().split(".")[2]);
							$($("input[name=natIp_04]")[index]).val((row.natIpRange).trim().split(".")[3]);
							
							if("A" == (row.ipClass).trim()) {
								$($("input[name=natIp_02]")[index]).prop("disabled", true);
								$($("input[name=natIp_03]")[index]).prop("disabled", true);
								$($("input[name=natIp_04]")[index]).prop("disabled", true);
							} else if("B" == (row.ipClass).trim()) {
								$($("input[name=natIp_03]")[index]).prop("disabled", true);
								$($("input[name=natIp_04]")[index]).prop("disabled", true);
							} else if("C" == (row.ipClass).trim()) {
								$($("input[name=natIp_04]")[index]).prop("disabled", true);
							}
						});
					}
				}
			} catch(e) {
					console.log(e);			
			}
		});
	}
	
	function fn_addRow() {
		var html = "";
		html += "<tr>";
		html += "<td>";
		html += "<select id='ipClass' name='ipClass' style='width: 60px;' onChange='javascript:fn_clsChange(this)'>";
		html += "<option value='A'>A</option>";
		html += "<option value='B'>B</option>";
		html += "<option value='C'>C</option>";
		html += "</select>";
		html += "</td>";
		html += "<td>";
		html += "<input type='text' style='width:50px;' name='natIp_01' onkeyup='javascript:fn_valCheck(this);'>";
		html += ".<input type='text' style='width:50px;' name='natIp_02' onkeyup='javascript:fn_valCheck(this);' value='0' disabled>";
		html += ".<input type='text' style='width:50px;' name='natIp_03' onkeyup='javascript:fn_valCheck(this);' value='0' disabled>";
		html += ".<input type='text' style='width:50px;' name='natIp_04' onkeyup='javascript:fn_valCheck(this);' value='0' disabled>";
		html += "</td>";
		html += "<td><button type='button' class='btn_s' onclick='javascript:fn_delRow(this);'>삭제</button></td>";
		html += "</tr>";
		
		$("#resultData").append(html);
	}
	
	function fn_clsChange(obj) {
		if("A" == obj.value) {
			$(obj).closest("tr").find("input[name='natIp_01']").val("").prop("disabled", false);
			$(obj).closest("tr").find("input[name='natIp_02']").val("0").prop("disabled", true);
			$(obj).closest("tr").find("input[name='natIp_03']").val("0").prop("disabled", true);
			$(obj).closest("tr").find("input[name='natIp_04']").val("0").prop("disabled", true);
		} else if("B" == obj.value) {
			$(obj).closest("tr").find("input[name='natIp_01']").val("").prop("disabled", false);
			$(obj).closest("tr").find("input[name='natIp_02']").val("").prop("disabled", false);
			$(obj).closest("tr").find("input[name='natIp_03']").val("0").prop("disabled", true);
			$(obj).closest("tr").find("input[name='natIp_04']").val("0").prop("disabled", true);
		} else if("C" == obj.value) {
			$(obj).closest("tr").find("input[name='natIp_01']").val("").prop("disabled", false);
			$(obj).closest("tr").find("input[name='natIp_02']").val("").prop("disabled", false);
			$(obj).closest("tr").find("input[name='natIp_03']").val("").prop("disabled", false);
			$(obj).closest("tr").find("input[name='natIp_04']").val("0").prop("disabled", true);
		}
	}
	
	function fn_valCheck(obj) {
		var rtnVal = obj.value;
		
		if(isNaN(rtnVal)) {
			argoAlert("warning", "숫자만 입력 가능합니다.", "", function() {
				obj.value = (rtnVal || "").replace(/[^0-9]/gi,"");
				$(obj).focus();
			});
			return false;
		} else {
			if(rtnVal > 255) {
				argoAlert("warning", "255 이하의 숫자만 입력 가능합니다.", "", function() {
					obj.value = (rtnVal || "").replace(/.$/,"");
					$(obj).focus();
				});
				return false;
			}
			
			if(rtnVal.length == 3) {
				var ipCls = $(obj).closest("tr").find("select[name='ipClass']").val();
				
				if("B" == ipCls && "natIp_01" == obj.name) {
					$(obj).closest("tr").find("input[name='natIp_02']").focus();
				} else if("C" == ipCls && "natIp_01" == obj.name) {
					$(obj).closest("tr").find("input[name='natIp_02']").focus();
				} else if("C" == ipCls && "natIp_02" == obj.name) {
					$(obj).closest("tr").find("input[name='natIp_03']").focus();
				}
			}
			
		}
	}
	
	function fn_delRow(obj) {
		obj.closest("tr").remove();
	}
	
	function fn_saveRange() {
		argoConfirm("저장 하시겠습니까?", function() {
			var insertLen = $("#resultData > tr").length;
			
			// 입력값 확인
			for(var i = 0 ; i < insertLen ; i++) {
				var obj_01 = $("input[name=natIp_01]")[i];
				var obj_02 = $("input[name=natIp_02]")[i];
				var obj_03 = $("input[name=natIp_03]")[i];
				
				if("" == obj_01.value) {
					argoAlert("warning", "IP 대역값을 입력하세요.", "", function() {
						obj_01.focus();
						return false;
					});
				}
				
				if("" == obj_02.value) {
					argoAlert("warning", "IP 대역값을 입력하세요.", "", function() {
						obj_02.focus();
						return false;
					});
				}
				
				if("" == obj_03.value) {
					argoAlert("warning", "IP 대역값을 입력하세요.", "", function() {
						obj_03.focus();
						return false;
					});
				}
			}
			
			// 저장 처리
			// 01. 데이터 모두 삭제
			argoJsonDelete("ipInfo", "setNatRangeDelete", "s_", {"tenantId":tenantId}, function() {
				// 02. 데이터 입력
				var resultCnt = 0;
				
				for(var j = 0 ; j < insertLen ; j++) {
					var clsStr = $("select[name=ipClass]")[j].value;
					var ipStr = $("input[name=natIp_01]")[j].value
						+ "." + $("input[name=natIp_02]")[j].value
						+ "." + $("input[name=natIp_03]")[j].value
						+ "." + $("input[name=natIp_04]")[j].value;
					
					argoJsonInsert("ipInfo", "setNatRangeInsert", "s_", {"tenantId":tenantId, "rangeSeq":j+1, "ipClass":clsStr, "natIpRange":ipStr}, function(data) {
						try {
							if (data.isOk()) {
								if (data.SVCCOMMONID.procCnt > 0) {
									resultCnt++;
								}
							}
						} catch (e) {
							console.log(e);
						}
					});
				}
				
				if(insertLen == resultCnt) {
					argoAlert("저장되었습니다.");
				} else {
					argoAlert("저장시 오류가 발생하였습니다.");
				}
			});
			
		});
	}
</script>
</head>
<body>
	<div class="sub_wrap pop">
		<section class="pop_contents">            
			<div class="pop_cont pt5">
				<div class="btn_topArea">
					<span>
						<strong class="title">태넌트 : </strong>
						<select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
					</span>
					<span class="btn_r">
						<button type="button" class="btn_m search" id="btnAddRange" name="btnAddRange">추가</button>   
						<button type="button" class="btn_m confirm" id="btnSaveRange" name="btnSaveRange">저장</button>   
					</span>               
				</div>
				<div class="input_area">
					<table class="input_table" id="tblMain">
						<colgroup>
							<col width="20%">
							<col width="63%">
							<col width="17%">
						</colgroup>
						<thead>
							<tr>
								<th>클래스</th>
								<th>IP대역</th>
								<th>삭제</th>
							</tr>
						</thead>
						<tbody id="resultData"></tbody>
					</table>
				</div>           
			</div>            
		</section>
	</div>
</body>

</html>
