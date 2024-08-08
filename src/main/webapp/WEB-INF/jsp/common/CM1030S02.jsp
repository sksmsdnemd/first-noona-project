<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.form.js"/>"></script>
<script>
var fvNotiId="";
var fvMode ='I' ;   
//-------------------------------------------------------------
//페이지 초기설정
//-------------------------------------------------------------   
$(document).ready( function() {	
	
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
    fvNotiId = sPopupOptions.pNotiId ;
 	fnInitCtrl();
 	fnInitFileProcess() ; /* 파일 업로드 관련 초기화 */
	
	if(fvNotiId !="") fnSearchDetail_CM1030S02(); //수정일 경우 데이터 조회
	else $('#ifEditor').attr('src', gGlobal.ROOT_PATH+"/scripts/smartEditor/argoSmartEditor2.html?ver=2017010906");
	
});


//-------------------------------------------------------------
//화면 공통 스크립트 호출 및 이벤트 처리
//-------------------------------------------------------------
function fnInitCtrl(){
	argoSetUserChoice01("btn_ipCM1030S02_User1", {"targetObj":"ipCM1030S02_User1", "multiYn":'Y'}); //상담사선택 팝업 연결처리(멀티)
	
    /* argoCbCreate("ipCM1030S02_NotiGubun", "ARGOCOMMON", "SP_UC_GET_CMCODE_01",{sort_cd:'NOTI_GUBUN'},{"selectIndex":0, "text":'<선택>', "value":''});
    argoCbCreate("ipCM1030S02_NotiGrade", "ARGOCOMMON", "SP_UC_GET_CMCODE_01",{sort_cd:'NOTI_GRADE'},{"selectIndex":0, "text":'<선택>', "value":''}); */
    argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정
    
    /* if(top.gMenu.EDIT_GRANT != 'A' ){
		$("#checkHidden1").css("display", "none");
		$("#checkHidden2").css("display", "none");
		//$(".input_search").css("margin-left", "0px; !important");
		$("#ipCM1030S02_NotiScope_1").prop("checked", true);
		fnSetNotiScope_CM1030S02("개인");
	}else{
		fnSetNotiScope_CM1030S02('전체');
	} */

    fnSetNotiScope_CM1030S02('전체');
    
    
    
    var today =argoSetFormat(argoCurrentDateToStr(),"-","4-2-2");
 	argoSetValue("ipCM1030S02_FrmDate", today);
 	argoSetValue("ipCM1030S02_EndDate", today);
    
    /* $("#btnCancel_CM1030S02").click(function(){
    	argoPopupClose();
	}); */	
    
	$("#btnSave_CM1030S02").click(function(){
		fnSave_CM1030S02();
	});		
 }
 
//-------------------------------------------------------------
//조회
//-------------------------------------------------------------
function fnSearchDetail_CM1030S02(){	
	var param = { "readHistYn":"N"
	    		 ,"notiId":fvNotiId}; 
	
	var multiService = new argoMultiService(fnCallbackSearch_CM1030S02);
	
	multiService.argoList("CM", "SP_CM1030M01_04", "__", param)
	            .argoList("CM", "SP_CM1030M01_05", "__", param)
	            .argoList("CM", "SP_CM1030M01_06", "__", param);
	
	multiService.action();  
}

//-------------------------------------------------------------
//조회 후 처리
//-------------------------------------------------------------
function fnCallbackSearch_CM1030S02(data, textStatus, jqXHR){
	try{
		if(data.isOk()){
					
			if(data.getRows(0) != ""){
				fvMode = 'U' ;
				var rows = data.getRows(0);				
				fnSetDetailInfo_CM1030S02(rows[0], data.getRows(1),data.getRows(2)) ;	    		
	    	}  	
	    } 
	} catch(e) {
		argoAlert(e);
	}
}

var fvContents ="" ;
//-------------------------------------------------------------
//조회 결과 화면에 설정 처리
//-------------------------------------------------------------

