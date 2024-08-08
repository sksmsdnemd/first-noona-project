package com.bridgetec.argo.vo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import com.bridgetec.argo.common.Constant;

public class CertfyItgLoginVo implements Serializable {
   
	
	private String userId;                   //서비스아이디
    private String pwd;
    private String tenantId;
	private boolean pwdChk;
    
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getPwd() {
		return pwd;
	}
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
	public String getTenantId() {
		return tenantId;
	}
	public void setTenantId(String tenantId) {
		this.tenantId = tenantId;
	}
	public boolean isPwdChk() {
		return pwdChk;
	}
	public void setPwdChk(boolean pwdChk) {
		this.pwdChk = pwdChk;
	}
    
    
}