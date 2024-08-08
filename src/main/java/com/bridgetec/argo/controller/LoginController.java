package com.bridgetec.argo.controller;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.common.util.HttpUtil;
import com.bridgetec.argo.service.LoginServiceImpl;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.bridgetec.common.util.security.RSAUtil;
import egovframework.com.cmm.EgovMessageSource;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 *
 */
@Controller
public class LoginController {
    private final Logger log = LoggerFactory.getLogger(LoginController.class);

    @Autowired
    private LoginServiceImpl loginService;

    @Resource(name = "egovMessageSource")
    EgovMessageSource egovMessageSource;


    /**
     * Login
     * 
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param requestParam RequestParam
     */
    @RequestMapping(value="/ARGO/login.do" , method= RequestMethod.POST)
    public void login(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> requestParam) {
        Map<String, Object> resultMap = new HashMap<>();

        try {
            // parameter 변환
            List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(requestParam, request);
            ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
            Map<String, Object> param = argoServiceVO.getReqInput();    // 파라미터맵
            String tenantId = (String) param.get("tenantId");   // 파라미터 태넌트ID

            // 로그인
            String loginId = (String) param.get("agentId");
            String decryptPassword = RSAUtil.decrypt(request, (String) param.get("agentPw"), false) ; // 비밀번호 RSA 복호화
            EgovMap userMap = loginService.login(tenantId, loginId, decryptPassword, request, response);

            // response
            argoServiceVO.setResOut(userMap);
            ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
            ArgoCtrlHelper.print(response, resultMap);
        }
        catch (MessageException e) {
            e.printStackTrace();

            // response
            resultMap.put(Constant.RESULT_CODE, e.getArgoCode());
            resultMap.put(Constant.RESULT_MSG, egovMessageSource.getMessage(e.getArgoCode(), e.getArguments()));
            resultMap.put(Constant.RESULT_SUB_CODE, e.getSubCode());
            ArgoCtrlHelper.print(response, resultMap);
        }
        catch (Exception e) {
            e.printStackTrace();

            // response
            resultMap.put(Constant.RESULT_MSG, egovMessageSource.getMessage("fail.login"));
            ArgoCtrlHelper.print(response, resultMap);
        }
    }


    /**
     * Logout
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     */
    @RequestMapping("/argoLogOut.do")
    public void argoLogOut(HttpServletRequest request, HttpServletResponse response) {
        HashMap<String, Object> resultMap = new HashMap<>();
        try {
            if (HttpUtil.isAjax(request)) {
                loginService.logout(request);

                resultMap.put(Constant.RESULT_CODE, Constant.RESULT_CODE_OK); // 0000
            }
            else {
                resultMap.put(Constant.RESULT_CODE, Constant.RESULT_CODE_ERR_RETURN); // 0102
            }
        }
        catch (MessageException me) {
            resultMap.put(Constant.RESULT_CODE, me.getArgoCode());
            resultMap.put(Constant.RESULT_MSG, me.getArgoMessage(egovMessageSource));
            resultMap.put(Constant.RESULT_SUB_CODE, me.getSubCode());
        }
        catch (Exception e) {
            e.printStackTrace();
            log.error("Exception : " + e.toString());
        }

        // Response  Write
        ArgoCtrlHelper.print(response, resultMap);
    }
}
