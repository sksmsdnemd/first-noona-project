<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "샘플콜조회";
	var workLog		= "";
	
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	   
	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	function fnInitCtrlPop() {
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		fvCurRow = sPopupOptions.pRowIndex;
	    console.log(fvCurRow);
	    $("#ip_FindRecKey").val(fvCurRow.recKey);
	    $("#ip_FindContent").val(fvCurRow.content);
	}
	
	function uptMemo(){
		argoConfirm("수정 하시겠습니까?", function(){
			fnDetailInfoCallback();	    
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
					
			Resultdata = argoJsonUpdate("recSample", "setRecSampleCallUpdate", "ip_", {});
			workLog = '[녹취키:' + fvCurRow.recKey + '] 메모수정';
	
			if(Resultdata.isOk()) {	
			    argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			    argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
			}else {
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
            <div class="pop_cont pt5">
                <div class="input_area">
                	<input type="hidden" id="ip_FindRecKey" name="ip_FindRecKey" />
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                        		<td align="center" colspan="5">메모</td>
                            </tr>
                            <tr>
							<th align="center"><button type="button" class="btn_m confirm" onclick="javascript:uptMemo();">수정</button></th>
								<td>
                           			<textarea id="ip_FindContent"  name="ip_FindContent"style="height:92px; width:100%; " ></textarea>
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
