package com.bridgetec.argo.dao;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.orm.ibatis.SqlMapClientCallback;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapExecutor;
import com.ibatis.sqlmap.engine.impl.ExtendedSqlMapClient;
import com.ibatis.sqlmap.engine.mapping.parameter.ParameterMap;
import com.ibatis.sqlmap.engine.mapping.parameter.ParameterMapping;
import com.ibatis.sqlmap.engine.mapping.statement.MappedStatement;
import com.ibatis.sqlmap.engine.scope.SessionScope;
import com.ibatis.sqlmap.engine.scope.StatementScope;

import egovframework.com.cmm.EgovMessageSource;
import egovframework.rte.fdl.string.EgovStringUtil;
import egovframework.rte.psl.dataaccess.EgovAbstractDAO;

public class ArgoDispatchDAO extends EgovAbstractDAO implements IArgoDispatchDAO {
    private Logger            loMeLogger = LoggerFactory.getLogger(ArgoDispatchDAO.class);

    int errorPosition=0;
    
    @Resource(name="egovMessageSource")
    EgovMessageSource egovMessageSource;    

    public ArgoDispatchDAO() {
        //loMeLogger.debug("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
    }
    
    public void setSuperSqlMapClient(SqlMapClient sqlMapClient) {
        super.setSuperSqlMapClient(sqlMapClient);
    }

    private void insert(ArgoDispatchServiceVo argoServiceVO) throws Exception {
        try {
            Object obj = insert(argoServiceVO.getQueryId(), argoServiceVO.getReqInput());
            argoServiceVO.setProCnt(1);
        } catch(NullPointerException npe) {

			loMeLogger.error("[" + argoServiceVO.getUserSabun() + "] insert EXCEPTION :" + npe.toString());
            throw new MessageException(npe, Constant.RESULT_CODE_ERR_INSERT);
        } catch(Exception ex) {
        	
        	loMeLogger.error("[" + argoServiceVO.getUserSabun() + "] insert EXCEPTION :" + ex.toString());
        	throw new MessageException(ex, Constant.RESULT_CODE_ERR_INSERT);
        }
    }

    private void update(ArgoDispatchServiceVo argoServiceVO) throws Exception {
        try {
            int cnt = update(argoServiceVO.getQueryId(), argoServiceVO.getReqInput());
            argoServiceVO.setProCnt(cnt);
        } catch(NullPointerException npe) {
            loMeLogger.error("["+argoServiceVO.getUserSabun()+"] update EXCEPTION :"+npe.toString());
            throw new MessageException(npe, Constant.RESULT_CODE_ERR_UPDATE);
        } catch(Exception ex) {
        	loMeLogger.error("["+argoServiceVO.getUserSabun()+"] update EXCEPTION :"+ex.toString());
        	throw new MessageException(ex, Constant.RESULT_CODE_ERR_UPDATE);
        }
    }

    private void delete(ArgoDispatchServiceVo argoServiceVO) throws Exception {
        try {
            int cnt = delete(argoServiceVO.getQueryId(), argoServiceVO.getReqInput());
            argoServiceVO.setProCnt(cnt);
        } catch(NullPointerException npe) {
            loMeLogger.error("["+argoServiceVO.getUserSabun()+"] delete EXCEPTION :"+npe.toString());
            throw new MessageException(npe, Constant.RESULT_CODE_ERR_DELETE);
        } catch(Exception ex) {
        	loMeLogger.error("["+argoServiceVO.getUserSabun()+"] delete EXCEPTION :"+ex.toString());
        	throw new MessageException(ex, Constant.RESULT_CODE_ERR_DELETE);
        }
    }

