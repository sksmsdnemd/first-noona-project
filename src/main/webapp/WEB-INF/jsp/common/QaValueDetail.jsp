<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<!DOCTYPE html >
<html>
<head>
<title>ARGO</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />
<%@ include file="/WEB-INF/jsp/include/common.jsp"%>
<%
	String recTableType = Globals.REC_TABLE_TYPE(); 
%>
<style>
	input[readonly=readonly], textarea[readonly=readonly]{
		color:blue !important;
	}
	
		#step1, #step2{
		cursor: pointer;
	}
	
	/* 통화 품질 평가 요청사항으로 인해 해당 화면만 음영 처리 하기 위해 수정 20221104 gyu*/
	/* 평가항목 그리드 */
	.table_grid .table_head {
		border: 1px solid #898b90;
		border-top: 2px solid #898b90;
		background: #fafafa;
		overflow: hidden;
	}

	.table_grid .table_list {
		border: 1px solid #898b90;
		border-top: none;
		max-height: 105px;
		overflow-x: hidden;
		overflow-y: auto;
		height: 105px;
	}


	.table_grid .table_head tr th.br_b {
		border-bottom: 1px solid #898b90;
	}

	.table_grid tr th, .table_grid tr td {
		border: 1px solid #898b90;
		line-height: 17px;
		text-align: center;
	}
	
	/* 텍스트 */
	textarea {
		color : blue;
	}
	
	/* 상단 그리드*/
	.input_table tr th, .input_table tr td {
		border: 1px solid #565353;
	}
	
	/* 20230609 jslee 평가표 깨짐현상 수정 위한 CSS추가 */
	.blank_box {
		border-left : 1px solid #898b90;
		width : 17px;
	}
	
	/* 20230609 jslee 평가표 깨짐현상 수정 위한 CSS추가 */
	td {
		border-right : 1px solid #898b90 ! important;
	}
	
	.table_grid.average tr td{
		padding: 0px;
	}
	
	.txt_l{
		padding: 5px !important;
	}
</style>
<script type="text/javascript" src="<c:url value="/scripts/security/sha512.js"/>"></script>
<script>
var recTableType = '<%=recTableType%>';
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var userName    = loginInfo.SVCCOMMONID.rows.userName;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;
var workMenu 	= "평가승인관리-상세보기";
var workLog 	= "";
var fvTimesId	= "";
var sRecTableNm = "";

