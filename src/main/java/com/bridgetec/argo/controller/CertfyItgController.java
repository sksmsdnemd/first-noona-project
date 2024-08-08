package com.bridgetec.argo.controller;

import com.bridgetec.argo.batch.work.WorkLogic;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.service.LoginServiceImpl;
import com.bridgetec.argo.service.UserServiceImpl;
import com.itg.ItgCrtfy;
import com.itg.exception.ItgCrtfyException;
import com.itg.vo.ItgUserInfoVo;
import egovframework.com.cmm.EgovMessageSource;
import egovframework.com.cmm.service.EgovProperties;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 *
 */
@Controller
public class CertfyItgController {
    private final Logger log = LoggerFactory.getLogger(UserController.class);

    private Logger loMeLogger = LoggerFactory.getLogger(CertfyItgController.class);
    
    @Autowired
    private UserServiceImpl userService;

	@Autowired
	private LoginServiceImpl loginService;

    @Resource(name = "egovMessageSource")
    EgovMessageSource egovMessageSource;

    
    /**
     * ITG 인증테스트
	 *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws ItgCrtfyException  예외
     */
    @RequestMapping(value="/api/itg/crtfy.do", method= RequestMethod.GET)
    public ModelAndView crtfyItgLogin(HttpServletRequest request, HttpServletResponse response
    		//, @RequestParam String crtfyKey
    		) throws UnsupportedEncodingException {
        ModelAndView mv = new ModelAndView();

		try {
//			if (!StringUtils.hasText(crtfyKey)) {
//				throw new MessageException("fail.acc.login"); //"잘못된 접근입니다"
//			}

			//통합로그인 인증키를 통해 사용자ID 요청
			// TODO : TEST 후 주석 헤제
//			ItgCrtfy itgCrtfy = new ItgCrtfy();
//			String itgUrl = EgovProperties.getProperty("Globals.ITG.URL"); //통합로그인 호출 url
//			ItgUserInfoVo userInfo = itgCrtfy.getCrtfyUser(itgUrl, crtfyKey);

			// TODO : TEST 후 삭제
			ItgUserInfoVo userInfo = new ItgUserInfoVo();
			userInfo.setUserId("btagent");
			userInfo.setPwd("$2a$10$NO5dkNMsjRlo5m3ro5F5Eu1EG6rZu5tEwi4yQ3Qqh5/HOnIFctooW");	// salt : 9yR4SWSx6Qs=

			// 로그인 사용자정보 조회
			EgovMap loginMap = loginService.getLoginInfo(userInfo.getUserId());
			if (loginMap == null) {
				throw new MessageException("fail.user.not.found");// '사용자 정보가 없습니다.'
			}
			String tenantId = (String) loginMap.get("tenantId");

			// 사용자 패스워드 Update
			int result = userService.setUserPassword(tenantId, userInfo.getUserId(), userInfo.getPwd());
			if (result < 1) {
				throw new MessageException("fail.user.password.update"); // '사용자 비밀번호 변경 실패' , 재시도?
			}

			// 사용자 로그인 처리
			mv.addObject("ssoTenant", tenantId);
			mv.addObject("ssoUserId", userInfo.getUserId());
			loginService.login((String) loginMap.get("tenantId"), userInfo.getUserId(), null, request, response);

			// 메인페이지 이동
			mv.setViewName("redirect:/external/EMainF.do");
		}
		catch (MessageException e) {
			mv.addObject("resultMsg", URLEncoder.encode(egovMessageSource.getMessage(e.getArgoCode(), e.getArguments()), StandardCharsets.UTF_8.toString()).replace("+", "%20"));
			mv.setViewName("redirect:/common/LoginF.do");
		}
		catch (Exception e) {
			e.printStackTrace();
			//throw new ItgCrtfyException("EFW.ERROR.0005", e.getMessage()); // 오류페이지 이동
			mv.addObject("resultMsg", e.getMessage());
			mv.setViewName("redirect:/common/LoginF.do");
		}

        return mv;
    }
    

