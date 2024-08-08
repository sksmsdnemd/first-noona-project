<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<script type="text/javascript">
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var userName    = loginInfo.SVCCOMMONID.rows.userName;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;
var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
var workMenu 	= "통화내역조회사유확인";
var workLog 	= "";
var dataArray 	= new Array();
var gPopupOptions;
$(document).ready(function() {
	fnInitCtrl();
	fnInitGrid();
	fnSearchListCnt();
});

function fnInitCtrl(){
	
	$("#s_RecFrmTm").prop("readonly", false);
	$("#s_RecEndTm").prop("readonly", false);
	$("#s_CallFrmTm").prop("readonly", false);
	$("#s_CallEndTm").prop("readonly", false);
	
	argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList", {}, {
		"selectIndex" : 0,
		"text" : '선택하세요!',
		"value" : ''
	});
	
	argoCbCreate("#s_ReasonCode", "ARGOCOMMON", "getBaseCodeList", {sort_cd : 'REC_SEARCH_REASON_CD'}, {
		"selectIndex" : 0,
		"text" : '선택하세요!',
		"value" : ''
	});
	
	/* $('#s_FindGroupId').append($('<option>', {
	    value: "",
	    text: "선택하세요!"
	})); */
	argoSetDeptChoice("btn_Group1", {"targetObj" : "s_FindGroup","multiYn" : 'N'}); //조직선택 팝업 연결처리(멀티)
			
	$('#s_FindMarkKind').append($('<option>', {
	    value: "",
	    text: "선택하세요!"
	}));
	
	
	$('#s_SoliKind').append($('<option>', {
	    value: "",
	    text: "선택하세요!"
	}));
	
	argoSetDatePicker();
	$('.timepicker.rec').timeSelect({
		use_sec : true
	});
	
	var termValList  = '<spring:eval expression="@code['Globals.termValList']"/>';
	var termValArr = termValList.split("|");
	var jData = [];
	for (var i = 0; i < termValArr.length; i++) {
		var text = termValArr[i].split(":");
		var arrTxt = {};
		arrTxt.codeNm = text[0];
		arrTxt.code = text[1];

		// 시간대별 제외
		if(text[1] != "S_1"){
			jData.push(arrTxt);	
		}
		
	}
	argoSetDateTerm('selDateTerm1', {
		"targetObj" : "s_txtDate1",
		"selectValue" : "M_1"
	}, jData);
	argoSetDateTerm('selDateTerm2', {
		"targetObj" : "s_InsrtDate",
		"selectValue" : "M_1"
	}, jData);
	
	$("#s_FindTenantId").change(function() {
		fnSetSubCb('tenant');
	});
	
	$("#btn_Search").click(function(){
		fnSearchListCnt();
	});
	
	$("#btnConfirm").click(function(){
		fnConfirm();
	});
	
	$("#btnConfirmAll").click(function(){
		fnConfirmAll();
	});
	
	argoCbCreate("s_SoliKind", "comboBoxCode", 
		"getUserDnGubunList", {}, {
		"selectIndex" : 0,
		"text" : '선택하세요!',
		"value" : ''
	});
	
	if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
		$("#div_tenant").hide();
	}
	argoSetValue("s_FindTenantId", tenantId);

	
	$('#clearButton').on('click', function() {
        argoSetValue("s_FindGroupId", "")
        argoSetValue("s_FindGroupNm", "")
    });
	
}

