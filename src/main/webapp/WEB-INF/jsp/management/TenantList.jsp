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
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"	/>"></script> -->
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
	var workMenu 	= "회사정보관리";
	var workLog 	= "";
	var dataArray 	= new Array();

	$(document).ready(function(param) {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
		
	});
	
	var fvKeyId ; 
	
	function fnInitCtrl(){	
		$("#s_txtDate1_From").val("2000-01-01");
		$("#s_txtDate1_To").val(fnStrMask("YMD", argoCurrentDateToStr()));
		
		argoSetDatePicker();
	
		$("#btnSearch").click(function(){ //조회
			fnSearchList();			
		});
		
		$("#btnAdd").click(function(){
			gPopupOptions = {cudMode:"I", tenantId:'', insId:userId} ;   	
		 	argoPopupWindow('회사등록', 'TenantPopupEditF.do', '600', '300');
		});

		$("#btnDelete").click(function(){
// 			fnDeleteList();
			fnExpireReason();
		});	
		
		$("#btnReset").click(function(){
			$("#s_txtDate1_From").val("2000-01-01");
			$("#s_txtDate1_To").val(fnStrMask("YMD", argoCurrentDateToStr()));
			$("#s_FindTenantNameText").val("");
			$("#s_FindDiskLimitFrom").val("");
			$("#s_FindDiskLimitTo").val("");
			$("#s_FindDiskUsedFrom").val("");
			$("#s_FindDiskUsedTo").val("");
		});
		
		$(".clickSearch").keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchList();
	 		 }
		});
	}
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        multiSelect: true,
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >=0 ) {
					gPopupOptions = {cudMode:'U', pRowIndex:record} ;
					if(record.expireDate == '' || record.expireDate == null) {
						argoPopupWindow('회사정보수정', 'TenantPopupEditF.do', '600', '300');
					} else {
						argoPopupWindow('회사정보수정', 'TenantPopupEditF.do', '600', '430');
					}
				}
	        },
	        columns: [  
					 	 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'tenantId', 	 	caption: '회사ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'tenantName', 	caption: '회사명', 		size: '9%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'agentCount', 	caption: '상담사수', 		size: '6%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'managerCount', 	caption: '내선수', 		size: '6%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'regDate', 		caption: '등록일자', 		size: '13%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'expireDate', 	caption: '해지일자', 		size: '13%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'expireReason', 	caption: '해지사유', 		size: '6%', 	sortable: true, attr: 'align=center' }
