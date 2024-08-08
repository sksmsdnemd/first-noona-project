<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.css"/>" type="text/css" /> -->
<!-- <link rel="stylesheet" href="<c:url value="/css/w2ui-1.5.rc1.min.css"/>" type="text/css" /> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.js"/>"></script> -->
<!-- <script type="text/javascript" src="<c:url value="/scripts/argojs/w2ui-1.5.rc1.min.js"/>"></script> -->

<script>

	var loginInfo = JSON.parse(sessionStorage.getItem("loginInfo"));
	var userId 	  = loginInfo.SVCCOMMONID.rows.userId;
	var tenantId  = loginInfo.SVCCOMMONID.rows.tenantId;
	var grantId   = loginInfo.SVCCOMMONID.rows.grantId;
	var workIp    = loginInfo.SVCCOMMONID.rows.workIp;
	var workMenu  = "프로세스관리";
	var workLog   = "";

	var dataArray = new Array();
	var procIp = "";
	var serverPort = document.location.protocol == "http:" ? 7060 : 7070;
	
	$(document).ready(function() {
		fnInitCtrl();
		fnInitGrid();
		fnSearchList();
		
		var delayTime = $("#refreshValue option:selected").val();	
		playInter("Y", delayTime);
	});
	 
	function fnInitCtrl(){	
		argoCbCreate("s_FindSystemIp", "sysGroup", "getSysIpList",{}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		argoCbCreate("s_FindProcessCode", "baseCode", "getBaseComboList", {classId:'process_class'}, {"selectIndex":0, "text":'선택하세요!', "value":''});
		procIp = document.location.protocol+ "//"+$("#s_FindSystemIp option:selected").val()+":"+serverPort+"/"
		
		$("#btnSearch").click(function(){
			fnSearchList();
		});
		
		$("#s_FindSystemIp").change(function(){
			procIp = document.location.protocol + "//"+$("#s_FindSystemIp option:selected").val()+":"+serverPort+"/" 
		});
		
		$("#autoRefresh").change(function()	{	 	
			if($("input:checkbox[id='autoRefresh']").is(":checked")){
				var delayTime = $("#refreshValue option:selected").val();	
				playInter("Y", delayTime);
			}else{  
				playInter("N");
			}
		});
	}
	
	var expandMap = new Map();
	function fnInitGrid(){
		$('#gridList').w2grid({ 
	        name: 'grid', 
	        show: {
	            lineNumbers: true,
	            footer: true,
	        },
	        onExpand: function (event)  {
	        	expandMap.set(String(event.recid), String(event.recid));
	        },
	        onCollapse: function (event)  {
	        	expandMap.delete(event.recid);
	        },
	        columns: [  
						 { field: 'recid', 			  caption: 'recid', 		size: '0%', 	sortable: true, attr: 'align=center' }
						,{ field: 'processName', 	  caption: '프로세스', 			size: '5%', 	sortable: true, attr: 'align=left' } 
						,{ field: 'activeStanby', 	  caption: 'ACTIVE/STANBY', 			size: '5%', 	sortable: true, attr: 'align=center' }
						,{ field: 'status', 	  caption: '상태', 			size: '5%', 	sortable: true, attr: 'align=center' }
						,{ field: 'version', 	  caption: '버전', 			size: '5%', 	sortable: true, attr: 'align=center' }
						,{ field: 'processDate', 	  caption: '시작시간', 			size: '5%', 	sortable: true, attr: 'align=center' }
						,{ field: 'server', 	  caption: '', 			size: '5%', 	sortable: true, attr: 'align=center' }
	        ],
	        records: dataArray,
	    });
		w2ui['grid'].hideColumn('recid');
		w2ui['grid'].show.expandColumn = !w2ui['grid'].show.expandColumn;
	}
	
	
	//리스트 로우 개수
// 	var dataPerPage = 15;
// 	function fnSearchListcnt() {
// 		argoJsonSearchOne('sysGroup', 'getSysProcServerListCnt', 's_', {},
// 		function(data, textStatus, jqXHR) {
// 			try {
// 				if (data.isOk()) {
// 					var totalData = data.getRows()['cnt'];
// 					paging(totalData, "1", dataPerPage, "3");

// 					$("#totCount").text(totalData);

// 					if (totalData == 0) {
// 						argoAlert('조회 결과가 없습니다.');
// 					}

// 					w2ui.grid.lock('조회중', true);
// 				}
// 			} catch (e) {
// 				console.log(e);
// 			}
// 		});
// 	}
	
	// 리스트 상태표시
	function fnProcStatus(idx){
		var result = {};
		switch(idx){
			case "1": 
				result.state = "RUNING";
				result.stateColor = "green";
				break;
			case "2":
				result.state = "DOWN";
				result.stateColor = "Red";
				break;
			case "3":
				result.state = "USER_STOP";
				result.stateColor = "gray";
				break;
			case "4":
				result.state = "WAITING";
				result.stateColor = "blue";
				break;
			default:	
				break;
		}
		return result;
	}
	
	// Active/Stanby 표기
	function fnNHAMode(idx){
		var result = "";
		switch(idx) {
			case "0":
				result = "StandAlone";
				break;
			case "1":
				result = "Active";
				break;
			case "2":
				result = "Standby";
				break;
			default :
				break;			
		}
		return result;
	}
	
	// 실질적 테이블 리스트
	function fnSearchListInfo(){
		var result = tblList;
		var param = {};
		
		for(var i=0;i<result.length;i++){
			var url = document.location.protocol+"//"+result[i].code +":"+serverPort+"/"+ "GetServerInfo.do" ;
			param.index = String(i);
			param.paramDataType = "json";
			param.url = url;
 			
			var jsonLen = 0;
			
			$.ajax({
				url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
				type : "POST",
				data : JSON.stringify(param),
				contentType: "application/json; charset=utf-8",
				success : function(data) {
					var rtJson;
					var json;
					children = new Array();
					try{
						rtJson = JSON.parse(decodeURI(data));	
					}catch(error){
						argoAlert("데이터 파싱 에러");
						return false;
					}
					
					jsonLen = rtJson.PROCESS.length;
					json = rtJson.PROCESS;
					
					// 자식 노드 Json 파싱
					for(var j=0;j<jsonLen;j++){
						var childrenData = {};
						// 재시작 버튼
						var btnHtml = '<button onclick="fnProcStop('+json[j].nProcessID+',\''+json[j].szProcessName+'\',\''+document.location.protocol+"//"+result[rtJson.INDEX].code +":"+serverPort+"/"+'\');" style="cursor:pointer;border-radius: 5em;padding: 0.1em 0.3em;background: #f3f1f1;box-shadow: 1px 1px 0px rgb(0 0 0 / 30%);margin-left: 5px;"><img style="width: 23%;margin-right: 3px;" src="../images/icons/refresh.png">재시작</button>';
						// 자식 노드 프로세스명 들여쓰기
						var blankSpan = '<span class="w2ui-show-children w2ui-icon-empty"></span>' + '<span class="w2ui-show-children w2ui-icon-empty"></span>';
						var processIcon = '<img src="../images/icons/circle_' + fnProcStatus(json[j].nProcessState).stateColor + '.gif">'
						
						
						var recid = "";
						if(rtJson.INDEX >= 10){
							childrenData.recid = "a"+rtJson.INDEX+""+j;
						}else{
							childrenData.recid = rtJson.INDEX+""+j;
						}
						
						
						
						
						childrenData.processName = blankSpan+json[j].szProcessName+"("+json[j].nProcessID+")";
						childrenData.activeStanby = fnNHAMode(json[j].nHAMode);
						childrenData.status = processIcon+" "+fnProcStatus(json[j].nProcessState).state;
						childrenData.version = json[j].szProcVer;
						childrenData.processDate = json[j].szStartTime;
						childrenData.server = btnHtml;
						
						if($("#s_FindProcessCode option:selected").val()=="" || json[j].szProcessName.indexOf($("#s_FindProcessCode option:selected").text().replace(/ /g,"")) > -1){
							children.push(childrenData);	
						}
					}
					
					if(rtJson.INDEX >= 10){
						w2ui['grid'].set("a"+rtJson.INDEX, {w2ui:{"children": children}});
					}else{
						w2ui['grid'].set(rtJson.INDEX, {w2ui:{"children": children}});
					}
					
					
					w2ui['grid'].refresh();
					
					if(expandMap.get(String(rtJson.INDEX)) != undefined){
						w2ui['grid'].expand(expandMap.get(String(rtJson.INDEX)));
						//w2ui['grid'].expand("a"+expandMap.get(String("a"+rtJson.INDEX)));	
					}	
					
					
					if(expandMap.get(String("a"+rtJson.INDEX)) != undefined){
						w2ui['grid'].expand(expandMap.get(String("a"+rtJson.INDEX)));	
					}	
					
				},
				error : function(xhr, status, error) {
					console.log("error");
					$("#result").val(JSON.stringify(status, null, '\t') + "\r\n");
				}
			});	
		}
		
		if($("input:checkbox[id='autoRefresh']").is(":checked")){
			var delayTime = $("#refreshValue option:selected").val();	
			playInter("Y", delayTime);
		}
		
		$("#updateTime").text(getTimeStamp());
	}
	
	function fnMruRestartPopup(){
		argoPopupWindow('프로세스 재시작 인증', 'ProcServerMruRestartPopAddF.do', '550', '200');	
	}
	
	function fnProcStop(procId,procName,url){
		if(procName.indexOf("MRU") > -1 || procName.indexOf("BRU") > -1 || procName.indexOf("VSS") > -1){
			gPopupOptions = {"procId":procId,"procName":procName,"url":url};   	
			argoConfirm(procName+" 프로세스는 재시작의 인증절차가 필요한 작업입니다.<br/>계속 진행하시겠습니까?",fnMruRestartPopup);
			return false;
		}
		fnProcStopCallBack(procId,procName,url);
	}
	var gPopupOptions;
	// 프로세스 스탑
	function fnProcStopCallBack(procId,procName,url){
		if(procName.indexOf("OAU") > -1){
			argoAlert("OAU프로세스 재시작 시  DOWN표시없이 1분뒤 정상적인 프로세트 상태가 표시됩니다.");
		}
		argoConfirm("재시작 하시겠습니까?", function(){
			var param = {};
			
			param.ProcessID = String(procId);
			param.ProcessName = procName;
			param.paramDataType = "json";
			param.url = url+"ProcessStop.do";
			
			$.ajax({
				type : "POST",
				url : gGlobal.ROOT_PATH + "/wau/browserCorsProxyF.do",
				data : JSON.stringify(param),
				dataType : "json",
				contentType: "application/json; charset=utf-8",
				success : function(data) {
					var json = JSON.parse(decodeURI(data));
					argoAlert(json.data);
					setTimeout(() => fnSearchListInfo(), 1000);
				},
				error : function(error) {
					console.log(error);
				}
			});
		});
	}
	var tblList;
	// 테이블 리스트
	function fnSearchList(){
		w2ui['grid'].clear();
		var selIp = $("#s_FindSystemIp option:selected").val();
		var result = new Array();
		argoJsonSearchList('sysGroup', 'getSysProcServerList', 's_', null, function (data, textStatus, jqXHR){
			if(data.getRows() != ""){
				//var i = data.getProcCnt();.
				tblList = data.getRows();
				for(var i=0;i<tblList.length;i++){
					var expandSpan = '<span id="w2uiLowChk'+i+'" class="w2ui-show-children w2ui-icon-expand" onclick="w2ui[\'grid\'].toggle(jQuery(this).parents(\'tr\').attr(\'recid\'));event.stopPropagation();"></span>' ;
					var gObject2 = {  "recid" 			: i>=10?"a"+String(i):String(i)
							, "processName"   : expandSpan+tblList[i].systemName
							, "activeStanby"	: ''
							, "status"		: ''
							, "version" 		: ''
							, "server" 		: ''
						};
					w2ui['grid'].add(gObject2);
					
					if(i >= 10){
						expandMap.set("a"+String(i), String(i));
					}else{
						expandMap.set(String(i), String(i));
					}
					
					
				}
				
			}
		});
		fnSearchListInfo();
		//fnExpandAll();
	}
	
	var sysGroupId = "";
	var systemId   = "";
	var processId  = "";
	
	// 타이머
	var timer;
	function playInter(playFlag, delay) {
		if (playFlag == "Y") {
			clearInterval(timer);
			timer = setInterval("fnSearchListInfo();", delay);
		} else {
			clearInterval(timer);
		}
	}
	
	// 전체 펼치기
	function fnExpandAll(){
		var obj = w2ui['grid'];
		for(var i = 0; i < obj.records.length; i++){
			obj.expand(String(obj.records[i].recid));
			expandMap.set(String(event.recid), String(event.recid));
		}	
	}

	// 전체 접기
	function fnCollapseAll(){
		var obj = w2ui['grid'];
		for(var i = 0; i < obj.records.length; i++){
			obj.collapse(obj.records[i].recid);
			expandMap.delete(String(obj.records[i].recid));
		}
	}
	
	function getTimeStamp() {
	    var d = new Date();
	    var date = leadingZeros(d.getFullYear(), 4) + '-' + leadingZeros(d.getMonth() + 1, 2) + '-' + leadingZeros(d.getDate(), 2) + ' ';
	    var time = leadingZeros(d.getHours(), 2) + ':' + leadingZeros(d.getMinutes(), 2) + ':' + leadingZeros(d.getSeconds(), 2);

	    return date + " / " + time;
	}
	
	function leadingZeros(n, digits) {
	    var zero = '';
	    n = n.toString();

	    if (n.length < digits) {
	        for (i = 0; i < digits - n.length; i++)
	            zero += '0';
	    }
	    return zero + n;
	}
	
</script>
</head>
<body>
	<div class="sub_wrap">
        <div class="location"><span class="location_home">HOME</span><span class="step">시스템관리</span><span class="step">시스템설정관리</span><strong class="step">프로세스관리</strong></div>
        <section class="sub_contents">
            <div class="search_area" style="height: 45px;">
                <div class="row">
                    <ul class="search_terms">
                    	<li>
                            <strong class="title ml20">시스템</strong>
                            <select id="s_FindSystemIp" name="s_FindSystemIp" style="width:300px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                        <li>
                            <strong class="title">프로세스구분</strong>
                            <select id="s_FindProcessCode" name="s_FindProcessCode" style="width:300px;" class="list_box">
                            	<option value="">선택하세요!</option>
                            </select>
                        </li>
                    </ul>
                </div>
            </div>     
            <div class="btns_top">
            	<div class="sub_l">
	            <img src="../images/icons/ico_refresh.gif">
            	<select id="refreshValue" name="refreshValue" style="width:70px" class="list_box">
					<option value="5000">5 Sec</option>
					<option value="10000">10 Sec</option>
					<option value="20000">20 Sec</option>
					<option value="30000">30 Sec</option>
				</select>
				<input type="checkbox" id="autoRefresh" name="autoRefresh" checked>
				<label>Auto Refresh &nbsp;&nbsp;&nbsp;&nbsp;</label>
            	<strong style="width: 25px">[ 전체 ]</strong>	: <span id="totCount">0</span>
            	&nbsp;&nbsp;&nbsp;&nbsp;
            	<img src="../images/icon_arrR.png">
				<label><strong>최근업데이트시간 : </strong></label><span id="updateTime"></span>  
                </div>
                
                <!-- <button type="button" id="btnStart" class="btn_m confirm">시작</button>
                <button type="button" id="btnKill" class="btn_m confirm">중지</button>
                <button type="button" id="btnRestart" class="btn_m confirm">다시시작</button>  -->
                <button type="button" id="btnCollapseAll" class="btn_m confirm" onclick="fnExpandAll();">펼치기</button>
                <button type="button" id="btnCollapseAll" class="btn_m confirm" onclick="fnCollapseAll();">접기</button>
                <button type="button" id="btnSearch" class="btn_m search">조회</button>
            </div>
            <div class="h136">
            	<div class="btn_topArea fix_h25"></div>
	            <div class="grid_area h25 pt0">
	                <div id="gridList" style="width: 100%; height: 1000px;"></div>
	                <div class="list_paging" id="paging">
                		<ul class="paging">
                 		</ul>
                	</div>
                </div>
	        </div>
        </section>
    </div>
</body>

</html>
