/**
 * argo.alert.js
 * 오픈창 
 * Copyright 2016, Noh ki won
 * Released on: 2016.12.11
 */

(function($){
	
	var result = false ;
	
	$.setOptions = {
		state : "normal",
		message : "This is a warning message.", 
		extend_message : "This is a warning message.",
		win_size : "big" 
	}
	$.fn.openAlert = function( options ){
		options = $.extend( null, $.setOptions, options );
		this.each( function(index){			
			var alim_view = new Alim_view(this, options.state, options.message, options.extend_message, options.win_size);
			$(this).find(".pop_confirm").on("click", function(e) { // 확인버튼 클릭시
				alim_view.alim_remove();				
				if (options.onConfirm !== undefined) {
					if( typeof options.onConfirm == "function" ){ // 함수이면
						options.onConfirm(e);
					}else {
						eval(options.onConfirm); //실행문장이면
					}
			 	}		
				return false;
			});	
			$(this).find(".pop_cancel").on("click", function(e) { //취소 버튼 클릭시
				alim_view.alim_remove();
				if (options.onCancel !== undefined) {
					if( typeof options.onCancel == "function" ){ // 함수이면
						options.onCancel(e);
					}else {
						eval(options.onCancel); //실행문장이면
					}
				}
				return false;
			});	
		});		
		return this;
	}	
})(jQuery);


function Alim_view(selector, state, message, extend_message, winSize ){	
	this.state = state;		
	this.message = message;	
	this.message2 = extend_message;
	this.winSize = winSize;	
	this.make_pop();
	this.selector = $(selector).find(".pop_alim");		
	this.pop_message = this.selector.find(".pop_message");
	this.pop_message2 = this.selector.find(".pop_message2");
	this.pop_box = null;
	this.pop_box = this.selector.find(".pop_box");
	this.btn_showHide = this.selector.find(".btn_showHide");
	this.pop_h =  this.selector.find(".pop_h");
	this.isOk = false;
	this.init();		
	
	//var objThis = this;
	/*
	$(window).on("orientationchange",function(e){		
		objThis.alim_position(300);				
	});	*/
}

Alim_view.prototype.init = function(){
	$("body").addClass("pop_alert");
	this.selector.addClass(this.state);
	this.pop_message.html(this.message);	
	this.pop_message2.html(this.message2);	
	//this.alim_position(100);	
	thisObj = this;
	this.btn_showHide.on( "click", function(){
		if( $(this).hasClass("on")	 ){
			$(this).removeClass("on")
			thisObj.pop_h.hide();
		}else{
			$(this).addClass("on")
			thisObj.pop_h.show();				
		}
		return false;
	});
	
	setTimeout(function(){
		if($("input[type=text]").length > 0 ){ $("input").blur(); }		
	},100);
}

Alim_view.prototype.make_pop = function(){	
	var html = "";
		if( this.winSize == "small" ){
			html += '<div class="pop_alim small">'	
		}else{
			html += '<div class="pop_alim">'
		}		
        html += 	'<div class="pop_bgLayer"></div>'
        html += 	'<div class="pop_box">'
        html +=             '<div class="pop_t">'
        html +=                 '<div class="pop_message"></div>'
		if( this.state == "extend" ){
		html +=                 '<a href="#" class="btn_showHide">Details</a>'
		}
        html +=             '</div>'
		if( this.state == "extend" ){
		html +=             '<div class="pop_h">'
        html +=                 '<div class="pop_message2"></div>'
        html +=             '</div>'
		}
        html +=             '<div class="pop_b">'
        html +=                    	'<a href="#" class="pop_confirm">OK</a>'
        html +=                     '<a href="#" class="pop_cancel">Cancel</a>'
        html +=             '</div>'
        html +=     '</div>'
        html += '</div>'
		
		$("body").append( html );
		if( this.winSize == "small" ){ return };
		setTimeout(function(){	$(".pop_bgLayer").css("opacity", "0.4");},10);
}

Alim_view.prototype.alim_remove = function(){
	$("body").removeClass("pop_alert");
	this.selector.remove();	
}

Alim_view.prototype.alim_position = function(time){	
	var objThis = this;
	setTimeout(function(){		
		var pop_w = objThis.pop_box.width();
		var win_w = $(window).width();
		var pop_h = objThis.pop_box.height();
		var win_h = $(window).height();
		var pos_x = ( win_w - pop_w ) / 2;
		var pos_y = ( win_h - pop_h ) / 2;
		objThis.pop_box.css({"top":pos_y, "left":pos_x, "opacity":1});			
	}, time);	
}


/** 
 * 경고창 (Alert)
 * @param  {String} dist : 경고창 구분 (warning:위험, error:에러, extend:확장)
 * @param  {String} msg : 알림메세지
 * @param  {String} extend : 확장 알림메세지 (extend일경우)
 * @param  {sConfirm} 확인 후 후처리 필요한 경우 e.g ) 팝업 화면에서 저장 성공 메시지 처리 후 화면 close 하려 할 경우 메시지 없이 화면이 종료됨.
 *  argoAlert('warning', '성공적으로 등록 되었습니다.','', 'argoPopupClose();') ;
 */
