package com.bridgetec.common.util.veloce;

import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

import javax.servlet.http.HttpServletRequest;

public final class StringUtility {

	public StringUtility() {
	}

	public static String fixLength(String input) {
		return fixLength(input, 15, "...");
	}

	public static String fixLength(String input, int limit) {
		return fixLength(input, limit, "...");
	}

	public static String fixLength(String input, int limit, String postfix) {
		String buffer = "";
		char charArray[] = input.toCharArray();
		if (limit >= charArray.length) {
			return input;
		}
		for (int j = 0; j < limit; j++) {
			buffer = buffer + charArray[j];

		}
		buffer = buffer + postfix;
		return buffer;
	}

	public static String head(String s, int size) {
		if (s == null) {
			return "";
		}
		String value = null;
		if (s.length() > size) {
			value = s.substring(0, size) + "...";
		} else {
			value = s;
		}
		return value;
	}

	public static String printStr(String source, String format) {
		if (source == null) {
			return "";
		}
		StringBuffer buf = new StringBuffer();
		char f[] = format.toCharArray();
		char s[] = source.toCharArray();
		int len = f.length;
		int h = 0;
		for (int i = 0; i < len; i++) {
			if (h >= s.length) {
				break;
			}
			if (f[i] == '#') {
				buf.append(s[h++]);
			} else {
				buf.append(f[i]);
			}
		}

		return buf.toString();
	}

	public static String replaceStr(String source, String keyStr,
			String toStr[]) {
		if (source == null) {
			return null;
		}
		int startIndex = 0;
		int curIndex = 0;
		int i = 0;
		StringBuffer result = new StringBuffer();
		String specialString = null;
		while ((curIndex = source.indexOf(keyStr, startIndex)) >= 0) {
			if (i < toStr.length) {
				specialString = toStr[i++];
			} else {
				specialString = " ";
			}
			result.append(source.substring(startIndex, curIndex)).append(
					specialString);
			startIndex = curIndex + keyStr.length();
		}
		if (startIndex <= source.length()) {
			result.append(source.substring(startIndex, source.length()));
		}
		return result.toString();
	}

	public static String replaceStr(String source, String keyStr, String toStr) {
		if (source == null) {
			return null;
		}
		int startIndex = 0;
		int curIndex = 0;
		StringBuffer result = new StringBuffer();
		while ((curIndex = source.indexOf(keyStr, startIndex)) >= 0) {
			result.append(source.substring(startIndex, curIndex)).append(toStr);
			startIndex = curIndex + keyStr.length();
		}
		if (startIndex <= source.length()) {
			result.append(source.substring(startIndex, source.length()));
		}
		return result.toString();
	}

	public static String replaceString(String source, String from, String to) {
		if (source == null || to == null || from == null) {
			return "";
		}
		if (to.indexOf(from) == -1) {
			int index;
			while ((index = source.indexOf(from)) != -1) {
				source = source.substring(0, index)
						+ to
						+ source.substring(index + from.length(), source
								.length());
			}
			return source;
		}
		StringBuffer sb = new StringBuffer();
		int index;
		for (int beforeIndex = 0; (index = source.indexOf(from, beforeIndex)) != -1; beforeIndex = index
				+ from.length()) {
			sb.append(source.substring(beforeIndex, index) + to);

		}
		return sb.toString();
	}

	public static String tail(String s, int size) {
		if (s == null) {
			return "";
		}
		String value = null;
		if (s.length() > size) {
			value = "..." + s.substring(s.length() - size);
		} else {
			value = s;
		}
		return value;
	}

