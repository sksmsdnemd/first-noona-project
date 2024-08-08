package com.bridgetec.argo.common;


public class Constant {
    
//    public static final String ROOT_PATH                        = "";               //application path 
    public static final String ROOT_PATH                        = "/BT-VELOCE";               //application path
	private static final String ME_SHARED_KEY = "BRIDGETEC_VELOCE"; // 암복호화 키
//    public static final int ME_SHARED_BIT                      = 128;                      //암복호화 키를 몇 BIT함수화키로 설정할지 (128,192,256 지원)
    public static final int ME_SHARED_BIT                      = 256;                      //암복호화 키를 몇 BIT함수화키로 설정할지 (128,192,256 지원)

    private static final int RSA_KEY_SIZE                       = 2048;                     //RSA 키 SIZE (브라우저-WAS간 사용)
    
	public static final String SVC_DB_ARGODB = "ARGODB"; // RDB

	public static final String SVC_IF_TCP = "ARGOTCP";

    
    public static final String SVC_COMMON_ID                    = "SVCCOMMONID";
    public static final String SVC_PARAM_SVCIDS                 = "svcIds";
    public static final String SVC_POSTFIX_NAME                 = ".svcName";
    public static final String SVC_POSTFIX_TYPE                 = ".svcType";
    public static final String SVC_POSTFIX_DB_TYPE              = ".dbType";    
    public static final String SVC_POSTFIX_METHOD_NAME          = ".methodName";
    public static final String SVC_POSTFIX_IN_PREFIX_NAME       = ".inPrefixName";
	public static final String SVC_POSTFIX_OUT_TYPE = ".outType";
	public static final String SVC_POSTFIX_OUT_NAME = ".outName";
    
	public static final String SVC_ARGO_PATH = "/ARGOCONTROL.do";
	public static final String SVC_FILE_UPLOAD_PATH = "/ARGOFILEUPLOAD.do";
	public static final String SVC_ARGO_DYNAMIC_PATH = "/ARGODYNAMIC.do";
    
    public static final String SVC_DB_TYPE_INSERT               = "I";
    public static final String SVC_DB_TYPE_BULK_INSERT          = "B";
    public static final String SVC_DB_TYPE_UPDATE               = "U";
    public static final String SVC_DB_TYPE_DELETE               = "D";
    public static final String SVC_DB_TYPE_SELECT               = "S";
    public static final String SVC_DB_TYPE_PROCEDURE       = "P";
    public static final String SVC_DB_TYPE_LIST                 = "L";
	public static final String SVC_IF_TYPE_IDS = "IDS";
	public static final String SVC_IF_TYPE_SVR = "SVR";
	public static final String SVC_IF_TYPE_R = "R";
    
    public static final String RESULT_CODE                      = "resultCode";
    public static final String RESULT_MSG                       = "resultMsg";
    public static final String RESULT_SUB_CODE                  = "resultSubCode";
    public static final String RESULT_SUB_MSG                   = "resultSubMsg";
    public static final String RESULT_SVC_ROWS                  = "rows";
    
    public static final String SVC_TOT_CNT                      = "totCnt";
    public static final String SVC_PROC_CNT                     = "procCnt";
    public static final String SVC_OUT_TYPE                     = "outType";
    public static final String SVC_OUT_NAME                     = "outName";
    
    public static final String STR_UNDERLINE                    = "_";
    public static final String STR_DOT                          = ".";
    public static final String STR_METHOD_MNG						   = "MNG";
    
    //excel import용 List의 이름.
    public static final String EXCEL_IMPORT_DATA                = "excelData";
    
    //for Argo code (2016.12.26 lmk872)
    public static final String RESULT_CODE_OK                   = "0000";
    public static final String RESULT_CODE_ERR_INSERT           = "0001";
    public static final String RESULT_CODE_ERR_UPDATE           = "0002";
    public static final String RESULT_CODE_ERR_DELETE           = "0003";
    public static final String RESULT_CODE_ERR_SELECT           = "0004";
    public static final String RESULT_CODE_ERR_PROC             = "0005";
    public static final String RESULT_CODE_ERR_ROLLBACK         = "0006";
    public static final String RESULT_CODE_ERR_BULK_INSERT      = "0007";
    public static final String RESULT_CODE_ERR_CALLSP           = "0008";
    public static final String RESULT_CODE_NO_GRANT             = "0021";
    public static final String RESULT_CODE_READ_GRANT           = "0022";
    public static final String RESULT_CODE_ERR_UPLOAD           = "0051";
    public static final String RESULT_CODE_ERR_FILESIZE         = "0052";
    public static final String RESULT_CODE_ERR_UNKNOW_HOST      = "0101";
    public static final String RESULT_CODE_ERR_RETURN           = "0102";
    public static final String RESULT_CODE_ERR_TIMEOUT          = "0103";
    public static final String RESULT_CODE_ERR_CUT              = "0104";
    public static final String RESULT_CODE_ERR_IO               = "0105";
    public static final String RESULT_CODE_ERR_EXCEPTION        = "0106";
    public static final String RESULT_CODE_ERR_RECV             = "0107";
    
    //SYSTEM관리자ID (TB_CC_GRANTMASTER TABLE 참고)
    public static final String SYSTEM_GRANT_ID                  = "2000000001";     
    
    //for dynamic query.
	public static final String ARGO_COMMON_SVR = "ARGOCOMMON";
	public static final String ARGO_METHOD_LOGIN = "login";
	public static final String ARGO_METHOD_DML_SELECT = "selectSql";
	public static final String ARGO_METHOD_DML_CUD = "updateSql";

    public static final String SESSION_ATTR_LOGIN = "sessionMAP";

    
    //for IDS.
    public static final String HEADER_STX                       = "iDML";
    public static final String HEADER_VER01                     = "01";    
    public static final String COMMOND_MDFY                     = "MDFY";
    
    
    public static String getRootPath() {    	
        return ROOT_PATH;
    }

    public static String getSharedKey() {
        return ME_SHARED_KEY;
    }
    
    public static int getSharedKeyBit() {
        return ME_SHARED_BIT;
    }
    
    public static int getRSAKeySize(){
        return RSA_KEY_SIZE;
    }

}