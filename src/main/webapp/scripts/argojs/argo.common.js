var comStdMonth = "";

$(function(){
	
	/*$.fn.openQaWindow = function( options ) {
		
		options = $.extend( null, $.setOptionsPW, options );
		this.each( function(index) {			
			var veloceWindow_view = new VeloceWindow_view( this, options.url, options.title, options.width, options.height, options.pid, options.ptype , options.multi  , options.closeable, options.target, options.callback, options.method);	
			veloceWindow_view.btn_close.on("click", function(e){				
				if (options.method  != null && options.method !=  undefined){
//					eval(options.method+'();');
					new Function(options.method+'();')();
				}
				if (options.close_onClick != undefined) {
					options.close_onClick(e);
				}		
				return false;		 				 
			});			
		});		

		return this;
	}	*/
	/*$(".yearMonth_date").find('input[type="text"]').keyup(function(e){
		comStdMonth = $(this).val();
	});
	
	$(".yearMonth_date").find('input[type="text"]').click(function(e){
		comStdMonth = $(this).val();
	});

	$(".yearMonth_date").find('input[type="text"]').blur(function(){
		var stdMonth = comStdMonth.replace(/-/g, "");
		if(comStdMonth.length >= 6){
			$(this).val(stdMonth.substring(0,4) + '-' + stdMonth.substring(4,6))
			
			comStdMonth = $(this).val();
		}else{
			var date = new Date();
		    var yyyy = date.getFullYear();
		    var mm = date.getMonth();
		    if (mm == 0){
		    	mm = 12;
		    	yyyy=yyyy-1;
		    }
		    if (mm < 10) mm = "0" + mm;
		    var sStdMonth = yyyy +'-'+ mm; 
		    comStdMonth = sStdMonth;
		    $(this).val(sStdMonth);
		}
	}); */
	
	
	
	$(document).mouseup(function (e){
		// 북마크 이벤트
		//if(parent.fnBookmarkControl != undefined) parent.fnBookmarkControl(e.target.id);
	});
});

var gPopupOptions  ; //팝업화면과 변수사용을 위해
/**
 * 조직선택 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 조직ID,조직명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetDeptChoice("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); 
 *   
 */
function argoSetDeptChoice(sSelector ,oOptions) {
	 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

 	//  입력란 엔터키 일때 팝업 호출
 	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
	// 현 화면에 대한 접근권한이[조] 또는 [개인]이면 로그인사용자 정보로 기본 설정, 비활성 처리
 	if(top.gMenu.SCOPE_KIND=="40" || top.gMenu.SCOPE_KIND=="50") {
		argoSetValue(sSelectorId, top.gLoginUser.DEPT_CD ) ; 
		argoSetValue(sSelectorNm, top.gLoginUser.DEPT_NM ) ;
		
		argoDisable(true, sSelector);
		argoDisable(true, sSelectorNm);		
	}else if(top.gMenu.SCOPE_KIND=="90"){
		argoSetValue(sSelectorId, top.gMenu.GRANT_DEPT_CD )
	}else if(top.gMenu.SCOPE_KIND=="10"){
		argoSetValue(sSelectorId, top.gLoginUser.CENTER_CDS);
		argoSetValue(sSelectorNm, top.gLoginUser.CENTER_NMS);
	}else if(top.gMenu.SCOPE_KIND=="20"){
		argoSetValue(sSelectorId, top.gLoginUser.PART_CDS);
		argoSetValue(sSelectorNm, top.gLoginUser.PART_NMS);
	}else if(top.gMenu.SCOPE_KIND=="30"){
		argoSetValue(sSelectorId, top.gLoginUser.TEAM_CDS);
		argoSetValue(sSelectorNm, top.gLoginUser.TEAM_NMS);
	}
	
 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('소속 선택', gGlobal.ROOT_PATH+'/common/DeptChoice01F.do', '400', '650' );		
	});	
}


/**
 * 조직선택(트리그리드) 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 조직ID,조직명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetDeptChoice02("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); 
 *   
 */
function argoSetDeptChoice02(sSelector ,oOptions) {
	 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
 	//  입력란 엔터키 일때 팝업 호출
 	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	    
    
	// 현 화면에 대한 접근권한이[조] 또는 [개인]이면 로그인사용자 정보로 기본 설정, 비활성 처리
	if(top.gMenu.SCOPE_KIND=="40" || top.gMenu.SCOPE_KIND=="50") {
		argoSetValue(sSelectorId, top.gLoginUser.DEPT_CD ) ; 
		argoSetValue(sSelectorNm, top.gLoginUser.DEPT_NM ) ;
		
		argoDisable(true, sSelector);
		argoDisable(true, sSelectorNm);		
	}else { // 접근권한이 [전체]가 아닌 경우 해당  해당 조직코드가 기본 조건으로 처리되기 위해 DEPT_CD에 해당값 설정
		 if(top.gMenu.SCOPE_KIND=="90")      argoSetValue(sSelectorId, top.gMenu.GRANT_DEPT_CD ) ; // 직접지정인 경우 
		 else if(top.gMenu.SCOPE_KIND=="10") argoSetValue(sSelectorId, top.gLoginUser.CENTER_CDS ) ; //센터
		 else if(top.gMenu.SCOPE_KIND=="20") argoSetValue(sSelectorId, top.gLoginUser.PART_CDS ) ;   //파트	  
		 else if(top.gMenu.SCOPE_KIND=="30") argoSetValue(sSelectorId, top.gLoginUser.TEAM_CDS ) ;   //팀
	}    

 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('소속 선택', gGlobal.ROOT_PATH+'/common/DeptChoice02F.do', '400', '600');			
	});	
}


/**
 * 조직선택(트리그리드) 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 조직ID,조직명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetDeptChoice02("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); 
 *   
 */
function argoSetDeptChoice02_02(sSelector ,oOptions) {
	 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
//  입력란 엔터키 일때 팝업 호출
 	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	    
    
	// 현 화면에 대한 접근권한이[조] 또는 [개인]이면 로그인사용자 정보로 기본 설정, 비활성 처리
	if(top.gMenu.SCOPE_KIND=="40" || top.gMenu.SCOPE_KIND=="50") {
		argoSetValue(sSelectorId, top.gLoginUser.DEPT_CD ) ; 
		argoSetValue(sSelectorNm, top.gLoginUser.DEPT_NM ) ;
		
		argoDisable(true, sSelector);
		argoDisable(true, sSelectorNm);		
	}else { // 접근권한이 [전체]가 아닌 경우 해당  해당 조직코드가 기본 조건으로 처리되기 위해 DEPT_CD에 해당값 설정
		 if(top.gMenu.SCOPE_KIND=="90")      argoSetValue(sSelectorId, top.gMenu.GRANT_DEPT_CD ) ; // 직접지정인 경우 
		 else if(top.gMenu.SCOPE_KIND=="10") argoSetValue(sSelectorId, top.gLoginUser.CENTER_CDS ) ; //센터
		 else if(top.gMenu.SCOPE_KIND=="20") argoSetValue(sSelectorId, top.gLoginUser.PART_CDS ) ;   //파트	  
		 else if(top.gMenu.SCOPE_KIND=="30") argoSetValue(sSelectorId, top.gLoginUser.TEAM_CDS ) ;   //팀
	}        

 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('소속 선택', gGlobal.ROOT_PATH+'/common/DeptChoice02_02F.do', '400', '600');			
	});	
}

/**
 * 상담사 선택 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 상담사ID,상담사명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetUserChoice01("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); 
 */

function argoSetUserChoice01(sSelector,oOptions ) {
 
	
	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }

	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
   
 	//  입력란 엔터키 일때 팝업 호출
 	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
	// 현 화면에 대한 접근권한이 [개인]이면 로그인사용자 정보로 기본 설정, 비활성 처리
	if(top.gMenu.SCOPE_KIND=="50") {
		argoSetValue(sSelectorId, top.gLoginUser.AGENT_ID ) ; 
		argoSetValue(sSelectorNm, top.gLoginUser.AGENT_NM ) ;
		
		argoDisable(true, sSelector);
		argoDisable(true, sSelectorNm);		
	}
	
 	
 	$(sSelectorNm).keydown(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13) 			
 		 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
	 		gPopupOptions = oOptions;	
	 		argoPopupWindow('상담사 선택', gGlobal.ROOT_PATH+'/common/UserChoice01F.do', '1066', '676' );
 		 }
	});	
 	
 	$(sSelectorNm).focusout(function(){
 		if($(sSelectorNm).val().trim()=='')  $(sSelectorId).val('') ;
	});	

 	$(sSelector).click(function(){
 	 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
 		gPopupOptions = oOptions ; 		
 		argoPopupWindow('상담사 선택', gGlobal.ROOT_PATH+'/common/UserChoice01F.do', '1066', '676' );
	});	
}

/**
 * 직급별 상담사 선택 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 상담사ID,상담사명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetUserChoice02("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); 
 */
function argoSetUserChoice02(sSelector,oOptions ) {
 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }

	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
    	//  입력란 엔터키 일때 팝업 호출
 	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
	// 현 화면에 대한 접근권한이 [개인]이면 로그인사용자 정보로 기본 설정, 비활성 처리
	if(top.gMenu.SCOPE_KIND=="50") {
		argoSetValue(sSelectorId, top.gLoginUser.AGENT_ID ) ; 
		argoSetValue(sSelectorNm, top.gLoginUser.AGENT_NM ) ;
		
		argoDisable(true, sSelector);
		argoDisable(true, sSelectorNm);		
	}
 	
 	$(sSelectorNm).keydown(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13) 			
 		 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
	 		gPopupOptions = oOptions;	
	 		argoPopupWindow('직급별 상담사 선택', gGlobal.ROOT_PATH+'/common/UserChoice02F.do', '900', '600');
 		 }
	});	
    
 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
	    argoPopupWindow('직급별 상담사 선택', gGlobal.ROOT_PATH+'/common/UserChoice02F.do', '900', '600');		
	});	
}

/**
 * 직책별 상담사 선택 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 상담사ID,상담사명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetUserChoice02("btn_Dept1", {"targetObj":"s_Dept1", "multiYn":'Y'}); 
 */
function argoSetUserChoice03(sSelector,oOptions ) {
 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }

	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
     	//  입력란 엔터키 일때 팝업 호출
 	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
 	$(sSelectorNm).keydown(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13) 			
 		 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
	 		gPopupOptions = oOptions;	
	 		argoPopupWindow('평가자 선택', gGlobal.ROOT_PATH+'/common/UserChoice03F.do', '900', '600');
 		 }
	});	
    
 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		oOptions['searchKey'] = $(sSelectorNm).val() ;
	    argoPopupWindow('평가자 선택', gGlobal.ROOT_PATH+'/common/UserChoice03F.do', '900', '600');		
	});	
}



function argoSetUserChoice04(sSelector,oOptions ) {
	 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }

	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
     	//  입력란 엔터키 일때 팝업 호출
 	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
 	$(sSelectorNm).keydown(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13) 			
 		 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
	 		gPopupOptions = oOptions;	
	 		argoPopupWindow('평가자 선택', gGlobal.ROOT_PATH+'/common/UserChoice04F.do', '900', '600');
 		 }
	});	
    
 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		oOptions['searchKey'] = $(sSelectorNm).val() ;
	    argoPopupWindow('평가자 선택', gGlobal.ROOT_PATH+'/common/UserChoice04F.do', '900', '600');		
	});	
}

/**
 * QA 평가표 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 조직ID,조직명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetEduSheetChoice("btn_Sheet", {"targetObj":"s_Sheet", "multiYn":'Y'}); 
 *   
 */
function argoSetQaSheetChoice(sSelector ,oOptions) {
 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('평가표 선택', gGlobal.ROOT_PATH+'/common/QaSheetChoiceF.do', '900', '600' );		
	});	
}

/**
 * QA 평가계획표 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 조직ID,조직명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetEduSheetChoice("btn_Sheet", {"targetObj":"s_Sheet", "multiYn":'Y'}); 
 *   
 */
function argoSetQaTimesChoice(sSelector ,oOptions) {
 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
 	$(sSelectorNm).keydown(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13) 			
 		 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
	 		gPopupOptions = oOptions;	
	 		argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/QaTimesChoiceF.do', '900', '600' );
 		 }
	});	
 	
 	$(sSelectorNm).focusout(function(){
 		if($(sSelectorNm).val().trim()=='')  $(sSelectorId).val('') ;
	});	
    
    
 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/QaTimesChoiceF.do', '900', '600' );		
	});	
}

