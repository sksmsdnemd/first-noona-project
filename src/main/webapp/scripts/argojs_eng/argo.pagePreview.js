/**
 * argo.pagePreview.js
 * pop window
 * Copyright 2017, Noh ki won
 * Released on: 2017.02.03
 */

(function($){
	$.setOptionsPP = {
		title : "Screen",
		url : ""
	}
	$.fn.pagePreview = function( options ){
		options = $.extend( null, $.setOptionsPP, options );
		this.each( function(index){			
			var page_preview = new Page_preview( this, options.url, options.title );				
			$(this).find(".btn_print").on("click", function(e) { 							
				if (options.onPrint !== undefined) {
					if( typeof options.onPrint == "function" ){ 
						options.onPrint(e);
					}else {
						eval(options.onPrint); 
					}
			 	} 				
			});	
			$(this).find(".btn_excel").on("click", function(e) {		
				if (options.onExcel !== undefined) {
					if( typeof options.onExcel == "function" ){ 
						options.onExcel(e);
					}else {
						eval(options.onExcel); 
					}
			 	} 				
			});				
		});		
		return this;
	}	
})(jQuery);


function Page_preview( selector, url, title ){		
	this.selector = $(selector);
	this.url = url;
	this.title = title;
	this.init();
	this.printLayer = this.selector.find(".print_layer");
	this.btn_close = this.printLayer.find(".btn_popClose");		
	this.addEvent();
	
}

Page_preview.prototype.init = function(){
	$("body").addClass("print");	
	this.make_window();			
}

Page_preview.prototype.make_window = function(){
	var html = "";
	html += '<div class="print_layer">'
    html += '<div class="pop_bgLayer"></div>'

    if(this.url == "../HR/HR3010S03F.do") html += '<div class="print_div" style="margin-top:-280px;">';
    if(this.url != "../HR/HR3010S03F.do") html += '<div class="print_div">';	
    	
 //   html +=         '<div class="pop_title print_hd">' + this.title + ' 미리보기<a href="#" class="btn_excel" title="엑셀 다운로드">엑셀 다운로드</a><a href="#" class="btn_print" title="인쇄">인쇄</a><a href="#" class="btn_popClose">닫기</a></div>'
    html += '<div class="pop_title print_hd">' + this.title + '<a href="#" class="btn_print" title="Print">Print</a><a href="#" class="btn_popClose">Close</a></div>'
    
    if(this.url == "../HR/HR3010S03F.do") html += '<div class="pop_content_hr">';
    if(this.url != "../HR/HR3010S03F.do") html += '<div class="pop_content">';
    	
    html += '<iframe id="ifPrint" src="' + this.url + '?state=print"></iframe></div></div></div>'
    
	this.selector.append( html );
	setTimeout(function(){ 	$(".print_layer .pop_bgLayer").css("opacity", "0.9");},10);
}

Page_preview.prototype.addEvent = function(){	
	var thisObj = this;
	this.btn_close.on( "click", function(){
		$("body").removeClass("print");
		thisObj.printLayer.remove();	
	});	
}


/**
 * argoPagePreview - 미리보기 페이지 
 * @param _title (필수) : 미리보기 페이지 타이틀
 * _url (필수) : 미리보기 실행 페이지 url
 * _printArea(선택) : 별도의 프린트 영역 selector / 생략 할 경우 sub_wrap 영역기본 처리
  * @returns
 */
function argoPagePreview( _title, _url, oOptions){

	top.gPopupOptions = gPopupOptions ;
	
    oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };  
    
	
	var sSelector = null;
	var pagePreview = $("body").pagePreview({
		title:_title,
		url:_url,
		onPrint:function(){
			//alert('프린트')	
			//window.print();
			//onPrint();
			//$('#ifPrint')[0].contentWindow.onPrint(_title);
			//argoPagePrint('#previewList', {header:'<h1>'+ptitle + '</h1>' })
			if(oOptions.printArea != undefined) {
				var sSelector = $('#ifPrint').contents().find(_printArea) ;		
				
			} else {
				var sSelector = $('#ifPrint').contents().find('.sub_wrap') ;		
				
			}
			if(sSelector != null && sSelector != undefined) {
				var sTitle = (oOptions.header == undefined ?_title : oOptions.header) ;
				
				if(_url =="../EDU/EDU1020S02F.do" && sTitle !='Question Management') { // 시험지 미리보기 인 경우 여러 화면에서 공통으로 호출되므로 인쇄 타이틀 부분 여기서 처리함
						sTitle = '<div class="print_title">'+ sTitle+ '</div>' 
				   		               + '<div class="print_title_sub"><div style="float:right;">'
				  		               + '<span style="padding-right:180px;">Number :</span>'
				  		               + '<span style="padding-right:100px;">Name :</span>'    
				  		             + '</div></div><br>';						
				} else if(_url =="../HR/HR3010S03F.do") {
					sTitle = '<div class="print_title">'+ sTitle+ '</div>'
						   + '<div style="align:center;"><table class="info_table" style="width:370px; margin:0 auto;">'
						   + '<colgroup><col width="100px"><col width="100px"><col width="90px"><col width="90px"></colgroup>'
						   + '<thead><tr class="txt_c"><th>Evaluation Type</th><th>Affiliation</th><th>Number</th><th>Agent Name</th></tr></thead>'
						   + '<tbody><tr><td>Evaluator</td><td></td><td></td><td></td></tr><tr><td>Evaluation Target</td><td></td><td></td><td></td></tr></tbody>'
						   + '</table></div>';			
					
				}else sTitle = '<div class="print_title">'+ sTitle  + '</div>' ;
				
			argoPagePrint(sSelector, {header:sTitle })
			}
			
		},
		onExcel:function(){
			alert('Excel')	
		}
	});
	//return false;
	return ;
	  
}

/**
 * argoPagePrint - 인쇄 
 * @param sSelector (필수) : 인쇄 영역 selctor
 * oOptions(선택) : header ..
  * @returns
 */
function argoPagePrint(sSelector,oOptions){
    oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };    

    $(sSelector).printThis({
        header:  (oOptions.header != undefined ?  oOptions.header  :"")
    });	
    
}    



