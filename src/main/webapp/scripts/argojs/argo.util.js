/***********************************************************
 * argo.util.js
 * 
 * CREATE BY   2016-12-21   
 * Argo WEB UTIL 기본 스크립트
 * 
 ***********************************************************/
/**
 * argoCurrentDateToStr 오늘날짜를 스트링으로 린턴
 * @param  N/A
 * @returns
 */
function argoCurrentDateToStr() {
    var date = new Date();
    var yyyy = date.getFullYear();
    var mm = date.getMonth() + 1;
    var dd = date.getDate();
    
    if (mm < 10) mm = "0" + mm;
    if (dd < 10) dd = "0" + dd;
    
    return yyyy +''+ mm +''+ dd; 
}

/**
 * argoCurrentTimeToStr 현재시간을 스트링으로 린턴
 * @param  N/A
 * @returns
 */
function argoCurrentTimeToStr() {
    var date = new Date();
    
    return (date.getHours()<10?'0':'')+ date.getHours()+''+(date.getMinutes()<10?'0':'') + date.getMinutes() +''+(date.getSeconds()<10?'0':'')+date.getSeconds(); 
}

/**
 * argoDateToStr : 날짜를 스트링으로 리턴
 * @param  date
 * @returns yyyymmdd
 */
function argoDateToStr(date)
{
    var strYear = date.getFullYear().toString();
    var strMonth = (date.getMonth()+1).toString();
    var strDate = date.getDate().toString();
     
    if(strYear.length==2)
        strYear = '19'+strYear;
    else if(strYear.length==1)
        strYear = '190'+strYear;
      
    if(strMonth.length==1)
        strMonth = '0'+strMonth;
    if(strDate.length==1)
        strDate = '0'+strDate;
     
    return strYear+strMonth+strDate;
}

/* argoAddMonth('20140428','-3');
 * 3달전(Date).
 */
function argoAddMonth(strMonth, nOffSet, pOnlyMonth)
{
    var date = new Date();
    date.setYear(parseInt(strMonth.substr(0, 4),0));
    if(pOnlyMonth=='Y'){	// 31일이 없는 달에는 다음 달 1일로 자동 변경됨 3개월 지정시 07~08 나오는 현상 
    	date.setDate(1);
    }else{
    	date.setDate(parseInt(strMonth.substr(6, 2),10));
    }
    date.setMonth(parseInt(strMonth.substr(4, 2),10)-1-(nOffSet*-1));
    
    if(strMonth==argoDateToStr(date)){
        return argoAddDate(strMonth, nOffSet*30);
    }
    
    return date;
}

/* argoAddDate('20140331', -30)
 * -30일전(Date) : 밀리세컨드로 변경하여 비교하므로 한달전, 석달전이라기 보다 30일전, 90일전을 구할때 사용.
 */
function argoAddDate(strDate, nOffSetDay)
{
    var date = new Date();
    strDate = ''+strDate;
    
    date.setYear(strDate.substr(0, 4));
    date.setMonth(strDate.substr(4, 2)-1);
    date.setDate(strDate.substr(6, 2));     
    
    if(nOffSetDay>0)
        return new Date(Date.parse(date) - 1000 * 3600 * 24 * nOffSetDay);
    else
        return new Date(Date.parse(date) + 1000 * 3600 * 24 * nOffSetDay);

}

/** argoSetFormat
 * type에 해당하는 포멧으로 리턴
 * @param str           변경대상 (예 185650)
 * @param delim         삽입문자 (예 :)
 * @param type          원하는포멧 (예 4-2-2)
 * @returns {String}    리턴 (예 18:56:50)
 */
function argoSetFormat(str, delim, type) {
    if(str == null || delim == null || type == null)        return '';
    var aType = type.split("-");
    var retStr = "";
    var firstLen = 0;
    var lastLen = 0;

    for(i3=0; i3<aType.length; i3++) {
        if(i3 == 0) {
            firstLen    = 0;
            lastLen     = parseInt(aType[0]);
        } else {
            firstLen    = lastLen;
            lastLen     = firstLen + parseInt(aType[i3]);
        }
        if(i3 == aType.length-1)
            retStr = retStr + str.substring(firstLen, lastLen);
        else
            retStr = retStr + str.substring(firstLen, lastLen) + delim;
    }
    return retStr;
}

