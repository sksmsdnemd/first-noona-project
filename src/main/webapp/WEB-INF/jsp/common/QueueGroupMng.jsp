<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" /> 
<script>
$(function () {
	
	// 호출화면의 조직팝업 옵션 정보 
	sPopupOptions = parent.gPopupOptions || {};
	sPopupOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
	
	fnInitCtrl();	
	fnInitGrid();
	fnSearchList01();

});

	function fnInitCtrl(){
	
		$("#btnAdd").click(function(){
	 		oOptions = {"targetObj":"s_Queue", "multiYn":'Y' ,"callPageId":"QUEUEGROUP"};
	 	    oOptions.get = function(key, value) {
	 	     return this[key] === undefined ? value : this[key];
	 	    };
	 	    
	 		gPopupOptions = oOptions ;
	 		argoPopupWindow('큐 선택', gGlobal.ROOT_PATH+'/KPI/KPI1050S01F.do', '300', '520' );	
		});
		
		$("#btnDel").click(function(){
			gridView02.deleteSelection(false);
		});	
	    
		$("#btnSave").click(function(){
			fnSave();
		});
		
	}	
	//-------------------------------------------------------------
	// 그리드 초기설정
	//-------------------------------------------------------------
	var gridView01;		// 그리드 오브젝트
	var dataProvider01; // 그리드용 데이터 오브젝트
	var gridView02;		// 그리드 오브젝트
	var dataProvider02; // 그리드용 데이터 오브젝트
		
	function fnInitGrid(){
	    dataProvider01 = new RealGridJS.LocalDataProvider();
	    gridView01 = new RealGridJS.GridView("grList01");
	    gridView01.setDataSource(dataProvider01);
	    argoSetGridStyle(gridView01,{"isPanel":false , "isCheckBar":false, "isEditable":false, "isFooter":false});  // 그리드 기본 스타일 적용 

	    var fields = [];
        fields.push({fieldName:"code",dataType: "text"},{fieldName:"codeNm",dataType: "text"}
        );
        
        // dataProvider에 필드를 생성합니다.
	    dataProvider01.setFields(fields);
        
	    var columns = [
					  {"name": "codeNm", "fieldName": "codeNm", "type": "data", "width": "200", "styles": {"textAlignment": "center"}, "header": {"text": "큐그룹명"}}
	   	       ];
	    gridView01.setColumns(columns);

	    gridView01.onDataCellClicked =  function (grid, index) {
	    	if(index.itemIndex >=0 ) fnSearchList02(index.itemIndex);
	    };
	    	
	    dataProvider02 = new RealGridJS.LocalDataProvider();
	    gridView02 = new RealGridJS.GridView("grList02");
	    gridView02.setDataSource(dataProvider02);
	    argoSetGridStyle(gridView02,{"isPanel":false , "isCheckBar":false, "isEditable":true, "isFooter":false});  // 그리드 기본 스타일 적용 
	    var fields = [	  {"fieldName": "groupCd", "dataType": "text"}
						, {"fieldName": "centerKind", "dataType": "text"}
						, {"fieldName": "centerNm", "dataType": "text"}
              			, {"fieldName": "queueId", "dataType": "text"}
              			, {"fieldName": "queueNm", "dataType": "text"}
              			, {"fieldName": "hideYn", "dataType": "text"} 
              			 ];
	   dataProvider02.setFields(fields);
	    var columns = [
						{
						    name: "centerNm", //컬럼명
						    fieldName: "centerNm",//dataProvider 의 필드명 
						    header : {    text: "센터"    },
						    width: 100
						    ,styles: { textAlignment: "center" }
						    ,editable:false
						},{
						    name: "queueNm", 
						    fieldName: "queueNm",
						    header : {    text: "큐"    },
						    width: 100
						    ,styles: { textAlignment: "center" }
						    ,editable:false
						},{
                            name: "hideYn",
                            fieldName: "hideYn",
                            header : {
                                text: "사용여부"
                            }
                            ,width: 60
                            ,styles: { textAlignment: "center" 
		                            	 ,figureBackground: "#ffff0000"
		                                 ,figureInactiveBackground: "#33ff0000"
		                                 ,figureSize: "100%"   
                            }   
                            ,type: "data"
                            ,renderer: {
                                type: "check"
                                ,editable: true
                                ,startEditOnClick: true
                                ,trueValues: "0"
                                ,falseValues: "1"
                            }
                            ,sortable :false
                        }
				   	
	   	       ];
	    gridView02.setColumns(columns);

	    gridView02.setOptions({edit:{deleteRowsConfirm: false}}); //삭제확인 컨펌 나오지않도록
	    dataProvider02.setOptions({softDeleting: true}); // 삭제 ROW 안보이지 않고 아이콘으로 표시되도록
	    gridView02.onCellEdited =  function (grid, itemIndex, dataRow, field) {gridView02.commit(true);};
    
	}

	function fnSearchList01(){	
		argoJsonSearchList('ARGOCOMMON','SP_UC_GET_CMCODE_01','__', {sort_cd:'QUEUE_GROUP_CD'}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					dataProvider01.clearRows();
					if(data.getRows() != ""){
						dataProvider01.setRows(data.getRows());
						fnSearchList02(0);					}
				}
			} catch(e) {
				console.log(e);			
			}
		});		
	}
	
	var fvGroupCd = "";
	function fnSearchList02(index){
		fvGroupCd = dataProvider01.getValue(index, "code") ; // 선택한 로우의 키값 저장
		argoJsonSearchList('ARGOCOMMON','SP_UC_GET_QUEUE_GROUP','__', {groupCd:fvGroupCd}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					dataProvider02.clearRows();
					if(data.getRows() != "") dataProvider02.setRows(data.getRows());
				}
			} catch(e) {
				console.log(e);			
			}
		});		
	}
	
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 그리드 행추가 모드
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
	function fnAdd(rowList){
	
	//	console.log(JSON.stringify(rowList)) ;
		$.each(rowList, function( index, row) {
			
			// 중복체크		
			var sCenterKind = row.centerKind ;
			var sQueueId    = row.queueId ;

		    var values = [sCenterKind ,sQueueId] ;
		 
		    var options = {
		        fields: ["centerKind" ,"queueId"],
		        values:values,
		        startIndex: 0,
		        caseSensitive: false,
		        partialMatch: false, /* 완전일치 */
		        wrap: true,
		        select: false
		    }
		 
		    var itemindex = gridView02.searchItem(options);
		 
			if(itemindex <0 ) { // 중복이 아니면 추가
				row.groupCd = fvGroupCd ;
			    row.hideYn  = 0;
				dataProvider02.addRow(row);
			}
			else console.log("중복입니다.") ;
		});
	}
	
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	// 그리드 편집내역 저장 (소분류)
	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
	function fnSave(){
		var c_cnt = dataProvider02.getRowStateCount('created');
		var u_cnt = dataProvider02.getRowStateCount('updated');
		var d_cnt = dataProvider02.getRowStateCount('deleted');
		var msg = '';
		if(c_cnt > 0) msg = '신규:'+c_cnt+'건 ';
		if(u_cnt > 0) msg = msg+'수정:'+u_cnt+'건 ';
		if(d_cnt > 0) msg = msg+'삭제:'+d_cnt+'건 ';
		var msgChk = false;
		if(msg != '') msgChk = true;
		if(msgChk){
		    argoConfirm("다음 변경내역을 적용하시겠습니까?<br><br>"+msg, function(){
		    	try{
		    			var multiService = new argoMultiService(fnCallbackSave02);
						var c_rowNum = new Array();
						var u_rowNum = new Array();
						var d_rowNum = new Array();
		
						if(c_cnt > 0){
							c_rowNum = dataProvider02.getStateRows('created'); // 신규추가 row번호
							$.each(c_rowNum, function( index, value) {
								 var param = gridView02.getValues(value) ;
								 param.cudGubun = "I" ;
								 
								 multiService.argoInsert("ARGOCOMMON","SP_UC_SET_QUEUE_GROUP","__", param);
							}); 
						}
						if(u_cnt > 0){
							u_rowNum = dataProvider02.getStateRows('updated'); // 내역변경 row번호
							$.each(u_rowNum, function( index, value) {
								 var param = gridView02.getValues(value) ;
								 param.cudGubun = "U" ;
								 
								 multiService.argoUpdate("ARGOCOMMON","SP_UC_SET_QUEUE_GROUP","__", param);		
								 
							}); 
						}
						if(d_cnt > 0){
							d_rowNum = dataProvider02.getStateRows('deleted'); // 내역변경 row번호
							$.each(d_rowNum, function( index, value) {
								 var param = gridView02.getValues(value) ;
								 param.cudGubun = "D" ;								 
								 multiService.argoUpdate("ARGOCOMMON","SP_UC_SET_QUEUE_GROUP","__", param);	
							}); 
						}
		    		multiService.action();
			    }catch(e){
		    		console.log(e)
		    	}			    						
		 	});
		 }else{
			 argoAlert('변경내역이 없습니다.');
		   	return;
		 }
	}	
	
	function fnCallbackSave02(Resultdata, textStatus, jqXHR){
		try{
		    if(Resultdata.isOk()) {
		    	argoAlert('성공적으로 저장 하였습니다.');
		    	
		    	var indexItem = gridView01.getCurrent() ;
		    	
		    	fnSearchList02(indexItem.itemIndex);
		    }
		} catch(e) {
			console.log(e);    		
		}
	}
