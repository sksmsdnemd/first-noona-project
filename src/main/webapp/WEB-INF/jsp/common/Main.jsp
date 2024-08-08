<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<title>VELOCE</title>
<%
 response.setHeader("X-Frame-Options", "SAMEORIGIN");
 response.setHeader("X-XSS-Protection", "1; mode=block");
 response.setHeader("X-Content-Type-Options", "nosniff");
%>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1">
<meta name="author" content="ARGO" />
<meta name="description" content="ARGO" />
<meta name="keywords" content="ARGO" />
<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet" 	href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.contants.css?ver=2017021601"/>"	type="text/css" />

<!--[if lt IE 9]>
	<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<script src="http://css3-mediaqueries-js.googlecode.com/svn/trunk/css3-mediaqueries.js"></script>
<![endif]-->

<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>

<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>

<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript"  src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>
<script>
	
	$(function(){
// 		
// 		fnSetInitInfo(); //로그인 기본 정보 설정
// 		//메뉴데이터 조회
// 		fnModuleSet();
	    
// 	    // 공통속성 환경설정 값 읽어서 처리 = 센터/파트/팀/조/행번/상담사명/직급/직책 
//  	    argoSetConfig();
// 	   // argoJsonSearchOne('CM','SP_CM1060M01_01','__',  null, fnCallbackGetConfig);
// 	    fnServiceableYn();
		fnSetScript();
	});
	function ck(){
		$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + '/UserManagement/userManamentF.do');	
	}
	function fnSetScript(){
		 $.getScript(gGlobal.ROOT_PATH+'/scripts/argojs/argo.navigation.js' , function(){
	          console.log("argo.navigation.js 로딩완료!!!");
	          
	 		 $.getScript( gGlobal.ROOT_PATH+'/scripts/argojs/argo.interface.js' , function(){
		          console.log("argo.interface.js 로딩완료!!!");
		     });
	     });	 
		if(gLoginUser.AGENT_JIKCHK=="80") $('#ifDashboard').attr('src', 'SYS00M01F.do');
	    else $('#ifDashboard').attr('src', 'SYS00M01F.do');	 
 	}
	
// 	function fnServiceableYn(){
// 		argoJsonSearchOne('ARGOCOMMON','SP_UC_GET_SERVICEABLE_YN', '__', {},  function(data, textStatus, jqXHR) {
//     		try {
//     			if (data.isOk()) {
//     				if(data.getRows()['serviceableYn']==0){
//     					argoAlert("라이센스 확인 바랍니다.");
//    					  	setTimeout("fnArgoLogOutResult()", 3000);
//     				}
//     			}
//     		} catch (e) {
//     			console.log(e);
//     		}
//     	});
// 	}
	
// 	function fnModuleSet(){
// 		 var tenantId = '${sessionMAP.tenantId}';
// 		$.ajax({
// 			type : 'post',
// 			data : {tenantId : tenantId},
// 			dataType : 'json',
// 			url : gGlobal.ROOT_PATH + '/common/chkMenuList.do',
// 			success : function(data) {
// 				if(data.flag=='Y'){
// 					fnMenuSet(data.module);
// 				}
// 				else{ 
// 					argoAlert(data.msg);
// 					setTimeout("fnArgoLogOutResult()", 3000);
// 					}
// 			},
// 			error : function(xhr, status, error) {
// 				console.log("Error : " + error);
// 			}
// 		});
// 	}
// 	function fnCallbackGetInitMenu(data, textStatus, jqXHR){
// 		try{
// 			if(data.isOk()){
// 				top.gMenuRows = data.getRows();
				
// 				fnSetMenu("sideMenu_HR", "HR");
// 				fnSetMenu("sideMenu_QA", "QA");
// 				fnSetMenu("sideMenu_EDU","EDU");
// 				fnSetMenu("sideMenu_KPI","KPI");
// 				fnSetMenu("sideMenu_CM", "CM");
				
// 				/* left menu 설정된 북마크 색 아이콘 처리 */
// 				fnSetLeftBookMark();
							
// 				//setTimeout("fnSetScript()", 1000); // 메뉴 동적 생성 후 js 로딩 처리 	
				

