<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script>

//-------------------------------------------------------------
//페이지 초기설정
//-------------------------------------------------------------   
var fvNotiId ;
var fvGlobalPath;

$(function () {
	fnSearchGlobalPath();
	
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
	};
	
	fvNotiId = sPopupOptions.pNotiId ;
	if(fvNotiId !="") fnSearchDetail_CM1030S01();
	
	
});

function fnSearchGlobalPath(){
	fvGlobalPath = "/";
	argoJsonSearchList('ARGOCOMMON', 'searchGlobalFilePath', '_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				var dataRow = data.getRows()[0];
				fvGlobalPath = dataRow.globalFilePath;
			} 
		}catch (e) {
			console.log(e);
		}
	});
}

//-------------------------------------------------------------
//조회
//-------------------------------------------------------------
function fnSearchDetail_CM1030S01(){	
var param = { "readHistYn":"Y", "notiId":fvNotiId}; 

var multiService = new argoMultiService(fnCallbackSearch_CM1030S01);

multiService.argoList("CM", "SP_CM1030M01_04", "__", param)
            .argoList("CM", "SP_CM1030M01_05", "__", param)
            .argoList("CM", "SP_CM1030M01_06", "__", param);

multiService.action();  
}

//-------------------------------------------------------------
//목록조회 - 
//-------------------------------------------------------------
function fnCallbackSearch_CM1030S01(data, textStatus, jqXHR){
	try{
		if(data.isOk()){
					
			if(data.getRows(0) != ""){
				var rows = data.getRows(0);				
				fnSetDetailInfo_CM1030S01(rows[0], data.getRows(1),data.getRows(2)) ;	    		
	    	}  	
	    } 
	} catch(e) {
		argoAlert(e);
	}
}

var fvFileList ;
var fvDelFileLIst = new Array(); // 삭제처리 대상 목록
//-------------------------------------------------------------
//조회정보 설정
//-------------------------------------------------------------
function fnSetDetailInfo_CM1030S01(rowMaster, rowFile, rowUser) {
	
	fvFileList = rowFile ;
	
	// 메인 정보 설정
	$('#no_CM1030S01').html('번호: '+ rowMaster.notiNo);
	$('#date_CM1030S01').html('등록일 : '+ rowMaster.createDt);
	$('#register_CM1030S01').html('등록자 : '+ rowMaster.createAgentInfo);
	$('#hit_CM1030S01').html('조회수 : '+ rowMaster.readCnt);
	
	$('#title_CM1030S01').html(rowMaster.notiTitle);
	//$('#state_CM1030S01').html('('+rowMaster.notiGubunNm+'/'+rowMaster.notiGradeNm +')' );
	// $('#contents_CM1030S01').html(rowMaster.notiContents);
	
	//fnSetContents(rowMaster.notiId);
	
	// 공지대상 설정 ---------------------------------------------------------------------------------
	var srltHtml ="";
	
	if(rowMaster.notiScope=='개인') {
		srltHtml = '개인:  총' + rowMaster.targetCnt + '명' ;
		
		if(rowUser!="") {
		srltHtml = srltHtml +  '<span class="more_area">'
		     	 + '<a href="#" class="btn_more">more</a>'
		         +'<div class="pop_detailList">'
		         +	'<ul>';
  
		$.each(rowUser, function( index, row ) {
			srltHtml = srltHtml + '<li>' + row.team + '/' + row.agentNm + '(' + row.sabun+')</li>' ;        		
         }); 
		srltHtml = srltHtml + '</ul> </div> </span>';
		}
	}
	
	$('#personal_CM1030S01').html(srltHtml);
	
	//첨부파일 설정 ------------------------------------------------------------------------------------
   srltHtml ="";
	srltHtml = '첨부파일(<strong>' + rowMaster.attachFileCnt + '</strong>)' ;
	
	if(rowFile!="") {
	srltHtml = srltHtml +  '<span class="download_area">'
	     	 + '<a href="#" class="btn_more download">download</a>'
	         +' <div class="pop_downList">'
	      //   + '<div class="downList_t"><a href="#" class="btn_allDown" onclick=fnFileAllDownload() >전체 다운로드</a></div>'
	         +	'<ul>';
 
	$.each(rowFile, function( index, row ) {
		//srltHtml = srltHtml + '<li><a href="#" title="' + row.userfileNm + '" onclick=argoFileDownload("'+row.filePath +'","'+ row.userfileNm + '");>' + row.userfileNm + '</a></li>' ;  
		srltHtml = srltHtml + '<li><a href="#" title="' + row.userfileNm + '" onclick=argoFileDownload("'+row.filePath +'","'+ row.userfileNm + '","' +  fvGlobalPath + '");>' + row.userfileNm + '</a></li>' ;
      fvDelFileLIst.push(row.filePath+'/' + row.userfileNm)	; // 삭제시 파일삭제처리를 위해 삭제대상 파일 목록 저장
	
	}); 
	srltHtml = srltHtml + '</ul> </div> </span></span>';
	}	
	$('#file_CM1030S01').html(srltHtml);
                        
	// 공지대상, 파일첨부 more 에 이벤트 연결
	$(".btn_more").on("click", function(){
		if( $(this).hasClass("on") ){
			$(this).removeClass("on");	
		}else{
			$(".btn_more").removeClass("on");	
			$(this).addClass("on");
		}
	});
	
}

