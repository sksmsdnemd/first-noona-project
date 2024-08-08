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
<style>
	.ui-autocomplete
	{
		max-height: 100px;
		overflow-y: auto; /* prevent horizontal scrollbar */
		overflow-x: hidden;
	}
	/* IE 6 doesn't support max-height
	* we use height instead, but this forces the menu to always be this tall
	*/
	html .ui-autocomplete
	{
		height: 100px;
	}
</style>

<script>
	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	var authRank	= loginInfo.SVCCOMMONID.rows.authRank;
	var workMenu 	= "사용자정보관리";
	var workLog 	= "";
	var dataArray 	= new Array();

	$(document).ready(function(param) {
		if(controlAuth == null){
			controlAuth = "";
		}

		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});
	
	var fvKeyId ; 

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			argoCbCreate("s_FindGrantId", "comboBoxCode", "getGrantList", {findTenantId:$('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			fnGroupCbChange("s_FindGroupId")
		}
	}	
	
	function fnInitCtrl(){	
		
		$("#btnExcel").click(function(){
			var excelArray = [];
			
			var param = {
	            userId:userId, controlAuth:controlAuth, grantId:grantId, authRank:authRank,
	            recListeningYn  : argoGetValue('selRecListeningYn'),
	            recDownloadYn   : argoGetValue('selRecDownloadYn'),
	            recAprvYn       : argoGetValue('selRecAprvYn'),
	            qaYn            : argoGetValue('selQaYn'),
	            lockUserSearch  : argoGetValue('s_LockUserSearch')
	        };
		    param["iSPageNo"] = 1;
		    param["iEPageNo"] = 99999;
			argoJsonSearchList('userInfo', 'getUserInfoList', 's_', param, function (data, textStatus, jqXHR) {
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {
							var retireFlag;
							if (row.retireeFlag == "0") { retireFlag = "퇴직" } else { retireFlag = "재직";}
							
							gObject = {   "순번" 		: index + 1
										, "사용자ID"	: row.userId
										, "사용자명" 	: row.userName
										, "그룹" 		: row.groupName
										, "권한" 		: row.grantName
										, "퇴직여부" 	: retireFlag
									};
							excelArray.push(gObject);
						});
						
						gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
						argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
						workLog = '[TenantId:'
							+ tenantId
							+ ' | UserId:' + userId
							+ ' | GrantId:'
							+ grantId
							+ '] Excel Export';
						
						
						argoJsonUpdate(
							"actionLog",
							"setActionLogInsert",
							"ip_",
							{
								tenantId : tenantId,
								userId : userId,
								actionClass : "action_class",
								actionCode : "W",
								workIp : workIp,
								workMenu : workMenu,
								workLog : workLog
							});
					}
				} catch (e) {
					console.log(e);
				}
			});
		});
		
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		//argoCbCreate("s_FindGroupId", "userAuth", "getUserControlGroupList", {tenantId:tenantId, userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
        argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupList", {findTenantId:tenantId, controlAuth:controlAuth}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		//argoCbCreate("s_FindGroupId", "comboBoxCode", "getControlAuthList", {findTenantId: tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});

		argoCbCreate("s_FindGrantId", "comboBoxCode", "getGrantList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnGroupCbChange("s_FindGroupId");
		
		fnAuthBtnChk(parent.$("#authKind").val());
		
		
		
		// 권한 나보다 높은거 삭제
		if(authRank > 1){
			for(var i = authRank ; i > 1 ; i-- ){
				$('#s_FindGrantId option').eq(i-1).remove();
			}
		}
		
		
		if(grantId != "SuperAdmin" && grantId != "SystemAdmin"){
			$("#div_tenant").hide();
		}

		$("#s_FindTenantId").change(function() {	fnSetSubCb('tenant'); 	});

		$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
		
		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});

		$("#btnAdd").hide();
		$("#btnAdd").click(function(){
			gPopupOptions = {cudMode:"I", tenantId:$('#s_FindTenantId option:selected').val(), insId:userId} ;   	
		 	argoPopupWindow('사용자등록', 'UserPopupEditF.do', '1000', '720');
		});

        /** 권한설정 버튼 클릭 이벤트 처리 - 사용자 권한 설정 팝업 */
        $("#btnAuthSet").css("display", authRank > 3 ? "none" : "");    // 권한설정 버튼 display - Manager 권한 이하 hide
        //$("#btnAuthSet").css("display", "none");    
		$("#btnAuthSet").click(function() {
		    if (authRank > 3) {
		        argoAlert('권한이 없습니다.');
		    }
            gPopupOptions = {tenantId: $('#s_FindTenantId').val() || tenantId} ;
            argoPopupWindow('사용자권한설정', 'UserAuthSetPopF.do', '1024', '760');
        });
        
		$("#btnForcedLogout").click(function() {
		    /* if (authRank > 3) {
		        argoAlert('권한이 없습니다.');
		    } */
		    var arrChecked = w2ui['grid'].getSelection();
		 	if(arrChecked.length==0) {
		 		argoAlert("강제 로그아웃 대상을 선택해 주십시오.") ; 
		 		return ;
		 	}
		    
		 	if(grantId != "SuperAdmin"){
		 		argoAlert("권한이 불충분합니다.<br>슈퍼어드민 권한 유저만 사용하여 주십시오.") ;
		 		return;
		 	}
		 	
		 	argoConfirm('선택한 유저 ' + arrChecked.length + '명을  <br>강제로그아웃 하시겠습니까?', function() {
				
		 		var multiService = new argoMultiService(fnCallbackForceLogout);
				$.each(arrChecked, function( index, value ) {
					var param = { 
					  "tenantId" : w2ui['grid'].get(value).tenantId,
					  "userId" : w2ui['grid'].get(value).userId,
					  "forcedLogout" : "1"
					};
					multiService.argoUpdate("userInfo","setForcedLogoutUpdate","__", param);
				});
				multiService.action();
			});	
        });
        
        
		$("#btnForcedLogoutCancel").click(function() {
		    /* if (authRank > 3) {
		        argoAlert('권한이 없습니다.');
		    } */
		    var arrChecked = w2ui['grid'].getSelection();
		 	if(arrChecked.length==0) {
		 		argoAlert("강제 로그아웃 취소 대상을 선택해 주십시오.") ; 
		 		return ;
		 	}
		    
		 	if(grantId != "SuperAdmin"){
		 		argoAlert("권한이 불충분합니다.<br>슈퍼어드민 권한 유저만 사용하여 주십시오.") ;
		 		return;
		 	}
		 	
		 	argoConfirm('선택한 유저 ' + arrChecked.length + '명을  <br>강제로그아웃 취소 하시겠습니까?', function() {
				
		 		var multiService = new argoMultiService(fnCallbackForceLogoutCancel);
				$.each(arrChecked, function( index, value ) {
					var param = { 
					  "tenantId" : w2ui['grid'].get(value).tenantId,
					  "userId" : w2ui['grid'].get(value).userId,
					  "forcedLogout" : ""
					};
					multiService.argoUpdate("userInfo","setForcedLogoutUpdate","__", param);
				});
				multiService.action();
			});	
        });
		
		

        $("#btnDelete").hide();
		$("#btnDelete").click(function(){
			fnDeleteList();
		});	
		
		$("#btnLive").click(function(){
			fnLiveApply();
		});

		$("#btnReset").click(function(){
			$('#s_FindGroupId		option[value=""]').prop('selected', true);
			$('#s_FindRetireeFlag	option[value="1"]').prop('selected', true);
			$('#s_FindAgentStatus	option[value=""]').prop('selected', true);
			$('#s_FindLoginCheck	option[value=""]').prop('selected', true);
			$('#s_FindGrantId		option[value=""]').prop('selected', true);
			$("#s_FindUserNameText").val('');
			$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
			argoCbCreate("s_FindGroupId", "userAuth", "getUserControlGroupList", {findTenantId:$('#s_FindTenantId option:selected').val(), userId:userId, controlAuth:controlAuth, grantId:grantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});

			fnGroupCbChange("s_FindGroupId")
		});
		
		$(".clickSearch").keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		
		//[input]사용자 자동검색 - start
		var dataList = "";
		$('#s_FindUserNameText').autocomplete({
			source : function(request, response){
				argoJsonSearchList('recSearch', 'getRecUserInfo', '',{"tenantId":tenantId, "authRank":authRank, "srchKeyword":$('#s_FindUserNameText').val()}, function(data, textStatus, jqXHR){
					try {
						var strOption2 = "";
						if (data.isOk()) {
							
							function fnUserListBind (){
								response(
									$.map(data.getRows(), function(item){
										return{
											label : item.tenantName + " " + item.groupName + " " + item.userName+"("+item.userId+")" //테넌트네임, 그룹명, 사용자명(상담사ID)
					             ,value : item.userId		// 선택 시 input창에 표시되는 값
					             ,idx : item.SEQ // index
										};
									})
								);
							}
							fnUserListBind();
						}
					} catch (e) {
						console.log(e);
					}
				});
			}
			,focus : function(event, ui) { // 방향키로 자동완성단어 선택 가능하게 만들어줌	
					return false;
			}
			,minLength: 1// 최소 글자수
			,autoFocus : true // true == 첫 번째 항목에 자동으로 초점이 맞춰짐
			,delay: 100	//autocomplete 딜레이 시간(ms)
			//,select : function(evt, ui) { 
					//console.log(ui.item.label);
					//console.log(ui.item.idx);
			//} 
		});
		//[input]사용자 자동검색 - end
		
	}
	
	function fnCallbackForceLogout(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	argoAlert('강제 로그아웃이 완료 되었습니다.') ;	
		    	fnSearchListCnt();
		    }
		} catch(e) {
			argoAlert(e);    		
		}
	}
	
	function fnCallbackForceLogoutCancel(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	argoAlert('강제 로그아웃이 취소 되었습니다.') ;	
		    	fnSearchListCnt();
		    }
		} catch(e) {
			argoAlert(e);    		
		}
	}
	
	
	function logOut(obj){

		var forcedLogout;
		var msg = "";
		var uptUserId = w2ui['grid'].getCellValue(obj.id, 1);
		var uptSessionId = w2ui['grid'].getCellValue(obj.id, 22);
		
		if(obj.checked == true){
			msg	= "강제 로그 아웃 하시겠습니까?";
			forcedLogout = "0";
		}else{
			msg	= "강제 로그 아웃 상태를 해제 하시겠습니까?";
			forcedLogout = "1";
		}
		
		var param = { 
						"sessionId" 	: uptSessionId, 
						"userId"   		: uptUserId,
						"forcedLogout"	: forcedLogout,
						"tenantId"		: tenantId
					};
		
		argoConfirm(msg, function() {
			argoJsonUpdate("userInfo", "setForcedLogoutUpdate", "s_", param, function(data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						workLog = ("[회사ID:" + tenantId + " | 사용자ID:" + uptUserId + "] 강제 로그아웃");
						argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
										,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
						if(obj.checked == true){
							argoAlert('성공적으로 강제로그아웃 되었습니다.');	
						}else{
							argoAlert('성공적으로 강제로그아웃 해제되었습니다.');
						}
						fnSearchListCnt();
					}
				} catch (e) {
					console.log(e);
				}	
			});
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
					gPopupOptions = {cudMode:'U', pRowIndex:record, tenantId:$('#s_FindTenantId option:selected').val(), insId:userId} ;   	
					argoPopupWindow('사용자정보수정', 'UserPopupEditF.do', '1000', '720');
				}
	        },
	        onChange: function (event) {
	        	var record = this.get(event.recid);
	        	var key = Object.keys(record);
	        	if(key[event.column] == "forcedLogout"){
	        		event.preventDefault();
	        	}
	        },
	        columns: [  
						 { field: 'recid', 			 	caption: 'recid', 			size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'tenantId', 	 		caption: '태넌트ID', 			size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'userId', 	 		caption: '사용자ID', 			size: '8%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'userName', 			caption: '사용자명', 			size: '8%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'groupId', 		    caption: '그룹', 				size: '0%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'groupName', 		    caption: '그룹', 				size: '8%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'grantName', 		 	caption: '권한', 				size: '8%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'grantId', 		 	caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'retireeFlag', 	 	caption: '퇴직여부', 			size: '0%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'retireeFlagName',  	caption: '퇴직여부', 			size: '6%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'accessFlag', 		caption: '접속권한', 			size: '0%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'accessFlagName',		caption: '접속권한', 			size: '0%', 	sortable: true, attr: 'align=center' }
            	 		,{ field: 'agentStatus', 	    caption: '접속상태', 			size: '6%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'loginDate', 		 	caption: '접속시간', 			size: '16%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'loginLockYn', 		caption: '장기미사용자', 		size: '6%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'loginIp', 	        caption: '로그인IP', 			size: '12%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'loginFlag', 	 	    caption: '매니저로그인', 		size: '8%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'forcedLogout', 		caption: '강제로그아웃여부', 	size: '8%', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center' }
            			,{ field: 'mainPage', 	 		caption: 'mainPage', 		size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'loginCheckUse',		caption: 'loginCheckUse', 	size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'loginCheckFrom', 	caption: 'loginCheckFrom', 	size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'loginCheckTo', 	 	caption: 'loginCheckTo', 	size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'convertFlagName', 	caption: '변환권한', 			size: '6%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'playerKindName',  	caption: '재생방법', 			size: '6%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'realPlayKindName',  	caption: '실시간감청 재생방법', 			size: '6%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'sessionId',  		caption: 'sessionId', 		size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'salt',  				caption: 'salt', 			size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'recListeningYn',  	caption: 'recListeningYn', 	size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'recDownloadYn',  	caption: 'recDownloadYn', 	size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'recAprvYn',  		caption: 'recAprvYn', 		size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'qaYn',  				caption: 'qaYn', 			size: '0%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'controlAuth', 	 	caption: 'controlAuth', 	size: '0%', 	sortable: true, attr: 'align=center' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'tenantId', 'sessionId', 'retireeFlag', 'groupId', 'grantId', 'accessFlag', 'accessFlagName', 'mainPage', 'loginCheckUse', 'loginCheckFrom', 'loginCheckTo', 'controlAuth', 'realPlayKindName', 'salt'
		    , 'recListeningYn', 'recDownloadYn', 'recAprvYn', 'qaYn', 'playerKindName', 'agentStatus'
        );
	}
	
	function fnSearchListCnt() {
        var param = {
            userId:userId, controlAuth:controlAuth, grantId:grantId, authRank:authRank,
            recListeningYn  : argoGetValue('selRecListeningYn'),
            recDownloadYn   : argoGetValue('selRecDownloadYn'),
            recAprvYn       : argoGetValue('selRecAprvYn'),
            qaYn            : argoGetValue('selQaYn'),
            lockUserSearch  : argoGetValue('s_LockUserSearch')
        };
		//w2ui.grid.lock('조회중', true);
		argoJsonSearchOne('userInfo', 'getUserInfoCount', 's_', param, function (data, textStatus, jqXHR) {
			try {
				
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					userListPaging(totalData, "1");
					$("#totCount").html(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
					
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	
	function userListPaging(totalData, currentPage, dataPerPage, cntType){
		pageCurrentCnt = currentPage;
		
		if(dataPerPage == undefined){
			dataPerPage=15;
		}

		var pageCount=10;
		var defaultYn="N";
		
		if(totalData==0){
			totalData=1;
			defaultYn="Y";
		}
		
		var totalPage = Math.ceil(totalData/dataPerPage);    // 총 페이지 수
		var pageGroup = Math.ceil(currentPage/pageCount);    // 페이지 그룹

		var last = pageGroup * pageCount;    // 화면에 보여질 마지막 페이지 번호
		if(last > totalPage)
			last = totalPage;
		var first = last - (pageCount-1);    // 화면에 보여질 첫번째 페이지 번호
		var next = last+1;
		var prev = first-1;

		if(first<1) first = 1
	   
		var html = "";
	   
	    if(prev > 0){
	        html += '<a href="#" class="first" id="first">first</a><a href="#" class="prev" id="prev">prev</a>';
	    }
	   
		html += '<ul class="paging">';

		for(var i=first; i <= last; i++){
			html += '<li><a href="#" id='+i+'>'+i+'</a></li>';
		}
		html +='</ul>';
	   
		if(last < totalPage){
	   		html += '<a href="#" class="next" id="next">next</a><a href="#" class="last" id="last">last</a>';
		}
	   
		$("#paging").html(html);    // 페이지 목록 생성
		$("#paging a#" + currentPage).addClass("on");    // 현재 페이지 표시
	   
		var startRow  = ((currentPage -1)*dataPerPage)+1;
		var endRow    = currentPage * dataPerPage;
	   
	    fnSearchList(startRow,endRow);

		if(defaultYn=='N'){
			$("#paging a").click(function(){
		       
				var $item = $(this);
				var $id = $item.attr("id");
				var selectedPage = $item.text();
		       
				if($id == "next")	selectedPage = next;
				if($id == "prev")	selectedPage = prev;
				if($id == "first")	selectedPage = 1;
				if($id == "last")	selectedPage = totalPage-(totalPage%pageCount)+1;
				userListPaging(totalData, selectedPage, dataPerPage, cntType);
			});
		}
		w2ui.grid.unlock();
	}
	
	
	function fnSearchList(startRow, endRow) {
	    var param = {
            userId:userId, controlAuth:controlAuth, grantId:grantId, authRank:authRank,
            recListeningYn  : argoGetValue('selRecListeningYn'),
            recDownloadYn   : argoGetValue('selRecDownloadYn'),
            recAprvYn       : argoGetValue('selRecAprvYn'),
            qaYn            : argoGetValue('selQaYn'),
            lockUserSearch  : argoGetValue('s_LockUserSearch')
        };
	    param["iSPageNo"] = startRow;
	    param["iEPageNo"] = endRow;
	    //////
		argoJsonSearchList('userInfo', 'getUserInfoList', 's_', param, function (data, textStatus, jqXHR) {
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					dataArray = [];
					if (data.getRows() != ""){ 
						var forceLogout;
						var chelog;
						var agentStatus;
						var weblog;
						var accessFlagName;
						var retireFlag;
						var subAdd;
						var convertFlag;
						var playerKind;
						var realPlayKind;
						
						$.each(data.getRows(), function( index, row ) {
							/* if(row.forcedLogout == "0"){
								forceLogout = '<input type="checkbox" id="' + index + '" name="forceLogout" onchange="javascript:logOut(this);" checked/>';
							}else{
								forceLogout = '<input type="checkbox" id="' + index + '" name="forceLogout" onchange="javascript:logOut(this);" />';
							} */
							//debugger;
							
							
							if(row.agentStatus == "01"){
								agentStatus = '<img src="../images/icons/agent_login.gif">'; 
							}else{
								agentStatus = '<img src="../images/icons/circle_logout.gif">'; 
								
							}
							if(row.loginFlag == "0"){
								weblog = '<img src="../images/icons/circle_logout.gif">';
							}else{
								weblog = '<img src="../images/icons/web_login.gif">';
							}
							
							if (row.accessFlag  == "0")	{ accessFlagName = "허용" } else { accessFlagName = "비허용";	}
							if (row.recDownloadYn == "Y")	{ convertFlag = "O" 	} else { convertFlag = "X";			}
							if (row.backupFlag	== "1")	{ backupFlag = "X" 	} 	  else { backupFlag = "O";			}
							if (row.retireeFlag == "0") { retireFlag = "퇴직" 	} else { retireFlag = "재직";			}
							if (row.playerKind  == "1")	{ playerKind = "전용재생"	} else { playerKind = "웹재생";		}
							if (row.realPlayKind  == "1")	{ realPlayKind = "전용재생"	} else { realPlayKind = "웹재생";		}
							subAdd = ' <button type="button" id="sub" class="btn_m" onclick="javascript:sortSh(' + index + ');">메모보기</button>';
							
							gObject2 = {  "recid" 			: index
										, "tenantId"		: row.tenantId	
										, "userId"		  	: row.userId
					   					, "userName"	  	: row.userName
										, "groupId" 		: row.groupId
										, "groupName" 		: row.groupName
										, "grantName" 		: row.grantName
										, "grantId" 		: row.grantId
										, "retireeFlag"		: row.retireeFlag
										, "retireeFlagName"	: retireFlag
										, "accessFlag" 		: row.accessFlag										
										, "accessFlagName" 	: accessFlagName										
										, "agentStatus" 	: agentStatus
										, "loginDate" 		: row.loginDate
										, "loginLockYn" 	: row.loginLockYn
										, "loginIp" 		: row.loginIp
										, "loginFlag" 	    : weblog
										, "forcedLogout"	: row.forcedLogout==1?true:false
										, "mainPage"    	: row.mainPage
										, "loginCheckUse"	: row.loginDateCheckUse
										, "loginCheckFrom"  : row.loginDateCheckFrom
										, "loginCheckTo"    : row.loginDateCheckTo
										, "convertFlag"    	: row.convertFlag
										, "convertFlagName" : convertFlag
										, "backupFlag"    	: row.backupFlag
										, "playerKind"		: row.playerKind
										, "playerKindName"	: playerKind
										, "realPlayKind"	: row.realPlayKind
										, "realPlayKindName": realPlayKind
										, "sessionId"    	: row.sessionId
										, "salt"			: row.salt
										, "recListeningYn"  : row.recListeningYn
										, "recDownloadYn"   :row.recDownloadYn
										, "recAprvYn"       : row.recAprvYn
										, "qaYn"            : row.qaYn 
										, "controlAuth"     : row.controlAuth
										
										//control_auth,{ field: 'controlAuth', 	 	caption: 'controlAuth', 	size: '0%', 	sortable: true, attr: 'align=center' }
										};
							
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
				}
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
	
	function fnDeleteList(){
		try{
			var arrChecked = w2ui['grid'].getSelection();

		 	if(arrChecked.length == 0) {
		 		argoAlert("삭제할 사용자를 선택하세요") ; 
		 		return ;
		 	}

			argoConfirm('선택한 사용자 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				
				var multiService = new argoMultiService(fnCallbackDelete);
				var tenantId = $('#s_FindTenantId option:selected').val();
				var duserId;
				
				$.each(arrChecked, function( index, value ) {

					var duserId = w2ui['grid'].getCellValue(value, 1);
					workLog = '[유저ID:' + duserId + '] 삭제';
					var param = { 
									"tenantId" :  tenantId, 
									"userId"   :  duserId
								};
					multiService.argoDelete("userInfo", "setUserInfoDelete", "__", param);
					argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
						,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
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
				workLog = '[유저ID:' + userId + '] 삭제';
				/*argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});*/
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchListCnt();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
	function fnLiveApply(){
		try{
			argoConfirm('사용자정보를  실시간적용요청을 하시겠습니까?', function() {
// 				argoJsonSearchList('comboBoxCode', 'getOsuIpList', 's_', {"updateType":"2"}, function (data, textStatus, jqXHR){
// 					try{
// 						if(data.isOk()){
// 							if(data.getRows() != ""){
// 								$.each(data.getRows(), function( index, row ) {
// 									argoJsonSearchList('comboBoxCode', 'getMruProcessList', 's_', {"updateType":"2", "code":row.code, "codeNm":row.codeNm}, function (data, textStatus, jqXHR){
// 										try{
// 											if(data.isOk()){
// 											}
// 										} catch(e) {
// 											console.log(e);			
// 										}
// 									});
// 								});
// 							}
// 						}
// 					} catch(e) {
// 						console.log(e);			
// 					}
// 				});
// 				argoJsonSearchList('comboBoxCode', 'getMruMruVSSIpList', 's_', {}, function (data, textStatus, jqXHR){
// 					$.each(data.getRows(), function( index, row ) {
// 						fnLiveApplyRequest(row.systemIp);
// 					});
// 				});

				workLog = ("[회사ID:" + tenantId + " | 사용자ID:" + userId + "] 실시간 적용 요청");
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			});
		}catch(e){
			console.log(e) ;	 
		}
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">운용관리</span><span class="step">사용자관리</span><strong class="step">사용자정보관리</strong></div>
        <section class="sub_contents">
            <div class="search_area row4">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title_wide ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px;display:none" class="clickSearch"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                        </li>
                        <li>
                            <strong class="title_wide ml20">권한</strong>
                            <select id="s_FindGrantId" name="s_FindGrantId" style="width:150px;" class="list_box"></select>
                        </li>
                        <li style="margin-top:4px;">
                            <strong class="title_wide ml20">장기 미사용자만 조회</strong>
                            <input type="checkbox" id="s_LockUserSearch" name="s_FindGrantId" value="O">
                        </li>
                    </ul>
                </div>
                <div class="row" id="div_user">
                    <ul class="search_terms">
                        <li>
                            <strong class="title_wide ml20">그룹</strong>
                            <select id="s_FindGroupId" name="s_FindGroupId" style="width:150px" class="list_box"></select>
                        </li>
                        <li>
                            <strong class="title_wide ml20">사용자</strong>
                            <input type="text" 	id="s_FindUserNameText" name="s_FindUserNameText" style="width:150px" class="clickSearch"/>
                        </li>
                        <li>
                            <strong class="title_wide ml20">평가권한</strong>
                            <select id="selQaYn" name="selQaYn" class="list_box"  style="width: 150px" >
                                <option value="" selected>선택하세요!</option>
                                <option value="A">전체권한</option>
                                <option value="Y">평가권한</option>
                                <option value="N">없음</option>
                            </select>
                        </li>
                    </ul>
                </div>        
                <div class="row">
                    <ul class="search_terms">
                       <li>
                            <strong class="title_wide ml20">퇴직여부</strong>
                            <select id="s_FindRetireeFlag" name="s_FindRetireeFlag" style="width:150px;" class="list_box">
                                <option value="">선택하세요!</option>
								<option value="1" selected>재직(아니요)</option>
								<option value="0">퇴직(예)</option>
                            </select>
                        </li>
                        <li>
                       		<strong class="title_wide ml20">접속상태</strong>
                        	<select id="s_FindAgentStatus" name="s_FindAgentStatus" class="list_box"  style="width: 150px" >
								<option value="" selected>선택하세요!</option>
								<option value="01">예</option>
								<option value="99">아니요</option>
							</select>
                        </li>
                        <li>
                        	<strong class="title_wide ml20">매니저로그인</strong>
                        	<select id="s_FindLoginCheck" name="s_FindLoginCheck" class="list_box"  style="width: 150px" >
								<option value="" selected>선택하세요!</option>
								<option value="1">예</option>
								<option value="2">아니요</option>
							</select>
                        </li>
                    </ul>
                </div>

                <div class="row">
                    <ul class="search_terms">
<%--                        <li style="width:280px"> --%>
<%--                             <strong class="title ml20">승인권한</strong> --%>
<%--                             <input type="checkbox" class="checkbox" id="chkRecListeningYn" name="chkRecListeningYn" value="Y" > --%>
<%--                             <label for="chkRecListeningYn" style="width: 60px">청취</label> --%>
<%--                             <input type="checkbox" class="checkbox" id="chkRecDownloadYn" name="chkRecDownloadYn" value="Y" > --%>
<%--                             <label for="chkRecDownloadYn" style="width: 60px">다운로드</label> --%>
<%--                         </li> --%>
                        <li>
                            <strong class="title_wide ml20">청취승인권한</strong>
                            <select id="selRecListeningYn" name="selRecListeningYn" class="list_box"  style="width: 150px;" >
                                <option value="" selected>선택하세요!</option>
                                <option value="Y">예</option>
                                <option value="N">아니요</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title_wide ml20">변환권한</strong>
                            <select id="selRecDownloadYn" name="selRecDownloadYn" class="list_box"  style="width: 150px;" >
                                <option value="" selected>선택하세요!</option>
                                <option value="Y">예</option>
                                <option value="N">아니요</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title_wide ml20">승인내역확인권한</strong>
                            <select id="selRecAprvYn" name="selRecAprvYn" class="list_box"  style="width: 150px;" >
                                <option value="" selected>선택하세요!</option>
                                <option value="Y">예</option>
                                <option value="N">아니요</option>
                            </select>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
	            <div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span>
	            	<button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button> 
                </div>
                
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnAuthSet" class="btn_m">권한설정</button>
                <button type="button" id="btnForcedLogout" class="btn_m confirm">강제로그아웃</button>
                <button type="button" id="btnForcedLogoutCancel" class="btn_m confirm">강제로그아웃 취소</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
                
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 415px;"></div>
	                <div class="list_paging" id="paging">
                		<ul class="paging">
                 			<li><a href="#" id='' class="on"></a>1</li>
                 		</ul>
                	</div>
	            </div>
	        </div>
        </section>
    </div>
</body>

</html>