//평가건 완료
function fnConfirm() {
	var arrChecked = w2ui['grid'].getSelection();
 	if(arrChecked.length==0) {
 		argoAlert("확인처리할 항목을 선택하세요.") ; 
 		return ;
 	}
	//gSheetkey = new Array();
	var isCheck = true;
	
	$.each(arrChecked, function(index, value) {
		var sValue = w2ui['grid'].get(value).confirmYn;
		//저장상태만 완료 가능 하도록 수정 
		 if (sValue != false) {
		 	argoAlert("미확인건에 대해서만 확인처리가 가능합니다.");
		 	isCheck=false;
		 	return false;
		 }
	});
	
	if( isCheck ) {
		argoConfirm("확인 처리 하시겠습니까?", function(){
			try{
				var multiService = new argoMultiService(fnConfirmCallbackSave);
				$.each(arrChecked, function(index, value) {
					var insId 			= w2ui['grid'].get(value).insId;
					var searchReasonId  = w2ui['grid'].get(value).searchReasonId;
					var param = {"insId":insId, "searchReasonId":searchReasonId}
					multiService.argoUpdate("recSearch","searchReasonConfirm","_", param);
				});
				multiService.action();
			}catch(e){
				console.log(e);
			}
		});
	}
}

function fnConfirmCallbackSave(data, textStatus, jqXHR) {
	if (data.isOk()) {
		argoAlert("확인 처리 되었습니다.");
		fnSearchListCnt();
	}
}


//평가건 완료
function fnConfirmAll() {
	argoConfirm("미확인 건에 대하여 일괄확인 처리 하시겠습니까?", function(){
		try{
			var multiService = new argoMultiService(fnConfirmAllCallbackSave);
			multiService.argoUpdate("recSearch","searchReasonConfirmAll","_", {});
			multiService.action();
		}catch(e){
			console.log(e);
		}
	});
}

function fnConfirmAllCallbackSave(data, textStatus, jqXHR) {
	if (data.isOk()) {
		argoAlert("일괄확인 처리 되었습니다.");
		fnSearchListCnt();
	}
}


var dataPerPage=15; 
var pageCount=5;

function fnSearchListCnt(){
	dataPerPage = argoGetValue("s_SearchCount"); 
	argoJsonSearchOne('recSearch', 'getRecSearchReasonConfirmListCnt', 's_', {"controlAuth":controlAuth}, function(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				var totalData=data.getRows()['cnt'];
				$("#totCount").text(totalData);
				pagingConfirm(totalData, dataPerPage, pageCount, "1");
			}
		} catch (e) {
			console.log(e);
		}
	});
}

function fnSearchList(startRow, endRow){
	w2ui.grid.lock();
	argoJsonSearchList('recSearch', 'getRecSearchReasonConfirmList', 's_', {"controlAuth":controlAuth, "startRow":startRow, "endRow":endRow}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				w2ui.grid.clear();
				
				if(data.getProcCnt() == 0){
					return;
				}
				
				dataArray = [];
				if (data.getRows() != ""){ 
					$.each(data.getRows(), function( index, row ) {
						gObject2 = {  "recid" 				: index
									, "searchReasonId"	  	: row.searchReasonId
									, "confirmYn"	  		: row.confirmYn==1?true:false
									, "insDate"	  			: row.insDate
		       	 					, "insId"				: row.insId
		       	 					, "insNm"				: row.insNm
									, "reasonCode"			: row.reasonCode
				    				, "memo"				: row.memo
									, "confirmUserId" 		: row.confirmUserId
									, "confirmDate"	  		: row.confirmDate
									, "tenantId" 			: row.tenantId
									, "dnNo"				: row.dnNo
									, "soliKind" 			: row.soliKind
									, "userId"				: row.userId
									, "groupId" 			: row.groupId
									, "custName" 			: row.custName
									, "custTel" 			: row.custTel
									, "custNo" 				: row.custNo
									, "findField" 			: row.findField
									, "findFieldText" 		: row.findFieldText
									, "callKind" 			: row.callKind
									, "custEtc9" 			: row.custEtc9
									, "callId" 				: row.callId
									, "tranTel" 			: row.tranTel
									, "frmRecDate" 			: row.frmRecDate
									, "frmRecTm" 			: row.frmRecTm
									, "toRecDate" 			: row.toRecDate
									, "toRecTm" 			: row.toRecTm
									, "frmCallTm" 			: row.frmCallTm
									, "toCallTm" 			: row.toCallTm
									, "chkListeningYn" 		: row.chkListeningYn
									, "chkDownloadYn" 		: row.chkDownloadYn
									, "uptId" 				: row.uptId
									, "uptDate" 			: row.uptDate
						};
						dataArray.push(gObject2);
					});
					w2ui['grid'].add(dataArray);
				}
				if(w2ui['grid'].getSelection().length == 0){
					w2ui['grid'].click(0,0);
				}
			}
			
		} catch (e) {
			console.log(e);
		}
		
		workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
		+ ' | GrantId:' + grantId + '] 조회';
		argoJsonUpdate("actionLog", "setActionLogInsert", "s_", {
			tenantId : tenantId,
			userId : userId,
			actionClass : "action_class",
			actionCode : "W",
			workIp : workIp,
			workMenu : workMenu,
			workLog : workLog
		});
	});
	w2ui.grid.unlock();
}

