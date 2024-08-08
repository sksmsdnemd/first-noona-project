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

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "매니저환경설정세팅";
	var workLog 	= "";
	
	$(function () {
	
	  	fnInitCtrlPop();
	  	fnConfigList();
	});
	
	function fnInitCtrlPop(){
		
		$("#btnSavePop").click(function(){
			setIniContent();
		});	
		
		argoSetValue("ip_UserId", userId);
	}
	
	function fnConfigList(){
		
		argoJsonSearchList('menu', 'getConfigList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				
				if(data.isOk()){
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						
						var section 	= "";
						var keyCode 	= "";
						var keyOrder	= "";
						var valType 	= "";
						var valCur 		= "";
						var valDefault 	= "";
						var valList 	= "";
						var titleList 	= "";
						var valDesc 	= "";
						
						var objHtml = '<tr>'
									+ '<th align="center">SECTION</th>'
									+ '<th align="center">KEY_CODE</th>'
									+ '<th align="center">DEFAULT</th>'
									+ '<th align="center">VALUE</th>'
									+ '<th align="center">MEMO</th>'
									+ '</tr>';
									
						var arrValueList = "";
						var arrTitleList = "";
						var valueListCnt = 0;
						var titleListCnt = 0;
						var checkFlag 	 = "";
						
						$(".resultData").append(objHtml);
	
						$.each(data.getRows(), function( index, row ) {
	
							section		= row.section;
							keyCode 	= row.keyCode;
							keyOrder	= row.keyOrder;
							valType 	= row.valType;
							valCur 		= row.valCur;
							if(row.valCur == null || row.valCur == "null"){
								valCur = "";
							}
							valDefault 	= row.valDefault;
							valList 	= row.valList;
							titleList 	= row.titleList;
							valDesc 	= row.valDesc;
	
							if(valList != null && valList != ""){
								arrValueList = valList.split(",");
								valueListCnt = arrValueList.length;
							}else{
								arrValueList = "";
							}
							
							if(titleList != null && titleList != ""){
								arrTitleList = titleList.split(",");
								titleListCnt = arrTitleList.length; 
							}else{
								arrTitleList = "";
							}
							
							objHtml   = "";
							checkFlag = "";
							
							if(valType == "TEXT"){
								objHtml += '<tr>';
								objHtml += '<td style="padding-left:5px" id="sectionTd_' + index + '"><span id="section_' + index + '">' + section + '</span></td>';
								objHtml += '<td style="padding-left:5px"><span id="keyCode_' + index + '">' + keyCode + '</span></td>';
								objHtml += '<td style="padding-left:5px"><span id="default_' + index + '">' + valDefault + '</span></td>';
								objHtml += '<td><input type="text" style="width:99%" id="text_' + index + '" name="text_' + index + '" value="' + valCur + '"/></td>';
								objHtml += '<td><span id="desc_' + index + '" title="' + valDesc + '" style="padding-left:6px;">' + valDesc + '</span></td>';
								objHtml += '<td style="display:none"><span id="data' + index + '">' + valType + '</span></td>';
								objHtml += '<td style="display:none"><span id="order' + index + '">' + keyOrder + '</span></td>';
								objHtml += '</tr>';
								
							}else if(valType == "RADIO"){
								objHtml += '<tr>';
								objHtml += '<td style="padding-left:5px" id="sectionTd_' + index + '"><span id="section_' + index + '">' + section + '</span></td>';
								objHtml += '<td style="padding-left:5px"><span id="keyCode_' + index + '">' + keyCode + '</span></td>';
								objHtml += '<td style="padding-left:5px"><span id="default_' + index + '">' + valDefault + '</span></td>';
								objHtml += '<td>';
								if(valueListCnt > 0){
									for(var j = 0; j < valueListCnt; j++){
										if(valCur == arrValueList[j]){
											checkFlag = "checked";
										}else{
											checkFlag = "";
										}
										objHtml += '<input type="radio" name="radio_' + index + '" id="radio_' + index 
												+ '" value="' + arrValueList[j] + '" ' + checkFlag + '/>' + arrTitleList[j] + '[' + arrValueList[j] + ']&nbsp;';
									}
								}
								objHtml += '</td>';
								objHtml += '<td><span id="desc_' + index + '" title="' + valDesc + '" style="padding-left:6px;">' + valDesc + '</span></td>';
								objHtml += '<td style="display:none"><span id="data' + index + '">' + valType + '</span></td>';
								objHtml += '<td style="display:none"><span id="order' + index + '">' + keyOrder + '</span></td>';
								objHtml += '</tr>';
							
							}else if(valType == "COMBO"){
								objHtml += '<tr>';
								objHtml += '<td style="padding-left:5px" id="sectionTd_' + index + '"><span id="section_' + index + '">' + section + '</span></td>';
								objHtml += '<td style="padding-left:5px"><span id="keyCode_' + index + '">' + keyCode + '</span></td>';
								objHtml += '<td style="padding-left:5px"><span id="default_' + index + '">' + valDefault + '</span></td>';
								objHtml += '<td><select id="combo_' + index + '" name="combo_' + index + '" style="width: 99%" class="list_box">';
								if(valueListCnt > 0){
									for(var j = 0; j < valueListCnt; j++){
										if(valCur == arrValueList[j]){
											checkFlag = "selected";
										}else{
											checkFlag = "";
										}
										objHtml += '<option value="' + arrValueList[j] + '" ' + checkFlag + '>[ ' + arrValueList[j] + ' ] ' + arrTitleList[j] + '</option>';
									}
									
								}
								objHtml += '</select></td>';
								objHtml += '<td><span id="desc_' + index + '" title="' + valDesc + '" style="padding-left:6px;">' + valDesc + '</span></td>';
								objHtml += '<td style="display:none"><span id="data' + index + '">' + valType + '</span></td>';
								objHtml += '<td style="display:none"><span id="order' + index + '">' + keyOrder + '</span></td>';
								objHtml += '</tr>';
							}
							
							$(".resultData").append(objHtml);
						});
						
						$("#text_1").focus();
						
						var colorArry  = ["#FFD3C7", "#FFF8D1", "#E3FFBA", "#BDFFEE", "#DBB5FF"];
						var sectionChk = "";
						var colorIdx   = -1;
						$.each(data.getRows(), function( index, row ) {
							if(sectionChk != row.section){
								sectionChk = row.section;
								colorIdx++;
							}
							if(colorIdx == 5){
								colorIdx = 0;
							}
							$("#sectionTd_" + index).attr("style","background-color:" + colorArry[colorIdx]);
							
						});
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function setIniContent(){
		
		var rowCount 	= $("#tblMain tr").size();
		var type 		= "";
		var strKeyValue	= "";
		var strSection 	= "";
		var strKeyCode 	= "";
		var strKeyOrder = "";
		
		if(rowCount > 0){
			argoConfirm("저장 하시겠습니까?", function(){
				
				for(var i=1; i < rowCount; i++){//row갯수만큼 0번째 인덱스는 타이틀이므로 제외
					type = $("#tblMain tr:eq("+i+") td:eq(5)").children().text();		 
					if(type == "RADIO"){
						var radioName = $("#tblMain tr:eq(" + i + ") td:eq(3)").children().attr('name');
						strKeyValue = $("input:radio[name=" + radioName + "]:checked").val();
						strSection = $("#tblMain tr:eq(" + i + ") td:eq(0)").children().text();
						strKeyCode = $("#tblMain tr:eq(" + i + ") td:eq(1)").children().text();
						strKeyOrder = $("#tblMain tr:eq(" + i + ") td:eq(6)").children().text();
					}
					if(type == "TEXT" || type == "COMBO"){
						strKeyValue = $("#tblMain tr:eq(" + i + ") td:eq(3)").children().val();
						strSection = $("#tblMain tr:eq(" + i + ") td:eq(0)").children().text();
						strKeyCode = $("#tblMain tr:eq(" + i + ") td:eq(1)").children().text();
						strKeyOrder = $("#tblMain tr:eq(" + i + ") td:eq(6)").children().text();
					}
					
					argoSetValue("ip_StrSection", strSection);
					argoSetValue("ip_StrKeyCode", strKeyCode);
					argoSetValue("ip_StrKeyOrder", strKeyOrder);
					argoSetValue("ip_StrKeyValue", strKeyValue);
					
					if(rowCount == i+1){
						Resultdata = argoJsonUpdate("menu", "setConfigSetting", "ip_", {}, fnCallbackSave);
					}else{
						Resultdata = argoJsonUpdate("menu", "setConfigSetting", "ip_", {});
					}
				}
			});
		}
	}
	
	function fnCallbackSave(data, textStatus, jqXHR){
		try{
		    if(data.isOk()) {
		    	
		    	workFlag = "메니저환경설정세팅";
		    	workLog  = '[태넌트:' + tenantId + ' | 수정ID:' + userId +'] ' + workFlag;
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
		    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
	    	} else {
	    		argoAlert("저장에 실패하였습니다.");
	    	}
		} catch(e) {
			console.log(e);    		
		}
	}

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="btn_areaB txt_r">
            		<button type="button" id="btnSavePop" name="btnSavePop" class="btn_m confirm" data-grant="W">저장</button>
            		<br>&nbsp;
            	</div>
            	<div class="input_area">
            		<table class="input_table" id="tblMain">
            			<colgroup>
            				<col width="20%">
                            <col width="17%">
                            <col width="13%">
                            <col width="17%">
                            <col width="33%">
                        </colgroup>
                        <tbody class="resultData">                                     
						</tbody>
					</table>
				</div>
                <div class="btn_areaB txt_r">  
                    <input type="hidden" id="ip_StrSection" name="ip_StrSection" >
					<input type="hidden" id="ip_StrKeyCode" name="ip_StrKeyCode" >
                    <input type="hidden" id="ip_StrKeyOrder" name="ip_StrKeyOrder" >
                    <input type="hidden" id="ip_StrKeyValue" name="ip_StrKeyValue" >
                    <input type="hidden" id="ip_UserId" name="ip_UserId" >  
            	</div>
            </div>            
        </section>
    </div>
</body>

</html>
