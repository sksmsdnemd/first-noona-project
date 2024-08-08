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
var workMenu 	= "배치결과조회";
var workLog 	= "";
var dataArray 	= new Array();

$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchListCnt();
});

function fnInitCtrl(){
	argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	argoSetDateTerm('selDateTerm1',{"targetObj":"s_txtDate1" , "selectValue":"T_0"});// 기간선택 콤보 설정
	var today = argoSetFormat(argoCurrentDateToStr(),"-","4-2-2")
	
	/* 테넌트 콤보박스  */
	argoCbCreate("s_TenantId", "ARGOCOMMON", "tenant", {},{"selectIndex":0, "text":'<전체>', "value":''});
	
	$("#btn_Search").click(function(){
		fnSearchListCnt();		
	});
}

function fnSearchList(startRow, endRow){
	//argoGrSearch("dataProvider", "MNG", "SP_MNG1030M01_02", "s_", {workResult : $("input:radio[name='s_WorkResult']:checked").val(), startRow: startRow ,endRow: endRow});
	
	
	argoJsonSearchList('MNG', 'SP_MNG1030M01_02', 's_', {workResult : $("input:radio[name='s_WorkResult']:checked").val(), startRow: startRow ,endRow: endRow}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				
				if(data.getProcCnt() == 0){
					argoAlert('조회 결과가 없습니다.');
					gSheetId = "";
					gValueYn = "";
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 				: index
				    				, "tenantId"			: row.tenantId
				   					, "workNm"	  			: row.workNm
									, "schId" 				: row.schId
									, "workResult"	  		: row.workResult
									, "workDateStrDt" 		: row.workDateStrDt
									, "workDateEndDt" 		: row.workDateEndDt
									, "workTm"				: row.workTm
									, "bigo"				: row.bigo
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

var gridView; // 그리드 오브젝트
var dataProvider; // 그리드용 데이터 오브젝트	
function fnInitGrid(){
	
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: false
        },
        multiSelect: false,
        columns: [  
			 	 { field: 'recid', 				caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'tenantId', 	 		caption: '태넌트', 		size: '8%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workNm', 			caption: '배치작업명', 	size: '20%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'schId', 				caption: '실행ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workResult', 		caption: '처리상태', 		size: '5%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workDateStrDt', 		caption: '시작일시', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workDateEndDt', 		caption: '종료일시', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'workTm', 			caption: '소요시간', 		size: '7%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'bigo', 	    		caption: '로그', 			size: '32%', 	sortable: true, attr: 'align=left' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
}

var dataPerPage=15; 
var pageCount=5;
function paging(totalData, dataPerPage, pageCount, currentPage){

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
	if(last%pageCount==0){
		first =last - (pageCount-1);
	}else{
		first = last - ((last%pageCount)-1);
	}
	prev = first-1;
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
  
   if(totalData!=0){
	  fnSearchList(startRow,endRow);
   }
   
   if(defaultYn=='N'){
	   $("#paging a").click(function(){
	       
	       var $item = $(this);
	       var $id = $item.attr("id");
	       var selectedPage = $item.text();
	       
	       if($id == "next")    selectedPage = next;
	       if($id == "prev")    selectedPage = prev;
	       if($id == "first")    selectedPage = 1;
	       if($id == "last")	 selectedPage = totalPage;
	       paging(totalData, dataPerPage, pageCount, selectedPage);
	   });
   }

}

function fnSearchListCnt(){
		argoJsonSearchOne('MNG', 'SP_MNG1030M01_01', 's_', {workResult : $("input:radio[name='s_WorkResult']:checked").val()}, function(data, textStatus, jqXHR) {
			try {
				if (data.isOk()) {
					var totalData=data.getRows()['cnt'];
					paging(totalData, dataPerPage, pageCount, "1")
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">관리자(MNG)</span><strong class="step">배치결과</strong></div>
        <section class="sub_contents">
            <div class="search_area fix_h54" >
            	 	<div class="row">
                    <ul class="search_terms">
                        <li>
                           <strong class="title">배치일자</strong>
                           <select id="selDateTerm1" name="" style="width:70px;" class="mr5"></select>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                           <span class="text_divide">~</span>
                           <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To"  name="s_txtDate1_To"></span>
                        </li>
						<li>
                        	<strong class="title">테넌트</strong>
                        	<select id="s_TenantId" name="s_TenantId" style="width:150px;">
                           		<option>전체</option>
                            </select>
                        </li>
                		<li>
	                        <span class="checks ml20"><input type="radio" id="s_WorkResultA" name="s_WorkResult" checked value=""><label for="s_WorkResultA">전체</label></span>
                            <span class="checks ml15"><input type="radio" id="s_WorkResultS" name="s_WorkResult" value="S"><label for="s_WorkResultS">성공</label></span>
                            <span class="checks ml15"><input type="radio" id="s_WorkResultF" name="s_WorkResult" value="F"><label for="s_WorkResultF">실패</label></span>
                		</li>
                		<li>
                			<strong class="title">작업명</strong>
                			<input type="text" id="s_WorkNm" name="s_WorkNm">
                		</li>
                    </ul>
                </div>
            </div>   
            <div class="btns_top">
                <button type="button" class="btn_m search" id="btn_Search">조회</button>
            </div>        
            <div style="height: calc(100% - 143px);">
                <div class="btn_topArea fix_h25"></div>
                <div class="grid_area h25 pt0">
                    <div id="grList" class="real_grid"></div>
                </div>
                <div class="list_paging" id="paging">
					<ul class="paging">
						<li><a href="#" id='' class="on">1</a></li>
					</ul>
				</div>
            </div>            
        </section>
    </div>
</body>
</html>