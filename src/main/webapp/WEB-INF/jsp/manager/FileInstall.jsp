<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ page import="java.util.Date"%>
<%@ page import="org.apache.commons.codec.binary.Base64"%>
<%@ page import="javax.crypto.Mac"%>
<%@ page import="javax.crypto.spec.SecretKeySpec"%>
<%@ include file="/WEB-INF/jsp/include/common.jsp"%>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
	
	<link rel="stylesheet" href="<c:url value="/css/veloce.fileInstall.css"/>" type="text/css" />
<%
String space = " ";					// one space
String newLine = "\n";					// new line
String method = "GET";					// method
String url = "/vmysql/v2/getCloudMysqlDatabaseList?regionCode=KR&cloudMysqlInstanceNo=1219446&pageNo=0&pageSize=10";	// url (include query string)
// String timestamp = timestamp;			// current timestamp (epoch)
String timestamp = String.valueOf(new Date().getTime());			// current timestamp (epoch)
System.out.println(">>>>> timestamp : " + timestamp);
String accessKey = "uY3Yowh9W9sWFGoeaJFR";			// access key id (from portal or sub account)
String secretKey = "vdDhVjgWHQ0QOms09tuiuzi9zxPS7NWp48PQYoRN";
// String accessKey = "E9EA6052FB905CFCD193";			// access key id (from portal or sub account)
// String secretKey = "36D0FDB7F524158E90C5981036A26DCAD50BAFB2";

String message = new StringBuilder()
	.append(method)
	.append(space)
	.append(url)
	.append(newLine)
	.append(timestamp)
	.append(newLine)
	.append(accessKey)
	.toString();

SecretKeySpec signingKey = new SecretKeySpec(secretKey.getBytes("UTF-8"), "HmacSHA256");
Mac mac = Mac.getInstance("HmacSHA256");
mac.init(signingKey);

byte[] rawHmac = mac.doFinal(message.getBytes("UTF-8"));
String encodeBase64String = Base64.encodeBase64String(rawHmac);

System.out.println(">>>>> encodeBase64String : " + encodeBase64String) ;
%>
</head>
<Script Language=JavaScript>
	function fnDownload(type) {
		var path = "/bridgetec/veloce/bin/MWS/apache-tomcat/webapps/BT-VELOCE/data";
		var fileName = "";
		if(type == "player") {
			fileName = "VLCPlayer_NonActiveX.exe";
		} else if(type == "screen") {
			fileName = "Veloce_Screen.exe";
		} else if(type == "agent") {
			fileName = "Veloce_Agent.exe";
		} else if(type == "grant") {
			fileName = "filecopy.bat";
		}
		
		var port = document.location.protocol == "http:" ? 7060 : 7070;
// 		var actionUrl = document.location.protocol + "//" + document.location.hostname + ":" + port +"/DownLoadAction.do"
		var actionUrl = document.location.protocol + "//" + "100.100.107.69" + ":" + port +"/DownLoadAction.do"
		
		if(document.getElementById("downIframe") != null) { $("#downIframe").remove(); }
		var downIframe = $('<iframe></iframe>');
		downIframe.attr("id","downIframe");
		downIframe.attr("name","downIframe");
// 		downIframe.attr("sandbox","");
		downIframe.attr("sandbox","allow-same-origin allow-scripts allow-downloads allow-modals");
// 		downIframe.attr("onload","fn_loading();");
		downIframe.css("display","none");
		
		downIframe.appendTo("body");
		
		if(document.getElementById("downForm") != null) { $("#downForm").remove(); }
		var downForm = $('<form></form>');
		downForm.attr("id", "downForm");
		downForm.attr("method", "post");
		downForm.attr("target", "downIframe");
		downForm.attr("action", actionUrl);
		
		downForm.append($("<input/>", {type: "hidden", id: "path", Name:"path", value:path}));
		downForm.append($("<input/>", {type: "hidden", id: "fileName", Name:"fileName", value:fileName}));
		
		downForm.appendTo("body");
		
// 		downForm.submit();
		$("#downForm").submit(function(){
			$("#loadingImg").show();
			$("#mask").show();
			
			var param = {
// 				paramDataType:"json",
				actionUrl,
				path:path,
				fileName:fileName
			};
			
			$.ajax({
// 				url : actionUrl,
				url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
				type : "POST",
// 				data : $("#downForm").serialize(),
				data : JSON.stringify(param),
				contentType: "application/json; charset=utf-8",
				success : function(d,s,x) {
console.dir(d);
// console.log(s);
console.log(x);
// console.log(x.getResponseHeader("some_header"));
					$("#loadingImg").hide();
			  		$("#mask").hide();
			  		
			  		$("#downForm").remove();
			  		$("#downIframe").remove();
				},
				error : function(d,s,x) {
					$("#loadingImg").hide();
			  		$("#mask").hide();
			  		
			  		$("#downForm").remove();
			  		$("#downIframe").remove();
			  		
			  		alert("파일 다운로드 중 오류가 발생했습니다.");
				}
			});
		}).submit();
	}
	
	function fn_goLogin() {
		window.setTimeout(function(){ window.location.replace(gGlobal.ROOT_PATH + "/common/LoginF.do"); }, 500);
	}
