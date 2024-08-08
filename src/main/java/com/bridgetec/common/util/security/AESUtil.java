package com.bridgetec.common.util.security;

import java.security.NoSuchAlgorithmException;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AESUtil {
	
	private static final Logger logger = LoggerFactory.getLogger(AESUtil.class);

    private static SecretKeySpec secretKey;
    private static byte[]        bKey;

    public static void setKey(String sKey, int nKeyBits) {
        int nKey = 16;

        switch (nKeyBits) {
        default:
        case 128:
            nKey = 16;
            break;
        case 192:
            nKey = 24;
            break;
        case 256:
            nKey = 32;
            break;
        }
        try {
            bKey = new byte[nKey];
            for (int i = 0; i < sKey.length() && i < nKey; i++) {
                bKey[i] = sKey.getBytes()[i];
            }
            
            secretKey = new SecretKeySpec(bKey, "AES");
        } catch (IllegalArgumentException iae) {
            logger.error("Error while setKey: " + iae.toString());
        } catch (Exception e) {
        	logger.error("Error while setKey: " + e.toString());
        }
    }

    public static String encrypt(String sMsg) {
        try {
            Cipher cipher = Cipher.getInstance("AES");
            cipher.init(Cipher.ENCRYPT_MODE, secretKey);
            return Base64.encodeBase64String(cipher.doFinal(sMsg.getBytes("UTF-8")));
        } catch (NoSuchAlgorithmException nsae) {
            logger.error("Error while encrypting: " + nsae.toString());
        } catch (Exception e) {
        	logger.error("Error while encrypting: " + e.toString());
        }
        return null;
    }

    public static String decrypt(String sMsg) {
    	String result = "";
    	
        try {
        	if(sMsg != null && sMsg.length() % 20 == 4 && sMsg.length() > 4){
	            Cipher cipher = Cipher.getInstance("AES");
	            cipher.init(Cipher.DECRYPT_MODE, secretKey);
	            //return new String(cipher.doFinal(Base64.decodeBase64(sMsg)));
	            result = new String(cipher.doFinal(Base64.decodeBase64(sMsg)),"UTF-8");
        	}
        	if(result == null || "".equals(result)){
    			result = sMsg;
    		}
        	return result;
        	
        }catch (NoSuchAlgorithmException nsae) {
            logger.error("Error while encrypting: " + nsae.toString());
        } catch (Exception e) {
            logger.error("Error while decrypting: " + e.toString());
        }
        return sMsg;
    }
}
