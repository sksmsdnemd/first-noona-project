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
    /* background-image: url(../images/common/catchall_bg_gr.png);  */
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
}
</style>
<title>BT-VELOCE</title>
</head>
<body>
<div class="main_wrap">
    <div class="container">
        <div class="outer">
            <div class="inner">
               	  요청하신 페이지에 오류가 발생했습니다.
               	 <br>관리자에게 문의하여 주십시오.
            </div>
        </div>
    </div>
</div>