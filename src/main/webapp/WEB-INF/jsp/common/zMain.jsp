<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<jsp:include page="/WEB-INF/jsp/include/common.jsp" flush="true" />

<link rel="stylesheet" href="<c:url value="/css/jquery.argo.scrollbar.css"/>" type="text/css" />
<link rel="stylesheet" 	href="<c:url value="/css/jquery-argo.ui.css?ver=2017030601"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.common.css?ver=2017021301"/>"	type="text/css" />
<link rel="stylesheet"	href="<c:url value="/css/argo.contants.css?ver=2017021601"/>"	type="text/css" />
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-1.11.3.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery-ui.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.scrollbar.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/jquery/jquery.cookie.js"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.core.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.basic.js?ver=2017011901"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.common.js?ver=2017012503"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.alert.js?ver=2017011301"/>"></script>
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.popWindow.js"/>"></script>    
<script type="text/javascript" src="<c:url value="/scripts/argojs/argo.pagePreview.js"/>"></script>


<script>
	$(document).ready(function() {
		fnInitCtrl();
		
		$('#ifDashboard').attr('src', 'VIntroF.do');
	});
	
	function fnInitCtrl(){	
		($("body").hasClass("side_w") ? $("body").removeClass("side_w").addClass("side_n") : $("body").addClass("side_w").removeClass("side_n") );
		
		this.btn_sideNavi = $(".btn_sideNavi");
		this.btn_sideNavi.on( "click", function(e){
			($("body").hasClass("side_w") ? $("body").removeClass("side_w").addClass("side_n") : $("body").addClass("side_w").removeClass("side_n") );	
			return false;
		});
		
		
	}
	
	function linkGo(value){
		$('#ifDashboard').attr('src', gGlobal.ROOT_PATH + value);
	}

	var togName = "";
	function fnMenuTog(menuName, depth2, depth3){

		togName = menuName + "_" + depth2 + "_" + depth3;

		$("#"+togName).toggle();

	}
	

	
