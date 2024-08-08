/**
 * argo.timeSelect.js
 * timeSelect 년/월 
 * Copyright 2016, Noh ki won
 * Released on: 2017.02.23
 */

(function($){
	$.setOptionsTs = {
		use_sec:false
	}	
	$.fn.timeSelect = function( options ){
		options = $.extend( null, $.setOptionsTs, options );
		this.each( function(index){			
			var time_select = new Time_select(this, options.use_sec);	
				
		});		
		return this;
	}	

	
})(jQuery);


function Time_select( selector, use_sec){
	this.selector = $(selector);
	this.use_sec = use_sec;
	this.input_time = this.selector.find(".input_time"); 
	this.timepicker_wrap = "";
	this.btn_time = "";
	this.btn_hourUp = "";
	this.btn_hourDown = "";
	this.input_hour = "";
	this.btn_minUp = "";
	this.btn_minDown = "";
	this.input_min = "";
	this.btn_secUp = "";
	this.btn_secDown = "";
	this.input_sec = "";
	this.gap =  { x:0, y:26};

	this.init();

}

Time_select.prototype.init = function(){
	if(this.use_sec){
		this.selector.addClass("sec")
		this.input_time.attr("maxlength", 8);
	}else{
		this.input_time.attr("maxlength", 5);
	}
	
	this.make_date();	
	if(!this.input_time.prop("disabled")){
		this.addEvent();
	}
	
}

Time_select.prototype.make_date = function(){
	var html = "";	
	html += '<div class="timepicker_wrap time_popView">'
	html += 	'<div class="time time_popView">'
	html += 		'<div class="prev time_count action-next time_popView"></div>'
	html += 		'<div class="ti_tx time_popView">'
	html += 			'<input type="text" class="timepicki-input time_popView" maxlength="2">'
	html += 		'</div>'
	html += 		'<div class="next action-prev time_popView"></div>'
	html += 	 '</div>'
	html += 	 '<span class="time_divide time_popView">:</span>'
	html += 	 '<div class="mins time_popView">'
	html += 		'<div class="prev action-next time_popView"></div>'
	html += 		'<div class="mi_tx"><input type="text" class="timepicki-input time_popView" maxlength="2"></div>'
	html += 		'<div class="next action-prev time_popView"></div>'
	html += 	 '</div>'
	if( this.use_sec ){
		html += 	 '<span class="time_divide time_popView">:</span>'
		html += 	 '<div class="sec time_popView">'
		html += 		'<div class="prev action-next time_popView"></div>'
		html += 		'<div class="mi_tx"><input type="text" class="timepicki-input time_popView" maxlength="2"></div>'
		html += 		'<div class="next action-prev time_popView"></div>'
		html += 	 '</div>'
	}
	html +=  '</div>'
	
	this.selector.append( html );
	
	this.timepicker_wrap = this.selector.find(".timepicker_wrap");
	this.btn_time = this.selector.find(".btn_time");
	this.btn_hourUp = this.timepicker_wrap.find(".time .prev");
	this.btn_hourDown = this.timepicker_wrap.find(".time .next");
	this.input_hour = this.timepicker_wrap.find(".time .timepicki-input");
	this.btn_minUp = this.timepicker_wrap.find(".mins .prev");
	this.btn_minDown = this.timepicker_wrap.find(".mins .next");
	this.input_min = this.timepicker_wrap.find(".mins .timepicki-input");
	
	if( this.use_sec ){
		this.btn_secUp = this.timepicker_wrap.find(".sec .prev");
		this.btn_secDown = this.timepicker_wrap.find(".sec .next");
		this.input_sec = this.timepicker_wrap.find(".sec .timepicki-input");
	}
	
	var placeholder = "";
	( this.use_sec ? placeholder="00:00:00" : placeholder="00:00" );
	this.input_time.attr("placeholder", placeholder);
	
}