/**
 * HR 평가계획표 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 계획ID, 계획명 input ID 의 Prefix 예) s_ScheId , s_ScheNm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetHrScheChoice("btn_Sche", {"targetObj":"s_Sche", "multiYn":'Y'}); 
 *   
 */
function argoSetHrScheChoice(sSelector ,oOptions) {
	 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
 	$(sSelectorNm).keydown(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13) 			
 		 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
	 		gPopupOptions = oOptions;	
	 		argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/HrScheChoiceF.do', '900', '600' );
 		 }
	});	
 	
 	$(sSelectorNm).focusout(function(){
 		if($(sSelectorNm).val().trim()=='')  $(sSelectorId).val('') ;
	});	
    
    
 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/HrScheChoiceF.do', '900', '600' );
	});	
}

/**
 * EDU 교육선택 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 조직ID,조직명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetEduSheetChoice("btn_Sheet", {"targetObj":"s_Sheet", "multiYn":'Y'}); 
 *   
 */
function argoSetEduSheetChoice(sSelector ,oOptions) {
 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('시험지 선택', gGlobal.ROOT_PATH+'/common/SheetChoiceF.do', '900', '600' );		
	});	
}




/**
 * EDU 평가계획 선택 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 조직ID,조직명 input ID 의 Prefix 예) s_Dept1_Id , s_Dept1_Nm ==> s_Dept1
 *                    multiYn   : Y/N 
 * e.g argoSetEduExamChoice("btn_Sheet", {"targetObj":"s_Sheet", "multiYn":'Y'}); 
 *   
 */
function argoSetEduExamChoice(sSelector ,oOptions) {
 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('평가계획 선택', gGlobal.ROOT_PATH+'/common/ExamChoiceF.do', '900', '600' );		
	});	
}

/**
 * EDU 교육계획 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 계획ID, 계획명 input ID 의 Prefix 예) s_ScheId , s_ScheNm ==> s_Sche
 *                    multiYn   : Y/N 
 * e.g argoSetEduScheChoice("btn_Sche", {"targetObj":"s_Sche", "multiYn":'Y'}); 
 *   
 */
function argoSetEduScheChoice(sSelector ,oOptions) {
	 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };

	var sSelectorNm = '#'+oOptions.targetObj+'Nm' ;
 	var sSelectorId = '#'+oOptions.targetObj+'Id' ;
 	
 	$(sSelectorNm).keydown(function(key){
 		 if(key.keyCode == 13){//키가 13이면 실행 (엔터는 13) 			
 		 	oOptions['searchKey'] = $(sSelectorNm).val() ; //입력란의 값을 팝업에 넘기기 위해
	 		gPopupOptions = oOptions;	
	 		argoPopupWindow('교육계획 선택', gGlobal.ROOT_PATH+'/common/EduScheChoiceF.do', '900', '600' );
 		 }
	});	
 	
 	$(sSelectorNm).focusout(function(){
 		if($(sSelectorNm).val().trim()=='')  $(sSelectorId).val('') ;
	});	
    
    
 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('교육계획 선택', gGlobal.ROOT_PATH+'/common/EduScheChoiceF.do', '900', '600' );
	});	
}

/**
 * HR 평가표 선택 팝업 연결 처리
 * @param String sSelector (필수) - 버튼ID
 * {} oOptions(필수) - targetObj : 평가표ID, 평가표Name input ID 의 Prefix 예) ip_SheetId , ip_SheetNm ==> ip_Sheet
 *                    multiYn   : Y/N 
 * e.g argoSetHrSheetChoice("btn_Sheet", {"targetObj" : "ip_Sheet", "multiYn":'Y'}); 
 *   
 */
function argoSetHrSheetChoice(sSelector ,oOptions) {
 
	if (typeof sSelector == 'string') {
 		if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
	}
 	
	oOptions = oOptions || {};
	oOptions.get = function(key, value) {
		return this[key] === undefined ? value : this[key];
	};

 	$(sSelector).click(function(){
 		gPopupOptions = oOptions ;
 		argoPopupWindow('평가표 선택', gGlobal.ROOT_PATH+'/common/HrSheetChoiceF.do', '900', '600' );		
	});	
}


/**
 * 화면의 권한에 따른 버튼 비활성처리
 * @param  {String} sSelector   버튼객체를 포함한 오브젝트명  e.g) '#ivSeaarchCond'  또는 화면 전체를 보낼경우 document
 */
function argoSetGrant(sSelector ) {
 
 	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
 	var sMenuGrant = top.gMenu.SCOPE_KIND ;
    if(sMenuGrant !="" ) {
    	$(sSelector).find('button,input[type=file]').each(function(index, ele) {
            var $searchObj = $(ele);
           if( !_isBtnEnabled('#'+$searchObj.attr("id"))){
            argoDisable(true, $searchObj.attr("id")) ;
           }
        });
    }
}
/**메뉴권한에 따라 버튼 활성 가능 여부 체크
 * 권한 : 관리자(A)/쓰기(W)/읽기(R)
 * 메뉴권한 W 일때 버튼 권한 A 는 불가능
 * 메뉴권한 R 일때 버튼 권한 A,W 불가능
*/
function _isBtnEnabled(sSelector){
	
	var $searchObj = $(sSelector);
    var strBtnGrant = $searchObj.attr("data-grant") ; //버튼의 권한
    var sMenuGrant = top.gMenu.SCOPE_KIND ; //화면의 권한
    
    var rltValue = true ;    
    
    // EXCEL 버튼과 권한이 분리되므로
    
     if(strBtnGrant=="E") {
    	 if(top.gMenu.EXCEL_GRANT == "N")  rltValue = false ;  
    	 
     }else {    
	      if((sMenuGrant=='W' && strBtnGrant=='A') || (sMenuGrant=='R' && (strBtnGrant=='A' || strBtnGrant=='W' || strBtnGrant=='D'))) {
	    	 rltValue = false ;    	 
	     }
     }
	return rltValue ;
}
/**
 * 객체 활성/비활성 처리
 * 활성처리시 메뉴권한에 따라 체크
 * @param             TF true(disabled)/false(enabled)
 * @param target     객체대상리스트. 콤마(,)구분자로 
 * e.g argoDisable(true, '#rd01,#chk01,#s_Text,#btnSearch'); //비활성처리
 *    argoDisable(false, '#rd01,#chk01,#s_Text,#btnSearch'); //활성처리
 * 
 */
function argoDisable(TF, target){
    var arrary = target.split(",");
    var $oObj;
    var sObj = "select checkbox button radio input" ; //disabled/endabled 처리되어야 할 오브젝트 그 외는 readonly
    var sSelector ;
    var sRadio ;
    
    for(var i=0 ; i < arrary.length ; i++){
    	
    	sSelector =   $.trim(arrary[i]);
    	sRadio    =   sSelector ;
    	if (typeof sSelector == 'string') {
            if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
        }
        $oObj = $(sSelector);
        
        if ($oObj.length==0) $oObj = $('[name='+ sRadio+']'); // Radio 인 경우 sSelector 를 가지는 id 가 아닌 name 이므로

        if(TF){
            if(  sObj.indexOf($oObj.attr("type"))!= -1  || ($oObj.length>0 && sObj.indexOf($oObj.get(0).tagName.toLowerCase())!= -1 ) ){
            	
            	$oObj.attr("disabled","disabled");
            }else{
                $oObj.attr("readonly", true);
         //       $oObj.css("background-color","#dddddd");
            }       
        }else{
        	// 화면 내에서 개별적으로 버튼 활성화  호출하더라도  메뉴권한에 따른 체크 한다
        	var isBtnEnabled = true ;
        	
        	if($oObj.attr("type")=="button" || ($oObj.length>0 && $oObj.get(0).tagName.toLowerCase()=="button")){
        		isBtnEnabled = _isBtnEnabled(sSelector);        		
        	}
        	
        	if(isBtnEnabled) {
	        	if(sObj.indexOf($oObj.attr("type"))!= -1 || ($oObj.length>0 && sObj.indexOf($oObj.get(0).tagName.toLowerCase())!= -1 ) ){
	        	    $oObj.removeAttr("disabled");
	        	//    $oObj.css("background-color","");
	             }else{
	                $oObj.removeAttr("readonly");
	           //     $oObj.css("background-color","");
	            }    
        	}else {
        		console.log("[INFO] 버튼 권한이 없어 활성처리 거부 되었습니다.")
        	}
        }       
    }
}

/**
 * 객체 hide/show 처리
 * @param TF true(show)/false(hide)
 * @param target     객체대상리스트. 콤마(,)구분자로 
 * e.g argoVisible(true, '#rd01,#chk01,#s_Text,#btnSearch'); //show처리
 *     argoVisible(false, '#rd01,#chk01,#s_Text,#btnSearch'); //hide처리 * 
 */
function argoHide(TF, target){
    var arrary = target.split(",");
    var $oObj;
    var sSelector ;
    for(var i=0 ; i < arrary.length ; i++){ 
    	sSelector =   $.trim(arrary[i]);
    	
    	if (typeof sSelector == 'string') {
            if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
        }
        $oObj = $(sSelector);
        if(TF){
        $oObj.hide();
        }else {
        	$oObj.show();	
        }
    }
}   

/**
 * argoSetGridStyle 그리드 공통 스타일 적용
 * @param sSelector (필수)
 * oOptions (선택) - isPanel(그룹핑표시여부), isCheckBar(체크바표시여부), isEditable(수정가능여부), isFooter(푸터표시여부)
 * @returns
 */
