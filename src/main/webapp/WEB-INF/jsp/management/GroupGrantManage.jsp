<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script>
//공통 변수 세팅
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
var workMenu 	= "그룹별 권한관리";
var workLog 	= "";
var dataArray 	= new Array();
var vPartCd		= "";
var vMajorCd	= "";

$(function () {
	// 상단 버튼 이벤트
	$("#btnSave").click(function(){fnSave()});                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
	argoCbCreate("s_FindGrantId", "comboBoxCode", "getGrantList", {findTenantId:tenantId}, {"selectIndex":0, "text":'선택하세요!', "value":''});
	argoSetValue("s_FindGrantId", "GroupManager");
	argoDisable(true, "s_FindGrantId");
	fnInitGrid();
	fnSearchList();
	fnInitTree_DeptChoice();
});


function fnInitGrid(){
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        reorderRows:true,
        onChange: function (event) {
	       	var record = this.get(event.recid);
	       	var key = Object.keys(record);
	       	if(key[event.column] == "grantYn"){
	       		event.preventDefault();
	       	}
        },
        onClick: function (event) {
	       	var record = this.get(event.recid);
	       	var key = Object.keys(record);
	       	if(argoNullConvert(key[event.column]) != ""){
	       		fnInitTree_DeptChoice(record);
	       	}
        },
        columns: [  
				 	 { field: 'recid', 			caption: '', 					size: '0%', 						sortable: false, attr: 'align=center' }
				 	,{ field: 'tenantId', 	 	caption: '', 					size: '0%', 						sortable: false, attr: 'align=center' }
				 	,{ field: 'code', 	 		caption: '그룹코드', 			size: '0%', 						sortable: false, attr: 'align=center' }
        	 		,{ field: 'codeNm', 		caption: '그룹명', 				size: '60%', 						editable:{ type:"text" }, sortable: false, attr: 'align=left' }
        	 		,{ field: 'grantYn', 		caption: '권한 등록여부', 		editable:{ type:"checkbox" },		size: '100px', 		sortable: false, attr: 'align=center' }
       	],
        records: dataArray
    });
	w2ui['grid'].hideColumn('recid', 'code', 'tenantId');
	//w2ui['grid'].hideColumn('codeId' );
}



var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
var workMenu 	= "그룹별 권한관리";
var workLog 	= "";
function fnSearchList(){
	//jsleecomboBoxCode.getGroupGrantList
	var findGrantId = argoGetValue("s_FindGrantId");
	var multiService = new argoMultiService(fnCallbackSearchList);
	multiService.argoList("comboBoxCode", "getGroupGrantList", "__", {findTenantId:tenantId, grantId:findGrantId, controlAuth:controlAuth}) 	
	multiService.action();
	
}

function fnCallbackSearchList(data, textStatus, jqXHR){
	try {
		
		if(data.isOk()){
			w2ui.grid.clear();
			if(data.getRows(0) != ""){
				dataArray = [];
				$.each(data.getRows(0), function( index, row ) {
					gObject2 = {  "recid" 			: index
								, "tenantId"		: row.tenantId
			    				, "code"			: row.code
			   					, "codeNm"	  		: row.codeNm
			   					, "grantYn"			: row.grantCnt!=0?true:false
								};
					dataArray.push(gObject2);
				});
				w2ui['grid'].add(dataArray);
	        }
	    }
	} catch(e) {
		console.log('error fnCallbackSearchList() : ' + e);
	}
}

	
	

/* function fnSearchList(){
	console.log("tenantId : " + tenantId);
	console.log("grantId : " + argoGetValue("s_FindGrantId"));
	console.log("userId : " + userId);
	console.log("controlAuth : " + controlAuth);
	var findGrantId = argoGetValue("s_FindGrantId");
	
	
	argoJsonSearchList('comboBoxCode', 'getGroupGrantList2', '_', {findTenantId:tenantId, grantId:findGrantId, controlAuth:controlAuth}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getProcCnt() == 0){
					return;
				}
				w2ui.grid.clear();
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
									, "tenantId"		: row.tenantId
				    				, "code"			: row.code
				   					, "codeNm"	  		: row.codeNm
				   					, "grantYn"			: row.grantCnt!=0?true:false
									};
						dataArray.push(gObject2);
					});
					w2ui['grid'].add(dataArray);
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
} */
	

	
	

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//그리드 편집내역 저장
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
function fnSave(){
	
	var arrChecked = w2ui['grid'].getSelection();
	
	if(arrChecked.length == 0){
		argoAlert("좌측의 그룹을 선택해 주세요.");
		return;
	}
	
	var selectedNodes = $('#trList_DeptChoice01').jstree('get_selected', true);
    var targetDeptCdArr = selectedNodes.map(function (node) {
        return node.id;
    });
    var targetDeptCds = targetDeptCdArr.join(",");
    var grantId = argoGetValue("s_FindGrantId");	
    
    
	argoConfirm("선택한" + arrChecked.length + "건에 대하여 대상소속 청취권한을 부여하시겠습니까?", function(){
	 	try{
	 		var multiService = new argoMultiService(fnCallbackSave);
	 		
	 		$.each(arrChecked, function(idx, value){
	 			var param = { 
					"tenantId":w2ui.grid.get(value).tenantId, 
					"grantId":grantId,
					"groupId":w2ui.grid.get(value).code,
					"targetDeptCds":targetDeptCds,
					"userId":userId
				};
	 			multiService.argoDelete("recSearch", "delRecGroupGrant", "__", param);
	 			if(argoNullConvert(targetDeptCds) != ""){
	 				multiService.argoInsert("recSearch", "insRecGroupGrant", "__", param);	 				
	 			}
	 		});
	 		
	 		/* w2ui.grid.records.forEach(function(obj, index) {
				var param = { 
					"tenantId":argoNullConvert(obj.tenantId), 
					"grantId":grantId,
					"groupId":argoNullConvert(obj.code),
					"targetDeptCds":targetDeptCds,
					"userId":userId
				};
				
				
				
				
 				multiService.argoDelete("recSearch", "delRecGroupGrant", "__", param);
				multiService.argoInsert("recSearch", "insRecGroupGrant", "__", param);
 	    	}); */
			multiService.action();
	    }catch(e){
	 		console.log(e)
	 	}			    						
	});
}	

