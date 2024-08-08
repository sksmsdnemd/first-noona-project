<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var userId2    	= loginInfo.SVCCOMMONID.rows.userId;
	var workMenu 	= "내선패턴등록 및 수정";
	var workLog 	= "";
	
	$(function () {
		var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };


	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	var cudMode;
	var systemId;
	var processId;
	var userId;
	var reqTenantId;
	var orgIp;
	function fnInitCtrlPop() {
		cudMode 	= sPopupOptions.cudMode;
		systemId 	= sPopupOptions.systemId;
		processId 	= sPopupOptions.processId;
		userId 		= sPopupOptions.userId;
		reqTenantId = sPopupOptions.sTenantId;
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});
		
		$("#ip_SystemId").change(function(){
	 		fnSetSubCb("system");
	 	});
		
		// 내선번호 / 전화기ip 라디오버튼 클릭
		$("input:radio[name='ip_StateIp']").click(function(){	
			var id = $(this).attr('id');
			if(id == "ip_StateIpIp"){
				$("#trIp").css("display","");
				$("#trNo").css("display","none");
			}else{
				$("#trIp").css("display","none");
				$("#trNo").css("display","");
			}
		});	
	}
	
	function fnSetSubCb(kind) {
	 if (kind == "system") {
			if($('#ip_SystemId option:selected').val() == ''){
				$("#ip_ProcessId").find("option").remove();
			}else{
				argoCbCreate("ip_ProcessId", "comboBoxCode", "getProcessList2", {findSystemId:$('#ip_SystemId option:selected').val(), findProcessName:"MRU"}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}			
		}
	}
	
	// 팝업 세팅
	function ArgSetting() {

		argoCbCreate("ip_SystemId", "comboBoxCode", "getMruVssSystemList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
        argoCbCreate("ip_TenantId", "comboBoxCode", "getTenantList", {}, {"selectIndex":0});


		$("#ip_SystemId").change(function() {	fnSetSubCb('system');		});

		if(cudMode =='I') {
            $("#ip_TenantId").val(reqTenantId).attr("selected", "selected");
            $("#ip_PtrnId").val('');

		}else{
			console.log(sPopupOptions);
			
			fvCurRow= sPopupOptions.pRowIndex ;
		   	argoSetValues("ip_", fvCurRow);
		   	
		   	// 팝업 대역 초기화
		   	if(fvCurRow.stateIp == 'I'){
		   		$("#ip_StateIpIp").attr("checked",true);
				$("#trIp").css("display","");
				$("#trNo").css("display","none");
		   	}else if(fvCurRow.stateIp == 'N'){
		   		$("#ip_StateIpNo").attr("checked",true);
				$("#trIp").css("display","none");
				$("#trNo").css("display","");
		   	}
		   	
		   	$('#ip_SystemId option[value=' + fvCurRow.systemId + ']').prop("selected", true);

		   	fnSetSubCb("system");

		   	$('#ip_ProcessId option[value=' + fvCurRow.processId + ']').prop("selected", true);


			var excpPtrnAtC;
			var ch = fvCurRow.excpPtrnAt;
			if( ch == "O"){
                excpPtrnAtC = "1"
			}else{
                excpPtrnAtC = "0"
			}
			$('input:radio[name="ip_ExcpPtrnAt"]').filter('[value=' + excpPtrnAtC + ']').prop('checked', 'checked');
            excpPtrnChk(excpPtrnAtC);

		}
	}
	
	function fnSavePop(){
		var excpPtrnAt  = $("input[name=ip_ExcpPtrnAt]:checked").val();
        var exitAt  =false;
        var aValidate;
        // startDnNo 가 있으면 endDnNo  필수
		var startDnNo   = $("#ip_StartDnNo").val();
		var endDnNo     = $("#ip_EndDnNo").val();
        var startIp		= $("#ip_StartIp").val();
        var endIp		= $("#ip_EndIp").val();
        var stateIp= $("input:radio[name='ip_StateIp']:checked").val();
        var excpPtrnAt  = $("input[name=ip_ExcpPtrnAt]:checked").val();

        aValidate = {
            rows:[
                {"check":"length", "id":"ip_TenantId", "minLength":1, "maxLength":50, "msgLength":"태넌트를 입력하세요."}
                ,{"check":"length", "id":"ip_SystemId", "minLength":1, "maxLength":50, "msgLength":"시스템을 입력하세요."}
                ,{"check":"length", "id":"ip_ProcessId", "minLength":1, "maxLength":50, "msgLength":"프로세스를 입력하세요."}
            ]
        };

        

        if( excpPtrnAt == '0' ) {
        	if (argoValidator(aValidate) != true) return;
        	// 공백체크
            if (startDnNo == '' && startIp == ''){	
                argoAlert("내선번호 대역 또는 전화기IP 대역은 필수 입력값입니다.");
                return;
            }
			if(stateIp == "N"){	 
				if(startDnNo != '' && endDnNo == '')  {
	                argoAlert("내선번호 대역이 올바르지 않습니다.");
	                return;
	            }				
				if(startDnNo >= endDnNo){
					argoAlert("내선번호 대역) 시작값이 종료값보다 크거나 같을수 없습니다.");
					return;
				}
			}else if(stateIp == "I"){
				if(startIp != '' && endIp == '')  {
	                argoAlert("전화기IP 대역이 올바르지 않습니다.");
	                return;
	            }	
				if(startIp >= endIp){
					argoAlert("전화기IP 대역) 시작값이 종료값보다 크거나 같을수 없습니다.");
					return;
				}
			}else{
				argoAlert("대역구분을 선택해주세요.");
                return;
			}
        } else {
            // 예외패턴여부1일때 같은 태넌트ID에 예외패턴인게 존재하면 Return;
            argoJsonSearchOne('userTel', 'getExcpPtrnCnt', 'ip_', {} , function (Resultdata, textStatus, jqXHR){
                if(Resultdata.isOk()) {
                    cnt = parseInt(Resultdata.getRows()['cnt']);
                    if(cnt != 0 ){
                        argoAlert("해당 태넌트에 예외패턴이 이미 존재합니다.");
                        $('input:radio[name="ip_ExcpPtrnAt"]').filter('[value=0]').prop('checked', 'checked');
                        excpPtrnChk(0);
                        exitAt=true;
                        return;
                    }
                }
            });

            if(exitAt) return;

        }

        argoConfirm("저장 하시겠습니까?", function(){
            fnDetailInfoCallback();
        });
	}

	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		var Resultdata;

        try {
        	var resultCnt = 0;
        	// 대역 중복조회 
        	argoJsonSearchOne('userTel', 'selectDnPtrnOverlapCheck', 'ip_', {} , function (Resultdata, textStatus, jqXHR){
                if(Resultdata.isOk()) {
                	resultCnt = parseInt(Resultdata.getRows()['cnt']);
                }
            });
        	
			console.log(resultCnt);        	
        	if(resultCnt > 0){
        		argoAlert("중복된 대역입니다.");
        		return;
        	}
			

        	
			if(cudMode == "I"){
				
                Resultdata = argoJsonUpdate("userTel", "setDnPtrnInsert", "ip_", {"cudMode":cudMode});
                workLog = '[내선패턴] 등록';

			}else{

				Resultdata = argoJsonUpdate("userTel", "setDnPtrnUpdate", "ip_", {"cudMode":cudMode});
				workLog = '[내선패턴] 수정';
			}
			
		    if(Resultdata.isOk()) {	
			   	argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId2
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
			}else {
			   	argoAlert("저장에 실패하였습니다");	 
			}
		} catch (e) {
			console.log(e);
		}
	}


	/**예외패턴 처리*/
    function excpPtrnChk(value){
        if(value == 1){
            $("#ip_StartDnNo").attr("disabled",true);
            $("#ip_EndDnNo").attr("disabled",true);
            $("#ip_StartIp").attr("disabled",true);
            $("#ip_EndIp").attr("disabled",true);
            
            $("#ip_StartDnNo").val("");
            $("#ip_EndDnNo").val("");
            $("#ip_StartIp").val("");
            $("#ip_EndIp").val("");
            
			$("input:radio[name='ip_StateIp']").attr("disabled",true);
       }else{
            $("#ip_StartDnNo").attr("disabled",false);
            $("#ip_EndDnNo").attr("disabled",false);
            $("#ip_StartIp").attr("disabled",false);
            $("#ip_EndIp").attr("disabled",false);
            $("input:radio[name='ip_StateIp']").attr("disabled",false);
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
                       <button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>
                        <input type="hidden" name="ip_PtrnId" id="ip_PtrnId" value="" />
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
                                <th>태넌트<span class="point">*</span></th>
                                <td>
                                    <select	id="ip_TenantId" name="ip_TenantId" style="width: 150px" class="list_box"></select>
                                </td>
                                <th>예외 패턴 여부</th>
                                <td>
                                    <span> <label> <input type="radio" name="ip_ExcpPtrnAt" id="ip_ExcpPtrnAtY" value="1" onclick="javascript:excpPtrnChk(this.value);" /> </label></span>예
                                    <span> <label> <input type="radio" name="ip_ExcpPtrnAt" id="ip_ExcpPtrnAtN" value="0" onclick="javascript:excpPtrnChk(this.value);" checked/> </label></span>아니요
                                </td>
                            </tr>
                            <tr>
                                <th>시스템<span class="point">*</span></th>
                                <td>
                                    <select id="ip_SystemId" name="ip_SystemId" style="width:200px;" class="list_box"> </select>
                                </td>
                                <th>프로세스<span class="point">*</span></th>
                                <td>
                                    <select id="ip_ProcessId" name="ip_ProcessId" style="width:200px;" class="list_box"> </select>
                                </td>
                            </tr>
                            <tr style="height:50px;">
                        		<th>대역구분</th>
                                <td colspan="3">
                                	<input type="radio" name="ip_StateIp" id="ip_StateIpNo" value="N" checked/>내선번호&nbsp;
                           			<input type="radio" name="ip_StateIp" id="ip_StateIpIp" value="I"/>전화기IP
                                </td>
                            </tr>
                        	<tr style="height:50px;" id="trNo">
                        		<th>내선번호 대역</th>
                                <td colspan="3">
                           			<input type="text" name="ip_StartDnNo" id="ip_StartDnNo" style="width: 85px" class="mr10 onlyNum" />~ &nbsp;
                           			<input type="text" name="ip_EndDnNo" id="ip_EndDnNo" style="width: 85px" class="mr10 onlyNum" />
                                </td>
                            </tr>
                            <tr style="height:50px; display:none;" id="trIp">
                                <th>
                                    전화기IP 대역
                                </th>
                                <td colspan="3">
                                    <input type="text" name="ip_StartIp" id="ip_StartIp" style="width:200px" class="mr10"  />&nbsp;~&nbsp;
                                    <input type="text" name="ip_EndIp" id="ip_EndIp" style="width:200px" class="mr10"  />
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
