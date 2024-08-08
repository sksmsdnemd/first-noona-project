/***********************************************************
 * argo.core.js
 * 
 * CREATE BY lmk872  2016-12-08   
 * Argo WEB  서버통신용 
 * 
 ***********************************************************/

/**
 * Dispatch 방식에서 사용되는 서비스 객체
 * @param  {String} svcId         서비스를 구분하기 위한 서비스아이디
 * @param  {String} svcName       서비스명(서버아이디)
 * @param  {String} methodName    메소드명(전문아이디)
 * @param  {String} svcType       서비스타입(argodb:ARGO 데이터베이스, saTcp:SA TCP)
 * @param  {String} dbType        db거래타입(only DB I:입력, U:갱신, D:삭제, S:단일검색, L:다중건조회, IDS:IDS거래, SVR:CASVR거래)
 * @param  {String} inType        인풋타입(F:폼, I:폼무시)
 * @param  {String} inPrefixName  인풋폼요소의 프리픽스명
 * @param  {String} outType       아웃풋타입(F:폼, C:콤보, G:그리드, T:트리, CT:콤보트리, CG:콤보그리드)
 * @param  {String} outName       아웃풋타입에따라서(F:아웃폼요소의 프리픽스명, C:콤보객체명, G:그리드객체명)
 * @param  {Object} addParam      해당 거래에 사용될 추가파라미터
 * @method {String} toParam       서비스객체를 시리얼라이즈한 문자열 반환
 */
function ArgoService(svcId, svcName, methodName, svcType, dbType, inType, inPrefixName, outType, outName, addParam) {
	this.svcId        = XSS_Check(svcId, 1);
    this.svcName      = XSS_Check(svcName, 1);
    this.svcType      = XSS_Check(svcType, 1);
    this.dbType       = XSS_Check(dbType, 1);
    this.methodName   = XSS_Check(methodName, 1);
    this.inType       = XSS_Check(inType, 1);
    this.inPrefixName = XSS_Check(inPrefixName, 1);
    this.outType      = XSS_Check(outType, 1);
    this.outName      = XSS_Check(outName, 1);
    this.addParam     = addParam;
    
    this.toParam = function() {
        var retStr;
        retStr = 
          "_" + this.svcId + ".svcName=" + encodeURIComponent(this.svcName) + "&"
        + "_" + this.svcId + ".svcType=" + encodeURIComponent(this.svcType) + "&"
        + "_" + this.svcId + ".methodName=" + encodeURIComponent(this.methodName) + "&"
        + "_" + this.svcId + ".dbType=" + encodeURIComponent(this.dbType) + "&"
        + "_" + this.svcId + ".inType=" + encodeURIComponent(this.inType) + "&"
        + "_" + this.svcId + ".outType=" + encodeURIComponent(this.outType) + "&"
        + "_" + this.svcId + ".outName=" + encodeURIComponent(this.outName);
        return retStr;
    };
}

 /**
  * SaDispatch 방식에서 사용되는 서비스 처리
  * @param  {Object} oService      서비스객체 또는 써비스객체를 담고있는 서비스배열
  * @param  {Object} oCbOptions    콤보에서 사용되는 옵션정보
  * @param  {String} svcType       서비스타입(argodb:argo 데이터베이스)
  * @param  {String} fnCallback    콜백메소드
  * @return {Json}   jResult       서비스정보에서 얻어온 Json객체를 반환
  */
function argoAction(oService, fnCallback, oCbOptions, oGobj) {

    if(typeof(oGobj)=="undefined"){
        oGobj = gGlobal;
    }

    var svcId      = "";
    var svcStr      = "";
    var svcForm  = "";
    var svcAddParm = "";
    var svcParam = "";
    var apmKey   = "";    //APM(어플리케이션 성능관리툴에서 구분하기 위한 키값)
    
    //ArgoService객체인경우 배열로 처리하기 위한 변환
    if(oService instanceof ArgoService) {
        var svcArr = new Array();
        svcArr.push(oService);
        oService = svcArr;
    }
    
    if(oService instanceof Array) {
        for (var i = 0; i < oService.length; i++) {
            //서비스아이디
            if(svcId != "") svcId = svcId + ",";
            svcId = svcId + oService[i].svcId;
            
            //서비스정보
            if(svcStr != "") svcStr = svcStr + "&";
            svcStr = svcStr + oService[i].toParam();
                        
            //폼정보
            if(svcForm != "") svcForm = svcForm + "&";
            if(oService[i].inType == "F")
                svcForm = svcForm + serializeForm(oService[i].inPrefixName, oService[i].svcId);
            
            //추가파라미터정보
            if(oService[i].addParam) {            	
                if(svcAddParm != "") svcAddParm = svcAddParm + "&";
                svcAddParm = svcAddParm + serializeObj(oService[i].addParam, oService[i].svcId);
            }
        }
    }else {
        //TODO 메시지처리
    }
    
    svcStr	= XSS_Check(svcStr, 1);
    var svcParam = oGobj.SVC_PARAM_SVCIDS + "=" + svcId + "&" + svcStr + "&" + svcForm + "&" + svcAddParm;

    argoConsoleLog('REQUEST', svcParam);    
    
    for (var i = 0; i < oService.length; i++) {
        if(apmKey != "") apmKey = apmKey + "&";
        apmKey = apmKey + oService[i].svcName.toUpperCase() + "." + oService[i].methodName.toUpperCase();
    }
        
    //콜백 메소드가 있을경우
    //console.log(apmKey);
    if (fnCallback) {
    	//postsync//postasync
    	//console.log(apmKey);
    	if(apmKey == "USERINFO.SETSESSIONUPDATE")
        {
    		argoAjax("postasync", oGobj.ROOT_PATH + oGobj.SVC_ARGO_PATH + "?APMKEY="+apmKey, svcParam, oCbOptions, fnCallback, null);
        }
    	else
    	{	
    		argoAjax("postsync", oGobj.ROOT_PATH + oGobj.SVC_ARGO_PATH + "?APMKEY="+apmKey, svcParam, oCbOptions, fnCallback, null);
    	}
        
    }
    else {
    	
        var jResult = argoAjax("postsync", oGobj.ROOT_PATH + oGobj.SVC_ARGO_PATH + "?APMKEY="+apmKey, svcParam, oCbOptions, null, null);
    
        for (var i = 0; i < oService.length; i++) {
            if(oService[i].outType == "G") {
                $(oService[i].outName).datagrid("loading").datagrid("loadData", jResult.getRows(oService[i].svcId)).datagrid("loaded");
            } else if(oService[i].outType == "F") {
                var jRow = jResult.getRows(oService[i].svcId);
                argoSetValues(oService[i].outName, jRow);
            } else if(oService[i].outType == "C") {
            	_cbCreate(oService[i].outName, jResult.getRows(oService[i].svcId), oCbOptions);              
            } else if(oService[i].outType == "T") {
                argoTrSearchCallback(jResult);
            }else if(oService[i].outType == "CG") {
                var cbgrid = $(data.getOutName()).combogrid('grid');
                cbgrid.datagrid("loadData", data.getRows());                
            }else if(oService[i].outType == "CT") {
                argoCbTreeCallback(jResult,null,null,oCbOptions);  //core에서 common을 호출 ㅡㅡ;;
                /*var jComboTree =$(oService[i].outName);
                var jComboOptions = {idField:"treeId", treeField:"treeName"};
                if (oCbOptions.addoptions !== undefined) {
                    $.extend(true, jComboOptions, oCbOptions.addoptions);
                }
                jComboTree.combotree(jComboOptions);
                oCbOptions = oCbOptions || {};
                if (oCbOptions.text !== undefined) {
                    jResult.getRows().unshift({treeId:oCbOptions.value, treeName: oCbOptions.text, parentId:""});    //이거고민인데.. 일단..첨부..
                }
                jComboTree.combotree("loadData", json2tree(jResult.getRows(), "treeId", "parentId", doInit));*/
            }else if(oService[i].outType == "R") { //ADD BY 2017-01-19 YAKIM
            	_radioCreate(oService[i].outName, jResult.getRows(oService[i].svcId), oCbOptions);              
            }
        }
        return jResult;
    }
}

