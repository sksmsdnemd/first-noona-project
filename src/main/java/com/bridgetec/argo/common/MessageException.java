package com.bridgetec.argo.common;

import java.io.PrintStream;
import java.io.PrintWriter;
import java.sql.SQLException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;

import egovframework.com.cmm.EgovMessageSource;
import egovframework.rte.fdl.string.EgovStringUtil;

public class MessageException extends Exception {
    
    private static Logger loger = LoggerFactory.getLogger( MessageException.class );
    
    String code;
    String message;
    
    String subCode;
    String subMessage;
    
    Throwable throwable;

    private Object[] arguments;

    public MessageException(String code, Object... arguments) {
        this(new Exception(), code, arguments);
    }

    public MessageException(Throwable throwable, String code, Object... arguments) {
        this(throwable, code);
        this.arguments = arguments;
    }

    public MessageException(String code) {
        this(new Exception(), code);
    }

    public MessageException(Throwable throwable, String code) {
        this.code = code;
        this.throwable = throwable;
        if(throwable instanceof DataAccessException) {
            DataAccessException dae = (DataAccessException) throwable;
            
            if(dae.contains(SQLException.class)) {
                SQLException se = (SQLException)dae.getCause();
                subCode = String.valueOf(se.getErrorCode());
                subMessage = se.getMessage();
            }
        }
        
        if(subMessage == null) {
            subMessage = throwable.getMessage();
            
            //Exception 상세 PrintStackTarce log 기록. 2015.02.09. ADD
            loger.error("["+code+"] "+subMessage, throwable);
        }
        
    }
    
    public String getArgoCode() {
        return this.code;
    }
    
    public String getArgoMessage(EgovMessageSource egovMessageSource) {
        return EgovStringUtil.null2void(egovMessageSource.getMessage(this.code)); 
    }
    
    public String getMeessage() {
        return this.throwable.getMessage();
    }
    
    public String getSubCode() {
        return EgovStringUtil.null2void(this.subCode);
    }
    
    public String getSubMessage() {
        return EgovStringUtil.null2void(this.subMessage);
    }
    
    public void printStackTrace() {
        this.throwable.printStackTrace();
    }
    
    public void printStackTrace(PrintStream printStream) {
        this.throwable.printStackTrace(printStream);
    }
    
    public void printStackTrace(PrintWriter printWriter) {
        this.throwable.printStackTrace(printWriter);
    }
    
    public Throwable getException(){
        return this.throwable;
    }
    
    public void setUserMessage(String msg){
        this.subMessage = this.subMessage + msg;
    }

    public Object[] getArguments() {
        return arguments;
    }
}