</script>
</head>
<body>
	<div id="wrap">
    
    	<!-- S:Side Navi(Left) -->
    	<aside class="side_navi">
        	<h1 class="side_logo"><a href="javascript:linkGo('/common/VIntroF.do');">VELOCE</a></h1>
            <div class="gnb_scroll scrollbar-inner">
                <ul class="gnb" id="sideMenuArea">
                	<li class="hr"><a href="#">상태모니터링관리<span class="eng">(AM)</span><span class="showHide">show/hide</span></a>
						<div id="sideMenu_AM"></div>
					</li>

					<li class="hr"><a href="javascript:fnMenuTog('2','0','0');">통화내역관리<span class="eng">(SP)</span><span class="showHide">show/hide</span></a>
						<div id="sideMenu_SP">
							<span class="icon_arrow"></span>
                            <ul id="2_0_0" style="display:none"></br>
                            	<li id="2_1_0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            		<a href="javascript:linkGo('/recording/RecSearchF.do');" style="color:gray">통화내역조회<span class="icon_pm"></span></a>
								</li></br>
                            </ul>
						</div>
					</li>
										
					<li class="hr"><a href="#">운용관리<span class="eng">(UM)</span><span class="showHide">show/hide</span></a>
						<div id="sideMenu_UM"></div>
					</li>
					
					<li class="hr"><a href="#">평가관리<span class="eng">(AV)</span><span class="showHide">show/hide</span></a>
						<div id="sideMenu_AV"></div>
					</li>
					
					<li class="hr"><a href="javascript:fnMenuTog('5','0','0');">시스템관리<span class="eng">(SM)</span><span class="showHide">show/hide</span></a>
						<div id="sideMenu_SM">
							<span class="icon_arrow"></span>
                            <ul id="5_0_0" style="display:none"></br>
                            	<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            		<a href="javascript:fnMenuTog('5','1','0');" style="color:gray"><strong>시스템설정관리</strong><span class="icon_pm"></span></a>
                                    <ul id = "5_1_0" style="display:none">
                                    	<li></li></br>
                                    	<li id='5_1_2'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    		<a href="javascript:linkGo('/system/SysInfoMainF.do');" style="color:green"><strong>시스템정보관리</strong></a></li></br>
                    					<li id='5_1_3'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    						<a href="javascript:linkGo('/system/IpInfoMainF.do');" style="color:green"><strong>IP정보관리</strong></a></li></br>
                    					<li id='5_1_4'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    						<a href="javascript:linkGo('/system/ProcInfoMainF.do');" style="color:green"><strong>프로세스관리</strong></a></li></br>
                    					<li id='5_1_5'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    						<a href="javascript:linkGo('/system/ResMonMainF.do');" style="color:green"><strong>리소스관리</strong></a></li></br>
                    					<li id='5_1_6'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    						<a href="javascript:linkGo('/system/ResMonDefMainF.do');" style="color:green"><strong>리소스기본설정</strong></a></li></br>
                                    </ul>
                                </li></br>
                                
                                <li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            		<a href="javascript:fnMenuTog('5','2','0');" style="color:gray"><strong>백업관리</strong><span class="icon_pm"></span></a>
                                    <ul id = "5_2_0" style="display:none">
                                    	<li></li></br>
                                    	<li id='5_2_1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    		<a href="javascript:linkGo('/system/BkLabelMainF.do');" style="color:green"><strong>백업레이블관리</strong></a></li></br>
                    					<li id='5_2_2'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    						<a href="javascript:linkGo('/system/BkInfoMainF.do');" style="color:green"><strong>백업장치관리</strong></a></li></br>
                                    </ul>
                                </li></br>
                                
                                <li id="5_4_0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            		<a href="javascript:linkGo('/system/ResourceMainF.do');" style="color:gray">리소스통계<span class="icon_pm"></span></a>
								</li></br>
                                
                            </ul>
						</div>
					</li>
					
					<li class="hr"><a href="javascript:fnMenuTog('6','0','0');">장애관리<span class="eng">(FM)</span><span class="showHide">show/hide</span></a>
						<div id="sideMenu_FM">
							<span class="icon_arrow"></span>
                            <ul id="6_0_0" style="display:none"></br>
                            	<li id="6_2_0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            		<a href="javascript:linkGo('/alarm/CurErrMainF.do');" style="color:gray">현재장애로그조회<span class="icon_pm"></span></a>
								</li></br>
                            	<li id="6_3_0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            		<a href="javascript:linkGo('/alarm/ErrLogMainF.do');" style="color:gray">장애이력조회<span class="icon_pm"></span></a>
                                </li></br>
                                
                            </ul>
						</div>
					</li>
					<li><a href="javascript:linkGo('/RecManagement/recInfoManamentF.do');" style="fontcolor:white">청취로그조회</a></li>
			<li><a href="javascript:linkGo('/RecManagement/recISampleCallF.do');" style="fontcolor:white">샘플콜관리</a></li>
			<li><a href="javascript:linkGo('/RecManagement/recSampleGrpManamentF.do');" style="fontcolor:white">샘플콜분류관리</a></li>
                       
			<li><a href="javascript:linkGo('/UserManagement/userManamentF.do');" style="fontcolor:white">그룹정보관리</a></li>
              		<li><a href="javascript:linkGo('/UserManagement/userInfoManamentF.do');" style="fontcolor:white">사용자정보관리</a></li>
              		<li><a href="javascript:linkGo('/UserManagement/telNumManamentF.do');" style="fontcolor:white">내선번호관리</a></li>
                </ul>
               
            </div>
        </aside>  
        <!-- E:Side Navi(Left) -->
        
        <!-- S:Content(Right) -->  	 
        <section class="section dashboard">  
        	<!-- S:header -->      	
        	<header class="header">                
                <a class="btn_sideNavi" href="#"><span class="icon_arrow">side_menu</span></a>
                <span class="project_logo"><img src="../images/login_bs.png" alt="부산은행"></span>
                <div class="top_r">
                    <p class="user_info">
                        <span class="user_photo" id="userImg"></span>                                                                     
                        <span class="user_name">[10002] 테스트 2</span>
                        <span class="user_connect" id="loginTime">(14:47)</span>
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
            	<div class="content_wrap" data-id="DASHBOARD"><iframe id="ifDashboard" src=""></iframe></div>        
            </article>
            <!-- E:Contents --> 
            
            <article class="bottom">
            	<img src="../images/icon_clock.png">
            	<span class="now_date">2017-11-08</span>
                <span class="now_time">
                    <ul>
                        <li>(</li>
                        <li class="now_hour">15</li>
                        <li class="now_point">:</li>
                        <li class="now_min">39</li>
                        <li class="now_point">:</li>
                        <li class="now_sec">07</li>
                        <li>)</li>
                    </ul>                    
                </span>
                <!-- <span class="now_c">|</span>
                <span class="now_page"></span -->>
            	<span class="copyright">Copyright (c) Bridgetec.corp. All right Reserved.</span>
            </article>
            
        </section>    
        <!-- E:Content(Right) -->
            
	</div>
</body>
</html>