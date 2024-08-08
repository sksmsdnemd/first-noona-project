<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String recTableType = Globals.REC_TABLE_TYPE(); 
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>

<style type="text/css">
	.ui-autocomplete
	{
		max-height: 100px;
		overflow-y: auto; /* prevent horizontal scrollbar */
		overflow-x: hidden;
	}
	html .ui-autocomplete
	{
		height: 100px;
	}

</style>

<script type="text/javascript">
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var userName    = loginInfo.SVCCOMMONID.rows.userName;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;
var workMenu 	= "파일변조내역조회";
var workLog 	= "";
var dataArray 	= new Array();
var gPopupOptions;
var procType="";
$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchList();
});

function fnInitCtrl(){
	argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
		"selectIndex" : 0,
		"text" : '선택하세요!',
		"value" : ''
	});
	
	argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	argoSetDateTerm('selDateTerm1',{"targetObj":"s_txtDate1" , "selectValue":"M_1"});// 기간선택 콤보 설정
	argoSetUserChoice01("btn_User1", {"targetObj" : "s_User1","multiYn" : 'Y', "findTenantId" : argoGetValue("s_FindTenantId")}); //상담사선택 팝업 연결처리(멀티)
	
	$("#btn_Search").click(function(){
		fnSearchList();
	});
	
	$('#s_FindUserNameText').keyup(function(event) {
	    if (event.which === 13) { // Enter 키의 keyCode는 13입니다.
	    	fnSearchList();
	    }
	});
	
	$('#s_CallId').keyup(function(event) {
	    if (event.which === 13) { // Enter 키의 keyCode는 13입니다.
	    	fnSearchList();
	    }
	});
	
	$('#s_FileNm').keyup(function(event) {
	    if (event.which === 13) { // Enter 키의 keyCode는 13입니다.
	    	fnSearchList();
	    }
	});
	
	$('#s_FileHash').keyup(function(event) {
	    if (event.which === 13) { // Enter 키의 keyCode는 13입니다.
	    	fnSearchList();
	    }
	});
	
	
	//[input]사용자 자동검색 - start
	var dataList = "";
	var authRank = loginInfo.SVCCOMMONID.rows.authRank;
	$('#s_FindUserNameText').autocomplete({
		source : function(request, response){
			argoJsonSearchList('recSearch', 'getRecUserInfo', '',{"tenantId":argoGetValue("s_FindTenantId"), "authRank":authRank, "srchKeyword":$('#s_FindUserNameText').val()}, function(data, textStatus, jqXHR){
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
	});
	//[input]사용자 자동검색 - end
	
	if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
		$("#div_tenant").hide();
	}
	argoSetValue("s_FindTenantId", tenantId);
}

function fnInitGrid(){
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false
            //selectColumn: true
        },
        //multiSelect: true,
        columns: [
			 	 { field: 'recid', 				caption: '', 				size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'reckey', 			caption: '', 				size: '0%',  	sortable: true, attr: 'align=center' }
			 	,{ field: 'tenantName', 	 	caption: '태넌트', 			size: '8%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'downloadDate', 		caption: '다운로드 일시', 		size: '10%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'downloadUserInfo', 	caption: '다운로드 유저정보', 	size: '10%',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'callId', 			caption: '콜ID', 			size: '25%',  	sortable: true, attr: 'align=left' }
		       	,{ field: 'fileName', 			caption: '파일명', 			size: '24%',  	sortable: true, attr: 'align=left' }
		       	,{ field: 'hashValue', 			caption: '해시값', 			size: '23%',  	sortable: true, attr: 'align=left' }
       	],
        records: dataArray
    });
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('reckey' );
	
}


function fnSearchList(){
	
	argoJsonSearchList('recSearchHash', 'getRecFileHashList', 's_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				if(data.getProcCnt() == 0){
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {
										"recid" 			: index
					    				, "reckey"			: row.reckey
					   					, "tenantName"	  	: row.tenantName
					   					, "downloadDate"	: row.downloadDate
										, "downloadUserInfo": row.downloadUserInfo
										, "callId"	  		: row.callId
										, "fileName" 		: row.fileName
										, "hashValue" 		: row.hashValue
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
</script>
</head>
<body>
		<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역조회</span><strong
				class="step">녹취파일 다운로드 이력조회</strong>
		</div>
        <section class="sub_contents">
            <div class="search_area row2">
            	<div class="row">
                    <ul class="search_terms">
                        <li id="div_tenant">
                        	<strong class="title ml20">태넌트</strong>
                        	<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select>
                        </li>
                        <li>
                           <strong class="title ml20">다운로드 일자</strong>
                           <select id="selDateTerm1" name="" style="width:70px;" class="mr5"></select>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                           <span class="text_divide">~</span>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To"  name="s_txtDate1_To"></span>
                        </li>
                        <li>
							<strong class="title ml20" >다운로드 유저정보</strong>
							<input type="text" id="s_FindUserNameText" name="s_FindUserNameText" style="width: 140px" class="clickSearch" />
						</li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
						<li>
							<strong class="title ml20" >콜ID</strong>
							<input type="text" id="s_CallId" name="s_CallId" style="width: 140px" />
						</li>
						<li>
							<strong class="title ml20" >파일명</strong>
							<input type="text" id="s_FileNm" name="s_FileNm" style="width: 140px" />
						</li>
						<li>
							<strong class="title ml20" >해시값</strong>
							<input type="text" id="s_FileHash" name="s_FileHash" style="width: 140px" />
						</li>
                    </ul>
                </div>   
            </div>   
            <div class="btns_top">
                <button type="button" class="btn_m search" id="btn_Search" data-grant="R">조회</button>
            </div>        
            <div id="hashHelpDiv" style="width: 100%;height: 112px;background-color: black;z-index: 9999;/* position: absolute; */top: 55px;left: 729.562px;/* border-radius: 14px; */">
				<p style="color: white; font-size: 12pt; font-weight: bold; padding-top:8px;">※ 해시값 추출 가이드</p><br>
				<p style="color: white;">1.명령 프롬프트(CMD) 실행</p><br>
				<p style="color: white;">2.명령어 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: Certutil -hashfile "C:\test.mp3" MD5</p><br>
				<p style="color: white;">3.명령어결과 : MD5의 C:\test.mp3 해시 : 59695c093f26303e1fc05530d7603361</p>
			</div>
            <div class="h228">
                <div class="btn_topArea fix_h25"></div>
                <div class="grid_area h25 pt0">
                    <div id="grList" class="real_grid"></div>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>