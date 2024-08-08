<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript">
//공통 변수 세팅
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가항목 순서변경";
var workLog 	= "";
var dataArray 	= new Array();
var fvSheetId = "";
$(document).ready( function() {
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
	};
	fvSheetId = sPopupOptions.pSheetId;
	
	fnInitCtrl();
	fnInitGrid();
	fnSearchList();
});

function fnInitCtrl(){
	$("#btnSave").click(function(){
		fnSave();
	});
}

//-------------------------------------------------------------
// 그리드 초기설정
//-------------------------------------------------------------
function fnInitGrid(){
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false
        },
        multiSelect: false,
        reorderRows:true,
        columns: [  
		 	 { field: 'recid', 			caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
		 	,{ field: 'sheetId', 	 	caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
		 	,{ field: 'majorCd', 	 	caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
		 	,{ field: 'majorNm', 	 	caption: '대분류명', 	size: '50%', 		sortable: false, attr: 'align=center' }
      	 	,{ field: 'minorCd', 		caption: '', 		size: '0%', 		sortable: false, attr: 'align=center' }
      	 	,{ field: 'minorNm', 		caption: '소분류명', 	size: '50%', 		sortable: false, attr: 'align=center' }
       	],
        records: dataArray
    });
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('sheetId' );
	w2ui['grid'].hideColumn('majorCd' );
	w2ui['grid'].hideColumn('minorCd' ); 
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 평가항목 조회
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function fnSearchList(){
	argoJsonSearchList('QA','SP_QA1020S07_01','__', {"sheetId":fvSheetId}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				dataArray = [];
				if(data.getProcCnt() == 0){
					return;
				}
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
		    				, "sheetId"					: row.sheetId
							, "majorCd"					: row.majorCd
							, "majorNm"					: row.majorNm
		   					, "minorCd"	  				: row.minorCd
		   					, "minorNm"	  				: row.minorNm
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
	});
}

function fnSave(){
	var orderVelidateArr = new Array();
	var validateChk = ""; 
	var flag = true;
	
	w2ui.grid.records.forEach(function(obj, index) {
		if(index==0){
			validateChk = argoNullConvert(obj.majorCd)
		}
		
		if(validateChk != argoNullConvert(obj.majorCd)){
			orderVelidateArr.push(validateChk);
			validateChk = argoNullConvert(obj.majorCd);
		}
		
		if($.inArray(validateChk, orderVelidateArr) != -1){
			flag = false;
			argoAlert("대분류 " + argoNullConvert(obj.majorNm) + "을(를) 연결하여 등록해 주십시오.");
			return;
		}
    });
	
	if(flag){
		argoConfirm("다음 변경내역을 적용하시겠습니까?", function(){
	    	try{
				var multiService = new argoMultiService(fnCallbackSave);
				w2ui.grid.records.forEach(function(obj, index) {
					var param = {
						"sheetId":fvSheetId,
						"majorCd":argoNullConvert(obj.majorCd),
						"minorCd":argoNullConvert(obj.minorCd),
						"sort":index
					};
					multiService.argoUpdate("QA","SP_QA1020S07_02","__", param);
			    });
				multiService.action();
		    }catch(e){
	    		console.log(e)
	    	}			    						
	 	});
	}
}

function fnCallbackSave(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('warning', '성공적으로 저장 되었습니다.','', 'parent.fnSearchList02(fvSheetId); argoPopupClose();');		    	
	    }
	} catch(e) {
		console.log(e);    		
	}
}
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt5">            	
                <div class="pop_btn">
                	<span class="btn_l" style="margin-top: 5px; color: red;">※ 순서변경 방법 : "#" 항목 드래그</span>
                    <span class="btn_r">
                        <button type="button" class="btn_m confirm"  id="btnSave" data-grant="W">저장</button>
                    </span>
                </div>	
                <div class="grid_area h35 pt0" >
                    <div id="grList" class="real_grid"></div>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>
