<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

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

	var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
	if(loginInfo!=null){	
		var tenantId    = loginInfo.SVCCOMMONID.rows.tenantId;	
		var userId      = loginInfo.SVCCOMMONID.rows.userId;
		var grantId     = loginInfo.SVCCOMMONID.rows.grantId;
		var workIp      = loginInfo.SVCCOMMONID.rows.workIp;
		var playerKind  = loginInfo.SVCCOMMONID.rows.playerKind;
		var convertFlag = loginInfo.SVCCOMMONID.rows.convertFlag;
		var groupId		= loginInfo.SVCCOMMONID.rows.groupId;
		var depth		= loginInfo.SVCCOMMONID.rows.depth;
		var controlAuth	= loginInfo.SVCCOMMONID.rows.controlAuth;
		var backupAt	= loginInfo.SVCCOMMONID.rows.backupAt;
	}else{
		var tenantId    = 'bridgetec';	
		var userId      = 'btadmin';
		var grantId     = 'SuperAdmin';
		var workIp      = '127.0.0.1';
		var playerKind  = '0';
		var convertFlag = '1';
		var groupId		= '1';
		var depth		= 'A';
		var controlAuth	= null;
	}
	
	var popOption;
	var workMenu 	= "시스템정보관리";
	var workLog 	= "";

	var dataArray 	= new Array();
	var param;
	$(document).ready(function() {
		console.log(parent);
		sPopupOptions = parent.gPopupOptions || {};
        sPopupOptions.get = function (key, value) {
            return this[key] === undefined ? value : this[key];
        };
        
        param = sPopupOptions.param;
        
        fnInitCtrl();
		fnParamSetting();
	});
	
	function fnParamSetting(){
		
	}

	function fnInitCtrl(){
		$("#btnSavePop").click(function(){
			argoConfirm("수정하시겠습니까?",fnExcelInsert);
		});
		$("#btnExcel").click(function(){
			dnExcelSampleDownload();
		});
	}

	function dnExcelSampleDownload(){
		var form = $('<form>');
		var actionUrl = gGlobal.ROOT_PATH + "/RecSearch/RecSearchCustInfoUpdateF.do?"+param+"&excelImSvcName=recSearch"
											+"&excelImMethodName=getRecSearchListExcelImport&disInsColNum=8&fileName=UserInfoUpdate.xlsx";
		form.attr('action', actionUrl);
		form.attr('method', 'post');
		
		form.appendTo('body');
		form.submit();
		form.remove();
	}
	
	// 엑셀 일괄 업로드
	function fnExcelInsert(){
		var formData = new FormData($("#frmExcelFile")[0]);
		formData.append("insColNum",8);
		formData.append("insSeedNum",19);
		
		$.ajax({
			url : gGlobal.ROOT_PATH+"/RecSearch/CustInfoExcelInsertF.do",
			type : "POST",
			data:formData,  
			enctype : 'multipart/form-data',
			dataType:"json",
			processData: false,
		    contentType: false,
		    cache: false,
		    async:false,
			success : function(data) {
				var message = data.message;
				argoAlert('warning', message, '',	'parent.fnSearchListCnt(); argoPopupClose();');
			},error : function(xhr, status, error) {
				console.log(xhr);
				argoPopupClose();
			}
		}); 
	}
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
               		<span class="btn_r">
                       	<button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">수정</button>   
                    </span>               
                </div>
                <div class="input_area">
                	<form id="frmExcelFile">
	                	<table  class="input_table">
	                    	<tbody>
	                    		<tr>
	                            	<th colspan="1">엑셀파일</th>
	                                <td colspan="1">
	                                	<input type="file" id="excelFile" name="excelFile"/>                                
	                                </td>
	                            </tr>
	                            <tr>
	                            	<td>
	                            		<button type="button" class="btn_sm excel" title="Excel Export" id="btnExcel" data-grant="E">Excel Export</button>
	                            	</td>
	                            	<td colspan="1" >
		                            	<strong>
			                            	좌측에 샘플파일 다운로드 버튼이 있습니다.<br/>
											다운로드 받고 내용 수정 후, 사용해주시기 바랍니다.
										</strong>
									</td>	                            	
	                            </tr>
	                        </tbody>
	                    </table>
                    </form>
               	</div>
            </div>
        </section>
    </div>
</body>

</html>