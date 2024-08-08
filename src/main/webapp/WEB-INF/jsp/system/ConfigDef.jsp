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
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo  = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId   = loginInfo.SVCCOMMONID.rows.tenantId;
	var userId     = loginInfo.SVCCOMMONID.rows.userId;
	var grantId    = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 	   = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu   = "매니저환경설정";
	var workLog    = "";
	var dataArray  = new Array();
	var changeFlag = "Y";

	$(document).ready(function(param) {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
	});
	
	function fnInitCtrl(){	

		argoCbCreate("s_FindSection", "menu", "getConfigSectionList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		
		$("#btnSearch").click(function(){
			fnSearchList();			
		});
		
		$("#btnAdd").click(function(){
			gPopupOptions = {cudMode:"I"};   	
		 	argoPopupWindow('매니저환경설정 등록', 'ConfigPopupEditF.do', '800', '625');
		});
		
		$("#btnDelete").click(function(){
			fnDeleteList();
		});
		
		$("#btnSetting").click(function(){
			
			if(changeFlag == "Y"){
				fnSearchList();
				$('#ifConfigList').attr('src', '');
				$(".sub_contents").show();
				$(".configSection").hide();
				changeFlag = "N";
			}else{
				$('#ifConfigList').attr('src', '../system/ConfigParamAddF.do');
				$(".sub_contents").hide();
				$(".configSection").show();
				changeFlag = "Y";
			}
		});
		
		$(".sub_contents").hide();
		$('#ifConfigList').attr('src', '../system/ConfigParamAddF.do');
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
	        onDblClick: function(event) {
	        	var record = this.get(event.recid);
	        	if(record.recid >=0 ) {
					gPopupOptions = {cudMode:'U', pRowIndex:record};   	
					argoPopupWindow('매니저환경설정 수정', 'ConfigPopupEditF.do', '800', '625');
				}
	        },
	        columns: [  
						 { field: 'recid', 		caption: 'recid', 	size: '0%', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'section', 	caption: '분류코드', 	size: '13%', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'keyCode', 	caption: '항목', 		size: '20%', 	sortable: true, attr: 'align=left'   }
		           	 	,{ field: 'keyOrder', 	caption: '순서', 		size: '5%', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'valType', 	caption: '형태', 		size: '0px', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'valCur', 	caption: '설정값', 	size: '12%', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'valDefault', caption: '기본값', 	size: '12%', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'valList', 	caption: '값목록', 	size: '0%', 	sortable: true, attr: 'align=center' }
		           	 	,{ field: 'titleList', 	caption: '표시목록', 	size: '0%', 	sortable: true, attr: 'align=left'   }
		           	 	,{ field: 'valDesc', 	caption: '메모', 		size: '38%', 	sortable: true, attr: 'align=left'   }
	       	],
	        records: dataArray
	    });
		w2ui['grid'].hideColumn('recid', 'valType', 'valList', 'titleList'); 
	}

	function fnSearchList(){
		
		var totCnt = 0;
		w2ui.grid.lock('조회중', true);
		
		argoJsonSearchList('menu', 'getConfigList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					dataArray = [];
					if (data.getRows() != ""){ 
						
						$.each(data.getRows(), function( index, row ) {
							
							gObject2 = {  "recid" 		: index
										, "section"		: row.section
					    				, "keyCode"	  	: row.keyCode
					    				, "keyOrder"	: row.keyOrder
					    				, "valType"	  	: row.valType
					    				, "valCur"	  	: row.valCur
					    				, "valDefault"	: row.valDefault
					    				, "valList"	  	: row.valList
					    				, "titleList"	: row.titleList
					    				, "valDesc"		: row.valDesc
										};
										
							dataArray.push(gObject2);
							
							totCnt++;
						});
						w2ui['grid'].add(dataArray);
					}
					$("#totCount").text(totCnt);
				}
				w2ui.grid.unlock();
			} catch (e) {
				console.log(e);
			}
		});
	}
	
	function fnDeleteList(){
		
 		try{
			var arrChecked = w2ui['grid'].getSelection();
			
			if(arrChecked.length == 0){
				argoAlert("삭제할 환경설정을 선택하세요"); 
		 		return ;
			}

			argoConfirm('선택한 환경설정 ' + arrChecked.length + '건을  삭제하시겠습니까?', function() {
				var multiService = new argoMultiService(fnCallbackDelete);
				var section  = "";
				var keyCode  = "";
				var keyOrder = "";

				$.each(arrChecked, function( index, value ) {
					
					section  = w2ui['grid'].getCellValue(value, 1);
					keyCode  = w2ui['grid'].getCellValue(value, 2);
					keyOrder = w2ui['grid'].getCellValue(value, 3);

					var param = { 
									"section"   : section, 
									"keyCode"   : keyCode,
									"keyOrder"  : keyOrder
								};

					multiService.argoDelete("menu", "setConfigDelete", "__", param);
					
				});
				multiService.action();
		 	}); 
		 	
		}catch(e){
			console.log(e) ;	 
		} 
	}
	
	function fnCallbackDelete(Resultdata, textStatus, jqXHR) {
		try {
			if (Resultdata.isOk()) {
				argoAlert('성공적으로 삭제 되었습니다.');
				fnSearchList();
			}
		} catch (e) {
			argoAlert(e);
		}
	}
		
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location">
        	<button type="button" id="btnSetting" class="btn_tab">환경설정전환</button>
        	<span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템설정관리</span><strong class="step">매니저환경설정</strong>
        </div>
        <section class="sub_contents">
            <div class="search_area row2">
                <div class="row" id="div_tenant">
                    <ul class="search_terms">
                        <li>
                            <strong class="title ml20">SECTION</strong>
                            <select id="s_FindSection" name="s_FindSection" style="width: 250px" class="list_box"></select>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="btns_top">
	            <div class="sub_l">
	            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount"></span> 
                </div>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
                <button type="button" id="btnAdd" class="btn_m confirm">등록</button>
                <button type="button" id="btnDelete" class="btn_m confirm">삭제</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 463px;"></div>
	            </div>
	        </div>
        </section>
        <section class="configSection">
        	<div class="content_wrap" style="height:600px;">
        		<iframe id="ifConfigList"src=""></iframe>
        	</div>
        </section>
    </div>
</body>

</html>