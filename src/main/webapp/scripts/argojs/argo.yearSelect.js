/**
 * argo.yearSelect.js
 * Copyright 2017, Noh ki won
 * Released on: 2017.04.24
 */

(function($){
	$.setOptionsYear = {
		min:"",
		max:"",
		setYear:""	
	}
	$.fn.yearSelect = function( options ){
		options = $.extend( null, $.setOptionsYear, options );
		this.each( function(index){
			var year_select = new Year_select(this, options.min, options.max, options.setYear);	
			$( this ).data( "year_select", year_select );
			
			year_select.btn_prev.on("click", function(e) {	
				if (options.onPrevYear!== undefined) {
					if( typeof options.onPrevYear == "function" ){ 
						e.currentYear = year_select.year_num;
						options.onPrevYear(e);											
					}else {
						eval(options.onPrevYear);					
					}
				} 	
				return false;			
			});		
			
			year_select.btn_next.on("click", function(e) { 
								
				if (options.onNextYear!== undefined) {
					if( typeof options.onNextYear == "function" ){ 
						e.currentYear = year_select.year_num;
						options.onNextYear(e);						
					}else {
						eval(options.onNextYear); 
					}
				} 
				return false;
			});						
		});		
		return this;
	}	
	
	$.fn.getCurrentYear = function(){
		var year_select = $(this).data("year_select");
		return year_select.year_num;
	}
	
})(jQuery);

function Year_select( selector, min, max, setYear ){
	this.selector = $(selector);
	this.btn_prev = this.selector.find(".btn_yearPrev");
	this.btn_next = this.selector.find(".btn_yearNext");
	this.input_year = this.selector.find(".input_year");
	this.year_num = 0;
	this.min = min;
	this.max = max;
	this.setYear = setYear;
	this.init();
	this.addEvent();
}  

Year_select.prototype.init = function(){	
	var nowYear = "";
	if( this.setYear == "" ){	
		var nowDate = new Date();
		nowYear = nowDate.getFullYear();
	}else{
		nowYear = this.setYear;	
	}
	this.input_year.attr({"value":nowYear + "년"});
	this.year_num = Number(this.input_year.val().substr(0,4));
}


Year_select.prototype.addEvent = function(){
	var thisObj = this;
	this.btn_prev.on("click", function(){
		var num = Number(thisObj.input_year.val().substr(0,4));
		--num;		
		if( thisObj.min != "" ){
			if( num <= thisObj.min	){ 
				num = thisObj.min; 				
				thisObj.btn_prev.hide();
			}
		}		
		thisObj.btn_next.show();
		thisObj.year_num = num;
		thisObj.input_year.val( thisObj.year_num  + "년");
		return false;
	});
	
	this.btn_next.on("click", function(){
		var num = Number(thisObj.input_year.val().substr(0,4));
		++num;	
		if( thisObj.max != "" ){
			if( num >= thisObj.max	){ 
				num = thisObj.max; 
				thisObj.btn_next.hide();
			}
		}	
		thisObj.btn_prev.show();		
		thisObj.year_num = num;
		thisObj.input_year.val( thisObj.year_num + "년");
		return false;
	});	
	
	this.input_year.on("keydown", function(event){
		thisObj.onlyNumberInput(event);
	}).on("keyup", function(){
		thisObj.removeChar(event);
	});
	
	this.input_year.on("blur", function(){
		var year_val = $(this).val().trim();		
		if( year_val != "" ){
			year_val = year_val.split("년");
			year_num = year_val[0];
			console.log(year_num.length)
			if( year_num.length < 4 ){
				var nowDate = new Date();
				var nowYear = nowDate.getFullYear();
				thisObj.input_year.val(nowYear + "년");	
				thisObj.btn_prev.show();	
				thisObj.btn_next.show();	
			}else{
				if( thisObj.min != "" ){
					if( year_num < thisObj.min	){ 
						year_num = thisObj.min;	
						thisObj.btn_prev.hide();	
						thisObj.btn_next.show();					
					}
				}		
				if( thisObj.max != "" ){
					if( year_num > thisObj.max	){ 
						year_num = thisObj.max; 
						thisObj.btn_prev.show();	
						thisObj.btn_next.hide();
					}
				}	
				thisObj.input_year.val(year_num + "년");		
			}
		}
	})
}

Year_select.prototype.onlyNumberInput = function(event)
{
	event = event || window.event;
	var keyID = (event.which) ? event.which : event.keyCode;
	if ( (keyID >= 48 && keyID <= 57) || (keyID >= 96 && keyID <= 105) || keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 || keyID == 186 ) 
		return;
	else
		return false;
}
Year_select.prototype.removeChar = function(event) {
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




