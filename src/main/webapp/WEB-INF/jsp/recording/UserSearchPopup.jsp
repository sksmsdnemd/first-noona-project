<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    	= loginInfo.SVCCOMMONID.rows.userId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var authRank	= loginInfo.SVCCOMMONID.rows.authRank;
	var dataArray 	= new Array();
	
	var cuMode;
	var recId;

	$(document).ready(function(param) {
		
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	    cudMode = sPopupOptions.cudMode;
	    recId   = sPopupOptions.recId;

		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
	});

	function fnSetSubCb(kind) {
		if (kind == "tenant") {
			if($('#s_FindTenantId option:selected').val() == ''){
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}else{
				argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId: $('#s_FindTenantId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			}
			fnGroupCbChange("s_FindGroupId");
		}
	}	
	
	function fnInitCtrl(){	
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		fnGroupCbChange("s_FindGroupId");
		
		if(grantId != "SuperAdmin" && grantId != "SystemAdmin"){
			$("#div_tenant").hide();
		}
		
		$("#s_FindTenantId").change(function(){
			fnSetSubCb('tenant');	 	
		});
		
		$("#s_FindGroupId").change(function(){
			fnSetSubCb('group');	 	
		});	
		
		$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
		
		$("#btnSearch").click(function(){
			fnSearchListCnt();			
		});

		$("#btnReset").click(function(){
			$("#s_FindTenantId").val(tenantId).attr("selected", "selected");
			argoCbCreate("s_FindGroupId", "comboBoxCode", "getGroupDepthList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
			fnGroupCbChange("s_FindGroupId");
			$('#s_FindRetireeFlag option[value="1"]').prop('selected', true);
			$("#s_FindUserNameText").val('');
		});
		
		$('.clickSearch').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
	}
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: false
	        },
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 			 	caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'userId', 	 		caption: '사용자ID', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'userName', 			caption: '사용자명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'groupId', 		    caption: '그룹', 			size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'groupName', 		    caption: '그룹', 			size: '13%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'grantName', 		 	caption: '권한', 			size: '11%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'retireeFlag', 	 	caption: '퇴직여부', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'retireeFlagName',  	caption: '퇴직여부', 		size: '7%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'accessFlag', 		caption: '접속권한', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'accessFlagName',		caption: '접속권한', 		size: '9%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'loginDate', 		 	caption: '접속시간', 		size: '19%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'loginIp', 	        caption: '로그인IP', 		size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userSelect', 	    caption: '선택', 			size: '6%', 	sortable: true, attr: 'align=center' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'retireeFlag', 'groupId', 'accessFlag'); 
	}
	
	function fnSearchListCnt(){

		argoJsonSearchOne('userInfo', 'getUserInfoCount', 's_', {authRank:authRank}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					$("#totCount").html(totalData);
					w2ui.grid.lock('조회중', true);
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow){
		argoJsonSearchList('userInfo', 'getUserInfoList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow, authRank:authRank}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					dataArray = [];
					if (data.getRows() != ""){ 
						
						var accessFlagName;
						var retireFlag;
						var btnHtml = "";
						var userId  = "";

						$.each(data.getRows(), function( index, row ) {

							if (row.accessFlag  == "0"){ 
								accessFlagName = "허용" 
							} else { 
								accessFlagName = "비허용";	
							}
							if (row.retireeFlag == "0"){ 
								retireFlag = "퇴직" 	
							} else { 
								retireFlag = "재직";			
							}
							
							userId   = "'" + row.userId + "'";
							userName = "'" + row.userName + "'";
							btnHtml  = '<a href="javascript:fnUserSelect(' + userId + ',' + userName + ');"><img src="../images/btn_choice.gif"></a>';
							
							gObject2 = {  
										  "recid" 			: index
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
										, "loginDate" 		: row.loginDate
										, "loginIp" 		: row.loginIp
										, "userSelect" 		: btnHtml
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
		});
	}
	
	function fnUserSelect(userId, userNm){

		var sOpener 	= window.frameElement.attributes["data-pid"].value ;
		var sOpenerType = window.frameElement.attributes["data-ptype"].value ;

		if(sOpenerType == "M" ) {
			parent.fnAppendOption(recId, userId, userNm);
		}else{
			parent.frames[sOpener].fnAppendOption(recId, userId, userNm);
		}
		argoPopupClose();
	}

</script>
</head>
<body>
	<div class="sub_wrap">
        <section class="sub_contents" style="width:860px;">
            <div class="search_area row2">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">태넌트</strong>
                            <select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>
							<input type="text"	id="s_FindTenantIdText" name="s_FindTenantIdText" style="width:150px; display:none" class="clickSearch"/>
							<input type="text"  id="s_FindSearchVisible" name="s_FindSearchVisible" style="display:none" value="1">
                        </li>
                    </ul>
                </div>
                <div class="row" id="div_user">
                    <ul class="search_terms">
                        <li style="width:280px">
                            <strong class="title ml20">그룹</strong>
                            <select id="s_FindGroupId" name="s_FindGroupId" style="width:150px" class="list_box"></select>
                        </li>
                        <li style="width:280px">
                            <strong class="title">퇴직여부</strong>
                            <select id="s_FindRetireeFlag" name="s_FindRetireeFlag" style="width:150px;" class="list_box">
                                <option value="">선택하세요!</option>
								<option value="1" selected>재직(아니요)</option>
								<option value="0">퇴직(예)</option>
                            </select>
                        </li>
                        <li style="width:280px">
                            <strong class="title" style="width:80px">사용자</strong>
                            <input type="text" 	id="s_FindUserNameText" name="s_FindUserNameText" style="width:150px" class="clickSearch"/>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
	            <div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width:860px; height: 415px;"></div>
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