function argoAlert(dist, sMessage, sExtMsg, sConfirm){
	
	if(sMessage ==undefined ) {// 메시지만 넘어올 경우 를 위해 e.g) argoAlert("메시지 ") ;
		sMessage = dist ; 
		dist = 'warning';		
	}
	
	$("body").openAlert({
				 state : dist
				 ,message: sMessage
				 ,extend_message : sExtMsg
				 ,onConfirm:sConfirm
	});	
}

/* 경고창 - argoSmallPopupWindow 에서 사용할 alert
 * 
 */
function argoSmallAlert(dist, sMessage, sExtMsg, sConfirm){
	
	if(sMessage ==undefined ) {// 메시지만 넘어올 경우 를 위해 e.g) argoAlert("메시지 ") ;
		sMessage = dist ; 
		dist = 'warning';		
	}
	
	$("body").openAlert({
				 state : dist
				 ,message: sMessage
				 ,extend_message : sExtMsg
				 ,onConfirm:sConfirm
				 ,win_size : "small"
	});	
}


/** 
 * 확인창 (confirm)
 * @param  {String} sMessage : 알림메세지
 * @param  {String or 함수} sConfirm : 확인 버튼 클릭시 실행함수명 또는 실행문(string)
 * @param  {String or 함수} sCancel  취소 버튼 클릭시 실행함수명 또는 실행문(string)
 * e.g)
 * argoConfirm("삭제하시겠습니까?", fnDelete) ;
 * argoConfirm("삭제하시겠습니까?", "argoAlert('확인선택')", "argoAlert('취소선택')") ;
 * 
  */
function argoConfirm(sMessage, sConfirm, sCancel){
	
	$("body").openAlert({
				 state : 'confirm'
				 ,message: sMessage
				 ,onConfirm:sConfirm
				 ,onCancel:sCancel
	});	
}
/* 경고창 - argoSmallPopupWindow 에서 사용할 confirm
 * 
 */
function argoSmallConfirm(sMessage, sConfirm, sCancel){
	
	$("body").openAlert({
				 state : 'confirm'
				 ,message: sMessage
				 ,onConfirm:sConfirm
				 ,onCancel:sCancel
				 ,win_size : "small"
	});	
}

/** 
 * 경고창 (Alert)
 * @param  {String} dist : 경고창 구분 (warning:위험, error:에러, extend:확장)
 * @param  {String} msg : 알림메세지
 * @param  {String} extend : 확장 알림메세지 (extend일경우)
 */
function argoAlert_back(dist, msg, ext_msg){
	try{
		var gbn = dist;
		switch(gbn){
			case 'warning' : { var openAlert = $("body").openAlert({	state : gbn, message : msg }); break;}
			case 'error' : { var openAlert = $("body").openAlert({	state : gbn, message : msg }); break;}
			case 'extend' : { var openAlert = $("body").openAlert({	state : gbn, message : msg, extend_message : ext_msg }); break;}
			default : {
				// MODIFIED BY YAKIM 기존 argoAlert(msg)사용하는 경우를 위해.
				 var openAlert = $("body").openAlert({	state : 'warning', message : dist });
				//alert('구분이 잘못되었습니다');
				}
		}
	}catch(e){
		alert(e);
	}
}

/** 
 * 확인창 (confirm)
 * @param  {String} msg : 알림메세지
 * @param  {String} accept_gbn : 확인시 next 액션구분 (text:warning창 호출 / function:함수호출)
 * @param  {String} cancel_gbn : 취소시 next 액션구분 (text:warning창 호출 / function:함수호출)
 * @param  {String} accept_msg : 확인시  메세지 or 함수명 (accept_gbn가 text일경우 메세지, function일경우 함수명) 
 * @param  {String || Array} accept_param : 확인시 함수 파라메터 (파라메터가복수개일 경우 배열['A', 'B', 'C'] 형식으로 사용, accept_gbn가 text일경우는 NULL)
 * @param  {String} cancel_msg : 취소시  메세지 or 함수명 (accept_gbn가 text일경우 메세지, function일경우 함수명)
 * @param  {String|| Array} cancel_param : 확인시 함수 파라메터 (파라메터가복수개일 경우 배열['A', 'B', 'C'] 형식으로 사용, accept_gbn가 text일경우는 NULL)
 */
function argoConfirm_Back(msg, accept_gbn, cancel_gbn, accept_msg, accept_param, cancel_msg, cancel_param){
	try{
		var openAlert = $("body").openAlert({	
			state : 'confirm', message : msg,
			onConfirm:function(){			
				if(accept_gbn == 'text'){
					var openAlert = $("body").openAlert({	state : 'warning', message : accept_msg });
				}else if(accept_gbn == 'function'){
					eval(accept_msg)(accept_param);
				}else{
					 return;
				}
			},
			onCancel:function(){
				if(cancel_gbn == 'text'){
					var openAlert = $("body").openAlert({	state : 'warning', message : cancel_msg });
				}else if(cancel_gbn == 'function'){
					eval(cancel_msg)(cancel_param);
				}else{
					return;
				}
			}
		});
	}catch(e){
		alert(e);
	}		
}
