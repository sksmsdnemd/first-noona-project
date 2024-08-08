<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/rsa.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/jsbn.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/prng4.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/rng.js"/>"></script>



<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
	var workMenu 	= "프로세스관리MRU재시작";
	var workLog 	= "";
	var sPopupOptions;
	var restartGrants = ["SuperAdmin"];
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
	    fnGrantChk();
	    //$("#tdId").text(userId);
	    console.log(parent.gPopupOptions);
	    console.log(sPopupOptions);
	  	fnInitCtrlPop();
	});
	
	function fnGrantChk(){
		for(var i=0;i<restartGrants.length;i++){
			var restartGrant = restartGrants[i];
	    	if(restartGrant == grantId){
				return;		    	
		    }
	    }
		parent.argoAlert("권한이 없는 계정입니다.");
    	argoPopupClose();
	}
	
	/* function fnInitCtrlPop() {
		$("#btnGrantChkPop").click(function(){
			
			debugger;
			var AgentPw 	 = $('#agentPwView').val();
			
			
			
			// rsa 암호화
	        var rsa = new RSAKey();
	        rsa.setPublic($('#RSAModulus').val(), $('#RSAExponent').val());
	        AgentPw = rsa.encrypt(AgentPw);
	        
	        
	        
			argoJsonSearchOne("ARGOCOMMON", "login", "s_", {CallMothd:"salt", AgentPw:AgentPw,"TenantId":tenantId,"AgentId":userId}, fnUserCheckCallback);
		});
	} */
	
	function fnInitCtrlPop() {
		$("#btnGrantChkPop").click(function(){
			var key  = "BRIDGETEC_VELOCE";
			var enPw = $("#agentPwView").val();
			
			if(enPw == ''){
				argoAlert("비밀번호를 입력하세요.");
				return;
			}
			
			var param = {
				key  : key
				,enPw : enPw
			};
			
			$.ajax({
				type : 'post',
		        data: param,
				url : gGlobal.ROOT_PATH + "/procRestartConfirmPw.do",
				dataType : "json",
				success : function(data) {
					if(data.ret=="failPw"){
						parent.argoAlert("패스워드를 확인해주세요.");
						location.reload();
					}else if(data.ret=="success"){
						parent.fnProcStopCallBack(sPopupOptions.procId ,sPopupOptions.procName ,sPopupOptions.url);
						argoPopupClose();
					}
				},error : function(xhr, status, error) {
		            console.log(error);
		       }
			});	
		});
	}
	
	/* function fnUserCheckCallback(Result, textStatus, jqXHR){
		if(Result.getRows()['resultCd'] == "LOGINOK"){
			parent.fnProcStopCallBack(sPopupOptions.procId ,sPopupOptions.procName ,sPopupOptions.url);
			argoPopupClose();
		}else{
			parent.argoAlert("패스워드를 확인해주세요.");
			location.reload();
		}
	} */
	
	
	
	

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="input_area">
            		<table class="input_table">
                        <tbody>
                        	<tr style="display: none;">
                            	<th>아이디</th>
                                <td id="tdId"></td>
							</tr>
							<tr>
								<th>패스워드</th>
								<td><input type="password" id="agentPwView" name="agentPwView" style="width:100%;"></td>       
							</tr>
						</tbody>
					</table>
				</div>
                <div class="btn_areaB txt_r">
                    <button type="button" id="btnGrantChkPop" name="btnGrantChkPop" class="btn_m confirm" data-grant="W">계속</button>   
            	</div>      
                <input type="hidden" id="RSAModulus" name="RSAModulus" value="${RSAModulus}">
                <input type="hidden" id="RSAExponent" name="RSAExponent" value="${RSAExponent}">        
            </div>            
        </section>
    </div>
</body>

</html>
