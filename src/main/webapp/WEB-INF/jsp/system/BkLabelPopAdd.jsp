<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId    = loginInfo.SVCCOMMONID.rows.userId;
	
	$(function () {
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	});
	
	var cudMode;
	
	function fnInitCtrlPop() {
		
		cudMode = sPopupOptions.cudMode;
		
		argoCbCreate("ip_BkDevice", "baseCode", "getBaseComboList", {classId:'bk_device'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("ip_MediaKind", "baseCode", "getBaseComboList", {classId:'media_kind'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
	
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	}
	
	function ArgSetting() {
		
		$("#ip_BkLabelId").attr("readonly", true);
		$("#ip_BkDevice").attr("disabled", true);
		$("#ip_MediaKind").attr("disabled", true);
		$("#ip_FromCondition").attr("readonly", true);
		$("#ip_EndCondition").attr("readonly", true);
		$("#ip_LastBkTime").attr("readonly", true);
		$("#ip_BkFileCnt").attr("readonly", true);
		$("#ip_UsedSpace").attr("readonly", true);
		$("#ip_UsableSpace").attr("readonly", true);
		
		if(cudMode == 'I') {
		
		}else{
	
			fvCurRow = sPopupOptions.pRowIndex;
		    console.log(fvCurRow);
		   	argoSetValues("ip_", fvCurRow);
		}
	}
	
	function fnSavePop(){
		
		argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
				rows:[ 
					]
			};	
				
			if (argoValidator(aValidate) != true) return;
	
			argoJsonUpdate("bkLabel", "setBkLabelUpdate", "ip_", {"cudMode":cudMode}, fnDetailInfoCallback);
		});
	}
	
	function fnDetailInfoCallback(Resultdata, textStatus, jqXHR) {
		try {
			if(Resultdata.isOk()) {	
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
            <div class="pop_cont h0 pt20">
            	<div class="input_area">
            		<table class="input_table">
            			<colgroup>
            				<col width="18%">
                            <col width="32%">
                            <col width="18%">
                            <col width="32%">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>레이블ID<span class="point">*</span></th>
                                <td><input type="text" id="ip_BkLabelId" name="ip_BkLabelId" style="width:200px;"></td>
                                <th>백업장치<span class="point">*</span></th>
                                <td><select id="ip_BkDevice" name="ip_BkDevice" style="width:200px;"></select></td>   
							</tr>
							<tr>
								<th>백업미디어<span class="point">*</span></th>
								<td><select id="ip_MediaKind" name="ip_MediaKind" style="width:200px;"></select></td>
								<th>최종작업자<span class="point"></span></th>
								<td><input type="text" id="ip_LastWorker" name="ip_LastWorker" style="width:200px;"></td>       
							</tr>
							<tr>
								<th>보관장소<span class="point"></span></th>
								<td><input type="text" id="ip_StorePlace" name="ip_StorePlace" style="width:200px;"></td>
								<th>보관기간<span class="point"></span></th>
								<td><input type="text" id="ip_StoreYear" name="ip_StoreYear" class="onlyNum" style="width:200px;">(년)</td>     
							</tr>
							<tr> 
								<th>녹취시작일시<span class="point"></span></th>
								<td><input type="text" id="ip_FromCondition" name="ip_FromCondition" style="width:200px;"></td>
								<th>녹취종료일시<span class="point"></span></th>
								<td><input type="text" id="ip_EndCondition" name="ip_EndCondition" style="width:200px;"></td>        
							</tr>
							<tr>
								<th>최종백업일자<span class="point"></span></th>
								<td><input type="text" id="ip_LastBkTime" name="ip_LastBkTime" style="width:200px;"></td>
								<th>백업파일수<span class="point"></span></th>
								<td><input type="text" id="ip_BkFileCnt" name="ip_BkFileCnt" style="width:200px;"></td>  
							</tr>
							<tr>
                            	<th>사용중인공간<span class="point"></span></th>
								<td><input type="text" id="ip_UsedSpace" name="ip_UsedSpace" style="width:200px;">(MB)</td>
								<th>사용가능공간<span class="point"></span></th>
								<td><input type="text" id="ip_UsableSpace" name="ip_UsableSpace" style="width:200px;">(MB)</td>
                            </tr>                                    
						</tbody>
					</table>
				</div>
                <div class="btn_areaB txt_r">
                    <button type="button" id="btnSavePop" name="btnSavePop" class="btn_m confirm" data-grant="W">저장</button>                   
            	</div>              
            </div>            
        </section>
    </div>
</body>

</html>