function argoSetGridStyle(sSelector ,oOptions){
	
	oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
    
    
	sSelector.setStyles({
	    body:   { "fontSize": "12", "fontFamily": "Nanum Gothic", "fontBold": "false", "background":"#ffffff", "foreground":"#444444",
	    	line:"#ffcccccc,0" 
	    		},
		header: { "fontSize": "13", "fontFamily": "Nanum Gothic", "fontBold": "true", "background":"#fafafa", "foreground":"#444444"
					,"selectedBackground":"#ff376e96", 
			        "selectedForeground":"#ffffffff", 
			        "hoveredBackground":"#ffdeeef9",
			        "hoveredForeground":"#ff376e96",
			        "group": {
			        	"fontSize": "13", "fontFamily": "Nanum Gothic", "fontBold": "true", "background":"#fafafa", "foreground":"#444444"
							,"selectedBackground":"#ff376e96", 
					        "selectedForeground":"#ffffffff", 
					        "hoveredBackground":"#ffdeeef9",
					        "hoveredForeground":"#ff376e96"			        	
			        }
		},
		footer:{
			"background": "#ffdee2e7",
	        "iconLocation": "left",
	        "border": "#88888888,1",
	        "iconAlignment": "center",
	        "iconOffset": "0",
	        "borderTop": "#ff79828b,1",
	        "selectedBackground": "#ff696969",
	        "contentFit": "auto",
	        "inactiveBackground": "#ffd3d3d3",
	        "selectionDisplay": "mask",
	        "iconPadding": "0",
	        "hoveredMaskBackground": "#1f5292f7",
	        "hoveredMaskBorder": "#335292f7,1",
	        "paddingRight": "2",
	        "paddingBottom": "1",
	        "paddingTop": "2",
	        "figureBackground": "#ff008800",
	        "selectedForeground": "#ffffffff",
	        "foreground": "#ff000000",
	        "inactiveForeground": "#ff808080",
	        "textAlignment": "near",
	        "borderLeft": "#ffffffff,1",
	        "lineAlignment": "center",
	        "borderRight": "#ff9099a3,1",
	        "borderBottom": "#88888888,1",
	        "iconIndex": "0"
		},
		selection: {
		//	background: "#40f8f4e8",
			background: "#169a7512",
			border: "#ffffffff,0"
		}
		,checkBar: {
			figureBackground: "#ef5b30",
			"borderRight": "#ffcccccc,1", "borderBottom": "#ffcccccc,1",
			head: {
				figureBackground: "#ef5b30"
			}
		},
		statusBar: {			
			"borderRight": "#ffcccccc,1", "borderBottom": "#ffcccccc,1"		
		},
		indicator: {
			"fontSize": "12", "fontFamily": "Nanum Gothic", "fontBold": "false", "background":"#ebf3fc", "foreground":"#444444",
			"borderRight": "#ffcccccc,1", "borderBottom": "#ffcccccc,1", "selectedForeground": "#ffff0000","selectedBackground": "#fff8f4e8"
		},
		fixed: {"background": "#fff1f1f1","foreground": "#ff444444","borderRight": "#ffcccccc,1", "borderBottom": "#ffcccccc,1"
			
		}		
		
		});
	    
	sSelector.setOptions({
	        header: {
	            minHeight: 31
	        },
			display: {
				rowHeight: 29
			}
	    });
	
	sSelector.setDisplayOptions({
        fitStyle: "evenFill",
   		 showEmptyMessage:true, 
		 emptyMessage:"자료가 없습니다"     
			 ,focusColor:"#ed992b",
			 showInnerFocus: false  //Merged Cell에서 개별 cell 영역 표시 여부를 지정한다.
    });
	
	sSelector.setStyles({
		 body:{
		 empty:{
		//     background:"#2100ff00", 
		     textAlignment:"center", 
		     lineAlignment:"center", 
		     fontSize:15, 
		     fontBold:true
		 }
		 }
		});
		
	 if(oOptions.isPanel!=undefined){
	 sSelector.setOptions({
		 panel: {
			 visible: oOptions.isPanel //그룹핑 패널 표시여부
	        }
	    });
	 }
	 if(oOptions.isCheckBar!=undefined){
		 sSelector.setOptions({
			 checkBar: {
				 visible: oOptions.isCheckBar
		        }
		    });
		 }	 

	 if(oOptions.isEditable!=undefined){
		 sSelector.setOptions({
			 edit: {
		        	editable :  oOptions.isEditable,
		            insertable: oOptions.isEditable,
		            appendable: oOptions.isEditable,
		            deletable:  oOptions.isEditable
		        }
		    });
		 
		  //CUD상태를 표현하는 Indicator 표시여부
		 sSelector.setStateBar({
		        visible: oOptions.isEditable
		    });
		 
		 if(oOptions.isEditable== true){
			 sSelector.setStyles({
			        body : {
			            cellDynamicStyles : [{
			                criteria : "state = 'c'",
			                styles : "background=#f6fdec;foreground=#8fb45b"			                
			            },{
			                criteria : "state = 'u'",
			                styles : "background=#eaf5fd;foreground=#5791bb"			                			                
			            },{
			                criteria : "state = 'd'",
			                styles : "background=#fde6de;foreground=#d66740"
			            }]
			        }
			    });
			 }else {
				    //ROW단위로 Selection
				 sSelector.setSelectOptions({
				    	 style: "rows"
				    });
			 }
	 }

	 if(oOptions.isFooter!=undefined){
		 sSelector.setFooter({	      
		        visible: oOptions.isFooter	      
		    });
	 }	
	 
	sSelector.setSortingOptions({keepFocusedRow:true});
	 
	sSelector.onIndicatorCellClicked=function (grid, index) {	// 최상단 좌측 클릭 시 전체 선택 
		var endItem = sSelector.getItemCount();
		var sel = {startItem: 0, endItem: endItem, style: "rows"};
		sSelector.setSelection(sel);
	};
	
	document.onclick = function(event) {	//canvas 밖으로 focus 간 경우 edit commit 하기 위함
    	if(!(event.target instanceof HTMLCanvasElement)){
        	sSelector.commit();
    	}
	}
	
}



/**
 * argoSetDatePicker 날짜선택 입력 박스 에 달력버튼 설정처리
 * @param N/A
 * @returns
 */
function argoSetDatePicker(){
	$( ".datepicker" ).datepicker({
		  showOn: "button",
		  buttonImage: gGlobal.ROOT_PATH+"/images/icon_calendar.gif",
		  buttonImageOnly: true,
		  buttonText: "Select date",
		  dateFormat: "yy-mm-dd",
		  dayNamesMin: [ "일", "월", "화", "수", "목", "금", "토" ],
		  monthNames: [ "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월" ],
		  monthNamesShort: [ "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월" ],
		  changeMonth: true,
	      changeYear: true,
	      onSelect: function (){
	    	  $(this).change();
	      },
	 	  onClose: function () {
               $(this).change();
            }
		});
}

/**
 * argoSetYearMonthPicker 년월선택 입력 박스 에 버튼 설정처리
 * @param oOptions : next_mState 생략시 기본값은 true
next_mState:false 지정시 현재달 기준 다음달부터 클릭이벤트 및 표시 비활성화
argoSetYearMonthPicker({ next_mState:false });
 * @returns
 */
function argoSetYearMonthPicker(oOptions){
	
	oOptions = oOptions ||{};
	
	
	
	
	$(".yearMonth_date").dateSelect(oOptions);
	
	
	
	
	
	
	
	
}

/**
 * argoSetTimePicker 시간선택 입력 박스 에 시간버튼 설정처리
 * @param 	(use_sec 생략시 기본값 : false)
 * argoSetTimePicker();
 * argoSetTimePicker({use_sec:true})
 * @returns
 */
function argoSetTimePicker(oOptions){
	/*
	oOptions = oOptions ||{
		show_meridian:false,
		min_hour_value:0,
		max_hour_value:23,
		overflow_minutes:true,
		increase_direction:'up'
	};
	    */
	$('.timepicker').timeSelect(oOptions); 
}

/**
 * argoSetNumberPicker 년월선택 입력 박스 에 버튼 설정처리
 * @param oOptions : max:100,
		min:0,
		set_num:100
argoSetNumberPicker({ next_mState:false });
 * @returns
 */
function argoSetNumberPicker(oOptions){
	
	oOptions = oOptions ||{};
	 
	$(".count_num").countNum(oOptions);
}

/**
 * argoSetDateTerm 날짜기간 선택 Select 박스 처리
 * @param sSelector : 날짜선택구분 콤보박스id
 * oOptions : 초기선택값 등 
 * jData    : 당일, 1주, 1개월,3개월 외 다른 기간 조건 사용시 해당 데이터
 * @returns
 */
function argoSetDateTerm(sSelector,oOptions,jData){
	    oOptions = oOptions || {};
	    oOptions.get = function(key, value) {
	     return this[key] === undefined ? value : this[key];
	    };
	    
		var onlyMonth ;
		if (oOptions.onlyMonth != undefined) {
			onlyMonth = oOptions.onlyMonth ;
		}else {
			onlyMonth = 'N' ;
		}	
	   
	    if (typeof jData == "undefined" || jData == null || jData.length == 0) { 
	    	if(onlyMonth=="Y"){
		    	jData =[  {"codeNm":"당월","code" :"M_0"}
						,{"codeNm":"3개월","code" :"M_2"}
						,{"codeNm":"6개월","code":"M_5"}
						,{"codeNm":"12개월","code":"M_11"}] ;	    		
	    	}else {
		    	jData = [{"codeNm":"당일","code" :"T_0"}
						,{"codeNm":"1주","code" :"W_1"}
						,{"codeNm":"1개월","code":"M_1"}
						,{"codeNm":"3개월","code":"M_3"}] ;
	    	}
	    }
	    if (typeof sSelector == 'string') {
	        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
	    }
	    
        var objId ;
		if (oOptions.targetObj != undefined) {
			objId = oOptions.targetObj ;
		}else {
			objId = 'txtDate' ;
		}
		
	    $(sSelector).change(function(){
	        var sTerm = $(sSelector+' option:selected').val() ;
	        _selTermOnchange(sTerm,objId,onlyMonth  );
	    });
	    
	    $(sSelector).empty();

	    //조회결과를 select box에 추가
	    $.each(jData, function(i, row){
	            $(sSelector).append($('<option>').text(row.codeNm).attr('value', row.code));
	    });
	   
	    //selectValue 값으로 선책 처리
	    if (oOptions.selectValue != undefined) {
	    		 $(sSelector).val(oOptions.selectValue).attr("selected", "selected");
	    	}else {
	    		 $(sSelector+ " option:eq(0)").attr("selected", "selected");
	   	}
	    
	    _selTermOnchange($(sSelector+' option:selected').val() ,objId,onlyMonth ) ;
}

function _selTermOnchange(pTerm, pObjId,pOnlyMonth){

    var arrTerm = pTerm.split("_");

    if(arrTerm.length <2) {
    	console.log("날짜구분값 오류입니다.");
    	return;
    }
    
    var nDay = parseInt(arrTerm[1]);
    
  	var strFromDate ;
	var strToDate   ;
	switch (arrTerm[0]) {
	  case 'T'  : 		      
	 			 strToDate   = argoDateToStr(argoAddDate(argoCurrentDateToStr(), -nDay)) ;
	 			 strFromDate = argoDateToStr(argoAddDate(strToDate, -nDay)) ;
	       break;
	  case 'W' : 
		 		  strToDate   = argoCurrentDateToStr() ;
		 		  strFromDate = argoDateToStr(argoAddDate(strToDate, -(nDay*7))) ;
	       break;
	  case 'M'  : strToDate   = argoCurrentDateToStr() ;
				  strFromDate = argoDateToStr(argoAddMonth(strToDate, -nDay, pOnlyMonth)) ;
	       break;
	  case 'S' :
		  		  strToDate   = argoCurrentDateToStr();
		  		  strFromDate = argoDateToStr(argoAddDate(strToDate, -nDay+ 2)) ;
		  break;	       
	  default   : strFromDate = argoCurrentDateToStr() ;
		  		  strToDate   = argoCurrentDateToStr() ;
	       break;
	} 
	
	if(pOnlyMonth=="Y"){
		strFromDate = argoSetFormat(strFromDate,"-","4-2") ;
		strToDate   = argoSetFormat(strToDate,"-"  ,"4-2") ;
		
	}else {
		strFromDate = argoSetFormat(strFromDate,"-","4-2-2") ;
		strToDate   = argoSetFormat(strToDate,"-"  ,"4-2-2") ;
	}
	
	$('#'+pObjId+'_From').val( strFromDate);	
	$('#'+pObjId+'_To').val( strToDate);		
	
}

/**
 * argoGetSearchMaxTerm 날짜기간 선택 Select 박스에 따른 최대 검색 기간 일수
 * @param toDate         : 검색기간 to
 * @param jData          : 당일, 1주, 1개월,3개월 외 다른 기간 조건 사용시 해당 데이터
 * @returns maxSearchDay : 최대 검색 기간 일수
 */
function argoGetSearchMaxTerm(toDate, jData) {
	var maxSearchDay = 31;
	var maxMonTerm = 0;
	
	$.each(jData, function(i, row) {
		var arrTerm = (row.code).split("_");

	    if(arrTerm.length < 2) {
	    	console.log("날짜구분값 오류입니다.");
	    	return;
	    }
	    
	    if(arrTerm[0] == "M") {
	    	if(maxMonTerm < arrTerm[1]) {
	    		maxMonTerm = arrTerm[1];
	    	}
	    }
	});
	
	if(maxMonTerm > 0) {
		var nDay = parseInt(maxMonTerm);
		var fromDate = argoSetFormat(argoDateToStr(argoAddMonth(toDate.replace(/-/g,""), -nDay)), "-", "4-2-2");

		maxSearchDay = fnDiffDate(fromDate, toDate);
	}
	
	return maxSearchDay;
}


/**
 * Chart 생성
 * @param div, chartType, jData, color
 * @returns
 */
function argoAmChart(sSelector, chartType, jData, color){
    return new _argoDrawChart(sSelector, chartType, jData, color);
}

/**
 * Chart 객체 생성
 * @param div, chartType, jData, color
 * @returns
 */
