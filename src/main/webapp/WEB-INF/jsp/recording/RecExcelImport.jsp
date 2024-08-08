<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/velocejs/veloce.excel.js?ver=0"/>"></script>

<script>

var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;
var userId      = loginInfo.SVCCOMMONID.rows.userId;
var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
var workMenu    = "고객정보일괄저장";

//페이지 초기설정
//-------------------------------------------------------------   
$(document).ready( function() 
{	
	
    fnInitCtrl();
    fnInitGrid();
    
	// EXCEL Export 설정 ==> 해당 그리드 생성 후 호출해야 함
	// 기존 그리드의 컬럼 및 필드 유지할 경우 ==> isSetColumns:false
	//                             이 경우 엑셀의 컬럼명이 A/B/C/D... 로 생성되므로 해당 명으로 필드가 생성되어야 함.
	// 기존 컬럼 및 필드 유지 안하고 선택한 엑셀파일 내용으로 새로 만들 경우  ==>isSetColumns:true
	//fillMode 데이터 채움모드  ==> defalut (set) /  set, append, inser, update
	veloceSetExcelImport('excelImport',w2ui['grid'],{excelFilePath:'excelFilePath'});
});

//-------------------------------------------------------------
//화면 공통 스크립트 호출 및 이벤트 처리
//-------------------------------------------------------------
function fnInitCtrl()
{
	
	$("#btnCancel").click(function(){
    	argoPopupClose();
	});
	
	$("#btnSave").click(function(){
		fnSave();	
	});	
	
	$("#btnAllSelect").click(function(){
		w2ui.grid.selectAll();
	});

 }

//-------------------------------------------------------------
//그리드 초기설정
//-------------------------------------------------------------
var gridView;		// 그리드 오브젝트
var dataProvider; // 그리드용 데이터 오브젝트
var dataArray 	= new Array();

