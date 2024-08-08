<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html >
<html>
<head>
<title>ARGO</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />
<%@ include file="/WEB-INF/jsp/include/common.jsp"%>
<style>
.date_layer .date_b .date_list li a{padding: 0; line-height: 32px;}
.date_layer .date_b .date_list li{line-height: 32px;}
</style>
<script>

var fvTargetObjId ; //호출화면의 INPUT Object Name
var fvTargetObjNm ; //호출화면의 INPUT Object Name
var fvMultiYn ="N"; //멀티여부 - Y 이면 멀티선택 허용

var fvRltIds =""; // 리턴값(Ids)
var fvRltNms =""; // 리턴값(Names))

	$(function () {		
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 호출 화면의 정보 설정
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
	     fvTargetObjId = sPopupOptions.targetObj+"Id" ;
	     fvTargetObjNm = sPopupOptions.targetObj+"Nm" ;
	     fvMultiYn     = sPopupOptions.multiYn ;	     

	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 버튼 이벤트
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	     
		$("#btnSearch_SheetChoice").click(function(){			
			fnSearchList_SheetChoice();
		});
		
	     $("#btnConfirm_SheetChoice").click(function(){			
			fnSetUserChoice();
			argoPopupClose();
		});
	     
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 콤보박스 데이터 바인딩
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
		argoSetYearMonthPicker();
		
		var sStdMonth = argoSetFormat(argoCurrentDateToStr(),"-","4-2") ;
		argoSetValue('s_StdMonthFrom', sStdMonth) ;
		argoSetValue('s_StdMonthTo', sStdMonth) ;
		
	    argoCbCreate("s_EduSheetType", "ARGOCOMMON", "SP_UC_GET_CMCODE_01",{sort_cd:'EDU_SHEET_TYPE'},{"selectIndex":0, "text":'<전체>', "value":''});
		  
		fnInitGrid_SheetChoice(); //그리드 초기화

		fnSearchList_SheetChoice() ;

	});

	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	var gridView_SheetChoice_1,  dataProvider_SheetChoice_1 ;// 그리드상단

	function fnInitGrid_SheetChoice(){

	    dataProvider_SheetChoice_1 = new RealGridJS.LocalDataProvider(); 
	    gridView_SheetChoice_1 = new RealGridJS.GridView("grList_SheetChoice_1");
	    gridView_SheetChoice_1.setDataSource(dataProvider_SheetChoice_1);
	    
	   // argoSetGridStyle(gridView_SheetChoice_1); // 그리드 기본 스타일 적용 - 기본   
	   
	    argoSetGridStyle(gridView_SheetChoice_1, {"isPanel":false ,"isCheckBar":( fvMultiYn=='Y'? true: false),"isEditable":false, "isFooter":false }); // 그리드 기본 스타일 적용 - isPanel, isCheckBar, isEditable, isFooter
	    //ROW단위로 Selection
	    gridView_SheetChoice_1.setSelectOptions({
	    	 style: "rows"
	    });
	    
	    // 그리드 컬럼오브젝트    
	    var columns = [                  
	                   {    name: "eduSheetTypeNm"
	                       ,fieldName: "eduSheetTypeNm"
	                       ,header : { text: "평가구분" }
	                       ,width: 100
	                       ,styles: { textAlignment: "center" }
	                   }   
	                   ,{    name: "sheetNm"
	                       ,fieldName: "sheetNm"
	                       ,header : { text: "시험지" }
	                       ,width: 350
	                   } 
	                   ,{    name: "scoreSum"
	                       ,fieldName: "scoreSum"
	                       ,header : { text: "총점" }
	                       ,width: 80
	                       ,styles: { textAlignment: "center" }
	                   }      
	                   ,{    name: "questionCnt"
	                       ,fieldName: "questionCnt"
	                       ,header : { text: "문항수" }
	                       ,width: 80
	                       ,styles: { textAlignment: "center" }
	                   }                   
		                   
	                ];
	              //컬럼을 GridView에 입력 합니다.
	            gridView_SheetChoice_1.setColumns(columns);
	           
	            // 그리드 더블클릭시 선택 처리  (싱글일 경우)
	    	    gridView_SheetChoice_1.onDataCellDblClicked = function (grid, index) {
	    	    	if( fvMultiYn!='Y') {
	    	    	//fnSetUserChoice(index.dataRow) ;
	    	    		$("#btnConfirm_SheetChoice").trigger('click');
	    	    	}
	   		    }
	}	
	
	//-------------------------------------------------------------
	//상담사 목록조회 
	//-------------------------------------------------------------	
	function fnSearchList_SheetChoice(){
	 var param = {}; 			
		 argoGrSearch("dataProvider_SheetChoice_1", "ARGOCOMMON", "SP_UC_GET_EDU_SHEET", "s_", param); 
		}
	
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직선택값 호출 오브젝트에 설정 
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
	function fnSetUserChoice() {
		fvRltIds = "";
		fvRltNms ="";
		
		var arrIds = new Array();
		var arrNms = new Array();
		
			if( fvMultiYn=='Y') {
			
			var arrChecked = gridView_SheetChoice_1.getCheckedRows(false);			
				$.each(arrChecked, function( index, value ) {
					arrIds.push(dataProvider_SheetChoice_1.getValue(value,"sheetId"));
					arrNms.push(dataProvider_SheetChoice_1.getValue(value,"sheetNm"));
				 });
				fvRltIds = arrIds.join(',');
				fvRltNms = arrNms.join(', ');
			} else {
				var index = gridView_SheetChoice_1.getCurrent();
				fvRltIds = dataProvider_SheetChoice_1.getValue(index.dataRow,"sheetId");
				fvRltNms = dataProvider_SheetChoice_1.getValue(index.dataRow, "sheetNm");
				//fvRltNms = dataProvider_SheetChoice_1.getValue(index.dataRow, "deptPath")+"/" + dataProvider_SheetChoice_1.getValue(index.dataRow, "sheetNm");
			}
			
			//***************호출한 화면에 선택한 코드 및 코드값 설정 처리 *****************************		
		 	var sOpener = window.frameElement.attributes["data-pid"].value ;
		 	var sOpenerType = window.frameElement.attributes["data-ptype"].value ;
		
	        if(sOpenerType == "M" ) {//메인 화면에서 호출시
		 		$("#"+fvTargetObjId, parent.document).val(fvRltIds);
				$("#"+fvTargetObjNm, parent.document).val(fvRltNms);
	    	 
		     }else { //팝업에서 호출시
		    	 $("#"+fvTargetObjId, parent.frames[sOpener].document).val(fvRltIds);
		    	 $("#"+fvTargetObjNm, parent.frames[sOpener].document).val(fvRltNms);
		     }

	}
	