	/**
	 * 게시판 Content 내용 Convert (HTML막기-관리자만 html편집기를 이용하여 html사용)
	 * 
	 * @return the translated string.
	 * @param strContent
	 *            String 변환할 문자열 zhangse 2002.03.15
	 */
	public static String textConvert1(String strContent, String gbn) {

		String returnString = null;

		if (gbn.equals("u")) {
			returnString = StringUtility.replaceStr(strContent, "&", "&amp;");
			returnString = StringUtility.replaceStr(returnString, "<", "&lt;");
			returnString = StringUtility.replaceStr(returnString, ">", "&gt;");
			returnString = StringUtility.replaceStr(returnString, "\n", "<br>");
			returnString = StringUtility.replaceStr(returnString, "'", "''");
		} else if (gbn.equals("a")) {
			returnString = StringUtility.replaceStr(strContent, "'", "''");
		} else {
			returnString = strContent;
		}

		return returnString;
	}

	public static String textConvert2(String strContent, String gbn) {
		String returnString = null;

		if (gbn.equals("u")) {
			returnString = StringUtility.replaceStr(strContent, "<br>", "\n");
			returnString = StringUtility.replaceStr(strContent, "<BR>", "\n");
			returnString = StringUtility.replaceStr(returnString, "''", "'");
			returnString = StringUtility.replaceStr(returnString, "\"\"", "");
		} else if (gbn.equals("a")) {
			returnString = StringUtility.replaceStr(strContent, "''", "'");
			returnString = StringUtility.replaceStr(returnString, "\"\"", "");
		} else if (gbn.equals("m")) {
			returnString = StringUtility.replaceStr(strContent, "\r\n", "<br>");
			returnString = StringUtility.replaceStr(returnString, "''", "'");
			returnString = StringUtility.replaceStr(returnString, "\"\"", "");
		} else {
			returnString = strContent;
		}

		return returnString;
	}

	public static String textConvert3(String strContent) {
		String returnString = null;

		// returnString = StringUtility.replaceStr(strContent,"\n","<br>");
		returnString = StringUtility.replaceStr(strContent, "'", "''");

		return returnString;
	}

	// 게시판 Content 내용 Convert(답변)
	public static String replyConvert(String strContent, String gbn) {
		String returnString = null;

		if (gbn.equals("u")) {
			returnString = StringUtility.replaceStr(strContent, "<br>", "\n>>");

			returnString = StringUtility.replaceStr(returnString, "''", "'");
			returnString = returnString + "\n\n";
		} else if (gbn.equals("a")) {
			returnString = StringUtility.replaceStr(strContent, "<P>", "<P>>>");
			returnString = StringUtility.replaceStr(returnString, "''", "'");

			returnString = returnString + "<br><br>";
		} else {
			returnString = strContent;
		}

		return returnString;
	}

	public static String nvl2(String str, String val) {
		if (str == null){
			return val.trim();
		}
		else if(str.trim().equals("")){
			return val.trim();
		}
		else{
			return str.trim();
		}
	}

	public static String nvl(Object str, String val) {
		if (str == null)
			return val.trim();
		else{
			if( str instanceof java.lang.String ){
				return ((String)str).trim();
			}
			else{
				return str.toString();
			}
		}
	}

	public static String nvl(String str, String val) {
		if (str == null || "".equals(str))
			return val.trim();
		else
			return str.trim();
	}

	public static String[] strSplit(String sentence, String sep_key) {
		StringTokenizer st = new StringTokenizer(sentence, sep_key);
		String[] rtn_array = new String[st.countTokens()];
		
		for (int i = 0; i < rtn_array.length; i++) {
			rtn_array[i] = st.nextElement().toString();
		}
		return rtn_array;
	}
	
	public static String[] split(String str, String regex){
		List list = new ArrayList();
		if( str.indexOf(regex) > -1 ){
			while( str.indexOf(regex) > -1 ){
				list.add(str.substring(0, str.indexOf(regex)));
				if( str.length() >= str.indexOf(regex)+1 ){
					str = str.substring(str.indexOf(regex)+1);
				}
			}
		}
//		if( str.length() > 0 ){
			list.add(str);
//		}
		return (String[])list.toArray(new String[list.size()]);
	}

	
	public static String fill(char c, int length) {
		if (length <= 0)
			return "";
		char ca[] = new char[length];
		for (int index = 0; index < length; index++)
			ca[index] = c;

		return new String(ca);
	}

