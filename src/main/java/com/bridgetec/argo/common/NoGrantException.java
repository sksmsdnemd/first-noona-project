package com.bridgetec.argo.common;

import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;

public class NoGrantException extends Exception implements java.io.Serializable {

    private static Exception exception;
    private String code;
    private String message;
    
    public  NoGrantException(){
        super();
    }
    
    public NoGrantException(String error)
    {
        super(error);
    }

    public NoGrantException(String errorCode, String error)
    {
        super(error);
        this.code = errorCode;
    }

    public NoGrantException(String errorCode, String errorMessage, String error)
    {
        super(error);
        this.code = errorCode;
        this.message = errorMessage;
    }

    public void setErrorCode(String errorCode)
    {
        this.code = errorCode;
    }

    public String getErrorCode()
    {
        return this.code;
    }

    public void setErrorMessage(String errorMessage)
    {
        this.message = errorMessage;
    }

    public String getErrorMessage()
    {
        return this.message;
    }
    
    public static Exception getRootCause() {
      if (exception instanceof NoGrantException) {
        return ((NoGrantException) exception).getRootCause();
      }
      return exception == null ? null : exception;
    }
  
  
}
