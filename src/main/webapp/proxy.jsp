<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="false"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.net.*,java.io.*,javax.net.ssl.*,java.security.cert.*,java.security.*,java.util.*" %>

<%@ page trimDirectiveWhitespaces="true" %>

<%!
  
private static class Base64
{
    public static String encode(byte[] data)
    {
        char[] tbl = {
            'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
            'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
            'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
            'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

        StringBuilder buffer = new StringBuilder();
        int pad = 0;
        for (int i = 0; i < data.length; i += 3) {

            int b = ((data[i] & 0xFF) << 16) & 0xFFFFFF;
            if (i + 1 < data.length) {
                b |= (data[i+1] & 0xFF) << 8;
            } else {
                pad++;
            }
            if (i + 2 < data.length) {
                b |= (data[i+2] & 0xFF);
            } else {
                pad++;
            }

            for (int j = 0; j < 4 - pad; j++) {
                int c = (b & 0xFC0000) >> 18;
                buffer.append(tbl[c]);
                b <<= 6;
            }
        }
        for (int j = 0; j < pad; j++) {
            buffer.append("=");
        }

        return buffer.toString();
    }

    public static byte[] decode(String data)
    {
        int[] tbl = {
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54,
            55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2,
            3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
            20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28, 29, 30,
            31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
            48, 49, 50, 51, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
            -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 };
        byte[] bytes = data.getBytes();
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        for (int i = 0; i < bytes.length; ) {
            int b = 0;
            if (tbl[bytes[i]] != -1) {
                b = (tbl[bytes[i]] & 0xFF) << 18;
            }
            // skip unknown characters
            else {
                i++;
                continue;
            }

            int num = 0;
            if (i + 1 < bytes.length && tbl[bytes[i+1]] != -1) {
                b = b | ((tbl[bytes[i+1]] & 0xFF) << 12);
                num++;
            }
            if (i + 2 < bytes.length && tbl[bytes[i+2]] != -1) {
                b = b | ((tbl[bytes[i+2]] & 0xFF) << 6);
                num++;
            }
            if (i + 3 < bytes.length && tbl[bytes[i+3]] != -1) {
                b = b | (tbl[bytes[i+3]] & 0xFF);
                num++;
            }

            while (num > 0) {
                int c = (b & 0xFF0000) >> 16;
                buffer.write((char)c);
                b <<= 8;
                num--;
            }
            i += 4;
        }
        return buffer.toByteArray();
    }
}
%>
<%



try {
	String reqUrl = request.getParameter("url");
	String reqData = request.getParameter("data");
	System.out.println("URL 00: " + reqUrl);
	System.out.println("data 00: " + reqData);
	
	byte[] decodedURLBytes = Base64.decode(reqUrl);
	reqUrl = new String(decodedURLBytes);
 	System.out.println("url -->base64.decode 11: " + reqUrl);
	
	byte[] decodedDataBytes = Base64.decode(reqData);
	reqData = new String(decodedDataBytes);
 	System.out.println("data -->base64.decode 11: " + reqData);
	
 	String[] agentList = new String[]{
		"http://localhost:8090", "http://127.0.0.1:8090"
		, "http://"+com.bridgetec.argo.controller.ArgoCtrlHelper.getClientIpAddr(request)+":8090"
	};
 	
 	if(Arrays.asList(agentList).contains(reqUrl)) {
		
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
			response.setContentType(con.getContentType().replaceAll("[\\r\\n]", ""));
			//데이터 수신
			BufferedReader rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
			String line;
			while ((line = rd.readLine()) != null) {
				out.println(line); 
				System.out.println(line);
			}
			rd.close();
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
			response.setContentType(con.getContentType().replaceAll("[\\r\\n]", ""));
			//데이터 수신
			BufferedReader rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
			String line;
			while ((line = rd.readLine()) != null) {
				out.println(line); 
				System.out.println(line);
			}
			rd.close();
		} else {
			response.setStatus(500);
			response.getWriter().write("Unknwon URL");
		    response.flushBuffer();
		}
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