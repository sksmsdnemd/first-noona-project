<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.util.*" %>
<%@page import="java.security.*" %>
<%@page import="java.math.*" %>
<%@page import="java.io.*" %>
<%@page import="org.springframework.context.*" %>
<%@page import="org.springframework.context.annotation.*" %>
<%@page import="org.springframework.web.servlet.support.*" %>
<%@page import="org.springframework.beans.factory.annotation.*"%>
<%@page import="org.springframework.web.context.support.*"%>
<%@page import="com.bridgetec.argo.common.*" %>
<%@page import="com.bridgetec.argo.vo.*" %>
<%@page import="com.bridgetec.argo.service.*" %>
<%@page import="com.bridgetec.common.util.security.*" %>
<%!
	public void jspInit() {
	    SpringBeanAutowiringSupport.processInjectionBasedOnServletContext(this, getServletContext());
	}

	@Autowired
	ArgoDispatchServiceImpl 	argoDispatchServiceImpl;

%>
<%
	ArgoDispatchServiceVo saDispatchServiceVo = new ArgoDispatchServiceVo("SVCCOMMONID");
	saDispatchServiceVo.setSvcType("ARGODB");
	saDispatchServiceVo.setSvcName("mt");
	saDispatchServiceVo.setDbType("P");
	
	HashMap<String, Object> reqInput = new HashMap<String, Object>();
	
	String InTenantId		= request.getParameter("InTenantId");
	String InFlag			= request.getParameter("InFlag");
	String InAgentId		= request.getParameter("InAgentId");
	String InDeptCd			= request.getParameter("InDeptCd");
	String InAgentGrant		= request.getParameter("InAgentGrant");
	String InAgentNm		= request.getParameter("InAgentNm");
	String InAgentPw		= request.getParameter("InAgentPw");
	String InDnNo			= request.getParameter("InDnNo");
	String InTelephonIp		= request.getParameter("InTelephonIp");
	String InVeloceSystem	= request.getParameter("InVeloceSystem");
	String InVeloceProcess	= request.getParameter("InVeloceProcess");
	String RtnCode			= request.getParameter("RtnCode");
	String InDnRefNo		= request.getParameter("InDnRefNo");
	String RtnMsg			= request.getParameter("RtnMsg");
	
	reqInput.put("InFlag", InFlag);
	reqInput.put("InTenantId", InTenantId);
	reqInput.put("InAgentId", InAgentId);
	reqInput.put("InDeptCd", InDeptCd);
	reqInput.put("InAgentGrant", InAgentGrant);
	reqInput.put("InAgentNm", InAgentNm);
	
	//비밀번호 암호화
	EncryptUtil encp 		= new EncryptUtil();
	byte[] 		bSalt		= encp.getSaltData();
	byte[] 		bDigest		= encp.getEncSaltData("SHA-512", "kjb2395001*", bSalt, false);
	String 		salt		= encp.byteToBase64(bSalt);
	String 		InAgentPw1	= encp.byteToBase64(bDigest);
	
// 	System.out.println(InAgentPw1);
	
	try {
	    MessageDigest digest = MessageDigest.getInstance("SHA-512");
	    digest.reset();
	    digest.update("kjb2395001*".getBytes("utf8"));
	    String InAgentPw2 = String.format("%040x", new BigInteger(1, digest.digest()));
// 	    System.out.println(InAgentPw2);
	    
	} catch (NoSuchAlgorithmException nsae) {
		System.out.println("Exception : " + nsae.toString());
	} catch (IllegalFormatException ife) {
		System.out.println("Exception : " + ife.toString());
	} catch (Exception e) {
		System.out.println("Exception : " + e.toString());
	}
	
	reqInput.put("InAgentPw", InAgentPw);
	reqInput.put("InDnNo", InDnNo);
	reqInput.put("InTelephonIp", InTelephonIp);
	reqInput.put("InVeloceSystem", InVeloceSystem);
	reqInput.put("InVeloceProcess", InVeloceProcess);
	reqInput.put("InDnRefNo", InDnRefNo);
	
	saDispatchServiceVo.setReqInput(reqInput);
	saDispatchServiceVo.setMethodName("setExUserInfoADD");
	
	List<ArgoDispatchServiceVo> svcList = new ArrayList<ArgoDispatchServiceVo>();
	svcList.add(saDispatchServiceVo);
	
	try 
	{
		argoDispatchServiceImpl.excute(svcList);
		String result	= saDispatchServiceVo.getResultCode();
		
		if (result != Constant.RESULT_CODE_OK)
			out.println("9999^");
		else
			out.println("0000^");
		
	}
	catch (MessageException e) 
	{
		System.out.println("Exception : " + e.toString());
	}
	
%>