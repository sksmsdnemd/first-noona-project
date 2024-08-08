package com.bridgetec.argo.service;

import java.util.HashMap;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.stereotype.Service;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.argo.common.MessageException;
import com.bridgetec.argo.vo.ArgoDispatchServiceVo;
import com.bridgetec.common.SecurityUtil;
import com.bridgetec.common.SortProperties;
import com.bridgetec.common.util.security.RSAUtil;

import egovframework.com.cmm.service.EgovProperties;
import egovframework.rte.fdl.cmmn.AbstractServiceImpl;

@Service("ArgoDynamicService")
public class ArgoDynamicService extends AbstractServiceImpl {
    
    private Logger loMeLogger = LoggerFactory.getLogger(ArgoDynamicService.class);
    
    public void dbPwdChg(ArgoDispatchServiceVo argoServiceVO) throws Exception {
        
        String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
        
        try{
            SortProperties properties = new SortProperties();
            properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
            
            String encCurPwd = SecurityUtil.AESEncrypyt((String)argoServiceVO.getReqInput().get("curPwd"),null);
            if( !(encCurPwd.equals(properties.getProperty("Globals.Oracle.Password"))) ){
                throw new MessageException(new Exception("이전 비밀번호와 입력하신 정보가 일치 하지 않습니다."), Constant.RESULT_CODE_ERR_PROC); 
            }
        
            String sPwd = SecurityUtil.AESEncrypyt((String)argoServiceVO.getReqInput().get("chgPwd"),null);
            properties.setProperty("Globals.Oracle.Password", sPwd);
            properties.store(new java.io.FileOutputStream(GLOBALS_PROPERTIES_FILE), "");    
            
            loMeLogger.info("["+argoServiceVO.getUserSabun()+"] DB 비번변경 SUCCESS :"+sPwd);
            argoServiceVO.setResultCode(Constant.RESULT_CODE_OK);
            
        }catch(NullPointerException npe){
        	loMeLogger.error("NullPointerException : " + npe.toString());
        }catch(Exception e){
            
            //StringBuffer errSb = new StringBuffer();
            MessageException me;
            if((e instanceof MessageException) == false) {
                me = new MessageException(e, Constant.RESULT_CODE_ERR_PROC); 
            }else {
                me = (MessageException)e;
            }
            
            loMeLogger.error("["+argoServiceVO.getUserSabun()+"] DB 비번변경 EXCEPTION :"+me.getSubMessage());
            
            /*errSb.append(me.getSubMessage());
            argoServiceVO.setResultCode(me.getArgoCode());
            argoServiceVO.setResultMsg(errSb.toString());*/
            throw me;            
        }               
    }

	public void rsaPublicKey(ArgoDispatchServiceVo argoServiceVo) throws Exception {
        

        HashMap<String, Object> map = new HashMap();
		String keyInfo[] = RSAUtil.getKey((HttpServletRequest) argoServiceVo.getReqInput().get("req"));
        if(keyInfo!=null){
            map.put("publicKeyModulus", keyInfo[0]);
            map.put("publicKeyExponent", keyInfo[1]);
        }

		System.out.println("DAE WON - publicKeyModulus : " + keyInfo[0]);
		System.out.println("DAE WON - publicKeyExponent : " + keyInfo[1]);
		argoServiceVo.setResOut(map);
		argoServiceVo.setResultCode(Constant.RESULT_CODE_OK);
        
    }


}
