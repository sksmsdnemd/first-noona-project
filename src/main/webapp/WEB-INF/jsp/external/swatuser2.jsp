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
<%@page import="java.util.zip.*" %>
<%!
	public void jspInit() {
	    SpringBeanAutowiringSupport.processInjectionBasedOnServletContext(this, getServletContext());
	}

	@Autowired
	ArgoDispatchServiceImpl 	argoDispatchServiceImpl;

%>
<%
// System.out.println("윤영식테스트");
int bufferSize = 1024 * 2;
String ouputName = "test";

String parm_recv = (String)request.getAttribute("parm_send");
            
ZipOutputStream zos = null;
OutputStream os = null;
try {
	//response.setHeader("Content-Description", "JSP Generated Data"); 
   /* if (request.getHeader("User-Agent").indexOf("MSIE 5.5") > -1) {
        response.setHeader("Content-Disposition", "filename=" + ouputName + ".zip" + ";");
    } else {
        response.setHeader("Content-Disposition", "attachment; filename=" + ouputName + ".zip" + ";");
    }
    response.setHeader("Content-Transfer-Encoding", "binary");*/
    
                
    os = response.getOutputStream();
    zos = new ZipOutputStream(os); // ZipOutputStream
    zos.setLevel(8); // 압축 레벨 - 최대 압축률은 9, 디폴트 8
    BufferedInputStream bis = null;
    
                
    
    String[] filePaths = parm_recv.split("\\|\\|");
    
    String fileNames = "";
    out.clear(); //out--> jsp자체 객체
    out=pageContext.pushBody();
    //{"fileName1","fileName2","fileName3"};
    int    i = 0;
    for(String filePath : filePaths){
        File sourceFile = new File(filePath);        
        System.out.println("윤영식 테스트 1" + filePath);
        fileNames = filePaths[i].substring(filePaths[i].lastIndexOf("/")).replace("/", "");
//         System.out.println(fileNames);
        bis = new BufferedInputStream(new URL(filePath).openStream());
//         System.out.println("윤영식 테스트 2");
        ZipEntry zentry = new ZipEntry(fileNames);
//         System.out.println("윤영식 테스트 3");
        zentry.setTime(sourceFile.lastModified());
        zos.putNextEntry(zentry);
        
        
        byte[] buffer = new byte[bufferSize];
        int cnt = 0;
        while ((cnt = bis.read(buffer, 0, bufferSize)) != -1) {
            zos.write(buffer, 0, cnt);            
//             System.out.println("윤영식 테스트 4");
        }
        //out.print(zos);
        zos.closeEntry();
        i++;
    }
    zos.flush();              
    zos.close();
    if(bis != null) { bis.close(); }
    if (request.getHeader("User-Agent").indexOf("MSIE 5.5") > -1) {
        response.setHeader("Content-Disposition", "filename=" + ouputName + ".zip" + ";");
    } else {
        response.setHeader("Content-Disposition", "attachment; filename=" + ouputName + ".zip" + ";");
    }
    response.setHeader("Content-Transfer-Encoding", "binary");
                
} catch(IOException ie){
	System.out.println("Exception : " + ie.toString());
} catch(Exception e){
	System.out.println("Exception : " + e.toString());
}

	
%>