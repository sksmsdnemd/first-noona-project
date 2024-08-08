<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html >
<html>
<head>
<title>ARGO</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />
<%@ include file="/WEB-INF/jsp/include/common.jsp"%>
<script type="text/javascript" src="<c:url value="/scripts/security/sha512.js"/>"></script>

<script>

$(document).ready( function() {
	
	fnInitCtrl();
	
	/* 상담사 기본정보 셋팅 */
	fnInitUser();
	
	argoSetDatePicker(); //Date 픽커 - 날짜 입력항목에 달력설정
	
	$.setOptionsSW = {
			title : "",
			url : "",
			width : "435",
			height : "250",
			pid:"",
			ptype:""
			
		}
	$.fn.openSmallWindow = function( options ){
		options = $.extend( null, $.setOptionsSW, options );
		this.each( function(index){			
			var window_views = new Window_views( this, options.url, options.title, options.width, options.height, options.pid, options.ptype );	
		});		
		return this;
	}	
});

function fnInitCtrl(){
	
	/* 사진 편집 */
	$("#btnPopImg").click(function(){
	 	gPopupOptions = {"pUserId": $('#s_User1Id').val() ,"pParentId" :"UserEdit"} ;
	 	fnSmallPopupWindow(this,'사진업로드', 'UserEditImgUploadF.do', '415', '172');
	});
	
	/* 비밀번호 변경  */
	$("#btnPopPwd").click(function(){
		gPopupOptions = {"pUserId": argoGetValue('s_User1Id') } ;
		argoPopupWindow('비밀번호변경', 'UserEditPwdF.do',  '364', '271' );
		
	});	
	
}
/* 상담사 기본정보 셋팅 */
function fnInitUser(){
	argoJsonSearchOne('ARGOCOMMON','SP_CM_USEREDIT_01','__', {}, function(data, textStatus, jqXHR) {
   		try {
   			if (data.isOk) {

				/* 성별 설정 */
				$('input:radio[name=genderKind]:input[value=' + data.getRows()['genderKind'] + ']').attr("checked", true);
				
				/* 소속 */
				var teamNm = data.getRows()['centerNm'] + "/" + data.getRows()['partNm'] + "/" + data.getRows()['teamNm']
				
				/* 사용 여부 */
				var hideYn = '';
				if(data.getRows()['hideYn'] == 0) hideYn = '사용';
				if(data.getRows()['hideYn'] == 1) hideYn = '미사용';
				
				/* 평가정보 */
				if(data.getRows()['scheTargetYn'] == '1')	$("input:checkbox[id='scheTargetYn']").prop("checked", true); // 스케줄 관리
				if(data.getRows()['eduTargetYn']  == '1') 	$("input:checkbox[id='eduTargetYn']").prop("checked", true);  // 교육평가
				if(data.getRows()['qaTargetYn']   == '1')  	$("input:checkbox[id='qaTargetYn']").prop("checked", true);	  // 통화품질
				if(data.getRows()['kpiTargetYn']  == '1') 	$("input:checkbox[id='kpiTargetYn']").prop("checked", true);  // 성과실적

				/* 이미지 */
				if(argoNullToSpace(data.getRows()['imgRealFilename']) != "") {
	    			
					var sImgFile = data.getRows()['imgRealFilename'] ;
	    			
	    			sImgFile = encodeURI(sImgFile, "UTF-8") ;
	    			var sFullPath = location.protocol+"//"+location.hostname +(location.port ? ":"+location.port:"" ) + gGlobal.ROOT_PATH+gGlobal.FILE_PATH+data.getRows().imgPath+"/"+sImgFile ;
	    			$('#userImg').html('<img src="'+sFullPath + '" width="125" height="125">') ;
	    			    
	    		} else {
	    			$('#userImg').html("");
	    		}
				
				parent.fnUserPhoto();
				
				/* 정보 셋팅 */
				$('#s_User1Id').val(data.getRows()['agentId']);	// 상담사ID
				$('#sabun').html(data.getRows()['sabun']); 		// 행번
				$('#agentNm').val(data.getRows()['agentNm']);	// 상담사명
				$('#birthYmd').val(data.getRows()['birthYmd']);	// 생년월일
				$('#telNo').val(data.getRows()['telNo']);		// 전화번호
				$('#grantId').html(data.getRows()['grantId']);	// 권한
				$('#hideYn').html(hideYn);		// 숨김
				$('#teamNm').html(teamNm);		// 소속
				$('#agentJikgupNm').html(data.getRows()['agentJikgupNm']); // 직급
				$('#agentJikchkNm').html(data.getRows()['agentJikchkNm']); // 직책
				$('#daynightGubun').html(data.getRows()['daynightGubun']); // 주/야간
				$('#jikjongKind').html(data.getRows()['jikjongKind']);	   // 직종
				$('#contractFrm').html(data.getRows()['contractFrm']);	   // 계약시작
				$('#contractEnd').html(data.getRows()['contractEnd']);	   // 계약종료
				$('#tmKind').html(data.getRows()['tmKind']);			   // 업무그룹
				$('#jaejikGubun').html(data.getRows()['jaejikGubun']);	   // 재직구분
				$('#enterYmd').html(data.getRows()['enterYmd']);		   // 입사일자
				
				//전화번호 설정
	    		var sTel = argoGetValue('telNo') ;	    		
	    		argoSetValue('telNo_Ext', argoFormatterTelNo(sTel ));
				
   			} else {
   			}
   		} catch (e) {
   			console.log(e);
   		}
   	});
}

