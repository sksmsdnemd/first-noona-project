package egovframework.com.cmm.util;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.bridgetec.argo.common.Constant;
import egovframework.com.utl.cas.service.EgovSessionCookieUtil;
import egovframework.rte.fdl.string.EgovObjectUtil;

/**
 * EgovUserDetails Helper 클래스
 * 
 * @author sjyoon
 * @since 2009.06.01
 * @version 1.0
 * @see
 *
 * <pre>
 * << 개정이력(Modification Information) >>
 *   
 *   수정일      수정자           수정내용
 *  -------    -------------    ----------------------
 *   2009.03.10  sjyoon         최초 생성
 *   2011.07.01	 서준식          interface 생성후 상세 로직의 분리
 * </pre>
 */

public class EgovUserDetailsHelper {
	/**
	 * 인증된 사용자객체를 VO형식으로 가져온다.
	 * @return Object - 사용자 ValueObject
	 */
	public static Object getAuthenticatedUser(HttpServletRequest request) throws Exception {
		return EgovSessionCookieUtil.getSessionAttribute(request, Constant.SESSION_ATTR_LOGIN);
	}
	
	/**
	 * 인증된 사용자객체를 VO형식으로 가져온다.
	 * @return Object - 사용자 ValueObject
	 */
//	public static Integer getCurrentUserId(HttpServletRequest request) throws Exception {
//		LoginSessionVO userMaster = (LoginSessionVO)EgovSessionCookieUtil.getSessionAttribute(request, "sessionVO");
//		if(userMaster != null){
//			return userMaster.getUserId();
//		}
//		return null;
//	}
	
	/**
	 * 인증된 사용자객체를 VO형식으로 가져온다.
	 * @return Object - 사용자 ValueObject
	 */
//	public static String getCurrentUserSabun(HttpServletRequest request) throws Exception {
//		LoginSessionVO userMaster = (LoginSessionVO)EgovSessionCookieUtil.getSessionAttribute(request, "sessionVO");
//		if(userMaster != null){
//			return userMaster.getUserSabun();
//		}
//		return "";
//	}
	
	/**
	 * 인증된 사용자객체를 VO형식으로 가져온다.
	 * @return Object - 사용자 ValueObject
	 */
//	public static String getCurrentUserPW(HttpServletRequest request) throws Exception {
//		LoginSessionVO userMaster = (LoginSessionVO)EgovSessionCookieUtil.getSessionAttribute(request, "sessionVO");
//		if(userMaster != null){
//			return userMaster.getPlainPw();
//		}
//		return "";
//	}
	
	/**
	 * 인증된 사용자 여부를 체크한다.
	 * @return Boolean - 인증된 사용자 여부(TRUE / FALSE)	
	 */
	public static Boolean isAuthenticated(HttpServletRequest request) throws Exception {
		return Boolean.valueOf(!EgovObjectUtil.isNull(getAuthenticatedUser(request)));
	}

	/**
	 * 세션 삭제
	 * @param request
	 * @throws Exception
	 */
	public static void invalidateSession(HttpServletRequest request) throws Exception{
		HttpSession session = request.getSession();
		if( session != null ){
			session.invalidate();
		}
	}
}
