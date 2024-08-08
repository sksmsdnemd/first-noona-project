<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String recTableType = Globals.REC_TABLE_TYPE(); 
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
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
		border-bottom : 2px solid #898b90;
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
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<script type="text/javascript">
var recTableType = '<%=recTableType%>';
var fvTimesId='', fvAgentId='', fvRecordId='';
var fvSheetkey='', fvQaValueStatus ='';
var sRecTableNm = "";

var interval;
var isTimeLimit = 3;
var isTimeChk = 0;
var chkCompleteArr = new Array();

var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var playerKind 	= loginInfo.SVCCOMMONID.rows.playerKind;

var saveCode = "";

//Step1 검색 파라메터
var sTimesId, sTimesNm, sQaaId, sQaaNm, sCurrIndex;
$(document).ready(function() {
	top.windowStepFlag = true;
	top.windowStepVal = "QA2010M03"; 
	
	//테스트용 preloading. 실사용시 setTimemout 제거
	fvAgentId = $('#fvAgentId').val();   
	fvAgentNm = $('#fvAgentNm').val();
	fvTimesId = $('#fvTimesId').val();   
	//sRecTableNm = argoQaTimesRecTable(fvTimesId, recTableType);
	fvRecordId = $('#fvRecordId').val();  
	fvSheetkey = $('#fvSheetkey').val();  
	sTimesId = $('#sTimesId').val();    
	sTimesNm = $('#sTimesNm').val();    
	sQaaId = $('#sQaaId').val();      
	sQaaNm = $('#sQaaNm').val(); 
	sCurrIndex = $('#sCurrIndex').val();  
	disable = $('#disable').val();
	
	
	
	
	
	sRecTableNm = argoQaTimesRecTable(fvTimesId, recTableType);
	fnInitCtrl();
	fnShowTooltip();
});

function fnIncreaseValue() {
	isTimeChk++;
}

function fnIntervalIncrease(){
	interval = setInterval(fnIncreaseValue, 1000);
}

function fnIncreaseStart(obj){
	if(chkCompleteArr.length == 0){
		chkCompleteArr.push(obj.attr("name"));
		fnIntervalIncrease();
	}else{
		var isStringFound = $.inArray(obj.attr("name"), chkCompleteArr) !== -1;
		// 결과 출력
		if (!isStringFound){
			if(isTimeLimit-1 >= isTimeChk){
				argoAlert("연속해서 평가할 수 없습니다.<br>" + isTimeLimit + "초 이후 다시 시도해 주세요.");
				obj.prop("checked", false);
				clearInterval(interval);
				isTimeChk = 0;
				fnIntervalIncrease();
			}else{
				chkCompleteArr.push(obj.attr("name"));
				clearInterval(interval);
				isTimeChk = 0;
				fnIntervalIncrease();
			}
		}else{
			//isTimeChk = 0;
		}
	}
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
			current_row.attr("rowspan",Number(currentRow_num) + 2);
			$("." + selector).show();
		} else {
			$(this).addClass("on");
			parent_row.attr("rowspan",Number(parentRow_num)- Number(currentRow_num));
			current_row.attr("rowspan", 2);
			$("." + selector).hide();
		}
		check_gridScroll();
	});
}

function fnInitCtrl() {
	
	if(argoNullConvert(fvSheetkey) == ""){
		fnQaInProgress();	
	}
	
	
	fnDetailInfo();
	
	$("#btn_Save").click(function() {
		//fnSave("10");
		saveCode = "10";
		fnQaInProgressAndSave();
	});

	$("#btn_Complete").click(function() {
		//fnSave("40");
		saveCode = "40";
		fnQaInProgressAndSave();
	});
	
	$("#btn_Step2").click(function(){
		fnPageMove();
	});

	//접기/펴기 버튼
	$(".btn_avShowHide").on("click", function() {
		if ($(this).hasClass("on")) {
			$(this).removeClass("on");
			$(".sub_contents").removeClass("hidden_cont");
			//추가 
			var gh = $('.grid_resizeArea').height() - 193;
			$('.grid_resizeArea').height(gh);
		} else {
			$(this).addClass("on");
			$(".sub_contents").addClass("hidden_cont");
			//추가 
			var gh = $('.grid_resizeArea').height() + 193;
			$('.grid_resizeArea').height(gh);
		}
		check_gridScroll();
	});
	
	if(disable!='false'){
		argoDisable(true, 'btn_Complete, btn_Save');
	};
	
	$.fn.hasScrollBar = function() {
		return (this.prop("scrollHeight") == 0 && this.prop("clientHeight") == 0)
				|| (this.prop("scrollHeight") > this.prop("clientHeight"));
	};
}