function _argoDrawChart(div, chartType, jData, color){
    var target = div;
    
    /* Draw Chart */
    var chart, prop;
    switch(chartType){
        case "radar":
            prop = {
                        "type": "radar"
                       ,"categoryField": ""
                       ,"guides": []
                       ,"dataProvider": jData
                       ,"theme": "light"
                   };
            break;
            
        case "serial":
            prop = {
                       "type": "serial"
                      ,"dataProvider": jData
                      ,"categoryField": ""
                      ,"categoryAxis": {
                          "minorGridEnabled": true
                      }  
                      ,"chartCursor": {
                          "cursorAlpha": "0.1"
                          ,"fullWidth": true
                      }
                      ,"theme": "light"
                   };
            break;
            
        case "pie":
            prop = {
                       "type": "pie"
                      ,"dataProvider": jData    
                      ,"titleField": ""
                      ,"valueField": ""    
                      ,"angle": 10
                      ,"balloonText": ""
                      ,"depth3D": 10
                      ,"innerRadius": "30%"
//                      ,"labelRadius": -30
                      ,"labelText": ""
                      ,"radius": 90
                      ,"outlineAlpha": 0.8
                      ,"theme": "light"
                    };
            break;

        case "funnel":
            prop =  {
                       "type": "funnel"
                      ,"dataProvider": jData
                      ,"balloonText": ""
                      ,"outlineAlpha": 0.8
                      ,"titleField": ""
                      ,"valueField": ""
                      ,"labelPosition": "right"
                      ,"neckHeight": "30%"
                      ,"neckWidth": "40%"
                      ,"marginRight": 120
                      ,"marginTop": 0
                      ,"theme": "light"                        
                    };
            break;
            
        default:
            prop = {"dataProvider": jData};
            break;    
    }
    
    if(color!==undefined){
        prop.colors = color;
    }
       
    /* Add Item */
    var addItem = function(item){
        $.extend(prop, item);
    };

    /* Get Chart */
    var getChart = function(){
        return chart;
    };
    
    var getDiv = function(){
        return target;
    };
    
    return{
        init : function(){
            //alert('init..');
        },
        getChart : getChart,
        getDiv  : getDiv,
        addItem : addItem,
        makeChart : function(){
            argoConsoleLog("amChart", JSON.stringify(prop));
            //console.log(JSON.stringify(prop));
            chart = AmCharts.makeChart(target, prop);
            //chart.addListener("clickGraphItem", function(event){alert(event.item.category + ": " + event.item.values.value);});
            chart.write(target);
        }
    };
}


/** 
 * 쿠기값설정
 * @param  {String}    key
 * @param  {String}    value
 */
function argoSetCookie(key, value, expire){
    var oOpion = { path: gGlobal.ROOT_PATH };
    if(expire && !isNaN(expire)) oOpion.expires = expire; 
    $.cookie(key, value, oOpion);
}

/** 
 * 쿠기값 GET
 * @param  {String}    key
 * @return {String}
 */
function argoGetCookie(key){
    return $.cookie(key);
}

/**
 * 쿠키 삭제
 * @param     {String}     key
 * @param     {json}         option
 * @returns {bloon}     
 */
function argoRemoveCookie(key, option){
    var oOpion = {path: gGlobal.ROOT_PATH};
    if(option) $.extend(oOpion, option);
    return $.removeCookie(key, oOpion);
}


/**
 * 그리드 공통 조회메소드
 *  데이터조회 후 그리드의 dataProvider에 필드 및 데이터 설정처리함.
 * @param  {String} sDataProvider     그리드에 연결된 dataProvider 명
 * @param  {String} sServiceName  서비스명
 * @param  {String} sMethod       메소드명
 * @param  {String} sInPrefixName 인풋폼요소의 프리픽스명
 * @return {Json}   jResult       서비스정보에서 얻어온 Json객체를 반환
 * argoGrSearch("dataProvider", "SASAMPLE", "selectCenterList", "s")
 */
function argoGrSearch(sDataProvider, sServiceName, sMethod, sInPrefixName, oAddParam, ext) {    
    
    var iGlobal = $.extend(true, {}, gGlobal);
    if(typeof(ext)!="undefined")
        iGlobal = $.extend(true, iGlobal, ext);
    
    //서비스생성
    var service = new ArgoService
      (iGlobal.SVC_COMMON_ID,   //서비스아이디
       sServiceName,            //서비스명
       sMethod,                 //호출메소드
       iGlobal.SVC_DB_ARGODB,     //서비스타입
       iGlobal.SVC_DB_TYPE_LIST,//DB서비스타입
       "F",                     //인풋폼타입
       sInPrefixName,           //인풋프리픽스
       "G",                     //아웃폼타입
       sDataProvider,            //아웃명 - DataProvider명
       oAddParam);              //추가파라미터

    argoAction(service, _argoGrSearchCallback);
}
/**
 * 그리드 공통 콜백함수
 */
function _argoGrSearchCallback(data, textStatus, jqXHR){
    if(data.isOk()) {
    	var provider = ( new Function( 'return ' + data.getOutName() ))(); //dataProvider를 오브젝트로 변환
   	
    	provider.clearRows();
    	
    	if(data.getRows().length>0) {
    	var  fields = Object.keys( data.getRows()[0] ); // 첫레코드로 컬럼명 추출하여 필드 리스트 설정 
    	provider.setFields(fields);
    	}
		
    	
     	if(data.getRows() != "") provider.setRows(data.getRows());
    }
}

/**
 * 콤보령태의 공통 조회메소드
 * 
 * @param  {String} sSelector     콤보객체명
 * @param  {String} sServiceName  서비스명
 * @param  {String} sMethod       메소드명
 * @param  {String} sInPrefixName 인풋폼요소의 프리픽스명
 * @param  {String} oAddParam     키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallBack    콜백함수
 * @return {Json}   jResult       서비스정보에서 얻어온 Json객체를 반환
 */
function argoCbCreate(sSelector, sServiceName, sMethod, oAddParam, oOptions, fnCallBack, ext) {

   var iGlobal = $.extend(true, {}, gGlobal);
   if(typeof(ext)!="undefined")
       iGlobal = $.extend(true, iGlobal, ext);
       
   //서비스생성
   var service = new ArgoService
     (iGlobal.SVC_COMMON_ID,   //서비스아이디
      sServiceName,            //서비스명
      sMethod,                 //호출메소드
      iGlobal.SVC_DB_ARGODB,     //서비스타입
      iGlobal.SVC_DB_TYPE_LIST,//DB서비스타입
      "",                      //인풋폼타입
      "",                      //인풋폼명
      "C",                     //아웃폼타입
      sSelector,               //아웃명
      oAddParam);              //추가파라미터
   
   if(fnCallBack===undefined)
       fnCallBack = null;

   var jResult = argoAction(service, fnCallBack, oOptions);
   if(jResult)
           return jResult;
   else
           return null;
}

/**
* 비동기로 콤보박스를 생성하고 싶을때 argoCbCreate의 fnCallBack값에 _argoCbCallback로 호출.
* @param data
* @param textStatus
* @param jqXHR
* @param oCbOptions
*/
function _argoCbCallback(data, textStatus, jqXHR, oCbOptions){
   _cbCreate(data.getOutName(), data.getRows(), oCbOptions);
}

/**
 * combo생성함수
 * @param  {String} sSelector       콤보 셀렉터 문자열
 * @param  {Json}   jData           메소드가 loadData인 경우 데이터
 * @param  {Object} oOptions        콤보옵션
 */
//oOptions {text:'', value:'', selectValue:'', selectIndex:0}
function _cbCreate(sSelector, jData, oOptions) {
    oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
   
    //if (typeof jData == "undefined" || jData == null || jData.length == 0) { return; }
    
    if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
    
    $(sSelector).empty();
    
    // 전체 추가
    if (oOptions.text !== undefined) {
    	$(sSelector).append($('<option>').text(oOptions.text).attr('value', oOptions.value || ''));
    }

    //조회결과를 select box에 추가
    $.each(jData, function(i, row){
        // ADD BY 2017-02-23 콤보박스에 USERDATA 항목 추가
            $(sSelector).append($('<option>').text(row.codeNm).attr('value', row.code).attr('data-user1', row.userData1).attr('data-user2', row.userData2));
    });
   
    //선택 처리     
    //index 값으로 선택
    if (oOptions.selectIndex != undefined) {
    	if (oOptions.selectIndex >= 0) {
    		$(sSelector+ " option:eq("+ oOptions.selectIndex +")").attr("selected", "selected");
    		
    	}
    	}
  
    //VALUE 값으로 선책 처리
    if (oOptions.selectValue != undefined) {
    		 $(sSelector).val(oOptions.selectValue).attr("selected", "selected");
    	}
}

/**
* 입력항목 초기화 
* 각 입력항목의 초기값이 설정되어 있을 경우 해당 값으로 초기화 됨.
* 초기값 변수 설명 이하 참조
* input text | password | textarea | ==> data-defaultValue
* input checkbox | radio ==> data-defaultChecked = "true" 
* 
* @param selector - 초기화 대상 영역
*/
function argoFrmClear(sSelector) {
	
	if (typeof sSelector == 'string') {
        if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    }
	

    var $container = $(sSelector);
    // <input type="text|password" data-defaultValue="" />
    $container.find('input[type=text],input[type=password],input[type=hidden]').each(function(index, ele) {
        var $input = $(ele);
        $input.val($input.attr("data-defaultValue") != undefined ? $input.attr("data-defaultValue") : "");
    });
    
    // <select data-defaultValue="" />
    $container.find('select').each(function(index, ele) {
        var $input = $(ele);
        if($input.attr("data-defaultValue") != undefined ) {
        	$input.val($input.attr("data-defaultValue")).attr("selected", "selected");
        }else {
         	$input.val("");
        	$input.trigger('change') ;
        //	$input.val("").attr("selected", "selected");
        }
    });    
    
    // <textarea data-defaultValue="" />
    $container.find('textarea').each(function(index, ele) {
        var $input = $(ele);
        $input.val($input.attr("data-defaultValue") != undefined ? $input.attr("data-defaultValue") : "");
    });    
 
    // <input type="radio" defaultChecked="true" />
    $container.find("input[type=radio]").each(function(index, ele) {
        var $radio = $(ele);
        if ($radio.attr("data-defaultChecked") != undefined) {
        	 if ($(this).attr("data-defaultChecked") == "true") {
        		 this.checked = "checked";
        	 }
        }else {
        	$radio.prop("checked", false);
        }
    });
    // <input type="checkbox" defaultChecked="true" />
    $container.find("input[type=checkbox]").each(function(index, ele) {
        var $checkbox = $(ele);
        if ($checkbox.attr("data-defaultChecked") == undefined) {
            $checkbox.attr("checked", false);
        } else {
            if ($checkbox.attr("data-defaultChecked") == "true") {
                $checkbox.get(0).checked = "checked";
            } else {
                $checkbox.attr("checked", false);
            }
        }
    });
}

	

/**
 *  Form 정보값 설정
 *  json데이터의 값을 읽어서 preFix로 시작되는 입력오브젝트에 설정
 * @param prefixId      폼요소의 프리픽스
 * @param jData         JSON 데이터
 */
function argoSetValues(prefixId, jData) {
    var key = null;

    for (key in jData) {
        var sName = prefixId  + key.charAt(0).toUpperCase() + key.substring(1);
        argoSetValue(sName, jData[key]);
    }
}

/**
 * input요소 정보값 설정
 * @param sSelector     selector or name
 * @param sValue        값
 */
function argoSetValue(sSelector, sValue) {
    var jObj, oObj, sText;
    
    jObj = $((sSelector.indexOf("#") != 0 ? "#" + sSelector: sSelector)); 
    
   // jObj = $(sSelector);
    if (jObj.length==0) jObj = $('[name='+ sSelector+']'); // Radio 인 경우 sSelector 를 가지는 id 가 아닌 name 이므로
    
    //셀렉터 존재여부 확인
    if(jObj.length == 0) return;
    
    if(sValue===null || typeof(sValue)=="undefined")    sText = "";
    else sText = sValue;
    
    oObj = jObj.get(0);
    switch (oObj.tagName.toLowerCase()) {
        case "input":
            switch (oObj["type"].toLowerCase()) {
                case "radio":
                    // jquery bug 때문에 예외 처리 ( jquery-1.10.2.min.js )
                	
                    jObj = $("[name=" + oObj["name"] + "]");
                    jObj = jObj.attr("checked", false).filter("[value='" + sText + "']");
                    if (jObj.length > 0) jObj.get(0)["checked"] = true;
                    break;
                case "checkbox":
                    // jquery bug 때문에 예외 처리 ( jquery-1.10.2.min.js )
                    jObj = jObj.attr("checked", false).filter("[value='" + sText + "']");
                    if (jObj.length > 0) jObj.get(0)["checked"] = true;
                    break;
                default:
                      jObj.val(sText);

                    break;
            }
            break;
        case "select":
        	jObj.val(sText);
        	jObj.trigger("change"); // 셀렉트 박스 skin 값 변경
            break;
        case "textarea":
            jObj.val(sText);
            break;
    }
}


