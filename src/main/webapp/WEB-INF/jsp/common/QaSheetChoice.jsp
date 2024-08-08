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
//공통 변수 세팅
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가표선택";
var workLog 	= "";
var dataArray 	= new Array();

var fvTargetObjId ; //호출화면의 INPUT Object Name
var fvTargetObjNm ; //호출화면의 INPUT Object Name
var fvMultiYn ="N"; //멀티여부 - Y 이면 멀티선택 허용

var fvRltIds =""; // 리턴값(Ids)
var fvRltNms =""; // 리턴값(Names))
var fvStdMonth ="";
var fvSheetId = "";
var fvSheetNm = "";
var flag = "";
	$(function () {		
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 호출 화면의 정보 설정
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
	    fvTargetObjId 	= sPopupOptions.targetObj+"Id" ;
	    fvTargetObjNm 	= sPopupOptions.targetObj+"Nm" ;
	    fvMultiYn     	= sPopupOptions.multiYn;

	 	fnInitCtrl_SheetChoice();
	 	fnInitGrid_SheetChoice();
	 	fnSearchList_SheetChoice();
	});
	
	function fnInitCtrl_SheetChoice(){
		//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 버튼 이벤트
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	     
		$("#btnSearch_SheetChoice").click(function(){			
			fnSearchList_SheetChoice();
		});
		
	     $("#btnConfirm_SheetChoice").click(function(){			
			fnSetUserChoice();
			//argoPopupClose();
		});
	}

	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	function fnInitGrid_SheetChoice(){

		$('#grList_SheetChoice_1').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: false,
	            selectColumn: fvMultiYn=="N"?false:true
	        },
	        multiSelect: fvMultiYn=="N"?false:true,
	        onDblClick: function(event) {
	        	if( fvMultiYn!='Y') {
	        		var record = this.get(event.recid);
	        		fvSheetId = record.sheetId;
	        		fvSheetNm = record.sheetNm;
    	    		$("#btnConfirm_SheetChoice").trigger('click');
    	    	}
	        },
	        columns: [  
				 	 { field: 'recid', 				caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
	       	 		,{ field: 'sheetId', 	 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
	       	 		,{ field: 'sheetNm', 			caption: '평가표 제목', 	size: '60%', 	sortable: true, attr: 'align=left' }
	       	 		,{ field: 'sheetTotalScore', 	caption: '평가표 배점', 	size: '13%', 	sortable: true, attr: 'align=center' }
	       	 		,{ field: 'hideYn', 			caption: '사용여부', 		size: '10%', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center' }
	       	 		,{ field: 'valueYn', 			caption: '평가여부', 		size: '10%', 	editable:{ type:"checkbox" }, sortable: true, attr: 'align=center' }
	       	 		,{ field: 'agentNm', 			caption: '작성자', 		size: '20%', 	sortable: true, attr: 'align=center' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid' );
		w2ui['grid'].hideColumn('sheetId' );
	}	
	
	//-------------------------------------------------------------
	//상담사 목록조회 
	//-------------------------------------------------------------	
	function fnSearchList_SheetChoice(){
		argoJsonSearchList('QA', 'SP_UC_GET_QA_SHEET', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					
					if(data.getProcCnt() == 0){
						argoAlert('조회 결과가 없습니다.');
						return;
					}
					
					dataArray = [];
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {  "recid" 	: index
			    				, "sheetId"			: row.sheetId
			   					, "sheetNm"	  		: row.sheetNm
			   					, "sheetTotalScore"	: row.sheetTotalScore
								, "hideYn"	  		: row.hideYn==0?true:false
								, "valueYn" 		: row.valueYn==1?true:false
								, "agentNm" 		: row.agentNm
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
	
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직선택값 호출 오브젝트에 설정 
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
	function fnSetUserChoice() {
		
		fvRltIds = "";
		fvRltNms ="";
		
		var arrIds = new Array();
		var arrNms = new Array();
		
		if( fvMultiYn=='Y') {
			var arrChecked = w2ui['grid'].getSelection();
		 	if(arrChecked.length==0) {
		 		argoAlert("적용할 평가표를 선택하세요") ; 
		 		return ;
		 	}
			
			$.each(arrChecked, function( obj, index ) {
				arrIds.push(w2ui['grid'].get(index).sheetId);
				arrNms.push(w2ui['grid'].get(index).sheetNm);
			});
			fvRltIds = arrIds.join(',');
			fvRltNms = arrNms.join(', ');
		} else {
			
			if(argoNullConvert(w2ui['grid'].get(w2ui.grid.getSelection()[0]).sheetTotalScore) == "0" || argoNullConvert(w2ui['grid'].get(w2ui.grid.getSelection()[0]).sheetTotalScore) == ""){
				argoAlert("배점이 0점인 평가표는 선택할 수 없습니다.");
				return;
			}
			
			if(argoNullConvert(fvSheetId) == ""){
				if(w2ui.grid.getSelection().length == 0){
					//flag == false;
					argoAlert("평가표를 선택해 주세요.");
					return;
				} 
				fvSheetId = w2ui['grid'].get(w2ui.grid.getSelection()[0]).sheetId;
			}
			
			if(argoNullConvert(fvSheetNm) == ""){
				fvSheetNm = w2ui['grid'].get(w2ui.grid.getSelection()[0]).sheetNm;
			}
			fvRltIds = fvSheetId;  
			fvRltNms = fvSheetNm;
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
        argoPopupClose();
	}
	
</script>

</head>

<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="btn_topArea">            	
                <span class="btn_l">                	
                    <ul class="search_terms">
<!--                         <li> -->
<!--                             <strong class="title ml5">기준년월</strong> -->
<!--                             <span class="yearMonth_date" id="d1"><input type="text" placeholder="년 - 월" class="input_ym onlyDate" id="s_StdMonth" name="s_StdMonth"><a href="#" class="btn_calendar">년/월 선택</a></span>    -->
<!--                         </li> -->
<!--                         <li> -->
<!--                            <strong class="title">평가분류</strong> -->
<!--                            <select id="s_QaTmKind" name="s_QaTmKind" style="width:95px;"> -->
<!--                             </select> -->
<!--                         </li>                                          -->
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