function hasScrollBar(obj){
	return (obj.prop("scrollHeight") == 0 && obj.prop("clientHeight") == 0)|| (obj.prop("scrollHeight") > obj.prop("clientHeight"));
}

function fnShowTooltip(){
	$(".tooltip_l").tooltip({
		position: {
			my: "left top",
			at: "right+5 top+13",
			collision: "none"
		}
	});

	$(".tooltip_r").tooltip({
		position: {
			my: "right top",
			at: "left+10 top+13",
			collision: "none"
		}
	});

	//Step 툴팁 자동실행
	$(".btn_stepPrev ").trigger("mouseover").addClass("on");
	$(".btn_stepNext ").trigger("mouseover").addClass("on");
	
	setTimeout(function(){
		$(".btn_stepPrev ").trigger("mouseout").removeClass("on");
		$(".btn_stepNext ").trigger("mouseout").removeClass("on");
	}, 1500);
}


// 다른 평가자가 평가하였는지 확인
function fnQaInProgress() {
	try {
		var param = {
			timesId : fvTimesId,
			agentId : fvAgentId
		};
		var multiService = new argoMultiService(fnCallbackQaInProgress);
		multiService.argoList("QA", "SP_QA2010M03_08", "__", param);
		multiService.action();
	} catch (e) {
		console.log(e);
	}
}

function fnCallbackQaInProgress(data, textStatus, jqXHR) {
	try {
		if (data.isOk()) {
			if(data.getRows(0).length != 0){
				argoAlert('warning', "해당 상담사는 이미 평가를 진행한 QAA가 존재합니다.<br><br>진행한 평가자 정보 : " + data.getRows(0)[0].qaaInfo + "<br>다른 피평가자를 선택하여 주십시오.", '','fnStep1Move();');
			}
		}
	} catch (e) {
		argoAlert(e);
	}
}


function fnQaInProgressAndSave() {
	try {
		var param = {
			timesId : fvTimesId,
			agentId : fvAgentId
		};
		var multiService = new argoMultiService(fnCallbackQaInProgressAndSave);
		multiService.argoList("QA", "SP_QA2010M03_08", "__", param);
		multiService.action();
	} catch (e) {
		console.log(e);
	}
}

function fnCallbackQaInProgressAndSave(data, textStatus, jqXHR) {
	try {
		if (data.isOk()) {
			if(data.getRows(0).length != 0){
				argoAlert('warning', "해당 상담사는 이미 평가를 진행한 QAA가 존재합니다.<br><br>진행한 평가자 정보 : " + data.getRows(0)[0].qaaInfo + "<br>다른 피평가자를 선택하여 주십시오.", '','fnStep1Move();');
			}else{
				fnSave(saveCode);
			}
		}
	} catch (e) {
		argoAlert(e);
	}
}


// 검색
function fnSearchList() {
	try {
		var param = {
			sheetId : $("#sheetId").val(),
			sheetkey : fvSheetkey,
			timesId : fvTimesId,
			agentId : fvAgentId
		};

		var multiService = new argoMultiService(fnCallbackSearch);
		multiService
		.argoList("ARGOCOMMON", "SP_UC_GET_QA_SHEET_SUMMARY", "__", param)		//평가표 요약
						.argoList("ARGOCOMMON", "SP_UC_GET_QA_VALUE_DETAIL", "__", param)
						.argoList("QA", "SP_QA2010M03_04", "__", param)
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
			fnSetTable3(data.getRows(2));
		}
	} catch (e) {
		argoAlert(e);
	}
}

