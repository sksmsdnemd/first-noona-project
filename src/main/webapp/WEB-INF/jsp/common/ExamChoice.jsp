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
		$("#btnSearch_ExamChoice").click(function(){			
			fnSearchList_ExamChoice();
		});
		
	     $("#btnConfirm_ExamChoice").click(function(){			
			fnSetUserChoice();
			argoPopupClose();
		});
	     
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		// 콤보박스 데이터 바인딩
		//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		//argoSetYearMonthPicker();
	 	//next_mState:false
		var sStdMonth = argoSetFormat(argoCurrentDateToStr(),"-","4-2") ;
		argoSetValue('s_StdMonthFrom', sStdMonth) ;
		argoSetValue('s_StdMonthTo', sStdMonth) ;
		$("#d1.yearMonth_date").dateSelect({next_mState:false});
		$("#d2.yearMonth_date").dateSelect({next_mState:false});
		
		fnInitGrid_ExamChoice(); //그리드 초기화

		fnSearchList_ExamChoice() ;

	});

	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	var gridView_ExamChoice_1,  dataProvider_ExamChoice_1 ;// 그리드상단

	function fnInitGrid_ExamChoice(){

	    dataProvider_ExamChoice_1 = new RealGridJS.LocalDataProvider(); 
	    gridView_ExamChoice_1 = new RealGridJS.GridView("grList_ExamChoice_1");
	    gridView_ExamChoice_1.setDataSource(dataProvider_ExamChoice_1);
	    
	   // argoSetGridStyle(gridView_ExamChoice_1); // 그리드 기본 스타일 적용 - 기본   
	   
	    argoSetGridStyle(gridView_ExamChoice_1, {"isPanel":false ,"isCheckBar":( fvMultiYn=='Y'? true: false),"isEditable":false, "isFooter":false }); // 그리드 기본 스타일 적용 - isPanel, isCheckBar, isEditable, isFooter
	    //ROW단위로 Selection
	    gridView_ExamChoice_1.setSelectOptions({
	    	 style: "rows"
	    });
	    
	    var columns = [                  
	                   {    name: "stdMonth"
	                       ,fieldName: "stdMonth"
	                       ,header : { text: "기준년월" }
	                       ,width: 60
	                       ,styles: { textAlignment: "center" }
	                   },  
	                   {  type: "group",
	                       name: "평가계획",
	                       width: 470,
	                       columns: [ {   name: "scheNm",
	                                       fieldName: "scheNm",
	                                       header : { text: "계획명" }
	                                       ,width: 150
                                   
	                                   }, {
	                                       name: "examPeriod",
	                                       fieldName: "examPeriod",
	                                       header : {  text: "평가일시" },
	                                       width: 110
	                                       ,styles: { textAlignment: "center" }
	                                   } , {
	                                       name: "eduEvalTypeNm",
	                                       fieldName: "eduEvalTypeNm",
	                                       header : {  text: "평가구분" },
	                                       width: 60
	                                       ,styles: { textAlignment: "center" }
	                                   } , {
	                                       name: "eduExamTypeNm",
	                                       fieldName: "eduExamTypeNm",
	                                       header : {  text: "업무유형" },
	                                       width: 60
	                                       ,styles: { textAlignment: "center" }
	                                   } , {
	                                       name: "scheStatusNm",
	                                       fieldName: "scheStatusNm",
	                                       header : {  text: "진행상태" },
	                                       width: 60
	                                       ,styles: { textAlignment: "center",fontBold:true },
	               						dynamicStyles: [
	               										{criteria: "value like '%시작알림%'",styles: "foreground=#e06611"},
	               										{criteria: "value like '%진행중%'",styles: "foreground=#e0cf11"},
	               										{criteria: "value like '%완료%'",styles: "foreground=#2080D0"},
	               										{criteria: "value like '%마감%'",styles: "foreground=#008000"}
	               									]
	                                       
	                                   } ,{   name: "kpiYn"
	                                 	  ,fieldName: "kpiYn"
	                                           ,header : { text: "KPI반영" }
	                                           ,width: 40
	                                           ,styles: { textAlignment: "center" 
	                                          	     ,figureBackground: "#ffff0000"
	                                                  ,figureInactiveBackground: "#33ff0000"
	                                                   ,figureSize: "100%"   
	                                             }   
	                                             ,type: "data"
	                                             ,renderer: {
	                                                 type: "check"
	                                                 ,editable: true
	                                                 ,startEditOnClick: true
	                                                 ,trueValues: "1"
	                                                 ,falseValues: "0"
	                                             }
	                                       } ]
	                   }
	                ];
	              //컬럼을 GridView에 입력 합니다.
	            gridView_ExamChoice_1.setColumns(columns);
	           
	            // 그리드 더블클릭시 선택 처리  (싱글일 경우)
	    	    gridView_ExamChoice_1.onDataCellDblClicked = function (grid, index) {
	    	    	if( fvMultiYn!='Y') {
	    	    	//fnSetUserChoice(index.dataRow) ;
	    	    		$("#btnConfirm_ExamChoice").trigger('click');
	    	    	}
	   		    }
	}	
	
	//-------------------------------------------------------------
	//상담사 목록조회 
	//-------------------------------------------------------------	
	function fnSearchList_ExamChoice(){
	 var param = {}; 		
	 
		 gridView_ExamChoice_1.setAllCheck(false); // 그리드 헤더 체크  - unchecked 상태로
		 argoGrSearch("dataProvider_ExamChoice_1", "ARGOCOMMON", "SP_UC_GET_EDU_EXAM", "s_", param); 
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
			
			var arrChecked = gridView_ExamChoice_1.getCheckedRows(false);			
				$.each(arrChecked, function( index, value ) {
					arrIds.push(dataProvider_ExamChoice_1.getValue(value,"scheId"));
					arrNms.push(dataProvider_ExamChoice_1.getValue(value,"scheNm"));
				 });
				fvRltIds = arrIds.join(',');
				fvRltNms = arrNms.join(', ');
			} else {
				var index = gridView_ExamChoice_1.getCurrent();
				fvRltIds = dataProvider_ExamChoice_1.getValue(index.dataRow,"scheId");
				fvRltNms = dataProvider_ExamChoice_1.getValue(index.dataRow, "scheNm");
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
                            <strong class="title ml5">평가기간</strong>
                            <span class="yearMonth_date" id="d1"><input type="text" placeholder="년 - 월" class="input_ym" id="s_StdMonthFrom" name="s_StdMonthFrom"><a href="#" class="btn_calendar">년/월 선택</a></span>
                            <span class="text_divide">~</span> 
                            <span class="yearMonth_date" id="d2"><input type="text" placeholder="년 - 월" class="input_ym" id="s_StdMonthTo" name="s_StdMonthTo"><a href="#" class="btn_calendar">년/월 선택</a></span> 
                        </li>                                                          
                    </ul>                                            
                </span>
                <span class="btn_r">
                      <button type="button" id="btnSearch_ExamChoice" name="btnSearch_ExamChoice" class="btn_m search" >조회</button>
                </span>
            </div>    
            <div class="pop_cont">            
                <div class="grid_area h38 pt0" >
                    <div id="grList_ExamChoice_1" class="real_grid"></div>
                </div>
                <div class="btn_areaB txt_r">
                   <button type="button" id="btnConfirm_ExamChoice" name="btnConfirm_ExamChoice" class="btn_m confirm" >확인</button>
            	</div>
            </div>            
        </section>
    </div>
</body>
</html>
