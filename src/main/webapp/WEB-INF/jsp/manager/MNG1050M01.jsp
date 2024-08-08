<%@ page language="java" pageEncoding="UTF-8"
	contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<%
	response.setHeader("X-Frame-Options", "SAMEORIGIN");
	response.setHeader("X-XSS-Protection", "1; mode=block");
	response.setHeader("X-Content-Type-Options", "nosniff");
%>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<link rel="stylesheet" href="<c:url value="/css/codemirror.min.css"/>" type="text/css" />
<style>
  /* 스타일을 수정하여 텍스트 에디터의 크기를 조정합니다. */
  .CodeMirror {
    height: 100%; /* 원하는 높이로 조정합니다. */
    font-size: 20px;
  }
  
  /* div{
	font-size: 20px;
  } */
  
  .CodeMirror-code > div {
	  font-size: 20px;
	  font-weight: bold;
  }
</style>

<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.spin.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/codemirror.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/sql.min.js"/>"></script>





<script type="text/javascript">
var workMenu 	= "관리자페이지";
var codeEditor;


$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnInitTree();
});

var vStdMonth = "";
function fnInitCtrl() {
	
	codeEditor = CodeMirror.fromTextArea(document.getElementById("ip_Txt"), {
    	lineNumbers: true, // 줄 번호 표시
    	mode: "text/x-sql", // 편집기 모드 설정 (HTML, CSS, JavaScript)
    	theme: "default" // 테마 설정 (옵션)
    });
	
	codeEditor.on("keydown", function (cm, e) {
        if (e.ctrlKey && e.keyCode == 13) {
        	fnSelect();
        }
    }); 
	
	//$(".CodeMirror-code").eq(0).find("div").css("font-size", "20px");
	//$(".CodeMirror-code").eq(0).find("div").css("font-weight", "bold");
	//codeEditor.getWrapperElement().style.fontSize = "50px"; // 폰트 크기 변경
	
	$(".btn_showHideW").on("click", function(){		
		($(".sub_contents").hasClass("side_hide")) ? $(".sub_contents").removeClass("side_hide") : $(".sub_contents").addClass("side_hide");
	})
	
	/* $("#btnExcelExport").click(function(){
		argoExcelExport(gridView, {"fileName":"조회결과.xlsx"} );
	}); */
	
	$("#btnExcel").click(function(){
		argoGridExlConvert(w2ui['grid'], workMenu);
	});	
	
	$("#btnExcute").click(function(){
		fnExcute();
	});
	
	$("#btnTreeHide").click(function(){
		fnTreeHideCtrl();
	});
	
	$("#btnInsert").click(function(){
		fnInsert();
	});
	
	$("#btnSelect").click(function(){
		fnSelect();
	});
	
	$("#s_Type").change(function(){
		fnInitTree();
	});
	
	$("#s_ObjNm").keydown(function(key){
		if(key.keyCode == 13){
			fnInitTree();
		}
	})
	
	
	$(".btn_avShowHide").on("click", function() {
		if ($(this).hasClass("on")) {
			$(this).removeClass("on");
			$('#top').removeClass("half23");
			$('#bottom').removeClass("half77");
			//codeEditor.setSize(null, 585);
			$('#top').addClass("half77");
			$('#bottom').addClass("half23");
			w2ui["grid"].reset();
		} else {
			$(this).addClass("on");
			$('#top').removeClass("half77");
			$('#bottom').removeClass("half23");
			//codeEditor.setSize(null, 150);
			$('#top').addClass("half23");
			$('#bottom').addClass("half77");
			w2ui["grid"].reset();
			//$('#bottom').addClass("half40");
		}
	});
	
}


function fnTreeHideCtrl(){
	if($("#mainContent").css("padding-left") == "0px"){
		$("#mainContent").css("padding-left", "430px");
		$("#treeDiv").css("display", "inline-block");
	}else{
		$("#mainContent").css("padding-left", "0px");
		$("#treeDiv").css("display", "none");
	}
	w2ui["grid"].reset();
}

//-------------------------------------------------------------
// 그리드 초기설정
//-------------------------------------------------------------
//var gridView     ;// 그리드 오브젝트
//var dataProvider ;// 그리드용 데이터 오브젝트

