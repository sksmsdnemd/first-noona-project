<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="egovframework.com.cmm.service.Globals"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script type="text/javascript">
var valueYn = "N";
$(function () {
	
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };    
  	fnInitCtrl_QA1020S01();
  	fnSearchList__QA1020S01(); 
});

function fnInitCtrl_QA1020S01() {
	valueYn = argoNullConvert(sPopupOptions.valueYn)==""?"N":argoNullConvert(sPopupOptions.valueYn);
	argoSetDeptChoice("btn_Dept1", {"targetObj":"ip_Dept1", "multiYn":'Y', "parentYn" :"Y", "valueYn":valueYn}); //조직선택 팝업 연결처리(멀티)
	
	$("#btnSave_QA1020S01").click(function(){
		fnSave_QA1020S01();
	});	
}

//-------------------------------------------------------------
//목록조회
//-------------------------------------------------------------
function fnSearchList__QA1020S01(){
	
	if(sPopupOptions.cudGubun =='I') { // 추가일때 로그인사용자 소속부서 설정
		// 관리소속 전체 디폴트 세팅 _ hwang _ 221124
		argoJsonSearchOne("ARGOCOMMON", "SP_UC_GET_ACCESS_DEPT", "__", {}, function (Resultdata, textStatus, jqXHR) {
			if (Resultdata.isOk()) {
				var sDeptId = Resultdata.getRows()['deptCd']; 
				var sDeptNm = Resultdata.getRows()['deptNm']; 
				argoSetValue('ip_Dept1Id', sDeptId ) ; 
				argoSetValue('ip_Dept1Nm', sDeptNm ) ;
				argoSetValue('ip_HideYn', 0);
			}
		});
		
	}else {
	   	// 수정시 부모 그리드 값 전송
	   	argoSetValue("ip_SheetId", 		argoNullConvert(sPopupOptions.sheetId));
	   	argoSetValue("ip_SheetNm", 		argoNullConvert(sPopupOptions.sheetNm));
	   	argoSetValue("ip_HideYn",		argoNullConvert(sPopupOptions.hideYn));
	   	argoSetValue("ip_SheetType", 	argoNullConvert(sPopupOptions.sheetType));
	   	argoSetValue("ip_Dept1Nm", 		argoNullConvert(sPopupOptions.dept1Nm));
	   	argoSetValue("ip_Dept1Id", 		argoNullConvert(sPopupOptions.dept1Id));
	   	console.log("sPopupOptions.dept1Id : " + sPopupOptions.dept1Id);
    }
}

//-------------------------------------------------------------
//저장
//-------------------------------------------------------------
function fnSave_QA1020S01(){
	
	if(argoGetValue("ip_Dept1Id").indexOf(argoGetValue("ip_DeptId"))==-1){
		argoAlert("본인 소속이 포함되어 있지 않습니다. 확인해주십시오.");
		return ;
	}
	
	argoConfirm("저장 하시겠습니까?", function(){
			var aValidate = {
		        rows:[ 
		          {"check":"length", "id":"ip_SheetNm", "minLength":1, "maxLength":100,  "msgLength":"평가표명을 100byte이하로 입력하세요"}
		        ]
		    };	
			
		   if (argoValidator(aValidate) != true) return;
		   
		    argoJsonSearchOne("QA","SP_QA1020S01_01","ip_", {"cudGubun":sPopupOptions.cudGubun},function (Resultdata, textStatus, jqXHR){
		    	try{
		    	    if(Resultdata.isOk()) {
		    	    
		    	           // 등록의 경우 새로 생성한 KEY 를 해당 컨트롤에 설정
		    	    		if(typeof(Resultdata.getRows()['keyId'])!="undefined"){
		    	    			parent.fvKeyId  = Resultdata.getRows()['keyId'] ;
		    	    	     }
		    	    		argoAlert('warning', '성공적으로저장 되었습니다.','', 'parent.fnSearchList01(); argoPopupClose();');
		    	    		
		    	    }
		    	} catch(e) {
		    		argoAlert(e);    		
		    	}
		    } );
	});
}

</script>

<style type="text/css">
.select2-results__options {
    height: 80px;
    overflow-y: auto;
}
</style>
</head>
<body>

	<input type="hidden" id ='ip_DeptId' value="<c:out value="${sessionMAP.groupId}"/>">
	<div class="sub_wrap pop hAuto">
        <section class="pop_contents">            
            <div class="pop_cont">
            	<div class="btn_topArea">
                	<span class="btn_r">
                         <button type="button" class="btn_m confirm" id="btnSave_QA1020S01" name="btnSave_QA1020S01" data-grant="W">저장</button>   
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
                            	<th>평가표<span class="point">*</span></th>
                                <td>
                                    <input type="text" id="ip_SheetNm" name="ip_SheetNm" class="mr10" style="width:360px;" >
				                    <input type="hidden" id="ip_SheetId" name="ip_SheetId" >  
     	                            <input type="checkbox" id="ip_HideYn" name="ip_HideYn" data-defaultChecked=true value="0"><label for="ip_HideYn">사용</label>
                                </td>
                            </tr>
                            <tr style = 'display:none'>
                            	<th>평가구분<span class="point">*</span></th>
                                <td>
                                	<select id="ip_SheetType" name="ip_SheetType" style="width:200px;"></select>                         
                                </td>
                            </tr>
                            <tr>
                            	<th>관리소속<span class="point">*</span></th>
                                <td>
                                	<input type="text"   id="ip_Dept1Nm" name="ip_Dept1Nm" style="width:360px;" readonly><button type="button" id="btn_Dept1" class="btn_termsSearch">검색</button>
                           			<input type="hidden" id="ip_Dept1Id" name="ip_Dept1Id" > 
                                </td>
                            </tr>                            
                        </tbody>
                    </table>
                </div>           
            </div>            
        </section>
    </div>
</body>
</html>