// 			}
// 		} catch(e) {
// 			alert(e);    		
// 		}
// 	}
	
    // 공통속성 환경설정 값 읽어서 처리 = 센터/파트/팀/조/행번/상담사명/직급/직책 	
/*
    function fnSetConfig(){

    argoJsonSearchOne('CM','SP_CM1060M01_01','__',  null,     
						function (data, textStatus, jqXHR){					
						if(data.isOk()){
							
							gConfig.CENTER = data.getRows()['diDeptTxt1'] ; 
							gConfig.IS_CENTER = (data.getRows()['diDeptVisible1'] == '1' ? true : false) ; 
							gConfig.PART = data.getRows()['diDeptTxt2'] ; 
							gConfig.IS_PART = (data.getRows()['diDeptVisible2'] == '1' ? true : false) ; 
							gConfig.TEAM = data.getRows()['diDeptTxt3'] ; 
							gConfig.IS_TEAM = (data.getRows()['diDeptVisible3'] == '1' ? true : false) ; 
							gConfig.JO = data.getRows()['diDeptTxt4'] ; 
							gConfig.IS_JO = (data.getRows()['diDeptVisible4'] == '1' ? true : false) ; 
			
							gConfig.SABUN = data.getRows()['diAgtTxt1'] ; 
							gConfig.IS_SABUN = (data.getRows()['diAgtVisible1'] == '1' ? true : false) ; 			
							gConfig.AGENT_NM = data.getRows()['diAgtTxt2'] ; 
							gConfig.IS_AGENT_NM = (data.getRows()['diAgtVisible2'] == '1' ? true : false) ; 	
							gConfig.JIKGUP = data.getRows()['diAgtTxt3'] ; 
							gConfig.IS_JIKGUP = (data.getRows()['diAgtVisible3'] == '1' ? true : false) ; 	
							gConfig.JIKCHK = data.getRows()['diAgtTxt4'] ; 
							gConfig.IS_JIKCHK = (data.getRows()['diAgtVisible4'] == '1' ? true : false) ;
							
							gConfig.PW_COMBI_YN = data.getRows()['pwCombiYn'] ; 
							gConfig.PW_INIT = data.getRows()['pwInit'] ; 
							gConfig.PW_INIT_TXT = data.getRows()['pwInitTxt'] ; 
							gConfig.DI_TEL_TYPE = data.getRows()['diTelType'] ; 
							gConfig.DI_RNO_TYPE = data.getRows()['diRnoType'] ; 
						}	
					}   );
		}
	
	
// 	// 기본 메뉴 그리기
// function fnMenuSet(module){
// 	var htmlObj = '';
// 	if(module.indexOf('HR')!=-1){
// 		htmlObj+='<li class="hr">'
// 						+'<a href="#">인사관리'
// 							+'<span class="eng">(HR)</span>'
// 							+'<span class="showHide">shiw/hide</span>'                    
// 						+'</a>'
// 						+'<div class="lv2" id="sideMenu_HR"></div>'
// 					+'</li>';
// 	}
// 	if(module.indexOf('QA')!=-1){
// 		htmlObj+='<li class="qa">'
// 					+'<a href="#">통화품질'
// 						+'<span class="eng">(QA)</span>'
// 						+'<span class="showHide">shiw/hide</span>' 
// 					+'</a>'
// 				   +'<div class="lv2" id="sideMenu_QA"></div>'
// 				+'</li>';
// 	}
// 	if(module.indexOf('EDU')!=-1){
// 		htmlObj+='<li class="edu">'
// 						+'<a href="#">교육'
// 							+'<span class="eng">(EDU)</span>'
// 							+'<span class="showHide">shiw/hide</span>' 
// 						+'</a>'
// 						+'<div class="lv2" id="sideMenu_EDU"></div>'
// 					+'</li>';
// 	}
// 	if(module.indexOf('KPI')!=-1){
// 		htmlObj+='<li class="kpi">'
// 						+'<a href="#">성과실적'
// 							+'<span class="eng">(KPI)</span>'
// 							+'<span class="showHide">shiw/hide</span>'                    
// 						+'</a>'
// 						+'<div class="lv2" id="sideMenu_KPI"></div>'
// 					+'</li>';
// 	}
// 	if(module.indexOf('CM')!=-1){
// 		htmlObj+='<li class="cm">'
// 						+'<a href="#">통합관리'
// 							+'<span class="eng">(CM)</span>'
// 							+'<span class="showHide">shiw/hide</span>'                    
// 						+'</a>'
// 						+'<div class="lv2" id="sideMenu_CM"></div>'
// 					+'</li>';
// 	}
// 	$("#sideMenuArea").append(htmlObj);
	
// 	var param = {"systemKind":module}; // 로그인 사용자의 전체 메뉴 조회
//     argoJsonSearchList('ARGOCOMMON','SP_UC_GET_MENU_01','__', param, fnCallbackGetInitMenu);
// }
// 	function fnSetInitInfo(){
// 		// 사용자 개인 이미지 셋팅 
// 		fnUserPhoto();
		
// 		// 로그인사용자 정보 및 서버 시간 설정
// 		var sServerDt = "${sessionMAP.serverDate}";
// 		gServerDt = new Date(sServerDt); //FOOTER 에서 기준으로 DISPLAY
		
// 		sServerDt = sServerDt.substring(11,16)
// 		$('#loginTime').html(' ('+sServerDt+')');
	
//         //2017-05-11 로그인 사용자 정보 gLoginUser 에 저장  
//         gLoginUser.CENTER_CD = '${sessionMAP.centerCd}' ;
//         gLoginUser.CENTER_NM = '${sessionMAP.centerNm}' ;
//         gLoginUser.PART_CD   = '${sessionMAP.partCd}' ;
//         gLoginUser.PART_NM   = '${sessionMAP.partNm}' ;
//         gLoginUser.TEAM_CD   = '${sessionMAP.teamCd}' ;
//         gLoginUser.TEAM_NM   = '${sessionMAP.teamNm}' ;
//         gLoginUser.DEPT_CD   = '${sessionMAP.deptCd}' ;
//         gLoginUser.DEPT_NM   = '${sessionMAP.deptNm}' ;
//         gLoginUser.AGENT_ID  = '${sessionMAP.agentId}' ;
//         gLoginUser.AGENT_NM  = '${sessionMAP.agentNm}' ;
//         gLoginUser.SABUN     = '${sessionMAP.sabun}' ;
//         gLoginUser.AGENT_JIKGUP = '${sessionMAP.agentJikgup}' ;
//         gLoginUser.AGENT_JIKCHK = '${sessionMAP.agentJikchk}' ;
//         gLoginUser.CENTER_CDS = '${sessionMAP.centerCds}' ;
//         gLoginUser.PART_CDS   = '${sessionMAP.partCds}' ;
//         gLoginUser.TEAM_CDS   = '${sessionMAP.teamCds}' ;
        
//         var aDeptCd = [];
//         var aDeptNm = [];
//         if(gConfig.IS_CENTER) {
//         	aDeptCd.push(gLoginUser.CENTER_CD) ;
//         	aDeptNm.push(gLoginUser.CENTER_NM) ;
//         }
//         if(gConfig.IS_PART) {
//         	aDeptCd.push(gLoginUser.PART_CD) ;
//         	aDeptNm.push(gLoginUser.PART_NM) ;
//         }
//         if(gConfig.IS_TEAM) {
//         	aDeptCd.push(gLoginUser.TEAM_CD) ;
//         	aDeptNm.push(gLoginUser.TEAM_NM) ;
//         }      
// 		if (gLoginUser.DEPT_CD != gLoginUser.CENTER_CD
// 				&& gLoginUser.DEPT_CD != gLoginUser.PART_CD
// 				&& gLoginUser.DEPT_CD != gLoginUser.TEAM_CD) {
// 			aDeptCd.push(gLoginUser.DEPT_CD);
// 			aDeptNm.push(gLoginUser.DEPT_NM);
// 		}

// 		gLoginUser.DEPT_PATH_CD = aDeptCd.join(",");
// 		gLoginUser.DEPT_PATH_NM = aDeptNm.join(",");

// 		// 2017-04-17 상담사(직급 = 80 ) 인 경우 상담사용 dashboard 로 처리

// 		// 	    if(gLoginUser.AGENT_JIKCHK=="80") $('#ifDashboard').attr('src', 'dashboard02F.do');
// 		// 	    else $('#ifDashboard').attr('src', 'dashboard01F.do');	 

// 		// fnPopAgentPw();
// 	}

// 	//------------------------------------------------------
// 	// 메뉴그리기
// 	//------------------------------------------------------	
// 	function fnSetMenu(activeId, supMenu) {

// 		try { // 해당 메뉴만 filtering
// 			var data = $.grep(top.gMenuRows, function(n, i) {
// 				return (n.systemKind == supMenu);
// 			});

// 			var strMenu = '<span class="icon_arrow"></span><ul class="lv2_scroll">';

// 			if (data.length > 0) {

// 				$
// 						.each(
// 								data,
// 								function(index, row) {
// 									// 중분류 메뉴 시작
// 									if (row.idx == "1") {
// 										if (index > 0)
// 											strMenu = strMenu + '</ul></li>'; //이전 중분류 close

// 										strMenu = strMenu
// 												+ '<li> <a href="#" class="show">'
// 												+ row.groupNm
// 												+ '<span class="icon_pm"></span></a><ul class="lv3">';
// 									}
// 									//소분류 메뉴
// 									strMenu = strMenu
// 											+ '<li><a href="#" id="'+ row.pgmId +'" data-path="'+ row.pgmPath +'" data-kind="'+ row.systemKind +'">'
// 											+ row.pgmNm
// 											+ '</a><span class="btn_favor" id="btnFavor' + row.pgmId+'">favor</span></li>';

// 								});

// 				strMenu = strMenu + '</ul></li></ul>'; // 마지막 중분류메뉴 close
// 				$('#' + activeId).append(strMenu);
// 			}

// 			if (supMenu == 'CM')
// 				fnSetScript(); // 최종 메뉴 등록 후 스크립트 로딩 처리
// 		} catch (e) {
// 			console.log(e);
// 		}
// 	}

// 	//------------------------------------------------------
// 	// Logout
// 	//------------------------------------------------------
// 	function fnArgoLogOutConfirm() {
// 		argoConfirm('로그아웃 하시겠습니까?', fnArgoLogOutResult);
// 	}

// 	function fnArgoLogOutResult() {

// 		argoAjax("postsync", gGlobal.ROOT_PATH + "/argoLogOut.do", null, null,
// 				function(data, textStatus, jqXHR) {
// 					if (data.resultCode = '0000')
// 						window.location.replace(gGlobal.ROOT_PATH + '/');
// 					else
// 						alert(data.resultCode);
// 				}, null);
// 	}

// 	//------------------------------------------------------
// 	// EDU 업무평가응시에서 시간체크에 의해 응시화면 자동 팝업 처리
// 	//------------------------------------------------------
// 	var gRowExamMaster = null;
// 	var gRowExamDetail = null;
// 	function fnEduExamStart(rowExamMaster, rowExamDetail) {
// 		gRowExamMaster = rowExamMaster;
// 		gRowExamDetail = rowExamDetail;
// 		$("body")
// 				.append(
// 						"<iframe class='evaluation_frame' id='' name='' src='../EDU/EDU2010M02F.do'></iframe>");
// 	}

// 	//------------------------------------------------------
// 	// 비밀번호 정책 처리 ==> 최초 로그인 또는 최대암호사용기한 체크
// 	//------------------------------------------------------
// 	function fnPopAgentPw() {

// 		var sPW_MAX_PERIOD_YN = '${sessionMAP.pwMaxPeriodYn}';
// 		var sPW_FIRST_CHANGE_YN = '${sessionMAP.pwFirstChangeYn}';

// 		var sTitle = "";

// 		if (sPW_FIRST_CHANGE_YN == 'Y') {
// 			sTitle = " [최초 로그인]";
// 		} else {
// 			if (sPW_MAX_PERIOD_YN == 'Y') {
// 				sTitle = " [암호사용기간 초과]";
// 			}
// 		}

// 		if (sTitle.length > 0) {
// 			gPopupOptions = {
// 				"pUserId" : gLoginUser.AGENT_ID
// 			};

// 			var openWindowPwd = $("body").openWindow({
// 				title : "비밀번호 변경하십시오" + sTitle,
// 				url : gGlobal.ROOT_PATH + '/HR/HR1010S01F.do',
// 				width : 460,
// 				height : 280,
// 				pid : "Main",
// 				ptype : "M",
// 				multi : false,
// 				closeable : false
// 			/* 저장 하기 전엔 닫을 수 없다.*/
// 			});
// 		}