function fnInitGrid()
{
	$('#gridList').w2grid(
	{
		name: 'grid', 
        multiSelect : true,
        show: 
        {
            lineNumbers: true,
            footer: true,
            selectColumn: true
        },
        columns: [  
		     { field: 'recid', 		caption: 'recid', 	size: '0px', 	attr: 'align=center' }
		    ,{ field: 'reckey', 	caption: 'reckey', 	size: '110px', 	attr: 'align=center' }
	        ,{ field: 'callId', 	caption: '콜아이디 ', 	size: '120px', 	attr: 'align=center' }
	        ,{ field: 'recTime', 	caption: '통화일자 ', 	size: '100px', 	attr: 'align=center' }
	        ,{ field: 'userId', 	caption: '상담사id', 	size: '100px', 	attr: 'align=center' }
       		,{ field: 'userName', 	caption: '상담사명', 	size: '80px', 	attr: 'align=center' }
       		,{ field: 'custName', 	caption: '고객명', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'custTel', 	caption: '전화번호', 	size: '100px', 	attr: 'align=center' }
			,{ field: 'custNo', 	caption: '고객번호', 	size: '100px', 	attr: 'align=center' }
			,{ field: 'etc_1', 		caption: '기타1', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_2', 		caption: '기타2', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_3', 		caption: '기타3', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_4', 		caption: '기타4', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_5', 		caption: '기타5', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_6', 		caption: '기타6', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_7', 		caption: '기타7', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_8', 		caption: '기타8', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_9', 		caption: '기타9', 	size: '80px', 	attr: 'align=center' }
			,{ field: 'etc_10', 	caption: '기타10', 	size: '80px', 	attr: 'align=center' }
          	
		],
		records: dataArray
	});
	
	w2ui['grid'].hideColumn('recid', 'etc_1', 'etc_2', 'etc_3', 'etc_4', 'etc_5', 'etc_6', 'etc_7', 'etc_8', 'etc_9', 'etc_10');
	$('#gridList').show();
	w2ui.grid.unlock();
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//저장-마스터
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
function fnSave()
{
 	try
 	{
		argoConfirm("저장 하시겠습니까?", function()
		{
			w2ui['grid'].selectAll();
			var arrChecked = w2ui['grid'].getSelection();
			
			var recKey 	 	= "";
			var callId 	 	= "";
			var rectime		= "";
			var userid  	= "";
			var userName 	= "";
			var custName 	= "";
			var custTel 	= "";
			var custNo 		= "";
			var	etc_1		= "";
			var	etc_2		= "";
			var	etc_3		= "";
			var	etc_4		= "";
			var	etc_5		= "";
			var	etc_6		= "";
			var	etc_7		= "";
			var	etc_8		= "";
			var	etc_9		= "";
			var	etc_10		= "";
			
			var multiService = new argoMultiService(fnCallbackSave);
			
			$.each(arrChecked, function( index, row ) 
			{
				
				recKey 		= w2ui['grid'].getCellValue(row, 1);
				callId 		= w2ui['grid'].getCellValue(row, 2);
				rectime 	= w2ui['grid'].getCellValue(row, 3);
				userid 		= w2ui['grid'].getCellValue(row, 4);
				userName	= w2ui['grid'].getCellValue(row, 5);
				custName 	= w2ui['grid'].getCellValue(row, 6);
				custTel 	= w2ui['grid'].getCellValue(row, 7);
				custNo 		= w2ui['grid'].getCellValue(row, 8);
				etc_1		= w2ui['grid'].getCellValue(row, 9);
				etc_2		= w2ui['grid'].getCellValue(row, 10);
				etc_3		= w2ui['grid'].getCellValue(row, 11);
				etc_4		= w2ui['grid'].getCellValue(row, 12);
				etc_5		= w2ui['grid'].getCellValue(row, 13);
				etc_6		= w2ui['grid'].getCellValue(row, 14);
				etc_7		= w2ui['grid'].getCellValue(row, 15);
				etc_8		= w2ui['grid'].getCellValue(row, 16);
				etc_9		= w2ui['grid'].getCellValue(row, 17);
				etc_10		= w2ui['grid'].getCellValue(row, 18);

				var param = { 
								"recKey" 	: recKey,
								"callId" 	: callId,
								"recTime"   : rectime,
								"userId"  	: userId,
								"userName" 	: userName,
								"custName" 	: custName,
								"custTel"	: custTel,
								"custNo"	: custNo,
								"etc_1"		: etc_1,
								"etc_2"		: etc_2,
								"etc_3"		: etc_3,
								"etc_4"		: etc_4,
								"etc_5"		: etc_5,
								"etc_6"		: etc_6,
								"etc_7"		: etc_7,
								"etc_8"		: etc_8,
								"etc_9"		: etc_9,
								"etc_10"	: etc_10
							};

				multiService.argoUpdate("recordFile", "updateRecFile", "__", param);
				
				workLog = '[CallID:' +  callId + ' | 녹취키:' + recKey + ' | 상담사ID:' + userName + '] 마킹삭제';
				argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {tenantId:tenantId, userId:userId
								,actionClass:"action_class", actionCode:"W", workIp:workIp, workMenu:workMenu, workLog:workLog});
			});
			multiService.action();
		});

	} 
 	catch(e) 
 	{
		argoAlert(e);    		
	}
}	 
	
function fnCallbackSave(Resultdata, textStatus, jqXHR)
{
	try
	{
	    if(Resultdata.isOk()) 
	    {
	    	argoAlert('warning', '성공적으로 Import 되었습니다.','', 'argoPopupClose();');
	    }
	} 
	catch(e) 
	{
		argoAlert(e);    		
	}
}

	 
</script>

</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="btn_topArea">
            	<span class="btn_l">
                    <div class="filebox">     
                    	<input type="text" readonly id="excelFilePath" style="width:200px;">
						<label for="excelImport">Excel Import</label>
						<input type="file" id="excelImport" name="excelImport[]"  data-grant="E" accept=".xlsx">
			        </div>
                </span>
                <span class="btn_r">
	            	<button type="button" id="btnAllSelect" name="btnAllSelect" class="btn_m">모두선택</button>  
	            	<button type="button" id="btnSave" name="btnSave" class="btn_m confirm" data-grant="W">저장</button>  
                </span>
            </div>
             <div class="pop_cont">            
                <div class="grid_area h20 pt0" >
                    <div id="gridList" style="width: 100%; height: 350px;"></div>
                </div>
               
            </div>
        </section>
    </div>
    
    <!-- 파일다운로드 처리를 위한 iframe 삽입 -->
    <iframe id="fileDown" style='display:none' src="" width="0" height="0"></iframe>
</body>
</html>