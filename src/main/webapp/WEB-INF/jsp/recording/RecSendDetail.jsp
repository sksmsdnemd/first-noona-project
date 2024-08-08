<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
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
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>

<script>
	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
	var userId	  	= loginInfo.SVCCOMMONID.rows.userId;
	var workIp		= loginInfo.SVCCOMMONID.rows.workIp;
	var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
	var depth		= loginInfo.SVCCOMMONID.rows.depth;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	var workMenu	= "녹취전송조회";
	var workLog	  	= "";
	var dataArray 	= new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
		
		$("#btnStat").click(function(){
			
			window.open(gGlobal.ROOT_PATH+"/recording/RecSendDetailStatF.do", "stat", "width=500,height=400,resizable=no,location=no");
		}) 
	});
	
	function fnInitCtrl(){ 
		
		argoSetDatePicker();
		$('.timepicker.rec').timeSelect({use_sec:true});
		
		fnArgoSetting();
		
		
		fnGroupCbChange("s_FindGroupId");

		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});
		

		$("#btnReset").click(function(){

			$('#s_FindSearchVisible option[value=""]').prop('selected', true);
			$('#s_FindSearch option[value=""]').prop('selected', true);
			$("#s_FindText").val('');
			
			fnArgoSetting();
		});

		$('#s_FindText').keydown(function(key){
	 		 if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		 }
		});
		 
		$("#s_FindKey").change(function(){
			var sSel = argoGetValue('s_FindKey');
			if(sSel == ""){
				$("#s_FindText").val("");
			}
			$("#s_FindText").focus();
			
		});
		
		$('.clickSearch').keydown(function(key){
			if(key.keyCode == 13){
				fnSearchListCnt();
			}
		});
		
		
		if(grantId == "Agent" || grantId == "GroupManager" || grantId == "Manager"){
			$("#div_tenant").hide();
		}
		argoSetValue("s_FindTenantId", tenantId);
	}
	
	function fnArgoSetting(){

		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		argoSetValue("s_FindSRegTime", "00:00:00");
		argoSetValue("s_FindERegTime", "23:59:59");
		argoCbCreate("s_FindTenantId", "comboBoxCode",
				"getTenantList", {}, {
				});
		argoCbCreate("s_FindUploadKind", "baseCode",
				"getBaseComboList", { "classId" :"upload_class"}, {
					"selectIndex" : 0,
					"text" : '전체',
					"value" : ''
				});
		$('#s_FindTenantId option[value="' + tenantId + '"]').prop('selected', true);
		$('#selDateTerm1 option[value="T_0"]').prop('selected', true);
	}
	
	function fnInitGrid(){


		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
// 	            lineNumbers: true,
// 	            footer: true,
// 	            selectColumn: true
	        },
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', hidden:true,	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'recTime', 		caption: '통화일자', 		size: '170px', 	sortable: true, attr: 'align=center', frozen : true}
// 	            		,{ field: 'tenantId', 		caption: '회사코드', 		size: '100px', 	sortable: true, attr: 'align=center', frozen : true}
	            		,{ field: 'userId', 		caption: '상담사ID', 		size: '80px', 	sortable: true, attr: 'align=center', frozen : true}
	            		,{ field: 'dnNo', 			caption: '내선번호', 		size: '80px', 	sortable: true, attr: 'align=center', frozen : true}
	            		,{ field: 'recKey', 		caption: 'REC_KEY', 	size: '150px', 	sortable: true, attr: 'align=center', frozen : true}
	            		,{ field: 'callId', 		caption: 'CALL ID', 	size: '150px', 	sortable: true, attr: 'align=center', frozen : true}
	            		,{ field: 'uploadKind', 	caption: 'UPLOAD_KIND', size: '100px', 	sortable: true, attr: 'align=center', frozen : true}
	            		,{ field: 'endTime', 		caption: 'endTime', 	size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'custTel', 		caption: '고객전화번호', 	size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'searchVisible', 	caption: '조회여부', 		size: '70px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'callTime', 		caption: 'callTime', 	size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'rxrtpcnt', 		caption: 'rxrtpcnt', size: '100px', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'txrtpcnt', 		caption: 'txrtpcnt', size: '100px', 	sortable: true, attr: 'align=center' }
                        ,{ field: 'rxfilesize', 	caption: 'rxfilesize', size: '100px', 	sortable: true, attr: 'align=center' }
                        ,{ field: 'txfilesize', 		caption: 'txfilesize', size: '100px', 	sortable: true, attr: 'align=center' }

	        ],
	        records: dataArray
	    });
		
	}
	
	function fnSearchListCnt(){
		
		if(argoGetValue('s_FindText') != ''){
			if(argoGetValue('s_FindSearch') == ''){
				argoAlert("검색항목을 선택하세요.") ; 
		 		return ;
			}
		}
		
		argoSetValue("s_FindSRecTime", $("#s_txtDate1_From").val().replace(/-/gi,"") + $("#s_FindSRegTime").val().replace(/:/gi,""));
		argoSetValue("s_FindERecTime", $("#s_txtDate1_To").val().replace(/-/gi,"") + $("#s_FindERegTime").val().replace(/:/gi,""));
		
		var termS = $("#selDateTerm1").val();
		if (termS == "S_1") {
			termS = "0";
		} else {
			termS = "1";
		}
		//w2ui.grid.lock('조회중', true);

		argoJsonSearchOne('recordFile', 'getRecSendDetailListCnt', 's_',
				{"tenantId": $("s_FindTenantId").val() ,"findTS" : termS }, function (data, textStatus, jqXHR){ 
			try {
				if (data.isOk()) {
					var totalData = data.getRows()['cnt'];
					paging(totalData, "1");
					
					$("#totCount").text(totalData);
					
					if(totalData == 0){
						argoAlert('조회 결과가 없습니다.');
					}
				}
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnSearchList(startRow, endRow){

		var termS = $("#selDateTerm1").val();
		if (termS == "S_1") {
			termS = "0";
		} else {
			termS = "1";
		}
		
		argoJsonSearchList('recordFile', 'getRecSendDetailList', 's_', {"tenantId":$("s_FindTenantId").val(), "iSPageNo":startRow, "iEPageNo":endRow,"findTS" : termS}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();

					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							

							gObject2 = {  "recid" 			: index
					    				, "recTime"			: row.recTime
					   					, "uploadKind"		: row.uploadKindStr +'('+row.uploadKind+')'
										, "tenantId" 		: row.tenantId
										, "dnNo" 			: row.dnNo
										, "recKey" 			: row.recKey
										, "userId" 			: row.userId
										, "callId" 			: row.callId
										, "endTime" 		: fnSecondsConv(row.endTime)
										, "custTel" 		: row.custTel
										, "searchVisible" 	: (row.searchVisible=="1"?"예(1)":"아니오(0)")
										, "callTime" 		: fnSecondsConv(row.callTime)
										, "rxrtpcnt" 		: row.rxrtpcnt
										, "txrtpcnt" 		: row.txrtpcnt
                                        , "rxfilesize" 		: row.rxfilesize
										, "txfilesize" 		: row.txfilesize
										};
										
							dataArray.push(gObject2);
						});
						
						w2ui['grid'].add(dataArray);
					}
				}
				//w2ui.grid.unlock();
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">전송상태조회</span><strong class="step">녹취전송조회</strong></div>
        <section class="sub_contents">
            <div class="search_area">
   				<div class="row" id="div_tenant">
					<ul class="search_terms">
						<li id="div_tenant">
							<strong class="title ml20">태넌트</strong> 
							<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
						</li>
					</ul>
				</div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title  ml20">검색</strong>
                            <select id="s_FindSearch" name="s_FindSearch" style="width:140px" class="list_box">
                            	<option value="">선택</option>
                            	<option value="dn_no" >내선번호</option>
                            	<option value="user_id" >상담사ID</option>
                            	<option value="user_name" >상담사명</option>
							</select>
							<input type="text"	id="s_FindText" name="s_FindText" style="width:140px"/>
						</li>
                        <li>
                            <strong class="title  ml20">변환상태</strong>
                            <select id="s_FindUploadKind" name="s_FindUploadKind" style="width:140px" class="list_box">
							</select>
						</li>
                        <li>
                            <strong class="title  ml20">조회여부</strong>
                            <select id="s_FindSearchVisible" name="s_FindSearchVisible" style="width:140px" class="list_box">
                            	<option value="">전체</option>
                            	<option value="1">예 (1)</option>
                            	<option value="0">아니오 (0)</option>
							</select> 
						</li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">검색기간</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
                            <span class="timepicker rec" id="rec_time1"><input type="text" id="s_FindSRegTime" name="s_FindSRegTime" class="input_time"><a href="#" class="btn_time">시간 선택</a></span> 
							<span class="text_divide">~</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                            <span class="timepicker rec" id="rec_time2"><input type="text" id="s_FindERegTime" name="s_FindERegTime" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>
                            <select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
                        </li>
                    </ul>
                </div>
            </div>     
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
                <button type="button" id="btnStat" class="btn_m">통계</button>
                <input type="hidden" id="s_FindSRecTime" name="s_FindSRecTime" />
                <input type="hidden" id="s_FindERecTime" name="s_FindERecTime" />
            </div>
            <div class="h136">
          
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	            <div style="text-align: right">
	             <b>녹취 변환 종류 ( 0 : 통화중, 1 : 통화 종료, 2 : 변환 중 , 3 : 변환 완료 , 9 : 짧은 콜 또는 패킷없는 콜  )       </b></div>
	                <div id="gridList" style="width: 100%; height: 415px;"></div>
	                <div class="list_paging" id="paging">
                		<ul class="paging">
                 			<li><a href="#" id='' class="on"></a>1</li>
                 		</ul>
                	</div>
                </div>
	        </div>
        </section>
    </div>
</body>

</html>