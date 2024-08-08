package com.bridgetec.common;

//import java.lang.reflect.Array;
import java.io.PrintWriter;
import java.util.*;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.bridgetec.argo.service.ArgoDispatchServiceImpl;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import egovframework.com.utl.slm.EgovMultiLoginPreventor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.ModelAndViewDefiningException;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.util.HttpUtil;

import egovframework.com.cmm.util.EgovUserDetailsHelper;
import egovframework.rte.fdl.string.EgovStringUtil;

@Controller("ArgoInterceptor")
public class ArgoInterceptor extends HandlerInterceptorAdapter {

    private static Logger loMeLogger = LoggerFactory.getLogger(ArgoInterceptor.class);
    private Set<String>   seMePermittedURL;
    private Set<String>   seMePermittedMethod;

    @Autowired
    private ArgoDispatchServiceImpl argoDispatchServiceImpl;
    
    @SuppressWarnings("rawtypes")
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception { //control요청전
        boolean isPermittedURL = false;        

        String sName, sValues[], sClientIp;
        int iCount, iNumber;
        Enumeration enNames;
        StringBuilder sbParameters;
        
        // ServletContext servletContext;
        // boolean isWrite, isRead;
        // String sProgramNo;

        String sRequestURI, sUrlPattern, sContextPath;
        Iterator<String> it;
        ModelAndView moView;
        String userSabun = "";
        
        sClientIp = request.getRemoteAddr();
 
        Map sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
        if(sessionMAP!=null){
            sessionMAP.put("loginIpAddr", sClientIp);
            userSabun = sessionMAP.get("sabun")+"";
        }
        
        //PARAMETER PRINT.
        sbParameters = new StringBuilder();
        sbParameters.append("url:[").append(request.getRequestURI()).append("]");
        
        enNames = request.getParameterNames();
        if (enNames.hasMoreElements() == true) {
            sName = (String) enNames.nextElement();
            sValues = request.getParameterValues(sName);

            if (sValues.length <= 1) {
                sbParameters.append(", parameters:[").append(sName).append(":").append(request.getParameter(sName));
            } else {
                sValues = request.getParameterValues(sName);
                sbParameters.append(", parameters:[").append(sName).append("(array)").append(":(").append(sValues[0]);

                iNumber = sValues.length;
                for (iCount = 1; iCount < iNumber; iCount++) {
                    sbParameters.append(",").append(sValues[iCount]);
                }
                sbParameters.append(")");
            }

            while (enNames.hasMoreElements() == true) {
                sName = (String) enNames.nextElement();
                sValues = request.getParameterValues(sName);

                if (sValues.length <= 1) {
                    sbParameters.append(", ").append(sName).append(":").append(request.getParameter(sName));
                } else {
                    sbParameters.append(", ").append(sName).append("(array)").append(":(").append(sValues[0]);

                    iNumber = sValues.length;
                    for (iCount = 1; iCount < iNumber; iCount++) {
                        sbParameters.append(",").append(sValues[iCount]);
                    }
                    sbParameters.append(")");
                }
            }
            sbParameters.append("]");
        }
        
        if(loMeLogger.isDebugEnabled()){
            loMeLogger.debug("["+userSabun+"]"+sbParameters);
        }

        //CHECK PERMITION SERVICE.METHOD.
        isPermittedURL = chekPermision(request);
        
        //CHECK PERMITION URL.
        sRequestURI = request.getRequestURI(); // 요청 URI
        if(!isPermittedURL){
            if (this.seMePermittedURL == null)
                return true;

            sContextPath = request.getContextPath();
            it = this.seMePermittedURL.iterator();
            while (it.hasNext() == true) {
                sUrlPattern = sContextPath + (String) it.next();
                if (Pattern.matches(sUrlPattern, sRequestURI) == true) { // 정규표현식을 이용해서 요청 URI가 허용된 URL에 맞는지 점검함.
                    isPermittedURL = true;
                    break;
                }
            }            
        }

        // 세션만료 또는 허용되지 않는 URL이면 로그인 페이지로 이동
       
        if (isPermittedURL == false && EgovUserDetailsHelper.isAuthenticated(request)==false) 
        {
        	//System.out.println("permittedURL : " + isPermittedURL);
        	//System.out.println("is Authenticatted : " + EgovUserDetailsHelper.isAuthenticated(request));
        	/* 세션 만료 시 해당 메뉴가 아닌 전체 화면에서 재 로그인 하도록 수정 (2017.04.25) */
//        	 System.out.println("===================================세션테스트1::"+this.seMePermittedMethod+"::"+isPermittedURL+"::"+EgovUserDetailsHelper.isAuthenticated(request)+"::"+sRequestURI);
        	HttpUtil.sendScript(response, "if(typeof(goLoginPage)=='function'){window.opener.location.href='" + Constant.ROOT_PATH + "/common/LoginF.do?IsSessionValid=N';;}else{top.location.href='" + Constant.ROOT_PATH + "/common/LoginF.do?IsSessionValid=N';}");
            return false;
        	            
            /*if(HttpUtil.isAjax(request)){
            	
            	//HttpUtil.sendScript(response, "if(typeof(goLoginPage)=='function'){goLoginPage();}else{top.location.href='" + Constant.ROOT_PATH + "/common/LoginF.do?IsSessionValid=N';}");
            	HttpUtil.sendScript(response, "if(typeof(goLoginPage)=='function'){window.opener.location.href='" + Constant.ROOT_PATH + "/common/LoginF.do?IsSessionValid=N';;}else{top.location.href='" + Constant.ROOT_PATH + "/common/LoginF.do?IsSessionValid=N';}");
                return false;
            }else{
            	
                moView = new ModelAndView("redirect:/common/LoginF.do?IsSessionValid=N");
                throw new ModelAndViewDefiningException(moView);                
            }*/
        }

        // 강제로그아웃 체크
        if (sessionMAP != null && !isPermittedURL) {
            String userId = (String) sessionMAP.get("agentId");

            ArgoDispatchServiceVo argoDispatchServiceVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
            argoDispatchServiceVo.setSvcName("ARGOCOMMON");
            //argoDispatchServiceVo.setMethodName("getIntroRecentList");
            argoDispatchServiceVo.getReqInput().put("logoutTenantId", Objects.requireNonNull(sessionMAP).get("tenantId"));
            argoDispatchServiceVo.getReqInput().put("logoutAgentId", userId);
            String logoutKind = argoDispatchServiceImpl.selectLogOutCheck(argoDispatchServiceVo);
            if ("0".equals(logoutKind)) { // 강제로그아웃
                EgovMultiLoginPreventor.invalidateByLoginId(userId);

                request.getRequestDispatcher("/argoLogOut.do").forward(request, response);
            }
        }

        // 권한체크
        String methodName = request.getParameter("APMKEY");
        if (sessionMAP != null
                && request.getParameter("SVCCOMMONID.grantId") != null
                && !methodName.equals("ARGOCOMMON.LOGIN")
                && !sessionMAP.get("grantId").equals(request.getParameter("SVCCOMMONID.grantId")))
        {
            response.setContentType("text/html; charset=UTF-8");

            PrintWriter out = response.getWriter();
            out.println("<script>argoAlert('잘못된 접근입니다.'); </script>");
            out.flush();
            out.close();

            return false;
        }

        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView model) throws Exception { //view요청전
        
//        String sProgramNo;
//        List<MenuVO> menuList;
//        LoginSessionVO sessionVO = null;
//        ServletContext servletContext;
//        boolean isWrite, isRead;
//        int iSize;
         if (model == null) 
            return;
        
		response.setHeader("Cache-Control", "no-store");
		response.setHeader("Pragma", "no-cache");
		response.setDateHeader("Expires", 0);

		if (request.getProtocol().equals("HTTP/1.1")) {
			response.setHeader("Cache-Control", "no-cache");
			response.setHeader("Pragma", "no-cache");
			response.setDateHeader("Expires", 0);
		}

        //model.addObject("hostAddress", SocketUtil.getHostIp());
        
/*        sessionVO = (LoginSessionVO) EgovUserDetailsHelper.getAuthenticatedUser(request);
        if(sessionVO==null){
            sessionVO = new LoginSessionVO();
        }
        //sessionVO.setSessionParam("test","1234");
        EgovSessionCookieUtil.setSessionAttribute(request, "sessionVO", sessionVO);*/
        
     
        
/*
        model.addObject("rootPath", Global.getRootPath());
        model.addObject("fileUploadExtentions", Global.getFileUploadExtentions());
        model.addObject("fileUploadLimitSize", Global.getFileUploadLimitSize());
        model.addObject("pageSize", Global.getPageSize());

        sProgramNo = Global.getProgramNo(request);
        
        if (sProgramNo.equals("") == false) {
            
            menuList = Global.selProgramPathList(request, sProgramNo);

            if (menuList != null && (iSize = menuList.size()) > 0)
                model.addObject("programName", menuList.get(iSize - 1).getMenuName());
            else
                model.addObject("programName", null);

            model.addObject("programPathList", menuList);

            // 프로그램 사용자 권한
            sessionVO = (LoginSessionVO) EgovUserDetailsHelper.getAuthenticatedUser(request);
            servletContext = request.getSession().getServletContext();

            isWrite = sessionVO.getIsWrite(servletContext, sProgramNo);
            isRead = sessionVO.getIsRead(servletContext, sProgramNo);

            model.addObject("isWrite", isWrite);
            model.addObject("isRead", isRead);

            if (isWrite == true || isRead == true)
                model.addObject("isPopupEnable", true);
            else
                model.addObject("isPopupEnable", false);

            if (isWrite == true)
                model.addObject("isPopupWrite", true);
            else
                model.addObject("isPopupWrite", false);
            // 프로그램 사용자 권한
        }
*/
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }

