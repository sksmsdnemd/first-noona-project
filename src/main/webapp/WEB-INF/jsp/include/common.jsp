<!-- 
/****************************************************************
 * 파일명: common.jsp
 * 설명   : ARGO 메인 화면 공통 파일 include 
 *
 * 수정일		       수정자       Version		
 * 
 * 2016.12.14	     	1.0			최초생성
 *
 */
  -->
<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
%>
<meta http-equiv="X-UA-Compatible" content="ie=EDGE" />
<link rel="stylesheet" 	href="<c:url value="/css/jquery-argo.ui.css?ver=2024011001"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.common.css?ver=2024011001"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.contants.css?ver=2024011001"/>"	type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/w2ui-1.5.rc1.css?ver=2024011001"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/w2ui-1.5.rc1.min.css?ver=2024011001"/>"	type="text/css" />

<link rel="shortcut icon" href="<c:url value="/images/icons/favicon.ico"/>"/>
<script type="text/javascript"	src="<c:url value="/scripts/realgrid1.1.23/jszip.min.js"/>"></script>

<script type="text/javascript"	src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript"	src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript"	src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2024011001"/>"></script>



<!-- 사용하는 곳이 없는것 같음. 동일한 URL을 한번 더 호출하는 현상이 있어서 주석처리함. 2020.05.15 정윤석 -->
<%-- <script type="text/javascript"	src="<c:url value="/scripts/jquery/jquery.ajax-cross-origin.min.js"/>"></script> --%>


<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.basic.js?ver=2024011001"/>"></script>
<!-- 2018 VLEOCE START -->
<script type="text/javascript"	src="<c:url value="/scripts/velocejs/veloce.basic.js?ver=2024011001"/>"></script>
<!-- 2018 VLEOCE END -->
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.core.js?ver=2024011001"/>"></script>
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.common.js?ver=2024011003"/>"></script>
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.util.js?ver=2024011001"/>"></script>

<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.alert.js?ver=2024011001"/>"></script>
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.popWindow.js?ver=2024011001"/>"></script>
<script type="text/javascript"  src="<c:url value="/scripts/argojs/argo.popSmallWindow.js"/>"></script>

<!-- JSTREE -->
<link rel="stylesheet"	href="<c:url value="/scripts/jstree3.3.3/dist/themes/default/style.min.css?ver=2024011001"/>" />
<script type="text/javascript"	src="<c:url value="/scripts/jstree3.3.3/dist/jstree.min.js"/>"></script>

<!-- 년-월 캘린더 -->
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.dateSelect.js"/>"></script>
<!--시:분:초 셀렉터 -->
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<!--카운트 셀렉터 -->
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>

<!-- select box -->
<link rel="stylesheet"	href="<c:url value="/css/select2.min.css"/>"	type="text/css" />
<script type="text/javascript"	src="<c:url value="/scripts/jquery/select2.min.js"/>"></script>

<!--EXCEL -->
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.excel.js"/>"></script>
<script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.excel.shim.js"/>"></script>
<%-- <script type="text/javascript"	src="<c:url value="/scripts/argojs/argo.excel.xlsx.js"/>"></script> --%>
<!--PREVIEW -->
<script type="text/javascript"  src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/printThis-master/printThis.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>

<!-- W2UI -->
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>




