package com.bridgetec.argo.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.bridgetec.argo.common.ConnextionDBInfo;
import com.bridgetec.argo.common.util.LicenseDecrypt;
import com.bridgetec.common.util.security.AESUtil;
import com.bridgetec.common.util.security.SHA512Util;

import egovframework.com.cmm.service.EgovProperties;

public class ArgoLicenseService extends ConnextionDBInfo {
	private static final Logger logger = LoggerFactory.getLogger(ArgoLicenseService.class);

	public static String main(String licenseTxt)  throws ParseException, SQLException {

	    Connection conn = null;
		PreparedStatement cstmt = null; //CallableStatement cstmt = null;
		String ret = "fail";
//		String s = "{\"head\":{\"ver\":\"4.0\"},\"master\":{\"company\":\"브리지텍\",\"mac_list\":[\"0A002700000B\",\"08002782de7b\",\"00E04C598097\",\"00E04C59812D\",\"00E04C50EB3B\",\"C85B768442AE\",\"00E04C564EF7\"],\"tenant_list\":[\"BT\",\"TEST\"]},\"body\":{\"tenant\":{\"BT\":{\"name\":\"개발6팀\",\"type\":\"Registered\",\"sdate\":\"20170101\",\"fdate\":\"99991231\",\"user\":50,\"CM\":1,\"HR\":1,\"EDU\":1,\"QA\":1,\"KPI\":1},\"TEST\":{\"name\":\"테스트\",\"type\":\"Trial\",\"sdate\":\"20170101\",\"fdate\":\"20170630\",\"user\":10,\"CM\":1,\"HR\":1,\"EDU\":1,\"QA\":0,\"KPI\":0}}}}";
		String s= LicenseDecrypt.main(licenseTxt);
		
		JSONParser parser = new JSONParser();
		Object obj = parser.parse(s);
		JSONObject jsonObj = (JSONObject) obj;
		JSONObject master = new JSONObject();
		JSONObject body = new JSONObject();
		JSONObject head = new JSONObject();
		
		master = (JSONObject) jsonObj.get("master");
		body = (JSONObject) jsonObj.get("body");
		head = (JSONObject) jsonObj.get("head");
		
		String version = head.get("ver").toString();
		String company = master.get("company").toString();
		String macList = master.get("mac_list").toString().replaceAll("[\\]\\[\"]", "");
		String[] tenantList = master.get("tenant_list").toString().replaceAll("[\\]\\[\"]", "").split(",");
//		String version =jsonObj.get("version").toString();
		
		obj = parser.parse(body.get("tenant").toString());
		
		String query1= "{CALL SP_MNG1010S01_01(?,?,?,?,?,?)}";
		String query2 = "{CALL SP_MNG1010S01_02(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)}";
		
		try {
			/*
			 * ===============================================================
			 * 1. 소스 DB연결
			 * ===============================================================
			 */
			 String driver = EgovProperties.getProperty("Globals.ARGO.RDB.Driver");
			 String jdbcPath = EgovProperties.getProperty("Globals.ARGO.RDB.Url");
			 String user = EgovProperties.getProperty("Globals.ARGO.RDB.Account");
			 String pw = EgovProperties.getProperty("Globals.ARGO.RDB.Password"); 

			 conn = getConn(driver, jdbcPath, AESUtil.decrypt(user), AESUtil.decrypt(pw));
			 
			 cstmt = conn.prepareCall(query1);
			 cstmt.setString(1, licenseTxt);						// 라이센스 키 
			 cstmt.setString(2, company);						// 회사명
			 cstmt.setString(3, macList);							// Mac 주소 리스트
			 cstmt.setString(4, SHA512Util.SHA512(macList));	// Mac 주소 암호화
			 cstmt.setInt(5,tenantList.length);					// 테넌트 갯수
			 cstmt.setString(6, version);								// Version
			 cstmt.executeUpdate();
			 
			 cstmt = conn.prepareCall(query2);
			 
			 jsonObj = (JSONObject) obj;
			 for(int i =0; i<tenantList.length; i++){
					JSONObject tmpJson = (JSONObject)jsonObj.get(tenantList[i]);
					
					String sdate = tmpJson.get("sdate").toString();
					String fdate = tmpJson.get("fdate").toString();
					String type = tmpJson.get("type").toString();
					String moduleEnc = "";
					if(tmpJson.get("CM").toString().equals("1")) moduleEnc += "CM";
					if(tmpJson.get("HR").toString().equals("1")) moduleEnc += "HR";	
					if(tmpJson.get("QA").toString().equals("1")) moduleEnc += "QA";
					if(tmpJson.get("EDU").toString().equals("1")) moduleEnc += "EDU";
					if(tmpJson.get("KPI").toString().equals("1")) moduleEnc += "KPI";
						
					int userCnt = Integer.parseInt(tmpJson.get("user").toString());

					cstmt.setString(1, tenantList[i]);													// 테넌트ID
					cstmt.setString(2, tmpJson.get("name").toString());							// 테넌트명
					cstmt.setString(3, type);																// Type 
					cstmt.setString(4, sdate);																// 시작일
					cstmt.setString(5, fdate);																// 종료일
					cstmt.setInt(6, userCnt);																// 유저
					cstmt.setInt(7, Integer.parseInt(tmpJson.get("CM").toString()));		// CM 모듈 사용여부
					cstmt.setInt(8, Integer.parseInt(tmpJson.get("HR").toString()));		// HR 모듈 사용여부
					cstmt.setInt(9, Integer.parseInt(tmpJson.get("EDU").toString()));		// EDU 모듈 사용여부
					cstmt.setInt(10, Integer.parseInt(tmpJson.get("QA").toString()));		// QA 모듈 사용여부
					cstmt.setInt(11, Integer.parseInt(tmpJson.get("KPI").toString()));		// KPI 모듈 사용여부
					cstmt.setString(12, SHA512Util.SHA512(type));
					cstmt.setString(13, SHA512Util.SHA512(sdate));
					cstmt.setString(14, SHA512Util.SHA512(fdate));
					cstmt.setString(15, SHA512Util.SHA512(Integer.toString(userCnt)));
					cstmt.setString(16, SHA512Util.SHA512(moduleEnc));
					cstmt.executeUpdate();
					
				}
			 
			 cstmt.close();
			 conn.close();
			 
			 ret = "success";
		} catch (NullPointerException npe) {
			if(conn != null) { conn.rollback(); }
			logger.error(npe.toString());
			ret = npe.toString();
		} catch (Exception e) {
			if(conn != null) { conn.rollback(); }
			logger.error(e.toString());
			ret = e.toString();
		} finally {	
			if(cstmt != null) { cstmt.close(); }
			if(conn != null) { conn.close(); }
		}
		return ret;
	}

}
