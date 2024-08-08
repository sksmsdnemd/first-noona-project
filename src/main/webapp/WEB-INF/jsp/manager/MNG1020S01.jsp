<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.spin.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.countNum.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/security/aes256.js"/>"></script>
<script>

var fvTenantId = '';
var fvWorkId   = '';
var fvWorkNm   = '';
var fvWorkGbn  = '';
var fvRetryCnt = '';

// 암호화를 위한 User 정보
var fvUserId = '';
var fvUserPw = '';

var fvTiberoJdbcDriver = 'com.tmax.tibero.jdbc.TbDriver';	// tibero JdbcDriver
var fvOracleJdbcDriver = 'oracle.jdbc.driver.OracleDriver';	// oracle JdbcDriver
var fvMsJdbcDriver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';	// mssql JdbcDriver

//-------------------------------------------------------------
//페이지 초기설정
//-------------------------------------------------------------   
$(document).ready( function() {
	
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
    };

    fnInitCtrl();
  
});

function fnInitCtrl(){
	$("#ip_StrTm").prop("readonly", false);
	$("#ip_EndTm").prop("readonly", false);
	/* 테넌트 콤보박스  */
	argoCbCreate("ip_TenantId", "ARGOCOMMON", "tenant", {},{"selectIndex":0, "text":'<선택>', "value":''});
	
	/* 작업구분 변경  */
	$('#ip_WorkGubun').change(function(){
		fnWorkGubunChange();
	});
	
	/* 작업구분 수신일 때 DB/FILE 선택  */
	$('#ip_SourceTyp').change(function(){
		fnSourceTypChange();
	});
	
	/* 재시도 횟수 숫자 설정  */
	$(".count_num.retryCnt").countNum({
		max:9,
		min:0,
		set_num:0
	});
	
	/* 수행일자(+/-) */
	/* $(".count_num.fileDays").countNum({
		max:99,
		min:0,
		set_num:0
	}); */
	
	/* 반복주기(분단위) */
	$(".count_num.cycle").countNum({
		max:1440,
		min:0,
		set_num:0
	});
	
	/* 시작일자/시간, 종료일자/시간 설정  */	
	argoSetDatePicker();
	var today = argoSetFormat(argoCurrentDateToStr(),"-","4-2-2")
	argoSetValue("ip_StrDt", today);
	argoSetValue("ip_EndDt", today);
	$('.timepicker.subject').timeSelect({use_sec:false});
	
	/* 저장버튼 클릭  */
	$("#btnSave").click(function(){
		
		var workGbn   = $("#ip_WorkGubun option:selected").val();
		var	SourceTyp = $("#ip_SourceTyp option:selected").val();
		
		if(workGbn == 'IN'){
			if(SourceTyp == 'DB'){
				fvUserId = AES_Encode(argoGetValue('ip1_UserId'));
				fvUserPw = AES_Encode(argoGetValue('ip1_UserPw'));
			}
		}
		
		fnSave();
	});
	
	$("#btnExcute").click(function(){
		fnExcute();
	});
	
	/* 반복주기 변경 이벤트  */	
	$(".btn_minus.cycle").click(function(){
		fnEndDtTm();
	});
	$(".btn_plus.cycle").click(function(){
		fnEndDtTm();
	});
	$("#ip_RepCycle").focusout(function(){
		fnEndDtTm();
	});	
	
	/* 메인에서 넘겨받은 데이터를 화면에 처리  */
	fnSetValue();
	
	/* 탭 선택  */
	$(".tab_btns a").on( "click", function(){
		$(".tab_btns a").removeClass("on");
		$(".chart_div").css({"opacity":"0"});
		$(this).addClass("on");
		var index = $(this).parent().index();
		$(".tab_area").hide();		
		$(".tab_area.tab"+ index ).show();
		
		if(index == 0){
			$('#jobInfo').show();
			$('#scheInfo').hide();
		} else if (index == 1) {
			$('#jobInfo').hide();
			$('#scheInfo').show();
		}
	});	

	$("#ip2_FileDays").keyup(function(){$(this).val( $(this).val().replace(/[^0-9\-]/g,"") );} );
	$("#ip3_FileDays").keyup(function(){$(this).val( $(this).val().replace(/[^0-9\-]/g,"") );} );
	
}

