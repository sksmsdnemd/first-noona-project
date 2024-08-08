/***********************************************************
 * veloce.basic.js
 * 
 * CREATE BY yoonys  2018-10-10   
 * BT-VELOCE 추가적으로 생성되는 기본스크립트
 * 
 * FIXED BY yoonys 2018-11-05
 * SSO 디버깅모드 관련 옵션화
 * 
 * FIXED BY yoonys 2018-11-06
 * 문자열 NULL&공백값처리 함수 공용함수추가
 ***********************************************************/
var vlcOPT = {		
	//스크린청취 사용 ON=1,OFF=0	 
    VLC_SCREEN_LISTEN : "1",
    //SSO[신호 받기] 사용여부 ON=1,OFF=0(feat. 대구은행)
    VLC_SSO_IN_USE : "0",
    //SSO[신호 주기] 사용여부 ON=1,OFF=0(feat. 전북은행,initech)
    VLC_SSO_OUT_USE : "0",
    //SSO 디버깅모드 ON=1,OFF=0
    VLC_SSO_DEBUG : "0",
    //SSO 테넌트 아이디
    VLC_SSO_TENANT_ID : "bridgetec",
    //NonActiveX 재생시에 NAT구성 필터링 ON=1, OFF=0(feat. 농협멤버십)
    VLC_NAT_IP : "0",
    //로그입력 방식을 MFU로 한다 ON=1, OFF=0(feat. 전북은행)
    VLC_LOG_MFU : "1",
    //고객정보 일괄등록 기능 사용 ON=1, OFF=0 (feat.광주은행)
    VLC_CUST_ALL : "0",	
    //IE iframe 메모리 누수관련 메뉴바 카운트
    VLC_TAB_CNT : 5,
    //청취권한 그리드 출력 옵션
    VLC_ETC_GRANT_USE : "0",
    //통화내역조회 API옵션 (feat.삼천리)
    VLC_REC_API_USE : "1",
    //테넌트는 노출 비노출[VLC_SSO_TENANT_ID]와 상호여야함(feat.삼천리)
    // 1 이면 노출, 0이면 비노출
    VLC_TENANT_SHOW : "1"
};

var tempCurrentVal	= "";

function VLC_StringProc_NVL(val,retVal)
{
	var valProc = val;
	//.trim();
	if(valProc==''||valProc==""||valProc=='undefined'||
			valProc==undefined||valProc==null||valProc=='null'||valProc.length==0)
		{
			return retVal;
		}
	else
		{
			return val;
		}
}


function getXMLHttpRequest(){
	if(window.XDomainRequest){ //이거 쓰는게 IE 8, 9, 10밖에 없으니 처음부터 체크해봅시다 -_-
			try{
					return new XDomainRequest();
			}catch(e){
					try{ //어? 아닌가? 아니였어??
							return new ActiveXObject("Msxml2.XMLHTTP");
					}catch(e){
							try{
									return new ActiveXObject("Microsoft.XMLHTTP");
							}catch(e1) {
									return null;
							}
					}
			}
	}else if(window.ActiveXObject){ // IE 5, 6, 7
			try{
					return new ActiveXObject("Msxml2.XMLHTTP");
			}catch(e){
					try{
							return new ActiveXObject("Microsoft.XMLHTTP");
					}catch(e1) {
							return null;
					}
			}
	}else if(window.XMLHttpRequest){ // Other
	//alert("XMLHttpRequest");
			return new XMLHttpRequest();
	}else{
			return null;
	}
}