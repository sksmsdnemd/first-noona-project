package com.bridgetec.argo.service;

import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.controller.ArgoCtrlHelper;
import com.bridgetec.argo.dao.ArgoDispatchDAO;
import com.itg.ItgCrtfy;
import egovframework.com.cmm.util.EgovUserDetailsHelper;
import egovframework.com.utl.cas.service.EgovSessionCookieUtil;
import egovframework.rte.fdl.cmmn.AbstractServiceImpl;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

//@SuppressWarnings("ALL")
@Service("loginService")
public class LoginServiceImpl extends AbstractServiceImpl {
    //private final Logger log = LoggerFactory.getLogger(LoginServiceImpl.class);
    
	@Resource(name = "ARGODB")
    private ArgoDispatchDAO argoDao;

    @Autowired
    private UserServiceImpl userService;

    @Autowired
    private ActionLogServiceImpl actionLogService;


    /**
     * Login
     *
     * @param tenantId 태넌트ID
     * @param loginId 로그인 ID
     * @param loginPassword 로그인 패스워드
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return 로그인 사용자 정보
     * @throws Exception 예외
     */
    public EgovMap login(String tenantId, String loginId, String loginPassword, HttpServletRequest request, HttpServletResponse response) throws Exception {
        /** 로그인 사용자정보 조회 */
        EgovMap userMap = this.getLoginInfo(tenantId, loginId);
        if (userMap == null) {
            throw new MessageException(new Exception(), "error.login.id");   // 'ID 또는 비밀번호가 틀립니다.'
        }

        /** 최초로그인시 통합인증 여부 체크*/
        if (userMap.get("userPwd") == null || ((String) userMap.get("userPwd")).equals("")) {
            throw new MessageException("error.req.itg.login");   // '통합인증 후 로그인 가능합니다.'
        }
        String userPwd = (String) userMap.get("userPwd");

        /** 환경설정정보 조회 - 로그인 IP 체크 여부 */
        EgovMap confMap = userService.getConfigValue("INPUT", "USE_CHECK_LOGIN_IP");    // 환경설정 로그인 아이피 대역 사용여부 조회
        String useLoginIp = String.valueOf(confMap.get("code"));    // 로그인 아이피 대역 사용여부 (1:사용/0:미사용)
        String loginIpChkCnt = "1";
        if (useLoginIp.equals("1")) {
            // IP 대역 체크
            EgovMap loginIpChkMap = userService.getLoginIpCheck(tenantId, ArgoCtrlHelper.getClientIpAddr(request));
            loginIpChkCnt = String.valueOf(loginIpChkMap.get("loginIpChkCnt"));
            if (!"1".equals(loginIpChkCnt)) {
                throw new MessageException(new Exception(), "error.ban.login.ip");  // '제한된 IP대역입니다.<br/>매니저님께 문의부탁드리겠습니다.'
            }
        }
        userMap.put("userIpChk", loginIpChkCnt);

        /** 로그인 실패 횟수 체크 */
        int sitePwdFailCount = userMap.get("sitePwdFailCount") != null ? Integer.parseInt((String) userMap.get("sitePwdFailCount")) : 0;    // 0 : 미사용
        int loginErrCount = userMap.get("loginErrCount") != null ? ((BigDecimal) userMap.get("loginErrCount")).intValue() : null;     // 로그인 실패 횟수
        if (sitePwdFailCount > 0 && loginErrCount >= sitePwdFailCount) {
            throw new MessageException("error.login.fail.count", loginErrCount);  // '비밀번호를 {0}회 틀렸습니다.\n>관리자에게 문의 바랍니다.'
        }

        /** 계정 잠김 여부 체크 */
        int accLockDay = userMap.get("nouseAccLock") != null ? Integer.parseInt((String) userMap.get("nouseAccLock")) : 0;    // 0 : 미사용
        String lastLoginDate = userMap.get("loginDate") != null ? String.valueOf(userMap.get("lastLoginDate")) : null;
        if (accLockDay > 0 && StringUtils.hasText(lastLoginDate)) {
            // 계정 잠김 기간
            Calendar accLockCal = Calendar.getInstance();
            accLockCal.add(Calendar.DATE, - accLockDay);
            // 사용자 로그인
            Calendar loginCal = Calendar.getInstance();
            loginCal.setTime((new SimpleDateFormat("yyyyMMdd")).parse(lastLoginDate));
            if (accLockCal.getTimeInMillis() > loginCal.getTimeInMillis()) {
                throw new MessageException("error.nouse.acc.lock", accLockDay);    // '{0}일 이상 로그인을 하지 않아 접속이 제한됩니다.<br>관리자에게 문의바랍니다.'
            }
        }

        /** 로그인 가능기간 만료 체크 */
        confMap = userService.getConfigValue("INPUT", "USE_CHECK_LOGIN_DATE");  // 환경설정 로그인 가능기간 사용여부 조회
        String useCheckLoginDate = String.valueOf(confMap.get("code")); // 환경설정 로그인 가능기간 사용여부 (1:사용/0:미사용)
        String loginDateCheckUse = userMap.get("loginDateCheckUse") != null ? String.valueOf(userMap.get("loginDateCheckUse")) : null;  // 사용자 로그인 사용기간 사용여부 (1:사용/0:미사용)
        String loginDateCheckFrom = userMap.get("loginDateCheckFrom") != null ? String.valueOf(userMap.get("loginDateCheckFrom")) : null;
        String loginDateCheckTo = userMap.get("loginDateCheckTo") != null ? String.valueOf(userMap.get("loginDateCheckTo")) : null;
        if (StringUtils.hasText(useCheckLoginDate) && useCheckLoginDate.equals("1")
                && StringUtils.hasText(loginDateCheckUse) && loginDateCheckUse.equals("1")
                && StringUtils.hasText(loginDateCheckFrom) && StringUtils.hasText(loginDateCheckTo)
        ) {
            Calendar fromCal = Calendar.getInstance();
            fromCal.setTime((new SimpleDateFormat("yyyyMMddHHmmss")).parse(loginDateCheckFrom +"000000"));
            Calendar toCal = Calendar.getInstance();
            toCal.setTime((new SimpleDateFormat("yyyyMMddHHmmss")).parse(loginDateCheckTo +"235959"));
            Calendar cal = Calendar.getInstance();
            if (fromCal.getTimeInMillis() > cal.getTimeInMillis() || toCal.getTimeInMillis() < cal.getTimeInMillis()) {
                throw new MessageException("error.login.term.expr", (new SimpleDateFormat("yyyy-MM-dd")).format(toCal.getTime()));    // '로그인 가능기간이 만료 되었습니다.<br>[ 만료일 : {0} ]'
            }
        }

        /** 강제 로그아웃 체크 */
        String forcedLogout = userMap.get("forcedLogout") != null ? String.valueOf(userMap.get("forcedLogout")) : null;
        if (StringUtils.hasText(forcedLogout) && forcedLogout.equals("0")) {
            throw new MessageException(new Exception(), "error.forced.logout"); // '관리자에 의해 강제 로그아웃 되었습니다 확인바랍니다.'
        }


        /** 로그인 패스워드와 사용자 패스워드 비교 체크 */
        ItgCrtfy itgCrtfy = new ItgCrtfy();
        if (StringUtils.hasText(loginPassword) && !itgCrtfy.passwordMatches(loginPassword, userPwd)) {  // 평문패스워드 암호화패스워드
            throw new MessageException("error.login.id");   // 'ID 또는 비밀번호가 틀립니다.'
        }

        /** 로그인 사용자정보 Update 및 세션 저장 */
        this.setLoginInfo(tenantId, loginId, request.getSession().getId(), request.getRemoteAddr());
        ArgoCtrlHelper.setSession(request, response, userMap);

        return userMap;
    }