var dataArray 	= new Array();
var keys 	= new Array();
//그리드 헤더  및 옵션 세팅
function fnInitGrid(){
	$('#gridList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: true,
            selectColumn: false
        },
        multiSelect: true,
        columns: [  
			{ field: 'query', 			caption: '쿼리를 입력하세요', 		size: '100%', 	sortable: true, attr: 'align=center' }
       	],
        records: dataArray
    }); 
	
	fnGridTypeChange();
}

//-------------------------------------------------------------
// 트리 조회 및 생성
//-------------------------------------------------------------
function fnInitTree(){
	//TREE 리로드	
	$('#trList').jstree("destroy").empty();
	argoJsonSearchList('MNG','SP_MNG1050M01_01','s_', '', fnCallbackGetTreeList);
}

var fvNodeId, fvNodeTx, fvNodePid, fvNodeLevel;
var fvOrgNodeId = ''; //변경전 node Id
var fvOrgNodePid = ''; //변경전 부모 node
var fvOrgSortNo = ''; //변경전 순차번호
var fvIsNode = false; //Tree Node 구분
var xArray;
function fnCallbackGetTreeList(data, textStatus, jqXHR){
	try {
		if(data.isOk()){
			if(data.getRows() != ""){
				 xArray = new Array();
				deptRows = data.getRows();
				var itemArray = new Array();

				$.each(deptRows, function( index, row ) {
	            		var parentCd = row.parentCd ;
		            	if (parentCd == null || parentCd.length==0) parentCd = "#";
		            	var obj = new Object();
			            	obj.id     = row.grpId  ;
			            	obj.parent = row.parentCd;
			            	obj.text   = row.grpNm;
			            	obj.state  = { "selected" : false  ,  "opened" : true  };
			            	if(row.compileYn=="N"){
			            		xArray.push(row.grpId);
			            	}
			            	itemArray.push(obj);
	            });
				
				$('#trList').on("changed.jstree", function (e, data) {
					if(data.selected.length) {
						fvNodeId = data.instance.get_node(data.selected[0]).id ;
						fvNodeTx = data.instance.get_node(data.selected[0]).text;
						fvNodePid = data.instance.get_node(data.selected[0]).parent;
						fvNodeLevel = data.instance.get_node(data.selected[0]).parents.length;
					}
				}).on('show_contextmenu.jstree', function(e, reference, element) { // contextmenu 활성화시
					if(fvOrgNodeId != '') fnRemoveNode(fvOrgNodeId);
				    
				}).on("move_node.jstree", function(node, nodes){//노드이동시 변경순서등록
					fvIsNode = false; //노드이동 변경후 노드선택유무 false
				}).bind("loaded.jstree", function (event, data) {
					fnScrollMove();
					$.each(xArray, function(index, value){
						data.instance.set_icon(value, "../images/tree_x.png");
					});
				}).bind("click.jstree", function (e, data) { //클릭 이면 선택값 넘김
					fvIsNode = true;
					if(fvNodeLevel == 2){
						if(fvOrgNodeId != '') fnRemoveNode(fvOrgNodeId);
						
						// 초기상태 버튼 비활성화 (선택그룹이 있을경우 활성화 처리)
						argoDisable(false, 'btnDel,btnTarget');
						
						fnDetail(fvNodeId, fvNodePid);
					}
      			 }).jstree({
					'core' : {
						'multiple' :true ,
						"check_callback" : function(operation, node, node_parent, node_position, more) {
							if(operation == 'move_node') {
								//노드를 클릭해야 이동가능	
								if(!fvIsNode ){
									return false;
								}else{
									 if (node_parent.id == fvNodePid) return true //상위메뉴가 같은경우만 이동가능
			                         else return false;
								}		                            
	                        }else if(operation == 'create_node'){//노드생성시 부모도드 ID와 레벨값을 변수에 담아둔다
	                        	fvOrgNodePid = node_parent.id;
	                        }
	                    },
						'data' : itemArray
					}
      			, "plugins" : [ "contextmenu", "dnd", "search"]
				, "contextmenu" : { "items": customMenu }
				});
	        }
	    } else {
	    	console.log('fnCallbackGetTreeList : no data');
	    }
	} catch(e) {
		console.log('error fnCallbackGetTreeList : ' + e);
	}
}

