/**
 * argo.popLayer.js
 * pop smallWindow
 * Copyright 2017, Noh ki won
 * Released on: 2017.01.05
 */

(function($){
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
})(jQuery);


function Window_views( selector, url, title, width, height, pid, ptype ){		
	this.selector = $(selector);
	this.url = url;
	this.title = title;
	this.width = width;
	this.height = height;
	this.pid = pid;
	this.ptype = ptype ; /* opener type - M (메인) / P (팝업) */
	this.pos_y = this.selector.offset().top + 30;
	this.pos_x = this.selector.offset().left + 10;
	this.gap = 0;
	this.init();
	this.popLayer = $("body").find( "#pop" + id_num );
	this.popBox = this.popLayer.find(".pop_div");
	this.popBg = this.popLayer.find(".pop_bgLayer");
	this.btn_close = this.popLayer.find(".btn_popClose");
	this.addEvent();	

	if( this.pos_x + this.popBox.width() > $(window).width() ){
		this.gap = ( this.pos_x + this.popBox.width() ) - $(window).width() + 22 ;
	}
	this.popBox.css({"top":this.pos_y - $(window).scrollTop(), "left":this.pos_x - this.gap, "opacity":1});
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
		//return false;
	});	
	
	this.popBg.on( "click", function(){
		$("body").removeClass("pop_layer");
		
		$(this).closest(".pop_layer").remove();
		///return false;	
	});
	
}

//타이틀, url, 창 넓이, 창 높이
function argoSmallPopupWindow( _selector,_title, _url, _width, _height){
	
	 // 팝업 오픈 시 호출자가 메인이 아닐 경우 (팝업에서 팝업 호출할 경우) 메인을 기준으로 화면 lock 처리 되어야 하므로 parent 의 openwindow 를 호출해야함.	
	 var isPopup   = false;
	 var sOpenerId = "";
	 
    if(window.frameElement){
		var sLayer = window.frameElement.parentNode.className ;		
	
		if(sLayer=="content_wrap") { // 메인인 경우
			isPopup   = false;		
			sOpenerId = window.frameElement.parentNode.attributes["data-id"].value ;
			
		}else {
			isPopup = true;	
			sOpenerId = $(window.frameElement.parentNode).closest('.pop_layer').attr("id");
		}
	} 
	    
	    var openWindow ;
	    isPopup = false ; // small popup 인 경우 구분 필요없나??
	    
	    if(isPopup) { // 팝업에서 팝업을 호출 할 경우 
	    	parent.gPopupOptions = gPopupOptions ;
		    openWindow = parent.$(_selector).openSmallWindow({
							title:_title,
							url:_url,
							width:_width,
							height:_height,
							pid:sOpenerId,
							ptype:"P"
						});
	    } else {
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
}