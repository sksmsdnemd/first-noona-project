package egovframework.com.cmm.service;

/**
 *  Class Name : Globals.java
 *  Description : 시스템 구동 시 프로퍼티를 통해 사용될 전역변수를 정의한다.
 *  Modification Information
 *
 *     수정일         수정자                   수정내용
 *   -------    --------    ---------------------------
 *   2009.01.19    박지욱          최초 생성
 *
 *  @author 공통 서비스 개발팀 박지욱
 *  @since 2009. 01. 19
 *  @version 1.0
 *  @see
 *
 */

public class Globals {

    //property path
    //public static final String CLIENT_CONF_PATH     = EgovProperties.getPathProperty("Globals.ClientConfPath");

    //IDS
    public static String IDS_IP()           {return EgovProperties.getProperty("Globals.IdsIp");}
    public static String IDS_PORT()         {return EgovProperties.getProperty("Globals.IdsPort");}
    public static String IDS_TIMOUT()       {return EgovProperties.getProperty("Globals.IdsTimout");}    
    
    //SVR
    public static String SVR_IP()           {return EgovProperties.getProperty("Globals.SvrIp");}
    public static String SVR_PORT()         {return EgovProperties.getProperty("Globals.SvrPort");}
    public static String SVR_TIMOUT()       {return EgovProperties.getProperty("Globals.SvrTimout");}
    
    //R
    public static String R_IP()             {return EgovProperties.getProperty("Globals.RIp");}
    public static String R_PORT()           {return EgovProperties.getProperty("Globals.RPort");}
    public static String R_TIMOUT()         {return EgovProperties.getProperty("Globals.RTimout");}
    
    //WS
    public static String WS_IP()             {return EgovProperties.getProperty("Globals.WsIp");}
    public static String WS_PORT()           {return EgovProperties.getProperty("Globals.WsPort");}
    
    //FILE UPLOAD/DOWNLOAD PATH
    public static String DOWNLOAD_PATH()    {return EgovProperties.getProperty("Globals.path.download");}
    public static String UPLOAD_PATH()      {return EgovProperties.getProperty("Globals.path.upload");}

    //암호화방식
    public static String SECURITY_TYPE()    {return EgovProperties.getProperty("Globals.SecurityType");}
    
    public static String VELOCESALT_TYPE()    {return EgovProperties.getProperty("Globals.encryptSalt");}
    public static String VELOCESEC_TYPE()    {return EgovProperties.getProperty("Globals.encryptType");}
    public static String VELOCELIST_TYPE()    {return EgovProperties.getProperty("Globals.encryptList");}
    
    //카테고리 실제 운영 댑스
    public static String CATEGORY_DEPTH()   {return EgovProperties.getProperty("Category.REAL.Depth");}
    
    // (2023.08.22) Globals 프로퍼티 추가 (REC_TABLE_TYPE) (HAGUANGHO)
    public static String REC_TABLE_TYPE()   {return EgovProperties.getProperty("Globals.REC.TABLE.TYPE");}
    
}

