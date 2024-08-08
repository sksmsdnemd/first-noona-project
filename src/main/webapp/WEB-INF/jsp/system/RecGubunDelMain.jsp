<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
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
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var userId	  = loginInfo.SVCCOMMONID.rows.userId;
	var workIp	  = loginInfo.SVCCOMMONID.rows.workIp;
	var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
	var depth		= loginInfo.SVCCOMMONID.rows.depth;
	var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
	var workMenu	  = "녹취파일삭제분류조회";
	var workLog	  = "";
	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
// 		fnSearchListCnt();
	});
	
	function fnInitCtrl(){
		argoSetDatePicker();
		$('.timepicker.rec').timeSelect({use_sec:true});
		
		fnArogoSetting();
		
		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});

		$("#btnReset").click(function(){
			$("#s_FindGubunName").val('');
			$("#s_FindDelPath").val('');
			$("#s_FindDelWorkId").val('');
			
			$('#s_FindDelWorkGubun option[value=""]').prop('selected', true);
			$('#s_FindDelComplate option[value=""]').prop('selected', true);
			
			fnArogoSetting();
		});
		
		$("#btnAdd").click(function(){
			gPopupOptions = {cudMode:"I"} ;   	
		 	argoPopupWindow('녹취파일삭제분류 등록', 'RecGubunDelPopAddF.do', '1300', '820');
		});	
	}
	
	function fnArogoSetting(){
		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code":"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		$('#selDateTerm1 option[value="T_0"]').prop('selected', true);
	}
	
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	            selectColumn: true
	        },
	        multiSelect: true,
	        columns: [  
						 { field: 'recid', 				caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'delDate', 			caption: '삭제일', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunName', 			caption: '분류명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delWorkId', 			caption: '요청자', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delWorkGubun', 		caption: '삭제요청구분', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'tagetDelData', 		caption: '삭제요청용량/시간', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'tagetDelCount', 		caption: '대상파일개수', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delWorkData', 		caption: '삭제진행용량/기간', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delWorkCount', 		caption: '진행파일개수', 		size: '8%', 	sortable: true, attr: 'align=center' }
            			,{ field: 'delComplateFlag', 	caption: '완료여부', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delPath', 			caption: '삭제경로', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delDesc', 		   	caption: '사유', 		size: '8%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid');
	}
	
	function fnGetTimeParam(){
		var findSGubunTime = $("#s_txtDate1_From").val().replace(/-/gi,"");
		var findEGubunTime = $("#s_txtDate1_To").val().replace(/-/gi,"") ;
		
		var parm = {"sFindSGubunTime":findSGubunTime , "sFindEGubunTime": findEGubunTime };
		
		return parm;
	}
	
	function fnSearchListCnt(){
		var parm = fnGetTimeParam();
		
		w2ui.grid.lock('조회중', true);

		argoJsonSearchOne('recSearch', 'getRecDelGubunInfoCnt', 's_', parm , function (data, textStatus, jqXHR){
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
		var parm = fnGetTimeParam();
		parm.iSPageNo = startRow;
		parm.iEPageNo = endRow;
		argoJsonSearchList('recSearch', 'getRecDelGubunInfo', 's_', parm, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();

					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							gObject2 = {  "recid" 			: index
// 					    				, "gubunTime"			: fnStrMask("YMD", row.gubunTime)
					   					, "delDate"		: row.delDate
										, "gubunName" 		: row.gubunName
										, "delWorkId" 		: row.delWorkId
										, "delWorkGubun" 	: row.delWorkGubun == "1" ? "기간" : "용량"
										, "tagetDelData" 	: row.tagetDelData
										, "tagetDelCount"	: row.tagetDelCount
										, "delWorkData" 	: row.delWorkData
										, "delWorkCount" 	: row.delWorkCount
										, "delComplateFlag" : row.delComplateFlag
										, "delPath" 		: row.delPath
										, "delDesc" 		: row.delDesc
										};
										
							dataArray.push(gObject2);
						});
						
						w2ui['grid'].add(dataArray);
					}
				}
				w2ui.grid.unlock();
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">통화내역관리</span><span class="step">전송상태조회</span><strong class="step">미전송내역조회</strong></div>
        <section class="sub_contents">
            <div class="search_area row4">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20 mr7">삭제일</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
							<span class="text_divide">~</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
                            <select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
                        </li>	
                    </ul>
                </div>
                <div class="row">
                	<ul class="search_terms">
                		<li>
                            <strong class="title ml20 mr7">분류명</strong>
							<input type="text"	id="s_FindGubunName" name="s_FindGubunName" style="width: 231px;"/>
                        </li>
                        <li>
                            <strong class="title ml20 mr7">삭제경로</strong>
							<input type="text"	id="s_FindDelPath" name="s_FindDelPath" style="width: 231px;"/>
                        </li>
                	</ul>
                </div>
                <div class="row">
                	<ul class="search_terms">
                    	<li>
                            <strong class="title ml20 mr7">요청자</strong>
							<input type="text" id="s_FindDelWorkId" name="s_FindDelWorkId" style="width: 231px;"/>
                        </li>
                	</ul>
                </div>
                <div class="row">
                	<ul class="search_terms">
                    	<li>
                            <strong class="title ml20 mr7">삭제요청구분</strong>
							<select id="s_FindDelWorkGubun" name="s_FindDelWorkGubun" style="width: 110px;" class="mr5">
								<option value="">전체</option>
								<option value="1">용량</option>
								<option value="2">기간</option>
							</select>
                        </li>
                        <li>
                            <strong class="title ml20">완료여부</strong>
							<select id="s_FindDelComplate" name="s_FindDelComplate" style="width: 110px;" class="mr5">
								<option value="">전체</option>
								<option value="Y">완료</option>
								<option value="N">미완료</option>
							</select>
                        </li>
                	</ul>
                </div>
            </div>    
            <div class="btns_top">
            	<div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
                <button type="button" id="btnReset" class="btn_m">초기화</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
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