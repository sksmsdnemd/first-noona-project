package com.bridgetec.argo.service;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.dao.ArgoDispatchDAO;
import egovframework.com.utl.cas.service.EgovSessionCookieUtil;
import egovframework.rte.fdl.cmmn.AbstractServiceImpl;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@Service("actionLogService")
public class ActionLogServiceImpl extends AbstractServiceImpl {
    private final Logger log = LoggerFactory.getLogger(LoginServiceImpl.class);
    
	@Resource(name = "ARGODB")
    private ArgoDispatchDAO argoDao;


    /**
     * action log
     *
     * @param tenantId 태넌트 ID
     * @param userId 사용자 ID
     * @param actionClass action class
     * @param actionCode action code
     * @param workIp ip
     * @param workMenu work/menu
     * @param workLog log
     * @return update count
     */
    public int log(String tenantId, String userId, String actionClass, String actionCode, String workIp, String workMenu, String workLog) {
        Map<String, Object> param = new HashMap<>();
        param.put("tenantId"    , tenantId);
        param.put("userId"      , userId);
        param.put("actionClass" , actionClass);
        param.put("actionCode"  , actionCode);
        param.put("workIp"      , workIp);
        param.put("workMenu"    , workMenu);
        param.put("workLog"     , workLog);

        log.debug("action log: {}", workLog);
        return argoDao.update("actionLog.setActionLogInsert", param);
    }

    /**
     * action log
     *
     * @param workMenu work/menu
     * @param workLog log
     * @return update count
     * @throws Exception 예외
     */
    public int log(String workMenu, String workLog) throws Exception {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
        EgovMap sessionMAP = (EgovMap) EgovSessionCookieUtil.getSessionAttribute(request, Constant.SESSION_ATTR_LOGIN);

        return this.log((String) sessionMAP.get("tenantId"), (String) sessionMAP.get("userId"), "action_class", "W", request.getRemoteAddr(), workMenu, workLog);
    }
}
