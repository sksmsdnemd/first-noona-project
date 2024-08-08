<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->

<script>

	var dataArray = new Array();
	
	$(function () {
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrlPop();
	  	ArgSetting();
	  	fnInitGrid();
	  	fnSearchList();
	});
	
	function fnInitCtrlPop() {
		$("#btnCancel").click(function(){
			argoPopupClose();
		});
	}
	
	function ArgSetting() {
		
		var cudMode   = sPopupOptions.cudMode;
		var recTime   = (sPopupOptions.recTime).replace("-","").replace("-","");
		var userId    = sPopupOptions.userId;
		var mediaKind = sPopupOptions.mediaKind;
		var sRecTime  = recTime + "000000";
		var eRecTime  = recTime + "235959";
		
		argoSetValue('ip_Userid', userId);
		argoSetValue('ip_FindMediaKind', mediaKind);
		argoSetValue('ip_FindSRecTime', sRecTime);
		argoSetValue('ip_FindERecTime', eRecTime);
	}
	
	function fnInitGrid(){
	
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true
	        },
	        columns: [  
						 { field: 'recid', 			caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'fileName', 		caption: '파일명', 		size: '34%', 	sortable: true, attr: 'align=center' }
						,{ field: 'mediaKindName', 	caption: '미디어구분', 		size: '10%', 	sortable: true, attr: 'align=center' }
						,{ field: 'mrsSystemId', 	caption: 'MRS ID', 		size: '8%', 	sortable: true, attr: 'align=center' }
						,{ field: 'uploadKindName', caption: '업로드상태', 		size: '12%', 	sortable: true, attr: 'align=center' }
						,{ field: 'uploadDate', 	caption: '업로드일', 		size: '20%', 	sortable: true, attr: 'align=center' }
						,{ field: 'retryCount', 	caption: '시도횟수', 		size: '8%', 	sortable: true, attr: 'align=center' }
						,{ field: 'storeDrive', 	caption: '저장위치', 		size: '8%', 	sortable: true, attr: 'align=center' }
						,{ field: 'mediaKind', 		caption: 'mediaKind', 	size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'uploadKind', 	caption: 'uploadKind', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            	 	,{ field: 'recKey', 		caption: 'recKey', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'tnantId', 		caption: 'tnantId', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'recTime', 		caption: 'recTime', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'dnNo', 			caption: 'dnNo', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'userId', 		caption: 'userId', 		size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaVoice', 	caption: 'mediaVoice', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'mediaScr', 		caption: 'mediaScr', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkLabelId', 		caption: 'bkLabelId', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'bkDelKind', 		caption: 'bkDelKind', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'delTime', 		caption: 'delTime', 	size: '0%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'rxrtpcnt', 		caption: 'rxCnt', 	size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'txrtpcnt', 		caption: 'txCnt', 	size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'rxfilesize', 	caption: 'rxSize', 	size: '10%', 	sortable: true, attr: 'align=center' }
	            		,{ field: 'txfilesize', 	caption: 'txSize', 	size: '10%', 	sortable: true, attr: 'align=center' }
	            		
	        ],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid', 'mediaKind', 'uploadKind', 'recKey', 'tnantId', 'recTime', 'dnNo', 'userId', 'mediaVoice'
								,'mediaScr', 'bkLabelId', 'bkDelKind', 'delTime');
	}
	
	function fnSearchList(){;
	
		argoJsonSearchList('recordFile', 'getNoSendRecFileIndexList', 'ip_', {}, function (data, textStatus, jqXHR){
			try{
				if (data.isOk()) {
					w2ui.grid.clear();
		
					if (data.getRows() != ""){
						dataArray = new Array();
						$.each(data.getRows(), function( index, row ) {
							
							gObject2 = {  "recid" 			: index
					    				, "recKey"			: row.recKey
					   					, "tnantId"			: row.tnantId
										, "recTime" 		: row.recTime
										, "dnNo" 			: row.dnNo
										, "userId" 			: row.userId
										, "mediaVoice" 		: row.mediaVoice
										, "mediaScr" 		: row.mediaScr
										, "mediaKind" 		: row.mediaKind
										, "fileName" 		: row.fileName
										, "mrsSystemId" 	: row.mrsSystemId
										, "uploadKind" 		: row.uploadKind
										, "uploadDate" 		: row.uploadDate
										, "storeDrive" 		: row.storeDrive
										, "bkLabelId" 		: row.bkLabelId
										, "bkDelKind" 		: row.bkDelKind
										, "delTime" 		: row.delTime
										, "retryCount" 		: row.retryCount
										, "mediaKindName" 	: row.mediaKindName
										, "uploadKindName" 	: row.uploadKindName
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
        <div class="location"></div>
         <section class="sub_contents"> 
            <div class="input_area" style="width:965px">
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 965px; height: 200px;"></div>
                </div>
	        </div>
        	<div class="btn_areaB txt_r" style="width:965px">
                <button type="button" class="btn_m" id="btnCancel" data-grant="W">닫기</button>
				<input type="hidden" id="ip_Userid" name="ip_Userid" />
            	<input type="hidden" id="ip_FindMediaKind" name="ip_FindMediaKind" />
            	<input type="hidden" id="ip_FindSRecTime" name="ip_FindSRecTime" />
            	<input type="hidden" id="ip_FindERecTime" name="ip_FindERecTime" />            
			</div>
 		</section>
    </div>
</body>

</html>