/* 상담사 정보 저장 */
function fnUserEditSave(){

	var agentNm    = $('#agentNm').val();
	var birthYmd   = $('#birthYmd').val().replace(/-/gi, '');
	var genderKind = $("input:radio[name='genderKind']:checked").val();
	var telNo      = $('#telNo').val();
	
	if(agentNm == ''){
		argoAlert("상담사명을 입력해주세요.");
		return;
	};
	
	var param = { "agentNm"    : agentNm
				, "birthYmd"   : birthYmd									
				, "genderKind" : genderKind
				, "telNo"      : telNo
				};
		
	 Resultdata = argoJsonUpdate("ARGOCOMMON","SP_CM_USEREDIT_02","__", param);		 
	    if(Resultdata.isOk()) {
	    	argoAlert('warning', '성공적으로 저장 되었습니다.', '', 'argoPopupClose();');
	    }
}



function Window_views( selector, url, title, width, height, pid, ptype ){		
	this.selector = $(selector);
	this.url = url;
	this.title = title;
	this.width = width;
	this.height = height;
	this.pid = pid;
	this.ptype = ptype ; /* opener type - M (메인) / P (팝업) */
	this.init();
	this.popLayer = $("body").find( "#pop" + id_num );
	this.popBox = this.popLayer.find(".pop_div");
	this.popBg = this.popLayer.find(".pop_bgLayer");
	this.btn_close = this.popLayer.find(".btn_popClose");
	this.addEvent();	

	this.popBox.css({"top":(342 - 250) / 2, "left":(1100 - 435) / 2, "opacity":1});
}

Window_views.prototype.init = function(){
	$("body").addClass("pop_layer");	
	this.make_window();	
		
}

var id_num = 0;
Window_views.prototype.make_window = function(){
	id_num = $("div.pop_layer.small").length;
	var html = "";
	html += '<div class="pop_layer small" data-pid="'+ this.pid +'" id="pop'+ id_num +'">'
    html += 	'<div class="pop_bgLayer"></div>'
    html +=     '<div class="pop_div" style="width:' + this.width + 'px; height:' + this.height + 'px;">'
    html +=         '<div class="pop_title"><div class="title_area">' + this.title + '<a href="#" class="btn_popClose">닫기</a></div></div>'
    html +=         '<div class="pop_content">'
    html +=         	'<iframe src="' + this.url + '" name="pop'+ id_num +'" data-pid="'+ this.pid +'" data-ptype="'+ this.ptype +'" ></iframe>'
    html +=         '</div></div></div>'
    	
	$("body").append( html );
	
}

Window_views.prototype.addEvent = function(){
	this.btn_close.on( "click", function(){
		$("body").removeClass("pop_layer");
		$(this).closest(".pop_layer").remove();	
		return false;
	});	
	
	this.popBg.on( "click", function(){
		$("body").removeClass("pop_layer");
		$(this).closest(".pop_layer").remove();
		return false;	
	});
	
}

//타이틀, url, 창 넓이, 창 높이
function fnSmallPopupWindow( _selector,_title, _url, _width, _height){
	
	// 팝업 오픈 시 호출자가 메인이 아닐 경우 (팝업에서 팝업 호출할 경우) 메인을 기준으로 화면 lock 처리 되어야 하므로 parent 의 openwindow 를 호출해야함.	
	var sOpenerId = $(window.frameElement.parentNode).closest('.pop_layer').attr("id");
	var openWindow ;
	    
	gPopupOptions = gPopupOptions ;
	openWindow = $(_selector).openSmallWindow({
		title:_title,
		url:_url,
		width:_width,
		height:_height,
		pid:sOpenerId,
		ptype:"M"
	});
}

</script>

</head>