	public static String padRight(String s, char c, int length) {
		return s + fill(c, length - s.length());
	}

	public static String padLeft(String s, char c, int length) {
		return fill(c, length - s.length()) + s;
	}
	
	public static String cutStr(String s, int i) {

		String ss = s.trim();
		if (ss.equals("")) {
			return ss;
		}
		if (ss.length() > i) {
			return ss.substring(0, i) + "..";
		} else {
			return ss;
		}

	}


	/**
	 * <pre>
	 * rowLen 마다 개행문자 추가
	 * </pre>
	 * @param src
	 * @param rowLen
	 * @return
	 */
	public static String newLine(StringBuffer src, int rowLen){
		return newLine(src.toString(), rowLen); 
	}
	
	/**
	 * <pre>
	 * rowLen 마다 개행문자 추가
	 * </pre>
	 * @param src
	 * @param rowLen
	 * @return
	 */
	public static String newLine(String src, int rowLen){
		StringBuffer buff = new StringBuffer();
		int startIdx = 0;
		int endIdx = 0;
		int len = src.length();
		while(startIdx <= len){
			endIdx = (startIdx+rowLen);
			if( endIdx > len ){
				buff.append(src.substring(startIdx));
			}
			else{
				buff.append(src.substring(startIdx, endIdx));
			}
			startIdx += rowLen;
			if( startIdx > 0 && startIdx <= len && (startIdx+rowLen) <= len){
				buff.append("\n");
			}
		}
		return buff.toString();
	}
	
	public static String cleanXSS(String value) {
		String tmp = value;
		try {
			value = value.replaceAll("<","&lt;").replaceAll(">","&gt;");
			value = value.replaceAll("&lt;p&gt;", "<p>");
			value = value.replaceAll("&lt;P&gt;", "<P>");
			value = value.replaceAll("&lt;br&gt;", "<br>");
			value = value.replaceAll("&lt;BR&gt;", "<BR>");
			value = value.replaceAll("javascript", "x-javascript");
			value = value.replaceAll("script", "x-script");
			value = value.replaceAll("iframe", "x-iframe");
			value = value.replaceAll("document", "x-document");
			value = value.replaceAll("vbscript", "x-vbscript");
			value = value.replaceAll("applet", "x-applet");
			value = value.replaceAll("embed", "x-embed");
			value = value.replaceAll("object", "x-object");
			value = value.replaceAll("frame", "x-frame");
			value = value.replaceAll("grameset", "x-grameset");
			value = value.replaceAll("layer", "x-layer");
			value = value.replaceAll("bgsound", "x-bgsound");
			value = value.replaceAll("alert", "x-alert");
			value = value.replaceAll("onblur", "x-onblur");
			value = value.replaceAll("onchange", "x-onchange");
			value = value.replaceAll("onclick", "x-onclick");
			value = value.replaceAll("ondblclick","x-ondblclick");
			value = value.replaceAll("enerror", "x-enerror");
			value = value.replaceAll("onfocus", "x-onfocus");
			value = value.replaceAll("onload", "x-onload");
			value = value.replaceAll("onmouse", "x-onmouse");
			value = value.replaceAll("onscroll", "x-onscroll");
			value = value.replaceAll("onsubmit", "x-onsubmit");
			value = value.replaceAll("onunload", "x-onunload");
			value = value.replaceAll("\\(","&#40;").replaceAll("\\)","&#41;");
			value = value.replaceAll("\"","&quot;");
			value = value.replaceAll("'","&#x27;");
			//value = value.replaceAll("/","&#x2F;");	//수정 2014-09-04
			value = value.replaceAll("eval\\((.*)\\)","");
			value = value.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']","\"\"");
			value = value.replaceAll("(?i)"+"script","");
			value = value.replaceAll("(?i)"+"select","");
			value = value.replaceAll("(?i)"+"window","");
			value = value.replaceAll("(?i)"+"http","");
			value = value.replaceAll("(?i)"+"alert","");
			value = value.replaceAll("(?i)"+"Content-Type","");
			value = value.replaceAll("(?i)"+"Content-Location","");
			value = value.replaceAll("(?i)"+"Content-Transfer-Encoding","");
		} catch (PatternSyntaxException pse) {
			return tmp;
		} catch (Exception e) {
			return tmp;
		}
		
		return value;
	}
	