//평가 점수 그리드 
function fnSetTable1(dataRow) {
	var valueScore = 0;
	var objHtml = '';
	var checkYn =0;
	$.each(dataRow,function(index, row) {
		objHtml += '<tr onclick="fnSetScrollPosition('+(index)+')" class="trbg '+(row.score==0 ? "":"bgwhite")+'" >'
							+ '<td style="min-width : 20px;">'+ (index + 1)+ '</td>'
							+ '<td class="txt_l">'+ (row.itemNm)+ '</td>'
					+ '</tr>';
		valueScore += row.score;
		if(row.checkYn == 1){
			checkYn = row.checkYn; 
		}
	});
	
	$("#valueScore").html(valueScore.toFixed(2));
	$("#table1").append(objHtml);
}

function fnSetScrollPosition(index){
	var offset = $("#table_List").offset().top; // table_List top 위치
	var top=$(".pos-relative:eq("+(index+1)+")").offset().top; // 선택한 소분류 top 위치
	$('#tableScore').stop().animate( { scrollTop : top-offset }); // 애니메이션 효과
	
	$(".trbg").removeClass("bgblue");
	$(".trbg:eq("+(index)+")").addClass("bgblue");
}


function fnCheckYn(index, id){
	if($("#"+id).is(":checked")){
		$('#score_List tr').eq(index).find('input[name=checkYn]').val(0);
	}else{
		$('#score_List tr').eq(index).find('input[name=checkYn]').val(1);
	}
}

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
	
	var majorMinorCd = "";
	$.each(dataRow,function(index, row) {
 		if(majorCd!=row.majorCd){
 			majorCd = row.majorCd;
 			minorCd = row.minorCd;
 			cnt++;
 			dataCode = row.majorCd+row.minorCd;
 			//jslee
 			
 			//var trStyle = "border-top:2px solid #898b90";
 			
 			//objHtml += "<tr class='group"+majorCd+minorCd+"' style='"+trStyle+"'>"
 			var pxl = "1.5px";
 			if(index != 0){
 				pxl = "2px";
 			}
 			
 			objHtml += "<tr class='group"+majorCd+minorCd+"' style='border-top:"+pxl+" solid #898b90'>"
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
												+'<input type="checkbox" onclick="fnIncreaseStart($(this));" id="check_'+ majorCd+minorCd+ '_'+ (j + 1)+ '" name="group'+ majorCd+minorCd+ '"  class="pr0" value="'+ sebuCd[j]+ ','+ sebuCdScore[j]+','+index+','+row.majorCd+','+row.minorCd+','+cnt+'"       '+ (sebuCd[j] == row.selSebuCd ? "checked": "")+ '>'
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
 		     			objHtml += "<tr class='group"+majorCd+minorCd+"' style='border-top:2px solid #898b90'>"
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
 															+'<input type="checkbox" onclick="fnIncreaseStart($(this));" id="check_'+ majorCd+minorCd+ '_'+ (j + 1)+ '" name="group'+ majorCd+minorCd+ '"  class="pr0" value="'+ sebuCd[j]+ ','+ sebuCdScore[j]+','+index+','+row.majorCd+','+row.minorCd+','+cnt+'"       '+ (sebuCd[j] == row.selSebuCd ? "checked": "")+ '>'
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
 						
 						
 						
 						//jslee
 			 			
 			 			//var trStyle = "border-top:2px solid #898b90";
 			 			
 			 			//objHtml += "<tr class='group"+majorCd+minorCd+"' style='"+trStyle+"'>"
 						
 			 			var trBoldStyle = "border-top:1px solid #898b90";
 			 			//debugger;
 			 			/* if(majorMinorCd != "" && majorMinorCd != majorCd+minorCd){
 			 				trBoldStyle = "border-bottom:2px solid #898b90";
 			 			}else{
 			 				trBoldStyle = "border-bottom:1px solid #898b90";
 			 			}
 			 			majorMinorCd = majorCd+minorCd; */
 			 			
 			 			//= majorCd + minotCd
 						
 						objHtml+= "<tr class='hidden_row item"+majorCd+minorCd+"' style='"+trBoldStyle+"'>"
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
	console.log("fvQaValueStatus : " + fvQaValueStatus);
	fnDisabled(fvQaValueStatus);
	fnCheckboxInit();
	
	$(".textarea-resize").trigger('click');
}

//상단 상세보기
function fnDetailInfo() {
	if (fvSheetkey.length < 10)
		fvSheetkey = '';
	var param = {
		"timesId" : fvTimesId,
		"sheetkey" : fvSheetkey,
		"agentId" : fvAgentId,
		"recordId" : fvRecordId,
		"tableNm" : sRecTableNm
	};
	argoJsonSearchOne('QA', 'SP_QA2010M03_01', 's_', param, fnDetailInfoCallback);
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
 		if(score==0){
			$(".trbg:eq("+(index)+")").removeClass("bgwhite");
		}else{ 
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
 		$("#valueScore").html(sumScore.toFixed(2));
		
		});
	 
	// 평가 점수 세팅
	var trSize = $('#data_List tr').size();
	var sumScore = 0 ;
	for (var i = 0; i < trSize; i++) {
		var score= $('#data_List tr').eq(i).find('#selScore').html();
		sumScore +=(score != null ? Number(score) : 0);
	}
	$("#valueScore").html(sumScore.toFixed(2));
	 
}

// 상세정보 세팅
function fnDetailInfoCallback(data, textStatus, jqXHR) {
	try {
		if (data.isOk()) {
			var info = data.getRows();
			if(info.recordId!=null){
				$("#timesNm").html(info.timesNm);
				$("#timesNmMemo").html(info.timesNm);
				$("#sheetNm").html(info.sheetNm);
				$("#sheetId").val(info.sheetId);
				$("#qaEvalType").html(info.qaEvalType);
				$("#valueFrmTo").html(info.valueFrmDt + ' ~ ' + info.valueEndDt);
				//$("#recordId").html('<img src="../images/speak_up.png" onclick="argoRecPlay(\''+info.recKey+'\' , ' +playerKind+ ')">'+'&nbsp&nbsp&nbsp'+info.recKey);
				//$("#recordId").html('<img src="../images/speak_up.png" onclick="argoRecPlay(\''+info.recordId+'\' , \'' +playerKind +'\' , \'' +sRecTableNm+'\')">'+'&nbsp&nbsp&nbsp'+info.recordId);
				$("#recordId").html('<img src="../images/speak_up.png" onclick="argoRecPlay(\''+info.recordId+'\' , \'' +playerKind +'\' , \'' +sRecTableNm+'\')">'+'&nbsp&nbsp&nbsp');
				$("#sttId").html('<img src="../images/icon_code.png" onclick="argoTaPopup(\''+info.recordId+'\', \'' +sRecTableNm+'\')">'+'&nbsp&nbsp&nbsp');
				$("#valueYmd").html(info.valueYmd);
				$("#qaValueStatus").html(info.qaValueNm);
				$("#deptInfo").html(info.deptInfo);
				$("#agentNm").html(info.agentNm +' ('+info.agentSabun+')');
				$("#recYmd").html(argoNullConvert(info.recYmd));
				
				var recTime = argoNullConvert(info.starttime)==""?"":info.starttime + ' ~ ' + info.endtime;
				$("#rectime").html(recTime);
				$("#talkTm").html(argoNullConvert(info.talkTm));
				$("#totalComment").val(info.totalComment);
				
				// 평가일자 로직 추가  20221130 gyu
				if(info.modYn == 0) {
					argoDisable(true, 'btn_Complete, btn_Save');
				}

				if(info.valueMembNm!=null){
					$("#valueMemb").html(info.valueMembNm +' ('+info.valueMemb+')');
					$("#valueMembMemo").html(info.valueMembNm +' ('+info.valueMemb+')');
				}
				fvQaValueStatus = info.qaValueStatus;
				fnSetRecordInfo(info);
			}
				fnSearchList();
		}
	} catch (e) {
		console.log(e);
	}
}

var dataArray = new Array();
function fnSetRecordInfo(data){
	var agentId = argoNullConvert(data.agentId);
	var recordId = argoNullConvert(data.recordId);
	var recYmd = argoNullConvert(data.recYmd).replace(/\-/g, "");
	var startTm = argoNullConvert(data.starttime).replace(/\:/g, "");
	var endTm = argoNullConvert(data.endtime).replace(/\:/g, "");
	var talkTm = argoNullConvert(data.talkTm).replace(/\:/g, "");
	dataArray.push({agentId : agentId, recordId : recordId, startTm : startTm, endTm : endTm, recYmd : recYmd, talkTm : talkTm});
}

function check_gridScroll() {
	$(".table_list").each(
		function(i) {
			if (hasScrollBar($(this))) {
				var blank_box = '<span class="blank_box" style="width:17px;"></span>';
				var length = $(this).closest(".table_grid").find(".blank_box").length;
				if (length < 1) {
					$(this).prev(".table_head").addClass("use_pr").parent().append(blank_box);
				}
			} else {
				$(this).prev(".table_head").removeClass("use_pr").parent().find(".blank_box").remove();
			}
		});
}

var fvQaValueStatus;
//저장 및 완료
function fnSave(qaValueStatus) {
	
	fvQaValueStatus=qaValueStatus;
	var majorCd = ''; // 대분류코드
	var minorCd = '' // 소분류코드

	var sheetId = argoGetValue("sheetId");
	var agentId = fvAgentId;
	var gbn = "C"
	var sheetkey = "";

	if (fvSheetkey.length > 10) {
		gbn = "U";
		sheetkey = fvSheetkey;
	}
	
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
			"sheetkey"      	: sheetkey,
			"timesId"       		: fvTimesId,
			"recordId"      		: fvRecordId,
			"sheetId"       		: sheetId,
			"qaValueStatus" 	: qaValueStatus,
			"agentId"       	: agentId,
			"totalComment"  : $("#totalComment").val() ,
		}
		argoJsonSearchOne('QA', 'SP_QA2010M03_05', '__', param, function(data, textStatus, jqXHR) {
			fnSaveDetail(data.getRows().sheetKey);
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
	var j=0;
	try {

		var multiService = new argoMultiService(fnCallbackSave(sheetkey));
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
					var checkYn = $('#score_List tr').eq(j).find('input[name=checkYn]').val();
					if(checkYn!=1){
						checkYn=0;
					}
					
					j++;
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
							sheetId :argoGetValue("sheetId"),
							checkYn : checkYn
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

function fnSetTable3(dataRow) {
	var avgScore = 0;
	var objHtml = '';
	$.each(dataRow, function(index, row) {
		objHtml += '<tr>' + '<td>' + (index + 1) + '</td>' 
		+ '<td class="txt_l">' + (row.timesNm) + '</td>'
		+ '<td>' + (row.avgScore) + '</td>' + '</tr>';
		avgScore += Number(row.avgScore);
	});

	var valueScore = (dataRow.length == 0 ? 0 : avgScore / dataRow.length);
	$("#avg_score").html("평균 " + valueScore.toFixed(2));
	$("#table3").append(objHtml);
}

function fnCallbackSave(sheetkey) {
	if(fvQaValueStatus==10){
		fvSheetkey=sheetkey;
		argoAlert("저장되었습니다.");
		$("#qaValueStatus").html("저장");
		return ;
	};
	var sheetId = argoGetValue("sheetId");
	var param ={sTimesId : sTimesId 
						,sTimesNm : sTimesNm
						,sQaaId:sQaaId
						,sQaaNm:sQaaNm
						,currIndex:sCurrIndex
						,timesId:fvTimesId
						,searchYn:"1"
						,disable:disable
						}
	var url = "QA2010M01F.do";
	fnDynamicForm(param,url);
}


// 상태값에 따른 disabled 처리
function fnDisabled(qaValueStatus){
	if(qaValueStatus!=null&&qaValueStatus!='10'&&qaValueStatus!='20'&&qaValueStatus!='90')	{  
		$("input:checkbox").attr("disabled",true);
	
		//$( '#btn_Save' ).unbind( 'click' );
		//$( '#btn_Complete' ).unbind( 'click' );
		$( '#btn_Save' ).attr("disabled", true);
		$( '#btn_Complete' ).attr("disabled", true);
		$( 'label' ).unbind( 'click' );
		$("textarea").attr("readonly",true);
		$("#ip_Memo").attr("readonly",false);
	}
}

function fnPageMove(){
	var param ={
						timesId:fvTimesId
						,agentId:fvAgentId
						,agentNm:fvAgentNm
						,currIndex:sCurrIndex
						,sQaaId:sQaaId
						,sQaaNm:sQaaNm
						,sTimesId: sTimesId
						,sTimesNm : sTimesNm
						,disable:disable
						}
	var url = "QA2010M02F.do";
	fnDynamicForm(param, url);
}

/* 신규추가  */
$(window).on("resize", function(){
	var cont = $('.sub_wrap').height();
	var bt = $(".comment_area ").height();
	var vh = 0;
	($(".btn_avShowHide").hasClass("on")) ?  vh = 131 : vh =286 ;
	var h = cont - bt - vh;
	var btnH = cont - bt - 52;
// 		$('.grid_resizeArea').height(h);
	$(".drag_bar").css("top", btnH);
})

function dragResize(){
	var h = $('.drag_bar').css('top');
	var c = $('.sub_wrap').height();
	var vh = 0;
	h = parseInt(h);				
	var bH = c-h-59;		
	($(".btn_avShowHide").hasClass("on")) ?  vh = 85 : vh =276 ;
	$('.grid_resizeArea').height(h - vh);
	$('.textarea_resize').height(bH);
}

function textareaResize(obj){
	$(this).css('height','auto');
	//obj.style.height = "1px";
	obj.style.height = ((obj.scrollHeight+2))+"px";
	
}

function fnUseTab(obj){
	if(event.keyCode == 9){
		obj.select();
		//this.select()
	}
}

function fnEdu(){
	gPopupOptions = {"pDataArray" : dataArray};
	argoPopupWindow('콜 등록', 'QA2010S01F.do', '550', '345');
}

/*
	완료시 전체 체크 했는지 여부 확인 2018.11.01 요청자 - 이선영 
	작업자 jin
*/
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

function fnStep1Move(){
	var param ={sTimesId : sTimesId 
				,sTimesNm : sTimesNm
				,sQaaId:sQaaId
				,sQaaNm:sQaaNm
				,currIndex:sCurrIndex
				,timesId:fvTimesId
				,searchYn:"1"
				,disable:disable
			}
	var url = "QA2010M01F.do";
	fnDynamicForm(param,url);
}
</script>
</head>

<body>

	<%-- 비즈니스 로직 변경으로 인한 20220617 GYU --%>
	<input type="hidden" id ='fvTimesId' value="<c:out value="${timesId}"/>">
	<input type="hidden" id ='fvAgentId' value="<c:out value="${agentId}"/>">
	<input type="hidden" id ='fvAgentNm' value="<c:out value="${agentNm}"/>">
    <input type="hidden" id ='fvRecordId' value="<c:out value="${recordId}"/>">
    <input type="hidden" id ='fvSheetkey' value="<c:out value="${sheetkey}"/>">
    <input type="hidden" id ='sTimesId' value="<c:out value="${sTimesId}"/>">
    <input type="hidden" id ='sTimesNm' value="<c:out value="${sTimesNm}"/>">
    <input type="hidden" id ='sQaaId' value="<c:out value="${sQaaId}"/>">
    <input type="hidden" id ='sQaaNm' value="<c:out value="${sQaaNm}"/>">
    <input type="hidden" id ='sCurrIndex' value="<c:out value="${currIndex}"/>">
    <input type="hidden" id ='disable' value="<c:out value="${disable}"/>">

	<div class="sub_wrap">
		<div class="location">
			<span class="location_home">HOME</span><span class="step">통화품질(QA)</span>
			<span class="step">통화품질평가</span><strong class="step">통화품질평가</strong>
		</div>
		<section class="sub_contents">
			<div class="step_area">
				<a href="#l" class="btn_stepPrev tooltip_l" title="녹음파일 조회" id="btn_Step2">녹음파일 조회</a>
				<div class="step_view step3">
					<ul>
						<li id="step1" onclick="fnStep1Move();"><em class="num">1</em>
							<p class="step">STEP 01</p>
							<p class="title">배정인원 조회</p></li>
						<li id="step2" onclick="fnPageMove();"><em class="num">2</em>
							<p class="step">STEP 02</p>
							<p class="title">녹음파일 조회</p></li>
						<li class="on"><em class="num">3</em>
							<p class="step">STEP 03</p>
							<p class="title">통화품질평가</p></li>
					</ul>
				</div>
			</div>
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
							<th>평가표</th>
							<td id="sheetNm"></td>
							<th>평가구분</th>
							<td id="qaEvalType"></td>
							<th>평가기간</th>
							<td id="valueFrmTo"></td>
							<th>평가일자</th>
							<td id="valueYmd"></td>
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
							<th>평가상태</th>
							<td id="qaValueStatus"></td>
							<th></th>
							<td id=""></td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="h367 pos-relative grid_resizeArea" style="height: calc(100% - 300px);">
				<div class="sub_l fix210">
					<div class="btn_topArea fix_h25"></div>
					<div class="grid_area h47 pt0">
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
										<col width="15%">
										<col width="70%">
										<%-- <col width="15%"> --%>
									</colgroup>
									<tbody id="table1">
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
				<div class="sub_c plr210">
					<div class="btn_topArea fix_h25 avBtn_area">
						<a href="#" class="btn_avShowHide"></a>
					</div>
					<div class="grid_area h47 pt0">
						<div class="table_grid average ct">
							<div class="table_head">
								<table id="table_header">
									
								</table>
							</div>
							<div class="table_list" id="tableScore">
								<table id="data_List">
									<tbody id="table_List">
										<!-- ITEM -->
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
				<div class="sub_r fix210 pos-absolute">
					<div class="btn_topArea fix_h25"></div>
					<div class="grid_area h47 pt0">
						<div class="table_grid average">
							<div class="table_head">
								<table>
									<colgroup>
										<col width="100%">
									</colgroup>
									<thead>
										<tr>
											<th><p>이전 평가점수</p> <span class="av_score" id="avg_score"></span></th>
										</tr>
									</thead>
								</table>
							</div>
							<div class="table_list">
								<table>
									<colgroup>
										<col width="10%">
										<col width="55%">
										<col width="45%">
									</colgroup>
									<tbody id="table3">
									</tbody>
								</table>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="drag_bar"></div>
            <div class="comment_area bgDrag pt15 mt0" style="margin-top: 0px; bottom: 15px;">
				<div class="comment_title">종합평가결과</div>
				<div class="comment_txt">
					<%-- <textarea id="totalComment" name="" rows="" class="textarea_resize"onclick='textareaResize(this)' onKeydown='textareaResize(this)'></textarea>--%>
					<textarea id="totalComment" name="" rows="" style="height: 70px;"></textarea>
				</div>
				<div class="comment_btns mt15">
					<button type="button" class="btn_m confirm mb5" id="btn_Save" data-grant="R">저장</button>
					<button type="button" class="btn_m search" id="btn_Complete" data-grant="R">완료</button>
				</div>
			</div>
			<!-- 필요한 정보 Hidden -->
			<input type="hidden" id="sheetId">
			
			<form name="form1" method="POST">
				<input type="hidden" name="sheetKey"/>
				<input type="hidden" name="notiYn"/>
				<input type="hidden" name="confirmYn"/>				
			</form>
		</section>
	</div>
</body>
</html>