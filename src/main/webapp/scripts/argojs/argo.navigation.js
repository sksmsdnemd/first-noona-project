/**
 * ARGO Side Navigation
 * @author Noh ki won
 * @version 1.0.0
 */

(function($){
	
	/* 우측 상단 북마크 이벤트 */
	fnInitBookmark();
	
	$.setOptions = {}
	$.fn.navigation = function( options ){
		options = $.extend( null, $.setOptions, options );
		this.each( function(index){			
			var navi = new Navi(this);
			
			$(this).find(".lv3 li a").on("click", function(e) {				
				if (options.lv3_onClick !== undefined) {
					options.lv3_onClick(e);
				 }		
				 return false;		 				 
			});				
			// left menu 북마크 선택, 해제
			var btn_favor = $(this).find(".btn_favor");
			btn_favor.on("click", function(e) {
				var target = e.currentTarget;
				var id = $(target).prev().attr("id");
				var title = $(target).prev().text();
				var path = $(target).prev().data("path");
				
				var multiService = new argoMultiService(fnCallbackBookmark);
				
				if($(this).hasClass("on")	){					
					multiService.argoDelete("ARGOCOMMON","SP_CM_BOOKMARK_02", "__", {"pgmId" : id ,"gbn" : "D"});
					$(this).removeClass("on"); 
				}else{
					multiService.argoInsert("ARGOCOMMON","SP_CM_BOOKMARK_02", "__", {"pgmId" : id, "gbn" : "I"});
					$(this).addClass("on");
				}
				
				multiService.action();
				
				return false;	 				 
			});	
			
			//사이드메뉴 접기/펴기 
			this.btn_sideNavi = $(".btn_sideNavi");
			this.btn_sideNavi.on( "click", function(e){
				($("body").hasClass("side_w") ? $("body").removeClass("side_w").addClass("side_n") : $("body").addClass("side_w").removeClass("side_n") );	
				if (options.sideNavi_onClick !== undefined) {
					options.sideNavi_onClick(e);
				 }	
				return false;
			}); 	
		});		
		return this;
	}
	
})(jQuery);

function fnInitBookmark(){
	argoJsonSearchList('ARGOCOMMON', 'SP_CM_BOOKMARK_01', '__', {},  function(data, textStatus, jqXHR) {
		var strHtml = '';

		try {
			if (data.getRows() != '') {
				
				$(".util .btn_favor").addClass("on");		
				$(".favor_blank").hide();
								
				$.each(data.getRows(), function( index, row ) {
					if(row.editGrant == 'N'){ 
						strHtml += '<li><a href="#" id="'+ row.pgmId +'" onclick="argoAlert(\'접근권한이 없습니다.\');" data-path="'+ row.pgmPath +'" style="display: inline;">';
						strHtml += '<strike><strong>['+ row.systemKind +']</strong> ' + row.pgmNm +'</strike></a>';
					}else{
						strHtml += '<li><a href="#" id="'+ row.pgmId +'" onclick="add_tab(this)" data-path="'+ row.pgmPath +'" style="display: inline;">';
						strHtml += '<strong>['+ row.systemKind +']</strong> ' + row.pgmNm +'</a>';
					}
					
					strHtml += '<span style="float:right; padding-right:5px;">';
					strHtml += '<img src="../images/icon_delete1.png" id="btnFavorDel" onclick="fnBookmarkDelete(' + index + ');" style="cursor:pointer;"';
					strHtml += 'onmouseover="' + "this.src='../images/icon_delete2.png'" + ';" onmouseout="' + "this.src='../images/icon_delete1.png'" + ';"></span></li>';
				});
				$(".favor_list ul").html(strHtml);
				
			} else {
				$(".util .btn_favor").removeClass("on");
				$(".favor_blank").show();
				$(".favor_list ul").html(null);
			}
		} catch (e) {
			console.log(e);
		}
	});
}

/**
 * 우측 상단 북마크 삭제 이벤트
 * 
 * fnInitBookmark 에서 row.pgmId 파라미터가 제대로 넘어오지 않아 재 조회하여 index 매칭 후 삭제
 * 
 */