// 	}

// 	function fnSetLeftBookMark() {

// 		argoJsonSearchList('ARGOCOMMON', 'SP_CM_BOOKMARK_01', '__', {},
// 				function(data, textStatus, jqXHR) {
// 					try {
// 						if (data.getRows() != '') {
// 							$.each(data.getRows(), function(index, row) {
// 								$('#btnFavor' + row.pgmId).addClass("on");
// 							});
// 						} else {
// 							$(".util .btn_favor").removeClass("on");
// 							$(".favor_blank").show();
// 						}
// 					} catch (e) {
// 						console.log(e);
// 					}
// 				});
// 	}

// 	function fnArgoUserEdit() {
// 		argoPopupWindow('개인정보변경', gGlobal.ROOT_PATH + '/common/UserEditF.do',
// 				'1100', '375');
// 	}

// 	/* 사용자 개인 이미지 셋팅 */
// 	function fnUserPhoto() {
// 		argoJsonSearchOne(
// 				'ARGOCOMMON',
// 				'SP_CM_USEREDIT_01',
// 				'__',
// 				{},
// 				function(data, textStatus, jqXHR) {
// 					try {
// 						if (data.isOk) {
// 							if (data.getRows()['imgRealFilename'] == null)
// 								data.getRows()['imgRealFilename'] = "";
// 							if (data.getRows()['imgRealFilename'] != "") {
// 								var sImgFile = data.getRows()['imgRealFilename'];