var spinner;
function fnExcute(strQuery){
	//var ipTxtTrim = $.trim(argoGetValue("ip_Txt").replace(/\s+/g, '')).substring(0,6).toUpperCase();
	var ipTxtTrim = $.trim(codeEditor.getValue().replace(/\s+/g, '')).substring(0,6).toUpperCase();
	if(ipTxtTrim == "INSERT" || ipTxtTrim == "UPDATE"  || ipTxtTrim.substring(0,5) == "MERGE"){
		argoAlert("해당버튼은 TABLE, PROCEDURE, FUNCTION 관리로 사용해주세요.") ; 
		return;
	}else{
		var target = document.getElementById('foo');
		spinner = new Spinner().spin(target);
		$.ajax({
			type : 'post',
			//data : {"strQuery" : (strQuery==null?argoGetValue("ip_Txt"):strQuery), "type" : "exeQuery"},
			data : {"strQuery" : (strQuery==null?codeEditor.getValue():strQuery), "type" : "exeQuery"},
			url : gGlobal.ROOT_PATH + '/manager/workLogic.do',
			dataType : 'json',
			timeout : (60000*30),		//30분
			success : function(data) {
				fnExcuteCallback(data);
				spinner.stop();
			},
			error : function(xhr, status, error) {
				argoAlert("Error : " + error); 
				console.log("Error : " + error);
			}
		});
		fnInitTree();
	}
}

function fnInsert(strQuery){
	
	
	//var ipTxtTrim = $.trim(argoGetValue("ip_Txt").replace(/\s+/g, '')).substring(0,6).toUpperCase();
	//var ipTxtTrim = $.trim(codeEditor.getValue().replace(/\s+/g, '')).substring(0,6).toUpperCase();
	var ipTxtTrim = $.trim(codeEditor.getValue().replace(/\s+/g, '')).substring(0,15).toUpperCase();
	
	//if(ipTxtTrim.substring(0,4) == "CALL" || ipTxtTrim == "INSERT" || ipTxtTrim == "UPDATE"  || ipTxtTrim.substring(0,5) == "MERGE" || ipTxtTrim == "DELETE"){
	if(ipTxtTrim != "CREATEORREPLACE"){	
		var target = document.getElementById('foo');
		spinner = new Spinner().spin(target);
		$.ajax({
			type : 'post',
			data : {"strQuery" : (strQuery==null?codeEditor.getValue():strQuery), "type" : "insert"},
			url : gGlobal.ROOT_PATH + '/manager/workLogic.do',
			dataType : 'json',
			timeout : (60000*30),		//30분
			success : function(data) {
				fnExcuteCallback(data);
				spinner.stop();
			},
			error : function(xhr, status, error) {
				argoAlert("Error : " + error); 
				console.log("Error : " + error);
			}
		});
		fnInitTree();
		return;
	}else{
		argoAlert("해당버튼으로는 create or replace 명령어를 사용할 수 없습니다.") ; 
		return;
	}
}

function fnSelect(){
	//$('#gridList').w2grid().columns = {};
	var target = document.getElementById('foo');
	spinner = new Spinner().spin(target);
	$.ajax({
		type : 'post',
		//data : {"strQuery" : argoGetValue("ip_Txt"), "type" : "SELECT"},
		data : {"strQuery" : codeEditor.getValue(), "type" : "SELECT"},
		url : gGlobal.ROOT_PATH + '/manager/workLogic.do',
		dataType : 'json',
		timeout : (60000*2),		//2분
		success : function(data) {
			spinner.stop();
			fnSelectCallback(data.rs)
		},
		error : function(xhr, status, error) {
			argoAlert("Error : " + error); 
			console.log("Error : " + error);
		}
	});
}

function fnSelectCallback(data){
	if(data.length == 0){
		w2ui.grid.clear();
		$('#gridList').w2grid().columns = {};
		var columns = new Array();
		columns.push({field:"자료가없습니다", caption:"자료가없습니다.", size:"100%", sortable:true, attr:"align=center"});
		$('#gridList').w2grid().columns = columns;
	}else{
		var columns = new Array();
		$.each(Object.keys(data[0]), function(index, value){
			columns.push({field: value, caption: value, size: '25%', sortable: true, attr: 'align=center' });                         
		});
		
		$('#gridList').w2grid().columns = {};
		$('#gridList').w2grid().columns = columns;
		
		w2ui.grid.clear();
		dataArray = [];
		for(var i = 0; i<data.length; i++){
		    data[i]["recid"] = i;
			dataArray.push(data[i]);
		}
		w2ui['grid'].add(dataArray);
		w2ui.grid.unlock();
	}
}

