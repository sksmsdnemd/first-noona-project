package com.bridgetec.common.util.veloce;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import com.bridgetec.common.util.veloce.Config;
import com.bridgetec.common.util.veloce.Configuration;
import com.bridgetec.common.util.veloce.ConfigurationException;

/**
 * PathUtility.java
 * 
 * NOTICE ! You can copy or redistribute this code freely, but you should not
 * remove the information about the copyright notice and the author.
 * 
 * This class is made for coding convenience when writing output path in Servlet
 * 
 * @author SooKyung Lim, carpe@channeli.net
 */

public final class PathUtility {

	/*
	 * Don't let anyone instantiate this class
	 */
	private PathUtility() {
	}

	/*
	 * <p>
	 */
	public static String get(String target) {
		String path = "/"; // 디폴트 디렉토리

		try {
			Config conf = new Configuration();
			path = conf.get(target);
			return path;
		} catch (ConfigurationException e) {
			return path;
		} catch (Exception e) {
			return path;
		}
	}
	
	public static String get(String target, String fileName) {
		String path = "/"; // 디폴트 디렉토리

		try {
			Config conf = new Configuration(fileName);
			path = conf.get(target);
			return path;
		} catch (ConfigurationException e) {
			return path;
		} catch (Exception e) {
			return path;
		}
	}
	
	public static Map getAll() {
		Map	propsMap = null;
		try {
			Config conf = new Configuration();
			Properties	prop = conf.getProperties();
			Set					states 		= prop.keySet();
			Iterator 		itr 			= states.iterator();
			String			keyName		=	"";
			String			keyValue	= "";
			
			propsMap = new HashMap();
			while(itr.hasNext()) { 
				keyName = (String) itr.next();
				keyValue	=	prop.getProperty(keyName);
				propsMap.put(keyName, keyValue);
			}
			return propsMap;
		} catch (ConfigurationException e) {
			return propsMap;
		} catch (Exception e) {
			return propsMap;
		}
	}
	public static Map getAllorgFile(String fileName) {
		Map	propsMap = null;
		try {
			Config conf = new Configuration(fileName);
			Properties	prop = conf.getProperties();
			Set					states 		= prop.keySet();
			Iterator 		itr 			= states.iterator();
			String			keyName		=	"";
			String			keyValue	= "";
			
			propsMap = new HashMap();
			while(itr.hasNext()) { 
				keyName = (String) itr.next();
				keyValue	=	prop.getProperty(keyName);
				propsMap.put(keyName, keyValue);
			}
			return propsMap;
		} catch (ConfigurationException e) {
			return propsMap;
		} catch (Exception e) {
			return propsMap;
		}
	}
	
	
	public static void save(String key, String value) throws ConfigurationException{
		Configuration conf = new Configuration();
		conf.saveConfigFile(key, value);
	}
	
	public static String getNatIp(String kind, String ip) {
		int ipCnt = 5;
		String natUseUserIp = "USER_IP";
		String mfuNatIp = "MFU_NAT_IP1";
		String mrsNatIp1 = "MRS_NAT_IP1";
		String mrsNatIp2 = "MRS_NAT_IP2";
		String propName = "";
		String tempUserIp = "";
		String tempMfuIp = "";
		String tempMrsIp1 = "";
		String tempMrsIp2 = "";
		
		
		try {
			Config conf = new Configuration();
			
			for(int i=0; i<ipCnt; i++){
				tempUserIp = conf.get(natUseUserIp + Integer.toString(i+1));
				tempMfuIp = conf.get(natUseUserIp + Integer.toString(i+1) + "_" + mfuNatIp);
				tempMrsIp1 = conf.get(natUseUserIp + Integer.toString(i+1) + "_" + mrsNatIp1);
				tempMrsIp2 = conf.get(natUseUserIp + Integer.toString(i+1) + "_" + mrsNatIp2);
				
				if(ip.startsWith(tempUserIp) && !"".equals(tempUserIp)){
					if("MFU".equals(kind)){
						return tempMfuIp;
					}else if("MRS1".equals(kind)){
						return tempMrsIp1;
					}else if("MRS2".equals(kind)){
						return tempMrsIp2;
					}else{
						return "";
						
					}
				}
			}
			
			return "";
		} catch (ConfigurationException ce) {
			System.out.println("Exception : " + ce.toString());
			return "";
		} catch (Exception e) {
			System.out.println("Exception : " + e.toString());
			return "";
		}
	}
}
