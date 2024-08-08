package com.bridgetec.argo.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.PrivateKey;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.regex.PatternSyntaxException;

import javax.annotation.Resource;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.core.async.AsyncLoggerConfigDisruptor.Log4jEventWrapper;
//import org.apache.http.HttpHeaders;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.codehaus.jackson.map.ObjectMapper;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.bnk.crypto.CSNcrypt;
import com.bridgetec.argo.batch.util.StringUtil;
import com.bridgetec.argo.batch.work.WorkBatch;
import com.bridgetec.argo.batch.work.WorkLogic;
import com.bridgetec.argo.common.ConfigLoader;
import com.bridgetec.argo.common.ConnextionDBInfo;
import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.common.NoGrantException;
import com.bridgetec.argo.common.util.HttpUtil;
import com.bridgetec.argo.common.util.VeloceExcelInsert;
import com.bridgetec.argo.service.ArgoDispatchServiceImpl;
import com.bridgetec.argo.service.ArgoFileUploadService;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.bridgetec.common.SecurityUtil;
import com.bridgetec.common.SortProperties;
import com.bridgetec.common.osu.veloce.DateUtil;
import com.bridgetec.common.osu.veloce.Destination;
import com.bridgetec.common.osu.veloce.InterfaceException;
import com.bridgetec.common.osu.veloce.Message;
import com.bridgetec.common.osu.veloce.OSUBody_2800;
import com.bridgetec.common.osu.veloce.OSUBody_3020;
import com.bridgetec.common.osu.veloce.OSUBody_Ack_2800;
import com.bridgetec.common.osu.veloce.OSUBody_Ack_3020;
import com.bridgetec.common.osu.veloce.OSUClient;
import com.bridgetec.common.osu.veloce.OSUHeader;
import com.bridgetec.common.osu.veloce.SocketClient;
import com.bridgetec.common.osu.veloce.TIDSeqManager;
import com.bridgetec.common.util.security.AESUtil;
import com.bridgetec.common.util.security.EncryptUtil;
import com.bridgetec.common.util.security.RSAUtil;
import com.bridgetec.common.util.security.SHA512Util;
import com.bridgetec.common.util.veloce.StringUtility;

import egovframework.com.cmm.EgovMessageSource;
import egovframework.com.cmm.EgovWebUtil;
import egovframework.com.cmm.service.EgovProperties;
import egovframework.com.cmm.service.Globals;
import egovframework.com.cmm.util.EgovUserDetailsHelper;
import egovframework.rte.fdl.string.EgovStringUtil;
import egovframework.rte.psl.dataaccess.util.EgovMap;
//import org.springframework.core.io.Resource;

@Controller
@SuppressWarnings({ "rawtypes", "unchecked", "static-access" })
public class ArgoDispatchController extends ConnextionDBInfo {

    private Logger loMeLogger = LoggerFactory.getLogger(ArgoDispatchController.class);
    private ConfigLoader configLoader;

    @Autowired
    private ArgoDispatchServiceImpl argoDispatchServiceImpl;
    
    @Autowired
    private ArgoFileUploadService argoFileUploadService;
    
    private String SHA_TYPE = EgovProperties.getProperty("Globals.encryptType");

    // (2023.08.22) Globals 프로퍼티 추가 (REC_TABLE_TYPE) (HAGUANGHO)
    private String REC_TABLE_TYPE = Globals.REC_TABLE_TYPE();

    @Resource(name = "egovMessageSource")
    EgovMessageSource egovMessageSource;
    
    
    private final Path audioLocation = Paths.get("audio");
    
    
    
    
    @RequestMapping(value = "/{path}/{page}")
    public String swatsso(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> parm, Model model, @PathVariable String path, @PathVariable String page) {

        String result = "";
        
        path = path == null ? "" : path;
        page = page == null ? "" : page;
        
        try {
            if (path.equals("external")) {

                if (page.equals("vlctk")) {
                    result = "external/maketk";
                } else if(page.equals("user")) {
                    result = "external/user";
                } else {
                    result = "external/swatuser";
                }
                /*
                 * ArgoDispatchServiceVo saDispatchServiceVo = new
                 * ArgoDispatchServiceVo("SVCCOMMONID");
                 * saDispatchServiceVo.setSvcType("ARGODB");
                 * saDispatchServiceVo.setSvcName("mt"); saDispatchServiceVo.setDbType("P");
                 * 
                 * HashMap<String, Object> reqInput = new HashMap<String, Object>();
                 * 
                 * String InTenantId = request.getParameter("InTenantId"); String InFlag =
                 * request.getParameter("InFlag"); String InAgentId =
                 * request.getParameter("InAgentId"); String InDeptCd =
                 * request.getParameter("InDeptCd"); String InAgentGrant =
                 * request.getParameter("InAgentGrant"); String InAgentNm =
                 * request.getParameter("InAgentNm"); String InAgentPw =
                 * request.getParameter("InAgentPw"); String InDnNo =
                 * request.getParameter("InDnNo"); String InTelephonIp =
                 * request.getParameter("InTelephonIp"); String InVeloceSystem =
                 * request.getParameter("InVeloceSystem"); String InVeloceProcess =
                 * request.getParameter("InVeloceProcess"); String RtnCode =
                 * request.getParameter("RtnCode"); String InDnRefNo =
                 * request.getParameter("InDnRefNo"); String RtnMsg =
                 * request.getParameter("RtnMsg");
                 * 
                 * reqInput.put("InFlag", InFlag); reqInput.put("InTenantId", InTenantId);
                 * reqInput.put("InAgentId", InAgentId); reqInput.put("InDeptCd", InDeptCd);
                 * reqInput.put("InAgentGrant", "Agent"); reqInput.put("InAgentNm", InAgentNm);
                 * 
                 * //비밀번호 암호화 EncryptUtil encp = new EncryptUtil(); byte[] bSalt =
                 * encp.getSaltData(); byte[] bDigest = encp.getEncSaltData("SHA-512",
                 * "kjb2395001*", bSalt, false); String salt = encp.byteToBase64(bSalt); String
                 * InAgentPw1 = encp.byteToBase64(bDigest);
                 * 
                 * System.out.println(InAgentPw1);
                 * 
                 * try { MessageDigest digest = MessageDigest.getInstance("SHA-512");
                 * digest.reset(); digest.update("kjb2395001*".getBytes("utf8")); String
                 * InAgentPw2 = String.format("%040x", new BigInteger(1, digest.digest()));
                 * System.out.println(InAgentPw2);
                 * 
                 * } catch (Exception e) { e.printStackTrace(); }
                 * 
                 * reqInput.put("InAgentPw", InAgentPw); reqInput.put("InDnNo", InDnNo);
                 * reqInput.put("InTelephonIp", InTelephonIp); reqInput.put("InVeloceSystem",
                 * InVeloceSystem); reqInput.put("InVeloceProcess", InVeloceProcess);
                 * reqInput.put("InDnRefNo", InDnRefNo);
                 *
                 * saDispatchServiceVo.setReqInput(reqInput);
                 * saDispatchServiceVo.setMethodName("setExUserInfoADD");
                 *
                 * List<ArgoDispatchServiceVo> svcList = new ArrayList<ArgoDispatchServiceVo>();
                 * svcList.add(saDispatchServiceVo);
                 *
                 * try { argoDispatchServiceImpl.excute(svcList); result =
                 * saDispatchServiceVo.getResultCode();
                 *
                 * if (result != Constant.RESULT_CODE_OK) result="9999^"; else result="0000^";
                 *
                 * } catch (MessageException e) { e.printStackTrace(); }
                 */
            }
        } catch (IllegalArgumentException iae) {
            loMeLogger.error("Exception : " + iae.toString());
        } catch (Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
        return result;
        // "external/swatuser";

    }

    @RequestMapping("/{path}/{page}F.do")
    public String form(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> parm, Model model, @PathVariable String path, @PathVariable String page) throws NoGrantException, Exception {
        Map<String, Object> sessionMAP = null;
        ArgoDispatchServiceVo argoServiceVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);

        sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request); // 인증된 사용자 세션정보를 가져온다
        
        path = path == null ? "" : path;
        page = page == null ? "" : page;
        
        // 20230925 jslee VMain URL로 접근시 세션이 없으면 로그인 창으로 이동
        if (page.equals("VMain")) {
        	
        	// 20231010 jslee 죽전/일산 구분을 위한 서버IP 추출하여 구분값 리턴
            // JJ : 죽전
            // IS : 일단
            // 이외 : 개발계로 표현
            if(request.getLocalAddr().contains("172.28.111")) {
            	model.addAttribute("serverAddrGb", "JJ");
            }else if(request.getLocalAddr().contains("172.28.211")) {
            	model.addAttribute("serverAddrGb", "IS");
            }else {
            	model.addAttribute("serverAddrGb", "DEV");
            }
        	
    		if(sessionMAP == null) {
        		String tenantIdList = "";
            	String tenantNmList = "";
                
                WorkLogic workLogic = new WorkLogic();
                net.sf.json.JSONArray jsonArray = new net.sf.json.JSONArray();
                String strQuery = " SELECT \r\n" + 
			                		"    LISTAGG(TENANT_ID, ',') WITHIN GROUP (ORDER BY TENANT_ID) AS TENANT_ID_LIST,\r\n" + 
			                		"    LISTAGG(TENANT_NAME, ',') WITHIN GROUP (ORDER BY TENANT_ID) AS TENANT_NAME_LIST\r\n" + 
			                		" FROM TB_MNG_COMPANY\r\n" +
			                		" WHERE EXPIRE_DATE is null OR EXPIRE_DATE = '' \r\n";
                jsonArray = workLogic.exeSelect(strQuery);
                if (jsonArray.size() > 0) {
                    net.sf.json.JSONObject firstItem = jsonArray.getJSONObject(0);
                    tenantIdList = firstItem.getString("TENANT_ID_LIST");
                    tenantNmList = firstItem.getString("TENANT_NAME_LIST");
                    model.addAttribute("tenantIdList", tenantIdList);
                    model.addAttribute("tenantNmList", tenantNmList);
                }
        		return "common/Login";
        	}
        }
        
        // 세션체크
        try {
            // csrf check start
            if("Y".equals(EgovProperties.getProperty("Globals.refererCheck"))) {
                if(page.equals("STTPlayC") || page.equals("STTPlayO")) {
                    if("Y".equals(EgovProperties.getProperty("Globals.refererCheck.api"))) {
                        if(request.getHeader("referer") == null) {
                            return "common/error.jsp";
                        }
                    }
                } else {
                	if(!path.equals("external") && !page.equals("Login") && !page.equals("LoginSSO") && !page.equals("LoginConfig")&& !page.equals("VMain")) {
                        if(request.getHeader("referer") != null) {
                            String requestUrl = request.getRequestURL().toString();
                            int startNum = request.isSecure() ? 9 : 8;
                            String expectedRefererStartsWith = requestUrl.substring(0, requestUrl.indexOf('/', startNum));
                            String referer = request.getHeader("referer");
                            
                            // http or https 상관없이 체크하기 위해서 protocol 제거함
                            expectedRefererStartsWith = expectedRefererStartsWith.replaceAll("http://", "").replaceAll("https://", "");
                            referer = referer.replaceAll("http://", "").replaceAll("https://", "");
                            
                            if(!(referer != null && referer.startsWith(expectedRefererStartsWith))) {
                                return "common/error.jsp";
                            }
                        }else {
                            return "common/error.jsp";
                        }
                    }
                }
            }
            // csrf check end
            
            // 권한체크
            if (!path.equals("external") && !page.equals("STTPlayie") && !page.equals("STTPlaychrome") && !page.equals("STTPlayscreen")
                    && !page.equals("RecSearch") && !page.equals("STTPlayO") && !page.equals("STTPlayC")
                    && !page.equals("Login") && !page.equals("LoginConfig") && !page.equals("DbInfoConfig")
                    && !page.equals("DbInfoPopAdd") && !page.equals("RealTimePlay") && !page.equals("dbInfoConfig")
                    && !page.equals("Env") && !path.equals("manager") && !page.equals("LoginSSO")
                    && !page.equals("RecSearchMark") && !page.equals("vlcdml") && !page.equals("RecGrant")
                    && !page.equals("RecSendDetailStat") && !page.equals("DbInfoPopAdd") && !page.equals("STTPlayC_Scr")) { // 특정페이지를 제외하고 로그인 세션체크를 한다

                //sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request); // 인증된 사용자 세션정보를 가져온다
                argoServiceVO.setSvcName(page);
                argoServiceVO.getReqInput().put("glo_grantId", sessionMAP.get("grantId")); // ??어디서 생성
                argoServiceVO.getReqInput().put("glo_userId", sessionMAP.get("agentId"));
                argoDispatchServiceImpl.pageGrantCheck(argoServiceVO);
                if (sessionMAP.get("grantId") != null && !String.valueOf(sessionMAP.get("grantId")).equals("")
                        && !page.equals("VMain") && !page.equals("VIntro") && page.indexOf("Pop") == -1 && !page.equals("EMain")
                        && page.indexOf("STTPlay") == -1 && page.indexOf("Detail") == -1 && page.indexOf("Add") == -1
                        && !page.equals("RecSearchSamp")&& !page.equals("RealTimePlay")  && !page.equals("RecSendDetailStat") && page.indexOf("VEx") == -1) {

                    // argoDispatchDAO = new ArgoDispatchDAO();
                    String checkUrl = "";
                    checkUrl = "/" + path + "/" + page + "F.do";
                    String gid = (String) sessionMAP.get("grantId");
                    String tid = (String) sessionMAP.get("tenantId");
                    Map map = new HashMap();
                    map.put("GID", gid);
                    map.put("TID", tid);
                    map.put("URL", checkUrl);
                    //String result = argoDispatchServiceImpl.getGrantForm(argoServiceVO, map);
                    //if (result.equals("0")) {
                    //    return "common/error.jsp";
                    //}
                }
            }

            if (page.equals("multidown")) {
                String parm_send = (String) parm.get("urls");
                model.addAttribute("parm_send", parm_send);
                return "external/swatuser2";
            }

            if (page.equals("Main")) {
                if (sessionMAP != null) {
                    String sdate = "";
                    String fdate = "";
                    String sdateEnc = "";
                    String fdateEnc = "";
                    if (!SHA512Util.SHA512(sdate).equals(sdateEnc) || !SHA512Util.SHA512(fdate).equals(fdateEnc)) {
                        // yoonys0515 2018-10-08 start
                        EgovUserDetailsHelper.invalidateSession(request); // 세션삭제
                        if(request.getSession() != null) { request.getSession().invalidate(); } // 다중세션처리
                        page = "Main";
                        model.addAttribute("errorCd", "dateLicense");
                        model.addAttribute("msg", "라이센스 값(사용기간)이 임의로 변경되었습니다.");
                        // yoonys0515 2018-10-08 end
                    }
                }
            }
            
            List<ArgoDispatchServiceVo> reqUserInfoSvcList = new ArrayList<>();
            if((path+"/"+page).equals("recording/STTPlayC_Scr")) {
                ArgoDispatchServiceVo reqUserInfoVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                Map<String, Object> reqInput = new HashMap<String, Object>();
                String loginIp = ArgoCtrlHelper.getClientIpAddr(request);
                parm.put("loginIp", loginIp);
                String qsCallId = parm.get("call_id");
                
                reqUserInfoVo.setSvcType("ARGODB");
                reqUserInfoVo.setSvcName("recSearch");
                reqUserInfoVo.setDbType("S");
                reqUserInfoVo.setMethodName("getCallIdSearch");
                reqInput.put("callId", qsCallId);
                reqUserInfoVo.setReqInput(reqInput);
                reqUserInfoSvcList.add(reqUserInfoVo);
                argoDispatchServiceImpl.execute(reqUserInfoSvcList);
                if(reqUserInfoVo.getResOut() == null) {
                    page = "STTPlayC";
                }else {
                    page = "STTPlayS";
                }
            }

            if ("Login".equals(page) || "UserPopupEdit".equals(page) || "RecAuthPop".equals(page) || "Env".equals(page)
                    || "DbPwChangeMain".equals(page) || "ProcServerMruRestartPopAdd".equals(page)) {
                String[] rsakey = RSAUtil.getKey(request);
                model.addAttribute("RSAModulus", rsakey[0]);
                model.addAttribute("RSAExponent", rsakey[1]);
            }
            
            // jslee
            if ("Login".equals(page)) {
            	
            	// 20231010 jslee 죽전/일산 구분을 위한 서버IP 추출하여 구분값 리턴
                // JJ : 죽전
                // IS : 일단
                // 이외 : 개발계로 표현
                if(request.getLocalAddr().contains("172.28.111")) {
                	model.addAttribute("serverAddrGb", "JJ");
                }else if(request.getLocalAddr().contains("172.28.211")) {
                	model.addAttribute("serverAddrGb", "IS");
                }else {
                	model.addAttribute("serverAddrGb", "DEV");
                }
            	
            	String tenantIdList = "";
            	String tenantNmList = "";
                
                WorkLogic workLogic = new WorkLogic();
                net.sf.json.JSONArray jsonArray = new net.sf.json.JSONArray();
                String strQuery = " SELECT \r\n" + 
			                		"    LISTAGG(TENANT_ID, ',') WITHIN GROUP (ORDER BY TENANT_ID) AS TENANT_ID_LIST,\r\n" + 
			                		"    LISTAGG(TENANT_NAME, ',') WITHIN GROUP (ORDER BY TENANT_ID) AS TENANT_NAME_LIST\r\n" + 
			                		" FROM TB_MNG_COMPANY\r\n" +
			                		" WHERE EXPIRE_DATE is null OR EXPIRE_DATE = '' \r\n";
                jsonArray = workLogic.exeSelect(strQuery);
                if (jsonArray.size() > 0) {
                    net.sf.json.JSONObject firstItem = jsonArray.getJSONObject(0);
                    tenantIdList = firstItem.getString("TENANT_ID_LIST");
                    tenantNmList = firstItem.getString("TENANT_NAME_LIST");
                    model.addAttribute("tenantIdList", tenantIdList);
                    model.addAttribute("tenantNmList", tenantNmList);
                }
            }
        } catch (NoGrantException ne) {
            loMeLogger.info("[로그용 :/" + path + "/" + page + "F.do][" + sessionMAP.get("userName") + "] 허용되지 않는 요청 :" + ne.toString());
        } catch (Exception e) {
            loMeLogger.info("[로그용 :/" + path + "/" + page + "F.do] Page Init Exception :" + e.toString());
        }

        for (String key : parm.keySet()) {
            if (EgovStringUtil.isNotEmpty(key)) {
                model.addAttribute(key, parm.get(key));
            }
        }