/**
 * UI 객체의 Value값을 리턴
 * @param sSelector    
 * @returns
 */
function argoGetValue(sSelector) {
    
    var jObj, oObj, sValue;

    jObj = $((sSelector.indexOf("#") != 0 ? "#" + sSelector: sSelector));
    if (jObj == null) jObj = $('[name='+ sSelector+']');
    
    if (jObj.length==0) jObj = $('[name='+ sSelector+']'); // Radio 인 경우 sSelector 를 가지는 id 가 아닌 name 이므로
    
    
    if (jObj == null) return null;
    
    // 0 번째
    oObj = jObj.get(0);
    //
    switch (oObj.tagName.toLowerCase()) {
        case "input":
            switch (oObj["type"].toLowerCase()) {
                case "radio":
                	sValue = $("input:radio[name="+sSelector+"]:checked").val();
                 //   sValue = $('[name='+sSelector+']').filter(":checked").val().trim();
//                    sValue = jObj.filter(":checked").val().trim();
                    break;
                case "checkbox":
                    sValue = jObj.filter(":checked").val()||"";
                    break;
                default:
                	sValue = jObj.val().trim();
                 }
            break;
        case "select":
            // id 인경우와 name 인경우 분리
        		sValue = jObj.val().trim();
            break;
        case "textarea":
            sValue = jObj.val().trim();
            break;
        default:
            sValue = null;
            break;
    }
    
    return sValue;
    
}

/**
 * argo Validator
 * @param  {String}    jsValidation   유효성이 정의된 구조체
 *  @param  {String}   popWinSize(옵션)     alrert 등의 사이즈 조절을 위한 구분값 / 
 * @return {boolean}   result         유효성 체크결과(true/false)
 * e.g
 * 		var aValidate = {
		        rows:[ 
				  {"check":"length", "id":"ip_JobexamKind"     , "minLength":1, "maxLength":50,  "msgLength":"계획구분을 선택하세요."}     
		         ,{"check":"length", "id":"ip_GuideCont"       , "minLength":0, "maxLength":256, "msgLength":"안내글은 256자(한글85자)자까지 입력가능합니다."}
		        ]
		    };	
		
	   if (argoValidator(aValidate) != true) return;
 */
function argoValidator(jsValidation, popWinSize) {
     
     var jsRows, jsRow, id, oObj, sCheck, sValue, jObj, iLength, iBytes;

     
     if (jsValidation == null || jsValidation["rows"] == null) return false;
     
     jsRows = jsValidation["rows"];
     iLength = jsRows.length;
     for (i = 0; i < iLength; i++) {
         //유효성 정보
         jsRow = jsRows[i];
         
        //엘리먼트로 변경
         if (jsRow.id != null) {
             jObj = $("#" + jsRow.id);
             id = jsRow.id;
         }

         if (jObj.length==0) jObj = $('[name='+ id+']'); // Radio 인 경우 sSelector 를 가지는 id 가 아닌 name 이므로
         
         //엘리먼트 존재여부 확인
         if (jObj.length == 0) {
        	if(popWinSize =="small") argoSmallAlert("항목을 찾을 수 없습니다. 대소문자가 일치하는지 확인 바랍니다.");
        	else	argoAlert("항목을 찾을 수 없습니다. 대소문자가 일치하는지 확인 바랍니다.");
             return false;
         }
         
         oObj = jObj.get(0);
         switch (oObj.tagName.toLowerCase()) {
             case "input":
                 switch (oObj.type.toLowerCase()) {
                     case "radio":
                          sValue = $("input[name='"+id+"']").filter(":checked").val();
                          if(typeof(sValue)=="undefined")    sValue = "";
                         break;                         
                     case "checkbox":
                         sValue = jObj.filter(":checked").val();
                         break;
                     default:
                         className = jObj.attr('class') + "";                        
                         sValue = jObj.val();
  
                         break;
                 };
                 break;
             case "select":
                        sValue = jObj.val();
                 break;
             case "textarea":
                 sValue = jObj.val();
         }
         
         sCheck = jsRow.check.toLowerCase();
         if (sCheck.search("value") > -1) {
        	 var rltValue = true ;
             switch (jsRow["opCode"]) {
                 case "!=":
                     if (sValue != jsRow["checkValue"]) {
                         if(popWinSize =="small")  argoSmallAlert(jsRow["msgValue"]);
                       	else argoAlert(jsRow["msgValue"]);
                         rltValue = false ;
                     }
                     break;
                 case ">=":
                     if (sValue >= jsRow["checkValue"]) {
                         if(popWinSize =="small")  argoSmallAlert(jsRow["msgValue"]);
                       	else argoAlert(jsRow["msgValue"]);
                         rltValue = false ;
                     }
                     break;
                 case "<=":
                     if (sValue <= jsRow["checkValue"]) {
                         if(popWinSize =="small")  argoSmallAlert(jsRow["msgValue"]);
                       	else argoAlert(jsRow["msgValue"]);
                         rltValue = false ;
                     }
                     break;
                 case ">":
                     if (sValue > jsRow["checkValue"]) {
                         if(popWinSize =="small")  argoSmallAlert(jsRow["msgValue"]);
                       	else argoAlert(jsRow["msgValue"]);
                        
                         rltValue = false ;
                     }
                     break;
                 case "<":
                     if (sValue < jsRow["checkValue"]) {
                         if(popWinSize =="small")  argoSmallAlert(jsRow["msgValue"]);
                       	else argoAlert(jsRow["msgValue"]);
                         rltValue = false ;
                     }
                     break;
                 default:
                     if (sValue == jsRow["checkValue"]) {
                         if(popWinSize =="small")  argoSmallAlert(jsRow["msgValue"]);
                       	else argoAlert(jsRow["msgValue"]);
                         rltValue = false ;
                     }
                     break;
             }
             
             if(rltValue==false ) return false ;             
         }
         
         if(sValue==null) sValue = "";
         
         if (sCheck.search("length") > -1) {
        	 
        	 //MODIFIED BY YAKIM 한글일 경우와 분리하여 길이 체크
        	 var totalByte = 0;
        	 for (var j = 0; j < sValue.length; j++) {
        		    var oneChar = sValue.charAt(i);
        		    if (escape(oneChar).length > 4) {
        		        totalByte += 3;
        		    } else {
        		        totalByte++;
        		    }
        	 }
               if (jsRow["minLength"] > totalByte) {
                if(popWinSize =="small")  argoSmallAlert(jsRow["msgLength"]);
               	else argoAlert(jsRow["msgLength"]);
                 
                 return false;
             }
             if (jsRow["maxLength"] <totalByte) {
                 if(popWinSize =="small")  argoSmallAlert(jsRow["msgLength"]);
                	else argoAlert(jsRow["msgLength"]);
                 return false;
             }
         }
         
         if (sCheck.search("bytes") > -1) {
             if (jsRow["minLength"] > sValue.byte()) {
                 argoAlert(jsRow["msgLength"]);
                 return false;
             }
             if (jsRow["maxLength"] < sValue.byte()) {
                 if(popWinSize =="small")  argoSmallAlert(jsRow["msgLength"]);
                	else argoAlert(jsRow["msgLength"]);
                 return false;
             }
         }
         
         if (sCheck.search("pattern") > -1 && (new RegExp(jsRow["pattern"])).test(sValue) == false) {
            
        	if(popWinSize =="small")  argoSmallAlert(jsRow["msgPattern"]);
         	else argoAlert(jsRow["msgPattern"]);
             return false;
         }
     }
     
     return true;     
}

/**
 * 파일다운로드
 * @param String sFilePath (필수) - 파일경로
 *        String sFileName (필수) - 파일명
 *   
 */
//function argoFileDownload(sFilePath ,sFileName) {
// 
//	var sfileNm = encodeURI(encodeURIComponent(sFileName)) ;
//	// window.location.href 로 처리하면 파일오류 등 발생했을때 기존 페이지 유지되지 못하는 문제로 별도의 iframe 로 처리함.
//	//window.location.href = gGlobal.ROOT_PATH+'/common/ucFileDownloadF.do?file_name='+ sfileNm +'&file_path='+sFilePath ;
//	
//	var url = gGlobal.ROOT_PATH+'/common/ucFileDownloadF.do?file_name='+ sfileNm +'&file_path='+sFilePath ;
//	   
//	 $('#fileDown').attr('src', url);	 
//}

/**
 * 파일 삭제처리
 * @param String sFilePath (필수) - 파일경로+파일명 , 콤마구분자로 여러건 받는다.
 * 
 */
//function argoFileDelete(sFilePath ) {
//	 
//    var sfileNm = encodeURI(encodeURIComponent(sFilePath)) ;
//	var url = gGlobal.ROOT_PATH+'/common/ucFileDeleteF.do?file_path='+ sfileNm  ;
//	   
//	 $('#fileDown').attr('src', url);	 
//}

/**
 * 파일경로에서 파일명과 파일확장자 분리하여 리턴
 * @param {String} fname 경로를 포함한 파일정보
 * @returns  var fileArr = getfileInfo(fname); 
	var fileNm  =  fileArr[0]+ '.'+ fileArr[1] ;
 */
function argoGetfileInfo(fname){
    var fileName = fname.substring(fname.lastIndexOf("\\")+1);
    return fileName.split("."); 
}

/**
 * RADIO의 공통 조회메소드
 * 
 * @param  {String} sSelector     RADIO 오브젝트를 생성할 span id
 * @param  {String} sServiceName  서비스명
 * @param  {String} sMethod       메소드명
 * @param  {String} sInPrefixName 인풋폼요소의 프리픽스명
 * @param  {String} oAddParam     키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallBack    콜백함수
 * @return {Json}   jResult       서비스정보에서 얻어온 Json객체를 반환
 */
function argoRadioCreate(sSelector, sServiceName, sMethod, oAddParam, oOptions, fnCallBack, ext) {

   var iGlobal = $.extend(true, {}, gGlobal);
   if(typeof(ext)!="undefined")
       iGlobal = $.extend(true, iGlobal, ext);
       
   //서비스생성
   var service = new ArgoService
     (iGlobal.SVC_COMMON_ID,   //서비스아이디
      sServiceName,            //서비스명
      sMethod,                 //호출메소드
      iGlobal.SVC_DB_ARGODB,     //서비스타입
      iGlobal.SVC_DB_TYPE_LIST,//DB서비스타입
      "",                      //인풋폼타입
      "",                      //인풋폼명
      "R",                     //아웃폼타입
      sSelector,               //아웃명
      oAddParam);              //추가파라미터
   
   if(fnCallBack===undefined)
       fnCallBack = null;

   var jResult = argoAction(service, fnCallBack, oOptions);
   if(jResult)
           return jResult;
   else
           return null;
}

/**
 * Radio 생성함수 콜백
 * @param  {String} sSelector       Radio셀렉터 문자열
 * @param  {Json}   jData           메소드가 loadData인 경우 데이터
 * @param  {Object} oOptions        콤보옵션
 */
//oOptions {text:'', value:'', selectValue:''}
function _radioCreate(sSelector, jData, oOptions) {
    oOptions = oOptions || {};
    oOptions.get = function(key, value) {
     return this[key] === undefined ? value : this[key];
    };
   
    if (typeof jData == "undefined" || jData == null || jData.length == 0) { return; }
    
    var sObjId ;
    if (typeof sSelector == 'string') {
    	sObjId = sSelector ; //sSelector 를 radio id로 
        //if(sSelector.indexOf("#") != 0) sSelector = "#" + sSelector;
    	// radio를 감싸는 span 의 id와 중복되므로 임의의 class 로 사용
    	sSelector = "." + sSelector;
    }
    
    $(sSelector).empty();

    var strHtml="" ;
    
    // 전체 추가
    if (oOptions.text !== undefined) {
    	strHtml = '<span class="checks"><input type="radio" id="'+ sObjId+ '0" name="'+ sObjId +'" value=""><label for="'+ sObjId+ '0">'+oOptions.text+'</label></span>';
    	$(sSelector).append(strHtml);   	
    }

    //조회결과를 select box에 추가
    $.each(jData, function(i, row){
		strHtml = '<span class="checks' + ($('input:radio[name='+ sObjId+']').length>0 ? ' ml15' : '' ) + '"><input type="radio" id="'+ sObjId+ (i+1)+ '" name="'+ sObjId +'" value="'+row.code +'">'
		         +'<label for="'+ sObjId+ (i+1)+ '">'+ row.codeNm+ '</label></span>';
	   	$(sSelector).append(strHtml);
    });
   
    //선택 처리       
    //VALUE 값으로 선책 처리
    if (oOptions.selectValue != undefined) {
    		 $('input:radio[name='+ sObjId+']:input[value="' + oOptions.selectValue + '"]').attr("checked", true);    		 
    	}
}