    /**
     * ITG 인증
	 *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws ItgCrtfyException  예외
     */
//    @RequestMapping(value="/api/itg/crtfy.do", method= RequestMethod.GET)
//    public ModelAndView crtfyItgLogin(HttpServletRequest request, HttpServletResponse response, @RequestParam String crtfyKey) throws UnsupportedEncodingException {
//        ModelAndView mv = new ModelAndView();
//
//		try {
//			if (!StringUtils.hasText(crtfyKey)) {
//				throw new MessageException("fail.acc.login"); //"잘못된 접근입니다"
//			}
//
//			//통합로그인 인증키를 통해 사용자ID 요청
//			// TODO : TEST 후 주석 헤제
//			ItgCrtfy itgCrtfy = new ItgCrtfy();
//			String itgUrl = EgovProperties.getProperty("Globals.ITG.URL"); //통합로그인 호출 url
//			ItgUserInfoVo userInfo = itgCrtfy.getCrtfyUser(itgUrl, crtfyKey);
//
//			// TODO : TEST 후 삭제
////			ItgUserInfoVo userInfo = new ItgUserInfoVo();
////			userInfo.setUserId("teskim");
////			userInfo.setPwd("$2a$10$NO5dkNMsjRlo5m3ro5F5Eu1EG6rZu5tEwi4yQ3Qqh5/HOnIFctooW");	// salt : 9yR4SWSx6Qs=
//
//			// 로그인 사용자정보 조회
//			EgovMap loginMap = loginService.getLoginInfo(userInfo.getUserId());
//			if (loginMap == null) {
//				throw new MessageException("fail.user.not.found");// '사용자 정보가 없습니다.'
//			}
//			String tenantId = (String) loginMap.get("tenantId");
//
//			// 사용자 패스워드 Update
//			int result = userService.setUserPassword(tenantId, userInfo.getUserId(), userInfo.getPwd());
//			if (result < 1) {
//				throw new MessageException("fail.user.password.update"); // '사용자 비밀번호 변경 실패' , 재시도?
//			}
//
//			// 사용자 로그인 처리
//			mv.addObject("ssoTenant", tenantId);
//			mv.addObject("ssoUserId", userInfo.getUserId());
//			loginService.login((String) loginMap.get("tenantId"), userInfo.getUserId(), null, request, response);
//
//			// 메인페이지 이동
//			mv.setViewName("redirect:/external/EMainF.do");
//		}
//		catch (MessageException e) {
//			mv.addObject("resultMsg", URLEncoder.encode(egovMessageSource.getMessage(e.getArgoCode(), e.getArguments()), StandardCharsets.UTF_8.toString()).replace("+", "%20"));
//			mv.setViewName("redirect:/common/LoginF.do");
//		}
//		catch (Exception e) {
//			e.printStackTrace();
//			//throw new ItgCrtfyException("EFW.ERROR.0005", e.getMessage()); // 오류페이지 이동
//			mv.addObject("resultMsg", e.getMessage());
//			mv.setViewName("redirect:/common/LoginF.do");
//		}
//
//        return mv;
//    }
    
