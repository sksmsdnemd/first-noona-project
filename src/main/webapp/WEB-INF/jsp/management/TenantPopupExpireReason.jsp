<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 

<script>
	$(function () {
		$("#btnSavePop").click(function(){
			fnSavePop();
		});	
	});
	
	function fnSavePop(){
		var aValidate;
				
		aValidate = {
	        rows:[ 
				 	 {"check":"length", "id":"expireReason", "minLength":1, "maxLength":100, "msgLength":"해지 사유를 입력하세요."}
	        	]
	    };	
		if (argoValidator(aValidate) != true) return;
		
		parent.fnDeleteList( $("#expireReason").val() );
		
		argoPopupClose();
	}
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont pt5">
            	<div class="btn_topArea">
                	<span class="btn_r">
                       <button type="button" class="btn_m confirm" id="btnSavePop" name="btnSavePop">저장</button>   
                    </span>               
                </div>
                <div class="input_area">
                	<table class="input_table">
                    	<colgroup>
                        	<col width="158">
                            <col width="">
                        </colgroup>
                        <tbody>
                        	<tr>
                        		<th>해지사유<span class="point">*</span></th>
                                <td><textarea id="expireReason" name="expireReason" rows="5"></textarea></td>
                            </tr>
                        </tbody>
                    </table>
                </div>           
            </div>            
        </section>
    </div>
</body>

</html>
