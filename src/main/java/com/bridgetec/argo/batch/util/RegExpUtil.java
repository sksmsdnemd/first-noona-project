package com.bridgetec.argo.batch.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * =======================================================
 * 설명 : 정규식 처리 유틸
 * =======================================================
 */
public class RegExpUtil {
	/**
	 *  
	 * @param strData
	 * @param strPattern
	 * @return
	 */
	public static Matcher matchString(String strData, String strPattern) {
		if (strData == null)
			return null;
		Pattern objPattern	= null;
		Matcher		objMatcher	= null;
		objPattern	= Pattern.compile(strPattern);
		objMatcher	= objPattern.matcher(strData);
		return objMatcher;
	}
	
}
