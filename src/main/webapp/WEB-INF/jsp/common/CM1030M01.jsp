<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
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
var workMenu 	= "파일관리";
var workLog 	= "";
var dataArray 	= new Array();

var fvKeyId ; 

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
	
	argoSetDeptChoice("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); //조직선택 팝업 연결처리(멀티)
	argoSetUserChoice01("btn_User1", {"targetObj":"s_User1", "multiYn":'Y'}); //상담사선택 팝업 연결처리(멀티)
	argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	argoSetDateTerm('selDateTerm1',{"targetObj":"s_txtDate1","selectValue":"M_1"});// 당일이 기본 선택이나 이를 변경하고자 할 경우

	$("#btnSearch").click(function(){
		fnSearchList();		
	});
  
	$("#btnAdd").click(function(){
		gPopupOptions = {"pNotiId":""} ;   	
		argoPopupWindow('파일업로드', 'CM1030S02F.do',  '1066', '300');
	});
	
	$("#btnFilePathSet").click(function(){
		argoPopupWindow('파일경로 설정', 'CM1030S03F.do',  '500', '200');
	});
	
	$("#btnDel").click(function(){		
		fnDelete();
	});	
	
	
	$("#btnHandDownload").click(function(){		
		argoPopupWindow('수동 다운로드', 'CM1030S04F.do',  '500', '200');
	});	
	
	
	$("#s_Subject").keydown(function(key){		
		if(key.keyCode == 13){
			fnSearchList();
		}
	});
}

