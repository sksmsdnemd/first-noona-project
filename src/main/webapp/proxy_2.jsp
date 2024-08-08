<%@page import="org.json.simple.JSONArray"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="false"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.net.*,java.io.*,javax.net.ssl.*,java.security.cert.*,java.security.*" %>
<%
try {
	request.setCharacterEncoding("utf-8"); 
	String reqData = request.getParameter("data") == null ? "" : request.getParameter("data").replaceAll("&quot;", "\""); 
	JSONParser jsonParser = new JSONParser();
    JSONObject jsonObj = (JSONObject) jsonParser.parse(reqData);
    String reqUrl = jsonObj.get("url").toString();
    
	System.out.println("URL (1): " + reqUrl); 
 	System.out.println("DATA (1): " + reqData);
	
	URL url = new URL(reqUrl);
	if (reqUrl.startsWith("http://")) { //HTTP
		HttpURLConnection con = (HttpURLConnection)url.openConnection();
		con.setDoInput(true);
		con.setRequestMethod(request.getMethod());
		con.setDoOutput(true);
		//데이터 전송
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
	    wr.write(reqData.getBytes("UTF-8"));
	    wr.flush();
	    wr.close();
		
		int responseCode = con.getResponseCode();
		System.out.println(responseCode);
		response.setStatus(responseCode);
		response.setContentType(con.getContentType());
		//데이터 수신
		BufferedReader rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
		String line;
		while ((line = rd.readLine()) != null) {
			out.println(line); 
			System.out.println(line);
		}
		rd.close();
		con.disconnect();
	} else if (reqUrl.startsWith("https://")) { //HTTPS
		TrustManager[] trustAllCerts = new TrustManager[] {new X509TrustManager() {
	            @Override
				public X509Certificate[] getAcceptedIssuers() {
	                return null;
	            }
	            @Override
				public void checkClientTrusted(X509Certificate[] certs, String authType) {
	            }
	            @Override
				public void checkServerTrusted(X509Certificate[] certs, String authType) {
	            }
			}
		};
		// Install the all-trusting trust manager
		SSLContext sc = SSLContext.getInstance("SSL");
		sc.init(null, trustAllCerts, new SecureRandom());
		HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
		
		// Create all-trusting host name verifier
		HostnameVerifier allHostsValid = new HostnameVerifier() {
	        @Override
			public boolean verify(String hostname, SSLSession session) {
	            return true;
	        }
	    };
	    HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
	    
	    HttpsURLConnection con = (HttpsURLConnection)url.openConnection();
	    //con.setHostnameVerifier(allHostsValid);
	    //con.setSSLSocketFactory(sc.getSocketFactory());
		
		con.setDoInput(true);
		con.setRequestMethod(request.getMethod());
		con.setDoOutput(true);
		//데이터 전송
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
	    wr.write(reqData.getBytes("UTF-8"));
	    wr.flush();
	    wr.close();
		
		int responseCode = con.getResponseCode();
		System.out.println(responseCode);
		response.setStatus(responseCode);
		response.setContentType(con.getContentType());
		//데이터 수신
		BufferedReader rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
		String line;
		while ((line = rd.readLine()) != null) {
			out.println(line); 
			System.out.println(line);
		}
		rd.close();
		con.disconnect();
	} else {
		response.setStatus(500);
		response.getWriter().write("Unknwon URL");
	    response.flushBuffer();
	}

} catch(IOException ie) {
  	response.setStatus(500);
	response.getWriter().write(ie.toString());
    response.flushBuffer();
    
	System.out.println("Exception : " + ie.toString());
} catch(Exception e) {
  	response.setStatus(500);
	response.getWriter().write(e.toString());
    response.flushBuffer();
    
	System.out.println("Exception : " + e.toString());
}
%>