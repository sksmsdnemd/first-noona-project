package com.bridgetec.common;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.service.LoginServiceImpl;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.springframework.stereotype.Component;
import org.springframework.web.context.ContextLoader;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

@Component
public class EventSessionListener implements HttpSessionListener {


	public void sessionCreated(HttpSessionEvent se) {
		HttpSession session = se.getSession();
		System.out.println(">>>>> Create session : " + session.getId());
	}

	/**
	 * invaild, setMaxInactiveInterval
	 *
	 * @param se the notification event
	 */
	public void sessionDestroyed(HttpSessionEvent se) {
		HttpSession session = se.getSession();
		System.out.println(">>>>> Close session : " + session.getId());

		if (session.getAttribute(Constant.SESSION_ATTR_LOGIN) != null) {
			try {
				EgovMap sm = (EgovMap) session.getAttribute(Constant.SESSION_ATTR_LOGIN);
				((LoginServiceImpl) ContextLoader.getCurrentWebApplicationContext().getBean("loginService")).logout((String) sm.get("tenantId"), (String) sm.get("userId"));
			}
			catch (Exception e) {
				throw new RuntimeException(e);
			}
		}
	}
}
