/**
 * ARGO Interface
 * @author Noh ki won
 * @version 1.0.0
 */


//Side Navigation
var currentID = "DASHBOARD";
$(function(){	
	$(".side_navi").navigation({
		//3Depth메뉴 클릭시 히스토리탭메뉴 생성	
		lv3_onClick:function(e){		
			if( $(e.currentTarget).hasClass("non_tab") ){
				return false;
			}else{
				add_tab(e.currentTarget); //MODIFIED BY YAKIM - 즐겨찾기 목록에서 공통으로 사용하기 위해
				//console.log("e.currentTarget>>" + e.currentTarget) ;
			}
		},
		/* argo.navigation.js 에서 일괄 처리. (2017.04.24) */
		//즐겨찾기 클릭시 리스트 생성/삭제
		/*favor_onClick:function(e){
			var target = e.currentTarget;
			var id = $(target).prev().attr("id");
			var title = $(target).prev().text();	
	
			//MODIFIED BY YAKIM - 즐겨찾기에서 클릭시 메뉴실행 하도록 수정함.
			var path = $(target).prev().data("path");

			if(e.state == "on"){
				var favor_obj ='<li><a href="#" id="'+ id +'" onclick="add_tab(this)" data-path="'+ path +'">'+ title +'</a></li>';
				$(".favor_list ul").append( favor_obj );
			}else{
				$(".favor_list a[id="+id+"]").closest("li").remove();
			}
						
			if( e.count > 0 ){ // 즐겨찾기 메뉴 없을 시
				$(".util .btn_favor").addClass("on");		
				$(".favor_blank").hide();						
			}else{ // 즐겨찾기 메뉴 있을 시
				$(".util .btn_favor").removeClass("on"); 
				$(".favor_blank").show();
			} 
		},*/
		sideNavi_onClick:function(e){
			history_move(tab_index+1);	
		}
	});	
	
	//우측 상단 즐겨찾기메뉴( 리스트 Show/Hide ) 
	/*$(".btn_favor").on("click", function(){
		alert("우측 상단 즐겨찾기");
		( $(this).hasClass("show") ? $(this).removeClass("show") : $(this).addClass("show") );
		return false;
	});*/
	
	//히스토리탭 전체 삭제
	$(".btn_allDelete").on( "click", function(){
		$(".history_tab li a[id!=DASHBOARD]").parent().remove();

	    [].slice.call(document.querySelectorAll('iframe')).forEach(function (frame) {
	        // remove all frame children
	    	if(frame.id != "ifDashboard"){
		        while (frame.contentWindow.document.body.firstChild) {
		            frame.contentWindow.document.body.removeChild(frame.contentWindow.document.body.firstChild);
		        }
		        frame.src = 'about:blank';
		        frame.parentNode.removeChild(frame);
	    	}
	    });
	    // force garbarge collection for IE only
	    window.CollectGarbage && window.CollectGarbage();
		
		$(".content_wrap[data-id!=DASHBOARD]").remove();
		$(".history_tab li a[id=DASHBOARD]").addClass("on");
		$(".content_wrap[data-id=DASHBOARD]").show();
		currentID = "DASHBOARD";
		$(".section").addClass("dashboard");
		
		history_chk();
		return false;
	});
	
	//전/후 버튼 이동
	$(".btn_allNext").on("click", function(){
		if( tab_w - tab_posX[tab_index] > history_w ){
			++tab_index;
			$( ".history_tab" ).stop().animate({
				left: -tab_posX[tab_index]
			  }, 500, "easeOutExpo");			
			$(".btn_allPrev").removeClass("non_control");  	
			if( tab_w - tab_posX[tab_index] < history_w ){
				$(".btn_allNext").addClass("non_control");
			}		
		}
	});
	$(".btn_allPrev").on("click", function(){
		if( tab_index > 0 ){
			--tab_index;
			$( ".history_tab" ).stop().animate({
				left: -tab_posX[tab_index]
			  }, 500, "easeOutExpo");
			$(".btn_allNext").removeClass("non_control");
			if( tab_index == 0 ){
				$(".btn_allPrev").addClass("non_control");
			}
		}
	});	
	
	$(window).on( "resize", function(){	
		history_move(tab_index+1);
	});
	
	history_chk();
	
	// MODIFIED BY YAKIM 2017-03-21 DB 서버시간 기준으로 display 
	 function setServerTime()
	 {

		 gServerDt.setSeconds(gServerDt.getSeconds()+1);
	  
	     var year = gServerDt.getFullYear();
	     var month = gServerDt.getMonth() + 1;
	     var date = gServerDt.getDate();
	     var hours = gServerDt.getHours();
	     var minutes = gServerDt.getMinutes();
	     var seconds = gServerDt.getSeconds();
	     
	     if (month < 10)  month = "0" + month;
	  	  
	     if (date < 10)   date = "0" + date;
	       
	     if (hours < 10)  hours = "0" + hours;
	     
	     if (minutes < 10) minutes = "0" + minutes;
		  
	     if (seconds < 10) seconds = "0" + seconds;
	     
	        $('.now_date').html( year + "-" + month+ "-" + date );			
			
			$(".now_sec").html(seconds);
			
			$(".now_min").html(minutes);
			
			$(".now_hour").html(hours);	
	 }

		 setServerTime();
			setInterval( function() {			
				setServerTime();
			}, 1000);	
	/*	
	//현재 시간
	function setTime(){
		var newDate = new Date();
		//gServerDateTime.setSeconds(gServerDateTime.getSeconds()+1);
		
		newDate.setDate(newDate.getDate());		
		$('.now_date').html( newDate.getFullYear() + "-" + ( (newDate.getMonth()+1) < 10 ? "0" : "" ) + (newDate.getMonth()+1) + "-" + ( newDate.getDate() < 10 ? "0" : "" ) + newDate.getDate() );			
		var seconds = new Date().getSeconds();
		$(".now_sec").html(( seconds < 10 ? "0" : "" ) + seconds);
		var minutes = new Date().getMinutes();
		$(".now_min").html(( minutes < 10 ? "0" : "" ) + minutes);
		var hours = new Date().getHours();
		$(".now_hour").html(( hours < 10 ? "0" : "" ) + hours);	
	}
	
	setTime();
	setInterval( function() {			
		setTime();
	}, 1000);	
		*/
	

});

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

