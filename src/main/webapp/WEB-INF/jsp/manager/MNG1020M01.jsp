<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 

<script>
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "배치실행관리";
var workLog 	= "";
var dataArray 	= new Array();


//-------------------------------------------------------------
//페이지 초기설정
//-------------------------------------------------------------   
$(document).ready( function() {
	fnInitCtrl();
    fnInitGrid(); 
    fnSearchList();
});


//-------------------------------------------------------------
//화면 공통 스크립트 호출 및 이벤트 처리
//-------------------------------------------------------------
function fnInitCtrl(){

	/* 테넌트 콤보박스  */
	argoCbCreate("s_TenantId", "ARGOCOMMON", "tenant", {},{"selectIndex":0, "text":'<전체>', "value":''});
	
	/* 버튼 클릭 이벤트  */
	$("#btnSearch").click(function(){ // 조회
		fnSearchList();		
	});
	
	$("#btnAdd").click(function(){ // 추가
		gPopupOptions = {};
		argoPopupWindow('배치작업 등록', 'MNG1020S01F.do',  '600', '689');
	});
	
	$("#btnDel").click(function(){
		fnDel();
	});
	
	$("#btnUse").click(function(){ // 사용
		fnUse(0);
	});
	
	$("#btnUnuse").click(function(){ // 미사용
		fnUse(1);
	});
	
	$("#s_WorkNm").keydown(function(e){
		if (e.ctrlKey && e.keyCode == 110) {
		    parent.$("#MNG1050").trigger('click');
		}
		if(e.keyCode == 13){
			fnSearchList();
		}
	})
}