function fnInitGrid(){

	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        onDblClick: function(event) {
        	var record = this.get(event.recid);
        	if(record.recid >=0 ) {
        		fvKeyId = record.notiId; // 선택한 로우의 키값 저장
        		gPopupOptions = {"pNotiId":fvKeyId} ;        	    	
        		argoPopupWindow('파일 다운로드', 'CM1030S01F.do',  '1066', '300' );
			}
        },
        columns: [  
			 	 { field: 'recid', 				caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'notiId', 	 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'notiNo', 	 		caption: '번호', 			size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'notiGubunNm', 		caption: '구분', 			size: '5%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'notiGradeNm', 		caption: '등급', 			size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'notiTitle', 			caption: '제목', 			size: '60%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'notiScope', 			caption: '범위', 			size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'attachFileCnt', 		caption: '첨부파일수', 	size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'attachFile', 		caption: '첨부파일', 		size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'noticePeriod', 		caption: '공지기간', 		size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'createDt', 			caption: '등록일자', 		size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'readCnt', 	    	caption: '조회수', 		size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'createAgentInfo', 	caption: '작성자', 		size: '5%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('notiId' );
	w2ui['grid'].hideColumn('notiNo' );
	w2ui['grid'].hideColumn('notiGubunNm' );
	w2ui['grid'].hideColumn('notiGradeNm' );
	w2ui['grid'].hideColumn('notiScope' );
	w2ui['grid'].hideColumn('attachFile' );
	w2ui['grid'].hideColumn('noticePeriod' );
}

//-------------------------------------------------------------
//선택건의 파일목록 조회
//-------------------------------------------------------------
var fvIndex = 0;

function fnCallbackGetFileList(data, textStatus, jqXHR){
	try{
		if(data.isOk()){
			fvIndex = fvIndex + 1;
			var itemArray = new Array();
			var sPopMenu = "fileDown_"+fvKeyId+fvIndex ;
		
			$.each(data.getRows(), function( index, row ) {
				var obj = new Object();
				obj.label     = row.userfileNm  ;
				obj.tag = row.filePath;
			
				itemArray.push(obj);
			});
			gridView.addPopupMenu(sPopMenu, itemArray);

			gridView.setColumnProperty("attachFileCnt", "popupMenu", sPopMenu);

		}
	} catch(e) {
		console.log(e) ;
	}
}  

//-------------------------------------------------------------
//목록조회
//-------------------------------------------------------------
function fnSearchList(){	
	//var param = {}; 
	//gridView.setAllCheck(false); // 그리드 헤더 체크  - unchecked 상태로

	//argoGrSearch 내에서 필드오브젝트 자동 생성 처리  및 dataProvider 에 조회결과  바인딩 처리
  	//argoGrSearch("dataProvider", "CM", "SP_CM1030M01_01", "s_", param);
	argoJsonSearchList('CM', 'SP_CM1030M01_01', 's_', {}, function (data, textStatus, jqXHR){
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
								"recid" 				: index
								, "notiId"			: row.notiId
								, "notiNo"			: row.notiNo
			   					, "sheetNm"	  		: row.sheetNm
								, "notiGubunNm" 	: row.notiGubunNm
								, "notiGradeNm"	  	: row.notiGradeNm
								, "notiTitle" 		: row.notiTitle
								, "notiScope" 		: row.notiScope
								, "attachFileCnt"	: row.attachFileCnt
								, "attachFile"		: row.attachFile
								, "noticePeriod"	: row.noticePeriod
								, "createDt"		: row.createDt
								, "readCnt" 		: row.readCnt										
								, "createAgentInfo" : row.createAgentInfo										
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

//-------------------------------------------------------------
//삭제
//-------------------------------------------------------------
var fvDelFileLIst = new Array(); // 삭제처리 대상 목록
function fnDelete(){	
	try{

		var arrChecked = w2ui.grid.getSelection();

		if(arrChecked.length==0) {
			argoAlert("삭제할 대상을 선택하세요") ;
			return ;
		}

		argoConfirm("공지사항에 등록된  공지범위 및 첨부파일도 함께 삭제됩니다.<br>삭제하시겠습니까?", function() {
			var multiService = new argoMultiService(fnCallbackDelete);
			var arrChecked = w2ui.grid.getSelection();

			$.each(arrChecked, function( index, value ) {
				var sNotiId 	= w2ui.grid.get(value).notiId;
				var sAttachFile = w2ui.grid.get(value).attachFile;
				multiService.argoDelete("CM","SP_CM1030M01_03","__", {"notiId":sNotiId});		
				fvDelFileLIst.push(sAttachFile) ; //파일삭제처리를 위해 파일목록 저장
			});

			multiService.action();
		});
	} catch(e) {
		console.log(e) ;
	}
}

function fnCallbackDelete(Resultdata, textStatus, jqXHR){
	try{
		if(Resultdata.isOk()) {	  
			// 파일 삭제처리
			var fvGlobalPath = "/";
			argoJsonSearchList('ARGOCOMMON', 'searchGlobalFilePath', '_', {}, function (data, textStatus, jqXHR){
				try{
					if(data.isOk()){
						var dataRow = data.getRows()[0];
						fvGlobalPath = dataRow.globalFilePath;
						argoFileDelete(fvDelFileLIst.join(','), fvGlobalPath); 
						argoAlert('성공적으로 삭제 되었습니다.') ;	
						fnSearchList();
					} 
				}catch (e) {
					console.log(e);
				}
			});
		}
	} catch(e) {
		argoAlert(e);    		
	}
}	



</script>


</head>

<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><strong class="step">파일관리</strong></div>
        <section class="sub_contents">
            <div class="search_area">
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">등록일자</strong>
                            <select id="selDateTerm1" name="" style="width:86px;" class="mr5">
                            </select>
                            <span class="select_date"><input type="text" id="s_txtDate1_From" name="s_txtDate1_From"  class="datepicker onlyDate"></span>
                            <span class="text_divide">~</span>
                            <span class="select_date"><input type="text" id="s_txtDate1_To" name="s_txtDate1_To"  class="datepicker onlyDate"></span>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">제목/내용</strong>
                            <input type="text" id="s_Subject" name="s_Subject" style="width:200px;">
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
	            <div class="btns_tl">
                	<button type="button" class="btn_m" id="btnFilePathSet" >파일경로 설정</button>
				</div>
				
            	<button type="button" id="btnSearch" name="btnSearch" class="btn_m search" data-grant="R">조회</button> 
            	<button type="button" id="btnAdd" name="btnAdd" class="btn_m" data-grant="W">추가</button>
            	<button type="button" id="btnDel" name="btnDel" class="btn_m" data-grant="W">삭제</button> 
            	<button type="button" id="btnHandDownload" name="btnHandDownload" class="btn_m" data-grant="W">수동다운로드</button>
            </div>
            <div class="h136">
                <div class="btn_topArea fix_h25"></div>
                <div class="grid_area h25 pt0">
                    <div id="grList" class="real_grid"></div>
                </div>
            </div>

        </section>
            

    </div>
    <!-- 파일다운로드 처리를 위한 iframe 삽입 -->
    <iframe id="fileDown" style='display:none' src="" width="0" height="0"></iframe>
    
</body>

</html>