/* 메인에서 넘겨받은 데이터를 화면에 처리  */
function fnSetValue(){
	
	argoSetValues("ip_" ,sPopupOptions);
	
	if(sPopupOptions.workGubun == 'IN'){
		if(sPopupOptions.sourceTyp == 'DB'){
			
			argoSetValues("ip1_" ,sPopupOptions);
			
			if(sPopupOptions.jdbcDriver == fvTiberoJdbcDriver){
				
				var jdbcUrl = sPopupOptions.jdbcUrl.replace('jdbc:tibero:thin:@', '').split(':');
				argoSetValue("ip1_JdbcDriver", 'T');
				argoSetValue("ip1_UrlIp", jdbcUrl[0]);
				argoSetValue("ip1_UrlPort", jdbcUrl[1]);
				argoSetValue("ip1_UrlSid", jdbcUrl[2]);
				
			}
			else if(sPopupOptions.jdbcDriver == fvOracleJdbcDriver) {
			
				var jdbcUrl = sPopupOptions.jdbcUrl.replace('jdbc:oracle:thin:@', '').split(':');
				argoSetValue("ip1_JdbcDriver", 'O');
				argoSetValue("ip1_UrlIp", jdbcUrl[0]);
				argoSetValue("ip1_UrlPort", jdbcUrl[1]);
				argoSetValue("ip1_UrlSid", jdbcUrl[2]);
				
			}
			else if(sPopupOptions.jdbcDriver == fvMsJdbcDriver)	{	
				
				var jdbcUrl = sPopupOptions.jdbcUrl.replace('jdbc:sqlserver://', '').split(':');
				argoSetValue("ip1_JdbcDriver", 'M');
				argoSetValue("ip1_UrlIp", jdbcUrl[0]);
				
				var jdbcUrl2 = jdbcUrl[1].split(';')
				argoSetValue("ip1_UrlPort", jdbcUrl2[0]);
				argoSetValue("ip1_UrlSid", jdbcUrl2[1]);
				
			}
			
			// ID/PW 복호화
			argoSetValue('ip1_UserId', AES_Decode(argoGetValue('ip1_UserId')));
			argoSetValue('ip1_UserPw', AES_Decode(argoGetValue('ip1_UserPw')));
		}
		else if(sPopupOptions.sourceTyp == 'FILE'){
			
			argoSetValues("ip2_" ,sPopupOptions);
		}
	}
	else if(sPopupOptions.workGubun == 'OUT'){
		argoSetValues("ip3_" ,sPopupOptions);
	}
	else if(sPopupOptions.workGubun == 'EXE_SP'){
		argoSetValues("ip4_" ,sPopupOptions);
	}
	else if(sPopupOptions.workGubun == 'EXE_CMD'){
		argoSetValues("ip5_" ,sPopupOptions);
	}
	
	if(!sPopupOptions.tenantId){
		$("#btnExcute").hide();	
	}
	fnEndDtTm();
}

/* 작업구분 변경 이벤트  */
function fnWorkGubunChange(){
	
	/* [workGbn : 작업구분]
	 * IN : 수신
 	 * OUT : 송신 
	 * EXE_SP : 쿼리실행
	 * EXE_CMD : 명령실행
	 */
	 
	var workGbn = $("#ip_WorkGubun option:selected").val();
	
	if(workGbn == 'IN'){
		$('#spanSourceTyp').show();
		if($("#ip_SourceTyp option:selected").val() == 'DB')   $('#divInDB').show();
		if($("#ip_SourceTyp option:selected").val() == 'FILE') $('#divInFile').show();
		
		$('#divOut').hide();
		$('#divExeSp').hide();
		$('#divExeCmd').hide();
		
	} else if(workGbn == 'OUT'){
		$('#divOut').show();
		
		$('#spanSourceTyp').hide();
		$('#divInDB').hide();
		$('#divInFile').hide();
		$('#divExeSp').hide();
		$('#divExeCmd').hide();
		
	} else if(workGbn == 'EXE_SP'){
		$('#divExeSp').show();
		
		$('#spanSourceTyp').hide();
		$('#divInDB').hide();
		$('#divInFile').hide();
		$('#divOut').hide();
		$('#divExeCmd').hide();
		
	} else if(workGbn == 'EXE_CMD'){
		$('#divExeCmd').show();
		
		$('#spanSourceTyp').hide();
		$('#divInDB').hide();
		$('#divInFile').hide();
		$('#divOut').hide();
		$('#divExeSp').hide();
		
	} else {
		
		$('#spanSourceTyp').hide();
		$('#divInDB').hide();
		$('#divInFile').hide();
		$('#divOut').hide();
		$('#divExeSp').hide();
		$('#divExeCmd').hide();
		
	}
}

