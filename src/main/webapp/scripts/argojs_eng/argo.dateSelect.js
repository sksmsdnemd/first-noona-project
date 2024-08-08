/**
 * argo.dateSelect.js
 * datePicker 년/월 
 * Copyright 2016, Noh ki won
 * Released on: 2016.12.29
 */

(function($){
	$.setOptionsDs = {
		next_mState:true
	}	
	$.fn.dateSelect = function( options ){
		options = $.extend( null, $.setOptionsDs, options );
		this.each( function(index){			
			var date_select = new Date_select(this, options.next_mState);	
			$( this ).data( "date_select", date_select );		
			
			$(this).find(".date_list li a").on("click", function(e){
				if( !$(this).hasClass("use")){			
					return false
				}
				date_select.selectMonth(this);
				if (options.onChange !== undefined) {
					if( typeof options.onChange == "function" ){ // 함수이면
						options.onChange(e);
					}else {
						eval(options.onChange); //실행문장이면
					}
				}
				return false;
			});	
			
			$(this).find(".input_ym").on("keypress", function(e){
				if (options.onKeyPress !== undefined) {
					if( typeof options.onKeyPress == "function" ){ // 함수이면
						options.onKeyPress(e);
					}else {
						eval(options.onKeyPress); //실행문장이면
					}
				}				
			});	
			
			$(this).find(".input_ym").on("keyup", function(e){
				if (options.onKeyUp !== undefined) {
					if( typeof options.onKeyUp == "function" ){ // 함수이면
						options.onKeyUp(e);
					}else {
						eval(options.onKeyUp); //실행문장이면
					}
				}				
			});	
			
		});		
		return this;
	}	
	$.fn.getSelectDate = function( options ){
		var date_select = $( this ).data( "date_select" );
		var tmp_value = date_select.input.val();        
        var delim_value = "-";        
        var idx = 0;        
        while (tmp_value.indexOf(delim_value) != -1 ) {        
            idx = tmp_value.indexOf(delim_value);        
            tmp_value = tmp_value.substring(0, idx) + tmp_value.substring(idx + 1, tmp_value.length );        
        }
		return tmp_value;
	}
	
})(jQuery);


function Date_select( selector, next_mState){
	this.selector = $(selector);
	this.next_mState = next_mState;
	this.input = this.selector.children(".input_ym");
	this.nowYear = this.currentYear = this.currentDate().nowYear;
	this.nowMonth = this.currntMonth = this.currentDate().nowMonth;
	this.gap =  { x:0, y:26};
	this.date_layer = "";
	this.btn_calendar = "";
	this.select_year = "";
	this.btn_prev = "";
	this.btn_next = "";
	this.month_list = "";
	this.btn_month = "";

	this.init();

}

Date_select.prototype.init = function(){
	this.make_date();	
	if(!this.input.prop("disabled")){
		this.addEvent();
	}	
}

Date_select.prototype.make_date = function(){
	//var num = $(".date_layer").length;
	//if( num < 1 ){
		var html = "";	
		html += '<div class="date_layer">'
		html += '	<div class="date_t">'
		html += '    	<a href="#" class="btn_prev">prev</a><span class="select_year"></span><a href="#" class="btn_next">next</a>'
		html += '    </div>'
		html += '    <div class="date_b">'
		html += '    	<ul class="date_list">'
		html += '         	<li><a href="#" class="use">January</a></li>'
		html += '            <li><a href="#" class="use">Febuary</a></li>'
		html += '            <li><a href="#" class="use">March</a></li>'
		html += '            <li><a href="#" class="use">April</a></li>'
		html += '            <li><a href="#" class="use">May</a></li>'
		html += '            <li><a href="#" class="use">June</a></li>'
		html += '            <li><a href="#" class="use">July</a></li>'
		html += '            <li><a href="#" class="use">August</a></li>'
		html += '            <li><a href="#" class="use">September</a></li>'
		html += '            <li><a href="#" class="use">October</a></li>'
		html += '            <li><a href="#" class="use">November</a></li>'
		html += '            <li><a href="#" class="use">December</a></li> </ul></div></div>'
		this.selector.append( html );
	//}
	
	this.date_layer = this.selector.find(".date_layer");
	this.select_year = this.date_layer.find(".select_year");
	this.btn_prev = this.date_layer.find(".btn_prev");
	this.btn_next = this.date_layer.find(".btn_next");		
	this.month_list = this.date_layer.find(".date_list li");
	this.btn_month = this.date_layer.find(".date_list li a");
	
	this.btn_calendar = this.selector.find(".btn_calendar");	
	this.input.attr("maxlength", 7);
}	

