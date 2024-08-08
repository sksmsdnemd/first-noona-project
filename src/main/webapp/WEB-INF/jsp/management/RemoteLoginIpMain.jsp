<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
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
<script src="<c:url value="/scripts/velocejs/convertListToTree.js"/>"></script>
<script src="<c:url value="/scripts/jstree3.3.3/dist/jstree.js"/>"></script>
<link rel="stylesheet"
href="<c:url value="/scripts/jstree3.3.3/dist/themes/default/style.css"/>"
	type="text/css" />
<style type="text/css">
.search_radio {
	background-color: initial;
    cursor: default;
    appearance: auto;
    box-sizing: border-box;
    margin: 3px 3px 3px 4px;
    padding: initial;
    border: initial;
}
</style>
<script>
	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId = loginInfo.SVCCOMMONID.rows.tenantId;
	var userId = loginInfo.SVCCOMMONID.rows.userId;
	var grantId = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu = "원격로그인IP 관리";
	var dataArray;
	var duplchkAt = false;
	var CodeAt = false;
	var deletePathAt = false;
	var overlapParentLevel = 0;

	$(document).ready(function(param) {
		try{
			ArgSetting();
			fnInitCtrl();
			fnSearchListCnt();
		}catch(e){
			console.log(e);
		}
	});

	function ArgSetting(){
		fnInitGrid();
	}
	
	function fnInitCtrl() {
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		$("#btnAdd").click(function (){
			gPopupOptions = {cudMode:'I'} ;
			argoPopupWindow('원격로그인IP 관리', 'RemoteLoginIpPopAddF.do', '460', '460');
		});
		
		$("#btnSearch").click(function(){
			fnSearchListCnt();
		});
		
		$("#btnDelete").click(function(){
			removeLoginIpDelete();
		});
	}

	function removeLoginIpDelete(){
		//12 ipSeq
		var records = w2ui['grid'].getSelection();
		if(records.length==0){
			argoAlert("IP대역을 선택해주세요.");
			return false;
		}
		
		for(var i=0;i<records.length;i++){
			var record = records[i];
			var pIpSeq = w2ui['grid'].getCellValue(record, 12)
			argoJsonUpdate("userInfo","removeLoginIpDelete", "ip_", {"ipSeq":pIpSeq} );
		}
		
		argoAlert("성공적으로 삭제되었습니다.");
		fnSearchListCnt();
	}

	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >=0 ) {
					gPopupOptions = {cudMode:'U', pRowIndex:record} ;
					argoPopupWindow('원격로그인IP 관리', 'RemoteLoginIpPopAddF.do', '460', '460');
				}
	        },
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'tenantName', 	caption: '태넌트', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'ipFlagName', 	caption: '범위', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'startIp', 		caption: '시작IP', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'endIp', 			caption: '범위IP', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'ipComments', 	caption: '설명', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'loginFlagName', 	caption: '로그인', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'useFlagName', 	caption: '상태', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		//hide_column
	            		,{ field: 'tenantId', 	caption: '테넌트ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'ipFlag', 	caption: 'IP범위', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'loginFlag', 	caption: '상태', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'useFlag', 	caption: '사용유무', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'ipSeq', 	caption: '시퀀스', 		size: '8%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid','tenantId','ipFlag','loginFlag','useFlag','ipSeq');
	}
	
	function fnSearchListCnt(){
		w2ui.grid.lock('조회중', true);

		argoJsonSearchOne('userInfo', 'getLoginIpListCnt', 's_', {} , function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1", "15", "3"); 
					
					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow){
		argoJsonSearchList('userInfo', 'getLoginIpList', 's_', {"iSPageNo":startRow,"iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();

					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							gObject2 = { 
										"recid" 			: index
					    				, "tenantName"		: row.tenantName
					   					, "ipFlagName"		: row.ipFlag == "0" ? "특정" : "범위"
										, "startIp" 		: row.startIp
										, "endIp" 			: row.endIp
										, "ipComments" 		: row.ipComments	    
										, "loginFlagName" 	: row.loginFlag == "0" ? "허용" : "금지"
										, "useFlagName" 	: row.useFlag == "0" ? "사용" : "미사용"
										, "tenantId" 		: row.tenantId	    
										, "ipFlag" 		: row.ipFlag	    
										, "loginFlag" 		: row.loginFlag	    
										, "useFlag" 		: row.useFlag
										, "ipSeq" 		: row.ipSeq	    
										};
							dataArray.push(gObject2);
						});
						
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
			} catch(e) {
				console.log(e);			
			}
		});
	}

</script>
</head>
<body>
	<div class="sub_wrap">
		<div class="location">
			<span class="location_home">HOME</span><span class="step">운용관리</span>
			<span class="step">사용자관리</span><strong class="step">그룹정보관리</strong>
		</div>
		<section class="sub_contents">
			<div class="search_area row2">
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">태넌트</strong>
							<select id="s_FindTenantId" name="s_FindTenantId" style="width: 150px" class="list_box"></select>							
						</li>
						<li>
							<strong class="title title_wide ml20">IP</strong>
							<input type="text" 	id="s_FindStartIp" name="s_FindStartIp" style="width:150px" class="clickSearch"/>&nbsp;&nbsp;~&nbsp;&nbsp;
							<input type="text" 	id="s_FindEndIp" name="s_FindEndIp" style="width:150px" class="clickSearch"/>
						</li>
					</ul>
				</div>
				<div class="row">
					<ul class="search_terms">
						<li><strong class="title_wide ml20">범위</strong>
							<select id="s_FindIpFlag" name="s_FindIpFlag" style="width: 150px" class="list_box">
								<option value="">선택해주세요.</option>
								<option value="0">특정</option>
								<option value="1">범위</option>
							</select>
						</li>
						<li><strong class="title_wide ml20">로그인</strong>
							<select id="s_FindLoginFlag" name="s_FindLoginFlag" style="width: 150px" class="list_box">
								<option value="">선택해주세요.</option>
								<option value="0">허용</option>
								<option value="1">금지</option>
							</select>
						</li>
						<li><strong class="title_wide ml20">상태</strong>
							<select id="s_FindUseFlag" name="s_FindUseFlag" style="width: 150px" class="list_box">
								<option value="">선택해주세요.</option>
								<option value="0">사용</option>
								<option value="1">미사용</option>
							</select>
						</li>
					</ul>
				</div>
			</div>
			<div class="btns_top">
				<button type="button" id="btnSearch" class="btn_m search">조회</button>
				<button type="button" id="btnAdd" class="btn_m confirm" onclick="">등록</button>
				<button type="button" id="btnDelete" class="btn_m confirm" onclick="">삭제</button>
			</div>
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
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