/* 작업구분 수신일 때 DB/FILE 선택 이벤트  */
function fnSourceTypChange(){
	
	var SourceTyp = $("#ip_SourceTyp option:selected").val();
	
	if(SourceTyp == 'DB'){
		$('#divInDB').show();
		$('#divInFile').hide();
	} else if (SourceTyp == 'FILE'){
		$('#divInDB').hide();
		$('#divInFile').show();
	} else {
		$('#divInDB').hide();
		$('#divInFile').hide();
	}
}

/* 작업구분 별 파라미터 설정  */
function fnSave(){

	if($('#ip_TenantId').val() == ''){
		argoAlert("테넌트를 선택하세요.");
		return;
	}
	
	/* if($('#ip_SystemGubun').val() == ''){
		argoAlert("시스템을 선택하세요.");
		return;
	} */
	
	if($('#ip_WorkNm').val() == ''){
		argoAlert("작업명을 입력하세요.");
		return;
	}
	
	if($('#ip_WorkGubun').val() == ''){
		argoAlert("작업구분을 선택하세요.");
		return;
	}
	
	if($('#ip_RetryCnt').val() == '00'){
		argoAlert("재시도 횟수를 입력하세요.");
		return;
	}
	
	/* [workGbn : 작업구분]
	 * IN : 수신
 	 * OUT : 송신 
	 * EXE_SP : 쿼리실행
	 * EXE_CMD : 명령실행
	 */
	 
	var param = {};
	var workGbn = $("#ip_WorkGubun option:selected").val();
	var SourceTyp = '';
	
	if(workGbn == 'IN'){
	
		SourceTyp = $("#ip_SourceTyp option:selected").val();
		if(SourceTyp == 'DB'){
			
			if($('#ip1_JdbcDriver').val() == ''){
				argoAlert("DataBase를 선택하세요.");
				return;
			}
			
			if($('#ip1_UrlIp').val() == ''){
				argoAlert("IP를 입력하세요.");
				return;
			}
			
			if($('#ip1_UrlPort').val() == ''){
				argoAlert("PORT를 입력하세요.");
				return;
			}
			
			if($('#ip1_UrlSid').val() == ''){
				argoAlert("SID를 입력하세요.");
				return;
			}
			
			if($('#ip1_UserId').val() == ''){
				argoAlert("ID를 입력하세요.");
				return;
			}
			
			if($('#ip1_UserPw').val() == ''){
				argoAlert("PW를 입력하세요.");
				return;
			}
			
			if($('#ip1_SelQuery').val() == ''){
				argoAlert("조회쿼리를 입력하세요.");
				return;
			}
			
			if($('#ip1_ExeQuery').val() == ''){
				argoAlert("실행쿼리를 입력하세요.");
				return;
			}
			
			var jdbcDriver = '';
			var jdbcUrl    = '';
			
			if($('#ip1_JdbcDriver').val() == 'T'){
				jdbcDriver = fvTiberoJdbcDriver;
				jdbcUrl    = 'jdbc:tibero:thin:@' + $('#ip1_UrlIp').val() + ':' + $('#ip1_UrlPort').val() + ':' + $('#ip1_UrlSid').val();
			}
			else if($('#ip1_JdbcDriver').val() == 'O'){
				jdbcDriver = fvOracleJdbcDriver;
				jdbcUrl    = 'jdbc:oracle:thin:@' + $('#ip1_UrlIp').val() + ':' + $('#ip1_UrlPort').val() + ':' + $('#ip1_UrlSid').val(); 
			}
			else if($('#ip1_JdbcDriver').val() == 'M') {
				jdbcDriver = fvMsJdbcDriver;
				jdbcUrl    = 'jdbc:sqlserver://' + $('#ip1_UrlIp').val() + ':' + $('#ip1_UrlPort').val() + ';' + $('#ip1_UrlSid').val(); 
			}
			
			param = { jdbcDriver    : jdbcDriver
					, jdbcUrl       : jdbcUrl
					, userId        : fvUserId
					, userPw        : fvUserPw
					, selQuery      : $('#ip1_SelQuery').val()
					, preExeQuery   : $('#ip1_PreExeQuery').val()
					, exeQuery      : $('#ip1_ExeQuery').val()
					, nextExeQuery  : $('#ip1_NextExeQuery').val()
					};
			
		} else if(SourceTyp == 'FILE'){
			
			if($('#ip2_FilePath').val() == ''){
				argoAlert("파일경로를 입력하세요.");
				return;
			}

			if($('#ip2_FileEncode').val() == ''){
				argoAlert("파일 인코딩을 선택하세요.");
				return;
			}
			
			if($('#ip2_FileDelimiter').val() == ''){
				argoAlert("구분자를 입력하세요.");
				return;
			}
			
			if($('#ip2_ExeQuery').val() == ''){
				argoAlert("실행쿼리를 입력하세요.");
				return;
			}			

			param = { filePath         : $('#ip2_FilePath').val()
					, fileNm           : $('#ip2_FileNm').val()
					, fileEncode       : $('#ip2_FileEncode').val()
					, fileDelimiter    : $('#ip2_FileDelimiter').val()
					, fileDays         : $('#ip2_FileDays').val()
					, preExeQuery      : $('#ip2_PreExeQuery').val()
					, exeQuery         : $('#ip2_ExeQuery').val()
					, nextExeQuery     : $('#ip2_NextExeQuery').val()
					};
		}
		
	} else if(workGbn == 'OUT') {
		$("#ip_SourceTyp option:selected").val('');
		if($('#ip3_FilePath').val() == ''){
			argoAlert("파일경로를 입력하세요.");
			return;
		}
		
		if($('#ip3_FileNm').val() == ''){
			argoAlert("파일명을 입력하세요.");
			return;
		}
		
		if($('#ip3_FileEncode').val() == ''){
			argoAlert("파일인코딩을 선택하세요.");
			return;
		}
		
		if($('#ip3_FileDelimiter').val() == ''){
			argoAlert("구분자를 입력하세요.");
			return;
		}
		
		if($('#ip3_SelQuery').val() == ''){
			argoAlert("조회쿼리를 입력하세요.");
			return;
		}
		
		param = { filePath      : $('#ip3_FilePath').val()
				, fileNm        : $('#ip3_FileNm').val()
				, fileEncode    : $('#ip3_FileEncode').val()
				, fileDays      : $('#ip3_FileDays').val()
				, fileDelimiter : $('#ip3_FileDelimiter').val()
				, selQuery      : $('#ip3_SelQuery').val()
				};
		
	} else if(workGbn == 'EXE_SP') {
		$("#ip_SourceTyp option:selected").val('');
		if($('#ip4_ExeQuery').val() == ''){
			argoAlert("실행쿼리를 입력하세요.");
			return;
		}
		
		param = {exeQuery : $('#ip4_ExeQuery').val()};
		
	} else if(workGbn == 'EXE_CMD') {
		$("#ip_SourceTyp option:selected").val('');
		if($('#ip5_ExeQuery').val() == ''){
			argoAlert("명령문을 입력하세요.");
			return;
		}
		
		param = {exeQuery : $('#ip5_ExeQuery').val()};
		
	} else {
		argoAlert("작업구분을 선택하세요.");
		return false;
	}
	
	
	if($('#ip_ScheNm').val() == ''){
		argoAlert("스케줄명을 입력하세요.");
		return;
	}
	
	if($('#ip_StrDt').val() == ''){
		argoAlert("시작일자를 입력하세요.");
		return;
	}
	
	if($('#ip_StrTm').val() == ''){
		argoAlert("시작시간를 입력하세요.");
		return;
	}
	
	if($('#ip_EndDt').val() == ''){
		argoAlert("종료일자를 입력하세요.");
		return;
	}
	
	if($('#ip_EndTm').val() == ''){
		argoAlert("종료시간을 입력하세요.");
		return;
	}
	
	argoConfirm("저장하시겠습니까?", function(){
		argoJsonSearchOne("MNG", "SP_MNG1020S01_01", "ip_", param, fnBatchScheSave);
	});
	
}