</script>

</head>

<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="btn_topArea">            	
                <span class="btn_l">                	
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml5">작성기간</strong>                            
                            <span class="yearMonth_date" id="d1"><input type="text" placeholder="년 - 월" class="input_ym" id="s_StdMonthFrom" name="s_StdMonthFrom"><a href="#" class="btn_calendar">년/월 선택</a></span>
                            <span class="text_divide">~</span> 
                            <span class="yearMonth_date" id="d2"><input type="text" placeholder="년 - 월" class="input_ym" id="s_StdMonthTo" name="s_StdMonthTo"><a href="#" class="btn_calendar">년/월 선택</a></span>   
                        </li>
                        <li>
                           <strong class="title">평가유형</strong>
                           <select id="s_EduSheetType" name="s_EduSheetType" style="width:95px;">
                            </select>
                        </li>                                         
                    </ul>                                            
                </span>
                <span class="btn_r">
               		 <button type="button" id="btnSearch_SheetChoice" name="btnSearch_SheetChoice" class="btn_m search" >조회</button>
                </span>
            </div>    
            <div class="pop_cont">            
                <div class="grid_area h38 pt0" >
                    <div id="grList_SheetChoice_1" class="real_grid"></div>
                </div>
                <div class="btn_areaB txt_r">
                <button type="button" id="btnConfirm_SheetChoice" name="btnConfirm_SheetChoice" class="btn_m confirm" >확인</button>
            	</div>
            </div>            
        </section>
    </div>
</body>
</html>
