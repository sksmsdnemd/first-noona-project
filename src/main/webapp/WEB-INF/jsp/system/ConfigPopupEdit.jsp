<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 

<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var userId    = loginInfo.SVCCOMMONID.rows.userId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp 	  = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "매니저환경설정팝업";
	var workLog   = "";
	
	var cudMode;
	var fvCurRow;
	var dataArray = new Array();
	
	$(function (){
	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
			return this[key] === undefined ? value : this[key];
	    };
	    
		cudMode  = sPopupOptions.cudMode;
		
		fnInitGrid();
		ArgSetting();
		
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
		
		$("#ip_Section").change(function(){
	 		fnMaxOrder();
	 	});
		
		$("#ip_ValType").change(function(){
	 		fnValTypeChange();
	 	});
	});
	
	function ArgSetting(){
		
		argoSetValue("ip_UserId", userId);
		argoCbCreate("ip_Section", "menu", "getConfigSectionList", {}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		$("#ip_ValCur").attr("disabled", true);
		
		if(cudMode =='I') {
			$("#gridList").hide();
	
		}else{
			
			var valList  = "";
			var titlList = "";
			
			fvCurRow = sPopupOptions.pRowIndex;
			argoSetValues("ip_", fvCurRow);
			
			argoSetValue("ip_BkSection", fvCurRow.section);
			argoSetValue("ip_BkKeyCode", fvCurRow.keyCode);
			argoSetValue("ip_BkKeyOrder", fvCurRow.keyOrder);
			
			if(fvCurRow.valType == "TEXT"){
				$("#gridList").hide();
			}
			
			valList   = fvCurRow.valList;
			titleList = fvCurRow.titleList;
	
			if(valList != null && valList != ""){	
				var objVList = valList.split(",");
				var objTList = titleList.split(",");
		
				if(objVList.length > 0){
					for(var i=0; i < objVList.length; i++){
						
						gObject = {   "recid" 		: i+1
									, "valList"		: objVList[i]
									, "titleList"	: objTList[i]
								};
						dataArray.push(gObject);
					}
					w2ui['grid'].add(dataArray);
				}
			}
			
			$("#ip_Section").attr("disabled", true);
			$("#ip_KeyCode").attr("disabled", true);
			$("#ip_SectionAdd").attr("disabled", true);
			$("#btnSectionAdd").attr("disabled", true);
		}
	}
	
	function fnSavePop(){
		
		var resultData;
		
		argoConfirm("저장 하시겠습니까?", function(){
			
			w2ui['grid'].selectAll();
			var arrChecked 	= w2ui['grid'].getSelection();
			var valueL 		= "";
			var titleL 		= "";
			var strToken 	= ",";
			
			$.each(arrChecked, function( index, value ) {
				if((arrChecked.length-1) != index){
					valueL += w2ui['grid'].getCellValue(value-1, 1) + strToken;
					titleL += w2ui['grid'].getCellValue(value-1, 2) + strToken;
				}else{
					valueL += w2ui['grid'].getCellValue(value-1, 1);
					titleL += w2ui['grid'].getCellValue(value-1, 2);
				}
			});
			
			var aValidate = {
				rows:[
						 {"check":"length", "id":"ip_Section", "minLength":1, "maxLength":100, "msgLength":"분류코드를 선택하세요."}
						,{"check":"length", "id":"ip_KeyCode", "minLength":1, "maxLength":100, "msgLength":"항목명을 입력하세요."}
						,{"check":"length", "id":"ip_KeyOrder", "minLength":1, "maxLength":10, "msgLength":"순번을 입력하세요."}
					]
			};
			
			if (argoValidator(aValidate) != true) return;
			
			if($("#ip_ValCur").val() == ""){
				$("#ip_ValCur").val($("#ip_ValDefault").val());
			}
			
			if(cudMode == "I"){
				Resultdata = argoJsonUpdate("menu", "setConfigInsert", "ip_", {"cudMode":cudMode, "valList":valueL, "titleList":titleL});
			}else{
				Resultdata = argoJsonUpdate("menu", "setConfigUpdate", "ip_", {"cudMode":cudMode, "valList":valueL, "titleList":titleL});
			}
			
			if(Resultdata.isOk()) {	
		    	argoAlert('warning', '성공적으로 저장 되었습니다.', '',	'parent.fnSearchList(); argoPopupClose();');
		    	
		    }else {
		    	argoAlert("저장에 실패하였습니다");	 
		    }
		});
	}
	
	function SectionAdd(){
		var val = $("#ip_SectionAdd").val(); 
		$("#ip_Section").append("<option value='" + val + "'>" + val + "</option>");
		$('#ip_Section option[value="' + val + '"]').prop('selected', true);
		$("#ip_Section").change();
		
	}
	
	function fnMaxOrder(){
		var maxOrder;
		argoJsonSearchOne("menu", "getConfigMaxOrder", "ip_", {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						var info = data.getRows();
						maxOrder = info.maxKeyOrder;
						//$("#maxOrder").text(maxOrder);
						$("#ip_KeyOrder").val(maxOrder);
					}
				}
			}catch(e){
				console.log(e);
			}
		});
	}
	
	function fnValTypeChange(){
		
		var valType = $("#ip_ValType").val();
		
		if(valType == "TEXT"){
			$("#gridList").hide();
			w2ui.grid.clear();
		}else{
			$("#gridList").show();
		}
	}
	
	function fnInitGrid(){
	    $('#gridList').w2grid({ 
	        name: 'grid', 
	        show: { 
	            toolbar			: true,
	            selectColumn	: true,
	            footer			: true,
	            toolbarAdd		: true,
	            toolbarDelete	: true,
	            lineNumbers		: true,
	            searchAll 		: false,
	            toolbarReload	: false,
	            toolbarColumns	: false,
	            toolbarSearch	: false,
	            toolbarInput    : false
	        },
	        columns: [                
			            { field: 'recid', 		caption: 'ID', 		size: '10%'									},
			            { field: 'valList', 	caption: '값 List', 	size: '30%',	editable: { type: 'text' }	},
			            { field: 'titleList', 	caption: '표시 List', 	size: '60%',	editable: { type: 'text' }	}
	            
	        ],
	        onAdd: function (event) {
	        	w2ui.grid.add({	recid:w2ui.grid.records.length+1	});
	        },
	        records: dataArray
	    });
	    
	    w2ui['grid'].hideColumn('recid');
	}

