<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<%-- <script type="text/javascript" src="<c:url value="/ProcessScript/QA/QA1030S01.js"/>?<%=Globals.DEPLOY_KEY()%>"></script> --%>

<script type="text/javascript">
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "평가대상 상담사 선택";
var workLog 	= "";
var dataArray 	= new Array();

$(function () {		
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 	// 호출 화면의 정보 설정
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

    $('#s_AgentNm').keyup(function(event) {
	    if (event.which === 13) { // Enter 키의 keyCode는 13입니다.
	    	fnSearchList01();
	    }
	});
    
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 	// 버튼 이벤트
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	     
	$("#btnSearch_QA1030S01").click(function(){			
		fnSearchList01();
	});
	
	$("#btnMoveAdd_QA1030S01").click(function(){			
		fnMove_QA1030S01("down" , -1) ;
	});

	$("#btnMoveRemove_QA1030S01").click(function(){			
		fnMove_QA1030S01("up", -1) ;
	});		
	
    $("#btnConfirm_QA1030S01").click(function(){			
    	fnSave_QA1030S01();
	});
  	
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 	// 콤보박스 데이터 바인딩
 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	     
	fnInitTree_QA1030S01();  // 트리 초기화
	fnInitGrid_QA1030S01(); //그리드 초기화
	
	//fnSearchList_QA1030S01();
	if(sPopupOptions.cudGubun == 'R') { //평가진행중이면 수정불가 처리
		//argoDisable(true, 'btnMoveAdd_QA1030S01,btnMoveRemove_QA1030S01,btnConfirm_QA1030S01');
		argoDisable(true, 'btnMoveRemove_QA1030S01');
	}
	
	// 초기 조회
	fnSearchList_QA1030S01();
})

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 조직조회
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
function fnInitTree_QA1030S01(){
	argoJsonSearchList('ARGOCOMMON','SP_UC_GET_DEPT','__', {grantDeptCds:top.gMenu.GRANT_DEPT_CD, tenantId:tenantId}, fnCallbackGetTreeList_QA1030S01);
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 조직트리 생성
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var itemArray = new Array();
var initDeptArray = new Array();
function fnCallbackGetTreeList_QA1030S01(data, textStatus, jqXHR){
	try {
		if(data.isOk()){
			if(data.getRows() != ""){
				deptRows = data.getRows();

				//var itemArray = new Array();
	          
				$.each(deptRows, function( index, row ) {
	            	
	            	if (row.hasDeptAuth == "Y") {
		            	
	            		var parentDeptCd = row.parentDeptCd ;
		            	if (parentDeptCd == null || parentDeptCd.length==0) parentDeptCd = "#";

		            	var obj = new Object();
			            	obj.id     = row.deptCd  ;
			            	obj.parent = parentDeptCd;
			            	obj.text   = row.deptNm;
			            	obj.state  = { "selected" : true  ,  "opened" : true  };
			            	initDeptArray.push(row.deptCd);
			            	itemArray.push(obj);
	            	}
	            }); 

	            var tempArray = new Array();
				tempArray.push(itemArray);
				
				$('#trList_QA1030S01')
				.on("changed.jstree", function (e, data) {
					if(data.selected.length) {
						fvRltIds = data.instance.get_node(data.selected[0]).id ;
					}
				}).bind("dblclick.jstree", function (e, data) { //싱글옵션이고 더블클릭 이면 선택값 넘기면 화면닫기
	            	
		            	var node = $(e.target).closest("li");
						fvRltIds = node[0].id ;
		            	fnSearchList_QA1030S01() ;
		            	
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
		} else {
	    	console.log('fnCallbackGetTreeList_QA1030S01 : no data');
	    }
	} catch(e) {
		console.log('error fnCallbackGetTreeList_QA1030S01() : ' + e);
	}
}	

function fnInitGrid_QA1030S01(){
	$('#grList_QA1030S01_1').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        onDblClick: function(event) {
        },
        onClick: function(event) {
        },
        columns: [  
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'deptCd', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'agentId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'deptInfo', 	 	caption: '소속', 			size: '60%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'sabun', 			caption: '사번', 			size: '20%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '20%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('deptCd' );
	w2ui['grid'].hideColumn('agentId' ); 
	
	
	$('#grList_QA1030S01_2').w2grid({ 
        name: 'grid2', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        onDblClick: function(event) {
        },
        onClick: function(event) {
        },
        columns: [  
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'deptCd', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'agentId', 		caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
			 	,{ field: 'deptInfo', 	 	caption: '소속', 			size: '50%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'sabun', 			caption: '사번', 			size: '25%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'agentNm', 		caption: '상담사명', 		size: '25%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    });
	
	w2ui['grid2'].hideColumn('recid' );
	w2ui['grid2'].hideColumn('deptCd' );
	w2ui['grid2'].hideColumn('agentId' ); 
}	

//-------------------------------------------------------------
//상담사 목록조회 
//-------------------------------------------------------------	
function fnSearchList_QA1030S01(){
	fnSearchList01();
	fnSearchList02();
}


function fnSearchList01(){
	var arrDepts = $("#trList_QA1030S01").jstree("get_selected");
	if(arrDepts.length == 0){
		arrDepts = initDeptArray;
	}
	var sDeptIds =  arrDepts.join(',');
	var timesId = sPopupOptions.pTimesId;   
	var qaaId = sPopupOptions.pQaaId;
	var type = 0;
 	
	if($("input:checkbox[id='check']").is(":checked")) type = 1;
 	var param = { "dept1Id":sDeptIds,"timesId": timesId, "qaaId":qaaId, type: type}; 
	
	argoJsonSearchList('QA', 'SP_QA1030S01_01', 's_', param, function (data, textStatus, jqXHR){
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
									, "deptInfo" 		: row.deptInfo
									, "sabun"	  		: row.sabun
									, "agentNm" 		: row.agentNm							
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
}


function fnSearchList02(){
	var arrDepts = $("#trList_QA1030S01").jstree("get_selected");
	if(arrDepts.length == 0){
		arrDepts = initDeptArray;
	}
	var sDeptIds =  arrDepts.join(',');
	var timesId = sPopupOptions.pTimesId;   
	var qaaId = sPopupOptions.pQaaId;
	var type = 0;
 	
	if($("input:checkbox[id='check']").is(":checked")) type = 1;
	//jslee
 	if(sDeptIds=="") sDeptIds = groupId ;
 	
 	var param = { "dept1Id":sDeptIds,"timesId": timesId, "qaaId":qaaId, type: type}; 
	
	
	argoJsonSearchList('QA', 'SP_QA1030S01_02', 's_', param, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid2.clear();
				if(data.getProcCnt() == 0){
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 			: index
				    				, "deptCd"			: row.deptCd
				   					, "agentId"	  		: row.agentId
									, "deptInfo" 		: row.deptInfo
									, "sabun"	  		: row.sabun
									, "agentNm" 		: row.agentNm				
									};
						dataArray.push(gObject2);
					});
					w2ui['grid2'].add(dataArray);
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
	fnSetChoiceCnt();
}


function fnSetChoiceCnt(){
	$('#choiceCnt').html(w2ui['grid2'].records.length) ;
}
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 상담사 선택 처리 (move up/down)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
function fnMove_QA1030S01(sUpDown, nIndex) {
	
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
				if(w2ui['grid'].get(index).sabun == arr2[j].sabun){
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
		   					, "deptInfo"		: w2ui['grid'].get(index).deptInfo
		   					, "sabun"			: w2ui['grid'].get(index).sabun
		   					, "agentNm"			: w2ui['grid'].get(index).agentNm
				};
				dataArray.push(gObject2);	
			}
		});
		w2ui['grid2'].add(dataArray);
		w2ui['grid'].click();
		w2ui['grid2'].click();
			
	}else {
		var arrChecked = w2ui['grid2'].getSelection();
	 	if(arrChecked.length==0) {
	 		return ;
	 	}
	 	w2ui["grid2"].delete(w2ui.grid2.getSelection());
	 	w2ui['grid'].click();
	}	
	fnSetChoiceCnt();
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 중복체크 및 추가
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		

function fnSave_QA1030S01(){	
try{
	if(w2ui['grid2'].records.length == 0){
		argoAlert("평가대상자를 추가하여 주세요.");
		return;
	}
	
	var multiService = new argoMultiService(fnCallbackSave);
	argoConfirm('선택한  ' + w2ui['grid2'].records.length + '명의 평가대상자를 <br>등록 하시겠습니까?', function() {
			// 기존 평가대상자 삭제
			multiService.argoDelete("QA","SP_QA1030M03_02","__",  {timesId:sPopupOptions.pTimesId, qaaId:sPopupOptions.pQaaId}); 
			
			w2ui['grid2'].records.forEach(function(obj, idx){
				multiService.argoInsert("QA","SP_QA1030S01_04","__",  {timesId:sPopupOptions.pTimesId, agentId:obj.agentId, qaaId:sPopupOptions.pQaaId});
			});
			
			multiService.action();
		});	
	} catch(e) {
		//argoAlert(e); 
		console.log(e) ;	 
	}
}

function fnCallbackSave(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {	  
	    	argoAlert('warning', '성공적으로 저장 되었습니다.','', 'parent.fnSearchList();argoPopupClose();');
	    	//argoAlert('warning', '성공적으로 저장 되었습니다.','', 'parent.fnSearchList2("'+sPopupOptions.pQaaId+'");argoPopupClose();');
	    }
	} catch(e) {
		argoAlert(e);    		
	}
}	

</script>

<style>
.pop_layer.small .pop_div{top:63px !important; left:180px !important;  }
</style>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0">
            	
                <div class="sub_l fix230 h0 top0 pt15 pr22">
                    <div class="tree_area h0">
 					 <div id="trList_QA1030S01" ></div>
                    </div>
                </div>
                
                <div class="sub_r pl230 h93">
                    <div class="search_area fix_h54">                        
                        <div class="row">
                            <ul class="search_terms">
                                <li>
                                	<strong class="title ml10" style="padding-right: 0px !important;">상담사명</strong>
                                	<input type="text" id="s_AgentNm" name="s_AgentNm" style="width:160px;" placeholder="상담사명을 입력해주세요.">
                                </li>
                            </ul>
                        </div>                
                    </div>
                    <div class="btns_top">
                    	<span class="btn_l" style="left: 0;  position: absolute;">
                    		<input type="checkbox" id="check" checked/><label for="check" class="ml20" >중복대상자 제외</label>
                    	</span>
                        <button type="button" id="btnSearch_QA1030S01" name="btnSearch_QA1030S01" class="btn_m search" >조회</button> 
                    </div>
                    <div class="cont_lr non_btn h45 clearfix">
                        <div class="btn_moves">
                        <button type="button" class="btn_add" id="btnMoveAdd_QA1030S01" >add</button>
                        <button type="button" class="btn_remove" id="btnMoveRemove_QA1030S01">remove</button>
                        </div>
                        <div class="sub_l per56_l">
                         <div class="grid_info"></div>
                            <div class="grid_area h25 pt0">
                               <div id="grList_QA1030S01_1" class="real_grid" ></div>
                            </div> 
                        </div>
                        <div class="sub_r per44_r">
                            <div class="grid_info"><span class="icon_dot"></span>선택인원 : <strong id="choiceCnt">0</strong>명</div>
                            <div class="grid_area h25 pt0">
                                <div id="grList_QA1030S01_2" class="real_grid"></div>
                            </div> 
                        </div>
                    </div>
                    <div class="btn_areaB txt_r">
                       <button type="button" id="btnConfirm_QA1030S01" name="btnConfirm_QA1030S01" class="btn_m confirm" >등록</button>  
                    </div>
              </div> 
                
            </div>            
        </section>
    </div>
</body>
</html>