// 								sImgFile = encodeURI(sImgFile, "UTF-8");
// 								var sFullPath = location.protocol
// 										+ "//"
// 										+ location.hostname
// 										+ (location.port ? ":" + location.port
// 												: "") + gGlobal.ROOT_PATH
// 										+ gGlobal.FILE_PATH
// 										+ data.getRows().imgPath + "/"
// 										+ sImgFile;
// 								$('#userImg')
// 										.html(
// 												'<img src="'+sFullPath + '" width="31" height="31"/>');

// 							} else {
// 								$('#userImg').html("");
// 							}
// 						}
// 					} catch (e) {
// 						console.log(e);
// 					}
// 				});
// 	}

// 	/* 북마크 이벤트  */
// 	function fnBookmarkControl(targetId) {
// 		if (targetId.indexOf("btnFavorTop") != -1) {
// 			if ($(".favor_box").is(':visible')) {
// 				$(".favor_box").hide();
// 			} else {
// 				$(".favor_box").show();
// 			}
// 			;
// 		} else if (targetId.indexOf("btnFavor") == -1 || targetId == undefined) {
// 			$(".favor_box").hide();
// 		}
// 		;

// 	}

</script>

<style type="text/css">
.custom-menu {
    z-index:1000;
    position: absolute;
    background-color:#C0C0C0;
    border: 1px solid black;
    padding: 2px;
/*     height: 20px; */
}