function fnExcuteCallback(data){
	$('#gridList').w2grid().columns = {};
	w2ui.grid.clear();
	if(data.cd=="S"){
		var columns = new Array();
		columns.push({field:"cd", caption:"성공여부", size:"25%", sortable:true, attr:"align=center"});
		$('#gridList').w2grid().columns = {};
		$('#gridList').w2grid().columns = columns;
		dataArray = [];
		data["recid"] = 0;
		dataArray.push(data);
		w2ui['grid'].add(dataArray);
		w2ui.grid.unlock();
	}else{
		var columns = new Array();
		columns.push({field:"cd", caption:"성공여부", size:"25%", sortable:true, attr:"align=center"});
		columns.push({field:"msg", caption:"에러메시지", size:"80%", sortable:true, attr:"align=center"});
		$('#gridList').w2grid().columns = {};
		$('#gridList').w2grid().columns = columns;
		data["recid"] = 0;
		dataArray = [];
		dataArray.push(data);
		w2ui['grid'].add(dataArray);
		w2ui.grid.unlock();
	}
}

function fnDetail(objNm, type){
	debugger;
	var param = {"objNm" : objNm, "type" : type}
	argoJsonSearchList("MNG", "SP_MNG1050M01_02", "_", param, function(data, textStatus, jqXHR){
		var text='';
		
		$.each(data.getRows(), function(i, v){
			text+=v.text;
		});
		//argoSetValue("ip_Txt", text);
		
		codeEditor.setValue(text); 
	});
	
	
	
	/* if(type == "table"){
		argoJsonSearchList("MNG", "SP_MNG1050M01_02", "_", param, function(data, textStatus, jqXHR){
			var text='';
			
			$.each(data.getRows(), function(i, v){
				text+=v.text;
			});
			//argoSetValue("ip_Txt", text);
			
			codeEditor.setValue(text); 
		});
	} */
	
}

function dragResize(){
	var h = $('.drag_bar').css('top');
	var c = $('.sub_wrap').height();
	var vh = 0;
	h = parseInt(h);				
	var bH = c-h-28;	
	($(".btn_avShowHide").hasClass("on")) ?  vh = 30 : vh =163 ;
	$('.grid_resizeArea').height(h - vh);
	$('.textarea_resize').height(bH);
}

function textareaResize(obj){
	obj.style.height = "1px";
	obj.style.height = (obj.scrollHeight)+"px";
}

function customMenu(node) {
    var items = {
		compileItem: {
			label: "컴파일",
            action: function (node) {
           		try{
           			var strQuery = "ALTER  "+fvNodePid+" "+fvNodeId+" COMPILE"; 
           			fnExcute(strQuery);
           		}catch(e){
           			console.log(e);
           		}         
           	},
   			"icon" : gGlobal.ROOT_PATH+"/images/icon_conEdit.png"
		},
		excuteItem:{
			label: "실행",
			action: function (node) {
				var strQuery = "SELECT  ARGUMENT_NAME,DATA_TYPE,IN_OUT,SEQUENCE, '' AS DATA FROM all_arguments"
			    				    +" WHERE  object_id ="
		    				        + " (SELECT object_id FROM user_objects" 
									+" WHERE object_name = '"+ fvNodeId+"'"
		    				        +" AND object_type ='PROCEDURE')"
		    				        +" ORDER BY Sequence";
				gPopupOptions = {strQuery : strQuery} ;   	
				argoSmallPopupWindow($("#btnExcelExport"),'PL/SQL 실행', 'MNG1050S01F.do', '424', '300' );
			},
   			"icon" : gGlobal.ROOT_PATH+"/images/icon_conDelete.png"
		}
    };

    if (fvNodeLevel == 1) {
        delete items.compileItem;
        delete items.excuteItem;
    }
    if(fvNodePid !='PROCEDURE'){
    	delete items.compileItem;
        delete items.excuteItem;
    }
    
    return items;
}