Time_select.prototype.addEvent = function(){
	
	var thisObj = this;
	this.btn_time.on("click", function(){	
		if(!thisObj.input_time.prop("disabled")){
			if($(this).hasClass("on")){
				thisObj.timepicker_wrap.fadeOut(200);
				$(this).removeClass("on");						
			}else{
				$(".btn_time").removeClass("on");
				$(".timepicker_wrap").fadeOut(200);
				thisObj.timepicker_wrap.css({"left":thisObj.gap.x, "top":thisObj.gap.y});			
				thisObj.timepicker_wrap.fadeIn(300);
				thisObj.input_time.focus();
				var timeVal = thisObj.input_time.val();
				if( timeVal == "" ){
					thisObj.nowHour = thisObj.currentTime().nowHour;
					thisObj.nowMin = thisObj.currentTime().nowMin;
					thisObj.nowSec = thisObj.currentTime().nowSec;			
				}else{
					var timeD = timeVal.split(":");
					thisObj.nowHour = Number(timeD[0]);
					thisObj.nowMin = Number(timeD[1]);
					thisObj.nowSec = Number(timeD[2]);						
				}						
				thisObj.input_hour.val( thisObj.digit(thisObj.nowHour));
				thisObj.input_min.val( thisObj.digit(thisObj.nowMin));
				if( thisObj.use_sec ){
					thisObj.input_sec.val(thisObj.digit(thisObj.nowSec));		
				}		
				
				$(this).addClass("on");				
	
			}
		}
		return false;
	});
	
	this.btn_hourUp.on("click", function(){
		thisObj.input_time.focus();
		++thisObj.nowHour;
		if( thisObj.nowHour > 23 ){ thisObj.nowHour = 0; }
		thisObj.input_hour.val( thisObj.digit( thisObj.nowHour ) );
		thisObj.outputTime();
		return false;
	});
	
	this.btn_hourDown.on("click", function(){
		thisObj.input_time.focus();
		--thisObj.nowHour;
		if( thisObj.nowHour < 0 ){ thisObj.nowHour = 23; }
		thisObj.input_hour.val( thisObj.digit( thisObj.nowHour ) );
		thisObj.outputTime();
		return false;
	});
	
	this.btn_minUp.on("click", function(){
		thisObj.input_time.focus();
		++thisObj.nowMin;
		if( thisObj.nowMin > 59 ){ thisObj.nowMin = 0; }
		thisObj.input_min.val( thisObj.digit( thisObj.nowMin ) );
		thisObj.outputTime();
		return false;
	});
	
	this.btn_minDown.on("click", function(){
		thisObj.input_time.focus();
		--thisObj.nowMin;
		if( thisObj.nowMin < 0 ){ thisObj.nowMin = 59; }
		thisObj.input_min.val( thisObj.digit( thisObj.nowMin ) );
		thisObj.outputTime();
		return false;
	});
		
	if( this.use_sec ){
		this.btn_secUp.on("click", function(){
			thisObj.input_time.focus();
			++thisObj.nowSec;
			if( thisObj.nowSec > 59 ){ thisObj.nowSec = 0; }
			thisObj.input_sec.val( thisObj.digit( thisObj.nowSec ) );
			thisObj.outputTime();
			return false;
		});
		
		this.btn_secDown.on("click", function(){
			thisObj.input_time.focus();
			--thisObj.nowSec;
			if( thisObj.nowSec < 0 ){ thisObj.nowSec = 59; }
			thisObj.input_sec.val( thisObj.digit( thisObj.nowSec ) );
			thisObj.outputTime();
			return false;
		});
	}	
	
	this.input_time.on("blur", function(){
		var time_val = $(this).val().trim();		
		if( time_val != "" ){
			time_val = time_val.split(":");
			var inputHour = Number(time_val.toString().substring(0,2));
			var inputMin  = Number(time_val.toString().substring(2,4));
			var inputSec  = Number(time_val.toString().substring(4,6));
			if(thisObj.use_sec){
				if( time_val.length == 3 ){
					if( Number(time_val[0]) > 24 ){
						thisObj.nowHour = 24;
					}else{
						thisObj.nowHour = time_val[0];
					}
					if( Number(time_val[1]) > 59 ){
						thisObj.nowMin = 0;		
					}else{
						thisObj.nowMin = time_val[1];	
					}
					if( Number(time_val[2]) > 59 ){
						thisObj.nowSec = 0;						
					}else{
						thisObj.nowSec = time_val[2];	
					}
					thisObj.outputTime();
				}else{
					if(inputHour > 23){
						argoAlert("시간은 00부터 23까지의<br>숫자를 입력해야 합니다.");
						thisObj.outputTime2();
					}
					else if(inputMin > 59){
						argoAlert("분은 00부터 59까지의<br>숫자를 입력해야 합니다.");
						thisObj.outputTime2();
					}
					else if(inputSec > 59){
						argoAlert("초는 00부터 59까지의<br>숫자를 입력해야 합니다.");
						thisObj.outputTime2();
					} else {
						thisObj.nowHour = inputHour;
						thisObj.nowMin  = inputMin;
						thisObj.nowSec  = inputSec;
						thisObj.outputTime();
					}
				}	
							
			}else{
				if( time_val.length == 2 ){
					if( Number(time_val[0]) > 24 ){
						thisObj.nowHour = 24;
					}else{
						thisObj.nowHour = time_val[0];
					}
					if( Number(time_val[1]) > 59 ){
						thisObj.nowMin = 0;		
					}else{
						thisObj.nowMin = time_val[1];	
					}
					thisObj.outputTime();
				}else{
					if(inputHour > 23){
						argoAlert("시간은 00부터 23까지의 숫자를 입력해야 합니다.");
						thisObj.outputTime2();
					}
					else if(inputMin > 59){
						argoAlert("분은 00부터 59까지의 숫자를 입력해야 합니다.");
						thisObj.outputTime2();
					} else {
						thisObj.nowHour = inputHour;
						thisObj.nowMin  = inputMin;
						thisObj.outputTime();
					}
				}
			}
		}
	})
	
	// ADD Jin
	this.input_hour.on("keydown", function(event){
		thisObj.onlyNumberInput(event);
	}).on("keyup", function(){
		thisObj.removeChar(event);
		if(thisObj.input_hour.val()>23){
			thisObj.input_hour.val("23");
		}
		thisObj.nowHour = thisObj.input_hour.val();
		thisObj.outputTime();
	});
	
	this.input_min.on("keydown", function(event){
		thisObj.onlyNumberInput(event);
	}).on("keyup", function(){
		thisObj.removeChar(event);
		if(thisObj.input_min.val()>59){
			thisObj.input_min.val("59");
		}
		thisObj.nowMin = thisObj.input_min.val();
		thisObj.outputTime();
	});
	
	if(this.use_sec){
		this.input_sec.on("keydown", function(event){
			thisObj.onlyNumberInput(event);
		}).on("keyup", function(){
			thisObj.removeChar(event);
			if(thisObj.input_sec.val()>59){
				thisObj.input_sec.val("59");
			}
			thisObj.nowSec = thisObj.input_sec.val();
			thisObj.outputTime();
		});
	}
	// ---------ADD JIN
	
	
	this.input_hour.on("keydown", function(event){
		thisObj.onlyNumberInput(event);
	}).on("keyup", function(){
		thisObj.removeChar(event);
		thisObj.nowHour = thisObj.input_hour.val();
		thisObj.outputTime();
	});
	
	this.input_time.on("keydown", function(event){
		thisObj.onlyNumberInput(event);
	}).on("keyup", function(){
		thisObj.removeChar(event);
	});
	
	
	
	$(document).on("click", function(event) {
		if ( !$(event.target).is(".time_popView")  ) {
			thisObj.btn_time.removeClass("on");	
			thisObj.timepicker_wrap.fadeOut(10);	
		}
	});
	
	
}

