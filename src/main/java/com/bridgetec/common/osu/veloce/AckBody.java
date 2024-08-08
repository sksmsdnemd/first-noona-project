package com.bridgetec.common.osu.veloce;


public interface AckBody extends Body {

	public String getResult();
	public String getMsg();
	
	public void setResult(String result);
	public void setMsg(String msg);
}
