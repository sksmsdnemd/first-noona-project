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

var fvGrdCmCode =[], fvGrdCmValue=[];
var fvTargetObjId ; //호출화면의 INPUT Object Name
var fvTargetObjNm ; //호출화면의 INPUT Object Name
var fvMultiYn ="N"; //멀티여부 - Y 이면 멀티선택 허용

var fvRltIds =""; // 리턴값(Ids)
var fvRltNms =""; // 리턴값(Names))
var fvStdMonth ="";

$(function (){		

	/* 호출화면의 정보 설정  */	
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
	};
    
    fvTargetObjId 	= sPopupOptions.targetObj+"Id" ;
    fvTargetObjNm 	= sPopupOptions.targetObj+"Nm" ;
    fvMultiYn     	= sPopupOptions.multiYn;
 
    fnInitCtrl_SheetChoice();
    
});
	
function fnInitCtrl_SheetChoice(){
	
    /* 조회버튼  */ 
	$("#btnSearch_SheetChoice").click(function(){			
		fnSearchList_SheetChoice();
	});
	
    /* 확인버튼  */
	$("#btnConfirm_SheetChoice").click(function(){			
		fnSetUserChoice();
		argoPopupClose();
	});
     
	argoSetYearMonthPicker();
	
	fnInitGrid_SheetChoice();
	
	fnSearchList_SheetChoice();
	
}

//-------------------------------------------------------------
// 그리드 초기설정
//-------------------------------------------------------------
var gridView_SheetChoice_1, dataProvider_SheetChoice_1;

function fnInitGrid_SheetChoice(){

    dataProvider_SheetChoice_1 = new RealGridJS.LocalDataProvider(); 
    gridView_SheetChoice_1     = new RealGridJS.GridView("grList_SheetChoice_1");
    gridView_SheetChoice_1.setDataSource(dataProvider_SheetChoice_1);
    
    argoSetGridStyle(gridView_SheetChoice_1, {"isPanel" : false , "isCheckBar":( fvMultiYn=='Y'? true: false), "isEditable" : false, "isFooter"  : false });
    
    gridView_SheetChoice_1.setSelectOptions({ style : "rows" });  //ROW단위로 Selection
//     gridView_SheetChoice_1.setDisplayOptions({ fitStyle : "even" });  
    
    
	var columns = [ { name: "agentJikchkNm"
					, fieldName: "agentJikchkNm"
					, header : { text: "평가대상" }
					, width: 100
					, styles: { textAlignment: "center" }
					}    
				  , { name: "sheetNm"
					, fieldName: "sheetNm"
					, header : { text: "평가표" }
					, width: 380					
					}
				  , { name: "scoreSum"
					, fieldName: "scoreSum"
					, header : { text: "배점" }
					, width: 60					
                    , styles: { textAlignment: "center" }
					}
				  , { name: "questionCnt"
					, fieldName: "questionCnt"
					, header : { text: "평가항목" }
					, width: 60					
                    , styles: { textAlignment: "center" }
					}
				  , { name: "hideYn"
					, fieldName: "hideYn"
					, header : { text: "사용여부" }
					, width: 60
					, styles: { textAlignment: "center", figureBackground: "#ffff0000", figureInactiveBackground: "#33ff0000", figureSize: "100%" }   
                    , type: "data"
                    , renderer: { type: "check", editable: true, startEditOnClick: true, trueValues: "0", falseValues: "1" }
					}
				  , { name: "evalYn"
					, fieldName: "evalYn"
					, header : { text: "평가여부" }
					, width: 60
					, styles: { textAlignment: "center", figureBackground: "#ffff0000", figureInactiveBackground: "#33ff0000", figureSize: "100%" }   
                    , type: "data"
                    , renderer: { type: "check", editable: true, startEditOnClick: true, trueValues: "1", falseValues: "0" }
					}];
	
	// 컬럼을 GridView1에 입력
	gridView_SheetChoice_1.setColumns(columns);
	
    // 그리드 더블클릭시 선택 처리  (싱글일 경우)
	gridView_SheetChoice_1.onDataCellDblClicked = function (grid, index) {
		if( fvMultiYn != 'Y') {
			$("#btnConfirm_SheetChoice").trigger('click');
		}
	}	
}	
	
//-------------------------------------------------------------
//평가표 목록조회 
//-------------------------------------------------------------	
function fnSearchList_SheetChoice(){
	var param = {}; 			
	argoGrSearch("dataProvider_SheetChoice_1", "HR", "SP_HR3010M01_01", "s_", param);
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
