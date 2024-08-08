<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->    
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "문자열정의관리";
	var workLog 	= "";
	var dataArray 	= new Array();

	$(document).ready(function(param) {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});
	
	function fnInitCtrl() {	
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		if(grantId != "SuperAdmin" && grantId != "SystemAdmin") {
			$("#div_tenant").hide();
		}
		
		$("#s_FindTenantId").val(tenantId);
		
		$("#btnSearch").click(function() {
			fnSearchList();			
		});
		
		$("#btnSave").click(function() {
			fnSaveList();
		});
	}
	
	function fnInitGrid() {
		// 개인정보 마킹 종류 : {"":"선택", "ssn":"주민번호", "account":"계좌번호", "card":"카드번호", "tel":"전화번호", "email":"이메일", "name":"이름"}
		var groupList = {"":"선택", "ssn":"주민번호", "account":"계좌번호", "card":"카드번호", "tel":"전화번호", "email":"이메일", "name":"이름"};
		
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: false,
	        },
	        recordHeight : 26,
	        multiSelect: false,
	        columns: [  
						 { field: 'recid', 		caption: 'recid', 	size: '0%', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'tableName', 	caption: '테이블명', 	size: '200px', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'fieldName', 	caption: '필드명', 	size: '200px', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'fieldTitle', caption: '표시제목', 	size: '200px', 	sortable: true, attr: 'align=center', editable: { type: 'text' } }
		           	 	,{ field: 'maskingFlag', caption: '마스킹여부', 	size: '100px', 	sortable: true, attr: 'align=center',
		           	 		render: function (record) {
		           	 			var html = '';
		           	 			if(record.fieldTitle != "" && record.fieldTitle != null) {
			           	 			html = '<div  id="maskingDiv_'+record.recid+'" style="text-align: center">'+
				                    '    <input type="checkbox"  id="maskingFlag_'+record.recid+'" onclick="javascript:fnSetMaskingType(\''+ record.recid+ '\')" '+( record.maskingFlag == "Y" ? 'checked':'')+'>'+
				                    '</div>';
		           	 			} else {
		           	 				html = '<div  id="maskingDiv_'+record.recid+'" style="text-align: center; display: none;">'+
									'    <input type="checkbox"  id="maskingFlag_'+record.recid+'" onclick="javascript:fnSetMaskingType(\''+ record.recid+ '\')">'+
									'</div>';
		           	 			}
		           	        return html;
		             		}
						}
		           	 	//  Masking Type 
		           	 	,{ field: 'maskingType', caption: '마스킹타입', 	size: '200px', 	sortable: true, attr: 'align=center',
		           	 		render: function (record) {
		           	 			var html = "";
		           	 			
// 		           	 			if(record.fieldTitle != "" && record.fieldTitle != null) {
		           	 				var obj = document.createElement("select");
		           	 				
		           	 				for(key in groupList) {
										var opt = document.createElement("option");
										opt.appendChild(document.createTextNode(groupList[key]));
										opt.setAttribute ("value", key);
										if(key == record.maskingType) {
											opt.setAttribute ("selected", true);
										}
										obj.options.add(opt);
		           	 				}
		           	 				
		           	 				obj.setAttribute("id", "maskingType_"+record.recid);
		           	 				obj.setAttribute("name", "maskingType_"+record.recid);
		           	 				
		           	 				if(record.fieldTitle != "" && record.fieldTitle != null && record.maskingFlag == "Y") {
			           	 				obj.setAttribute("style", "width:95%;");
		           	 				} else {
		           	 					obj.setAttribute("style", "width:95%; display: none;");
		           	 				}
		           	 				
		           	 				html = obj.outerHTML;
// 		           	 			}
		           	 			
		           	        	return html;
		             		} 
		           	 	}
	       	],
	        records: dataArray,
	        onChange : function(event) {
	        	// value != ""  ? enabled
	        	// 문자열 표시제목 수정시
	        	if(event.column == "3") {
	        		// 새로운 값이 공백이 아니면 마스킹 여부 활성화
	        		if(event.value_new != "" && event.value_new != null) {
		        		$("div[id=maskingDiv_"+event.index+"]").css("display","block");
	        		} else {
		        		$("div[id=maskingDiv_"+event.index+"]").css("display","none");
		        		$("input:checkbox[id=maskingFlag_"+event.index+"]").prop("checked", false);
	        		}
	        	} else {
		        	if(w2ui['grid'].getCellValue(event.index,3) != "") {
		        		
		        	}
	        	}
	        },
	    });
		w2ui['grid'].hideColumn('recid');
	}

	function fnSetMaskingType(index){
		var maskingFlag = $("input:checkbox[id=maskingFlag_"+index+"]").is(":checked");

		// 마스킹 사용유무 Y 일때 마스킹 타입 지정
		if(maskingFlag == "true" || maskingFlag == true){
			$("select[id=maskingType_"+index+"]").css('display','block');
		}else{
			$("select[id=maskingType_"+index+"]").css('display','none');
			$("select[id=maskingType_"+index+"]").val("");
		}
	}
	
	function fnSearchList(){
		argoJsonSearchList('menu', 'getColTitleList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					dataArray = [];
					if (data.getRows() != ""){ 
						
						$.each(data.getRows(), function( index, row ) {
							
							gObject2 = {  "recid" 		: index
										, "tableName"	: row.tableName
					    				, "fieldName"	: row.fieldName
					   					, "fieldTitle"	: row.fieldTitle					
					   					, "maskingFlag"	: row.maskingFlag					
					   					, "maskingType"	: row.maskingType					
										};
										
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
						
					}
				}
				w2ui.grid.unlock();
			} catch (e) {
				console.log(e);
			}
			workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
			+ ' | GrantId:' + grantId + '] 조회';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
				tenantId : tenantId,
				userId : userId,
				actionClass : "action_class",
				actionCode : "W",
				workIp : workIp,
				workMenu : workMenu,
				workLog : workLog
			});
		});
	}
	
	function fnSaveList(){
// 		var arrChange = w2ui['grid'].getChanges();
// 		if (arrChange.length == 0) {
// 			return;
// 		}
		
		try{
			argoConfirm('변경된 내용을 저장 하시겠습니까?', function() {
				var param;
				var multiService = new argoMultiService(fnCallbackSave);
				$.each(w2ui['grid'].records, function( index, row ) {
					param = { 
								"findTenantId" 	: $("#s_FindTenantId").val(), 
								"fieldName"		: w2ui['grid'].getCellValue(row.recid, 2),
// 								"fieldTitle"	: row.fieldTitle,
								"fieldTitle"	: w2ui['grid'].getCellValue(row.recid, 3),
								"maskingFlag"	: $("input:checkbox[id=maskingFlag_"+row.recid+"]").is(":checked")?"Y":"N",
								"maskingType"	: $("select[id=maskingType_"+row.recid+"]").val(),
								"uptId"			: userId
							};
					
					if (w2ui['grid'].getCellValue(row.recid, 3) != "") {
						if (dataArray[row.recid].fieldTitle == "" || dataArray[row.recid].fieldTitle == null) {
							multiService.argoUpdate("menu", "setColTitleInsert", "__", param);
						} else {
							multiService.argoUpdate("menu", "setColTitleUpdate", "__", param);		
						}							
					}else{
						if (dataArray[row.recid].fieldTitle != "" && dataArray[row.recid].fieldTitle != null) {
							multiService.argoDelete("menu", "setColTitleDelete", "__", param);
						}
					}								
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		}
	}
	
	function fnCallbackSave(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				workLog = '[태넌트:' + $('#s_FindTenantId option:selected').val() + '] 변경';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
				argoAlert('성공적으로  저장 되었습니다.');
				fnSearchList();
			}
		} catch (e) {
			argoAlert(e);
		}
	}	
		
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">메뉴관리</span><strong class="step">문자열정의관리</strong></div>
        <section class="sub_contents">
            <div class="search_area row2">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px; display:none;" class="clilkSearch"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
	            <div class="sub_l">
	            	<!-- <strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span>  -->
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnSave" class="btn_m confirm">저장</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 100%;"></div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>