	/**
	 * 패스워드 유효성 검증
	 * 
	 * @param passwd
	 * @return
	 */
	public static String passwordValidator(String passwd){
		String returnValue = "success";
		String propFileName = "pw.validation.properties";
		String PWD_CHAR_CHECK = StringUtility.nvl(PathUtility.get("PWD_CHAR_CHECK"), "N");
		
		if("N".equals(PWD_CHAR_CHECK)){
			return returnValue;
		}
		
		String checkType = StringUtility.nvl(PathUtility.get("check.type", propFileName), "1");
		int checkMin = Integer.parseInt(StringUtility.nvl(PathUtility.get("check.min", propFileName), "8"));
		int checkMax = Integer.parseInt(StringUtility.nvl(PathUtility.get("check.max", propFileName), "16"));
		int checkSame = Integer.parseInt(StringUtility.nvl(PathUtility.get("check.same", propFileName), "0"));
		int checkCon = Integer.parseInt(StringUtility.nvl(PathUtility.get("check.con", propFileName), "0"));
		int checkKeybordCon = Integer.parseInt(StringUtility.nvl(PathUtility.get("check.conkey", propFileName), "0"));
		
		if(checkSame < 3 && checkSame != 0 ){
			checkSame = 3;
		}
		if(checkCon < 3 && checkCon != 0 ){
			checkCon = 3;
		}
		if(checkKeybordCon < 3 && checkKeybordCon != 0 ){
			checkKeybordCon = 3;
		}
		
		String typePattern = "";
		String checkTypeMsg = "";
		
		if("1".equals(checkType)){
			typePattern = "(?=.*[a-zA-Z])(?=.*[!@#$%^&*+=-])(?=.*[0-9])";
			checkTypeMsg = "비밀번호는 영문, 숫자, 특수문자(!@#$%^&*+=- 만 허용) 조합으로 입력해주세요";
		}else{
			typePattern = "(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*+=-])";
			checkTypeMsg = "비밀번호는 대문자, 소문자, 숫자, 특수문자(!@#$%^&*+=- 만 허용) 조합으로 입력해주세요";
		}
		
		Pattern p = Pattern.compile(typePattern);
		Matcher m = p.matcher(passwd);
		
		String samePattern = "\\1\\1";
		for(int i=3; i<checkSame; i++){
			samePattern = samePattern + "\\1";
		}
		
		Pattern p2 = Pattern.compile("(\\w)" + samePattern);
		Matcher m2 = p2.matcher(passwd);
		
		Pattern p3 = Pattern.compile("([\\{\\}\\[\\]\\/?.,;:|\\)*~`!^\\-_+&lt;&gt;@\\#$%&amp;\\\\\\=\\(\\'\\\"])" + samePattern);
		Matcher m3 = p3.matcher(passwd);
		
		if(spaceCheck(passwd)){	//패스워드 공백 문자열 체크
			returnValue = "비밀번호에 공백문자를 허용하지 않습니다.";
		}else if(passwd.length() < checkMin || passwd.length() > checkMax){	//자릿수 검증
			returnValue = "비밀번호는 " + Integer.toString(checkMin) +"~" + Integer.toString(checkMax) + "자리로 입력해주세요.";
		}else if(!m.find()){	//정규식 이용한 패턴 체크
			returnValue = checkTypeMsg;
		}else if(checkSame > 2 && (m2.find() || m3.find())){	// 동일 문자 체크
			returnValue = "비밀번호에 동일문자를 " + Integer.toString(checkSame) + "번 이상 사용할 수 없습니다.";
		}else if(checkCon > 2 && continueNumberCheck(passwd, checkCon)){	// 비밀번호 연속 숫자체크
			returnValue = "비밀번호에 연속된 문자를 " + Integer.toString(checkCon) + "자 이상 사용 할 수 없습니다.";
		}else if(checkKeybordCon > 2 && continueNumberKeybordCheck(passwd, checkKeybordCon)){	// 비밀번호 연속 숫자체크
			returnValue = "비밀번호에 QWE처럼 키보드에 연속된 문자를 " + Integer.toString(checkKeybordCon) + "자 이상 사용 할 수 없습니다.";
		}
		
		return returnValue;
	}
	
