package com.bridgetec.argo.controller;

import com.bridgetec.argo.common.ConfigLoader;
import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.service.ArgoDispatchServiceImpl;
import com.bridgetec.argo.service.RecGrantServiceImpl;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import egovframework.com.cmm.EgovMessageSource;
import egovframework.com.utl.cas.service.EgovSessionCookieUtil;
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
public class RecGrantController {
    private final Logger log = LoggerFactory.getLogger(RecGrantController.class);

    private ConfigLoader configLoader;

    @Autowired
    private ArgoDispatchServiceImpl argoDispatchServiceImpl;

    @Autowired
    private RecGrantServiceImpl recGrantService;

    @Resource(name = "egovMessageSource")
    EgovMessageSource egovMessageSource;


    /**
     * 녹취권한 처리
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param param parameter
     * @throws Exception Exception
     */
    @SuppressWarnings("unused")
    @RequestMapping(value="/ARGO/REC/GRANTCONTROL.do" , method= RequestMethod.POST)
    public void postGrantControl(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> param) {
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
            log.debug("#### methodName: "+ methodName);
            List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(param, request);
            // 승인내역 조회
            if ("recGrantAprv.getRecGrantAprv".toUpperCase().equals(methodName)) {
                ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
                recGrantService.getRecGrantAprv(argoServiceVO);

                ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
                ArgoCtrlHelper.print(response, resultMap);
            }
            // 승인 리스트 조회
            else if ("recGrantAprv.getRecGrantAprvList".toUpperCase().equals(methodName)) {
                ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
                recGrantService.getRecGrantAprvList(argoServiceVO);

                ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
                ArgoCtrlHelper.print(response, resultMap);
            }
            // 승인대상자 리스트 조회
            else if ("recGrantAprv.getRecGrantAprvrList".toUpperCase().equals(methodName)) {
                ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
                recGrantService.getRecGrantAprvrList(argoServiceVO);

                ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
                ArgoCtrlHelper.print(response, resultMap);
            }
            // 승인신청 등록
            else if ("recGrantAprv.setRecGrantAprvInsert".toUpperCase().equals(methodName)) {
                ArgoDispatchServiceVo argoServiceVO = svcList.get(0);
                recGrantService.addRecGrantAprvList(argoServiceVO);

                ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
                ArgoCtrlHelper.print(response, resultMap);
            }
            // 승인/반려
            else if ("recGrantAprv.setRecGrantAprvByAprvrUpdate".toUpperCase().equals(methodName)) {
                this.approvalRecGrant(request, response, param);
            }
            // 취소
            else if ("recGrantAprv.setRecGrantAprvDelete".toUpperCase().equals(methodName)) {
                this.cancelAprvReq(request, response, param);
            }

        }
        catch (MessageException me) {
            me.printStackTrace();
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

                log.error("Exception : " + me.toString());
            }
            catch (Exception e) {
                log.error("Exception : " + e.toString());
            }

            resultMap.put(Constant.RESULT_CODE, me.getArgoCode());
            resultMap.put(Constant.RESULT_MSG, me.getArgoMessage(egovMessageSource));
            resultMap.put(Constant.RESULT_SUB_CODE, me.getSubCode());
            ArgoCtrlHelper.print(response, resultMap);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 승인/반려 요청 처리
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param param 파라미터
     * @throws Exception  예외
     */
    private void approvalRecGrant(HttpServletRequest request, HttpServletResponse response, Map<String, String> param) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(param, request);
        ArgoDispatchServiceVo argoServiceVO = svcList.get(0);

        EgovMap session = (EgovMap) EgovSessionCookieUtil.getSessionAttribute(request, Constant.SESSION_ATTR_LOGIN);
        if (session.get("userId") == null || !session.get("userId").equals(argoServiceVO.getReqInput().get("aprvrId"))) {
            throw new MessageException("error.not.have.permission");    // '권한이 없습니다.'
        }
        recGrantService.approvalRecGrant(argoServiceVO);

        // response write
        ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
        ArgoCtrlHelper.print(response, resultMap);
    }

    /**
     * 취소 요청 처리
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @param param 파라미터
     * @throws Exception  예외
     */
    private void cancelAprvReq(HttpServletRequest request, HttpServletResponse response, Map<String, String> param) throws Exception {
        Map<String, Object> resultMap = new HashMap<>();

        List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(param, request);
        ArgoDispatchServiceVo argoServiceVO = svcList.get(0);

        EgovMap session = (EgovMap) EgovSessionCookieUtil.getSessionAttribute(request, Constant.SESSION_ATTR_LOGIN);
        if (session.get("userId") == null || !session.get("userId").equals(argoServiceVO.getReqInput().get("userId"))) {
            throw new MessageException("error.not.have.permission");    // '권한이 없습니다.'
        }
        recGrantService.cancelAprvReq(argoServiceVO);

        // response write
        ArgoCtrlHelper.setResult(resultMap, argoServiceVO, request, response);
        ArgoCtrlHelper.print(response, resultMap);
    }
}