function fnSetDetailInfo_CM1030S02(rowMaster, rowFile, rowUser) {
		
	 argoSetValues("ipCM1030S02_", rowMaster);
	 
	 fnSetContents(rowMaster.notiId);
	 
	 // 공지대상이 개인 인 경우 대상자 표시
	 var arrAgentIds = new Array();
	 var arrAgentNms = new Array();
	 
	if(rowMaster.notiScope=='개인') {
		$.each(rowUser, function( index, row ) {
			arrAgentNms.push(row.agentNm) ;	
			arrAgentIds.push(row.targetMemb) ;	
           }); 

		fnSetNotiScope_CM1030S02('개인');
		
		argoSetValue('ipCM1030S02_User1Nm', arrAgentNms.join(',')) ;
		argoSetValue('ipCM1030S02_User1Id', arrAgentIds.join(',')) ;
	}
	
	//첨부파일 표시 처리
	$.each(rowFile, function( index, row ) {
		if(fvFileUploadMode=='IE') {
			$('#file_route'+(index+1)).prop('value', row.userfileNm);
			$('#file_route'+(index+1)).attr('data-value', row.userfileNm);				
			$('#file_route'+(index+1)).attr('data-path', row.filePath);	
		}else {
			$("#fileList").append('<li data-value=' + row.userfileNm +' data-path='+row.filePath +'>'+row.userfileNm +'<a href="#" class="btn_deleteFileList" onclick="fnRemoveFileList(this);">Delete</a></li>');
		}
	});
}