function pagingConfirm(totalData, dataPerPage, pageCount, currentPage){

	var defaultYn="N";
	if(totalData==0){
		totalData=1;
		defaultYn="Y";
	}
   var totalPage = Math.ceil(totalData/dataPerPage);    // 총 페이지 수
   var pageGroup = Math.ceil(currentPage/pageCount);    // 페이지 그룹
   
   var last = pageGroup * pageCount;    // 화면에 보여질 마지막 페이지 번호

   if(last > totalPage)
       last = totalPage;
   
   var first = last - (pageCount-1);    // 화면에 보여질 첫번째 페이지 번호
   var next = last+1;
   var prev = first-1;
	if(last%pageCount==0){
		first =last - (pageCount-1);
	}else{
		first = last - ((last%pageCount)-1);
	}
	prev = first-1;
	if(first<1) first = 1
	
	
   var html = "";
   
    if(prev > 0){
        html += '<a href="#" class="first" id="first">first</a><a href="#" class="prev" id="prev">prev</a>';
    }
   
	html += '<ul class="paging">';

	for(var i=first; i <= last; i++){
		html += '<li><a href="#" id='+i+'>'+i+'</a></li>';
   }
   html +='</ul>';
   
   if(last < totalPage){
   		html += '<a href="#" class="next" id="next">next</a><a href="#" class="last" id="last">last</a>';
   }
   
   $("#paging").html(html);    // 페이지 목록 생성
   $("#paging a#" + currentPage).addClass("on");    // 현재 페이지 표시
   
   var startRow  = ((currentPage -1)*dataPerPage)+1;
   var endRow    = currentPage * dataPerPage;
   if(totalData!=0){
	  fnSearchList(startRow,endRow);
   }
   
   if(defaultYn=='N'){
	   $("#paging a").click(function(){
	       
	       var $item = $(this);
	       var $id = $item.attr("id");
	       var selectedPage = $item.text();
	       
	       if($id == "next")    selectedPage = next;
	       if($id == "prev")    selectedPage = prev;
	       if($id == "first")    selectedPage = 1;
	       if($id == "last")	 selectedPage = totalPage;
	       pagingConfirm(totalData, dataPerPage, pageCount, selectedPage);
	   });
   }
}


function fnSetSubCb(kind) {
	if (kind == "tenant") {
		if ($('#s_FindTenantId option:selected').val() == '') {
			/* $('#s_FindGroupId option').remove();
			$('#s_FindGroupId').append($('<option>', {
			    value: "",
			    text: "선택하세요!"
			})); */
					
			$('#s_FindMarkKind option').remove();
			$('#s_FindMarkKind').append($('<option>', {
			    value: "",
			    text: "선택하세요!"
			}));
			
			$('#s_FindField option').remove();
			$('#s_FindField').append($('<option>', {
			    value: "",
			    text: "선택하세요!"
			}));
					
		} else {
			/* argoCbCreate("s_FindGroupId", "comboBoxCode",
					"getGroupList", {
						findTenantId : $('#s_FindTenantId option:selected').val(),
						userId : userId,
						controlAuth : controlAuth,
						grantId : grantId
					}, {
						"selectIndex" : 0,
						"text" : '선택하세요!',
						"value" : ''
					}); */
			argoCbCreate("s_FindMarkKind", "comboBoxCode",
					"getMarkCodeList", {
						findTenantId : $('#s_FindTenantId option:selected').val()
					}, {
						"selectIndex" : 0,
						"text" : '선택하세요!',
						"value" : ''
					});
			
			
			fnFindFieldSet($('#s_FindTenantId option:selected').val());
			//fnGroupCbChange("s_FindGroupId");
		}
	} 
}

