package com.bridgetec.argo.controller;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.common.util.HttpUtil;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.bridgetec.common.SecurityUtil;
import com.bridgetec.common.util.security.RSAUtil;
import com.bridgetec.common.util.veloce.StringUtility;
import egovframework.com.cmm.service.EgovProperties;
import egovframework.com.cmm.util.EgovUserDetailsHelper;
import egovframework.com.utl.cas.service.EgovSessionCookieUtil;
import egovframework.com.utl.slm.EgovHttpSessionBindingListener;
import egovframework.rte.fdl.string.EgovStringUtil;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.json.simple.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ArgoCtrlHelper {
    private static final Logger log = LoggerFactory.getLogger(ArgoCtrlHelper.class);


    /**
     * 처리결과 Set
     *
     * @param resultMap 결과 맵
     * @param argoServiceVO ArgoDispatchServiceVo
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws MessageException 예외
     */
    public static void setResult(Map<String, Object> resultMap, ArgoDispatchServiceVo argoServiceVO, HttpServletRequest request, HttpServletResponse response) throws MessageException {
        resultMap.put(Constant.RESULT_CODE, Constant.RESULT_CODE_OK);

        Map<String, Object> svcResultMap = new HashMap<>();
        svcResultMap.put("rows", argoServiceVO.getResOut());
        svcResultMap.put(Constant.SVC_TOT_CNT, String.valueOf(argoServiceVO.getTotCnt()));
        svcResultMap.put(Constant.SVC_PROC_CNT, String.valueOf(argoServiceVO.getProCnt()));
        svcResultMap.put(Constant.SVC_OUT_TYPE, String.valueOf(argoServiceVO.getOutType()));
        svcResultMap.put(Constant.SVC_OUT_NAME, String.valueOf(argoServiceVO.getOutName()));
        resultMap.put(argoServiceVO.getSvcId(), svcResultMap);
    }

    /**
     * ARGOCOMMON.login 거래일경우 Session SET
     *
     * @param request
     * @param response
     * @param svo
     * @throws MessageException
     */
    public static void setSession(HttpServletRequest request, HttpServletResponse response, ArgoDispatchServiceVo svo) throws MessageException {
        // SALOGIN은 향후 거래제어에서 로그인을 보여달라고 할때를 대비해서 추가함(굳이 환경변수로 안빼고)
        if (svo.getResOut() != null
                && (svo.getSvcName().equals("ARGOLOGIN") || svo.getSvcName().equals(Constant.ARGO_COMMON_SVR))
                && svo.getMethodName().equals(Constant.ARGO_METHOD_LOGIN))
        {
            try {
                // ADD BY 2017-03-21 다음 이슈에 의해 수정함.
                // 브라우저 2개띄우고 서로 다른 계정 로그인 실패해도 다른창에서 새로고침 하면 실패한 ID로 로그인됨
                String resultCd = String.valueOf(((EgovMap) svo.getResOut()).get("resultCd"));
                if ("LOGINOK".equals(resultCd)) {
                    ArgoCtrlHelper.setSession(request, response, (EgovMap) svo.getResOut());

                }
                else if ("PWDCHG".equals(String.valueOf(((EgovMap) svo.getResOut()).get("resultCd")))) {
                    ArgoCtrlHelper.setSession(request, response, (EgovMap) svo.getResOut());
                }
                else {
                    log.info("로그인실패 [" + String.valueOf(((EgovMap) svo.getResOut()).get("resultCd")) + "]" + String.valueOf(((EgovMap) svo.getResOut()).get("resultMsg")));
                }
            }
            catch (Exception e) {
                log.error("세션생성실패 :" + e.toString());
                throw new MessageException(new Exception("세션 생성을 실패하였습니다."), Constant.RESULT_CODE_ERR_PROC);
            }
        }
    }

    public static void setSession(HttpServletRequest request, HttpServletResponse response, EgovMap map) throws MessageException {
        try {
            EgovUserDetailsHelper.invalidateSession(request);

            try {
                map.put("hostIp", ArgoCtrlHelper.getHostIp(request));
            }
            catch (Exception e) {
                log.error("Exception : " + e.toString());
            }

            if (map.get("workIp") == null || "".equals((String) map.get("workIp"))) {
                map.put("workIp", ArgoCtrlHelper.getClientIpAddr(request));
            }

            map.remove("salt");
            map.remove("userPwd");
            EgovSessionCookieUtil.setSessionAttribute(request, Constant.SESSION_ATTR_LOGIN, map);

            // LOGOUT 하지 않고 종료 세션만료 등의 사유로 로그아웃일때 로그이력 처리를 위해 쿠키에 저장
            Map sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
            EgovSessionCookieUtil.setCookie(response, "loginSeq", String.valueOf(sessionMAP.get("loginSeq")).replaceAll("[\\r\\n]", ""), 60 * 24);
            EgovSessionCookieUtil.setCookie(response, "agentId", String.valueOf(sessionMAP.get("agentId")).replaceAll("[\\r\\n]", ""), 60 * 24);

            String sessionProc = StringUtility.nvl(EgovProperties.getProperty("Globals.VLC.SESSION.Security"), "0");

            // 중복로그인 가능 로직 및 옵션추가
            // 중복로그인 허용 : 0
            // 중보로그인 비허용 : 1
            if (sessionProc.equals("1")) {
                EgovHttpSessionBindingListener listener = new EgovHttpSessionBindingListener();
                if(request.getSession() != null) {
                    request.getSession().setAttribute((String) map.get("agentId"), listener);
                }
            }
        }
        catch (Exception e) {
            log.error("세션생성실패 :" + e.toString());
            throw new MessageException(new Exception("세션 생성을 실패하였습니다."), Constant.RESULT_CODE_ERR_PROC);
        }
    }


    /**
     * 로그인 세션에 담을 접속서버 IP. SVR 거래시에 전문에 SET하여 사용함.(JSP및 saDispatchTcpDAO)
     *
     * @param request
     * @return
     */
    public static String getHostIp(HttpServletRequest request) {

        String HOSTIP = "";
        StringBuilder IFCONFIG = new StringBuilder();

        try {
            for (Enumeration<java.net.NetworkInterface> en = java.net.NetworkInterface.getNetworkInterfaces(); en.hasMoreElements(); ) {
                java.net.NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements(); ) {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    if (!inetAddress.isLoopbackAddress() && !inetAddress.isLinkLocalAddress() && inetAddress.isSiteLocalAddress()) {
                        IFCONFIG.append(inetAddress.getHostAddress()).append(",");
                        if (request.getHeader("Host").contains(inetAddress.getHostAddress())) {
                            HOSTIP = inetAddress.getHostAddress();
                        }
                        else if (request.getLocalAddr().contains(inetAddress.getHostAddress())) {
                            HOSTIP = inetAddress.getHostAddress();
                        }
                    }
                }
            }

            log.debug("["+HOSTIP+"]["+IFCONFIG.toString()+"]["+IFCONFIG.toString().split(",").length+"]=========================================================================================");
            if (!HOSTIP.equals("")) {
                return HOSTIP;
            }
            else if (IFCONFIG.toString().split(",").length == 1) {
                return IFCONFIG.toString().split(",")[0];
            }
        }
        catch (Exception ex) {
            log.error("Exception : " + ex.toString());
            return "";
        }

        return "";
    }


    /**
     * 요청 처리 결과 HttpServletResponse Write
     *
     * @param response
     * @param resultMap
     */
    public static void print(HttpServletResponse response, Map<String, Object> resultMap) {
        String jsonStr = JSONObject.toJSONString(resultMap);

        response.setContentType("text/html; charset=UTF-8");
        PrintWriter writer = null;

        try {
            writer = response.getWriter();
            writer.write(jsonStr); // dateArgoCtrlHelper.javatime 의 경우 따음표(") 가 생성되지 않아 클라이언트 parse 에러발생. (working?)
            writer.flush();
            writer.close();
        }
        catch (Exception ex) {
            log.error("Exception : " + ex.toString());
        }
    }


    /**
     * VO 생성
     *
     * @param param
     * @param request
     * @return
     */
    public static List<ArgoDispatchServiceVo> createVoList(Map<String, String> param, HttpServletRequest request) {
        List<ArgoDispatchServiceVo> argoServiceVOList = new ArrayList<>();
        String svcIds = param.get(Constant.SVC_PARAM_SVCIDS);


        // SQL 페이지 관련
        String sqlText = (param.get("SVCCOMMONID.text") == null ? "" : param.get("SVCCOMMONID.text"));
        if (!sqlText.equals("")) {
            param.put("SVCCOMMONID.text", sqlText.replaceAll("&#39;", "'"));
        }

        // 서비스 ValueObject 생성 및 서비스정보 설정
        if (EgovStringUtil.isNotEmpty(svcIds)) {
            String[] svcIdArr = EgovStringUtil.getStringArray(svcIds, ",");
            for (String s : svcIdArr) {
                if (!EgovStringUtil.isEmpty(s)) {
                    ArgoDispatchServiceVo argoServiceVO = new ArgoDispatchServiceVo(s);
                    argoServiceVO.setSvcName(param.get(Constant.STR_UNDERLINE + s + Constant.SVC_POSTFIX_NAME));
                    argoServiceVO.setSvcType(param.get(Constant.STR_UNDERLINE + s + Constant.SVC_POSTFIX_TYPE));
                    argoServiceVO.setDbType(param.get(Constant.STR_UNDERLINE + s + Constant.SVC_POSTFIX_DB_TYPE));
                    argoServiceVO.setMethodName(param.get(Constant.STR_UNDERLINE + s + Constant.SVC_POSTFIX_METHOD_NAME));

                    // filter 추가
                    String name = HttpUtil.filter(param.get(Constant.STR_UNDERLINE + s + Constant.SVC_POSTFIX_OUT_TYPE));
                    argoServiceVO.setOutType(StringUtility.cleanXSS(name));

                    String value = HttpUtil.filter(param.get(Constant.STR_UNDERLINE + s + Constant.SVC_POSTFIX_OUT_NAME));
                    argoServiceVO.setOutName(StringUtility.cleanXSS(value));
                    argoServiceVOList.add(argoServiceVO);
                }
            }
        }

        // 서비스 ValueObject 인풋폼정보 설정
        for (ArgoDispatchServiceVo argoServiceVO : argoServiceVOList) {
            argoServiceVO.getReqInput().put("clientIP", request.getRemoteAddr()); // clientIP를 기본으로 SET

            for (String key : param.keySet()) {
                // 서비스정보 처리는 끝났으므로 서비스정보 처리는 통과
                if (key.equals(Constant.STR_UNDERLINE) || key.indexOf(Constant.STR_UNDERLINE) == 0)
                    continue;

                String name = null;
                String value = null;

                if (EgovStringUtil.isNotEmpty(key) && key.startsWith(argoServiceVO.getParamPrefixName())) {
                    name = key.substring(argoServiceVO.getParamPrefixName().length());
                    name = name.substring(0, 1).toLowerCase() + name.substring(1);
                    value = param.get(key);

                    if (value.contains("L[{") || value.contains("L[]")) {
                        ObjectMapper mapper = new ObjectMapper();
                        try {
                            value = value.replaceAll("&quot;", "\"");
                            List<Map> list = mapper.readValue(value.substring(1),
                                    new TypeReference<List<Map<String, Object>>>(){});
                            argoServiceVO.getReqInput().put(name, list);
                        }
                        catch (Exception e) {
                            log.error("Exception : " + e.toString());
                        }
                    }
                    else if (value.contains("L[")) {
                        ObjectMapper mapper = new ObjectMapper();
                        try {
                            value = value.replaceAll("&quot;", "\"");

                            List<Map<String, Object>> list = mapper.readValue(value.substring(1), new TypeReference<ArrayList<Object>>() {});
                            argoServiceVO.getReqInput().put(name, list);
                        }
                        catch (Exception e) {
                            log.error("Exception : " + e.toString());
                        }
                    }
                    else {
                        argoServiceVO.getReqInput().put(name, value);
                    }
                }
                else {
                    name = key;
                    value = param.get(key);
                    argoServiceVO.getReqInput().put(name, value);
                }

                if (!"APMKEY".equals(name) && !"svcIds".equals(name)) {
                    argoServiceVO.addLogParam(name, value);
                }
            }

            // 파리미터 encryptPw 로 오는 값은 암호화.
            if (!EgovStringUtil.null2void((String) argoServiceVO.getReqInput().get("encryptPw")).equals("")
                    && !EgovStringUtil.null2void((String) argoServiceVO.getReqInput().get("userSabun")).equals(""))
            {
                argoServiceVO.getReqInput().put("encryptPw",
                        SecurityUtil.EncryptPassword(argoServiceVO.getReqInput().get("userSabun") + "",
                                RSAUtil.decrypt(request, argoServiceVO.getReqInput().get("encryptPw") + ""), "SHA512"));
                // 다이나믹 쿼리가 패킷에 SQL자체로 노출되지 않게 하기 위해 Client에서 BASE64로 인코딩하여 보내므로 디코딩처리
            }
            else if (argoServiceVO.getSvcName().equals(Constant.ARGO_COMMON_SVR)
                    && (argoServiceVO.getMethodName().equals(Constant.ARGO_METHOD_DML_SELECT)
                    || argoServiceVO.getMethodName().equals(Constant.ARGO_METHOD_DML_CUD)))
            {
                argoServiceVO.getReqInput().put("query", new String(org.apache.commons.codec.binary.Base64
                        .decodeBase64((String) argoServiceVO.getReqInput().get("query")), StandardCharsets.UTF_8));
            }
            // 세션에 있는 값을 MAP에 추가. common.login로 조회된 필드명에 prefix glo_를 붙여서 Map에 PUT ex)
            // SELECT USER_ID ..> glo_userId로 PUT.
            Map<String, Object> sessionMAP;
            try {
                sessionMAP = (Map<String, Object>) EgovUserDetailsHelper.getAuthenticatedUser(request);
                for (String key : sessionMAP.keySet()) {
                    if (EgovStringUtil.isNotEmpty(key))
                        argoServiceVO.getReqInput().put("glo_" + key, sessionMAP.get(key));
                    // System.out.println("111glo_"+key+"::"+sessionMAP.get(key));
                }

                if (StringUtils.hasText(argoServiceVO.getUserId())) {
                    argoServiceVO.getReqInput().put("workUser", argoServiceVO.getUserId());
                }

                long time = System.currentTimeMillis();
                SimpleDateFormat dayTime = new SimpleDateFormat("yyyy-mm-dd hh:mm:ss");
                String str = dayTime.format(new Date(time));
                argoServiceVO.getReqInput().put("currentTime", str);

                if (!log.isDebugEnabled()) { // debug 일때는 로깅하지 않는다.
                    // ArgoInterceptor에서 상세하게 기록하므로..
                    log.info("[" + argoServiceVO.getUserSabun() + "] IF:" + argoServiceVO.getSvcType()
                            + " ,Service:" + argoServiceVO.getSvcName() + " ,Method:" + argoServiceVO.getMethodName()
                            + " ,Action:" + argoServiceVO.getDbType());
                }
            }
            catch (Exception e) {
                e.printStackTrace();
                log.error("Exception : " + e.toString());
            }
        }
        return argoServiceVOList;
    }


    /**
     * 비밀번호 유효성 검사
     *
     * @param id id
     * @param pw password
     * @throws MessageException 예외
     */
    public static void validatePassword(String id, String pw) throws MessageException {
        String p1 = "^(?=.*[A-Za-z])(?=.*[0-9])(?=.*[$@$!%*#?&])[A-Za-z[0-9]$@$!%*#?&]{8,50}$";    // 특수문자, 영문, 숫자 조합 (8~10 자리)
        String p2 = "(\\w)\\1\\1"; // 같은 문자, 숫자

        Matcher m1 = Pattern.compile(p1).matcher(pw);
        Matcher m2 = Pattern.compile(p2).matcher(pw);

        // 특수문자, 영문, 숫자 조합 8자리 이상
        if (!m1.matches()) {
            throw new MessageException(new Exception(), "complexity");
        }

        // 동일문자 연속 사용 체크
        if (m2.find()) {
            throw new MessageException(new Exception(), "sameWord");
        }

        // 아이디 포함여부 체크
        if (pw.contains(id)) {
            throw new MessageException(new Exception(), "inclusionId");
        }
    }



    /**
     *
     * @param request
     * @return
     */
    public static String getClientIpAddr(HttpServletRequest request) {
        String ip = request.getHeader("iv-remote-address");

        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("X-Forwarded-For");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("HTTP_X_FORWARDED");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("HTTP_X_CLUSTER_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("HTTP_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("HTTP_FORWARDED");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("HTTP_VIA");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getHeader("REMOTE_ADDR");
        }
        if (ip == null || ip.length() == 0 || ip.equalsIgnoreCase("unknown")) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}