//-------------------------------------------------------------
//전체다운로드   제외 - IE에서 파일 다운로드시 자동으로 사용자에게 묻도록 되어 있어 동작 안함.
//-------------------------------------------------------------
function fnFileAllDownload(){
	    $.each(fvFileList, function( index, row ) {
		var sfileNm = encodeURI(encodeURIComponent(row.userfileNm)) ;
		var url = gGlobal.ROOT_PATH+'/common/ucFileDownloadF.do?file_name='+ sfileNm +'&file_path='+row.filePath + '&global_path='+fvGlobalPath ;
		 $('#fileDown'+index).attr('src', url);
	});
}


</script>

</head>
<body style="height:200px;">
	<div class="sub_wrap pop" style="height:200px; padding-bottom: 0px;">
        <section class="pop_contents">
            <div class="boardView_area" style="margin-top:15px; height:60px;">
            	<div class="view_top">
                	<div class="info_t">
                    	<div class="info_l">
                    	    <span class="txt_date" id="no_CM1030S01" ></span>
                        	<span class="txt_Regist" id="date_CM1030S01"></span>
                            <span class="txt_Regist" id="register_CM1030S01"></span>
                            <span class="txt_hits" id="hit_CM1030S01"></span>
                             <span class="txt_personal" id="personal_CM1030S01">                            
                            	<span class="more_area">
                                	<a href="#" class="btn_more">more</a>
                                    <div class="pop_detailList">
                                    	<ul>
  	                                    </ul>
                                    </div>
                                </span>
                            </span>
                        </div>
                        <div class="info_r">
                        	<span class="txt_file" id="file_CM1030S01" style="font-size: 11.5pt; font-weight: bold;" >
                            	<span class="download_area">
                                	<a href="#" class="btn_more download">download</a>
                                    <div class="pop_downList">
                                    	<!-- <div class="downList_t"><a href="#" class="btn_allDown">전체 다운로드</a></div>  -->
                                    	<ul>
	                                    </ul>
                                    </div>
                                </span>                            
                            </span>
                        </div>
                    </div>
                    <div class="info_b">
                    	<div class="info_l">
                            <span class="title" id="title_CM1030S01"> </span>
                        </div>
                        <div class="info_r">
                            <!-- <button class="btn_print print_hidden" title="인쇄" id="btnPrint_CM1030S01" name="btnPrint_CM1030S01" >인쇄</button> -->                            
                        </div>
                    </div>
                </div>
                <!-- <div class="view_bottom" id="contents_CM1030S01"></div> -->
            </div>
        </section>
    </div>
    <!-- 파일다운로드 처리를 위한 iframe 삽입 -->
    <iframe id="fileDown" style='display:none' src="" width="0" height="0"></iframe>
    
    <!-- 전체다운로드 기능 제외 - IE에서 파일 다운로드시 자동으로 사용자에게 묻도록 되어 있어 동작 안함.
    
    <iframe id="fileDown0" style='visibility:hidden' src="" width="0" height="0"></iframe>
    <iframe id="fileDown1" style='visibility:hidden' src="" width="0" height="0"></iframe>
    <iframe id="fileDown2" style='visibility:hidden' src="" width="0" height="0"></iframe>

     -->
</body>
</html>