//             	 		,{ field: 'diskLimit',  	caption: '디스크용량', 		size: '7%', 	sortable: true, attr: 'align=center' }
//             	 		,{ field: 'diskUsed', 		caption: '사용량(GB)',		size: '7%', 	sortable: true, attr: 'align=center' }
//             	 		,{ field: 'loginipCheck',	caption: '로그인IP제한', 	size: '8%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'basePath', 	    caption: '기본경로', 		size: '7%', 	sortable: true, attr: 'align=center' }
//             	 		,{ field: 'serialNo', 	   	caption: '등록번호', 		size: '6%', 	sortable: true, attr: 'align=center' }

	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid' ); 
	}
	
	function fnSearchList(startRow, endRow){
		argoJsonSearchList('userInfo', 'getTenantList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					$("#totCount").html(data.getProcCnt());
					
					if(data.getProcCnt() == 0){
						argoAlert('조회 결과가 없습니다.');
					}
					
					w2ui.grid.clear();
					dataArray = [];
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {  "recid" 			: index
					    				, "tenantId"		: row.tenantId
					   					, "tenantName"	  	: row.tenantName
										, "agentCount" 		: row.agentCount
										, "managerCount"	: row.managerCount
										, "regDate" 		: row.regDate
										, "expireDate" 		: row.expireDate
										, "expireReason"	: row.expireReason
										, "diskLimit"		: row.diskLimit
										, "diskUsed" 		: row.diskUsed										
										, "loginipCheck" 	: row.loginipCheck										
										, "basePath" 		: row.basePath
										, "serialNo" 		: row.serialNo
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
	
	var delTenantList;
// 	function fnDeleteList(){
	function fnDeleteList(expireReason){
		try{
			var arrChecked = w2ui['grid'].getSelection();

		 	if(arrChecked.length==0) {
// 		 		argoAlert("삭제할 회사를 선택하세요") ; 
		 		argoAlert("해지할 회사를 선택하세요") ; 
		 		return ;
		 	}
		 	
// 			argoConfirm('선택한 회사 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
			argoConfirm('선택한 회사 ' + arrChecked.length + '건을  해지하시겠습니까?', function() {
				
				var multiService = new argoMultiService(fnCallbackDelete);
				delTenantList = "";
				
				$.each(arrChecked, function( index, value ) {
					var param = { 
						"tenantId" :  w2ui['grid'].getCellValue(value, 1)
					  , "expireReason" : expireReason
					};
					delTenantList += w2ui['grid'].getCellValue(value, 1);
					multiService.argoDelete("userInfo", "setTenantInfoDelete", "__", param);
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		}
	}
	
	function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
// 				workLog = '[태넌트ID:' + delTenantList + '] 삭제';
				workLog = '[태넌트ID:' + delTenantList + '] 해지';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
// 				argoAlert('성공적으로 삭제 되었습니다.');
				argoAlert('성공적으로 해지 되었습니다.');
				fnSearchList();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
	function fnExpireReason() {
		// 1. 체크박스 선택 여부 검사		
		var arrChecked = w2ui['grid'].getSelection();
	 	if(arrChecked.length==0) {
	 		argoAlert("해지할 회사를 선택하세요"); 
	 		return;
	 	}
	 	
	 	// 2. 해지 회사 선택 여부 검사
	 	var expireCnt = 0;
	 	$.each(arrChecked, function( index, value ) {
	 		if(w2ui['grid'].getCellValue(value, 6) != "") {
				expireCnt++;
	 		}
	 	});
	 	if(expireCnt > 0) {
	 		argoAlert('이미 해지된 회사가 포함되어 있습니다.');
 			return;
	 	}
		
	 	// 3. 해지사유 입력 페이지 open
		argoPopupWindow('해지사유입력', 'TenantPopupExpireReasonF.do', '600', '300');
	}

</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">운용관리</span><strong class="step">회사정보관리</strong></div>
        <section class="sub_contents">
            <div class="search_area row3">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                           	<input type="text"	id="s_FindTenantNameText" name="s_FindTenantNameText" style="width:144px" class="clickSearch"/>
                        </li>
                    </ul>
                </div>
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">디스크용량</strong>
                           	<input type="text"	id="s_FindDiskLimitFrom" name="s_FindDiskLimitFrom" style="width:144px" class="clickSearch"/>
                           	&nbsp; ~ &nbsp;
                           	<input type="text"	id="s_FindDiskLimitTo" name="s_FindDiskLimitTo" style="width:144px" class="clickSearch"/>
                        </li>
                        <li>
                            <strong class="title ml20">디스크사용량</strong> &nbsp; 
                           	<input type="text"	id="s_FindDiskUsedFrom" name="s_FindDiskUsedFrom" style="width:100px" class="clickSearch"/>
                           	&nbsp; ~ &nbsp;
                           	<input type="text"	id="s_FindDiskUsedTo" name="s_FindDiskUsedTo" style="width:100px" class="clickSearch"/>
                        </li>
                    </ul>
                </div>
                <div class="row" style="display:none">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">등록일자</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
							<span class="text_divide" style="width:244px"> &nbsp; &nbsp; ~ &nbsp; &nbsp; </span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                        </li>
                    </ul>
                </div>                 
            </div>
            <div class="btns_top">
	            <div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
                <!-- <button type="button" id="btnDelete" class="btn_m confirm">삭제</button> -->
                <button type="button" id="btnDelete" class="btn_m confirm">해지</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 410px;"></div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>