</script>
</head>
<style type="text/css">
table,th,td { border-width:0px; }
</style>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
                	<span class="btn_r">
                       <button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>
                       <input type="hidden" id="ip_UserId" name="ip_UserId"/>
                       <input type="hidden" id="ip_BkSection" name="ip_BkSection"/>
                       <input type="hidden" id="ip_BkKeyCode" name="ip_BkKeyCode"/>
                       <input type="hidden" id="ip_BkKeyOrder" name="ip_BkKeyOrder"/>
                    </span>               
                </div>
                <div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158px">
                            <col width="200px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                        		<th>분류코드<span class="point">*</span></th>
                                <td>
                                	<select id="ip_Section" name="ip_Section" style="width:200px;" class="list_box"></select>
                                </td>
                                <td>
                                	<input type="text" id="ip_SectionAdd" name="ip_SectionAdd" style="width:210px;" class="mr10" />
                                	<button type="button" class="btn_m confirm" id="btnSectionAdd" name="btnSectionAdd" onclick="SectionAdd()">분류코드추가</button>   
                                </td>
                            </tr>
                            <tr>
                            	<th>항목명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_KeyCode" name="ip_KeyCode" style="width:200px;" class="mr10" />
                                </td>
                                <td>
								</td>
                            </tr>
                            <tr>
                            	<th>순번<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_KeyOrder" name="ip_KeyOrder" style="width:200px;" class="mr10 onlyNum" />
                                </td>
                                <td>숫자로 입력
                                </td>
							</tr>
                            <tr>
                            	<th>형태</th>
                                <td>
                                	<select id="ip_ValType" name="ip_ValType" style="width:200px;" class="list_box">
                                		<option value="TEXT">TEXT</option>
                                		<option value="COMBO">COMBO</option>
                                		<option value="RADIO">RADIO</option>
                                	</select>
								</td>
								<td>
                                </td>
                            </tr>
                            <tr>
                            	<th>Default값</th>
                                <td>
                                	<input type="text" id="ip_ValDefault" name="ip_ValDefault" style="width:200px;" class="mr10" />
                                </td>
                                <td>value : <input type="text" id="ip_ValCur" name="ip_ValCur" style="width:200px;" class="mr10"/>
                                </td>                             
                            </tr>
                            <tr>
                            	<th>메모</th>
                                <td colspan="2">
                                	<input type="text" id="ip_ValDesc" name="ip_ValDesc" style="width:560px;" class="mr10" />
								</td>
                            </tr>
                            <tr>
                            	<th>설정값</th>
                                <td colspan="2">
                                	<span>하단 그리드에서 추가 및 삭제 가능(TEXT는 제외)</span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div id="gridList" style="width: 100%; height: 236px;"></div>           
            </div>            
        </section>
    </div>
</body>

</html>
