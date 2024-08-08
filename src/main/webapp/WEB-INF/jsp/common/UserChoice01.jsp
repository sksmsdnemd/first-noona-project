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
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "상담사 선택";
var workLog 	= "";
var dataArray 	= new Array();

var fvTargetObjId ; //호출화면의 INPUT Object Name
var fvTargetObjNm ; //호출화면의 INPUT Object Name
var fvMultiYn ="N"; //멀티여부 - Y 이면 멀티선택 허용

var fvRltIds =""; // 리턴값(Ids)
var fvRltNms =""; // 리턴값(Names))

var fvAgentId = "";
var fvAgentNm = "";

	$(function () {

	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 호출 화면의 정보 설정
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
	 	// ADD BY YAKIM 2017-03-21 조직명을 포함하고 있을 경우 마지막 값 이름만 분리하여 검색 처리
	    var sSearchKey = sPopupOptions.searchKey ;
	    sSearchKey = sSearchKey.substring(sSearchKey.lastIndexOf('/')+1);
	    argoSetValue("spUserChoice01_UserInfo", argoNullConvert(sSearchKey));

	    fvTargetObjId = sPopupOptions.targetObj+"Id" ;
	    fvTargetObjNm = sPopupOptions.targetObj+"Nm" ;
	    fvMultiYn     = sPopupOptions.multiYn ;

	     
	     
	     
	     
	    //argoSetValue('spUserChoice01_UserInfo',sSearchKey );
	     
	    fnInitTree_UserChoice01();  // 트리 초기화
		fnInitGrid_UserChoice01();  //그리드 초기화
	     
	     
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 버튼 이벤트
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
		$("#btnSearch_UserChoice01").click(function(){
			fnSearchList_UserChoice01();
		});

		$("#btnMoveDown_UserChoice01").click(function(){
			fnMove_UserChoice01("down" , -1) ;
		});

		$("#btnMoveUp_UserChoice01").click(function(){
			fnMove_UserChoice01("up", -1) ;
		});

	     $("#btnConfirm_UserChoice01").click(function(){
			fnSetUserChoice();
			//parent.$('.btn_popClose').trigger('click') ;
			//$('.btn_popClose').trigger('click') ;

			//argoPopupClose();
			//$(window.frameElement.parentNode).closest('.pop_layer').remove();
		});

	  	$('#spUserChoice01_UserInfo').keydown(function(key){
	 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13)
	 			fnSearchList_UserChoice01();
	 		 }
		});
	  	
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 콤보박스 데이터 바인딩
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	    //argoCbCreate("s_TmKind", "ARGOCOMMON", "SP_UC_GET_CMCODE_01",{sort_cd:'TM_KIND'},{"selectIndex":0, "text":'<전체>', "value":''});

		
		
		fnSearchList_UserChoice01() ;
		
		
	})

	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직조회
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	function fnInitTree_UserChoice01(){
		argoJsonSearchList('ARGOCOMMON','SP_UC_GET_DEPT','__', {grantDeptCds:top.gMenu.GRANT_DEPT_CD, tenantId:tenantId}, fnCallbackGetTreeList_UserChoice01);
	}
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직트리 생성
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	var initDeptArray = new Array();
	function fnCallbackGetTreeList_UserChoice01(data, textStatus, jqXHR){
		try {
			if(data.isOk()){
				if(data.getRows() != ""){
					deptRows = data.getRows();

					var itemArray = new Array();

					$.each(deptRows, function( index, row ) {

		            	if (row.hasDeptAuth == "Y") {

		            		var parentDeptCd = row.parentDeptCd ;
			            	if (parentDeptCd == null || parentDeptCd.length==0) parentDeptCd = "#";

			            	var obj = new Object();
				            	obj.id     = row.deptCd  ;
				            	obj.parent = parentDeptCd;
				            	obj.text   = row.deptNm + '[' + row.agentCnt  +']'; //조직명[인원수]
				            	obj.state  = { "selected" : true  ,  "opened" : true  };
				            	initDeptArray.push(row.deptCd);
				            	itemArray.push(obj);
		            	}
		            });

		            var tempArray = new Array();
					tempArray.push(itemArray);

					$('#trList_UserChoice01').on("changed.jstree", function (e, data) {
						if(data.selected.length) {
							fvRltIds = data.instance.get_node(data.selected[0]).id ;
						}
					}).bind("dblclick.jstree", function (e, data) { //싱글옵션이고 더블클릭 이면 선택값 넘기면 화면닫기

			            	var node = $(e.target).closest("li");
							fvRltIds = node[0].id ;
			            	//fnSearchList_UserChoice01() ;

          			 })
					.jstree({
						'core' : {
							'multiple' :true ,
							'data' : itemArray
						}
					    ,"plugins" : ["checkbox" ]
					    , "checkbox" : {"keep_selected_style" :false} /* 멀티 선택일 경우 background 칼라등  사용안함*/
					});
		        }

				//fnSearchList_UserChoice01();//자동조회
			} else {
		    	console.log('fnCallbackGetTreeList_UserChoice01 : no data');
		    }
		} catch(e) {
			console.log('error fnCallbackGetTreeList_UserChoice01() : ' + e);
		}
	}

	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	function fnInitGrid_UserChoice01(){

		$('#grList_UserChoice01_1').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: false,
	            selectColumn: true
	        },
	        multiSelect: true,
	        onDblClick: function(event) {
	        	
	        	
	        	if( fvMultiYn!='Y') {
	        		var record = this.get(event.recid);
	        		fvAgentId = record.agentId;
	        		fvAgentNm = record.agentNm;
    	    		$("#btnConfirm_SheetChoice").trigger('click');
    	    	}else{
    	    		fnMove_UserChoice01("down" , -1) ;	
    	    	}
	        	
	        },
	        onClick: function(event) {
	        },
	        columns: [  
				 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
				 	,{ field: 'deptCd', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
				 	,{ field: 'deptPath', 	 	caption: '소속', 			size: '60%', 	sortable: true, attr: 'align=left' }
				 	,{ field: 'agentId', 		caption: '사번', 			size: '20%', 	sortable: true, attr: 'align=center' }
	       	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '20%', 	sortable: true, attr: 'align=center' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid' );
		w2ui['grid'].hideColumn('deptCd' );
		
		
		$('#grList_UserChoice01_2').w2grid({ 
	        name: 'grid2', 
	        show: {
	            lineNumbers: true,
	            footer: false,
	            selectColumn: true
	        },
	        multiSelect: true,
	        onDblClick: function(event) {
	        	fnMove_UserChoice01("up", -1) ;
	        },
	        onClick: function(event) {
	        },
	        columns: [  
				 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
				 	,{ field: 'deptCd', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
				 	,{ field: 'deptPath', 	 	caption: '소속', 			size: '50%', 	sortable: true, attr: 'align=left' }
				 	,{ field: 'agentId', 		caption: '사번', 			size: '20%', 	sortable: true, attr: 'align=center' }
	       	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '25%', 	sortable: true, attr: 'align=center' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid2'].hideColumn('recid' );
		w2ui['grid2'].hideColumn('deptCd' );
		 
	
	}

	//-------------------------------------------------------------
	//상담사 목록조회
	//-------------------------------------------------------------
	function fnSearchList_UserChoice01(){
		var arrDepts = $("#trList_UserChoice01").jstree("get_selected");
		if(arrDepts.length == 0){
			arrDepts = initDeptArray;
		}
		var sDeptIds =  arrDepts.join(',');
	 	if(sDeptIds=="") sDeptIds = groupId ;
	 	
	 	var param = { "dept1Id":sDeptIds}; 
		argoJsonSearchList('ARGOCOMMON', 'SP_UC_GET_AGENT', 'spUserChoice01_', param, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if(data.getProcCnt() == 0){
						return;
					}
					
					dataArray = [];
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {  "recid" 			: index
					    				, "deptCd"			: row.agentNm
					   					, "agentId"	  		: row.agentId
										, "deptPath" 		: row.deptPath
										, "agentNm" 		: row.agentNm							
										};
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
					/* if(w2ui['grid'].getSelection().length == 0){
						w2ui['grid'].click(0,0);
					} */
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

	function fnCallbackGet_UserChoice01(data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				dataProvider_UserChoice01_1.clearRows();
				if(data.getRows() != ""){
					//필드 오브젝트 최초 생성
					if(dataProvider_UserChoice01_1.getFields().length==0) {
						var  fields = Object.keys( data.getRows()[0] );
						dataProvider_UserChoice01_1.setFields(fields);
						dataProvider_UserChoice01_2.setFields(fields);
					}
					dataProvider_UserChoice01_1.setRows(data.getRows());
	
					//ADD BY 2017-03-09 검색결과 1건일 경우 자동 선택 처리
					var count = data.getRows().length;
					if(count==1) fnAdd_UserChoice01(0) ;
				}
		    }
		} catch(e) {
			argoAlert(e);
		}
	}
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 상담사 선택 처리 (move up/down)
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	function fnMove_UserChoice01(sUpDown, nIndex) {

		if(sUpDown=="down") { // 상담사선택
			var arrChecked = w2ui['grid'].getSelection();
		 	if(arrChecked.length==0) {
		 		return ;
		 	} 
		 	
		 	var arr2 = w2ui['grid2'].records;
		 	dataArray = [];
		 	
			$.each(arrChecked, function( obj, index ) {
				var dupChk = true;
				for(var j = 0; j<arr2.length; j++){
					if(w2ui['grid'].get(index).agentId == arr2[j].agentId){
						dupChk = false;
						return;
					}
				}
				
				if(dupChk == true){
					var idx = 0;
					w2ui.grid2.records.forEach(function(obj, idx2) {
						var recid	 	= obj.recid;
						idx = w2ui['grid2'].records.length+1
						if(recid >= idx){
							idx = idx + 1
						}
				    });
					
					gObject2 = {  "recid" 			: index
			    				, "deptCd"			: w2ui['grid'].get(index).deptCd
			   					, "agentId"	  		: w2ui['grid'].get(index).agentId
			   					, "deptPath"		: w2ui['grid'].get(index).deptPath
			   					, "agentNm"			: w2ui['grid'].get(index).agentNm
					};
					dataArray.push(gObject2);	
				}
			});
			w2ui['grid2'].add(dataArray);
			w2ui['grid'].click();
			w2ui['grid2'].click();

		}else {		//상담사선택 취소
			var arrChecked = w2ui['grid2'].getSelection();
		 	if(arrChecked.length==0) {
		 		return ;
		 	}
		 	w2ui["grid2"].delete(w2ui.grid2.getSelection());
		 	w2ui['grid'].click();
		}
	}

	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 상담사 중복체크 및 추가
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	function fnAdd_UserChoice01(nIndex) {
		// 중복체크
		var sSearchId = dataProvider_UserChoice01_1.getValue(nIndex, "agentId");

	    var values = [sSearchId];

	    var options = {
	        fields: ["agentId"],
	        values: values,
	        startIndex: 0,
	        caseSensitive: false,
	        partialMatch: false, /* 완전일치 */
	        wrap: true,
	        select: false
	    }

	    var itemindex = gridView_UserChoice01_2.searchItem(options);

		if(itemindex <0 ) {
			if( fvMultiYn!='Y') { //싱글이면 기존 선택 건 삭제 후 추가
				dataProvider_UserChoice01_2.clearRows();
			}
			dataProvider_UserChoice01_2.addRow(dataProvider_UserChoice01_1.getValues(nIndex));
		}
		else console.log("중복입니다.") ;
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
		 	w2ui['grid2'].records.forEach(function(obj, idx){
		 		arrIds.push(obj.agentId);
		 		arrNms.push(obj.agentNm);
			});
			fvRltIds = arrIds.join(',');
			fvRltNms = arrNms.join(', ');
		} else {
			w2ui['grid2'].records.forEach(function(obj, idx){
		 		arrIds.push(obj.agentId);
		 		arrNms.push(obj.agentNm);
			});
			fvRltIds = arrIds.join(',');
			fvRltNms = arrNms.join(', ');
			
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
		
		/* fvRltIds = "";
		fvRltNms ="";
		if(dataProvider_UserChoice01_2.getRowCount()>0) {

		   if(fvMultiYn=='Y') {
				fvRltIds = dataProvider_UserChoice01_2.getFieldValues("agentId");
				fvRltIds = fvRltIds.join(',');

				fvRltNms = dataProvider_UserChoice01_2.getFieldValues("agentNm");
				fvRltNms = fvRltNms.join(', ');

			}else {
				fvRltIds = dataProvider_UserChoice01_2.getValue(0,"agentId");
				// 싱글선택 일 경우 조직정보를 포함하여 리턴하나 onlyNm = 'Y' 일 경우 이름만 넘기도록 함
				if(sPopupOptions.onlyNm=='Y') fvRltNms =  dataProvider_UserChoice01_2.getValue(0, "agentNm") ;
				else fvRltNms = dataProvider_UserChoice01_2.getValue(0, "deptPath")+"/" + dataProvider_UserChoice01_2.getValue(0, "agentNm")
			}
		}

		//***************호출한 화면에 선택한 코드 및 코드값 설정 처리 *****************************

	 	var sOpener = window.frameElement.attributes["data-pid"].value ;
	 	var sOpenerType = window.frameElement.attributes["data-ptype"].value ;

        if(sOpenerType == "M" ) {//메인 화면에서 호출시
	 		$("#"+fvTargetObjId, parent.document).val(fvRltIds);
			$("#"+fvTargetObjNm, parent.document).val(fvRltNms).trigger('change');
            //$("#"+fvTargetObjNm, parent.document).trigger('change');
	     }else { //팝업에서 호출시
	    	 $("#"+fvTargetObjId, parent.frames[sOpener].document).val(fvRltIds);
	    	 $("#"+fvTargetObjNm, parent.frames[sOpener].document).val(fvRltNms);
	     } */

	}

</script>

</head>

<body>
	<div class="sub_wrap pop">
		<section class="pop_contents">
			<div class="sub_l fix290 pl17">
				<div class="btn_topArea"></div>
				<div class="tree_area h67">
					<div id="trList_UserChoice01"></div>
				</div>
			</div>
			<div class="sub_r pl270">
				<div class="btn_topArea">
					<span class="btn_l"> 
					<input type="text" id="spUserChoice01_UserInfo" name="spUserChoice01_UserInfo" style="width: 250px;" placeholder="행번 또는 성명을 입력하세요."> 
					<input type="checkbox" id="spUserChoice01_RetireYn" name="spUserChoice01_RetireYn" data-defaultChecked=false value="1"><label for="spUserChoice01_RetireYn" class="ml15">퇴직자 포함</label> 
					</span> <span class="btn_r"><button type="button" id="btnSearch_UserChoice01" name="btnSearch_UserChoice01" class="btn_m search">조회</button></span>
				</div>
				<div class="pop_cont">
					<div class="grid_area pt0 fix_h265">
						<div id="grList_UserChoice01_1" class="real_grid"></div>
					</div>
					<div class="btn_areaM">
						<a href="#" id="btnMoveDown_UserChoice01" class="btn_sm down">down</a>
						<a href="#" id="btnMoveUp_UserChoice01" class="btn_sm up">up</a>
					</div>
					<div class="grid_areapt0 br_b fix_h207">
						<div id="grList_UserChoice01_2" class="real_grid"></div>
					</div>
					<div class="btn_areaB txt_r">
						<button type="button" id="btnConfirm_UserChoice01" name="btnConfirm_UserChoice01" class="btn_m confirm">확인</button>
					</div>
				</div>
			</div>
		</section>
	</div>
</body>
</html>

