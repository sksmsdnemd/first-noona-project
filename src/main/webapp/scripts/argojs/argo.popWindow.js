/**
 * argo.popWindow.js
 * pop window
 * Copyright 2016, Noh ki won
 * Released on: 2016.12.21
 */

(function($){
	$.setOptionsPW = {
		title : "",
		url : "",
		width : "1066",
		height : "689",		
		pid:"",
		ptype:"",
		multi : false
		,closeable : true
	}
	$.fn.openWindow = function( options ){
		options = $.extend( null, $.setOptionsPW, options );
		this.each( function(index){			
			var window_view = new Window_view( this, options.url, options.title, options.width, options.height, options.pid, options.ptype
					, options.multi 
					, options.closeable);	
		});		
		return this;
	}	
})(jQuery);


function Window_view( selector, url, title, width, height, pid, ptype, multi,closeable ){	
	this.selector = $(selector);
	this.url = url;
	this.title = title;
	this.width = width;
	this.height = height;
	this.pid = pid;
	this.ptype = ptype ; /* opener type - M (메인) / P (팝업) */
	this.multi = multi;	
	this.closeable = closeable ;
	this.div_num = 0;
	this.init();	
	this.popLayer = this.selector.find( "#pop" + id_num );
	if( this.multi ){
		this.popBox = this.selector.find(".pop" + div_num );		
	}else{
		this.popBox = this.popLayer.find(".pop_div");		
	}
	
	this.btn_close = this.popBox.find(".btn_popClose");
	this.pop_title = this.popBox.find(".pop_title")
	this.popDrag = this.popBox.find(".pop_drag");	
	this.popBg = this.popBox.closest(".pop_layer").find(".pop_bgLayer");	
	this.popMove = this.popBox.closest(".pop_moveArea");
	
	this.addEvent();
}

Window_view.prototype.init = function(){
	$("body").addClass("pop_layer");	
	if( this.multi ){ this.multi_window()}else{ this.make_window()}
	this.window_position(0);		
}

var id_num = 0;
var div_num = 0;
Window_view.prototype.make_window = function(){

	id_num = $("div.pop_layer").length;
	var html = "";
	html += '<div class="pop_layer" data-pid="'+ this.pid +'" id="pop'+ id_num +'">'
    html += 	'<div class="pop_bgLayer"></div>'
	html += 	'<div class="pop_moveArea">'
    html +=     '<div class="pop_div pop' + id_num +'" style="width:' + this.width + 'px; height:' + this.height + 'px;">'
   // html +=         '<div class="pop_title"><div class="pop_drag">' + this.title + '</div><a href="#" class="btn_popClose">닫기</a></div>'
    html +=         '<div class="pop_title"><div class="pop_drag">' + this.title + '</div>'
    html += (this.closeable == false ? "" : '<a href="#" class="btn_popClose">닫기</a>') 
    html +=         '</div>'
    html +=         '<div class="pop_content">'
    html +=         	'<iframe src="' + this.url + '" name="pop'+ id_num +'" data-pid="'+ this.pid +'" data-ptype="'+ this.ptype +'" ></iframe>'
    html +=         '</div></div></div></div>'
	$("body").append( html );
	setTimeout(function(){ 	$(".pop_bgLayer").css("opacity", "0.3");},10);
}

Window_view.prototype.multi_window = function(){
	div_num++;	
	var html = "";
    html +=     '<div class="pop_div pop' + div_num +'" style="width:' + this.width + 'px; height:' + this.height + 'px; z-index:'+ win_depth +'">'
    html +=         '<div class="pop_title"><div class="pop_drag">' + this.title + '</div><a href="#" class="btn_popClose">닫기</a></div>'
    html +=         '<div class="pop_content">'
    html +=         	'<iframe src="' + this.url + '" name="pop'+ id_num +'" data-pid="'+ this.pid +'" data-ptype="'+ this.ptype +'" ></iframe>'
    html +=         '</div></div>'
	this.div_num = div_num;
	$(".pop_moveArea").append( html );
}

var win_depth = 100;
Window_view.prototype.addEvent = function(){
	var thisObj = this;
	this.btn_close.on( "click", function(){
		var div_length = $("div.pop_div").length;
		var layer_length = $("div.pop_layer").length;
		if( div_length > 1 && layer_length < 2 ){
			thisObj.popBox.remove();
		}else{			
			thisObj.removePop(this, layer_length);	
			div_num = 0;	
		}		
	//	return false;
	});
	
	this.pop_title.on( "mousedown", function(){		
		$(this).closest(".pop_div ").css({"z-index":win_depth++});		
	});
	
	/*this.popBg.on( "click", function(){
		thisObj.removePop(this);
		return false;
	});*/

	$(window).on("resize", function(){
		thisObj.window_position(0);	
	});
	
	if(this.closeable) {
	this.popBox.draggable({ 
		handle: this.popDrag, 
		cursor: "move",
		containment: this.popMove, 
		scroll: false 
	});
	}
}

Window_view.prototype.window_position = function(time){	
	var objThis = this;
	setTimeout(function(){		
		var pop_w = objThis.width;
		var pop_h = objThis.height;
		//var win_w = $(window).width();
		var win_w = objThis.popMove.width();		
		var win_h = $(window).height();
		var pos_x = ( win_w - pop_w ) / 2;
		var pos_y = ( win_h - pop_h ) / 2;
		objThis.popBox.css({"top":pos_y + objThis.div_num*20, "left":pos_x - objThis.div_num*20, "opacity":1});
	}, time);	
}

Window_view.prototype.removePop = function(_this, _length){
	var layer_length = _length;
	if( layer_length < 2 ){
		$("body").removeClass("pop_layer");
	}	
	$(_this).closest(".pop_layer").remove();	
}


//타이틀, url, 창 넓이, 창 높이
//function argoPopupWindow( _title, _url, _width, _height,_multi, target = null){
function argoPopupWindow( _title, _url, _width, _height,_multi, target){
	
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
	    
	    if(isPopup) { // 팝업에서 팝업을 호출 할 경우 
	    	parent.gPopupOptions = gPopupOptions ;
	    	
		    openWindow = parent.$("body").openWindow({
							title:_title,
							url:_url,
							width:_width,
							height:_height,
							pid:sOpenerId,
							ptype:"P",
							multi:_multi
						});
	    } else {
	    	gPopupOptions = gPopupOptions ;
	    	 openWindow = $("body").openWindow({
		    			title:_title,
		    			url:_url,
		    			width:_width,
		    			height:_height,
		    			pid:sOpenerId,
		    			ptype:"M",
		    			multi:_multi
		    		});
	    }
}

//팝업 닫기
function argoPopupClose(){
	$(window.frameElement.parentNode).closest('.pop_layer').remove();
}


