package com.bridgetec.argo.controller;

import com.bridgetec.argo.common.ConfigLoader;
import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.service.UserServiceImpl;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.bridgetec.common.util.security.RSAUtil;
import com.itg.crypto.ItgCryptPassword;
import egovframework.com.cmm.EgovMessageSource;
import egovframework.com.utl.cas.service.EgovSessionCookieUtil;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;


/**
 *
 */
@Controller
public class UserController {
    private final Logger log = LoggerFactory.getLogger(UserController.class);

    private ConfigLoader configLoader;

    @Autowired
    private UserServiceImpl userService;

    @Resource(name = "egovMessageSource")
    EgovMessageSource egovMessageSource;

    /**
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param param parameter
     * @throws Exception Exception
     */
    @RequestMapping(value="/ARGO/USERCONTROL.do" , method= RequestMethod.POST)
    public void postUserControl(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        try {
            log.info("[ param : " + param.toString() + " ]");

            // loginIp or workIp 값이 없을경우 요청자 IP로 셋팅
            String loginIp = ArgoCtrlHelper.getClientIpAddr(request);
            param.put("loginIp", loginIp);
            if("".equals(param.get("workIp")) || param.get("workIp") == null) {
                param.put("workIp", loginIp);
            }
            // loginIp or workIp 값이 없을경우 요청자 IP로 셋팅 - End

            String methodName = param.get("APMKEY");
            log.debug("#### USERCONTROL methodName: "+ methodName);

            // 사용자정보 등록 요청 처리
            if ("userInfo.setUserInfoInsert".toUpperCase().equals(methodName)) {
                this.addUserInfo(request, response, param);
            }
            // 사용자정보 변경 요청 처리, svn 확인
            else if ("userInfo.setUserInfoUpdate".toUpperCase().equals(methodName)) {
                this.setUserInfo(request, response, param);
            }
            // 사용자권한 리스트 저장
            else if ("userAuth.setUserAuthUpsert".toUpperCase().equals(methodName)) {
                this.setUserAuthList(request, response, param);
            }
            // 사용자 비밀번호 초기화
            else if ("userInfo.setUserPswdInit".toUpperCase().equals(methodName)) {
                this.setUserPswdInit(request, response, param);
            }
        }
        catch (MessageException me) {
            StackTraceElement l = me.getStackTrace()[0];

            try {
                String configLogUse = configLoader.get("AppConfig.SystemLogMonitorViewUse");
                if (configLogUse.trim().equals("true")) {
                    resultMap.put(Constant.RESULT_SUB_MSG, me.getSubMessage() + "\n" + l.getClassName() + "."
                            + l.getMethodName() + " (line:" + l.getLineNumber() + ")");
                }
                else {
                    resultMap.put(Constant.RESULT_SUB_MSG, "");
                }
            }
            catch (Exception e) {
                log.error("Exception : " + e.toString());
            }

            resultMap.put(Constant.RESULT_CODE, me.getArgoCode());
            resultMap.put(Constant.RESULT_MSG, egovMessageSource.getMessage(me.getArgoCode()));
            resultMap.put(Constant.RESULT_SUB_CODE, me.getSubCode());

            ArgoCtrlHelper.print(response, resultMap);
        }

        log.info("# end ================================================ ");
    }


    /**
     * 사용자정보 등록 요청 처리
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param param 파라미터
     * @throws Exception 예외
     */
    private void addUserInfo(HttpServletRequest request, HttpServletResponse response, Map<String, String> param) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        // 비밀번호 RSA 복호화
        String decryptPassword = RSAUtil.decrypt(request, param.get("SVCCOMMONID.UserPwd"), false) ;
        param.put("SVCCOMMONID.UserPwd", decryptPassword);

        // 비밀번호 유효성체크
        String userId = param.get("SVCCOMMONID.UserId");
        if (decryptPassword != null && !decryptPassword.equals("")) {
            ArgoCtrlHelper.validatePassword(userId, decryptPassword);
        }

        // 사용자정보 등록
        List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(param, request);
        ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
        userService.addUserInfo(argoServiceVO.getReqInput());

