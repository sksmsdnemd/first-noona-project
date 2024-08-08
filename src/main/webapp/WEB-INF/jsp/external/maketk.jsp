<%@ page language="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="java.util.*" %>
<%@page import="java.security.*" %>
<%@page import="java.math.*" %>
<%@page import="java.io.*" %>
<%@page import="org.springframework.context.*" %>
<%@page import="org.springframework.context.annotation.*" %>
<%@page import="org.springframework.web.servlet.support.*" %>
<%@page import="org.springframework.beans.factory.annotation.*"%>
<%@page import="org.springframework.web.context.support.*"%>
<%@page import="com.bridgetec.common.util.security.*" %>
<%@page import="java.text.*" %>
<%!
	public void jspInit() {
	    SpringBeanAutowiringSupport.processInjectionBasedOnServletContext(this, getServletContext());
	}
%>
<%	
	try {
		AESUtil.setKey("ipron-swat", 256);
		String token	= "ipron-swat";
		SimpleDateFormat format1 = new SimpleDateFormat ( "yyyyMMddHHmmss");
		Date time = new Date();
		String time1 = format1.format(time);
// 		System.out.println(time1);
		token = token+time1+"600";
		token = token+"btadmin";
		token = AESUtil.encrypt(token);
		
		out.println(token);
		
	} catch (IllegalArgumentException iae) {
		System.out.println("Exception : " + iae.toString());
		out.println("9999^");
	} catch (Exception e) {
		System.out.println("Exception : " + e.toString());
		out.println("9999^");
	}
	
%>