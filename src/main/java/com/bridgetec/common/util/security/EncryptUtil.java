package com.bridgetec.common.util.security;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.bridgetec.common.util.veloce.StringUtility;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

public class EncryptUtil {
	
	private static final Logger logger = LoggerFactory.getLogger(EncryptUtil.class);
	private final static int ITERATION_NUMBER = 1000;
	
	public EncryptUtil() {
	}
	
	// "MD5" or "SHA-1" or "SHA-256"
	public String encrypt(String algorithm, String userPwd) {
		String strENCData = "";
		try {
			MessageDigest digest = MessageDigest.getInstance(algorithm);
			digest.update(userPwd.getBytes());

			byte[] input  = digest.digest();
			String	data	= "";
			
			for (int i = 0; i < input.length; i++) {
				data	= StringUtility.padLeft(Integer.toHexString(input[i] & 0xFF), '0', 2);
				strENCData = strENCData	+ data;
			}
		} catch (NoSuchAlgorithmException e) {
			logger.error("암호화 알고리즘이 없습니다.");
		}
		return strENCData;
	}
	

	public byte[] getEncSaltData(String algorithm, String userPwd, byte[] bSalt, boolean flag) 
		throws NoSuchAlgorithmException, UnsupportedEncodingException{
		byte[] bDigest = (flag)?getHash(algorithm, ITERATION_NUMBER, userPwd, bSalt)
								:getHash2(algorithm, ITERATION_NUMBER, userPwd, bSalt);
		return bDigest;
	}
	
	public byte[] getSaltData() 
	throws NoSuchAlgorithmException, UnsupportedEncodingException{
		// Uses a secure Random not a simple Random
		SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
		// Salt generation 64 bits long
		byte[] bSalt = new byte[8];
		random.nextBytes(bSalt);
		return bSalt;
	}
	/**
	* From a base 64 representation, returns the corresponding byte[] 
	* @param data String The base64 representation
	* @return byte[]
	* @throws IOException
	*/
	public byte[] base64ToByte(String data) throws IOException {
		BASE64Decoder decoder = new BASE64Decoder();
		return decoder.decodeBuffer(data);
	}
	 
	/**
	* From a byte[] returns a base 64 representation
	* @param data byte[]
	* @return String
	* @throws IOException
	*/
	public String byteToBase64(byte[] data){
		BASE64Encoder endecoder = new BASE64Encoder();
		return endecoder.encode(data);
	}
	
	/**
	* From a password, a number of iterations and a salt,
	* returns the corresponding digest
	* @param iterationNb int The number of iterations of the algorithm
	* @param password String The password to encrypt
	* @param salt byte[] The salt
	* @return byte[] The digested password
	* @throws NoSuchAlgorithmException If the algorithm doesn't exist
	* @throws UnsupportedEncodingException 
	*/
	public byte[] getHash(String algorithm , int iterationNb, String password, byte[] salt) 
		throws NoSuchAlgorithmException, UnsupportedEncodingException {
		MessageDigest digest = MessageDigest.getInstance(algorithm);
		digest.reset();
		digest.update(salt);
		byte[] input = digest.digest(password.getBytes("UTF-8"));
		//logger.info("[password.getBytes(UTF-8)="+new String(password.getBytes("UTF-8"))+"]");
		for (int i = 0; i < iterationNb; i++) {
			digest.reset();
			input = digest.digest(input);
		}
		
		return input;
	}
	
	/**
	* From a password, a number of iterations and a salt,
	* returns the corresponding digest
	* @param iterationNb int The number of iterations of the algorithm
	* @param password String The password to encrypt
	* @param salt byte[] The salt
	* @return byte[] The digested password
	* @throws NoSuchAlgorithmException If the algorithm doesn't exist
	* @throws UnsupportedEncodingException 
	*/
	public byte[] getHash2(String algorithm , int iterationNb, String password, byte[] salt) 
		throws NoSuchAlgorithmException, UnsupportedEncodingException {
		MessageDigest digest = MessageDigest.getInstance(algorithm);
		digest.reset();
		digest.update(salt);
		byte[] input = digest.digest(password.getBytes("UTF-8"));
		//logger.info("[salt="+new String(salt)+"][password(UTF-8)="+new String(password.getBytes("UTF-8"))+"]");
		//logger.info("[input="+new String(input)+"]");
		return input;
	}
	
	public String getHash3(String algorithm , int iterationNb, String password, byte[] salt) 
	throws NoSuchAlgorithmException, UnsupportedEncodingException {
		String strENCData = "";
		MessageDigest digest = MessageDigest.getInstance(algorithm);
		digest.reset();
		digest.update(password.getBytes("UTF-8"));
		byte[] input = digest.digest(salt);
		String	data	= "";
		StringBuffer hexString = new StringBuffer();
		for (int i = 0; i < input.length; i++) {
			data	= StringUtility.padLeft(Integer.toHexString(input[i] & 0xFF), '0', 2);
			strENCData = strENCData	+ data;
			hexString.append(Integer.toHexString(0xFF & input[i]));
		}
		//logger.info("[salt=" + new String(salt)+"][password(UTF-8)="+new String(password.getBytes("UTF-8"))+"]");
		//logger.info("[input="+ new String(input)+"]");
		//logger.info("[input="+ hexString.toString()+"]");
		return strENCData;
	}
	public static String getHex(byte[] input){
		StringBuffer hexString = new StringBuffer();
		String	strENCData	= "";
		String	data	= "";
		for (int i = 0; i < input.length; i++) {
			data	= StringUtility.padLeft(Integer.toHexString(input[i] & 0xFF), '0', 2);
			strENCData = strENCData	+ data;
			hexString.append(Integer.toHexString(0xFF & input[i]));
		}
		return strENCData;
	}
}
