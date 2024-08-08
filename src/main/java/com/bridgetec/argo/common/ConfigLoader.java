package com.bridgetec.argo.common;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Hashtable;
import java.util.StringTokenizer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import egovframework.com.cmm.service.EgovProperties;

public class ConfigLoader {
    
    static Hashtable data = new Hashtable();
    static long ld_time = 0;
    static long cur_time;
    static File confile = null;
    private static Object lock = new Object();
    
    private static final Logger logger  = LoggerFactory.getLogger(ConfigLoader.class);
    
    public static void load() {
        
        String temp;
        StringTokenizer st;
        
        FileInputStream fis = null;
        InputStreamReader fr = null;

        try {

//            String PATH_PREFIX = EgovProperties.class.getResource("").getPath().substring(0, EgovProperties.class.getResource("").getPath().lastIndexOf("egovframe"));
        	String PATH_PREFIX = "";
        	if(EgovProperties.class.getResource("") != null) {
        		PATH_PREFIX = EgovProperties.class.getResource("").getPath().substring(0, EgovProperties.class.getResource("").getPath().lastIndexOf("egovframe"));
        	}
        	
            String CONFIG_PROPERTIES_FILE = PATH_PREFIX + "setting" + System.getProperty("file.separator") + "appConfig.properties";

            confile = new File(CONFIG_PROPERTIES_FILE);
            
            ld_time             = confile.lastModified();
//            InputStreamReader fr = new InputStreamReader(new FileInputStream(confile), "utf-8");
            fis = new FileInputStream(confile);
            fr = new InputStreamReader(fis, "utf-8");
            
            BufferedReader br   = new BufferedReader(fr);
            String stName       = "";
            
            while((temp = br.readLine()) != null) {
                String stCode       = null;
                String stCodeName   = null;
                
                if ( temp.trim().length() == 0 ) continue;
                if ( temp.charAt(0) == '#' ) continue;
                
                st = new StringTokenizer(temp, "=");
                stCode      = st.nextToken().trim();
                stCodeName  = st.nextToken().trim();
            
                data.put(stCode, stCodeName );
            }

        } catch (IOException ie) {
        	logger.error("Exception : " + ie.toString());
        } catch (Exception e) {
        	logger.error("Exception : " + e.toString());
        } finally {
        	if(fr != null) {
        		try {
        			fr.close();
        		} catch(IOException ie) {
        			logger.error("Exception : " + ie.toString());
        		} catch(Exception e) {
        			logger.error("Exception : " + e.toString());
        		}
        	}
        	if(fis != null) {
        		try {
        			fis.close();
        		} catch(IOException ie) {
        			logger.error("Exception : " + ie.toString());
        		} catch(Exception e) {
        			logger.error("Exception : " + e.toString());
        		}
        	}
        }
    }


    public static String get(String code) throws Exception{

        String msg   = null;
        Hashtable hs = null;
        if ( confile == null ) {
            cur_time = 1;
        } else {
            cur_time = confile.lastModified();
        }
        synchronized ( lock ) {
            if (ld_time < cur_time) load();
        }

        try{
            msg = (String)data.get(code);
            if ( msg == null ) msg = "";
        } catch (SecurityException se) {
        	logger.error("Exception : " + se.toString());
            msg = "";   
        } catch (Exception e) {
        	logger.error("Exception : " + e.toString());
        	msg = "";   
        }
        return msg;
    }

} 