//-------------------------------------------------------------
// 그리드 초기설정
//-------------------------------------------------------------
function fnInitGrid(){
	$('#grList1').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        onDblClick: function(event) {
        	var record = this.get(event.recid);
        },
        onClick: function (event) {
        	var record = this.get(event.recid);
        	var key = Object.keys(record);
        	if(key[event.column] == "view"){
       			gPopupOptions = record;
       			argoPopupWindow( record.workNm + " 상세보기", 'MNG1020S01F.do',  '600', '720' ); 
        	}
        },
        onChange: function (event) {
        	var record = this.get(event.recid);
        	var key = Object.keys(record);
        	if(key[event.column] == "hideYn"){
        		event.preventDefault();
        	}
        }, 
        columns: [  
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'tenantId', 	 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'tenantNm', 	 	caption: '태넌트', 		size: '8%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workId', 		caption: '작업ID', 		size: '6%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workNm', 		caption: '작업명', 		size: '30%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'workGubun', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workGubunNm', 	caption: '작업구분', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'sourceTyp', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'jdbcDriver', 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'jdbcUrl', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'userId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'userPw', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'selQuery', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'filePath', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'fileName', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'useChk', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'fileEncode', 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'fileDelimiter', 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'preExeQeury', 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'exeQuery', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'nextExeQuery', 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'hideYn', 		caption: '사용여부', 	size: '7%', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center' }
       	 		,{ field: 'retryCnt', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'fileDays', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'scheId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'scheNm', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'strDt', 			caption: '시작일자', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'strTm', 	    	caption: '시작시간', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'endDt', 	    	caption: '종료일자', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'endTm', 	    	caption: '종료시간', 	size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'repCycle', 	    caption: '반복주기(분)', size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'systemGubun', 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       			,{ field: 'view', 	    	caption: '상세보기', 	size: '6%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid');
	w2ui['grid'].hideColumn('tenantId');
	w2ui['grid'].hideColumn('workGubun');
	w2ui['grid'].hideColumn('sourceTyp');
	w2ui['grid'].hideColumn('jdbcDriver');
	w2ui['grid'].hideColumn('jdbcUrl');
	w2ui['grid'].hideColumn('userId');
	w2ui['grid'].hideColumn('userPw');
	w2ui['grid'].hideColumn('selQuery');
	w2ui['grid'].hideColumn('filePath');
	w2ui['grid'].hideColumn('fileName');
	w2ui['grid'].hideColumn('useChk');
	w2ui['grid'].hideColumn('fileEncode');
	w2ui['grid'].hideColumn('fileDelimiter');
	w2ui['grid'].hideColumn('preExeQeury');
	w2ui['grid'].hideColumn('exeQuery');
	w2ui['grid'].hideColumn('nextExeQuery');
	w2ui['grid'].hideColumn('retryCnt');
	w2ui['grid'].hideColumn('fileDays');
	w2ui['grid'].hideColumn('scheId');
	w2ui['grid'].hideColumn('scheNm');
	w2ui['grid'].hideColumn('systemGubun');
	
	
}
  
/* 목록 조회  */
function fnSearchList(){
	//gridView1.setAllCheck(false); // 그리드 헤더 체크  - unchecked 상태로
	//argoGrSearch("dataProvider1", "MNG", "SP_MNG1020M01_01", "s_", {hideYn : $("input:radio[name='s_Hide']:checked").val(), systemGubun:$("input:radio[name='s_SystemGubun']:checked").val()});
	argoJsonSearchList('MNG', 'SP_MNG1020M01_01', 's_', {hideYn : $("input:radio[name='s_Hide']:checked").val()}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				if(data.getProcCnt() == 0){
					argoAlert('조회 결과가 없습니다.');
					return;
				}
				dataArray = [];
				
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
									, "tenantId"		: row.tenantId
									, "tenantNm"		: row.tenantNm
									, "workId"			: row.workId
									, "workNm"			: row.workNm
									, "workGubun"		: row.workGubun
									, "workGubunNm"		: row.workGubunNm
									, "sourceTyp"		: row.sourceTyp
									, "jdbcDriver"		: row.jdbcDriver
									, "jdbcUrl"			: row.jdbcUrl
									, "userId"			: row.userId
									, "userPw"			: row.userPw
									, "selQuery"		: row.selQuery
									, "filePath"		: row.filePath
									, "fileName"		: row.fileName
									, "useChk"			: row.useChk
									, "fileEncode"		: row.fileEncode
									, "fileDelimiter"	: row.fileDelimiter
									, "preExeQeury"		: row.preExeQeury
									, "exeQuery"		: row.exeQuery
									, "nextExeQuery"	: row.nextExeQuery
									, "hideYn" 			: row.hideYn==0?true:false
									, "retryCnt"		: row.retryCnt
									, "fileDays"		: row.fileDays
									, "scheId"			: row.scheId
									, "scheNm"			: row.scheNm
									, "strDt"			: row.strDt
									, "strTm"			: row.strTm
									, "endDt"			: row.endDt
									, "endTm"			: row.endTm
									, "repCycle"		: row.repCycle
									, "systemGubun"		: row.systemGubun
									, "view" 			: '<img src="../images/bg_approval.png" style="width:20px; height:20px; cursor:pointer;"></img>'
						};
						dataArray.push(gObject2);
					});
					w2ui['grid'].add(dataArray);
				}
				if(w2ui['grid'].getSelection().length == 0){
					w2ui['grid'].click(0,0);
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

/* 삭제  */
function fnDel(){
	try{
		var arrChecked = w2ui['grid'].getSelection();
		if(arrChecked.length==0) {
			argoAlert("대상을 선택하세요.") ; 
			return ;
		}
		var multiService = new argoMultiService(fnCallbackDel);
		argoConfirm('선택한 ' + arrChecked.length + '건을 삭제 하시겠습니까?', function(){
			$.each(arrChecked, function( index, value ) {
				var param = { tenantId : w2ui['grid'].get(value).tenantId
	  				    , workId   : w2ui['grid'].get(value).workId
	  				    , scheId   : w2ui['grid'].get(value).scheId
	  					};
				multiService.argoDelete("MNG", "SP_MNG1020M01_03", "__", param);
			});
			multiService.action();
	 	});
	} catch(e) {
		console.log(e);
	}
}

/* 삭제 후 처리  */
function fnCallbackDel(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('warning', '성공적으로 삭제 되었습니다.', '', 'fnSearchList();');
	    }
	} catch(e) {
		console.log(e);    		
	}
}

