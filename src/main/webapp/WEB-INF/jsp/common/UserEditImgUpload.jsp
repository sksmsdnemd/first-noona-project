<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.form.js"/>"></script>
<script>
$(function () {
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
  	fnInitCtrl();
});

function fnInitCtrl() {
	fnInitFileProcess();
	
	$("#btnSave_EditImg").click(function(){
		fnSave_EditImg();
	});
}

var fvFilePath  ;

function fnInitFileProcess() {

	//파일 저장될 경로 :  페이지>현재날짜(YYYYMMDD))>현재시간(HHMMSS) 폴더에  생성됨.
	fvFilePath = getUrlFileNm()+'/'+argoCurrentDateToStr()+'/'+argoCurrentTimeToStr() ;
		
    var jForm = $("#frmFileUpload");
		$("#frmFileUpload").attr('action', gGlobal.ROOT_PATH+gGlobal.SVC_ARGO_UPATH); //argoAjaxUpload 사용시 설정 필요 - IE9일 경우 동작하기 위해
		
	  if($('#frmFileUpload #ip_MenuId').length == 0){
	        ($("<input type='hidden' name='ip_MenuId' id='ip_MenuId'>")).appendTo(jForm);
	        $('#frmFileUpload #ip_MenuId').val(fvFilePath);
	    }
}

//-------------------------------------------------------------
//저장
//-------------------------------------------------------------
var fvFileNm ;
function fnSave_EditImg(){
	
	var sFile = $('#file_route').val();     

    if (sFile == "") {
    	argoSmallAlert("파일을 선택하세요");
    	return false;
    }
    
	argoSmallConfirm("사진을 업로드 하시겠습니까?", function(){
		
		var jForm = $('#frmFileUpload');
	    var jObj = $("[type=file]", jForm);
	    var iNumber = jObj.length;

	    if (iNumber <= 0) 	return false;
	   	    
	    var files = jObj.get(0).files; //업로드한 파일들의 정보를 넣는다.
	        for (var i = 0; i < files.length; i++) {
	        	    if( (20*1024*1024)< files[i].size ) {
	        	    	argoSmallAlert("첨부파일은 20Mb를 초과 할 수 없습니다.");
		        		break;
		        		return false;
	        	    }
	         }

	    if(sFile.length>0) {
        	var aFileNm = argoGetfileInfo(sFile);
        	var sFileNm = aFileNm[0]+'.'+aFileNm[1];
            fvFileNm = sFileNm;
            
            if(sPopupOptions.pParentId=="UserEdit") {
	        	 Resultdata = argoJsonUpdate("HR","SP_HR1010M01_05","__"
	        			                   , {"cudGubun":"IMGUUPLOAD" 
	        		                          ,user1Id:sPopupOptions.pUserId
	        		                          ,imgPath:fvFilePath
	        		                          ,imgRealFileName:sFileNm
	        		                          ,imgUserFileName:sFileNm }
	        	 );	
	        	 
	        	 if(Resultdata.isOk()) {
	      	    	argoAjaxUpload("#frmFileUpload", fnUploadCallback);
	      	    }
            }
		}
	});      	
     	   
}

// 파일 업로드 콜백
function fnUploadCallback(result){
    var row = result.getRows();

    if(row.length > 0){
    	argoSmallAlert('warning', '성공적으로 업로드 되었습니다.','',function(){
		
    	parent.fnInitUser();     
   		argoPopupClose();
   		});
    } 
}  
</script>
</head>
<body>
	<div class="sub_wrap pop small">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt11">
            	<div class="cont_area">
                	<ul class="cont_list">
                    	<li>
                        	<strong class="title">사진 선택</strong>
			                <div class="filebox" style="display:inline-block">
			                    <form id="frmFileUpload" method="post" enctype="multipart/form-data" >
                                <input type="text" readonly id="file_route" style="width:200px;">
                                <label for="fileselect">파일 추가</label>
                                <input type="file" id="fileselect" name="fileselect[]" onChange="$('#file_route').prop('value', this.value); ">
                                </form>
                            </div>
                        </li>
                    </ul>
                    <div class="cont_info">
                    	<ul class="info_list">
                        	<li>업로드할 사진 파일을 선택하세요. 권장 사이즈(125 * 125)</li>
                        </ul>
                    </div>
                </div>
                <div class="btn_areaB txt_r">
                    <button type="button" class="btn_m confirm" id="btnSave_EditImg" name="btnSave_EditImg">저장</button>    
            	</div>              
            </div>            
        </section>
    </div>
</body>
</html>