    private void select(ArgoDispatchServiceVo argoServiceVO) throws Exception {
        try {
//        	System.out.println("Call ArgoDispatchDAO.select");
        	loMeLogger.debug("Call ArgoDispatchDAO.select");
        	
            Map map = (Map) selectByPk(argoServiceVO.getQueryId(), argoServiceVO.getReqInput());
            argoServiceVO.setResOut(map);
            if(map==null)   argoServiceVO.setProCnt(0);
            else            argoServiceVO.setProCnt(1);
        } catch(NullPointerException npe) {
            loMeLogger.error("["+argoServiceVO.getUserSabun()+"] ONE select EXCEPTION :"+npe.toString());
            throw new MessageException(npe, Constant.RESULT_CODE_ERR_SELECT);
        } catch(Exception ex) {
        	loMeLogger.error("["+argoServiceVO.getUserSabun()+"] ONE select EXCEPTION :"+ex.toString());
        	throw new MessageException(ex, Constant.RESULT_CODE_ERR_SELECT);
        }
    }
    
    // lmk872 프로시저 호출부분 추가 
    private void procedure(ArgoDispatchServiceVo argoServiceVO) throws Exception {
        try {
//        	System.out.println("Call ArgoDispatchDAO.procedure");
        	loMeLogger.debug("Call ArgoDispatchDAO.procedure");
        	
            Map map = (Map) selectByPk(argoServiceVO.getQueryId(), argoServiceVO.getReqInput());
            argoServiceVO.setResOut(map);
            if(map==null)   argoServiceVO.setProCnt(0);
            else            argoServiceVO.setProCnt(1);
        } catch(NullPointerException npe) {
            loMeLogger.error("["+argoServiceVO.getUserSabun()+"] ONE select EXCEPTION12 :"+npe.toString());
            throw new MessageException(npe, Constant.RESULT_CODE_ERR_CALLSP);
        } catch(Exception ex) {
        	loMeLogger.error("["+argoServiceVO.getUserSabun()+"] ONE select EXCEPTION12 :"+ex.toString());
        	throw new MessageException(ex, Constant.RESULT_CODE_ERR_CALLSP);
        }
    }
    
    private void list(ArgoDispatchServiceVo argoServiceVO) throws Exception {
        try {
//        	System.out.println("Call ArgoDispatchDAO.list");
        	loMeLogger.debug("Call ArgoDispatchDAO.list");
        	
            List list = list(argoServiceVO.getQueryId(),  argoServiceVO.getReqInput());
            argoServiceVO.setResOut(list);
            if(list != null && list.size() > 0) {
                argoServiceVO.setProCnt(list.size());
                Map resultMap = (Map) list.get(0);
                if(resultMap.containsKey(Constant.SVC_TOT_CNT)) {
                    argoServiceVO.setTotCnt(((BigDecimal) (resultMap.get(Constant.SVC_TOT_CNT))).longValue());
                }
            }
        } catch(NullPointerException npe) {
            loMeLogger.error("["+argoServiceVO.getUserSabun()+"] LIST list NullPointerException :"+npe.toString());
            throw new MessageException(npe, Constant.RESULT_CODE_ERR_SELECT);
        } catch(Exception ex) {
        	loMeLogger.error("["+argoServiceVO.getUserSabun()+"] LIST list EXCEPTION :"+ex.toString());
        	throw new MessageException(ex, Constant.RESULT_CODE_ERR_SELECT);
        }
    }