/* 사용여부 변경  */
function fnUse(hideYn){
	try{
		var arrChecked = w2ui['grid'].getSelection();
		if(arrChecked.length==0) {
			argoAlert("대상을 선택하세요.") ; 
			return ;
		}
		
		var multiService = new argoMultiService(fnCallbackUse);
		var uMsg = '';
		if(hideYn == 0) uMsg = '선택한 ' + arrChecked.length + '건을 사용 하시겠습니까?';
		if(hideYn == 1) uMsg = '선택한 ' + arrChecked.length + '건을 미사용 하시겠습니까?';
		argoConfirm(uMsg, function(){
			$.each(arrChecked, function( index, value ) {
		  		var param = { tenantId : w2ui['grid'].get(value).tenantId
		  				    , workId   : w2ui['grid'].get(value).workId
		  				    , scheId   : w2ui['grid'].get(value).scheId
		  				    , hideYn   : hideYn
		  				};
		  		multiService.argoUpdate("MNG", "SP_MNG1020M01_02", "__", param);
			});
	  		
	  		multiService.action();
	  		
		});
				  		
	} catch(e) {
		console.log(e);
	}
}

/* 사용여부 변경 후 처리  */
function fnCallbackUse(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('warning', '성공적으로 저장 되었습니다.','', 'fnSearchList();');
	    }
	} catch(e) {
		console.log(e);    		
	}
}
</script>

</head>

<body>
	<div class="sub_wrap">
		<div class="location"><span class="location_home">HOME</span><span class="step">관리자(MNG)</span><strong class="step">배치작업</strong></div>
		<section class="sub_contents">
			<div class="search_area">
				<div class="row">
					<ul class="search_terms">
						<li>
                        	<strong class="title ml20">테넌트</strong>
                        	<select id="s_TenantId" name="s_TenantId" style="width:150px;">
                           		<option>전체</option>
                            </select>
                        </li>
						<li>
                        	<strong class="title ml20">작업구분</strong>
                        	<select id="s_WorkGubun" name="s_WorkGubun" style="width:150px;">
                           		<option value=''><전체></option>
                           		<option value='IN'>수신</option>
                           		<option value='OUT'>송신</option>
                           		<option value='EXE_SP'>쿼리실행</option>
                            </select>
                        </li>
						<li>
                        	<strong class="title ml20">작업명</strong>
                        	<input type="text" id=s_WorkNm name="s_WorkNm" style="width:320px;">
                        </li>                        
                    </ul>
                </div>
                <div class="row">
                	<ul class="search_terms">
                		<li>
                        	<strong class="title ml20">사용여부</strong>
	                        <span class="checks ml20"><input type="radio" id="s_HideA" name="s_Hide" checked value=""><label for="s_HideA">전체</label></span>
                            <span class="checks ml15"><input type="radio" id="s_HideN" name="s_Hide" value="0"><label for="s_HideN">사용</label></span>
                            <span class="checks ml15"><input type="radio" id="s_HideY" name="s_Hide" value="1"><label for="s_HideY">미사용</label></span>
                		</li>
                	</ul>
                </div>
            </div>
            <div class="btns_top">
          		<button type="button" id="btnSearch" name="btnSearch" class="btn_m search" data-grant="R">조회</button>
          		<button type="button" id="btnAdd"  name="btnAdd" class="btn_m" data-grant="W">신규등록</button>
          		<button type="button" id="btnDel"  name="btnDel" class="btn_m" data-grant="W">삭제</button>
          		<button type="button" id="btnUse"  name="btnUse" class="btn_m" data-grant="W">사용</button>
          		<button type="button" id="btnUnuse"  name="btnUnuse" class="btn_m" data-grant="W">미사용</button>
<!--           		<button type="button" id="btnBatch"  name="btnBatch" class="btn_m confirm" data-grant="W">수동실행</button>  -->
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
				<div class="grid_area h25 pt0">
                    <div id="grList1" class="real_grid"></div>
                </div>
            </div>
        </section>
    </div>
</body>
</html>