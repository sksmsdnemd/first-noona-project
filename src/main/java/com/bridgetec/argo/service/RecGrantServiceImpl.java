package com.bridgetec.argo.service;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.dao.ArgoDispatchDAO;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import egovframework.rte.fdl.cmmn.AbstractServiceImpl;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("recGrantService")
public class RecGrantServiceImpl extends AbstractServiceImpl {
    private final Logger log = LoggerFactory.getLogger(RecGrantServiceImpl.class);
    
	@Resource(name = "ARGODB")
    private ArgoDispatchDAO argoDao;

    /**
     * 녹취권한승인정보 조회
     *
     * @param saDispatchServiceVo ArgoDispatchServiceVo
     * @throws Exception 예외
     */
    public void getRecGrantAprv(ArgoDispatchServiceVo saDispatchServiceVo) throws Exception {
        saDispatchServiceVo.setDbType(Constant.SVC_DB_TYPE_SELECT);
        String recTime = (String) saDispatchServiceVo.getReqInput().get("recTime");
        saDispatchServiceVo.getReqInput().put("recDt", recTime.substring(0, 6));    // TB_REC_FILE_YYYYMM
        argoDao.excute(saDispatchServiceVo);
    }

    /**
     * 녹취권한승인정보 리스트 조회
     *
     * @param vo saDispatchServiceVo
     * @throws Exception 예외
     */
    public void getRecGrantAprvList(ArgoDispatchServiceVo vo) throws Exception {
        // 건수 조회
        Map<String, Object> param = vo.getReqInput();
        Object obj = argoDao.selectByPk("recGrantAprv.getRecGrantAprvListCnt", param);

        // 리스트 조회
        int totCnt = obj == null || ((EgovMap) obj).get("cnt") == null ? 0 : ((BigDecimal) ((EgovMap) obj).get("cnt")).intValue();
        vo.setTotCnt(totCnt);
        List<EgovMap> list = null;
        if (totCnt > 0) {
            list = argoDao.list("recGrantAprv.getRecGrantAprvList", param);
            vo.setResOut(list);
        }
    }

    /**
     * 승인권한자 리스트 조회
     *
     * @param vo ArgoDispatchServiceVo
     * @throws Exception 예외
     */
    public void getRecGrantAprvrList(ArgoDispatchServiceVo vo) throws Exception {
        // 해당 그룹의 승인권한자 리스트 조회
        vo.setDbType(Constant.SVC_DB_TYPE_LIST);
        vo.setSvcName("recGrantAprv");
        vo.setMethodName("getRecGrantAprvrList");
        argoDao.excute(vo);
    }

    /**
     * 녹취권한승인정보 등록
     *
     * @param param 파라미터 맵
     * @return 처리건수
     * @throws Exception 예외
     */
    public int addRecGrantAprv(Map<String, Object> param) throws Exception {
        ArgoDispatchServiceVo saDispatchServiceVo = new ArgoDispatchServiceVo(Constant.SVC_COMMON_ID);
        saDispatchServiceVo.setDbType(Constant.SVC_DB_TYPE_UPDATE);
        saDispatchServiceVo.setSvcName("recGrantAprv");
        saDispatchServiceVo.setMethodName("setRecGrantAprvInsert");
        saDispatchServiceVo.setReqInput(param);

        argoDao.excute(saDispatchServiceVo);
        return saDispatchServiceVo.getProCnt();
    }

    /**
     * 녹취권한승인정보 리스트 등록
     *
     * @param saDispatchServiceVo ArgoDispatchServiceVo
     * @throws Exception 예외
     */
    public void addRecGrantAprvList(ArgoDispatchServiceVo saDispatchServiceVo) throws Exception {
        int result = 0;

        // 1.권한정보 Update
        Map<String, Object> in = saDispatchServiceVo.getReqInput(); // 파라미터
        List<Map<String, Object>> list = (List<Map<String, Object>>) in.get("params");
        for (Map<String, Object> ua : list) {
            result = this.addRecGrantAprv(ua);
        }

        // 예외처리
        if (result < 1) {
            throw new MessageException(new Exception(), Constant.RESULT_CODE_ERR_PROC);
        }
    }

    /**
     * 녹취권한 승인/반려 처리
     *
     * @param saDispatchServiceVo 파라미터
     * @throws Exception 예외
     */
    public void approvalRecGrant(ArgoDispatchServiceVo saDispatchServiceVo) throws Exception {
        int result = 0;

        // 1. 승인정보 Update
        saDispatchServiceVo.setDbType(Constant.SVC_DB_TYPE_UPDATE);
        argoDao.excute(saDispatchServiceVo);
        result = saDispatchServiceVo.getProCnt();

        // 2. 녹취권한 등록(Insert)
        Map<String, Object> in = saDispatchServiceVo.getReqInput(); // 파라미터
        String aprvStatus = (String) in.get("aprvStatus");  // 승인상태
        if (result > 0 && "A".equals(aprvStatus)) {
            // 녹취권한 등록 파라미터
            Map<String, Object> map = new HashMap<>();
            map.put("tenantId"      , in.get("tenantId"));
            map.put("userId"        , in.get("userId"));
            map.put("recKey"        , in.get("recKey"));
            map.put("startDate"     , in.get("startDt"));
            map.put("endDate"       , in.get("endDt"));
            map.put("insId"         , in.get("aprvrId"));
            map.put("downloadFlag"  , in.get("recGrant"));
            map.put("reason"        , in.get("reqReason"));
            saDispatchServiceVo.setReqInput(map);

            // 녹취권한 Insert
            result = argoDao.update("recInfo.registerGrandInfo", map);
        }

        // 예외처리
        if (result < 1) {
            throw new MessageException(Constant.RESULT_CODE_ERR_PROC);
        }
    }

    /**
     * 녹취권한 신청 취소
     *
     * @param saDispatchServiceVo 파라미터
     * @throws Exception 예외
     */
    public void cancelAprvReq(ArgoDispatchServiceVo saDispatchServiceVo) throws Exception {
        saDispatchServiceVo.setDbType(Constant.SVC_DB_TYPE_DELETE);
        argoDao.excute(saDispatchServiceVo);
    }
}
