<%@page contentType="text/html;charset=euc-kr"%>

<html>
<script>  
function checkForm() {   
 if (upload.file1.value == "") {   
  alert("������ ���ε����ּ���.");   
  return false;   
 }  else if(!checkFileType(upload.file1.value)) {   
  alert("�������ϸ� ���ε� ���ּ���.");   
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
<button type='button' id='' class='btn_tab' onclick='checkForm()'>��������</button>
<button type='button' id='' class='btn_tab'>�ϰ����</button>
</td>
</form>
</body>
 
</html>