/**
 * gConfig 정의된 환경설정 정보 리턴
 * @param {String} sKey 환경설정KEY 값
 * @returns  환경설정값
 */
function argoGetConfig(sKey){
	
 return top.gConfig[sKey]; 
   
}
/**
 * gConfig 정의된 환경설정 조회
 * @param 
 * @returns  
 */
function argoSetConfig(){

	argoJsonSearchOne('CM','SP_CM1060M01_01','__',  null,     
			function (data, textStatus, jqXHR){					
			if(data.isOk()){
				
				top.gConfig.CENTER = data.getRows()['diDeptTxt1'] ; 
				top.gConfig.IS_CENTER = (data.getRows()['diDeptVisible1'] == '1' ? true : false) ; 
				top.gConfig.PART = data.getRows()['diDeptTxt2'] ; 
				top.gConfig.IS_PART = (data.getRows()['diDeptVisible2'] == '1' ? true : false) ; 
				top.gConfig.TEAM = data.getRows()['diDeptTxt3'] ; 
				top.gConfig.IS_TEAM = (data.getRows()['diDeptVisible3'] == '1' ? true : false) ; 
				top.gConfig.JO = data.getRows()['diDeptTxt4'] ; 
				top.gConfig.IS_JO = (data.getRows()['diDeptVisible4'] == '1' ? true : false) ; 

				top.gConfig.SABUN = data.getRows()['diAgtTxt1'] ; 
				top.gConfig.IS_SABUN = (data.getRows()['diAgtVisible1'] == '1' ? true : false) ; 			
				top.gConfig.AGENT_NM = data.getRows()['diAgtTxt2'] ; 
				top.gConfig.IS_AGENT_NM = (data.getRows()['diAgtVisible2'] == '1' ? true : false) ; 	
				top.gConfig.JIKGUP = data.getRows()['diAgtTxt3'] ; 
				top.gConfig.IS_JIKGUP = (data.getRows()['diAgtVisible3'] == '1' ? true : false) ; 	
				top.gConfig.JIKCHK = data.getRows()['diAgtTxt4'] ; 
				top.gConfig.IS_JIKCHK = (data.getRows()['diAgtVisible4'] == '1' ? true : false) ;
				
				top.gConfig.PW_COMBI_YN = data.getRows()['pwCombiYn'] ; 
				top.gConfig.PW_INIT = data.getRows()['pwInit'] ; 
				top.gConfig.PW_INIT_TXT = data.getRows()['pwInitTxt'] ; 
				top.gConfig.DI_TEL_TYPE = data.getRows()['diTelType'] ; 
				top.gConfig.DI_RNO_TYPE = data.getRows()['diRnoType'] ; 
				
			}	
		}   );

   
}

/**
 * 메뉴이용이력 등록
 * @param  {String} sPgmId  프로그램ID (메뉴ID) 
 * @param  {String} sPgmFile  프로그램파일명 (jsp 파일)
 * @param  {String} sActionType L	로드/R	조회/W	수정/D	삭제/E	기타
 * @param  {String} sActionDesc 설명
 */
function argoAddMenuLog(sPgmId, sPgmFile, sActionType, sActionDesc) {
		
    var gPageFile = sPgmFile.substring(sPgmFile.lastIndexOf("/")+1); // 현페이지 파일명 (팝업인 경우 PGMID는 호출 페이지를 따라가므로 이를 구분하기 위해 )
	
	argoJsonInsert("ARGOCOMMON", "SP_UC_SET_MENU_HISTORY_01", "__",{ pgmId : sPgmId ,pgmFile : gPageFile ,actionType : sActionType, actionDesc:sActionDesc} , "");
	
}

/**
 * 엑셀 다운로드
 * @param  {Object} sGrid  grid (export할 grid) 
 * @param  {String} sExcelNm  엑셀파일명 
 */



/**
 * 녹취파일 청취
 * @param (String) recordId   recordId(팝업 제목) 
 */
function argoRecordListen(recordId) {
	
	var agent = navigator.userAgent.toLowerCase();
	var pWidth  = 0;
	var pHeight = 0;
	
	if ( (navigator.appName == 'Netscape' && agent.indexOf('trident') != -1) || (agent.indexOf("msie") != -1)) {
		// IE
		pWidth  = 320;
		pHeight = 168;
	}else{
		// IE 아닐 경우
		pWidth  = 300;
		pHeight = 80;
	};
	
	argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_AUDIO_INFO','__',  {recordId:recordId}, function (data, textStatus, jqXHR){					
		if(data.isOk()){
			var info = data.getRows();
			argoPopupWindow(recordId, '../common/QaRecordListenF.do?tenantId=' + info.tenantId + '&callId=' + info.callId 
					+ '&serverIp=' + info.serverIp + '&serverPort=' + info.serverPort + '&agentId=' + info.agentId, pWidth, pHeight);
		}
	})
}

/**
 * Qa 품질 평가 상세보기
 * @param (String) sheetkey 평가키 
 */
function argoQaResultDetail(sheetkey, timesId){
	if(sheetkey==''){
		return ;
	}
	gPopupOptions = {sheetkey : sheetkey, timesId : timesId};
	argoPopupWindow('상세보기', '../common/QaValueDetailF.do',  '1120', '689');
}

function fnDynamicForm(obj, url) {
	var form = makeForm(obj);
	form.action = url;
	form.submit();
}
var makeForm = function(obj) {
	var f = document.createElement('form');
	f.method = 'post';
	for (ele in obj) {
		var input = document.createElement('input');
		input.type = 'text';
		input.name = ele;
		input.value = obj[ele];
		f.appendChild(input);
		
	}
	document.body.appendChild(f);
	return f;
};

function fnReportOpen(obj){
	var form = makeForm(obj);
	
	var input = document.createElement('input');
	input.type = 'text';
	input.name = '__parameterpage';
	input.value = 'false';
	form.appendChild(input);
	
	form.action = gGlobal.ROOT_PATH+"/frameset";
	form.target ="_blak";
	form.submit();
}


// 20230627 jslee 특정 div 요소의 스크롤을 가장 아래로 이동시키는 함수
// 그리드에 데이터를 논리Add후 포커스를 자동 이동시킬 때 사용한다.
function argoScrollToBottom(elementId) {
	var element = $("#" + elementId).find(".w2ui-grid-records").eq(0);
	var scrollHeight = element[0].scrollHeight;
	element.animate({scrollTop: scrollHeight}, 1000);
}

// 20230627 jslee undefined이나 null값을 공백으로 치환
function argoNullConvert(value){
	if(value == "undefined" || typeof(value) == "undefined" || value == null || value == "null"){
		value = "";
	}
	return value;
}

//20230627 jslee undefined이나 null값을 공백으로 치환
function argoNullConvertZero(value){
	if(value == "undefined" || typeof(value) == "undefined" || value == null || value == "null"){
		value = 0;
	}
	return value;
}


// 20230712 jslee 그리드를 엑셀파일로 변환시키는 공통함수 생성
// 기존 방식으로는 헤더가 두 줄인 엑셀은 구현이 불가하여 해당 함수 구현함.
function argoGridExlConvert(grid, workMenu){
	var header1TmpArr = new Array();
	var header1Arr 	= new Array();
	var header2Arr 	= new Array();
	var dataArr 	= new Array();
	var dataRowArr 	= new Array();
	var summeryRowArr 	= new Array();
	var summeryArr 	= new Array();
	
	// 표현할 헤더에 대한 인덱스 선언 (hidden true가 아닌 것의 인덱스만 가져오기)
	var headerIdxArr = new Array();
	
	// 표현할 데이터에 대한 ID 선언 (데이터부, summery부 가져오기)
	var headerIdArr = new Array();
	
	$.each(grid.columns, function(index, obj){
		if(argoNullConvert(obj.hidden) != true){
			headerIdxArr.push(index);
			headerIdArr.push(obj.field);
			// 헤더2 완성
			header2Arr.push(obj.caption);
		}
	});
	
	if(grid.columnGroups.length != 0){
		$.each(grid.columnGroups, function(index, row){
		    for(var i = 0; i<row.span; i++){
		    	header1TmpArr.push(row.caption);
		    }
		});
	}
	
	// 헤더1 완성
	if(header1TmpArr.length > 0){
		$.each(headerIdxArr, function(index, row){
			header1Arr.push(header1TmpArr[headerIdxArr[index]]);
		});
	}
	
	// 데이터Row부 완성
	$.each(grid.records, function(index, row){
		for(var i = 0; i<headerIdArr.length; i++){
			// html태그 제거 후 push
			var rowText = row[headerIdArr[i]]+"".replace(/<[^>]*>?/g, '');
			dataRowArr.push(argoNullConvert(rowText));
			//argoNummConvert(row[headerIdArr[i]);
			//dataRowArr.push(extractTextFromHTML(argoNullConvert(row[headerIdArr[i]])));
		}
		dataArr.push(dataRowArr);
		dataRowArr = new Array();
	});
	
	
	// 데이터 summery부 start
	$.each(grid.summary, function(index, row){
		for(var i = 0; i<headerIdArr.length; i++){
			var rowText = row[headerIdArr[i]]+"".replace(/<[^>]*>?/g, '');
			summeryRowArr.push(argoNullConvert(rowText));
			//argoNummConvert(row[headerIdArr[i]);
			//summeryRowArr.push(extractTextFromHTML(argoNullConvert(row[headerIdArr[i]])));
			//summeryRowArr.push(argoNullConvert($(row[headerIdArr[i]]).text()));
		}
		dataArr.push(summeryRowArr);
		summeryRowArr = new Array();
	});
	
	gPopupOptions = {"pHeader1Arr":header1Arr, "pHeader2Arr":header2Arr, "pDataArr":dataArr, "workMenu":workMenu};
	argoPopupWindow('Excel Export', gGlobal.ROOT_PATH + '/common/VExcelExportMultiHeaderF.do', '150', '40');
}