function fnInitGrid(){
	$('#grList').w2grid({ 
        name: 'grid', 
        show: {
            lineNumbers: true,
            footer: false,
            selectColumn: true
        },
        multiSelect: true,
        onChange: function (event) {
        	var record = this.get(event.recid);
        	var key = Object.keys(record);
        	if(key[event.column] == "confirmYn"){
        		event.preventDefault();
        	} 
        },
        columns: [  
			 	 { field: 'recid', 					caption: '', 				size: '0%', 		sortable: true, attr: 'align=center' }
			 	,{ field: 'searchReasonId', 		caption: '', 				size: '0%', 		sortable: true, attr: 'align=center' }
			 	,{ field: 'confirmYn', 				caption: '확인여부', 			size: '70px',  		editable:{ type:"checkbox" },	sortable: true, attr: 'align=center', frozen: true }
			 	,{ field: 'insDate', 				caption: '확인요청일자', 		size: '100px',  	sortable: true, attr: 'align=center', frozen: true }
			 	,{ field: 'insId', 					caption: '확인요청자ID', 		size: '0px',  		sortable: true, attr: 'align=center', frozen: true }
			 	,{ field: 'insNm', 					caption: '확인요청자', 		size: '150px',  	sortable: true, attr: 'align=center', frozen: true }
		       	,{ field: 'reasonCode', 			caption: '조회사유', 			size: '130px',  	sortable: true, attr: 'align=center', frozen: true }
		       	,{ field: 'memo', 					caption: '조회사유상세', 		size: '200px',  	sortable: true, attr: 'align=left', frozen: true }
		       	,{ field: 'confirmUserId', 			caption: '확인자', 			size: '150px',  	sortable: true, attr: 'align=center', frozen: true }
		       	,{ field: 'confirmDate', 			caption: '확인일자', 			size: '100px',  	sortable: true, attr: 'align=center', frozen: true }
		       	,{ field: 'tenantId', 				caption: '태넌트', 			size: '80px',  		sortable: true, attr: 'align=center' }
			 	,{ field: 'dnNo', 					caption: '내선번호', 			size: '100px',  	sortable: true, attr: 'align=center' }
			 	,{ field: 'soliKind', 				caption: '내선구분', 			size: '80px', 		sortable: true, attr: 'align=center' }
			 	,{ field: 'userId', 	 			caption: '상담사', 			size: '80px', 		sortable: true, attr: 'align=center' }
       	 		,{ field: 'groupId', 				caption: '그룹', 				size: '120px',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'custName', 				caption: '고객명', 			size: '80px',  		sortable: true, attr: 'align=center' }
       	 		,{ field: 'custTel', 				caption: '전화번호', 			size: '120px',  	sortable: true, attr: 'align=center' }
       	 		,{ field: 'custNo', 				caption: '고객번호', 			size: '130px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'findField', 				caption: '추가검색어', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'findFieldText', 			caption: '입력 추가검색어', 		size: '120px',  	sortable: true, attr: 'align=left' }
		       	,{ field: 'callKind', 				caption: '통화구분', 			size: '80px',  		sortable: true, attr: 'align=center' }
		       	,{ field: 'custEtc9', 				caption: '마킹구분', 			size: '80px',  		sortable: true, attr: 'align=center' }
		       	,{ field: 'callId', 				caption: '콜아이디', 			size: '150px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'tranTel', 				caption: '호전환 번호', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'frmRecDate', 			caption: '녹취시작일자', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'frmRecTm', 				caption: '녹취시작시간', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'toRecDate', 				caption: '녹취종료일자', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'toRecTm', 				caption: '녹취종료시간', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'frmCallTm', 				caption: '통화시작시간', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'toCallTm', 				caption: '통화종료시간', 		size: '100px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'chkListeningYn', 		caption: '녹취권한-청취', 		size: '130px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'chkDownloadYn', 			caption: '녹취권한-다운로드', 	size: '130px',  	sortable: true, attr: 'align=center' }
		       	,{ field: 'uptId', 					caption: '수정자', 			size: '0px',  		sortable: true, attr: 'align=center' }
		       	,{ field: 'uptDate', 				caption: '수정일자', 			size: '0px',  		sortable: true, attr: 'align=center' }

		       	//jslee
       	],
        records: dataArray
    });
	
	w2ui['grid'].hideColumn('recid' );
	w2ui['grid'].hideColumn('searchReasonId' );
	w2ui['grid'].hideColumn('insId' );
	w2ui['grid'].hideColumn('uptId' );
	w2ui['grid'].hideColumn('uptDate' );
}

function fnFindFieldSet(tenantId) {
	argoJsonSearchList('recSearch', 'getRecSearchFiledList', 's_', {"findTenantId" : tenantId},function(data, textStatus, jqXHR) {
        try {
            if (data.isOk()) {
            	$('#s_FindField option').remove();
            	$('#s_FindField').append($('<option>', {
    			    value: "",
    			    text: "선택하세요!"
    			}));
            	
               	var colName;
                var colTitle;
				var strOption = "";
                $.each(data.getRows(), function(index, row) {
                    colName = "custEtc" + row.fieldId;
                    colTitle = row.fieldName;
                    strOption += '<option id="' + colName + '" value="' + colName + '">' + colTitle + '</option>';
                });
                
                $('#s_FindField').append(strOption);
                /* if ($('#s_FindField').find("option").length < 2) {
                    $('#s_FindField').append(strOption);
                } */
            }
        } catch (e) {
            console.log(e);
        }
    });
}




/* function fnUserChoice(){
	var timesId = argoGetValue("#s_TimesId").replace(/,/gi,'\',\'');
	oOptions = {"targetObj" : "s_Qaa","multiYn" : 'Y', "jikchkCd":"50"};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
    $("#s_QaaNm").focusout(function(){
 		if($("#s_QaaNm").val().trim()=='')  $("#s_QaaId").val('') ;
	});	
    
	oOptions['searchKey'] = argoGetValue("s_QaaNm");
	gPopupOptions = oOptions;	
	argoPopupWindow('직책별 상담사 선택', gGlobal.ROOT_PATH+'/common/UserChoice03F.do', '900', '600');
} */

</script>

</head>
<body>
		<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">통화내역조회</span><strong
				class="step">통화내역조회사유 확인</strong>
		</div>
        <section class="sub_contents">
            <div class="search_area row6">
            	<div class="row">
                    <ul class="search_terms">
                    	<li>
	                    	<strong class="title ml20">확인요청일자</strong>
							<span class="select_date"> 
								<input type="text" class="datepicker onlyDate" id="s_InsrtDate_From" name="s_InsrtDate_From"> 
							</span>
							<span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span>
							<span class="select_date"> 
								<input type="text" class="datepicker onlyDate" id="s_InsrtDate_To" name="s_InsrtDate_To">
							</span>
							<select id="selDateTerm2" name="" style="width: 70px;" class="mr5"></select>
						</li>
                    	
                    	<li class="pt3">
                    		<strong class="title" style="margin-left:33px;">확인여부</strong>
                       		<span class="checks" ><input type="radio" id="group1" name="s_Gbn"  value=""><label for="group1">전체</label></span>
                            <span class="checks ml15"><input type="radio" id="group2" name="s_Gbn"  value="1"><label for="group2">확인</label></span>
                            <span class="checks ml15"><input type="radio" id="group3" name="s_Gbn" checked value="0"><label for="group3">미확인</label></span>
                        </li> 
                    	
                        <li id="div_tenant">
                           <strong class="title ml20" style="margin-left: 40px !important;">태넌트</strong>
                           <select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select>
                        </li>
                        <!-- <li>
                           <strong class="title ml20">확인여부</strong> 
	                       <select id="s_FindConfirmYn" name="s_FindConfirmYn" style="width: 140px" class="list_box">
								<option value="">선택하세요!</option>
								<option value="1">확인</option>
								<option value="0">미확인</option>
							</select>
                        </li> -->
                        
                        
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                           <strong class="title ml20">내선번호</strong>
                           <input type="text" id="s_FindDnText" name="s_FindDnText" style="width: 140px" class="clickSearch" />
                        </li>
                        <li>
							<strong class="title ml20">내선구분</strong>
							<select id="s_SoliKind" name="s_SoliKind" style="width: 140px" class="list_box"></select>
							<!-- <input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" />
							<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1"> -->
						</li>
						<li>
                           <strong class="title ml20">상담사</strong>
                           <input type="text" id="s_FindUserNameText" name="s_FindUserNameText" style="width: 140px" class="clickSearch" />
                        </li>
                        <!-- <li>
	                        <strong class="title ml20">그룹</strong>
							<select id="s_FindGroupId" name="s_FindGroupId" style="width: 261px" class="list_box"></select>
						</li> -->
						<!-- <li>
                        	<strong class="title ml20">그룹</strong>
                        	<input type="text" id="s_FindGroupNm" name="s_FindGroupNm" style="width:237px;" readonly>
                        	<button type="button" class="btn_termsSearch" id="btn_Group1">검색</button>
                        	<input type="hidden" id="s_FindGroupId" name="s_FindGroupId">
                        </li> -->
                        <li>
							<div class="input-wrapper" style="position: relative;">
	                        	<strong class="title ml20">그룹</strong>
	                        	<input type="text" id="s_FindGroupNm" name="s_FindGroupNm" style="width:237px;" readonly><button type="button" class="btn_termsSearch" id="btn_Group1">검색</button>
	                        	
	                        	<button id="clearButton" 
		                        	style="position: absolute;
								    right: 27px;
								    top: 48%;
								    transform: translateY(-50%);
								    background-color: #FFFFFF;
								    color: #c2c4c7;
								    border: none;
								    cursor: pointer;">X</button>
	                        	<input type="hidden" id="s_FindGroupId" name="s_FindGroupId">
	                        </div>
                        </li>
                        
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                        	<strong class="title ml20">고객명</strong>
                        	<input type="text" id="s_FindCustNameText" name="s_FindCustNameText" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">전화번호</strong> 
							<input type="text" id="s_FindCustTelText" name="s_FindCustTelText" style="width: 140px" class="clickSearch" /> 
						</li>
						<li>
							<strong class="title ml20">고객번호</strong>
							<input type="text"id="s_FindCustNoText" name="s_FindCustNoText" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">추가검색어</strong> 
							<select id="s_FindField" name="s_FindField" style="width: 140px;" class="list_box">
								<option value="">== 추가검색어 ==</option>
							</select> 
							<input type="text" id="s_FindFieldText" name="s_FindFieldText" style="width: 120px" class="clickSearch" /> 
						</li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
	                        <strong class="title ml20">통화구분</strong> 
	                        <select id="s_FindCallKind" name="s_FindCallKind" style="width: 140px" class="list_box">
									<option value="">선택하세요!</option>
									<option value="1">Inbound</option>
									<option value="2">Outbound</option>
							</select>
						</li>
						<li>
							<strong class="title ml20">마킹구분</strong> 
							<select id="s_FindMarkKind" name="s_FindMarkKind" style="width: 140px" class="list_box"></select>
						</li>
						<li>
							<strong class="title ml20">콜아이디</strong> 
							<input type="text" id="s_FindCallIdText" name="s_FindCallIdText" style="width: 140px" class="clickSearch" />
						</li>
						<li>
							<strong class="title ml20">호전환 번호</strong>
							<input type="text" id="s_FindTranTelText" name="s_FindTranTelText" style="width: 140px" class="clickSearch" />
						</li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
	                        <strong class="title ml20">녹취일자</strong>
							<span class="select_date"> 
								<input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From">
							</span>
							<span class="timepicker rec" id="rec_time1"> 
								<input type="text" id="s_RecFrmTm" name="s_RecFrmTm" class="input_time" value="00:00:00"> <a href="#" class="btn_time">시간 선택</a></span> 
							<span class="text_divide" style="width: 234px">&nbsp; ~ &nbsp;</span>
							<span class="select_date"> 
								<input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To">
							</span>
							<span class="timepicker rec" id="rec_time2">
								<input type="text" id="s_RecEndTm" name="s_RecEndTm" class="input_time" value="23:59:59">
								<a href="#" class="btn_time">시간 선택</a>
							</span> &nbsp;
							<select id="selDateTerm1" name="" style="width: 70px;" class="mr5"></select>
						</li>
						<li>
							<strong class="title ml20">통화시간</strong> 
								<span class="timepicker rec" id="callFrmTm"> <input type="text" id="s_CallFrmTm" name="s_CallFrmTm" class="input_time" value="00:00:00"> 
								<a href="#" class="btn_time">시간 선택</a>
							</span> 
							<span class="text_divide">~</span>
							<span class="timepicker rec" id="callEndTm"> 
								<input type="text" id="s_CallEndTm" name="s_CallEndTm" class="input_time" value="23:59:59">
								<a href="#" class="btn_time">시간 선택</a>
							</span>
						</li>
                    </ul>
                </div>
                
                <div class="row">
                    <ul class="search_terms">
                        <li>
                        	<strong class="title ml20">녹취권한</strong>
                            <input type="checkbox" class="checkbox" id="s_ChkListeningYn" name="s_ChkListeningYn" value="Y" style="height:19px;">
                            <label for="chkListeningYn" style="width: 60px">청취</label>
                            <span style="width: 100px">&nbsp;&nbsp;</span>
                            <input type="checkbox" class="checkbox" id="s_ChkDownloadYn" name="s_ChkDownloadYn" value="Y" style="height:19px;">
                            <label for="chkDownloadYn" style="width: 60px">다운로드</label>
						</li>
						
						<li>
							<strong class="title ml20">조회사유</strong>
							<select id="s_ReasonCode" name="s_ReasonCode" style="width: 190px;"></select>
						</li>
                    </ul>
                </div>
                
            </div>   
            <div class="btns_top">
            	<div class="btns_tl">
            		<strong style="width: 25px">[ 전체 ]</strong> : <span id="totCount">0</span>
					<select id="s_SearchCount" name="s_SearchCount" style="width: 50px"
						class="list_box">
						<option value="200">200</option>
						<option value="100">100</option>
						<option value="50">50</option>
						<option value="30">30</option>
						<option value="15">15</option>
						<option value="5">5</option>
					</select>
				</div>
                <button type="button" class="btn_m search" id="btn_Search" data-grant="R">조회</button>
                <button type="button" class="btn_m confirm" id="btnConfirm" data-grant="W">확인</button>
                <button type="button" class="btn_m confirm" id="btnConfirmAll" data-grant="W">전체확인</button>
            </div>        
            <div class="h302">
                <div class="btn_topArea fix_h25"></div>
                <div class="grid_area h25 pt0">
                    <div id="grList" class="real_grid"></div>
                </div>
                <div class="list_paging" id="paging">
                	<ul class="paging">
                 		<li><a href="#" id='' class="on">1</a></li>
                 	</ul>
                </div>
            </div>            
        </section>
    </div>
</body>
</html>