</style>
</head>

<body>
	<div id="wrap">
    
    	<!-- S:Side Navi(Left) -->
    	<aside class="side_navi">
        	<h1 class="side_logo"><a href="#">ARGO</a></h1>
            <div class="gnb_scroll scrollbar-inner">
                <ul class="gnb" id="sideMenuArea">
                    <li class="hr">
                        <a href="#" onclick="ck()">인사관리
                            <span class="eng">(HR)</span>
                            <span class="showHide">shiw/hide</span>                    
                        </a>
                        <div class="lv2" id="sideMenu_HR"> 동적 생성 영역 </div>
                    </li>
                    <li class="qa">
                        <a href="#">통화품질
                            <span class="eng">(QA)</span>
                            <span class="showHide">shiw/hide</span> 
                        </a>
                       <div class="lv2" id="sideMenu_QA"> 동적 생성 영역 </div>
                    </li>
                    <li class="edu">
                        <a href="#">교육
                            <span class="eng">(EDU)</span>
                            <span class="showHide">shiw/hide</span> 
                        </a>
 						<div class="lv2" id="sideMenu_EDU"> 동적 생성 영역 </div>
                    </li>
                    <li class="kpi">
                        <a href="#">성과실적
                            <span class="eng">(KPI)</span>
                            <span class="showHide">shiw/hide</span> 
                        </a>
 						<div class="lv2" id="sideMenu_KPI"> 동적 생성 영역 </div>
                    </li>
                    <li class="cm">
                        <a href="#">통합관리
                            <span class="eng">(CM)</span>
                            <span class="showHide">shiw/hide</span> 
                        </a>
 						<div class="lv2" id="sideMenu_CM"> 동적 생성 영역 </div>
                    </li>
                </ul>
               
            </div>
        </aside>  
        <!-- E:Side Navi(Left) -->
        
        <!-- S:Content(Right) -->  	 
        <section class="section dashboard">  
        	<!-- S:header -->      	
        	<header class="header">                
                <a class="btn_sideNavi" href="#"><span class="icon_arrow">side_menu</span></a>
                <span class="project_logo"><!-- <img src="../images/icon_projectLogo.png" alt="농협중앙회"> --></span>
                <div class="top_r">
                    <p class="user_info">
                        <span class="user_photo" id="userImg"></span>                                                                     
                        <span class="user_name">[${sessionMAP.sabun}] ${sessionMAP.agentNm}</span>
                        <span class="user_connect" id="loginTime"></span>
                    </p>
                    <ul class="util">
                    	<li>
                        	<a href="#" class="btn_favor" id="btnFavorTop">즐겨찾기</a>
                        	<div class="favor_box">
                                <span class="icon_popArrow"></span>
                                <div class="favor_list" id="favor_list">
                                	<div class="favor_blank">등록된 메뉴가 없습니다.</div>
                                    <ul>
                                          
                                    </ul>
                                </div>
                            </div>  
                        </li>	
                        <li><a href="javascript:fnArgoUserEdit()" class="btn_setting">개인정보변경</a></li>
                        <li><a href="javascript:fnArgoLogOutConfirm();" class="btn_logout">로그아웃</a></li>
                    </ul>                
                </div>
            </header>
            <!-- E:header --> 
            
            <!-- S:History Tab --> 
            <article class="history">            	
            	<ul class="history_tab">                
                	<li><a href="#" id="DASHBOARD" class="on" onClick="historyTab(this, 'DASHBOARD')">대시보드</a><span class="bnt_refresh" onclick="refresh_tab();">delete</span></li>
                </ul>
              <div class="history_control">
					<a href="#" class="btn_allPrev non_control">Prev</a>
                    <a href="#" class="btn_allNext">next</a>                
                	<a href="#" class="btn_allDelete">전체삭제</a>
                </div>
            </article>
            <!-- E:History Tab -->  
            
            <!-- S:Contents --> 
            <article class="contents">
            	<div class="content_wrap" ><iframe id="ifDashboard" src=""></iframe></div>        
            </article>
            <!-- E:Contents --> 
            
            <article class="bottom">
            	<span class="now_date"></span>
                <span class="now_time">
                    <ul>
                        <li>(</li>
                        <li class="now_hour"></li>
                        <li class="now_point">:</li>
                        <li class="now_min"></li>
                        <li class="now_point">:</li>
                        <li class="now_sec"></li>
                        <li>)</li>
                    </ul>                    
                </span>
                <span class="now_c">|</span>
                <span class="now_page"></span>
            	<span class="copyright">Copyright (c) Bridgetec.corp. All right Reserved.</span>
            </article>
            
        </section>    
        <!-- E:Content(Right) -->
            
	</div>
</body>
</html>
