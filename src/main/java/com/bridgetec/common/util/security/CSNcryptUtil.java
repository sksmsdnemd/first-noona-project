package com.bridgetec.common.util.security;

import com.bridgetec.argo.batch.util.SecurityUtil;

/**
 * 암복호화 Util
 * @author ARGO
 * 
 */
public class CSNcryptUtil {
	
	/**
	 * 암호화
	 * @param sMsg - 문자열
	 * @param sEncType - 암호화 구분(TEL : 전화번호)
	 * @return
	 */
	public static String encrypt(String sEncType, String sMsg) {
		if ( sMsg == null )	return sMsg;
		
		String sEncMsg = null;
		
        try {
    		sEncMsg = SecurityUtil.AESEncrypyt(sMsg, null);
        } catch (Exception e) {
        	e.printStackTrace();
        }
        return sEncMsg;
    }

	/**
	 * 
	 * @param sDecType
	 * @param sMsg
	 * @return
	 */
    public static String decrypt(String sDecType, String sMsg) {
        if ( sMsg == null )	return sMsg;
        
        String sDecMsg = null;
		
        try {
    		sDecMsg = SecurityUtil.AESDecrypyt(sMsg, null);
        } catch (Exception e) {
        	e.printStackTrace();
        }
        
        return sDecMsg;
    }
    
    /**
     * ENC 구분자와 파라메터명 분리
     * ex) ENCTEL_TelNo
     * @param sName
     * @return
     */
    public static String[] getEncName(String sName) {
    	String[] sEncName = {"", "", ""};
    	
    	try {	
    	
	    	if ( sName != null ) {
	    		int index = sName.indexOf("_");
	    		
	    		if ( index >= 0 ) {
	    		
		    		String[] temp = {"", ""};
		    		temp[0] = sName.substring(0, index);
		    		temp[1] = sName.substring(index+1);		// underbar 제외
		    		
		    		if ( temp[0].length() >= 3 ) {
		    			sEncName[0] = temp[0].substring(0, 3).toUpperCase();
		    			sEncName[1] = temp[0].substring(3).toUpperCase();
		    			
		    			if ( temp[1].length() > 1 ) {
		    				sEncName[2] = temp[1].substring(0, 1).toLowerCase() + temp[1].substring(1);
		    			} else {
		    				sEncName[2] = temp[1].toLowerCase();
		    			}
		    		}
	    		}
	    	}
	    	
    	} catch(Exception e) {
    		e.printStackTrace();
    	}
    	
    	return sEncName;
    }
    
    /**
     * DEC 구분자와 컬럼명 분리
     * ex) DECTEL_CUST_TEL
     * @param sName
     * @return
     */
    public static String[] getDecName(String sName) {
    	String[] sDecName = {"", "", ""};
    	
    	try {	
	    	if ( sName != null ) {
	    		int index = sName.indexOf("_");
	    		
	    		if ( index >= 0 ) {
	    		
		    		String[] temp = {"", ""};
		    		temp[0] = sName.substring(0, index);
		    		temp[1] = sName.substring(index+1);	// underbar 제외
		    		
		    		if ( temp[0].length() >= 3 ) {
		    			sDecName[0] = temp[0].substring(0, 3).toUpperCase();
		    			sDecName[1] = temp[0].substring(3).toUpperCase();
		    			sDecName[2] = temp[1];
		    		}
	    		}
	    	}
	    } catch(Exception e) {
    		e.printStackTrace();
    	}
    	
    	return sDecName;
    }
}
