package com.bridgetec.common;

import com.bridgetec.argo.common.Constant;
import com.bridgetec.common.util.security.AESUtil;
import com.bridgetec.common.util.security.BlowfishUtil;
import com.bridgetec.common.util.security.SHA1Util;
import com.bridgetec.common.util.security.SHA512Util;
import com.bridgetec.common.util.security.TripleDESUtil;

/**
 * 암호화유틸
 * 
 * @author 조종탁
 * 
 */
public class SecurityUtil {

    public enum enmSecurityType {

        SHA1(1), SHA512(5), DESede(7), Blowfish(8);

        @SuppressWarnings("unused")
        private int value = 5;

        private enmSecurityType(int value) {
            this.value = value;
        }

        public String getName(int value) {
            String returnValue = "SHA512";

            if (value == 1) returnValue = "SHA1";
            else if (value == 5) returnValue = "SHA512";
            else if (value == 7) returnValue = "DESede";
            else if (value == 8) returnValue = "Blowfish";

            return returnValue;
        }
    }

    /**
     * 비밀번호암호화
     * 
     * @param userId
     * @param pass
     * @param mTypeName
     * @return
     * @throws Exception
     */
    public static String EncryptPassword(String userId, String pass, String mTypeName) {
        String returnValue = "";
        enmSecurityType mtype = enmSecurityType.SHA1;

        try {
            if (pass == "") return pass;

            if (mTypeName == null || mTypeName == "") mtype = enmSecurityType.SHA1;
            else mtype = Enum.valueOf(enmSecurityType.class, mTypeName);

            switch (mtype) {
            case SHA1:
                returnValue = SHA1Util.SHA1(userId.toString() + SHA1Util.SHA1(pass));
                break;
            case SHA512:
                returnValue = SHA512Util.SHA512(userId.toString() + SHA512Util.SHA512(pass));
                break;
            }
        } catch (IllegalArgumentException iae) {
        	System.out.println("Exception : " + iae.toString());
        } catch (Exception e) {
        	System.out.println("Exception : " + e.toString());
        }

        return returnValue;
    }

    /**
     * DESede 암호화
     * 
     * @param plainText
     * @param sharedKey
     * @return
     */
    public static String DESedeEncrypyt(String plainText, String sharedKey) throws Exception {
        String returnValue = "";

        if (sharedKey == null) sharedKey = Constant.getSharedKey();

        TripleDESUtil m = new TripleDESUtil(sharedKey);
        returnValue = m.encrypt(plainText);

        return returnValue;
    }

    /**
     * DESede 복호화
     * 
     * @param cipherText
     * @param sharedKey
     * @return
     */
    public static String DESedeDecrypyt(String cipherText, String sharedKey) throws Exception {
        String returnValue = "";

        if (sharedKey == null) sharedKey = Constant.getSharedKey();

        TripleDESUtil m = new TripleDESUtil(sharedKey);
        returnValue = m.decrypt(cipherText);

        return returnValue;
    }

    /**
     * Blowfish 암호화
     * 
     * @param plainText
     * @param sharedKey
     * @return
     */
    public static String BlowfishEncrypyt(String plainText, String sharedKey) throws Exception {
        String returnValue = "";

        if (plainText.isEmpty() || plainText == null) return "";

        if (sharedKey == null) sharedKey = Constant.getSharedKey();

        BlowfishUtil m = new BlowfishUtil(sharedKey);
        returnValue = m.encrypt(plainText);

        return returnValue;
    }

    /**
     * Blowfish 복호화
     * 
     * @param cipherText
     * @param sharedKey
     * @return
     */
    public static String BlowfishDecrypyt(String cipherText, String sharedKey) throws Exception {
        String returnValue = "";

        if (cipherText.isEmpty() || cipherText == null) return "";

        if (sharedKey == null) sharedKey = Constant.getSharedKey();

        BlowfishUtil m = new BlowfishUtil(sharedKey);
        returnValue = m.decrypt(cipherText);

        return returnValue;
    }

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

        if (sharedKey == null) sharedKey = Constant.getSharedKey();

        AESUtil.setKey(sharedKey, Constant.getSharedKeyBit());
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

        if (sharedKey == null) sharedKey = Constant.getSharedKey();

        AESUtil.setKey(sharedKey, Constant.getSharedKeyBit());
        returnValue = AESUtil.decrypt(cipherText);
        // String strenc = AESUtil.encrypt("780912-3456789");

        return returnValue;
    }

    /**
     * @Method Name : hexToBytes 문자열의 각 글자들의 ascii 값으로 byte 배열로
     * @param str
     * @return
     */
    public static byte[] hexToBytes(String str) {
        if (str == null) {
            return null;
        } else if (str.length() < 2) {
            return null;
        } else {
            int len = str.length() / 2;
            byte[] buffer = new byte[len];
            for (int i = 0; i < len; i++) {
                buffer[i] = (byte) Integer.parseInt(str.substring(i * 2, i * 2 + 2), 16);
            }
            return buffer;
        }

    }

    /**
     * @Method Name : bytesToHex byte 배열의 각각의 값을 해당하는 ascii 문자로 변환해서 문자열로 반환
     * @param data
     * @return
     */
    public static String bytesToHex(byte[] data) {
        if (data == null) {
            return null;
        } else {
            int len = data.length;
            String str = "";
            for (int i = 0; i < len; i++) {
                if ((data[i] & 0xFF) < 16) str = str + "0" + java.lang.Integer.toHexString(data[i] & 0xFF);
                else str = str + java.lang.Integer.toHexString(data[i] & 0xFF);
            }
            return str.toUpperCase();
        }
    }
}
