/*
 * Copyright 2008-2009 MOPAS(MINISTRY OF SECURITY AND PUBLIC ADMINISTRATION).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.bridgetec.common;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.util.PatternMatchUtils;

/**
*
* SessionTimeoutCookieFilter 
* @author 공통컴포넌트 팀 신용호
* @since 2020.06.17
* @version 1.0
* @see
*
* <pre>
* << 개정이력(Modification Information) >>
*
*  수정일               수정자           수정내용
*  ----------   --------   ---------------------------
*  2020.06.17   신용호            최초 생성
*
*/

public class UrlCheckFilter implements Filter{

	@SuppressWarnings("unused")
	private FilterConfig config;
	
	// 접속 제한 URL list
	private static final String[] unAuthList = {"*/dynamicColumns.rptdesign", "*/CFG/globals.properties*"};

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpServletResponse httpResponse = (HttpServletResponse) response;
		
		String requestURI = httpRequest.getRequestURI();
		
		if (PatternMatchUtils.simpleMatch(unAuthList, requestURI)) {
			httpResponse.sendRedirect(httpRequest.getContextPath()+"/common/error.jsp");
			return;
		}
		
		chain.doFilter(request, response);
	}

	public void init(FilterConfig config) throws ServletException {
		this.config = config;
	}

	public void destroy() {

	}
}
