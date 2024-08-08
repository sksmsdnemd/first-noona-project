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
var fvTargetObjId ; //호출화면의 조직코드    INPUT Object Name
var fvTargetObjNm ; //호출화면의 조직코드명 INPUT Object Name
var fvMultiYn ="N"; //멀티여부 - Y 이면 멀티선택 허용
var fvRltIds =""; // 리턴값(Ids)
var fvRltNms =""; // 리턴값(Names))
var fvParentYn ="Y" ; // 리턴시 상위코드를 포함할지 여부

var loginInfo   = JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;
var userId      = loginInfo.SVCCOMMONID.rows.userId;
var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
var groupId     = loginInfo.SVCCOMMONID.rows.groupId;

/* 
	이미 진행된 평가건인지 확인. 
	진행된 평가건일 시 소속코드를 넣을 때 기존 소속코드에 APPEND한다.
	진행되지 않은 평가건일 시 기존 소속코드 초기화 후 APPEND한다.
*/
var fvValueYn = "N"  


	$(function () {
		// 호출화면의 조직팝업 옵션 정보 
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
		};
	   
	    fvTargetObjId = sPopupOptions.targetObj+"Id" ;
	    fvTargetObjNm = sPopupOptions.targetObj+"Nm" ;
	    fvMultiYn     = sPopupOptions.multiYn ;

	    
	    // 부모창에 태넌트가 있을 시
	    if(argoNullConvert(parent.$("#s_FindTenantId").val()) != ""){
	    	tenantId = argoNullConvert(parent.$("#s_FindTenantId").val());
	    }
	    
	    // 평가표관리일 시
	    if(argoNullConvert(sPopupOptions.valueYn) != ""){
	   		fvValueYn = argoNullConvert(sPopupOptions.valueYn); 
	    }
	    // 평가계획관리일 시
	    else if($("#status", parent.document).text() == "진행"){
	    	fvValueYn = "Y";
	    }
	     
	    if(sPopupOptions.parentYn != undefined ) {		
			fvParentYn = sPopupOptions.parentYn;
		}
	  
		$("#btnConfirm_DeptChoice01").click(function(){			
			fnSetDeptChoice();
			argoPopupClose();
		});

		$("#btn_Search").click(function(){
			fnInitTree_DeptChoice01();
		});
		
		$('#s_GroupName').keyup(function(event) {
		    if (event.which === 13) { // Enter 키의 keyCode는 13입니다.
		    	fnInitTree_DeptChoice01();
		    }
		});
		
		fnInitTree_DeptChoice01();
	})

	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                                                                                                                                                            ━━━━━━━━━━━━━━━━━━━━━━━
	// 조직조회
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	function fnInitTree_DeptChoice01(){
		$('#trList_DeptChoice01').jstree('destroy');
		argoJsonSearchList('ARGOCOMMON','SP_UC_GET_DEPT','__', {tenantId:tenantId, grantDeptCds:top.gMenu.GRANT_DEPT_CD, groupName:argoGetValue("s_GroupName")}, fnCallbackGetTreeList_DeptChoice01);
	}
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직트리 생성
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	function fnCallbackGetTreeList_DeptChoice01(data, textStatus, jqXHR){
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
				            	obj.text   = row.deptNm + ' [' + row.agentCnt  +'명]'; //조직명[인원수]
				            	obj.state  = { "selected" : (fvMultiYn=='Y'? true : false) ,  "opened" : true  };
			            	
				            	itemArray.push(obj);
		            	}
		            }); 

		            var tempArray = new Array();
					tempArray.push(itemArray);
					
					$('#trList_DeptChoice01')
					.on("changed.jstree", function (e, data) {
						if(data.selected.length) {
							fvRltIds = data.instance.get_node(data.selected[0]).id ;
							//console.log('The selected node Nm is: ' + data.instance.get_node(data.selected[0]).text);
							//console.log('The selected node Id is: ' + data.instance.get_node(data.selected[0]).id);
						}
					}).bind("dblclick.jstree", function (e, data) { //싱글옵션이고 더블클릭 이면 선택값 넘기면 화면닫기
		            	
		            	if(fvMultiYn!='Y') {
			            	var node = $(e.target).closest("li");
							fvRltIds = node[0].id ;
			            	fnSetDeptSingleChoice() ;
			            	$("#btnConfirm_DeptChoice01").trigger('click');
		            	}
           			 })	
					.jstree({
						'core' : {
							'multiple' :(fvMultiYn=='Y'? true : false),
							'data' : itemArray
						}
					    ,"plugins" : [(fvMultiYn=='Y'? "checkbox" : "") ]
					    , "checkbox" : {"keep_selected_style" : (fvMultiYn=='Y'? false : true)} /* 멀티 선택일 경우 background 칼라등  사용안함*/
					});	

		        }
		    } else {
		    	console.log('fnCallbackGetTreeList_DeptChoice01 : no data');
		    }
		} catch(e) {
			console.log('error fnCallbackGetTreeList_DeptChoice01() : ' + e);
		}
	}	

	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직선택(싱글)
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
	function fnSetDeptSingleChoice() {
		if(fvRltIds =="") fvRltNms = "" ;
		else {
			fvRltNms = $("#trList_DeptChoice01").jstree("get_path",fvRltIds,'/') ; //path를 포함하여 리컨
			
			 // 조직명[인원수] 이므로 [인원수] 부분 제거
			 
			 var aRltNms = fvRltNms.split('/');
			 var arrDeptNms = new Array();
			 for (i = 0, j = aRltNms.length; i < j; i++) {
				 
					arrDeptNms.push(aRltNms[i].split('[')[0] );
	        }
			 
			 fvRltNms =  arrDeptNms.join('/'); 
			 
		}
	}
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직선택(멀티)
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
	function fnSetDeptMultyChoice() {
		 var arrSelDepts = $("#trList_DeptChoice01").jstree("get_selected");
		 
		 var arrDeptIds  = new Array();
		 var arrDeptNms = new Array();
		 
		   // 선택한 부서CD LOOP
			for (i = 0, j = arrSelDepts.length; i < j; i++) {
				// parent를 포함하여 리턴하는 경우  -----------------------------------------------------
				if(fvParentYn =="Y") {
				
					var arrParentsIds = $("#trList_DeptChoice01").jstree("get_node",arrSelDepts[i]).parents ; 
					
					var arrParentsNms = $("#trList_DeptChoice01").jstree("get_path",arrSelDepts[i]);
	
					// 선택한 id의  parent id도  중복체크 후 저장 
					$.each(arrParentsIds, function(x, el){
						if(el !="#") {
						if($.inArray(el, arrDeptIds) === -1) arrDeptIds.push(el);
						}
					});
	
					if($.inArray(arrSelDepts[i], arrDeptIds) === -1) arrDeptIds.push(arrSelDepts[i]);
					//arrDeptIds.push(arrSelDepts[i]) ; //선택 id 추가
	
					// 선택한 id의  parent을 포함하여  nm  중복체크 후 저장 
					$.each(arrParentsNms, function(y, el){
						var sDeptNm = el.split(' [')[0] ; // 조직명[인원수] 이므로 [인원수] 부분 제거	
						if($.inArray(sDeptNm, arrDeptNms ) === -1) {
							
							arrDeptNms.push(sDeptNm); 	
						}
					});
				}else {
					arrDeptIds.push(arrSelDepts[i]) ; //선택 id 추가
					var sDeptNm = $("#trList_DeptChoice01").jstree("get_text",arrSelDepts[i]).split('[')[0] ; // 조직명[인원수] 이므로 [인원수] 부분 제거	
					arrDeptNms.push(sDeptNm); 
				}
           }	
			 
			 fvRltIds =  arrDeptIds.join(',');
			 fvRltNms =  arrDeptNms.join(','); 
			 console.log(fvRltIds) ;
			 console.log(fvRltNms) ;
	}
	
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직선택(멀티)
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
	function fnSetDeptMultyChoice_Back() {
		 var arrDepts = $("#trList_DeptChoice01").jstree("get_selected");

		 var arrDeptNms = new Array();
		 
			for (i = 0, j = arrDepts.length; i < j; i++) {
				arrDeptNms.push($("#trList_DeptChoice01").jstree("get_text",arrDepts[i]) );
           }	
			
			fvRltIds =  arrDepts.join(',');
			
			// 조직명[인원수] 이므로 [인원수] 부분 제거			 
			 var arrDeptNms2 = new Array();
			 for (i = 0, j = arrDeptNms.length; i < j; i++) {
				 
					arrDeptNms2.push(arrDeptNms[i].split('[')[0] );
	        }
			 
			 fvRltNms =  arrDeptNms2.join(','); 		
	}
	
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 조직선택값 호출 오브젝트에 설정 
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
	function fnSetDeptChoice() {
		
		if(fvMultiYn=='Y') {
			fnSetDeptMultyChoice();		
		}else {
			fnSetDeptSingleChoice();
		}		
   
		//***************호출한 화면에 선택한 코드 및 코드값 설정 처리 *****************************	
		
		
	 	var sOpener = window.frameElement.attributes["data-pid"].value ;
	 	var sOpenerType = window.frameElement.attributes["data-ptype"].value ;
	 	
	 	//2017-05-11 메뉴별 접근권한에 따라 선택이 없을 경우 공백이 아닌 접근권한에 따른 기본 조직 조건을 넘김 
	 	if (fvRltIds=="") fvRltIds = top.gMenu.GRANT_DEPT_CD ;
	   
        if(sOpenerType == "M" ) {//메인 화면에서 호출시
	    	 if(fvValueYn == "Y"){
	    		var currentDeptCd = $("#"+fvTargetObjId, parent.document).val();
	    		var currentDeptNm = $("#"+fvTargetObjNm, parent.document).val();
	    		var removeDuplicateDeptCd = fnMergeAndRemoveDuplicates(currentDeptCd, fvRltIds, ",");
	    		var removeDuplicateDeptNm = fnMergeAndRemoveDuplicates(currentDeptNm, fvRltNms, ",");
	    		 
	    		$("#"+fvTargetObjId, parent.document).val(removeDuplicateDeptCd);
		 		$("#"+fvTargetObjNm, parent.document).val(removeDuplicateDeptNm);
	    		//$("#"+fvTargetObjId, parent.frames[sOpener].document).val(removeDuplicateDeptCd);
		    	//$("#"+fvTargetObjNm, parent.frames[sOpener].document).val(removeDuplicateDeptNm);
	    		 
	    	 }else{
	    		$("#"+fvTargetObjId, parent.document).val(fvRltIds);
	 			$("#"+fvTargetObjNm, parent.document).val(fvRltNms);
	    	 }
        	
	 		//$("#"+fvTargetObjId, parent.document).val(fvRltIds);
			//$("#"+fvTargetObjNm, parent.document).val(fvRltNms);
    	 
	     }else {
	    	 console.log("fvValueYn : " + fvValueYn);
	    	 if(fvValueYn == "Y"){
	    		 var currentDeptCd = $("#"+fvTargetObjId, parent.frames[sOpener].document).val();
	    		 var currentDeptNm = $("#"+fvTargetObjNm, parent.frames[sOpener].document).val();
	    		 var removeDuplicateDeptCd = fnMergeAndRemoveDuplicates(currentDeptCd, fvRltIds, ",");
	    		 var removeDuplicateDeptNm = fnMergeAndRemoveDuplicates(currentDeptNm, fvRltNms, ",");
	    		 console.log("currentDeptCd : " + currentDeptCd);
	    		 console.log("currentDeptNm : " + currentDeptNm);
	    		 $("#"+fvTargetObjId, parent.frames[sOpener].document).val(removeDuplicateDeptCd);
		    	 $("#"+fvTargetObjNm, parent.frames[sOpener].document).val(removeDuplicateDeptNm);
	    		 
	    	 }else{
		    	 //팝업에서 호출시
		    	 $("#"+fvTargetObjId, parent.frames[sOpener].document).val(fvRltIds);
		    	 $("#"+fvTargetObjNm, parent.frames[sOpener].document).val(fvRltNms);
	    	 }
	     }

	}
	
	// 중복 제거 및 합치기 함수
	function fnMergeAndRemoveDuplicates(value1, value2, splitGubun) {
		// 각 값을 배열로 변환
		var array1 = value1.split(splitGubun);
		var array2 = value2.split(splitGubun);
		
		// 배열 합치기 및 중복 제거
		var mergedArray = Array.from(new Set(array1.concat(array2)));
		
		// 콤마로 구분된 문자열로 변환하여 반환
		return mergedArray.join(splitGubun);
	}
	
	
	
</script>

</head>

<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">
        	<!-- <div class="blank_h20"></div> -->
            
            <div class="btn_topArea">
				<div class="top_inputBox text-center">
					<!-- <select name="s_Type" id="s_Type" style="width: 120px; background-color: white;">
						<option value="">전체</option>
						<option value="TABLE">TABLE</option>
						<option value="PROCEDURE">PROCEDURE</option>
						<option value="FUNCTION">FUNCTION</option>
						<option value="SEQUENCE">SEQUENCE</option>
					</select> --> 
					<input type="text" id="s_GroupName" name="s_GroupName" placeholder="소속명">
					<button type="button" id="btn_Search"  class="btn_termsSearch">조회</button>
				</div>
			</div>
            <div class="tree_area h70">
                <div id="trList_DeptChoice01" >
                </div>
            </div>
            <div class="btn_areaB txt_r">
                 <button type="button" id="btnConfirm_DeptChoice01" name="btnConfirm_DeptChoice01" class="btn_m confirm" >확인</button> 
            </div>           
        </section>
    </div>
</body>
</html>
