<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"  %>
<%@ page import="egovframework.com.cmm.service.Globals"%> 
<%@ page import="java.io.*"%>
<%@ page import="java.text.*" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page import="org.springframework.util.FileCopyUtils" %>
<%
	request.setCharacterEncoding("UTF-8");

	//문자 디코딩
	String fileName = URLDecoder.decode(request.getParameter("file_name"), "UTF-8") ;

	//String fileName = request.getParameter("file_name");
	String filePath = request.getParameter("file_path");
	String globalPath = request.getParameter("global_path");

	// 다운받을 파일이 저장되어 있는 폴더 이름
    // 파일 업로드된 경로
    //String root = request.getSession().getServletContext().getRealPath("/");
    //String savePath = root + "upload";
	//String savePath = root + "/bridgetec/argo/was/filedata/upload/" + filePath ; 
	//String savePath = Globals.UPLOAD_PATH() + filePath ; 
	String savePath = globalPath + filePath ;
 
    // 서버에 실제 저장된 파일명
    //String filename = "test.xlsx" ;
     
    // 실제 내보낼 파일명
    String orgfilename = fileName;
      
 
    InputStream in = null;
    OutputStream os = null;
    File file = null;
    boolean skip = false;
    String client = "";
    String temp[] = null;
	String sFileType="";
	String sFileName = "";
	String sPath = "";
 
    try{        
    	
 	    temp = savePath.split("/");
 	    for(int i = 0; i<temp.length; i++){
    		sPath += temp[i]+"/";
		}
 	    if(fileName.lastIndexOf(".") > -1){
 	    	sFileName = fileName.substring(0, fileName.lastIndexOf("."));
 			sFileType = fileName.substring(fileName.lastIndexOf("."), fileName.length());
 	    }else{
 	    	sFileName = fileName;
 	    }
 	    
        // 파일을 읽어 스트림에 담기
        try{
        	if(sFileName != null && !"".equals(sFileName)){
        		//sFileName = sFileName.replaceAll("\\.","").replaceAll("/","").replaceAll("\\\\","");
        		sFileType = sFileType.replaceAll("\\.","").replaceAll("/","").replaceAll("\\\\","");
            	file = new File(sPath, sFileName+"."+sFileType);
        	}
            in = new FileInputStream(file);
        	
        }catch(FileNotFoundException fe){
            skip = true;
        }
        
        if(skip){
                response.setContentType("text/html;charset=UTF-8");
                //out.println("<script language='javascript'>alert('파일을 찾을 수 없습니다');history.back();</script>");
                // 파일이 없을 경우 호출 페이지 reload 되는 것을 막기 위해 별도의 iframe 에서 처리함.
                out.println("<script language='javascript'>alert('파일을 찾을 수 없습니다');</script>");

        }else{    
        	 client = request.getHeader("User-Agent");
        	 
             // 파일 다운로드 헤더 지정
             response.reset() ;
             response.setContentType("application/octet-stream");
             response.setHeader("Content-Description", "JSP Generated Data");
                         
            // IE
            if(client.contains("MSIE") || client.contains("Trident")){
            	// 한글 파일명 처리
                orgfilename = URLEncoder.encode(orgfilename, "UTF-8").replaceAll("[\\r\\n]","");
                response.setHeader ("Content-Disposition", "attachment; filename=\"" + orgfilename + "\";");
 
            }else{
                // 한글 파일명 처리
                orgfilename = new String(orgfilename.getBytes("UTF-8")).replaceAll("[\\r\\n]","");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + orgfilename + "\"");
                response.setHeader("Content-Type", "application/octet-stream; charset=utf-8");
            }  
             
            response.setHeader ("Content-Length", ""+file.length() );
 
            out.clear();
            out = pageContext.pushBody();
       
            os = response.getOutputStream();
        /* 20201029 double을 int로 형변환 지적사항으로 변경 */
            try{
            	FileCopyUtils.copy(in, os);
            }catch(Exception e){
            	e.printStackTrace();
            }finally{
            	if(in != null){
            		try{
            			in.close();
            		}catch(Exception e){
            			e.printStackTrace();
            		}
            	}
            	if(os != null){
            		os.close();
            	}
            }
        }
            /* 20201029 double을 int로 형변환 지적사항으로 사용 중지
            byte b[] = new byte[(int)file.length()];
            int leng = 0;
             
            while( (leng = in.read(b)) > 0 ){
                os.write(b,0,leng);
            } 
 
        }
         
        20201029 double을 int로 형변환 지적사항으로 사용 중지
        in.close();
        os.close(); */
 
    }catch(Exception e){
     // e.printStackTrace();
    }
%>