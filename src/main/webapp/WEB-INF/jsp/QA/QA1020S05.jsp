<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" trimDirectiveWhitespaces="true"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script>
$(function(){
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
	};
	fnSearchList();
});

$.fn.hasScrollBar = function() {
	return (this.prop("scrollHeight") == 0 && this.prop("clientHeight") == 0) || (this.prop("scrollHeight") > this.prop("clientHeight"));
};


$.fn.rowspan = function(colIdx, isStats) {
	return this.each(function() {
				var that;
				$('tr', this).each(function(row) {
					$('td:eq(' + colIdx + ')', this).filter(':visible').each(function(col) {
						if ($(this).html() == $(that).html()&& (!isStats || isStats&& $(this).prev().html() == $(that).prev().html())) {
							rowspan = $(that).attr("rowspan") || 1;
							rowspan = Number(rowspan) + 1;
								$(that).attr("rowspan",rowspan);
								$(that).attr("data-num",rowspan - 2);
								// do your action for the colspan cell here            
								$(this).hide();
								$(this).removeClass("pos-relative"); 
								// do your action for the old cell here
							} else {
								that = this;
							}
						// set the that if not already set
						that = (that == null) ? this: that;
					});
				});
			});
		};
		
function check_gridScroll(){
	$(".table_list").each(function(i){				
		if($(this).hasScrollBar()){	
			var blank_box = '<span class="blank_box"></span>';					
			var length = $(this).closest(".table_grid").find(".blank_box").length;
			if( length < 1 ){
				$(this).prev(".table_head").addClass("use_pr").parent().append(blank_box);
			}
		}else{
			$(this).prev(".table_head").removeClass("use_pr").parent().find(".blank_box").remove();
		}
	});
}

check_gridScroll();

//접기/펴기 버튼
$(".btn_avShowHide").on("click", function(){
	if( $(this).hasClass("on" ) ){
		$(this).removeClass("on");	
		$(".sub_contents").removeClass("hidden_cont");
	}else{
		$(this).addClass("on");	
		$(".sub_contents").addClass("hidden_cont");
	}
	check_gridScroll();
})


function fnSetScrollPosition(index){
	var offset = $("#table_List").offset().top; // table_List top 위치
	var top=$(".pos-relative:eq("+(index+1)+")").offset().top; // 선택한 소분류 top 위치
	
	$('.table_list').scrollTop(top-offset); 		// 한번에
	$(".trbg").removeClass("bgblue");
	$(".trbg:eq("+(index)+")").addClass("bgblue");
}

function fnSearchList() {
	try {
		var param = {sheetId    :sPopupOptions.sheetId};
			argoJsonSearchList("QA", "SP_QA2010M03_03", "__", param, fnSetTable2)
	} catch (e) {
		console.log(e);
	}
}