/** argoNumkeyCheck
 * 인풋박스에 숫자만 입력
 *  <input type="text" onKeyPress="return numkeyCheck(event)" id=""/>
 */
function argoNumkeyCheck(e) {
	var keyValue = event.keyCode;
    if( ((keyValue >= 48) && (keyValue <= 57)) ) return true;
    else return false;
}

/** argoYmdFormCheck
 * 텍스트 박스에 날짜 형식(yyyymmdd)으로 입력시 유효성 검사
 * @param param_dt   날짜 (예 20161225)
 * @returns boolean  
 */
function argoYmdFormCheck(param_dt){
 	var bDateCheck = true;
 	
 	if(param_dt.length == 6) param_dt = param_dt+'01'; // ADD BY YAKIM YYYYMM 도 처리하기 위해
 	
 	if(param_dt.length != 8) {
 		bDateCheck = false;
 	}else{
 		var nYear = Number(param_dt.substring(0,4));
	    var nMonth = Number(param_dt.substring(4,6));
	    var nDay = Number(param_dt.substring(6,8));
	    //alert(nYear+'//'+nMonth+'//'+nDay);
	    if (nYear < 1900 || nYear > 3000) bDateCheck = false;
	    if (nMonth < 1 || nMonth > 12) bDateCheck = false;
	    var nMaxDay = new Date(new Date(nYear, nMonth, 1) - 86400000).getDate(); // 해당달의 마지막 일자 구하기
	    if (nDay < 1 || nDay > nMaxDay) bDateCheck = false;
 	}
 	return bDateCheck;
}

/** argoTimeFormCheck
 * 텍스트 박스에 시간 형식(hhmm)으로 입력시 유효성 검사
 * 
 * @param param_tm   시간 (예 1315)
 * @returns boolean  
 */
function argoTimeFormCheck(param_tm){
 	var bTimeCheck = true;
 	/*
 	if(param_tm.length != 4 ) {
 		bTimeCheck = false;
 	}else {
 		var hh = Number(param_tm.substring(0,2));
	    var mm = Number(param_tm.substring(2,4));
	    if (hh > 23) bTimeCheck = false;
	    if (mm > 59) bTimeCheck = false;
 	} */
 	
 	if(param_tm.length == 4) param_tm = param_tm+'00';
 	
 	if(param_tm.length == 6) {
 		var hh = Number(param_tm.substring(0,2));
	    var mm = Number(param_tm.substring(2,4));
	    var ss = Number(param_tm.substring(4,6));
	    if (hh > 23) bTimeCheck = false;
	    if (mm > 59) bTimeCheck = false;
	    if (ss > 59) bTimeCheck = false;	    
 	}else bTimeCheck = false;
 	
 	return bTimeCheck;
}

/** argoArrayOverlap
 *  배열 중복값 체크 
 * @param chkArray
 * @returns boolean  
 */
function argoArrayOverlap(chkArray){
	var chk = false;
	var result = [];
	$.each(chkArray, function(index, element) {     
		if ($.inArray(element, result) == -1) result.push(element);
		else chk = true;
	});
	return chk;
}

/** argoSetNumberFormat
 *  숫자포맷으로 변환하여 리턴 
 * @param 12345
 * @returns 12,345  
 */
function argoFormatterNumber(pNumber){
	
	var strNumber = '' + pNumber;   
	var returnVal ;
	 
    if (isNaN(strNumber) || strNumber == "") {    // 숫자 형태의 값이 정상적으로 입력되었는지 확인합니다.
    	returnVal = strNumber ;
        console.log("숫자만 입력 하세요");
    }else {

	    returnVal = Number(strNumber).toLocaleString('en').split(".")[0] ;
    }
	return returnVal;
}

/** argoFormatterTelNo
 *  개인정보 (전화번호) 표시 타입 적용 하여 리턴
 * @param 021234567 
 * @returns 환경설정값(DI_TEL_TYPE) 에 따라 동작  *          
 *          0 ==> 02-123-4567 
 *          1 ==> 02-***-4567 
 *          2 ==> 02-123-****  
 */