    @RequestMapping(value="/api/ext/crtfy.do", method= RequestMethod.GET)
    public ModelAndView crtfyExtLogin(HttpServletRequest request, HttpServletResponse response
    		//, @RequestParam String userId
    		) throws Exception {
    	ModelAndView mv = new ModelAndView();
    	loMeLogger.debug("url : /api/ext/crtfy.do" );
		try {
			
//			loMeLogger.debug("param userId : " + userId);
//			// TODO: TEST 후 주석 해제
//			String referer = request.getHeader("referer");
//			
//			// TODO: TEST 후 삭제
//			//String referer = "phbday2.shinhan.com";
//			
//			if(null == referer){
//				referer = request.getHeader("Referer");
//				//	referer = "phbday2.shinhan.com";
//			}
//			
//			if(null == referer){
//				loMeLogger.debug("referer : null");
//				//	referer = "phbday2.shinhan.com";
//			}
//			
//			loMeLogger.debug("referer : " + referer);
//			String solUrl = EgovProperties.getProperty("Globals.SOL.URL"); //쏠로몬 request url
//			loMeLogger.debug("solUrl : " + solUrl);
//			
//			//쏠로몬 요청 여부 확인
////			if (!StringUtils.hasText(referer) || !referer.equals(solUrl)) {
////				loMeLogger.debug("solUrlRequestFail!!!! referer : " + referer + "  ,solUrl : " + solUrl );
////				throw new MessageException("fail.acc.login");
////			}
//			
//			//쏠로몬 요청 여부 확인
//			if(!referer.contains(solUrl)) {
//				loMeLogger.debug("solUrlRequestFail!!!! referer : " + referer + "  ,solUrl : " + solUrl );
//				throw new MessageException("fail.acc.login");
//			}
			
			String userId = "btagent";

			// 로그인 사용자정보 조회
			EgovMap loginMap = loginService.getLoginInfo(userId);
			
			loMeLogger.debug("loginMap Success : " + loginMap.toString());
			if (loginMap == null) {
				loMeLogger.debug("사용자정보가 없습니다.");
				throw new MessageException("fail.user.not.found"); // '사용자 정보가 없습니다.'
			}
			String tenantId = (String) loginMap.get("tenantId");
			loMeLogger.debug("tenantId : " + tenantId);
			
			// 사용자 로그인 처리
			mv.addObject("ssoTenant", tenantId);
			loMeLogger.debug("ssoTenant : " + tenantId);
			mv.addObject("ssoUserId", userId);
			loMeLogger.debug("ssoUserId : " + userId);
			loginService.login((String) loginMap.get("tenantId"), userId, null, request, response);
			loMeLogger.debug("loginService.login Success!!!");
			
			// 메인페이지 이동
			mv.setViewName("redirect:/external/EMainF.do");
			
			
		}
		catch (MessageException e) {
			loMeLogger.error("MessageException : " + e.getMeessage());
			
			mv.addObject("resultMsg", URLEncoder.encode(egovMessageSource.getMessage(e.getArgoCode(), e.getArguments()), StandardCharsets.UTF_8.toString()).replace("+", "%20"));
			mv.setViewName("redirect:/common/LoginF.do");
		}
		catch (Exception e) {
			loMeLogger.error("MessageException : " +  e.getMessage());
			e.printStackTrace();
			mv.addObject("resultMsg", e.getMessage());
			mv.setViewName("redirect:/common/LoginF.do");
		}

    	return mv;
    }
    
    
//    @RequestMapping(value="/api/ext/crtfy.do", method= RequestMethod.GET)
//    public ModelAndView crtfyExtLogin(HttpServletRequest request, HttpServletResponse response, @RequestParam String userId) throws Exception {
//    	ModelAndView mv = new ModelAndView();
//    	loMeLogger.debug("url : /api/ext/crtfy.do" );
//		try {
//			
//			loMeLogger.debug("param userId : " + userId);
//			// TODO: TEST 후 주석 해제
//			String referer = request.getHeader("referer");
//			
//			// TODO: TEST 후 삭제
//			//String referer = "phbday2.shinhan.com";
//			
//			if(null == referer){
//				referer = request.getHeader("Referer");
//				//	referer = "phbday2.shinhan.com";
//			}
//			
//			if(null == referer){
//				loMeLogger.debug("referer : null");
//				//	referer = "phbday2.shinhan.com";
//			}
//			
//			loMeLogger.debug("referer : " + referer);
//			String solUrl = EgovProperties.getProperty("Globals.SOL.URL"); //쏠로몬 request url
//			loMeLogger.debug("solUrl : " + solUrl);
//			
//			//쏠로몬 요청 여부 확인
////			if (!StringUtils.hasText(referer) || !referer.equals(solUrl)) {
////				loMeLogger.debug("solUrlRequestFail!!!! referer : " + referer + "  ,solUrl : " + solUrl );
////				throw new MessageException("fail.acc.login");
////			}
//			
//			//쏠로몬 요청 여부 확인
//			if(!referer.contains(solUrl)) {
//				loMeLogger.debug("solUrlRequestFail!!!! referer : " + referer + "  ,solUrl : " + solUrl );
//				throw new MessageException("fail.acc.login");
//			}
//			
//
//			// 로그인 사용자정보 조회
//			EgovMap loginMap = loginService.getLoginInfo(userId);
//			
//			loMeLogger.debug("loginMap Success : " + loginMap.toString());
//			if (loginMap == null) {
//				loMeLogger.debug("사용자정보가 없습니다.");
//				throw new MessageException("fail.user.not.found"); // '사용자 정보가 없습니다.'
//			}
//			String tenantId = (String) loginMap.get("tenantId");
//			loMeLogger.debug("tenantId : " + tenantId);
//			
//			// 사용자 로그인 처리
//			mv.addObject("ssoTenant", tenantId);
//			loMeLogger.debug("ssoTenant : " + tenantId);
//			mv.addObject("ssoUserId", userId);
//			loMeLogger.debug("ssoUserId : " + userId);
//			loginService.login((String) loginMap.get("tenantId"), userId, null, request, response);
//			loMeLogger.debug("loginService.login Success!!!");
//			
//			// 메인페이지 이동
//			mv.setViewName("redirect:/external/EMainF.do");
//			
//			
//		}
//		catch (MessageException e) {
//			loMeLogger.error("MessageException : " + e.getMeessage());
//			
//			mv.addObject("resultMsg", URLEncoder.encode(egovMessageSource.getMessage(e.getArgoCode(), e.getArguments()), StandardCharsets.UTF_8.toString()).replace("+", "%20"));
//			mv.setViewName("redirect:/common/LoginF.do");
//		}
//		catch (Exception e) {
//			loMeLogger.error("MessageException : " +  e.getMessage());
//			e.printStackTrace();
//			mv.addObject("resultMsg", e.getMessage());
//			mv.setViewName("redirect:/common/LoginF.do");
//		}
//
//    	return mv;
//    }
    
}
