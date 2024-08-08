<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workMenu 	= "리소스통계";

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

		argoCbCreate("s_FindSysGroupId", "sysGroup", "getSysGroupComboList", {sort_cd:'SYS_GROUP_ID'}, {"selectIndex":0, "text":'선택하세요!', "value":''});		
		argoCbCreate("s_FindSystemId", "sysGroup", "getSystemComboList", {sort_cd:'SYSTEM_ID'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindResCode", "baseCode", "getBaseComboList", {classId:'res_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		fnAuthBtnChk(parent.$("#authKind").val());

		$("#btnSearch").click(function(){ //조회
			fnSearchListCnt();			
		});

		$("#btnReset").click(function(){
			
			$('#s_FindSysGroupId option[value=""]').prop('selected', true);
			$('#s_FindSystemId option[value=""]').prop('selected', true);
			$('#s_FindResCode option[value=""]').prop('selected', true);
			$("#s_FindResLimit").val('');
			$('#s_FindBaseDateKind option[value="1"]').prop('selected', true);

			fnArogoSetting();
		});
		
		$("#s_FindSysGroupId").change(function(){
			fnSetSubCb();
	 	});
		
		$('#s_FindResLimit').keydown(function(key){
	 		if(key.keyCode == 13){
	 			fnSearchListCnt();
	 		}
		});
		
		$("#btnExcel").click(function(){
			var excelArray = new Array();
			argoJsonSearchList('resource', 'getResourceList', 's_', {"iSPageNo":100000000, "iEPageNo":100000000}, function (data, textStatus, jqXHR){
				try {
					if (data.isOk()) {
						$.each(data.getRows(), function( index, row ) {

							gObject = {   "순번" 		: index + 1
					    				, "등록일"		: fnStrMask("YMD", row.regDate)
					   					, "등록시간"	: fnStrMask("HMS", row.regTime)
										, "시스템그룹" 	: row.sysGroupName
										, "시스템명" 	: row.systemName
										, "리소스명" 	: row.resNameConv
										, "최소값(%)" 	: row.resMin
										, "최대값(%)" 	: row.resMax
										, "평균값(%)" 	: row.resAvg
										};
										
							excelArray.push(gObject);
						});
						
						gPopupOptions = {"pRowIndex":excelArray, "workMenu":workMenu};
						argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportF.do', '150', '40');
					}
				} catch (e) {
					console.log(e);
				}
			});
		});
	}
	
	function fnArogoSetting(){

		jData =[{"codeNm":"당일", "code":"T_0"}, {"codeNm":"1주", "code" :"W_1"}, {"codeNm":"2주", "code":"W_2"}, {"codeNm":"한달", "code":"M_1"}] ;
		argoSetDateTerm('selDateTerm1', {"targetObj":"s_txtDate1", "selectValue":"T_0"}, jData);
		argoSetValue("s_FindSRegTime", "00:00:00");
		argoSetValue("s_FindERegTime", "23:59:59");
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
	            	 	,{ field: 'regDate', 		caption: '등록일', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'regTime', 		caption: '등록시간', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'sysGroupName', 	caption: '시스템그룹', 		size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'systemName', 	caption: '시스템명', 		size: '15%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resNameConv', 	caption: '리소스명', 		size: '20%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resMin', 		caption: '최소값(%)', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resMax', 		caption: '최대값(%)', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resAvg', 		caption: '평균값(%)', 		size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'sysGroupId', 	caption: 'sysGroupId', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'systemId', 		caption: 'systemId', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resClass', 		caption: 'resClass', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resCode', 		caption: 'resCode', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resName', 		caption: 'resName', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'resCodeName', 	caption: 'resCodeName', size: '0%', 	sortable: true, attr: 'align=center' }
	            		
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'sysGroupId', 'systemId', 'resClass', 'resCode', 'resName', 'resCodeName');
	}
	
	function fnSearchListCnt(){
		
		var baseDateKind = $("#s_FindBaseDateKind").val();
		var groupBy 	 = "";
		var dateColList  = "";
		var dateCol 	 = "";
		var groupByComm	 = ", a.sys_group_id, a.system_id, b.system_name , a.res_class,  a.res_code, a.res_name";
		
		if(baseDateKind == "1"){
			dateColList = " a.reg_date , a.reg_time ";
			dateCol 	= dateColList;
			groupBy 	= "group by " + dateColList + groupByComm;
			
		}else if(baseDateKind == "2"){
			dateColList = " a.reg_date , substring(a.reg_time,1,2) ";
			dateCol 	= dateColList + " reg_time";
			groupBy 	= "group by " + dateColList + groupByComm;
			
		}else if(baseDateKind == "3"){
			dateColList = " a.reg_date ";
			dateCol 	= dateColList + ", '' reg_time";
			groupBy 	= "group by " + dateColList + groupByComm;
			
		}else if(baseDateKind == "4"){
			dateColList = " substring(a.reg_date,1, 6)  ";
			dateCol 	= dateColList + " reg_date , '' reg_time";
			groupBy 	= "group by " + dateColList + groupByComm;
		}
		
		argoSetValue("s_FindSRegDate", $("#s_txtDate1_From").val().replace(/-/gi,""));
		argoSetValue("s_FindERegDate", $("#s_txtDate1_To").val().replace(/-/gi,""));
		argoSetValue("s_GroupBy", groupBy);
		argoSetValue("s_DateCol", dateCol);

		argoJsonSearchOne('resource', 'getResourceCount', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						var totalData = data.getRows()['cnt'];
						paging(totalData, "1");

						$("#totCount").text(totalData);
						
						if(totalData == 0){
							argoAlert('조회 결과가 없습니다.');
						}
						
						w2ui.grid.lock('조회중', true);
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function fnSearchList(startRow, endRow){
		
		var baseDateKind = $("#s_FindBaseDateKind").val();
		var groupBy 	 = "";
		var dateColList  = "";
		var dateCol 	 = "";
		var groupByComm	 = ", a.sys_group_id, a.system_id, b.system_name , a.res_class,  a.res_code, a.res_name";
		
		if(baseDateKind == "1"){
			dateColList = " a.reg_date , a.reg_time ";
			dateCol 	= dateColList;
			groupBy 	= "group by " + dateColList + groupByComm;
			
		}else if(baseDateKind == "2"){
			dateColList = " a.reg_date , substring(a.reg_time,1,2) ";
			dateCol 	= dateColList + " reg_time";
			groupBy 	= "group by " + dateColList + groupByComm;
			
		}else if(baseDateKind == "3"){
			dateColList = " a.reg_date ";
			dateCol 	= dateColList + ", '' reg_time";
			groupBy 	= "group by " + dateColList + groupByComm;
			
		}else if(baseDateKind == "4"){
			dateColList = " substring(a.reg_date,1, 6)  ";
			dateCol 	= dateColList + " reg_date , '' reg_time";
			groupBy 	= "group by " + dateColList + groupByComm;
		}
		
		argoSetValue("s_FindSRegDate", $("#s_txtDate1_From").val().replace(/-/gi,""));
		argoSetValue("s_FindERegDate", $("#s_txtDate1_To").val().replace(/-/gi,""));
		argoSetValue("s_GroupBy", groupBy);
		argoSetValue("s_DateCol", dateCol);

		argoJsonSearchList('resource', 'getResourceList', 's_', {"iSPageNo":startRow, "iEPageNo":endRow}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();
					
					if (data.getRows() != ""){ 
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							gObject2 = {  "recid" 			: index
					    				, "regDate"			: fnStrMask("YMD", row.regDate)
					   					, "regTime"			: fnStrMask("HMS", row.regTime)
										, "sysGroupName" 	: row.sysGroupName
										, "systemName" 		: row.systemName
										, "resNameConv" 	: row.resNameConv
										, "resMin" 			: row.resMin
										, "resMax" 			: row.resMax
										, "resAvg" 			: row.resAvg
										, "sysGroupId" 		: row.sysGroupId
										, "systemId" 		: row.systemId
										, "resClass" 		: row.resClass
										, "resCode" 		: row.resCode
										, "resName" 		: row.resName
										, "resCodeName" 	: row.resCodeName
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
	
	function fnSetSubCb() {
		
		if($('#s_FindSysGroupId option:selected').val() == ''){
			//$("#s_FindSystemId").find("option").remove();
		}else{
			argoCbCreate("s_FindSystemId", "sysGroup", "getSystemComboList", {sort_cd:'SYSTEM_ID', sysGoupId:$('#s_FindSysGroupId option:selected').val()}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		}
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><strong class="step">리소스통계</strong></div>
        <section class="sub_contents">
            <div class="search_area row3">
                <div class="row">
                    <ul class="search_terms">
                    	<li style="width:345px">
                    		<strong class="title ml20">시스템그룹</strong>
                            <select id="s_FindSysGroupId" name="s_FindSysGroupId" style="width:200px;" class="list_box">
                                <option>선택하세요!</option>
                            </select>
                        </li>
                        <li>
                        	<strong class="title">시스템</strong>
                            <select id="s_FindSystemId" name="s_FindSystemId" style="width:200px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                    	<li style="width:345px">
                            <strong class="title ml20">검색주기</strong>
                            <select id="s_FindBaseDateKind" name="s_FindBaseDateKind" style="width:200px" class="list_box">
								<option value="1" >기본수집주기</option>
								<option value="2" >시간별</option>
								<option value="3" >일 별</option>
								<option value="4" >월 별</option>
							</select>
                        </li>
                        <li>
                            <strong class="title">리소스구분</strong>
                            <select id="s_FindResCode" name="s_FindResCode" style="width:200px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                            <span><b>&nbsp;&nbsp;평균값(%) : </b><input type="text" onKeyPress="return argoNumkeyCheck(event)" id="s_FindResLimit" name="s_FindResLimit" style="width:50px;" maxlength="3"/> <b>이상</b></span>
                          
                        </li>
                    </ul>
                </div>
                <div class="row">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">검색일자</strong>
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
                <button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
                <!-- <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
                <button type="button" id="btnDelete" class="btn_m">삭제</button> -->
                <button type="button" id="btnReset" class="btn_m">초기화</button>
                <input type="hidden" id="s_FindSRegDate" name="s_FindSRegDate" >
                <input type="hidden" id="s_FindERegDate" name="s_FindERegDate" >
                <input type="hidden" id="s_GroupBy" name="s_GroupBy" >
                <input type="hidden" id="s_DateCol" name="s_DateCol" >
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