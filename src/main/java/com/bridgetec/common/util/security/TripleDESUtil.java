package com.bridgetec.common.util.security;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;

public class TripleDESUtil {

    IvParameterSpec iv;
    Cipher          cipher;
    Cipher          decipher;
    SecretKey       sharedKey;

    public TripleDESUtil(String sharedKey) throws Exception {
        try {
            setKey(sharedKey);
            //
            iv = new IvParameterSpec(new byte[8]);
            cipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");
            decipher = Cipher.getInstance("DESede/CBC/PKCS5Padding");

        } catch (NoSuchAlgorithmException nsae) {
            throw new NoSuchAlgorithmException("Failed to initialize the encryption object.");
        } catch (Exception e) {
        	throw new Exception("Failed to initialize the encryption object.");
        }
    }

    private void setKey(String sharedKey) throws Exception {
//        MessageDigest md = MessageDigest.getInstance("md5");
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        EncryptUtil enc = new EncryptUtil();
        md.update(enc.getSaltData());
        byte[] digestOfPassword = md.digest(sharedKey.getBytes("utf-8"));
        byte[] keyBytes = Arrays.copyOf(digestOfPassword, 24);
        //
        for (int j = 0, k = 16; j < 8;) {
            keyBytes[k++] = keyBytes[j++];
        }
        //
        this.sharedKey = new SecretKeySpec(keyBytes, "DESede");
    }

    public String encrypt(String message) throws Exception {
        String returnValue = "";
        byte[] plainTextBytes = null;
        byte[] cipherText = null;
        Base64 encoder = new Base64();
        try {
            cipher.init(Cipher.ENCRYPT_MODE, this.sharedKey, iv);
            plainTextBytes = message.getBytes("utf-8");
            cipherText = cipher.doFinal(plainTextBytes);
            //
            returnValue =  encoder.encodeAsString(cipherText);
        } catch (UnsupportedEncodingException e) {
            throw new UnsupportedEncodingException("Failed to encrypt the plaintext.");
        } catch (IllegalBlockSizeException e) {
        	throw new IllegalBlockSizeException("Failed to encrypt the plaintext.");
        } catch (Exception e) {
        	throw new Exception("Failed to encrypt the plaintext.");
        }
        return returnValue;
    }

    public String decrypt(String message) throws Exception {
        String returnValue = "";
        byte[] encData = null;
        byte[] plainText = null;
        Base64 decoder = new Base64();
        
        try {
            decipher.init(Cipher.DECRYPT_MODE, this.sharedKey, iv);
            encData = decoder.decode(message);
            plainText = decipher.doFinal(encData);
            //
            returnValue = new String(plainText, "utf-8");
        } catch (UnsupportedEncodingException e) {
            throw new UnsupportedEncodingException("Failed to decrypt the ciphertext.");
        } catch (IllegalBlockSizeException e) {
        	throw new IllegalBlockSizeException("Failed to decrypt the ciphertext.");
        } catch (Exception e) {
            throw new Exception("Failed to decrypt the ciphertext.");
        }
        return returnValue;
    }

}