function argoFormatterTelNo(pTelno){
    var formatNum = '';
    if(pTelno===null || typeof(pTelno)=="undefined") return formatNum;
    
    var num = pTelno.replace(/\-/g,"");

    var type = argoGetConfig('DI_TEL_TYPE') ; // 환경설정의 전화번호 표시 유형 
    
    if(num.length==11){
        if(type=="1"){
            formatNum = num.replace(/(\d{3})(\d{4})(\d{4})/, '$1-****-$3');
        }else if(type=="2"){
            formatNum = num.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-****');
        }else{
            formatNum = num.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
        }
    }else if(num.length==7 || num.length==8){
    	if(type=="1"){
            formatNum = num.replace(/(\d{3,4})(\d{4})/, '***-$2');
        }else if(type=="2"){
            formatNum = num.replace(/(\d{3,4})(\d{4})/, '$1-****');
        }else{
        	 formatNum = num.replace(/(\d{3,3})(\d{4})/, '$1-$2');
        }
    }else{
        if(num.indexOf('02')==0){
            if(type=="1"){
                formatNum = num.replace(/(\d{2})(\d{3,4})(\d{4})/, '$1-****-$3');
            }else if(type=="2"){
                formatNum = num.replace(/(\d{2})(\d{3,4})(\d{4})/, '$1-$2-****');
            }else{
                formatNum = num.replace(/(\d{2})(\d{3,4})(\d{4})/, '$1-$2-$3');
            }
        }else{
            if(type=="1"){
                formatNum = num.replace(/(\d{3})(\d{3})(\d{4})/, '$1-***-$3');
            }else if(type=="2"){
                formatNum = num.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-****');
            }else{
                formatNum = num.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
            }
        }
    }
     return formatNum;
    
}

/** argoDateTermChk
 *  두 날짜(일시) 사이의 일, 시, 분, 초 구하기 
 * @param startDt 시작일자시간 14자리(예:20170101131530 - 2017년 1월 1일 13시 15분 30초)
 * @param endDt   종료일자시간 14자리(예:20170102153020 - 2017년 1월 2일 15시 30분 20초)
 * @param termChk 리턴받을 기간 (day:일수, hour:시, min:분, sec:초)
 * @returns string  
 */
function argoDateTermChk(startTime, endTime, termChk){
	   // 시작일시 
	   var startDate = new Date(parseInt(startTime.substring(0,4), 10),
	             parseInt(startTime.substring(4,6), 10)-1,
	             parseInt(startTime.substring(6,8), 10),
	             parseInt(startTime.substring(8,10), 10),
	             parseInt(startTime.substring(10,12), 10),
	             parseInt(startTime.substring(12,14), 10));
	            
	   // 종료일시 
	   var endDate   = new Date(parseInt(endTime.substring(0,4), 10),
	             parseInt(endTime.substring(4,6), 10)-1,
	             parseInt(endTime.substring(6,8), 10),
	             parseInt(endTime.substring(8,10), 10),
	             parseInt(endTime.substring(10,12), 10),
	             parseInt(endTime.substring(12,14), 10));

	   // 두 일자(startTime, endTime) 사이의 차이를 구한다.
	   var dateGap = endDate.getTime() - startDate.getTime();
	   var timeGap = new Date(0, 0, 0, 0, 0, 0, endDate - startDate); 
	   
	   // 두 일자(startTime, endTime) 사이의 간격을 "일-시간-분"으로 표시한다.
	   var diffDay  = Math.floor(dateGap / (1000 * 60 * 60 * 24)); // 일수       
	   var diffHour = timeGap.getHours();       // 시간 
	   var diffMin  = timeGap.getMinutes();      // 분
	   var diffSec  = timeGap.getSeconds();      // 초
	   	   
	   switch(termChk){
			case 'day' : return diffDay; break;
			case 'hour' : return diffHour; break;
			case 'min' : return diffMin; break;
			case 'sec' : return diffSec; break;
			default : {
				return null;
			}
	   } 
}
/** argoNullToSpace
 *  파라메터값이 null 인 경우 공백으로 리턴
 * @param String value 
 * @returns string  
 */
