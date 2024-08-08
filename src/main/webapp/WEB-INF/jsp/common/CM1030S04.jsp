<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.form.js"/>"></script>
<script>
	//-------------------------------------------------------------
	//페이지 초기설정
	//-------------------------------------------------------------   
	$(document).ready( function() {	
		fnInitCtrl();
	});
	
	
	//-------------------------------------------------------------
	//화면 공통 스크립트 호출 및 이벤트 처리
	//-------------------------------------------------------------
	function fnInitCtrl(){
		$("#btnFileDownload").click(function(){
			fnFileDownload();
		});		
	}
	 
	//-------------------------------------------------------------
	//조회
	//-------------------------------------------------------------
	/* function fnSearch(){
		var multiService = new argoMultiService(fnCallbackSearch);
		multiService.argoList("ARGOCOMMON", "searchGlobalFilePath", "__", {});
		multiService.action();  
	} */
	
	//-------------------------------------------------------------
	//조회 후 처리
	//-------------------------------------------------------------
	/* function fnCallbackSearch(data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getRows(0) != ""){
					argoSetValue("ip_GlobalFilePath", data.getRows(0)[0].globalFilePath);
		    	}  	
		    } 
		} catch(e) {
			argoAlert(e);
		}
	} */

	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	//저장-마스터
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
	function fnFileDownload(){
		try{
			var multiService = new argoMultiService(fnCallbackSave);
			
			argoConfirm("파일을 다운로드 하시겠습니까?", function(){
				var filePath = argoGetValue("ip_FilePath");
				var fileName = filePath.split("/").pop();
				console.log("fileName : " + fileName);
				
				var lastIndex = filePath.lastIndexOf("/");
				if(lastIndex != -1){
					var updatePath = filePath.substring(0, lastIndex+1);
					filePath = updatePath;
					console.log("최종경로 : " + filePath);
				}
				
				argoFileDownload(filePath, fileName, "");
				
				//argoFileDownload("'+row.filePath +'","'+ row.userfileNm + '","' +  fvGlobalPath + '")
				
				/* var globalPathFirstChar = globalFilePath.charAt(0);
				var globalPathLastChar = globalFilePath.slice(-1);
				
				if(globalFilePath.length == 0){
					globalFilePath = "/";
				}else{
					if(globalPathFirstChar != "/"){
						globalFilePath = "/" + globalFilePath;
					}
					
					if(globalPathLastChar != "/"){
						globalFilePath = globalFilePath + "/";
					}
				}
				
				multiService.argoInsert("ARGOCOMMON", "updateGlobalFilePath", "_", {globalFilePath:globalFilePath});
				multiService.action(); */
			});
			
		} catch(e) {
			argoAlert(e);
		}
	}	 

	
	function fnCallbackSave(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	argoAlert('warning', '성공적으로저장 되었습니다.','', 'parent.fnSearchList(); argoPopupClose();');
		    }
		} catch(e) {
			argoAlert(e);    		
		}
	}
	

</script>


</head>
<body>

	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="btn_topArea">
                <span class="btn_r">
            	<!-- <button type="button" id="btnCancel_CM1030S02" name="btnCancel_CM1030S02" class="btn_m">취소</button> -->  
            	<button type="button" id="btnFileDownload" name="btnFileDownload" class="btn_m confirm" data-grant="W">저장</button>  
            	<!--  <button type="submit" id="btnFile_CM1030S02" name="btnFile_CM1030S02" class="btn_m confirm" onClick="fnFileUpload();">파일</button>               
                 -->
                </span>
            </div>
            <div class="boardWrite_area">
            	<div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="100">
                            <col width="300">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>파일경로<span class="point">*</span></th>
                                <td>
                                	<input type="text" id="ip_FilePath" name="ip_FilePath" style="width:300px;" placeholder="ex) /bridgetec/veloce/filePath/test.log">
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>
    </div>
    <iframe id="fileDown" style='display:none' src="" width="0" height="0"></iframe>
</body>
</html>