/**
 * argoAction을 form submit으로 사용.
 * @param {Object} oService      서비스객체 또는 써비스객체를 담고있는 서비스배열
 * @param {Object} oGobj          글로벌 파라미터를 재정의한 객체
 */
function argoFormAction(oService, oGobj) {

    if(typeof(oGobj)=="undefined"){
        oGobj = gGlobal;
    }

    var svcId      = "";
    var svcStr      = "";
    var svcForm  = "";
    var svcAddParm = "";
    var svcParam = "";
    var apmKey   = "";    //APM(어플리케이션 성능관리툴에서 구분하기 위한 키값)
    
    //ArgoService객체인경우 배열로 처리하기 위한 변환
    if(oService instanceof ArgoService) {
        var svcArr = new Array();
        svcArr.push(oService);
        oService = svcArr;
    }
    
    if(oService instanceof Array) {
        for (var i = 0; i < oService.length; i++) {
            //서비스아이디
            if(svcId != "") svcId = svcId + ",";
            svcId = svcId + oService[i].svcId;
            
            //서비스정보
            if(svcStr != "") svcStr = svcStr + "&";
            svcStr = svcStr + oService[i].toParam();
            
            //폼정보
            if(svcForm != "") svcForm = svcForm + "&";
            if(oService[i].inType == "F")
            svcForm = svcForm + serializeForm(oService[i].inPrefixName, oService[i].svcId);
            
            //추가파라미터정보
            if(oService[i].addParam) {
                if(svcAddParm != "")
                    svcAddParm = svcAddParm + "&";
                svcAddParm = svcAddParm + serializeObj(oService[i].addParam, oService[i].svcId);
            }
        }
    }
    
    svcStr	= XSS_Check(svcStr, 1);
    var svcParam = oGobj.SVC_PARAM_SVCIDS + "=" + svcId + "&" + svcStr + "&" + svcForm + "&" + svcAddParm;
    
    argoConsoleLog("REQUEST" , svcParam);
    
    for (var i = 0; i < oService.length; i++) {
        if(apmKey != "") apmKey = apmKey + "|";
        apmKey = apmKey + oService[i].svcName.toUpperCase() + "." + oService[i].methodName.toUpperCase();
    }
    
    var jForm = $("form[name=saFormChange]");
    if (jForm.length > 0) return;
    
    jBody = $(document.body);
    
    var formStr = "<form name='saFormChange' action='"+oGobj.ROOT_PATH + oGobj.SVC_ARGO_PATH+"?APMKEY="+apmKey+"' method='post' ></form>";    
    jBody.append(formStr);
    
    jForm = $("form[name=saFormChange]");
    
    var jaDatas = svcParam.iSplit("&");
    var iNumber = jaDatas.length;
    for (var iCount = 0; iCount < iNumber; iCount++) {
        jaData = jaDatas[iCount].iSplit("=");
        if (jaData.length <= 1) {
            jForm.append("<input type='hidden' name='" + decodeURIComponent(jaData[0]) + "' />");
        } else {
//            jForm.append("<input type='hidden' name='" + decodeURIComponent(jaData[0]) + "' value='" + decodeURIComponent(jaData[1]) + "' />");
            jForm.append("<input type='hidden' name='" + decodeURIComponent(jaData[0]) + "' value='' />");
            jForm.find("input[name='" + decodeURIComponent(jaData[0]) + "']").val(decodeURIComponent(jaData[1]));
        }
    }
    
    jForm.submit().remove();    

}

/**
 * 폼요소중에 프리픽스명으로 시작되는 요소를 시리얼라이즈
 * @param  {String} prefix         프리픽스명
 * @return {String} serializeForm 시리얼라이즈
 */
function serializeForm(prefix, svcId) {
    var kvpairs = [];
    var radioName="";
    var radioBloon=true;
    var input, orgName, name, value, className;
    $('input, select, textarea').each(function(index){  
         input = $(this);
         orgName = input.attr('name');
         value = "";
          if(orgName && (prefix == "" || orgName.indexOf(prefix) == 0)) {
              name = svcId + "." + orgName.replace(new RegExp("^" + prefix,""), "");
              tagName = input.get(0).tagName;
              switch (tagName.toLowerCase()) {
                  case "input":
                    switch (input.attr('type')) {
                        case 'text':
                        case 'textarea':
                        case 'password':
                        case 'hidden':
                            className = $('#'+orgName).attr('class') + "";
                            value = input.val(); 
                            if(className.indexOf('datepicker') > -1 
                              || className.indexOf('input_ym') > -1  
                              || className.indexOf('input_time') > -1) 
                            {    
                            	value = value.replace(/\./g, "").replace(/\-/g, "").replace(/\:/g, "").replace(/\s/g,'') ;
                            }else {
                                value = input.val();
                            }
                            kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                            break;
                        case 'radio':     //TODO
                            if(radioName=="") radioName=orgName;
                            if(radioName!=orgName) radioBloon=true;
                            if(radioBloon){
                                radioName = orgName;    
                                value = $("input:radio[name="+orgName+"]:checked").val();
                                if(value != undefined) kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                                radioBloon = false;
                            }                            
                            break;
                        case 'checkbox':  //TODO
                            if($('#'+orgName).is(":checked")){
                                value = $('#'+orgName).val();
                            }
                            kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                            //if (e.checked) kvpairs.push(encodeURIComponent(input.attr('name')) + "=" + encodeURIComponent(input.attr('name')));
                            break;
                     }
                    break;
                case "select":
                    if (input["className"] && input["className"].indexOf("combobox-f ") > -1) {
                       
                        // ADD BY 2016-11-10
                        var options = $('#'+orgName).combotree("options");
                        
                        if(options && options.multiple) {
                        	value = $('#'+orgName).combo('getValues').join(',');    
                            
                        }else  value = input.combobox('getValue');
                               
                    } else {
                        value = input.val();
                    }
                    if(value===null)    value="";
                    kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                    break;
                case "textarea":
                    value = input.val();
                    kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                    break;
              }
            //console.log('Type: ' + input.attr('type') + ', Name: ' + name + ', Value: ' + value);
          }
    });
    return kvpairs.join("&");
}
 
/**
 * 키밸유형테의 객체를 시리얼라이즈
 * @param  {Object} obj           키밸유형태의 객체
 * @param  {String} prefix        키에추가할 프리픽스
 * @return {String} serializeForm 시리얼라이즈
 */
function serializeObj(obj, prefix) {
    var str = [];
    var name;
    for(var p in obj)
      if (obj.hasOwnProperty(p)) {
          if(prefix)
              name = prefix + "." + p;
          else
              name = p;
          if(obj[p] instanceof Array)
              str.push(encodeURIComponent(name) + "=" + encodeURIComponent("L" + JSON.stringify(obj[p])));
          else
              str.push(encodeURIComponent(name) + "=" + encodeURIComponent(obj[p]));
      }
    return str.join("&");
}

/**
 * Json형태의 프로시저 호출 메소드
 * @param  {String} sServiceName    서비스명
 * @param  {String} sMethod         	  메소드명
 * @param  {String} sInPrefixName    인풋폼요소의 프리픽스명
 * @param  {String} oAddParam        키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallback       	  콜백메소드명
 * @param  {String} ext       			  콜백메소드명
 * @return {Json}   jResult                서비스정보에서 얻어온 Json객체를 반환
 */
function argoJsonCallSP(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback, ext) {                  
      var iGlobal = $.extend(true, {}, gGlobal);
      
      if(typeof(ext)!="undefined") iGlobal = $.extend(true, iGlobal, ext);
      
      //서비스생성
      var service = new ArgoService
        	(iGlobal.SVC_COMMON_ID,     		//서비스아이디
        	 sServiceName,              				//서비스명
             sMethod,                   					//호출메소드
             iGlobal.SVC_DB_ARGODB,       		//서비스타입
             iGlobal.SVC_DB_TYPE_PROCEDURE,		//DB서비스타입
             "F",                       						//인풋폼타입
             sInPrefixName,             				//인풋프리픽스
             "",                        						//아웃폼타입
             "",                        						//아웃명
             oAddParam);                				//추가파라미터
      
      var jResult = argoAction(service, fnCallback);
      
      if(jResult)
          return jResult;
      else
          return null;
}

