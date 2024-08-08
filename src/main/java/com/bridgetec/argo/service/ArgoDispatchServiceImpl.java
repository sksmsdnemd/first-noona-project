package com.bridgetec.argo.service;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.ContextLoader;
import org.springframework.web.context.WebApplicationContext;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.common.NoGrantException;
import com.bridgetec.argo.dao.ArgoDispatchDAO;
import com.bridgetec.argo.dao.IArgoDispatchDAO;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;

import egovframework.com.cmm.EgovMessageSource;
import egovframework.rte.fdl.cmmn.AbstractServiceImpl;

@Service("saDispatchServiceImpl")
public class ArgoDispatchServiceImpl extends AbstractServiceImpl {
    private final Logger loMeLogger = LoggerFactory.getLogger(ArgoDispatchServiceImpl.class);
    
	@Resource(name = "ARGODB")
	private ArgoDispatchDAO argoLogDAO;
    
    @Resource(name="egovMessageSource")
    EgovMessageSource egovMessageSource;
    
    @Autowired
    private ArgoLogServiceImpl saLogService;
    
    public void execute(List<ArgoDispatchServiceVo> svcList) throws MessageException {

		long accessId = argoLogDAO.selectNextAccessId();
        int seq = 1;
        for (ArgoDispatchServiceVo saDispatchServiceVo : svcList) {
            
            if(saDispatchServiceVo.getMethodName().equals("")){
                continue;
            }
            
            try{
                //서버에서 한번 더 권한체크.
				daoSelectGrantCheck(saDispatchServiceVo);
                
                //로그아이디설정 및 시작로그 등록
                saDispatchServiceVo.setAccessId(accessId);
               // seq = saLogService.logExcuteBefore(saDispatchServiceVo, seq);
                
                //IDS거래일경우 최종거래 accessId 필요. 
                if(saDispatchServiceVo.getDbType().equals(Constant.SVC_IF_TYPE_IDS)){
					saDispatchServiceVo.setIdsAccessId(argoLogDAO.selectFinalIdsAccessId(saDispatchServiceVo));
                }
                
                
                if(saDispatchServiceVo.getDbType().equals(Constant.SVC_DB_TYPE_SELECT) 
                                || saDispatchServiceVo.getDbType().equals(Constant.SVC_DB_TYPE_LIST) ){
                    daoSelectExcute(saDispatchServiceVo);
                }else{
                    daoExcute(saDispatchServiceVo);
                }
                
                
                saDispatchServiceVo.setResultCode(Constant.RESULT_CODE_OK);
            } catch (NullPointerException npe) {
            	loMeLogger.error("NullPointerException : " + npe.toString());
            } catch (Exception e) {
            	StringBuffer errSb = new StringBuffer();
            	MessageException me;
            	if((e instanceof MessageException) == false) {
            		me = new MessageException(e, Constant.RESULT_CODE_ERR_PROC);
            	}else {
            		me = (MessageException)e;
            	}
            	
            	errSb.append(me.getArgoMessage(egovMessageSource))
            	.append("\n")
            	.append(me.getSubMessage());
            	
            	//처리결과(오류)코드. 메시지
            	saDispatchServiceVo.setResultCode(me.getArgoCode());
            	saDispatchServiceVo.setResultMsg(errSb.toString());
            	
            	throw me;
            } finally {
               // saLogService.logExcuteAfter(saDispatchServiceVo);
            }
        }
    }
    
    //daoExcute 와 똑같은 작업을 수행하지만 트랜잭션 Advice에서 트랜잭션 ReadOnly처리하기 위해 별도 메소드로 구현
    private void daoSelectExcute(ArgoDispatchServiceVo saDispatchServiceVo) throws Exception {
        WebApplicationContext ctx = ContextLoader.getCurrentWebApplicationContext();
        IArgoDispatchDAO saDispatchDAO = (IArgoDispatchDAO) ctx.getBean(saDispatchServiceVo.getSvcType());
        saDispatchDAO.excute(saDispatchServiceVo);
    }
    
    private void daoExcute(ArgoDispatchServiceVo saDispatchServiceVo) throws Exception {
        WebApplicationContext ctx = ContextLoader.getCurrentWebApplicationContext();
        IArgoDispatchDAO saDispatchDAO = (IArgoDispatchDAO) ctx.getBean(saDispatchServiceVo.getSvcType());
        saDispatchDAO.excute(saDispatchServiceVo);
    }
    

	private void daoSelectGrantCheck(ArgoDispatchServiceVo saDispatchServiceVo) throws Exception {
		String grantNR = argoLogDAO.selectGrantReadWrite(saDispatchServiceVo);
        switch(grantNR){
            case "N":
            case "R":
                if( !(saDispatchServiceVo.getDbType().equals(Constant.SVC_DB_TYPE_SELECT) 
                        || saDispatchServiceVo.getDbType().equals(Constant.SVC_DB_TYPE_LIST)
                        || saDispatchServiceVo.getDbType().equals(Constant.SVC_IF_TYPE_R)) ){
                    if(grantNR.equals("N")){
                        throw new MessageException(new Exception("GRANT. N"), Constant.RESULT_CODE_NO_GRANT);                    
                    }else{
                        throw new MessageException(new Exception("GRANT. R"), Constant.RESULT_CODE_READ_GRANT);                    
                    }
                }
        }
        
    }
    
	public void pageGrantCheck(ArgoDispatchServiceVo argoDispatchServiceVo) throws Exception {
		String grantNR = argoLogDAO.selectGrantReadWrite(argoDispatchServiceVo);
        if(grantNR.equals("N")){
            throw new NoGrantException(Constant.RESULT_CODE_NO_GRANT);
        }
    }
	
	public String selectLogOutCheck(ArgoDispatchServiceVo argoDispatchServiceV) throws Exception {
		String logoutKind = argoLogDAO.selectLogOut(argoDispatchServiceV);
		return logoutKind;
    }
	
	public String selectParam(ArgoDispatchServiceVo argoDispatchServiceVo, String queryId) throws Exception {
		String resultParam = argoLogDAO.selectParam(argoDispatchServiceVo, queryId);
		return resultParam;
    }
	
	public String getGrantForm(ArgoDispatchServiceVo argoDispatchServiceVo,Map map) throws Exception {
		
		String result = argoLogDAO.getGrantForm(argoDispatchServiceVo, map);
		return result;
	}
    
}
