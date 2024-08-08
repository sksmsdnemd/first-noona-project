package com.bridgetec.common.util.security;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class SHA512Util {
    
	public static String SHA512(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException {
		MessageDigest md;
		md = MessageDigest.getInstance("SHA-512");
		byte[] sha1hash = new byte[40];
		md.update(text.getBytes("UTF-8"), 0, text.length());
		sha1hash = md.digest();
		return convertToHex(sha1hash);
	}

	private static String convertToHex(byte[] data) {
	    byte temp;
	    String out = "";
	    String s = "";
		
		for (int i = 0; i < data.length; i++) {
            temp = data[i];
            s = Integer.toHexString(new Byte(temp));
            while (s.length() < 2) {
                s = "0" + s;
            }
            s = s.substring(s.length() - 2);
            out += s;
        }
		
		return out.toString();
	}
}