function regExp(str){ 

    //특수문자 검증 start

    //var str = "2011-12-27";
	str = str + "";
    var regExp = /[\{\}\[\]\/?.,;:|\)*~`!^\-_+<>@\#$%&\\\=\(\'\"]/gi

 

    if(regExp.test(str)){

        //특수문자 제거

        var t = str.replace(regExp, "")

        console.log("특수문자를 제거했습니다. ==>" + str);

    }else{

    	console.log("정상적인 문자입니다. ==>" + str);

    }

    //특수문자 검증 end

 

}


function extractTextFromHTML(html) {
  // HTML 문자열을 jQuery 객체로 변환
  var $html = $(html+"");

  // 추출된 문자열을 저장할 변수
  var extractedText = "";

  // 재귀적으로 모든 요소를 탐색하면서 텍스트 추출
  function traverseElements($element) {
    // 자식 노드를 반복하여 텍스트 추출
	  $element.contents().each(function() {
	  var node = this;
	
	  // 텍스트 노드인 경우 텍스트를 추출하여 저장
	  if (node.nodeType === Node.TEXT_NODE) {
	    extractedText += node.textContent.trim() + ' ';
	  }
	
	  // 요소 노드인 경우 재귀적으로 탐색
      if (node.nodeType === Node.ELEMENT_NODE) {
        traverseElements($(node));
      }
    });
  }

  // 모든 HTML 요소를 탐색하여 텍스트 추출
  traverseElements($html);

  if(extractedText == ""){
	  extractedText = html+"";
  }
  
  // 공백 제거 후 추출된 텍스트 반환
  return extractedText.trim();
}


function argoSttView(callId){
	var taLink = "";
	argoJsonSearchOne('ARGOCOMMON', 'searchTaUrlCode', '_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getRows() != ""){
					taLink = data.getRows()['taUrl'];
					var newWindow = window.open(taLink+"?callId="+callId, 'newWindow', 'width=700,height=600,left=100,top=100,scrollbars=no');
		            // 새 창에서 팝업을 차단하지 않도록 팝업 차단기 비활성화
		            if (newWindow) {
		                newWindow.focus();
		            } else {
		            	console.log('팝업 차단을 풀어주세요.');
		            }
				} 
			}
		} catch(e) {
			console.log(e);			
		}
	});
}


// 20230801 jslee 
// QA평가용 청취 코드
var voiceQaPlayYn = "N";
function argoRecPlay(recKey, playerKind, recTableNm){
	
	if(argoNullConvert(recKey) == "" || recKey == "TEMP_REC_KEY"){
		argoAlert("해당 QA평가건은 녹취 이력이 없어 청취가 불가능합니다.");
		return;
	}
	
	var taLink = "";
	argoJsonSearchOne('ARGOCOMMON', 'searchTaUrlCode', '_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getRows() != ""){
					taLink = data.getRows()['taUrl'];
				} 
			}
		} catch(e) {
			console.log(e);			
		}
	});
	
	
	// 20230904 jslee 신한은행에서는 전용재생기만 사용한다고 함 전용재생기만 사용되도록 수정.
	argoJsonSearchOne('comboBoxCode', 'getMfuIpList', 's_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getRows() != ""){
					var iCmd = "11";
					//var iCmd = "0";
					var ws_data = "";
					var mfsIp = data.getRows()['code'];
					
					//debugger;
					
					argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_RECORD_INFO','__',  {recKey:recKey, tableNm:recTableNm}, function (data, textStatus, jqXHR){					
					//argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_RECORD_INFO','__',  {recKey:recKey}, function (data, textStatus, jqXHR){
						if(data.isOk()){
							var info = data.getRows();
							if(info.endTime < 2){
								argoAlert("통화시간이 2초 이내의 녹취 이력은 청취할 수 없습니다.");
								return;
							}else{
								
								console.log("voiceQaPlayYn : " + voiceQaPlayYn);
								if(voiceQaPlayYn == "Y"){
									argoAlert("이미 실행중입니다.");				
									return;
								}
								
								voiceQaPlayYn = "Y";
								console.log("voiceQaPlayYn : " + voiceQaPlayYn);
								
								if(argoNullConvert(info.mfuIp) != ""){
									mfsIp = argoNullConvert(info.mfuIp);
								}
								
								var mediaKind = "1";
								argoRecLogInsert(info.userId, info.dnNo, info.phoneIp, info.recLogTime, info.recKey, "0");
								
								if(info.mediaScr == "1"){
									mediaKind = "2";
								}
								
								ws_data="cmd=" + iCmd + "&mfu_ip=" + mfsIp + "&mfu_port=7200&tenant_id=" + info.tenantId
								+ "&user_id=" + info.userId
								+ "&call_id=" + info.callId
								+ "&media_kind=" + mediaKind;
								
								ws = new WebSocket("ws://localhost:8282");
								ws.onopen = function(e){
									console.log(e);			
									ws.send( ws_data );
								};
								ws.onclose = function(e){
									console.log(e);
									voiceQaPlayYn = "N";
								};	
								
								var newWindow = window.open(taLink+"?callId="+info.callId, 'newWindow', 'width=600,height=600,left=100,top=100,scrollbars=no');
					            // 새 창에서 팝업을 차단하지 않도록 팝업 차단기 비활성화
					            if (newWindow) {
					                newWindow.focus();
					            } else {
					            	console.log('팝업 차단을 풀어주세요.');
					            }
								return;
							}
						}
					});
				} 
			}
		} catch(e) {
			voiceQaPlayYn = "N";
			console.log("voicePlayYn3 : " + voicePlayYn);
			console.log(e);			
		}
	});
	
	
	// 20230904 jslee 신한은행에서는 전용재생기만 사용한다고 함 전용재생기만 사용되도록 수정.
	/*if(playerKind == "1"){
		argoJsonSearchOne('comboBoxCode', 'getMfuIpList', 's_', {}, function (data, textStatus, jqXHR){
			try{
				if(data.isOk()){
					if(data.getRows() != ""){
						var iCmd = "0";
						var ws_data = "";
						var mfsIp = data.getRows()['code'];
						
						argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_RECORD_INFO','__',  {recKey:recKey, tableNm:recTableNm}, function (data, textStatus, jqXHR){					
							if(data.isOk()){
								var info = data.getRows();
								ws_data="cmd=" + iCmd + "&mfu_ip=" + mfsIp + "&mfu_port=7200&tenant_id=" + info.tenantId
								+ "&user_id=" + info.userId
								+ "&call_id=" + info.callId;
								
								ws = new WebSocket("ws://localhost:8282");
								ws.onopen = function(e){
									console.log(e);			
									ws.send( ws_data );
								};
								ws.onclose = function(e){
									console.log(e);
								};	
								return;
							}
						});
					} 
				}
			} catch(e) {
				console.log(e);			
			}
		});
	}else{
		argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_RECORD_INFO','__',  {recKey:recKey, tableNm:recTableNm}, function (data, textStatus, jqXHR){					
			if(data.isOk()){
				var callPlayRecord = argoPlayRecord.bind(null, recKey, recTableNm);
				var info = data.getRows();
				velocePopupWindow('청취(고객명 : ' + VLC_StringProc_NVL(info.custName, "정보없음") + ')', 'about:blank','594', '386', '', 'sttPlay', callPlayRecord, "");
				//form.submit();
				return true;
			}
		});
		return;
	}*/
}



function argoTaPopup(recKey, recTableNm){
	
	if(argoNullConvert(recKey) == "" || recKey == "TEMP_REC_KEY"){
		argoAlert("해당 QA평가건은 녹취 이력이 존재하지 않아 TA팝업을 실행할 수 없습니다.");
		return;
	}
	
	var taLink = "";
	argoJsonSearchOne('ARGOCOMMON', 'searchTaUrlCode', '_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				if(data.getRows() != ""){
					taLink = data.getRows()['taUrl'];
					argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_RECORD_INFO','__',  {recKey:recKey, tableNm:recTableNm}, function (data, textStatus, jqXHR){					
						if(data.isOk()){
							var info = data.getRows();
							if(info.endTime < 2){
								argoAlert("통화시간이 2초 이내의 녹취 이력은 TA팝업을 실행할 수 없습니다.");
								return;
							}else{
								var newWindow = window.open(taLink+"?callId="+info.callId, 'newWindow', 'width=600,height=600,left=100,top=100,scrollbars=no');
					            if (newWindow) {
					                newWindow.focus();
					            } else {
					            	console.log('팝업 차단을 풀어주세요.');
					            }
								return;
							}
						}
					});
				}
			}
		} catch(e) {
			console.log(e);			
		}
	});
}


/*
 *	재생 목록을 팝업에 보내는 함수
 */
var argoPlayRecord = function(recKey, recTableNm) {
	var form = document.getElementById("stt_form");
	if (form == null) {
		form = document.createElement("form");
		form.setAttribute("id", "stt_form");
		form.setAttribute("method", "post");
		form.setAttribute("target", "sttPlay");
		var agent = navigator.userAgent.toLowerCase();
		if (agent.indexOf("chrome") != -1) {
			var playUrl = gGlobal.ROOT_PATH + "/recording/STTPlaychromeF.do";
		} else {
			var playUrl = gGlobal.ROOT_PATH + "/recording/STTPlayieF.do";
		}
		form.setAttribute("action", playUrl);
		document.getElementsByTagName("body").item(0).appendChild(form);
		var recData = document.createElement("input");
		recData.setAttribute("type", "hidden");
		recData.setAttribute("id", "recData");
		recData.setAttribute("Name", "recData");
		form.appendChild(recData);
	}
	
	var recItem = new Object();
	var recList = [];
	argoJsonSearchOne('comboBoxCode', 'getMfuIpList', '_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				recItem.ip = data.getRows()['code'];
				argoJsonSearchOne('ARGOCOMMON', 'SP_UC_GET_RECORD_INFO', '_', {"recKey":recKey, "tableNm":recTableNm}, function (data2, textStatus2, jqXHR2){
					try{
						if(data2.isOk()){
							recItem.tenant_id = data2.getRows()['tenantId'];
							recItem.call_id = data2.getRows()['callId'];
							recItem.port = data2.getRows()['port'];
							recItem.manager_id = data2.getRows()['managerId'];
							recItem.enc_key = data2.getRows()['encKey']; 
							recItem.dn_no = data2.getRows()['dnNo'];
							recItem.rec_time = data2.getRows()['recTime'];
							recItem.userName = data2.getRows()['userName'];
							recItem.custTel = data2.getRows()['custTel'];
							recItem.endTime = data2.getRows()['endTime'];
							recItem.custName = data2.getRows()['custName'];
							recList.push(recItem);
							var recData = document.getElementById("recData");
							var txtRecData = JSON.stringify(recList);
							recData.value = encodeURIComponent(txtRecData);
							form.submit();
							return true;
						}
					} catch(e) {
						console.log(e);			
					}
				});
			}
		} catch(e) {
			console.log(e);			
		}
	});
	return true;
}


function argoScrPopup(recKey, recTableNm) {
	//jslee
	/*var ci = colIndex[0];

	var rowMfuIp = $(w2ui['grid'].get(ci)).attr("mfuIp");
	var mfuIp = (argoNullConvert(rowMfuIp) == "" ? mfsIp : rowMfuIp);
	var port = <%=isHttps%> ? 7220 : 7210;
	var dnNo = $(w2ui['grid'].get(ci)).attr("dnNo");
	var userId = userId;
	var callId = $(w2ui['grid'].get(ci)).attr("callId");*/
	var recItem = new Object();
	argoJsonSearchOne('comboBoxCode', 'getMfuIpList', '_', {}, function (data, textStatus, jqXHR){
		try{
			if(data.isOk()){
				recItem.ip = data.getRows()['code'];
				argoJsonSearchOne('ARGOCOMMON', 'SP_UC_GET_RECORD_INFO', '_', {"recKey":recKey, "tableNm":recTableNm}, function (data2, textStatus2, jqXHR2){
					try{
						if(data2.isOk()){
							recItem.tenant_id = data2.getRows()['tenantId'];
							recItem.call_id = data2.getRows()['callId'];
							recItem.port = data2.getRows()['port'];
							recItem.manager_id = data2.getRows()['managerId'];
							recItem.enc_key = data2.getRows()['encKey']; 
							recItem.dn_no = data2.getRows()['dnNo'];
							recItem.rec_time = data2.getRows()['recTime'];
							recItem.userName = data2.getRows()['userName'];
							recItem.custTel = data2.getRows()['custTel'];
							recItem.endTime = data2.getRows()['endTime'];
							recItem.custName = data2.getRows()['custName'];
							recItem.mediaScr = data2.getRows()['mediaScr'];
							//recList.push(recItem);
							//var recData = document.getElementById("recData");
							//var txtRecData = JSON.stringify(recList);
							//recData.value = encodeURIComponent(txtRecData);
							//form.submit();
							//return true;
							var scrForm = document.getElementById("scr_form");
							if (scrForm == null) {
								scrForm = $('<form></form>');
								scrForm.attr("id", "scr_form");
								scrForm.attr("method", "post");
								scrForm.attr("target", "scrPlayPop");
								scrForm.attr("action", gGlobal.ROOT_PATH + "/recording/STTPlayscreenF.do");

								scrForm.append($("<input/>", {
									type : "hidden",
									id : "mfuIp",
									Name : "mfuIp",
									value : recItem.ip
								}));
								scrForm.append($("<input/>", {
									type : "hidden",
									id : "mfuPort",
									Name : "mfuPort",
									value : recItem.port
								}));
								scrForm.append($("<input/>", {
									type : "hidden",
									id : "dnNo",
									Name : "dnNo",
									value : recItem.dn_no
								}));
								scrForm.append($("<input/>", {
									type : "hidden",
									id : "userId",
									Name : "userId",
									value : recItem.manager_id
								}));
								scrForm.append($("<input/>", {
									type : "hidden",
									id : "callId",
									Name : "callId",
									value : recItem.call_id
								}));

								scrForm.appendTo("body");
							}
							window .open("", "scrPlayPop", "location=no, height=700, width=1000, scrollbars=yes, status=no");
							scrForm.target = "scrPlayPop";
							scrForm.submit();
							scrForm.remove();
						}
					} catch(e) {
						console.log(e);			
					}
				});
			}
		} catch(e) {
			console.log(e);			
		}
	});
}


//logRealtimeFlag 0=일반청취 / 1=실시간감청 / 2=파일변환 / 3=상담APP / 4=샘플콜
function argoRecLogInsert(agentId, dnNo, phoneIp, recLogtime, recKey, logRealtimeFlag) {
    //var record = {};
	//for(var i=0; i<indexs.length; i++) {
	//    record = w2ui['grid'].get(i);
	//	var index = indexs[i];

	//argoRecLogInsert(info.userId, info.dnNo, info.phoneIp, info.recLogTime, info.recKey, "0");
	argoJsonUpdate("recInfo", "setRecLogInsert", "ip_", {
		"tenantId"      : loginInfo.SVCCOMMONID.rows.tenantId,
		"workerId"      : loginInfo.SVCCOMMONID.rows.userId,
		"listeningKey"  : getTimeStamp2(), //+ argoSetZeroNumFn(index),
		"workerIp"      : loginInfo.SVCCOMMONID.rows.workIp,
		"userId"        : agentId,
		"dnNo"          : dnNo,
		"userIp"        : phoneIp ,
		"recTime"       : recLogtime,
		"realtimeFlag"  : logRealtimeFlag,
		"recKey"        : recKey
	});
	
	
}

function getTimeStamp2() {
    var d = new Date();
    var date = argoLeadingZeros(d.getFullYear(), 4) + argoLeadingZeros(d.getMonth() + 1, 2) + argoLeadingZeros(d.getDate(), 2);
    var time = argoLeadingZeros(d.getHours(), 2) + argoLeadingZeros(d.getMinutes(), 2) + argoLeadingZeros(d.getSeconds(), 2);

    return date + time;
}

function argoLeadingZeros(n, digits) {
    var zero = '';
    n = n.toString();

    if (n.length < digits) {
        for (i = 0; i < digits - n.length; i++)
            zero += '0';
    }
    return zero + n;
}

function argoSetZeroNumFn(num) {
    if (Number(num) < 10)
        return "0" + num;
    return num;
}


/*function getNextMonth(yearMonth) {
    var year = parseInt(yearMonth.substr(0, 4));
    var month = parseInt(yearMonth.substr(4, 2));
    month = (month % 12) + 1;
    year += Math.floor((month - 1) / 12);
    month = (month < 10) ? '0' + month : month.toString();
    return year.toString() + month;
}*/

function getNextMonth(yearMonth) {
	var year = parseInt(yearMonth.substr(0, 4));
	var month = parseInt(yearMonth.substr(4, 2));
	  
	// 다음 달로 변경하기 위해 월을 1 증가시킵니다.
	month = month + 1;
	  
	// 12월 다음은 다음 년도의 1월이므로 년도를 증가시킵니다.
	if (month > 12) {
		month = 1;
		year = year + 1;
	}
	  
	month = (month < 10) ? '0' + month : month.toString();
	return year.toString() + month;
}


/*function argoRecDynimicTable(yearMonth1, yearMonth2) {
    // 두 년월 값을 정수로 변환합니다.
	var frmMonth = yearMonth1.replace(/-/gi, "").substring(0,6); 
	var endMonth = yearMonth2.replace(/-/gi, "").substring(0,6);
	
    var start = parseInt(frmMonth);
    var end = parseInt(endMonth);
    
    // 결과를 저장할 변수를 초기화합니다.
    var result = '(';
    
    // 두 년월 값 사이의 월을 순회합니다.
    for (var ym = start; ym <= end; ym = getNextMonth(ym.toString())) {
      // 년월 값을 문자열 형식으로 변환합니다.
      var strYearMonth = ym.toString();
      
      // 결과에 해당 년월을 추가합니다.
      // test
      //result += 'SELECT * FROM TB_REC_FILE_' + strYearMonth.substr(0, 4) + '_' + strYearMonth.substr(4, 2) + ' ';
      result += 'SELECT * FROM TB_REC_FILE_' + strYearMonth.substr(0, 4) + '' + strYearMonth.substr(4, 2) + ' ';
      
      // 끝 년월이 아닌 경우 UNION ALL을 추가합니다.
      if (ym < end) {
        result += 'UNION ALL ';
      }
    }
    
    // 결과 문자열에 괄호를 추가합니다.
    result += ') ';
    
    console.log("result : " + result);
    
    // 생성된 문자열을 반환합니다.
    return result;
}*/

function argoRecDynimicTable(frm, end, recTableType) {
	if(recTableType == "YYYYMM"){
		// 두 년월 값을 정수로 변환합니다.
		var frmMonth = frm.replace(/-/gi, "").substring(0,6); 
		var endMonth = end.replace(/-/gi, "").substring(0,6);
		
	    var start = parseInt(frmMonth);
	    var end = parseInt(endMonth);
	    
	    // 결과를 저장할 변수를 초기화합니다.
	    var result = '(';
	    
	    // 두 년월 값 사이의 월을 순회합니다.
	    for (var ym = start; ym <= end; ym = getNextMonth(ym.toString())) {
	      // 년월 값을 문자열 형식으로 변환합니다.
	      var strYearMonth = ym.toString();
	      
	      // 결과에 해당 년월을 추가합니다.
	      // test
	      //result += 'SELECT * FROM TB_REC_FILE_' + strYearMonth.substr(0, 4) + '_' + strYearMonth.substr(4, 2) + ' ';
	      result += 'SELECT * FROM TB_REC_FILE_' + strYearMonth.substr(0, 4) + '' + strYearMonth.substr(4, 2) + ' ';
	      
	      // 끝 년월이 아닌 경우 UNION ALL을 추가합니다.
	      if (ym < end) {
	        result += 'UNION ALL ';
	      }
	    }
	    
	    // 결과 문자열에 괄호를 추가합니다.
	    result += ') ';
	    
	    // 생성된 문자열을 반환합니다.
	    return result;
	}else if(recTableType == "YYYY"){
		var frmYear = frm.replace(/-/gi, "").substring(0,4); 
		var endYear = end.replace(/-/gi, "").substring(0,4);
		var start = parseInt(frmYear);
	    var end = parseInt(endYear);
	    var result = '(';
	    for(var i=start; i<=end; i++){
	    	var strYear = i.toString();
	    	result += 'SELECT * FROM TB_REC_FILE_' + strYear.substr(0, 4) + ' ';
			if (i < end) {
				result += 'UNION ALL ';
			}
	    }
	    result += ') ';
	    return result;
	}else{
		var result = "TB_REC_FILE ";
		return result;
	}
}



/*function argoRecDynimicTableValidate(yearMonth1, yearMonth2) {
    // 두 년월 값을 정수로 변환합니다.
	var frmMonth = yearMonth1.replace(/-/gi, "").substring(0,6); 
	var endMonth = yearMonth2.replace(/-/gi, "").substring(0,6);
	
	console.log("frmMonth : " + frmMonth);
	console.log("endMonth : " + endMonth);
    var start = parseInt(frmMonth);
    var end = parseInt(endMonth);
    
    // 결과를 저장할 변수를 초기화합니다.
    var result = '(';
    
    // 두 년월 값 사이의 월을 순회합니다.
    for (var ym = start; ym <= end; ym = getNextMonth(ym.toString())) {
      // 년월 값을 문자열 형식으로 변환합니다.
      var strYearMonth = ym.toString();
      
      // 결과에 해당 년월을 추가합니다.
      // test
      //result += 'SELECT * FROM TB_REC_FILE_' + strYearMonth.substr(0, 4) + '_' + strYearMonth.substr(4, 2) + ' ';
      result += 'SELECT COUNT(*) FROM TB_REC_FILE_' + strYearMonth.substr(0, 4) + '' + strYearMonth.substr(4, 2) + ' ';
      
      // 끝 년월이 아닌 경우 UNION ALL을 추가합니다.
      if (ym < end) {
        result += 'UNION ALL ';
      }
    }
    
    // 결과 문자열에 괄호를 추가합니다.
    result += ') ';
    
    console.log("result : " + result);
    
    // 생성된 문자열을 반환합니다.
    return result;
}
*/

/*function argoQaTimesRecTable(timesId){
	var recFrmMonth = "";
	var recEndMonth = "";
	argoJsonSearchList('QA','SP_UC_GET_QA_TIMES_REC_YMD','__', {"timesId":timesId}, function (data, textStatus, jqXHR){
		try {
			if (data.isOk()) {
				recFrmMonth = data.getRows()[0].recFrmMonth;
				recEndMonth = data.getRows()[0].recEndMonth;
			}
		} catch (e) {
			console.log(e);
		}
	});
	return argoRecDynimicTable(recFrmMonth, recEndMonth);
}*/


function argoQaTimesRecTable(timesId, recTableType){
	var recFrmMonth = "";
	var recEndMonth = "";
	argoJsonSearchList('QA','SP_UC_GET_QA_TIMES_REC_YMD','__', {"timesId":timesId}, function (data, textStatus, jqXHR){
		try {
			if (data.isOk()) {
				recFrmMonth = data.getRows()[0].recFrmMonth;
				recEndMonth = data.getRows()[0].recEndMonth;
			}
		} catch (e) {
			console.log(e);
		}
	});
	return argoRecDynimicTable(recFrmMonth, recEndMonth, recTableType);
}


function argoQaTimesRecMonthFromTo(timesId){
	var recFrmMonth = "";
	var recEndMonth = "";
	var recMonthArr = new Array();
	argoJsonSearchList('QA','SP_UC_GET_QA_TIMES_REC_YMD','__', {"timesId":timesId}, function (data, textStatus, jqXHR){
		try {
			if (data.isOk()) {
				recFrmMonth = data.getRows()[0].recFrmMonth;
				recEndMonth = data.getRows()[0].recEndMonth;
				recMonthArr.push(recFrmMonth);
				recMonthArr.push(recEndMonth);
			}
		} catch (e) {
			console.log(e);
		}
	});
	return recMonthArr;
}



/**
 * 파일 삭제처리
 * @param String sFilePath (필수) - 파일경로+파일명 , 콤마구분자로 여러건 받는다.
 * 
 */
function argoFileDelete(sFilePath, sGlobalPath ) {
	 
    var sfileNm = encodeURI(encodeURIComponent(sFilePath)) ;
	var url = gGlobal.ROOT_PATH+'/common/ucFileDeleteF.do?file_path='+ sfileNm+ '&global_path='+sGlobalPath  ;
	   
	 $('#fileDown').attr('src', url);	 
}


/**
 * 파일다운로드
 * @param String sFilePath (필수) - 파일경로
 *        String sFileName (필수) - 파일명
 *   
 */
function argoFileDownload(sFilePath ,sFileName, sGlobalPath) {
 
	var sfileNm = encodeURI(encodeURIComponent(sFileName)) ;
	// window.location.href 로 처리하면 파일오류 등 발생했을때 기존 페이지 유지되지 못하는 문제로 별도의 iframe 로 처리함.
	//window.location.href = gGlobal.ROOT_PATH+'/common/ucFileDownloadF.do?file_name='+ sfileNm +'&file_path='+sFilePath ;
	
	var url = gGlobal.ROOT_PATH+'/common/ucFileDownloadF.do?file_name='+ sfileNm +'&file_path='+sFilePath + '&global_path='+sGlobalPath ;
	   
	 $('#fileDown').attr('src', url);	 
}



function argoConvertCamel(text){
	var inputText = text;
    var words = inputText.toLowerCase().split('_');
    for (var i = 1; i < words.length; i++) {
      words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1);
    }
    var camelText = words.join('');
    console.log("camelText : " + camelText);
}


//시분초를 초로 변환하는 함수
function argoTimeToSeconds(time) {
  var parts = time.split(':');
  var hours = parseInt(parts[0], 10) || 0;
  var minutes = parseInt(parts[1], 10) || 0;
  var seconds = parseInt(parts[2], 10) || 0;
  return hours * 3600 + minutes * 60 + seconds;
}

