<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@page import="com.bridgetec.argo.common.Constant"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

{"resultMsg":"DB TRANSACTION 에러가 발생하였습니다.(상세내용 참조).","resultSubMsg":"<c:out value="${exception.message}" />","resultCode":"<%=Constant.RESULT_CODE_ERR_PROC%>","resultSubCode":""}