/**
 * Json형태의 공통 단건조회메소드
 * @param  {String} sServiceName    서비스명
 * @param  {String} sMethod         	  메소드명
 * @param  {String} sInPrefixName    인풋폼요소의 프리픽스명
 * @param  {String} oAddParam        키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallback       	  콜백메소드명
 * @param  {String} ext       			  콜백메소드명
 * @return {Json}   jResult                서비스정보에서 얻어온 Json객체를 반환
 */
function argoJsonSearchOne(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback, ext) {                  
      var iGlobal = $.extend(true, {}, gGlobal);
      
      if(typeof(ext)!="undefined") iGlobal = $.extend(true, iGlobal, ext);
      
      //서비스생성
      var service = new ArgoService
        	(iGlobal.SVC_COMMON_ID,     		//서비스아이디
        	 sServiceName,              				//서비스명
             sMethod,                   					//호출메소드
             iGlobal.SVC_DB_ARGODB,       		//서비스타입
             iGlobal.SVC_DB_TYPE_SELECT,		//DB서비스타입
             "F",                       						//인풋폼타입
             sInPrefixName,             				//인풋프리픽스
             "",                        						//아웃폼타입
             "",                        						//아웃명
             oAddParam);                				//추가파라미터
      
      var jResult = argoAction(service, fnCallback, null, iGlobal);
      
      if(jResult)
          return jResult;
      else
          return null;
}

/**
 * Json형태의 공통 다건조회메소드
 * @param  {String} sServiceName    서비스명
 * @param  {String} sMethod         메소드명
 * @param  {String} sInPrefixName   인풋폼요소의 프리픽스명
 * @param  {String} oAddParam       키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallback      콜백메소드
 * @return {Json}   jResult         서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonSearchList(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback, ext) {                  
      //서비스생성
      var iGlobal = $.extend(true, {}, gGlobal);
      if(typeof(ext)!="undefined")
        iGlobal = $.extend(true, iGlobal, ext);
      
      var service = new ArgoService
        (iGlobal.SVC_COMMON_ID,   //서비스아이디
         sServiceName,            //서비스명
         sMethod,                 //호출메소드
         iGlobal.SVC_DB_ARGODB,     //서비스타입
         iGlobal.SVC_DB_TYPE_LIST,//DB서비스타입
         "F",                     //인풋폼타입
         sInPrefixName,           //인풋프리픽스
         "",                      //아웃폼타입
         "",                      //아웃명
         oAddParam);              //추가파라미터
      
      var jResult = argoAction(service, fnCallback, null, iGlobal);
      if(jResult)
          return jResult;
      else
          return null;
}


/**
 * Json형태의 공통 입력메소드
 * @param  {String} sServiceName    서비스명
 * @param  {String} sMethod         메소드명
 * @param  {String} sInPrefixName   인풋폼요소의 프리픽스명
 * @param  {String} oAddParam       키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallback      콜백메소드
 * @return {Json}   jResult         서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonInsert(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback, ext) {                  
    
      var iGlobal = $.extend(true, {}, gGlobal);
      if(typeof(ext)!="undefined")
        iGlobal = $.extend(true, iGlobal, ext);
            
    //서비스생성
    var service = new ArgoService
      (iGlobal.SVC_COMMON_ID,     //서비스아이디
       sServiceName,              //서비스명
       sMethod,                   //호출메소드
       iGlobal.SVC_DB_ARGODB,       //서비스타입
       iGlobal.SVC_DB_TYPE_INSERT,//DB서비스타입
       "F",                       //인풋폼타입
       sInPrefixName,             //인풋프리픽스
       "",                        //아웃폼타입
       "",                        //아웃명
       oAddParam);                //추가파라미터
    
    var jResult = argoAction(service, fnCallback);
    if(jResult)
        return jResult;
    else
        return null;
}


function argoJsonBulk(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback, ext) {                  
    
      var iGlobal = $.extend(true, {}, gGlobal);
      if(typeof(ext)!="undefined")
        iGlobal = $.extend(true, iGlobal, ext);
        
    //서비스생성
    var service = new ArgoService
      (iGlobal.SVC_COMMON_ID,   //서비스아이디
       sServiceName,            //서비스명
       sMethod,                 //호출메소드
       iGlobal.SVC_DB_ARGODB,     //서비스타입
       iGlobal.SVC_DB_TYPE_BULK,//DB서비스타입
       "F",                     //인풋폼타입
       sInPrefixName,           //인풋프리픽스
       "",                      //아웃폼타입
       "",                      //아웃명
       oAddParam);              //추가파라미터

    var reGlobal = JSON.parse(JSON.stringify(gGlobal));
    reGlobal.SVC_ARGO_PATH = '/argoExcelImport.do';  
    
    var jResult = argoAction(service, fnCallback, null, reGlobal);
    if(jResult)
        return jResult;
    else
        return null;
}

/**
 * Json형태의 공통 입력메소드
 * @param  {String} sServiceName    서비스명
 * @param  {String} sMethod         메소드명
 * @param  {String} sInPrefixName   인풋폼요소의 프리픽스명
 * @param  {String} oAddParam       키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallback      콜백메소드
 * @return {Json}   jResult         서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonUpdate(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback, ext) {                  
    
      var iGlobal = $.extend(true, {}, gGlobal);
      if(typeof(ext)!="undefined")
        iGlobal = $.extend(true, iGlobal, ext);
        
    //서비스생성
    var service = new ArgoService
      (iGlobal.SVC_COMMON_ID,     //서비스아이디
       sServiceName,              //서비스명
       sMethod,                   //호출메소드
       iGlobal.SVC_DB_ARGODB,       //서비스타입
       iGlobal.SVC_DB_TYPE_UPDATE,//DB서비스타입
       "F",                       //인풋폼타입
       sInPrefixName,             //인풋프리픽스
       "",                        //아웃폼타입
       "",                        //아웃명
       oAddParam);                //추가파라미터
    
    var jResult = argoAction(service, fnCallback, null, iGlobal);
    if(jResult)
        return jResult;
    else
        return null;
}

/**
 * Json형태의 공통 입력메소드
 * @param  {String} sServiceName    서비스명
 * @param  {String} sMethod         메소드명
 * @param  {String} sInPrefixName   인풋폼요소의 프리픽스명
 * @param  {String} oAddParam       키밸류 형태의 추가 파라미터 객체
 * @param  {String} fnCallback      콜백메소드
 * @return {Json}   jResult         서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonDelete(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback, ext) {
    
      var iGlobal = $.extend(true, {}, gGlobal);
      if(typeof(ext)!="undefined")
        iGlobal = $.extend(true, iGlobal, ext);
        
    //서비스생성
    var service = new ArgoService
      (iGlobal.SVC_COMMON_ID,     //서비스아이디
       sServiceName,              //서비스명
       sMethod,                   //호출메소드
       iGlobal.SVC_DB_ARGODB,       //서비스타입
       iGlobal.SVC_DB_TYPE_DELETE,//DB서비스타입
       "F",                       //인풋폼타입
       sInPrefixName,             //인풋프리픽스
       "",                        //아웃폼타입
       "",                        //아웃명
       oAddParam);                //추가파라미터
    
    var jResult = argoAction(service, fnCallback);
    if(jResult)
        return jResult;
    else
        return null;
}

/**
 * IDS와 연동하기 위한 JSON형태 공통 메소드
 * @param sServiceName            서비스명
 * @param sMethod                메소드명
 * @param sInPrefixName         인풋폼요소의 프리픽스명 (폼타입 I이므로 프리픽스는 무시함)
 * @param oAddData                키밸류 형태의 추가 파라미터 객체(saIDSitems.getItems()을 통해 받은 값)
 * @param fnCallback            콜백메소드
 * @returns                    서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonIDS(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback) {   

    //서비스생성. oAddParam은 saIDSitems.getItems()로 가져온 항목을 넘겨준다.(필요에 따라서 $.extend하여 사용).
    var service = new ArgoService
    (gGlobal.SVC_COMMON_ID,  //서비스아이디
     sServiceName,           //서비스명
     sMethod,                //호출메소드
     gGlobal.SVC_IF_TCP,     //서비스타입
     gGlobal.SVC_IF_TYPE_IDS,//DB서비스타입
     "I",                    //인풋폼타입
     sInPrefixName,          //인풋프리픽스
     "",                     //아웃폼타입
     "",                     //아웃명
     oAddParam);             //추가파라미터
    
    var jResult = argoAction(service, fnCallback);
    if(jResult)
        return jResult;
    else
        return null;
    
}

/**
 * SVR과 연동하기 위한 JSON형태 공통 메소드
 * @param sServiceName            서비스명
 * @param sMethod                메소드명
 * @param sInPrefixName            인풋폼요소의 프리픽스명 (폼타입 I이므로 프리픽스는 무시함)
 * @param oAddParam                키밸류 형태의 추가 파라미터 객체 (saSVRitems.getItem()을 통해 받은 값)
 * @param fnCallback            콜백메소드
 * @returns                    서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonSVR(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback) {   

    var service = new ArgoService
    (gGlobal.SVC_COMMON_ID,     //서비스아이디
     sServiceName,               //서비스명
     sMethod,                    //호출메소드
     gGlobal.SVC_IF_TCP,        //서비스타입
     gGlobal.SVC_IF_TYPE_SVR,    //DB서비스타입
     "I",                        //인풋폼타입
     sInPrefixName,                   //인풋프리픽스
     "",                         //아웃폼타입
     "",                        //아웃명
     oAddParam);                //추가파라미터
    
    var jResult = argoAction(service, fnCallback);
    if(jResult)
        return jResult;
    else
        return null;
}

/**
 * R과 연동하기 위한 JSON형태 공통 메소드
 * @param sServiceName          서비스명
 * @param sMethod               메소드명
 * @param sInPrefixName         인풋폼요소의 프리픽스명 (폼타입 I이므로 프리픽스는 무시함)
 * @param oAddParam             키밸류 형태의 추가 파라미터 객체 (saRitems.getItems()를 통해 받은 값)
 * @param fnCallback            콜백메소드
 * @returns                     서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonR(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback) { 
    
    var service = new ArgoService
    (gGlobal.SVC_COMMON_ID,     //서비스아이디
     sServiceName,              //서비스명
     sMethod,                   //호출메소드
     gGlobal.SVC_IF_TCP,        //서비스타입
     gGlobal.SVC_IF_TYPE_R,     //DB서비스타입
     "I",                       //인풋폼타입
     sInPrefixName,             //인풋프리픽스
     "",                        //아웃폼타입
     "",                        //아웃명
     oAddParam);                //추가파라미터
    

    var jResult = argoAction(service, fnCallback);
    if(jResult)
      return jResult;
    else
      return null;
    
}    

/**
 * DAO를 쓰지않는 공통서비스. 서버단은 Service만 추가개발. 현재는 서비스명을 SaNoDao로 고정.
 * 향후 운영방안에 따라 조절가능 하도록 일단 sServiceName(메뉴ID)을 받게 되어 있음.
 * @param sServiceName            서비스명
 * @param sMethod                메소드명
 * @param sInPrefixName            인풋폼요소의 프리픽스명
 * @param oAddParam                키밸류 형태의 추가 파라미터 객체
 * @param fnCallback            콜백메소드
 * @returns                    서비스정보에서 얻어온 Json객체 반환
 */