    //dispatcher-servlet.xml의 permittedURL 항목
    public void setPermittedURL(Set<String> permittedURL) {
        this.seMePermittedURL = permittedURL;
    }
    
    //dispatcher-servlet.xml의 permittedMethod 항목
    public void setPermittedMethod(Set<String> permittedMethod){
        this.seMePermittedMethod = permittedMethod;
    }

    //dispatcher-servlet.xml의 permittedMethod 항목과 비교하여 로그인을 체크여부를 결정함.
	private Boolean chekPermision(HttpServletRequest request) {
        String compareStr;
        String svcIds = request.getParameter(Constant.SVC_PARAM_SVCIDS);
        
        if(EgovStringUtil.isNotEmpty(svcIds)) {
            String[] svcIdArr = EgovStringUtil.getStringArray(svcIds, ",");
            for (int i = 0; i < svcIdArr.length; i++) {
                if(EgovStringUtil.isEmpty(svcIdArr[i]) == false) {
                    Iterator<String> it = this.seMePermittedMethod.iterator();
                    while (it.hasNext() == true) {
                    	compareStr = (String)it.next();
                    	
                    	String reqSvcName = request.getParameter(Constant.STR_UNDERLINE + svcIdArr[i] + Constant.SVC_POSTFIX_NAME) == null ? "" : request.getParameter(Constant.STR_UNDERLINE + svcIdArr[i] + Constant.SVC_POSTFIX_NAME);
                    	String reqMethodName = request.getParameter(Constant.STR_UNDERLINE + svcIdArr[i] + Constant.SVC_POSTFIX_METHOD_NAME) == null ? "" : request.getParameter(Constant.STR_UNDERLINE + svcIdArr[i] + Constant.SVC_POSTFIX_METHOD_NAME);
                    	
                		if( (reqSvcName.equals(compareStr.split("\\.")[0]) 
                				&&  reqMethodName.equals(compareStr.split("\\.")[1])) 
                				|| reqSvcName.equals(Constant.STR_METHOD_MNG)){
//                        	 System.out.println("세션테스트:::::::"+compareStr);
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }
}