function fnBookmarkDelete(indexVal){
	
	argoJsonSearchList('ARGOCOMMON', 'SP_CM_BOOKMARK_01', '__', {},  function(data, textStatus, jqXHR) {
		
		try {
			if (data.getRows() != '') {
								
				$.each(data.getRows(), function( index, row ) {
					if(indexVal == index){
						$(".lv3 .btn_favor[id='btnFavor"+ row.pgmId +"']").removeClass("on");
						
						var multiService = new argoMultiService(fnCallbackBookmark);
						multiService.argoDelete("ARGOCOMMON","SP_CM_BOOKMARK_02", "__", {"pgmId" : row.pgmId ,"gbn" : "D"});
						multiService.action();
					}
				});
			}
		} catch (e) {
			console.log(e);
		}
	});
}


function fnCallbackBookmark(Resultdata, textStatus, jqXHR){
	try{
		if(Resultdata.isOk()) {
			fnInitBookmark();
		}
	} catch(e) {
		console.log(e);    		
	}
}

function Navi(selector){		
	this.selector = $(selector);		
	this.btn_lv1 = this.selector.find(".gnb > li > a");
	this.lv2_area = this.selector.find(".lv2");
	this.btn_lv2 = this.selector.find(".lv2 .lv2_scroll > li > a");
	this.btn_favor = this.selector.find(".btn_favor");
	this.gnb_scroll = this.selector.find(".gnb_scroll");
	
	this.init();	
	
}

Navi.prototype.init = function(){	
	this.check_w();	
	
	this.lv1.onClick(this.btn_lv1);
	this.lv1.onMouseEnter(this.btn_lv1);
	this.lv1.onMouseLeave(this.btn_lv1);
	
	this.lv2.onClick(this.btn_lv2);
	this.lv2.onMouseEnter(this.lv2_area);
	this.lv2.onMouseLeave(this.lv2_area);
	
	this.addEvent();
	
	this.gnb_scroll.scrollbar();
	
}

Navi.prototype.lv1 = {	 
	//side_w
	onClick:function(selector){		
		selector.on( "click", function(){
			if( $("body").hasClass("side_w") ){			
				if($(this).hasClass("on")	){
					$(this).removeClass("on"); 
					$(this).next().slideUp(500).removeClass("bg_on");	
					$(this).parent();
				}else{
					$(this).addClass("on")	; 
					$(this).next().slideDown(500).addClass("bg_on");		
				}
			}
			return false;
		});
	},
	//side_n
	onMouseEnter:function(selector){
		var thisObj = this;
		selector.on( "mouseenter", function(){		
			if( $("body").hasClass("side_n") ){			
				$(this).next().addClass("view");
				thisObj.pop_HeightCheck($(this));	
			}
		});
	},
	//side_n
	onMouseLeave:function(selector){
		selector.on( "mouseleave", function(){		
			if( $("body").hasClass("side_n") ){			
				$(this).next().removeClass("view");
			}
		});
	},
	//side_n
	pop_HeightCheck:function(_target){		
		var target = _target;
		var winH = $(window).height();
		var popH = target.next().height();
		var popT = target.next().offset().top;
		var popWhole = popH + popT;
		target.next().find(".lv2_scroll").css("max-height", winH - popT -20 );
	}		
}

Navi.prototype.lv2 = {
	//side_n
	onMouseEnter:function(selector){
		selector.on( "mouseenter", function(){		
			if( $("body").hasClass("side_n") ){			
				$(this).addClass("view");	
			}
		});
	},
	//side_n
	onMouseLeave:function(selector){
		selector.on( "mouseleave", function(){		
			if( $("body").hasClass("side_n") ){			
				$(this).removeClass("view");
			}
		});
	},			
	onClick:function(selector){
		selector.on( "click", function(){
		if( $("body").hasClass("side_w") ){
			//side_w
			if($(this).hasClass("on")	){
				$(this).removeClass("on"); 
				$(this).next().slideUp(500);		
			}else{
				$(this).addClass("on")	; 
				$(this).next().slideDown(500);			
			}	
		}else{
			//side_n
			if($(this).hasClass("show")	){
				$(this).removeClass("show"); 				
			}else{
				$(this).addClass("show"); 
			}	
		}
		return false;
	});	
	}
}

Navi.prototype.addEvent = function(){
	var thisObj = this;
	//리사이즈 체크
	$(window).on("resize",function(e){		
		thisObj.check_w();	
	});	
	
	
		
}

Navi.prototype.check_w = function(){
	var winW = $(window).width();	
	if( winW >= 1280 ){
		$("body").addClass("side_w").removeClass("side_n");
		
	}else{
		$("body").removeClass("side_w").addClass("side_n");	
	}   	
}