function argoJsonNoDao(sServiceName, sMethod, sInPrefixName, oAddParam, fnCallback) {
    
    /*if(typeof(oAddParam)=="undefined" ||typeof(oAddParam)=="object"){
        if(oAddParam.sClassName!==null){
            oAddParam.sClassName = "SaNoDao";    
        }
    }*/
    
    var service = new ArgoService
    (gGlobal.SVC_COMMON_ID,     //서비스아이디
     sServiceName,                   //서비스명
     sMethod,                    //호출메소드
     "",                        //서비스타입
     "",                        //DB서비스타입
     "F",                        //인풋폼타입
     sInPrefixName,                   //인풋프리픽스
     "",                         //아웃폼타입
     "",                        //아웃명
     oAddParam);                //추가파라미터
    
    var reGlobal = JSON.parse(JSON.stringify(gGlobal));
    reGlobal.SVC_ARGO_PATH = gGlobal.SVC_ARGO_DPATH;

    var jResult = argoAction(service, fnCallback ,null, reGlobal);
    if(jResult)
        return jResult;
    else
        return null;    
}


/**
 * Json형태의 공통 다건조회메소드
 * @param  {String} sJsonString    json형태의 문자열
 * @return {Json}   jResult        서비스정보에서 얻어온 Json에 메소드를 추가하여 객체 반환
 */