function argoNullToSpace(value) {
	return (value == null) ? "" : value ;
}

/** argoNullToZero
 *  파라메터값이 null 인 경우 "0" 으로 리턴
 * @param String value 
 * @returns string  
 */
function argoNullToZero(value) {
	return (value == null) ? "0" : value ;
}

/** argoTimeDiffToMms
 *  두 시간간  차이를 분으로 계산하여 리턴
 *  
 * @param String sTime1, String sTime2 ==> (hh:mm or hh:mm:ss or hhmm or hhmmss) 
 * @returns string  
 */
function argoTimeDiffToMms(sTime1, sTime2 ) {
	sTime1 = sTime1.replace(/[^0-9]/gi,""); //숫자만 남기고
	sTime2 = sTime2.replace(/[^0-9]/gi,"");
	
	if(sTime1.length == 4) sTime1 = sTime1+'00';
	if(sTime2.length == 4) sTime2 = sTime2+'00';
	
	if(sTime1.length != 6 || sTime2.length != 6) return 0;
	
	sTime1 = argoSetFormat(sTime1,":","2-2-2") ;
	sTime2 = argoSetFormat(sTime2,":","2-2-2") ;
	
	var sToday = argoSetFormat(argoCurrentDateToStr(),"-","4-2-2")

	var old = new Date (sToday +'T'+ sTime1 );
	var now = new Date (sToday +'T'+ sTime2 );
	
	var gap = now.getTime() - old.getTime();
	var min_gap = gap / 1000 /60;
	
	return min_gap ;
}

/** argoNumberToCycleNumner
 *  파라미터로 받은 숫자를 동그라미숫자로 리턴
 * @param int value 
 * @returns string  
 */
function argoNumberToCycleNumner(pNumber) {
	var rltValue =  (pNumber==1? '①':(pNumber==2? '②' :(pNumber==3? '③':(pNumber==4? '④':(pNumber==5? '⑤': pNumber) )  )))
	return (pNumber == null) ? "" : rltValue ;
}


var pageCurrentCnt;
function paging(totalData, currentPage, dataPerPage, cntType){
	pageCurrentCnt = currentPage;
	
	if(dataPerPage == undefined){
		dataPerPage=15;
	}

	var pageCount=10;
	var defaultYn="N";
	
	if(totalData==0){
		totalData=1;
		defaultYn="Y";
	}
	
	var totalPage = Math.ceil(totalData/dataPerPage);    // 총 페이지 수
	var pageGroup = Math.ceil(currentPage/pageCount);    // 페이지 그룹

	var last = pageGroup * pageCount;    // 화면에 보여질 마지막 페이지 번호
	if(last > totalPage)
		last = totalPage;
	var first = last - (pageCount-1);    // 화면에 보여질 첫번째 페이지 번호
	var next = last+1;
	var prev = first-1;

	if(first<1) first = 1
   
	var html = "";
   
    if(prev > 0){
        html += '<a href="#" class="first" id="first">first</a><a href="#" class="prev" id="prev">prev</a>';
    }
   
	html += '<ul class="paging">';

	for(var i=first; i <= last; i++){
		html += '<li><a href="#" id='+i+'>'+i+'</a></li>';
	}
	html +='</ul>';
   
	if(last < totalPage){
   		html += '<a href="#" class="next" id="next">next</a><a href="#" class="last" id="last">last</a>';
	}
   
	$("#paging").html(html);    // 페이지 목록 생성
	$("#paging a#" + currentPage).addClass("on");    // 현재 페이지 표시
   
	var startRow  = ((currentPage -1)*dataPerPage)+1;
	var endRow    = currentPage * dataPerPage;
	
	if(cntType == "4"){
		var paramText = parent.$("#RecSearchNewF").val().split("||");
		var paramText2 = "";
		var textStr = "";
		if(paramText.length > 1){
			for (var i = 0; i < paramText.length; i++) {
				paramSet = paramText[i].split("::")
				if(paramSet[0] != "selectionPage"){
					if(i > 0){
						paramText2 += "||";
					}
					textStr = paramSet[0] + "::" + paramSet[1] ;
					paramText2 += textStr;
				}
			}
			paramText2 = paramText2 + "||selectionPage::" + currentPage;
			parent.$("#RecSearchNewF").val(paramText2);
		}
	}else if(cntType == "3"){
		startRow = dataPerPage;
	}else if(cntType != "2"){
		if(totalPage == currentPage){
			startRow = totalData%dataPerPage;
			if(startRow == 0){
				startRow = dataPerPage;
			}
		}else{
			startRow = dataPerPage;
		}
	}else{	//통화내역조회시 최근작업페이지로 이동
		var paramText = parent.$("#RecSearchF").val().split("||");
		var paramText2 = "";
		var textStr = "";
		if(paramText.length > 1){
			for (var i = 0; i < paramText.length; i++) {
				paramSet = paramText[i].split("::")
				if(paramSet[0] != "selectionPage"){
					if(i > 0){
						paramText2 += "||";
					}
					textStr = paramSet[0] + "::" + paramSet[1] ;
					paramText2 += textStr;
				}
			}
			paramText2 = paramText2 + "||selectionPage::" + currentPage;
			parent.$("#RecSearchF").val(paramText2);
		}
	}
   
    fnSearchList(startRow,endRow);

	if(defaultYn=='N'){
		$("#paging a").click(function(){
	       
			var $item = $(this);
			var $id = $item.attr("id");
			var selectedPage = $item.text();
	       
			if($id == "next")	selectedPage = next;
			if($id == "prev")	selectedPage = prev;
			if($id == "first")	selectedPage = 1;
			if($id == "last")	selectedPage = totalPage-(totalPage%pageCount)+1;
			paging(totalData, selectedPage, dataPerPage, cntType);
		});
	}
	w2ui.grid.unlock();
}


