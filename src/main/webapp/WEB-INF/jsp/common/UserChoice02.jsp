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
		$("#btnSearch_UserChoice02").click(function(){			
			fnSearchList_UserChoice02();
		});
		
	     $("#btnConfirm_UserChoice02").click(function(){			
			fnSetUserChoice();
			argoPopupClose();
		});
	     
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 콤보박스 데이터 바인딩
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
	 	var sJikgup = top.gLoginUser.AGENT_JIKGUP ; //로그인사용자의 직급을 기본값으로 설정

	    argoCbCreate("spUserChoice02_AgentJikgup", "ARGOCOMMON", "SP_UC_GET_CMCODE_01",{sort_cd:'AGENT_JIKGUP'},{"selectValue":sJikgup});		  
		  
		fnInitGrid_UserChoice02(); //그리드 초기화
		
		if(sJikgup !="") {
		fnSearchList_UserChoice02() ;
		}
	});

	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	var gridView_UserChoice02_1,  dataProvider_UserChoice02_1 ;// 그리드상단

	function fnInitGrid_UserChoice02(){

	    dataProvider_UserChoice02_1 = new RealGridJS.LocalDataProvider(); 
	    gridView_UserChoice02_1 = new RealGridJS.GridView("grList_UserChoice02_1");
	    gridView_UserChoice02_1.setDataSource(dataProvider_UserChoice02_1);
	    
	   // argoSetGridStyle(gridView_UserChoice02_1); // 그리드 기본 스타일 적용 - 기본   
	   
	    argoSetGridStyle(gridView_UserChoice02_1, {"isPanel":false ,"isCheckBar":( fvMultiYn=='Y'? true: false),"isEditable":false, "isFooter":false }); // 그리드 기본 스타일 적용 - isPanel, isCheckBar, isEditable, isFooter
	    //ROW단위로 Selection
	    gridView_UserChoice02_1.setSelectOptions({
	    	 style: "rows"
	    });
	    
	   // 그리드 컬럼오브젝트 
	   var columns = [
	                  {
	                      name: "deptPath", //컬럼명
	                      fieldName: "deptPath",//dataProvider 의 필드명 
	                      header : {
	                          text: "소속"
	                      },
	                      width: 440
	                  },
	                  {
	                      name: "agentJikgupNm",
	                      fieldName: "agentJikgupNm",
	                      header : {
	                          text: argoGetConfig('JIKGUP')
	                      }
	                      , width: 100
	                  },
	                  {
	                      name: "sabun",
	                      fieldName: "sabun",
	                      header : {
	                          text: argoGetConfig('SABUN')
	                      },
	                      width: 100
	                  },
	                  {
	                      name: "agentNm",
	                      fieldName: "agentNm",
	                      header : {
	                          text: argoGetConfig('AGENT_NM')
	                      },
	                      width: 140
	                  }
	              ];
	              //컬럼을 GridView에 입력 합니다.
	            gridView_UserChoice02_1.setColumns(columns);
	           
	            // 그리드 더블클릭시 선택 처리  (싱글일 경우)
	    	    gridView_UserChoice02_1.onDataCellDblClicked = function (grid, index) {
	    	    	if( fvMultiYn!='Y') {
	    	    	//fnSetUserChoice(index.dataRow) ;
	    	    		$("#btnConfirm_UserChoice02").trigger('click');
	    	    	}
	   		    }
	}	
	
	//-------------------------------------------------------------
	//상담사 목록조회 
	//-------------------------------------------------------------	
	function fnSearchList_UserChoice02(){
	
	     gridView_UserChoice02_1.setAllCheck(false); // 그리드 헤더 체크  - unchecked 상태로
	 
		 argoGrSearch("dataProvider_UserChoice02_1", "ARGOCOMMON", "SP_UC_GET_AGENT_JIKGUP", "spUserChoice02_", {grantDeptCds:top.gMenu.GRANT_DEPT_CD}); 
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
			
			var arrChecked = gridView_UserChoice02_1.getCheckedRows(false);			
				$.each(arrChecked, function( index, value ) {
					arrIds.push(dataProvider_UserChoice02_1.getValue(value,"agentId"));
					arrNms.push(dataProvider_UserChoice02_1.getValue(value,"agentNm"));
				 });
				fvRltIds = arrIds.join(',');
				fvRltNms = arrNms.join(', ');
			} else {
				var index = gridView_UserChoice02_1.getCurrent();
				fvRltIds = dataProvider_UserChoice02_1.getValue(index.dataRow,"agentId");
				fvRltNms = dataProvider_UserChoice02_1.getValue(index.dataRow, "deptPath")+"/" + dataProvider_UserChoice02_1.getValue(index.dataRow, "agentNm");
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
                    <input type="text" id="spUserChoice02_UserInfo" name="spUserChoice02_UserInfo" style="width:250px;" placeholder="ID 또는 성명을 입력하세요.">
                    
                 <select id="spUserChoice02_AgentJikgup" name="spUserChoice02_AgentJikgup" style="width:95px;"></select>          
                </span>
                <span class="btn_r">
                     <button type="button" id="btnSearch_UserChoice02" name="btnSearch_UserChoice02" class="btn_m search" >조회</button>
                </span>
            </div>    
            <div class="pop_cont">            
                <div class="grid_area h38 pt0" >
                    <div id="grList_UserChoice02_1" class="real_grid"></div>
                </div>
                <div class="btn_areaB txt_r">
                    <button type="button" id="btnConfirm_UserChoice02" name="btnConfirm_UserChoice02" class="btn_m confirm" >확인</button>   
            	</div>
            </div>            
        </section>
    </div>
</body>
</html>