function argoJson(sJsonString) {
    argoConsoleLog("RESPONSE" , sJsonString);
    
    var sResult;
    if(sJsonString.length > 0)
        sResult = sJsonString.trim();
    else
        sResult = "";
    
    //세션종료시 ajax거래가 들어왔을경우 Interceptor에서 리턴시 사용
    if(sResult.indexOf('<script')==0){
        $(sResult).appendTo($('head'));
        return;
    }
    
    //MODIFIED BY 2016-10-07 YAKIM
    //시험지관리 - 문제 조회시 이미지 건이 있어서 .. 나오지 않는 문제 발생.. 왜 아래 부분이 있는지 알수 없음.. 우선 막음
    /*
    //R 호출임시로 코딩. 향후 R 이용방안 결정되면 공통작업으로 수행  (카테고리별이슈관련 )
    if(sResult=='IMAGE SAVE FAIL' || sResult.indexOf('.png') > 0){
        return sResult;
    }
    */
    
    if (sResult.charAt(0) != "{") sResult = "{}";
    
    if (sResult != null) {
        sResult = sResult.replace(/\s/g, ' ');
        sResult = sResult.replace("\n", "");
    }
    var jsonResult;
    
    try{
        //jsonResult = eval("(" + sResult + ")");
//        jsonResult = $.parseJSON(sResult);
        jsonResult = $.parseJSON(sResult);
    }catch(e){
    	// debug 시 주석해제 .. 
//    	console.log(jsonResult);		// 날짜형의 경우 값부분에 따음표가("") 가 제외되어 파싱오류 발생. 2016.8.25
//    	console.log(sResult);		// 날짜형의 경우 값부분에 따음표가("") 가 제외되어 파싱오류 발생. 2016.8.25
//    	console.log(sJsonString);	// 날짜형의 경우 값부분에 따음표가("") 가 제외되어 파싱오류 발생. 2016.8.25
    	
        alert("JSON Parse 오류 : " + e);
    }
    
    if(jsonResult && jsonResult[gGlobal.RESULT_CODE]) {
        //서비스ROWS 반환
        jsonResult.getRows = function(serviceId) {
            if(serviceId !== undefined) {
                
                if($.isNumeric(serviceId))
                    serviceId = gGlobal.SVC_COMMON_ID + serviceId;
                
                if(this[serviceId] && this[serviceId][gGlobal.RESULT_SVC_ROWS])
                    return this[serviceId][gGlobal.RESULT_SVC_ROWS];
                else 
                    return eval("([])");
            }
            else {
                if(this[gGlobal.SVC_COMMON_ID] && this[gGlobal.SVC_COMMON_ID][gGlobal.RESULT_SVC_ROWS])
                    return this[gGlobal.SVC_COMMON_ID][gGlobal.RESULT_SVC_ROWS];
                else
                    return eval("([])");
            }
        };
        //서비스ROWS 전체갯수
        jsonResult.getTotCnt = function(serviceId) {
            if(serviceId !== undefined) {
                
                if($.isNumeric(serviceId))
                    serviceId = gGlobal.SVC_COMMON_ID + serviceId;
                
                if(this[serviceId] && this[serviceId][gGlobal.SVC_TOT_CNT])
                    return this[serviceId][gGlobal.SVC_TOT_CNT];
                else 
                    return 0;
            }
            else {
                if(this[gGlobal.SVC_COMMON_ID] && this[gGlobal.SVC_COMMON_ID][gGlobal.SVC_TOT_CNT])
                    return this[gGlobal.SVC_COMMON_ID][gGlobal.SVC_TOT_CNT];
                else
                    return 0;
            }
        };
        //서비스ROWS 처리갯수
        jsonResult.getProcCnt = function(serviceId) {
            if(serviceId !== undefined) {
                
                if($.isNumeric(serviceId))
                    serviceId = gGlobal.SVC_COMMON_ID + serviceId;

                if(this[serviceId] && this[serviceId][gGlobal.SVC_PROC_CNT])
                    return Number(this[serviceId][gGlobal.SVC_PROC_CNT]);
                else 
                    return 0;
            }
            else {
                if(this[gGlobal.SVC_COMMON_ID] && this[gGlobal.SVC_COMMON_ID][gGlobal.SVC_PROC_CNT])
                    return Number(this[gGlobal.SVC_COMMON_ID][gGlobal.SVC_PROC_CNT]);
                else
                    return 0;
            }
        };
        //아웃풋 셀렉터명
        jsonResult.getOutName = function(serviceId) {
            if(serviceId !== undefined) {
                if($.isNumeric(serviceId))
                    serviceId = gGlobal.SVC_COMMON_ID + serviceId;

                if(this[serviceId] && this[serviceId][gGlobal.SVC_OUT_NAME])
                    return this[serviceId][gGlobal.SVC_OUT_NAME];
                else 
                    return null;
            }
            else {
                if(this[gGlobal.SVC_COMMON_ID] && this[gGlobal.SVC_COMMON_ID][gGlobal.SVC_OUT_NAME])
                    return this[gGlobal.SVC_COMMON_ID][gGlobal.SVC_OUT_NAME];
                else
                    return null;
            }
        };
        //서비스처리결과
        jsonResult.isOk = function() {
            if(jsonResult.getCode() == "0000")
                return true;
            else
                return false;
                
        };
        //서비스처리결과코드
        jsonResult.getCode = function() {
            return this[gGlobal.RESULT_CODE];
        };
        //서비스처리결과메시지
        jsonResult.getMessage = function() {
            return this[gGlobal.RESULT_MSG];
        };
        //서비스처리결과세부코드
        jsonResult.getSubCode = function() {
            return this[gGlobal.RESULT_SUB_CODE];
        };
        //서비스처리결과세부메시지
        jsonResult.getSubMessage = function() {
            return this[gGlobal.RESULT_SUB_MSG];
        };
     } else {
        //서비스ROWS 전체갯수
        jsonResult.getTotCnt = function() {
            return 0;
        };
        //서비스ROWS 처리갯수
        jsonResult.getProcCnt = function() {
            return 0;
        };
        //아웃풋 셀렉터명
        jsonResult.getOutName = function(serviceId) {
            return null;
        };
        //서비스처리결과
        jsonResult.isOk = function() {
            return false;
        };
        jsonResult.getRows = function() {
            return eval("([])");
        };
        //서비스처리결과코드
        jsonResult.getCode = function() {
            return "9999";
        };
        //서비스처리결과메시지
        jsonResult.getMessage = function() {
            return "서버와의 통신에 오류가 있습니다. 잠시 후 다시 시도하여 주세요.";
        };
        //서비스처리결과세부코드
        jsonResult.getSubCode = function() {
            return "";
        };
        //서비스처리결과세부메시지
        jsonResult.getSubMessage = function() {
            return "";
        };
        return jsonResult;
    }
        
    //alert(">>"+jsonResult.getCode());
    if(jsonResult.getCode() != "0000") { //결과가 성공이 아닐경우 에러메세지만 호출 
//        alert(jsonResult.getMessage());
    	//argoResultDialog(jsonResult.getCode(), jsonResult.getMessage(), jsonResult.getSubCode(), jsonResult.getSubMessage());
    }
    return jsonResult;
}

/**
 * 멀티서비스처리객체
 * @param  {String} fnCallback      콜백메소드
 * @method {Method} action             멀티서비스에대한 액션처리
 */
function argoMultiService(fnCallback) {
    //서비스배열 생성
    this.svcArr = new Array();
    
    this.push = function(sServiceName, sMethod, sDbType, sInPrefixName, oAddParam, sOutType, sOutName, sSvcType, sInType) {
        var service = new ArgoService
        (gGlobal.SVC_COMMON_ID + this.svcArr.length, //서비스아이디
         sServiceName,                               //서비스명
         sMethod,                                    //호출메소드
         sSvcType,                                   //서비스타입
         sDbType,                                    //DB서비스타입
         sInType,                                    //인풋폼타입
         sInPrefixName,                              //인풋프리픽스
         sOutType,                                   //아웃폼타입
         sOutName,                                   //아웃명
         oAddParam);                                 //추가파라미터
        
         this.svcArr.push(service);
         return this;
    };
    
    this.argoInsert = function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName, ext) {
        var iSvcType = gGlobal.SVC_DB_ARGODB;
        if(typeof(ext)!="undefined"){iSvcType=ext.SVC_DB_ARGODB;}
        return this.push(sServiceName, sMethod, gGlobal.SVC_DB_TYPE_INSERT, sInPrefixName, oAddParam, sOutType, sOutName, iSvcType , 'F');
    };
    this.argoUpdate = function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName) {
        var iSvcType = gGlobal.SVC_DB_ARGODB;
        if(typeof(ext)!="undefined"){iSvcType=ext.SVC_DB_ARGODB;}
        return this.push(sServiceName, sMethod, gGlobal.SVC_DB_TYPE_UPDATE, sInPrefixName, oAddParam, sOutType, sOutName, iSvcType , 'F');
    };
    this.argoDelete = function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName) {
        var iSvcType = gGlobal.SVC_DB_ARGODB;
        if(typeof(ext)!="undefined"){iSvcType=ext.SVC_DB_ARGODB;}
        return this.push(sServiceName, sMethod, gGlobal.SVC_DB_TYPE_DELETE, sInPrefixName, oAddParam, sOutType, sOutName, iSvcType , 'F');
    };
    this.argoSelect = function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName) {
        var iSvcType = gGlobal.SVC_DB_ARGODB;
        if(typeof(ext)!="undefined"){iSvcType=ext.SVC_DB_ARGODB;}
        return this.push(sServiceName, sMethod, gGlobal.SVC_DB_TYPE_SELECT, sInPrefixName, oAddParam, sOutType, sOutName, iSvcType , 'F');
    };
    this.argoList = function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName) {
        var iSvcType = gGlobal.SVC_DB_ARGODB;
        if(typeof(ext)!="undefined"){iSvcType=ext.SVC_DB_ARGODB;}
        return this.push(sServiceName, sMethod, gGlobal.SVC_DB_TYPE_LIST, sInPrefixName, oAddParam, sOutType, sOutName, iSvcType , 'F');
    };
    this.argoBulk = function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName) {
        var iSvcType = gGlobal.SVC_DB_ARGODB;
        if(typeof(ext)!="undefined"){iSvcType=ext.SVC_DB_ARGODB;}
        return this.push(sServiceName, sMethod, gGlobal.SVC_DB_TYPE_BULK, sInPrefixName, oAddParam, sOutType, sOutName, iSvcType , 'F');
    };
    this.argoIDS =  function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName) {
        //oAddParam은 saIDSitems.getItems()로 가져온 항목을 넘겨준다(필요에 따라서 $.extend하여 사용).
        return this.push(sServiceName, sMethod, gGlobal.SVC_IF_TYPE_IDS, sInPrefixName, oAddParam, sOutType, sOutName, gGlobal.SVC_IF_TCP , 'I');
    };
    this.argoSVR =  function(sServiceName, sMethod, sInPrefixName, oAddParam, sOutType, sOutName) {
        return this.push(sServiceName, sMethod, gGlobal.SVC_IF_TYPE_SVR, sInPrefixName, oAddParam, sOutType, sOutName, gGlobal.SVC_IF_TCP , 'I');
    };
    
    this.action = function() {
        if(this.svcArr.length > 0)
            return argoAction(this.svcArr, fnCallback);
    };
    
    //향후 formAction을 멀티로 쏘게 될경우를 위해서 추가.
    this.formAction = function(reGlobal){
        if(this.svcArr.length > 0)
            argoFormAction(this.svcArr,reGlobal);
    };
    
}

