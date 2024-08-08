<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.util.*" %>
<%@page import="java.security.*" %>
<%@page import="java.math.*" %>
<%@page import="java.io.*" %>
<%@page import="java.net.*" %>
<%@page import="org.springframework.context.*" %>
<%@page import="org.springframework.context.annotation.*" %>
<%@page import="org.springframework.web.servlet.support.*" %>
<%@page import="org.springframework.beans.factory.annotation.*"%>
<%@page import="org.springframework.web.context.support.*"%>
<%@page import="com.bridgetec.argo.common.*" %>
<%@page import="com.bridgetec.argo.vo.*" %>
<%@page import="com.bridgetec.argo.service.*" %>
<%@page import="com.bridgetec.common.util.security.*" %>
<%@page import="com.bridgetec.common.util.veloce.*" %>
<%@page import="com.bridgetec.common.SortProperties" %>
<%@page import="egovframework.com.cmm.service.EgovProperties" %>
<%!
	public void jspInit() {
	    SpringBeanAutowiringSupport.processInjectionBasedOnServletContext(this, getServletContext());
	}

	@Autowired
	ArgoDispatchServiceImpl 	argoDispatchServiceImpl;

%>
<%
	request.setCharacterEncoding("utf-8");

	ArgoDispatchServiceVo saDispatchServiceVo = new ArgoDispatchServiceVo("SVCCOMMONID");
	saDispatchServiceVo.setSvcType("ARGODB");
	saDispatchServiceVo.setSvcName("mt");
	saDispatchServiceVo.setDbType("P");
	
	HashMap<String, Object> reqInput = new HashMap<String, Object>();
	
	String cmd = StringUtility.nvl(request.getParameter("cmd"), "1");
	
	if("1".equals(cmd)) {
		String InCallId		= request.getParameter("call_id");
		String InCustTel	= request.getParameter("cust_tel");
		String InCustNo		= request.getParameter("cust_no");
		String InCustName	= request.getParameter("cust_name");
		String InTransTel	= request.getParameter("trans_tel");
		String InCallKind	= request.getParameter("call_kind");
		String InCustEtc1	= request.getParameter("cust_etc1");
		String InCustEtc2	= request.getParameter("cust_etc2");
		String InCustEtc3	= request.getParameter("cust_etc3");
		String InCustEtc4	= request.getParameter("cust_etc4");
		String InCustEtc5	= request.getParameter("cust_etc5");
		String InCustEtc6	= request.getParameter("cust_etc6");
		String InCustEtc7	= request.getParameter("cust_etc7");
		String InCustEtc8	= request.getParameter("cust_etc8");
		String InCustEtc	= InCustEtc1 + "|C" + InCustEtc2 + "|C" + InCustEtc3 + "|C" + InCustEtc4 + "|C" + InCustEtc5 + "|C" + InCustEtc6 + "|C" + InCustEtc7 + "|C" + InCustEtc8 + "|C";
		
		reqInput.put("InCallId", InCallId);
		reqInput.put("InCustName", InCustName);
		reqInput.put("InCustTel", InCustTel);
		reqInput.put("InCustNo", InCustNo);
		reqInput.put("InTransTel", InTransTel);
		reqInput.put("InCustEtc", InCustEtc);
		reqInput.put("InCallKind", InCallKind);
		
		saDispatchServiceVo.setMethodName("setCustInfoADD");
	} else if("4".equals(cmd)) {
		String InTenantId		= StringUtility.nvl(request.getParameter("tenantId"), "");
		String InUserId			= StringUtility.nvl(request.getParameter("userId"), "");
		String InGroupId		= StringUtility.nvl(request.getParameter("groupId"), "");
		String InGrantId		= StringUtility.nvl(request.getParameter("grantId"), "");
		String InUserName		= StringUtility.nvl(request.getParameter("userName"), "");
		String InUserPwd		= StringUtility.nvl(request.getParameter("userPwd"), "");
		String InEncryptFlag	= StringUtility.nvl(request.getParameter("encryptFlag"), "");
		
		reqInput.put("InTenantId", InTenantId);
		reqInput.put("InUserId", InUserId);
		reqInput.put("InGroupId", InGroupId);
		reqInput.put("InGrantId", InGrantId);
		reqInput.put("InUserName", InUserName);
		
		String encryptPwd = "";
		String salt = "";
		if(!"".equals(InUserPwd)) {
			String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
			SortProperties properties = new SortProperties();
			properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
			String SHA_TYPE = StringUtility.nvl(properties.getProperty("Globals.encryptType").trim(), "SHA-256");
			
			EncryptUtil eu = new EncryptUtil();
			
			byte[] bSalt = eu.getSaltData();
			byte[] bDigest = eu.getEncSaltData(SHA_TYPE, InUserPwd, bSalt, false);
			
			salt = eu.byteToBase64(bSalt);
			encryptPwd = eu.byteToBase64(bDigest);
		}
		reqInput.put("encryptPwd", encryptPwd);
		reqInput.put("salt", salt);
		
		reqInput.put("retireeFlag", "1");
		reqInput.put("accessFlag", "0");
		reqInput.put("insId", "external");
		
		saDispatchServiceVo.setMethodName("setExUserInfoInsert");
	} else if("6".equals(cmd)) {
		String InFlag			= StringUtility.nvl(request.getParameter("InFlag"), "");
		String InTenantId		= StringUtility.nvl(request.getParameter("InTenantId"), "");
		String InAgentId		= StringUtility.nvl(request.getParameter("InAgentId"), "");
		String InDeptCd			= StringUtility.nvl(request.getParameter("InDeptCd"), "");
		String InAgentGrant		= StringUtility.nvl(request.getParameter("InAgentGrant"), "");
		String InAgentNm		= StringUtility.nvl(request.getParameter("InAgentNm"), "");
		String InAgentPw		= StringUtility.nvl(request.getParameter("InAgentPw"), "");
		String InDnNo			= StringUtility.nvl(request.getParameter("InDnNo"), "");
		String InTelephonIp		= StringUtility.nvl(request.getParameter("InTelephonIp"), "");
		String InVeloceSystem	= StringUtility.nvl(request.getParameter("InVeloceSystem"), "");
		String InVeloceProcess	= StringUtility.nvl(request.getParameter("InVeloceProcess"), "");
		String InDnRefNo		= StringUtility.nvl(request.getParameter("InDnRefNo"), "");
		String encryptFlag		= StringUtility.nvl(request.getParameter("encryptFlag"), "");
		
System.out.println(">>>>> InAgentNm : " + InAgentNm);
		String paramsTmp = request.getQueryString();
System.out.println(">>>>> paramsTmp de : " + URLDecoder.decode(paramsTmp));
		
		Map<String, String> map = new HashMap<String, String>();
		String[] tmpMap = paramsTmp.split("&");
// System.out.println(">>>>> tmpMap : " + tmpMap.length);
		
		for(int i = 0; i < tmpMap.length; i++) {
			String key = tmpMap[i].split("=")[0];
			String value = tmpMap[i].split("=")[1];
System.out.println(">>>>> key : " + key);
System.out.println(">>>>> value : " + value);
			
			map.put(key, value);
		}
		
System.out.println(">>>>> map : " + map);

System.out.println(">>>>> map InAgentNm dde : " + URLDecoder.decode(map.get("InAgentNm"), "UTF-8"));




// System.out.println(">>>>> paramsTmp : " + paramsTmp);
System.out.println(">>>>> InAgentNm : " + InAgentNm);

// 		String paramsTmp_decode = URLDecoder.decode(map.get("InAgentNm"));
// System.out.println(">>>>> paramsTmp_decode : " + paramsTmp_decode);
// System.out.println(">>>>> kk : " + new String(InAgentNm.getBytes("ISO-8859-1"), "utf-8"));
		
		
// System.out.println(">>>>> InTenantId : " + InTenantId);
// System.out.println(">>>>> InAgentNm : " + InAgentNm);
		
		
		
		
		reqInput.put("InFlag", InFlag);
		reqInput.put("InTenantId", InTenantId);
		reqInput.put("InAgentId", InAgentId);
		reqInput.put("InDeptCd", InDeptCd);
		reqInput.put("InAgentGrant", InAgentGrant);
		reqInput.put("InAgentNm", InAgentNm);
		
		String encAgentPw = "";
		if(!"".equals(InAgentPw)) {
			String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
			SortProperties properties = new SortProperties();
			properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
			String encryptType = StringUtility.nvl(properties.getProperty("Globals.encryptType").trim(), "MD5");
			
			String chgEncType = (encryptFlag == null || "".equals(encryptFlag))?encryptType:encryptFlag;
			
			EncryptUtil eu = new EncryptUtil();
			encAgentPw = eu.encrypt(chgEncType, InAgentPw);
		}
		reqInput.put("InAgentPw", encAgentPw);
		
		reqInput.put("InDnNo", InDnNo);
		reqInput.put("InTelephonIp", InTelephonIp);
		reqInput.put("InVeloceSystem", InVeloceSystem);
		reqInput.put("InVeloceProcess", InVeloceProcess);
		reqInput.put("InDnRefNo", InDnRefNo);
		
		saDispatchServiceVo.setMethodName("setExUserInfoADD_OLD");
	}
	
// 	saDispatchServiceVo.setReqInput(reqInput);
	
// 	List<ArgoDispatchServiceVo> svcList = new ArrayList<ArgoDispatchServiceVo>();
// 	svcList.add(saDispatchServiceVo);
	
// 	try {
// 		argoDispatchServiceImpl.excute(svcList);
// 		String result	= saDispatchServiceVo.getResultCode();
		
// 		if (result != Constant.RESULT_CODE_OK) {
// 			out.println("9999^");
// 		} else {
// 			out.println("0000^");
// 		}
		
// 	} catch (MessageException e) {
// 		e.printStackTrace();
// 	}
	
%>