var dataArray 	= new Array();

	$(document).ready(function() {
		fnInitCtrl();
		fnValueInfo();
		fnSearchList();
	});
	
	
	
	function textareaResize(obj){
		$(this).css('height','auto');
		obj.style.height = ((obj.scrollHeight+2))+"px";
		
	}
	
	function fnSearchList(){
		try {
			var param = {
				sheetkey : sPopupOptions.sheetkey
			};
	
			var multiService = new argoMultiService(fnCallbackSearch);
	
			multiService.argoList("QA", "SP_QA2010M03_02", "__", param)
							.argoList("ARGOCOMMON", "SP_UC_GET_QA_VALUE_DETAIL", "__", param)
			multiService.action();
		} catch (e) {
			console.log(e);
		}
	}

	function fnCallbackSearch(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				fnSetTable1(data.getRows(0));
				fnSetTable2(data.getRows(1));
			}
		} catch (e) {
			argoAlert(e);
		}
	}
	
	//평가 점수
	function fnSetTable1(dataRow) {
		var valueScore = 0;
		var objHtml = '';
		$.each(dataRow,function(index, row) {
			objHtml += '<tr onclick="fnSetScrollPosition('+(index)+')" class="trbg '+(row.score==0 ? "":"bgwhite")+'" >'
					+ '<td>'+ (index + 1)+ '</td>'
					+ '<td class="txt_l">'+ (row.itemNm)+ '</td>'
					+ '<td id="'+row.majorCd+row.minorCd+'" name="table1Score" style="min-width: 20px;">'+ (row.score) + '</td>'
					+ '</tr>';
			valueScore += row.score;
		});

		$("#valueScore").html(valueScore);
		$("#table1").append(objHtml);
		
	}

	function fnInitCtrl() {
		// 호출화면의 조직팝업 옵션 정보 
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	
	    fvTimesId 	= sPopupOptions.timesId;
	    sRecTableNm = argoQaTimesRecTable(fvTimesId, recTableType);
	    
    	$("#btn_Save").click(function() {
			fnSave("10");
		})

		$("#btn_Complete").click(function() {
			fnSave("40");
		})
	    
	    
		$.fn.rowspan = function(colIdx, isStats) {
			return this
			.each(function(){
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
					
		//접기/펴기 버튼
		$(".btn_avShowHide").on("click", function() {
			if ($(this).hasClass("on")) {
				$(this).removeClass("on");
				$(".sub_contents").removeClass("hidden_cont");
			} else {
				$(this).addClass("on");
				$(".sub_contents").addClass("hidden_cont");
			}
			check_gridScroll();
		})
		
		$.fn.hasScrollBar = function() {
			return (this.prop("scrollHeight") == 0 && this.prop("clientHeight") == 0)
					|| (this.prop("scrollHeight") > this.prop("clientHeight"));
		};
		
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
		
	function check_gridScroll() {
		$(".table_list").each(
			function(i) {
				if ($(this).hasScrollBar()) {
					var width = "0px;";
					var div = document.getElementById("tableScore");
					var scrollbarWidth = div.offsetWidth - div.clientWidth;
					var width = scrollbarWidth-2;
					var blank_box = '<span class="blank_box" style="width:'+width+'px;"></span>';
					//var blank_box = '<span class="blank_box"></span>';
					var length = $(this).closest(".table_grid").find(".blank_box").length;
					if (length < 1) {
						$(this).prev(".table_head").addClass("use_pr").parent().append(blank_box);
					}
				} else {
					$(this).prev(".table_head").removeClass("use_pr").parent().find(".blank_box").remove();
				}
			}
		);
	}
	
	function fnDetailInfoCallback(data, textStatus, jqXHR) {
		try {
			if (data.isOk()) {
				var info = data.getRows();
				//jslee 본인이 평가자이면서 저장상태일 때만 버튼 보이기
				if(info.qaaSabun == userId && info.qaValueStatus == "10"){
					argoSetValue("modYn", "1");
				}
				fnCtrlSheet();
				$("#timesNm").html(info.timesNm);
				$("#sheetNm").html(info.sheetNm);
				$("#sheetId").val(info.sheetId);
				$("#qaEvalType").html(info.qaEvalType);
				$("#valueFrmTo").html(info.valueFrmDt + ' ~ ' + info.valueEndDt);
				//$("#recordId").html('<img src="../images/speak_up.png" onclick="argoRecPlay(\''+info.recordId+'\' , \'' +playerKind +'\' , \'' +sRecTableNm+'\')">'+'&nbsp&nbsp&nbsp'+info.recordId);
				$("#recordId").html('<img src="../images/speak_up.png" onclick="argoRecPlay(\''+info.recordId+'\' , \'' +playerKind +'\' , \'' +sRecTableNm+'\')">'+'&nbsp&nbsp&nbsp');
				$("#sttId").html('<img src="../images/icon_code.png" onclick="argoTaPopup(\''+info.recordId+'\', \'' +sRecTableNm+'\')">'+'&nbsp&nbsp&nbsp');
				$("#valueYmd").html(info.valueYmd);
				$("#valueMemb").html(info.qaaNm + ' ('+info.qaaSabun+')');
				$("#qaValueStatus").html(info.qaValueStatusNm);
				$("#deptInfo").html(info.deptInfo);
				$("#sabun").html(info.agentSabun);
				$("#agentNm").html(info.agentNm + ' ('+info.agentSabun+')');
				
				
				$("#recYmd").html(argoNullConvert(info.recYmd));
				
				var recTime = argoNullConvert(info.starttime)==""?"":info.starttime + ' ~ ' + info.endtime;
				$("#rectime").html(recTime);
				
				var talkTm = argoNullConvert(info.talkTm)=="::"?"":info.talkTm;
				$("#talkTm").html(talkTm);
				$("#totalComment").val(info.totalComment);
				argoSetValue("status", info.qaValueStatus);
				argoSetValue("qaaId", info.qaaId);
				
				//sRecTableNm = argoQaTimesRecTable(info.timesId , recTableType);
			}
		} catch (e) {
			console.log(e);
		}
	}

	/* function fnSetTable2(dataRow) {
		var objHtml = "";
		var checkIndex = 0;
		var tempMajorCd = "";
		var tempMinorCd = "";
		var dataIndex = 0;
		var tempIndex = 0;
		
		$.each(dataRow,function(index, row) {
			if (row.qaSebuCd == '0'&& tempMinorCd != row.majorCd) {
				tempMinorCd = row.majorCd;
				dataIndex = 0;
				itemIndex = checkIndex;
				checkIndex++;
			} else if (row.qaSebuCd == '0'&& tempMajorCd == row.majorCd&& tempMinorCd == row.majorCd) {
				dataIndex++;
				itemIndex = checkIndex + '-' + String(dataIndex);
			}

			if (row.qaSebuCd == '0' && tempMajorCd != row.majorCd) {
				objHtml += '<tr class="group'+checkIndex+'">';
				tempMajorCd = row.majorCd;
			} else if ((row.qaSebuCd == '0' && tempMajorCd == row.majorCd)||row.qaSebuCd == '1') {
				objHtml += '<tr>';
			} else {
				objHtml += '<tr class="hidden_row item'+ (itemIndex) + '">';
			}

			objHtml += '<td>'+ row.majorNm+ '</td>'
					+ '<td class="pos-relative">'+ row.minorNm+ '<a href="#" class="btn_more" data-item="item'+itemIndex+'" data-group="group'+checkIndex+'"></a></td>'
					+ '<td>'+ row.qaSebuNm+ '</td>'
					+ (row.qaSebuCd == '1' ? '<td class="txt_l"><textarea rows="" cols="" id="sheetText">'+ (row.valueText)+ '</textarea></td>': '<td class="txt_l">'+ row.sheetText + '</td>')
					+ (row.qaSebuCd == '1' ? '<td></td>': '<td>' + row.score + '</td>')+ (row.qaSebuCd == '0' ? '<td id="selScore">'+ row.selScore + '</td>': '<td></td>')
					+ '<input type="hidden" value="'+row.majorCd+'" name="majorCd">'
					+ '<input type="hidden" value="'+row.minorCd+'" name="minorCd">'
					+ '<input type="hidden" value="'+row.qaSebuCd+'" name="sebuCd">'
					+ '<input type="hidden" value="'+row.plusMinus+'" name="plusMinus">';
			
			var checkHtml = '';
			if (row.qaSebuCd == '0') {
				var sebuCd = row.sebuCd.split(",");
				var sebuCdScore = row.sebuCdScore.split(",");

				for (var i = 0; i < sebuCd.length; i++) {
					checkHtml += '<td>'
								+'<input type="checkbox" id="check_'+ itemIndex+ '_'+ (i + 1)+ '" name="group'+ itemIndex+ '"  class="pr0" value="'+ sebuCd[i]+ ','+ sebuCdScore[i]+ ','+ index+','+row.majorCd+','+row.minorCd+','+tempIndex+ '"           '+ (sebuCd[i] == row.selSebuCd ? "checked": "")+ '>'
								+'<label for="check_'+ itemIndex+ '_'+ (i + 1)+ '" name="group'+ itemIndex+ '_'+ (i + 1)+ '"  class="mr0")"></label>'
								+'</td>';
				}
				tempIndex++;
				for (var i = sebuCd.length; i < 5; i++) {
					checkHtml += '<td></td>'
				}
			} else {
				checkHtml = '<td></td><td></td><td></td><td></td><td></td>';
			}
			objHtml += checkHtml + "</tr>";

		});
		$("#table_List").append(objHtml);
		$("#data_List").rowspan(0);
		$("#data_List").rowspan(1);
		check_gridScroll();
		fnClickEvent();
		fnCheckboxInit();
		fnCtrlSheet();
	} */
	
	function fnSetTable2(dataRow) {
		var objHtml = "";
		var majorCd='';
		var minorCd='';
		var dataCode='';
		var cnt = -1;
		var maxCnt = dataRow[0].maxCnt;		// 평가표 문항 수
		var qaCdList = dataRow[0].qaCdList.split(",");
		var tdHtml = "";
		// 평가표 Header
		var tableColgroup = '<colgroup>'
										+'<col width="90px">'
										+'<col width="90px">'
										+'<col width="40px">'
										+'<col width="">'
										+'<col width="40px">'
										+'<col width="33px">'
										;
		
		// 20230609 jslee 평가표 DATA부 그룹컬럼을 새로 만들었음.
		// DATA부의 마지막 컬럼에는 1픽셀이 적어야 안깨져서 따로 변수로 뺐음.
		var tableColDataGroup = '<colgroup>'
										+'<col width="90px">'
										+'<col width="90px">'
										+'<col width="40px">'
										+'<col width="">'
										+'<col width="40px">'
										+'<col width="33px">'
										;
		
		
		var tableThead = '<thead>'
									+'<tr>'
										+'<th colspan="2" class="br_b">평가항목</th>'
										+'<th rowspan="2">구분</th>'
										+'<th rowspan="2">평가내용</th>'
										+'<th rowspan="2">배점</th>'
										+'<th rowspan="2">평점</th>';
		for(var i = 0; i<maxCnt; i++){
			
			// 20230609 jslee 데이터부의 마지막 행은 1px이 적어야 안꺠짐.
			if(i == maxCnt-1){
				tableColDataGroup += '<col width="32px">';
			}else{
				tableColDataGroup += '<col width="33px">';
			}
			
			tableColgroup += '<col width="33px">';
		
			
			tableThead += '<th rowspan="2">'+qaCdList[i]+'</th>'
			tdHtml += "<td></td>"
		}
			tableColgroup += '</colgroup>';
			tableColDataGroup += '</colgroup>';
			tableThead += '</tr>'
								 +'<tr>'
										+'<th>대분류</th>'
										+'<th>소분류</th>'
									+'</tr>'
								+'</thead>'; 
		$("#table_header").append(tableColgroup);
		$("#table_header").append(tableThead);
		
		// 20230609 jslee 데이터부용 그룹 HTML 적용
		$("#data_List").append(tableColDataGroup);
		
		
		$.each(dataRow,function(index, row) {
	 		if(majorCd!=row.majorCd){
	 			majorCd = row.majorCd;
	 			minorCd = row.minorCd;
	 			cnt++;
	 			dataCode = row.majorCd+row.minorCd;
	 			objHtml += "<tr class='group"+majorCd+minorCd+"'>"
	 							+		"<td style='font-weight:900;' rowspan='"+row.rowspan1+"'>"+row.majorNm+"</td>"
	 							+		"<td style='font-weight:900;' rowspan='"+row.rowspan2+"' data-num='"+(row.rowspan2-2)+"' class='pos-relative'>"+row.minorNm+"<a href='#' class='btn_more' data-item='item"+majorCd+minorCd+"' data-group='group"+dataCode+"'>show/hide</a></td>"
	 							+		"<td>설명</td>"
	 							+		"<td class='txt_l'>"+row.sheetText+"</td>"
	 							+      "<td>"+row.score+"</td>"
								+		"<td id='selScore' style = 'font-weight:900;'>"+row.selScore+"</td>"
								+		 '<input type="hidden" value="'+row.majorCd+'" name="majorCd">'
								+		 '<input type="hidden" value="'+row.minorCd+'" name="minorCd">'
								+		 '<input type="hidden" value="'+row.qaSebuCd+'" name="sebuCd">'
								+		'<input type="hidden" value="'+row.checkYn+'" name="checkYn">';

								
								var sebuCd = row.sebuCd.split(",");
								var sebuCdScore = row.sebuCdScore.split(",");
								
								for(var i =0; i<maxCnt; i++){
									var chkCd = true;
									for(var j=0; j<sebuCd.length; j++){
										if(sebuCd[j]==qaCdList[i]){
											objHtml += '<td>'
													+'<input type="checkbox" id="check_'+ majorCd+minorCd+ '_'+ (j + 1)+ '" name="group'+ majorCd+minorCd+ '"  class="pr0" value="'+ sebuCd[j]+ ','+ sebuCdScore[j]+','+index+','+row.majorCd+','+row.minorCd+','+cnt+'"       '+ (sebuCd[j] == row.selSebuCd ? "checked": "")+ '>'
													+'<label for="check_'+ majorCd+minorCd+ '_'+ (j + 1)+ '" name="group'+ majorCd+minorCd+ '_'+ (j + 1)+ '"  class="mr0" ></label>'
													+'</td>';
											chkCd = false;
											break;
										}
									}
									if(chkCd){
										objHtml += '<td></td>'
									}
								}
								objHtml += "</tr>"
	 					}else if(minorCd != row.minorCd){
	 						minorCd = row.minorCd;
	 						cnt++;
	 		     			objHtml += "<tr class='group"+majorCd+minorCd+"'>"
	 		     							+		"<td style='font-weight:900;' rowspan='"+row.rowspan2+"' data-num='"+(row.rowspan2-2)+"' class='pos-relative'>"+row.minorNm+"<a href='#' class='btn_more' data-item='item"+majorCd+minorCd+"' data-group='group"+dataCode+"'>show/hide</a></td>"
	 		     							+		"<td>설명</td>"
	 		     							+		"<td class='txt_l'>"+row.sheetText+"</td>"
	 		     							+      "<td>"+row.score+"</td>"
	 										+		"<td id='selScore' style='font-weight:900;'>"+row.selScore+"</td>"
	 										+		 '<input type="hidden" value="'+row.majorCd+'" name="majorCd">'
	 										+		 '<input type="hidden" value="'+row.minorCd+'" name="minorCd">'
	 										+		 '<input type="hidden" value="'+row.qaSebuCd+'" name="sebuCd">'
	 										+		'<input type="hidden" value="'+row.checkYn+'" name="checkYn">'
	 										;
	 										var sebuCd = row.sebuCd.split(",");
	 										var sebuCdScore = row.sebuCdScore.split(",");
	 										
	 										for(var i =0; i<maxCnt; i++){
	 											var chkCd = true;
	 											for(var j=0; j<sebuCd.length; j++){
	 												if(sebuCd[j]==qaCdList[i]){
	 													objHtml += '<td>'
	 															+'<input type="checkbox" id="check_'+ majorCd+minorCd+ '_'+ (j + 1)+ '" name="group'+ majorCd+minorCd+ '"  class="pr0" value="'+ sebuCd[j]+ ','+ sebuCdScore[j]+','+index+','+row.majorCd+','+row.minorCd+','+cnt+'"       '+ (sebuCd[j] == row.selSebuCd ? "checked": "")+ '>'
	 															+'<label for="check_'+ majorCd+minorCd+ '_'+ (j + 1)+ '" name="group'+ majorCd+minorCd+ '_'+ (j + 1)+ '"  class="mr0" ></label>'
	 															+'</td>';
	 													chkCd = false;
	 													break;
	 												}
	 											}
	 											if(chkCd){
	 												objHtml += '<td></td>'
	 											}
	 										}
	 										objHtml += "</tr>"
	 						
	 					}else if(row.qaSebuCd==1){
							
							var rowText ='';
							rowText = row.valueText
							if(row.valueText ==' ')
							{
								rowText = ''
							}
							
				
	 						objHtml+=	"<tr>"
	 									+		"<td>평가</td>"
										+		"<td class='txt_l'><textarea class='textarea-resize'  rows='' cols='' id='sheetText' onclick='textareaResize(this)' onKeydown='textareaResize(this)' >"+rowText+"</textarea></td>"
	 									+		"<td></td>"
	 									+		"<td></td>"
	 									+		tdHtml
	  									+		 '<input type="hidden" value="'+row.majorCd+'" name="majorCd">'
										+		 '<input type="hidden" value="'+row.minorCd+'" name="minorCd">'
										+		 '<input type="hidden" value="'+row.qaSebuCd+'" name="sebuCd">'
										+		'<input type="hidden" value="'+row.checkYn+'" name="checkYn">'
	 									+	"</tr>";
	 					}else{
	 						objHtml+= "<tr class='hidden_row item"+majorCd+minorCd+"'>"
	                        			+		"<td>"+ row.qaSebuNm+"</td>"  
	                        			+		"<td class='txt_l'>"+row.sheetText+"</td>"
	                        			+		"<td>"+row.score+"</td>"
	                        			+		"<td></td>"
	                        			+		tdHtml
	            						+		 '<input type="hidden" value="'+row.majorCd+'" name="majorCd">'
										+		 '<input type="hidden" value="'+row.minorCd+'" name="minorCd">'
										+		 '<input type="hidden" value="'+row.qaSebuCd+'" name="sebuCd">'
										+		'<input type="hidden" value="'+row.checkYn+'" name="checkYn" >'
	                    				+	"</tr>";
	                    				
	 					}
						});
		
		
		$("#table_List").append(objHtml);
		check_gridScroll();
		fnClickEvent();
		fnCheckboxInit();
		fnCtrlSheet();
		
		$(".textarea-resize").trigger('click');
	}
	
	function fnValueInfo(){
		var param = { sheetkey:sPopupOptions.sheetkey, tableNm : sRecTableNm};   
  		argoJsonSearchOne("ARGOCOMMON", "SP_UC_GET_QA_VALUE_INFO", "__", param, fnDetailInfoCallback);
	}
	
	function fnSetScrollPosition(index){
		var offset = $("#table_List").offset().top; // table_List top 위치
		var top=$(".pos-relative:eq("+(index+1)+")").offset().top; // 선택한 소분류 top 위치
		
        //$('.table_list').scrollTop(top-offset); 		// 한번에
 		$('.table_list').stop().animate( { scrollTop : top-offset }); // 애니메이션 효과
		
		
		$(".trbg").removeClass("bgblue");
		$(".trbg:eq("+(index)+")").addClass("bgblue");
		
	}

	function fnCtrlSheet(){
		if(argoGetValue("modYn")==0){
			$('input[type=checkbox]').attr("disabled", true);
			$('textarea').attr("readonly", true); 
			$("#totalComment").attr("style","width:932px");
		}else{
			$(".comment_btns").attr("style","display : block");
			
		}
	}
	
	// 체크 박스 선택시 이벤트 (백그라운드 컬러 및 값 세팅)
	function fnCheckboxInit(){
		
		 $('input[type="checkbox"]').change(function(){
			 $('input[type="checkbox"][name="'+this.name+'"]').not(this).prop("checked", false);
			 var valueArray=this.value.split(",");
			 var score = ($('input[type="checkbox"][name="'+this.name+'"]:checked').length==0 ? 0:valueArray[1] );
			 var row = valueArray[2];
			 var majorCd = valueArray[3];
			 var minorCd = valueArray[4];
			 var index = valueArray[5];

			$("#" + majorCd + minorCd).html(score);
			$('#data_List tr').eq(row).find('#selScore').html(score);
		
			// 평가 점수 background color 세팅
	 		if(score==0){
				$(".trbg:eq("+(index)+")").removeClass("bgwhite");
//  				$(".trbg:eq("+(index)+")").addClass("bgred");
 			}else{ 
//  				$(".trbg:eq("+(index)+")").removeClass("bgred");
 				$(".trbg:eq("+(index)+")").addClass("bgwhite");
 			}
 			
	 		$(".trbg").removeClass("bgblue");
			$(".trbg:eq("+(index)+")").addClass("bgblue");
 		
			var trSize = $('#data_List tr').size();
	 		var sumScore = 0 ;
	 		for (var i = 0; i < trSize; i++) {
	 			var score= $('#data_List tr').eq(i).find('#selScore').html();
	 			sumScore +=(score != null ? Number(score) : 0);
	 		}
	 		$("#valueScore").html(sumScore);
			
    		});
		 
		// 평가 점수 세팅
		var trSize = $('#data_List tr').size();
 		var sumScore = 0 ;
 		for (var i = 0; i < trSize; i++) {
 			var score= $('#data_List tr').eq(i).find('#selScore').html();
 			sumScore +=(score != null ? Number(score) : 0);
 		}
 		$("#valueScore").html(sumScore);
		 
	}
	
	function fnCompleteChk() {
		var flag = false;
		for (var i = 0; i < $('#data_List tr').size(); i++) {
			var sebuCd = $('#data_List tr').eq(i).find('input[name=sebuCd]').val();
			
			if(sebuCd == '0') {
				 if($('#data_List tr').eq(i).find('input[type="checkbox"]:checked').val()==null){
					 flag = true;
					 break;
				 }
			}
		}
		return flag;
	}
	
	///////////////////////////////////////////////////
	//저장 및 완료
	function fnSave(qaValueStatus) {
		
		var majorCd = ''; // 대분류코드
		var minorCd = '' // 소분류코드
		var tempMajorCd = ''; // 임시 대분류코드 
		var tempMinorCd = ''; // 임시 소분류코드

		var sheetId = argoGetValue("sheetId");
		var gbn = "U"
		var sheetkey = sPopupOptions.sheetkey;

		// 수정해야함 null 값이 string 형태로 넘어와서 임시로 이렇게함 추후 수정할거에용
		
		/* var msg = "";
		if(qaValueStatus == '20'){ //완료버튼 클릭시
			msg = "상담사 통화품질평가를 완료 처리 하시겠습니까?";
		}else{
			msg = "상담사 통화품질평가를 저장하시겠습니까?";
		} */
		
		var msg = "";
		if(qaValueStatus == '40'){ //완료버튼 클릭시
			if(fnCompleteChk()){
				argoAlert("상담사 통화품질평가가 완료되지 않았습니다.");
				return ;
			}
			msg = "상담사 통화품질평가를 완료 처리 하시겠습니까?";
			
		}else{
			msg = "상담사 통화품질평가를 저장하시겠습니까?";
		}
		
		
		argoConfirm(msg, function() {
			var param = {
				"gbn" : gbn,
				"sheetkey"      : sheetkey,
				"sheetId"       : sheetId,
				"qaValueStatus" : qaValueStatus,
				"totalComment"  : $("#totalComment").val()
			}
			argoJsonSearchOne('QA', 'SP_QA2010M03_05', '__', param, function(data, textStatus, jqXHR) {
				fnSaveDetail(sheetkey);
			});
		});
	}

	// Detail 저장
	function fnSaveDetail(sheetkey) {
		var majorCd = ''; // 대분류코드
		var minorCd = '' // 소분류코드
		var qaSebuInfo = '' // 선택한 값
		var score = 0; // 선택한 값에 대한 스코어
		var valueText = '';
		var tempMajorCd = ''; // 임시 대분류코드 
		var tempMinorCd = ''; // 임시 소분류코드
		var selSebuCd = "";
		var selScore = 0;
		var sheetId = argoGetValue("sheetId");
		try {

			var multiService = new argoMultiService(fnCallbackSave);
			for (var i = 0; i < $('#data_List tr').size(); i++) {
				majorCd = $('#data_List tr').eq(i).find('input[name=majorCd]').val();
				minorCd = $('#data_List tr').eq(i).find('input[name=minorCd]').val();
				var sebuCd = $('#data_List tr').eq(i).find('input[name=sebuCd]').val();

				if (tempMajorCd != majorCd || tempMinorCd != minorCd) {

					if (sebuCd == '0') {
						selSebuCd = "";
						selScore = 0;
						var temp = $('#data_List tr').eq(i).find('input[type="checkbox"]:checked').val();
						if (temp != null) {
							qaSebuInfo = temp.split(",");
							selSebuCd = qaSebuInfo[0];
							selScore = qaSebuInfo[1];
						} else {
							selSebuCd = '1';
							selScore = 0;
						}
					} else if (sebuCd == '1') {
						valueText = $('#data_List tr').eq(i).find('#sheetText').val();
						tempMajorCd = majorCd;
						tempMinorCd = minorCd;
						if (selSebuCd != '') {
							var param = {
								sheetkey : sheetkey,
								majorCd : majorCd,
								minorCd : minorCd,
								qaSebuCd : selSebuCd,
								score : selScore,
								valueText : valueText,
								sheetId :sheetId,
							//	lastChk : ($('#data_List tr').size()-1==i? 1:0)
							}
							multiService.argoInsert("QA", "SP_QA2010M03_06","__", param);
						}
					}
				}
			}
			
			multiService.argoUpdate("QA", "SP_QA2010M03_07","__", {sheetkey:sheetkey, sheetId:argoGetValue("sheetId")});
			multiService.action();

		} catch (e) {
			console.log(e);
		}
	
	}
	
	function fnCallbackSave(data, textStatus, jqXHR) {
		try{
			if(data.isOk()){
				argoAlert('warning', '성공적으로 저장되었습니다.','', 'parent.fnSearchList(); argoPopupClose();');
			}
			
		}catch(e){
			argoAlert(e)
		}
		
	}
	
	
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents sub_contents">            
            <div class="pop_cont h0 pt20">
                   <div class="input_area">
						<table class="input_table txt_less">
							<colgroup>
								<col width="7%">
								<col width="13%">
								<col width="7%">
								<col width="13%">
								<col width="7%">
								<col width="13%">
								<col width="7%">
								<col width="13%">
								<col width="7%">
								<col width="13%">
							</colgroup>
							<tbody>
								<tr>
									<th>평가계획</th>
									<td id="timesNm"></td>
									<!-- <th>평가표</th>
									<td id="sheetNm"></td> -->
									<th>평가구분</th>
									<td id="qaEvalType"></td>
									<th>평가기간</th>
									<td id="valueFrmTo"></td>
									<th>평가상태</th>
									<td id="qaValueStatus"></td>
									<th> </th>
									<td> </td>
								</tr>
								<tr>
									<th>녹취일자</th>
									<td id="recYmd"></td>
									<th>녹취시간</th>
									<td id="rectime"></td>
									<th>통화시간</th>
									<td id="talkTm"></td>
									<th>청취</th>
									<td id="recordId"></td>
									<th>STT</th>
									<td id="sttId"></td>
								</tr>
								<tr>
									<th>소속</th>
									<td id="deptInfo"></td>
									<th>상담사명</th>
									<td id="agentNm"></td>
									<th>평가자</th>
									<td id="valueMemb"></td>
									<th>평가일자</th>
									<td id="valueYmd"> </td>
									<th> </th>
									<td> </td>
								</tr>
							</tbody>
						</table>
				</div>
				<div class="h228 pos-relative" style="height: calc(100% - 193px)">
				<div class="sub_l fix210">
					<div class="btn_topArea fix_h25"></div>
					<div class="grid_area h25 pt0">
						<div class="table_grid average">
							<div class="table_head">
								<table>
									<colgroup>
										<col width="100%">
									</colgroup>
									<thead>
										<tr>
											<th><p>평가점수</p> <span class="av_score" id="valueScore"></span></th>
										</tr>
									</thead>
								</table>
							</div>
							<div class="table_list">
								<table id="score_List">
									<colgroup>
										<col width="13%">
										<col width="76%">
										<col width="13%">
									</colgroup>
									<tbody id="table1">
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
				<div class="sub_c" style="padding-left: 210px;">
					<div class="btn_topArea fix_h25 avBtn_area">
						<a href="#" class="btn_avShowHide"></a>
					</div>
					<div class="grid_area h25 pt0">
						<div class="table_grid average ct">
							<div class="table_head">
								<table id="table_header">
									
								</table>
								<!-- <table>
									<colgroup>
										<col width="90px">
										<col width="90px">
										<col width="40px">
										<col width="">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
									</colgroup>
									<thead>
										<tr>
											<th colspan="2" class="br_b">평가항목</th>
											<th rowspan="2">구분</th>
											<th rowspan="2">평가내용</th>
											<th rowspan="2">배점</th>
											<th rowspan="2">평점</th>
											<th rowspan="2">A</th>
											<th rowspan="2">B</th>
											<th rowspan="2">C</th>
											<th rowspan="2">D</th>
											<th rowspan="2">E</th>
										</tr>
										<tr>
											<th>대분류</th>
											<th>소분류</th>
										</tr>
									</thead>
								</table> -->
							</div>
							<div class="table_list" id="tableScore">
								<table id="data_List">
									<tbody id="table_List">
										<!-- ITEM -->
									</tbody>
								</table>
								<!-- <table id="data_List">
									<colgroup>
										<col width="90px">
										<col width="90px">
										<col width="40px">
										<col width="">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
										<col width="33px">
									</colgroup>
									<tbody id="table_List">
										ITEM
									</tbody>
								</table> -->
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="comment_area">
				<div class="comment_title">종합평가결과</div>
				<div class="comment_txt">
					<textarea id="totalComment" name="" rows=""></textarea>
				</div>
				<div class="comment_btns" style="display: none;">
					<button type="button" class="btn_m confirm mb5" id="btn_Save">저장</button>
					<button type="button" class="btn_m search" id="btn_Complete">완료</button>
				</div>
			</div>
            </div>            
        </section>
    </div>
    <input type="hidden" id="status">
    <input type="hidden" id="qaaId">
    <input type="hidden" id="sheetId">
    <input type="hidden" id="modYn">
</body>
</html>