function pageNavi(totalData, currentPage, dataPerPage, cntType, func) {
	if (dataPerPage == undefined) {
		dataPerPage = 15;
	}

	var pageCount = 10;
	var defaultYn = "N";

	if(totalData==0) {
		totalData = 1;
		defaultYn = "Y";
	}

	var totalPage = Math.ceil(totalData / dataPerPage);    // 총 페이지 수
	var pageGroup = Math.ceil(currentPage / pageCount);    // 페이지 그룹

	var last = pageGroup * pageCount;    // 화면에 보여질 마지막 페이지 번호
	if (last > totalPage) {
		last = totalPage;
    }
	var first = last - (pageCount -1);    // 화면에 보여질 첫번째 페이지 번호
	var next = last + 1;
	var prev = first - 1;

	if (first < 1) first = 1

	var html = "";
    if(prev > 0) {
        html += '<a href="#" class="first" id="first">first</a><a href="#" class="prev" id="prev">prev</a>';
    }
	html += '<ul class="paging">';

	for (var i=first; i <= last; i++) {
		html += '<li><a href="#" id='+i+'>'+i+'</a></li>';
	}
	html +='</ul>';

	if(last < totalPage) {
   		html += '<a href="#" class="next" id="next">next</a><a href="#" class="last" id="last">last</a>';
	}

	$("#paging").html(html);    // 페이지 목록 생성
	$("#paging a#" + currentPage).addClass("on");    // 현재 페이지 표시

	var startRow  = ((currentPage -1) * dataPerPage) +1;
	var endRow    = currentPage * dataPerPage;
    if(totalPage == currentPage) {
        startRow = totalData % dataPerPage;
        if(startRow == 0) {
            startRow = dataPerPage;
        }
    }
    else {
        startRow = dataPerPage;
    }

    $("#paging a").click(function() {
        var $item = $(this);
        var $id = $item.attr("id");
        var selectedPage = $item.text();
        if($id == "next")	selectedPage = next;
        if($id == "prev")	selectedPage = prev;
        if($id == "first")	selectedPage = 1;
        if($id == "last")	selectedPage = totalPage - (totalPage % pageCount) +1;

        if (typeof func == "function") {
            $("#paging a").removeClass("on")
            $item.addClass("on");
            func(selectedPage);
        }
        else {
            fnSearchList(selectedPage);
        }
    });
}

