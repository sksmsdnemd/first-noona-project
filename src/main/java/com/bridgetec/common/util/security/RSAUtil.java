package com.bridgetec.common.util.security;
import java.security.InvalidParameterException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.RSAPublicKeySpec;

import javax.crypto.Cipher;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.bridgetec.argo.common.Constant;

public class RSAUtil {
	private static final Logger logger = LoggerFactory.getLogger(RSAUtil.class);
    
    public static String[] getKey(HttpServletRequest req){
        
        KeyPairGenerator generator;
        try {
            generator = KeyPairGenerator.getInstance("RSA");
            generator.initialize(Constant.getRSAKeySize());
            
            KeyPair keyPair = generator.genKeyPair();
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");

            PublicKey publicKey = keyPair.getPublic();
            PrivateKey privateKey = keyPair.getPrivate();

            HttpSession session = req.getSession();
            // 세션에 공개키의 문자열을 키로하여 개인키를 저장한다.
            session.setAttribute("__rsaPrivateKey__", privateKey);

            // 공개키를 문자열로 변환하여 JavaScript RSA 라이브러리 넘겨준다.
            RSAPublicKeySpec publicSpec = (RSAPublicKeySpec) keyFactory.getKeySpec(publicKey, RSAPublicKeySpec.class);

            String publicKeyModulus = publicSpec.getModulus().toString(16);
            String publicKeyExponent = publicSpec.getPublicExponent().toString(16);
            
            String[] keyInfo  = {publicKeyModulus, publicKeyExponent};
            return keyInfo;
            
        } catch (InvalidParameterException ipe) {
            logger.error("getKey Exception : " + ipe.toString());
        } catch (Exception e) {
        	logger.error("getKey Exception : " + e.toString());
        }
        return null;
    }

    
    public static String decrypt(HttpServletRequest req, String sMsg) {
        return RSAUtil.decrypt(req, sMsg, true);
    }

    public static String decrypt(HttpServletRequest req, String sMsg, boolean once) {
        HttpSession session = req.getSession();
        PrivateKey privateKey = (PrivateKey) session.getAttribute("__rsaPrivateKey__");

        if (once) {
            session.removeAttribute("__rsaPrivateKey__"); // 키의 재사용을 막는다. 항상 새로운 키를 받도록 강제.
            if (privateKey == null) {
                throw new RuntimeException("암호화 개인키 정보를 찾을 수 없습니다.(페이지를 다시 로드하세요)");
            }
        }

        try {
            return decryptRsa(privateKey, sMsg);
        }
        catch (Exception ex) {
            logger.error("decrypt Exception : " + ex.toString());
            return sMsg;
        }
    }
    
    private static String decryptRsa(PrivateKey privateKey, String securedValue) throws Exception {
        //System.out.println("will decrypt : ["+privateKey+"]" + securedValue);
        Cipher cipher = Cipher.getInstance("RSA");
        byte[] encryptedBytes = hexToByteArray(securedValue);
        cipher.init(Cipher.DECRYPT_MODE, privateKey);
        byte[] decryptedBytes = cipher.doFinal(encryptedBytes);
        String decryptedValue = new String(decryptedBytes, "utf-8"); // 문자 인코딩 주의.
        return decryptedValue;
    }

    /**
     * 16진 문자열을 byte 배열로 변환한다.
     */
    public static byte[] hexToByteArray(String hex) {
        if (hex == null || hex.length() % 2 != 0) {
            return new byte[]{};
        }

        byte[] bytes = new byte[hex.length() / 2];
        for (int i = 0; i < hex.length(); i += 2) {
            byte value = (byte)Integer.parseInt(hex.substring(i, i + 2), 16);
            bytes[(int) Math.floor(i / 2)] = value;
        }
        return bytes;
    }
    
    
    
}
