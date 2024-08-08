<%@page contentType="text/html;charset=euc-kr"%>

<html>
<script>  
function checkForm() {   
 if (upload.file1.value == "") {   
  alert("파일을 업로드해주세요.");   
  return false;   
 }  else if(!checkFileType(upload.file1.value)) {   
  alert("엑셀파일만 업로드 해주세요.");   
  return false;   
 }   
  document.upload.submit();
}   
function checkFileType(filePath){   
  
 var fileLen = filePath.length;   
 var fileFormat = filePath.substring(fileLen - 4);   
 fileFormatfileFormat = fileFormat.toLowerCase();   
  
 if (fileFormat == ".xls"){   return true;    
 }   else{     return false;     }   
}
</script>  
 
<body>
<form action="VExcelInsertF.xDo" name="upload" method="POST" enctype="multipart/form-data">
<!--  enctype="multipart/form-data"> -->
<td><input type="file" name="file1" size="20" align="absmiddle" />    </td>
<td>
<button type='button' id='' class='btn_tab' onclick='checkForm()'>가져오기</button>
<button type='button' id='' class='btn_tab'>일괄등록</button>
</td>
</form>
</body>
 
</html>