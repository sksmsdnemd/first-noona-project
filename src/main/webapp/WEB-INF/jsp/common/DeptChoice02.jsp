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
		$("#btnSearch_DeptChoice02").click(function(){			
			fnSearchList_DeptChoice02();
		});
		
	     $("#btnConfirm_DeptChoice02").click(function(){			
			fnSetUserChoice();
			argoPopupClose();
		});
	     	  
		fnInitGrid_DeptChoice02(); //그리드 초기화
		fnSearchList_DeptChoice02();			
	});

	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	var treeView_DeptChoice02_1,  dataProvider_DeptChoice02_1 ;// 그리드상단

	function fnInitGrid_DeptChoice02(){

	    dataProvider_DeptChoice02_1 = new RealGridJS.LocalTreeDataProvider(); 
	    treeView_DeptChoice02_1 = new  RealGridJS.TreeView("grList_DeptChoice02_1");
	    treeView_DeptChoice02_1.setDataSource(dataProvider_DeptChoice02_1);
	    
	   argoSetGridStyle(treeView_DeptChoice02_1); // 그리드 기본 스타일 적용 - 기본   
	   
	    argoSetGridStyle(treeView_DeptChoice02_1, {"isPanel":false ,"isCheckBar":( fvMultiYn=='Y'? true: false),"isEditable":false, "isFooter":false }); // 그리드 기본 스타일 적용 - isPanel, isCheckBar, isEditable, isFooter
	    //ROW단위로 Selection
	    treeView_DeptChoice02_1.setSelectOptions({
	    	 style: "rows"
	    });
	    
	   	    dataProvider_DeptChoice02_1.setFields([
	                                             { fieldName: "deptCd"     }
	                                           , { fieldName: "deptNm"     }
	                                           , { fieldName: "deptCdPath" }
	                                           , { fieldName: "agentCnt"   }
	                                           ]);
	   // 그리드 컬럼오브젝트 
	   var columns = [
	                  {   name      : "deptNm"
	                      ,fieldName: "deptNm" 
	                      ,header   : {  text: "소속"   }
	                      ,width    : 200
	                  },
	                  {   name		: "agentCnt"
	                      ,fieldName: "agentCnt"
	                      ,header 	: {  text: "상담사수"   }
	                      ,width	: 60
	                      ,styles	: { textAlignment: "center" }
	                  }
	              ];
	              //컬럼을 GridView에 입력 합니다.
	            treeView_DeptChoice02_1.setColumns(columns);
	           
	            // 그리드 더블클릭시 선택 처리  (싱글일 경우)
	    	    treeView_DeptChoice02_1.onDataCellDblClicked = function (grid, index) {
	    	    	if( fvMultiYn!='Y') {
	    	    	//fnSetUserChoice(index.dataRow) ;
	    	    		$("#btnConfirm_DeptChoice02").trigger('click');
	    	    	}
	   		    }
	}	
	
	//-------------------------------------------------------------
	//상담사 목록조회 
	//-------------------------------------------------------------	
	function fnSearchList_DeptChoice02(){
			
	 argoJsonSearchList('ARGOCOMMON','SP_UC_GET_DEPT_TREE','__', {grantDeptCds:top.gMenu.GRANT_DEPT_CD}, fnCallbackGet_DeptChoice02);
		}
	function fnCallbackGet_DeptChoice02(data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				dataProvider_DeptChoice02_1.clearRows();
				
				dataProvider_DeptChoice02_1.setRows(data.getRows(),"deptCdPath");    	
				treeView_DeptChoice02_1.expandAll();
				}
		} catch(e) {
			argoAlert(e);			
		}
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
			
			var arrChecked = treeView_DeptChoice02_1.getCheckedRows(false);			
				$.each(arrChecked, function( index, value ) {
					arrIds.push(dataProvider_DeptChoice02_1.getValue(value,"deptCd"));
					arrNms.push(dataProvider_DeptChoice02_1.getValue(value,"deptNm"));
				 });
				fvRltIds = arrIds.join(',');
				fvRltNms = arrNms.join(', ');
			} else {
				var index = treeView_DeptChoice02_1.getCurrent();
				fvRltIds = dataProvider_DeptChoice02_1.getValue(index.dataRow,"deptCd");
				fvRltNms = dataProvider_DeptChoice02_1.getValue(index.dataRow,"deptNm");
				//fvRltNms = dataProvider_DeptChoice02_1.getValue(index.dataRow, "deptPath")+"/" + dataProvider_DeptChoice02_1.getValue(index.dataRow, "deptNm");
			}
			
			//***************호출한 화면에 선택한 코드 및 코드값 설정 처리 *****************************		
		 	var sOpener = window.frameElement.attributes["data-pid"].value ;
		 	var sOpenerType = window.frameElement.attributes["data-ptype"].value ;
		 	
		 	//2017-05-11 메뉴별 접근권한에 따라 선택이 없을 경우 공백이 아닌 접근권한에 따른 기본 조직 조건을 넘김 
		 	if (fvRltIds=="") fvRltIds = top.gMenu.GRANT_DEPT_CD ;
		
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
       <div class="blank_h20"></div>
          
                <div class="grid_area h58 pt0" >
                    <div id="grList_DeptChoice02_1" class="real_grid"></div>
                </div>
                <div class="btn_areaB txt_r">
                    <button type="button" id="btnConfirm_DeptChoice02" name="btnConfirm_DeptChoice02" class="btn_m confirm" >확인</button>   
            	</div>
            
        </section>
    </div>
</body>
</html>