function delete_tab(_this){
	var selector = $(_this);	
	var id = selector.prev().attr("id");
	//alert(_this+"////");
	if( id == currentID ){
		var target = selector.closest("li").prev("li").find("a");
		target.addClass("on");
		currentID = target.attr("id");
		$(".content_wrap[data-id='" + currentID + "']").show();	
	}
	
    [].slice.call(document.querySelectorAll('iframe')).forEach(function (frame) {
        // 선택된 화면 모든개체 제거
    	if(id == frame.id){
            while (frame.contentWindow.document.body.firstChild) {
                frame.contentWindow.document.body.removeChild(frame.contentWindow.document.body.firstChild);
            }
            frame.src = 'about:blank';
            frame.parentNode.removeChild(frame);
    	}
    });

	selector.closest("li").remove();
	$(".content_wrap[data-id='" + id + "']").remove();
	
    // force garbarge collection for IE only
    window.CollectGarbage && window.CollectGarbage();

	history_chk();
}


function check_overlap(_id){
	var result = false;
	var total = $(".history_tab li").length;
	$(".history_tab li").each( function(i, obj){
		var id = $(obj).find("a").attr("id");	
		if( id == _id ){
			result = true;	
		}
	});
	return result;
}

//대시보드 Refresh
function refresh_tab(){	
	var dashboardID = "DASHBOARD";
	var dashboardURL = $(".content_wrap[data-id='" + dashboardID + "'] iframe").attr("src");
	if( currentID == dashboardID ){
		$(".content_wrap[data-id='" + dashboardID + "'] iframe").attr("src", dashboardURL );
	}
}

//ADD BY YAKIM - 소분류 메뉴 클릭시  tab 생성  또는 Active 처리
function add_tab(_this){
	var id = _this.id;
	var title = $(_this).data("kind")==null?_this.innerText:'['+$(_this).data("kind")+'] '+_this.innerText;
	var check = check_overlap(id);			
	if( check ){
		//중복
		if( id == "DASHBOARD" ){ $(".section").addClass("dashboard"); }
		$(".history_tab li a[id='" + currentID + "']").removeClass("on");	
		$(".content_wrap[data-id='" + currentID + "']").hide();				
		$(".history_tab li a[id='" + id + "']").addClass("on");	
		$(".content_wrap[data-id='" + id + "']").show();	
		var select_index = $(".history_tab li a[id='" + id + "']").parent().index();
		history_move(select_index);				
		currentID = id;
		
		//index 왼쪽 하단 페이지 정보
		$(".bottom .now_page").text(currentID);
		
	}else{
		//신규 생성
		var tab_html = "<li><a href='#' id='"+ id +"' onclick='historyTab(this)' class='on navi' >" + title + "</a><span class='bnt_delete' onclick='delete_tab(this);'>delete</span></li>"; 
		$(".history_tab").append(tab_html);		
		
		//배경 흰색처리
		if( $(".section").hasClass("dashboard") ){
			$(".section").removeClass("dashboard");	
		}
						
		//MODIFIED BY YAKIM
		var content_html ;
		
		if ($(_this).is("[data-path]")) {
			var path = gGlobal.ROOT_PATH + $(_this).data("path");
		
			// ADD BY YAKIM - dashboard 등 메뉴를 통해서가 아닌 페이지에서  호출 시 페이지간 넘길 값 등 으로 사용
			var sUserOption = "" ;
		
			if ($(_this).is("[data-useroption]")) {
				
				sUserOption = $(_this).data("useroption") ;
			}
			content_html = "<div class='content_wrap' data-id='" + id + "'><iframe id='"+id+"' src='"+ path+"' data-useroption='"+ sUserOption+"'></iframe></div> ";
		} else {
			//content_html = "<div class='content_wrap' data-id='" + id + "'>"+ id +"</div> ";
			content_html = "<div class='content_wrap' data-id='" + id + "'><iframe src='"+ id+".html'></iframe></div> ";
		}
		$(".contents").append(content_html);
		
		$(".history_tab li a[id='" + currentID + "']").removeClass("on");
		$(".content_wrap[data-id='" + currentID + "']").hide();
		currentID = id;					
		
		history_chk();
		
		if($.isFunction(argoAddMenuLog)) argoAddMenuLog(currentID, path, 'L',''); // 메뉴이용이력 등록
	}
	top.gMenu.PGM_ID = id ; //현재 메뉴ID 설정	
}