function fnSecondsConv(seconds) {
	var pad = function(x) { return (x < 10) ? "0"+x : x; }
	return pad(parseInt(seconds / (60*60))) + ":" + pad(parseInt(seconds / 60 % 60)) + ":" + pad(seconds % 60);
}

function fnStrMask(flag,value){
	var strText = "";
	if(flag == "YMD"){ 			//yyyy-mm-dd
		strText	= value.substr(0,4)+"-"+value.substr(4,2)+"-"+value.substr(6,2);
	}else if(flag == "HMS"){	//hh:mm:ss
		strText	= value.substr(0,2)+":"+value.substr(2,2)+":"+value.substr(4,2);
	}else if(flag == "DHMS"){	//yyyy-mm-dd hh:mm:ss
		strText	= value.substr(0,4)+"-"+value.substr(4,2)+"-"+value.substr(6,2)+" "+value.substr(8,2)+":"+value.substr(10,2)+":"+value.substr(12,2);
	}else{
		strText = value;
	}
	
	return strText;
}

function fnAuthBtnChk(value){

	if(value == "1"){
		$(".confirm").hide();
		$(".excel").hide();
	}else{
		$(".confirm").show();
		$(".excel").show();
	}
}

function fnDiffDate(fromDt, toDt){
	
	var strDate1 = fromDt;
    var strDate2 = toDt;

    var arr1 = strDate1.split('-');
    var arr2 = strDate2.split('-');
    
    var dat1 = new Date(arr1[0], arr1[1], arr1[2]);
    var dat2 = new Date(arr2[0], arr2[1], arr2[2]);
    
	var diff = dat2 - dat1;
    var currDay = 24 * 60 * 60 * 1000;

    var diffDate = parseInt(diff/currDay);
    
    return diffDate;
	
}

function fnGroupCbChange(selectId){
	
	var groupCb = "";
	for(var i=0; i<$("#"+selectId+" option").length; i++){
		var text  = $("#"+selectId+" option:eq("+i+")").text();
		//alert(text);
		//.replace("-|","&nbsp;&nbsp;&nbsp;&nbsp;").replace("-|","&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
		var value = $("#"+selectId+" option:eq("+i+")").val();
		groupCb += '<option value='+value+'>'+text+'</option>';	
	}
	
	$("#"+selectId).find("option").remove();
	$("#"+selectId).append(groupCb);
}


// yyyyMMddhhmmss 형식의 date format
//연도 yyyy 월 mm 일 dd 시간 hh 분 MM 초 ss
function stringNon_ToDateformat(str,type){
	type = type.replace("yyyy",str.substr(0,4));
	type = type.replace("mm",str.substr(4,2));
	type = type.replace("dd",str.substr(6,2));
	type = type.replace("hh",str.substr(8,2));
	type = type.replace("MM",str.substr(10,2));
	type = type.replace("ss",str.substr(12,2));
	
	return type;		
}

// IE 함수 설정
function util_Browser_Check(obj,type){
	var bwAgent = navigator.userAgent.toLowerCase();
	// true==IE : false==chrome||safari||...
	//rv:1 == IE11
	var browser = bwAgent.indexOf("msie") != -1 || bwAgent.indexOf("rv:1")!=-1 ? true : false;
	
	// remove
	if(type == "rm" && browser){
		obj.parentNode.removeChild(obj);
	}else if (type == "rm" && !browser){
		obj.remove();
	
	// dropdown
	// chrome , safari ...  브라우저 "파일을 끌어 올려주세요."
	}else if (type == "dropdownStr" && browser){
		$(obj).text("파일을 선택해주세요.");
	
	
	// 파일 배열 푸시
	}else if (type == "filePush" && bwAgent.indexOf("msie") != -1 ){
		var pFiles = [];
		var map = {};
		map.name = $(obj).val();
		map.size = 0;
		pFiles.push(map);
		return pFiles;
	}else if(type == "filePush" && !browser){
		var pFiles = [];
		pFiles.push($(obj)[0].files);
		return pFiles;
	}
	
	
}
