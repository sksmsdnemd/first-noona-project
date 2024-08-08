package com.bridgetec.common.util.veloce;

/**
 * @(#) CharConversion.java
 *
 * NOTICE !      You can copy or redistribute this code freely,
 * but you should not remove the information about the copyright notice
 * and the author.
 *
 * @author  WonYoung Lee, javaservice@hanmail.net
 */
import java.io.UnsupportedEncodingException;

public final class CharConversion {

	/**
	 * Don't let anyone instantiate this class
	 */
	private CharConversion() {
	}

	/**
	 * 8859_1 --> KSC5601.
	 */
	public static String E2K(String english) {
		String korean = null;

		if (english == null)
			return null;

		try {
			korean = new String(english.getBytes("8859_1"), "KSC5601");
		} catch (UnsupportedEncodingException e) {
			korean = new String(english);
		}
		return korean;
	}

	/**
	 * KSC5601 --> 8859_1.
	 */
	public static String K2E(String korean) {
		String english = null;

		if (korean == null)
			return null;

		english = new String(korean);
		try {
			english = new String(korean.getBytes("KSC5601"), "8859_1");
		} catch (UnsupportedEncodingException e) {
			english = new String(korean);
		}
		return english;
	}
	
	
	/**
	 * ISO-8859-1 --> utf-8
	 */
	public static String chgUtf8(String korean) {
		String result = null;

		if (korean == null)
			return null;

		result = new String(korean);
		try {
			result = new String(korean.getBytes("ISO-8859-1"), "utf-8");
		} catch (UnsupportedEncodingException e) {
			result = new String(korean);
		}
		return result;
	}
	
	/**
	 * utf-8 --> ISO-8859-1
	 */
	public static String chgEucKr(String utf8Str) {
		String result = null;

		if (utf8Str == null)
			return null;

		result = new String(utf8Str);
		try {
			result = new String(utf8Str.getBytes("utf-8"), "ISO-8859-1");
		} catch (UnsupportedEncodingException e) {
			result = new String(utf8Str);
		}
		return result;
	}
	
	/**
	 * 2003.07.10 Add zhangse. 바이트로변환후 한국유니코드적용
	 */
	public static String us2kr(String src) {
		String ret = "";
		try {
			if (src.length() > 0) {
				ret = new String(src.getBytes("8859_1"), "KSC5601");
			}
		} catch (UnsupportedEncodingException uee) {
			System.out.println("Exception : " + uee.toString());
		} catch (Exception e) {
			System.out.println("Exception : " + e.toString());
		}
		return ret;
	}
	
	public static String encode(String str, String charset) {
		StringBuilder sb = new StringBuilder();
		try {
			byte[] key_source = str.getBytes(charset);
			for (byte b : key_source) {
				String hex = String.format("%02x", b).toUpperCase();
				sb.append("%");
				sb.append(hex);
			}
		} catch (UnsupportedEncodingException e) {
			System.out.println("Exception : " + e.toString());
		}// Exception
		return sb.toString();
	}

	public static String decode(String hex, String charset) {
		byte[] bytes = new byte[hex.length() / 3];
		int len = hex.length();
		for (int i = 0; i < len;) {
			int pos = hex.substring(i).indexOf("%");
			if (pos == 0) {
				String hex_code = hex.substring(i + 1, i + 3);
				bytes[i / 3] = (byte) Integer.parseInt(hex_code, 16);
				i += 3;
			} else {
				i += pos;
			}
		}
		try {
			return new String(bytes, charset);
		} catch (UnsupportedEncodingException e) {
			System.out.println("Exception : " + e.toString());
		}// Exception
		return "";
	}

	public static String changeCharset(String str, String charset) {
		try {
			byte[] bytes = str.getBytes(charset);
			return new String(bytes, charset);
		} catch (UnsupportedEncodingException e) {
			System.out.println("Exception : " + e.toString());
		}// Exception
		return "";
	}
}