    /**
     * 로그인 사용자 정보 조회
     *
     * @param tenantId 태넌트ID
     * @param userId 로그인 사용자 ID
     * @return 사용자 정보
     */
    public EgovMap getLoginInfo(String tenantId, String userId) {
        Map<String, Object> param = new HashMap<>();
        param.put("tenantId"   , tenantId);
        param.put("agentId"    , userId);

        Object obj = argoDao.selectByPk("ARGOCOMMON.login", param);
        return obj != null ? (EgovMap) obj : null;
    }

    /**
     * 로그인 사용자 정보 조회
     *
     * @param userId 로그인 사용자 ID
     * @return 사용자 정보
     */
    public EgovMap getLoginInfo(String userId) throws Exception {
        return this.getLoginInfo(null, userId);
    }

    /**
     * 사용자정보 Login Update
     *
     * @param tenantId 태넌트 ID
     * @param userId 사용자 ID
     * @param sessionId Session ID
     * @param loginIp  Login IP
     * @param loginFlag Login Flag
     * @return Update Count
     */
    public int setLoginInfo(String tenantId, String userId, String sessionId, String loginIp, String loginFlag) {
        Map<String, Object> param = new HashMap<>();
        param.put("tenantId"    , tenantId);
        param.put("userId"      , userId);
        param.put("sessionId"   , sessionId);
        param.put("loginIp"     , loginIp);
        param.put("loginFlag"   , loginFlag);

        return argoDao.update("userInfo.setSessionUpdate", param);
    }

    /**
     * 사용자정보 Login Update
     *
     * @param tenantId 태넌트 ID
     * @param userId 사용자 ID
     * @param sessionId Session ID
     * @param loginIp  Login IP
     * @return Update Count
     */
    public int setLoginInfo(String tenantId, String userId, String sessionId, String loginIp) {
        return this.setLoginInfo(tenantId, userId, sessionId, loginIp, "1");
    }

    /**
     * logout
     *
     * @param request HttpServletRequest
     * @throws Exception 예외
     */
    public void logout(HttpServletRequest request) throws Exception {
        EgovMap sessionMAP = (EgovMap) EgovUserDetailsHelper.getAuthenticatedUser(request);

        // 사용자정보 logout Update
        String tenantId = null;
        String userId = null;
        if (sessionMAP != null) {
            tenantId = (String) sessionMAP.get("tenantId");
            userId = (String) sessionMAP.get("userId");
            this.setLogoutInfo(tenantId, userId);
        }

        // action log
        actionLogService.log("로그인/로그아웃", "[TenantId:" + tenantId + " | 사용자Id:" + userId + "] 로그아웃");

        // 세션 삭제
        EgovUserDetailsHelper.invalidateSession(request);
        if (request.getSession() != null) {
            request.getSession().invalidate();
        } // 다중세션처리
    }

    public void logout(String tenantId, String userId) throws Exception {
        // 사용자정보 logout Update
        this.setLogoutInfo(tenantId, userId);

        // action log
        //actionLogService.log("로그인/로그아웃", "[TenantId:" + tenantId + " | 사용자Id:" + userId + "] 로그아웃");
    }

    /**
     * 사용자정보 logout update
     *
     * @param tenantId 태넌트 ID
     * @param userId 사용자 ID
     * @return update count
     */
    public int setLogoutInfo(String tenantId, String userId) {
        Map<String, Object> param = new HashMap<>();
        param.put("tenantId"    , tenantId);
        param.put("userId"      , userId);

        return argoDao.update("userInfo.setSessionOutUpdate", param);
    }
}
