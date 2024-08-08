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
var fvStdMonth ="";
var fvMenuId="";

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
    fvMultiYn     = sPopupOptions.multiYn;
 	fvMenuId	  = sPopupOptions.menuId;
	var sStdMonth = argoSetFormat(argoCurrentDateToStr(),"-","4-2") ;
	argoSetValue('s_StdMonth', sStdMonth) ;
		   

 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 	// 버튼 이벤트
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	     
	$("#btn_Search").click(function(){			
		fnSearchList();
	});
 	
	$("#btn_Confirm").click(function(){			
		fnSetUserChoice();
		argoPopupClose();
	});
     
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 	// 콤보박스 데이터 바인딩
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
	argoSetYearMonthPicker({ next_mState:false });
	
	var sStdMonth = (fvStdMonth =='' ? argoSetFormat(argoCurrentDateToStr(),"-","4-2") : fvStdMonth.substr(0,4)+"-"+fvStdMonth.substr(4,2));
	argoSetValue('s_StdMonth', sStdMonth) ;
	
	fnInitGrid(); //그리드 초기화
	
	fnSearchList();

});

//-------------------------------------------------------------
// 그리드 초기설정
//-------------------------------------------------------------
var gridView1, dataProvider1;
function fnInitGrid(){

	dataProvider1 = new RealGridJS.LocalDataProvider(); 
	gridView1 = new RealGridJS.GridView("grList1");
	gridView1.setDataSource(dataProvider1);
    
    argoSetGridStyle(gridView1, {"isPanel":false ,"isCheckBar":( fvMultiYn=='Y'? true: false),"isEditable":false, "isFooter":false });

    gridView1.setSelectOptions({
		style: "rows"
    });
    
	var columns = [ { name: "scheNm"
				    , fieldName: "scheNm"
					, header : { text: "평가계획" }
					, width: 200
					}    
				  , { name: "sheetNm"
					, fieldName: "sheetNm"	
					, header : { text: "평가표" }
					, width: 200
					}
   	       		  ];
	
	gridView1.setColumns(columns);
	
    // 그리드 더블클릭시 선택 처리  (싱글일 경우)
    gridView1.onDataCellDblClicked = function (grid, index) {
		if( fvMultiYn != 'Y') {
			$("#btn_Confirm").trigger('click');
		}
	}	

}	
	
/* 평가계획 목록 조회  */		
function fnSearchList(){
	argoGrSearch("dataProvider1", "ARGOCOMMON", "SP_UC_GET_HR_SCHE", "s_", { grantDeptCd : '${sessionMAP.deptCd}' }); 
}
	
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 조직선택값 호출 오브젝트에 설정 
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
function fnSetUserChoice() {
	fvRltIds = "";
	fvRltNms ="";
	
	var arrIds = new Array();
	var arrNms = new Array();
	
	if( fvMultiYn == 'Y') {
		
		var arrChecked = gridView1.getCheckedRows(false);
		
		$.each(arrChecked, function( index, value ) {
			arrIds.push(dataProvider1.getValue(value, "scheId"));
			arrNms.push(dataProvider1.getValue(value, "scheNm"));
		});

		fvRltIds = arrIds.join(',');
		fvRltNms = arrNms.join(', ');
		
	} else {
		
		var index = gridView_SheetChoice_1.getCurrent();
		
		fvRltIds = dataProvider1.getValue(index.dataRow, "scheId");
		fvRltNms = dataProvider1.getValue(index.dataRow, "scheNm");
		
	}
		
	/* 호출한 화면에 선택한 코드 및 코드값 설정 처리  */		
 	var sOpener = window.frameElement.attributes["data-pid"].value ;
 	var sOpenerType = window.frameElement.attributes["data-ptype"].value ;

	if(sOpenerType == "M" ) {//메인 화면에서 호출시
		$("#"+fvTargetObjId, parent.document).val(fvRltIds);
		$("#"+fvTargetObjNm, parent.document).val(fvRltNms);
   	 
		if(fvMenuId=='HR3030M01'){
       		parent.fnTimesSet(fvRltIds);
       	}
		
     } else { //팝업에서 호출시
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
                            <strong class="title ml5">기준년월</strong>
                            <span class="yearMonth_date" id="d1"><input type="text" placeholder="년 - 월" class="input_ym onlyDate" id="s_StdMonth" name="s_StdMonth"><a href="#" class="btn_calendar">년/월 선택</a></span>   
                        </li>
                    </ul>                                            
                </span>
                <span class="btn_r">
               		 <button type="button" id="btn_Search" name="btn_Search" class="btn_m search">조회</button>
                </span>
            </div>    
            <div class="pop_cont">            
                <div class="grid_area h38 pt0" >
                    <div id="grList1" class="real_grid"></div>
                </div>
                <div class="btn_areaB txt_r">
                <button type="button" id="btn_Confirm" name="btn_Confirm" class="btn_m confirm" >확인</button>
            	</div>
            </div>            
        </section>
    </div>
</body>
</html>
