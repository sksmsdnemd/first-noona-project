﻿<%@ page import="java.util.*,java.text.*,java.lang.*"%>
<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="egovframework.rte.fdl.string.EgovStringUtil" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript">

$(document).ready(function() {

	var agent = navigator.userAgent.toLowerCase();
	
	/* 브라우저에 따른 플레이어 show */
	if ( (navigator.appName == 'Netscape' && agent.indexOf('trident') != -1) || (agent.indexOf("msie") != -1)) {
		// IE
		$('#IE_Player').show();
	}else{
		// IE 아닐 경우
		$('#CH_Player').show();
	};
	
});
	
<%
	request.setCharacterEncoding("UTF-8");

	String tenantId   = EgovStringUtil.null2void(request.getParameter("tenantId"));
	String callId     = EgovStringUtil.null2void(request.getParameter("callId"));
	String agentId    = EgovStringUtil.null2void(request.getParameter("agentId"));    
	String serverIp   = EgovStringUtil.null2void(request.getParameter("serverIp"));
	String serverPort = EgovStringUtil.null2void(request.getParameter("serverPort"));
	
	String strHASH_TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	String strKey = "BRIDGETEC_VELOCE";
	 
	java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("ssmmMMyyyyddHH");
	String strTime = formatter.format(new java.util.Date());
 
	int nKeyLen = callId.length();
	int nKeyTableSize = strHASH_TABLE.length();
 
	while(strKey.length() < nKeyLen){
		strKey = strKey + strKey;
	}

	while(strTime.length() < nKeyLen){
		strTime = strTime + strTime;
	}
	
	char chKey;
	char chTime;
	char chUcid;
	char chEncKey;
		
	int nChar;
	char [] szEncKey = new char[nKeyLen];

	for(int i=0; i < nKeyLen; i++)
	{
		chKey = strKey.charAt(i);	    
		chTime = strTime.charAt(i);	    
		chUcid = callId.charAt(i);	    
		int nKey = (int)chKey;
		int nTime = (int)chTime;
		int nUcid = (int)chUcid;
		
		if(nUcid >= 0 && nKey >= 0 && nTime >= 0 && nKeyTableSize >= 0) {
			nChar = (int)((nUcid + nKey + nTime) % nKeyTableSize);
		} else {
			nChar = 0;
		}
		
		chEncKey = strHASH_TABLE.charAt(nChar);	 
		
		szEncKey[i] = chEncKey;
	}

	String strEncKey = new String(szEncKey);
  
	String strURL = "http://" + serverIp + ":" + serverPort + "/fileplay?call_id=" + callId + "&user_id=" + agentId + "&tenant_id=" + tenantId + "&rec_key=" + strEncKey;
%>  

</script>
</head>

<body>

	<!-- IE -->
    <object id="IE_Player" classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6" width="320" height="120" style="display: none;">
		<param name="autoStart" value="True">
		<param name="URL" value="<%=strURL%>">
		<param name="stretchToFit" value="true">
    </object>
	
	<!-- IE 아닐 경우 -->    
	<audio id="CH_Player" style="display: none;" controls autoplay>
		<source src="<%=strURL%>" type="audio/wav">
		<source src="<%=strURL%>" type="audio/ogg">
	</audio>
	
</body>
</html>