/* 저장 후 스케줄 저장  */
function fnBatchScheSave(data, textStatus, jqXHR){

	try{
	    if(data.isOk()) {
			if(argoGetValue('ip_WorkId') == '') argoSetValue('ip_WorkId', data.getRows()['workId']);
	    	argoJsonUpdate("MNG", "SP_MNG1020S01_02", "ip_", {}, fnCallbackSave);
	    } else {
	    	argoAlert("작업정보 저장에 실패하였습니다");
	    }
	} catch(e) {
		console.log(e);    		
	}
}

/* 저장 후 처리 */
function fnCallbackSave(data, textStatus, jqXHR){
	try{
	    if(data.isOk()) {
	    	argoAlert('warning', '성공적으로 저장 되었습니다.','', 'parent.fnSearchList(); argoPopupClose();');
    	} else {
    		argoAlert("스케줄 저장에 실패하였습니다.");
    	}
	} catch(e) {
		console.log(e);    		
	}
}

/* 반복주기 0일 때 종료일자, 시간 처리  */
function fnEndDtTm(){
	if(argoGetValue('ip_RepCycle') == '00' || argoGetValue('ip_RepCycle') == '0'){
		argoSetValue('ip_EndDt', argoGetValue('ip_StrDt'));
		argoSetValue('ip_EndTm', argoGetValue('ip_StrTm'));
		argoDisable(true, 'ip_EndDt, ip_EndTm');
	} else {
		argoDisable(false, 'ip_EndDt, ip_EndTm');
	}
}
var spinner;
function fnExcute(){
	
	argoConfirm("해당 배치를 수동실행하시겠습니까?", function(){
		var target = document.getElementById('foo');
		 spinner = new Spinner().spin(target);
		$("#btnExcute").hide();
		$.ajax({
			type : 'post',
			data : {"tenantId" : argoGetValue("ip_TenantId"), "workId" : argoGetValue("ip_WorkId")},
			url : gGlobal.ROOT_PATH + '/manager/handBatch.do',
			dataType : 'json',
			timeout : (60000*30),		//30분
			success : function(data) {
				spinner.stop();
				if(data.ret=="S"){
					argoAlert('warning', '성공적으로 실행 되었습니다.','', 'argoPopupClose();');
				}else{
					argoAlert('warning', '관리자에게 문의하시기 바랍니다.','', '');
				}
			},
			error : function(xhr, status, error) {
				argoAlert("Error : " + error); 
				console.log("Error : " + error);
			}
		});
	})
}
</script>
</head>

