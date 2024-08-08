/***********************************************************
 * argo.basic.js
 * 
 * CREATE BY lmk872  2016-12-08   
 * Argo WEB  기본 스크립트
 * 
 ***********************************************************/
var gGlobal = {
	ROOT_PATH: "/BT-VELOCE",
    SVC_ARGO_PATH: "/ARGOCONTROL.do", 
    SVC_ARGO_UPATH: "/ARGOFILEUPLOAD.do", 
    SVC_ARGO_DPATH: "/ARGODYNAMIC.do",
    SVC_DB_ARGODB: "ARGODB", 
    SVC_IF_TCP: "ARGOTCP", 
        
    SVC_PARAM_SVCIDS: "svcIds",  
    SVC_COMMON_ID: "SVCCOMMONID",  
    SVC_TOT_CNT: "totCnt",
    SVC_PROC_CNT: "procCnt", 
    SVC_OUT_TYPE: "outType", 
    SVC_OUT_NAME: "outName",
        
    SVC_DB_TYPE_INSERT: "I", 
    SVC_DB_TYPE_UPDATE: "U", 
    SVC_DB_TYPE_DELETE: "D", 
    SVC_DB_TYPE_BULK: "B",
    SVC_DB_TYPE_SELECT: "S", 
    SVC_DB_TYPE_LIST: "L", 
    SVC_DB_TYPE_PROCEDURE: "P", 
    SVC_IF_TYPE_IDS: "IDS", 
    SVC_IF_TYPE_SVR: "SVR",
    SVC_IF_TYPE_R: "R",
        
    RESULT_CODE: "resultCode",
    RESULT_MSG: "resultMsg",
    RESULT_SUB_CODE: "resultSubCode",
    RESULT_SUB_MSG: "resultSubMsg",
    RESULT_SVC_ROWS: "rows",
     
    SYSTEM_ID: "2000000001"
  // ,FILE_PATH : "/bridgetec/argo/was/filedata/upload/" 	
	// #screen listening ON=1,OFF=0
	// Globals.VLC.SCREEN.listen=0
	//,VLC_SCREEN_LISTEN : "0"   
};

var gMenuRows ; // 로그인 사용자 메뉴 데이터

var gServerDt =''; //DB서버시간

//현재 Active 된 메뉴에 대한 정보
var gMenu = {
	 SYSTEM_KIND:""
	,SYSTEM_KIND_NM:""
	,GROUP_NM:""
	,PGM_ID:""  //현재 페이지ID
	,PGM_NM:""	
	,PGM_PATH:""
	,EDIT_GRANT:"" //현재 페이지 권한코드
	,SCOPE_KIND:"" //현재 페이지 접근권한
	,GRANT_DEPT_CD:"" //현재 페이지 접근권한 부서
	,EXCEL_GRANT:""	
};

//로그인 사용자의 정보를 담고 있는 변수
var gLoginUser = {
     CENTER_CD:""
	,CENTER_NM:""
	,PART_CD:""
	,PART_NM:""			
	,TEAM_CD:""
	,TEAM_NM:""		
	,DEPT_CD:""
	,DEPT_NM:""
	,AGENT_ID:""
	,AGENT_NM:""	
	,AGENT_JIKGUP:""
	,AGENT_JIKCHK:""
	,SABUN:""	
	// 로그인 사용자의 해당 소속조직의 하위 조직을 포함한 	변수
    ,CENTER_CDS:""
   	,PART_CDS:""
    ,TEAM_CDS:""		
	,DEPT_PATH_CD:""
	,DEPT_PATH_NM:""
};

//환경설정값 - 로그인 후 데이터 조회하여 처리됨.
var gConfig = {
	CENTER: "센터"
    ,IS_CENTER: true
    ,PART: "파트"
    ,IS_PART: true   
    ,TEAM: "팀"
    ,IS_TEAM: true	     	
    ,JO: "조"
    ,IS_JO: true   
    ,SABUN: "사번"
    ,IS_SABUN:true   	
    ,AGENT_NM: "상담사명"
    ,IS_AGENT_NM:true     
    ,JIKGUP: "직급"
    ,IS_JIKGUP:true 
    ,JIKCHK: "직책"
    ,IS_JIKCHK:true
    ,PW_COMBI_YN:"0" /* 암호복잡도 설정 */
    ,PW_INIT:"0"    /* 암호초기화  0(행번)/1(생년월일)/2(사용자정의)*/
    ,PW_INIT_TXT:""	/* 암호초기화 설정값*/
    ,DI_TEL_TYPE:"0" /* 개인정보(전화번호) 표시타입  010-1234-1234 / 010-****-1234 / 010-1234-**** */	
    ,DI_RNO_TYPE:"0" /* 개인정보(실명번호) 표시타입  830720-1234567 / 830720-1******    */		
};