Date_select.prototype.chk_useNext = function(_nowYear){
	var thisObj = this;
	if( this.currentYear > _nowYear ){
		this.btn_month.addClass("use");
		this.btn_prev.show();
		this.btn_next.show();
	}else if( this.currentYear == _nowYear ){
		this.month_list.each(function(i){
			if( i > thisObj.currntMonth-1 ){
				$(this).find("a").removeClass("use");
			}else{
				$(this).find("a").addClass("use");			
			}
		});		
		this.btn_prev.show();
		this.btn_next.hide();
	}else{
		this.btn_month.removeClass("use");
	}
}

Date_select.prototype.selectMonth = function(_this){
	this.month_list.find("a").removeClass("on");	
	this.nowMonth = $(_this).parent().index() + 1;
	if(this.nowMonth < 10 ){this.nowMonth = "0" + this.nowMonth; }
	this.input.val(this.nowYear + "-" + this.nowMonth);
	this.btn_calendar.removeClass("on");			
	this.date_layer.fadeOut(200);	
}


Date_select.prototype.addEvent = function(){
	var thisObj = this;
	this.btn_calendar.on("click", function(){
		
		if( !thisObj.input.prop("disabled") ){
			if($(this).hasClass("on")){
				thisObj.date_layer.fadeOut(200);
				$(this).removeClass("on");						
			}else{
				$(".btn_calendar").removeClass("on");
				$(".date_layer").fadeOut(200);
				thisObj.date_layer.css({"left":thisObj.gap.x, "top":thisObj.gap.y});			
				thisObj.date_layer.fadeIn(300);
				thisObj.input.focus();
				
				thisObj.currentYear = thisObj.currentDate().nowYear;
				thisObj.currentMonth = thisObj.currentDate().nowMonth;
				
				if( thisObj.input.val() == "" ){
					thisObj.select_year.text(thisObj.nowYear + "년");
					thisObj.month_list.eq(thisObj.nowMonth-1).find("a").addClass("active");
				}else{
					var input_txt = thisObj.input.val();
					
					thisObj.nowYear = Number(input_txt.substr(0,4));
					// IE 에서는 2017-06으로 값을 가져 오는데 크롬에서는 201706으로 값을 가져옴....
					var input_month = input_txt.length==6?Number(input_txt.substr(4,2)):Number(input_txt.substr(5,2));
					thisObj.select_year.text( thisObj.nowYear + "년");	
					thisObj.month_list.eq(input_month-1).find("a").addClass("on");	
				}
				
				$(this).addClass("on");	
				
				if(!thisObj.next_mState){
					thisObj.chk_useNext(thisObj.nowYear);
				}		
			}
		}
		return false;
	});
	
	this.btn_prev.on("click", function(){
		thisObj.input.focus();
		thisObj.month_list.find("a").removeClass("on");	
		thisObj.select_year.text((--thisObj.nowYear) + "년");	
		thisObj.checkYear(thisObj.nowYear);
		if(!thisObj.next_mState){
			thisObj.chk_useNext(thisObj.nowYear);
		}	
		return false;
	});
	
	this.btn_next.on("click", function(){
		thisObj.input.focus();
		thisObj.month_list.find("a").removeClass("on");	
		thisObj.select_year.text((++thisObj.nowYear) + "년");
		thisObj.checkYear(thisObj.nowYear);
		if(!thisObj.next_mState){
			thisObj.chk_useNext(thisObj.nowYear);
		}	
		return false;
	});
	
	
	
	$(document).on("click", function(event) {
		if ( !$(event.target).is(".date_layer") && !$(event.target).is(".yearMonth_date") && !$(event.target).is(".date_t")  && !$(event.target).is(".date_b")  && !$(event.target).is(".date_list li") ) {
			thisObj.btn_calendar.removeClass("on");	
			thisObj.date_layer.fadeOut(10);	
		}
	});
	
}

Date_select.prototype.currentDate = function(){
	var nowDate = new Date();
	var nowYear = nowDate.getFullYear();
	var nowMonth = nowDate.getMonth() + 1;
	if(nowMonth < 10 ){nowMonth = "0" + nowMonth; }
	var todayDate = {"nowYear" : nowYear,"nowMonth": nowMonth}
	return todayDate;
}

Date_select.prototype.checkYear = function(_nowYear){
	if( this.currentYear == _nowYear ){
		this.month_list.eq(this.currntMonth-1).find("a").addClass("active");
	}else{
		this.btn_month.removeClass("active");
	}

	if( this.input.val().substr(0,4) == _nowYear ){
		var select_month = this.input.val().substr(5,2);
		this.month_list.eq(select_month-1).find("a").addClass("on");	
	}else{
		this.btn_month.removeClass("on");
	}
}

