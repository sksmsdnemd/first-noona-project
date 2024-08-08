<%@page contentType="text/html; charset=euc-kr" language="java"
	errorPage=""%>
<%@page import="java.util.*,java.io.*"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="jxl.*"%>
<%@ page import="java.sql.*"%>


<%   
 
 String savePath = request.getRealPath("/"); 
 //request.getRealPath("/")+"upload/tmp"; // 저장할 디렉토리   
 
 int sizeLimit = 30 * 1024 * 1024 ; // 용량제한   
 String formName = "";   
 String fileName = "";   
 Vector vFileName = new Vector();   
 Vector vFileSize = new Vector();   
 String[] aFileName = null;   
 String[] aFileSize = null;   
 long fileSize = 0;   
 MultipartRequest multi = new MultipartRequest(request, savePath, sizeLimit, "euc-kr", new DefaultFileRenamePolicy());   
 
 Enumeration formNames = multi.getFileNames();    
 
 while (formNames.hasMoreElements()) 
 {    
  formName = (String)formNames.nextElement();    
  fileName = multi.getFilesystemName(formName);    
  
  if(fileName != null)  // 파일이 업로드 되면
  {      
   fileSize = multi.getFile(formName).length();   
   vFileName.addElement(fileName);   
      vFileSize.addElement(String.valueOf(fileSize));    
  }    
 
 }   
    
 aFileName = (String[])vFileName.toArray(new String[vFileName.size()]);   
 aFileSize = (String[])vFileSize.toArray(new String[vFileSize.size()]);   
%>

<%   
 Workbook workbook = Workbook.getWorkbook(new File(savePath + "/" + fileName));    
 Sheet sheet = workbook.getSheet(0);   
  
 int col = sheet.getColumns();  // 시트의 컬럼의 수를 반환한다.    
 int row = sheet.getRows();   // 시트의 행의 수를 반환한다.  
%>


<html>
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" />
<link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.timeSelect.js"/>"></script>
<TITLE>Excel Document Reader</TITLE>
</HEAD>
<BODY>

	workbook =
	<%=workbook %>
	<br> 행 수 :
	<%=row %>
	<br> 컬럼 수 :
	<%=col %>
	<br>
	<br>
	<br>

	<table border="1">
		<%
 
 String [][] content = new String[row][col];
 
 for (int i = 0 ; i < row ; i++)
 {
  for (int j = 0 ; j < col ; j++)
  {
   content[i][j] = sheet.getCell(j, i).getContents(); // 첫번째 인자가 열 값, 두번째 인자값이 행 값이다.!
  } 
 }
 
    out.println("text 방식" + "<br>");
 for (int k = 0 ; k < content.length ; k++) //자동 : 테이블 형태가 아닌 방식으로 출력(단순 text로 보인다).
 {
  for (int l = 0 ; l < content[k].length ; l++)
  {
   out.println(content[k][l]);
  } 
  out.println("<br>");
 }
 
    out.println("<br><br>");
 
    out.println("테이블형태의 방식");
 for (int k = 0 ; k < content.length ; k++)       // 자동 : 테이블 형태의 방식으로 출력
 {
     out.println("<tr>");
  for (int l = 0 ; l < content[k].length ; l++)
  {
   out.println("<td>");
   out.println(content[k][l]);
   out.println("</td>");
  } 
  out.println("</tr>");
 }
%>
	</table>
	<br>
	<br>
	<br>

	<table border="1">

		<%
 Connection conn = null;
 PreparedStatement pstmt = null;
 
 try
 {
 
//     개발실 DB 접속 
     Class.forName("oracle.jdbc.driver.OracleDriver");
     conn = DriverManager.getConnection("jdbc:oracle:thin:@11.11.11.11:1521:ora9","id","password");       
                                                      
 
//      Record를 읽어 배열로 저장
  out.println("DB에 저장되는 데이터");
  
     for (int i = 0 ; i < row ; i++)            // 수동 : 테이블 형태의 방식
  {     
      String aaa  = sheet.getCell(0,i).getContents(); //첫번째 인자가 열 값, 두번째 인자값이 행 값..!
      String bbb  = sheet.getCell(1,i).getContents();  
      String ccc  = sheet.getCell(2,i).getContents();  
      
      String sql="insert into PHONE_NUMBER(idx, id, grp) values(?,?,?) ";
 
      pstmt = conn.prepareStatement(sql);
         
         pstmt.setString(1,aaa);
      pstmt.setString(2,bbb);
      pstmt.setString(3,ccc);
               
      pstmt.executeUpdate();
      
      out.println("<tr>");                      // 테이블 형태의 방식으로 출력
      out.println("<td>"+aaa+"</td>");   
      out.println("<td>"+bbb+"</td>");  
      out.println("<td>"+ccc+"</td>");    
      out.println("</tr>");   
     } // end of for                

     
 }
 catch(Exception e)
 {
  System.out.println("Exception : " + e.toString());
  if(conn != null) { conn.rollback(); }
%>
		<script language=javascript>
 alert("처리중 오류가 발생하였습니다\n잠시후 다시 시도하세요!!");
 history.back();
</script>
		<%  
 } 
 finally
 {
  if(conn != null)
  {
   conn.commit();
   conn.close();
  }
 }
    
%>

	</table>

</BODY>
</HTML>