    public String getGrantForm(ArgoDispatchServiceVo argoServiceVO,Map map) throws Exception {
    	String result ="";
    	 try {
//         	System.out.println("Call ArgoDispatchDAO.getGrantForm");
         	loMeLogger.debug("Call ArgoDispatchDAO.getGrantForm");
         	//argoServiceVO.get
             Map map2 = (Map) selectByPk("ARGOCOMMON.grantForm", map);
             argoServiceVO.setResOut(map2);
             result = (String)map2.get("authKind");
//             if(map2==null)   argoServiceVO.setProCnt(0);
//             else            argoServiceVO.setProCnt(1);
         } catch(NullPointerException npe) {
             loMeLogger.error("["+argoServiceVO.getUserSabun()+"] ONE select NullPointerException :"+npe.toString());
             throw new MessageException(npe, Constant.RESULT_CODE_ERR_SELECT);
         } catch(Exception ex) {
        	 loMeLogger.error("["+argoServiceVO.getUserSabun()+"] ONE select EXCEPTION :"+ex.toString());
        	 throw new MessageException(ex, Constant.RESULT_CODE_ERR_SELECT);
         }
    	 return result;
    }
    
    
    
    
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void batchInsert(final ArgoDispatchServiceVo argoServiceVO) throws Exception {
        
        Object cnt = 0;
        try{
            cnt = getSqlMapClientTemplate().execute( new SqlMapClientCallback() {
                public Object doInSqlMapClient(SqlMapExecutor executor) throws SQLException {
                    
                    int result = 0;
                    List list = (List) argoServiceVO.getReqInput().get(Constant.EXCEL_IMPORT_DATA);
                    if(list.size() < 1) return result;
                    
                    HashMap glo_map = new HashMap();
                    Map param = (Map)argoServiceVO.getReqInput();
                    for( Object key : param.keySet() ){
                        if(EgovStringUtil.isNotEmpty((String)key)){
                            if(!((String)key).startsWith(Constant.EXCEL_IMPORT_DATA)){
                                glo_map.put(key, param.get(key));
                            }
                        }
                    }
                    
                    for (int i = 0; i < list.size(); i++) {
                        HashMap row = (HashMap) list.get(i);
                        errorPosition = i+1;
                        
                        executor.startBatch();
                        executor.insert(argoServiceVO.getQueryId(), deepMerge(row,glo_map));
                        result++;
                        executor.executeBatch();
//                        if (i % 1000 == 0) {
//                            executor.startBatch();
//                        }
                    }
//                    executor.executeBatch();
                    
                    return result;
                }
            });
            
        } catch(NullPointerException npe) {
            loMeLogger.error("["+argoServiceVO.getUserSabun()+"] Batch Insert NullPointerException :"+npe.toString()+"[엑셀에러위치(헤더제외) : " + errorPosition + "행]");
            
            MessageException me = new MessageException(npe, Constant.RESULT_CODE_ERR_BULK_INSERT);
            me.setUserMessage("[엑셀에러위치(헤더제외) : " + errorPosition +"행]");
            throw me;
        } catch(Exception ex) {
        	loMeLogger.error("["+argoServiceVO.getUserSabun()+"] Batch Insert EXCEPTION :"+ex.toString()+"[엑셀에러위치(헤더제외) : " + errorPosition + "행]");
        	
        	MessageException me = new MessageException(ex, Constant.RESULT_CODE_ERR_BULK_INSERT);
        	me.setUserMessage("[엑셀에러위치(헤더제외) : " + errorPosition +"행]");
        	throw me;
        } finally{
            argoServiceVO.setProCnt((int) cnt);
        }
    }

    @Override
	public void excute(ArgoDispatchServiceVo argoDispatchServiceVo) throws Exception {
        
        //debug mode면 sql을 남긴다. 
        if(loMeLogger.isDebugEnabled()){
            try{
				// loMeLogger.debug("[" + argoDispatchServiceVo.getUserSabun() +
				// "] " + getSqlQuery(argoDispatchServiceVo.getQueryId(),
				// argoDispatchServiceVo.getReqInput()));
            }catch(NullPointerException npe){
				loMeLogger.debug("[" + argoDispatchServiceVo.getUserSabun() + "] debug Mode에서 Sql logging Error입니다." + npe.toString());
            }catch(Exception e){
            	loMeLogger.debug("[" + argoDispatchServiceVo.getUserSabun() + "] debug Mode에서 Sql logging Error입니다." + e.toString());
            }
        }
        
        //lmk872 프러시저 호출 (P) 추가
		if (Constant.SVC_DB_TYPE_INSERT.equals(argoDispatchServiceVo.getDbType())) {
			insert(argoDispatchServiceVo);
		} else if (Constant.SVC_DB_TYPE_UPDATE.equals(argoDispatchServiceVo.getDbType())) {
			update(argoDispatchServiceVo);
		} else if (Constant.SVC_DB_TYPE_DELETE.equals(argoDispatchServiceVo.getDbType())) {
			delete(argoDispatchServiceVo);
		} else if (Constant.SVC_DB_TYPE_SELECT.equals(argoDispatchServiceVo.getDbType())) {
			select(argoDispatchServiceVo);
		} else if (Constant.SVC_DB_TYPE_PROCEDURE.equals(argoDispatchServiceVo.getDbType())) {
			procedure(argoDispatchServiceVo);
		}  else if (Constant.SVC_DB_TYPE_LIST.equals(argoDispatchServiceVo.getDbType())) {
			list(argoDispatchServiceVo);
		} else if (Constant.SVC_DB_TYPE_BULK_INSERT.equals(argoDispatchServiceVo.getDbType())) {
			batchInsert(argoDispatchServiceVo);
        } 
        
    }

