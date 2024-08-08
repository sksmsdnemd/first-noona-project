package com.bridgetec.argo.vo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import com.bridgetec.argo.common.Constant;

public class ArgoDispatchServiceVo implements Serializable {
    private String svcId;                   //서비스아이디
    private String svcName;                 //서비스명
    private String svcType;                 //서비스타입
    private String dbType;                  //DB거래타입
    private String methodName;              //실행함수아이디
    private String outType;
    private String outName;
    
    private Map<String, Object> reqInput;   //요청파라미터맵
    
    private int proCnt;                     //처리건수(현재조회건수)
    private long totCnt;                    //총데이터건수
    private Object resOut;                  //결과리스트맵
    
    private long accessId;                  //작업이력 아이디 
    private int svcSeq;                     //작업순번
    private int systemId;
    private StringBuffer logParam;          //로그에 남길 파라미터 내용
    private StringBuffer logTr;             //로그에 남길 IN/OUT 전문
    private String resultCode;              //처리결과코드(9999:진행중, 0000:정상, XXXX:오류코드)
    private String resultMsg;               //오류시메시지
    
    private long idsAccessId;               //IDS용 최종 거래 아이디
    
    public ArgoDispatchServiceVo(String svcId) {
        this.svcId = svcId;
        this.reqInput = new HashMap<String, Object>();
    }
    public String getSvcId() {
        return this.svcId;
    } 
    public String getSvcName() {
        return this.svcName;
    }
    public void setSvcName(String svcName) {
        this.svcName = svcName;
    }
    public String getSvcType() {
        return this.svcType;
    }
    public void setSvcType(String svcType) {
        this.svcType = svcType;
    }
    public String getDbType() {
        return this.dbType;
    }
    public void setDbType(String dbType) {
        this.dbType = dbType;
    }
    public String getMethodName() {
        return this.methodName;
    }
    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }
    public String getOutType() {
        return this.outType;
    }
    public void setOutType(String outType) {
        this.outType = outType;
    }
    public String getOutName() {
        return this.outName;
    }
    public void setOutName(String outName) {
        this.outName = outName;
    }
    public String getParamPrefixName() {
        return this.svcId + Constant.STR_DOT; 
    }
    public Map<String, Object> getReqInput() {
        return this.reqInput;
    }
    public void setReqInput(Map<String, Object>  reqInput) {
        this.reqInput = reqInput;
    }
    public Object getResOut() {
        return this.resOut;
    }
    public void setResOut(Object resOut) {
        this.resOut = resOut;
    }
    public String getQueryId() {
        return this.svcName + "." + this.methodName;
    }
    public int getProCnt() {
        return this.proCnt;
    }
    public void setProCnt(int proCnt) {
        this.proCnt = proCnt;
    }
    public long getTotCnt() {
        return this.totCnt;
    }
    public void setTotCnt(long totCnt) {
        this.totCnt = totCnt;
    }
    
    //로그관련 필드접근
    public long getAccessId() {
        return this.accessId;
    }
    public void setAccessId(long accessId) {
        this.accessId = accessId;
    }
    public int getSvcSeq() {
        return this.svcSeq;
    }
    public void setSvcSeq(int svcSeq) {
        this.svcSeq = svcSeq;
    }
    public int getSystemId() {
        return this.systemId;
    }
    public void setSystemId(int systemId) {
        this.systemId = systemId;
    }
    public String getLogParam() {
        if(logParam != null) return logParam.toString();
        else return "";
    }
    public void addLogParam(String name, String value) {
        if(logParam == null) {
            logParam = new StringBuffer();
        }else {
            logParam.append("\n");
        }
        
        if(value!=null){
            if(name.startsWith("encryptPw")) value = "********"; 
        }
        
        logParam.append(name)
            .append(" : ")
            .append(value);
    }
    public String getLogTr() {
        if(logTr != null) return logTr.toString();
        else return "";
    }
    public void addLogTr(String name, String value) {
        if(logTr == null) {
            logTr = new StringBuffer();
        }else {
            logTr.append("\n");
        }

        logTr.append(name)
            .append(" : ")
            .append(value);
    }    
    public String getResultCode() {
        return this.resultCode;
    }
    public void setResultCode(String resultCode) {
        this.resultCode = resultCode;
    }
    public String getResultMsg() {
        return this.resultMsg;
    }
    public void setResultMsg(String resultMsg) {
        this.resultMsg = resultMsg;
    }
    
    public  String getUserId() {
        String userId = null;
        if(this.reqInput != null) {
            if (reqInput.get("glo_userId") != null) {
                userId = (String) reqInput.get("glo_userId");
            }
        }
        return userId;
    }
    
    public long getGrantId() {
        if (this.reqInput != null) {
            if (reqInput.get("glo_grantId") != null) {
                return ((BigDecimal) reqInput.get("glo_grantId")).longValue();
            }
        }

        return 0;       
    }
    
    public long getIdsAccessId() {
        return this.idsAccessId;
    }
    public void setIdsAccessId(long idsAccessId) {
        this.idsAccessId = idsAccessId;
    }    
    
    public String getUserSabun(){
        if(this.reqInput != null) {
            String userSabun = (String) reqInput.get("glo_userSabun");
            if(userSabun != null)
                return userSabun;
        }
        return "";        
    }
    
}
