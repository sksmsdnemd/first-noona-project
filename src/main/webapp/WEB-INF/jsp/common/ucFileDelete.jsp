<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"  %>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ page import="java.io.*"%>
<%@ page import="java.text.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%
  request.setCharacterEncoding("UTF-8");
 
//문자 디코딩
//String fileName = URLDecoder.decode(request.getParameter("file_name"), "UTF-8") ;

String filePath = URLDecoder.decode(request.getParameter("file_path"), "UTF-8") ;
String globalPath = request.getParameter("global_path");

 //String root = request.getSession().getServletContext().getRealPath("/");
 //String savePath = Globals.UPLOAD_PATH()  ; 
 String savePath = globalPath ;
 
 out.println("<script language='javascript'>console.log('[파일삭제경로]"+ savePath+ "');</script>");
 
 
     OutputStream os = null;
   // File file = null;
    boolean skip = false;
    String sMsg = "";    
    String sFile ="";
    
    //filePath= filePath.replaceAll("\\.","").replaceAll("/","").replaceAll("\\\\","");
    try{        
    	StringTokenizer tokens = new StringTokenizer( filePath, "," );
    	for( int x = 1; tokens.hasMoreElements(); x++ ){
    		
    		sFile = savePath +"/"+ tokens.nextToken() ;
    		String temp[] = null;
    		String fileType="";
    		String fileName = "";
    		String path = "";
     	    temp = sFile.split("/");
     	    for(int i = 0; i<temp.length; i++){
     	    	if(temp[i].indexOf(".") > -1){
     	    		fileName = temp[i].substring(0, temp[i].indexOf("."));
     	    		fileType = temp[i].substring(temp[i].indexOf(".")+1, temp[i].length());
     	    	}else{
     	    		path += temp[i]+"/";
     	    	}
     	    }
     	    if(fileName != null && !"".equals(fileName)){
     	    	fileName = fileName.replaceAll("\\.","").replaceAll("/","").replaceAll("\\\\","");
        	    File file = new File(path+fileName+"."+fileType);
	            
        	    if( file.exists()) {
	            	skip = file.delete(); // 파일이 존재하면 파일을 삭제한다.
	            } else {
	            	System.out.println( "Not exist File>> " + sFile );
	            }
     	    }
    	}        	
        
        if(skip){
        	sMsg = "파일삭제 성공" ;
 
        }else{ 
        	if(tokens.countTokens()==0 ) sMsg = "처리할 대상 파일이 없습니다."; 
        	else sMsg = "파일삭제 실패"; 
        }
        
       	response.setContentType("text/html;charset=UTF-8");
        // 파일이 없을 경우 호출 페이지 reload 되는 것을 막기 위해 별도의 iframe 에서 처리함.
        out.println("<script language='javascript'>console.log('[파일삭제처리결과]"+ sMsg+ "');</script>");        	
 
    }catch(Exception e){
      e.printStackTrace();
    }
%>