	/**
	 * 공백 문자 체크
	 * 
	 * @param spaceCheck
	 * @return
	 */
	public static boolean spaceCheck(String spaceCheck){
	    for(int i = 0 ; i < spaceCheck.length() ; i++) {
	        if(spaceCheck.charAt(i) == ' ')
	        	return true;
	    }
	    
	    return false;
	}
	
	/**
	 * 연속된 숫자 체크
	 * 
	 * @param numberCheck
	 * @return 
	 */
	public static boolean continueNumberCheck(String numberCheck, int limit){
		int o = 0;
		int d = 0;
		int p = 0;
		int n = 0;		
		char tempVal;
	    for(int i = 0 ; i < numberCheck.length() ; i++) {
    		tempVal = numberCheck.charAt(i);
    		if (i >0 && Math.abs((p = o - tempVal)) == 1 && (n = p == d ? n + 1 : 0) > limit - 3) {
    			return true;
    		}
	        d = p;
	        o = tempVal;
	    }
	    
	    return false;
	}
	
	/**
	 * 키보드 연속된 문자열 체크
	 * 
	 * @param numberCheck
	 * @return 
	 */
	public static boolean continueNumberKeybordCheck(String numberCheck, int limit){
		String temp = "";
		String val_con2 ="QWERTYUIOP";
		String val_con3 ="ASDFGHJKL";
		String val_con4 ="ZXCVBNM";	
		String val_con5 ="qwertyuiop";	
		String val_con6 ="asdfghjkl";	
		String val_con7 ="zxcvbnm";	
		String ifPw[] = {
				  val_con2
				, reverseString(val_con2)
				, val_con3
				, reverseString(val_con3)
				, val_con4
				, reverseString(val_con4)
				, val_con5
				, reverseString(val_con5)
				, val_con6
				, reverseString(val_con6)
				, val_con7
				, reverseString(val_con7)
				};

		
		for (int i =0 ; i < numberCheck.length() - limit+1 ; i++ ){
			temp = "";
			for(int k=0; k<limit; k++){
				temp = temp + Character.toString(numberCheck.charAt(i + k));
			}
			for ( int j = 0 ; j < ifPw.length ; j ++){

				if ( ifPw[j].indexOf(temp) != -1 ){
					return true;
				}
			}
		}
		return false;
	}
	public static String reverseString(String s) {
	    return ( new StringBuffer(s) ).reverse().toString();
	  }
	
	
	public static String getClientIp(HttpServletRequest request){
		String ip = request.getHeader("X-Forwarded-For");
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { 
		    ip = request.getHeader("Proxy-Client-IP"); 
		} 
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { 
		    ip = request.getHeader("WL-Proxy-Client-IP"); 
		} 
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { 
		    ip = request.getHeader("HTTP_CLIENT_IP"); 
		} 
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { 
		    ip = request.getHeader("HTTP_X_FORWARDED_FOR"); 
		} 
		if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) { 
		    ip = request.getRemoteAddr(); 
		}
		return ip;
	}
}