<body>
	<div class="sub_wrap pop" style="padding-bottom: 0px; height: 90%;">
		<div id='foo'></div>
	        <div class="tab_btns pt20">
				<ul>
					<li><a href="#" class="btn_tab on">작업정보</a></li>
	                <li><a href="#" class="btn_tab">스케줄</a></li>
	            </ul>                
			</div>            
                <div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="25%">
                            <col width="75%">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>테넌트<span class="point">*</span></th>
                                <td>
		                        	<input type="hidden" id="ip_WorkId" name="ip_WorkId" style="width:100%;">
		                        	<input type="hidden" id="ip_ScheId" name="ip_ScheId" style="width:100%;">
									<select id="ip_TenantId" name="ip_TenantId" style="width:42%;">
		                           		<option>전체</option>
		                            </select>
									<!-- <select id="ip_SystemGubun" name="ip_SystemGubun" style="width:42%;">
		                           		<option>&lt;선택&gt;</option>
		                           		<option value="VELOCE">VELOCE</option>
		                            </select> -->
                                </td>
                            </tr>
                            <tr>
                            	<th>작업명<span class="point">*</span></th>
                                <td>
                                	<input type="text" id=ip_WorkNm name="ip_WorkNm" style="width:100%;">                         
                                </td>
                            </tr>
                            <tr>
                            	<th>작업구분<span class="point">*</span></th>
                            	<td>
	                            	<span>
				                       	<select id="ip_WorkGubun" name="ip_WorkGubun" style="width:42%;">
			                          		<option value=''><전체></option>
			                          		<option value='IN'>수신</option>
			                          		<option value='OUT'>송신</option>
			                          		<option value='EXE_SP'>쿼리실행</option>
			                        	</select>
									</span>
									<span id="spanSourceTyp" style="display: none;">
										<select id="ip_SourceTyp" name="ip_SourceTyp" style="width:42%;">
			                          		<option value=''><전체></option>
			                          		<option value='DB'>DB</option>
			                          		<option value='FILE'>FILE</option>
			                            </select>
									</span>
	                            </td>
                            </tr>
                            <tr>
                            	<th>재시도 횟수<span class="point">*</span></th>
                                <td>
                               		<span class="count_num retryCnt">
	                            		<button type="button" class="btn_minus">-</button><input type="text" id="ip_RetryCnt" name="ip_RetryCnt" style="width:10%;" class="txt_c input_num"><button type="button" class="btn_plus">+</button>
									</span>
                                </td>
                            </tr>                            
                        </tbody>
                    </table>
                </div>
                <br>
                
                <div id="jobInfo">
				<!-- 작업구분  : 수신(DB) -->
                <div class="input_area" id="divInDB" style="display: none;">
                	<table class="input_table">
                		<colgroup>
                        	<col width="20%">
                            <col width="20%">
                            <col width="20%">
                            <col width="40%">
                        </colgroup>
	                	<tbody>
                        	<tr>
                            	<th>DataBase<span class="point">*</span></th>
                                <td>
									<select id="ip1_JdbcDriver" name="ip1_JdbcDriver" style="width:100%;">
		                           		<option value=''><전체></option>
		                          		<option value='T'>TIBERO</option>
		                          		<option value='O'>ORACLE</option>
		                          		<option value='M'>MS-SQL</option>
		                            </select>
                                </td>
                            	<th>IP<span class="point">*</span></th>
                                <td colspan="3">
                                	<input type="text" id=ip1_UrlIp name="ip1_UrlIp">                         
                                </td>
                            </tr>
                            <tr>
                            	<th>PORT<span class="point">*</span></th>
                                <td>
                                	<input type="text" id=ip1_UrlPort name="ip1_UrlPort">                         
                                </td>
                                <th>SID(DB명)<span class="point">*</span></th>
                                <td>
                                	<input type="text" id=ip1_UrlSid name="ip1_UrlSid">                         
                                </td>
							</tr>
                            <tr>
                            	<th>ID<span class="point">*</span></th>
                                <td>
                                	<input type="text" id=ip1_UserId name="ip1_UserId">
                                </td>
                                <th>PW<span class="point">*</span></th>
                                <td>
                                	<input type="password" id=ip1_UserPw name="ip1_UserPw">                         
                                </td>
							</tr>
							<tr>
                            	<th>조회쿼리<span class="point">*</span></th>
                                <td colspan="3">
                                	<textarea id="ip1_SelQuery" rows="3" name="ip1_SelQuery"></textarea>                         
                                </td>
							</tr>
							<tr>
                            	<th>선행쿼리</th>
                                <td colspan="3">
                                	<textarea id="ip1_PreExeQuery" rows="2" name="ip1_PreExeQuery"></textarea>                         
                                </td>
							</tr>
							<tr>
                            	<th>실행쿼리<span class="point">*</span></th>
                                <td colspan="3">
                                	<textarea id="ip1_ExeQuery" rows="3" name="ip1_ExeQuery"></textarea>                         
                                </td>
							</tr>
							<tr>
                            	<th>후행쿼리</th>
                                <td colspan="3">
                                	<textarea id="ip1_NextExeQuery" rows="1" name="ip1_NextExeQuery"></textarea>                         
                                </td>
							</tr>
						</tbody>
                	</table>
                </div>
                
                
                <!-- 작업구분  : 수신(FILE) -->
				<div class="input_area" id="divInFile" style="display: none;">
                	<table class="input_table">
                		<colgroup>
                        	<col width="20%">
                            <col width="30%">
                            <col width="20%">
                            <col width="30%">
                        </colgroup>
	                	<tbody>
                        	<tr>
                            	<th>파일경로<span class="point">*</span></th>
                                <td colspan="3">
									<input type="text" id="ip2_FilePath" name="ip2_FilePath" style="width:100%">
                                </td>
                            </tr>
                        	<tr>
                            	<th>파일명</th>
                                <td colspan="3">
									<input type="text" id="ip2_FileNm" name="ip2_FileNm" style="width:100%">
                                </td>
                            </tr>
                            <tr>
                            	<th>파일 인코딩<span class="point">*</span></th>
                                <td>
									<select id="ip2_FileEncode" name="ip2_FileEncode" style="width:100%;">
		                           		<option value=''><전체></option>
		                          		<option value='UTF-8'>UTF-8</option>
		                          		<option value='EUC-KR'>EUC-KR</option>
		                            </select>                         
                                </td>
                                <th>수행일자(+/-)<span class="point">*</span></th>
                                <td>
                                	<!-- <span class="count_num fileDays">
	                            		<button type="button" class="btn_minus">-</button><input type="text" id="ip2_FileDays" name="ip2_FileDays" style="width:30%;" class="txt_c input_num"><button type="button" class="btn_plus">+</button>
									</span> -->                         
	                            	<input type="text" id="ip2_FileDays" name="ip2_FileDays" style="width:50%;" maxlength="2">
                                </td>
							</tr>
                            <tr>
                            	<th>구분자<span class="point">*</span></th>
                                <td colspan="3">
									<input type="text" id="ip2_FileDelimiter" name="ip2_FileDelimiter">                         
                                </td>
							</tr>
							<tr>
                            	<th>선행쿼리</th>
                                <td colspan="3">
                                	<textarea id="ip2_PreExeQuery" rows="2" name="ip2_PreExeQuery"></textarea>                         
                                </td>
							</tr>
							<tr>
                            	<th>실행쿼리<span class="point">*</span></th>
                                <td colspan="3">
                                	<textarea id="ip2_ExeQuery" rows="4" name="ip2_ExeQuery"></textarea>                         
                                </td>
							</tr>
							<tr>
                            	<th>후행쿼리</th>
                                <td colspan="3">
                                	<textarea id="ip2_NextExeQuery" rows="2" name="ip2_NextExeQuery"></textarea>                         
                                </td>
							</tr>
							
						</tbody>
                	</table>
                </div>


                <!-- 작업구분  : 송신 -->
				<div class="input_area" id="divOut" style="display: none;">
                	<table class="input_table">
                		<colgroup>
                        	<col width="20%">
                            <col width="30%">
                            <col width="20%">
                            <col width="30%">
                        </colgroup>
	                	<tbody>
                        	<tr>
                            	<th>파일경로<span class="point">*</span></th>
                                <td colspan="3">
									<input type="text" id="ip3_FilePath" name="ip3_FilePath" style="width:100%">
                                </td>
                            </tr>
                        	<tr>
                            	<th>파일명<span class="point">*</span></th>
                                <td colspan="3">
									<input type="text" id="ip3_FileNm" name="ip3_FileNm" style="width:100%">
                                </td>
                            </tr>
                            <tr>
                            	<th>파일 인코딩<span class="point">*</span></th>
                                <td>
									<select id="ip3_FileEncode" name="ip3_FileEncode" style="width:100%;">
		                           		<option value=''><전체></option>
		                          		<option value='UTF-8'>UTF-8</option>
		                          		<option value='EUC-KR'>EUC-KR</option>
		                            </select>                         
                                </td>
                                <th>수행일자(+/-)<span class="point">*</span></th>
                                <td>
                                	<!-- <span class="count_num fileDays">
	                            		<button type="button" class="btn_minus">-</button><input type="text" id="ip3_FileDays" name="ip3_FileDays" style="width:30%;" class="txt_c input_num"><button type="button" class="btn_plus">+</button>
									</span>-->
									<input type="text" id="ip3_FileDays" name="ip3_FileDays" style="width:50%;" maxlength="2">
                                </td>
							</tr>
                            <tr>
                            	<th>구분자<span class="point">*</span></th>
                                <td colspan="3">
									<input type="text" id="ip3_FileDelimiter" name="ip3_FileDelimiter">                         
                                </td>
							</tr>
							<tr>
                            	<th>조회쿼리<span class="point">*</span></th>
                                <td colspan="3">
                                	<textarea id="ip3_SelQuery" rows="11" name="ip3_SelQuery"></textarea>                         
                                </td>
							</tr>
						</tbody>
                	</table>
                </div>
                
                
                <!-- 작업구분  : 쿼리실행 -->
				<div class="input_area" id="divExeSp" style="display: none;">
                	<table class="input_table">
                		<colgroup>
                        	<col width="20%">
                            <col width="30%">
                            <col width="20%">
                            <col width="30%">
                        </colgroup>
	                	<tbody>
							<tr>
                            	<th>실행쿼리<span class="point">*</span></th>
                                <td colspan="3">
                                	<textarea id="ip4_ExeQuery" rows="15" name="ip4_ExeQuery"></textarea>                         
                                </td>
							</tr>	                	
						</tbody>
                	</table>
                </div>
                
                
                <!-- 작업구분  : 명령문 실행 -->
				<div class="input_area" id="divExeCmd" style="display: none;">
                	<table class="input_table">
                		<colgroup>
                        	<col width="20%">
                            <col width="30%">
                            <col width="20%">
                            <col width="30%">
                        </colgroup>
	                	<tbody>
							<tr>
                            	<th>명령문<span class="point">*</span></th>
                                <td colspan="3">
                                	<textarea id="ip5_ExeQuery" rows="15" name="ip5_ExeQuery"></textarea>                         
                                </td>
							</tr>	                	
						</tbody>
                	</table>
                </div>                
            </div>
            
            <!-- 스케줄 정보  -->
            <div class="input_area" id="scheInfo" style="display:none;">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="25%">
                            <col width="75%">
                        </colgroup>
                        <tbody>
                        	<tr>
                            	<th>스케줄명<span class="point">*</span></th>
                                <td>
									<input type="text" id=ip_ScheNm name="ip_ScheNm" style="width:100%;">
                                </td>
                            </tr>
                            <tr>
                            	<th>반복주기(분)<span class="point">*</span></th>
                                <td>
                                	<span class="count_num cycle">
	                            		<button type="button" class="btn_minus cycle">-</button><input type="text" id="ip_RepCycle" name="ip_RepCycle" style="width:10%;" class="txt_c input_num"><button type="button" class="btn_plus cycle">+</button>
									</span>
                                </td>
                            </tr>
                            <tr>
                            	<th>시작일자/시간<span class="point">*</span></th>
                                <td>
                                	<span class="select_date"><input type="text" id="ip_StrDt" name="ip_StrDt" class="datepicker onlyDate"></span>
                                	<span class="timepicker subject"><input type="text" id="ip_StrTm" name="ip_StrTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>                         
                                </td>
                            </tr>
                            <tr>
                            	<th>종료일자/시간<span class="point">*</span></th>
                                <td>
                                	<span class="select_date"><input type="text" id="ip_EndDt" name="ip_EndDt" class="datepicker onlyDate"></span>
                                	<span class="timepicker subject"><input type="text" id="ip_EndTm" name="ip_EndTm" class="input_time"><a href="#" class="btn_time">시간 선택</a></span>                         
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
    </div>
    <div class="btn_areaB txt_r" style="padding-right: 15px; padding-top:15px;">
    	<button type="button" class="btn_m" id="btnExcute" name="btnExcute">수동실행</button>
		<button type="button" class="btn_m confirm" id="btnSave" name="btnSave">저장</button>   
	</div>
	<iframe id="handBatch" style='display:none' src="" width="0" height="0"></iframe>
</body>
</html>