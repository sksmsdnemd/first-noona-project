package com.bridgetec.argo.batch.util;

import com.bridgetec.common.util.security.AESUtil;

/**
 * 암호화유틸
 * 
 */
public class SecurityUtil {

	private static final String ME_SHARED_KEY = "bridgetec_argo_security123456789"; // 암복호화 키
    private static final int ME_SHARED_BIT    = 256;  //암복호화 키를 몇 BIT함수화키로 설정할지 (128,192,256 지원)

  
    /**
     * AES 암호화
     * 
     * @param plainText
     * @param sharedKey
     * @return
     */
    public static String AESEncrypyt(String plainText, String sharedKey) throws Exception {
        String returnValue = "";

        if (plainText.isEmpty() || plainText == null) return "";
      
        if (sharedKey == null) sharedKey = ME_SHARED_KEY;

        AESUtil.setKey(sharedKey, ME_SHARED_BIT);
        returnValue = AESUtil.encrypt(plainText);

        return returnValue;
    }

    /**
     * AES 복호화
     * 
     * @param cipherText
     * @param sharedKey
     * @return
     */
    public static String AESDecrypyt(String cipherText, String sharedKey) throws Exception {
        String returnValue = "";

        if (cipherText.isEmpty() || cipherText == null) return "";

        if (sharedKey == null) sharedKey =ME_SHARED_KEY;

        AESUtil.setKey(sharedKey, ME_SHARED_BIT);
        returnValue = AESUtil.decrypt(cipherText);
        // String strenc = AESUtil.encrypt("780912-3456789");

        return returnValue;
    }
    
    /**
     * AES 암호화
     * 
     * @param plainText
     * @param sharedKey
     * @param sharedBit
     * @return
     */
    public static String AESEncrypyt(String plainText, String sharedKey, int sharedBit) throws Exception {
        String returnValue = "";

        if (plainText.isEmpty() || plainText == null) return "";
      
        if (sharedKey == null) sharedKey = ME_SHARED_KEY;
        
       
        AESUtil.setKey(sharedKey, sharedBit);
        returnValue = AESUtil.encrypt(plainText);

        return returnValue;
    }

    /**
     * AES 복호화
     * 
     * @param cipherText
     * @param sharedKey
     * @param sharedBit
     * @return
     */
    public static String AESDecrypyt(String cipherText, String sharedKey, int sharedBit) throws Exception {
        String returnValue = "";

        if (cipherText.isEmpty() || cipherText == null) return "";

        if (sharedKey == null) sharedKey = ME_SHARED_KEY;

        AESUtil.setKey(sharedKey, sharedBit);
        returnValue = AESUtil.decrypt(cipherText);
        // String strenc = AESUtil.encrypt("780912-3456789");

        return returnValue;
    }


}
