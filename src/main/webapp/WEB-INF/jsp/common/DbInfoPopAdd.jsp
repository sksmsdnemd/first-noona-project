<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>



<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script>
	$(function () {
	    fnSysinfoIpList();
		pageOpenValue();
	});
	
	const userId 		 = '<spring:eval expression="@code['Globals.ARGO.RDB.Account']"/>';
	const dbPort 		 = '<spring:eval expression="@code['Globals.ARGO.RDB.DbPort']"/>';
	const dbIp 		 = '<spring:eval expression="@code['Globals.ARGO.RDB.DbIp']"/>';
	const sid 		 = '<spring:eval expression="@code['Globals.ARGO.RDB.Sid']"/>';
	
	
	// default value 
	function pageOpenValue(){
		$("#s_FindDBIP").val(dbIp);
		$("#s_FindDBPort").val(dbPort);
		$("#s_inpDBSID").val(sid);
		fnDbIDEncrypt();	
	}
	
	// DB ID 복호화
	function fnDbIDEncrypt(){
		var param = {"id" :userId};
		$.ajax({
			url : "/BT-VELOCE/common/DbPassWordDecryptF.do",
			type : "POST",
			data:param,  
			success : function(data) {
				console.log(data);
				$("#s_inpDBID").val(data.id);
			},error : function(xhr, status, error) {
				console.log("fnDbIDEncrypt = error");
			}
		}); 
	}
	var arrWAU = [];
	// 접속서버 리스트
	function fnSysinfoIpList() {
		argoJsonSearchList('sysInfo', 'getSysinfoIpList', 's_', null, function(
				data, textStatus, jqXHR) {
			var row = data.SVCCOMMONID.rows;
			for (var i = 0; i < row.length; i++) {
				var rowi = row[i];
				arrWAU.push('http://'+rowi.systemIp+':7060/');
			}
		});
	}
	
	// 패스워드 변경 confirm 알림창
	function fnDbPwChangeConfirm(){
		if($("#s_inpDBSID").val() == ""){
			alert("SID를 입력해 주세요.");
			return false;
		}
		if($("#s_inpDBID").val() == ""){
			alert("아이디를 입력해주세요.");
			return false;
		}
		if($("#s_inpDBPwChange").val() == ""){
			alert("변경 패스워드를 입력해 주세요.");
			return false;
		}
		if( $("#s_inpDBPwChangeChk").val() == ""){
			alert("패스워드 확인.");
			return false;
		}
		if($("#s_inpDBPwChange").val() != $("#s_inpDBPwChangeChk").val()){
			alert("변경 패스워드 확인이 일치하지 않습니다.");
			return false;
		}
		if(confirm("변경하시겠습니까?")){
			fnDbEncrypt();
		}
	}
	
	// 암호화
	function fnDbEncrypt(){
		var param = {"sid":$("#s_inpDBSID").val(),"id" : $("#s_inpDBID").val(),
					 "pwChange" : $("#s_inpDBPwChange").val()};
		$.ajax({
			url : "/BT-VELOCE/common/DbPassWordSecurityF.do",
			type : "POST",
			data:param,  
			async: false,
			success : function(data) {
				console.log("fnDbEncrypt = success");
				fnDbPwChange(data);
			},error : function(xhr, status, error) {
				console.log("fnDbEncrypt = error");
			}
		}); 
	}
	
	// 패스워드 변경
	function fnDbPwChange(param){
		for(var i=0;i<arrWAU.length;i++){
			$.ajax({
				url : arrWAU[i]+"DBPwChange.do",
				type : "POST",
				data:JSON.stringify(param),  
				async: false,
				success : function(data) {
					console.log("fnDbPwChange = success");
					//OK || NG
					var result = JSON.parse(decodeURI(data));
					console.log(arrWAU[i]);
					console.log(result);
					if(result.result == "OK"){
						alert(arrWAU[i]);
						argoAlert("IP : "+arrWAU[i]+"</br>DB 패스워드 수정 되었습니다.");
						fnDbPassWordSecurity(param);
					}else{
						
					}
				},error : function(xhr, status, error) {
					console.log("fnDbPwChange = error");
				}
			});
		}
	}
	
	function fnDbPassWordSecurity(param){
		$.ajax({
			url : "/BT-VELOCE/common/ProDbPassWordChangeF.do",
			type : "POST",
			data:{"pwChange": $("#s_inpDBPwChange").val()},
			async: false,
			success : function(data) {
				console.log("fnDbPassWordSecurity = success");
				fnDBPwChangeResult(param);
			},error : function(xhr, status, error) {
				console.log("fnDbPassWordSecurity = error");
			}
		}); 
	}
	
	function fnDBPwChangeResult(param){
		for(var i=0;i<arrWAU.length;i++){
			$.ajax({
				url : arrWAU[i]+"MWSREBOOT.do",
				type : "POST",
				data:JSON.stringify(param),  
				async: false,
				success : function(data) {
					//OK || NG
					console.log("fnDBPwChangeResult = success");
				},error : function(xhr, status, error) {
					console.log("fnDBPwChangeResult = error");
				}
			}); 
		}
	}
	
	
	

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
					<span class="btn_r">
                       <button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop" onclick="fnDbPwChangeConfirm()">저장</button>
                    </span>               
                </div>
                <div class="input_area">
                
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158px;">
                            <col width="">
                        	<col width="158px;">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>DB IP</th>
                                <td>
                                    <input type="text" readonly="readonly" id="s_FindDBIP" name="s_FindDBIP" style="width: 300px;" value="http://100.100.107.21" />
                                </td>
                                <th>포트</th>
                                <td>
                                    <input type="text" readonly="readonly"  id="s_FindDBPort" name="s_FindDBPort" style="width:200px;" value="7060"/> 
                                </td>
                            </tr>
                            <tr style="height:50px;">
                        		<th>SID</th>
                                <td colspan="3" style="text-align: center;">
                           			<input type="text" readonly="readonly" name="s_inpDBSID" id="s_inpDBSID" style="width: 630px" class="mr10" />
                                </td>
                            </tr>
                        	<tr style="height:50px;" id="trNo">
                        		<th>아이디</th>
                                <td colspan="3" style="text-align: center;">
                           			<input type="text" name="s_inpDBID" readonly="readonly" id="s_inpDBID" style="width: 630px" class="mr10" />
                                </td>
                            </tr>
                            <tr style="height:50px;" id="trNo">
                        		<th>변경 패스워드<span class="point">*</span></th>
                                <td colspan="3" style="text-align: center;">
                           			<input type="password" name="s_inpDBPwChange" id="s_inpDBPwChange" style="width: 630px" class="mr10" />
                                </td>
                            </tr>
                            <tr style="height:50px;" id="trNo">
                        		<th>패스워드 확인<span class="point">*</span></th>
                                <td colspan="3" style="text-align: center;">
                           			<input type="password" name="s_inpDBPwChangeChk" id="s_inpDBPwChangeChk" style="width: 630px" class="mr10" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </div>
</body>

</html>