//히스토리탭 이동버튼 유/무 체크
var tab_index = 0;
var tab_posX = [];
var tab_posW = [];
var history_w = 0;
var tab_w = 0;
var left_gap = 0;
var max_index = 0;
function history_chk(){
	if( $("body").hasClass( "side_w" )){
		left_gap = 215;
	}else{
		left_gap = 65;
	}
	var control_w = $(".history_control").innerWidth();
	history_w = $(".history").width() - control_w;		
	var history_xStr = $(".history_tab").css("left");
	var history_x = history_xStr.substring(0,history_xStr.length-2); 
	tab_posX = [];
	tab_posW = [];
	tab_w = 0;
	var a = 0;
	$(".history_tab li").each(function(i){
		tab_w += $(this).width();			
		tab_posX[i] = Math.floor($(this).offset().left - left_gap - history_x);		
		tab_posW[i] = Math.floor($(this).width());
	});
	
	if( $(".history_tab li").length > 5 ){
		$(".history_tab").width(tab_w + 1);	
	}
	tab_posX[tab_posX.length-1] = Math.floor( $(".history_tab li:last-child").offset().left - left_gap - history_x );

	if( tab_w > history_w ){
		$(".history_control").addClass("over_tab");		
		
		for( var i=0; i<$(".history_tab li").length; i++ ){
			if( tab_w - tab_posX[i] < history_w ){
				var skip = tab_index = max_index = i;
				$(".btn_allNext").addClass("non_control");
				$(".btn_allPrev").removeClass("non_control");
				break;
			}	
		}
		
		$( ".history_tab" ).stop().animate({
				left: -tab_posX[skip]
		}, 800, "easeOutExpo");		
		
	}else{
		$(".history_control").removeClass("over_tab");
		tab_index = 0;
		$( ".history_tab" ).css({left:0});	
		$(".btn_allNext").removeClass("non_control");
		$(".btn_allPrev").addClass("non_control");		
	}	
	
	//index 왼쪽 하단 페이지 정보	
	$(".bottom .now_page").text(currentID);
}

function history_move( id ){	
	var overlap_index = id;
	if( overlap_index-1 < tab_index  ){
		tab_index = overlap_index-1;
		$( ".history_tab" ).stop().animate({
				left: -tab_posX[tab_index]
		}, 800, "easeOutExpo");			
		histoy_tabUse();
	}	
	
	//console.log("tab_index=",tab_index, ",max_index=",max_index)	
	//console.log("tab_posX=",tab_posX)
	//console.log("tab_posW=",tab_posW)	
	//console.log("total=",tab_posX[overlap_index] + tab_posW[overlap_index] - tab_posX[tab_index], ",history_w=",history_w )
	
	if( tab_posX[overlap_index] + tab_posW[overlap_index] - tab_posX[tab_index] > history_w ){
		if( overlap_index - 1 < max_index ){
			tab_index = overlap_index - 1;	
		}else{
			tab_index = max_index;
		}
		$( ".history_tab" ).stop().animate({
				left: -tab_posX[tab_index]
		}, 800, "easeOutExpo");			
		histoy_tabUse();
	}

}

function histoy_tabUse(){
	if( tab_index == 0 ){		
		$(".btn_allPrev").addClass("non_control");
		$(".btn_allNext").removeClass("non_control");
	}else if( tab_w - tab_posX[tab_index] < history_w){
		$(".btn_allPrev").removeClass("non_control");  	
		$(".btn_allNext").addClass("non_control");
	}else{
		$(".btn_allPrev").removeClass("non_control");  	
		$(".btn_allNext").removeClass("non_control");
	}
}

window.addEventListener('beforeunload', function () {
    [].slice.call(document.querySelectorAll('iframe')).forEach(function (frame) {
        // remove all frame children
        while (frame.contentWindow.document.body.firstChild) {
            frame.contentWindow.document.body.removeChild(frame.contentWindow.document.body.firstChild);
        }      
        frame.src = 'about:blank';
        frame.parentNode.removeChild(frame);
    });
    // force garbarge collection for IE only
    window.CollectGarbage && window.CollectGarbage();
});