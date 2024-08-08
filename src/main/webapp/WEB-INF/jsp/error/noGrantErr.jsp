<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ include file="/WEB-INF/jsp/include/common.jsp"%>
<%
    response.setStatus(200);
%> 
<style>
.container {
    width: 70%;
    height: 70%;
    margin: 40px auto;
    background-position: center;
    background-repeat: no-repeat;
    background-image: url(../images/common/catchall_bg_gr.png);  
}
.outer {
    display: table;
    width: 100%;
    height: 100%;
}
.inner {
    display: table-cell;
    vertical-align: middle;
    text-align: center;
    font-family: NanumGothic-Bold;
    font-size: x-large;
    line-height: initial;
    padding-top: 26px;
}
</style>
<title>404 PAGE NotFound</title>
</head>
<body>
<div id="wrap">
    <!-- Head S
    <jsp:include page="/WEB-INF/jsp/include/header.jsp" flush="true" />-->
    <!-- Head E-->
    <hr />
    <!-- body S-->
	 <div id="body">
	   <div class="wrap2">
	     <div class="mt5 ml10 mr10 mb10">
	       <div class="b_calendar mb10"> 요청하신 페이지에 대한 권한이 존재하지 않습니다.</div>
	       <div id="caLayout">
	       
	           <div class="container">
	               <div class="outer">
	                   <div class="inner">
	                               페이지 접근 오류(NoGrant)가 발생했습니다
	                   </div>
	               </div>
	           </div>
	           
	       </div>
	     </div>
	   </div>
	 </div>
    <!-- body E-->
    <hr />
    <!-- foot S
    <jsp:include page="/WEB-INF/jsp/include/footer.jsp" flush="true" />-->
    <!-- foot E-->
</div>