function fnScrollMove(){
	var node = document.getElementById(fvNodeId);
	if(node!=null){
		$('#trList').jstree('select_node', fvNodeId);
		$('.tree_area').scrollTop(fvScrollTop);
		 
	}
}

var fvScrollTop;
function fnCallbackCompile(Resultdata, textStatus, jqXHR){
	try{
	    if(Resultdata.isOk()) {
	    	fvScrollTop = $('.tree_area').scrollTop();
			$('#trList').jstree("destroy").empty();
			fnInitTree();
	    }
	} catch(e) {
		console.log(e);    		
	}
}

function fnGridTypeChange(){
	var sGridType = argoGetValue("s_GridSelectType");
	//sGridType = argoNullConvert(sGridType)==""?"cell":sGridType;
	w2ui.grid.selectType = sGridType;
	w2ui.grid.reset();
}

</script>

</head>
<body>
	<div class="sub_wrap">
		<div id='foo'></div>
		<div class="location">
			<span class="location_home">HOME</span><span class="step">시스템관리</span><strong
				class="step">관리자페이지</strong>
		</div>
		<section class="sub_contents side_hide">
			<div class="sub_l fix430 h0" id="treeDiv" style="height: 98%">
				<div class="btn_topArea">
					<div class="top_inputBox text-center">
						<select name="s_Type" id="s_Type" style="width: 120px; background-color: white;">
							<option value="">전체</option>
							<option value="TABLE">TABLE</option>
							<option value="PROCEDURE">PROCEDURE</option>
							<option value="FUNCTION">FUNCTION</option>
							<option value="SEQUENCE">SEQUENCE</option>
							<option value="TRIGGER">TRIGGER</option>
						</select> <input type="text" id="s_ObjNm" name="s_ObjNm" placeholder="오브젝트명">
						<!-- <button type="button" id="btn_Search"  class="btn_termsSearch">검색</button> -->
					</div>
				</div>
				<div class="tree_area">
					<div id="trList"></div>
				</div>
			</div>
			<a href="#" class="btn_showHideW" style="display: none;">트리메뉴 숨기기</a>
			<div class="sub_r pl430 h20" id="mainContent">
				<div class="btn_topArea">
					<span class="btn_l">
						<button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel</button>
					</span> 
					<span class="btn_r">
						<button type="button" id="btnTreeHide" name="btnTreeHide" class="btn_m confirm">넓게 / 기본</button>
						<button type="button" id="btnInsert" name="btnInsert" class="btn_m confirm">쿼리실행</button>
						<button type="button" id="btnExcute" name="btnExcute" class="btn_m confirm">TABLE / PROCEDURE / FUNCTION / SEQUENCE</button>
						<button type="button" id="btnSelect" name="btnSelect" class="btn_m search">조회</button>
					</span>
				</div>
				<div class="grid_area h67 pt0">
					<div class="half23" id="top">
						<textarea rows="" cols="" id="ip_Txt" name="ip_Txt" style="height: 100%"></textarea>
					</div>
					<div class="btn_topArea fix_h30 avBtn_area" style="z-index: 9999;">
						<strong style="float: left; display: inline-block; margin-top: 18px;">그리드 선택방식</strong>
						<select name="s_GridSelectType" id="s_GridSelectType" onchange="fnGridTypeChange();" style="margin-left:5px; width: 150px;background-color: white;float: left;margin-top: 4px;position: relative;/* text-align: left; */">
							<option value="cell">셀별 선택 </option>
							<option value="row">행별 선택</option>
							<option value="column">열별 선택(칼럼클릭)</option>
							<!-- <option value="single">단일 선택</option> -->
							<!-- <option value="multi">다중 선택</option> -->
						</select>
						<a href="#" class="btn_avShowHide on" style="margin-top: 11px; position: relative; right: 83px;"></a>
						<!-- <a href="#" class="btn_avShowHide on"></a> -->
					</div>
					<div class="half77" id="bottom">
						<div id="gridList" style="width: 100%; height: 100%;"></div>
					</div>
				</div>
			</div>
		</section>
	</div>
</body>
</html>