    public long selectNextAccessId() {
        Long resultId = null;
        try {
            // resultId = (Long) selectByPk("ARGOCOMMON.selectNextAccessId", null);
            resultId = 1L;
        } catch(NullPointerException npe) {
            loMeLogger.error("NullPointerException : " + npe.toString());
        } catch(Exception ex) {
//            ex.printStackTrace();
        	loMeLogger.error("Exception : " + ex.toString());
        }
        
        if(resultId != null) return resultId.longValue();
        else return 0L;
    }
    
	public void insertAccessLog(ArgoDispatchServiceVo argoDispatchServiceVo) {
        try {
			insert("ARGOCOMMON.insertAccessLog", argoDispatchServiceVo);
        } catch(NullPointerException npe) {
			loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] insertAccessLog NullPointerException :" + npe.toString());
        } catch(Exception ex) {
        	loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] insertAccessLog Exception :" + ex.toString());
//            ex.printStackTrace();
        }
    }

	public void updateAccessLog(ArgoDispatchServiceVo argoDispatchServiceVo) {
        try {
            /*
			 * update("ARGOCOMMON.updateAccessLog", argoDispatchServiceVo);
			 * if(argoDispatchServiceVo.getSvcSeq() > 1 &&
			 * !argoDispatchServiceVo.getResultCode().equals(Constant.
			 * RESULT_CODE_OK)){ argoDispatchServiceVo.setResultCode(Constant.
			 * RESULT_CODE_ERR_ROLLBACK);
			 * argoDispatchServiceVo.setResultMsg(EgovStringUtil.null2void(
			 * egovMessageSource.getMessage(Constant.RESULT_CODE_ERR_ROLLBACK)))
			 * ; update("ARGOCOMMON.updateAccessLog2", argoDispatchServiceVo); }
			 */
        } catch(NullPointerException npe) {
			loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] updateAccessLog NullPointerException :" + npe.toString());
        } catch(Exception ex) {
        	loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] updateAccessLog Exception :" + ex.toString());
//            ex.printStackTrace();
        }
    }

	public String selectGrantReadWrite(ArgoDispatchServiceVo argoDispatchServiceVo) {
        String result = null;
        try {
			// result = (String) selectByPk("ARGOCOMMON.selectGrantCheck",
			// argoDispatchServiceVo);
            result = "AA";
        } catch(NullPointerException npe) {
			loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] selectGrantReadWrite NullPointerException :" + npe.toString());
        } catch(Exception ex) {
        	loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] selectGrantReadWrite Exception :" + ex.toString());