Time_select.prototype.outputTime = function(){
	var out_time = "";
	( this.use_sec ? out_time=this.digit(Number(this.nowHour)) + ":" + this.digit(Number(this.nowMin)) + ":" + this.digit(Number(this.nowSec)) : out_time=this.digit(Number(this.nowHour)) + ":" + this.digit(Number(this.nowMin))  );
	this.input_time.val( out_time ).change();
	
}

Time_select.prototype.outputTime2 = function(){
	var out_time = "";
	( this.use_sec ? "" : "");
	this.input_time.val( out_time ).change();
	
}


Time_select.prototype.currentTime = function(){
	var nowDate = new Date();
	var h = nowDate.getHours();
	var m = nowDate.getMinutes();
	var s = nowDate.getSeconds();
	//h = this.digit(h);
	//m = this.digit(m);
	//s = this.digit(s);
	var nowTime = {"nowHour":h, "nowMin":m, "nowSec":s}
	return nowTime;
}

Time_select.prototype.digit = function(i){
	
	if( i < 10 ){ i = "0" + i};
	return i;
}



Time_select.prototype.onlyNumberInput = function(event)
{
	event = event || window.event;
	var keyID = (event.which) ? event.which : event.keyCode;
	if ( (keyID >= 48 && keyID <= 57) || (keyID >= 96 && keyID <= 105) || keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 || keyID == 186 ) 
		return;
	else
		return false;
}
Time_select.prototype.removeChar = function(event) {
	event = event || window.event;	
	var keyID = (event.which) ? event.which : event.keyCode;
	if ( keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 || keyID == 16 || keyID == 35|| keyID == 36 ){ 
		
		return;
	}else{
		if(  keyID != 16 && keyID != 186 ){
			event.target.value = event.target.value.replace(/[^0-9,:]/g, "");
		}
	}
}