</script>
</head>
<body>
	<div class="sub_wrap pop">
        <section class="pop_contents">            
            <div class="pop_cont h0 pt15">            	
                <div class="per35_l">
                	<div class="pop_btn">
                        <span class="btn_l">
                        </span>
                        <span class="btn_r pb5">
                          <!--  <button type="button" id="btnSave01" class="btn_sm save">저장</button>   --> 
                        </span>
                    </div>	
                    <div class="grid_area h35 pt0" >
                        <div id="grList01" class="real_grid"></div>
                    </div>
                </div>
                <div class="per65_r">
                	<div class="pop_btn">
                        <span class="btn_r pb5">
                    	<button type="button" class="btn_m" id="btnAdd" data-grant="W">추가</button>
                        <button type="button" class="btn_m" id="btnDel" data-grant="D">삭제</button>
                        <button type="button" class="btn_m confirm" id="btnSave" data-grant="W">저장</button>   
                        </span>
                    </div>	
                    <div class="grid_area h35 pt0" >
                        <div id="grList02" class="real_grid"></div>
                    </div>
                </div>
               <input type="hidden"  id="s_QueueNm" name="s_QueueNm" style="width:180px;" readonly>
                           <input type="hidden" id="s_QueueId" name="s_QueueId"  style="width:180px;" >
            </div>            
        </section>
    </div>
</body>
</html>