<script>

	$(function(){

		// 평가자, 평가표, 평가계획 조회조건이 공백일 시 검색값 초기화
		$("#s_QaaNm").focusout(function(){
			if($("#s_QaaNm").val().trim()=='' && typeof($("#s_QaaId").val()) != "undefined"  )  $("#s_QaaId").val('') ;
		});	
		$("#s_TimesNm").focusout(function(){
			if($("#s_TimesNm").val().trim()=='' && typeof($("#s_TimesId").val()) != "undefined"  )  $("#s_TimesId").val('') ;
		});	
		$("#s_SheetNm").focusout(function(){
			if($("#s_SheetNm").val().trim()=='' && typeof($("#s_SheetId").val()) != "undefined" )  $("#s_SheetId").val('') ;
		});	
		
	    //------------------------------------------------------
		//IE에서 팝업 레이터 input 포커스 후 창닫은 뒤 호출 화면의 input keyin 안되는 문제 로
		//------------------------------------------------------			
		$('input[type=text]').bind('mousedown.ui-disableSelection selectstart.ui-disableSelection', function(event) {
			event.stopImmediatePropagation();
			 $(this).focus();
		}) ;
		
		
	    //------------------------------------------------------
		// SELECT BOX 
		//------------------------------------------------------		
		
		// onlyNum class 설정 시  숫자만 
		$(".onlyNum").keyup(function(){$(this).val( $(this).val().replace(/[^0-9]/gi,"") );} );  // 숫자만
		$(".onlyTelNo").keyup(function(){$(this).val( $(this).val().replace(/[^0-9\-]/gi,"") );} ); //숫자와 -만
		$(".onlyDate").attr("maxLength",10);
 		$(".onlyDate").keyup(function(event){
 			if (!(event.keyCode >=37 && event.keyCode<=40)) {
 				$(this).val( $(this).val().replace(/[^0-9\-]/gi,"") );
 			}
 			
 		} ); // 숫자와 - 만
		
		$(".onlyTime").keyup(function(){$(this).val( $(this).val().replace(/[^0-9\:]/gi,"") );} ); // 숫자와 : 만
		
		//  개인정보 (전화번호) 표시 타입 적용  
		$(".onlyTelNo").focusin(function(){
			if($(this).is('[data-link]')){
				var sObj = $(this).attr("data-link") ;			
				this.value = $("#"+sObj).val() ;
			}
		});
		
		$(".onlyTelNo").focusout(function(){
			if($(this).is('[data-link]')){
				var sObj = $(this).attr("data-link") ;	
				
				var sTelNo  = this.value ;
				if(sTelNo.indexOf("*") < 0) {
					sTelNo = sTelNo.replace(/\-/g,"");
					$("#"+sObj).val(sTelNo) ;
					this.value = argoFormatterTelNo(sTelNo) ;
				}
			}
		});
		
		$(".onlyDate").focus(function(){
			var sVal = this.value;
			//sVal =sVal.replace(/\-/g,"");
			this.value = sVal ;
		});

		// 날짜 입력란 유효성 체크 및 yyyy-mm-dd 포맷 설정 처리
		$(".onlyDate").focusout(function(){
				var sVal  = this.value ;
				sVal = sVal.replace(/\-/g,"");
 				if(sVal.length>8) sVal = sVal.substring(0,8);
				if(argoYmdFormCheck(sVal)) {
					if(sVal.length==6) sVal = sVal.replace(/(\d{4})(\d{2})/, '$1-$2');	
					else sVal = sVal.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
				}else {
					var toDay = argoCurrentDateToStr();
					sVal = toDay.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');
				}
				this.value = sVal ;
			});
		
		// 시간 입력란 유효성 체크 및 00:00  포맷 설정 처리
		$(".onlyTime").focusout(function(){							
				var sVal  = this.value ;
				sVal = sVal.replace(/\:/g,"");
				if(argoTimeFormCheck(sVal)) {
					if(sVal.length==4)	sVal = sVal.replace(/(\d{2})(\d{2})/, '$1:$2');	
					else sVal = sVal.replace(/(\d{2})(\d{2})(\d{2})/, '$1:$2:$3');
				}else {
					sVal = "";
				}
				this.value = sVal ;
			});	
		
		$(".input_time").attr("readonly",true);
		
		$(document).on("contextmenu",function(e){
			return false;
		})
	});
	
	var Base64 = {

			// private property
			_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",

			// public method for encoding
			encode : function (input) {
			    var output = "";
			    var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
			    var i = 0;

			    input = Base64._utf8_encode(input);

			    while (i < input.length) {

			        chr1 = input.charCodeAt(i++);
			        chr2 = input.charCodeAt(i++);
			        chr3 = input.charCodeAt(i++);

			        enc1 = chr1 >> 2;
			        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			        enc4 = chr3 & 63;

			        if (isNaN(chr2)) {
			            enc3 = enc4 = 64;
			        } else if (isNaN(chr3)) {
			            enc4 = 64;
			        }

			        output = output +
			        this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) +
			        this._keyStr.charAt(enc3) + this._keyStr.charAt(enc4);

			    }

			    return output;
			},

			// public method for decoding
			decode : function (input) {
			    var output = "";
			    var chr1, chr2, chr3;
			    var enc1, enc2, enc3, enc4;
			    var i = 0;

			    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

			    while (i < input.length) {

			        enc1 = this._keyStr.indexOf(input.charAt(i++));
			        enc2 = this._keyStr.indexOf(input.charAt(i++));
			        enc3 = this._keyStr.indexOf(input.charAt(i++));
			        enc4 = this._keyStr.indexOf(input.charAt(i++));

			        chr1 = (enc1 << 2) | (enc2 >> 4);
			        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			        chr3 = ((enc3 & 3) << 6) | enc4;

			        output = output + String.fromCharCode(chr1);

			        if (enc3 != 64) {
			            output = output + String.fromCharCode(chr2);
			        }
			        if (enc4 != 64) {
			            output = output + String.fromCharCode(chr3);
			        }

			    }

			    output = Base64._utf8_decode(output);

			    return output;

			},

			// private method for UTF-8 encoding
			_utf8_encode : function (string) {
			    string = string.replace(/\r\n/g,"\n");
			    var utftext = "";

			    for (var n = 0; n < string.length; n++) {

			        var c = string.charCodeAt(n);

			        if (c < 128) {
			            utftext += String.fromCharCode(c);
			        }
			        else if((c > 127) && (c < 2048)) {
			            utftext += String.fromCharCode((c >> 6) | 192);
			            utftext += String.fromCharCode((c & 63) | 128);
			        }
			        else {
			            utftext += String.fromCharCode((c >> 12) | 224);
			            utftext += String.fromCharCode(((c >> 6) & 63) | 128);
			            utftext += String.fromCharCode((c & 63) | 128);
			        }

			    }

			    return utftext;
			},

			// private method for UTF-8 decoding
			_utf8_decode : function (utftext) {
			    var string = "";
			    var i = 0;
			    var c = c1 = c2 = 0;

			    while ( i < utftext.length ) {

			        c = utftext.charCodeAt(i);

			        if (c < 128) {
			            string += String.fromCharCode(c);
			            i++;
			        }
			        else if((c > 191) && (c < 224)) {
			            c2 = utftext.charCodeAt(i+1);
			            string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
			            i += 2;
			        }
			        else {
			            c2 = utftext.charCodeAt(i+1);
			            c3 = utftext.charCodeAt(i+2);
			            string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
			            i += 3;
			        }

			    }

			    return string;
			}

		}
	
	
	
	$(document).keydown(function(e){
		if(e.target.nodeName != "INPUT" && e.target.nodeName != "TEXTAREA"){
			if(e.keyCode === 8){
				return false;
			}
		}
	});
	window.history.forward(0);

	
	//History 탭메뉴
	function historyTab(_this){
		var selector = $(_this);
		$(".history_tab li a[id='" + currentID + "']").removeClass("on");
		$(".content_wrap[data-id='" + currentID + "']").hide();	
		selector.addClass( "on" );
		currentID = selector.attr("id");	
		if( currentID == "DASHBOARD" ){
			$(".section").addClass("dashboard");			
		}else{
			$(".section").removeClass("dashboard");	
		}
		$(".content_wrap[data-id='" + currentID + "']").show();	
		
		//index 왼쪽 하단 페이지 정보
		$(".bottom .now_page").text(currentID);
	}
	
</script>