</Script>

<body>
<%
%>
	<div class="fi_wrap">
		<div id="mask">
			<img alt="loading" id="loadingImg" src="../images/large-loading.gif" style="width:60px; display: none;">
		</div>
		<section class="fi_section">
	    	<div class="argo_logo"><img src="../images/veloce/login_veloce.png" alt="VELOCE"></div>
	        <div class="fi_box">
	        	<div class="fi_title"><font style="font-size:20px; color:#777676; font-weight:600;">프로그램 다운로드</font></div>
	            <div class="fi_cont">
	                <div class="input_area" style="padding: 10px;">
	                	<table class="input_table">
							<colgroup>
								<col width="10%" />
								<col width="30%" />
								<col />
								<col width="15%" />
							</colgroup>
							<tbody class="resultData">                                     
								<tr>
									<th align="center"><span style="font-size:14px;">순서</span></th>
									<th align="center"><span style="font-size:14px;">프로그램</span></th>
									<th align="center"><span style="font-size:14px;">기능</span></th>
									<th align="center"><span style="font-size:14px;">다운로드</span></th>
								</tr>
								<tr>
									<td style="text-align:center; font-weight: bold; font-size:13px;">1</td>
									<td style="padding-left:5px;">
										<span style="font-weight: bold; font-size:13px;">전용재생기</span><br/>
										<span style="font-size:12px;">(VLCPlayer_NonActiveX.exe)</span>
									</td>
									<td style="padding-left:5px;">
										<span style="font-size:13px;">녹취 파일 재생기 프로그램 입니다.</span>
									</td>
									<td><button type="button" id="btnGrantD" class="btn_tab" onclick="javascript:fnDownload('player');">down</button></td>
								</tr>
								<tr>
									<td style="text-align:center; font-weight: bold; font-size:13px;">2</td>
									<td style="padding-left:5px;">
										<span style="font-weight: bold; font-size:13px;">스크린재생기</span><br/>
										<span style="font-size:12px;">(Veloce_Screen.exe)</span>
									</td>
									<td style="padding-left:5px;">
										<span style="font-size:13px;">스크린 파일 재생기 프로그램 입니다.</span>
									</td>
									<td><button type="button" id="btnGrantD" class="btn_tab" onclick="javascript:fnDownload('screen');">down</button></td>
								</tr>
								<tr>
									<td style="text-align:center; font-weight: bold; font-size:13px;">3</td>
									<td style="padding-left:5px;">
										<span style="font-weight: bold; font-size:13px;">VeloceAgent</span><br/>
										<span style="font-size:12px;">(Veloce_Agent.exe)</span>
									</td>
									<td style="padding-left:5px;">
										<span style="font-size:13px;">agent 프로그램 입니다.</span>
									</td>
									<td><button type="button" id="btnGrantD" class="btn_tab" onclick="javascript:fnDownload('agnet');">down</button></td>
								</tr>
								<tr>
									<td style="text-align:center; font-weight: bold; font-size:13px;">4</td>
									<td style="padding-left:5px;">
										<span style="font-weight: bold; font-size:13px;">권한회수</span><br/>
										<span style="font-size:12px;">(filecopy.bat)</span>
									</td>
									<td style="padding-left:5px;">
										<span style="font-size:13px;">권한회수 프로그램 입니다.</span>
									</td>
									<td><button type="button" id="btnGrantD" class="btn_tab" onclick="javascript:fnDownload('grant');">down</button></td>
								</tr>
							</tbody>
						</table>
	                </div>
	            </div>
				<div class="fi_message"><span style="color: red; font-weight: 600; font-size:13px;">* 반드시 순서에 따라 설치하시기 바랍니다.</span></div>
				<div class="fi_message">* 프로그램 <span style="color: #4169E1;">설치 완료 후</span>에는 아래의 <span style="color: #4169E1;">[로그인 페이지로 이동] 버튼을 클릭</span>하여 주시기 바랍니다.</div>
				<div class="fi_btn"><button type="button" id="btnReset" class="btn_m confirm" onclick="javascript:fn_goLogin();">로그인 페이지로 이동</button></div>
	        </div>
	        <div class="copyright">Copyright (c) Bridgetec.corp. All right Reserved.</div>
	    </section> 
	</div>
</body>
</html>