var isErrorAlert = false;
/**
 * SA에서 호출하는 Ajax함수
 * @param  {String} method          메소드명
 * @param  {String} action          URL
 * @param  {String} data                키밸류 형태의 파라미터 객체
 * @param  {String} fnSuccess       성공콜백메소드
 * @param  {String} fnError           실패콜백메소드
 * @param  {String} dataType           responseDataType(xml, html, script, json, jsonp, text)-현재사용되는곳 없음
 * @param  {String} contentType     contentType-현재사용되는곳 없음
 * @return {Json}   jResult         argoJson형상으로 객체 반환
 */
function argoAjax(method, action, data, oCbOptions ,fnSuccess, fnError, dataType, contentType) {
    ////////////////////////////////////////////////////////////////////
    // function( data, textStatus, jqXHR )
    ////////////////////////////////////////////////////////////////////
    // data       : 인자는 서버에서 전달된 데이터, 
    // textStatus : 두번째는 데이터의 타입, 
    // jqXHR        : ajax 객체
    ////////////////////////////////////////////////////////////////////
    // function( jqXHR, textStatus, errorThrown )
    ////////////////////////////////////////////////////////////////////
    // jqXHR : ajax 객체, 
    // testStatus :"timeout", "error", "abort", "parsererror",
    // errorThrown : HTTP 에러, "NotFound" 나 "Internal Server Error."
    ////////////////////////////////////////////////////////////////////
    var jResult;
    var sSendData;
    
    if (fnError == null) fnError = function(jqXHR, textStatus, errorThrown) {
    
        argoHideLoadMsg();
        if(isErrorAlert == false) {
            isErrorAlert = true;
           // alert("서버와의 통신에 오류가 있습니다. 잠시 후 다시 시도하여 주세요."+textStatus, function() {
               argoAlert('warning',"서버와의 통신에 오류가 있습니다. <br>잠시 후 다시 시도하여 주세요."+"["+textStatus +"]", function() {
                isErrorAlert = false;
            });
        }
    };
    
    if (data != null && typeof (data) == "object") {
        contentType = "application/json; charset=utf-8";
        sSendData = jsonToString(data);
    } else {
        sSendData = data;
    }
     switch (method.toLowerCase()) {
        case "postsync":
            if (fnSuccess != null) {
                $.ajax({
                    "async":false, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                    	jResult = argoJson(data);
                        fnSuccess(jResult, textStatus, jqXHR);
                    }, "error":fnError, "dataType":dataType, "contentType":contentType});
            } else {
                $.ajax({
                    "async":false, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                        jResult = argoJson(data);
                    }, "error":fnError, "dataType":dataType, "contentType":contentType});
            }
            break;
        case "getsync":
           /* if (fnSuccess != null) {
                $.ajax({
                    "async":false, "type":"get", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                    	jResult = argoJson(data);
                        fnSuccess(jResult, textStatus, jqXHR);
                    }, error:fnError, "dataType":dataType, "contentType":contentType});
            } else {
                $.ajax({
                    "async":false, "type":"get", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                        jResult = argoJson(data);
                    }, "error":fnError, "dataType":dataType, "contentType":contentType});
            }*/
            if (fnSuccess != null) {
                $.ajax({
                    "async":false, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                    	jResult = argoJson(data);
                        fnSuccess(jResult, textStatus, jqXHR);
                    }, error:fnError, "dataType":dataType, "contentType":contentType});
            } else {
                $.ajax({
                    "async":false, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                        jResult = argoJson(data);
                    }, "error":fnError, "dataType":dataType, "contentType":contentType});
            }
            break;
        case "postasync":
           //argoShowLoadMsg(); 화면별 선별적으로 처리하기 위해 막음
            if (fnSuccess != null) {
                 $.ajax({
                    "async":true, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {                       
                        jResult = argoJson(data);
                        
                        if(jResult[gGlobal.SVC_COMMON_ID] && fnSuccess.length == 1) {

                            jResult[gGlobal.SVC_COMMON_ID].total = jResult[gGlobal.SVC_COMMON_ID][gGlobal.SVC_TOT_CNT];
                            fnSuccess(jResult[gGlobal.SVC_COMMON_ID]);
                        }else {         

                            fnSuccess(jResult, textStatus, jqXHR, oCbOptions);
                        }
                        
                   //     argoHideLoadMsg();
                      
                    }, error:fnError, "dataType":dataType, "contentType":contentType, timeout:60000 });
            } else {
                $.ajax({
                    "async":true, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                        argoHideLoadMsg();
                        jResult = argoJson(data);
                    }, "error":fnError, "dataType":dataType, "contentType":contentType});
            }
            break;
        case "getasync":
            argoShowLoadMsg();
            /*if (fnSuccess != null) {
                $.ajax({
                    "async":true, "type":"get", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                    	argoHideLoadMsg();
                        jResult = argoJson(data);
                        fnSuccess(jResult, textStatus, jqXHR, oCbOptions);
                    }, error:fnError, "dataType":dataType, "contentType":contentType});
            } else {
                $.ajax({
                    "async":true, "type":"get", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                        argoHideLoadMsg();
                        jResult = argoJson(data);
                    }, "error":fnError, "dataType":dataType, "contentType":contentType});
            }*/
            if (fnSuccess != null) {
                $.ajax({
                    "async":true, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                    	argoHideLoadMsg();
                        jResult = argoJson(data);
                        fnSuccess(jResult, textStatus, jqXHR, oCbOptions);
                    }, error:fnError, "dataType":dataType, "contentType":contentType});
            } else {
                $.ajax({
                    "async":true, "type":"post", "url":action, "data":sSendData, "cache":false, "success":function(data, textStatus, jqXHR) {
                        argoHideLoadMsg();
                        jResult = argoJson(data);
                    }, "error":fnError, "dataType":dataType, "contentType":contentType});
            }
            break;
    }
     
    return jResult;
}

/**
 * 파일업로드
 * @param     {String} oForm            서브밋 폼(enctype="multipart/form-data")
 * @param  {String} fnCallback        콜백메소드
 * @return {Json}   jResult        argoJson형상으로 객체 반환
 */
function argoAjaxUpload(oForm, fnCallback){
    
    var jResult;
    var jForm = $(oForm);
    var jObj = $("[type=file]", jForm);
    var iNumber = jObj.length;
    
    if (iNumber <= 0) return false;
    
    /*for (iCount = 0; iCount < iNumber; iCount++) {
        sFileName = jObj.get(iCount).value;
    }*/
    
    if($(oForm+' #ip_MenuId').length == 0){
        ($("<input type='hidden' name='ip_MenuId' id='ip_MenuId'>")).appendTo(jForm);
        $(oForm+' #ip_MenuId').val(getUrlFileNm());
    }
    
    var options = { 
        beforeSend: function(){argoShowLoadMsg();},
        success: function(){argoHideLoadMsg();},
        complete: function(data){
            jResult = argoJson(data.responseText);
            fnCallback(jResult);
        },
        error: function(){
            argoHideLoadMsg();
            if(isErrorAlert == false) {
                isErrorAlert = true;
                alert("서버와의 통신에 오류가 있습니다. 잠시 후 다시 시도하여 주세요.", function() {
                    isErrorAlert = false;
                });
            }
        }
    };
    
    if(fnCallback!= null){
        jForm.ajaxForm(options).submit();           
    }else{
        options.complete = function(data){
            jResult = argoJson(data);
        };
        jForm.ajaxForm(options).submit();        
    }
    
    return jResult;
    
}

