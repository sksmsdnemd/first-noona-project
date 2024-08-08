package com.bridgetec.argo.service;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.dao.ArgoDispatchDAO;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.bridgetec.common.util.security.EncryptUtil;
import egovframework.com.cmm.service.EgovProperties;
import egovframework.rte.fdl.cmmn.AbstractServiceImpl;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.security.NoSuchAlgorithmException;
import java.util.*;

@Service("userService")
public class UserServiceImpl extends AbstractServiceImpl {
    private final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);
    
	@Resource(name = "ARGODB")
    private ArgoDispatchDAO argoDao;


    /**
     * 녹취권한 승인/반려 처리
     *
     * @param param 파라미터
     * @throws Exception 예외
     */
    public int saveUserAuthList(Map<String, Object> param) throws Exception {
        int result = 0;

        // 1.권한정보 Update
        List<Map<String, Object>> list = (List<Map<String, Object>>) param.get("params");
        for (Map<String, Object> ua : list) {
            result += this.saveUserAuth(ua);
        }

        // 예외처리
        if (result < 1) {
            throw new MessageException(new Exception(), Constant.RESULT_CODE_ERR_PROC);
        }

        return result;
    }


    /**
     * 사용자 권한 저장
     *
     * @param param 사용자권한정보
     * @return 처리건수
     * @throws Exception 예외
     */
    public int saveUserAuth(Map<String, Object> param) throws Exception {
        int result = 0;

        // 사용자 권한이 "SuperAdmin" 이면 다운로드승인권한 부여
        String tenantId = (String) param.get("tenantId");
        String grantId  = (String) param.get("grantId");
        param.put("recDownloadYn", "SuperAdmin".equals(grantId) ? "Y" : "N");

        // GroupManager 권한인 사용자의 제어그룹을 지정하지 않으면 사용자그룹으로 저장
        if ("GroupManager".equals(grantId) && (param.get("controlGroup") == null || ((String) param.get("controlGroup")).equals(""))) {
            param.put("controlGroup", param.get("groupId"));
        }

        // 중복 제어그룹 제거
        if (param.get("controlGroup") != null && !((String) param.get("controlGroup")).equals("")) {
            String ca = (String) param.get("controlGroup");
            List<String> controlAuthList = new ArrayList<>(Arrays.asList(ca.split(",")));
            List<Map<String, String>> caList = new ArrayList<>();
            List<String> cgList = new ArrayList<>();
            List<Map<String, String>> childList = null;
            for (final String groupId : controlAuthList) {
                if (!this.existsGroup(caList, groupId)) {
                    childList = this.getChildGroupList(tenantId, groupId);
                    if (childList != null && childList.size() > 0) {
                        caList.addAll(childList);
                        cgList.add(groupId);
                    }
                }
            }
            if (cgList.size() > 0) {
                param.put("controlGroup", String.join(",", cgList));
            }
        }

        // 사용자권한 Insert 파라미터
        //vo.setReqInput(param);

        // Upsert
        result = argoDao.update("userAuth.setUserAuthUpsert", param);

        // 처리 건수
        return result;
    }

    /**
     * 그룹존재여부 체크
     *
     * @param list 그룹 리스트
     * @param groupId 그룹ID
     * @return 그룹존재여부
     */
    private boolean existsGroup(List<Map<String, String>> list, String groupId) {
        boolean b = false;

        if (list != null && list.size() > 0) {
            for (Map<String, String> map : list) {
                if (map.containsKey("groupId") && ((String) map.get("groupId")).equals(groupId)) {
                    b = true;
                    break;
                }
            }
        }

        return b;
    }

    /**
     * 하위그룹 리스트 조회
     *
     * @param tenantId 태넌트ID
     * @param groupId 그룹ID
     * @return 하위그룹 리스트
     */
    private List<Map<String, String>> getChildGroupList(String tenantId, String groupId) {
        Map<String, Object> map = new HashMap<>();
        map.put("tenantId"  , tenantId);
        map.put("groupId"   , groupId);

        return (List<Map<String, String>>) argoDao.list("Group.getChildGroupList", map);
    }

    /**
     * 사용자정보 변경
     *
     * @param param 사용자정보
     * @return 처리건수
     * @throws Exception 예외
     */
    public void setUserInfo(Map<String, Object> param) throws Exception {
        int result = 0;

        // 사용자정보 조회
        ArgoDispatchServiceVo sel = this.getUserInfo((String) param.get("tenantId"), (String) param.get("userId"));

        // "사용자가 존재하지 않습니다."
        if (sel.getResOut() == null) {
            throw new MessageException(new Exception(), "fail.user.not.found");
        }

        // 비밀번호 암호화 및 이전비밀번호 체크
        if (param.get("userPwd") != null && !"".equals((String) param.get("userPwd"))) {
            EgovMap selMap = (EgovMap) sel.getResOut();

            String encPassword = this.encryptUserPassword((String) param.get("userPwd"), (String) selMap.get("salt"));
            param.put("userPwd", encPassword);

            // 이전 비밀번호 사용여부 체크
            if (selMap.get("userPwd").equals(encPassword)) {
                throw new MessageException(new Exception(), "fail.invalid.id"); // "이전에 사용하셨던 비밀번호는 사용하실 수 없습니다."
            }
        }

        // 사용자정보 update
        result = argoDao.update("userInfo.setUserInfoUpdate", param);

        // 사용자권한 저장
        if (result > 0) {
           result = this.saveUserAuth(param);
        }

        // 예외처리
        if (result < 1) {
            throw new MessageException(new Exception(), Constant.RESULT_CODE_ERR_PROC);
        }
    }


    /**
     * 사용자정보 등록
     *
     * @param param 파라미터
     * @throws Exception 예외
     */
    public void addUserInfo(Map<String, Object> param) throws Exception {
        int result = 0;

        // 사용자정보 조회
        ArgoDispatchServiceVo sel = this.getUserInfo((String) param.get("tenantId"), (String) param.get("userId"));

        // "#ip_UserId").val() + "(은/는) 이미 존재합니다."
        if (sel.getResOut() != null) {
            throw new MessageException(new Exception(), "fail.already.exist");
        }

        // 사용자정보 등록
        String salt = this.encryptUserSalt();
        param.put("salt"    , salt);
        param.put("userPwd" , this.encryptUserPassword((String) param.get("userPwd"), salt));
        result = argoDao.update("userInfo.setUserInfoInsert", param);

        // 사용자권한 저장
        if (result > 0) {
            result = this.saveUserAuth(param);
        }

        // 예외처리
        if (result < 1) {
            throw new MessageException(new Exception(), Constant.RESULT_CODE_ERR_PROC);
        }
    }


    /**
     * 사용자정보 조회
     *
     * @param tenantId 태넌트ID
     * @param userId 사용자ID
     * @return ArgoDispatchServiceVo
     * @throws Exception 예외
     */
    public ArgoDispatchServiceVo getUserInfo(String tenantId, String userId) throws Exception {
        ArgoDispatchServiceVo vo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);

        Map<String, Object> param = new HashMap<>();
        param.put("tenantId"  , tenantId);
        param.put("userId"    , userId);

        Object obj = argoDao.selectByPk("userInfo.getUserInfo", param);
        vo.setResOut(obj);

        return vo;
    }


    /**
     * 사용자 패스워드 암호화
     *
     * @param password 패스워드
     * @param encryptSalt Salt
     * @return 암호화된 패스워드
     * @throws IOException 예외
     * @throws NoSuchAlgorithmException 예외
     */
    public String encryptUserPassword(String password, String encryptSalt) throws IOException, NoSuchAlgorithmException {
        String SHA_TYPE = EgovProperties.getProperty("Globals.encryptType");
        EncryptUtil encp = new EncryptUtil();
        byte[] bDigest = encp.getEncSaltData(SHA_TYPE, password, encp.base64ToByte(encryptSalt), false);

        return encp.byteToBase64(bDigest);
    }

    /**
     *
     * @return
     * @throws UnsupportedEncodingException
     * @throws NoSuchAlgorithmException
     */
    public String encryptUserSalt() throws UnsupportedEncodingException, NoSuchAlgorithmException {
        EncryptUtil encp = new EncryptUtil();
        byte[] bSalt = encp.getSaltData();
        return encp.byteToBase64(bSalt);
    }

    /**
     * 사용자 패스워드 변경
     *
     * @param tenantId 태넌트ID
     * @param userId 사요자ID
     * @param password 패스워드
     * @return 처리건수
     */
    public int setUserPassword(String tenantId, String userId, String password) {
        return this.setUserPassword(tenantId, userId, password, null);
    }
    public int setUserPassword(String tenantId, String userId, String password, String salt) {
        Map<String, Object> param = new HashMap<>();
        param.put("tenantId", tenantId);
        param.put("userId"  , userId);
        param.put("userPwd" , password);
        param.put("salt"    , salt);

        return argoDao.update("userInfo.pwdUpdate", param);
    }


    /**
     * 환경설정 정보 조회
     *
     * @param section
     * @param keyCode
     * @return
     */
    public EgovMap getConfigValue(String section, String keyCode) {
        Map<String, Object> param = new HashMap<>();
        param.put("section", section);
        param.put("keyCode", keyCode);

        Object obj = argoDao.selectByPk("comboBoxCode.getConfigValue", param);
        return obj != null ? (EgovMap) obj : null;
    }

    /**
     * 로그인 IP 체크
     *
     * @param tenantId
     * @param loginIp
     * @return
     */
    public EgovMap getLoginIpCheck(String tenantId, String loginIp) {
        Map<String, Object> param = new HashMap<>();
        param.put("tenantId", tenantId);
        param.put("loginIp", loginIp);

        Object obj = argoDao.selectByPk("userInfo.getLoginIpCheck", param);
        return obj != null ? (EgovMap) obj : null;
    }

    /**
     * 하위권한 리스트 조회
     *
     * @param tenantId 태넌트ID
     * @param authRank 권한랭크
     * @return 리스트
     */
    public List getAuthLowRankList(String tenantId, int authRank) {
        Map<String, Object> authParam = new HashMap<>();
        authParam.put("tenantId", tenantId);
        authParam.put("low"     , new BigDecimal(authRank));
        return argoDao.list("auth.getAuthList", authParam);
    }
}
