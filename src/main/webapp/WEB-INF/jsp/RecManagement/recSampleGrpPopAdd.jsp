<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/argo.contants.css?ver=2017021601"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>

<script>

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 		= loginInfo.SVCCOMMONID.rows.userId;
	var tenantId 	= loginInfo.SVCCOMMONID.rows.tenantId;
	var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu 	= "샘플콜분류조회";
	var workLog 	= "";
	var dataArray 	= new Array();
	
	$(function () {
		var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	
	  	fnInitCtrlPop();
	  	fnInitGrid();
	  	fnSearchList();
	});
	
	function fnInitGrid(){
		$('#grid').w2grid({ 
			name: 'grid',
			show: {
				lineNumbers: true,
				footer:true,
				selectColumn: false
			},
			multiSelect: true,
			onDblClick: function(event) {
				var record = this.get(event.recid);
				parent.fnSerch(record);
				argoPopupClose();
			},
			columns: [
						{ field: 'recid',  		caption: 'recid', 		size: '0%'   }, 
	                	{ field: 'subAdd', 		caption: '하부', 			size: '10%'  },
			            { field: 'tenantId', 	caption: 'tenantId', 	size: '150px'},
			            { field: 'groupId', 	caption: '분류ID', 		size: '10%'  },
			            { field: 'groupName', 	caption: '분류명', 		size: '10%'  },
			            { field: 'topParentId', caption: 'topParentId', size: '90px' },
			            { field: 'parentId', 	caption: 'parentId', 	size: '90px' },
			            { field: 'depth', 		caption: 'depth', 		size: '90px' },
			            { field: 'groupDesc', 	caption: '설명', 			size: '40%'  },
			            { field: 'sortCol', 	caption: 'sortCol', 	size: '90px' },
			            { field: 'isExist', 	caption: 'isExist', 	size: '90px' },
			            { field: 'level', 		caption: 'level', 		size: '90px' },
			            { field: 'depthPath', 	caption: 'depthPath', 	size: '90px' }
			]
		});
		w2ui['grid'].hideColumn('recid', 'tenantId', 'groupId', 'topParentId', 'parentId', 'depth', 'sortCol', 'isExist', 'level', 'depthPath');
	}
	
	function fnSearchList(){
		argoJsonSearchList('recSample', 'getSampleCallGrpList', 's_', {tenantId:$('#s_FindTenantId option:selected').val()}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					var dataArray2;
					var gObject2;
					var records;
					dataArray2 = new Array();
					
					$.each(data.getRows(), function( index, row ) {
						var	subAdd = ' <button type="button" id="sub" class="btn_m" onclick="javascript:subclick(' + index + ');">선택</button>';
						gObject2 = {  "recid"       :  index
								    , "subAdd"      :  subAdd
								    , "tenantId"    :  row.tenantId
				    			    , "groupId"     :  row.groupId
				    			    , "groupName"   :  row.groupName
									, "topParentId" :  row.topParentId
									, "parentId"    :  row.parentId
									, "depth"       :  row.depth
									, "groupDesc"   :  row.groupDesc
									, "sortCol"     :  row.sortCol
									, "isExist"     :  row.isExist
									, "level"       :  row.level
									, "depthPath"   :  row.depthPath
									};
						
						dataArray2.push(gObject2);
					});
					w2ui['grid'].add(dataArray2);
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function subclick(idx){
		var depthPath = w2ui['grid'].getCellValue(idx,12);
		var groupName = w2ui['grid'].getCellValue(idx,4);
		param = {
					"depthPath":depthPath,
					"groupName":groupName
				};
		parent.fnSerch(param);
		argoPopupClose();
	}
	
	function fnInitCtrlPop() {
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
		
		argoCbCreate("s_FindTenantId", "comboBoxCode", "getTenantList",	{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		$("#s_FindTenantId").val(sPopupOptions.pTenantId).attr("selected", "selected");
	}
	
	function uptMemo(){
		argoConfirm("수정 하시겠습니까?", function(){	
			fnDetailInfoCallback();	    
		});
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			Resultdata = argoJsonUpdate("recSample", "setRecSampleCallUpdate", "ip_", {});
	
			if(Resultdata.isOk()) {	
				argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchListCnt(); argoPopupClose();');
			}else {
				argoAlert("저장에 실패하였습니다");	 
			}
		} catch (e) {
			console.log(e);
		}
	}

</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">   
       	    <div class="h136">
            	<div class="input_area" style="margin: 5px 0;">
            		<table class="input_table">
                    	<colgroup>
                        	<col width="120">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                        		<th align="center">태넌트<span class="point">*</span></th>
                        		<td>
                        			<select id="s_FindTenantId" name="s_FindTenantId" style="width: 140px" class="list_box"></select> 
									<input type="text" id="s_FindTenantIdText" name="s_FindTenantIdText" style="width: 150px; display: none;" class="clickSearch" /> 
									<input type="text" id="s_FindSearchVisible" name="s_FindSearchVisible" style="display: none" value="1">
                        		</td>
                            </tr>
                        </tbody>
                    </table>
            	</div>
<!--             	<div class="btn_topArea fix_h25"></div> -->
	            <div class="grid_area h25 pt0">
	               <div id="grid" style="width: 100%; height: 400px;  overflow: hidden;" ></div>
            	</div>
        	</div>      
        	<!-- 
            <div class="pop_cont pt5">
                <div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                        		<td align="center" colspan="5">메모</td>
                            </tr>
                            <tr>
                            	<th align="center"><button type="button" class="btn_m confirm" onclick="javascript:uptMemo();">수정</button></th>
                            	 <td>
                           			<textarea id="ip_FindContent"  name="ip_FindContent"style="height:92px; width:100%; " ></textarea>
                                </td>
                            </tr>
                            <tr>
                            	<input type="hidden" id="ip_FindRecKey" name="ip_FindRecKey" />
                            </tr>
                        </tbody>
                    </table>
                </div>       
            </div> 
            -->             
        </section>
    </div>
</body>

</html>