//            ex.printStackTrace();
        }
        
        if(result != null) return result;
        else return "";        
    }

	public long selectFinalIdsAccessId(ArgoDispatchServiceVo argoDispatchServiceVo) {
        Long resultId = null;
        try {
			resultId = (Long) selectByPk("ARGOCOMMON.selectFinalIdsAccessId", argoDispatchServiceVo);
        } catch(NullPointerException npe) {
			loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] IDS selectFinalIdsAccessId NullPointerException :" + npe.toString());
        } catch(Exception ex) {
        	loMeLogger.error("[" + argoDispatchServiceVo.getUserSabun() + "] IDS selectFinalIdsAccessId EXCEPTION :" + ex.toString());
//            ex.printStackTrace();
        }
        
        if(resultId != null) return resultId.longValue();
        else return 0L;
    }

    private Map deepMerge(Map original, Map newMap) {
        for (Object key : newMap.keySet()) {
            if (newMap.get(key) instanceof Map && original.get(key) instanceof Map) {
                Map originalChild = (Map) original.get(key);
                Map newChild = (Map) newMap.get(key);
                original.put(key, deepMerge(originalChild, newChild));
            } else {
                original.put(key, newMap.get(key));
            }
        }
        
        try{    //bulk시 파라미터가 로그로 나오지 않아서 맵의 값을 로그로 남김.
            if(loMeLogger.isDebugEnabled()){
                loMeLogger.debug("==== S ===============================================");
                for( Object key : original.keySet() ){
                    if(EgovStringUtil.isNotEmpty(key.toString()))
                        loMeLogger.debug("key["+key+"], value=["+original.get(key)+"]");
                }
                loMeLogger.debug("==== E ===============================================");
            }
        }catch(NullPointerException npe){
            //무시한다.
        	loMeLogger.error("Exception : " + npe.toString());
        }catch(Exception e){
        	//무시한다.
        	loMeLogger.error("Exception : " + e.toString());
        }
        
        return original;
    }

    private String getSqlQuery(String statementId, Map parameters) throws SQLException { 
        SessionScope sessionScope = new SessionScope(); 
        sessionScope.setSqlMapClient(getSqlMapClient()); 
        StatementScope statementScope = new StatementScope(sessionScope); 
        
        ExtendedSqlMapClient extendedSqlMapClient = (ExtendedSqlMapClient) getSqlMapClient(); 
        MappedStatement mappedStatement = extendedSqlMapClient.getMappedStatement(statementId); 
        mappedStatement.initRequest(statementScope); 
        
        ParameterMap parameterMap = mappedStatement.getSql().getParameterMap(statementScope, parameters); 
        Object[] bindParameter = parameterMap.getParameterObjectValues(statementScope, parameters); 
        ParameterMapping[] parameterMappinge = parameterMap.getParameterMappings(); 
        String preparedStatement = mappedStatement.getSql().getSql(statementScope, parameters); 
        
        for (int i = 0 ; i < bindParameter.length ; i ++) { 
            if (parameterMappinge[i].getJdbcType() == 0) { 
                preparedStatement = preparedStatement.replaceFirst("[?]", "'" +bindParameter[i].toString() + "'");
            } else { 
                preparedStatement = preparedStatement.replaceFirst("[?]", bindParameter[i].toString()); 
            } 
        } 
        
        char[] toCharArray = preparedStatement.toCharArray(); 
        int index = 1; 
        for (int i = 1; i < toCharArray.length; i++) { 
            toCharArray[index] = toCharArray[i]; 
            if (toCharArray[index] != ' ') { 
                index++;
            } else if (toCharArray[index - 1] != ' ') { 
                index++;
            }
        }
        
        return new String(toCharArray, 0, index).trim(); 
    }


	public String selectLogOut(ArgoDispatchServiceVo argoDispatchServiceVo) {
        String resultKind = "";
        try {
        	resultKind = (String) selectByPk("ARGOCOMMON.logoutCheck", argoDispatchServiceVo.getReqInput());
        } catch(NullPointerException npe) {
            loMeLogger.error("NullPointerException : " + npe.toString());
        } catch(Exception ex) {
//            ex.printStackTrace();
        	loMeLogger.error("Exception : " + ex.toString());
        }
        
        if(resultKind != null) return resultKind;
        else return "1";
    }
	
	public String selectParam(ArgoDispatchServiceVo argoDispatchServiceVo, String queryId) {
        String resultParam = "";
        try {
        	resultParam = (String) selectByPk(queryId, argoDispatchServiceVo.getReqInput());
        } catch(NullPointerException npe) {
            loMeLogger.error("NullPointerException : " + npe.toString());
        } catch(Exception ex) {
//            ex.printStackTrace();
        	loMeLogger.error("Exception : " + ex.toString());
        }
        
        if(resultParam != null) return resultParam;
        else return "";
    }
}
