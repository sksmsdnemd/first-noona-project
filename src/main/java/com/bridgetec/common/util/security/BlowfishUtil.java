package com.bridgetec.common.util.security;

import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class BlowfishUtil {
	private static final Logger logger = LoggerFactory.getLogger(BlowfishUtil.class);

    /** 암호화, 복호화 키 */
    public String key = "KeyString1234";
    SecretKeySpec sksSpec = null;

    public BlowfishUtil(String inKey) throws NoSuchAlgorithmException, UnsupportedEncodingException {
        key = inKey;
        sksSpec = new SecretKeySpec(key.getBytes(), "Blowfish");
    }

    /**
     * 문자열을 암호화한뒤 암호화된 문자열을 반환
     * 
     * @param message
     *            문자열
     * @return 암호화된 문자열
     */
    public String encrypt(String message) {

        Cipher cipher = null;
        String returnValue = null;
        try {
            cipher = Cipher.getInstance("Blowfish/ECB/PKCS5Padding");
            cipher.init(javax.crypto.Cipher.ENCRYPT_MODE, sksSpec);
            byte[] encrypt = cipher.doFinal(message.getBytes());
            byte[] encodedBytes = Base64.encodeBase64(encrypt);
            returnValue = new String(encodedBytes);
        } catch (NoSuchAlgorithmException nae) {
        	logger.error(nae.getMessage());
            return null;
        } catch (Exception e) {
        	logger.error(e.getMessage());
        	return null;
        }
        return returnValue;

    }

    /**
     * 암호화된 문자열을 복호화한뒤 복호화된 문자열로 반환
     * 
     * @param message
     *            암호화된 문자열
     * @return 복호화된 문자열
     */
    public String decrypt(String message) {
        String returnValue = null;
        try {
            byte[] decrypt = Base64.decodeBase64(message.getBytes());
            Cipher cipher = Cipher.getInstance("Blowfish/ECB/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, sksSpec);
            returnValue = new String(cipher.doFinal(decrypt));
        } catch (NoSuchAlgorithmException nae) {
        	logger.error(nae.getMessage());
            return null;
        } catch (Exception e) {
        	logger.error(e.getMessage());
        	return null;
        }
        return returnValue;
    }

}