/**
 * 멀티파일 업로드 - 
 * IE9에선 formdata 를 지원하지 않고 또한 input 의 multiple 도 동작하지 않음
 * 이 경우 catch 하여   argoAjaxUpload 를 호출하여 업로드 처리함. (input type 에 있는 파일 대상)
 * @param  {String} oForm         서브밋 폼(enctype="multipart/form-data")
 * @param  {String} fnCallback    콜백메소드
 * @param  {object} oFormData     input type = file 사용하지 않고  별도의 formdata 사용시 해당 formdata 오브젝트
 * @return {Json}   jResult        argoJson형상으로 객체 반환
 */
		    
	function argoAjaxUploadMultiple(oForm, fnCallback , oFormData){
		 try{	        
		        var jResult;
		        var jForm = $(oForm);
		        var jObj = $("[type=file]", jForm);
		        var iNumber = jObj.length;
		        
		        if (iNumber <= 0) return false;
		        
		        if (oFormData == undefined) { // 파일정보를 담고 있는 formData를 받지 않은 경우 form 내에 input=file 에 있는 파일정보를 읽어 처리함.
		        	
		        	var formData = new FormData(jForm);		        
			        
			        var files = jObj.get(0).files; //업로드한 파일들의 정보를 넣는다.
				        for (var i = 0; i < files.length; i++) {
				        	formData.append('file-'+i, files[i]); //업로드한 파일을 하나하나 읽어서 FormData 안에 넣는다.
			            }
		        }else {
		        	var formData = oFormData ;
		        }
		        
		        var options = { 
	        		url: gGlobal.ROOT_PATH+gGlobal.SVC_ARGO_UPATH,
	                processData: false,
	                contentType: false,
	                data: formData,
	                type: 'POST',
		            beforeSend: function(){argoShowLoadMsg();},
		            success: function(){argoHideLoadMsg();},
		            complete: function(data){
		                jResult = argoJson(data.responseText);
		                fnCallback(jResult);
		            },
		            error: function(){
		                argoHideLoadMsg();
		                if(isErrorAlert == false) {
		                    isErrorAlert = true;
		                    alert("서버와의 통신에 오류가 있습니다. 잠시 후 다시 시도하여 주세요.", function() {
		                        isErrorAlert = false;
		                    });
		                }
		            }
		        };
		        
		        if(fnCallback!= null){
	        	
		        	$.ajax(options);
		            
		        }else{
		            options.complete = function(data){
		                jResult = argoJson(data);		                
		            };
		            $.ajax(options);  
		        }
		        
		        return jResult;
		 } catch (e) {
			 argoAjaxUpload(oForm, fnCallback );
		 }
		        
		    }		    
		    
		    function argoAjaxUploadMultiple_back(oForm, fnCallback){
		        
		        var jResult;
		        var jForm = $(oForm);
		        var jObj = $("[type=file]", jForm);
		        var iNumber = jObj.length;
		        
		        if (iNumber <= 0) return false;

		        var formData = new FormData(jForm);		        
		        
		        var files = jObj.get(0).files; //업로드한 파일들의 정보를 넣는다.
			        for (var i = 0; i < files.length; i++) {
			        	console.log('jObj.get(iCount).value>>' + files[i].name) ;
			        	formData.append('file-'+i, files[i]); //업로드한 파일을 하나하나 읽어서 FormData 안에 넣는다.
		            }
			        
			       formData.append('ip_MenuId', getUrlFileNm());//업로드 경로 

		        var options = { 
	        		url: gGlobal.ROOT_PATH+gGlobal.SVC_ARGO_UPATH,
	                processData: false,
	                contentType: false,
	                data: formData,
	                type: 'POST',
		            beforeSend: function(){argoShowLoadMsg();},
		            success: function(){argoHideLoadMsg();},
		            complete: function(data){
		                jResult = argoJson(data.responseText);
		                fnCallback(jResult);
		            },
		            error: function(){
		                argoHideLoadMsg();
		                if(isErrorAlert == false) {
		                    isErrorAlert = true;
		                    alert("서버와의 통신에 오류가 있습니다. 잠시 후 다시 시도하여 주세요.", function() {
		                        isErrorAlert = false;
		                    });
		                }
		            }
		        };
		        
		        if(fnCallback!= null){
	        	
		        	$.ajax(options);
		            
		        }else{
		            options.complete = function(data){
		                jResult = argoJson(data);
		                console.log("jResult>>" + data.responseText) ;
		            };
		            $.ajax(options);  
		        }
		        
		        return jResult;
		        
		    }

/**
 * 파일업로드시 서버에서 생성할 폴더명(메뉴ID)
 * @returns
 */
function getUrlFileNm() {

    var restr  = "";
    try{
        
        var v=location.pathname, p, q;
        p=v.length;
        while (p>0) {
            if (v.charAt(p-1)=='/') break;
            p--;
        }
        
        q=v.length;
        while (q>=0) {
            if (v.charAt(q)=='.') break;
            q--;
        }
        
        if (q<p) q=v.length;
        restr = v.substring(p, q);
        
        //return restr.substring(0, restr.length-1);        
        return restr.substring(0, 10);
        
    }catch(e){
        return restr;
    }

}

/**
 * 페이지 처리중 로딩바 생성
 */
function argoShowLoadMsg() {
	if($('.preloading').length < 1){
		$("body").append('<div class="preloading"></div>');
  }		
	if($('.sub_wrap').length >0 ){ // sub_wrap 영역에서만 처리하기 위해. 
		$(".preloading").fadeIn("fast");
	}
}


function argoHideLoadMsg() {
	$(".preloading").fadeOut("fast");
}


////////////////////////////////////////////////////////////////////
//처리결과 오류메시지 출력(START)
////////////////////////////////////////////////////////////////////

/**
* 처리결과 오류내용을 화면에 표시
* @param  {String} code         결과코드
* @param  {String} msg          결과메시지
* @param  {String} subCode      세부코드
* @param  {String} subMsg         세부메시지
*/
function argoResultDialog(code, msg, subCode, subMsg) {
	try{
		alert("결과코드 : " + code + "\n" + msg+"\n 세부결과코드 : " + subCode + "\n" + subMsg);
	}catch(e){
		alert(e);
	}
}

////////////////////////////////////////////////////////////////////
//처리결과 오류메시지 출력(END)
////////////////////////////////////////////////////////////////////

/**
 * IDS SEND시 가변적인 items영역을 설정해주는 즉시실행함수.
 * @RETURN {items:"{"idsItemArray":"[{},{},....]"}"}
 */
var saIDSitems = (function(){
    var items = {"idsItemArray":[]};
    return{
        putItem : function(obj){
            items.idsItemArray.push(obj);
        } ,
        putParamItem : function(pMethod, pTable, pKey, pData, pEtc){ //key, data, pEtc는 {}(object)로
            var obj = {method:pMethod, table:pTable, key:pKey};
            if(pData!=null)     obj.data = pData;
            if(pEtc!=null) $.extend(obj, pEtc);
            items.idsItemArray.push(obj);
        } ,
        getItems : function(){
            var jStr = JSON.stringify(items);
            items.idsItemArray = [];
            return {"items":jStr};
        }
    };
}());

/**
 * SVR SEND시 가변적인 영역을 설정해주는 즉시 실행함수.
 * @RETURN {sendData:'data부 json string', nCmdID:패킷ID, nSysTo:시스템ID, nTo:프로세스ID}
 */
