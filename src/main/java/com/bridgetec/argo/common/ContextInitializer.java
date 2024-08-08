package com.bridgetec.argo.common;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.bridgetec.common.SortProperties;

import egovframework.com.cmm.service.EgovProperties;

public class ContextInitializer implements ServletContextListener {
    /** log */
    protected static final Log LOG = LogFactory.getLog(ContextInitializer.class);

    /**
     * 시스템 구동 시 시작되는 메소드
     */
    @SuppressWarnings({ })
    public void contextInitialized( ServletContextEvent sce ) {
		LOG.info("============================================================ BT-VELOCE System Initialized Start ============================================================");

        /** zhangse 2014.12.08
         * globals_properties의 Globals.SA.RDB.Security=false로 되어있으면 Globals.SA.RDB.Account, Globals.SA.RDB.Password가 평문으로 작성되어야하며
         * WAS가 기동시  Globals.SA.RDB.Security=false일경우 Account, Password를 암호화하고 Security를 true로 변경한다.
         */
        String GLOBALS_PROPERTIES_FILE = EgovProperties.GLOBALS_PROPERTIES_FILE;
      
        SortProperties properties = new SortProperties();
        
        LOG.info("/*");
        LOG.info("/*");
        LOG.info("/*");
        LOG.info("/* GROBALS_PROPERTIES_FILE_PATH : " + GLOBALS_PROPERTIES_FILE );
        LOG.info("/*");
        LOG.info("/*");
        LOG.info("/*");
        
        FileInputStream fis = null;
        FileOutputStream fos = null;
        
        try {
//            properties.load(new java.io.FileInputStream(GLOBALS_PROPERTIES_FILE));
        	fis = new FileInputStream(GLOBALS_PROPERTIES_FILE);
            properties.load(fis);
            
            String isSecurity = properties.getProperty("Globals.SA.RDB.Security");
            if(isSecurity==null) isSecurity = "true";
            if(isSecurity.toLowerCase().trim().equals("false")){
                LOG.info("GLOBALS_PROPERTIES_FILE 암호화 SET을 시작합니다.");
                properties.setProperty("Globals.SA.RDB.Security", "true");
                properties.setProperty("Globals.SA.RDB.Account", properties.getProperty("Globals.SA.RDB.Account").trim() ,true );
                properties.setProperty("Globals.SA.RDB.Password", properties.getProperty("Globals.SA.RDB.Password").trim() ,true);
//                properties.store(new java.io.FileOutputStream(GLOBALS_PROPERTIES_FILE), "");
                fos = new FileOutputStream(GLOBALS_PROPERTIES_FILE);
                properties.store(fos, "");
                LOG.info("GLOBALS_PROPERTIES_FILE 암호화 완료 확인 :[S:"+properties.getProperty("Globals.SA.RDB.Security")+"][A:"+properties.getProperty("Globals.SA.RDB.Account")+"][P:"+properties.getProperty("Globals.SA.RDB.Password")+"]");

                fos.close();
            }
            
            fis.close();
        } catch (IOException ie) {
            LOG.error("GLOBALS_PROPERTIES_FILE 암호화 SET FAIL IOException : "+ie.toString());
        } catch (Exception e) {
            LOG.error("GLOBALS_PROPERTIES_FILE 암호화 SET FAIL Exception : "+e.toString());
        } finally {
        	if(fos != null) { try { fos.close(); } catch(IOException ie) { LOG.error("IOException : " + ie.toString()); } catch(Exception e) { LOG.error("Exception : " + e.toString()); } }
        	if(fis != null) { try { fis.close(); } catch(IOException ie) { LOG.error("IOException : " + ie.toString()); } catch(Exception e) { LOG.error("Exception : " + e.toString()); } }
        }
    }

    /**
     * 시스템 종료 시 구동되는 메소드
     */
    public void contextDestroyed(ServletContextEvent arg0) {
		LOG.info("=============================================================== BT-VELOCE System End ===============================================================");
    }
    
}