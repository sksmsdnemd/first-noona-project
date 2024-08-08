/**
 * argo.countNum.js
 * 숫자 +, -
 * Copyright 2017, Noh ki won
 * Released on: 2017.02.14
 */

(function($){
	$.setOptions = {
		max : 100,
		min : -1000,
		set_num : '0'
	}
	$.fn.countNum = function( options ){
		options = $.extend( null, $.setOptions, options );
		this.each( function(index){
			var count_num = new Count_num(this, options.max, options.min, options.set_num );		

		});		
		return this;
	}	
})(jQuery);


function Count_num( selector, max, min, set_num ){
	this.selector = $(selector)	;
	this.max = max;
	this.min = min;
	this.set_num = set_num;
	this.btn_minus = this.selector.find(".btn_minus");
	this.btn_plus = this.selector.find(".btn_plus");
	this.input_num = this.selector.children(".input_num");	
	
	this.init();
}

Count_num.prototype.init = function(){	
//	if( this.set_num < 10 ){ this.set_num = "0" + this.set_num; }	
	this.input_num.val(this.set_num);
	this.addEvent();
}

Count_num.prototype.addEvent = function(){
	var thisObj = this;
	this.btn_minus.on("click", function(){
		var num = Number(thisObj.input_num.val());
		if( num < ( thisObj.min + 1) ){ return}
		--num;		
//		if( num < 10 ){ num = "0" + num; }
		thisObj.input_num.val(num).trigger("change");
		thisObj.input_num.trigger("change");
		return false;
	});
	this.btn_plus.on("click", function(){
		var num = Number(thisObj.input_num.val());	
		if( num > ( thisObj.max - 1 ) ){ return}
		++num;	
//		if( num < 10 ){ num = "0" + num; }	
		thisObj.input_num.val(num).trigger("change");
		thisObj.input_num.trigger("change");
		return false;
	});	
	this.input_num.on('keypress', function(e) {		
		if (e.which == 13) {	
			thisObj.digit();
		}		
	}).on('blur', function(e){
		thisObj.digit();
	});
}

Count_num.prototype.digit = function(){
	var num = Number(this.input_num.val());			
	if( num > this.max ){ num = this.max}
	if( num < this.min ){ 
		num = this.min
		}
//	if( num < 10 ){ num = "0" + num; }
	if(isNaN(num)) num = "1";
	this.input_num.val(num);			
}