function fnCallbackSave(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	argoAlert('성공적으로 저장 하였습니다.');
	    	fnSearchList();
	    }
	} catch(e) {
		console.log(e);    		
	}
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 조직조회
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function fnInitTree_DeptChoice(record){
	var selectGroupId = "";
	var selectTenantId = "";
	if(argoNullConvert(record) != ""){
		selectGroupId = record.code;
		selectTenantId = record.tenantId;	
	}
	$('#trList_DeptChoice01').jstree('destroy');
	//argoJsonSearchList('ARGOCOMMON','SP_UC_GET_DEPT','__', {}, fnCallbackGetTreeList_DeptChoice);
	var multiService = new argoMultiService(fnCallbackGetTreeList_DeptChoice);
	multiService.argoList("ARGOCOMMON", "SP_UC_GET_DEPT", "__", {tenantId:tenantId}) 
		        .argoList("recSearch", "getRecGroupGrantList", "__", {tenantId:selectTenantId, groupId:selectGroupId});			
	multiService.action();
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 조직트리 생성
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function fnCallbackGetTreeList_DeptChoice(data, textStatus, jqXHR){
	try {
		if(data.isOk()){
			if(data.getRows(0) != ""){
				deptRows = data.getRows(0);
				deptGrantRows = data.getRows(1);
				var obj = new Object();
				var itemArray = new Array();
	          
				$.each(deptRows, function( index, row ) {
	            	
	            	if (row.hasDeptAuth == "Y") {
		            	
	            		var parentDeptCd = row.parentDeptCd ;
		            	if (parentDeptCd == null || parentDeptCd.length==0) parentDeptCd = "#";

		            	obj = new Object();
			            	obj.id     = row.deptCd  ;
			            	obj.parent = parentDeptCd;
			            	//obj.text   = row.deptNm + ' [' + row.agentCnt  +'명]'; //조직명[인원수]
			            	obj.text   = row.deptNm; //조직명
			            	
			            	
			            	/* var dsGrep = $.grep( deptGrantRows, function(n,i){
			            		debugger;
			            		return (n.groupId == row.deptCd);
			        		}); */
			            	var chkYn = false;
			            	$.each(deptGrantRows, function(idx, value){
			            		if(value.controlledGroupId == obj.id){
			            			chkYn = true;
			            		}
			            	});
			            	
			            	obj.state  = { "selected" : chkYn ,  "opened" : true  };
			            	
			            	/* if(chkYn == "Y"){
			            		obj.state  = { "selected" : true ,  "opened" : true  };
			            	}else{
			            		obj.state  = { "selected" : false ,  "opened" : true  };
			            	} */
			            	
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
	            	
	            	/* if(fvMultiYn!='Y') {
		            	var node = $(e.target).closest("li");
						fvRltIds = node[0].id ;
		            	fnSetDeptSingleChoice() ;
		            	$("#btnConfirm_DeptChoice01").trigger('click');
	            	} */
       			 })	
				.jstree({
					'core' : {
						'multiple' :true,
						'data' : itemArray
					}
				    ,"plugins" : ["checkbox"]
				    , "checkbox" : {"keep_selected_style" : false} /* 멀티 선택일 경우 background 칼라등  사용안함*/
				});	

	        }
	    } else {
	    	console.log('fnCallbackGetTreeList_DeptChoice01 : no data');
	    }
	} catch(e) {
		console.log('error fnCallbackGetTreeList_DeptChoice01() : ' + e);
	}
}




</script>
 
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt0">
	            <div style="height: 100%">        	
	                <div class="per33_l" style="width: 50%">
	                    <div class="pop_btn">
	                       	<select id="s_FindGrantId" name="s_FindGrantId" style="width:100px;" class="list_box mt5"></select>
	                        <span class="btn_l pt11" style="color:red; font-size:8pt; font-weight:bold; position: relative;">※ 그룹매니저 권한에 한하여 청취권한이 부여됩니다.</span>
	                    </div>	
	                    <div class="grid_area h35 pt0" >
	                        <div id="grList" class="real_grid"></div>
	                    </div>
	                </div>
	                <div class="per33_l" style="width: 50%">
	                	<div class="pop_btn">
	                        <span class="btn_r pt5">
	                            <button type="button" id="btnSave" class="btn_sm save">저장</button>
	                        </span>
	                    </div>	
                        <div class="tree_area h35 pt0">
			                <div id="trList_DeptChoice01" >
			                </div>
			            </div>
	                </div>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>