function fnSetTable2(data, textStatus, jqXHR) {
	var objHtml = "";
	var majorCd='';
	var minorCd='';
	var dataCode='';
	var cnt = -1;
	$.each(data.getRows(),function(index, row) {
			if(majorCd!=row.majorCd){
				majorCd = row.majorCd;
				minorCd = row.minorCd;
				cnt++;
				dataCode = row.majorCd+row.minorCd;
				objHtml += "<tr class='group"+majorCd+minorCd+"'>"
								+		"<td rowspan='"+row.rowspan1+"'>"+row.majorNm+"</td>"
								+		"<td rowspan='"+row.rowspan2+"' data-num='"+(row.rowspan2-2)+"' class='pos-relative'>"+row.minorNm+"<a href='#' class='btn_more' data-item='item"+majorCd+minorCd+"' data-group='group"+dataCode+"'>show/hide</a></td>"
								+		"<td>설명</td>"
								+		"<td class='txt_l'>"+row.sheetText+"</td>"
								+      "<td>"+row.score+"</td>";
							objHtml += "</tr>"
						}else if(minorCd != row.minorCd){
							minorCd = row.minorCd;
							cnt++;
			     			objHtml += "<tr class='group"+majorCd+minorCd+"'>"
			     							+		"<td rowspan='"+row.rowspan2+"' data-num='"+(row.rowspan2-2)+"' class='pos-relative'>"+row.minorNm+"<a href='#' class='btn_more' data-item='item"+majorCd+minorCd+"' data-group='group"+dataCode+"'>show/hide</a></td>"
			     							+		"<td>설명</td>"
			     							+		"<td class='txt_l'>"+row.sheetText+"</td>"
			     							+      "<td>"+row.score+"</td>";
											objHtml += "</tr>"
							
						}else if(row.qaSebuCd==1){
							objHtml+=	"<tr>"
										+		"<td>평가</td>"
										+		"<td class='txt_l'><textarea rows='' cols='' id='sheetText'>"+row.valueText+"</textarea></td>"
										+		"<td></td>"
										+ 		'<input type="hidden" value="'+row.majorCd+'" name="majorCd">'
										+ 		'<input type="hidden" value="'+row.minorCd+'" name="minorCd">'
										+ 		'<input type="hidden" value="'+row.qaSebuCd+'" name="sebuCd">'
										+	"</tr>";
						}else{
							objHtml+= "<tr class='hidden_row item"+majorCd+minorCd+"'>"
	                    			+		"<td>"+ row.qaSebuNm+"</td>"  
	                    			+		"<td class='txt_l'>"+row.sheetText+"</td>"
	                    			+		"<td>"+row.score+"</td>"
	                    			+ 		'<input type="hidden" value="'+row.majorCd+'" name="majorCd">'
									+ 		'<input type="hidden" value="'+row.minorCd+'" name="minorCd">'
									+ 		'<input type="hidden" value="'+row.qaSebuCd+'" name="sebuCd">'
	                				+	"</tr>";
	                				
						}
					});
	$("#table_List").append(objHtml);
	check_gridScroll();
	fnClickEvent();
}

function fnClickEvent() {
	$(".btn_more").on("click",function() {
		var selector = $(this).attr("data-item");
		var g_id = $(this).attr("data-group");
		var parent_row = $("tr." + g_id).find("td:nth-child(1)");
		var parentRow_num = parent_row.attr("rowspan");
		var current_row = $(this).parent();
		var currentRow_num = current_row.attr("data-num");
		if ($(this).hasClass("on")) {
			$(this).removeClass("on");
			parent_row.attr("rowspan",Number(parentRow_num)+ Number(currentRow_num));
			current_row.attr("rowspan",Number(currentRow_num) + 2);$("." + selector).show();
		} else {
			$(this).addClass("on");
			parent_row.attr("rowspan",Number(parentRow_num)- Number(currentRow_num));
			current_row.attr("rowspan", 2);
			$("." + selector).hide();
		}
		check_gridScroll();
	});
}
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="h20 pos-relative">        
				<div class="sub_c">    
                    <div class="btn_topArea fix_h25 avBtn_area">
                    </div>
                	<div class="grid_area h25 pt0">
                        <div class="table_grid average ct">
                            <div class="table_head">
                                <table>
                                    <colgroup>
                                        <col width="70px">
                                        <col width="70px">
                                        <col width="40px">
                                        <col width="">
										<col width="51px">
                                    </colgroup>
                                    <thead>
                                    	<tr>
                                            <th colspan="2" class="br_b">평가항목</th>
                                            <th rowspan="2">구분</th>
                                            <th rowspan="2">평가내용</th>
                                            <th rowspan="2">평점</th>
                                        </tr>
                                        <tr>
                                            <th>대분류</th>
                                            <th>소분류</th>
                                        </tr>
                                    </thead>
                                </table> 
                            </div>  
                            	<div class="table_list">
								<table id="data_List">
									<colgroup>
                                        <col width="70px">
                                        <col width="70px">
                                        <col width="40px">
                                        <col width="">
                                        <col width="50px">
									</colgroup>
									<tbody id="table_List">
										<!-- ITEM -->
									</tbody>
								</table>
							</div>
                        </div>  
                    </div>                
                </div>
            </div>
        </section>
    </div>
</body>
</html>