        return path + "/" + page;
    }

    @RequestMapping("/common/VExcelInsertF.do")
    public String test(MultipartHttpServletRequest request) {
        /*
         * String studentNumber = request.getParameter("studentNumber"); MultipartFile
         * report = request.getFile("report");
         */
        return "common/VExcelInsert";
    }

    @RequestMapping("/dbInfoConfig.do")
    @ResponseBody
    public net.sf.json.JSONObject goUpt(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> parm) throws Exception {

        net.sf.json.JSONObject jsonObj = new net.sf.json.JSONObject();
        String ret = "";
        String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
        SortProperties properties = new SortProperties();
        String code = parm.get("Code");
        
        FileInputStream fis = null;
        FileOutputStream fos = null;

        try {
            if (code.equals("LOG")) {
//              properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
                fis = new FileInputStream(GLOBALS_PROPERTIES_FILE);
                properties.load(fis);
                String id = properties.getProperty("Globals.admin.id").trim();
                String pw = properties.getProperty("Globals.admin.passwd").trim();
                String enId = AESUtil.encrypt(parm.get("enId")) == null ? "" : AESUtil.encrypt(parm.get("enId")).trim();
                String enPw = AESUtil.encrypt(parm.get("enPw")) == null ? "" : AESUtil.encrypt(parm.get("enPw")).trim();

                if (!id.equals(enId)) {
                    ret = "failId";
                    jsonObj.put("ret", ret);
                    return jsonObj;
                }
                
                if (!pw.equals(enPw)) {
                    ret = "failPw";
                    jsonObj.put("ret", ret);
                    return jsonObj;
                }
                ret = "success";
            } else if (code.equals("ENC")) {
                String encryptId = AESUtil.decrypt(parm.get("decryptId")).trim();
                String encryptPw = AESUtil.decrypt(parm.get("decryptPw")).trim();
                String encryptLoId = AESUtil.decrypt(parm.get("decryptLoId")).trim();
                String encryptLoPw = AESUtil.decrypt(parm.get("decryptLoPw")).trim();
                String encryptSwatInitPw = AESUtil.decrypt(parm.get("decryptSwatInitPw")).trim();
                jsonObj.put("chId", encryptId);
                jsonObj.put("chPw", encryptPw);
                jsonObj.put("chLoId", encryptLoId);
                jsonObj.put("chLoPw", encryptLoPw);
                jsonObj.put("chSwatInitPw", encryptSwatInitPw);
                return jsonObj;

            } else if (code.equals("SAVE")) {
//              properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
                fis = new FileInputStream(GLOBALS_PROPERTIES_FILE);
                properties.load(fis);
                properties.setProperty("Globals.ARGO.RDB.Account", AESUtil.encrypt(parm.get("chUserId")));
                properties.setProperty("Globals.ARGO.RDB.Password", AESUtil.encrypt(parm.get("chUserPw")));
                properties.setProperty("Globals.admin.id", AESUtil.encrypt(parm.get("chUserLoId")));
                properties.setProperty("Globals.admin.passwd", AESUtil.encrypt(parm.get("chUserLoPw")));
                properties.setProperty("Globals.ARGO.RDB.Driver", parm.get("chDriver"));
//              properties.setProperty("Globals.ARGO.RDB.Url", parm.get("chUrl"));
                properties.setProperty("Globals.ARGO.RDB.Url", HttpUtil.codeToSpecial(parm.get("chUrl")));
                properties.setProperty("Globals.encryptType", parm.get("chEncryptType"));
                properties.setProperty("Globals.encryptList", parm.get("chEncryptList"));
                properties.setProperty("Globals.encryptSalt", parm.get("chEncryptSalt"));
                properties.setProperty("Globals.ARGO.RDB.Kind", parm.get("chDbKind"));
                properties.setProperty("Globals.ARGO.RDB.DbPort", parm.get("chDbPort"));
                properties.setProperty("Globals.ARGO.RDB.DbIp", parm.get("chDbIp"));
                properties.setProperty("Globals.ARGO.RDB.Sid", parm.get("chSid"));
                properties.setProperty("Globals.ARGO.RDB.CenterCd", parm.get("chCenterCd"));
                properties.setProperty("Globals.ARGO.RDB.CenterNm", parm.get("chCenterNm"));
                properties.setProperty("Globals.ARGO.RDB.ArchiveSerIp", parm.get("chArchiveSerIp"));
                properties.setProperty("Globals.ARGO.RDB.ArchiveDir", parm.get("chArchiveDir"));
                properties.setProperty("Globals.ARGO.RDB.FailOver", parm.get("chFailOver"));
                properties.setProperty("Globals.ARGO.RDB.LoadBalance", parm.get("chLoadBalance"));
                properties.setProperty("Globals.ARGO.RDB.ValidationSql", parm.get("chValidationSql"));
                properties.setProperty("Globals.authUserId1", parm.get("chAuthUserId1"));
                properties.setProperty("Globals.authUserId2", parm.get("chAuthUserId2"));
                properties.setProperty("Globals.recAuth", parm.get("chRecAuth"));
                properties.setProperty("Globals.VLC.SESSION.Security", parm.get("chDuplicateLogin"));


                if ("ORACLE".equals(parm.get("chDbKind"))) {
                    properties.setProperty("Globals.sqlMapType", "ora");
                } else if ("MSSQL".equals(parm.get("chDbKind"))) {
                    properties.setProperty("Globals.sqlMapType", "ms");
                } else if ("TIBERO".equals(parm.get("chDbKind"))) {
                    properties.setProperty("Globals.sqlMapType", "tb");
                } else if ("MYSQL5".equals(parm.get("chDbKind"))) {
                    properties.setProperty("Globals.sqlMapType", "my5");
                } else if ("MYSQL8".equals(parm.get("chDbKind"))) {
                    properties.setProperty("Globals.sqlMapType", "my8");
                } else if ("MARIADB".equals(parm.get("chDbKind"))) {
                    properties.setProperty("Globals.sqlMapType", "maria");
                }

                properties.setProperty("Globals.termValList", parm.get("chTermValList"));
                properties.setProperty("Globals.agentUseYn", parm.get("chAgentUseYn"));
                properties.setProperty("Globals.swatInitPwType", parm.get("chSwatInitPwType"));
                properties.setProperty("Globals.swatInitPw", "".equals(parm.get("chSwatInitPw")) ? "" : AESUtil.encrypt(parm.get("chSwatInitPw")));
//              properties.store(new java.io.FileOutputStream(GLOBALS_PROPERTIES_FILE), "");
                fos = new FileOutputStream(GLOBALS_PROPERTIES_FILE);
                properties.store(fos, "");
                ret = "success";
            }
            
            if(fos != null) { fos.close(); }
            if(fis != null) { fis.close(); }
        } catch (FileNotFoundException fnfe) {
            loMeLogger.error("GLOBALS_PROPERTIES_FILE  SET FAIL Exception : " + fnfe.toString());
        } catch (Exception e) {
            loMeLogger.error("GLOBALS_PROPERTIES_FILE  SET FAIL Exception : " + e.toString());
        } finally {
            jsonObj.put("ret", ret); // 처리결과 설정
            if(fos != null) { fos.close(); }
            if(fis != null) { fis.close(); }
        }

        return jsonObj;
    }

    @RequestMapping(value = Constant.SVC_ARGO_PATH , method=RequestMethod.POST)
    public void invloke(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> parm) throws Exception {
    	System.out.println("여기로 들어오는거니??");
        ArgoDispatchServiceVo argoServiceVO1 = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
        HashMap<String, Object> resultMap = new HashMap();
        EncryptUtil encp = new EncryptUtil();
        String encrpt_pwd = null;
        String strUesrIpChk = "1";
        Map<String, Object> sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);

        FileInputStream fis = null;
        
        try {
            loMeLogger.info("[ param : " + parm.toString() + " ]");
            loMeLogger.info("working? : invoke() start ================================================ ");
            String loginIp = ArgoCtrlHelper.getClientIpAddr(request);

            boolean pwdCheck = false;
            parm.put("loginIp", loginIp);
            
            // QA일 시 동적테이블 sqlInjection 처리
            if(parm.get("APMKEY").contains("SP_QA")) {
            	if(parm.get("SVCCOMMONID.tableNm") != null && !parm.get("SVCCOMMONID.tableNm").trim().equals("")) {
            		String tableNm = exportSqlInjectionTable(parm.get("SVCCOMMONID.tableNm"));
            		parm.put("SVCCOMMONID.tableNm", tableNm);
            	}
            }
            // jslee 관리자 페이지관련
            String methodName = parm.get("APMKEY");
            if(methodName.contains("SP_MNG")) {
                for (String key : parm.keySet()) {
                    parm.put(key, getHtmlStrCnvr(parm.get(key)));
                }
            }
            
            // SQL 페이지 관련
            if (methodName.equals("MT.GETTBLIST")) {
                parm.put("SVCCOMMONID.owner", AESUtil.decrypt(parm.get("SVCCOMMONID.owner")).trim());

            }

            // ArgoInterceptor로 이동
            // 권한체크
//            if (sessionMAP != null
//                    && parm.get("SVCCOMMONID.grantId") != null
//                    && !methodName.equals("ARGOCOMMON.LOGIN")
//                    && !sessionMAP.get("grantId").equals(parm.get("SVCCOMMONID.grantId"))) {
//                response.setContentType("text/html; charset=UTF-8");
//
//                PrintWriter out = response.getWriter();
//                out.println("<script>argoAlert('잘못된 접근입니다.'); </script>");
//                out.flush();
//                out.close();
//                return;
//            }

            // 과거 비밀번호 사용 금지
            if ("USERINFO.CHECKPASTUSERPWD".equals(methodName)) {
                byte[] bCheckPastUserPwdSalt = null;

                String findSalt = (String) parm.get("SVCCOMMONID.findSalt");
                String findUserPwd = (String) parm.get("SVCCOMMONID.findUserPwd");

                PrivateKey sessionRsaPk = (PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__");
                String decrypFindUserPwd = RSAUtil.decrypt(request, findUserPwd);
                request.getSession().setAttribute("__rsaPrivateKey__", sessionRsaPk);

                bCheckPastUserPwdSalt = encp.base64ToByte(findSalt);
//              byte[] bDigest = encp.getEncSaltData("SHA-512", decrypFindUserPwd, bCheckPastUserPwdSalt, false);
                byte[] bDigest = encp.getEncSaltData(SHA_TYPE, decrypFindUserPwd, bCheckPastUserPwdSalt, false);
                String encrptPwd = encp.byteToBase64(bDigest);

                parm.put("SVCCOMMONID.findUserPwd", encrptPwd);
            }

            if ("USERINFO.CHECKAUTHUSERPWD".equals(methodName)) {

                byte[] checkAuthUserPwdSalt1 = null;
                byte[] checkAuthUserPwdSalt2 = null;

                String findSalt1 = (String) parm.get("SVCCOMMONID.findSalt1");
                String findSalt2 = (String) parm.get("SVCCOMMONID.findSalt2");
                String findUserPwd1 = (String) parm.get("SVCCOMMONID.findUserPwd1");
                String findUserPwd2 = (String) parm.get("SVCCOMMONID.findUserPwd2");

                PrivateKey sessionRsaPk = (PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__");

                
                String decryptFindUserPwd1 = RSAUtil.decrypt(request, findUserPwd1);

                request.getSession().setAttribute("__rsaPrivateKey__", sessionRsaPk);

                
                
                String decryptFindUserPwd2 = RSAUtil.decrypt(request, findUserPwd2);


                request.getSession().setAttribute("__rsaPrivateKey__", sessionRsaPk);

                checkAuthUserPwdSalt1 = encp.base64ToByte(findSalt1);
                checkAuthUserPwdSalt2 = encp.base64ToByte(findSalt2);


//              byte[] bDigest1 = encp.getEncSaltData("SHA-512", decryptFindUserPwd1, checkAuthUserPwdSalt1, false);
//              byte[] bDigest2 = encp.getEncSaltData("SHA-512", decryptFindUserPwd2, checkAuthUserPwdSalt2, false);
                byte[] bDigest1 = encp.getEncSaltData(SHA_TYPE, decryptFindUserPwd1, checkAuthUserPwdSalt1, false);
                byte[] bDigest2 = encp.getEncSaltData(SHA_TYPE, decryptFindUserPwd2, checkAuthUserPwdSalt2, false);

                String encryptPwd1 = encp.byteToBase64(bDigest1);
                String encryptPwd2 = encp.byteToBase64(bDigest2);


                parm.put("SVCCOMMONID.findUserPwd1", encryptPwd1);
                parm.put("SVCCOMMONID.findUserPwd2", encryptPwd2);
            }

            // 고객번호, 고객전화번호 암호화 _20171206
            if ("RECSEARCH.GETRECSEARCHLIST".equals(methodName) || "RECSEARCH.GETRECSEARCHLISTCNT".equals(methodName)) {

                loMeLogger.info("##### recSearch cust(id/tel) enc #####");
                String decCustNo = parm.get("SVCCOMMONID.FindCustNoText");
                String decCustTel = parm.get("SVCCOMMONID.FindCustTelText");
                String decCustEtc1 = parm.get("SVCCOMMONID.FindCustEtc1Text");
                String encSeed = parm.get("SVCCOMMONID.encKey");
                
                String decSeed = "";
                String encCustNo = ""; // 고객번호 암호화
                String encCustTel = ""; // 전화번호 암호화
                String encCustEtc1 = ""; // 전화번호 암호화

                ArgoDispatchServiceVo companyKindVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                companyKindVO.getReqInput().put("section", "COMPANY");
                companyKindVO.getReqInput().put("keyCode", "SITE_PAGE_KIND");
                String sitePageKind = argoDispatchServiceImpl.selectParam(companyKindVO, "menu.getSelectParam");
                
                // seed 복호화
                decSeed = getStrCrypt(sitePageKind, "dec", "custNo", encSeed,null);
                
                // seed를 이용한 고객정보 암호화 
                encCustNo = getStrCrypt(sitePageKind, "enc", "custNo", decCustNo,decSeed);
                encCustTel = getStrCrypt(sitePageKind, "enc", "custTel", decCustTel,decSeed);
                encCustEtc1 = getStrCrypt(sitePageKind, "enc", "custTel", decCustEtc1,decSeed);
                
                // response
                parm.put("findCustNoText", decCustNo); // 고객번호(평문)
                parm.put("findCustTelText", decCustTel); // 전화번호(평문)
                parm.put("findCustEtc1Text", decCustEtc1); // 전화번호(평문)
                parm.put("findCustNoEnc", encCustNo); // 고객번호(암호화)
                parm.put("findCustTelEnc", encCustTel); // 전화번호(암호화)
                parm.put("findCustEtc1Enc", encCustEtc1); // 전화번호(암호화)

            } // end

            // loginIp or workIp 값이 없을경우 요청자 IP로 셋팅 - Start
            if("".equals(parm.get("loginIp")) || parm.get("loginIp") == null) {
                parm.put("loginIp", loginIp);
            }
            
            if("".equals(parm.get("workIp")) || parm.get("workIp") == null) {
                parm.put("workIp", loginIp);
            }
            // loginIp or workIp 값이 없을경우 요청자 IP로 셋팅 - End
            
            List<ArgoDispatchServiceVo> svcList = ArgoCtrlHelper.createVoList(parm, request);

            /* (2023.07.21) 동적 테이블 관련 설정을 위해 파라미터를 재설정한다. (HAGUANGHO) START */
            String today = DateUtil.getDate();
            for (ArgoDispatchServiceVo argoDispatchServiceVo : svcList) {
                boolean isMakeTableFlag = false;        // 모든 svcList 에 대해서 테이블 생성을 막기 위해 특정 메소드 명들만 테이블 생성을 하기 위한 Flag
                boolean isMakeDualTableFlag = false;    // 각각 다른 범주의 테이블을 생성해야 하는 경우가 있어서 _2 테이블 생성을 하기 위한 Flag
                boolean isMakeIndexTableFlag = false;   // INDEX 테이블을 생성하기 위한 Flag

                Map<String, Object> reqInput = argoDispatchServiceVo.getReqInput();
                String innerSvcName     = argoDispatchServiceVo.getSvcName();
                String innerMethodName  = argoDispatchServiceVo.getMethodName();
                String innerName        = innerSvcName + "." + innerMethodName; // innerName 은 xml 내에서 사용하는 id 가 된다.

                /* (2023.08.18) TB_REC_FILE 테이블 마킹 등록/삭제 작업 (HAGUANGHO) START */
                if ("recordFile.setRecFileMemoUpdate".equals(innerName)) {
                    String date = "";

                    Set<String> keySet = reqInput.keySet();
                    String keys = String.join("@@", keySet);

                    for (String key : keys.split("@@")) {
                        if (key.toUpperCase().contains("FMTRECDATE")) {
                            date = reqInput.get(key).toString();

                            if (key.contains("SVCCOMMONID")) {
                                key = key.substring(0, key.indexOf(".") + 1);
                            } else {
                                key = "";
                            }

                            parm.put("sDate", date);
                            parm.put("eDate", date);

                            setTbRecFileTable(parm, reqInput, "sDate", "eDate", false, true, key);

                            argoDispatchServiceVo.setReqInput(reqInput);
                        }
                    }
                }
                /* (2023.08.18) TB_REC_FILE 테이블 마킹 등록/삭제 작업 (HAGUANGHO) END */
                
                /* (2023.08.18) 상담원일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) START */
                if ("recordFile.setRecFileUserIdUpdate".equals(innerName)) {
                    Set<String> keySet = reqInput.keySet();
                    String keys = String.join("@@", keySet); 
                    
                    for (String key : keys.split("@@")) {
                        if (key.toUpperCase().contains("CALLDT")) {
                            if (key.contains("SVCCOMMONID")) {
                                key = key.substring(0, key.indexOf(".") + 1);
                            } else {
                                key = "";
                            }
                            
                            parm.put("sDate", reqInput.get(key + "callDt").toString());
                            parm.put("eDate", reqInput.get(key + "callDt").toString());
                            
                            setTbRecFileTable(parm, reqInput, "sDate", "eDate", false, true, key);
                            
                            argoDispatchServiceVo.setReqInput(reqInput);
                        }
                    }
                }
                /* (2023.08.18) 상담원일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) END */

                /* (2023.08.18) 상담원일괄변경상세 일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) START */
                if ("recordFile.setRecFileCallUserIdUpdate".equals(innerName)) {
                    Set<String> keySet = reqInput.keySet();
                    String keys = String.join("@@", keySet); 
                    
                    for (String key : keys.split("@@")) {
                        if (key.toUpperCase().contains("RECTIME")) {
                            if (key.contains("SVCCOMMONID")) {
                                key = key.substring(0, key.indexOf(".") + 1);
                            } else {
                                key = "";
                            }
                            
                            parm.put("sDate", reqInput.get(key + "recTime").toString());
                            parm.put("eDate", reqInput.get(key + "recTime").toString());
                            
                            setTbRecFileTable(parm, reqInput, "sDate", "eDate", false, true, key);
                            
                            argoDispatchServiceVo.setReqInput(reqInput);
                        }
                    }
                }
                /* (2023.08.18) 상담원일괄변경상세 일괄변경 시 TB_REC_FILE 테이블 동적 설정을 위한 파라미터 설정 (HAGUANGHO) END */

                /* (2023.07.21) TB_REC_FILE 테이블을 여러 개 사용해야 할 경우 이 쪽 분기를 태운다. (HAGUANGHO) START */
                if ("sysCheck.getSummaryProcess".contentEquals(innerName) 
                        || "ARGOCOMMON.GETINTRORECCNTLIST".equals(innerName.toUpperCase()) 
                        || "RECSEARCH.GETRECSEARCHLIST_API".equals(innerName)
                        || "recInfo.setAppRecLogRealInsert".equals(innerName)) {
                    
                    parm.put("sDate", today);
                    parm.put("eDate", today);

                    isMakeTableFlag = true;
                    
                    if ("sysCheck.getSummaryProcess".contentEquals(innerName)) {
                        isMakeIndexTableFlag = true;
                    }
                }

                if ("sysCheck.getSummaryRecode".equals(innerName)) {
                    parm.put("sDate", DateUtil.addDays(today, -18));
                    parm.put("eDate", DateUtil.addDays(today, 18));

                    isMakeTableFlag = true;
                    
                    if ("sysCheck.getSummaryRecode".contentEquals(innerName)) {
                        isMakeIndexTableFlag = true;
                    }
                }

                if ("sysCheck.getRecCnfrmtyCnt".equals(innerName) || "sysCheck.getRecCnfrmtyList".equals(innerName)) {
                    parm.put("sDate", DateUtil.addDays(parm.get("SVCCOMMONID.findRecDate"), -1));
                    parm.put("eDate", DateUtil.addDays(parm.get("SVCCOMMONID.findRecDate"), 1));

                    isMakeTableFlag = true;
                }

                if ("recordFile.getNoSendRecFileIndexList".equals(innerName)
                        || "recordFile.getNoSendRecCount".equals(innerName)
                        || "recordFile.getNoSendRecList".equals(innerName)
                        || "recordFile.getNoSendRecCount_org".equals(innerName)
                        || "recordFile.getNoSendRecList_org".equals(innerName)
                        || "recordFile.getAPIConstList".equals(innerName)
                        || "recordFile.getAPIConstListCnt".equals(innerName)) {

                    parm.put("sDate", parm.get("SVCCOMMONID.FindSRecTime"));
                    parm.put("eDate", parm.get("SVCCOMMONID.FindERecTime"));

                    isMakeTableFlag = true;
                    
                    if ("recordFile.getNoSendRecFileIndexList".equals(innerName)
                            || "recordFile.getNoSendRecCount".equals(innerName)
                            || "recordFile.getNoSendRecList".equals(innerName)
                            || "recordFile.getNoSendRecCount_org".equals(innerName)
                            || "recordFile.getNoSendRecList_org".equals(innerName)) {
                        
                        isMakeIndexTableFlag = true;   
                    }
                }

                if ("recordFile.getRecFileList".equals(innerName)) {
                    parm.put("sDate", parm.get("SVCCOMMONID.FindSRecTime"));
                    parm.put("eDate", parm.get("SVCCOMMONID.FindERecTime"));

                    parm.put("sDate_2", parm.get("SVCCOMMONID.FindBefTime"));
                    parm.put("eDate_2", parm.get("SVCCOMMONID.FindSRecTime"));

                    isMakeTableFlag = true;
                    isMakeDualTableFlag = true;
                }

                if ("recordFile.getRecFileCallList".equals(innerName)) {
                    parm.put("sDate", parm.get("SVCCOMMONID.StartDate"));
                    parm.put("eDate", parm.get("SVCCOMMONID.EndDate"));

                    isMakeTableFlag = true;
                }

                if ("recordFile.getRecSendDetailListCnt".equals(innerName)
                        || "recordFile.getRecSendDetailList".equals(innerName)
                        || "recordFile.getRecSendDetailStat".equals(innerName)
                        || "recSearch.getRecSearchListCnt".equals(innerName)
                        || "recSearch.getRecSearchListCnt_org".equals(innerName)
                        || "recSearch.getRecSearchList".equals(innerName)
                        || "recSearch.getRecSearchList_org".equals(innerName)
                        || "recSearch.getRecSearchListCnt_Grant".equals(innerName)
                        || "recSearch.getRecSearchList_Grant".equals(innerName)
                        || "recSearch.getRecChartTimeList".equals(innerName)
                        || "recSearch.getRecGrantListCnt".equals(innerName)
                        || "recSearch.getRecGrantList".equals(innerName)
                        || "recInfo.getRecLogCount".equals(innerName)
                        || "recInfo.getRecLogList".equals(innerName)) {

                    parm.put("sDate", parm.get("SVCCOMMONID.txtDate1_From"));
                    parm.put("eDate", parm.get("SVCCOMMONID.txtDate1_To"));

                    isMakeTableFlag = true;
                    
                    if ("recSearch.getRecSearchList".equals(innerName)
                            || "recSearch.getRecSearchListCnt_org".equals(innerName)
                            || "recSearch.getRecSearchList_org".equals(innerName)
                            || "recordFile.getRecSendDetailListCnt".equals(innerName)
                            || "recordFile.getRecSendDetailList".equals(innerName)
                            || "recordFile.getRecSendDetailStat".equals(innerName)) {
                        
                        isMakeIndexTableFlag = true;   
                    }
                }

                if (isMakeTableFlag) {
                    /* parm (검색조건) 으로 넘어온 맵에 tenantId 가 있는지 체크 후 있으면 그걸 쓰고 아니면 세션에서 가져온다. */
                    String tenantId = "";
                    if (parm.containsKey("SVCCOMMONID.TenantId") || !StringUtil.isNullOrSpace(parm.get("SVCCOMMONID.TenantId"))) {
                        tenantId = parm.get("SVCCOMMONID.TenantId");
                    } else {
                        tenantId = sessionMAP.get("tenantId").toString();
                    }

                    /* parm (검색조건) 으로 넘어온 맵에 search_visible 이 있는지 체크 후 있으면 그걸 쓰고 아니면 세션에서 가져온다. */
                    String searchVisible = "";
                    if (parm.containsKey("SVCCOMMONID.FindSearchVisible") || !StringUtil.isNullOrSpace(parm.get("SVCCOMMONID.FindSearchVisible"))) {
                        searchVisible = parm.get("SVCCOMMONID.FindSearchVisible");
                    }
                    
                    this.setTbRecFileTable(parm, reqInput, "sDate", "eDate", false, false, null);
                    if (isMakeDualTableFlag) setTbRecFileTable(parm, reqInput, "sDate_2", "eDate_2", true, false, null);
                    
                    argoDispatchServiceVo.setReqInput(reqInput);
                }
                
                if (isMakeIndexTableFlag) {
                    setTbRecFileIndexTable(parm, reqInput, "sDate", "eDate");
                }
                /* (2023.07.21) TB_REC_FILE 테이블을 여러 개 사용해야 할 경우 이 쪽 분기를 태운다. (HAGUANGHO) END */
            }
            /* (2023.07.21) 동적 테이블 관련 설정을 위해 파라미터를 재설정한다. (HAGUANGHO) END */

            argoDispatchServiceImpl.execute(svcList);

            resultMap.put(Constant.RESULT_CODE, Constant.RESULT_CODE_OK);

            for (ArgoDispatchServiceVo argoServiceVO : svcList) {
                // SQL 페이지 관련 -> NULL을 공백으로 수정 , json 변환 시 에러관련
                if (methodName.equals("MT.GETROWLIST") || methodName.equals("MT.GETDMLLIST")) {
                    for (int i = 0; i < ((List) argoServiceVO.getResOut()).size(); i++) {
                        EgovMap egovMap = (EgovMap) ((List) argoServiceVO.getResOut()).get(i);
                        for (int j = 0; j < egovMap.size(); j++) {
                            egovMap.put(egovMap.get(j), egovMap.getValue(j) != null ? egovMap.getValue(j).toString() : "");
                        }
                    }
                }

                // 현재장애로그 삭제
                if ("COMBOBOXCODE.GETOSUIPLIST".equals(methodName)) {
                    String updateType = parm.get("SVCCOMMONID.updateType");
                    if (("N").equals(updateType)) {
                        CurErrDeleteRealReq(request, response, parm, argoServiceVO);
                    }
                }

                // 사용자정보,내선번호 실시간적용 요청
                if ("COMBOBOXCODE.GETMRUPROCESSLIST".equals(methodName)) {
                    ProcInfoRealtimeReq(request, response, parm, argoServiceVO);
                }

                if ("COMBOBOXCODE.GETVSSPROCESSLIST".equals(methodName)) {
                    ProcInfoRealtimeReq(request, response, parm, argoServiceVO);
                }

                // setSession() 실행 후 rsa session key가 삭제 되는 현상으로 인해 받아온 session key 셋팅
                PrivateKey sessionRsaPk = (PrivateKey) request.getSession().getAttribute("__rsaPrivateKey__");

                HashMap<String, Object> svcResultMap = new HashMap();
                svcResultMap.put("rows", argoServiceVO.getResOut());
                svcResultMap.put(Constant.SVC_TOT_CNT, String.valueOf(argoServiceVO.getTotCnt()));
                svcResultMap.put(Constant.SVC_PROC_CNT, String.valueOf(argoServiceVO.getProCnt()));
                svcResultMap.put(Constant.SVC_OUT_TYPE, String.valueOf(argoServiceVO.getOutType()));
                svcResultMap.put(Constant.SVC_OUT_NAME, String.valueOf(argoServiceVO.getOutName()));
                resultMap.put(argoServiceVO.getSvcId(), svcResultMap);

                //
                ArgoCtrlHelper.setSession(request, response, argoServiceVO);

                // setSession() 실행 후 rsa session key가 삭제 되는 현상으로 인해 받아온 session key 셋팅
                request.getSession().setAttribute("__rsaPrivateKey__", sessionRsaPk);


            }
        }
        catch (MessageException me) {
            StackTraceElement l = me.getStackTrace()[0];

            try {
                String configLogUse = (String) configLoader.get("AppConfig.SystemLogMonitorViewUse");
                if (configLogUse.trim().equals("true")) {
                    resultMap.put(Constant.RESULT_SUB_MSG, me.getSubMessage() + "\n" + l.getClassName() + "."
                            + l.getMethodName() + " (line:" + l.getLineNumber() + ")");
                } else {
                    resultMap.put(Constant.RESULT_SUB_MSG, "");
                }
                
                loMeLogger.error("Exception : " + me.toString());
            } catch (IOException ie) {
                loMeLogger.error("Exception : " + ie.toString());
            } catch (Exception e) {
                e.printStackTrace();
                loMeLogger.error("Exception : " + e.toString());
            }

            resultMap.put(Constant.RESULT_CODE, me.getArgoCode());
            resultMap.put(Constant.RESULT_MSG, me.getArgoMessage(egovMessageSource));
            resultMap.put(Constant.RESULT_SUB_CODE, me.getSubCode());
        } finally {
            if(fis != null) { fis.close(); }
        }

        // Response  Write
        ArgoCtrlHelper.print(response, resultMap);

        loMeLogger.info("working? : invloke() end ================================================ ");
    }


    /****** 함수들 ************************************************************/

    /**
     * 라이센스 Module 사용여부 암호화 값이랑 비교
     */
    /*
     * @RequestMapping("/common/chkMenuList.do")
     *
     * @ResponseBody public net.sf.json.JSONObject
     * chkMenuList(@RequestParam("tenantId") String tenantId) throws ParseException{
     * net.sf.json.JSONObject jsonObj = new net.sf.json.JSONObject();
     * ArgoDispatchServiceVo saDispatchServiceVo = new
     * ArgoDispatchServiceVo("SVCCOMMONID");
     * saDispatchServiceVo.setSvcType("ARGODB");
     * saDispatchServiceVo.setSvcName("ARGOCOMMON");
     * saDispatchServiceVo.setDbType("S"); HashMap<String, Object> reqInput = new
     * HashMap<>(); reqInput.put("tenantId", tenantId);
     * saDispatchServiceVo.setReqInput(reqInput);
     * saDispatchServiceVo.setMethodName("SP_UC_CHK_MENU_LIST");
     * List<ArgoDispatchServiceVo> svcList = new ArrayList<>();
     * svcList.add(saDispatchServiceVo); try {
     * argoDispatchServiceImpl.excute(svcList); Map<String, Object> map =
     * (Map<String, Object>) saDispatchServiceVo.getResOut(); String module="";
     * if(map.get("cm").toString().equals("1")) module+="CM";
     * if(map.get("hr").toString().equals("1")) module+="HR";
     * if(map.get("qa").toString().equals("1")) module+="QA";
     * if(map.get("edu").toString().equals("1")) module+="EDU";
     * if(map.get("kpi").toString().equals("1")) module+="KPI";
     *
     * if(SHA512Util.SHA512(module).equals(map.get("enc").toString())){
     * jsonObj.put("module", module); jsonObj.put("flag", "Y"); }else{ //
     * jsonObj.put("module", ""); jsonObj.put("msg", "라이센스 정보가 임의로 변경되었습니다.");
     * jsonObj.put("flag", "N"); }
     *
     * } catch (MessageException e) {
     *
     * e.printStackTrace(); } catch (NoSuchAlgorithmException e) {
     *
     * e.printStackTrace(); } catch (UnsupportedEncodingException e) {
     *
     * e.printStackTrace(); } return jsonObj; }
     */
    private void CurErrDeleteRealReq(HttpServletRequest req, HttpServletResponse res, Map<String, String> parm, ArgoDispatchServiceVo argoServiceVO) throws Exception {

        // String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
        // SortProperties properties = new SortProperties();
        // properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
        // String dbKind = properties.getProperty("Globals.ARGO.RDB.Kind").trim();
        String dbKind = "ORACLE";

        res.setContentType("text/html; charset=utf-8");
        PrintWriter out = res.getWriter();

        try {

            loMeLogger.info("########### OSU start (err)##########");

            String errKey = parm.get("SVCCOMMONID.errKey");
            short systemId = Short.parseShort(parm.get("SVCCOMMONID.systemId"));
            short processId = Short.parseShort(parm.get("SVCCOMMONID.processId"));

            int desPort = 7030;
            String desIp;
            int desSysId;
            // int desProcId;

            Destination des = new Destination();
            SocketClient client = new OSUClient();

            loMeLogger.debug("OSU IP size :: " + ((List) argoServiceVO.getResOut()).size());

            for (int i = 0; i < ((List) argoServiceVO.getResOut()).size(); i++) {

                EgovMap egovMap = (EgovMap) ((List) argoServiceVO.getResOut()).get(i);

                desIp = (String) egovMap.get("code");
                if ("ORACLE".equals(dbKind) || "TIBERO".equals(dbKind)) {
                    desSysId = Integer.parseInt(String.valueOf(egovMap.get("codeNm") + ""));
                } else {
                    desSysId = (int) egovMap.get("codeNm");
                }

                des.setPort(desPort);
                des.setIp(desIp);
                des.setSystemId(desSysId);
                des.setProcessId(processId);

                // 전송 메시지 생성
                loMeLogger.debug("##### 전송메시지 생성");
                List<Message> msgList = new ArrayList<Message>();
                OSUBody_2800 body = null;

                body = new OSUBody_2800();
                body.setDelKind((short) 3);
                body.setErrKey(errKey);
                body.setSystemId(systemId);
                body.setProcessId(processId);

                OSUHeader header = new OSUHeader();
                header.setCommand(OSUHeader.OAM_CLIENT_CUR_ERR_DEL_REQ);
                header.setTxId(TIDSeqManager.getInstance().getNextSeq());
                header.setLength(body.getBodyLen());

                loMeLogger.debug("== body   | delkind   :: " + (short) 3);
                loMeLogger.debug("== body   | errkey    :: " + errKey);
                loMeLogger.debug("== body   | systemId  :: " + body.getSystemId());
                loMeLogger.debug("== body   | processId :: " + body.getProcessId());
                loMeLogger.debug("== header | command   :: " + header.getCommand());
                loMeLogger.debug("== header | txid      :: " + header.getTxId());
                loMeLogger.debug("== header | length    :: " + header.getLength());

                msgList.add(new Message(header, body, OSUBody_Ack_2800.class));

                // Destination 생성
                loMeLogger.debug("##### destination 생성");
                List<Message> sendDataList = new ArrayList<Message>();

                for (int j = 0; j < msgList.size(); j++) {
                    Message msg = msgList.get(j);
                    msg.setDestination(des);
                    sendDataList.add(msg.clone());

                    loMeLogger.debug("== destination | ousPort  :: " + des.getPort());
                    loMeLogger.debug("== destination | ip       :: " + des.getIp());
                    loMeLogger.debug("== destination | processId:: " + des.getProcessId());
                    loMeLogger.debug("== destination | systemId :: " + des.getSystemId());
                }

                loMeLogger.debug("sendDataList.size() = " + sendDataList.size());
                if (sendDataList.size() < 1) {
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("resultData", "0001");
                    jsonObj.put("resultMsg", URLEncoder.encode("요청할 대상 시스템이 존재하지 않습니다", "UTF-8"));
                    out.print(jsonObj);
                    out.close();
                }

                // 메시지 전송 및 수신
                loMeLogger.debug("##### 메시지 전송 및 수신 시작");
                Message[] ackList = client.send(SocketClient.BYTE_ORDER_LITTLE,
                        sendDataList.toArray(new Message[sendDataList.size()]));
                loMeLogger.debug("##### 메시지 전송 및 수신 끝");

                // Ack 검사
                loMeLogger.debug("##### ack검사");
                StringBuffer errMsg = new StringBuffer();
                // String [] result = new String[ackList.length];

                int erroCnt = 0;
                for (int k = 0; k < ackList.length; k++) {
                    OSUBody_Ack_2800 ack = (OSUBody_Ack_2800) ackList[k].getBody();

                    if (!("0000".equals(ack.getResult())
                            || ack.getMsg().contains("inputstream has returned an unexpected EOF"))) {
                        if (errMsg.length() > 0) {
                            errMsg.append(", \\n");
                        }
                        errMsg.append(ack.getMsg());
                        erroCnt++;
                    }
                }

                // 결과 디스플레이
                loMeLogger.debug("##### 결과디스플레이");
                if (erroCnt > 0) {
                    throw new InterfaceException(errMsg.toString());
                } else {
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("resultData", "0000");
                    out.print(jsonObj);
                    out.close();
                }
            }

            loMeLogger.info("########## OSU end ##########");

        } catch (InterfaceException ife) {
            loMeLogger.error("Exception=" + ife);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("resultData", "0001");
            jsonObj.put("resultMsg", URLEncoder.encode(ife.getMessage(), "UTF-8"));
            out.print(jsonObj);
            out.close();
        } catch (Exception e) {
            loMeLogger.error("Exception=" + e);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("resultData", "0001");
            jsonObj.put("resultMsg", URLEncoder.encode(e.getMessage(), "UTF-8"));
            out.print(jsonObj);
            out.close();
        } finally {
            out.close();
        }
    }

    private void ProcInfoRealtimeReq(HttpServletRequest req, HttpServletResponse res, Map<String, String> parm, ArgoDispatchServiceVo argoServiceVO) throws Exception {

        res.setContentType("text/html; charset=utf-8");
        PrintWriter out = res.getWriter();

        try {

            loMeLogger.info("########### OSU start (user)##########");

            // updateType : 1(내선번호), 2(상담원)
            short updateType = Short.parseShort(parm.get("SVCCOMMONID.updateType"));
            String desIp = parm.get("SVCCOMMONID.code");
            int desSysId = Integer.parseInt(parm.get("SVCCOMMONID.codeNm"));
            // int desProcId;
            int desPort = 7030;

            Destination des = new Destination();
            SocketClient client = new OSUClient();

            loMeLogger.debug("OSU IP size :: " + ((List) argoServiceVO.getResOut()).size());

            des.setPort(desPort);
            des.setIp(desIp);
            des.setSystemId(desSysId);
            // des.setProcessId(processId);

            short systemId;
            short processId;

            for (int i = 0; i < ((List) argoServiceVO.getResOut()).size(); i++) {

                EgovMap egovMap = (EgovMap) ((List) argoServiceVO.getResOut()).get(i);

                systemId = Short.parseShort(egovMap.get("systemId").toString());
                processId = Short.parseShort(egovMap.get("processId").toString());

                // 전송 메시지 생성
                loMeLogger.debug("##### 전송메시지 생성");
                List<Message> msgList = new ArrayList<Message>();
                OSUBody_3020 body = null;

                body = new OSUBody_3020();
                body.setSystemId(systemId);
                body.setProcessId(processId);
                body.setUpdateType(updateType);

                OSUHeader header = new OSUHeader();
                header.setCommand(OSUHeader.CMD_REALTIME_USER_DN_REQ);
                header.setTxId(TIDSeqManager.getInstance().getNextSeq());
                header.setLength(body.getBodyLen());

                loMeLogger.debug("== body   | updateType:: " + body.getUpdateType());
                loMeLogger.debug("== body   | systemId  :: " + body.getSystemId());
                loMeLogger.debug("== body   | processId :: " + body.getProcessId());
                loMeLogger.debug("== header | command   :: " + header.getCommand());
                loMeLogger.debug("== header | txid      :: " + header.getTxId());
                loMeLogger.debug("== header | length    :: " + header.getLength());

                msgList.add(new Message(header, body, OSUBody_Ack_3020.class));

                // Destination 생성
                loMeLogger.debug("##### destination 생성");
                List<Message> sendDataList = new ArrayList<Message>();

                for (int j = 0; j < msgList.size(); j++) {
                    Message msg = msgList.get(j);
                    msg.setDestination(des);
                    sendDataList.add(msg.clone());

                    loMeLogger.debug("== destination | ousPort  :: " + des.getPort());
                    loMeLogger.debug("== destination | ip       :: " + des.getIp());
                    loMeLogger.debug("== destination | processId:: " + des.getProcessId());
                    loMeLogger.debug("== destination | systemId :: " + des.getSystemId());
                }

                loMeLogger.debug("sendDataList.size() = " + sendDataList.size());
                if (sendDataList.size() < 1) {
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("resultData", "0001");
                    jsonObj.put("resultMsg", URLEncoder.encode("요청할 대상 시스템이 존재하지 않습니다", "UTF-8"));
                    out.print(jsonObj);
                    out.close();
                }

                // 메시지 전송 및 수신
                loMeLogger.debug("##### 메시지 전송 및 수신 시작");
                Message[] ackList = client.send(SocketClient.BYTE_ORDER_LITTLE,
                        sendDataList.toArray(new Message[sendDataList.size()]));
                loMeLogger.debug("##### 메시지 전송 및 수신 끝");

                // Ack 검사
                loMeLogger.debug("##### ack검사");
                StringBuffer errMsg = new StringBuffer();
                // String [] result = new String[ackList.length];

                int erroCnt = 0;
                for (int k = 0; k < ackList.length; k++) {
                    OSUBody_Ack_3020 ack = (OSUBody_Ack_3020) ackList[k].getBody();

                    if (!("0000".equals(ack.getResult())
                            || ack.getMsg().contains("inputstream has returned an unexpected EOF"))) {
                        if (errMsg.length() > 0) {
                            errMsg.append(", \\n");
                        }
                        errMsg.append(ack.getMsg());
                        erroCnt++;
                    }
                }

                // 결과 디스플레이
                loMeLogger.debug("##### 결과디스플레이");
                if (erroCnt > 0) {
                    throw new InterfaceException(errMsg.toString());
                } else {
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("resultData", "0000");
                    out.print(jsonObj);
                    out.close();
                }
            }

            loMeLogger.info("########## OSU end ##########");

        } catch (InterfaceException ife) {
            loMeLogger.error("Exception=" + ife);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("resultData", "0001");
            jsonObj.put("resultMsg", URLEncoder.encode(ife.getMessage(), "UTF-8"));
            out.print(jsonObj);
            out.close();
        } catch (Exception e) {
            loMeLogger.error("Exception=" + e);
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("resultData", "0001");
            jsonObj.put("resultMsg", URLEncoder.encode(e.getMessage(), "UTF-8"));
            out.print(jsonObj);
            out.close();
        } finally {
            out.close();
        }
    }

    // 암복호화 (회사, 암복호구분, 고객번호(전화)구분, 변환문자)
    private String getStrCrypt(String strSiteKind, String strType, String strFlag, String strText, String seed) {
        String strValue = "";
        AESUtil aesUtil = new AESUtil();

        try {
            if (strText == null || strText.equals("")) {
                strValue = "";
            } else if (seed == null || seed.equals("null")) {
                if ("enc".equals(strType)) {
                    strValue = aesUtil.encrypt(strText);
                } else {
                    strValue = aesUtil.decrypt(strText);
                }
            } else {
//                  aesUtil.setKey("BRIDGETEC_VELOCE", Constant.ME_SHARED_BIT);
                String deSeed = aesUtil.decrypt(seed);
                aesUtil.setKey(deSeed, Constant.ME_SHARED_BIT);
                if ("BNK".equals(strSiteKind)) { // 부산은행 암복호화
                    if ("enc".equals(strType)) {
                        if ("custNo".equals(strFlag)) {
                            strValue = CSNcrypt.Encrypt(StringUtility.nvl(strText, ""));
                        } else if ("custTel".equals(strFlag)) {
                            strValue = CSNcrypt.TELcrypt(CSNcrypt.ENCRYPT, StringUtility.nvl(strText, ""));
                        } else {
                            strValue = strText;
                        }
                    } else {
                        if ("custNo".equals(strFlag)) {
                            strValue = CSNcrypt.Decrypt(StringUtility.nvl(strText, ""));
                        } else if ("custTel".equals(strFlag) || "custEtc1".equals(strFlag)) {
                            strValue = CSNcrypt.TELcrypt(CSNcrypt.DECRYPT, StringUtility.nvl(strText, ""));
                        } else {
                            strValue = strText;
                        }
                    }
                } else { // 일반 암복호화
                    if ("enc".equals(strType)) {
                        if ("custNo".equals(strFlag) || "custTel".equals(strFlag)) {
                            strValue = aesUtil.encrypt(strText.trim());
                        } else {
                            strValue = strText;
                        }
                    } else {
                        if ("custNo".equals(strFlag) || "custTel".equals(strFlag)) {
                            strValue = aesUtil.decrypt(strText);
                        } else {
                            strValue = strText;
                        }
                    }
                }
                aesUtil.setKey("BRIDGETEC_VELOCE", Constant.ME_SHARED_BIT);
            }
        } catch (IllegalArgumentException iae) {
            loMeLogger.error("Exception : " + iae.toString());
            return strText;
        } catch (Exception ex) {
            loMeLogger.error("Exception : " + ex.toString());
            return strText;
        }
        return strValue;
    }


    @RequestMapping("/veloceRest/{api}.do")
    @ResponseBody
    public JSONObject restList(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> parm, @PathVariable String api) {
        loMeLogger.info(">>>>>==================== veloce rest start ====================");
        loMeLogger.info(">>>>>===== request ip : " + request.getRemoteAddr());
        loMeLogger.info(">>>>>===== request api : " + api);
        loMeLogger.info(">>>>>===== request parm : " + parm);

        JSONObject jsonObj = new JSONObject();
        
        
        String flag = (parm.get("flag") == null) ? "" : parm.get("flag").toString();
        String message = "";
        String excStr = "";
        String dbType = "";
        
        if("I".equals(flag)) {
            message = "요청(신규)";
            excStr = "Insert";
            dbType = flag;
        } else if("U".equals(flag)) {
            message = "요청(수정)";
            excStr = "Update";
            dbType = flag;
        } else if("D".equals(flag)) {
            message = "요청(삭제)";
            excStr = "Delete";
            dbType = flag;
        } else if("EXST".equals(flag)) {
            message = "존재여부";
            excStr = "ExstYn";
            dbType = "S";
        } else {
            flag = "L";
            message = "데이터 조회";
            excStr = "Select";
            dbType = flag;
        }
            
        ArgoDispatchServiceVo argoDispatchServiceVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
        argoDispatchServiceVo.setSvcType("ARGODB");
        argoDispatchServiceVo.setDbType(dbType);
        argoDispatchServiceVo.setSvcName("rest");
        argoDispatchServiceVo.setMethodName(api+excStr);

        HashMap<String, Object> reqInput = new HashMap<String, Object>();
        
        reqInput.put("tenantId", EgovStringUtil.null2void(parm.get("tenantId")).toString());

        if("tenant".equals(api)) {
            reqInput.put("tenantName", EgovStringUtil.null2void(parm.get("tenantName")).toString());
            reqInput.put("agentCount", EgovStringUtil.null2void(parm.get("agentCount")).toString());
            reqInput.put("managerCount", EgovStringUtil.null2void(parm.get("dnCount")).toString());
            reqInput.put("basePath", EgovStringUtil.null2void(parm.get("basePath")).toString());
            
            String expireReason = EgovStringUtil.null2void(parm.get("expireReason")).toString();
            if("".equals(expireReason)) {
                expireReason = "swat : request delete";
            }
            
            reqInput.put("expireReason", expireReason);
        } else if("group".equals(api)) {
            reqInput.put("groupId", EgovStringUtil.null2void(parm.get("groupId")).toString());
            reqInput.put("groupName", EgovStringUtil.null2void(parm.get("groupName")).toString());
            reqInput.put("parentId", EgovStringUtil.null2void(parm.get("parentId")).toString());
            reqInput.put("groupDesc", EgovStringUtil.null2void(parm.get("groupDesc")).toString());
        } else if("user".equals(api)) {
            reqInput.put("userId", EgovStringUtil.null2void(parm.get("userId")).toString());
            reqInput.put("userName", EgovStringUtil.null2void(parm.get("userName")).toString());
            reqInput.put("groupId", EgovStringUtil.null2void(parm.get("groupId")).toString());
            
            try {
                EncryptUtil encp = new EncryptUtil();
                
                byte[] bSalt = null;
                byte[] bDigest = null;
                String salt = "";
                String user_pwd = "";
                String encrptPwd = "";
                
                if("I".equals(flag)) {
                    user_pwd = (EgovStringUtil.null2void(parm.get("userPwd")).toString().trim() == "") ? "1" : parm.get("userPwd").toString();

                    bSalt = encp.getSaltData();
//                  bDigest = encp.getEncSaltData("SHA-512", user_pwd, bSalt, false);
                    bDigest = encp.getEncSaltData(SHA_TYPE, user_pwd, bSalt, false);
                    
                    salt = encp.byteToBase64(bSalt);
                    encrptPwd = encp.byteToBase64(bDigest);

                    reqInput.put("userPwd", encrptPwd);
                    reqInput.put("salt", salt);
                } else if("U".equals(flag) && !"".equals(EgovStringUtil.null2void(parm.get("userPwd")).toString().trim())) {
                    
                    ArgoDispatchServiceVo reqUserInfoVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                    reqUserInfoVo.setSvcType("ARGODB");
                    reqUserInfoVo.setSvcName("ARGOCOMMON");
                    reqUserInfoVo.setDbType("S");
                    reqUserInfoVo.setMethodName("login");

                    HashMap<String, Object> reqUserInfoInput = new HashMap<>();
                    reqUserInfoInput.put("tenantId", EgovStringUtil.null2void(parm.get("tenantId")).toString());
                    reqUserInfoInput.put("agentId", EgovStringUtil.null2void(parm.get("userId")).toString());

                    reqUserInfoVo.setReqInput(reqUserInfoInput);

                    List<ArgoDispatchServiceVo> reqUserInfoSvcList = new ArrayList<>();
                    reqUserInfoSvcList.add(reqUserInfoVo);

                    argoDispatchServiceImpl.execute(reqUserInfoSvcList);
                    
                    if(reqUserInfoVo.getResOut() == null) {
                        jsonObj.put("code", "999");
                        jsonObj.put("message", "상담사 정보가 존재하지 않습니다.");

                        return jsonObj;
                    }

                    salt = String.valueOf(((EgovMap) reqUserInfoVo.getResOut()).get("salt"));
                    user_pwd = parm.get("userPwd").toString();
                    
                    bSalt = encp.base64ToByte(salt);
//                  bDigest = encp.getEncSaltData("SHA-512", user_pwd, bSalt, false);
                    bDigest = encp.getEncSaltData(SHA_TYPE, user_pwd, bSalt, false);

                    encrptPwd = encp.byteToBase64(bDigest);

                    reqInput.put("userPwd", encrptPwd);
                }
                
            } catch(IOException ie) {
                jsonObj.put("code", "999");
                jsonObj.put("message", "비밀번호 변환 오류");
                
                return jsonObj;
            } catch(Exception e) {
                jsonObj.put("code", "999");
                jsonObj.put("message", "비밀번호 변환 오류");
                
                return jsonObj;
            }
            
            if("I".equals(flag)) {
                reqInput.put("grantId", (parm.get("grantId") == null) ? "Agent" : parm.get("grantId").toString());
            } else if("U".equals(flag) && !"".equals(EgovStringUtil.null2void(parm.get("grantId")).toString().trim())) {
                reqInput.put("grantId", parm.get("grantId").toString());
            }
            
            if(!"".equals(EgovStringUtil.null2void(parm.get("retireeFlag")).toString().trim())) {
                reqInput.put("retireeFlag", parm.get("retireeFlag").toString());
            }
            
        } else if("dn".equals(api)) {
            reqInput.put("dnNo", EgovStringUtil.null2void(parm.get("dnNo")).toString());
            reqInput.put("phoneIp", EgovStringUtil.null2void(parm.get("phoneIp")).toString());
            reqInput.put("userId", EgovStringUtil.null2void(parm.get("userId")).toString());
            reqInput.put("userIp", EgovStringUtil.null2void(parm.get("userIp")).toString());
        } else if("recInfo".equals(api)) {
            String sDate = EgovStringUtil.null2void(parm.get("startDate")).toString();
            String sTime = EgovStringUtil.null2void(parm.get("startTime")).toString();
            String eDate = EgovStringUtil.null2void(parm.get("endDate")).toString();
            String eTime = EgovStringUtil.null2void(parm.get("endTime")).toString();
            
            try {
                if( Long.parseLong(eDate+eTime) > Long.parseLong(DateUtil.addDays(sDate, 1, "yyyyMMdd")+sTime) ) {
                    jsonObj.put("code", "999");
                    jsonObj.put("message", "조회 기간은 1일을 넘길 수 없습니다.");
                    
                    return jsonObj;
                }
            } catch(ParseException e) {
                jsonObj.put("code", "999");
                jsonObj.put("message", "날자 형식 오류");
                
                return jsonObj;
            }
            
//          reqInput.put("tenantId", EgovStringUtil.null2void(parm.get("tenantId")).toString());
            reqInput.put("startDate", sDate);
            reqInput.put("startTime", sTime);
            reqInput.put("endDate", eDate);
            reqInput.put("endTime", eTime);
            reqInput.put("agentId", EgovStringUtil.null2void(parm.get("agentId")).toString());
            reqInput.put("dnNo", EgovStringUtil.null2void(parm.get("dnNo")).toString());
        }
            
        reqInput.put("reqSystem", request.getRemoteAddr());

        argoDispatchServiceVo.setReqInput(reqInput);

        List<ArgoDispatchServiceVo> reqVeloceRestList = new ArrayList<>();
        reqVeloceRestList.add(argoDispatchServiceVo);
            
        try {
            argoDispatchServiceImpl.execute(reqVeloceRestList);

            jsonObj.put("code", "200");
            jsonObj.put("message", message+" 성공");
            
            if("L".equals(flag)) {
                if(argoDispatchServiceVo.getResOut() != null) {
                    jsonObj.put("count", ((ArrayList) argoDispatchServiceVo.getResOut()).size());
                    
                    // result null value to empty string
                    for(int i=0 ; i < ((ArrayList) argoDispatchServiceVo.getResOut()).size() ; i++) {
                        EgovMap dataMap = (EgovMap) ((ArrayList) argoDispatchServiceVo.getResOut()).get(i);
                        
                        Set<Map.Entry<String, Object>> entries = dataMap.entrySet();
                        for(Map.Entry<String, Object> entry : entries) {
                            if(entry.getValue() == null) {
                                ((EgovMap) ((ArrayList) argoDispatchServiceVo.getResOut()).get(i)).put(entry.getKey(), "");
                            }
                        }
                    }
                } else {
                    jsonObj.put("count", 0);
                }
                
                jsonObj.put("data", argoDispatchServiceVo.getResOut());
            } else if("EXST".equals(flag)) {
                if(argoDispatchServiceVo.getResOut() != null) {
                    jsonObj.put("exstYn", String.valueOf(((EgovMap) argoDispatchServiceVo.getResOut()).get("exstYn")));
                    
                    if("user".equals(api)) {
                        jsonObj.put("retireYn", String.valueOf(((EgovMap) argoDispatchServiceVo.getResOut()).get("retireYn")));
                    }
                } else {
                    jsonObj.put("exstYn", "");
                    jsonObj.put("retireYn", "");
                }
            }

        } catch (IllegalArgumentException iae) {
            jsonObj.put("code", "999");
            jsonObj.put("message", message + " 실패");
        } catch (Exception e) {
            jsonObj.put("code", "999");
            jsonObj.put("message", message + " 실패");
        }

//System.out.println(">>>>>===== return : " + jsonObj);
//      System.out.println(">>>>>==================== veloce rest end ====================");
        loMeLogger.info(">>>>>==================== veloce rest end ====================");

        return jsonObj;
    }
    
    @RequestMapping("/gubunRest/{api}.do")
    @ResponseBody
    public JSONObject gubunRest(HttpServletRequest request, HttpServletResponse response, @RequestBody Map<String, String> parm, @PathVariable String api) {
        loMeLogger.info(">>>>>==================== gubun rest start ====================");
        loMeLogger.info(">>>>>===== request ip : " + request.getRemoteAddr());
        loMeLogger.info(">>>>>===== request api : " + api);
        loMeLogger.info(">>>>>===== request parm : " + parm);

        JSONObject jsonObj = new JSONObject();
        String message = "";
        
        try {
            HashMap<String, Object> reqInput = new HashMap<String, Object>();
            reqInput.put("gubunCode", EgovStringUtil.null2void(parm.get("szTenantID")).toString());
            reqInput.put("workId", EgovStringUtil.null2void(parm.get("szWorkID")).toString());
        
            if("setGubunInfo".equals(api)) {
                if("".equals(EgovStringUtil.null2void(parm.get("szTenantID")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szTenantName")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szGubunPath")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szDeletePath")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szGubunFlag")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szDeleteFlag")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szStorageDay")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szStorageVolumn")).toString())
                ) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else {
                    reqInput.put("gubunName", EgovStringUtil.null2void(parm.get("szTenantName")).toString());
                    reqInput.put("gubunPath", EgovStringUtil.null2void(parm.get("szGubunPath")).toString());
                    reqInput.put("deletePath", EgovStringUtil.null2void(parm.get("szDeletePath")).toString());
                    reqInput.put("gubunUseFlag", EgovStringUtil.null2void(parm.get("szGubunFlag")).toString());
                    reqInput.put("deleteUseFlag", EgovStringUtil.null2void(parm.get("szDeleteFlag")).toString());
                    reqInput.put("storageDay", EgovStringUtil.null2void(parm.get("szStorageDay")).toString());
                    reqInput.put("storageVolumn", EgovStringUtil.null2void(parm.get("szStorageVolumn")).toString());
                    
                    ArgoDispatchServiceVo getGubunCodeCntVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                    getGubunCodeCntVo.setSvcType("ARGODB");
                    getGubunCodeCntVo.setDbType("S");
                    getGubunCodeCntVo.setSvcName("gubunRest");
                    getGubunCodeCntVo.setMethodName("getGubunCodeCnt");
                    
                    getGubunCodeCntVo.setReqInput(reqInput);
        
                    List<ArgoDispatchServiceVo> reqGubunCodeCntList = new ArrayList<>();
                    reqGubunCodeCntList.add(getGubunCodeCntVo);
    
                    argoDispatchServiceImpl.execute(reqGubunCodeCntList);
                
                    ArgoDispatchServiceVo setGubunCodeVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                    setGubunCodeVo.setSvcType("ARGODB");
                    setGubunCodeVo.setSvcName("gubunRest");
        
                    if(getGubunCodeCntVo.getResOut() == null || Integer.parseInt(String.valueOf(((EgovMap) getGubunCodeCntVo.getResOut()).get("cnt"))) == 0) {
                        setGubunCodeVo.setDbType("I");
                        setGubunCodeVo.setMethodName("insertGubunCode");
                        message = "분류 설정 등록";
                    } else {
                        setGubunCodeVo.setDbType("U");
                        setGubunCodeVo.setMethodName("updateGubunCode");
                        message = "분류 설정 수정";
                    }
                    
                    setGubunCodeVo.setReqInput(reqInput);
    
                    List<ArgoDispatchServiceVo> setGubunCodeInfo = new ArrayList<>();
                    setGubunCodeInfo.add(setGubunCodeVo);
                    
                    argoDispatchServiceImpl.execute(setGubunCodeInfo);
                    
                    jsonObj.put("code", "0000");
                    jsonObj.put("message", message+" 성공");
                }
            } else if("getGubunVolumn".equals(api) || "getDnVolumn".equals(api)) {
                if("".equals(EgovStringUtil.null2void(parm.get("szTenantID")).toString())
//                  || "".equals(EgovStringUtil.null2void(parm.get("szReqStartDate")).toString())
//                  || "".equals(EgovStringUtil.null2void(parm.get("szReqEndDate")).toString())
                ) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else if("getDnVolumn".equals(api) && "".equals(EgovStringUtil.null2void(parm.get("szDnNo")).toString())) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else {
                    message = "데이터 조회";
                    reqInput.put("reqStartDate", EgovStringUtil.null2void(parm.get("szReqStartDate")).toString());
                    reqInput.put("reqEndDate", EgovStringUtil.null2void(parm.get("szReqEndDate")).toString());
                    
                    if("getDnVolumn".equals(api)) {
                        reqInput.put("dnNo", EgovStringUtil.null2void(parm.get("szDnNo")).toString());
                    } else {
                        reqInput.put("dnNo", "");
                    }
                    
                    ArgoDispatchServiceVo getVolumnVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                    getVolumnVo.setSvcType("ARGODB");
                    getVolumnVo.setDbType("L");
                    getVolumnVo.setSvcName("gubunRest");
                    getVolumnVo.setMethodName("getVolumn");
                    
                    getVolumnVo.setReqInput(reqInput);
        
                    List<ArgoDispatchServiceVo> reqVolumnList = new ArrayList<>();
                    reqVolumnList.add(getVolumnVo);
    
                    argoDispatchServiceImpl.execute(reqVolumnList);
                    
//                  if(getVolumnVo.getResOut() == null || ((EgovMap) getVolumnVo.getResOut()).get("useVolumn") == null) {
                    if(((ArrayList) getVolumnVo.getResOut()).size() == 0) {
                        jsonObj.put("code", "1201");
                        jsonObj.put("message", "데이터 미존재");
                    } else {
                        jsonObj.put("code", "0000");
                        jsonObj.put("message", "데이터 조회 성공");
//                      jsonObj.put("useVolumn", String.valueOf(((EgovMap) getVolumnVo.getResOut()).get("useVolumn")));
//                      jsonObj.put("data1", getVolumnVo.getResOut());
                        
                        EgovMap returnMap = new EgovMap();
                        int totVolumn = 0;
                        for(int i=0 ; i < ((ArrayList) getVolumnVo.getResOut()).size() ; i++) {
                            EgovMap dataMap = (EgovMap) ((ArrayList) getVolumnVo.getResOut()).get(i);
                            
                            returnMap.put(dataMap.get("gubunTime"), EgovStringUtil.string2integer(dataMap.get("useVolumn").toString()));
                            
                            totVolumn += EgovStringUtil.string2integer(dataMap.get("useVolumn").toString());
                        }
                        returnMap.put("total", totVolumn);
                        
                        jsonObj.put("data", returnMap);
                    }
                }
            } else if("gubunDaysDelete".equals(api) || "dnDaysDelete".equals(api)
                        || "gubunTermDelete".equals(api) || "dnTermDelete".equals(api)
                        || "gubunVolumnDelete".equals(api) || "dnVolumnDelete".equals(api)
                    ) {
                if("".equals(EgovStringUtil.null2void(parm.get("szTenantID")).toString())) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else if(("gubunDaysDelete".equals(api) || "dnDaysDelete".equals(api)) && "".equals(EgovStringUtil.null2void(parm.get("szReqDelDay")).toString())) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else if(("gubunTermDelete".equals(api) || "dnTermDelete".equals(api))
                    && ("".equals(EgovStringUtil.null2void(parm.get("szReqStartDate")).toString()) || "".equals(EgovStringUtil.null2void(parm.get("szReqEndDate")).toString()))) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else if(("gubunVolumnDelete".equals(api) || "dnVolumnDelete".equals(api)) && "".equals(EgovStringUtil.null2void(parm.get("szReqDelVolumn")).toString())) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else if(("dnDaysDelete".equals(api) || "dnTermDelete".equals(api) || "dnVolumnDelete".equals(api)) && "".equals(EgovStringUtil.null2void(parm.get("szDnNo")).toString())) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else {
                    // 1. 가장 과거의 날자 조회 해서 삭제 기간 만들기
                    int getFirstRecDayCnt = 1;
                    message = "삭제";
                    
                    // 요청 들어온 년월일시분초 값을 reqInput에 담기
                    String reqDateTime = DateUtil.getTime();
                    reqInput.put("reqDateTime", reqDateTime);
                    
                    if("dnDaysDelete".equals(api) || "dnTermDelete".equals(api) || "dnVolumnDelete".equals(api)) {
                        reqInput.put("delTagetDn", EgovStringUtil.null2void(parm.get("szDnNo")).toString());
                    } else {
                        reqInput.put("delTagetDn", "");
                    }
                    
                    if("gubunDaysDelete".equals(api) || "dnDaysDelete".equals(api)) {
                        ArgoDispatchServiceVo getFirstRecDayVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                        getFirstRecDayVo.setSvcType("ARGODB");
                        getFirstRecDayVo.setDbType("S");
                        getFirstRecDayVo.setSvcName("gubunRest");
                        getFirstRecDayVo.setMethodName("getFirstRecDay");
                        
                        getFirstRecDayVo.setReqInput(reqInput);
            
                        List<ArgoDispatchServiceVo> getFirstRecDayList = new ArrayList<>();
                        getFirstRecDayList.add(getFirstRecDayVo);
        
                        argoDispatchServiceImpl.execute(getFirstRecDayList);
    
                        getFirstRecDayCnt = getFirstRecDayVo.getProCnt();
                        
                        int delDays = EgovStringUtil.string2integer(parm.get("szReqDelDay"));
                        
                        if(getFirstRecDayCnt > 0) {
                            String firstRecDay = getFirstRecDayVo.getResOut() == null ? "" : String.valueOf(((EgovMap) getFirstRecDayVo.getResOut()).get("firstRecDay"));
                            String lastRecDay = DateUtil.addDays(firstRecDay, delDays);
                            
                            reqInput.put("delStartDate", (firstRecDay+"000000"));
                            reqInput.put("delEndDate", (lastRecDay+"235959"));
                        }
                        reqInput.put("delTagetData", EgovStringUtil.integer2string(delDays));
                        reqInput.put("delWorkGubun", "1");
                    } else if("gubunVolumnDelete".equals(api) || "dnVolumnDelete".equals(api)) {
                        ArgoDispatchServiceVo getVolumnDelTermVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                        getVolumnDelTermVo.setSvcType("ARGODB");
                        getVolumnDelTermVo.setDbType("S");
                        getVolumnDelTermVo.setSvcName("gubunRest");
                        getVolumnDelTermVo.setMethodName("getVolumnDelTerm");
                        
                        reqInput.put("delVolumn", EgovStringUtil.null2void(parm.get("szReqDelVolumn")).toString());
                        
                        getVolumnDelTermVo.setReqInput(reqInput);
            
                        List<ArgoDispatchServiceVo> getVolumnDelTermList = new ArrayList<>();
                        getVolumnDelTermList.add(getVolumnDelTermVo);
        
                        argoDispatchServiceImpl.execute(getVolumnDelTermList);
                        
                        String delFromDay = "";
                        String delToDay = "";
                        if(getVolumnDelTermVo.getProCnt() > 0) {
                            delFromDay = String.valueOf(((EgovMap) getVolumnDelTermVo.getResOut()).get("fromDay"));
                            delToDay = String.valueOf(((EgovMap) getVolumnDelTermVo.getResOut()).get("toDay"));
                            
                            reqInput.put("delStartDate", (delFromDay + "000000"));
                            reqInput.put("delEndDate", (delToDay + "235959"));
                        }
                        
                        reqInput.put("delTagetData", delFromDay+"~"+delToDay);
                        reqInput.put("delWorkGubun", "3");
                    } else {
                        String reqStartDate = EgovStringUtil.null2void(parm.get("szReqStartDate")).toString();
                        String reqEndDate = EgovStringUtil.null2void(parm.get("szReqEndDate")).toString();
                        reqInput.put("delStartDate", (reqStartDate+"000000"));
                        reqInput.put("delEndDate", (reqEndDate+"235959"));
                        reqInput.put("delTagetData", reqStartDate+"~"+reqEndDate);
                        reqInput.put("delWorkGubun", "2");
                    }
                    
                    // 2. TB_REC_FILE 테이블 데이터 정보 수정
                    if(getFirstRecDayCnt > 0) {
                        ArgoDispatchServiceVo updateRecFileDelInfoVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                        updateRecFileDelInfoVo.setSvcType("ARGODB");
                        updateRecFileDelInfoVo.setDbType("U");
                        updateRecFileDelInfoVo.setSvcName("gubunRest");
                        updateRecFileDelInfoVo.setMethodName("updateRecFileDelInfo");
                        
                        updateRecFileDelInfoVo.setReqInput(reqInput);
            
                        List<ArgoDispatchServiceVo> updateRecFileDelInfoList = new ArrayList<>();
                        updateRecFileDelInfoList.add(updateRecFileDelInfoVo);
        
                        argoDispatchServiceImpl.execute(updateRecFileDelInfoList);
        
                        // update count 기록
                        reqInput.put("delTagetCount", String.valueOf(updateRecFileDelInfoVo.getProCnt()));
                    } else {
                        reqInput.put("delTagetCount", "0");
                    }
                    
                    // 3. TB_REC_GUBUN_DEL 테이블에 데이터 입력
                    reqInput.put("delDesc", EgovStringUtil.null2void(parm.get("szDeleteDesc")).toString());
                    
                    ArgoDispatchServiceVo insertGubunDelInfoVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                    insertGubunDelInfoVo.setSvcType("ARGODB");
                    insertGubunDelInfoVo.setDbType("I");
                    insertGubunDelInfoVo.setSvcName("gubunRest");
                    insertGubunDelInfoVo.setMethodName("insertGubunDelInfo");
                    
                    insertGubunDelInfoVo.setReqInput(reqInput);
        
                    List<ArgoDispatchServiceVo> insertGubunDelInfoList = new ArrayList<>();
                    insertGubunDelInfoList.add(insertGubunDelInfoVo);
    
                    argoDispatchServiceImpl.execute(insertGubunDelInfoList);
                    
                    jsonObj.put("code", "0000");
                    jsonObj.put("message", message+" 성공");
                }
            } else if("getRecStatistics".equals(api)) {
                if("".equals(EgovStringUtil.null2void(parm.get("szTenantID")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szReqStartDate")).toString())
                    || "".equals(EgovStringUtil.null2void(parm.get("szReqEndDate")).toString())
                ) {
                    jsonObj.put("code", "1100");
                    jsonObj.put("message", "필수 요청값을 확인해주세요.");
                } else {
                    message = "데이터 조회";
                    reqInput.put("reqStartDate", EgovStringUtil.null2void(parm.get("szReqStartDate")).toString());
                    reqInput.put("reqEndDate", EgovStringUtil.null2void(parm.get("szReqEndDate")).toString());
                    
                    if("".equals(EgovStringUtil.null2void(parm.get("szReqStartTime")).toString())) {
                        reqInput.put("reqStartTime", "000000");
                    } else {
                        reqInput.put("reqStartTime", EgovStringUtil.null2void(parm.get("szReqStartTime")).toString() + "00");
                    }
                    
                    if("".equals(EgovStringUtil.null2void(parm.get("szReqEndTime")).toString())) {
                        reqInput.put("reqEndTime", "235959");
                    } else {
                        reqInput.put("reqEndTime", EgovStringUtil.null2void(parm.get("szReqEndTime")).toString() + "59");
                    }
                    
                    ArgoDispatchServiceVo getRecStatisticsVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
                    getRecStatisticsVo.setSvcType("ARGODB");
                    getRecStatisticsVo.setDbType("L");
                    getRecStatisticsVo.setSvcName("gubunRest");
                    getRecStatisticsVo.setMethodName("getRecStatistics");
                    
                    getRecStatisticsVo.setReqInput(reqInput);
        
                    List<ArgoDispatchServiceVo> reqRecStatisticsList = new ArrayList<>();
                    reqRecStatisticsList.add(getRecStatisticsVo);
    
                    argoDispatchServiceImpl.execute(reqRecStatisticsList);
                    
                    if(((ArrayList) getRecStatisticsVo.getResOut()).size() == 0) {
                        jsonObj.put("code", "1201");
                        jsonObj.put("message", "데이터 미존재");
                    } else {
                        jsonObj.put("code", "0000");
                        jsonObj.put("message", "데이터 조회 성공");
                        jsonObj.put("count", ((ArrayList) getRecStatisticsVo.getResOut()).size());
                        
                        // result null value to empty string
                        for(int i=0 ; i < ((ArrayList) getRecStatisticsVo.getResOut()).size() ; i++) {
                            EgovMap dataMap = (EgovMap) ((ArrayList) getRecStatisticsVo.getResOut()).get(i);
                            
                            Set<Map.Entry<String, Object>> entries = dataMap.entrySet();
                            for(Map.Entry<String, Object> entry : entries) {
                                if(entry.getValue() == null) {
                                    ((EgovMap) ((ArrayList) getRecStatisticsVo.getResOut()).get(i)).put(entry.getKey(), "");
                                }
                            }
                        }
                        
                        jsonObj.put("data", getRecStatisticsVo.getResOut());
                    }
                }
            }
        } catch (MessageException me) {
            jsonObj.put("code", "1999");
            jsonObj.put("message", message+" 실패");
        } catch (Exception e) {
            jsonObj.put("code", "1999");
            jsonObj.put("message", message+" 실패");
        }
        
        loMeLogger.info(">>>>>==================== gubun rest end ====================");

        return jsonObj;
    }
    
    // DB 패스워드 암호화
    @RequestMapping(value = "/common/DbPassWordSecurityF.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> DbPassWordSecurity(HttpServletRequest request, @RequestParam Map<String, String> parm) {
        Map map = new HashMap<String, Object>();

        try {
            map.put("sid", SecurityUtil.AESEncrypyt(request.getParameter("sid"), null));
            map.put("id", SecurityUtil.AESEncrypyt(request.getParameter("id"), null));
            map.put("pwChange", SecurityUtil.AESEncrypyt(request.getParameter("pwChange"), null));

        } catch (IOException ie) {
            map.put("code", "999");
            map.put("message", ie.getMessage() + " 실패");
            loMeLogger.error("Exception=" + ie);
        } catch (Exception e) {
            map.put("code", "999");
            map.put("message", e.getMessage() + " 실패");
            loMeLogger.error("Exception=" + e);
        }
        return map;
    }

    // DB 패스워드 복호화
    @RequestMapping(value = "/common/DbPassWordDecryptF.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> DbPassWordDecryptF(HttpServletRequest request, @RequestParam Map<String, String> parm) {
        Map map = new HashMap<String, Object>();
        try {
            map.put("sid", AESUtil.decrypt(request.getParameter("sid")));
            map.put("id", AESUtil.decrypt(request.getParameter("id")));
            map.put("pw", AESUtil.decrypt(request.getParameter("pw")));
            map.put("pwChange", AESUtil.decrypt(request.getParameter("pwChange")));

        } catch (IllegalArgumentException iae) {
            map.put("code", "999");
            map.put("message", iae.getMessage() + " 실패");
            loMeLogger.error("Exception=" + iae);
        } catch (Exception e) {
            map.put("code", "999");
            map.put("message", e.getMessage() + " 실패");
            loMeLogger.error("Exception=" + e);
        }
        return map;
    }

    // DB패스워드 변경 후 프로퍼티 수정
    @RequestMapping(value = "/common/ProDbPassWordChangeF.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> ProDbPassWordChangeF(HttpServletRequest request,
            @RequestParam Map<String, String> parm) {
        Map map = new HashMap<String, Object>();
        
        FileInputStream fis = null;
        FileOutputStream fos = null;
        
        try {
            String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
            SortProperties properties = new SortProperties();
//          properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
            fis = new FileInputStream(GLOBALS_PROPERTIES_FILE);
            properties.load(fis);
            properties.setProperty("Globals.ARGO.RDB.Password", AESUtil.encrypt(parm.get("pwChange")));
//          properties.store(new java.io.FileOutputStream(GLOBALS_PROPERTIES_FILE), "");
            fos = new FileOutputStream(GLOBALS_PROPERTIES_FILE);
            properties.store(fos, "");
            map.put("code", "0000");
            map.put("message", "success");
            
            fos.close();
            fis.close();
        } catch (IOException ie) {
            map.put("code", "999");
            map.put("message", ie.getMessage() + " 실패");
            loMeLogger.error("Exception=" + ie);
        } catch (Exception e) {
            map.put("code", "999");
            map.put("message", e.getMessage() + " 실패");
            loMeLogger.error("Exception=" + e);
        } finally {
            if(fos != null) { try {fos.close(); } catch(IOException ie) { loMeLogger.error("Exception : " + ie.toString()); } catch(Exception e) { loMeLogger.error("Exception : " + e.toString()); } }
            if(fis != null) { try {fis.close(); } catch(IOException ie) { loMeLogger.error("Exception : " + ie.toString()); } catch(Exception e) { loMeLogger.error("Exception : " + e.toString()); } }
        }
        return map;
    }

    @RequestMapping(value = "/RecSearch/CustInfoExcelInsertF.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> ExcelInsert(MultipartHttpServletRequest request) {
        VeloceExcelInsert excelInsert = new VeloceExcelInsert();
        Map<String, Object> sessionMAP = null;
        int insColNum = Integer.parseInt(request.getParameter("insColNum"));
        int insSeedNum = Integer.parseInt(request.getParameter("insSeedNum"));
        
        try {
            sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
        } catch (IOException ie) {
            loMeLogger.error("Exception : " + ie.toString());
        } catch (Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
        
        MultipartFile file = request.getFile("excelFile");
        ArgoDispatchServiceVo reqUserInfoVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
        reqUserInfoVo.setSvcType("ARGODB");
        reqUserInfoVo.setSvcName("recSearch");
        reqUserInfoVo.setDbType("U");
        reqUserInfoVo.setMethodName("getRecSearchCustExcelUpdate");

        List<ArgoDispatchServiceVo> reqUserInfoSvcList = new ArrayList<>();
        reqUserInfoSvcList.add(reqUserInfoVo);

        return excelInsert.excelDataInsert(file, reqUserInfoSvcList, argoDispatchServiceImpl,insColNum,insSeedNum);
    }
    
    
    @RequestMapping(value = "/RecSearch/CustInfoExcelInsertNewF.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> ExcelInsertNew(MultipartHttpServletRequest request) {
        VeloceExcelInsert excelInsert = new VeloceExcelInsert();
        Map<String, Object> sessionMAP = null;
        int insColNum = Integer.parseInt(request.getParameter("insColNum"));
        int insSeedNum = Integer.parseInt(request.getParameter("insSeedNum"));
        
        try {
            sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
        } catch (IOException ie) {
            loMeLogger.error("Exception : " + ie.toString());
        } catch (Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
        
        MultipartFile file = request.getFile("excelFile");
        ArgoDispatchServiceVo reqUserInfoVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
        reqUserInfoVo.setSvcType("ARGODB");
        reqUserInfoVo.setSvcName("recSearch");
        reqUserInfoVo.setDbType("U");
        reqUserInfoVo.setMethodName("getRecSearchCustExcelUpdate");

        List<ArgoDispatchServiceVo> reqUserInfoSvcList = new ArrayList<>();
        reqUserInfoSvcList.add(reqUserInfoVo);

        return excelInsert.excelDataInsertNew(file, reqUserInfoSvcList, argoDispatchServiceImpl,insColNum,insSeedNum);
    }
    
    @RequestMapping(value = "/RecSearch/fnCbEncKeyF.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> fnCbEncKey(HttpServletRequest request, @RequestParam Map<String, String> parm) {
        Map map = new HashMap<String, Object>();
        String strCallID = request.getParameter("callId") == null ? "" : request.getParameter("callId");

        String strHASH_TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        String strKey = "BRIDGETEC_VELOCE";

        int nKeyLen = strCallID.length();
        int nKeyTableSize = strHASH_TABLE.length();

        java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("ssmmMMyyyyddHH");
        String strTime = formatter.format(new java.util.Date());

        while (strKey.length() < nKeyLen) {
            strKey = strKey + strKey;
        }

        while (strTime.length() < nKeyLen) {
            strTime = strTime + strTime;
        }

        char chKey;
        char chTime;
        char chUcid;
        char chEncKey;

        int nChar;
        char[] szEncKey = new char[nKeyLen];

        for (int i = 0; i < nKeyLen; i++) {
            chKey = strKey.charAt(i);
            chTime = strTime.charAt(i);
            chUcid = strCallID.charAt(i);
            int nKey = (int) chKey;
            int nTime = (int) chTime;
            int nUcid = (int) chUcid;
            if(nUcid >= 0 && nKey >= 0 && nTime >= 0 && nKeyTableSize >= 0) {
                nChar = (int) ((nUcid + nKey + nTime) % nKeyTableSize);
            } else {
                nChar = 0;
            }
            chEncKey = strHASH_TABLE.charAt(nChar);
            szEncKey[i] = chEncKey;
        }
        map.put("encKey", new String(szEncKey));

        return map;
    }

    @RequestMapping(value = "/SampleAPI/RecordAPISampleF.do", method = RequestMethod.POST)
    public void RecordAPISample(HttpServletRequest request, HttpServletResponse response,
            @RequestParam Map<String, String> parm) throws IOException {
        // 파일 객체 생성
        String realPath = request.getSession().getServletContext().getRealPath("/") + "data";
//      String fileName = parm.get("fileName");
        String fileName = (parm.get("fileName")).replaceAll("/","").replaceAll("\\\\","").replaceAll(".","").replaceAll("&","");
        File file = new File(realPath + "/" + fileName);

        if (file != null) {
            String userAgent = request.getHeader("User-Agent");

            if (userAgent.indexOf("MSIE") > -1 || userAgent.indexOf("Trident") > -1) {
                fileName = URLEncoder.encode(file.getName(), "utf-8").replaceAll("\\+", "%20");
                ;
            } else if (userAgent.indexOf("Chrome") > -1) {
                StringBuffer sb = new StringBuffer();
                for (int i = 0; i < file.getName().length(); i++) {
                    char c = file.getName().charAt(i);
                    if (c > '~') {
                        sb.append(URLEncoder.encode("" + c, "UTF-8"));
                    } else {
                        sb.append(c);
                    }
                }
                fileName = sb.toString();
            } else {
                fileName = new String(file.getName().getBytes("utf-8"));
            }

            response.setContentLength((int) file.length());
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\";");
            response.setHeader("Content-Transfer-Encoding", "binary");

            OutputStream out = response.getOutputStream();
            FileInputStream fis = null;
            try {
                fis = new FileInputStream(file);
                FileCopyUtils.copy(fis, out);
            } catch (FileNotFoundException fnfe) {
                loMeLogger.error("Exception : " + fnfe.toString());
            } catch (Exception e) {
                loMeLogger.error("Exception : " + e.toString());
            } finally {
                if (fis != null) {
                    try {
                        fis.close();
                    } catch (IOException ie) {
                        loMeLogger.error("Exception : " + ie.toString());
                    } catch (Exception e) {
                        loMeLogger.error("Exception : " + e.toString());
                    }
                }

                if (out != null) {
                    out.flush();
                }
            }
        }
    }
    
//    @RequestMapping(value = "/wau/browserCorsProxyF.do", method = RequestMethod.POST)
//    @ResponseBody
//    public String browserCorsProxy(HttpServletRequest request, HttpServletResponse response,
//            @RequestBody Map<String, String> parm) throws IOException {
//        String result = "";
//        BufferedReader rd = null;
//        HttpURLConnection con = null;
//        OutputStream out = null;
//        try {
//            request.setCharacterEncoding("utf-8");
//            ObjectMapper mapper = new ObjectMapper();
//            String reqData = mapper.writeValueAsString(parm);
//            JSONParser jsonParser = new JSONParser();
//            JSONObject jsonObj = (JSONObject) jsonParser.parse(reqData);
//            String strDataType = jsonObj.get("paramDataType").toString();
//            String reqUrl = jsonObj.get("url").toString();
//            String loginIp = ArgoCtrlHelper.getClientIpAddr(request);
//            
//            if (strDataType.equals("text")) {
//                reqData = "";
//                Set<Map.Entry<String, Object>> entries = jsonObj.entrySet();
//                for (Map.Entry<String, Object> entry : entries) {
//                    String jsonKey = entry.getKey();
//                    String jsonValue = jsonObj.get(jsonKey).toString();
//                    reqData += jsonKey + "=" + jsonValue + "&";
//                }
//            } else if(strDataType.equals("player")){
//                reqUrl = reqUrl.replace("127.0.0.1", loginIp.equals("0:0:0:0:0:0:0:1")?"127.0.0.1":loginIp);
//            }
//            
//            URL url = new URL(reqUrl);
//            con = (HttpURLConnection) url.openConnection();
//            
//            if (strDataType.equals("json")) {
//                con.setRequestProperty("Content-Type", "application/json; utf-8");
//            }
//            
//            if (reqUrl.startsWith("http://")) { // HTTP
//                con.setRequestMethod("POST");
//                con.setDoOutput(true);
//                out = con.getOutputStream();
//                out.write(reqData.getBytes());
//                out.flush();
//                int responseCode = con.getResponseCode();
//                response.setStatus(responseCode);
//                response.setContentType(con.getContentType());
//                // 데이터 수신
//                rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
//                String line;
//                while ((line = rd.readLine()) != null) {
////                  out.println(line); 
//                    result += URLDecoder.decode(line, "UTF-8");
//                }
//            } else if (reqUrl.startsWith("https://")) { // HTTPS
//                TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
//                    @Override
//                    public X509Certificate[] getAcceptedIssuers() {
//                        return null;
//                    }
//
//                    @Override
//                    public void checkClientTrusted(X509Certificate[] certs, String authType) {
//                    }
//
//                    @Override
//                    public void checkServerTrusted(X509Certificate[] certs, String authType) {
//                    }
//                } };
//                // Install the all-trusting trust manager
//                SSLContext sc = SSLContext.getInstance("SSL");
//                sc.init(null, trustAllCerts, new SecureRandom());
//                HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
//
//                // Create all-trusting host name verifier
//                HostnameVerifier allHostsValid = new HostnameVerifier() {
//                    @Override
//                    public boolean verify(String hostname, SSLSession session) {
//                        return true;
//                    }
//                };
//                HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
//
//                con.setRequestMethod("POST");
//                con.setDoOutput(true);
//
//                // 데이터 전송
//                con.getOutputStream().write(reqData.getBytes());
//                con.getOutputStream().flush();
//                con.getOutputStream().close();
//
//                int responseCode = con.getResponseCode();
//                response.setStatus(responseCode);
//                response.setContentType(con.getContentType());
//                // 데이터 수신
//                rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
//                String line;
//                while ((line = rd.readLine()) != null) {
////                  out.println(line);
//                    result += URLDecoder.decode(line, "UTF-8");
//                }
//            } else {
//                response.setStatus(500);
//                response.getWriter().write("Unknwon URL");
//                response.flushBuffer();
//            }
//        } catch (IOException ie) {
//            ie.printStackTrace();
//            loMeLogger.error("Exception : " + ie.toString());
//            response.setStatus(500);
//            response.getWriter().write(ie.getMessage());
//            response.flushBuffer();
//        } catch (Exception e) {
//            loMeLogger.error("Exception : " + e.toString());
//            response.setStatus(500);
//            response.getWriter().write(e.getMessage());
//            response.flushBuffer();
//        } finally {
//            if(out != null) { out.close(); }
//            if(rd != null) { rd.close(); }
//            if(con != null) { con.disconnect(); }
//        }
//        return result;
//    }
    
    
    @RequestMapping(value = "/wau/browserCorsProxyF.do", method = RequestMethod.POST)
    @ResponseBody
    public String browserCorsProxy(HttpServletRequest request, HttpServletResponse response, @RequestBody Map<String, String> parm) throws IOException {
    	loMeLogger.info("[로그용 :/wau/browserCorsProxyF.do] 시작");
    	String result = "";
        
        try {
        	//HttpHeaders headers = new HttpHeaders();
        	//loMeLogger.error("Exception : " + e.toString());
        	HttpHeaders headers = new HttpHeaders();
        	headers.setContentType(MediaType.APPLICATION_JSON);
        	
        	ObjectMapper objectmapper = new ObjectMapper();
        	String paramStr = objectmapper.writeValueAsString(parm);
        	
        	HttpEntity<String> req = new HttpEntity<>(paramStr, headers);
        	RestTemplate client = new RestTemplate();
        	ResponseEntity<String> responseEntity = client.postForEntity(parm.get("url"), req, String.class);
        	
        	result = URLDecoder.decode(responseEntity.getBody(), "UTF-8");
        			
        	
        } catch(Exception e) {
        	loMeLogger.error("Exception : " + e.toString());
        }
        
        return result;
    }

    @RequestMapping(value = "/wau/browserCorsProxyMultipartF.do", method = RequestMethod.POST)
    @ResponseBody
    public String browserCorsProxyMultipart(MultipartHttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String result = "";
        try {
            request.setCharacterEncoding("utf-8");
            Map<String, List<MultipartFile>> map = request.getMultiFileMap();
            String reqUrl = request.getParameter("url");
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddkkmmss");
            String currentDate = dateFormat.format(new Date());
            String boundary = "--"+currentDate+"VeloceBoundary";
            
            String crlf = "\r\n";

            URL url = new URL(reqUrl);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

            if (reqUrl.startsWith("http://")) { // HTTP
                con.setRequestMethod("POST");
                con.setDoOutput(true);
                OutputStream output = con.getOutputStream();
                

                List<MultipartFile> mapList = map.get("fileName");
                int ii=0;
                for (MultipartFile multi : mapList) {
                    ii++;
                    if (!multi.getOriginalFilename().equals("")) {
                        InputStream input = multi.getInputStream();
                        StringBuilder strBuild = new StringBuilder();

                        strBuild.append("--" + boundary + crlf)
                                .append("Content-Disposition: form-data; name=\"fileName\"; ")
                                .append("filename=\"").append(multi.getOriginalFilename()).append("\"").append(crlf)
                                .append("Content-Type: " + multi.getContentType()).append(crlf+crlf);
                        
                        output.write(strBuild.toString().getBytes());

                        byte[] buffer = new byte[128];
                        int size = -1;
                        while (-1 != (size = input.read(buffer))) {
                            output.write(buffer, 0, size);
                        }
                        
                        if(mapList.size() == ii) {
                            output.write((crlf+"--" + boundary+"--"+crlf).getBytes());   //마지막일떄는 -- 구분 처리
                        } else {
                            output.write((crlf+"--" + boundary+crlf).getBytes());
                        }
                        
                        input.close();
                    }
                }

                output.flush();
                output.close();

                int responseCode = con.getResponseCode();
                response.setStatus(responseCode);
                response.setContentType(con.getContentType());
                // 데이터 수신
                BufferedReader rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
                String line;
                while ((line = rd.readLine()) != null) {
                    result += URLDecoder.decode(line, "UTF-8");
                }
                rd.close();
                con.disconnect();
            } else if (reqUrl.startsWith("https://")) { // HTTPS
                TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
                    @Override
                    public X509Certificate[] getAcceptedIssuers() {
                        return null;
                    }

                    @Override
                    public void checkClientTrusted(X509Certificate[] certs, String authType) {
                    }

                    @Override
                    public void checkServerTrusted(X509Certificate[] certs, String authType) {
                    }
                } };
                // Install the all-trusting trust manager
                SSLContext sc = SSLContext.getInstance("SSL");
                sc.init(null, trustAllCerts, new SecureRandom());
                HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

                // Create all-trusting host name verifier
                HostnameVerifier allHostsValid = new HostnameVerifier() {
                    @Override
                    public boolean verify(String hostname, SSLSession session) {
                        return true;
                    }
                };
                HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);

                con.setRequestMethod("POST");
                con.setDoOutput(true);

                // 데이터 전송
                List<MultipartFile> mapList = map.get("fileName");
                int ii=0;
                for (MultipartFile multi : mapList) {
                    ii++;
                    if (!multi.getOriginalFilename().equals("")) {
                        InputStream input = multi.getInputStream();
                        StringBuilder strBuild = new StringBuilder();

                        strBuild.append("--" + boundary + crlf)
                                .append("Content-Disposition: form-data; name=\"fileName\"; ")
                                .append("filename=\"").append(multi.getOriginalFilename()).append("\"").append(crlf)
                                .append("Content-Type: " + multi.getContentType()).append(crlf+crlf);
                        
                        con.getOutputStream().write(strBuild.toString().getBytes());

                        byte[] buffer = new byte[128];
                        int size = -1;
                        while (-1 != (size = input.read(buffer))) {
                            con.getOutputStream().write(buffer, 0, size);
                        }
                        
                        if(mapList.size() == ii)
                            con.getOutputStream().write((crlf+"--" + boundary+"--"+crlf).getBytes());   //마지막일떄는 -- 구분 처리
                        else
                            con.getOutputStream().write((crlf+"--" + boundary+crlf).getBytes());
                        
                        input.close();
                    }
                }
                
                con.getOutputStream().flush();
                con.getOutputStream().close();

                int responseCode = con.getResponseCode();
                response.setStatus(responseCode);
                response.setContentType(con.getContentType());
                // 데이터 수신
                BufferedReader rd = new BufferedReader(new InputStreamReader(con.getInputStream()));
                String line;
                while ((line = rd.readLine()) != null) {
                    result += URLDecoder.decode(line, "UTF-8");
                }
                rd.close();
                con.disconnect();
            } else {
                response.setStatus(500);
                response.getWriter().write("Unknwon URL");
                response.flushBuffer();
            }
        } catch (IOException ie) {
            loMeLogger.error("Exception : " + ie.toString());
            response.setStatus(500);
            response.getWriter().write(ie.getMessage());
            response.flushBuffer();
        } catch (Exception e) {
            loMeLogger.error("Exception : " + e.toString());
            response.setStatus(500);
            response.getWriter().write(e.getMessage());
            response.flushBuffer();
        }
        return result;
    }

    // 고객정보 일괄수정 Excel Export
    @RequestMapping(value = "/RecSearch/RecSearchCustInfoUpdateF.do", method = RequestMethod.POST)
    public void RecSearchCustInfoUpdate(HttpServletRequest request, HttpServletResponse response,
            @RequestParam Map<String, Object> parm) throws IOException {
        try {
            Workbook xlsxWb = new XSSFWorkbook();
            Sheet sheet1 = xlsxWb.createSheet("CustInfo");

            Row row = null;
            Row titleRow = null;
            Cell cell = null;
            Cell titleCell = null;

            // 엑셀 고정(수정 안되는) 컬럼 표시 0 ~ disInsColNum
            // 없을시 == -1
            int disInsColNum = Integer.parseInt(parm.get("disInsColNum").toString());

            // Excel 데이터 조회
            ArgoDispatchServiceVo argoServiceVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
            argoServiceVO.setSvcType("ARGODB");
            argoServiceVO.setDbType("L");
            argoServiceVO.setSvcName(parm.get("excelImSvcName").toString());
            argoServiceVO.setMethodName(parm.get("excelImMethodName").toString());
            parm.put("iSPageNo", 1);
            parm.put("iEPageNo", 100000000);
            argoServiceVO.setReqInput(parm);

            List<ArgoDispatchServiceVo> reqVeloceRestList = new ArrayList<>();
            reqVeloceRestList.add(argoServiceVO);
            argoDispatchServiceImpl.execute(reqVeloceRestList);

            List<Map> listResult = (List<Map>) argoServiceVO.getResOut();

            // 첫번째 셀병합
            int listGet0Size = listResult == null ? 1 : listResult.get(0).size();
            sheet1.addMergedRegion(new CellRangeAddress(0, 0, 0, listGet0Size - 1));
            row = sheet1.createRow(0);
            cell = row.createCell(0);
            row.setHeight((short) 900);
            cell.setCellValue(
                    "1.흰색 배경의 셀만 수정해 주시기 바랍니다.\r\n2.통화내역 정보를 정확히 확인 후 수정 해주시기바랍니다.\r\n정보의 혼란을 막기위해  유의해 주시기 바랍니다.");

            titleRow = sheet1.createRow(1);

            CellStyle style = xlsxWb.createCellStyle();
            style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            style.setFillPattern(CellStyle.SOLID_FOREGROUND);
            style.setBorderRight(HSSFCellStyle.BORDER_THIN);
            style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
            style.setBorderTop(HSSFCellStyle.BORDER_THIN);
            style.setBorderBottom(HSSFCellStyle.BORDER_THIN);

            if(listResult != null) {
                for (int i = 0; i < listResult.size(); i++) {
                    Map<String, Object> map = listResult.get(i);
                    row = sheet1.createRow(i + 2);
                    int j = 0;
                    String strSeed = "";
    
                    // seed 값이 있으면  
                    if (map.get("seedExcelSecretColum") != null) {
                        strSeed = map.get("seedExcelSecretColum").toString(); // seed 조회
                        strSeed = AESUtil.decrypt(strSeed); // seed 값 복호화
                    }
    
                    for (Entry<String, Object> entrySet : map.entrySet()) {
                        cell = row.createCell(j);
                        // 첫번째 title 컬럼
                        if (i == 0) {
                            String columnName = entrySet.getKey();
                            titleCell = titleRow.createCell(j);
                            titleCell.setCellValue(columnName);
                            titleCell.setCellStyle(style);
                            // 컬럼 이름,컬럼 숨기기
                            if (columnName.indexOf("ExcelSecretColum") != -1) {
                                sheet1.setColumnHidden(j, true);
                            }
                        }
                        
                        if (entrySet.getValue() != null) {
                            cell.setCellValue(entrySet.getValue().toString());
                        }
                        
                        if (j < disInsColNum) {
                            cell.setCellStyle(style);
                        }
                        j++;
                    }
                }
            }
            response.setContentType("application/octect-stream");
//          response.setContentType("ms-vnd/excel");
            response.setHeader("Content-Disposition", "attachment;filename=" + parm.get("fileName"));
            xlsxWb.write(response.getOutputStream());
            response.getOutputStream().flush();
        } catch (FileNotFoundException e) {
            loMeLogger.error("FileNotFoundException : " + e.toString());
        } catch (IOException e) {
            loMeLogger.error("IOException : " + e.toString());
        } catch (MessageException e) {
            loMeLogger.error("MessageException : " + e.toString());
        } catch (Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
    }
    
    
    
    // 고객정보 일괄수정 Excel Export
    @RequestMapping(value = "/RecSearch/RecSearchCustInfoUpdateNewF.do", method = RequestMethod.POST)
    public void RecSearchCustInfoUpdateNew(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, Object> parm) throws IOException {
        try {
            Workbook xlsxWb = new XSSFWorkbook();
            Sheet sheet1 = xlsxWb.createSheet("CustInfo");

            Row row = null;
            Row titleRow = null;
            Cell cell = null;
            Cell titleCell = null;
            
            String recKeys = "";
            
            // 엑셀 고정(수정 안되는) 컬럼 표시 0 ~ disInsColNum
            // 없을시 == -1
            int disInsColNum = Integer.parseInt(parm.get("disInsColNum").toString());

            ArgoDispatchServiceVo argoServiceVO;
            List<ArgoDispatchServiceVo> reqVeloceRestList;
            
            // Excel 데이터 조회
            argoServiceVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
            argoServiceVO.setSvcType("ARGODB");
            argoServiceVO.setDbType("L");
            argoServiceVO.setSvcName("recSearchNew");
            argoServiceVO.setMethodName("getRecSearchListExcelImportNew");
            parm.put("iSPageNo", 1);
            parm.put("iEPageNo", 100000000);
            argoServiceVO.setReqInput(parm);
            reqVeloceRestList = new ArrayList<>();
            reqVeloceRestList.add(argoServiceVO);
            argoDispatchServiceImpl.execute(reqVeloceRestList);
            List<Map> listResult = (List<Map>) argoServiceVO.getResOut();
            
            if(listResult != null) {
                for (int i = 0; i < listResult.size(); i++) {
                    Map<String, Object> map = listResult.get(i);
                    recKeys = recKeys + map.get("recKey") + ",";
                }
            }
            recKeys = recKeys.substring(0, recKeys.length() - 1);
            parm.put("recKeys", recKeys);
            
            // Excel 동적헤더조회
            argoServiceVO.setSvcName("recSearchNew");
            argoServiceVO.setMethodName("getCustEtcListExlNew");
            argoServiceVO.setReqInput(parm);
            reqVeloceRestList = new ArrayList<>();
            reqVeloceRestList.add(argoServiceVO);
            argoDispatchServiceImpl.execute(reqVeloceRestList);
            List<Map> listDynimicHeader = (List<Map>) argoServiceVO.getResOut();
            
            
            // Excel 데이터 조회
            argoServiceVO.setSvcName("recSearchNew");
            argoServiceVO.setMethodName("getSearchCustEtcsExlNew");
            argoServiceVO.setReqInput(parm);
            reqVeloceRestList = new ArrayList<>();
            reqVeloceRestList.add(argoServiceVO);
            argoDispatchServiceImpl.execute(reqVeloceRestList);
            List<Map> listCustDat = (List<Map>) argoServiceVO.getResOut();
            
            //List<Map> listResult
            List<Map> dynimicHeaderList = new ArrayList();
            List<Map> dynimicResultList = new ArrayList();
            if(listResult != null && listDynimicHeader != null) {
                for (int i = 0; i < listResult.size(); i++) {
                    Map<String, Object> map = listResult.get(i);
                    for(int j = 0; j < listDynimicHeader.size(); j++) {
                        Map<String, Object> headerMap = listDynimicHeader.get(j);
                        map.put((String)headerMap.get("code"), (String)"");
                        continue;
                    }
                    dynimicHeaderList.add(map);
                }
            }
            
            if(dynimicHeaderList != null && listCustDat != null) {
                for(int i = 0; i<dynimicHeaderList.size(); i++) {
                    Map<String, Object> map = dynimicHeaderList.get(i);
                    Map<String, Object> tmpMap = new LinkedHashMap<>(map);
                    for (Entry<String, Object> entrySet : map.entrySet()) {
                        String columnName = entrySet.getKey();
                        for(int j = 0; j<listCustDat.size(); j++) {
                            Map<String, Object> custDatmap = listCustDat.get(j);
                            if(map.get("recKey").equals(custDatmap.get("recKey")) && columnName.equals(kamelConvert((String)custDatmap.get("colId")))) {
                                tmpMap.put(columnName, custDatmap.get("custData"));
                            }
                        }
                    }
                    dynimicResultList.add(tmpMap);
                    
                }
            }
            
            // 첫번째 셀병합
            int listGet0Size = listResult == null ? 1 : listResult.get(0).size();
            sheet1.addMergedRegion(new CellRangeAddress(0, 0, 0, listGet0Size - 1));
            row = sheet1.createRow(0);
            cell = row.createCell(0);
            row.setHeight((short) 900);
            cell.setCellValue("1.흰색 배경의 셀만 수정해 주시기 바랍니다.\r\n2.통화내역 정보를 정확히 확인 후 수정 해주시기바랍니다.\r\n정보의 혼란을 막기위해  유의해 주시기 바랍니다.");

            titleRow = sheet1.createRow(1);

            CellStyle style = xlsxWb.createCellStyle();
            style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            style.setFillPattern(CellStyle.SOLID_FOREGROUND);
            style.setBorderRight(HSSFCellStyle.BORDER_THIN);
            style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
            style.setBorderTop(HSSFCellStyle.BORDER_THIN);
            style.setBorderBottom(HSSFCellStyle.BORDER_THIN);

            if(dynimicResultList != null) {
                for (int i = 0; i < dynimicResultList.size(); i++) {
                    Map<String, Object> map = dynimicResultList.get(i);
                    row = sheet1.createRow(i + 2);
                    int j = 0;
                    String strSeed = "";
                    
                    // seed 값이 있으면  
                    if (map.get("seedExcelSecretColum") != null) {
                        strSeed = map.get("seedExcelSecretColum").toString(); // seed 조회
                        strSeed = AESUtil.decrypt(strSeed); // seed 값 복호화
                    }
    
                    for (Entry<String, Object> entrySet : map.entrySet()) {
                        cell = row.createCell(j);
                        // 첫번째 title 컬럼
                        if (i == 0) {
                            String columnName = entrySet.getKey();
                            titleCell = titleRow.createCell(j);
                            titleCell.setCellValue(columnName);
                            titleCell.setCellStyle(style);
                            // 컬럼 이름,컬럼 숨기기
                            if (columnName.indexOf("ExcelSecretColum") != -1) {
                                sheet1.setColumnHidden(j, true);
                            }
                        }
                        
                        if (entrySet.getValue() != null) {
                            cell.setCellValue(entrySet.getValue().toString());
                        }
                        
                        if (j < disInsColNum) {
                            cell.setCellStyle(style);
                        }
                        j++;
                    }
                }
            }
            response.setContentType("application/octect-stream");
            response.setHeader("Content-Disposition", "attachment;filename=" + parm.get("fileName"));
            xlsxWb.write(response.getOutputStream());
            response.getOutputStream().flush();
        } catch (FileNotFoundException e) {
            loMeLogger.error("FileNotFoundException : " + e.toString());
        } catch (IOException e) {
            loMeLogger.error("IOException : " + e.toString());
        } catch (MessageException e) {
            loMeLogger.error("MessageException : " + e.toString());
        } catch (Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
    }
    
        
        
    
    // DB컬럼 파라미터 Excel 추출
    // DB컬럼 파라미터 Excel 추출
    @RequestMapping(value = "/RecSearch/DataExcelExportNewF.do", method = RequestMethod.POST)
    public void RecSearchCustInfoUpdateV2New(HttpServletRequest request, HttpServletResponse response,
            @RequestParam Map<String, Object> parm) throws IOException, org.json.simple.parser.ParseException {
        JSONParser jsonParser = new JSONParser();
        JSONObject jsonObj = (JSONObject) jsonParser.parse(String.valueOf(parm.get("testlist")).replaceAll("&quot;", "\""));
        JSONArray excelColKey = (JSONArray) jsonParser.parse(String.valueOf(jsonObj.get("excelColKey")));
        JSONArray excelColName = (JSONArray) jsonParser.parse(String.valueOf(jsonObj.get("excelColName")));
        try {
            //////////////////////////////////////////////////////////////////
            Workbook xlsxWb = new XSSFWorkbook();
            Sheet sheet1 = xlsxWb.createSheet("CustInfo");
            
            // 엑셀 파일 우클릭 자세히 속성 값 지정
            Map<String, Object> sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
            String loginUserName = (String) sessionMAP.get("userName") + "(" + (String) sessionMAP.get("userId") + ")";
            ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setCreator(loginUserName);   // 만든 이
    
            Row row = null;
            Row titleRow = null;
            Cell cell = null;
            Cell titleCell = null;
    
            // Excel 데이터 조회
            ArgoDispatchServiceVo argoServiceVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
            argoServiceVO.setSvcType("ARGODB");
            argoServiceVO.setDbType("L");
            argoServiceVO.setSvcName(parm.get("excelImSvcName").toString());
            argoServiceVO.setMethodName(parm.get("excelImMethodName").toString());
            parm.put("iSPageNo", 1);
            parm.put("iEPageNo", 100000000);
            argoServiceVO.setReqInput(parm);
    
            List<ArgoDispatchServiceVo> reqVeloceRestList = new ArrayList<>();
            reqVeloceRestList.add(argoServiceVO);
            argoDispatchServiceImpl.execute(reqVeloceRestList);
            List<Map> listResult = (List<Map>) argoServiceVO.getResOut();
    
            // 첫번째 셀병합
            int listGet0Size = listResult == null ? 1 : listResult.get(0).size();
            sheet1.addMergedRegion(new CellRangeAddress(0, 0, 0, listGet0Size - 1));
            row = sheet1.createRow(0);
            cell = row.createCell(0);
            row.setHeight((short) 900);
            cell.setCellValue("1.흰색 배경의 셀만 수정해 주시기 바랍니다.\r\n2.통화내역 정보를 정확히 확인 후 수정 해주시기바랍니다.\r\n정보의 혼란을 막기위해  유의해 주시기 바랍니다.");
    
            titleRow = sheet1.createRow(1);
            CellStyle style = xlsxWb.createCellStyle();
            style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            style.setFillPattern(CellStyle.SOLID_FOREGROUND);
            style.setBorderRight(HSSFCellStyle.BORDER_THIN);
            style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
            style.setBorderTop(HSSFCellStyle.BORDER_THIN);
            style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
            
            if(listResult != null) {
                // 타이틀 
                for(int i=0;i<excelColName.size();i++) {
                    String columnName = excelColName.get(i).toString();
                    titleCell = titleRow.createCell(i);
                    titleCell.setCellValue(columnName);
                    titleCell.setCellStyle(style);
                }
                
                // 데이터 
                for (int i = 0; i < listResult.size(); i++) {
                    row = sheet1.createRow(i + 2);
                    Map<String, Object> map = listResult.get(i);
                    for(int j=0;j<excelColKey.size();j++) {
                        String excelVal = map.get(excelColKey.get(j)) == null ? "" : map.get(excelColKey.get(j)).toString();
                        cell = row.createCell(j);
                        cell.setCellValue(excelVal);
                    }
                }
            }
            
            response.setContentType("application/octect-stream");
            response.setHeader("Content-Disposition", "attachment;filename=" + parm.get("fileName"));
            xlsxWb.write(response.getOutputStream());
            response.getOutputStream().flush();
        } catch (FileNotFoundException e) {
            loMeLogger.error("FileNotFoundException : " + e.toString());
        } catch (IOException e) {
            loMeLogger.error("IOException : " + e.toString());  
        } catch (MessageException e) {
            loMeLogger.error("MessageException : " + e.toString());
        } catch (Exception e) {
            e.printStackTrace();
            loMeLogger.error("Exception : " + e.toString());
        }
    }
        
    
    // DB컬럼 파라미터 Excel 추출
    @RequestMapping(value = "/RecSearch/DataExcelExportF.do", method = RequestMethod.POST)
    public void RecSearchCustInfoUpdateV2(HttpServletRequest request, HttpServletResponse response,
            @RequestParam Map<String, Object> parm) throws IOException, org.json.simple.parser.ParseException {
        JSONParser jsonParser = new JSONParser();
        JSONObject jsonObj = (JSONObject) jsonParser.parse(String.valueOf(parm.get("testlist")).replaceAll("&quot;", "\""));
        JSONArray excelColKey = (JSONArray) jsonParser.parse(String.valueOf(jsonObj.get("excelColKey")));
        JSONArray excelColName = (JSONArray) jsonParser.parse(String.valueOf(jsonObj.get("excelColName")));
        try {
            //////////////////////////////////////////////////////////////////
            Workbook xlsxWb = new XSSFWorkbook();
            Sheet sheet1 = xlsxWb.createSheet("CustInfo");
            
            // 엑셀 파일 우클릭 자세히 속성 값 지정
            Map<String, Object> sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
            String loginUserName = (String) sessionMAP.get("userName") + "(" + (String) sessionMAP.get("userId") + ")";
            
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setTitle("제목");              // 제목
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setSubjectProperty("주제");    // 주제
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setKeywords("태그");           // 태그
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setCategory("범주");           // 범주
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setDescription("설명");        // 설명
            ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setCreator(loginUserName);   // 만든 이
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setRevision("수정 횟수");        // 수정 횟수
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setContentStatus("콘텐츠 상태");  // 콘텐츠 상태
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setContentType("");      
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setCreated("");
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setIdentifier("");           
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setLastPrinted("");      
//          ((XSSFWorkbook)xlsxWb).getProperties().getCoreProperties().setModified(""); 
    
            Row row = null;
            Row titleRow = null;
            Cell cell = null;
            Cell titleCell = null;
    
            // Excel 데이터 조회
            ArgoDispatchServiceVo argoServiceVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
            argoServiceVO.setSvcType("ARGODB");
            argoServiceVO.setDbType("L");
            argoServiceVO.setSvcName(parm.get("excelImSvcName").toString());
            argoServiceVO.setMethodName(parm.get("excelImMethodName").toString());
            parm.put("iSPageNo", 1);
            parm.put("iEPageNo", 100000000);
            argoServiceVO.setReqInput(parm);
    
            List<ArgoDispatchServiceVo> reqVeloceRestList = new ArrayList<>();
            reqVeloceRestList.add(argoServiceVO);
            argoDispatchServiceImpl.execute(reqVeloceRestList);
    
            List<Map> listResult = (List<Map>) argoServiceVO.getResOut();
    
            // 첫번째 셀병합
            int listGet0Size = listResult == null ? 1 : listResult.get(0).size();
            sheet1.addMergedRegion(new CellRangeAddress(0, 0, 0, listGet0Size - 1));
            row = sheet1.createRow(0);
            cell = row.createCell(0);
            row.setHeight((short) 900);
            cell.setCellValue("1.흰색 배경의 셀만 수정해 주시기 바랍니다.\r\n2.통화내역 정보를 정확히 확인 후 수정 해주시기바랍니다.\r\n정보의 혼란을 막기위해  유의해 주시기 바랍니다.");
    
            titleRow = sheet1.createRow(1);
    
            CellStyle style = xlsxWb.createCellStyle();
            style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            style.setFillPattern(CellStyle.SOLID_FOREGROUND);
            style.setBorderRight(HSSFCellStyle.BORDER_THIN);
            style.setBorderLeft(HSSFCellStyle.BORDER_THIN);
            style.setBorderTop(HSSFCellStyle.BORDER_THIN);
            style.setBorderBottom(HSSFCellStyle.BORDER_THIN);
            
            if(listResult != null) {
                // 타이틀 
                for(int i=0;i<excelColName.size();i++) {
                    String columnName = excelColName.get(i).toString();
                    titleCell = titleRow.createCell(i);
                    titleCell.setCellValue(columnName);
                    titleCell.setCellStyle(style);
                }
                
                // 데이터 
                for (int i = 0; i < listResult.size(); i++) {
                    row = sheet1.createRow(i + 2);
                    Map<String, Object> map = listResult.get(i);
                    for(int j=0;j<excelColKey.size();j++) {
                        String excelVal = map.get(excelColKey.get(j)) == null ? "" : map.get(excelColKey.get(j)).toString();
                        cell = row.createCell(j);
                        cell.setCellValue(excelVal);
                    }
                }
            }
            
            response.setContentType("application/octect-stream");
            response.setHeader("Content-Disposition", "attachment;filename=" + parm.get("fileName"));
            xlsxWb.write(response.getOutputStream());
            response.getOutputStream().flush();
        } catch (FileNotFoundException e) {
            loMeLogger.error("FileNotFoundException : " + e.toString());
        } catch (IOException e) {
            loMeLogger.error("IOException : " + e.toString());  
        } catch (MessageException e) {
            loMeLogger.error("MessageException : " + e.toString());
        } catch (Exception e) {
            e.printStackTrace();
            loMeLogger.error("Exception : " + e.toString());
        }
    }
    //통화내역 - 사용자 - 자동검색
    @RequestMapping(value = "/RecSearch/GetRecUserInfo.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> GetRecUserInfo(MultipartHttpServletRequest request) {
        Map<String, Object> sessionMAP = null;
        
        try {
            sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
        } catch (IOException ie) {
            loMeLogger.error("Exception : " + ie.toString());
        } catch (Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
        try {
            ArgoDispatchServiceVo reqUserInfoVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
            reqUserInfoVo.setSvcType("ARGODB");
            reqUserInfoVo.setSvcName("recSearch");
            reqUserInfoVo.setDbType("S");
            reqUserInfoVo.setMethodName("getRecUserInfo");

            List<ArgoDispatchServiceVo> reqUserInfoSvcList = new ArrayList<>();
            reqUserInfoSvcList.add(reqUserInfoVo);
            argoDispatchServiceImpl.execute(reqUserInfoSvcList);
        }catch(MessageException me) {
            loMeLogger.error("Exception : " + me.toString());
        }catch(Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
        
        
        
        return null;
    }

    @RequestMapping(value = "/License/LicenseEncryptF.do", method = RequestMethod.POST)
    @ResponseBody
    public String LicenseEncrypt(HttpServletRequest request, HttpServletResponse response,
            @RequestBody Map<String, Object> parm) throws IOException {
        String strResult = "";
        try {
            parm.put("encKey", parm.get("encKey").toString());
            parm.put("userId", parm.get("userId").toString());
            String strDate = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
            parm.put("licTime", strDate);

            ArgoDispatchServiceVo argoServiceVO = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
            argoServiceVO.setSvcType("ARGODB");
            argoServiceVO.setDbType(Constant.SVC_DB_TYPE_SELECT);
            argoServiceVO.setReqInput(parm);

            argoServiceVO.setSvcName("sysInfo");
            argoServiceVO.setMethodName("getLicenseOverlapCnt");
            List<ArgoDispatchServiceVo> reqVeloceRestList = new ArrayList<>();
            reqVeloceRestList.add(argoServiceVO);
            argoDispatchServiceImpl.execute(reqVeloceRestList);

            if(argoServiceVO.getResOut() != null) {
                if (((EgovMap) argoServiceVO.getResOut()).get("cnt").toString().equals("0")) {
                    argoServiceVO.setDbType(Constant.SVC_DB_TYPE_UPDATE);
                    argoServiceVO.setSvcName("sysInfo");
                    argoServiceVO.setMethodName("getLicenseTimeEndUpdate");
                    reqVeloceRestList = new ArrayList<>();
                    reqVeloceRestList.add(argoServiceVO);
    
                    argoDispatchServiceImpl.execute(reqVeloceRestList);
    
                    argoServiceVO.setDbType(Constant.SVC_DB_TYPE_INSERT);
                    argoServiceVO.setSvcName("sysInfo");
                    argoServiceVO.setMethodName("getLicenseInsert");
                    reqVeloceRestList = new ArrayList<>();
                    reqVeloceRestList.add(argoServiceVO);
                    argoDispatchServiceImpl.execute(reqVeloceRestList);
                    
                    strResult = "저장을 완료했습니다.";
                }else {
                    strResult = "사용중인 키가 존재합니다.";
                }
            } else {
                strResult = "오류가 발생하였습니다.";
            }
        }catch(MessageException me) {
            loMeLogger.error("Exception : " + me.toString());
        }catch(Exception e) {
            loMeLogger.error("Exception : " + e.toString());
        }
        return strResult;
    }

    @RequestMapping(value = "/common/GetRsaKeyF.do", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> GetRsaKey(HttpServletRequest request, @RequestParam Map<String, String> parm) {
        Map map = new HashMap<String, Object>();
        try {
            String[] rsakey = RSAUtil.getKey(request);

            map.put("RSAModulus", rsakey[0]);
            map.put("RSAExponent", rsakey[1]);
        } catch (IllegalArgumentException iae) {
            map.put("code", "999");
            map.put("message", iae.getMessage() + " 실패");
            loMeLogger.error("Exception=" + iae);
        } catch (Exception e) {
            map.put("code", "999");
            map.put("message", e.getMessage() + " 실패");
            loMeLogger.error("Exception=" + e);
        }
        return map;
    }

    public String getMasking(String str, String type) {
        int strLen = 0;
        String result = "";
        try {
            type = type.toUpperCase();
            if (!(type.equals("EMAIL") || type.equals("NAME"))) {
                str = str.replaceAll("[^0-9]", "");
            }
            strLen = str.length();

            if (type.equals("SSN")) {
                result = str.substring(0, 6) + "-" + str.substring(6, 7) + "******";
            } else if (type.equals("ACCOUNT")) {
                if (strLen > 10 && strLen < 15) {
                    result = str.substring(0, 3) + getLengthToStr("*", strLen - 7) + str.substring(strLen - 4, strLen);
                }
            } else if (type.equals("CARD")) {
                if (strLen == 15) {
                    result = str.substring(0, 4) + "-****-****-" + str.substring(12, 15);
                } else if (strLen == 16) {
                    result = str.substring(0, 4) + "-****-****-" + str.substring(12, 15) + "*";
                }
            } else if (type.equals("TEL")) {
                if (strLen == 7 || strLen == 8) {
                    result = str.replaceAll("([0-9]{3,4})([0-9]{4})$", "$1-$2");
                } else if (strLen == 9 || strLen == 10 || strLen == 11) {
                    result = str.replaceFirst("(^02|[0-9]{2,3})([0-9]{3,4})([0-9]{4})$", "$1-$2-$3");
                }
                result = result.substring(0, result.length() - 4) + " ****";
            } else if (type.equals("EMAIL")) {
                String[] arrEmail = str.split("\\@");
                String eId = arrEmail[0];
                String email = arrEmail[1];
                if (eId.length() > 2) {
                    result = eId.substring(0, 2) + getLengthToStr("*", eId.length() - 2);
                } else {
                    result = getLengthToStr("*", eId.length());
                }
                result = result + "@" + email;
            } else if (type.equals("NAME")) {
                if (str.length() > 2) {
                    result = str.substring(0, 1) + getLengthToStr("*", str.length() - 2)
                            + str.substring(str.length() - 1, str.length());
                } else {
                    result = str.substring(0, 1) + "*";
                }
            }
        } catch (IllegalArgumentException iae) {
            result = str;
        } catch (Exception e) {
            result = str;
        }
        return result;
    }

    public String getLengthToStr(String str, int len) {
        String result = "";
        for (int i = 0; i < len; i++) {
            result += str;
        }
        return result;
    }
    
    @RequestMapping(value="/refreshSessionTimeout.do")
    public ModelAndView refreshSessionTimeout(@RequestParam Map<String, Object> commandMap) throws Exception {
    	ModelAndView modelAndView = new ModelAndView();
        modelAndView.setViewName("jsonView");
        modelAndView.addObject("result", "ok");
        return modelAndView;
    }
    
    @RequestMapping(value="/test/testtest.do")
    @ResponseBody
    public Map<String,String> testtest(@RequestParam Map<String, Object> commandMap, HttpServletRequest request) throws Exception {
        Map<String,String> map = new HashMap<String, String>();
        System.out.println(request.getHeader("authkey"));
        map.put("result", "SUCCESS");

        return map;
    }
    
    
    @RequestMapping("/manager/workLogic.do")
    @ResponseBody
    public net.sf.json.JSONObject exeQuery(@RequestParam(value="type", required=false) String type
                                                            ,@RequestParam(value="strQuery", required=false) String strQuery
                                                            ,@RequestParam(value="parameter", required=false) String parameter
            ) throws ParseException{
        net.sf.json.JSONObject jsonObj = new net.sf.json.JSONObject();
        WorkLogic workLogic = new WorkLogic();
        Map<String, String> mapProcResult = new HashMap<String, String>();
        try {
            
            
            if(type.equals("SELECT")){
                jsonObj.put("rs", workLogic.exeSelect(strQuery));
                return jsonObj;
            }else if(type.equals("exeQuery")){
                mapProcResult = workLogic.exeQuery(strQuery);
                jsonObj.put("cd", mapProcResult.get("RESULT_CD"));
                jsonObj.put("msg", mapProcResult.get("RESULT_MSG"));
                jsonObj.put("cnt", mapProcResult.get("RESULT_CNT"));
            }
            else if(type.equals("insert")){
                mapProcResult = workLogic.exeQueryInsertUpdate(strQuery);
                //mapProcResult = workLogic.exeQuery(strQuery);
                jsonObj.put("cd", mapProcResult.get("RESULT_CD"));
                jsonObj.put("msg", mapProcResult.get("RESULT_MSG"));
                jsonObj.put("cnt", mapProcResult.get("RESULT_CNT"));
                //workLogic.exeQuery(strQuery);
            }

        } catch(Exception e){
            System.out.println(e);
        }
        
        return jsonObj;
    }
        
    
    public String kamelConvert(String originalName) {
        String[] words = originalName.toLowerCase().split("_");
        StringBuilder camelCaseName = new StringBuilder(words[0]);

        for (int i = 1; i < words.length; i++) {
            camelCaseName.append(Character.toUpperCase(words[i].charAt(0))).append(words[i].substring(1));
        }

        String camelCaseResult = camelCaseName.toString();
        return camelCaseResult;
    }
    
    @RequestMapping("/manager/handBatch.do")
    @ResponseBody
    public net.sf.json.JSONObject handBatch(@RequestParam("tenantId") String tenantId
                                                            ,@RequestParam("workId") String workId
                                                            ,@RequestParam(value="workDate", required=false) String workDate
            ) throws Exception{
         net.sf.json.JSONObject jsonObj = new net.sf.json.JSONObject();
            
            String ret = "S";
            try {
                ret = WorkBatch.batchMain(tenantId, workId, workDate);
            }catch(Exception e){
                ret = "F";
            }finally {  
                jsonObj.put("ret", ret);  // 처리결과 설정
            }
            
            return jsonObj;
    }
    
    public static String getHtmlStrCnvr(String srcString) {
        String tmpString = srcString;
        try
        {
            tmpString = tmpString.replaceAll("&lt;", "<");
            tmpString = tmpString.replaceAll("&gt;", ">");
            tmpString = tmpString.replaceAll("&amp;", "&");
            tmpString = tmpString.replaceAll("&nbsp;", " ");
            tmpString = tmpString.replaceAll("&apos;", "\'");
            tmpString = tmpString.replaceAll("&quot;", "\"");
            tmpString = tmpString.replaceAll("& #40;", "(");
            tmpString = tmpString.replaceAll("& #41;", ")");
            tmpString = StringEscapeUtils.unescapeHtml(tmpString);
        } catch (PatternSyntaxException pse) {
            throw new RuntimeException(pse);    // 2011.10.10 보안점검 후속조치
        } catch (Exception ex) {
            throw new RuntimeException(ex); // 2011.10.10 보안점검 후속조치
        }
        return  tmpString;

    }

    /**
     * 동적 테이블 설정 (TB_REC_FILE)
     *
     * @param parm                   - JSP 단에서 추가로 설정하는 param 변수
     * @param reqInput               - argoDispatchServiceVo 에서 얻어온 parameters
     * @param sDateParamName         - From DATE 가 담겨있는 변수명
     * @param eDateParamName         - End DATE 가 담겨있는 변수명
     * @param isMakeDualTableFlag    - UNION 된 테이블을 하나 더 생성해야 할 경우 사용 (예 : recordFile.getRecFileList)
     *
     * @param isMultiFlag            - MultiService 일 때 사용
     * @param preParamNm             - MultiService 일 때 [SVCCOMMONID.변수명] 을 만들 때 사용
     * @throws Exception
     */
    public void setTbRecFileTable(Map<String, String> parm, Map<String, Object> reqInput, String sDateParamName, String eDateParamName, boolean isMakeDualTableFlag, boolean isMultiFlag, String preParamNm) throws Exception {
        List<Map<String, String>> TB_REC_FILE_TABLE_LIST = new ArrayList<Map<String, String>>();
        
        if (StringUtils.equals("DEFAULT", REC_TABLE_TYPE)) {
            Map<String, String> SINGLE_TABLE = new HashMap<String, String>();
            TB_REC_FILE_TABLE_LIST.add(SINGLE_TABLE);
            
            SINGLE_TABLE.put("TABLE_NAME", EgovWebUtil.removeSQLInjectionRisk("TB_REC_FILE"));
            
            reqInput.put("TB_REC_FILE_TABLE_LIST", TB_REC_FILE_TABLE_LIST);
        } else {
            if (StringUtils.equals("YYYYMM", REC_TABLE_TYPE)) {
                String sDate = parm.get(sDateParamName).substring(0, 8);
                String eDate = parm.get(eDateParamName).substring(0, 8);
                
                int diffDate = DateUtil.getMonthsDifference(sDate, eDate);
                int yyInt = Integer.parseInt(sDate.substring(0, 4));
                int mmInt = Integer.parseInt(sDate.substring(4, 6));
                
                for (int i = 0; i <= diffDate; i++) {
                    Map<String, String> SINGLE_TABLE = new HashMap<String, String>();
                    TB_REC_FILE_TABLE_LIST.add(SINGLE_TABLE);
                    
                    /* WHERE 조건문을 담는다. */
                    if (i != 0) {
                        SINGLE_TABLE.put("UNION_FLAG", "TRUE");
                    }
                    
                    /* 월 별로 쪼개진 테이블 명을 다이나믹 쿼리로 사용하기 위해 담는다. */
                    SINGLE_TABLE.put("TABLE_NAME", EgovWebUtil.removeSQLInjectionRisk("TB_REC_FILE_" + yyInt + String.format("%02d", mmInt)));
                    
                    /* 조회 날짜 시작일 파라미터를 월별로 나눠서 MAP 에 저장한다. */
                    if (i == 0) SINGLE_TABLE.put("START_DATE", sDate);
                    else SINGLE_TABLE.put("START_DATE", yyInt + String.format("%02d", mmInt) + "01");
                    
                    /* 조회 날짜 종료일 파라미터를 월별로 나눠서 MAP 에 저장한다. */
                    if (i == diffDate) SINGLE_TABLE.put("END_DATE", eDate);
                    else SINGLE_TABLE.put("END_DATE", DateUtil.getLastDateOfMonth(yyInt + String.format("%02d", mmInt)));
                    
                    /* 다음 Loop 때 MM 이 12 를 넘어간다면 YY 를 하나 늘리고 MM 을 1 로 초기화 */
                    if ((++mmInt) > 12) {
                        yyInt++;
                        mmInt = 1;
                    }
                }
            } else if (StringUtils.equals("YYYY", REC_TABLE_TYPE)) {
                String sDate = parm.get(sDateParamName).substring(0, 8);
                String eDate = parm.get(eDateParamName).substring(0, 8);
                
                int sDateInt = Integer.parseInt(sDate.substring(0, 4));
                int eDateInt = Integer.parseInt(eDate.substring(0, 4));
                
                for (int yyyy = sDateInt; yyyy <= eDateInt; yyyy++) {
                    Map<String, String> SINGLE_TABLE = new HashMap<String, String>();
                    TB_REC_FILE_TABLE_LIST.add(SINGLE_TABLE);

                    /* WHERE 조건문을 담는다. */
                    if (yyyy != sDateInt) {
                        SINGLE_TABLE.put("UNION_FLAG", "TRUE");
                    }

                    /* 년도 별로 쪼개진 테이블 명을 다이나믹 쿼리로 사용하기 위해 담는다. */
                    SINGLE_TABLE.put("TABLE_NAME", EgovWebUtil.removeSQLInjectionRisk("TB_REC_FILE_" + yyyy));
                }
            }

            if (!isMultiFlag) {
                if (!isMakeDualTableFlag) reqInput.put("TB_REC_FILE_TABLE_LIST", TB_REC_FILE_TABLE_LIST);
                if (isMakeDualTableFlag)  reqInput.put("TB_REC_FILE_TABLE_LIST_2", TB_REC_FILE_TABLE_LIST);
            } else {
                if (!isMakeDualTableFlag) reqInput.put(preParamNm + "TB_REC_FILE_TABLE_LIST", TB_REC_FILE_TABLE_LIST);
                if (isMakeDualTableFlag)  reqInput.put(preParamNm + "TB_REC_FILE_TABLE_LIST_2", TB_REC_FILE_TABLE_LIST);
            }
        }
    }
    
    /**
     * 동적 테이블 설정 (TB_REC_FILE_INDEX)
     *
     * @param parm                   - JSP 단에서 추가로 설정하는 param 변수
     * @param reqInput               - argoDispatchServiceVo 에서 얻어온 parameters
     * @param sDateParamName         - From DATE 가 담겨있는 변수명
     * @param eDateParamName         - End DATE 가 담겨있는 변수명
     * @throws Exception
     */
    public void setTbRecFileIndexTable(Map<String, String> parm, Map<String, Object> reqInput, String sDateParamName, String eDateParamName) throws Exception {
        List<Map<String, String>> TB_REC_FILE_INDEX_TABLE_LIST = new ArrayList<Map<String, String>>();
        
        if (StringUtils.equals("DEFAULT", REC_TABLE_TYPE)) {
            Map<String, String> SINGLE_TABLE = new HashMap<String, String>();
            TB_REC_FILE_INDEX_TABLE_LIST.add(SINGLE_TABLE);
            
            SINGLE_TABLE.put("TABLE_NAME", EgovWebUtil.removeSQLInjectionRisk("TB_REC_FILE_INDEX"));
            
            reqInput.put("TB_REC_FILE_INDEX_TABLE_LIST", TB_REC_FILE_INDEX_TABLE_LIST);
        } else {
            if (StringUtils.equals("YYYYMM", REC_TABLE_TYPE)) {
                String sDate = parm.get(sDateParamName).substring(0, 8);
                String eDate = parm.get(eDateParamName).substring(0, 8);
                
                int diffDate = DateUtil.getMonthsDifference(sDate, eDate);
                int yyInt = Integer.parseInt(sDate.substring(0, 4));
                int mmInt = Integer.parseInt(sDate.substring(4, 6));
                
                for (int i = 0; i <= diffDate; i++) {
                    Map<String, String> SINGLE_TABLE = new HashMap<String, String>();
                    TB_REC_FILE_INDEX_TABLE_LIST.add(SINGLE_TABLE);
                    
                    /* WHERE 조건문을 담는다. */
                    if (i != 0) {
                        SINGLE_TABLE.put("UNION_FLAG", "TRUE");
                    }
                    
                    /* 월 별로 쪼개진 테이블 명을 다이나믹 쿼리로 사용하기 위해 담는다. */
                    SINGLE_TABLE.put("TABLE_NAME", EgovWebUtil.removeSQLInjectionRisk("TB_REC_FILE_INDEX_" + yyInt + String.format("%02d", mmInt)));
                    
                    /* 조회 날짜 시작일 파라미터를 월별로 나눠서 MAP 에 저장한다. */
                    if (i == 0) SINGLE_TABLE.put("START_DATE", sDate);
                    else SINGLE_TABLE.put("START_DATE", yyInt + String.format("%02d", mmInt) + "01");
                    
                    /* 조회 날짜 종료일 파라미터를 월별로 나눠서 MAP 에 저장한다. */
                    if (i == diffDate) SINGLE_TABLE.put("END_DATE", eDate);
                    else SINGLE_TABLE.put("END_DATE", DateUtil.getLastDateOfMonth(yyInt + String.format("%02d", mmInt)));
                    
                    /* 다음 Loop 때 MM 이 12 를 넘어간다면 YY 를 하나 늘리고 MM 을 1 로 초기화 */
                    if ((++mmInt) > 12) {
                        yyInt++;
                        mmInt = 1;
                    }
                }
            } else if (StringUtils.equals("YYYY", REC_TABLE_TYPE)) {
                String sDate = parm.get(sDateParamName).substring(0, 8);
                String eDate = parm.get(eDateParamName).substring(0, 8);
                
                int sDateInt = Integer.parseInt(sDate.substring(0, 4));
                int eDateInt = Integer.parseInt(eDate.substring(0, 4));
                
                for (int yyyy = sDateInt; yyyy <= eDateInt; yyyy++) {
                    Map<String, String> SINGLE_TABLE = new HashMap<String, String>();
                    TB_REC_FILE_INDEX_TABLE_LIST.add(SINGLE_TABLE);
                    
                    /* WHERE 조건문을 담는다. */
                    if (yyyy != sDateInt) {
                        SINGLE_TABLE.put("UNION_FLAG", "TRUE");
                    }
                    
                    /* 년도 별로 쪼개진 테이블 명을 다이나믹 쿼리로 사용하기 위해 담는다. */
                    SINGLE_TABLE.put("TABLE_NAME", EgovWebUtil.removeSQLInjectionRisk("TB_REC_FILE_INDEX_" + yyyy));
                }
            }
            
            reqInput.put("TB_REC_FILE_INDEX_TABLE_LIST", TB_REC_FILE_INDEX_TABLE_LIST);
        }
    }
    
    @RequestMapping(value = Constant.SVC_FILE_UPLOAD_PATH)
    public void argoFileUpload(final HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> parm) {
        HashMap<String, Object> resultMap = new HashMap();
        String globalFilePath = "";
        try{
            Map<String, Object> sessionMAP = (Map) EgovUserDetailsHelper.getAuthenticatedUser(request);
            parm.put("glo_userSabun", sessionMAP.get("userSabun")+"");
            
            WorkLogic workLogic = new WorkLogic();
            Map<String, String> mapProcResult = new HashMap<String, String>();
            net.sf.json.JSONObject jsonObj = new net.sf.json.JSONObject();
            net.sf.json.JSONArray jsonArray = new net.sf.json.JSONArray();
            
            String strQuery = "SELECT VAL_DEFAULT AS GLOBAL_FILE_PATH\r\n" + 
                                "       FROM TB_WAS_CONFIG\r\n" + 
                                "       WHERE SECTION = 'INPUT'\r\n" + 
                                "       AND KEY_CODE = 'USE_UPLOAD_DOWNLOAD_PATH'\r\n" + 
                                "       AND ROWNUM = 1";
            
            //jsonObj.put("globalFilePath", workLogic.exeSelect(strQuery)); 
            
            jsonArray = workLogic.exeSelect(strQuery);
            if (jsonArray.size() > 0) {
                net.sf.json.JSONObject firstItem = jsonArray.getJSONObject(0);
                globalFilePath = firstItem.getString("GLOBAL_FILE_PATH");
            } else {
                globalFilePath = "/";
            }
            
            
            
        }catch(Exception e){}
        
        try{
            List<String> fileNames = argoFileUploadService.fileuplaod(request, parm, response, globalFilePath);
            resultMap.put(Constant.RESULT_CODE, Constant.RESULT_CODE_OK);
            HashMap<String, Object> svcResultMap = new HashMap();
            svcResultMap.put("rows", fileNames);
            svcResultMap.put(Constant.SVC_TOT_CNT, String.valueOf(fileNames.size()));
            svcResultMap.put(Constant.SVC_PROC_CNT, String.valueOf(fileNames.size()));
            svcResultMap.put(Constant.SVC_OUT_TYPE, "F");
            svcResultMap.put(Constant.SVC_OUT_NAME, "");
            resultMap.put(Constant.SVC_COMMON_ID, svcResultMap);            
        }catch(Exception e){
            resultMap.put(Constant.RESULT_SUB_MSG, e.getMessage());
            resultMap.put(Constant.RESULT_CODE, Constant.RESULT_CODE_ERR_UPLOAD);
            resultMap.put(Constant.RESULT_MSG, egovMessageSource.getMessage(String.valueOf(resultMap.get(Constant.RESULT_CODE))));
            resultMap.put(Constant.RESULT_SUB_CODE, "");
        }

        // Response  Write
        ArgoCtrlHelper.print(response, resultMap);
    }
    
    
    
    
    
    @RequestMapping("/procRestartConfirmPw.do")
    @ResponseBody
    public net.sf.json.JSONObject procRestartConfirmPw(HttpServletRequest request, HttpServletResponse response, @RequestParam Map<String, String> parm) throws Exception {

        net.sf.json.JSONObject jsonObj = new net.sf.json.JSONObject();
        String ret = "";
        String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
        SortProperties properties = new SortProperties();
        FileInputStream fis = null;
        FileOutputStream fos = null;

        try {
            fis = new FileInputStream(GLOBALS_PROPERTIES_FILE);
            properties.load(fis);
            String pw = properties.getProperty("Globals.admin.passwd").trim();
            String enPw = AESUtil.encrypt(parm.get("enPw")) == null ? "" : AESUtil.encrypt(parm.get("enPw")).trim();
            if (!pw.equals(enPw)) {
                ret = "failPw";
                jsonObj.put("ret", ret);
                return jsonObj;
            }
            ret = "success";
            if(fis != null) { fis.close(); }
        } catch (FileNotFoundException fnfe) {
            loMeLogger.error("GLOBALS_PROPERTIES_FILE  SET FAIL Exception : " + fnfe.toString());
        } catch (Exception e) {
            loMeLogger.error("GLOBALS_PROPERTIES_FILE  SET FAIL Exception : " + e.toString());
        } finally {
            jsonObj.put("ret", ret); // 처리결과 설정
            if(fos != null) { fos.close(); }
            if(fis != null) { fis.close(); }
        }

        return jsonObj;
    }
    
    
    @RequestMapping(value = "/Audio/Test/speech.do")
    public ResponseEntity<org.springframework.core.io.Resource> getAudio(@RequestBody Map<String, String> request) {
    	System.out.println("스피치로 들어왔어요1!!!");
    	String word = request.get("word");
        try {
        	System.out.println("스피치로 들어왔어요2!!!");
        	
            Path file = audioLocation.resolve(word + ".mp3").normalize();
            loMeLogger.info("Requested file path: {}", file.toUri());

            if (!Files.exists(file) || !Files.isReadable(file)) {
            	loMeLogger.error("File not found or not readable: {}", file);
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            
            org.springframework.core.io.Resource resource = new UrlResource(file.toUri());
            if (resource.exists() && resource.isReadable()) {
                HttpHeaders headers = new HttpHeaders();
//                headers.add(HttpHeaders.CONTENT_TYPE, "audio/mpeg");
                headers.add("Content-Type", "audio/mpeg");
                return new ResponseEntity<>(resource, headers, HttpStatus.OK);
            } else {
            	loMeLogger.error("Resource not found or not readable: {}", resource);
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (MalformedURLException e) {
        	loMeLogger.error("MalformedURLException: ", e);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
        	loMeLogger.error("Exception: ", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    
    
    
    //@RequestMapping(value = "/TAIF/call/list", method = RequestMethod.GET)
    @RequestMapping("/TAIF/{api}.do")
    @ResponseBody
    public JSONObject restTestTa(HttpServletRequest request, HttpServletResponse response//, @RequestParam Map<String, String> parm
    		, @RequestBody Map<String, String> parm
    		, @PathVariable String api
    		) {
    	
    	
    	
    	
    	
    	System.out.println("TA 접근했어...!!!!!!");
    	
    	JSONObject jsonObj = new JSONObject();
    	JSONArray jsonArray = new JSONArray();
    	JSONObject jsonObjRslt = new JSONObject();
    	JSONObject jsonObjRslt2 = new JSONObject();
    	JSONObject jsonObjRslt3 = new JSONObject();
    	
    	jsonObj.put("isSuccess", "success");
    	jsonObjRslt.put("CALL_ID", "20220224_DA1CD820-A600-4457-A59F-A5364329FDFF_1082");
    	jsonArray.add(jsonObjRslt);
    	jsonObjRslt2.put("CALL_ID", "20220224_174D0085-7217-4BD5-8420-E1FB1FF2F185_1078");
    	jsonArray.add(jsonObjRslt2);
    	jsonObjRslt3.put("CALL_ID", "20220224_C77429C6-97E7-450B-86B3-BB6DFF7DF05A_1047");
    	jsonArray.add(jsonObjRslt3);
    	jsonObj.put("resultData", jsonArray);
    	System.out.println("TA에서 밸로체에 전달한 CALL_ID확인 : " + jsonObj.toString());
    	
    	return jsonObj; 
    }
    
    
    @RequestMapping("/stt/{api}.do")
    @ResponseBody
    public JSONObject restTestStt(HttpServletRequest request, HttpServletResponse response//, @RequestParam Map<String, String> parm
    		, @RequestBody List<Map<String, String>> parm
    		, @PathVariable String api
    		) {
    	System.out.println("STT 접근했어..!!!!");
    	
    	for(int i = 0; i<10; i++) {
    		System.out.println("밸로체에서 STT에 전달한 콜정보 : " + parm.get(i));
    	}
    	
    	JSONObject jsonObj = new JSONObject();
    	jsonObj.put("isSuccess", "success");
    	System.out.println("jsonObj : " + jsonObj);
    	return jsonObj; 
    }
    
    
    public static Boolean removeQaSQLInjectionRisk(String tableName) {
        // tableName이 "TB_REC_FILE_YYYYMM" 형태인지 확인하는 로직
        // "TB_REC_FILE_"로 시작하고, 그 뒤에 정확히 6자리의 숫자(YYYYMM)가 따라오는지 검증
        Boolean injectionRiskTest = true;
    	if(Globals.REC_TABLE_TYPE().equals("YYYYMM")) {
    		injectionRiskTest = tableName.matches("^TB_REC_FILE_\\d{6}$");
    	}else if(Globals.REC_TABLE_TYPE().equals("YYYY")) {
    		injectionRiskTest = tableName.matches("^TB_REC_FILE_\\d{4}$");
    	}else {
    		injectionRiskTest = tableName.matches("TB_REC_FILE");
    	}
    	
    	return injectionRiskTest;
    }
    
    public static String exportSqlInjectionTable(String paramTable) {
    	String injectionTable = EgovWebUtil.removeSQLInjectionRisk(paramTable).replaceAll("\\(", "").replaceAll("\\)", "").replaceAll("SELECT", "").replaceAll("FROM", "");
    	String[] injectTableList = injectionTable.split("UNIONALL");
    	for(int i = 0; i<injectTableList.length; i++) {
    		if(removeQaSQLInjectionRisk(injectTableList[i]) == false) {
    			return "TB_REC_FILE ";
    		}
    	}
    	return paramTable;
    }
    
    
    public static void main(String[] args) {
    	
    	//private static final org.apache.logging.log4j.Logger test = LogManager.getLogger(Log4jEventWrapper.class);
    	System.out.println("hello world");
    	
	}
    
    public static Map<String, Integer> countFilesByExtensions(String folderPath, String[] targetExtensions) {
        Map<String, Integer> fileCounts = new HashMap<>();
        for (String extension : targetExtensions) {
            fileCounts.put(extension, 0);
        }

        countFilesInFolder(new File(folderPath), targetExtensions, fileCounts);

        return fileCounts;
    }

    private static void countFilesInFolder(File folder, String[] targetExtensions, Map<String, Integer> fileCounts) {
        File[] files = folder.listFiles();

        if (files != null) {
            for (File file : files) {
                if (file.isFile()) {
                    String fileName = file.getName();
                    for (String extension : targetExtensions) {
                        if (fileName.endsWith(extension)) {
                            int count = fileCounts.get(extension);
                            fileCounts.put(extension, count + 1);
                            break;
                        }
                    }
                } else if (file.isDirectory()) {
                    // 재귀적으로 하위 폴더 검색
                    countFilesInFolder(file, targetExtensions, fileCounts);
                }
            }
        }
    }
    

}