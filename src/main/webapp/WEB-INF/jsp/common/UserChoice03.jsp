<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html >
<html>
<head>
<title>ARGO</title>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />
<%@ include file="/WEB-INF/jsp/include/common.jsp"%>

<script>
var loginInfo 	= JSON.parse(sessionStorage.getItem("loginInfo"));
var tenantId  	= loginInfo.SVCCOMMONID.rows.tenantId;
var userId    	= loginInfo.SVCCOMMONID.rows.userId;
var groupId    	= loginInfo.SVCCOMMONID.rows.groupId;
var grantId   	= loginInfo.SVCCOMMONID.rows.grantId;
var workIp 		= loginInfo.SVCCOMMONID.rows.workIp;
var workMenu 	= "유저 선택";
var workLog 	= "";
var dataArray 	= new Array();

var fvTargetObjId ; //호출화면의 INPUT Object Name
var fvTargetObjNm ; //호출화면의 INPUT Object Name
var fvMultiYn ="N"; //멀티여부 - Y 이면 멀티선택 허용

var fvRltIds =""; // 리턴값(Ids)
var fvRltNms =""; // 리턴값(Names))
var fvMenuId="";
var fvUserId = "";
var fvUserNm = "";


	$(function () {		
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
	 	// 호출 화면의 정보 설정
	 	//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━	
		sPopupOptions = parent.gPopupOptions || {};
		sPopupOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    var sSearchKey = sPopupOptions.searchKey ;
	    sSearchKey = sSearchKey.substring(sSearchKey.lastIndexOf('/')+1);
	    argoSetValue("spUserChoice03_UserInfo", argoNullConvert(sSearchKey));
	    
	    fvTargetObjId = sPopupOptions.targetObj+"Id" ;
	    fvTargetObjNm = sPopupOptions.targetObj+"Nm" ;
	    fvMultiYn     = sPopupOptions.multiYn ;	     
	    fvMenuId	   = sPopupOptions.menuId;
	     
	     //argoSetValue('spUserChoice03_UserInfo',sSearchKey );
	     
	     /* argoCbCreate("spUserChoice03_AgentJikchk", "ARGOCOMMON", "SP_UC_GET_CMCODE_01",{sort_cd:'AGENT_JIKCHK'},{"selectIndex":0, "text":'<전체>', "value":''}); */

	     //var sJikchk = sPopupOptions.jikchkCd;
	     //argoSetValue("spUserChoice03_AgentJikchk", sJikchk);
	     
	     // 엔터 입력시 검색
	     $("#spUserChoice03_UserInfo").keydown(function(key){
	    	 if(key.keyCode == 13) fnSearchList_UserChoice03();	
	     })
	     
	     $("#btnSearch_UserChoice03").click(function(){
	    	 fnSearchList_UserChoice03();
	     })
	     
	     $("#btnConfirm_UserChoice03").click(function(){			
				fnSetUserChoice();
				argoPopupClose();
		 });
	     fnInitGrid_UserChoice03();
	     fnSearchList_UserChoice03();
	});
	
	//상담사 목록조회
	function fnSearchList_UserChoice03(){
		//argoGrSearch("dataProvider_UserChoice03_1", "ARGOCOMMON", "SP_UC_GET_AGENT_JIKCHK", "spUserChoice03_", {grantDeptCds:top.gMenu.GRANT_DEPT_CD}); 
		argoJsonSearchList('ARGOCOMMON', 'SP_UC_GET_AGENT_QAA', 'spUserChoice03_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					w2ui.grid.clear();
					if(data.getProcCnt() == 0){
						argoAlert('조회 결과가 없습니다.');
						return;
					}
					
					dataArray = [];
					if (data.getRows() != ""){ 
						$.each(data.getRows(), function( index, row ) {
							gObject2 = {  "recid" 	: index
			    				, "deptPath"		: row.deptPath
			   					, "userId"	  		: row.userId
								, "userName"	  	: row.userName
							};
							dataArray.push(gObject2);
						});
						w2ui['grid'].add(dataArray);
					}
					if(w2ui['grid'].getSelection().length == 0){
						w2ui['grid'].click(0,0);
					}
				}
				w2ui.grid.unlock();
			} catch (e) {
				console.log(e);
			}
			
			workLog = '[TenantId:' + tenantId + ' | UserId:' + userId
			+ ' | GrantId:' + grantId + '] 조회';
			argoJsonUpdate("actionLog", "setActionLogInsert", "ip_", {
				tenantId : tenantId,
				userId : userId,
				actionClass : "action_class",
				actionCode : "W",
				workIp : workIp,
				workMenu : workMenu,
				workLog : workLog
			});
		});
	}
	
	function fnInitGrid_UserChoice03(){
		$('#grList_UserChoice03_1').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: false,
	            selectColumn: fvMultiYn=="N"?false:true
	        },
	        multiSelect: fvMultiYn=="N"?false:true,
	        onDblClick: function(event) {
	        	if( fvMultiYn!='Y') {
	        		var record = this.get(event.recid);
	        		fvUserId = record.userId;
	        		fvUserNm = record.userName;
    	    		$("#btnConfirm_UserChoice03").trigger('click');
    	    	}
	        },
	        columns: [
			 	 { field: 'recid', 			caption: '', 			size: '0%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'deptPath', 	 	caption: '소속', 			size: '60%', 	sortable: true, attr: 'align=left' }
       	 		,{ field: 'userId', 		caption: '사번', 			size: '20%', 	sortable: true, attr: 'align=center' }
       	 		,{ field: 'userName', 		caption: '상담사명', 		size: '20%', 	sortable: true, attr: 'align=center' }
	       	],
	        records: dataArray
	    });
		
		w2ui['grid'].hideColumn('recid' );
	}
	
	
	function fnSetUserChoice() {
		fvRltIds = "";
		fvRltNms ="";
		
		var arrIds = new Array();
		var arrNms = new Array();
		
		if( fvMultiYn=='Y') {
			var arrChecked = w2ui['grid'].getSelection();
		 	if(arrChecked.length==0) {
		 		argoAlert("사용자 목록을 선택하세요") ; 
		 		return ;
		 	}
			
			$.each(arrChecked, function( obj, index ) {
				arrIds.push(w2ui['grid'].get(index).userId);
				arrNms.push(w2ui['grid'].get(index).userName);
			});
			fvRltIds = arrIds.join(',');
			fvRltNms = arrNms.join(', ');
		} else {
			if(argoNullConvert(fvSheetId) == ""){
				if(w2ui.grid.getSelection().length == 0){
					argoAlert("사용자 목록을 선택하세요") ; 
			 		return ;
				} 
				fvUserId = w2ui['grid'].get(w2ui.grid.getSelection()[0]).userId;
			}
			
			if(argoNullConvert(fvUserNm) == ""){
				fvUserNm = w2ui['grid'].get(w2ui.grid.getSelection()[0]).userName;
			}
			fvRltIds = fvUserId;  
			fvRltNms = fvUserNm;
		}
		//***************호출한 화면에 선택한 코드 및 코드값 설정 처리 *****************************		
	 	var sOpener = window.frameElement.attributes["data-pid"].value ;
	 	var sOpenerType = window.frameElement.attributes["data-ptype"].value ;
	
        if(sOpenerType == "M" ) {//메인 화면에서 호출시
        	$("#"+fvTargetObjId, parent.document).val(fvRltIds).trigger('click');
			$("#"+fvTargetObjNm, parent.document).val(fvRltNms);
	     }else { //팝업에서 호출시
	    	 $("#"+fvTargetObjId, parent.frames[sOpener].document).val(fvRltIds);
	    	 $("#"+fvTargetObjNm, parent.frames[sOpener].document).val(fvRltNms);
	     }
        argoPopupClose();
	}
</script>

</head>

<body>
		<div class="sub_wrap pop">
        <section class="pop_contents">
            <div class="btn_topArea">
                <span class="btn_l">
                    <input type="text" id="spUserChoice03_UserInfo" name="spUserChoice03_UserInfo" style="width:250px;" class="test" placeholder="행번 또는 성명을 입력하세요.">
                    <!-- <select id="spUserChoice03_AgentJikchk" name="spUserChoice03_AgentJikchk" style="width:95px;">
                        <option>직책</option>
                    </select>        -->    
                </span>
                <span class="btn_r">
                      <button type="button" id="btnSearch_UserChoice03" name="btnSearch_UserChoice03" class="btn_m search" >조회</button>  
                </span>
            </div>    
            <div class="pop_cont">            
                <div class="grid_area h38 pt0" >
                    <div id="grList_UserChoice03_1" class="real_grid"></div>
                </div>
                <div class="btn_areaB txt_r">
                    <a href="#" class="btn_m confirm" id="btnConfirm_UserChoice03">확인</a>   
            	</div>
            </div>            
        </section>
    </div>
</body>
</html>