function fnSetContents(pNotiId){
	argoJsonSearchList('CM','SP_CM1030M01_09','__', {'notiId':pNotiId}, function(data, textStatus, jqXHR){
		if(data.isOk()){
			fvContents = '';
			$.each(data.getRows(), function( index, row ) {
				fvContents = fvContents + row.txt;
			});
			$('#ifEditor').attr('src', gGlobal.ROOT_PATH+"/scripts/smartEditor/argoSmartEditor2.html?ver=2017010906");
		}
	});
}

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//에디터에 컨텐츠 내용 전달용 함수
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
function fnGetContents() {
	return fvContents ;
}
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//저장-마스터
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
function fnSave_CM1030S02(){
	try{
		
		var sMsg ;
		if(fvMode=='I') { 
			sMsg = "작성내용을 저장하시겠습니까?" ;
		}else {
			sMsg = "변경내용을 저장하시겠습니까?" ;
		}
			
		var aValidate = {
			rows:[ 
				{"check":"length", "id":"ipCM1030S02_NotiTitle"      , "minLength":1, "maxLength":300, "msgLength":"제목은 1자 이상 300자(한글100자)까지 입력가능합니다."}
				/* ,{"check":"length", "id":"ipCM1030S02_NotiGubun"     , "minLength":1, "maxLength":50,  "msgLength":"공지구분을 선택하세요."}
				,{"check":"length", "id":"ipCM1030S02_NotiGrade"     , "minLength":1, "maxLength":50,  "msgLength":"공지등급을 선택하세요."}
				,{"check":"length", "id":"ipCM1030S02_FrmDate"       , "minLength":1, "maxLength":50,  "msgLength":"공지일자를 선택하세요."}
				,{"check":"length", "id":"ipCM1030S02_EndDate"       , "minLength":1, "maxLength":50,  "msgLength":"공지일자를 선택하세요."} */
			]
		};	
		
		if (argoValidator(aValidate) != true) return;
	   
		var strScope =	argoGetValue('ipCM1030S02_NotiScope');
	   
		if(strScope=='개인' ){
			if(argoGetValue('ipCM1030S02_User1Id')=="" ) {
	 			argoAlert("공지대상을 선택하세요");
				return;
			}
		}else {
		   	argoSetValue('ipCM1030S02_User1Id','');			
		}
	  
		var strContents = $('#ifEditor').get(0).contentWindow.getHTML();
		if(strContents =="") {
			argoAlert('내용을 작성하세요');
			return;
		}
	   
		if (strContents.length > 340000) { //DB처리제한
			argoAlert('공지사항 내용이 너무 깁니다.');
			return;
		}
	   
	    var Resultdata;
	    var param = { "cudGubun" : fvMode, "notiContents" : strContents} ;
		
	    argoConfirm(sMsg, function(){
	    	argoJsonCallSP('CM','SP_CM1030M01_02','ipCM1030S02_', param, fnCallbackSave_CM1030S02);
		});

	} catch(e) {
		argoAlert(e);
	}
}	 

	
	function fnCallbackSave_CM1030S02(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	var sMessage = ""
		    	
		    	if(fvMode=='I') { // 등록의 경우 새로 생성한 KEY 를 해당 컨트롤에 설정
		    		if(typeof(Resultdata.getRows()['keyId'])!="undefined"){
		    			var sKey  = Resultdata.getRows()['keyId'] ;
		    			
		    			 argoSetValue('ipCM1030S02_NotiId', sKey) ;
		    			 
		    	     }	    		
		    	}
	    	
		    	fnSaveFile_CM1030S02(); //파일 등록
		    	
		    }
	} catch(e) {
		argoAlert(e);    		
	}
	}
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	//저장-파일
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
	 function fnSaveFile_CM1030S02(){	
		    
		    var multiService = new argoMultiService(fnCallbackSaveFile_CM1030S02);
	        var sNotiId = argoGetValue('ipCM1030S02_NotiId');
	        
		    // 파일 데이터 처리		    
		    multiService.argoDelete("CM","SP_CM1030M01_03","__" ,{ notiId:sNotiId , fileId:'Y'});
		    
		    if(fvFileUploadMode=='IE') {
		    	
               for(var i=1 ; i<=5 ; i++) {
                	var oFileInput = $('#file_route'+i) ;
                	var sFile = $('#file_route'+i).val();                	
                		
                	if(sFile.length>0) {
                	var aFileNm = argoGetfileInfo(sFile);
                	var sFileNm = aFileNm[0]+'.'+aFileNm[1];

					 var cudRow = {notiId:sNotiId 
			    			    , filePath:oFileInput.attr('data-path') 
			    			    , fileRealNm:sFileNm
			    			    , fileUserNm:sFileNm
			    			    };
		  
		    		multiService.argoInsert("CM","SP_CM1030M01_07","__" ,cudRow);
                	}
                }
				 
			 }else {
				 
			    $('#fileList > li').each(function(index) {

			    	var sFileNm = $(this).attr('data-value') ;		    	
			    	
			    	 var cudRow = {notiId:sNotiId 
			    			    , filePath:$(this).attr('data-path')
			    			    , fileRealNm:sFileNm
			    			    , fileUserNm:sFileNm
			    			    };
			  
			    	multiService.argoInsert("CM","SP_CM1030M01_07","__" ,cudRow);
			    });	  
			 }
	         multiService.action();      
	
	 	}	 
	 
	 function fnCallbackSaveFile_CM1030S02(Resultdata, textStatus, jqXHR){
			try{
			    if(Resultdata.isOk()) {
			    	fnFileUpload() ; //파일 업로드 처리
			    }
		} catch(e) {
			argoAlert(e);    		
		}
		}	 

	 function fnAfterSave() {
	    	var sMessage = ""
		    	
		    	if(fvMode=='I') { // 등록의 경우 새로 생성한 KEY 를 해당 컨트롤에 설정
		    	    // 성공메시지 후 메인 화면 재조회  및 팝업닫기
		    	    sMessage = '성공적으로 등록 되었습니다.' ;	    	    
		    		
		    	}
		    	else { // 공지사항조회 화면에서 수정으로 호출한 경우
		    		 sMessage = '성공적으로 저장 되었습니다.' ;		    		
		    	}
	    	
	    	    // 파일 삭제처리
	    	    argoFileDelete(arrDelFileLIst.join(',')); 
	    	   
		    	argoAlert('warning', sMessage,'', 'parent.fnSearchList(); argoPopupClose();');
	 }
	 
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	//공유대상에 따라 조직선택 입력창 숨기기/보이기
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
	function fnSetNotiScope_CM1030S02(_opt) {		
		argoHide((_opt=='전체'? true : false), 'ipCM1030S02_User1Nm,btn_ipCM1030S02_User1') ;
	}
	
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	//파일 업로드 처리 
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━		
	var formDataFiles ;
	var fvFilePath  ;
	var fvFileUploadMode  ; /* IE 경우 formdata.append 외 제공되지 않아 multiful 파일 등록 아닌 <input 을 복수개 두어 처리하도록 함. */
	
	function fnInitFileProcess() {
		formDataFiles = new FormData();	
		
		//파일 저장될 경로 :  페이지>현재날짜(YYYYMMDD))>현재시간(HHMMSS) 폴더에  생성됨.
		//fvFilePath = getUrlFileNm()+'/'+argoCurrentDateToStr()+'/'+argoCurrentTimeToStr() ;
		
		
		// 2020.06.25 file 동기화를 위해 불필요한 하위폴더 제거
		// DB에서 가져오는 것으로 변경 20220907  gyu
		argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_SYSDATE','__',  null, function(data, textStatus, jqXHR){
			fvFilePath =  data.getRows().serverDate;
		});
		
	
		if ($.isFunction(formDataFiles.has)) { //IE 인 경우
			fvFileUploadMode = 'NON_IE' ;
			formDataFiles.append('ip_MenuId', fvFilePath) ; // 파일 업로드 경로 지정
		
		}else {
			fvFileUploadMode = 'IE' 			
			$('#filebox').hide(); 
			$('#filebox_ie').show(); 	
			
			var jForm = $("#frmFileUpload");
			$("#frmFileUpload").attr('action', gGlobal.ROOT_PATH+gGlobal.SVC_ARGO_UPATH); //argoAjaxUpload 사용시 설정 필요 - IE9일 경우 동작하기 위해
			
		  if($('#frmFileUpload #ip_MenuId').length == 0){
		        ($("<input type='hidden' name='ip_MenuId' id='ip_MenuId'>")).appendTo(jForm);
		        $('#frmFileUpload #ip_MenuId').val(fvFilePath);
		    }
		}
	}
	
	 function fnFileUpload(){	
//		 argoFileDelete('CM1030S02F/20170117/174705/테스트2.txt,CM1030S02F/20170117/173607/테스트1.txt') ;
//		 return ;
		 
		 var isFileUpload = false ;
		 if(fvFileUploadMode=='IE') {
			var sFlies = $('#fileselect1').val()+$('#fileselect2').val()+$('#fileselect3').val()+$('#fileselect4').val()+$('#fileselect5').val();
			isFileUpload = ( sFlies.length > 0 ? true : false );
			 
		 }else {
			 if ($.isFunction(formDataFiles.has)) { //formdata 에 있는 파일 중 최종 파일만 올리기 위해. 
				 var formData = new FormData(); 
				 $('#fileList > li').each(function(index) {
				    	var sFileNm = $(this).attr('data-value') ;		    
				    	
				    	if(formDataFiles.has(sFileNm)) { // IE에서 has 도 지원안함.
			   				formData.append(sFileNm, formDataFiles.get(sFileNm)) ;
				    		isFileUpload = true;
				    	 }  
				    });	   
			 } else { //IE는 dormdata.append 만 제공하므로  formdata 에 추가되었다가 삭제된 경우도 제외할 수 없는 문제... 데이터에선 제외되나. 파일은 올라간다.
				 var formData = formDataFiles ;		  
				 isFileUpload = ( nFiles > 0 ? true : false );
			 }
		 }
		 
		 if(isFileUpload) {
			 if(fvFileUploadMode=='IE') {
				 argoAjaxUpload("#frmFileUpload", fnUploadCallback);
			 }else {
				 formData.append('ip_MenuId', fvFilePath) ; // 파일 업로드 경로 지정				
				 argoAjaxUploadMultiple("#frmFileUpload", fnUploadCallback, formData);
			 }
		 } else {
			 fnAfterSave();
		 }
	}	 

	    // 파일 업로드 콜백
	    function fnUploadCallback(result){
	        var excelArr;
	        var Resultdata;
	        
	        var row = result.getRows();
	    
	        if(row.length > 0){
	        	$('#frmFileUpload').get(0).reset();
	        	fnAfterSave() ;
	        } 
	    }  
	   
	   var nFiles = 0 ; // 파일 등록 건수를 기록..	   
	   
	    //선택 파일 목록에 추가 처리	 IE일 아닌 경우   
	    function fnAddFileList(value) {		   
		   
	    	$('#file_route').prop('value', value);
	    	
	    	var jForm = $('#frmFileUpload');
	    	 
	        var jObj = $("[type=file]", jForm);
	        var iNumber = jObj.length;
	        
	        if (iNumber <= 0) return false;
	        
	        var files = jObj.get(0).files; //업로드한 파일들의 정보를 넣는다.
		        for (var i = 0; i < files.length; i++) {
		        	
			       	if($('#fileList > li').size()<5) {
			       		
			       		
			       		/* if(top.gLoginUser.AGENT_ID != '2021050001'){
			       			 if( (50*1024*1024)< files[i].size ) {
			        	    	argoAlert("첨부파일은 50Mb를 초과 할 수 없습니다.");
				        		break;
			        	    }	 
			       		} */
		        	    
		        	    if(files[i].name.indexOf(' ')>-1){
		        	    	argoAlert("파일명에 공백은 포함할수 없습니다.");
		        	    	break;
		        	    }
		        	    
		        	    nFiles = nFiles + 1 ;
		        	     formDataFiles.append(files[i].name, files[i]); //업로드한 파일을 하나하나 읽어서 FormData 안에 넣는다.
		        	     $("#fileList").append('<li data-new=Y data-value=' + files[i].name +' data-path='+fvFilePath +'>'+files[i].name+'<a href="#" class="btn_deleteFileList" onclick="fnRemoveFileList(this);">Delete</a></li>');
		        	} else {
		        		argoAlert("첨부파일은 5개까지 가능합니다.");
		        		break;
		        	}
		        }
	    }	   
	   
	   // 파일 추가/삭제 - IE일 경우 
	    var arrDelFileLIst = new Array(); // 삭제처리 대상 목록
	    
	    function fnAddFileList2(opt, value) {	    	
	    	var sFileInput = "#fileselect"+opt ;
	    	
	    	if(value==''){ // 파일 삭제인 경우
	    		 if(fvFileUploadMode=='IE') {
		        	// ie 일때 input[type=file] init.
		        	$(sFileInput).replaceWith( $(sFileInput).clone(true) );
		        } else {
		        	// other browser 일때 input[type=file] init.
		        	$(sFileInput).val("");
		        }
	    	
	    	// 파일 삭제 처리를 위해 삭제목록 추가
	    	    var sDelFile = $('#file_route'+opt).attr('data-path')+'/' + $('#file_route'+opt).attr('data-value') ;
	    	    
		        arrDelFileLIst.push(sDelFile)	;
	    	}else { // 파일 추가 		    	
	    		var jForm = $('#frmFileUpload');
		    	 
		        var jObj = $(sFileInput, jForm);
		        
		        var iNumber = jObj.length;
		        if (iNumber <= 0) return false;
		        
		        var files = jObj.get(0).files; //업로드한 파일들의 정보를 넣는다.
			        for (var i = 0; i < files.length; i++) {
			        	
			        	if( (50*1024*1024)< files[i].size ) {
		        	    	//argoAlert("첨부파일은 50Mb를 초과 할 수 없습니다.");
		        	    	//return;
			        		//break;			        		
		        	    }
	        	}
	    }	    	
	    	$('#file_route'+opt).prop('value', value);
	    	$('#file_route'+opt).attr('data-path', fvFilePath);	
	  }
	    
	   
	//선택 파일 목록에서 제거    	    
    function fnRemoveFileList(oli) {
    	var isNew = $(oli).parent().attr('data-new') ;
    	if(isNew=='Y') 	nFiles = nFiles - 1 ; 
    	
    	var strFile = $(oli).parent().attr('data-value') ;
    	
    	// 파일 삭제 처리를 위해 삭제목록 추가
	    var sDelFile = $(oli).parent().attr('data-path')+'/' + strFile;
        arrDelFileLIst.push(sDelFile)	;    	
    	
    	//formDataFiles.set(strFile, null); // formdata 에서 제거	    -IE에서 안됨
    	$(oli).parent().remove();
    }	 
	//파일 전체 삭제
    function fnRemoveFileAll() {    	
    	 $('#fileList > li').each(function(index) {
    		 fnRemoveFileList($(this).find('a'));
    	 });
    }	

	


