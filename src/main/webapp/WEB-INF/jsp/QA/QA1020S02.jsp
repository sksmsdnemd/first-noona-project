<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<script type="text/javascript">
var fvMinorCd='',fvMajorCd='';
var formGbn = parent.formGbn;
	$(function(){
		fnSetDetailCnt();
		$(document).on("change",".chkbox",function(){
			if( this.checked ){
				$(this).closest("tr").find(".txt_l textarea").removeAttr("readonly");
				$(this).closest("tr").find(".txt_c").removeAttr("readonly");
				$(this).closest("tr").find(".btn_plus").removeAttr("disabled");
				$(this).closest("tr").find(".btn_minus").removeAttr("disabled");
			}else{
				$(this).closest("tr").find(".txt_l textarea").attr({"readonly":"readonly"});
				$(this).closest("tr").find(".txt_c").attr({"readonly":"readonly"});
				$(this).closest("tr").find(".btn_plus").attr({"disabled":"disabled"});
				$(this).closest("tr").find(".btn_minus").attr({"disabled":"disabled"});
			}
			fnMaxScore();
		});
		// 호출화면의 팝업 옵션 정보 
		sPopupOptions2 = parent.gPopupOptions2 || {};
		sPopupOptions2.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
	  	fnInitCtrl_QA1020S02();
	  	
	  	$("#btnDel").click(function(){
	  		try{
	  			if(sPopupOptions2.valueYn == '1'){
					argoAlert("해당 평가표는 평가여부가 진행중으로 삭제 하실 수 없습니다.");
					return;
				}
		  		if($('#ip_MajorCd option:selected').val() == ''){
		  			argoAlert("대분류를 선택하세요");
					return;
		  		}
		  		if($('#ip_MinorCb option:selected').val() == ''){
		  			argoAlert("소분류를 선택하세요");
					return;
		  		}
		  		argoConfirm("해당 평가내용을 모두 삭제 하시겠습니까?", function(){
			  		argoJsonCallSP('QA', 'SP_QA1020S02_03', '__', {"cudGubun":"D","sheetId":sPopupOptions2.sheetId,"sheetText":"","majorCd":$('#ip_MajorCd option:selected').val(),"minorCd":$('#ip_MinorCb option:selected').val(), "qaSebuCd":"", "score":"", "plusMinus":""}, function (data, textStatus, jqXHR){
						if(data.isOk()) {
							argoAlert('warning', '평가내용이 삭제되었습니다','', 'parent.fnSearchList02('+sPopupOptions2.sheetId+'); argoPopupClose();');
							//fnFrmClear();
							
						}
					});
				});
	  		}catch(e){
	  			console.log(e);
	  		}	
		});
	  	
		$("#btnSave").click(function(){
			try{
				if($('#ip_MajorCd option:selected').val() == ''){
		  			argoAlert("대분류를 선택하세요");
					return;
		  		}else{
		  			sMajorCd = $('#ip_MajorCd option:selected').val();
		  		}
		  		if($('#ip_MinorCb option:selected').val() == ''){
		  			argoAlert("소분류를 선택하세요");
					return;
		  		}else{
		  			sMinorCd = $('#ip_MinorCb option:selected').val();
		  		}
		  		
		  		if($('#ip_score_0').val() == ''){
		  			argoAlert("배점을 입력하세요");
					return;
		  		}
		  		
		  		var multiService = new argoMultiService(fnCallbackSave);
		  		
		  		plusMinus = $("input:checkbox[id='ip_PlusMinus']").prop("checked") == true ? '1' : '0';
		  		param = {
		  				"cudGubun":sPopupOptions2.cudGubun
		  				, "sheetId":sPopupOptions2.sheetId
		  				, "sheetText":$("textarea#ip_sheetText_0").val()
		  				, "majorCd":sMajorCd
		  				, "minorCd":sMinorCd
		  				, "qaSebuCd":"0"
		  				, "score":$('#ip_score_0').val()
		  				, "plusMinus":plusMinus
		  		}
		  		multiService.argoUpdate("QA","SP_QA1020S02_03","__", param);
		  		
		  		var saveFlag = false;
		  		var table = document.getElementById("detailList");
				var rowsCount = table.rows.length;
				var sebuCd = new Array();
				sebuCd.push("0");
				for(var i=0; i<rowsCount; i++){
					if($("input:checkbox[id='ip_useYn_"+formGbn[i]+"']").prop("checked") == true){
						if($("#ip_score_"+formGbn[i]).val() == ''){
							argoAlert(formGbn[i]+"배점을 입력하세요");
							return;
						}
						if(Number($("#ip_score_"+formGbn[i]).val()) > Number($('#ip_score_0').val())){
							argoAlert(formGbn[i]+"평가배점이 "+$('#ip_score_0').val()+"점 보다 큽니다");
							return;
						}
						if($("textarea#ip_sheetText_"+formGbn[i]).val() == ''){
							argoAlert(formGbn[i]+"평가내용을 입력하세요");
							return;
						}
						sebuCd.push(formGbn[i]);					
						saveFlag=true;
				  		multiService.argoUpdate("QA","SP_QA1020S02_03","__", {"cudGubun":"U", "sheetId":sPopupOptions2.sheetId, "sheetText":$("textarea#ip_sheetText_"+formGbn[i]).val(), "majorCd":sMajorCd, "minorCd":sMinorCd, "qaSebuCd":formGbn[i], "score":$("#ip_score_"+formGbn[i]).val(), "plusMinus":plusMinus});
			  		}
				}	
				
				
				multiService.argoUpdate("QA","SP_QA1020S02_04","__", {"sheetId":sPopupOptions2.sheetId, "majorCd":sMajorCd, "minorCd":sMinorCd, "qaSebuCd": sebuCd.toString(), gubun : "START"});
				multiService.argoUpdate("QA","SP_QA1020S02_04","__", {"sheetId":sPopupOptions2.sheetId, "majorCd":sMajorCd, "minorCd":sMinorCd, "qaSebuCd": sebuCd.toString(), gubun : "END"});
				if(saveFlag) multiService.action();
				else argoAlert("평가항목을 입력해주세요.");
						  		
			}catch(e){
				console.log(e);
			}			
		});
		
		
	});
	
	function fnCallbackSave(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	argoAlert('warning', '변경내역을 저장 하였습니다.','', 'parent.fnSearchList02('+sPopupOptions2.sheetId+'); argoPopupClose();');
		    }
		} catch(e) {
			console.log(e);    		
		}
	}
	
	function fnInitCtrl_QA1020S02() {
		if(sPopupOptions2.cudGubun == 'U'){ //평가내용 더블클릭 (편집일경우)
			argoCbCreate("ip_MajorCd", "QA", "SP_QA1020S02_01", {"gbn":"A", "majorCd":"", "sheetId":sPopupOptions2.sheetId, "partCd":sPopupOptions2.partCd},{"selectValue":sPopupOptions2.majorCd, "text":'<선택>', "value":''});
			argoCbCreate("ip_MinorCb", "QA", "SP_QA1020S02_01", {"gbn":"B", "majorCd":sPopupOptions2.majorCd, "sheetId":sPopupOptions2.sheetId, "partCd":sPopupOptions2.partCd},{"selectValue":sPopupOptions2.minorCd, "text":'<선택>', "value":''});
			argoCbCreate("ip_PartCd", "ARGOCOMMON", "SP_UC_GET_CMCODE_01", {sort_cd:"QA_PART_CD"}, {"selectValue":sPopupOptions2.partCd, "text":'<선택>', "value":''});
			fvMajorCd=sPopupOptions2.majorCd;
			fvMinorCd=sPopupOptions2.minorCd;
			fnFrmDataIns();
		}else{ //추가일경우
			argoCbCreate("ip_MajorCd", "QA", "SP_QA1020S02_01", {"gbn":"A", "majorCd":"", "sheetId":sPopupOptions2.sheetId, "partCd":sPopupOptions2.partCd},{"selectIndex":0, "text":'<선택>', "value":''});
			argoCbCreate("ip_PartCd", "ARGOCOMMON", "SP_UC_GET_CMCODE_01", {sort_cd : 'QA_PART_CD'}, {"selectIndex" : 0,"text" : '<선택>',"value" : ''}); 
		}
		
		$('#ip_PartCd').change(function(){
			argoCbCreate("ip_MajorCd", "QA", "SP_QA1020S02_01", {"gbn":"A", "majorCd":"", "sheetId":sPopupOptions2.sheetId, "partCd":$('#ip_PartCd option:selected').val()},{"selectIndex":0, "text":'<선택>', "value":''});
			argoCbCreate("ip_MinorCb", "QA", "SP_QA1020S02_01", {"gbn":"B", "majorCd":$('#ip_MajorCd option:selected').val(), "sheetId":sPopupOptions2.sheetId},{"selectIndex":0, "text":'<선택>', "value":''});
	    });
		
		$('#ip_MajorCd').change(function(){
			argoCbCreate("ip_MinorCb", "QA", "SP_QA1020S02_01", {"gbn":"B", "majorCd":$('#ip_MajorCd option:selected').val(), "sheetId":sPopupOptions2.sheetId},{"selectIndex":0, "text":'<선택>', "value":''});
	    });
		
		$('#ip_MinorCb').change(function(){
			fnFrmDataChk();
	    });
		
		if(sPopupOptions2.valueYn==1){
			argoDisable(true, "btnDel");
			argoDisable(true, "btnSave")
		}
		
		if(sPopupOptions2.insYn){
			$("#btnDel").attr("style","display:none");
		}
	}
	
	//데이터 삽입
	function fnFrmDataIns(){
		argoJsonSearchList('QA','SP_QA1020S02_02','__', {"sheetId":sPopupOptions2.sheetId,"majorCd":$('#ip_MajorCd option:selected').val(),"minorCd":$('#ip_MinorCb option:selected').val()}, function (data, textStatus, jqXHR){
			try{
				
				if(data.isOk()){
					var scoreTotal = 0;
					
					argoSetValue("detailCnt", data.getRows().length-1);
					
					
					for(var i=0; i<data.getRows().length; i++){
						scoreTotal = eval(scoreTotal+data.getRows()[i].score);
						var gbn = data.getRows()[i].qaSebuCd; 
						switch (data.getRows()[i].qaSebuCd) {
						  case "0" : 
							  $("textarea#ip_sheetText_0").val(data.getRows()[i].sheetText);
							  $("#ip_score_0").val(data.getRows()[i].score);
							  if(data.getRows()[i].plusMinus == '1') $("input:checkbox[id='ip_PlusMinus']").prop("checked", true);
						  break;
						  case gbn : // A,B,C,D,E
							  $("textarea#ip_sheetText_"+gbn).val(data.getRows()[i].sheetText);
							  $("#ip_score_"+gbn).val(data.getRows()[i].score);
							  
							  if(data.getRows()[i].sheetText.length > 0){
								  $("input:checkbox[id='ip_useYn_"+gbn+"']").prop("checked", true);
								  $("textarea#ip_sheetText_"+gbn).removeAttr("readonly");
								  $("#ip_score_"+gbn).removeAttr("readonly");
								  $(".score_"+gbn).removeAttr("disabled");
							  }else{
								  $("input:checkbox[id='ip_useYn_"+gbn+"']").prop("checked", false);
							  }
						  break;
						  default : break;
						}
					}
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}
	
	function fnFrmDataChk(){
		if((fvMinorCd!=$('#ip_MinorCb option:selected').val())||(fvMajorCd!=$("#ip_MajorCd option:selected").val())){
			argoJsonSearchList('QA','SP_QA1020S02_02','__', {"sheetId":sPopupOptions2.sheetId,"majorCd":$('#ip_MajorCd option:selected').val(),"minorCd":$('#ip_MinorCb option:selected').val()}, function (data, textStatus, jqXHR){
				try{
					if(data.getRows().length>0) {
							argoAlert("기존에 등록되어있는 항목입니다.");
							argoSetValue("ip_MinorCb","");
							return;
					}
				} catch(e) {
					console.log(e);			
				}
			});
		}
	}
	
	//폼초기화
	function fnFrmClear(){
		$("#ip_score_0").val("");
		$("input:checkbox[id='ip_PlusMinus']").prop("checked", false);
		$("textarea#ip_sheetText_0").val("");
		
		for(var i=0; i<5; i++){
			$("textarea#ip_sheetText_"+formGbn[i]).val("");
			$("textarea#ip_sheetText_"+formGbn[i]).attr({"readonly":"readonly"});
			$("#ip_score_"+formGbn[i]).attr({"readonly":"readonly"});
			$("#ip_score_"+formGbn[i]).val("");
			$("input:checkbox[id='ip_useYn_"+formGbn[i]+"']").prop("checked", false);
		}
	}
	
	function fnMaxScore(){
		var score=[0];
		for(var i=0; i<formGbn.length; i++){
			if($("input:checkbox[id='ip_useYn_"+formGbn[i]+"']").is(":checked")){
					score.push(Number(($("#ip_score_"+formGbn[i]).val())));
			};
		}
		argoSetValue("ip_score_0", Math.max.apply(null, score));
	}
	
	function fnSetDetailCnt(){
		for(var i=1; i<formGbn.length+1; i++){
			$("#detailCnt").append("<option value='"+i+"' >"+i+"</option>");
		};
		argoSetValue("detailCnt", 5);
	}
	
	
	
	function fnSetSheetDetailRow(cnt){
		var table = document.getElementById("detailList");
		var rowsCount = table.rows.length;

		if(rowsCount<cnt){
			var objHtml;
			for(var i=rowsCount; i<cnt; i++){
				objHtml='<tr height="30">'
								+'<td>'+formGbn[i]+'</td>'
								+'<td><input type="checkbox" id="ip_useYn_'+formGbn[i]+'" name="ip_useYn_'+formGbn[i]+'" class="non_label chkbox"><label for="ip_useYn_'+formGbn[i]+'"></label></td>'
								+'<td>'
									+'<span class="count_num" id="count_num'+i+'">'
										+'<button type="button" class="btn_minus score_'+formGbn[i]+'" disabled="disabled">-</button><input type="text" id="ip_score_'+formGbn[i]+'" name="ip_score_'+formGbn[i]+'" style="width:30px;" onchange="fnMaxScore(this.value)" class="txt_c input_num score_'+formGbn[i]+'" readonly="readonly"><button type="button" class="btn_plus score_'+formGbn[i]+'" disabled="disabled">+</button>'
									+'</span>'
								+'</td>'
								+'<td class="txt_l td65"><textarea id="ip_sheetText_'+formGbn[i]+'" name="ip_sheetText_'+formGbn[i]+'" class="txtpt" rows="2" readonly="readonly"></textarea></td>'
							+'</tr>';
				
				$("#detailList").append(objHtml);
				$("#count_num"+i).countNum({
					max : 1000,
					min : -100,
					set_num : 0
				});
			};
		}else if(rowsCount==cnt){
			return ;
		}else{
			for(var i=0; i<rowsCount-cnt; i++){
				$('#dataTable > tbody > tr:last').remove();			
			}
		}
	}
</script>
 
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt20">
            	<div class="input_area">
                    <table class="input_table">
                        <colgroup>
                            <col width="90">
                            <col width="">
                            <col width="90">
                            <col width="">
                            <col width="90">
                            <col width="">
                        </colgroup>
                        <tbody>
                            <tr>
                                <th>구분</th>
                                <td>
                                	<select id="ip_PartCd" name="ip_PartCd" style="width:145px;">
                                        <option><선택></option>
                                    </select>
                                </td>
                                <th>대분류</th>
                                <td>
                                	<select id="ip_MajorCd" name="ip_MajorCd" style="width:145px;">
                                        <option><선택></option>
                                    </select>
                                </td>
                                <th>소분류</th>
                                <td>
                                	<select id="ip_MinorCb" name="ip_MinorCb" style="width:145px;">
                                        <option><선택></option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <th>배점</th>
                                <td>
                                    <input type="text" id="ip_score_0" name="ip_score_0" style="width:50px; text-align: center; padding-left: 0px;" readonly="readonly">
                                </td>
                                
                                <th>문항갯수</th>
                                <td>
                                	<select id="detailCnt" style="width: 70px;" onchange="fnSetSheetDetailRow(this.value);"></select>
                                </td>
 								<th> </th>
                                <td> </td>
                            </tr>
                            <tr>
                                <th>설명</th>
                                <td colspan="5">
                                	<textarea id="ip_sheetText_0" name="ip_sheetText_0" rows="3"></textarea>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="grid_area hAuto" style="height: 365px !important; overflow: auto;">
                    <table class="table_n" id="dataTable">
                        <colgroup>
                            <col width="7%">
                            <col width="9%">
                            <col width="14%">
                            <col width="70%">
                        </colgroup>
                        <thead>
                            <tr>
                                <th>구분</th>
                                <th>사용여부</th>
                                <th>배점</th>
                                <th>평가내용</th>
                            </tr>
                        </thead>
                        <tbody style="height: 305px !important; overflow: auto;" id="detailList">
                        </tbody>
                    </table> 
                </div>
                <div class="btn_areaB txt_r">
                	<button type="button" id="btnDel" name="btnDel" class="btn_m" >삭제</button>   
                    <button type="button" id="btnSave" name="btnSave" class="btn_m confirm">저장</button>   
            	</div>
            </div>            
        </section>
    </div>
</body>
</html>