<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="info_t">
                    <div class="sub_l fix175">
                        <div class="user_infoBox pop">
                            <div class="user_infoB" style="height:215px;">
                                <div class="photo_area">
                                    <p class="photo_box">
                                        <span class="user_photo">
                                            <!--<img src="../images/photo_sample.jpg" width="125" height="125" alt="photo">-->
                                            <span class="user_photo" id="userImg">                                   
		                                     	<!-- 이미지동적 추가 -->                                                                    
		                                    </span>                                                                     
                                        </span>
                                        <button type="button" id="btnPopImg" name="btnPopImg" class="btn_photoEdit" title="사진 편집" >사진 편집</button>   
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="sub_r pl175">
                        <div class="input_area">
                            <table class="input_table">
                                <colgroup>
                                    <col width="12%">
                                    <col width="21%">
                                    <col width="12%">
                                    <col width="22%">
                                    <col width="12%">
                                    <col width="21%">
                                </colgroup>
                                <tbody>
                                    <tr>
                                        <th>행번</th>
                                        <td>
                                        	<span class="info_txt" id="sabun"></span>
                                        	<input type="hidden" id="s_User1Id" name="s_User1Id">
                                        </td>
                                        
                                        <th>소속</th>
                                        <td><span class="info_txt" id="teamNm"></span></td>
                                        
                                        <th>업무그룹</th>
                                        <td><span class="info_txt" id="tmKind"></span></td>
                                    </tr>
                                    <tr>
                                        <th>상담사명</th>
                                        <td><input type="text" id="agentNm" name="agentNm" class="w100" maxlength="30"></td>
                                        
                                        <th>직급</th>
                                        <td><span class="info_txt" id="agentJikgupNm"></span></td>
                                            
                                        <th>재직구분</th>
                                        <td><span class="info_txt" id="jaejikGubun"></span></td>
                                        
                                    </tr>
                                    <tr>
                                        <th>생년월일</th>
                                        <td><span class="select_date"><input type="text" id="birthYmd" class="datepicker"></span></td>
                                        
                                        <th>직책</th>
                                        <td><span class="info_txt" id="agentJikchkNm"></span></td>
                                        
                                        <th>입사일자</th>
                                        <td><span class="info_txt" id="enterYmd"></span></td>
                                        
                                    </tr>
                                    <tr>
                                        <th>성별</th>
                                        <td>
                                            <span class="checks"><input type="radio" id="g1" name="genderKind" value='F' checked><label for="g1">여</label></span>
                                            <span class="checks ml15"><input type="radio" id="g2" name="genderKind" value='M'><label for="g2">남</label></span>
                                        </td>
                                        
                                        <th>주/야간</th>
                                        <td><span class="info_txt" id="daynightGubun"></span></td>
                                        
                                        <th>권한</th>
                                        <td><span class="info_txt" id="grantId"></span></td>
                                    </tr>
                                    <tr>
                                        <th>전화번호</th>
                                        <td>
                                        	<input type="text"  id="telNo_Ext" name="telNo_Ext" class="w100 onlyTelNo" data-link="telNo">
                                        	<input type="hidden" id="telNo" name="telNo" class="w100 onlyTelNo" maxlength="30">
                                        </td>
                                        
                                        <th>직종</th>
										<td><span class="info_txt" id="jikjongKind"></span></td>
										
                                        <th>사용여부</th>
                                        <td><span class="info_txt" id="hideYn"></span></td>										
										
                                    </tr>
                                    <tr>
                                        <th>평가정보</th>
                                        <td colspan="5">
                                        	<input type="checkbox" id="scheTargetYn" name="scheTargetYn" disabled="disabled" /><label for="scheTargetYn">스케줄관리</label>
	                                        <input type="checkbox" id="eduTargetYn" name="eduTargetYn" disabled="disabled" /><label for="eduTargetYn">교육평가</label>
	                                        <input type="checkbox" id="qaTargetYn" name="qaTargetYn" disabled="disabled" /><label for="qaTargetYn">통화품질</label>
	                                        <input type="checkbox" id="kpiTargetYn" name="kpiTargetYn" disabled="disabled" /><label for="kpiTargetYn">성과실적</label>
                                        </td>                                   
                                    </tr>
                                </tbody>
                            </table>
                        </div>  
                    </div>
                </div> 
                <div class="btn_areaB txt_r">
                	<button type="button" class="btn_m remove" id="btnPopPwd" name="btnPopPwd">비밀번호 변경</button>
                    <button type="button" class="btn_m confirm" onClick="fnUserEditSave();">저장</button>   
            	</div>              
            </div>            
        </section>
    </div>
</body>
</html>
