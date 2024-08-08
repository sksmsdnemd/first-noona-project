<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script>
//공통 변수 세팅
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가표관리";
var workLog 	= "";
var dataArray 	= new Array();

$(document).ready( function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchList01();
});

var gSheetId = "";
var gValueYn = "";

function fnInitCtrl(){		
	argoSetUserChoice01("btn_User1", {"targetObj":"s_User1", "multiYn":'Y'}); //상담사선택 팝업 연결처리(멀티)
	$('#s_SheetNm').keyup(function(event) {
	    if (event.which === 13) { // Enter 키의 keyCode는 13입니다.
			fnSearchList01();
	    }
	});
	
	$(".count_num").countNum({
		max:2100,
		min:2000,
		set_num:argoSetFormat(argoCurrentDateToStr(),"-","4")
	});

	$("#btnSearch").click(function(){
		fnSearchList01();		
	});
	
	$("#btnCopy").click(function(){
		fnCopy();	
	});
	
	$("#btnSheetItem").click(function(){
		argoPopupWindow( '평가항목관리', 'QA1020S04F.do',  '1000', '500' ); 
	});
	$("#btnAdd1").click(function(){		
		gPopupOptions = {"cudGubun":"I"} ;   	
		argoPopupWindow( '평가표등록', 'QA1020S01F.do',  '675', '225' ); 
	});
	$("#btnAdd2").click(function(){
		if(gSheetId == ''){
			argoAlert("선택된 평가표가 없습니다");
			return;
		}else{
			gPopupOptions2 = {"cudGubun":"I", "sheetId":gSheetId, "valueYn":gValueYn, "insYn":true};
			argoPopupWindow( '평가항목편집', 'QA1020S02F.do',  '900', '652' ); 	
		}
	});
	
	$("#btnDel1").click(function(){		
		fnDelete1();
	});	
	
	$("#btnSorting").click(function(){
		if(gSheetId == ''){
			argoAlert("선택된 평가표가 없습니다");
			return;
		}
		gPopupOptions = {"pSheetId" : gSheetId};
		argoPopupWindow( '순서변경', 'QA1020S07F.do',  '575', '475' );
	});
	
	$("#btnExcel").click(function(){
		var excelArray = new Array();
		argoJsonSearchList('QA','SP_QA1020M01_02','s_', {"sheetId":gSheetId}, function (data, textStatus, jqXHR){
			try {
				if (data.isOk()) {
					$.each(data.getRows(), function( index, row ) {
						gObject = {  "순번" 			: index
				   					, "대분류명"	  	: row.majorNm
									, "소분류명"		: row.minorNm
									, "구분" 			: row.qaSebuNm
									, "평가내용"		: row.sheetText
									, "배점"			: row.score
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
	fnSetQaSebuCd(); 
}


function fnInitGrid(){
	$('#grList01').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        onAdd: function(target, eventData){
            this.add({
                  recid: this.total + 1
                , sheetNm: '[입력]'					
            })
        },
        onDblClick: function(event) {
        	var record = this.get(event.recid);
        	if(record.recid >=0 ) {
        		gPopupOptions = {
       				cudGubun:'U', 
       				sheetId		:record.sheetId,
       				sheetNm		:record.sheetNm,
       				hideYn 		:record.hideYn==true?0:1,
       				sheetType 	:record.sheetType,
       				dept1Nm		:record.dept1Nm,
       				dept1Id		:record.dept1Id,
       				valueYn 	:record.valueYn==true?"Y":"N"
        		};
				argoPopupWindow( '평가표관리', 'QA1020S01F.do',  '675', '225' );
			}
        },
        onClick: function(event) {
        	var record = this.get(event.recid);
        	gSheetId = record.sheetId;
        	gValueYn = record.valueYn==true?1:0;
        	
        	//row.valueYn==1?true:false
        	fnSearchList02(gSheetId);
        },
        onChange: function (event) {
        	// 20230625 jslee 수정대상여부 추출하기 위해 컬럼의 정보를 json형태로 추출 {fieid:caption} 형태로 추출됨.
        	var record = this.get(event.recid);
        	// 20230625 jslee json의 컬럼값만 추출
        	var key = Object.keys(record);
        	// 20230625 jslee json의 키값에 해당하는 값이 컬럼의 인덱스와 일치할 시 이벤트 취소.
        	if(key[event.column] == "hideYn" || key[event.column] == "valueYn"){
        		event.preventDefault();
        	}
        },
        columns: [  
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'sheetId', 	 	caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'sheetNm', 		caption: '평가표 제목', 	size: '45%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'totalScore', 	caption: '총점', 			size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'hideYn', 		caption: '사용여부', 		size: '10%', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center' }
       	 		,{ field: 'valueYn', 		caption: '평가여부', 		size: '10%', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentNm', 		caption: '작성자', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'createDt', 		caption: '작성일', 		size: '10%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'dept1Id', 	    caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'dept1Nm', 	    caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'valueCnt', 	    caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('sheetId' );
	w2ui['grid'].hideColumn('dept1Id' ); 
	w2ui['grid'].hideColumn('dept1Nm' ); 
	w2ui['grid'].hideColumn('valueCnt' );  
	 
	$("#grList02").w2grid({
         name : "grid2"
       , reorderRows:true
       , onDblClick: function(event) {
    	   var record = this.get(event.recid);
		   if(record.recid >=0 ) {
			var record = this.get(event.recid);
				if(record.recid >=0 ) {
					gPopupOptions2 = {
			    		  "cudGubun":"U"
			    		, "sheetId":gSheetId
			    	    , "valueYn":gValueYn
			    	    , "partCd":record.partCd
			    	    , "majorCd":record.majorCd
					    , "minorCd":record.minorCd
					    , "insYn":false
					    //, "year":argoGetValue("s_Year")
			    	};
					argoPopupWindow( '평가항목편집', 'QA1020S02F.do',  '900', '632' ); 
				}
       		}
       }
	, columnGroups : [
             { caption:"평가항목", span:5 }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
           , { caption:"", master:true }
       ]
       , columns : [               
    	   { field: 'recid', 	 		caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
    	    ,{ field: 'majorCd', 	 	caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'majorNm', 		caption: '대분류', 	size: '13%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'minorCd', 		caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'minorNm', 		caption: '소분류명', 	size: '13%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'qaSebuCd', 		caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'qaSebuNm', 		caption: '구분', 		size: '10%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'sheetText', 		caption: '평가내용', 	size: '54%', 	sortable: false, attr: 'align=left' }
	 		,{ field: 'score', 	    	caption: '배점', 		size: '10%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'sort', 	    	caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'majorCnt', 	    caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'minorCnt', 	    caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'sortSeq', 	    caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'plusMinus', 	    caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
	 		,{ field: 'partCd', 	    caption: '', 		size: '0%', 	sortable: false, attr: 'align=center' }
       ]
   	});   
	
    w2ui['grid2'].hideColumn('recid' );
	w2ui['grid2'].hideColumn('majorCd' );
	w2ui['grid2'].hideColumn('minorCd' );
	w2ui['grid2'].hideColumn('qaSebuCd' ); 
	w2ui['grid2'].hideColumn('sort' ); 
	
	w2ui['grid2'].hideColumn('majorCnt' ); 
	w2ui['grid2'].hideColumn('minorCnt' );
	w2ui['grid2'].hideColumn('sortSeq' );
	w2ui['grid2'].hideColumn('plusMinus' );
	w2ui['grid2'].hideColumn('partCd' );  
}


function fnSearchList01(startRow, endRow){
	argoJsonSearchList('QA', 'SP_QA1020M01_01', 's_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				w2ui.grid2.clear();
				
				if(data.getProcCnt() == 0){
					argoAlert('조회 결과가 없습니다.');
					gSheetId = "";
					gValueYn = "";
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
				    				, "sheetId"			: row.sheetId
				   					, "sheetNm"	  		: row.sheetNm
									, "totalScore" 		: row.totalScore
									, "hideYn"	  		: row.hideYn==0?true:false
									, "valueYn" 		: row.valueYn==1?true:false
									, "agentNm" 		: row.agentNm
									, "createDt"		: row.createDt
									, "dept1Id"			: row.dept1Id
									, "dept1Nm" 		: row.dept1Nm										
									, "valueCnt" 		: row.valueCnt										
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


function fnSearchList02(sheetId){		
	argoJsonSearchList('QA','SP_QA1020M01_02','s_', {"sheetId":sheetId}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getRows() != ""){
					w2ui.grid2.clear();
					dataArray = [];
					var color = "";
					var majorCdColorFlg = "";
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							
							if(index == 0){
								majorCdColorFlg = ""+row.majorCd+""+row.minorCd;
								color = "#e6e0ec";
							}else if(majorCdColorFlg != ""+row.majorCd+""+row.minorCd){
								majorCdColorFlg = ""+row.majorCd+""+row.minorCd;
								
								if(color == "#ebf1de"){
									color = "#e6e0ec";
								}else{
									color = "#ebf1de";
								}
							}
							
							gObject2 = {  "recid" 			: index
					    				, "majorCd"			: row.majorCd
					   					, "majorNm"	  		: row.majorNm
										, "minorCd" 		: row.minorCd
										, "minorNm"			: row.minorNm
										, "qaSebuCd" 		: row.qaSebuCd
										, "qaSebuNm" 		: row.qaSebuNm
										, "sheetText"		: row.sheetText
										, "score"			: row.score
										, "sort" 			: row.sort										
										, "majorCnt" 		: row.majorCnt										
										, "minorCnt" 		: row.minorCnt
										, "sortSeq" 		: row.sortSeq
										, "plusMinus" 		: row.plusMinus
										, "partCd" 			: row.partCd
										, "w2ui": { "style": "background-color: " + color }
										};
							dataArray.push(gObject2);
						});
						w2ui['grid2'].add(dataArray);
					}
				}else{
					w2ui.grid2.clear();
				}
			}
		} catch(e) {
			console.log(e);			
		}
	});		
}

//-------------------------------------------------------------
//복사 - 평가표
//-------------------------------------------------------------
function fnCopy(){	
	try{
		var arrChecked = w2ui['grid'].getSelection();
	 	if(arrChecked.length==0) {
	 		argoAlert("복사할 평가표를 선택하세요") ; 
	 		return ;
	 	}
		argoConfirm('선택한 평가표 ' + arrChecked.length + '건을  <br>복사하시겠습니까?', function() {
			var multiService = new argoMultiService(fnCallbackCopy);
			$.each(arrChecked, function( index, value ) {
				var param = { 
				  "sheetId" : w2ui['grid'].get(value).sheetId
				};
				multiService.argoUpdate("QA","SP_QA1020M01_03","__", param);
			});
			multiService.action();
	 	}); 
	}catch(e){
		console.log(e) ;	 
	}
}

function fnCallbackCopy(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('성공적으로 복사생성 되었습니다.') ;	
	    	fnSearchList01();
	    }
	} catch(e) {
		argoAlert(e);    		
	}
}

//그리드 체크박스로 데이터 삭제
function fnDelete1(){
	try{
		var arrChecked = w2ui['grid'].getSelection();
		var flag = true;
	 	if(arrChecked.length==0) {
	 		argoAlert("삭제할 평가표를 선택하세요.") ; 
	 		return ;
	 	}
	 	
	 	$.each(arrChecked, function( index, value ) {
	 		if(w2ui['grid'].get(value).valueYn == true){
	 			flag = false;
	 		}
		});
	 	
	 	if(flag == false){
	 		argoAlert("평가가 진행된 평가표는 <br>삭제가 불가능합니다.") ;
 			return;
	 	}
	 	
	 	argoConfirm("등록된 평가내용도 함께 삭제 됩니다.<br><br>선택한 평가표를 삭제하시겠습니까?", function() {
		 	var multiService = new argoMultiService(fnCallbackDelete);
			$.each(arrChecked, function( index, value ) {
				multiService.argoDelete("QA","SP_QA1020M01_04","__", {"sheetId" : w2ui['grid'].get(value).sheetId});
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
			workLog = '[태넌트ID:' + tenantId + '] 삭제';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
							,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			argoAlert('성공적으로 삭제 되었습니다.');
			fnSearchList01();
		}
	} catch (e) {
		argoAlert(e);
	}
}

var formGbn = new Array();
function fnSetQaSebuCd(){
	argoJsonSearchList("ARGOCOMMON", "SP_UC_GET_CMCODE_01", "_", {"sort_cd" : 'QA_SEBU_CD'}, function(data, textStatus, jqXHR){
		formGbn=[];
		$.each(data.getRows(), function(index, value){
			if(value.code!=0){
				formGbn.push(value.code);
			}
		});
	})
}

/* function fnCreateCounterCloserEx(){
	var count = 0;
	
	var increment = function(){
		count++;
		console.log("count : " + count);
	}
	
	return increment;
} */


/* const _number10Add = (num, callback) => {
    setTimeout(() => {
    	console.log("_number10Add : " + callback);
    	console.log("num : " + num);
    	callback(num + 10);
    }, 1000);
};

// 1초마다 숫자에 20을 더해준다.
const _number20Add = (num, callback) => {
    setTimeout(() => {
    	console.log("_number20Add : " + callback);
    	console.log("num : " + num);
        callback(num + 20);
    }, 1000);
};

// 1초마다 숫자에 30을 더해준다.
const _number30Add = (num, callback) => {
    setTimeout(() => {
    	console.log("_number30Add : " + callback);
    	console.log("num : " + num);
        callback(num + 30);
    }, 1000);
};

// 결과값을 콘솔에 출력한다.
const _numberLog = (number) =>
    new Promise(() => {
        setTimeout(() => console.log(number), 1000);
    });

// 최종 연산 값을 출력한다. => 반복 콜백 문제 발생
const resultConsole = () => {
    _number10Add(0, (test) => {
        _number20Add(test, (test2) => {
            _number30Add(test2, (test3) => {
                _numberLog(test3);
            });
        });
    });
}; */

/* function test(num){
	return new Promise((resolve) => {
		
		// resolve
		resolve(1234);
		resolve(num + 20);
		
		
		console.log("num" + num);
	});
}

function testConsole(){
	test(10)
	.then((result1) => _number10Add(result1))
	.catch(error => console.error(error));
}


const _number10Add = (num) => {
    return new Promise((resolve) => {
    	resolve(num + 10);
    	console.log("num" + num);
    });
};

const _number20Add = (num) => {
    return new Promise((resolve) => {
	    console.log("_number20Add : " + num);
	    console.log("num : " + num);
	    resolve(num + 20);
    });
};

const _number30Add = (num) => {
    return new Promise((resolve) => {
    	console.log("_number30Add : " + num);
		console.log("num : " + num);
		resolve(num + 30);
    });
};

const _numberLog = (number) => {
    return new Promise((resolve) => {
	    console.log(number);
	    resolve();
    });
};

const resultConsole = () => {
    _number10Add(0)
        .then((result1) => _number20Add(result1))
        .then((result2) => _number30Add(result2))
        .then((result3) => _numberLog(result3))
        .catch((error) => console.error(error));
}; */

</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화품질(QA)</span><strong class="step">평가표관리</strong></div>
        <section class="sub_contents">
            <div class="search_area fix_h54">
            	<div class="row">
                    <ul class="search_terms">
                    	<li>
                    		<strong class="title ml20">기준년</strong>
                    		<span class="count_num">
                          		<button type="button" class="btn_minus" id="btn_minus">-</button><input type="text" id="s_Year" name="s_Year" style="width:50px;" class="input_num" maxlength="4"><button type="button" class="btn_plus" id="btn_plus">+</button>
							</span>
                    	</li>
                    	<li>
                            <strong class="title">평가표</strong>
                            <input type="text" id="s_SheetNm" name="s_SheetNm" style="width:200px;">
                        </li>
                    </ul>
                </div>               
            </div>
            <div class="btns_top">
            	<div class="btns_tl">
                <button type="button" class="btn_m" id="btnSheetItem" >평가항목관리</button>
					<button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
				</div>
                <button type="button" class="btn_m search" id="btnSearch">조회</button>
                <button type="button" class="btn_m confirm" id="btnCopy">평가표 복사</button>
            </div>
            <div class="h98">
                <div class="half40">
                	<div class="btn_topArea">
                		 <span class="btn_r pt5">
                        	<button type="button" class="btn_sm normal" id="btnAdd1" name="btnAdd1" data-grant="W">추가</button>  
                            <button type="button" class="btn_sm confirm" id="btnDel1" name="btnDel1" data-grant="W">삭제</button>    
                        </span>  
                    </div>
                    <div class="grid_area h47 pt0">
                        <div id="grList01" class="real_grid"></div>
                    </div>
                </div>
                <div class="half60">
                	<div class="btn_topArea">
	                    <span class="btn_l pt5">
	                    	<button type="button" class="btn_sm normal" id="btnSorting" name="btnSorting" data-grant="W">순서변경</button>
	                    </span>
                        <span class="btn_r pt5">
                        	<button type="button" class="btn_sm normal" id="btnAdd2" name="btnAdd2" data-grant="W">추가</button>            
                        </span>                        
                    </div>
                    <div class="grid_area h47 pt0">
                        <div id="grList02" class="real_grid"></div>
                    </div>
                </div>
            </div>
        </section>
    </div>
</body>
</html>