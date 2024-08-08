package com.bridgetec.argo.common.util;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.bridgetec.argo.common.ConnextionDBInfo;
import com.bridgetec.common.util.security.AESUtil;
import com.bridgetec.common.util.security.SHA512Util;

import egovframework.com.cmm.service.EgovProperties;

public class ServerUtils extends ConnextionDBInfo implements ServletContextListener{
	private static final Logger logger = LoggerFactory.getLogger(ServerUtils.class);

	// 웹 어플리케이션 시작 메소드
    public void contextInitialized(ServletContextEvent arg0) {
        // 웹 어플리케이션 시작 시 처리할 로직..
    	Connection conn = null;
		PreparedStatement cstmt = null; //CallableStatement cstmt = null;
		CallableStatement pstmt  = null;
		ResultSet rs = null;
		
		String macAddr="";
		String macAddrEnc="";
		try {
			// 로컬 IP취득
			InetAddress ip = InetAddress.getLocalHost();

			// 네트워크 인터페이스 취득
			NetworkInterface netif = NetworkInterface.getByInetAddress(ip);
			// 네트워크 인터페이스가 NULL이 아니면
			if (netif != null) {
				// 맥어드레스 취득
				byte[] mac = netif.getHardwareAddress();

				// 맥어드레스 출력
				if(mac != null) {
					for (byte b : mac) {
						macAddr+=String.format("%02X", b);
					}
				}
			}
			
			 String driver = EgovProperties.getProperty("Globals.ARGO.RDB.Driver");
			 String jdbcPath = EgovProperties.getProperty("Globals.ARGO.RDB.Url");
			 String user =EgovProperties.getProperty("Globals.ARGO.RDB.Account");
			 String pw = EgovProperties.getProperty("Globals.ARGO.RDB.Password"); 
			 
			 conn = getConn(driver, jdbcPath, AESUtil.decrypt(user), AESUtil.decrypt(pw));
			 
			 
			 pstmt = conn.prepareCall("{CALL SP_UC_GET_MAC_LIST(?)}");
			 String macList="";
			 String macListEnc="";

			 // tibero : com.tmax.tibero.TbTypes.CURSOR
			 // oracle : oracle.jdbc.driver.OracleTypes.CURSOR
			 pstmt.registerOutParameter(1, com.tmax.tibero.TbTypes.CURSOR);
			 pstmt.execute();
			 
			 rs = (ResultSet)pstmt.getObject(1);
			 while(rs.next()){
				 macList = rs.getString(1);
				 macListEnc = rs.getString(2);
			 }
			 
			 pstmt.close();
			 
			 macList = macList == null ? "" : macList;
			 macListEnc = macListEnc == null ? "" : macListEnc;
			 
			 int yn = 1;
			 if(!macListEnc.equals(SHA512Util.SHA512(macList))){
				 yn=0;
			 }else{
				 if(macList.indexOf(macAddr)!=-1){
					 yn = 1;
				 }else{
					 yn = 0;
				 }
			 }
			 cstmt = conn.prepareStatement("{CALL SP_UC_SET_SERVICE(?)}");
			 cstmt.setInt(1, yn);
			 cstmt.executeQuery();
			 conn.commit();
		} catch (SQLException se) {
			logger.error("Exception : " + se.toString());
		} catch (Exception e) {
			logger.error("Exception : " + e.toString());
		}finally{
			close(conn, cstmt, pstmt);
		}
    }
    
	@Override
	public void contextDestroyed(ServletContextEvent arg0) {
		// TODO Auto-generated method stub
		
	}
}