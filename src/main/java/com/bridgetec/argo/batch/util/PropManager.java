package com.bridgetec.argo.batch.util;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * 설명 : property파일을 읽어들이는 클래스
 */
public class PropManager {
	private static final Map<String,Properties> propMap = new HashMap<String, Properties>();

	// 디폴트 프로퍼티 파일을 읽어들인다.
	static {
		readProperty("account.properties","argoConfig.properties","dbConfig.properties");
	}
	
	/**
	 * 지정한 프로퍼티 파일을 읽어들인다.
	 * @param propNames
	 */
	protected static void readProperty(String... propNames) {
		Properties prop = null;
		ClassLoader cl = null;
		try {
			cl = Thread.currentThread().getContextClassLoader();
			if (cl == null) {
				cl = ClassLoader.getSystemClassLoader();
			}
			for (String propName : propNames) {
				prop = new Properties();
				URL url = cl.getResource(propName);
				if (url == null) {
					continue; // 지정한 프로퍼티가 존재하지 않을 경우 무시
				}
				prop.load(url.openStream());
				propMap.put(propName, prop);
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	/**
	 * 기본환경설정파일로 부터, key에 해당하는 String value를 반환
	 * ※ 기본환경설정파일 : config.properties를 검색
	 * @param key
	 * @return value
	 */
	public static String getStrValue(String key) {
		return propMap.get("argoConfig.properties").getProperty(key);
	}
	/**
	 * 기본환경설정파일로 부터, key에 해당하는 integer value를 반환
	 * ※ 기본환경설정파일 : config.properties를 검색
	 * @param key
	 * @return value (value가 null일 경우 0을 반환)
	 */
	public static int getIntValue(String key) {
		String value = getStrValue(key);
		if (value != null && !value.equals("")) {
			return Integer.parseInt(value);
		}
		return 0;
	}
	/**
	 * 지정한 프로퍼티로 부터, key에 해당하는 String value를 반환
	 * @param propName
	 * @param key
	 * @return value
	 */
	public static String getStrValue(String propName, String key) {
		return propMap.get(propName).getProperty(key);
	}
	/**
	 * 지정한 프로퍼티로 부터, key에 해당하는 integer value를 반환
	 * @param propName
	 * @param key
	 * @return value (value가 null일 경우 0을 반환)
	 */
	public static int getIntValue(String propName, String key) {
		String value = getStrValue(propName, key);
		if (value != null && !"".equals(value)) {
			return Integer.parseInt(value);
		}
		return 0;
	}
	/**
	 * 지정한 프로퍼티로 부터, key에 해당하는 String value를 반환, 값이 없을경우 default 반환
	 * @param propName
	 * @param key
	 * @param defaultVal
	 * @return value
	 */
	public static String getStrValue(String propName, String key, String defaultVal) {
		String returnVal = getStrValue(propName, key);
		if("".equals(StringUtil.nullToSpace(returnVal))){
			returnVal = defaultVal;
		}
		return returnVal;
	}
	/**
	 * 지정한 프로퍼티로 부터, key에 해당하는 String value를 반환, 값이 없을경우 default 반환
	 * @param propName
	 * @param key
	 * @param defaultVal
	 * @return value
	 */
	public static int getIntValue(String propName, String key, int defaultVal) {
		String tempVal = getStrValue(propName, key);
		if("".equals(StringUtil.nullToSpace(tempVal))){
			return defaultVal;
		}
		return Integer.parseInt(tempVal);
	}
	/**
	 * DB설정용 프로퍼티로 부터, key에 해당하는 String value를 반환
	 * @param key
	 * @return value
	 */
	public static String getDBStrValue(String key) {
		return propMap.get("dbConfig.properties").getProperty(key);
	}
	/**
	 * DB설정용 프로퍼티로 부터, key에 해당하는 String value를 반환
	 * @param key
	 * @param defaultVal
	 * @return value
	 */
	public static String getDBStrValue(String key, String defaultVal) {
		return getStrValue("dbConfig.properties", key, defaultVal);
	}
	/**
	 * FTP / DB등 계정정보용 프로퍼티
	 * @param key
	 * @return
	 */
	public static String getAccStr(String key) {
		return getStrValue("account.properties", key);
	}
	
}