</script>


</head>
<body>

	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="btn_topArea">
                <span class="btn_r">
            	<!-- <button type="button" id="btnCancel_CM1030S02" name="btnCancel_CM1030S02" class="btn_m">취소</button> -->  
            	<button type="button" id="btnSave_CM1030S02" name="btnSave_CM1030S02" class="btn_m confirm" data-grant="W">저장</button>  
            	<!--  <button type="submit" id="btnFile_CM1030S02" name="btnFile_CM1030S02" class="btn_m confirm" onClick="fnFileUpload();">파일</button>               
                 -->
                </span>
            </div>
            <div class="boardWrite_area">
            	<div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158">
                            <col width="">
                            <col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th >제목<span class="point">*</span></th>
                                <td colspan="3"><input type="text" id="ipCM1030S02_NotiTitle" name="ipCM1030S02_NotiTitle" style="width:500px;">
                                <input type="hidden" id="ipCM1030S02_NotiId" name="ipCM1030S02_NotiId" >
                                <input type="hidden" id="ipCM1030S02_NotiNo" name="ipCM1030S02_NotiNo" >
                                </td>
                            </tr>
                            <tr style="display: none;">
                            	<th>공지 구분/등급<span class="point">*</span></th>
                                <td>
                                	<select id="ipCM1030S02_NotiGubun" name="ipCM1030S02_NotiGubun" style="width:110px;"></select>
                                    <select id="ipCM1030S02_NotiGrade" name="ipCM1030S02_NotiGrade" style="width:110px;"></select>
                                 </td>
                                 <th>공지기간<span class="point">*</span></th>
                                 <td>
                                    <span class="select_date"><input type="text" id="ipCM1030S02_FrmDate" name="ipCM1030S02_FrmDate"  class="datepicker onlyDate"></span>
		                            <span class="text_divide">~</span>
		                            <span class="select_date"><input type="text" id="ipCM1030S02_EndDate" name="ipCM1030S02_EndDate" class="datepicker onlyDate"></span>
                            
                                </td>
                            </tr>
                            <tr style="display: none;">
                            	<th>공지범위</th>
                                <td colspan="3">
                                   	<span class="checks" id="checkHidden1"><input type="radio" name="ipCM1030S02_NotiScope"  id="ipCM1030S02_NotiScope"  value="전체" checked onclick="fnSetNotiScope_CM1030S02('전체');"><label for="ipCM1030S02_NotiScope">전체</label></span>
                                   	<span class="checks ml15" id="checkHidden2"><input type="radio" name="ipCM1030S02_NotiScope"  id="ipCM1030S02_NotiScope_1" value="개인"><label for="ipCM1030S02_NotiScope_1" onclick="fnSetNotiScope_CM1030S02('개인');">개인</label></span>
                                    <span class="input_search" style="width:245px;">
                                     <input type="text" id="ipCM1030S02_User1Nm" name="ipCM1030S02_User1Nm" placeholder="대상을 선택하세요" class="input_txtArea">
			                         <input type="hidden" id="ipCM1030S02_User1Id" name="ipCM1030S02_User1Id" >
		                            <a href="#" id="btn_ipCM1030S02_User1" class="btn_searchInput">검색</a>
		                           
		                           </span>                           
                                </td>
                            </tr>
                            <tr>
                            	<th>첨부파일</th>
                                <td colspan="3">
                                 <form id="frmFileUpload" method="post" enctype="multipart/form-data" >
                                   <div id="filebox" >
                                   <div class="filebox">                                	
                                    	<input type="text" readonly id="file_route" style="width:400px;">
                                        <label for="fileselect">파일 추가</label>
                                        <input type="file" id="fileselect" name="fileselect[]" multiple onChange="fnAddFileList(this.value); ">
                                   </div>
                                    <div class="filebox_list">
                                    	<div class="filebox_title">파일첨부<a href="#" class="btn_allDelete" onclick="fnRemoveFileAll();">전체 삭제</a></div>
                                        <div class="filebox_scroll">
                                            <ul id="fileList">
                                           </ul>
                                        </div>
                                    </div> 
                                    </div>   
                                    <div id="filebox_ie" style='display:none'>
                                    <div class="filebox">                                	
                                    	<input type="text" readonly id="file_route1" style="width:400px;" class="input_file">
                                        <label for="fileselect1"></label>
                                        <input type="file" id="fileselect1" name="fileselect1" onChange="fnAddFileList2(1, this.value); ">
                                        <button type="button" id="btnFileDel1_CM1030S02" name="btnFileDel1_CM1030S02" class="btn_fileRemove" onClick="fnAddFileList2(1, ''); ">삭제</button>  
                                   </div>    
                                   <div class="filebox" style="margin-top:1px">   
                                  	<input type="text" readonly id="file_route2" style="width:400px;" class="input_file">
                                        <label for="fileselect2">파일 추가</label>
                                         <input type="file" id="fileselect2" name="fileselect2" onChange="fnAddFileList2(2, this.value); ">
                                        <button type="button" id="btnFileDel2_CM1030S02" name="btnFileDel2_CM1030S02" class="btn_fileRemove" onClick="fnAddFileList2(2, ''); ">삭제</button>  
                                  </div>
                                   <div class="filebox" style="margin-top:1px">   
                                  	<input type="text" readonly id="file_route3" style="width:400px;" class="input_file">
                                        <label for="fileselect3">파일 추가</label>
                                          <input type="file" id="fileselect3" name="fileselect3" onChange="fnAddFileList2(3, this.value); ">
                                        <button type="button" id="btnFileDel3_CM1030S02" name="btnFileDel3_CM1030S02" class="btn_fileRemove" onClick="fnAddFileList2(3, ''); ">삭제</button>  
                                 </div>
                                   <div class="filebox" style="margin-top:1px">   
                                  	<input type="text" readonly id="file_route4" style="width:400px;" class="input_file">
                                        <label for="fileselect4">파일 추가</label>
               						     <input type="file" id="fileselect4" name="fileselect4" onChange="fnAddFileList2(4, this.value); ">
                                        <button type="button" id="btnFileDel4_CM1030S02" name="btnFileDel4_CM1030S02" class="btn_fileRemove" onClick="fnAddFileList2(4, ''); ">삭제</button>  
                                                       </div>
                                      <div class="filebox" style="margin-top:1px">   
                                  	<input type="text" readonly id="file_route5" style="width:400px;" class="input_file">
                                        <label for="fileselect5">파일 추가</label>
                     					<input type="file" id="fileselect5" name="fileselect5" onChange="fnAddFileList2(5, this.value); ">
                                        <button type="button" id="btnFileDel5_CM1030S02" name="btnFileDel5_CM1030S02" class="btn_fileRemove" onClick="fnAddFileList2(5, ''); ">삭제</button>  
                                                      </div>
                                    </div>   
                                 </form>                                 
                                </td>
                            </tr> 
                        </tbody>
                    </table>
                </div>
                <div class="editor_area" style="display: none;">  
                      <iframe id="ifEditor" scrolling="no" frameborder="0" src="" style="width:100%;height:100%;"></iframe>                  
                  <!--  <textarea id="ipCM1030S02_NotiContents" name="ipCM1030S02_NotiContents" style="width:100%;height:100%;border:0px  !important ">
                    </textarea> --> 
                </div>
            </div>
        </section>
    </div>
     <!-- 파일다운로드 처리를 위한 iframe 삽입 -->
    <iframe id="fileDown" style='display:none' src="" width="0" height="0"></iframe>
</body>
</html>