        // response
        ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
        ArgoCtrlHelper.print(response, resultMap);
    }


    /**
     * 사용자정보 변경 요청 처리
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param requestParam 요청 파라미터
     * @throws Exception 예외
     */
    private void setUserInfo(HttpServletRequest request, HttpServletResponse response, Map<String, String> requestParam) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        EgovMap sessionMap = (EgovMap) EgovSessionCookieUtil.getSessionAttribute(request, Constant.SESSION_ATTR_LOGIN);

        // parameter to vo
        List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(requestParam, request);
        ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
        Map<String, Object> param = argoServiceVO.getReqInput();

        // "권한이 없습니다."
        int authRank = Integer.parseInt(Objects.toString(sessionMap.get("authRank"), "99"));
        if (authRank > 3) { // Manager authRank
            throw new MessageException("error.not.have.permission");
        }

        // "변경 할 수 없는 권한입니다."
        @SuppressWarnings("unchecked")
        List<EgovMap> authLowList = userService.getAuthLowRankList(Objects.toString(sessionMap.get("tenantId")), authRank);
        boolean isAuth = false;
        for (EgovMap map : authLowList) {
            if (Objects.toString(param.get("grantId"), "").equals(map.get("grantId"))) {
                isAuth = true;
                break;
            }
        }
        if (!isAuth) {
            throw new MessageException("error.invalid.grant");
        }

        // 비밀번호 체크
        if (StringUtils.hasText(Objects.toString(param.get("userPwd")))) {
            // 비밀번호 RSA 복호화
            String decryptPassword = RSAUtil.decrypt(request, Objects.toString(param.get("userPwd"), ""), false);
            param.put("userPwd", decryptPassword);

            // 비밀번호 유효성체크
            String userId = Objects.toString(param.get("userId"));
            if (decryptPassword != null && !decryptPassword.equals("")) {
                ArgoCtrlHelper.validatePassword(userId, decryptPassword);
            }
        }

        // 사용자정보 변경
        userService.setUserInfo(argoServiceVO.getReqInput());

        // response
        ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
        ArgoCtrlHelper.print(response, resultMap);
    }

    /**
     * 사용자 권한 리스트 변경 요청 처리
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param param 파라미터
     * @throws Exception 예외
     */
    private void setUserAuthList(HttpServletRequest request, HttpServletResponse response, Map<String, String> param) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        EgovMap sessionMap = (EgovMap) EgovSessionCookieUtil.getSessionAttribute(request, Constant.SESSION_ATTR_LOGIN);

        // parameter to vo
        List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(param, request);
        ArgoDispatchServiceVo argoServiceVO = svcList.get(0);

        // "권한이 없습니다."
        int authRank = Integer.parseInt(Objects.toString(sessionMap.get("authRank"), "99"));
        if (authRank > 3) { // Manager authRank
            throw new MessageException("error.not.have.permission");
        }

        // 사용자권한 리스트 변경
        argoServiceVO.setProCnt(userService.saveUserAuthList(argoServiceVO.getReqInput()));

        // response
        ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
        ArgoCtrlHelper.print(response, resultMap);
    }

    /**
     * 사용자 비밀번호 초기화 요청 처리
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param requestParam 파라미터
     * @throws Exception 예외
     */
    private void setUserPswdInit(HttpServletRequest request, HttpServletResponse response, Map<String, String> requestParam) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();
        EgovMap sessionMap = (EgovMap) EgovSessionCookieUtil.getSessionAttribute(request, Constant.SESSION_ATTR_LOGIN);

        // parameter to vo
        List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(requestParam, request);
        ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
        Map<String, Object> param = argoServiceVO.getReqInput();

        // "권한이 없습니다."
        String ssGrantId = Objects.toString(sessionMap.get("grantId"));
        if (!"SuperAdmin".equals(ssGrantId)) { // Manager authRank
            throw new MessageException("error.not.have.permission");
        }

        // 사용자 패스워드 Update
        ItgCryptPassword itgCryptPassword = new ItgCryptPassword();
        String pswd = itgCryptPassword.encode("1");
        int result = userService.setUserPassword(Objects.toString(param.get("tenantId")), Objects.toString(param.get("userId")), pswd);
        if (result < 1) {
            throw new  MessageException("fail.user.password.update"); // '사용자 비밀번호 변경 실패' , 재시도?
        }

        // response
        ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
        ArgoCtrlHelper.print(response, resultMap);
    }
}