var saSVRitems = (function(){
    
    //sendData:전문DATA부, nCmdID:패킷ID(16진수), nSysTo:적용장비, nTo:적용프로세스
    var items = {sendData:'', nCmdID:0, nSysTo:0, nTo:0};    
    function init(){
        items.sendData = '';
        items.nCmdID = 0;
        items.nSysTo = 0;
        items.nTo = 0;
    }
    return{
        putItem : function (sendDate, nCmdID, nSysTo ,nTo){
            init();
            items.sendData = JSON.stringify(sendDate);
            items.nCmdID = nCmdID;
            if(typeof(nSysTo)!="undefined")    items.nSysTo = nSysTo;
            if(typeof(nTo)!="undefined")        items.nTo = nTo;            
        } ,
        getItem : function(){
            return items;    //json object!
        }
    };
}());

/**
 * R SEND시 가변적인 items영역을 설정해주는 즉시실행함수.
 * @RETURN {RJson:"{"rows":"[{},{},....],"items":"{}" "}"}
 */
var saRitems = (function(){
    var items = {};
   
    function putItemData(type){
        if(items.items===undefined) items.items = {};
        if(type=="item"){
            items.items[key] = value;
        }else{
            $.extend(items.items, obj);
        }
    }
   
    return{
        putRows : function(rows){
            items.rows = rows;
        } ,
        putItem : function(key, value){ 
            putItemData('item');
        } ,
        putObj : function(obj){
           putItemData('object');
        } ,
        getItems : function(){
            var jStr = JSON.stringify(items);
            items = new Object;
            return {"RJson":jStr};
        }
    };
}());

/**
 * RSA 비대칭 암호화 모듈. 
 * publicKeyModulus : 공개키, encryptPw : was로 넘길 input태그명.
 */
var argoRSA = (function(){
    return function (opt) {
        function init(){
            this.options = {
                publicKeyModulus:'publicKeyModulus', 
                publicKeyExponent:'publicKeyExponent', 
                encryptPw : 'encryptPw'
            };
            
            $.extend(true, this.options, opt);
            load.call(this.options);
            return this;
        }
        
        argoRSA.fn = init.prototype = {setEncWord: setEncWord};
        return new init();
    };
    
    function load(){
        var $that = this;
        if($('#'+$that.publicKeyModulus).length < 1)
            $("<input type='hidden' id='"+$that.publicKeyModulus+"' name='"+$that.publicKeyModulus+"' />").appendTo("body");
            
       if($('#'+$that.publicKeyExponent).length < 1)
            $("<input type='hidden' id='"+$that.publicKeyExponent+"' name='"+$that.publicKeyExponent+"' />").appendTo("body");
            
        if($('#'+$that.encryptPw).length < 1)
            $("<input type='hidden' id='"+$that.encryptPw+"' name='"+$that.encryptPw+"' />").appendTo("body");
        
        var result = argoJsonNoDao('ARGOCOMMON', 'rsaPublicKey', '__', null, null);
        if(result.isOk()){
            var rows = result.getRows();
            $('#'+$that.publicKeyModulus).val(rows.publicKeyModulus);
            $('#'+$that.publicKeyExponent).val(rows.publicKeyExponent);
        }else{
            alert('RSA 공개키를 받지 못했습니다. WAS를 확인하세요.');
        }
    }
    
    function setEncWord(text){
        var rsa = new RSAKey();
        rsa.setPublic( $('#'+this.options.publicKeyModulus).val() ,$('#'+this.options.publicKeyExponent).val() );
        $('#'+this.options.encryptPw).val(rsa.encrypt(text));
    }
    
}());

/**
 * 콘솔에 디버그 모드 설정에 따라 로그를 출력.
 */
var argoConsoleLog = function(sGbn, IOlog){
    try{
        if(argoGetCookie('isDebug')){
            if(sGbn=="REQUEST"){
                IOlog = IOlog.replace(/&&/g,'&');
                if(IOlog.substr( IOlog.length-1, IOlog.length)=="&"){
                    IOlog = IOlog.substr(0,IOlog.length-1);
                }
                if(getBrowserType()=="Chrome")
                    console.table(JSON.parse('[{"' + IOlog.replace(/&/g, '","').replace(/=/g,'":"') + '"}]'));
                else
                    console.log(sGbn+' : {"' + IOlog.replace(/&/g, '","').replace(/=/g,'":"') + '"}');
            }else{
                console.log(sGbn+" : "+IOlog);    
            }
        }
    }catch(e){}
};

/*
$(document).bind('keydown', function(e){
    if(window.event.altKey && window.event.shiftKey){
        if(e.which == 66){  //B
            if(argoGetCookie('isDebug')){
                argoRemoveCookie('isDebug');
                console.log("Debug Mode OFF ...");
            }else{
                argoSetCookie('isDebug',1);
                console.log("Debug Mode ON ...");
            }    
        }else if(e.which == 83){    //S
            window.open(gGlobal.ROOT_PATH+'/ca40/CA4040S600F.do','webDml');            
        }        
    }
});
*/

/*
 * 	20180910 JEON JY
 * 	xss 방지 코드 추가
 */
function XSS_Check(strTemp, level) 
{
	if (typeof strTemp === "string" || typeof strTemp === "number")
	{
		if ( level == undefined || level == 0 ) 
	    {
	      strTemp = strTemp.replace(/\<|\>|\"|\'|\%|\;|\(|\)|\&|\+|\-/g,"");		
	    }
	    else if (level != undefined && level == 1 ) 
	    {
	      strTemp = strTemp.replace(/\</g, "&lt;");
	      strTemp = strTemp.replace(/\>/g, "&gt;");
	    }
	}
    return strTemp;
 }

function serializeFormNoService(prefix) {
    var kvpairs = [];
    var radioName="";
    var radioBloon=true;
    var input, orgName, name, value, className;
    $('input, select, textarea').each(function(index){  
         input = $(this);
         orgName = input.attr('name');
         value = "";
          if(orgName && (prefix == "" || orgName.indexOf(prefix) == 0)) {
              name = orgName.replace(new RegExp("^" + prefix,""), "");
              name = name.charAt(0).toLowerCase() + name.substr(1,name.length);
              
              tagName = input.get(0).tagName;
              switch (tagName.toLowerCase()) {
                  case "input":
                    switch (input.attr('type')) {
                        case 'text':
                        case 'textarea':
                        case 'password':
                        case 'hidden':
                            className = $('#'+orgName).attr('class') + "";
                            value = input.val(); 
                            if(className.indexOf('datepicker') > -1 
                              || className.indexOf('input_ym') > -1  
                              || className.indexOf('input_time') > -1) 
                            {    
                            	value = value.replace(/\./g, "").replace(/\-/g, "").replace(/\:/g, "").replace(/\s/g,'') ;
                            }else {
                                value = input.val();
                            }
                            kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                            break;
                        case 'radio':     //TODO
                            if(radioName=="") radioName=orgName;
                            if(radioName!=orgName) radioBloon=true;
                            if(radioBloon){
                                radioName = orgName;    
                                value = $("input:radio[name="+orgName+"]:checked").val();
                                if(value != undefined) kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                                radioBloon = false;
                            }                            
                            break;
                        case 'checkbox':  //TODO
                            if($('#'+orgName).is(":checked")){
                                value = $('#'+orgName).val();
                            }
                            kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                            //if (e.checked) kvpairs.push(encodeURIComponent(input.attr('name')) + "=" + encodeURIComponent(input.attr('name')));
                            break;
                     }
                    break;
                case "select":
                    if (input["className"] && input["className"].indexOf("combobox-f ") > -1) {
                       
                        // ADD BY 2016-11-10
                        var options = $('#'+orgName).combotree("options");
                        
                        if(options && options.multiple) {
                        	value = $('#'+orgName).combo('getValues').join(',');    
                            
                        }else  value = input.combobox('getValue');
                               
                    } else {
                        value = input.val();
                    }
                    if(value===null)    value="";
                    kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                    break;
                case "textarea":
                    value = input.val();
                    kvpairs.push(encodeURIComponent(name) + "=" + encodeURIComponent(value));
                    break;
              }
            //console.log('Type: ' + input.attr('type') + ', Name: ' + name + ', Value: ' + value);
          }
    });
    return kvpairs.join("&");
}

