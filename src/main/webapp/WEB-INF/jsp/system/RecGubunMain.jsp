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
	var workMenu	  = "녹취파일분류조회";
	var workLog	  = "";
	var dataArray = new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchListCnt();
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
			$("#s_FindGubunPath").val('');
			$("#s_FindSStorageSize").val('');
			$("#s_FindEStorageSize").val('');
			
			$('#s_SelSearchType option[value="G"]').prop('selected', true);
			
			fnArogoSetting();
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
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'gubunTime', 		caption: '분류일', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunName', 		caption: '분류명', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunCount', 		caption: '분류파일개수', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunWorkCheck', 	caption: '분류정합성', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunDate', 		caption: '분류날짜', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunPath', 		caption: '분류경로', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'gubunDailyVolumn', 		caption: '일자별사용량', 		size: '8%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'storegeUseVolumn', 		caption: '분류별 총 사용량', 		size: '8%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid');
	}
	
	function fnGetTimeParam(){
		var findSGubunTime = $("#s_txtDate1_From").val().replace(/-/gi,"");// + $("#s_FindSGubunTime").val().replace(/:/gi,"");
		var findEGubunTime = $("#s_txtDate1_To").val().replace(/-/gi,"") ;//+ $("#s_FindEGubunTime").val().replace(/:/gi,"");
		
		var parm = {"sFindSGubunTime":findSGubunTime , "sFindEGubunTime": findEGubunTime };
		
		return parm;
	}
	
	function fnSearchListCnt(){
		var parm = fnGetTimeParam();
		
		w2ui.grid.lock('조회중', true);

		argoJsonSearchOne('recSearch', 'getRecGubunInfoCnt', 's_', parm , function (data, textStatus, jqXHR){
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
		argoJsonSearchList('recSearch', 'getRecGubunInfo', 's_', parm, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();

					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							gObject2 = {  "recid" 			: index
					    				, "gubunTime"			: fnStrMask("YMD", row.gubunTime)
					   					, "gubunName"			: row.gubunName
										, "gubunCount" 		: row.gubunWorkCount
										, "gubunWorkCheck" 	: row.gubunWorkCheck
										, "gubunDate" 		: fnStrMask("YMD", row.gubunDate)
										, "gubunPath" 		: row.gubunPath
										, "gubunDailyVolumn" 		: (Math.ceil(row.gubunDailyVolumn / 1024 *100)/100) +"MB"
										, "storegeUseVolumn" 		: (Math.ceil(row.storageUseVolumn / 1024 *100)/100)+"MB"
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
            <div class="search_area row3">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">분류일</strong>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_From" name="s_txtDate1_From"></span>
<!--                             <span class="timepicker rec" id="rec_time1"><input type="text" id="s_FindSGubunTime" name="s_FindSGubunTime" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>  -->
							<span class="text_divide">~</span>
                            <span class="select_date"><input type="text" class="datepicker onlyDate" id="s_txtDate1_To" name="s_txtDate1_To"></span>
<!--                             <span class="timepicker rec" id="rec_time2"> <input type="text" id="s_FindEGubunTime" name="s_FindEGubunTime" class="input_time"> <a href="#" class="btn_time">시간 선택</a></span> -->
                            <select id="selDateTerm1" name="" style="width:86px;" class="mr5"></select>
                        </li>	
                    </ul>
                </div>
                <div class="row">
                	<ul class="search_terms">
                		<li>
                            <strong class="title ml20">분류명</strong>
							<input type="text"	id="s_FindGubunName" name="s_FindGubunName" style="width: 231px;"/>
                        </li>
                        <li>
                            <strong class="title ml20">분류경로</strong>
							<input type="text"	id="s_FindGubunPath" name="s_FindGubunPath" style="width: 231px;"/>
                        </li>
                	</ul>
                </div>
                <div class="row">
                	<ul class="search_terms">
                    	<li>
                            <strong class="title ml20">검색</strong>
							<select id="s_SelSearchType" name="s_SelSearchType" style="width: 110px;" class="mr5">
								<option value="G">일자별사용량</option>
								<option value="S">분류별총사용량</option>
							</select>
							<input type="text" id="s_FindSStorageSize" name="s_FindSStorageSize" placeholder="MB" style="width: 113px;text-align: right;"/>&nbsp;&nbsp;~&nbsp;&nbsp;
							<input type="text" id="s_FindEStorageSize" name="s_FindEStorageSize" placeholder="MB" style="width: 113px;text-align: right;"/>
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